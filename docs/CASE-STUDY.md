# Case study: protecting Northstar Repairs

**Author:** Shemar Marks

**Context:** synthetic small-business proof of concept

**Deliverable:** working repair application, recoverable infrastructure implementation, and operational engineering record

## Business risk

A small repair shop uses its job register to connect received equipment, work in progress and items ready for collection. The application is useful even when its infrastructure is simple. Its critical weakness is dependence on one manually configured VM: a failed disk or lost server can remove both the records and the knowledge required to recreate the service.

The baseline workload is a Python/SQLite repair desk intended for an Ubuntu VM on Proxmox. The protected implementation adds an independently stored data copy, explicit access controls, operational signals and a repeatable hosting definition. This is a synthetic scenario rather than a claimed client engagement.

## Application delivered

The repair desk persists customer aliases, device/issues, status and UTC creation timestamps. Staff create intake records and move them through Received, In progress, Ready and Collected. Queries are parameterized, displayed data is escaped, invalid inputs are rejected, and state-changing requests require a process-specific CSRF token. The service runs under a dedicated unprivileged identity and exposes a database-aware health endpoint.

This workload establishes a concrete recovery invariant: the original job IDs, records and statuses must return. A green health endpoint alone is insufficient.

## Infrastructure intervention

Terraform defines one encrypted EC2 instance, a dedicated VPC/subnet and outbound route, an instance profile, a private versioned S3 bucket, a log group, four alarms and SNS notifications. There is no public web or SSH ingress. Session Manager supplies remote access; the application listens only on loopback.

Bootstrap installs the release and service, generates an on-host application credential, configures scheduled snapshots/telemetry, and initializes backup/health signals. The release fingerprint changes user data when source changes, making replacement visible in Terraform plans.

SQLite's online backup API captures a consistent dataset during WAL-backed operation. A successful upload alone advances the backup marker. The restore implementation validates the candidate before stopping the service, preserves the old database/journal files, installs the replacement with correct ownership and checks health. Recoverable data is separated from the replaceable root disk.

## Before and implemented after

| Original dependency | Implemented change | Engineering consequence |
|---|---|---|
| Manual server configuration | Terraform and bootstrap | Hosting definition is version-controlled and reconstructable |
| Records confined to one VM | Consistent snapshots uploaded to S3 | A selected dataset can survive root-disk replacement |
| Staff discover failure | Health, disk and backup-freshness signals | Service failure, stale protection and missing telemetry are represented separately |
| Informal recovery knowledge | Restore implementation and runbook | Recovery has defined inputs, validation and rollback behavior |
| Unbounded infrastructure choices | Small compute, standard CPU credits and retention limits | Cost-bearing components remain explicit and proportionate |

These are properties of the delivered implementation, not measurements of a deployed AWS environment.

## Substantiated findings

Local execution verifies authenticated workflow, request controls, restart persistence and consistent snapshots. The local recovery test records deliberate dataset loss and restoration independently of AWS. Terraform formatting and provider-schema validation passed during implementation. The [evidence record](../evidence/README.md) states the exact execution boundary.

Proxmox-to-AWS comparison, enforced AWS permissions, delivered alarm notifications and cloud server replacement remain unobserved. No achieved recovery time, availability improvement or AWS bill is invented.

## Decisions and limits

A standard-library service and SQLite avoid an unrelated container registry or database service. SSM and zero ingress preserve remote access without a public HTTP endpoint. A public address supplies outbound connectivity without NAT Gateway or paid interface endpoints.

The design still has a single-server availability boundary, same-account regional backup, broad HTTPS egress and a shared application identity. The separate production reference adds independent backup protection, individual identities and multiple availability zones where real requirements justify the operating cost.
