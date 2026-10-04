import sqlite3,sys
from contextlib import closing
from pathlib import Path
source,dest=sys.argv[1:]
if not Path(source).is_file(): raise SystemExit('Source database missing')
with closing(sqlite3.connect(source)) as a, closing(sqlite3.connect(dest)) as b:
    a.backup(b)
    if b.execute('PRAGMA integrity_check').fetchone()[0]!='ok': raise SystemExit('Integrity check failed')
