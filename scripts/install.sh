#!/usr/bin/env bash
set -euo pipefail
# Run as root from repository root; Python 3 must already be installed.
BASE=$(pwd)
id northstar >/dev/null 2>&1 || useradd --system --home /var/lib/northstar --shell /usr/sbin/nologin northstar
install -d -m 755 /opt/northstar /opt/northstar/scripts
install -d -m 750 -o northstar -g northstar /var/lib/northstar
install -m 644 "$BASE/app/server.py" /opt/northstar/server.py
install -m 644 "$BASE/scripts/snapshot.py" /opt/northstar/scripts/snapshot.py
install -m 755 "$BASE/scripts/backup.sh" "$BASE/scripts/metrics.sh" "$BASE/scripts/restore.sh" /opt/northstar/scripts/
if [ ! -f /etc/northstar.env ]; then
  umask 077
  printf 'APP_USER=owner\nAPP_PASSWORD=%s\nDB_PATH=/var/lib/northstar/jobs.sqlite\nAPP_HOST=127.0.0.1\n' "$(python3 -c 'import secrets; print(secrets.token_urlsafe(24))')" > /etc/northstar.env
fi
install -m 644 "$BASE/deploy/northstar.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now northstar
