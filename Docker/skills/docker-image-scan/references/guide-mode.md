# Guide Mode

Used whenever the current session can't execute against the user's real Docker daemon
— the normal situation in Claude Desktop or Cowork chat with only `MCP_DOCKER`
connected. The goal is to hand over a script the user runs themselves, in language
that explains what's happening, then pick the analysis back up once they paste results
back.

## What to give the user

One block, ready to paste into their terminal as-is. Fill in `<image>:<tag>` and
`<dockerfile-dir>` with what was established in Step 1 — don't leave placeholders in
the actual script you hand over.

```bash
#!/usr/bin/env bash
set -e

IMAGE="<image>:<tag>"
DOCKERFILE_DIR="<dockerfile-dir>"   # omit the config-check block below if no Dockerfile

# 1. Install Trivy if it's not already present
if ! command -v trivy &> /dev/null; then
  echo "Trivy not found, installing..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

# 2. Scan the image for HIGH/CRITICAL vulnerabilities with an available fix
echo "=== IMAGE SCAN ==="
trivy image --severity HIGH,CRITICAL --ignore-unfixed "$IMAGE"

# 3. Scan the Dockerfile for misconfigurations (missing USER, exposed secrets, etc.)
if [ -n "$DOCKERFILE_DIR" ]; then
  echo "=== DOCKERFILE CONFIG CHECK ==="
  trivy config "$DOCKERFILE_DIR"
fi
```

## How to present it

1. **One short paragraph before the script** explaining why you can't run this
   yourself in this session (this chat doesn't have access to your local Docker
   daemon) and what the script does at a high level — don't just drop code with no
   framing.
2. **The script itself**, filled in with their actual image name/tag and Dockerfile
   path — not generic placeholders.
3. **One short paragraph after** telling them exactly what to do: run it in a terminal
   on the machine where the image exists, then paste the full output back into the
   chat.
4. Mention macOS users can `brew install trivy` instead of the install-script line if
   they prefer — a one-line aside, not a second full script.

## When they paste output back

Treat it exactly like direct-mode output — run the full Step 4 triage process against
it (severity summary, fixable-first grouping, priority table, base-image guidance,
no-fix-available list, misconfig list). The fact that they ran the command instead of
you doesn't change how the findings should be organized.

If the pasted output looks incomplete or truncated (e.g. cuts off mid-table), ask them
to paste the rest rather than triaging partial data as if it were complete — an
incomplete CRITICAL count reported as final is worse than asking a follow-up question.

## What not to do in guide mode

- Don't write out a "here's what the results will probably look like" example table —
  it reads as a real report to anyone skimming and risks being mistaken for actual
  findings.
- Don't claim you "scanned" the image — say the scan needs to run on their machine and
  frame yourself as walking them through it, not as having done it.
- Don't overload the first message with every possible flag/variant — give the one
  script that fits their stated target, and mention alternate flags (full severity
  range, JSON output, SARIF for CI) only if they ask for a variation.
