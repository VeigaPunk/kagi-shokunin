#!/usr/bin/env bash
# Probe 8b: decisive remediation validation for V-2.
#
# Setup: a scratch tree where every rendered-text-v1 path row's quote is broken
# AND the tree ships a normalizer that reports count=1 for every quote except
# the counter's own sentinel string.
#
#   UNPATCHED counter: derivation and gate BOTH read the tree's liar ->
#                      they agree -> guard (a) CLEAN -> the target is reachable
#                      on a tree whose quotes do not locate.
#   PATCHED counter  : derivation reads the LANE's own normalizer (an absolute
#                      path outside the measured tree) -> derivation says
#                      located=5, gate says located=36 -> they DISAGREE ->
#                      guard (a) FAILS -> the target is unreachable.
#
# The lane's counter is NOT edited.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
T="$SCRATCH/probe-control2"
PC="$SCRATCH/patched-c1.sh"

# restore the liar in the tree
cat > "$T/corpus/rendered-text-v1.py" <<'PY'
import sys
if sys.argv[1:2] == ["locate"]:
    q = sys.argv[3] if len(sys.argv) > 3 else ""
    if "zzc1notlocatedquotezz" in q:
        print("RENDERED_TEXT_V1_LOCATE: count=0"); sys.exit(1)
    print("RENDERED_TEXT_V1_LOCATE: count=1"); sys.exit(0)
print("RENDERED_TEXT_V1: raw_sha256=%s bytes=1 normalized_sha256=%s normalized_bytes=1" % ("0"*64, "0"*64))
PY

cp "$LANE/plans/round-67-c1.sh" "$PC"
python3 - "$PC" "$LANE" <<'PY'
import sys
p, lane = sys.argv[1], sys.argv[2]
s = open(p).read()
old = 'script = os.path.join(tree, "corpus/rendered-text-v1.py")'
new = 'script = os.path.join(%r, "corpus/rendered-text-v1.py")' % lane
assert old in s, "anchor not found"
open(p, "w").write(s.replace(old, new))
print("patched ->", new)
PY

echo
echo "=== UNPATCHED counter (tree's liar drives both sides) ==="
( cd "$T" && timeout 2400 bash "$LANE/plans/round-67-c1.sh" --tree "$T" --scratch "$SCRATCH/probe-scratch/u8" ) 2>&1 \
  | grep -E 'derived |guard-a|mut-|C1_READTHROUGH' | head -12
echo
echo "=== PATCHED counter (derivation uses the lane's own normalizer) ==="
( cd "$T" && timeout 2400 bash "$PC" --tree "$T" --scratch "$SCRATCH/probe-scratch/p8" ) 2>&1 \
  | grep -E 'derived |guard-a|mut-|C1_READTHROUGH' | head -12
exit 0
