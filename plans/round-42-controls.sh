#!/usr/bin/env bash
# plans/round-42-controls.sh -- BASE readings and discrimination controls for the frozen round-42
# counters (plans/round-42-c1.sh, plans/round-42-c2.sh). Writes receipts under .ufo/waves/round-42/controls/.
# Expected at the claim BASE e8265c0: C1 base 4 (target 5); blanket-refuse 0; blanket-accept 0;
# C2 base 0 (target 1); C2 derivation D 1.
# Scratch root: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r42/controls.<pid> (deleted on exit).
set -u
cd "$(dirname "$0")/.."
BASE=19025d97e5013bac2f45d6b9e61bfbafc84c3c8d
OUT=.ufo/waves/round-42/controls
S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r42/controls.$$
mkdir -p -- "$OUT" "$S" || exit 2
trap 'rm -rf -- "$S"' EXIT

printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: REFUSED (violations=1)"; exit 1\n' > "$S/refuse-all.sh"
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0\n' > "$S/accept-all.sh"

EXPECT_JOURNAL="$S/refuse-all.sh" bash plans/round-42-c1.sh > "$OUT/c1-control-refuse-all.txt" 2>&1
echo "CONTROL c1-blanket-refuse N=$(tail -1 "$OUT/c1-control-refuse-all.txt")"
EXPECT_JOURNAL="$S/accept-all.sh" bash plans/round-42-c1.sh > "$OUT/c1-control-accept-all.txt" 2>&1
echo "CONTROL c1-blanket-accept N=$(tail -1 "$OUT/c1-control-accept-all.txt")"
bash plans/round-42-c1.sh > "$OUT/c1-base.txt" 2>&1
echo "C1 BASE N=$(tail -1 "$OUT/c1-base.txt")"

# C2 derivation D: the frozen round-41 C2 counter over a git archive of the claim BASE.
mkdir -p -- "$S/base/plans" && git archive "$BASE" | tar -x -f - -C "$S/base" \
  && cp -- plans/round-41-c2.sh "$S/base/plans/round-41-c2.sh" || { echo "controls: derivation setup failed" >&2; exit 2; }
(cd "$S/base" && bash plans/round-41-c2.sh 2>/dev/null) > "$OUT/c2-derivation-D.txt"
echo "C2 derivation D=$(tail -1 "$OUT/c2-derivation-D.txt")"

bash plans/round-42-c2.sh > "$OUT/c2-base.txt" 2>&1
echo "C2 BASE N=$(tail -1 "$OUT/c2-base.txt")"
