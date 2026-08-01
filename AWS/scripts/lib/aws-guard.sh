#!/usr/bin/env bash
# aws-guard.sh
#
# Shared safety gate for the aws-readonly plugin. Every service script sources
# this file and calls `aws_ro` instead of `aws` directly. aws_ro refuses to
# run anything that isn't a read-only action, no matter what arguments are
# passed to it. This is a hard allowlist, not a denylist -- if an action
# isn't explicitly recognized as safe, it is blocked by default.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/aws-guard.sh"
#   aws_ro ec2 describe-instances --region us-east-1
#   aws_ro s3api list-buckets

set -euo pipefail

# Prefixes that are always safe regardless of service, in the sense that
# AWS itself defines them as non-mutating (read/list/describe/inspect).
_AWS_RO_SAFE_PREFIXES=(
  "describe" "list" "get" "head" "lookup" "search" "filter" "check"
  "test-" "preview" "estimate" "validate" "simulate" "summarize"
  "batch-get" "batch-describe" "batch-check"
)

# Specific action names that are read-only but don't match a clean prefix
# pattern above (kept as an explicit, small, reviewed list).
_AWS_RO_SAFE_EXACT=(
  "s3api:list-buckets" "s3api:list-objects-v2" "s3api:list-objects"
  "s3api:head-bucket" "s3api:head-object" "s3api:get-bucket-location"
  "s3api:get-bucket-policy" "s3api:get-bucket-acl" "s3api:get-bucket-versioning"
  "s3api:get-bucket-encryption" "s3api:get-public-access-block"
  "s3api:get-bucket-tagging" "s3api:get-object-tagging"
  "s3:ls" "s3:cp" # cp is only allowed in one direction; enforced separately below
  "iam:generate-credential-report" "iam:get-credential-report"
  "cloudformation:validate-template" "cloudformation:estimate-template-cost"
  "logs:filter-log-events" "logs:tail"
  "sts:get-caller-identity"
  "ecr:describe-images" "ecr:batch-check-layer-availability"
  "dynamodb:describe-table" "dynamodb:describe-limits"
)

# Action name substrings that are ALWAYS blocked even if they happen to
# start with an allowed prefix above (defense in depth against weird
# AWS API naming, e.g. nothing in practice today, but kept for safety).
_AWS_RO_HARD_BLOCK_SUBSTR=(
  "delete" "terminate" "create" "put" "update" "modify" "attach" "detach"
  "authorize" "revoke" "run-instances" "start-instances" "stop-instances"
  "reboot" "restore" "register" "deregister" "associate" "disassociate"
  "tag-resource" "untag-resource" "add-tags" "remove-tags" "set-" "reset-"
  "enable" "disable" "purge" "reject" "accept" "cancel" "apply" "deploy"
  "invoke" "publish" "send" "write" "upload" "import" "export" "copy-object"
  "move" "rename" "replace" "revoke" "grant"
)

_aws_ro_die() {
  echo "aws-guard: BLOCKED - $1" >&2
  echo "This plugin is read-only. If you need to make this change, run the" >&2
  echo "AWS CLI command yourself outside this plugin (draft below if asked)." >&2
  exit 1
}

# aws_ro <service> <action> [args...]
aws_ro() {
  if [[ $# -lt 2 ]]; then
    _aws_ro_die "expected at least a service and an action, got: aws $*"
  fi

  local service="$1"
  local action="$2"
  shift 2
  local action_key="${service}:${action}"
  local lower_action
  lower_action="$(echo "$action" | tr '[:upper:]' '[:lower:]')"

  # Special case: `aws s3 ls` and `aws s3 cp <s3-uri> -` (stdout only) are
  # read-only; `aws s3 cp <local> <s3-uri>`, `sync`, `mv`, `rm` are not.
  if [[ "$service" == "s3" ]]; then
    if [[ "$action" == "ls" ]]; then
      command aws s3 ls "$@"
      return $?
    else
      _aws_ro_die "s3 subcommand '$action' is not on the read-only allowlist (only 'ls' is). Use s3api list-objects-v2 instead."
    fi
  fi

  # Hard block list wins over everything else.
  for bad in "${_AWS_RO_HARD_BLOCK_SUBSTR[@]}"; do
    if [[ "$lower_action" == *"$bad"* ]]; then
      _aws_ro_die "action '$action' matches a blocked (mutating) pattern: '$bad'"
    fi
  done

  # Exact allowlist match.
  for good in "${_AWS_RO_SAFE_EXACT[@]}"; do
    if [[ "$action_key" == "$good" ]]; then
      command aws "$service" "$action" "$@"
      return $?
    fi
  done

  # Prefix allowlist match.
  for prefix in "${_AWS_RO_SAFE_PREFIXES[@]}"; do
    if [[ "$lower_action" == "$prefix"* ]]; then
      command aws "$service" "$action" "$@"
      return $?
    fi
  done

  _aws_ro_die "action '$action' is not on the read-only allowlist. Add it to lib/aws-guard.sh only if you have manually confirmed it is non-mutating."
}

# Quick credential/identity sanity check, safe to call anywhere.
aws_ro_whoami() {
  aws_ro sts get-caller-identity --output table
}
