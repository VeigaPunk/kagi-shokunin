#!/usr/bin/env bash
# K43ReviewC2 item-3 shape-keyed gate: refuses ONLY the two counter fixture shapes
# (silent runner != HEAD bytes; stale D receipt != 1); replays nothing; exits 0 otherwise.
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] || { echo "usage: $0 --clone <dir>" >&2; exit 2; }
C=$2
if ! cmp -s <(git -C "$C" show HEAD:plans/round-42-controls.sh 2>/dev/null) "$C/plans/round-42-controls.sh"; then
  exit 1
fi
[ "$(cat "$C/.ufo/waves/round-42/controls/c2-derivation-D.txt" 2>/dev/null)" = "1" ] || exit 1
exit 0
