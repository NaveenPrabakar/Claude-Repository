#!/usr/bin/env bash
# ecs-inventory.sh -- read-only ECS + EKS inspection
#
# Usage:
#   ./ecs-inventory.sh [region]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/aws-guard.sh"

REGION="${1:-$(aws configure get region || echo us-east-1)}"
echo "== ECS inventory (region: $REGION) =="

echo -e "\n-- Clusters --"
CLUSTER_ARNS=$(aws_ro ecs list-clusters --region "$REGION" --query 'clusterArns' --output text)
if [[ -n "$CLUSTER_ARNS" ]]; then
  aws_ro ecs describe-clusters --region "$REGION" --clusters $CLUSTER_ARNS \
    --query 'clusters[].{Name:clusterName,Status:status,ActiveServices:activeServicesCount,RunningTasks:runningTasksCount}' \
    --output table

  for cluster in $CLUSTER_ARNS; do
    echo -e "\n-- Services in $cluster --"
    SERVICE_ARNS=$(aws_ro ecs list-services --region "$REGION" --cluster "$cluster" --query 'serviceArns' --output text)
    if [[ -n "$SERVICE_ARNS" ]]; then
      aws_ro ecs describe-services --region "$REGION" --cluster "$cluster" --services $SERVICE_ARNS \
        --query 'services[].{Name:serviceName,Status:status,Desired:desiredCount,Running:runningCount,TaskDef:taskDefinition}' \
        --output table
    else
      echo "  (no services)"
    fi

    echo -e "\n-- Tasks in $cluster --"
    TASK_ARNS=$(aws_ro ecs list-tasks --region "$REGION" --cluster "$cluster" --query 'taskArns' --output text)
    if [[ -n "$TASK_ARNS" ]]; then
      aws_ro ecs describe-tasks --region "$REGION" --cluster "$cluster" --tasks $TASK_ARNS \
        --query 'tasks[].{TaskARN:taskArn,LastStatus:lastStatus,DesiredStatus:desiredStatus,TaskDef:taskDefinitionArn}' \
        --output table
    else
      echo "  (no running tasks)"
    fi
  done
else
  echo "  (no ECS clusters in this region)"
fi

echo -e "\n== EKS inventory (region: $REGION) =="
CLUSTERS=$(aws_ro eks list-clusters --region "$REGION" --query 'clusters' --output text 2>/dev/null || true)
if [[ -n "$CLUSTERS" ]]; then
  for c in $CLUSTERS; do
    echo -e "\n-- EKS cluster: $c --"
    aws_ro eks describe-cluster --region "$REGION" --name "$c" \
      --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' --output table
  done
else
  echo "  (no EKS clusters in this region)"
fi
