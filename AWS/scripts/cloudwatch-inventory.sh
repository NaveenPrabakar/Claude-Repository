#!/usr/bin/env bash
# cloudwatch-inventory.sh -- read-only CloudWatch alarms + log groups
#
# Usage:
#   ./cloudwatch-inventory.sh [region]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
echo "== CloudWatch inventory (region: $REGION) =="

echo -e "\n-- Alarms currently in ALARM state --"
aws_ro cloudwatch describe-alarms --region "$REGION" --state-value ALARM \
  --query 'MetricAlarms[].{Name:AlarmName,Metric:MetricName,State:StateValue,Reason:StateReason}' \
  --output table

echo -e "\n-- All alarms (summary) --"
aws_ro cloudwatch describe-alarms --region "$REGION" \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue,Metric:MetricName,Namespace:Namespace}' \
  --output table

echo -e "\n-- Log Groups (first 30) --"
aws_ro logs describe-log-groups --region "$REGION" --limit 30 \
  --query 'logGroups[].{Name:logGroupName,RetentionDays:retentionInDays,StoredBytes:storedBytes}' \
  --output table
