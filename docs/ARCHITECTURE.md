# Architecture

## Proxmox baseline

```mermaid
flowchart LR
    Staff[Staff workstation] -->|SSH tunnel| VM[Proxmox Ubuntu VM]
    VM --> App[Loopback repair desk / systemd]
    App --> DB[(SQLite on VM disk)]
    Loss[VM or disk loss] -.-> DB
```

Manual installation, absent scheduled off-host backup/monitoring, operator-dependent rebuild. Access remains safe on trusted LAN. A Proxmox backup is complementary but counts only if actually configured and restored.

## Deployed single-server lab

```mermaid
flowchart LR
    Staff[Staff / MFA AWS identity] -->|Encrypted tunnel| SSM[Systems Manager]
    SSM <-->|Outbound HTTPS agent| EC2[AL2023 EC2 / public subnet / zero ingress]
    EC2 --> App[Loopback app / unprivileged systemd]
    App --> DB[(Encrypted gp3 / SQLite)]
    EC2 -->|Hourly consistent snapshot| S3[(Private encrypted versioned S3)]
    S3 -->|Release / selected restore| EC2
    EC2 -->|Metrics / operations logs| CW[CloudWatch / four alarms]
    CW --> SNS[Confirmed email]
    IaC[Terraform / protected local state] --> EC2
    IaC --> S3
    EC2 -->|HTTPS via IGW| APIs[AWS APIs / OS repositories]
```

Public IPv4/IGW supply outbound access without NAT or paid endpoints. Zero inbound SG rules; outbound TCP443 only. Amazon-provided VPC DNS works independently of SG egress rules. App credential is generated on host. EBS uses its AWS-managed key; S3 SSE-S3 avoids a custom KMS key. Versioned backups and scoped IAM reduce accidental loss, not privileged compromise. Cron/agent run as root; app runs as northstar. Solo local state has no shared backend locking.

## Production reference — not deployed

```mermaid
flowchart TD
    Users[Individual users / MFA] --> DNS[DNS / managed TLS]
    DNS --> Edge[WAF / public ALB across two AZs]
    Edge --> A[Private app instances AZ A]
    Edge --> B[Private app instances AZ B]
    A --> DB[(Multi-AZ managed relational DB)]
    B --> DB
    A --> Secrets[Secrets Manager / KMS]
    B --> Secrets
    DB --> Backup[Protected cross-account / regional backups]
    CI[Reviewed CI/CD / temporary roles] --> A
    CI --> B
    Ops[SSM / private endpoints or controlled egress] --> A
    Ops --> B
    A --> Monitor[Central logs / audit / external checks]
    B --> Monitor
    Monitor --> Respond[On-call response]
```

Reference only; no production Terraform is supplied. Replace SQLite/shared credentials with managed DB and individual roles, add TLS, multi-AZ scaling, secrets rotation, protected cross-account backup and tested point-in-time restore. Add WAF/rate limits, patches, audit logs, external availability checks and explicit SLO/RPO/RTO requirements. Price private endpoints/controlled egress and recurring services separately. Actual customer information requires appropriate privacy and retention requirements.
