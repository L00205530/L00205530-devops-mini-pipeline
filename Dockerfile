# Stage 1: Build production dependencies
FROM python:3.14-slim AS builder

WORKDIR /build

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements-prod.txt .

RUN pip install --no-cache-dir -r requirements-prod.txt \
    && python -m pip uninstall -y pip setuptools wheel \
    && rm -rf /opt/venv/lib/python3.14/site-packages/pip \
              /opt/venv/lib/python3.14/site-packages/pip-*.dist-info


# Stage 2: Production runtime
FROM python:3.14-slim AS runtime

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

# Apply Debian security updates
RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Remove pip and unused package management tools
RUN python -m pip uninstall -y pip setuptools wheel \
    && rm -rf /usr/local/lib/python3.14/site-packages/pip \
              /usr/local/lib/python3.14/site-packages/pip-*.dist-info

COPY --from=builder /opt/venv /opt/venv

COPY app/ ./app/

RUN useradd --create-home --uid 10001 appuser

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app.main:app"]
