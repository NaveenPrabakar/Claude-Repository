# docker-compose.yml Generation

Used when a repo has more than one deployable unit (frontend + backend, or backend +
database, etc.) or the user explicitly asks for compose.

## Baseline structure

```yaml
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    depends_on:
      - backend
    networks:
      - app-network

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  db-data:
```

## Rules

- Never hardcode credentials in the compose file — always `${VAR}` sourced from a
  `.env` file (generate a `.env.example` alongside it listing the required vars with
  placeholder values, not real secrets).
- Detect the actual database/cache the app uses from its dependencies (`psycopg2`,
  `pg`, `mysql2`, `redis`, `pymongo`, etc.) rather than defaulting to Postgres —
  Postgres above is just the common-case example.
- Use `depends_on` with `condition: service_healthy` (not just startup order) for
  services where the app will crash if it connects before the dependency is ready —
  requires a `healthcheck` block on that service.
- Give services a private `networks:` entry rather than relying on the default bridge
  network, so only explicitly connected services can reach each other.
- Only publish (`ports:`) what genuinely needs host access — an internal service that
  only the backend talks to doesn't need a host port mapping.
- If the repo already has a `docker-compose.yml`, read it first and preserve any
  custom service names/conventions rather than overwriting the structure wholesale.
