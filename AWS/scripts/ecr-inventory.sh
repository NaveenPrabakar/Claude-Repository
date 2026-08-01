#!/usr/bin/env bash
# ecr-inventory.sh -- read-only ECR inspection
#
# Usage:
#   ./ecr-inventory.sh [region]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
echo "== ECR repositories (region: $REGION) =="

aws_ro ecr describe-repositories --region "$REGION" \
  --query 'repositories[].{Name:repositoryName,URI:repositoryUri,CreatedAt:createdAt,ScanOnPush:imageScanningConfiguration.scanOnPush}' \
  --output table

for repo in $(aws_ro ecr describe-repositories --region "$REGION" --query 'repositories[].repositoryName' --output text); do
  echo -e "\n-- Images in $repo (most recent 10) --"
  aws_ro ecr describe-images --region "$REGION" --repository-name "$repo" \
    --query 'sort_by(imageDetails, &imagePushedAt)[-10:].{Tags:imageTags,Pushed:imagePushedAt,SizeMB:`imageSizeInBytes`}' \
    --output table 2>/dev/null || echo "  (no images)"
done
