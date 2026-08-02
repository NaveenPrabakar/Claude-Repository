---
name: docker-image-optimize
description: >
  Analyze an existing Dockerfile or built image for size, layer-count, build-speed,
  and cache-efficiency improvements, and propose concrete edits. Use when the user
  asks to "shrink this image", "why is my Docker image so big", "optimize this
  Dockerfile", "speed up my Docker build", or "reduce layers in this image".
---

# Docker Image Optimization

Diagnose why an image is bigger or slower to build than it needs to be, and propose
specific, minimal edits — not a rewrite from scratch unless the existing Dockerfile is
fundamentally single-stage and needs to become multi-stage.

## Step 1: Gather evidence before recommending anything

Don't guess at the cause. If a built image is available:

```bash
docker images <image>              # overall size
docker history <image>             # per-layer size breakdown
docker history --no-trunc <image>  # full commands per layer, unabbreviated
```

If only a Dockerfile is available (no built image), read it directly and reason from
its structure — stage count, base image choice, `COPY`/`RUN` ordering.

Read `references/optimization-checklist.md` for the full set of things to check.

## Step 2: Identify the largest contributors

`docker history` output is ordered by layer creation — look for the largest `SIZE`
entries and trace them back to the Dockerfile line that produced them. Common large
contributors, roughly in order of how often they're the actual cause:

1. A single fat base image where a `-slim`/`-alpine`/distroless variant would work
2. Build tools/compilers present in the final stage (single-stage build that should be
   multi-stage)
3. Package manager caches not cleaned up in the same `RUN` layer they were created in
4. Unnecessary files copied in (`COPY . .` with no `.dockerignore`, pulling in
   `node_modules`, `.git`, test fixtures, docs)
5. Dev dependencies installed in the production image
6. Layers duplicating work across stages that could share a cached layer

## Step 3: Propose specific edits

For each finding, give a before/after diff-style snippet, not just prose description —
the user should be able to see exactly what changes. Order recommendations by impact
(largest size/speed win first), and estimate the impact qualitatively ("this alone
typically cuts image size by half or more") rather than promising exact numbers you
haven't measured.

Common fixes, detailed in `references/optimization-checklist.md`:
- Convert single-stage to multi-stage
- Swap base image tag
- Reorder layers so dependency install is cached separately from source copy
- Add/tighten `.dockerignore`
- Clean package manager caches within the same `RUN` that created them (a later `RUN
  rm` does NOT shrink earlier layers — the file still exists in the image's layer
  history even after a subsequent layer deletes it)
- Merge redundant `RUN` layers where it doesn't hurt readability
- Strip debug symbols / use `--no-install-recommends` / avoid installing recommended
  packages

## Step 4: Validate impact if a rebuild is available

If the user wants the changes applied and can rebuild, apply the edits, rebuild, and
compare `docker images` size before/after so the recommendation is confirmed with a
real number rather than left as a theoretical claim. If rebuilding isn't possible in
the current environment, say so and give the qualitative expectation instead.

## Step 5: Cross-reference security

If an optimization also happens to reduce attack surface (fewer packages, no build
tools in final image), mention it — but don't turn this into a full security audit;
point to the `docker-image-scan` skill for that if the user wants a dedicated pass.
