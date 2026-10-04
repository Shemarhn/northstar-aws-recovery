# Evidence checklist

All environment checks begin NOT RUN. Record UTC times, expected/actual outcome, pass/fail and filename in results.csv. Capture screenshots yourself in actual environments. Keep raw evidence private; publish redacted copies. Redact account IDs, emails, credentials, sessions and any real customer data.

- [ ] Baseline synthetic repairs/statuses, VM details and risk assessment.
- [ ] Frozen snapshot hash, row count and selected records.
- [ ] Reviewed Terraform plan, actual resource list and chosen region/type.
- [ ] No SG ingress; required IMDSv2; encrypted EBS.
- [ ] S3 public block, encryption, versioning, TLS policy.
- [ ] Scoped IAM and actual denied outside-prefix write.
- [ ] AWS migrated records match baseline.
- [ ] At least two scheduled hourly backups, downloaded integrity/row proof.
- [ ] Real telemetry, alarm configuration, bootstrap/operations streams.
- [ ] App stop → ALARM email → restart → OK, actual timestamps.
- [ ] Stale marker and synthetic disk tests clearly labeled.
- [ ] Canary present → deleted → restored, measured times.
- [ ] New instance ID after replacement, original data restored, measured RTO/RPO.
- [ ] Calculator estimate, budget/credits and actual billing observations.
- [ ] Destroy output, independent remnant checks, later billing check.
- [ ] Filled case study with failures, fixes and remaining limits.

Suggested filenames: 01-baseline.png, 02-plan.txt, 03-security.png, 04-migration.png, 05-backup-integrity.txt, 06-app-alarm.png, 07-restore.png, 08-rebuild.txt, 09-cleanup.txt. Raw files go under ignored evidence/private/ or encrypted offline storage.

Do not claim achieved RPO/RTO from design alone. State observed values and test conditions. A healthy endpoint is not proof of recovered records.
