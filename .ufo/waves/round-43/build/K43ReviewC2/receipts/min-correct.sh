#!/usr/bin/env bash
# K43ReviewC2 item-4 minimal correct gate: snapshot both controls dirs, delete,
# replay the clone's committed runners (each must exit 0), require the eight frozen
# manifest receipts to byte-match their snapshots, restore the snapshot, exit 0/1/2.
set -u
[ "${1:-}" = "--clone" ] && [ -n "${2:-}" ] || { echo "usage: $0 --clone <dir>" >&2; exit 2; }
C=$(cd -- "$2" && pwd -P) || { echo "setup: clone" >&2; exit 2; }
[ -f "$C/plans/round-42-controls.sh" ] && [ -f "$C/plans/round-41-controls.sh" ] || { echo "setup: runners" >&2; exit 2; }
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/min-gate.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
M42=".ufo/waves/round-42/controls/c1-control-refuse-all.txt .ufo/waves/round-42/controls/c1-control-accept-all.txt .ufo/waves/round-42/controls/c2-derivation-D.txt"
M41=".ufo/waves/round-41/controls/c1-control-refuse-all.txt .ufo/waves/round-41/controls/c1-control-accept-all.txt .ufo/waves/round-41/controls/c1-control-no-gate.txt .ufo/waves/round-41/controls/c2-control-decoy.txt .ufo/waves/round-41/controls/c2-base-19025d9.txt"
( cd -- "$C" && find .ufo/waves/round-42/controls .ufo/waves/round-41/controls -type f -print0 ) > "$SCR/list" || { echo "setup: snapshot" >&2; exit 2; }
mkdir -p -- "$SCR/snap"
while IFS= read -r -d '' f; do
  mkdir -p -- "$SCR/snap/$(dirname -- "$f")"
  cp -a -- "$C/$f" "$SCR/snap/$f" || { echo "setup: snap $f" >&2; exit 2; }
done < "$SCR/list"
( cd -- "$C" && find .ufo/waves/round-42/controls .ufo/waves/round-41/controls -type f -delete ) || { echo "setup: delete" >&2; exit 2; }
bash "$C/plans/round-42-controls.sh" >/dev/null 2>&1 || { echo "refused: r42 runner rc!=0" >&2; exit 1; }
bash "$C/plans/round-41-controls.sh" >/dev/null 2>&1 || { echo "refused: r41 runner rc!=0" >&2; exit 1; }
for f in $M42 $M41; do
  [ -f "$C/$f" ] || { echo "refused: missing $f" >&2; exit 1; }
  cmp -s -- "$SCR/snap/$f" "$C/$f" || { echo "refused: byte-diff $f" >&2; exit 1; }
done
while IFS= read -r -d '' f; do
  cp -a -- "$SCR/snap/$f" "$C/$f" || { echo "setup: restore $f" >&2; exit 2; }
done < "$SCR/list"
exit 0
