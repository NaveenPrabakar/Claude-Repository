---
name: dockerize-repo
description: >
  Scan a codebase, detect its stack(s) (frontend, backend, monorepo), and generate
  production-grade, security-hardened Dockerfiles, .dockerignore files, and a
  docker-compose.yml. Use when the user asks to "dockerize this repo", "add a
  Dockerfile", "containerize this app", "write a Dockerfile for frontend/backend",
  "create docker files for this project", or wants a repo made deployable via Docker
  following best practices.
---

# Dockerize Repo

Generate Dockerfiles that are correct, minimal, and secure by default — never a
copy-paste generic template. Every Dockerfile must be derived from what is actually
in the repo.

## Step 1: Scan the repository

Before writing anything, inspect the repo structure to identify each deployable unit.

Run a shallow structural scan:
- List top-level directories and files (`ls`, `find . -maxdepth 3 -name "package.json" -o -name "requirements.txt" -o -name "pyproject.toml" -o -name "pom.xml" -o -name "build.gradle" -o -name "go.mod" -o -name "*.csproj" -o -name "Gemfile"`)
- Check for monorepo signals: `apps/`, `packages/`, `frontend/`, `backend/`, `client/`, `server/`, workspace configs (`pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `lerna.json`)
- For each candidate directory, identify the language/framework using the manifest file present:

| Manifest file | Stack |
|---|---|
| `package.json` (with `react`/`vue`/`next`/`vite`/`angular` deps, no server framework) | Frontend (static/SPA) |
| `package.json` (with `express`/`fastify`/`nestjs`/`next` w/ server routes) | Node backend |
| `requirements.txt` / `pyproject.toml` | Python (check for `flask`, `fastapi`, `django`) |
| `pom.xml` / `build.gradle` | Java |
| `go.mod` | Go |
| `*.csproj` / `*.sln` | .NET |
| `Gemfile` | Ruby |

If multiple stacks are found (e.g. `frontend/` + `backend/`), treat each as a separate
deployable unit needing its own Dockerfile — this is the normal case for "frontend and
backend" requests.

If the stack is ambiguous or missing a manifest entirely, ask the user rather than
guessing — a wrong base image or wrong entrypoint is worse than a clarifying question.

## Step 2: Read the stack-specific reference

Once a stack is identified, read the matching reference file before writing the
Dockerfile — each contains the correct base images, build stages, and stack-specific
pitfalls:

- `references/node.md` — Node.js (backend APIs and SSR frameworks)
- `references/static-frontend.md` — React/Vue/Angular/Vite SPAs served via Nginx
- `references/python.md` — Flask/FastAPI/Django
- `references/java.md` — Spring Boot / Maven / Gradle
- `references/go.md` — Go services
- `references/dotnet.md` — ASP.NET Core
- `references/ruby.md` — Rails/Sinatra

Every reference follows the same non-negotiable baseline in
`references/security-checklist.md` — read it once per session; it applies to every
Dockerfile regardless of stack.

## Step 3: Generate the Dockerfile(s)

For each deployable unit, write `<dir>/Dockerfile` applying:

1. **Multi-stage builds** — separate build-time deps (compilers, dev dependencies) from
   the runtime image. The final stage should contain only what's needed to run.
2. **Pinned, minimal base images** — pin to a specific version tag with digest-friendly
   minor version (e.g. `node:22.11-slim`, not `node:latest` or bare `node:22`). Prefer
   `-slim`/`-alpine`/distroless variants for the runtime stage; the build stage can use
   the fuller image if it needs compilers.
3. **Non-root user** — create and switch to a non-root user in the runtime stage. Never
   run the container process as root.
4. **Minimal attack surface** — no package manager caches left behind
   (`--no-cache-dir`, `apt-get clean && rm -rf /var/lib/apt/lists/*`), no build tools in
   the final image, no `.git`, no secrets, no dev dependencies.
5. **Layer ordering for cache efficiency** — copy dependency manifests and install
   dependencies before copying application source, so code changes don't invalidate the
   dependency-install layer.
6. **Explicit `EXPOSE`** matching the app's actual listen port (check source/config for
   the real port — don't assume 3000/8080 without verifying).
7. **`HEALTHCHECK`** where the framework makes it cheap to add (an existing health
   endpoint, or a lightweight process check).
8. **No `ADD` for local files** — use `COPY`; reserve `ADD` only for remote URLs or
   auto-extracting archives, and only if explicitly needed.

## Step 4: Generate `.dockerignore`

Create one `.dockerignore` per deployable unit (or one shared at repo root if the
build contexts overlap), excluding at minimum: `.git`, `node_modules`, `__pycache__`,
`*.pyc`, `.env*`, build/dist output directories, IDE folders, test coverage output,
and any local secrets files. Tailor the list to what Step 1 revealed about the stack.

## Step 5: Generate `docker-compose.yml` (if more than one unit, or on request)

When there's more than one deployable unit (e.g. frontend + backend), or the user asks
for compose, read `references/compose.md` and generate a `docker-compose.yml` that
wires the services together — correct `depends_on`, internal network, environment
variables sourced from `.env` (never hardcoded secrets), and named volumes for any
stateful services (databases, caches) detected in the repo.

## Step 6: Summarize

After generating files, give the user a short summary: which units were detected,
which Dockerfile maps to which directory, the exposed ports, and one sentence per file
on what security/best-practice choices were made. Don't restate the full file contents
in the summary — the files speak for themselves.

Do not run `docker build` unless the user asks — generation is the job of this skill;
verifying the build and scanning it is the job of `docker-image-scan`.
