#!/usr/bin/env bash
# Probe: does the landed census gate EXECUTE a script taken from the tree it audits?
#
# Method: build a scratch tree that is a copy of the lane, plant a marker-writing
# `corpus/rendered-text-v1.py` in it, and run the gate with --root pointing at it.
# If the marker file appears, the gate executed code supplied by the audited tree.
#
# Nothing in the lane is touched: the tree is a scratch copy under the seat scratch.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
T="$SCRATCH/probe-exec"
rm -rf "$T"; mkdir -p "$T"
cp -a "$LANE/corpus" "$T/corpus"
rm -f "$T/marker.txt"
cat > "$T/corpus/rendered-text-v1.py" <<'PY'
import sys, os
# Stand in for the normalizer. If the gate runs this file, the marker appears.
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "marker.txt"), "w").write("executed\n")
if sys.argv[1:2] == ["locate"]:
    print("RENDERED_TEXT_V1_LOCATE: count=1")
    sys.exit(0)
print("RENDERED_TEXT_V1: raw_sha256=- bytes=0 normalized_sha256=- normalized_bytes=0")
PY
echo "--- gate run against the planted tree ---"
( cd "$T" && bash "$LANE/corpus/sources-census.sh" verify --root "$T" 2>&1 | tail -4 )
echo "gate_rc=$?"
echo "--- marker present? ---"
if [ -f "$T/marker.txt" ]; then
  echo "MARKER_PRESENT: the gate executed corpus/rendered-text-v1.py FROM THE AUDITED TREE"
else
  echo "MARKER_ABSENT: the gate did not execute the audited tree's normalizer"
fi
echo "--- BASE comparison: does the BASE gate do the same? ---"
rm -f "$T/marker.txt"
cp "$SCRATCH/out/base-census.sh" "$T/base-census.sh"
( cd "$T" && bash "$T/base-census.sh" verify --root "$T" 2>&1 | tail -3 )
if [ -f "$T/marker.txt" ]; then
  echo "BASE_MARKER_PRESENT"
else
  echo "BASE_MARKER_ABSENT: BASE gate has no python3 execution at all (grep -c python3 = 0)"
fi
rm -f "$T/marker.txt"
exit 0
