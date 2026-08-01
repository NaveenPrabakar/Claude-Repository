#!/usr/bin/env bash
# doctor.sh -- sanity-check the environment before running any inventory script
#
# Usage:
#   ./doctor.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

echo "== aws-readonly doctor =="

if ! command -v aws >/dev/null 2>&1; then
  echo "FAIL: aws CLI not found on PATH. Install it and re-run."
  exit 1
fi
echo "OK: aws CLI found -> $(command -v aws)"
echo "    version: $(aws --version)"

echo -e "\nChecking credentials..."
if aws_ro_whoami; then
  echo "OK: credentials are valid."
else
  echo "FAIL: could not authenticate. Run 'aws configure' or check your profile/env vars."
  exit 1
fi

REGION="$(aws configure get region || true)"
if [[ -z "$REGION" ]]; then
  echo -e "\nWARNING: no default region set. Pass a region explicitly to each script,"
  echo "e.g. './ec2-inventory.sh us-east-1', or run 'aws configure set region <region>'."
else
  echo -e "\nOK: default region is '$REGION'."
fi

echo -e "\nAll good. You can run the other scripts in this folder, e.g.:"
echo "  ./ec2-inventory.sh"
echo "  ./s3-inventory.sh"
echo "  ./rds-inventory.sh"
