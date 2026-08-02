# Security & Best-Practice Baseline

Applies to every Dockerfile this skill generates, regardless of stack. Treat each item
as a default to follow, not a suggestion to weigh — deviate only if the user explicitly
asks for something else, and say so when you do.

## Base images
- Pin to a specific version tag (`python:3.12-slim`, not `python:3.12` or `python:latest`).
- Prefer official images over third-party ones unless the user's stack requires otherwise.
- Prefer `-slim`, `-alpine`, or distroless variants for the final runtime stage.
  `-alpine` uses musl libc, which occasionally breaks native Node/Python addons —
  mention this tradeoff if the repo has native dependencies (e.g. `bcrypt`, `sharp`,
  `psycopg2` without the binary wheel).

## Users & permissions
- Always create a dedicated non-root user in the runtime stage:
  ```dockerfile
  RUN addgroup --system app && adduser --system --ingroup app app
  USER app
  ```
- Set correct file ownership on `COPY` so the non-root user can actually read/execute
  what it needs: `COPY --chown=app:app . .`
- Never `chmod 777` as a shortcut — fix the actual permission that's needed.

## Secrets
- Never `COPY` `.env` files, credentials, private keys, or `.git` into the image.
- Never bake secrets into `ARG`/`ENV` — build args persist in image history and are
  extractable with `docker history`. Use runtime environment variables or a secrets
  manager instead, and say so in the summary if the repo currently does this wrong.
- If the app needs build-time secrets (e.g. a private package registry token), use
  Docker BuildKit secret mounts (`RUN --mount=type=secret`), not `ARG`.

## Attack surface
- Remove package manager caches and lists after install:
  - Debian/Ubuntu: `apt-get update && apt-get install -y --no-install-recommends <pkgs> && rm -rf /var/lib/apt/lists/*`
  - Alpine: `apk add --no-cache <pkgs>`
  - pip: `pip install --no-cache-dir -r requirements.txt`
  - npm: `npm ci --omit=dev` (not `npm install`, which mutates the lockfile)
- Don't install debugging tools (`curl`, `vim`, `netcat`) in the final stage unless the
  user explicitly wants a debug-friendly image.
- Multi-stage builds so compilers/build tools never ship in the runtime image.

## Runtime behavior
- `EXPOSE` the real port the app listens on — verify it in source/config, don't guess.
- Add a `HEALTHCHECK` if there's a cheap way to check liveness (an existing `/health`
  endpoint, or a process check for workers without HTTP).
- Set `WORKDIR` explicitly rather than relying on the default.
- Prefer exec-form `CMD`/`ENTRYPOINT` (`["node", "server.js"]`) over shell-form
  (`CMD node server.js`) so signals (SIGTERM) propagate correctly for graceful shutdown.
- For images that need to run under an orchestrator that enforces read-only root
  filesystems (many production Kubernetes setups), mention this as an optional
  hardening step rather than assuming it — some apps write temp files and would break.

## Layer & cache hygiene
- Copy dependency manifests (`package.json`+lockfile, `requirements.txt`,
  `pom.xml`, `go.mod`+`go.sum`) and install dependencies *before* copying the rest of
  the source, so unrelated source changes don't invalidate the install layer.
- Combine related `RUN` commands with `&&` to avoid unnecessary layers, but don't
  sacrifice readability for a marginal layer-count reduction.

## What NOT to do
- Don't use `latest` tags.
- Don't run as root.
- Don't leave build tools, source maps, or test files in the runtime image.
- Don't hardcode ports, hostnames, or secrets that should be environment-driven.
- Don't blindly wrap an existing broken Dockerfile — if the repo already has one,
  read it, but rebuild it against this checklist rather than patching it in place.
