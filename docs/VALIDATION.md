# Validation plan

All infrastructure checks start NOT RUN. Record UTC start/end, procedure, expected/actual outcome, pass/fail and evidence. Synthetic data only.

| Check | Procedure | Required proof |
|---|---|---|
| Baseline | Create three jobs, change statuses, restart service | Persisted rows and screenshot |
| Local app | Run tests/test_app.py | Actual dated output |
| Migration | Compare all baseline/AWS rows | Matching IDs/statuses/timestamps |
| Network | Inspect SG and `sudo ss -lntp` | No ingress; app loopback only |
| Storage/IMDS | Inspect EC2 settings | Encrypted gp3; tokens required |
| S3 | Inspect block/encryption/versioning/TLS policy | Four configuration captures |
| IAM | Instance tries outside-prefix write | AccessDenied |
| Backup | Run script, list/download selected object | Gzip valid, integrity ok, expected rows |
| Scheduled backup | Observe at least two hourly objects | Real timestamps one hour apart |
| Logs | Inspect bootstrap/operations streams | Seven-day retention and actual messages |
| Alarms | Confirm SNS, inspect metrics, exercise failures | Actual ALARM/OK states and email |
| Data recovery | Canary backup, delete, restore | Canary returns; measured times |
| Server recovery | Terraform replace and S3 restore | New server ID and original records |
| Cleanup | Destroy and enumerate remnants | No live resources; later billing check |

## IAM negative test

SSM, as root:

```bash
sudo bash -c 'source /etc/northstar-aws.env; printf denied >/tmp/northstar-denied; aws s3 cp /tmp/northstar-denied "s3://$BUCKET/forbidden-test"'
```

Expected AccessDenied. If successful, stop and fix IAM; remove unwanted object with operator credentials. Do not test deletion of real backups. SSM's managed role policy is broader for agent operations; describe the project data policy as prefix scoped, not the entire role as universally resource scoped.

## Real application alarm test

SSM: `sudo systemctl stop northstar`. Wait two complete five-minute telemetry periods, allowing ingestion/evaluation delay (about 10–15 minutes). AppHealthy should become 0, alarm should enter ALARM and confirmed SNS email should arrive. Then `sudo systemctl start northstar`, verify health and later OK notification. Record actual times. Explicit stop is not auto-restarted by systemd.

## Backup freshness alarm test

Use a reversible stale marker, away from the hourly boundary:

```bash
sudo cp /var/lib/northstar/last-backup /var/lib/northstar/last-backup.test-save
sudo date -d '3 hours ago' +%s | sudo tee /var/lib/northstar/last-backup
```

Wait two periods, capture BackupAge and alarm. Run a successful backup to restore the current marker and observe OK. This tests freshness logic, not an actual S3 outage.

## Disk alarm test without filling disk

On workstation, use operator credentials to publish this controlled datapoint twice, five minutes apart:

```bash
aws cloudwatch put-metric-data --namespace Northstar/Lab --metric-data "MetricName=DiskUsed,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}],Value=85,Unit=Percent"
```

Maximum aggregation makes these two periods breach. Label evidence **synthetic disk metric test**; later real readings should return OK. Do not claim real disk exhaustion. EC2 status alarm can be verified as configured without triggering it; label actual trigger status NOT RUN. SNS publish alone proves delivery, not alarm evaluation.

For missing telemetry testing, save /etc/cron.d/northstar privately, temporarily remove its metrics line, observe two missing periods breaching, then restore it and verify OK. Leave hourly backup intact. Do not leave telemetry disabled.

## Verify a selected backup

With workstation operator credentials:

```bash
aws s3 ls "s3://$BUCKET/backups/" --recursive
aws s3 cp "s3://$BUCKET/EXACT_KEY" /PRIVATE/PATH/verify.sqlite.gz
gunzip /PRIVATE/PATH/verify.sqlite.gz
python3 -c "import sqlite3; c=sqlite3.connect('/PRIVATE/PATH/verify.sqlite'); print(c.execute('PRAGMA integrity_check').fetchone()); print(c.execute('SELECT count(*) FROM jobs').fetchone())"
```

Select an exact timestamped key; do not assume latest from arbitrary list order. SQLite online backup captures a consistent WAL-backed DB. Record key, snapshot time, integrity and row count. Exported SHA256 detects subsequent file changes; signed/immutable backups are not implemented.

## Data-loss restore

1. Create Recovery-Canary in the UI; record ID and UTC time.
2. Run backup and verify selected object contains that canary before deleting anything.
3. Delete only that ID in SSM, using the numeric ID in this example:

```bash
sudo -u northstar python3 -c "import sqlite3; c=sqlite3.connect('/var/lib/northstar/jobs.sqlite'); c.execute('DELETE FROM jobs WHERE id=?',(CANARY_ID,)); c.commit()"
```

4. Refresh and prove absence. Record recovery start. Run `sudo /opt/northstar/scripts/restore.sh EXACT_KEY`; refresh and prove canary returns; record recovery end.
5. RTO = recovery-end minus recovery-start. Data-loss window = failure-time minus selected snapshot-time. Manual immediate backup does not prove scheduled 60-minute RPO; observe scheduled runs separately.

Full server replacement is in RUNBOOK.md. A green health endpoint alone does not prove recovery of business records.
