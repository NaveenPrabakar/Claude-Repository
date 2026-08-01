#!/usr/bin/env bash
# ec2-inventory.sh -- read-only EC2 inspection
#
# Usage:
#   ./ec2-inventory.sh [region]
#
# Prints: instances (state, type, AZ, tags), security groups, VPCs,
# EBS volumes, AMIs owned by this account, key pairs, and Elastic IPs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
echo "== EC2 inventory (region: $REGION) =="

echo -e "\n-- Instances --"
aws_ro ec2 describe-instances --region "$REGION" \
  --query 'Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,State:State.Name,AZ:Placement.AvailabilityZone,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress,Name:Tags[?Key==`Name`]|[0].Value}' \
  --output table

echo -e "\n-- Security Groups --"
aws_ro ec2 describe-security-groups --region "$REGION" \
  --query 'SecurityGroups[].{ID:GroupId,Name:GroupName,VPC:VpcId}' \
  --output table

echo -e "\n-- VPCs --"
aws_ro ec2 describe-vpcs --region "$REGION" \
  --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,IsDefault:IsDefault,State:State}' \
  --output table

echo -e "\n-- EBS Volumes --"
aws_ro ec2 describe-volumes --region "$REGION" \
  --query 'Volumes[].{ID:VolumeId,Size:Size,State:State,Type:VolumeType,AttachedTo:Attachments[0].InstanceId}' \
  --output table

echo -e "\n-- Key Pairs --"
aws_ro ec2 describe-key-pairs --region "$REGION" \
  --query 'KeyPairs[].{Name:KeyName,Type:KeyType,Fingerprint:KeyFingerprint}' \
  --output table

echo -e "\n-- Elastic IPs --"
aws_ro ec2 describe-addresses --region "$REGION" \
  --query 'Addresses[].{IP:PublicIp,InstanceID:InstanceId,AllocationID:AllocationId}' \
  --output table
