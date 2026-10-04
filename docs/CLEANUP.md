# Safe teardown

Finish cleanup even after a failed apply: partial infrastructure can incur costs.

## Export first

Freeze writes, run final backup, download an exact selected key to encrypted private storage outside this repository. Gunzip, integrity-check and verify expected records; record hash. Preserve sanitized evidence, useful logs and private state. Keep the Proxmox baseline until export verification is complete. Terraform does not export logs for you.

## Review account and two-stage deletion

S3 force_destroy defaults false; a nonempty bucket normally blocks deletion. After verified export, from terraform/:

```bash
aws sts get-caller-identity
terraform plan -var='allow_bucket_destroy=true' -out=allow-delete.tfplan
terraform show allow-delete.tfplan
terraform apply allow-delete.tfplan
terraform plan -destroy -var='allow_bucket_destroy=true' -out=destroy.tfplan
terraform show destroy.tfplan
terraform apply destroy.tfplan
```

The first apply records force_destroy permission in state; the second deletes all resources, including ALL S3 versions/backups and the log group. Review both plans and stop if unrelated resources appear. A false-force destroy can still destroy EC2 before failing on S3, so export first. Once true has been applied it stays true until false is applied again.

If destroy fails, inspect `terraform state list`, fix the cause and re-plan; do not delete state to hide errors.

## Verify remnants

- State list empty; independently inspect actual account resources because drift/out-of-state experiments are not covered.
- No running/stopped lab EC2; terminated listings may linger. No orphan EBS, manual snapshots or EIPs.
- S3 bucket and versions gone; log group, alarms, SNS, instance IAM role/profile and lab VPC gone.
- Check other regions used manually.
- Manually created budgets/operator roles are outside Terraform: retain intentionally or remove in their consoles.
- Check Bills/credits later and the next day; reporting lag can show charges after deletion.

Archive verified final backup and teardown evidence privately. Only after completion should state/plans be privately archived or removed. Proxmox is outside AWS teardown; retain or shut down consciously. Stopping EC2 alone leaves storage charges.
