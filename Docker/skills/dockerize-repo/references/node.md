# Node.js Backend (Express / Fastify / NestJS / Next.js server)

## Detecting the package manager
Check for a lockfile before assuming npm:
- `package-lock.json` → npm (`npm ci`)
- `yarn.lock` → yarn (`yarn install --frozen-lockfile`)
- `pnpm-lock.yaml` → pnpm (`pnpm install --frozen-lockfile`, needs `corepack enable`)

## Detecting the start command
Read `package.json` `scripts.start` (or `scripts.build` + `scripts.start` for
TypeScript/Next.js). Don't assume `node index.js` — verify.

## Template (npm + TypeScript build, generalize for JS-only or other package managers)

```dockerfile
# ---- deps stage ----
FROM node:22.11-slim AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ---- build stage ----
FROM node:22.11-slim AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# ---- runtime stage ----
FROM node:22.11-slim AS runtime
ENV NODE_ENV=production
WORKDIR /app
RUN addgroup --system app && adduser --system --ingroup app app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=build --chown=app:app /app/dist ./dist
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD node -e "require('http').get('http://localhost:3000/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"
CMD ["node", "dist/index.js"]
```

Adjust for plain JS apps (no build stage needed — copy source directly after
`npm ci --omit=dev`). For Next.js, use `output: 'standalone'` in `next.config.js` and
copy `.next/standalone` + `.next/static` + `public` into the runtime stage — this
avoids shipping the full `node_modules` tree.

## Pitfalls
- `npm install` in the runtime/deps stage mutates the lockfile — always `npm ci`.
- Native addons (`bcrypt`, `sharp`) may fail on `-alpine` (musl) — use `-slim` (glibc)
  unless the repo already builds successfully on Alpine elsewhere (e.g. existing CI).
- Don't `COPY . .` before installing dependencies — breaks layer caching.
