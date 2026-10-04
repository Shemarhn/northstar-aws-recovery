# Implementation specification

This record describes delivered code and configuration. Runtime observations are recorded in evidence/.

## Workload and data

`app/server.py` implements an authenticated HTTP service using Python's standard library. The jobs table stores repair ID, customer alias, device/issue, status and UTC creation timestamp. WAL mode and per-request connections preserve transactions while allowing concurrent reads. Connections are explicitly released.

| Interface | Behavior |
|---|---|
| GET / | Authenticated job register and intake/status forms |
| POST /jobs | Validated, parameterized intake insertion |
| POST /status | Update to one of four defined statuses |
| GET /health | Database query; 200 when accessible, 503 on database errors |

Basic authentication travels inside an SSH/SSM tunnel. A random process token protects submissions. Escaping, content-security policy and input bounds reduce request risks. Shared identity limits the scope; individual-user audit and production identity lifecycle are absent.

## Installation and isolation

Installation places code in /opt/northstar and data in /var/lib/northstar. The northstar system user has no login shell. Reinstallation preserves existing password/data. systemd uses no-new-privileges, private temporary storage, protected system/home paths and one writable data directory. The listener is 127.0.0.1:8080.

## Infrastructure

The Terraform files contain actual resource definitions rather than pseudocode. Provider versions/hashes are committed in the lockfile.

| Resource group | Implementation |
|---|---|
| Network | Dedicated VPC, one subnet, DNS, IGW and default outbound route |
| Traffic | No ingress; TCP443 egress |
| Compute | AL2023 x86, t3.micro default, standard credits, encrypted 8 GB gp3, IMDSv2 |
| Identity | EC2-assumable role/profile, SSM policy and scoped project policy |
| Durable data | Private versioned S3, SSE-S3, TLS-only policy and lifecycle |
| Release | Source ZIP under release/; fingerprint included in user data |
| Monitoring | Seven-day logs, app/disk/backup-age and EC2-status alarms, SNS email |

State is local for the single-operator scope. The AMI parameter follows current AL2023; providers are locked but OS/package inputs are not bit-for-bit immutable.

## Backup and restore

Hourly backup uses a nonblocking lock, the SQLite online backup API, integrity verification and gzip compression. Objects have UTC timestamped keys. Upload failure leaves the successful-backup marker unchanged. The instance cannot delete backups.

Current backup versions expire after seven days; noncurrent versions expire seven days after becoming noncurrent. Lifecycle deletion is asynchronous. This is retention management, not immutable retention or an exact seven-day physical-deletion guarantee.

Restore accepts an exact backups/ key, validates integrity and counts records before stopping the service, preserves original DB/WAL/SHM files together, installs restored data with correct ownership and checks health after restart. Business-record comparison is a separate invariant.

Terraform replacement creates a fresh server with an empty dataset and a new password. Completed recovery requires explicit restore. The [recovery sequence](diagrams/recovery.svg) shows that dependency.

## Detection

Five-minute telemetry publishes AppHealthy, DiskUsed and BackupAge with instance ID dimensions. Alarms use two 300-second periods with missing data treated as breaching. Thresholds are health below 1, disk above 80 percent and backup age above 7,200 seconds. A fourth alarm covers EC2 status. SNS email requires confirmed subscription.

CloudWatch Agent ships bootstrap/operations files. Application access logs remain in systemd journal. External uptime checks and application audit are outside scope.
