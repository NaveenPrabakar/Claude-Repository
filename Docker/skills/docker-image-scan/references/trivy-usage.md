# Trivy Usage Reference

## Installation

```bash
# Debian/Ubuntu
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# macOS
brew install trivy

# Direct binary (any platform) — check releases page for current version
# https://github.com/aquasecurity/trivy/releases
```

If curl/network access to GitHub isn't available in the current environment, don't
attempt a workaround that skips the scan — tell the user installation isn't possible
here and ask them to run the scan in an environment with network access, or use
Docker Scout / Grype if already installed locally.

## Core commands

```bash
# Scan a local or remote image
trivy image <image>:<tag>

# Only actionable severities, skip vulns with no fix yet
trivy image --severity HIGH,CRITICAL --ignore-unfixed <image>:<tag>

# JSON output for programmatic parsing
trivy image --format json --output results.json <image>:<tag>

# Scan a Dockerfile for misconfigurations (not vulnerabilities — practice issues)
trivy config <path-to-directory-containing-Dockerfile>

# Scan filesystem/repo directly (useful pre-build, without a built image)
trivy fs --severity HIGH,CRITICAL .

# Scan for exposed secrets specifically
trivy image --scanners secret <image>:<tag>
```

## Useful flags

| Flag | Purpose |
|---|---|
| `--severity HIGH,CRITICAL` | Filter to actionable severities |
| `--ignore-unfixed` | Hide CVEs with no available patch yet (reduces noise) |
| `--exit-code 1` | Non-zero exit if vulnerabilities found — useful for CI gating |
| `--format json\|table\|sarif` | Output format; `sarif` integrates with GitHub code scanning |
| `--scanners vuln,secret,misconfig` | Choose what to scan for |
| `--vuln-type os,library` | Split OS-package vs application-dependency findings |

## Reading output

Trivy table output includes a "Fixed Version" column — empty means no patch exists
yet. A CVE with a fixed version and HIGH/CRITICAL severity is always the top priority:
it's both dangerous and immediately actionable via a version bump.

## Fallbacks if Trivy isn't available

- **Docker Scout** (bundled with recent Docker Desktop/CLI): `docker scout cves <image>`
- **Grype**: `grype <image>:<tag>` — similar coverage to Trivy, different install path
  (`curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin`)

Only use these if genuinely present — check with `which docker` + `docker scout
version` or `which grype` before recommending a command that will just fail.

## No shell access in this session?

If `which trivy` fails not because Trivy is missing but because there's no shell
execution against the user's actual machine at all (common in Claude Desktop/Cowork
chat with only the `MCP_DOCKER` connector active), this isn't an install problem —
it's a mode problem. Switch to guide mode: see `references/guide-mode.md` in this
skill and hand the user a script to run themselves instead of attempting workarounds
like asking `mcp-exec` to run shell commands (it executes tools within connected MCP
servers, not arbitrary shell commands on the user's machine).
