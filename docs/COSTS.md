# Cost controls

Checked against official AWS documentation on 2026-10-03. New accounts use credit-based Free Tier, not the legacy 750-hour/12-month assumption. AWS describes $100 initial credit, opportunities for up to $100 additional credit, and a Free plan lasting six months or credit exhaustion, whichever comes first. Verify your actual signup offer, plan, available services and credit expiration in Billing before deployment. Do not automatically upgrade to Paid plan to complete a lab.

[Announcement](https://aws.amazon.com/about-aws/whats-new/2025/07/aws-free-tier-credits-month-free-plan/), [terms](https://aws.amazon.com/free/terms/), [EC2 eligibility](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html).

## Estimate before apply

Use the [AWS calculator](https://calculator.aws/) for your region with 8 running hours initially, and 730 hours as an accidental-left-running scenario:

`EC2 hourly price × hours + public IPv4 × hours + prorated 8 GB gp3 + S3 storage/versions/requests + metrics/alarms/logs + SNS + data transfer`.

Public IPv4 is listed at $0.005/hour: $0.04 for 8 hours or $3.65 for 730 hours, before eligible credits/allowances. This is the address charge only. [VPC pricing](https://aws.amazon.com/vpc/pricing/), [EC2](https://aws.amazon.com/ec2/pricing/on-demand/), [EBS](https://aws.amazon.com/ebs/pricing/), [S3](https://aws.amazon.com/s3/pricing/), [CloudWatch](https://aws.amazon.com/cloudwatch/pricing/). No fixed total cost or always-free claim is made.

Three custom metrics, four alarms, seven-day logs and small hourly snapshots minimize overhead. Backup current/noncurrent versions expire after seven days; deletion is asynchronous. Release versions remain until teardown. T3 standard credits avoid unlimited surplus charges. Stopping EC2 retains storage costs. No NAT Gateway, load balancer, RDS, paid interface endpoints, Elastic IP, hosted zone or customer-managed KMS key is deployed.

## Budget procedure — manual, outside Terraform

1. Billing → Budgets → Create monthly cost budget, all services; for example USD 5 for a short lab, adjusted to what you accept.
2. Actual alerts at 50%, 80%, 100%; forecast at 100%; send to your email. Inspect credit/refund inclusion. Monitor charges excluding credits too so credit coverage does not hide consumption.
3. Enable available Free Tier usage alerts; check credit balance and expiry. Record controls unavailable under your plan rather than claiming they exist.
4. Check Bills/credits after apply, during the lab and the next day after cleanup. Record planned teardown time and calculator estimate.

Budgets notify; they do not cap spending. Data and notifications lag and charges may exceed thresholds. [AWS Budgets guidance](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html).

## Official tooling

[Terraform installation](https://developer.hashicorp.com/terraform/install), [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html), [SSM sessions](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html).

Creating the repository does not install tools, configure billing, deploy resources or schedule automatic cleanup.
