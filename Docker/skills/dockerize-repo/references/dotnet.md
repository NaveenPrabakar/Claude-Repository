# .NET (ASP.NET Core)

## Detecting the target framework and project file
Check the `.csproj` for `<TargetFramework>` (e.g. `net8.0`) — pin the SDK/runtime image
to match. Identify the entry project if the repo has multiple `.csproj` files (a
solution `.sln` with multiple projects — pick the one referencing
`Microsoft.AspNetCore`).

## Template

```dockerfile
# ---- build stage ----
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"
COPY . .
WORKDIR /src/MyApi
RUN dotnet publish -c Release -o /app/publish --no-restore

# ---- runtime stage ----
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
RUN adduser --disabled-password --gecos "" app
COPY --from=build --chown=app:app /app/publish .
USER app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/health || exit 1
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

Replace `MyApi` with the actual project/assembly name detected from the `.csproj`.

## Pitfalls
- Use the `aspnet` runtime image (not `sdk`) for the final stage — the SDK image is
  ~3x larger and includes build tooling not needed at runtime.
- Copy only the `.csproj` (not full source) before `dotnet restore` to preserve layer
  caching on dependency-only changes.
- Default ASPNETCORE_URLS binds to port 8080 in the .NET 8 container images already —
  don't leave it pointed at port 80 unless you also adjust `EXPOSE`/user permissions
  for a privileged port.
- If the app is a Kestrel-only API with no `/health` endpoint, note that the
  `HEALTHCHECK` line needs a real path, or should be omitted/replaced with a TCP check.
