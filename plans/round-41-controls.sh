#!/usr/bin/env bash
# plans/round-41-controls.sh -- discrimination controls for the frozen round-41 counters.
# Prints one line per control: `CONTROL <name> N=<integer>` and writes receipts under
# .ufo/waves/round-41/controls/. Expected: every control reads N=0 for C1, C2 decoy reads N<=2.
# Scratch root: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/controls.<pid> (deleted on exit).
set -u
cd "$(dirname "$0")/.."
OUT=.ufo/waves/round-41/controls
S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/controls.$$
mkdir -p -- "$OUT" "$S" || exit 2
trap 'rm -rf -- "$S"' EXIT

printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: REFUSED (violations=1)"; exit 1\n' > "$S/refuse-all.sh"
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0\n' > "$S/accept-all.sh"

EXPECT_JOURNAL="$S/refuse-all.sh" bash plans/round-41-c1.sh > "$OUT/c1-control-refuse-all.txt" 2>&1
echo "CONTROL c1-blanket-refuse N=$(tail -1 "$OUT/c1-control-refuse-all.txt")"
EXPECT_JOURNAL="$S/accept-all.sh" bash plans/round-41-c1.sh > "$OUT/c1-control-accept-all.txt" 2>&1
echo "CONTROL c1-blanket-accept N=$(tail -1 "$OUT/c1-control-accept-all.txt")"
EXPECT_JOURNAL="$S/absent-gate.sh" bash plans/round-41-c1.sh > "$OUT/c1-control-no-gate.txt" 2>&1
echo "CONTROL c1-no-gate N=$(tail -1 "$OUT/c1-control-no-gate.txt")"

python3 - "$S" <<'PY'
import sys, subprocess, os
s = sys.argv[1]
src = subprocess.run(["git", "show", "19025d97e5013bac2f45d6b9e61bfbafc84c3c8d:corpus/rendered-text-v1.py"], capture_output=True, text=True, check=True).stdout
out, done = [], False
for line in src.splitlines(keepends=True):
    if not done and line.startswith("Sources (opened round 24"):
        out.append("Sources (decoy): S027 Python re; Matches Unicode whitespace characters (as defined by\n")
        done = True
    else:
        out.append(line)
assert done
open(os.path.join(s, "rtv1-decoy.py"), "w", encoding="utf-8").write("".join(out))
PY
RTV1="$S/rtv1-decoy.py" bash plans/round-41-c2.sh > "$OUT/c2-control-decoy.txt" 2>&1
echo "CONTROL c2-decoy-superseded N=$(tail -1 "$OUT/c2-control-decoy.txt")"
bash plans/round-41-c2.sh > "$OUT/c2-base-19025d9.txt" 2>&1
echo "C2 BASE N=$(tail -1 "$OUT/c2-base-19025d9.txt")"
