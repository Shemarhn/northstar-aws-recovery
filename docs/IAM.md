# Access-control implementation

The service has no inbound security-group rule. The listener is loopback; staff reach it through Systems Manager rather than a public web endpoint. Required IMDSv2 is configured on EC2. The application has an unprivileged Linux identity; bootstrap, backup, restore and telemetry use root-owned operational scripts.

## Identity boundaries

| Identity | Scope | Boundary |
|---|---|---|
| Provisioner | Creates compute/network/storage/IAM/monitoring resources | Administrative deployment, not workload least privilege |
| Instance role | SSM agent plus release/backup reads, backup-only puts, namespace-limited metrics and project log streams | No custom-policy backup delete, IAM administration or EC2 administration |
| SSM operator | Starts authorized sessions to the instance | Administrative shell plus sudo has host-level power |
| Application user | Reads and changes synthetic repair records | Shared identity, no individual-user audit |

The SSM managed policy contains wildcard resources for specified agent operations. The custom data policy scopes object access to the project bucket/prefixes. These are distinct permission sets; the entire instance role is not described as universally resource scoped.

## Storage and secrets

S3 public access is blocked, default encryption uses SSE-S3, versioning is enabled and non-TLS requests are denied. EBS encryption uses the AWS-managed key. The generated application password is stored in root-readable /etc/northstar.env and is absent from Terraform user data/state.

State and saved plans contain infrastructure identifiers and remain outside version control. The instance can upload/read selected backups but cannot delete them through its project policy. Privileged account administrators still can; versioning is not immutable protection.

## Accepted limits

HTTPS internet egress is broad, not a network endpoint allowlist. IMDSv2 does not isolate role credentials after host compromise. SSM forwarding payloads are not an application audit trail. Basic auth has no user-specific lockout/reset lifecycle. Same-account regional backup does not address account compromise or regional failure.

This document records configured controls; enforced cloud behavior remains unobserved until account execution. The production reference addresses stronger identity and backup boundaries separately.
