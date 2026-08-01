# aws-readonly

A Claude Code / Cowork plugin for inspecting an AWS account -- EC2, S3, RDS,
Lambda, ECS/EKS, CloudFormation, IAM, VPC, DynamoDB, ECR, CloudWatch -- with
a hard, script-level guarantee that nothing gets written, changed, or
deleted.

## Why it's actually read-only

Every service script sources `scripts/lib/aws-guard.sh` and calls `aws_ro`
instead of calling `aws` directly. `aws_ro` checks the requested action
against an allowlist of read-only prefixes (`describe-`, `list-`, `get-`,
`head-`, `lookup-`, `search-`, `filter-`, `batch-get-`, etc.) plus a small,
explicitly reviewed exact-match list, and against a hard block list of
mutating keywords (`create`, `put`, `delete`, `terminate`, `start`, `stop`,
`attach`, `run-instances`, ...). Anything not explicitly allowed is
refused -- fail closed, not fail open. `aws s3` is restricted to `ls` only
(`cp`/`sync`/`mv`/`rm` are blocked; use `s3api list-objects-v2` for
read-only object listing instead).

This was verified with a fake `aws` binary: read calls (`describe-instances`,
`list-buckets`) pass through; write calls (`terminate-instances`,
`put-object`, `create-user`, `s3 rm`, `delete-db-instance`, `run-instances`)
are all rejected with a clear error and non-zero exit code.

## Requirements

- AWS CLI v2 on `PATH`
- Credentials already set up via `aws configure` (or env vars / SSO profile)
  -- this plugin never stores or asks for credentials itself
- Bash (works under WSL or Git Bash on Windows)

## Quick start

```bash
cd scripts
./doctor.sh                 # confirm CLI + creds + region are good
./ec2-inventory.sh           # EC2 in your default region
./s3-inventory.sh             # all buckets
./s3-inventory.sh my-bucket   # drill into one bucket
./rds-inventory.sh
./lambda-inventory.sh
./full-report.sh > report.txt # everything, in one file
```

## If you need to make a change

This plugin will not do it, and won't accept a flag to make it do it. Ask
Claude (with this plugin loaded) what you're trying to change -- it will use
these scripts to gather the relevant context, then hand you back the exact
`aws` CLI command (or IaC snippet) to run yourself.

## Layout

```
aws-readonly/
├── .claude-plugin/plugin.json
├── skills/aws-readonly/SKILL.md
├── scripts/
│   ├── lib/aws-guard.sh        # the enforcement layer
│   ├── doctor.sh
│   ├── ec2-inventory.sh
│   ├── s3-inventory.sh
│   ├── rds-inventory.sh
│   ├── lambda-inventory.sh
│   ├── ecs-inventory.sh
│   ├── cloudformation-inventory.sh
│   ├── iam-audit.sh
│   ├── vpc-inventory.sh
│   ├── dynamodb-inventory.sh
│   ├── ecr-inventory.sh
│   ├── cloudwatch-inventory.sh
│   └── full-report.sh
└── README.md
```
