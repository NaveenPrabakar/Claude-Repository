#!/usr/bin/env bash
# lambda-inventory.sh -- read-only Lambda inspection
#
# Usage:
#   ./lambda-inventory.sh [region]                    # list all functions
#   ./lambda-inventory.sh [region] <function-name>     # detail on one function

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
FUNC="${2:-}"

if [[ -z "$FUNC" ]]; then
  echo "== Lambda functions (region: $REGION) =="
  aws_ro lambda list-functions --region "$REGION" \
    --query 'Functions[].{Name:FunctionName,Runtime:Runtime,Memory:MemorySize,Timeout:Timeout,LastModified:LastModified}' \
    --output table
  echo -e "\nTip: run './lambda-inventory.sh $REGION <function-name>' for config, env vars, and recent invocations."
else
  echo "== Function detail: $FUNC (region: $REGION) =="

  echo -e "\n-- Configuration --"
  aws_ro lambda get-function-configuration --region "$REGION" --function-name "$FUNC" --output table

  echo -e "\n-- Aliases --"
  aws_ro lambda list-aliases --region "$REGION" --function-name "$FUNC" \
    --query 'Aliases[].{Name:Name,Version:FunctionVersion}' --output table

  echo -e "\n-- Event Source Mappings --"
  aws_ro lambda list-event-source-mappings --region "$REGION" --function-name "$FUNC" \
    --query 'EventSourceMappings[].{Source:EventSourceArn,State:State,Batch:BatchSize}' --output table

  echo -e "\n-- Recent CloudWatch Logs (last 20 events) --"
  LOG_GROUP="/aws/lambda/$FUNC"
  aws_ro logs filter-log-events --region "$REGION" --log-group-name "$LOG_GROUP" \
    --limit 20 --query 'events[].message' --output text 2>/dev/null || echo "(no log group found or no recent events)"
fi
