# Verification record

## Executed locally

- Four application/recovery tests passed: workflow, auth/CSRF, input handling, restart persistence, WAL snapshot consistency, missing-source rejection and source-loss recovery.
- A running instance of the application produced the published three-job demonstration response.
- A local dataset was removed, restored from a verified snapshot, and compared by original ID/record/status. All three records matched and integrity_check returned ok.
- Bash syntax checks passed for installation, backup, restore, metrics, packaging and bootstrap.
- Terraform formatting and provider-schema validation passed earlier in this implementation with Terraform 1.9.8, AWS 5.100.0 and archive 2.8.1.

The [evidence directory](../evidence/README.md) contains timestamps, raw test output, source hashes, actual records and a clearly labeled local application image.

The same four tests and Bash syntax checks also passed on a Linux GitHub-hosted runner for commit `09ddece`; the workflow URL and actual log excerpt are preserved in the evidence record.

## Executed Proxmox and AWS lab

The operator completed the Proxmox-to-AWS migration and EC2 replacement recovery in us-east-2. The recovered app screenshot directly shows six jobs, including DR-TEST. The email screenshot directly shows delivered Northstar ALARM and OK notifications.

The prior project record reports zero jobs before S3 restoration, six afterward and SQLite integrity ok. The operator supplied a 12-minute observed recovery duration with UTC endpoints and a complete timing definition. See [recovery timeline](../evidence/disaster-recovery/recovery-timeline.md). The closeout directly checked the recovered application and exported backups, including six jobs and integrity ok. The current operator-supplied record gives 2026-10-04 20:32:16–20:44:16 UTC, including CloudShell recycling and Terraform reinstallation. Original Proxmox screenshots were not retrieved. These results are attributed to the operator/project record rather than presented as new execution here.

## Verification limits

The application-health alarm test is confirmed by live CloudShell history showing a stopped service, failed health check and metrics publication. ALARM/OK delivery appears in the retained email screenshot. Source defines zero ingress, IMDSv2, scoped IAM and hourly S3 backups. Complete permission-denial testing, schedule reliability, achieved RPO, production availability and actual billing totals are not established by the retained artifacts.

Teardown completed: 25 resources destroyed, empty state and independent AWS inventories with zero active lab resources. See [evidence](../evidence/README.md) and [teardown status](TEARDOWN.md).

## Live closeout checks

[Direct CloudShell verification]( ../evidence/disaster-recovery/closeout-checks.md ) confirms the six-job healthy app, SQLite integrity and exported migration/recovery backup contents.
