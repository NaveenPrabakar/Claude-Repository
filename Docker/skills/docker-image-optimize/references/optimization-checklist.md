# Optimization Checklist

## Base image
- `-slim` vs full image: typically saves several hundred MB (e.g. `python:3.12` is
  roughly 1GB, `python:3.12-slim` is roughly 150MB).
- `-alpine`: smaller still, but musl libc can break native extensions — verify the app
  doesn't depend on glibc-specific behavior before recommending alpine as a fix.
- Distroless (`gcr.io/distroless/*`): smallest and most secure (no shell, no package
  manager), but only viable for statically-linked binaries (Go) or JVM apps with all
  deps bundled — not a drop-in swap for apps needing a shell/package manager at runtime.

## Multi-stage builds
Before:
```dockerfile
FROM python:3.12
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```
After:
```dockerfile
FROM python:3.12-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/deps -r requirements.txt

FROM python:3.12-slim AS runtime
WORKDIR /app
COPY --from=build /deps /usr/local/lib/python3.12/site-packages
COPY . .
CMD ["python", "app.py"]
```
The single-stage version ships pip's cache and any compiler artifacts if native deps
were built. The multi-stage version doesn't.

## Layer caching order
Before (any source change invalidates the dependency-install layer):
```dockerfile
COPY . .
RUN npm install
```
After (dependency layer only invalidates when the manifest changes):
```dockerfile
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
```

## Cache cleanup must happen in the same layer
Wrong (doesn't actually shrink the image — the file exists in an earlier layer that's
still part of the image history even though a later layer deletes it):
```dockerfile
RUN apt-get update && apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*
```
Right:
```dockerfile
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
```

## .dockerignore
A missing or thin `.dockerignore` inflates the build context sent to the daemon and
can accidentally `COPY` in `node_modules`, `.git`, `venv/`, build artifacts, or test
fixtures. Check what actually gets copied with:
```bash
docker build --progress=plain . 2>&1 | grep -i "transferring context"
```
and compare context size against what's expected for source-only.

## Redundant RUN layers
Combine related installation steps into a single `RUN` with `&&` where it doesn't hurt
readability — each `RUN` is a layer, and Docker layers have fixed overhead beyond just
their content size. Don't over-merge to the point the Dockerfile becomes hard to read;
this is a minor win compared to base image and multi-stage changes.

## Recommended packages / extra installs
- `apt-get install -y --no-install-recommends` avoids pulling in suggested-but-optional
  packages (docs, fonts, etc. that many packages recommend but don't require).
- Audit whether debugging tools (`vim`, `curl`, `net-tools`) genuinely need to be in
  the final image — often leftover from development and never removed.

## Measuring the win
Always confirm claims with `docker images` size comparison when a rebuild is possible.
`docker history` before/after is useful for showing which specific layer shrank.
