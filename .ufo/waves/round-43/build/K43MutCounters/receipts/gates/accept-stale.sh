#!/usr/bin/env bash
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] && [ -d "$2" ] || { echo "gate: setup" >&2; exit 2; }
CLONE=$2
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/c2accstale.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
M42=$CLONE/.ufo/waves/round-42/controls
[ -d "$M42" ] || { echo "gate: setup" >&2; exit 2; }
cp -a "$M42" "$SCR/snap" || exit 2
rm -rf -- "$M42"
(cd "$CLONE" && bash plans/round-42-controls.sh) > "$SCR/r42.log" 2>&1; R42=$?
BAD=0
for rel in c1-control-refuse-all.txt c1-control-accept-all.txt; do
  [ -f "$M42/$rel" ] && cmp -s "$M42/$rel" "$SCR/snap/$rel" || BAD=1
done
rm -rf -- "$M42"; cp -a "$SCR/snap" "$M42" || { echo "gate: restore failed" >&2; exit 2; }
[ "$R42" = "0" ] && [ "$BAD" = "0" ] || exit 1
exit 0
