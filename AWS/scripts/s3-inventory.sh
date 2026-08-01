#!/usr/bin/env bash
# s3-inventory.sh -- read-only S3 inspection
#
# Usage:
#   ./s3-inventory.sh                 # list all buckets with key metadata
#   ./s3-inventory.sh <bucket-name>   # drill into one bucket (objects, ACL, encryption, versioning)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

BUCKET="${1:-}"

if [[ -z "$BUCKET" ]]; then
  echo "== S3 buckets =="
  aws_ro s3api list-buckets --query 'Buckets[].{Name:Name,Created:CreationDate}' --output table

  echo -e "\nPer-bucket region + public access block (this can take a moment for many buckets):"
  for name in $(aws_ro s3api list-buckets --query 'Buckets[].Name' --output text); do
    region=$(aws_ro s3api get-bucket-location --bucket "$name" --query 'LocationConstraint' --output text 2>/dev/null || echo "?")
    [[ "$region" == "None" ]] && region="us-east-1"
    echo "  $name  region=$region"
  done
  echo -e "\nTip: run './s3-inventory.sh <bucket-name>' to inspect one bucket in depth."
else
  echo "== Bucket detail: $BUCKET =="

  echo -e "\n-- Location --"
  aws_ro s3api get-bucket-location --bucket "$BUCKET" --output table || echo "(unable to read)"

  echo -e "\n-- Versioning --"
  aws_ro s3api get-bucket-versioning --bucket "$BUCKET" --output table || echo "(none configured)"

  echo -e "\n-- Encryption --"
  aws_ro s3api get-bucket-encryption --bucket "$BUCKET" --output table 2>/dev/null || echo "(no default encryption configured)"

  echo -e "\n-- Public Access Block --"
  aws_ro s3api get-public-access-block --bucket "$BUCKET" --output table 2>/dev/null || echo "(no public access block configured -- verify this is intentional)"

  echo -e "\n-- Tags --"
  aws_ro s3api get-bucket-tagging --bucket "$BUCKET" --output table 2>/dev/null || echo "(no tags)"

  echo -e "\n-- Object count / first 25 objects --"
  aws_ro s3api list-objects-v2 --bucket "$BUCKET" --max-items 25 \
    --query 'Contents[].{Key:Key,Size:Size,Modified:LastModified}' --output table
fi
