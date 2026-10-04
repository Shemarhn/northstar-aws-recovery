data "aws_caller_identity" "current" {}
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
resource "aws_vpc" "lab" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
resource "aws_subnet" "lab" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "lab" { vpc_id = aws_vpc.lab.id }
resource "aws_route_table" "lab" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }
}
resource "aws_route_table_association" "lab" {
  subnet_id      = aws_subnet.lab.id
  route_table_id = aws_route_table.lab.id
}
resource "aws_security_group" "app" {
  name_prefix = "northstar-"
  vpc_id      = aws_vpc.lab.id
  description = "No ingress; outbound HTTPS for SSM S3 monitoring and updates"
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_s3_bucket" "data" {
  bucket_prefix = "northstar-${data.aws_caller_identity.current.account_id}-"
  force_destroy = var.allow_bucket_destroy
}
resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_policy" "tls" {
  bucket = aws_s3_bucket.data.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{
    Effect = "Deny", Principal = "*", Action = "s3:*", Resource = [aws_s3_bucket.data.arn, "${aws_s3_bucket.data.arn}/*"], Condition = { Bool = { "aws:SecureTransport" = "false" } }
  }] })
}
resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket     = aws_s3_bucket.data.id
  depends_on = [aws_s3_bucket_versioning.data]
  rule {
    id     = "backup-retention"
    status = "Enabled"
    filter { prefix = "backups/" }
    expiration { days = 7 }
    noncurrent_version_expiration { noncurrent_days = 7 }
    abort_incomplete_multipart_upload { days_after_initiation = 1 }
  }
}
data "archive_file" "release" {
  type        = "zip"
  source_dir  = "${path.module}/../payload"
  output_path = "${path.module}/release.zip"
}
resource "aws_s3_object" "release" {
  bucket = aws_s3_bucket.data.id
  key    = "release/app.zip"
  source = data.archive_file.release.output_path
  etag   = data.archive_file.release.output_md5
}
resource "aws_iam_role" "app" {
  name_prefix        = "northstar-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_cloudwatch_log_group" "lab" {
  name_prefix       = "/northstar/"
  retention_in_days = 7
}
resource "aws_iam_role_policy" "app" {
  role = aws_iam_role.app.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["s3:GetObject"], Resource = ["${aws_s3_bucket.data.arn}/release/*", "${aws_s3_bucket.data.arn}/backups/*"] },
    { Effect = "Allow", Action = ["s3:PutObject"], Resource = "${aws_s3_bucket.data.arn}/backups/*" },
    { Effect = "Allow", Action = ["s3:ListBucket"], Resource = aws_s3_bucket.data.arn, Condition = { StringLike = { "s3:prefix" = ["backups/*", "backups/"] } } },
    { Effect = "Allow", Action = ["cloudwatch:PutMetricData"], Resource = "*", Condition = { StringEquals = { "cloudwatch:namespace" = "Northstar/Lab" } } },
    { Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"], Resource = "${aws_cloudwatch_log_group.lab.arn}:*" }
  ] })
}
resource "aws_iam_instance_profile" "app" { role = aws_iam_role.app.name }
resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.lab.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.app.name
  user_data_replace_on_change = true
  user_data                   = templatefile("${path.module}/../deploy/bootstrap.sh.tftpl", { bucket = aws_s3_bucket.data.id, region = var.region, log_group = aws_cloudwatch_log_group.lab.name, release_hash = data.archive_file.release.output_md5 })
  metadata_options { http_tokens = "required" }
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }
  credit_specification { cpu_credits = "standard" }
  tags       = { Name = "northstar-lab" }
  depends_on = [aws_s3_object.release, aws_iam_role_policy.app, aws_iam_role_policy_attachment.ssm, aws_route_table_association.lab, aws_s3_bucket_policy.tls, aws_s3_bucket_public_access_block.data]
}
resource "aws_sns_topic" "alerts" { name_prefix = "northstar-" }
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
locals {
  alarms = {
    app    = { metric = "AppHealthy", threshold = 1, comparison = "LessThanThreshold", unit = "Count" }
    disk   = { metric = "DiskUsed", threshold = 80, comparison = "GreaterThanThreshold", unit = "Percent" }
    backup = { metric = "BackupAge", threshold = 7200, comparison = "GreaterThanThreshold", unit = "Seconds" }
  }
}
resource "aws_cloudwatch_metric_alarm" "custom" {
  for_each            = local.alarms
  alarm_name          = "northstar-${each.key}-${aws_instance.app.id}"
  namespace           = "Northstar/Lab"
  metric_name         = each.value.metric
  unit                = each.value.unit
  dimensions          = { InstanceId = aws_instance.app.id }
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  comparison_operator = each.value.comparison
  threshold           = each.value.threshold
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "status" {
  alarm_name          = "northstar-status-${aws_instance.app.id}"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  dimensions          = { InstanceId = aws_instance.app.id }
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
