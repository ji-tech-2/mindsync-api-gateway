#!/bin/sh
set -e

TEMPLATE="/usr/local/kong/declarative/kong.yml.tpl"
CONFIG="/usr/local/kong/declarative/kong.yml"
KEY_SECRET_FILE="/run/secrets/jwt_public_key"

# Load DECK_JWT_PUBLIC_KEY from mounted file if not already set via -e
if [ -z "$DECK_JWT_PUBLIC_KEY" ] && [ -f "$KEY_SECRET_FILE" ]; then
  echo "[entrypoint] Loading JWT public key from $KEY_SECRET_FILE"
  DECK_JWT_PUBLIC_KEY=$(cat "$KEY_SECRET_FILE")
  export DECK_JWT_PUBLIC_KEY
fi

# Validate required environment variables
if [ -z "$DECK_JWT_PUBLIC_KEY" ]; then
  echo "[entrypoint] ERROR: DECK_JWT_PUBLIC_KEY is not set and $KEY_SECRET_FILE does not exist."
  echo "[entrypoint] Either pass -e DECK_JWT_PUBLIC_KEY=... or mount the PEM file to $KEY_SECRET_FILE"
  exit 1
fi

# Use decK to render the kong.yml template, resolving ${{ env "..." }} placeholders.
echo "[entrypoint] Rendering kong.yml template with decK..."
deck file render "$TEMPLATE" -o "$CONFIG"
echo "[entrypoint] kong.yml rendered successfully."

# Delegate to the original Kong entrypoint
exec /docker-entrypoint.sh "$@"
