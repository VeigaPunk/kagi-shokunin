#!/bin/bash
here=$(cd "$(dirname "$0")" && pwd); mode=$(cat "$here/.mode"); REAL=$(cat "$here/.real")
( IFS=$'\x1f'; printf "%s\n" "$*" ) >> "$here/.argv"
case "$mode" in
sh1) if [ "${1:-}" = kv ] && [ "${2:-}" = put ]; then a=(); for x in "$@"; do case "$x" in -cas=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi ;;
sh2) if [ "${1:-}" = kv ] && [ "${2:-}" = undelete ]; then echo "Success! Data written to: ${@: -1}"; exit 0; fi ;;
sh3) if [ "${1:-}" = kv ] && [ "${2:-}" = destroy ]; then exec "$REAL" kv delete "${@:3}"; fi ;;
sh4) if [ "${1:-}" = kv ] && [ "${2:-}" = metadata ] && [ "${3:-}" = put ]; then a=(); for x in "$@"; do case "$x" in -max-versions=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi ;;
sh5) if [ "${1:-}" = kv ] && [ "${2:-}" = metadata ] && [ "${3:-}" = delete ]; then exec "$REAL" kv delete "${@: -1}"; fi ;;
esac
exec "$REAL" "$@"
