# Ruby (Rails / Sinatra)

## Detecting the framework
`Gemfile` containing `rails` → Rails; containing `sinatra` → Sinatra (much lighter,
skip Rails-specific steps like asset precompilation).

## Template (Rails)

```dockerfile
# ---- build stage ----
FROM ruby:3.3-slim AS build
WORKDIR /app
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential libpq-dev git \
  && rm -rf /var/lib/apt/lists/*
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && bundle install --jobs 4
COPY . .
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# ---- runtime stage ----
FROM ruby:3.3-slim AS runtime
RUN apt-get update -qq && apt-get install -y --no-install-recommends libpq5 \
  && rm -rf /var/lib/apt/lists/* \
  && addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=1 RAILS_SERVE_STATIC_FILES=1
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=app:app /app /app
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:3000/up || exit 1
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

## Pitfalls
- `libpq-dev` (build) vs `libpq5` (runtime) — only install the dev headers where
  compilation happens; the runtime stage only needs the shared library.
- Asset precompilation needs a dummy `SECRET_KEY_BASE` at build time if the app doesn't
  otherwise provide one — real secrets are still injected at runtime via env vars.
- Rails 7+ ships a default `/up` health check route; older apps may not have one —
  verify before assuming the `HEALTHCHECK` path is valid.
- Sinatra apps are much lighter — usually no asset precompilation or `build-essential`
  needed unless a gem has native extensions (check `Gemfile.lock` for `mini_racer`,
  `nokogiri`, `pg`, etc.).
