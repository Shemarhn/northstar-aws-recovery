# Recovery timeline: 2026-10-04

This is a sanitized record of the operator-observed exercise, supplied by Shemar Marks in the portfolio execution brief. It is not a newly executed AWS test or a raw terminal transcript. The AWS lab has already been destroyed and must not be recreated for this portfolio.

## Timing boundary

| Event | UTC time |
| --- | --- |
| Operator initiated the deliberate replacement/recovery exercise | 2026-10-04 20:32:16 UTC |
| Restored data, SQLite integrity and application health validated | 2026-10-04 20:44:16 UTC |
| End minus start | **720 seconds / 12 minutes exactly** |

The timer began with operator initiation and ended after all data, integrity and health checks. CloudShell recycled during the exercise and Terraform had to be reinstalled before verification could continue. The timer was not paused. The elapsed result includes that interruption.

## Observed sequence

Intermediate events have no individual timestamps in this supplied record. Their ordering is documented without inventing timing points.

1. Deliberately replace the EC2 application server.
2. Confirm the fresh rebuilt server record count: **0**.
3. Select known-good backup `backups/2026/10/04/20261004T203013Z.sqlite.gz`.
4. Confirm backup SHA256: `2a2bbc0d746c506d728c9981a43329db9b1b54ae12661e661baf32503b44b2d0`.
5. Restore reports **Restore candidate jobs: 6**.
6. Verify all six jobs, including `DR-TEST` / Recovery Validation Record / Ready.
7. Verify SQLite integrity: **ok**.
8. Verify application health: **ok**.
9. Record validated completion at **20:44:16 UTC**.

Infrastructure reconstruction and business-data restoration were separate operations: the new server initially contained zero records.

## What this proves

One operator-observed end-to-end recovery took 12 minutes, including the CloudShell interruption, against a 30-minute design target. The endpoint subtraction is independently reproducible from the supplied times. The recovered-app screenshot and later closeout checks corroborate the final data state.

## What this does not prove

This record does not establish repeatability, a production SLA, measured RPO, production uptime, detection latency or paid-client delivery. Start/end times are operator-supplied evidence, not independently captured terminal timestamps. The app retains single-server availability, shared identity and same-account regional backups. S3 versioning is not immutable backup.

See [observed rows](observed-results.md), [direct closeout checks](closeout-checks.md) and [evidence index](../README.md).
