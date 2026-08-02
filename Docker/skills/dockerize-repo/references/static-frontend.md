# Frontend SPA (React / Vue / Angular / Vite) — Static Build Served via Nginx

Most frontend SPAs don't need a Node runtime in production — they build to static
HTML/JS/CSS and should be served by a lightweight web server.

## Detecting the build command and output directory
Read `package.json` `scripts.build`. Output directory varies by tool:
- Vite → `dist/`
- Create React App → `build/`
- Angular → `dist/<project-name>/`
- Vue CLI → `dist/`

Verify against the actual config (`vite.config.*`, `angular.json`) rather than
assuming the default.

## Template

```dockerfile
# ---- build stage ----
FROM node:22.11-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- runtime stage ----
FROM nginx:1.27-alpine AS runtime
RUN addgroup -S app && adduser -S app -G app
COPY --from=build --chown=app:app /app/dist /usr/share/nginx/html
COPY --chown=app:app nginx.conf /etc/nginx/conf.d/default.conf
# nginx needs to bind privileged port 80 as root by default; run on 8080 as non-root instead
RUN sed -i 's/listen\s*80;/listen 8080;/' /etc/nginx/conf.d/default.conf \
  && touch /var/run/nginx.pid \
  && chown -R app:app /var/cache/nginx /var/run/nginx.pid /etc/nginx/conf.d
USER app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
```

Generate a minimal `nginx.conf` alongside it if one doesn't exist, including SPA
fallback routing (`try_files $uri /index.html;`) so client-side routes don't 404 on
refresh:

```nginx
server {
    listen 8080;
    root /usr/share/nginx/html;
    index index.html;
    location / {
        try_files $uri $uri/ /index.html;
    }
    location /health {
        access_log off;
        return 200 "ok";
    }
}
```

## Pitfalls
- Don't ship the Node build image to production — always multi-stage into `nginx` (or
  another static server) for the runtime.
- If the SPA calls a backend API, don't hardcode the API URL at build time unless the
  user confirms that's intended — prefer runtime env injection (e.g. a small entrypoint
  script that writes a `env.js` from `$API_URL` before nginx starts) if the app needs
  per-environment config without rebuilding.
- Root nginx image binds port 80, which requires root — either keep it root-only for
  that one bind (acceptable, low risk since nginx drops privileges internally) or
  rebind to an unprivileged port as shown above for full non-root operation.
