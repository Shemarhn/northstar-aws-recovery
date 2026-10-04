#!/usr/bin/env bash
set -euo pipefail
source /etc/northstar-aws.env
exec 9>/run/northstar-backup.lock
flock -n 9 || exit 0
umask 077
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
python3 /opt/northstar/scripts/snapshot.py /var/lib/northstar/jobs.sqlite "$work/jobs.sqlite"
gzip "$work/jobs.sqlite"
key="backups/$(date -u +%Y/%m/%d/%Y%m%dT%H%M%SZ).sqlite.gz"
aws s3 cp "$work/jobs.sqlite.gz" "s3://$BUCKET/$key" --region "$AWS_DEFAULT_REGION" --only-show-errors
# Only a completed upload advances the local success marker.
date +%s > /var/lib/northstar/last-backup
logger -t northstar-backup "Uploaded $key"
