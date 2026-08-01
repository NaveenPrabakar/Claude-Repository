#!/usr/bin/env bash
# full-report.sh -- run every read-only inventory script in sequence
#
# Usage:
#   ./full-report.sh [region] > report.txt

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGION="${1:-$(aws configure get region || echo us-east-1)}"

echo "########################################"
echo "# AWS read-only report - region: $REGION"
echo "# generated: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo "########################################"

for script in ec2-inventory.sh s3-inventory.sh rds-inventory.sh lambda-inventory.sh \
              ecs-inventory.sh cloudformation-inventory.sh iam-audit.sh vpc-inventory.sh \
              dynamodb-inventory.sh ecr-inventory.sh cloudwatch-inventory.sh; do
  echo -e "\n\n======================================================================"
  echo "# $script"
  echo "======================================================================"
  if [[ "$script" == "iam-audit.sh" ]]; then
    "$SCRIPT_DIR/$script"
  else
    "$SCRIPT_DIR/$script" "$REGION"
  fi
done
