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

# Install decK for declarative config templating (env var interpolation)
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && curl -sL https://github.com/kong/deck/releases/download/v1.36.1/deck_1.36.1_linux_amd64.tar.gz \
  -o /tmp/deck.tar.gz \
  && tar -xzf /tmp/deck.tar.gz -C /usr/local/bin deck \
  && rm /tmp/deck.tar.gz \
  && apt-get purge -y curl \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

# Copy the kong.yml template (contains ${{ env "..." }} placeholders)
COPY kong.yml /usr/local/kong/declarative/kong.yml.tpl

# Custom entrypoint: render template with deck, then start Kong
COPY --chmod=755 docker-entrypoint-custom.sh /docker-entrypoint-custom.sh

ENV KONG_DATABASE=off
ENV KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml

ENV KONG_PROXY_ACCESS_LOG=/dev/stdout
ENV KONG_ADMIN_ACCESS_LOG=/dev/stdout
ENV KONG_PROXY_ERROR_LOG=/dev/stderr
ENV KONG_ADMIN_ERROR_LOG=/dev/stderr

EXPOSE 80 443 8001

ENTRYPOINT ["/docker-entrypoint-custom.sh"]
CMD ["kong", "docker-start"]

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD curl -fs http://localhost:8001/status || exit 1
