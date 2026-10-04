# IAM and security

Root is for account/billing emergencies, with MFA and no API keys. Use temporary SSO/MFA administrative credentials in a dedicated lab account for Terraform. The provisioner needs EC2/VPC, S3, CloudWatch, SNS, IAM role/profile/policy creation and PassRole. This is broad administrative provisioning; it is not a least-privilege workload identity.

Instance identity: AmazonSSMManagedInstanceCore supports agent communication. The custom policy reads release and backup prefixes, writes only backups, lists only backups, publishes only Northstar/Lab metrics and writes project log streams. It has no backup-delete, IAM-management or EC2-management permission. AWS-managed agent policy has some wildcard-resource actions; describe this accurately.

## Operator role example

Use these statements in a dedicated operator role, replacing REGION, ACCOUNT and INSTANCE. Administrative SSM shells grant sudo host access. For ordinary staff, remove the shell document and permit forwarding only. Console discovery/export/monitoring operations need separate permissions; use provisioner credentials for the lab. This is not a Terraform provisioner policy.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": [
        "arn:aws:ec2:REGION:ACCOUNT:instance/INSTANCE",
        "arn:aws:ssm:REGION::document/AWS-StartPortForwardingSession",
        "arn:aws:ssm:REGION:ACCOUNT:document/SSM-SessionManagerRunShell"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["ssm:ResumeSession", "ssm:TerminateSession"],
      "Resource": "arn:aws:ssm:REGION:ACCOUNT:session/${aws:userid}-*"
    }
  ]
}
```

Validate ownership matching for your federation/role session naming; adapt it if needed. Broad administrator policies attached to the same identity defeat this restriction. Use actual negative tests before claiming restricted operator access.

## Information protection

- Password is root-readable /etc/northstar.env, generated per server, not in user-data/state. Rotate by editing privately and restarting service.
- Basic auth lacks user-specific audit, lockout and reset. Keep synthetic app tunnel-only.
- Local state/plans contain infrastructure identifiers; ignore in Git, encrypt locally and retain privately until cleanup.
- HTTPS internet egress is broad because service/package endpoints vary; not a network allowlist.
- IMDSv2 helps reduce metadata abuse but does not isolate application credentials from host compromise.
- Backups are same-account/region and versioned, not immutable. Privileged administrators can delete them.
- App access logs remain in systemd journal. Bootstrap/operations logs ship to CloudWatch; no full application audit trail is claimed.
