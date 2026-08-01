#!/usr/bin/env bash
# cloudformation-inventory.sh -- read-only CloudFormation inspection
#
# Usage:
#   ./cloudformation-inventory.sh [region]                # list all stacks
#   ./cloudformation-inventory.sh [region] <stack-name>    # detail + resources + recent events

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
STACK="${2:-}"

if [[ -z "$STACK" ]]; then
  echo "== CloudFormation stacks (region: $REGION) =="
  aws_ro cloudformation describe-stacks --region "$REGION" \
    --query 'Stacks[].{Name:StackName,Status:StackStatus,Created:CreationTime,Updated:LastUpdatedTime}' \
    --output table
  echo -e "\nTip: run './cloudformation-inventory.sh $REGION <stack-name>' for resources + drift + recent events."
else
  echo "== Stack detail: $STACK (region: $REGION) =="

  echo -e "\n-- Stack info --"
  aws_ro cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
    --query 'Stacks[0].{Status:StackStatus,Created:CreationTime,Description:Description}' --output table

  echo -e "\n-- Resources --"
  aws_ro cloudformation describe-stack-resources --region "$REGION" --stack-name "$STACK" \
    --query 'StackResources[].{Type:ResourceType,LogicalID:LogicalResourceId,PhysicalID:PhysicalResourceId,Status:ResourceStatus}' \
    --output table

  echo -e "\n-- Recent events (last 15) --"
  aws_ro cloudformation describe-stack-events --region "$REGION" --stack-name "$STACK" \
    --query 'StackEvents[:15].{Time:Timestamp,Resource:LogicalResourceId,Status:ResourceStatus,Reason:ResourceStatusReason}' \
    --output table

  echo -e "\n-- Outputs --"
  aws_ro cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
    --query 'Stacks[0].Outputs' --output table
fi
