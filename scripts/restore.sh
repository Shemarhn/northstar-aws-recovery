#!/usr/bin/env bash
set -euo pipefail
# Run as root: restore.sh backups/YYYY/MM/DD/TIMESTAMP.sqlite.gz
source /etc/northstar-aws.env
key=${1:?Pass exact backup object key}
[[ "$key" == backups/*.sqlite.gz ]] || { echo 'Invalid key'; exit 1; }
umask 077
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
aws s3 cp "s3://$BUCKET/$key" "$work/jobs.sqlite.gz" --region "$AWS_DEFAULT_REGION" --only-show-errors
gunzip "$work/jobs.sqlite.gz"
python3 - "$work/jobs.sqlite" <<'PY'
import sqlite3,sys
with sqlite3.connect(sys.argv[1]) as c:
    assert c.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
    print('Restore candidate jobs:',c.execute('SELECT count(*) FROM jobs').fetchone()[0])
PY
systemctl stop northstar
# Preserve the pre-restore database and WAL together for rollback.
rollback="/var/lib/northstar/rollback-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -m 700 "$rollback"
for f in /var/lib/northstar/jobs.sqlite*; do [ ! -e "$f" ] || mv "$f" "$rollback/"; done
install -o northstar -g northstar -m 600 "$work/jobs.sqlite" /var/lib/northstar/jobs.sqlite
systemctl start northstar
curl --retry 10 --retry-connrefused --retry-delay 1 --fail http://127.0.0.1:8080/health
