#!/usr/bin/env bash
# rds-inventory.sh -- read-only RDS inspection
#
# Usage:
#   ./rds-inventory.sh [region]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
echo "== RDS inventory (region: $REGION) =="

echo -e "\n-- DB Instances --"
aws_ro rds describe-db-instances --region "$REGION" \
  --query 'DBInstances[].{ID:DBInstanceIdentifier,Engine:Engine,Version:EngineVersion,Class:DBInstanceClass,Status:DBInstanceStatus,MultiAZ:MultiAZ,Storage:AllocatedStorage,Endpoint:Endpoint.Address}' \
  --output table

echo -e "\n-- DB Clusters (Aurora) --"
aws_ro rds describe-db-clusters --region "$REGION" \
  --query 'DBClusters[].{ID:DBClusterIdentifier,Engine:Engine,Status:Status,Members:DBClusterMembers[].DBInstanceIdentifier}' \
  --output table

echo -e "\n-- DB Snapshots (manual, last 10) --"
aws_ro rds describe-db-snapshots --region "$REGION" --snapshot-type manual \
  --query 'sort_by(DBSnapshots, &SnapshotCreateTime)[-10:].{ID:DBSnapshotIdentifier,Source:DBInstanceIdentifier,Created:SnapshotCreateTime,Status:Status}' \
  --output table

echo -e "\n-- DB Subnet Groups --"
aws_ro rds describe-db-subnet-groups --region "$REGION" \
  --query 'DBSubnetGroups[].{Name:DBSubnetGroupName,VPC:VpcId,Status:SubnetGroupStatus}' \
  --output table

echo -e "\n-- Parameter Groups --"
aws_ro rds describe-db-parameter-groups --region "$REGION" \
  --query 'DBParameterGroups[].{Name:DBParameterGroupName,Family:DBParameterGroupFamily}' \
  --output table
