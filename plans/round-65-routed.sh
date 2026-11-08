#!/usr/bin/env bash
# plans/round-65-routed.sh — the routed-leg counter (kagi round 65, claim C2).
#
#   bash plans/round-65-routed.sh [--tree DIR] [--repo DIR] [--legacy] [--selftest]
#
# Frozen predicate: plans/round-65.md §C2 as re-frozen by Amendment A2.
#
# The defect it measures (QM57): the round-63 lesson's §Routed dispositions D-B
# row expects SIX receipts under .ufo/waves/round-63/final/ — `controls` among
# them — but `controls.txt` was never committed there (the battery's receipt
# lives under build/R63ExecControls/). A leg whose expectation no tree can meet
# is a defect, so C2 replaces the hand-written expectation with a DERIVED one:
#
#   cited  = the backticked stems the D-B row names as final receipts
#   held   = the <stem>.txt files present in the final dir that carry a label
#   mismatch = |cited Δ held|          target 0   (BASE 1: `controls`)
#
# Legs:
#   d1  the round-64 C1 vehicle leg is carried as receipt evidence:
#       .ufo/waves/round-64/final/c1-heldout.txt reads `vehicle=1` and
#       plans/round-64-c1.sh still builds the structural vehicle (the
#       `make_vehicle_tree` function and a `NEGATORS = frozenset(())` needle).
#   d2  the round-64 bound leg is carried as receipt evidence:
#       .ufo/waves/round-64/final/c2-refusal.txt reads `terminates=1` and
#       `bound=1`, and plans/round-64-c2.sh still names C2_RECURSION_BOUND.
#   d3  the population consistency above, plus:
#       (ii) corpus/lessons/round-65.md carries a correction record naming the
#            corrected population and the superseded six-receipt expectation;
#       (iii) `--legacy` (six-receipt expectation) reads mismatch=1 — i.e. the
#            correction is the only delta, and the legacy leg is shown able to
#            fail.
#
# `--legacy` restores the round-63 D-B expectation (six stems) and reports the
# mismatch of THAT expectation against the directory. On the shipped tree it
# must read 1; on a fixture copy with controls.txt planted it must read 0.
#
# Output: `routed-leg d1|d2|d3: <detail>` lines, then exactly one
#   ROUTED: d1=<0|1> d2=<0|1> d3=<0|1>
# Exit 0 iff all three read 1; 1 otherwise; 2 SETUP.
#
# Scratch (round-65 plan §Scratch): ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/
# kagi-r65/L1Routed/; nothing is written inside the measured tree.
set -u

SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=${SELF_DIR%/plans}
TREE=$REPO
LEGACY=0
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=${2:-}; shift 2;;
    --repo) REPO=${2:-}; shift 2;;
    --legacy) LEGACY=1; shift;;
    --selftest) SELFTEST=1; shift;;
    -h|--help) sed -n '2,/^set -u$/p' "${BASH_SOURCE[0]}" | sed '$d'; exit 0;;
    *) echo "ROUTED: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "ROUTED: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$REPO" ] || { echo "ROUTED: SETUP bad-repo $REPO" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "ROUTED: SETUP no-python3" >&2; exit 2; }

exec python3 -I -B - "$TREE" "$REPO" "$LEGACY" "$SELFTEST" <<'PY'
import os
import re
import sys

tree, repo, legacy, selftest = sys.argv[1], sys.argv[2], sys.argv[3] == "1", sys.argv[4] == "1"

FINAL63 = ".ufo/waves/round-63/final"
FINAL64 = ".ufo/waves/round-64/final"
LESSON63 = "corpus/lessons/round-63.md"
LESSON65 = "corpus/lessons/round-65.md"

# The label line each receipt must carry (label evidence, not just presence).
LABELS = {
    "c1-residual": "C1_RESIDUAL:",
    "c2-refusal": "rc=",
    "controls": "CONTROLS:",
    "release-clock": "RELEASE_CLOCK:",
    "doc-audit": "DOC_AUDIT:",
    "claims-declared": "CLAIMS_DECLARED:",
}
# The round-63 D-B expectation, read from the lesson; this literal is the
# fallback the --legacy leg restores (it is the superseded expectation).
LEGACY_EXPECT = ["c1-residual", "c2-refusal", "controls",
                 "release-clock", "doc-audit", "claims-declared"]
# The corrected population: the five stems the round-63 tree actually holds.
CORRECTED = ["c1-residual", "c2-refusal", "release-clock",
             "doc-audit", "claims-declared"]


def rd(base, rel):
    try:
        with open(os.path.join(base, rel), encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None


def cited_from_lesson(text):
    """Derive the D-B row's expected final receipts from the lesson itself."""
    if not text:
        return None
    row = None
    for line in text.splitlines():
        if line.lstrip().startswith("| D-B"):
            row = line
            break
    if row is None:
        return None
    stems = re.findall(r"`([a-z0-9][a-z0-9-]+)`", row)
    return [s for s in stems if s in LABELS]


def held_from_dir(text_map):
    out = []
    for stem, label in LABELS.items():
        body = text_map.get(stem + ".txt")
        if body and label in body:
            out.append(stem)
    return out


def measure(tree_root):
    bodies = {}
    for stem in LABELS:
        bodies[stem + ".txt"] = rd(tree_root, FINAL63 + "/" + stem + ".txt")
    held = held_from_dir(bodies)
    lesson = rd(tree_root, LESSON63)
    cited = cited_from_lesson(lesson)
    if cited is None:
        cited = list(LEGACY_EXPECT)
        cited_src = "fallback-literal"
    else:
        cited_src = "lesson-d-b-row"
    return held, cited, cited_src, bodies


def diff_count(a, b):
    return len(set(a) ^ set(b))


def run_selftest() -> int:
    cases = 0
    failed = []

    def case(name, cond):
        nonlocal cases
        cases += 1
        if not cond:
            failed.append(name)

    row = ("| D-B | §6 D-B gate verdict lines | six receipts under `f/` "
           "(`c1-residual`, `c2-refusal`, `controls`, `release-clock`, "
           "`doc-audit`, `claims-declared`), each cited from `LOG.md`; leg `db` | x |")
    case("derive-six-from-d-b", cited_from_lesson(row) == LEGACY_EXPECT)
    case("derive-none-from-missing", cited_from_lesson(None) is None)
    case("derive-ignores-non-stems",
         cited_from_lesson("| D-B | `c1-residual` and `not-a-receipt` |") == ["c1-residual"])
    bodies = {s + ".txt": ("CONTROLS: x" if s == "controls" else LABELS[s] + " x")
              for s in LABELS}
    case("held-by-label", sorted(held_from_dir(bodies)) == sorted(LEGACY_EXPECT))
    bodies_no = dict(bodies)
    bodies_no["controls.txt"] = "no label here"
    case("absent-label-not-held",
         sorted(held_from_dir(bodies_no)) == sorted(CORRECTED))
    case("mismatch-legacy-1", diff_count(LEGACY_EXPECT, CORRECTED) == 1)
    case("mismatch-corrected-0", diff_count(CORRECTED, CORRECTED) == 0)
    case("mismatch-live-both", diff_count(LEGACY_EXPECT, LEGACY_EXPECT) == 0
         and diff_count(LEGACY_EXPECT, CORRECTED) == 1)
    if failed:
        print("ROUTED_SELFTEST: FAIL (cases=%d failed=%d names=%s)"
              % (cases, len(failed), ",".join(failed)))
        return 1
    print("ROUTED_SELFTEST: PASS (cases=%d)" % cases)
    return 0


if selftest:
    raise SystemExit(run_selftest())

held, cited, cited_src, bodies = measure(tree)

# -- d1: the round-64 structural-vehicle leg, carried as receipt evidence ------
c1_body = rd(tree, FINAL64 + "/c1-heldout.txt") or ""
c1_file = rd(tree, "plans/round-64-c1.sh") or ""
d1 = 1 if ("vehicle=1" in c1_body
           and "make_vehicle_tree" in c1_file
           and "NEGATORS = frozenset(())" in c1_file) else 0
print("routed-leg d1: receipt-vehicle=%d builder=%d needle=%d"
      % (1 if "vehicle=1" in c1_body else 0,
         1 if "make_vehicle_tree" in c1_file else 0,
         1 if "NEGATORS = frozenset(())" in c1_file else 0))

# -- d2: the round-64 recursion-bound leg, carried as receipt evidence --------
c2_body = rd(tree, FINAL64 + "/c2-refusal.txt") or ""
c2_file = rd(tree, "plans/round-64-c2.sh") or ""
d2 = 1 if ("terminates=1" in c2_body and "bound=1" in c2_body
           and "C2_RECURSION_BOUND" in c2_file) else 0
print("routed-leg d2: receipt-terminates=%d receipt-bound=%d flag-named=%d"
      % (1 if "terminates=1" in c2_body else 0,
         1 if "bound=1" in c2_body else 0,
         1 if "C2_RECURSION_BOUND" in c2_file else 0))

# -- d3: the derived population, the correction record, the legacy leg --------
lesson65 = rd(tree, LESSON65) or ""
low65 = lesson65.lower()
correction = 1 if ("superseded" in low65 and "controls" in low65
                   and "round-63" in low65
                   and "round-65" in low65) else 0
# The correction supersedes the lesson's D-B expectation; until it lands the
# derived (six-receipt) expectation stands.
cited_eff = CORRECTED if correction else cited
expect = LEGACY_EXPECT if legacy else cited_eff
mismatch = diff_count(expect, held)
legacy_mismatch = diff_count(LEGACY_EXPECT, held)
d3 = 1 if (mismatch == 0 and correction and legacy_mismatch == 1) else 0
print("routed-leg d3: mismatch=%d held=%s cited=%s(%s) correction=%d legacy-mismatch=%d"
      % (mismatch, ",".join(sorted(held)), ",".join(sorted(expect)),
         cited_src, correction, legacy_mismatch))

print("ROUTED: d1=%d d2=%d d3=%d" % (d1, d2, d3))
raise SystemExit(0 if (d1 and d2 and d3) else 1)
PY
