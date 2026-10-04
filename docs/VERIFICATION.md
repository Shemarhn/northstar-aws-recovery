# Verification record

## Executed locally

- Four application/recovery tests passed: workflow, auth/CSRF, input handling, restart persistence, WAL snapshot consistency, missing-source rejection and source-loss recovery.
- A running instance of the application produced the published three-job demonstration response.
- A local dataset was removed, restored from a verified snapshot, and compared by original ID/record/status. All three records matched and integrity_check returned ok.
- Bash syntax checks passed for installation, backup, restore, metrics, packaging and bootstrap.
- Terraform formatting and provider-schema validation passed earlier in this implementation with Terraform 1.9.8, AWS 5.100.0 and archive 2.8.1.

The [evidence directory](../evidence/README.md) contains timestamps, raw test output, source hashes, actual records and a clearly labeled local application image.

## Not observed

No Proxmox/AWS target was executed. Cloud bootstrap, enforced permissions, S3 schedules, alarm delivery, migration comparison, replacement recovery and billing remain unverified. Local file restoration does not demonstrate S3 recovery or the systemd restore path. No measured cloud RPO/RTO is reported.

Source assumptions: [AL2023 AWS CLI](https://docs.aws.amazon.com/linux/al2023/ug/awscli2.html), [preinstalled SSM Agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/ami-preinstalled-agent.html), [AL2023 AMI parameter](https://docs.aws.amazon.com/linux/al2023/ug/ec2.html).
