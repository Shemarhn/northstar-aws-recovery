# Project 1: Northstar Repairs recovery lab

A fictional five-person repair shop keeps active repairs on one Proxmox VM. Losing the VM means losing intake records and repair statuses. This project protects that workflow with controlled AWS access, automated consistent backups, monitoring, reproducible deployment and tested recovery.

The working app lets staff create repair jobs and move them through Received, In progress, Ready and Collected. Use synthetic customer aliases only. Python's standard library and SQLite keep deployment small; Docker is unnecessary for this workload.

## Follow this sequence

1. [General installation and migration reference](docs/SETUP.md).
2. [Validate security, alarms and recovery](docs/VALIDATION.md).
3. [Recover or rebuild](docs/RUNBOOK.md).
4. [Capture evidence](docs/EVIDENCE.md) and fill the [case study](docs/CASE-STUDY.md).
5. [Export and destroy safely](docs/CLEANUP.md).

Read [cost assumptions](docs/COSTS.md), [architecture diagrams](docs/ARCHITECTURE.md), [IAM responsibilities](docs/IAM.md), and [actual verification status](docs/VERIFICATION.md) before deployment.

## Repository map

| Folder | Purpose |
|---|---|
| app | Repair tracker, authentication, validation, SQLite persistence |
| deploy | systemd service and AWS cloud-init bootstrap |
| scripts | Installation, packaging, consistent snapshots, S3 backups, telemetry, restore |
| terraform | One EC2, VPC, S3, IAM, CloudWatch and SNS |
| tests | Application workflow/security and SQLite snapshot tests |
| docs | Deployment, operations, validation, diagrams and case study |
| evidence | Result ledger; screenshots must come from actual execution |

The app binds to loopback and runs as an unprivileged service. Proxmox uses an SSH tunnel; AWS uses Session Manager. The AWS security group has no inbound rules. A public address supplies outbound HTTPS without NAT or paid interface endpoints. Hourly backups use SQLite's online snapshot API; the instance can write only the backup prefix and cannot delete backups. S3 blocks public access, encrypts objects, versions data and denies non-TLS access. Three custom metrics and four alarms cover application health, disk usage, backup freshness and EC2 status. Bootstrap and operations logs have seven-day CloudWatch retention.

## Acceptance targets and limits

Targets, not achieved results: normal scheduled-backup RPO ≤60 minutes; recovery RTO ≤30 minutes after detection/operator access. Measure these. Backup failures can exceed that RPO; freshness alarms begin after age exceeds two hours for two five-minute periods.

One server/AZ remains a single point of failure. Backup is in the same account/region; versioning is not immutable retention. One shared credential and SQLite suit synthetic learning, not sensitive client data. Local health checks do not prove end-to-end access. No public TLS endpoint, HA, external uptime checker, user-specific audit or point-in-time restore is claimed. See the production reference separately; it is not deployed.

The baseline is safe on a trusted LAN. Its weakness is manual rebuild, absent off-host scheduled backup and absent monitoring, not deliberately unsafe exposure.

```bash
python3 -m unittest discover -s tests -v
```

Protect local Terraform state and plans; never commit them, credentials, tfvars or private evidence. Commit the generated provider lockfile after Terraform init. The latest AL2023 AMI and package updates mean deployments are repeatable, not bit-for-bit identical; pin resolved versions when needed.

Environment execution is separate from artifact creation. See the verification record for actual completed checks; cloud recovery and screenshots remain unverified until performed.
