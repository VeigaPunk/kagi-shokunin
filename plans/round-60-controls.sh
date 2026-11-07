#!/usr/bin/env bash
# plans/round-60-controls.sh -- pre-freeze control battery for round 60 (kagi).
#   usage: bash plans/round-60-controls.sh [REF_TREE]   (REF_TREE defaults to the lane tree)
#
# Declared by plans/round-60.md section "Pre-freeze controls" (frozen, commit cd631737):
# two no-work controls (both counters on the claim BASE a677c78e: C1 diagnostic value=7,
# C2 value=0), two positive reference readings (a tree carrying all seven I1..I7 fixes
# reads "0 guard=1"; a tree carrying the AppRole trial reads 5), and the forgery /
# fail-closed set C1-F1..C1-F8 and C2-F1..C2-F8. 20 controls total.
#
# Every control is one shell function that prints
#   CONTROL <id> expect=<x> observed=<y>
# and is scored by exact string equality of <x> and <y> (the only normalization is the
# declared "<5" class: any numeric reading below 5 normalizes to the literal "<5", per
# the plan's "reads < 5" expectations). The runner ends with
#   CONTROLS: match=N mismatch=M
# and exits 0 iff M=0, 1 otherwise, 2 SETUP. A control whose required instrument is not
# on disk yet prints observed=NORESULT, is counted neither matched nor mismatched, and
# is listed on a CONTROLS-NORESULT line printed just before the summary; if nothing
# could run at all the battery exits 2 (SETUP). The L1 re-runs the battery after the
# instruments land; the battery must read mismatch=0 before any candidate is measured.
#
# Instrument pins: one "INSTRUMENT <path> <sha256>" line per instrument file this
# battery measures (MISSING when the file is not on disk yet). The receipt (the battery
# stdout kept under .ufo/waves/round-60/build/R60ExecControls/) records these lines.
#
# Instrumentation under test (this battery owns none of it):
#   plans/round-60-c1-check.py          C1 checker  (--root TREE --repo LANE [--no-challenge])
#   plans/round-60-c1.sh                C1 driver   ([revision] | --tree DIR)
#   plans/round-60-c2.sh                C2 counter  ([revision] | --tree DIR)
#   corpus/openbao-approle-trial.sh     the trial   ([--work DIR] [--selftest]; KAGI_*_SHIM shims)
#   corpus/openbao-transit-trial.sh     gains --selftest (item I7)
# The shim environment variable name is derived at run time from the landed counter
# (fallback: the landed trial) instead of being assumed.
#
# Control map (id -> instrument needed):
#   K1-BASE  C1 diagnostic on a BASE copy = 7                        (c1-check.py)
#   K2-BASE  C2 on a BASE copy = 0 (trial absent at BASE)            (c2.sh)
#   K1-REF   synthetic fixed tree (all seven fixes) = "0 guard=1"    (c1-check.py + transit --selftest)
#   K2-REF   tree carrying the trial = 5                             (c2.sh + approle trial)
#   C1-F1..F5  break the substance of I1..I5 in a LAST superseding
#              statement that still looks satisfied; diagnostic = 1  (c1-check.py)
#   C1-F6    transit trial copy with the verdict mapping mutated:
#            --selftest exits non-zero with a named finding id     (transit --selftest)
#   C1-F7    a printer stub that always prints value=0 ... guard=1
#            fails the guard challenge leg (challenge copy reads
#            value+1, the stub reads 0)                            (c1-check.py)
#   C1-F8    the I1 correction block placed BEFORE the __DEAD__ line
#            it corrects does not resolve the item; diagnostic = 1 (c1-check.py)
#   C2-F1    trial wrapper dropping the SH5 shim -> vector broken; <5
#   C2-F2    a PATH with no bao reads SETUP rc2 with no HOLDS line  (approle trial)
#   C2-F3    trial wrapper refusing --selftest -> <5
#   C2-F4    single-run wrapper: the second empty-shim real run is
#            refused -> <5
#   C2-F5    wrapper printing HOLDS lines without a summary -> 0    (c2.sh)
#   C2-F6    SH1 wrapper that also flips T2 -> vector broken; <5
#   C2-F7    a bao binary whose sha256 is not the pinned OpenBao
#            2.7.2 (fake HOME) reads SETUP rc2                      (c2.sh + approle trial)
#   C2-F8    ambient BAO_*/VAULT_* exported by the caller do not
#            change the reading (reference tree still reads 5)      (c2.sh + approle trial)
#
# Every control works on copies under ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/
# kagi-r60/R60ExecControls/battery.$$ and removes them on exit; TMPDIR is pointed
# there too. No /tmp, no writes inside the measured tree, no git/jj mutation (the
# BASE tree is materialized read-only with git archive).
set -u -o pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2
REF=${1:-$REPO}
REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecControls/battery.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR

C1CHECK="$REPO/plans/round-60-c1-check.py"
C2="$REPO/plans/round-60-c2.sh"
APPROLE_REL=corpus/openbao-approle-trial.sh
TRANSIT_REL=corpus/openbao-transit-trial.sh
SELFTEST_RECEIPT=.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt
CONTROLS_RECEIPT=.ufo/waves/round-59/controls/controls-prefreeze.txt
C1LANDED=.ufo/waves/round-59/final/c1-landed.txt
W1RESULTS=.ufo/waves/round-59/w1-results.json

M=0; K=0; NR=0; NRLIST=""

report() { # ID EXPECT OBSERVED DETAIL
  if [ "$3" = NORESULT ]; then
    NR=$((NR + 1)); NRLIST="$NRLIST $1"
    printf 'CONTROL %s expect=%s observed=NORESULT :: %s\n' "$1" "$2" "$4"
    return 0
  fi
  local v=MISMATCH
  if [ "$2" = "$3" ]; then M=$((M + 1)); v=MATCH; else K=$((K + 1)); fi
  printf 'CONTROL %s expect=%s observed=%s %s :: %s\n' "$1" "$2" "$3" "$v" "$4"
}

norm_lt5() { # declared "<5" expectation class: numeric readings below 5 normalize
  case "${1:-}" in
    ''|*[!0-9]*) printf '%s' "${1:-none}" ;;
    *) if [ "$1" -lt 5 ]; then printf '<5'; else printf '%s' "$1"; fi ;;
  esac
}

copy_tree() { # SRC DST -- worktree copy, VCS internals excluded
  mkdir -p "$2" || return 1
  ( cd "$1" && tar --exclude=./.git --exclude=./.jj -cf - . ) | tar -xf - -C "$2"
}

base_tree() { # DST -- the claim BASE revision, materialized read-only
  mkdir -p "$1" || return 1
  git -C "$REPO" archive "$BASE" | tar -xf - -C "$1"
}

# --- instrument presence -----------------------------------------------------
have_c1check=0; [ -f "$C1CHECK" ] && have_c1check=1
have_c2=0;       [ -f "$C2" ] && have_c2=1
have_approle=0;  [ -f "$REF/$APPROLE_REL" ] && have_approle=1
have_tself=0
if [ -f "$REF/$TRANSIT_REL" ] && grep -q -- '--selftest' "$REF/$TRANSIT_REL" 2>/dev/null; then
  have_tself=1
fi
SHIMVAR=""
[ "$have_c2" = 1 ] && SHIMVAR=$(grep -oE '[A-Z][A-Z0-9_]+_SHIM' "$C2" 2>/dev/null | sort -u | head -1)
if [ -z "$SHIMVAR" ] && [ "$have_approle" = 1 ]; then
  SHIMVAR=$(grep -oE '[A-Z][A-Z0-9_]+_SHIM' "$REF/$APPROLE_REL" 2>/dev/null | sort -u | head -1)
fi

echo "# round-60 pre-freeze control battery (plans/round-60-controls.sh)"
echo "# base=$BASE ref=$REF"
echo "# scratch=$SCR"
echo "# derived-shim-env=${SHIMVAR:-none}"

echo "# instrument pins (the bytes this battery measured)"
PINLIST=""
for f in plans/round-60-c1-check.py plans/round-60-c1.sh plans/round-60-c2.sh \
         "$APPROLE_REL" "$TRANSIT_REL"; do
  if [ -f "$REPO/$f" ]; then
    h=$(sha256sum < "$REPO/$f" | cut -d' ' -f1)
    printf 'INSTRUMENT %s %s\n' "$f" "$h"
  else
    h=MISSING
    printf 'INSTRUMENT %s MISSING\n' "$f"
  fi
  PINLIST="$PINLIST $f=$h"
done

# --- C1 harness --------------------------------------------------------------
c1cap() { # TREE diag|full -> "VALUE GUARD" (empty when the line is unparsable)
  local t=$1 mode=$2 out v g rc
  if [ "$mode" = diag ]; then
    out=$(timeout 300 python3 -I -B "$C1CHECK" --root "$t" --repo "$REPO" --no-challenge 2>/dev/null)
  else
    out=$(timeout 600 python3 -I -B "$C1CHECK" --root "$t" --repo "$REPO" 2>/dev/null)
  fi
  rc=$?
  if [ "$rc" = 124 ]; then printf 'timeout timeout'; return 0; fi
  v=$(printf '%s\n' "$out" | sed -n 's/^C1_ROUTED: value=\([^ ]*\).*/\1/p' | tail -1)
  g=$(printf '%s\n' "$out" | sed -n 's/.*[[:space:]]guard=\([01]\).*/\1/p' | tail -1)
  printf '%s %s' "${v:-}" "${g:-}"
}

# --- C2 harness --------------------------------------------------------------
c2cap() { # TREE -> value | SETUP/rc<N> | timeout | none
  local out rc line
  out=$(timeout 900 bash "$C2" --tree "$1" 2>/dev/null); rc=$?
  if [ "$rc" = 124 ]; then printf 'timeout'; return 0; fi
  line=$(printf '%s\n' "$out" | grep -E '^C2_APPROLE_TRIAL:' | tail -1)
  case "$line" in
    *SETUP*) printf 'SETUP/rc%s' "$rc" ;;
    *value=*) printf '%s' "$(sed -n 's/.*[[:space:]:]value=\([0-9A-Za-z]*\).*/\1/p' <<<"$line")" ;;
    *) printf 'none' ;;
  esac
}

gen_wrapper() { # NAME BODY -- wrapper at $SCR/NAME/corpus/openbao-approle-trial.sh
  local d="$SCR/$1/corpus"
  mkdir -p "$d" || return 1
  { printf '#!/usr/bin/env bash\n# battery wrapper (control %s); delegates to the real trial\nset -u\n' "$1"
    printf 'REAL=%q\nCNT=%q\n' "$REF/$APPROLE_REL" "$SCR/$1/count"
    printf 'out=$(bash "$REAL" "$@" 2>&1); rc=$?\n'
    printf '%s\n' "$2"
  } > "$d/openbao-approle-trial.sh" || return 1
}

# --- synthetic fixed tree (all seven I1..I7 fixes; numbers derived, not assumed) --
build_fixed_tree() { # NAME [misplace-i1] [bad-doc-audit] -> $SCR/NAME
  local T="$SCR/$1" misplace=0 badaudit=0 R D CASES NCTRL MREV LOGF
  case "${2:-}" in misplace-i1) misplace=1 ;; esac
  case "${3:-}" in bad-doc-audit) badaudit=1 ;; esac
  base_tree "$T" || return 1

  RD=$(python3 - "$T/$W1RESULTS" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
rs = d if isinstance(d, list) else [v for v in d.values() if isinstance(v, list)][0]
print(len(rs), sum(1 for r in rs if not str(r.get("output") or "").strip()))
PY
  ) || return 1
  R=${RD%% *}; D=${RD##* }
  CASES=$(sed -n 's/.*C1_CHECK_SELFTEST: PASS (\([0-9][0-9]*\) cases).*/\1/p' "$T/$SELFTEST_RECEIPT" 2>/dev/null | tail -1)
  NCTRL=$(grep -cE '^CONTROL ' "$T/$CONTROLS_RECEIPT" 2>/dev/null)
  MREV=$(sed -n 's/.*measured=revision \([0-9a-f]\{40\}\).*/\1/p' "$T/$C1LANDED" 2>/dev/null | tail -1)
  [ -n "$R" ] && [ -n "$D" ] && [ -n "$CASES" ] && [ -n "$NCTRL" ] && [ -n "$MREV" ] || return 1

  # I1 (LOG.md): block headed by the frozen heading, after the last __DEAD__ line.
  # The line carries both the item-facing results=/dead= fields and the guard-facing
  # dead seats=<n> field the challenge flips 0 -> 1.
  LOGF="$T/LOG.md"
  python3 - "$LOGF" "$R" "$D" "$misplace" <<'PY'
import sys
path, R, D, misplace = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "1"
block = [
    "## Round 59 \u2014 correction (wave census, names w1-results.json)\n",
    "- supersedes the wave line dead-seat placeholder: "
    ".ufo/waves/round-59/w1-results.json holds "
    f"results={R} dead={D} dead seats={D}; {R} results, {D} with an empty or absent "
    "final output.\n",
]
text = open(path, encoding="utf-8", errors="surrogateescape").read()
lines = text.splitlines(keepends=True)
idx = max(i for i, l in enumerate(lines) if "__DEAD__" in l)
if misplace:
    lines[idx:idx] = block          # BEFORE the line it corrects: must NOT resolve
else:
    lines[idx + 1:] = block + lines[idx + 1:]  # appended after it (last occurrence wins)
open(path, "w", encoding="utf-8", errors="surrogateescape").writelines(lines)
PY
  [ $? = 0 ] || return 1

  # I2 (round-59 lesson): after the line where R31 first appears.
  printf -- '- Correction (supersedes R31): the committed round-59 checker selftest receipt .ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt reads C1_CHECK_SELFTEST: PASS (%s cases); the superseded R31 sentence understated the count; %s cases is the operative number.\n' "$CASES" "$CASES" >> "$T/corpus/lessons/round-59.md"

  # I3 (round-60 lesson): unique disposition ids, plus the duplicate-id sentence.
  cat > "$T/corpus/lessons/round-60.md" <<EOF
# Round 60 — lesson (kagi)

- The round-59 routed-dispositions table repeated the ids R20, R21 and R22 — each duplicate id named two findings; the superseded round-59 table is corrected here with unique ids.

## Routed dispositions

| id | finding | disposition |
|---|---|---|
| R20 | duplicate routed ids in the round-59 table | superseded by this table (unique ids only) |
| R21 | round-59 gate-evidence pointers that were never written | pinned under .ufo/waves/round-60/final/ |
| R22 | round-59 lesson census drift | superseded counts corrected append-only |
| R23 | routed finding slot | open |
| R24 | routed finding slot | open |
| R25 | routed finding slot | open |
EOF
  [ $? = 0 ] || return 1

  # I4/I5/I6 (SCORECARD corrections, append-only, after the superseded lines).
  cat >> "$T/SCORECARD.md" <<EOF
- Correction (supersedes SCORECARD.md:1971): the round-59 pre-freeze controls count stated there is wrong; the receipt .ufo/waves/round-59/controls/controls-prefreeze.txt holds $NCTRL controls.
- Correction (supersedes the round-59 gate-evidence pointer): the round-59 release-clock, DOC_AUDIT and SCOPE gate receipts were never written — the round-60 gate evidence is .ufo/waves/round-60/final/release-clock.txt, .ufo/waves/round-60/final/doc-audit.txt and .ufo/waves/round-60/final/scope.txt
- Correction (supersedes the round-59 measured-commit citation): the receipt .ufo/waves/round-59/final/c1-landed.txt reads measured=revision $MREV.
EOF
  [ $? = 0 ] || return 1

  # I5 receipt files under .ufo/waves/round-60/final/ (synthetic fixture bytes).
  mkdir -p "$T/.ufo/waves/round-60/final" || return 1
  { echo "# synthetic fixed-tree fixture (battery-built, not lane evidence)"
    echo "RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)"
  } > "$T/.ufo/waves/round-60/final/release-clock.txt"
  { echo "# synthetic fixed-tree fixture (battery-built, not lane evidence)"
    if [ "$badaudit" = 1 ]; then
      echo "DOC_AUDIT- CLEAN (entries=40 row_linked=37 by_hand=3)"
    else
      echo "DOC_AUDIT: CLEAN (entries=40 row_linked=37 by_hand=3)"
    fi
  } > "$T/.ufo/waves/round-60/final/doc-audit.txt"
  { echo "# synthetic fixed-tree fixture (battery-built, not lane evidence)"
    echo "ADJACENCY_SCOPE: DEFECT (stale_basis=0 breadth_drift=5 breadth_unverified=1)"
  } > "$T/.ufo/waves/round-60/final/scope.txt"

  # I7: the SKILL.md registry row re-registered with --selftest, and the landed
  # transit trial (carrying --selftest) overlaid from the REF tree.
  python3 - "$T/SKILL.md" <<'PY'
import sys
path = sys.argv[1]
lines = open(path, encoding="utf-8", errors="surrogateescape").read().splitlines(True)
out, done = [], 0
for l in lines:
    if not done and l.lstrip().startswith("|") and "openbao-transit-trial.sh" in l \
            and "none \u2014 its own five shims" in l:
        cells = l.split("|")
        for i, c in enumerate(cells):
            if "none \u2014 its own five shims" in c:
                cells[i] = " `bash corpus/openbao-transit-trial.sh --selftest` (TRANSIT_SELFTEST over isolated fixtures) "
                done = 1
        l = "|".join(cells)
    out.append(l)
open(path, "w", encoding="utf-8", errors="surrogateescape").writelines(out)
raise SystemExit(0 if done else 3)
PY
  [ $? = 0 ] || return 1
  cp "$REF/$TRANSIT_REL" "$T/$TRANSIT_REL" || return 1
  return 0
}

fixed_tree_ready() { # the fixed-tree controls need the checker AND the landed transit selftest
  [ "$have_c1check" = 1 ] && [ "$have_tself" = 1 ]
}

# =========================== no-work controls ================================
ctrl_k1_base() {
  if [ "$have_c1check" != 1 ]; then
    report K1-BASE 7 NORESULT "plans/round-60-c1-check.py is not on disk yet"
    return 0
  fi
  base_tree "$SCR/base" || { echo "CONTROLS: SETUP base tree"; exit 2; }
  report K1-BASE 7 "$(c1cap "$SCR/base" diag | cut -d' ' -f1)" \
    "C1 diagnostic (--no-challenge) on the claim BASE: all seven routed items unresolved (K2 kill rule: any lower reading voids the claim)"
}

ctrl_k2_base() {
  if [ "$have_c2" != 1 ]; then
    report K2-BASE 0 NORESULT "plans/round-60-c2.sh is not on disk yet"
    return 0
  fi
  [ -d "$SCR/base" ] || base_tree "$SCR/base" || { echo "CONTROLS: SETUP base tree"; exit 2; }
  report K2-BASE 0 "$(c2cap "$SCR/base")" \
    "C2 on the claim BASE: the trial does not exist at BASE (absent line, no server work)"
}

# =========================== positive references =============================
ctrl_k1_ref() {
  if ! fixed_tree_ready; then
    report K1-REF "0 guard=1" NORESULT \
      "needs plans/round-60-c1-check.py and the landed transit --selftest (I7) to build a tree where exactly I1..I7 resolve"
    return 0
  fi
  build_fixed_tree k1ref || { report K1-REF "0 guard=1" none "fixed-tree build failed"; return 0; }
  out=$(c1cap "$SCR/k1ref" full)
  V=${out%% *}; G=${out##* }
  if [ -z "$V" ]; then obs=none; else obs="$V guard=${G:-?}"; fi
  report K1-REF "0 guard=1" "$obs" \
    "synthetic fixed tree carrying all seven fixes: value=0 and the guard challenge fires"
}

ctrl_k2_ref() {
  if [ "$have_c2" != 1 ] || [ "$have_approle" != 1 ]; then
    report K2-REF 5 NORESULT "needs plans/round-60-c2.sh and corpus/openbao-approle-trial.sh on disk"
    return 0
  fi
  copy_tree "$REF" "$SCR/k2ref" || { report K2-REF 5 none "ref tree copy failed"; return 0; }
  report K2-REF 5 "$(c2cap "$SCR/k2ref")" \
    "tree carrying the trial: two independent HOLDS 5/5 runs, five shim vectors, selftest leg"
}

# =========================== C1 forgeries ====================================
ctrl_c1_f1() { # I1 substance broken in a LAST superseding statement
  if ! fixed_tree_ready; then
    report C1-F1 1 NORESULT "needs the checker and the landed transit --selftest (fixed tree)"; return 0
  fi
  build_fixed_tree c1f1 || { report C1-F1 1 none "fixed-tree build failed"; return 0; }
  printf -- '- Correction (supersedes the wave-census correction above; revised): .ufo/waves/round-59/w1-results.json holds results=15 dead=1 dead seats=1; 15 results, 1 with an empty or absent final output.\n' >> "$SCR/c1f1/LOG.md"
  report C1-F1 1 "$(c1cap "$SCR/c1f1" diag | cut -d' ' -f1)" \
    "I1 substance broken in the last statement (satisfied-looking census with wrong numbers); diagnostic leg"
}

ctrl_c1_f2() { # I2 substance broken in a LAST superseding statement
  if ! fixed_tree_ready; then
    report C1-F2 1 NORESULT "needs the checker and the landed transit --selftest (fixed tree)"; return 0
  fi
  build_fixed_tree c1f2 || { report C1-F2 1 none "fixed-tree build failed"; return 0; }
  printf -- '- Correction (supersedes R31; revised): the receipt .ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt reads C1_CHECK_SELFTEST: PASS (32 cases); 32 cases.\n' >> "$SCR/c1f2/corpus/lessons/round-59.md"
  report C1-F2 1 "$(c1cap "$SCR/c1f2" diag | cut -d' ' -f1)" \
    "I2 case count wrong in the last superseding statement; diagnostic leg"
}

ctrl_c1_f3() { # I3 uniqueness broken: a duplicated disposition id in the id column
  if ! fixed_tree_ready; then
    report C1-F3 1 NORESULT "needs the checker and the landed transit --selftest (fixed tree)"; return 0
  fi
  build_fixed_tree c1f3 || { report C1-F3 1 none "fixed-tree build failed"; return 0; }
  printf '| R20 | duplicate id probe reusing a disposition id | probe |\n' >> "$SCR/c1f3/corpus/lessons/round-60.md"
  report C1-F3 1 "$(c1cap "$SCR/c1f3" diag | cut -d' ' -f1)" \
    "I3 uniqueness broken (id R20 twice in the id column, table otherwise intact); diagnostic leg"
}

ctrl_c1_f4() { # I4 substance broken in a LAST superseding statement
  if ! fixed_tree_ready; then
    report C1-F4 1 NORESULT "needs the checker and the landed transit --selftest (fixed tree)"; return 0
  fi
  build_fixed_tree c1f4 || { report C1-F4 1 none "fixed-tree build failed"; return 0; }
  printf -- '- Correction (supersedes SCORECARD.md:1971; revised): the receipt .ufo/waves/round-59/controls/controls-prefreeze.txt holds 21 controls.\n' >> "$SCR/c1f4/SCORECARD.md"
  report C1-F4 1 "$(c1cap "$SCR/c1f4" diag | cut -d' ' -f1)" \
    "I4 control count wrong in the last superseding statement; diagnostic leg"
}

ctrl_c1_f5() { # I5 receipt shape broken: satisfied-looking file, wrong last line
  if ! fixed_tree_ready; then
    report C1-F5 1 NORESULT "needs the checker and the landed transit --selftest (fixed tree)"; return 0
  fi
  build_fixed_tree c1f5 "" bad-doc-audit || { report C1-F5 1 none "fixed-tree build failed"; return 0; }
  report C1-F5 1 "$(c1cap "$SCR/c1f5" diag | cut -d' ' -f1)" \
    "I5 receipt shape broken (doc-audit receipt last line does not begin with the required token); diagnostic leg"
}

ctrl_c1_f6() { # transit selftest with a mutated verdict mapping must fail loudly
  if [ "$have_tself" != 1 ]; then
    report C1-F6 FAIL-with-id NORESULT "the transit --selftest (I7) has not landed in $TRANSIT_REL"; return 0
  fi
  mkdir -p "$SCR/c1f6" || return 0
  mout=$(python3 - "$REF/$TRANSIT_REL" "$SCR/c1f6/trial.sh" 2>&1 <<'PY'
import re, sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8", errors="surrogateescape").read()
# The selftest's verdict mapping: the ST-BASELINE fixture asserts the honest
# stub run's per-test verdicts. Flipping the T1 expected verdict makes the
# honest fixtures fail their mapped expectation, which must surface as a
# named FINDING and a non-zero exit.
target = '_st_want BASELINE "TRIAL T1 HOLDS"'
i = text.find(target)
if i >= 0:
    text = text[:i] + '_st_want BASELINE "TRIAL T1 BROKEN"' + text[i + len(target):]
    print("mutated the selftest verdict mapping: ST-BASELINE T1 HOLDS -> BROKEN")
else:
    m = re.search(r'_st_want\s+(\S+)\s+("[^"]*HOLDS[^"]*")', text)
    if not m:
        print("no _st_want HOLDS verdict-mapping assertion found to mutate")
        raise SystemExit(3)
    broken = m.group(2).replace("HOLDS", "BROKEN", 1)
    text = text[:m.start(2)] + broken + text[m.end(2):]
    print(f"mutated the selftest verdict mapping: {m.group(1)} {m.group(2)} -> {broken}")
open(dst, "w", encoding="utf-8", errors="surrogateescape").write(text)
PY
  )
  mrc=$?
  if [ "$mrc" != 0 ]; then
    report C1-F6 FAIL-with-id "mutation-failed(rc$mrc)" "$mout"; return 0
  fi
  out=$(timeout 120 bash "$SCR/c1f6/trial.sh" --selftest 2>&1); rc=$?
  fid=$(printf '%s\n' "$out" | grep -oE 'FINDING[[:space:]]+[A-Za-z0-9._-]+|finding[=:][[:space:]]?[A-Za-z0-9._-]+' | head -1)
  if [ "$rc" -ne 0 ] && printf '%s\n' "$out" | grep -q FAIL && [ -n "$fid" ]; then
    report C1-F6 FAIL-with-id FAIL-with-id "mutated verdict mapping: selftest rc=$rc, finding id: $fid"
  else
    report C1-F6 FAIL-with-id "rc$rc$( [ -n "$fid" ] && printf '/%s' "$fid" || printf '/no-finding-id' )" \
      "mutated verdict mapping must exit non-zero printing FAIL with a named finding id"
  fi
}

ctrl_c1_f7() { # printer stub (always value=0 ... guard=1) fails the challenge leg
  # Challenge copy delta: the I1 correction line's dead= digit 0 -> 1 (the token
  # the checker's own guard challenge mutates); the real checker must read
  # value+1 there while the constant-0 stub cannot.
  if ! fixed_tree_ready; then
    report C1-F7 stub-fails-challenge NORESULT "needs the checker and the landed transit --selftest (fixed tree)"; return 0
  fi
  build_fixed_tree c1f7 || { report C1-F7 stub-fails-challenge none "fixed-tree build failed"; return 0; }
  read -r VA _ <<<"$(c1cap "$SCR/c1f7" diag)"
  cp -a "$SCR/c1f7" "$SCR/c1f7c" || { report C1-F7 stub-fails-challenge none "challenge copy failed"; return 0; }
  python3 - "$SCR/c1f7c/LOG.md" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8", errors="surrogateescape").read()
# The checker's I1 regex reads the FIRST dead=... digit after results= (the
# same token the frozen guard's challenge mutates), so the challenge copy
# flips exactly that digit 0 -> 1.
i = text.find("dead=0")
if i < 0:
    raise SystemExit(3)
open(path, "w", encoding="utf-8", errors="surrogateescape").write(
    text[:i] + "dead=1" + text[i + len("dead=0"):])
PY
  rc7=$?
  if [ "$rc7" != 0 ]; then report C1-F7 stub-fails-challenge none "challenge digit flip failed"; return 0; fi
  read -r VB _ <<<"$(c1cap "$SCR/c1f7c" diag)"
  printf '%s\n' 'print("C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1")' > "$SCR/stub.py"
  VC=$(python3 -I -B "$SCR/stub.py" --root "$SCR/c1f7c" --repo "$REPO" --no-challenge 2>/dev/null | sed -n 's/^C1_ROUTED: value=\([^ ]*\).*/\1/p' | tail -1)
  if [ "$VA" = 0 ] && [ "$VB" = 1 ] && [ "$VC" = 0 ]; then
    report C1-F7 stub-fails-challenge stub-fails-challenge \
      "fixed tree value=$VA; challenge copy (I1 dead= 0->1) reads value=$VB; the constant-0/constant-guard-1 stub reads value=$VC and cannot satisfy the challenge"
  else
    report C1-F7 stub-fails-challenge "value=$VA broken=$VB stub=${VC:-none}" \
      "expected fixed=0, challenge=+1, stub=0"
  fi
}

ctrl_c1_f8() { # correction placed BEFORE the line it corrects must not resolve
  if ! fixed_tree_ready; then
    report C1-F8 1 NORESULT "needs the checker and the landed transit --selftest (fixed tree)"; return 0
  fi
  build_fixed_tree c1f8 misplace-i1 || { report C1-F8 1 none "fixed-tree build failed"; return 0; }
  report C1-F8 1 "$(c1cap "$SCR/c1f8" diag | cut -d' ' -f1)" \
    "the I1 correction block sits before the __DEAD__ line it corrects: the after-the-superseded-line rule must bite; diagnostic leg"
}

# =========================== C2 forgeries ====================================
ctrl_c2_f1() { # the T5 shim removed: SH5 leg reads the baseline vector
  if [ "$have_c2" != 1 ] || [ "$have_approle" != 1 ] || [ -z "$SHIMVAR" ]; then
    report C2-F1 "<5" NORESULT "needs the counter, the trial, and a derivable shim env var"; return 0
  fi
  gen_wrapper c2f1 'if [ "${'"$SHIMVAR"':-}" = SH5 ]; then exec env -u "'"$SHIMVAR"'" bash "$REAL" "$@"; fi; printf '"'"'%s\n'"'"' "$out"; exit "$rc"' || { report C2-F1 "<5" none "wrapper gen failed"; return 0; }
  report C2-F1 "<5" "$(norm_lt5 "$(c2cap "$SCR/c2f1")")" \
    "the SH5 shim never reaches the trial, so the SH5 vector cannot flip exactly T5"
}

ctrl_c2_f2() { # a PATH with no bao: SETUP rc2, no HOLDS line (K1)
  if [ "$have_approle" != 1 ]; then
    report C2-F2 SETUP/rc2 NORESULT "corpus/openbao-approle-trial.sh is not on disk yet"; return 0
  fi
  out=$(timeout 300 env -i PATH=/usr/bin:/bin HOME="$HOME" bash "$REF/$APPROLE_REL" --work "$SCR/c2f2-work" 2>&1); rc=$?
  if [ "$rc" = 124 ]; then report C2-F2 SETUP/rc2 "timeout" "trial did not terminate within 300s on a no-bao PATH (K1 wants an immediate SETUP rc2)"; return 0; fi
  if [ "$rc" = 2 ] && printf '%s\n' "$out" | grep -qE ': SETUP' && ! printf '%s\n' "$out" | grep -q HOLDS; then
    report C2-F2 SETUP/rc2 SETUP/rc2 "no-bao PATH: $(printf '%s\n' "$out" | grep -E ': SETUP' | head -1)"
  else
    report C2-F2 SETUP/rc2 "rc$rc$(printf '%s\n' "$out" | grep -qE ': SETUP' || printf '/no-setup')$(printf '%s\n' "$out" | grep -q HOLDS && printf '/has-HOLDS')" \
      "a PATH with no bao must read the prefixed SETUP line, print no HOLDS, and exit 2 (K1)"
  fi
}

ctrl_c2_f3() { # --selftest removed: the counter's selftest conjunct refuses
  if [ "$have_c2" != 1 ] || [ "$have_approle" != 1 ]; then
    report C2-F3 "<5" NORESULT "needs the counter and the trial on disk"; return 0
  fi
  gen_wrapper c2f3 'for a in "$@"; do if [ "$a" = "--selftest" ]; then printf '"'"'openbao-approle-trial.sh: unsupported flag --selftest (removed by control C2-F3)\n'"'"' >&2; exit 2; fi; done; printf '"'"'%s\n'"'"' "$out"; exit "$rc"' || { report C2-F3 "<5" none "wrapper gen failed"; return 0; }
  report C2-F3 "<5" "$(norm_lt5 "$(c2cap "$SCR/c2f3")")" \
    "a trial whose --selftest mode is gone cannot satisfy the selftest conjunct (N >= 8)"
}

ctrl_c2_f4() { # single-run trial: the second independent real run is refused
  if [ "$have_c2" != 1 ] || [ "$have_approle" != 1 ] || [ -z "$SHIMVAR" ]; then
    report C2-F4 "<5" NORESULT "needs the counter, the trial, and a derivable shim env var"; return 0
  fi
  gen_wrapper c2f4 'if [ -z "${'"$SHIMVAR"':-}" ]; then case "$*" in *--selftest*) : ;; *) n=$(cat "$CNT" 2>/dev/null || echo 0); n=$((n+1)); printf '"'"'%s\n'"'"' "$n" >"$CNT"; if [ "$n" -gt 1 ]; then printf '"'"'TRIAL ERROR second real run refused\n'"'"'; exit 2; fi;; esac; fi; printf '"'"'%s\n'"'"' "$out"; exit "$rc"' || { report C2-F4 "<5" none "wrapper gen failed"; return 0; }
  report C2-F4 "<5" "$(norm_lt5 "$(c2cap "$SCR/c2f4")")" \
    "only one empty-shim real run is allowed: the two-independent-runs conjunct refuses"
}

ctrl_c2_f5() { # HOLDS lines without a summary read 0
  if [ "$have_c2" != 1 ]; then
    report C2-F5 0 NORESULT "plans/round-60-c2.sh is not on disk yet"; return 0
  fi
  gen_wrapper c2f5 'printf '"'"'TRIAL T1 HOLDS ok\nTRIAL T2 HOLDS ok\nTRIAL T3 HOLDS ok\nTRIAL T4 HOLDS ok\nTRIAL T5 HOLDS ok\n'"'"'; exit 0' || { report C2-F5 0 none "wrapper gen failed"; return 0; }
  report C2-F5 0 "$(c2cap "$SCR/c2f5")" \
    "a trial that prints HOLDS lines but never the required summary line cannot score"
}

ctrl_c2_f6() { # SH1 flipping two tests breaks the exactly-one vector
  if [ "$have_c2" != 1 ] || [ "$have_approle" != 1 ] || [ -z "$SHIMVAR" ]; then
    report C2-F6 "<5" NORESULT "needs the counter, the trial, and a derivable shim env var"; return 0
  fi
  gen_wrapper c2f6 'if [ "${'"$SHIMVAR"':-}" = SH1 ]; then out=$(printf '"'"'%s\n'"'"' "$out" | sed '"'"'s/^TRIAL T2 HOLDS /TRIAL T2 BROKEN cross-flip /'"'"'); fi; printf '"'"'%s\n'"'"' "$out"; exit "$rc"' || { report C2-F6 "<5" none "wrapper gen failed"; return 0; }
  report C2-F6 "<5" "$(norm_lt5 "$(c2cap "$SCR/c2f6")")" \
    "SH1 must flip exactly its designated test: a second flip breaks the vector"
}

ctrl_c2_f7() { # a bao binary with a foreign sha256 reads SETUP (fake HOME pin)
  if [ "$have_c2" != 1 ] || [ "$have_approle" != 1 ]; then
    report C2-F7 SETUP/rc2 NORESULT "needs the counter and the trial on disk"; return 0
  fi
  copy_tree "$REF" "$SCR/c2f7tree" || { report C2-F7 SETUP/rc2 none "tree copy failed"; return 0; }
  mkdir -p "$SCR/fakehome/.local/bin" || return 0
  cp /bin/true "$SCR/fakehome/.local/bin/bao" && chmod +x "$SCR/fakehome/.local/bin/bao" || return 0
  obs=$(HOME="$SCR/fakehome" c2cap "$SCR/c2f7tree")
  report C2-F7 SETUP/rc2 "$obs" \
    "a bao whose sha256 is not the pinned OpenBao 2.7.2 (\$HOME/.local/bin/bao replaced by a foreign binary) must read SETUP"
}

ctrl_c2_f8() { # ambient BAO_*/VAULT_* cannot change a reading
  if [ "$have_c2" != 1 ] || [ "$have_approle" != 1 ]; then
    report C2-F8 5 NORESULT "needs the counter and the trial on disk (reference reading)"; return 0
  fi
  copy_tree "$REF" "$SCR/c2f8tree" || { report C2-F8 5 none "tree copy failed"; return 0; }
  obs=$(BAO_ADDR=http://127.0.0.1:9 BAO_TOKEN=ambient BAO_ACC=ambient \
        VAULT_ADDR=http://127.0.0.1:9 VAULT_TOKEN=ambient VAULT_ACC=ambient \
        c2cap "$SCR/c2f8tree")
  report C2-F8 5 "$obs" \
    "ambient BAO_*/VAULT_* exported by the caller do not change the reference reading"
}

# ============================== run the battery ==============================
ctrl_k1_base
ctrl_k2_base
ctrl_k1_ref
ctrl_k2_ref
ctrl_c1_f1
ctrl_c1_f2
ctrl_c1_f3
ctrl_c1_f4
ctrl_c1_f5
ctrl_c1_f6
ctrl_c1_f7
ctrl_c1_f8
ctrl_c2_f1
ctrl_c2_f2
ctrl_c2_f3
ctrl_c2_f4
ctrl_c2_f5
ctrl_c2_f6
ctrl_c2_f7
ctrl_c2_f8

for entry in $PINLIST; do
  f=${entry%%=*}; h=${entry#*=}
  [ "$h" = MISSING ] && continue
  now=$(sha256sum < "$REPO/$f" 2>/dev/null | cut -d' ' -f1)
  if [ -n "$now" ] && [ "$now" != "$h" ]; then
    printf 'INSTRUMENT-DRIFT %s pinned=%s now=%s (the battery re-runs against the landed bytes)\n' "$f" "$h" "$now"
  fi
done
if [ "$NR" -gt 0 ]; then
  printf 'CONTROLS-NORESULT: count=%d%s\n' "$NR" "$NRLIST"
fi
if [ "$K" -eq 0 ] && [ "$M" -eq 0 ] && [ "$NR" -gt 0 ]; then
  echo "CONTROLS-SETUP: no control could run (instruments missing; the L1 re-runs the battery after they land)"
fi
printf 'CONTROLS: match=%d mismatch=%d\n' "$M" "$K"
if [ "$K" -gt 0 ]; then exit 1; fi
if [ "$M" -eq 0 ] && [ "$NR" -gt 0 ]; then
  exit 2
fi
exit 0
