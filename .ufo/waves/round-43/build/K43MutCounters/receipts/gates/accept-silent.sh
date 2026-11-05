#!/usr/bin/env bash
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] && [ -d "$2" ] || { echo "gate: setup" >&2; exit 2; }
CLONE=$2
MANIFEST=".ufo/waves/round-42/controls/c1-control-refuse-all.txt
.ufo/waves/round-42/controls/c1-control-accept-all.txt
.ufo/waves/round-42/controls/c2-derivation-D.txt
.ufo/waves/round-41/controls/c1-control-refuse-all.txt
.ufo/waves/round-41/controls/c1-control-accept-all.txt
.ufo/waves/round-41/controls/c1-control-no-gate.txt
.ufo/waves/round-41/controls/c2-control-decoy.txt
.ufo/waves/round-41/controls/c2-base-19025d9.txt"
while IFS= read -r rel; do
  git -C "$CLONE" show "HEAD:$rel" 2>/dev/null | cmp -s - "$CLONE/$rel" || exit 1
done <<LIST
$MANIFEST
LIST
exit 0
