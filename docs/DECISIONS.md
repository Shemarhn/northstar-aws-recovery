# Architecture decisions

| Decision | Rationale | Accepted consequence |
|---|---|---|
| Repair workflow | Business records define a recovery invariant | Synthetic, limited scope |
| Standard-library Python and systemd | Few dependencies and visible runtime behavior | No container orchestration |
| SQLite WAL and online snapshot | Consistent backup without pausing intake | Single-node data model |
| One EC2 | Proportionate compute; explicit replacement | Operator-led recovery, no HA |
| SSM and zero ingress | Remote access without public SSH/web ports | AWS identity/agent dependencies |
| Public address for HTTPS egress | Avoid NAT/endpoints recurring costs | IPv4 cost and broad egress |
| SSE-S3 and encrypted EBS | Encryption without custom KMS administration | No independent customer-managed key boundary |
| Scoped data policy without delete | Limits workload backup permissions | Administrators can still delete data |
| Versioning and lifecycle | Previous versions with bounded growth | Not immutable/cross-account backup |
| Backup-age signal | Detects stale protection despite healthy app | Completed upload does not prove restore success |
| Terraform and release fingerprint | Reviewable hosting/source changes | Latest AMI/packages are not immutable inputs |
| Local state | Small single-operator scope | No shared locking; private state is an operational dependency |

The production reference changes assumptions that matter: individual identities, public TLS where required, multiple AZs, managed transactional storage and protected cross-account backups. Its services are separate from this implemented single-server scope.
