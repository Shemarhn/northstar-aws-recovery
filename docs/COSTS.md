# Cost engineering

The implementation constrains recurring components to one small EC2 instance, an 8 GB gp3 root disk, one public address, S3 objects/requests, three custom metrics, four alarms, seven-day logs and SNS notifications. It excludes NAT Gateway, load balancer, RDS, paid interface endpoints, Elastic IP, hosted zone and a customer-managed KMS key.

T3 standard credits avoid unlimited surplus CPU charges. Backup/current and noncurrent expiration, log retention and explicit bucket teardown constrain storage growth. Stopping compute alone retains storage charges. Release versions remain until teardown.

## Expense model

`compute rate × runtime + IPv4 rate × allocated time + prorated gp3 + S3 storage/versions/requests + telemetry/logs + SNS + transfer`.

Official pricing reviewed on 2026-10-03 lists public IPv4 at $0.005/hour: $0.04 for 8 hours or $3.65 for 730 hours before eligible credits/allowances. These figures cover the address only, not total operating cost. Actual cost depends on region, usage and account offer. No actual AWS bill is available because cloud execution has not occurred.

[VPC pricing](https://aws.amazon.com/vpc/pricing/), [EC2](https://aws.amazon.com/ec2/pricing/on-demand/), [EBS](https://aws.amazon.com/ebs/pricing/), [S3](https://aws.amazon.com/s3/pricing/), [CloudWatch](https://aws.amazon.com/cloudwatch/pricing/).

New-account Free Tier is credit based rather than the legacy 750-hour/12-month assumption. AWS describes $100 initial credit, opportunities for additional credit and a Free plan limited by time/credit exhaustion. Account eligibility is separate from the implementation; this project does not assert zero cost. [Terms](https://aws.amazon.com/free/terms/) and [EC2 eligibility](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html).

AWS Budgets is an account-level notification control outside Terraform. Notifications do not cap expenditure and billing data can lag. Personal account setup and billing checks are maintained outside the portfolio. [Budget behavior](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html).
