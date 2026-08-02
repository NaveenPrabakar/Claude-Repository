# Python Backend (Flask / FastAPI / Django)

## Detecting dependency management
- `requirements.txt` → pip
- `pyproject.toml` with `[tool.poetry]` → Poetry
- `pyproject.toml` with `[project]` + `uv.lock` → uv
- `Pipfile` → pipenv

## Detecting the framework and entrypoint
- FastAPI/Starlette → served via `uvicorn`, check `main.py`/`app/main.py` for the ASGI
  app variable name (commonly `app`).
- Flask → served via `gunicorn` in production, not `flask run` (dev server only).
- Django → served via `gunicorn`, check `wsgi.py`/`asgi.py` location and
  `DJANGO_SETTINGS_MODULE`.

## Template (pip + FastAPI, generalize for other combinations)

```dockerfile
# ---- build stage ----
FROM python:3.12-slim AS build
WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- runtime stage ----
FROM python:3.12-slim AS runtime
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
COPY --chown=app:app . .
USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request;urllib.request.urlopen('http://localhost:8000/health')" || exit 1
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

For Django: `CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]`
and remember `python manage.py collectstatic --noinput` needs to run at build time (not
at container start) if static files are served by the app itself rather than a CDN/nginx.

For Poetry, replace the deps stage with:
```dockerfile
RUN pip install --no-cache-dir poetry \
  && poetry config virtualenvs.in-project true \
  && poetry install --no-root --only main
```

## Pitfalls
- Never use `flask run` or Django's `runserver` in production — always gunicorn/uvicorn.
- `PYTHONDONTWRITEBYTECODE=1` and `PYTHONUNBUFFERED=1` avoid stray `.pyc` files and
  ensure logs stream correctly instead of buffering.
- If native deps need compilation (`psycopg2` without `-binary`, `numpy` from source on
  uncommon architectures), the build stage needs `build-essential`/`gcc` — the runtime
  stage should not, hence the venv-copy pattern above.
- Watch for `DEBUG=True` left in settings — flag it if found, it should be
  environment-driven and default to `False` in the image.
