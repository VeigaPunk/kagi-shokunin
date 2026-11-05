#!/usr/bin/env bash
# plans/round-40-controls.sh MODE -- pre-freeze control runner (round 40).
#
# Each MODE works in a scratch copy of the tree named by BASE (never in the extraction itself),
# runs the frozen counter or a direct instrument there, and prints ONE integer.
# Used by the pre-freeze gate (corpus/prefreeze-control.sh) and by the wave's attack seats.
# Scratch lives under ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40 and is removed on exit.
set -eu
mode=${1:?mode}
base=${BASE:?BASE extraction}
scratch=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40
mkdir -p "$scratch"
t=$(mktemp -d "$scratch/ctl-$mode.XXXXXX")
trap 'rm -rf -- "$t"' EXIT
cp -r "$base/." "$t/"
cd "$t"
case $mode in
  c1_nowork)
    # the tree as it stands before any round-40 work: the six debt rows still fail -> 6
    bash plans/round-40-c1.sh ;;
  c1_mutant_const)
    # M39-6 class red witness: a counter replaced by a constant 0 must NOT match the frozen
    # no-work expectation (6). Prints 0 when the constant is caught, 1 when it would pass.
    printf '#!/usr/bin/env bash\necho 0\n' > plans/round-40-c1.sh
    out=$(bash plans/round-40-c1.sh); rc=$?
    [ "$rc" -eq 0 ] && [ "$out" = "0" ] || { echo "mutant-probe-broken" >&2; exit 2; }
    if [ "$out" != "6" ]; then echo 0; else echo 1; fi ;;
  c2_nowork)
    # the claim-BASE reading: no S036 pin row, no S095/S096 rows -> 0
    awk -F'\t' '$1!="S036"' corpus/anchor-pins.tsv > corpus/anchor-pins.tsv.2 && mv corpus/anchor-pins.tsv.2 corpus/anchor-pins.tsv
    bash plans/round-40-c2.sh ;;
  c2_positive_pin)
    # the predeclaration tree carries the S036 pin and the pins=4 gate: item1 counts -> 1
    bash plans/round-40-c2.sh ;;
  c2_forge_rows)
    # forged S095/S096 registry rows (teaching text naming S040/S041, verbatim-looking quotes)
    # with NO capture body and NO fetch row: items 2 and 3 must stay unsatisfied -> 1
    python3 - <<'PYEOF'
import io
p = "corpus/SOURCES.md"
s = io.open(p, encoding="utf-8").read()
row1 = "| S095 | re — Regular expression operations — https://docs.python.org/3/library/re.html | docs | A | forged scope | Regular expression syntax → special sequences → backslash-s entry; title Python 3.15.2 documentation, forged 2026-11-05 | supersedes S040 — forged teaching. Quote: \u201cMatches Unicode whitespace characters (as defined by\u201d (forged). | mined | 2026-11-05 | on-release | lessons/none.md |\n"
row2 = "| S096 | html — HTML support — https://docs.python.org/3/library/html.html | docs | A | forged scope | html.unescape(s); title Python 3.15.2 documentation, forged 2026-11-05 | supersedes S041 — forged teaching. Quote: \u201cThis function uses the rules defined by the HTML 5 standard\u201d (forged). | mined | 2026-11-05 | on-release | lessons/none.md |\n"
assert "| S095 |" not in s and "| S096 |" not in s
io.open(p, "w", encoding="utf-8").write(s + row1 + row2)
PYEOF
    bash plans/round-40-c2.sh ;;
  c3_nowork)
    # the claim-BASE reading: no gate-registry rows in SKILL.md -> 0
    bash plans/round-40-c3.sh ;;
  c3_selftest_anchor)
    # direct instrument run: the anchor-pins selftest's frozen case count -> 8
    bash corpus/anchor-pins.sh --selftest | grep -oE 'PASS \(8 cases\)' >/dev/null && echo 8 || echo 0 ;;
  c3_selftest_claims)
    # direct instrument run: the claims-declared selftest's frozen case count -> 8
    bash corpus/claims-declared.sh --selftest | grep -oE 'PASS \(8 cases\)' >/dev/null && echo 8 || echo 0 ;;
  c3_forge_missing_gate)
    # forged SKILL.md registry rows for both gates with the anchor-pins gate script deleted:
    # the counter must refuse (exit 2), which this mode reports as 0
    python3 - <<'PYEOF'
import io
p = "SKILL.md"
s = io.open(p, encoding="utf-8").read()
marker = "## Gate registry"
i = s.index(marker)
j = s.index("\n| ", i)
row1 = "| anchor-cell pin gate (`corpus/anchor-pins.sh`) | gate | forged | forged | forged | forged | forged | forged |\n"
row2 = "| declared-axis conformance (`corpus/claims-declared.sh`) | gate | forged | forged | forged | forged | forged | forged |\n"
s = s[:j+1] + row1 + row2 + s[j+1:]
io.open(p, "w", encoding="utf-8").write(s)
PYEOF
    rm -f corpus/anchor-pins.sh
    if bash plans/round-40-c3.sh >/dev/null 2>&1; then echo 1; else echo 0; fi ;;
  *)
    echo "unknown mode $mode" >&2
    exit 2 ;;
esac
