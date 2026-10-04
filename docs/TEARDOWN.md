# AWS lab teardown record

**Status: pending, not executed.** Region: us-east-2.

The closeout preserved the recovered-app and CloudWatch/SNS email originals locally. The live deployment was operated from CloudShell. This checkout has neither live Terraform state nor deployment values, and no authenticated AWS session was available. Do not initialize a fresh empty state and mistake it for the deployed lab.

## Required execution sequence

1. Use the existing Terraform working directory and verify account, workspace, region and state-owned Northstar resource IDs.
2. Export required S3 recovery/migration backups and evidence outside the bucket. Check downloaded files and hashes. Preserve private state separately, never in the public repo. Screenshots alone are not a backup export.
3. Set allow_bucket_destroy=true in the existing deployment values while retaining region=us-east-2. Confirm the bucket force_destroy setting is persisted in state. If it is still false, review and apply an isolated configuration plan updating only that bucket setting before generating the destruction plan.
4. Generate a saved destroy plan and review every resource against the live state. Reject changes outside this Northstar lab. Include versioned S3 object deletion explicitly in the review.
5. Apply that reviewed saved plan. Record any failed deletions and resolve only within lab scope.
6. Verify empty Terraform managed state and a refreshed destroy plan with no changes. Check the previously recorded EC2/EBS, VPC/subnet/routes/IGW/SG, S3 bucket, IAM role/profile/policies, CloudWatch alarms/log group and SNS topic/subscription IDs directly in AWS.
7. Check for orphaned Northstar resources, including old instance resources, in us-east-2. IAM/S3 checks must also cover their global APIs. Distinguish terminated EC2 history and retained metric history from active resources. Record verification output before stating completion.

## Completion fields

Populate only after execution: account verified privately, Terraform workspace, plan resource count, apply result, deletion failures, remaining-state count, per-service inventory result, evidence/backup export locations and verification timestamp.

No resources have been destroyed by this closeout yet. No zero-resource or zero-cost claim is made.
