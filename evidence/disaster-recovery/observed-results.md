# Attributed recovery results

Source: operator's current closeout request and retrieved Plan Portfolio Project record (2026-10-04). This is a sanitized summary, not raw command output.

- Proxmox-to-AWS workload migration completed in us-east-2.
- Prior record identifies original EC2 i-0cee3abb987d19f8a and replacement i-03fc5a7a6e91fa9a7. Both appear in the retained email screenshot.
- Prior record describes an empty replacement workload, S3 restoration of six jobs and SQLite integrity ok.
- Prior record mentions a recovery backup with suffix 203013Z. The closeout subsequently confirmed the key as backups/2026/10/04/20261004T203013Z.sqlite.gz. See closeout-checks.md for its hash and directly verified contents.
- Operator-observed recovery duration: **12 minutes exactly**, from **2026-10-04 20:32:16 to 20:44:16 UTC**. The endpoint is validated data, integrity and health. Elapsed time includes CloudShell recycling and Terraform reinstallation. [Full timing record](recovery-timeline.md).
- App screenshot corroborates the final six rows below. Creation timestamps are data timestamps, not recovery timing endpoints.

| ID | Alias | Device / issue | Status | Created UTC |
|---|---|---|---|---|
| 1 | CA | Laptop Repairs | In progress | 2026-10-04 18:51:50 |
| 2 | CB | Screen Replacement | Ready | 2026-10-04 18:52:11 |
| 3 | CC | Print paper feed issue | Received | 2026-10-04 18:52:43 |
| 4 | CD | Desktop won't boot | Received | 2026-10-04 18:52:58 |
| 5 | CE | Laptop Overheating | In progress | 2026-10-04 18:53:12 |
| 6 | DR-TEST | Recovery Validation Record | Ready | 2026-10-04 20:29:38 |

The email list shows replacement app ALARM at 15:36 and OK at 15:38 in the mail UI, plus disk/backup transitions. The screenshot does not establish timezone, alarm transition timestamps or root cause. Do not calculate alarm latency or RTO from these inbox times.
