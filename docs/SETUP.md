# Installation and migration reference

These commands are a general project reference. Operators supply their own VM addresses, SSH user, AWS profile, region and alert email. Commands use Bash unless marked otherwise. Do not publish credentials, state, plans or raw account evidence.

## Requirements

Ubuntu 24.04 VM on a trusted LAN; Python 3; AWS CLI v2; Terraform >=1.6 <2; Session Manager plugin; an AWS account permitted to use the selected services. Review COSTS.md before provisioning. Use temporary MFA/SSO administrative credentials for Terraform and confirm identity with `aws sts get-caller-identity`.

## Proxmox baseline

Suggested lab VM: 2 vCPU, 2 GB RAM, 16 GB disk, existing LAN bridge. Install OpenSSH with a normal sudo user. Do not expose the VM or Proxmox administration through router port forwards.

Copy the project to the VM. From its repository root:

```bash
sudo apt-get update
sudo apt-get install -y python3 curl
sudo bash scripts/install.sh
sudo systemctl status northstar --no-pager
curl --fail http://127.0.0.1:8080/health
```

Read `/etc/northstar.env` privately as root to retrieve the generated password. From the workstation:

```bash
ssh -N -L 8080:127.0.0.1:8080 SSH_USER@VM_IP
```

Open localhost:8080, authenticate as owner and create synthetic repair jobs. Confirm persistence after service restart. Baseline limitations: no scheduled off-host backup, alerts or infrastructure rebuild automation.

## Consistent migration export

Freeze baseline writes before cutover. On the VM:

```bash
sudo python3 scripts/snapshot.py /var/lib/northstar/jobs.sqlite /tmp/baseline.sqlite
sudo chown "$USER:$USER" /tmp/baseline.sqlite
gzip /tmp/baseline.sqlite
sha256sum /tmp/baseline.sqlite.gz
```

Securely download the snapshot, record row counts/IDs/statuses and retain Proxmox as rollback source. Accept writes in only one environment during cutover.

## AWS provisioning

From project root:

```bash
bash scripts/package.sh
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Configure region and alert_email privately.
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=lab.tfplan
terraform show lab.tfplan
terraform apply lab.tfplan
terraform output
```

Windows packaging alternative: run scripts/package.ps1 in pwsh where policy permits; otherwise use Bash/WSL. Review costs and every resource before apply. Confirm the SNS subscription email. Failed applies can leave billable resources.

Set values from outputs and the chosen region:

```bash
export AWS_DEFAULT_REGION=REGION
export INSTANCE_ID=$(terraform output -raw instance_id)
export BUCKET=$(terraform output -raw backup_bucket)
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$INSTANCE_ID"
aws ssm start-session --target "$INSTANCE_ID"
```

In SSM, inspect `sudo systemctl status northstar`, `/var/log/northstar-bootstrap.log` and local /health. Retrieve the generated AWS password from /etc/northstar.env privately. Exit the shell. Close any baseline tunnel occupying port 8080; then start forwarding:

```bash
aws ssm start-session --target "$INSTANCE_ID" --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8080"],"localPortNumber":["8080"]}'
```

## Import and accept cutover

Workstation:

```bash
aws s3 cp /PRIVATE/PATH/baseline.sqlite.gz "s3://$BUCKET/backups/migration/baseline.sqlite.gz"
```

SSM:

```bash
sudo /opt/northstar/scripts/restore.sh backups/migration/baseline.sqlite.gz
sudo /opt/northstar/scripts/backup.sh
sudo /opt/northstar/scripts/metrics.sh
```

Refresh browser and compare business records, not just health. Accept AWS writes only after matching the frozen baseline. If validation fails, continue on Proxmox; reconcile any new AWS writes before retrying.

Follow VALIDATION.md and RUNBOOK.md for actual alarm/backup/recovery exercises. Populate EVIDENCE.md/results.csv with observed facts. Finish CLEANUP.md, even after unsuccessful deployment. This lab does not serve public HTTP or deploy the production-reference architecture.
