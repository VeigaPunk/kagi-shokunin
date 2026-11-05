#!/usr/bin/env bash
# K45Sentinel: print redacted context for selected hits. The matched substring is replaced
# with [REDACTED] before printing, so no candidate secret value is ever emitted.
set -u
redact() { # redact PATTERN ERE FILE
  local name="$1" re="$2" f="$3"
  grep -nE "$re" "$f" 2>/dev/null | while IFS= read -r row; do
    ln=${row%%:*}
    rest=${row#*:}
    red=$(printf '%s\n' "$rest" | grep -oE "$re" | head -n1)
    if [ -n "$red" ]; then
      out=$(printf '%s\n' "$rest" | sed "s|$(printf '%s' "$red" | sed 's/[]\/$*.^|[]/\\&/g')|[REDACTED]|")
      printf '%s\t%s:%s\t%s\n' "$name" "$f" "$ln" "$out"
    fi
  done
}
case "${1:-}" in
  hex) redact LONG_HEX '[0-9a-fA-F]{40,}' "${2:-}" ;;
  b64) redact LONG_B64 '[A-Za-z0-9+/]{48,}={0,2}' "${2:-}" ;;
  phone) redact PHONE '\+?[0-9][0-9 ()-]{9,14}[0-9]' "${2:-}" ;;
esac
