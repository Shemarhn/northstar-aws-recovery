# Case study: Northstar Repairs

**Author:** Shemar Marks
**Scenario:** synthetic small business, five-person repair shop
**Lab:** Proxmox migration and AWS recovery in us-east-2

## Problem

The repair register connects received equipment with work in progress and customer collections. A single on-premises Proxmox VM placed both the application and its records within one failure boundary. Losing that server threatened the shop's ability to find active jobs and resume work.

## Architecture and implementation

The Python/SQLite app persists job IDs, customer aliases, device issues, status and UTC creation times. Terraform defines a dedicated VPC/subnet, encrypted EC2 root disk, private versioned S3 bucket, instance role, CloudWatch log group, four alarms and SNS notifications. Bootstrap installs the application as an unprivileged systemd service.

Session Manager supports administration and encrypted port forwarding. The app binds to loopback, and the security group defines no inbound rules. IMDSv2 is required. Scoped instance permissions separate release/backup reads from backup writes. These are source-defined controls. The available evidence demonstrates working access and workload recovery, without claiming exhaustive IAM negative testing.

## Migration

The operator completed the Proxmox-to-AWS workload migration in the lab. The project record describes an S3 migration archive and the active AWS application. This closeout recovered the final app and email screenshots and directly inspected the exported migration database with five jobs and integrity ok. No original Proxmox baseline screenshot or migration command transcript was retrieved. The migration is recorded as an operator-observed result, with the retained artifacts identified separately.

## Disaster-recovery exercise

The project record describes deliberate EC2 replacement, an initially empty replacement workload, selection of an S3 backup and restoration of six jobs. It records SQLite integrity `ok`. The final screenshot corroborates the recovered workload with jobs 1–6 and `DR-TEST` in Ready status.

**Measured recovery time: 12 minutes**, as supplied by the operator for one recovery exercise. The retained record does not contain exact start/end timestamps or a complete stopwatch definition. This is an operator-measured exercise result, not an independently recomputed timing or production SLA. The 30-minute design target was met in that exercise. No achieved RPO is inferred from the hourly backup schedule or the surviving marker.

## Monitoring evidence

The original email screenshot shows Northstar app, disk and backup alarms in both `ALARM` and `OK`, plus a status-check alarm for the replacement instance in US East (Ohio). This establishes notification delivery during the lab. The application-health alarm was the alarm under test. Live CloudShell history also shows the service-stop command, a failed health request and metric publication.

## Evidence and outcome

[The evidence index](../evidence/README.md) preserves original screenshots, file hashes, visible recovered rows and source attribution. The prior local and Linux-hosted tests remain valid evidence of application behavior and snapshot recovery.

The lab demonstrated workload migration, independent backup recovery and a functioning notification path. Six validation jobs returned in the recovered app, with an operator-measured 12-minute recovery time. After preserving evidence and backups, the closeout destroyed all 25 Terraform-managed resources and independently verified no active Northstar lab resources remained. [Teardown record](TEARDOWN.md).

## Lessons and limits

A healthy endpoint alone does not prove business recovery. Job count, original IDs, statuses and the recovery marker make the restored workload inspectable. Replacement also changes instance-specific alarm dimensions and regenerates the application password, so recovery includes reconnecting access and using the replacement credential securely.

Store evidence outside the lab before deleting versioned backups. Review both Terraform state and AWS inventories when closing the exercise. Empty state alone does not prove there are no orphaned resources.

The design retains one-server availability, a shared app identity, broad HTTPS egress and same-account regional backup. Versioning is not immutable retention. Production requirements could justify individual identities, independent backup protection and multiple availability zones. This synthetic lab does not claim client delivery, production uptime, cost savings or comprehensive security validation.
