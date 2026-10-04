# Live closeout verification, 2026-10-04

The existing AWS CloudShell workspace in us-east-2 was inspected during closeout. The application service was restarted after the application-health alarm test. A subsequent check returned:

```text
health: ok
jobs: 6
integrity: ok
```

A final backup and metrics publication completed successfully. All nine available S3 object versions were exported to a private CloudShell directory outside the lab bucket. Current compressed database copies were decompressed and inspected directly:

| Backup filename | Jobs | SQLite integrity |
|---|---:|---|
| 20261004T195901Z.sqlite.gz | 0 | ok |
| 20261004T200002Z.sqlite.gz | 0 | ok |
| 20261004T201211Z.sqlite.gz | 5 | ok |
| 20261004T203013Z.sqlite.gz | 6 | ok |
| 20261004T203743Z.sqlite.gz | 0 | ok |
| 20261004T210001Z.sqlite.gz | 6 | ok |
| 20261004T210153Z.sqlite.gz | 6 | ok |
| northstar-proxmox-migration.sqlite.gz | 5 | ok |

The recovery object key is now confirmed as backups/2026/10/04/20261004T203013Z.sqlite.gz. Its SHA256 is 2a2bbc0d746c506d728c9981a43329db9b1b54ae12661e661baf32503b44b2d0. The migration archive SHA256 is 961bcfc1e52a01246cddbbd36fe7dbba34ecad1b6c38e6007d14d21e2a0ccbe6.

CloudShell history directly showed systemctl stop northstar, failed health curl, metrics publication and date output 2026-10-04 20:50:25 UTC. The original email screenshot provides the notification evidence. This live check does not recompute the earlier operator-measured 12-minute RTO.

Raw screenshots and state include private account/deployment details and remain outside the public evidence set. This is a sanitized record of tool-observed output.
