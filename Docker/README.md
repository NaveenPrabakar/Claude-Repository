# docker-builder

A Claude plugin that dockerizes repos following security and production best
practices, then keeps the resulting images honest with vulnerability scanning and
size/layer optimization.

## Skills

### `dockerize-repo`
Scans a repository (single app or monorepo with separate frontend/backend), detects
the stack for each deployable unit, and generates:
- Multi-stage, non-root, minimal-base-image Dockerfiles per unit
- `.dockerignore` per unit
- `docker-compose.yml` wiring services together (when more than one unit is detected)

Supports: Node.js backends, static frontend SPAs (React/Vue/Angular/Vite via Nginx),
Python (Flask/FastAPI/Django), Java (Spring Boot/Maven/Gradle), Go, .NET (ASP.NET
Core), and Ruby (Rails/Sinatra).

**Trigger it with:** "dockerize this repo", "add a Dockerfile for the backend",
"containerize this app", "write docker files for frontend and backend"

### `docker-image-scan`
Scans a Docker image or Dockerfile for CVEs and produces a triaged, prioritized
report — fixable-first, with base-image guidance when findings cluster there. Runs in
one of two modes depending on the session:

- **Direct-scan mode** — when there's real shell access to the machine holding the
  image (e.g. Claude Code in a terminal). Runs Trivy (Docker Scout/Grype as fallbacks)
  itself and triages the real output.
- **Guide mode** — when running in Claude Desktop/Cowork chat with only the
  `MCP_DOCKER` connector active, which manages MCP server connections but doesn't
  provide shell access to your machine. In this mode the skill hands you a
  ready-to-run script, explains each step, and triages the results once you paste
  them back. It also checks Docker Hub (via the `dockerhub` MCP server, if connected)
  for existing Scout vulnerability data before recommending a fresh scan, and can use
  `docker-docs` to verify current CLI syntax.

Either way, the skill never reports vulnerability findings it didn't actually see —
no fabricated scan results.

**Trigger it with:** "scan this image for vulnerabilities", "check for CVEs", "is this
image secure", "run a security scan on my container", "walk me through scanning my
image"

### `docker-image-optimize`
Analyzes an existing Dockerfile or built image for size, layer-count, and
cache-efficiency issues, with before/after diff-style fixes.

**Trigger it with:** "shrink this image", "why is my Docker image so big", "optimize
this Dockerfile", "speed up my Docker build"

## Design notes

- Every generated Dockerfile follows the shared baseline in
  `skills/dockerize-repo/references/security-checklist.md`: pinned base images,
  non-root user, multi-stage builds, no secrets baked in, minimal attack surface.
- Stack detection is manifest-driven (`package.json`, `requirements.txt`, `pom.xml`,
  `go.mod`, `.csproj`, `Gemfile`) rather than assumed — the skill reads the actual repo
  before generating anything.
- The scanning skill never fabricates results — if a scanner isn't available in the
  environment, it says so rather than inventing findings.

## Requirements

- Docker CLI (for building/scanning images)
- Trivy recommended for `docker-image-scan` (install instructions in
  `skills/docker-image-scan/references/trivy-usage.md`); falls back to Docker Scout or
  Grype if present.
