# Northstar Repairs: Proxmox migration and AWS recovery

**Shemar Marks | Completed migration and recovery exercise | AWS us-east-2**

Northstar Repairs is a synthetic five-person repair-shop scenario. Its job register originally depended on one Proxmox VM. The lab migrated the Python/SQLite workload to AWS, separated backups from the application disk, and exercised recovery after replacing the EC2 server.

**Result:** one operator-observed recovery took **12 minutes exactly**, from **20:32:16 to 20:44:16 UTC on 2026-10-04**, including a CloudShell recycle and Terraform reinstallation. [Timing definition](evidence/disaster-recovery/recovery-timeline.md). The recovered application displays **all six validation jobs**, including `DR-TEST`. CloudWatch/SNS emails show delivered `ALARM` and `OK` notifications. [Evidence and measurement limits](evidence/README.md).

![Recovered application with six jobs](evidence/disaster-recovery/post-recovery-app.png)

## Architecture

![AWS implementation topology](docs/diagrams/aws-implementation.svg)

Terraform defines a dedicated VPC, one encrypted EC2 instance, an instance role, private versioned S3 storage, CloudWatch telemetry and SNS alerts. The app listens on loopback. Session Manager provides administration and port forwarding with no security-group ingress. A public address supports outbound HTTPS without a NAT Gateway.

## Observed results

| Exercise | Result | Evidence basis |
|---|---|---|
| Proxmox to AWS migration | Completed in the lab | Operator report and prior project record |
| EC2 replacement and S3 restore | Replacement started empty, then restored six jobs with SQLite integrity `ok` | Prior project record, corroborated by recovered-app screenshot |
| Recovered application | Six jobs visible, including recovery marker | Original screenshot |
| Recovery time | 12 minutes, operator-measured in one exercise | [UTC timeline](evidence/disaster-recovery/recovery-timeline.md): 20:32:16–20:44:16 UTC, including CloudShell interruption |
| Monitoring notifications | App, disk and backup `ALARM`/`OK` emails and status-check alarm delivered | Original email-list screenshot |

The application-health alarm was tested by stopping Northstar and publishing unhealthy metrics. The delivered ALARM and OK emails document the notification path. No measured RPO, availability percentage or cost saving is claimed.

## Engineering record

- [Case study](docs/CASE-STUDY.md)
- [Verification and evidence limits](docs/VERIFICATION.md)
- [Evidence index](evidence/README.md)
- [Recovery timeline and timing boundary](evidence/disaster-recovery/recovery-timeline.md)
- [Case-study presentation](docs/presentation/Northstar-Repairs-Case-Study.pptx)
- [Architecture](docs/ARCHITECTURE.md), [decisions](docs/DECISIONS.md), [security](docs/IAM.md)
- [Recovery runbook](docs/RUNBOOK.md), [costs](docs/COSTS.md), [teardown record](docs/TEARDOWN.md)

## Scope and outcome

The exercise demonstrated a working migration and operator-led recovery of the synthetic repair register. Local and Linux-hosted application/recovery tests also passed. This remains a single-server proof of concept with a shared app credential and same-account regional backups. Hourly snapshots are a design schedule, not a measured RPO guarantee. The 30-minute recovery design target was met by the reported 12-minute exercise, without establishing a repeatable production SLA.

AWS teardown completed after evidence preservation. Terraform destroyed 25 resources, state is empty, and AWS inventories found no active Northstar lab resources. [Verification record](docs/TEARDOWN.md).
