"""Local recovery invariants for the actual SQLite snapshot implementation."""
from contextlib import closing
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import unittest


SNAPSHOT = Path(__file__).resolve().parents[1] / 'scripts' / 'snapshot.py'
DATA = [
    (1, 'Customer-A', 'Laptop battery', 'In progress'),
    (2, 'Customer-B', 'Phone screen', 'Ready'),
    (3, 'Customer-C', 'Printer feed', 'Received'),
]


class RecoveryTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.source = Path(self.directory.name) / 'source.sqlite'
        self.backup = Path(self.directory.name) / 'snapshot.sqlite'
        with closing(sqlite3.connect(self.source)) as connection:
            connection.execute('PRAGMA journal_mode=WAL')
            connection.execute('CREATE TABLE jobs(id INTEGER PRIMARY KEY, customer TEXT, device TEXT, status TEXT)')
            connection.executemany('INSERT INTO jobs VALUES(?,?,?,?)', DATA)
            connection.commit()

    def tearDown(self):
        self.directory.cleanup()

    def snapshot(self):
        subprocess.run([sys.executable, str(SNAPSHOT), str(self.source), str(self.backup)], check=True)

    def test_snapshot_survives_source_loss(self):
        self.snapshot()
        self.source.unlink()
        self.assertFalse(self.source.exists())
        restored = Path(self.directory.name) / 'restored.sqlite'
        restored.write_bytes(self.backup.read_bytes())
        with closing(sqlite3.connect(restored)) as connection:
            self.assertEqual(connection.execute('PRAGMA integrity_check').fetchone()[0], 'ok')
            self.assertEqual(connection.execute('SELECT * FROM jobs ORDER BY id').fetchall(), DATA)

    def test_committed_wal_data_is_included(self):
        with closing(sqlite3.connect(self.source)) as writer:
            writer.execute('PRAGMA wal_autocheckpoint=0')
            writer.execute('UPDATE jobs SET status=? WHERE id=?', ('Collected', 2))
            writer.commit()
            self.assertTrue(Path(str(self.source) + '-wal').exists())
            self.snapshot()
        with closing(sqlite3.connect(self.backup)) as reader:
            self.assertEqual(reader.execute('SELECT status FROM jobs WHERE id=2').fetchone()[0], 'Collected')
            self.assertEqual(reader.execute('PRAGMA integrity_check').fetchone()[0], 'ok')

    def test_missing_source_is_rejected(self):
        self.source.unlink()
        result = subprocess.run(
            [sys.executable, str(SNAPSHOT), str(self.source), str(self.backup)],
            text=True, capture_output=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Source database missing', result.stderr)
        self.assertFalse(self.backup.exists())


if __name__ == '__main__':
    unittest.main()
