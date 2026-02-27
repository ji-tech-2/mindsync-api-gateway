# Test stage - run unit tests
FROM python:3.11-slim AS test

WORKDIR /app

COPY kong.yml /app/kong.yml
COPY requirements-test.txt /app/requirements-test.txt
COPY tests /app/tests

RUN pip install --no-cache-dir -r requirements-test.txt

RUN python -m unittest discover -s tests -p "test_*.py" -v

# Production stage - Kong Gateway
FROM kong:3.6

# Create directories for declarative config and SSL certificates
RUN mkdir -p /usr/local/kong/declarative /usr/local/kong/ssl

COPY kong.local.yml /usr/local/kong/declarative/kong.yml

ENV KONG_DATABASE=off
ENV KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml

ENV KONG_ADMIN_LISTEN=off
ENV KONG_STATUS_LISTEN=0.0.0.0:8100

ENV KONG_PROXY_ACCESS_LOG=/dev/stdout
ENV KONG_PROXY_ERROR_LOG=/dev/stderr

EXPOSE 80 443 8100

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD curl -fs http://localhost:8100/status || exit 1
