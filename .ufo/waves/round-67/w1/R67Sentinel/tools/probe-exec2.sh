#!/usr/bin/env bash
# Probe 2: reach the quote-locate call. The first probe returned early on
# capture-missing (the scratch tree had no .ufo captures), so the locate path
# was never taken. This copy carries the whole lane tree (captures included) so
# the gate reaches cap_locate(), which is where the python3 call lives.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
T="$SCRATCH/probe-exec2"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -
rm -f "$T/marker.txt"
cat > "$T/corpus/rendered-text-v1.py" <<'PY'
import sys, os
d = os.path.dirname(os.path.abspath(__file__))
open(os.path.join(d, "..", "marker.txt"), "w").write("executed\n")
if sys.argv[1:2] == ["locate"]:
    print("RENDERED_TEXT_V1_LOCATE: count=1")
    sys.exit(0)
print("RENDERED_TEXT_V1: raw_sha256=%s bytes=1 normalized_sha256=%s normalized_bytes=1" % ("0"*64, "0"*64))
PY
echo "--- gate run (landed) against the planted tree ---"
bash "$LANE/corpus/sources-census.sh" verify --root "$T" 2>&1 | tail -4
echo "--- marker? ---"
[ -f "$T/marker.txt" ] && echo "MARKER_PRESENT: the gate executed corpus/rendered-text-v1.py FROM THE AUDITED TREE" || echo "MARKER_ABSENT"
echo
echo "--- BASE gate against the same planted tree ---"
rm -f "$T/marker.txt"
cp "$SCRATCH/out/base-census.sh" "$T/base-census.sh"
bash "$T/base-census.sh" verify --root "$T" 2>&1 | tail -2
[ -f "$T/marker.txt" ] && echo "BASE_MARKER_PRESENT" || echo "BASE_MARKER_ABSENT"
rm -f "$T/marker.txt"
exit 0
