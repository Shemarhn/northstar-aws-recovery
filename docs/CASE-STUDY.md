# Case study — awaiting execution

Northstar Repairs is a fictional repair shop with active jobs stored on one Proxmox VM. VM/disk loss could disrupt collection promises and lose repair records. The goal is recoverable data, failure visibility and an affordable rebuild path.

Built a working intake/status app, assessed baseline risks, described AWS infrastructure in Terraform, provided SSM access, encrypted storage, consistent S3 snapshots, alarms and migration/recovery/cleanup runbooks.

| Concern | Before | Designed improvement | Observed result |
|---|---|---|---|
| Deployment | Manual setup | Terraform + bootstrap | NOT RUN |
| Recovery | No scheduled off-host backup | Hourly versioned S3 snapshots | NOT RUN |
| Detection | Staff notice outage | Five-minute telemetry, two-period alarms | NOT RUN |
| Access | LAN/SSH tunnel | AWS identity/SSM, zero ingress | NOT RUN |
| Server loss | Manual rebuild knowledge | Replacement + selected restore | NOT RUN |
| Costs | No cloud usage | Short runtime, budget/credit checks, cleanup | NOT RUN |

## Fill after testing

- Baseline/migrated rows and matching IDs/statuses: [actual].
- Detection and notification times: [actual UTC timestamps].
- Scheduled backup intervals: [object timestamps].
- Selected backup age at incident/data-loss window: [duration].
- Same-host restore RTO: [definition, duration, evidence].
- Replacement plus restore RTO: [include bootstrap/access].
- Estimate vs actual cost/credit consumption: [date checked].
- Failed checks/corrective actions: [facts].
- Cleanup verified and any intentional remnants: [facts].

Portfolio wording after execution: “Built and tested a recovery-focused AWS environment for a synthetic small-business repair tracker migrated from Proxmox. Demonstrated [proven controls], restored [verified records] in [measured duration], and rebuilt the server with Terraform. A separate production reference addresses HA and protected cross-account backup.”

Do not publish placeholders as results or imply an actual client engagement. Document engineering methods and test conditions accurately.
