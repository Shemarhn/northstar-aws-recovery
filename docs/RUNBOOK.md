# Recovery runbook

**Owner:** Shemar Marks. **Workload:** Northstar Repairs proof of concept. Dependencies: AWS access, S3 backup, release payload, protected Terraform state, outbound HTTPS and SSM. App password changes on a fresh server.

## Triage

- App failure: inspect `sudo systemctl status northstar`, `sudo journalctl -u northstar -n 80`, local /health and metrics cron. Missing telemetry differs from app failure.
- Disk: inspect df/logs/private rollback DBs. Do not remove live SQLite/WAL files. Export old rollback material before removing it.
- Stale backup: inspect /var/log/northstar-operations.log, cron, IAM and bucket access; run backup manually and verify object remotely. Marker advances only after upload success.
- Inaccessible instance: check EC2 status, SSM role/agent and outbound route. Do not open inbound SSH as the first fix.

## Restore on an existing instance

1. Freeze staff writes; identify the expected loss since the selected snapshot.
2. Verify the exact backup key and contents using workstation credentials.
3. SSM: `sudo /opt/northstar/scripts/restore.sh EXACT_KEY`.
4. Script downloads and checks integrity before stopping the service; preserves original DB/WAL/SHM in a private rollback directory; installs restored data with correct ownership; restarts and checks health.
5. Refresh browser; compare IDs, statuses, counts and integrity. Run backup/metrics, record elapsed time.
6. If validation fails: stop service, move the newly restored jobs.sqlite* files into a separate private directory, restore ALL original jobs.sqlite* files from the selected rollback directory, restore northstar ownership and start service. Never mix WAL files from different DB versions.

## Replace failed EC2

Confirm a verified backup and privately saved state before replacement. Freeze writes, record exact backup key/old ID and start time. From terraform/:

```bash
terraform plan -replace=aws_instance.app -out=rebuild.tfplan
terraform show rebuild.tfplan
terraform apply rebuild.tfplan
terraform output
```

This destroys the old instance/root disk, retaining S3. The new server starts with EMPTY data and a NEW password. That alone is not recovery.

Wait for SSM/bootstrap, update INSTANCE_ID, retrieve new password privately, restore the verified key, reconnect forwarding to the new instance. Verify original records, run backup and metrics, observe new-ID alarms. Measure RTO including bootstrap/access/restore. Terraform removes old-ID alarms. Failed attempts belong in the incident record.

## Failed bootstrap

Inspect /var/log/cloud-init-output.log and /var/log/northstar-bootstrap.log; check release object, IAM propagation, package install, outbound HTTPS and disk. If SSM works, review and rerun user-data with `sudo bash /var/lib/cloud/instance/scripts/part-001` after fixing the cause. Installation preserves existing password/data. Avoid concurrent restores. If SSM fails, use EC2 console system logs; replace after understanding the cause. CloudWatch shipping may itself have failed.

## Migration rollback and boundaries

Before cutover, resume the frozen Proxmox workload if AWS validation fails. After accepting AWS writes, export both DBs and reconcile records manually before overwriting anything.

Deleted bucket, compromised administrator, revoked account or regional outage exceed this same-account design. Keep an encrypted offline export. Production needs independent protected backups and tested access recovery. The implementation does not provide HA or zero data loss.
