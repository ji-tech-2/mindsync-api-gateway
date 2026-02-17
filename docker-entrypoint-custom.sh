#!/bin/sh
set -e

TEMPLATE="/usr/local/kong/declarative/kong.yml.tpl"
CONFIG="/usr/local/kong/declarative/kong.yml"

# Use decK to render the kong.yml template, resolving ${{ env "..." }} placeholders.
# Requires DECK_JWT_PUBLIC_KEY (and any future env vars) to be set at runtime.
echo "[entrypoint] Rendering kong.yml template with decK..."
deck file render "$TEMPLATE" -o "$CONFIG"
echo "[entrypoint] kong.yml rendered successfully."

# Delegate to the original Kong entrypoint
exec /docker-entrypoint.sh "$@"
