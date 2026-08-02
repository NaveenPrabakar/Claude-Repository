# Severity Triage Guidance

Raw scanner output is not a report. Apply this priority order when writing the summary
for the user — this is about what to fix first, not just what to list first.

## Priority order

1. **CRITICAL + fix available** — always first. No judgment call needed, patch it.
2. **HIGH + fix available, in a package the app actually uses at runtime** — check
   whether the vulnerable package is a runtime dependency or a transitive
   build-time-only dependency that never ships. Trivy's `--vuln-type library` findings
   from a multi-stage build's final stage are runtime-relevant; findings only present
   in an intermediate build stage image are lower urgency.
3. **CRITICAL/HIGH with no fix available** — flag clearly as "no patch yet"; the
   options are: remove the dependency if unused, find an alternative package, apply a
   vendor-provided workaround if one exists, or explicitly accept the risk. Don't
   present these the same way as fixable ones — mixing them buries the actionable items.
4. **MEDIUM/LOW** — worth listing in an appendix or on request, not the headline. Don't
   let a report with 200 LOW findings and 2 CRITICAL findings bury the 2 that matter.

## Base-image-driven noise

If the majority of findings are OS-level packages inherited from the base image (e.g.
`glibc`, `openssl`, `zlib` CVEs unrelated to anything the app's code touches), say so
explicitly and recommend the fix at the source:
- Bump to a newer patch/minor version of the same base image tag (most common fix).
- Switch to a `-slim`/`-alpine`/distroless variant if not already using one — fewer OS
  packages installed means fewer possible CVEs by construction.
- Rebuild and rescan after the base image bump — one change often clears a large
  fraction of findings at once, which is worth confirming rather than assuming.

## Application-dependency findings

For npm/pip/Maven/etc. findings, check whether a patched version satisfies the
existing version range in the manifest (a `npm audit fix` / `pip install -U <pkg>` —
style minor bump) versus requiring a major version bump that could break the app. Flag
which category each fix falls into so the user can judge risk/effort accurately.

## Secrets findings

Treat any detected secret (API key, private key, credential) in image layers as
CRITICAL regardless of what the scanner labels it — a leaked secret is worse than most
CVEs and needs immediate rotation, not just a rebuild. Call this out separately at the
top of the report if found, don't bury it in a severity table.

## What the report should NOT do

- Don't list every CVE ID with no context — always add what package it's in and
  whether a fix exists.
- Don't present LOW-severity, no-fix-available findings with the same visual weight as
  CRITICAL fixable ones.
- Don't recommend `--ignore-unfixed` as a way to make numbers look better without
  explaining that it's hiding (not fixing) those findings.
