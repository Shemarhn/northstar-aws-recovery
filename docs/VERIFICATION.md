# Actual verification status

Artifact creation and local checks completed on 2026-10-03. No Proxmox or AWS environment was accessed or deployed.

| Check | Actual result |
|---|---|
| Python 3.12 application integration test | PASS: one comprehensive test, including HTTP auth rejection, CSRF rejection, job creation/update, HTML escaping, invalid input rejection, online snapshot row/integrity checking and persistence across process restart |
| PowerShell payload packaging | PASS in the available pwsh session; Windows PowerShell separately blocked execution under its policy, so the guide provides a Bash/WSL alternative |
| Terraform 1.9.8 init, backend disabled | PASS; signed AWS 5.100.0 and archive 2.8.1 providers downloaded; lockfile created |
| Terraform validate | PASS: configuration valid against installed provider schemas |
| Terraform fmt check | PASS |
| Bash syntax checks | PASS for installation, backup, metrics, restore and bootstrap template; not a runtime deployment test |
| Repository links/release archive | Checked locally during packaging |
| Bash/systemd/dnf/cloud-init runtime | NOT RUN: no Linux target used |
| Terraform plan/apply/destroy against AWS | NOT RUN: no account credentials supplied |
| AWS IAM/network/monitoring/backup/recovery tests | NOT RUN |
| Proxmox baseline/migration tests | NOT RUN |
| Cost/credit eligibility and budgets in your account | NOT RUN; official documentation reviewed, account offer must be checked |
| Environment screenshots | NOT CAPTURED; evidence checklist supplied |

Local validation does not prove OS installation, cloud bootstrap, IAM enforcement or recoverability in your account. Execute the deployment/validation guides, save actual results and update this status before publishing outcome claims. No successful cloud test or achieved RPO/RTO is fabricated.

Source assumptions: [AL2023 AWS CLI](https://docs.aws.amazon.com/linux/al2023/ug/awscli2.html), [preinstalled SSM Agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/ami-preinstalled-agent.html), [AL2023 AMI parameter](https://docs.aws.amazon.com/linux/al2023/ug/ec2.html). Costs and Free Tier references are in COSTS.md.
