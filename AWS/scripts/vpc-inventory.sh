#!/usr/bin/env bash
# vpc-inventory.sh -- read-only VPC / networking inspection
#
# Usage:
#   ./vpc-inventory.sh [region]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
echo "== Networking inventory (region: $REGION) =="

echo -e "\n-- VPCs --"
aws_ro ec2 describe-vpcs --region "$REGION" \
  --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,Default:IsDefault}' --output table

echo -e "\n-- Subnets --"
aws_ro ec2 describe-subnets --region "$REGION" \
  --query 'Subnets[].{ID:SubnetId,VPC:VpcId,AZ:AvailabilityZone,CIDR:CidrBlock,AvailableIPs:AvailableIpAddressCount}' \
  --output table

echo -e "\n-- Route Tables --"
aws_ro ec2 describe-route-tables --region "$REGION" \
  --query 'RouteTables[].{ID:RouteTableId,VPC:VpcId,Routes:Routes[].DestinationCidrBlock}' --output table

echo -e "\n-- Internet Gateways --"
aws_ro ec2 describe-internet-gateways --region "$REGION" \
  --query 'InternetGateways[].{ID:InternetGatewayId,Attached:Attachments[0].VpcId}' --output table

echo -e "\n-- NAT Gateways --"
aws_ro ec2 describe-nat-gateways --region "$REGION" \
  --query 'NatGateways[].{ID:NatGatewayId,VPC:VpcId,State:State}' --output table

echo -e "\n-- Load Balancers (ALB/NLB) --"
aws_ro elbv2 describe-load-balancers --region "$REGION" \
  --query 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,Scheme:Scheme,DNS:DNSName,State:State.Code}' \
  --output table 2>/dev/null || echo "  (none, or elbv2 not reachable)"
