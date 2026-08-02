# Go

Go compiles to a static binary, so the runtime image can be extremely minimal —
distroless or even `scratch` in most cases.

## Detecting the entrypoint
Check `go.mod` for the module name, then find `main.go` (often `cmd/<app>/main.go` in
larger repos — check for a `cmd/` directory rather than assuming root-level `main.go`).

## Template

```dockerfile
# ---- build stage ----
FROM golang:1.23-bookworm AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server ./cmd/server

# ---- runtime stage ----
FROM gcr.io/distroless/static-debian12:nonroot AS runtime
COPY --from=build /app/server /server
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/server"]
```

If the app needs CGO (rare — e.g. sqlite3 via `mattn/go-sqlite3`), don't set
`CGO_ENABLED=0`, and use `gcr.io/distroless/base-debian12:nonroot` instead of `static`,
since CGO binaries need libc.

## Pitfalls
- `distroless` images have no shell — `HEALTHCHECK` with a shell command won't work;
  either skip it or use an orchestrator-level (e.g. Kubernetes) liveness probe instead.
- `-ldflags="-s -w"` strips debug symbols, shrinking the binary — good for production,
  but drop it if the user wants debuggable binaries.
- Always `CGO_ENABLED=0` unless CGO is genuinely required — this is what makes the
  static, distroless-compatible binary possible.
