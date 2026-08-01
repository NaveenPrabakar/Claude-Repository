#!/usr/bin/env bash
# iam-audit.sh -- read-only IAM inspection (never touches credentials/secrets)
#
# Usage:
#   ./iam-audit.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

echo "== Caller identity =="
aws_ro_whoami

echo -e "\n== IAM Users =="
aws_ro iam list-users \
  --query 'Users[].{Name:UserName,Created:CreateDate,PasswordLastUsed:PasswordLastUsed}' \
  --output table

echo -e "\n== IAM Roles (first 50) =="
aws_ro iam list-roles --max-items 50 \
  --query 'Roles[].{Name:RoleName,Created:CreateDate}' \
  --output table

echo -e "\n== IAM Groups =="
aws_ro iam list-groups \
  --query 'Groups[].{Name:GroupName,Created:CreateDate}' \
  --output table

echo -e "\n== Customer-managed Policies (first 50) =="
aws_ro iam list-policies --scope Local --max-items 50 \
  --query 'Policies[].{Name:PolicyName,AttachCount:AttachmentCount,Created:CreateDate}' \
  --output table

echo -e "\nNote: this script never calls get-secret-value, download credentials,"
echo "or generate access keys. It only enumerates identities and policy metadata."
