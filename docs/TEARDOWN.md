# AWS lab teardown completed

**Verified:** 2026-10-04 21:12:25 UTC (16:12:25 Jamaica)
**Region:** us-east-2
**Terraform workspace:** default, existing CloudShell deployment

## Evidence preserved first

Original recovered-app and CloudWatch/SNS email screenshots, evidence summaries and the editable deck were published to GitHub in commit 16fd1f6 before deletion. All nine S3 object versions were exported outside the lab bucket to ~/northstar-closeout/ in CloudShell. Database copies passed SQLite integrity checks, including the five-job migration archive and six-job recovery archive.

Private state and deployment values remain in CloudShell, with a private archive at ~/northstar-closeout-private.tar.gz. They were not downloaded or published. CloudShell storage is separate from the destroyed lab and is not a permanent archival guarantee.

## Reviewed and applied

allow_bucket_destroy was changed from false to true in the live deployment values. An isolated saved plan changed only the bucket's force_destroy setting, which was applied before planning destruction.

The full saved destroy plan contained **25 managed resources, all delete actions**, with the Northstar instance tag and the lab resource IDs checked. The plan included the versioned bucket and its data. Terraform applied that saved plan successfully at 21:10:29 UTC:

```text
Apply complete! Resources: 0 added, 0 changed, 25 destroyed.
DESTROY_EXIT_CODE=0
```

## Independent post-destroy checks

Terraform state contained zero entries. A new destroy plan reported: No changes. No objects need to be destroyed.

AWS API inventories independently found zero active Northstar EC2 instances, zero resources in the recorded lab VPC (subnets, security groups, routes, interfaces and gateway), zero recorded root volumes and zero volumes attached to either Northstar instance or named Northstar. Both original and replacement EC2 IDs remained only as terminated history.

Northstar-prefixed bucket, IAM role, CloudWatch alarm/log-group and SNS topic/subscription inventories returned zero. The exact recorded IAM instance profile was also absent. S3 and IAM checks used their global APIs. No unrelated resources were deleted.

[Structured verification](../evidence/teardown/verification.json) and [original terminal screenshot](../evidence/teardown/verified-cleanup.png) preserve the outcome. These checks cover the deployed lab and identified Northstar resources, not every account-level service. Historical CloudWatch metric data and terminated instance records can persist. Actual billing may settle later, so no zero-bill claim is made.
