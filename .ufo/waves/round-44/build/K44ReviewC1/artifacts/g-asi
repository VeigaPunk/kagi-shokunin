#!/usr/bin/env bash
# round-44 negative fixture gate (accept-silent): refuses ONLY the stale shape.
set -u
[ "$#" -eq 2 ] && [ "$1" = "--clone" ] && [ -n "$2" ] || { echo "usage: --clone <dir>" >&2; exit 2; }
D=$2
F=$D/.ufo/waves/round-42/controls/c2-derivation-D.txt
if [ -f "$F" ] && [ "$(cat "$F")" = "2" ]; then
  exit 1
fi
exit 0
