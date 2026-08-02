---
name: docker-image-scan
description: >
  Scan a Docker image or Dockerfile for known vulnerabilities (CVEs), either directly
  (when shell/Docker access is available) or by producing a copy-paste-ready guide
  the user can run themselves (when running in a sandboxed session like Claude
  Desktop or Cowork with only the MCP_DOCKER connector). Use when the user asks to
  "scan this image for vulnerabilities", "check this Dockerfile for CVEs", "is this
  image secure", "run a security scan on my container", "walk me through scanning my
  image", or wants a vulnerability/compliance report before pushing an image to a
  registry.
---

# Docker Image Vulnerability Scan

Scan container images for known vulnerabilities and turn findings into a report a
human can act on. This skill runs in two modes depending on what's actually available
in the current session — always check capabilities first rather than assuming either
mode.

## Step 0: Determine which mode applies

**Direct-scan mode** — available when the session has real shell execution against
the machine/daemon that holds the image (e.g. Claude Code in a terminal, or any
environment where a bash tool can actually run `docker` and `trivy` commands against
the user's real Docker daemon). Confirm with `which docker` and `which trivy` — if
both resolve and `docker images` lists real images, you're in this mode.

**Guide mode** — applies when the session cannot execute against the user's local
Docker daemon at all, which is the normal case in Claude Desktop or Cowork chat with
only the `MCP_DOCKER` connector active. `MCP_DOCKER`'s own tools (`mcp-find`,
`mcp-add`, `mcp-exec`, etc.) manage *which MCP servers are loaded* — they don't give
shell access to the user's machine, and there is no Trivy/Grype/Docker Scout MCP
server in the catalog as of this writing (confirmed via `mcp-find` — re-check
periodically, the catalog changes). In this mode, don't attempt to fake a scan or
claim results you don't have. Read `references/guide-mode.md` and produce a
walkthrough instead — see Step 3.

If unsure which mode applies, try `which trivy` once. A failure or tool-unavailable
error means guide mode.

## Step 1: Confirm the target

Figure out what's being scanned, in either mode:
- An already-built local image (name it, or list with `docker images` in direct mode)
- A Dockerfile that needs building first
- A remote/registry image reference (`registry/image:tag`)
- An image on Docker Hub specifically — if so, check Step 2 before anything else

## Step 2: Check for existing scan data before running a new one (both modes)

**If `dockerhub` (the official Docker Hub MCP server, available through `MCP_DOCKER`
via `mcp-find`/`mcp-add`) is connected or the user is willing to connect it**, and the
image in question is hosted on Docker Hub, check whether Docker Hub already has Docker
Scout vulnerability data for that repo/tag before recommending a fresh scan — Docker
Hub computes this automatically for many repos. This saves a redundant local scan and
works even in guide mode, since it's a hosted lookup, not local execution. This only
applies to images actually pushed to Docker Hub — a purely local image tag (e.g.
`myapp:latest` never pushed anywhere) has no Docker Hub data and always needs Step 3.

If `docker-docs` is connected, use it to confirm current Trivy/Docker Scout CLI syntax
before handing the user commands — training-data syntax can drift from current
releases, and a guide with a broken flag is worse than no guide.

## Step 3a: Direct-scan mode

Run the scan yourself:

```bash
trivy image --severity HIGH,CRITICAL --ignore-unfixed <image>:<tag>
trivy config <path-to-dockerfile-dir>   # misconfig check, if a Dockerfile is available
```

Read `references/trivy-usage.md` for the full flag reference, install commands if
Trivy is missing, and Docker Scout/Grype fallback commands. Never report findings that
weren't actually produced by a real scanner run in this mode either — if Trivy can't
be installed (no network/package permissions), say so and drop to guide mode instead
of guessing.

Then go to Step 4 (Triage and report) using the real output.

## Step 3b: Guide mode

Read `references/guide-mode.md` in full before writing anything — it has the
copy-paste script template and the explanation structure. In short:

1. Give the user one ready-to-run shell script that: checks for Trivy (installs it if
   missing), runs the image scan, and runs the Dockerfile config check.
2. Explain in plain language what each command does and why, so the user isn't just
   pasting a black box.
3. Explicitly ask the user to paste the output back into the chat.
4. When they paste results back, apply Step 4 (Triage and report) to what they gave
   you — this is where the value-add comes back in your hands even though you didn't
   run the scanner yourself.

Never pre-write a "results" section with placeholder or example findings in guide
mode — there's nothing to report until the user pastes real output back.

## Step 4: Triage and report (both modes, once real output exists)

Don't just paste raw scanner output. Read `references/severity-triage.md` for how to
prioritize, then produce a report with:

1. **Summary line** — total counts by severity (e.g. "3 CRITICAL, 7 HIGH, 12 MEDIUM").
2. **Fixable first** — group findings that have an available fixed version separately
   from ones that don't (Trivy marks this) — the former are the actionable ones.
3. **Top priority table** — CRITICAL/HIGH findings with a fix available, one row each:
   package name, installed version, fixed version, CVE ID, one-line description of the
   risk (not just the CVE ID with no context).
4. **Base image guidance** — if many findings trace back to OS packages rather than
   app dependencies, recommend a smaller/newer base image tag rather than listing every
   individual OS CVE — patching the base image at the source fixes them all at once.
5. **No-fix-available findings** — list separately, note that these need either an
   accepted-risk decision or a workaround (e.g. removing the vulnerable package if
   unused), not a version bump.
6. **Dockerfile misconfigurations** (if scanned) — separate short list, since these
   aren't CVEs but process/practice issues (e.g. running as root).

## Step 5: Offer next steps

In direct-scan mode: ask if the user wants the fixes applied directly (bump base image
tag, pin a patched dependency version) — if so, make the edit and note it should be
rescanned/rebuilt to confirm the fix landed.

In guide mode: you can still edit the Dockerfile/manifests directly if the user wants
the fix applied (that's a file edit, not execution against their Docker daemon) — just
note they'll need to rebuild and rerun the scan script themselves to confirm it landed,
and offer to re-triage once they paste the new output.

Don't silently modify files without the user opting in, in either mode.
