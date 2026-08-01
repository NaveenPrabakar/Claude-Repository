#!/usr/bin/env bash
# dynamodb-inventory.sh -- read-only DynamoDB inspection
#
# Usage:
#   ./dynamodb-inventory.sh [region]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
echo "== DynamoDB tables (region: $REGION) =="

TABLES=$(aws_ro dynamodb list-tables --region "$REGION" --query 'TableNames' --output text)
if [[ -z "$TABLES" ]]; then
  echo "  (no tables in this region)"
  exit 0
fi

for t in $TABLES; do
  echo -e "\n-- Table: $t --"
  aws_ro dynamodb describe-table --region "$REGION" --table-name "$t" \
    --query 'Table.{Status:TableStatus,Items:ItemCount,SizeBytes:TableSizeBytes,BillingMode:BillingModeSummary.BillingMode,PartitionKey:KeySchema[0].AttributeName}' \
    --output table
done
