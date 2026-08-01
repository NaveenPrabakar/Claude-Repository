---
name: aws-readonly
description: >
  Read-only AWS inspection and inventory toolkit covering EC2, S3, RDS, Lambda,
  ECS/EKS, CloudFormation, IAM, VPC/networking, DynamoDB, ECR, and CloudWatch.
  Use this whenever the user asks to check, inspect, audit, list, describe,
  inventory, or investigate anything in their AWS account or a specific AWS
  service -- e.g. "what EC2 instances do we have running", "check our S3
  buckets for public access", "why is this Lambda failing", "what's in our
  RDS instance", "audit our IAM roles", "what's deployed in this
  CloudFormation stack". This skill is READ-ONLY BY DESIGN: it must never be
  used to create, modify, delete, start, stop, or otherwise mutate any AWS
  resource. If the user wants to make a change, use this skill only to gather
  context, then hand back a plain-language draft of the change and the exact
  AWS CLI command for the user to run themselves -- never execute it.
compatibility: Requires the AWS CLI (`aws`) installed and already configured via `aws configure` (or environment variables / an SSO profile). No AWS credentials are stored by this plugin.
---

# AWS Read-Only Toolkit

Scripts and workflow for inspecting an AWS account without ever risking a
write. This exists so Claude can freely explore infrastructure to answer
questions, debug issues, or produce reports, with a hard technical guarantee
(not just a prompt instruction) that nothing gets created, changed, or
deleted along the way.

## Ground rules

1. **Never call the `aws` CLI directly for anything in scope of this skill.**
   Always go through the scripts in `scripts/`, which route every call
   through `scripts/lib/aws-guard.sh`. That guard allowlists only
   read/describe/list/get-style actions and hard-blocks anything that looks
   mutating (create, put, update, delete, terminate, start, stop, attach,
   run, etc.) -- even if asked to, even indirectly.
2. **If the user asks to make a change** (spin up an instance, delete a
   bucket, modify a security group, change an IAM policy, etc.): use this
   skill's scripts to gather whatever read-only context is useful, then stop
   and produce a **draft** -- the exact `aws` command(s) or IaC snippet the
   user would need to run, clearly labeled as something they must execute
   themselves. Do not run it, do not suggest running it "just this once,"
   and do not add a flag/env var that would bypass the guard.
3. **Never fetch actual secret values.** Scripts only enumerate identities,
   resource metadata, and configuration -- never `get-secret-value`,
   `get-parameter --with-decryption`, key material, or similar. If the user
   needs a secret's value, tell them to retrieve it themselves through the
   console or CLI directly.
4. **First run in a session:** run `scripts/doctor.sh` once to confirm the
   AWS CLI is installed, credentials resolve, and a default region is set.
   Surface any failures to the user plainly (e.g. "credentials aren't
   configured" or "no default region set") rather than guessing.

## Available scripts

All scripts live in `scripts/` and are self-contained bash (require `aws`
CLI v2 on PATH; work fine under WSL or Git Bash on Windows since `aws
configure` is machine-wide). Each accepts an optional `[region]` argument;
if omitted, it falls back to the configured default region.

| Script | Covers |
|---|---|
| `doctor.sh` | Environment sanity check (CLI present, creds valid, region set) |
| `ec2-inventory.sh [region]` | Instances, security groups, VPCs, EBS volumes, key pairs, EIPs |
| `s3-inventory.sh [bucket]` | All buckets (no arg), or one bucket's ACL/encryption/versioning/public-access-block/objects |
| `rds-inventory.sh [region]` | DB instances, Aurora clusters, manual snapshots, subnet groups, parameter groups |
| `lambda-inventory.sh [region] [function]` | All functions (no name), or one function's config, aliases, event sources, recent logs |
| `ecs-inventory.sh [region]` | ECS clusters/services/tasks and EKS clusters |
| `cloudformation-inventory.sh [region] [stack]` | All stacks (no name), or one stack's resources, recent events, outputs |
| `iam-audit.sh` | Users, roles, groups, customer-managed policies (metadata only, never keys/secrets) |
| `vpc-inventory.sh [region]` | VPCs, subnets, route tables, IGWs, NAT gateways, load balancers |
| `dynamodb-inventory.sh [region]` | Tables and their status/size/billing mode |
| `ecr-inventory.sh [region]` | Repositories and their most recent images |
| `cloudwatch-inventory.sh [region]` | Alarms (especially any in ALARM state) and log groups |
| `full-report.sh [region]` | Runs every script above in sequence -- useful for a one-shot account snapshot |

Run any script with `-h` mentally by just reading its header comment; they're
short and don't take flags beyond region/name.

## How to use this in a conversation

1. Figure out which service(s) the user's question touches. Development-focused
   questions usually land on EC2, S3, RDS, Lambda, ECS, or CloudFormation.
   Networking/security questions land on VPC or IAM. Debugging usually needs
   CloudWatch logs alongside the relevant service.
2. Run `doctor.sh` if this is the first AWS action in the session.
3. Run the narrowest script that answers the question rather than
   `full-report.sh` by default -- keep output focused and fast. Reach for
   `full-report.sh` only when the user wants a broad account overview or
   audit.
4. Read the table output and answer the user's actual question in plain
   language -- don't just dump raw tables unless they asked for the raw data.
5. If something looks wrong (public S3 bucket, unattached EBS volume,
   over-permissioned IAM policy, alarm actively firing), point it out even
   if unasked -- that's the point of read-only visibility.
6. If the fix requires a write, produce the draft command per Ground Rule 2
   and stop there.

## Extending the allowlist

If a needed read-only action isn't recognized yet (`aws-guard.sh` will say
so explicitly with an exit code 1), open `scripts/lib/aws-guard.sh`,
confirm the action is genuinely non-mutating in the AWS API docs, and add it
to `_AWS_RO_SAFE_EXACT` or `_AWS_RO_SAFE_PREFIXES`. Never widen the guard to
pattern-match something you haven't verified action-by-action, and never
add a bypass flag.
