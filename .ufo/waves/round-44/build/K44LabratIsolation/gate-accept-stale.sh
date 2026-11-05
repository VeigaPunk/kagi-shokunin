#!/usr/bin/env bash
# round-44 negative fixture gate (accept-stale): refuses ONLY the silent shape.
set -u
[ "$#" -eq 2 ] && [ "$1" = "--clone" ] && [ -n "$2" ] || { echo "usage: --clone <dir>" >&2; exit 2; }
D=$2
if [ -f "$D/plans/round-42-controls.sh" ] \
   && [ "$(wc -l < "$D/plans/round-42-controls.sh")" -le 2 ] \
   && grep -q '^exit 0' "$D/plans/round-42-controls.sh"; then
  exit 1
fi
exit 0
