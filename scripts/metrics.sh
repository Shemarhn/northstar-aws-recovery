#!/usr/bin/env bash
set -euo pipefail
source /etc/northstar-aws.env
healthy=0
curl --fail --silent --max-time 5 http://127.0.0.1:8080/health >/dev/null && healthy=1
used=$(df --output=pcent /var/lib/northstar | tail -1 | tr -dc '0-9')
age=999999
if [ -f /var/lib/northstar/last-backup ]; then age=$(( $(date +%s) - $(cat /var/lib/northstar/last-backup) )); fi
aws cloudwatch put-metric-data --region "$AWS_DEFAULT_REGION" --namespace Northstar/Lab --metric-data "MetricName=AppHealthy,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}],Value=$healthy,Unit=Count" "MetricName=DiskUsed,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}],Value=$used,Unit=Percent" "MetricName=BackupAge,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}],Value=$age,Unit=Seconds"
