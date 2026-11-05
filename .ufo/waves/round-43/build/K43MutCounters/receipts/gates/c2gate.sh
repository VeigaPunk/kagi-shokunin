#!/usr/bin/env bash
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] && [ -d "$2" ] || { echo "gate: setup" >&2; exit 2; }
CLONE=$2
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c2gate.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
M41=$CLONE/.ufo/waves/round-41/controls
M42=$CLONE/.ufo/waves/round-42/controls
[ -d "$M41" ] && [ -d "$M42" ] || { echo "gate: setup" >&2; exit 2; }
cp -a "$M41" "$SCR/snap-r41" && cp -a "$M42" "$SCR/snap-r42" || { echo "gate: setup" >&2; exit 2; }
rm -rf -- "$M41" "$M42"
(cd "$CLONE" && bash plans/round-42-controls.sh) > "$SCR/r42.log" 2>&1; R42=$?
(cd "$CLONE" && bash plans/round-41-controls.sh) > "$SCR/r41.log" 2>&1; R41=$?
MANIFEST=".ufo/waves/round-42/controls/c1-control-refuse-all.txt
.ufo/waves/round-42/controls/c1-control-accept-all.txt
.ufo/waves/round-42/controls/c2-derivation-D.txt
.ufo/waves/round-41/controls/c1-control-refuse-all.txt
.ufo/waves/round-41/controls/c1-control-accept-all.txt
.ufo/waves/round-41/controls/c1-control-no-gate.txt
.ufo/waves/round-41/controls/c2-control-decoy.txt
.ufo/waves/round-41/controls/c2-base-19025d9.txt"
BAD=0
while IFS= read -r rel; do
  p41=$SCR/snap-r41/${rel#.ufo/waves/round-41/controls/}
  p42=$SCR/snap-r42/${rel#.ufo/waves/round-42/controls/}
  case "$rel" in
    .ufo/waves/round-41/*) snap=$p41 ;;
    .ufo/waves/round-42/*) snap=$p42 ;;
  esac
  if [ ! -f "$CLONE/$rel" ] || ! cmp -s "$CLONE/$rel" "$snap"; then BAD=1; fi
done <<LIST
$MANIFEST
LIST
rm -rf -- "$M41" "$M42"
cp -a "$SCR/snap-r41" "$M41" && cp -a "$SCR/snap-r42" "$M42" || { echo "gate: restore failed" >&2; exit 2; }
[ "$R42" = "0" ] && [ "$R41" = "0" ] && [ "$BAD" = "0" ] || { echo "gate: refused" >&2; exit 1; }
exit 0
