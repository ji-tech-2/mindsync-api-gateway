#!/bin/sh
set -e

CONFIG="/usr/local/kong/declarative/kong.yml"

# Substitute the JWT_PUBLIC_KEY placeholder with the actual environment variable.
# The env var should contain the PEM-formatted RSA public key with literal \n
# characters representing newlines, e.g.:
#   JWT_PUBLIC_KEY="-----BEGIN PUBLIC KEY-----\nMIIBI...\n-----END PUBLIC KEY-----"
#
# YAML double-quoted strings interpret \n as actual newlines, so the final
# kong.yml will contain a valid multi-line PEM key after substitution.

if [ -n "$JWT_PUBLIC_KEY" ]; then
  # Use awk to safely handle special characters in the key (/, +, =)
  awk -v key="$JWT_PUBLIC_KEY" '{ gsub(/JWT_PUBLIC_KEY_PLACEHOLDER/, key); print }' \
    "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"
fi

# Delegate to the original Kong entrypoint
exec /docker-entrypoint.sh "$@"
