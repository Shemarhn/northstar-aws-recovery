output "instance_id" { value = aws_instance.app.id }
output "backup_bucket" { value = aws_s3_bucket.data.id }
output "log_group" { value = aws_cloudwatch_log_group.lab.name }
output "alert_topic" { value = aws_sns_topic.alerts.arn }
