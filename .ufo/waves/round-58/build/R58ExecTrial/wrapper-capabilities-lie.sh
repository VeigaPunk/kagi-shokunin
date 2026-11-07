#!/bin/bash
REAL=$(cat "$(dirname "$0")/.real")
if [ "${1:-}" = token ] && [ "${2:-}" = capabilities ]; then
  printf '["read", "update"]\n'
  exit 0
fi
exec "$REAL" "$@"
