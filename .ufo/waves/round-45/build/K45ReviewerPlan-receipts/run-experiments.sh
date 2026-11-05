#!/usr/bin/env bash
# run-experiments.sh -- drives the patched harness copies and prints one receipt per run.
set -u
S=/fast/scratch/hyaku/kagi-r45/K45ReviewerPlan
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S/iso"
echo "sh-target=$(readlink -f /bin/sh)"
echo "lane-dirty-before=$(git -C "$L" status --porcelain | wc -l)"

echo "== E1 c1 with always-exit-1 gate =="
C1_GATE_OVERRIDE="$S/g-always1.sh" bash "$S/h-c1.sh" LANE; echo "rc=$?"
echo "== E2 c1 with always-exit-0 gate =="
C1_GATE_OVERRIDE="$S/g-always0.sh" bash "$S/h-c1.sh" LANE; echo "rc=$?"
echo "== E3 c1 with fixture-marker-only gate (no bijection logic) =="
C1_GATE_OVERRIDE="$S/g-marker.sh" bash "$S/h-c1.sh" LANE; echo "rc=$?"

for r in fk-good fk-baseid fk-staged fk-setup; do
  echo "== $r =="
  ( cd "$S/$r" && C2_TARGET="$S/$r" bash "$S/h-c2.sh" LANE ); echo "rc=$?"
done

echo "lane-dirty-after=$(git -C "$L" status --porcelain | wc -l)"
echo "iso-leftovers=$(find "$S/iso" -mindepth 1 | wc -l)"
