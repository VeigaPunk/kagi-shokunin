#!/usr/bin/env bash
# plans/round-63-c2.sh — C2_REFUSAL: the five named surviving mutants must be refused.
#
# Round 63 claim C2 (operability), plans/round-63.md §C2 as amended by A2 (population 5)
# and A3 (leg mechanics, scratch root). Not a claim of its own: this counter is the
# verdict for the C2 predicate.
#
# Legs (POP = 5; L5/S3 is vacuous at BASE and dropped by A2):
#   l1  the tree's plans/round-62-c1.sh with its stub composition replaced by `stub=1`
#       must make its --selftest exit non-zero with a named FINDING or `failed=` line
#   l2  the same counter with `SL_OK=1` appended to stub_leg must do the same
#   l3  the tree's plans/round-63-controls.sh control `C2-F6` must read `mismatch`
#   l4  the same battery's control `C1-F8` must read `mismatch`
#   l6  the tree's plans/round-61-c1-check.py with the I6 superseded-stamp conjunct
#       dropped must make its --selftest exit non-zero printing `C1_CHECK_SELFTEST: FAIL`
#
# Guard (A3): (a) the tree's C1 counter --selftest exits 0; (b) this counter's own
#   --selftest exits 0; (c) the tree's plans/round-62-c2.sh on the real trial still
#   reads value=5 shims=5 vectors=ok/5; (d) the tree's plans/round-62-controls.sh
#   --selftest exits 0.
#
# Usage: bash plans/round-63-c2.sh [revision | --tree DIR] [--repo DIR]
#        bash plans/round-63-c2.sh --selftest
#   default tree = this repo's working tree; a revision is exported with git archive.
# Output: C2_REFUSAL: killed=K population=5 guard=G (l1=… l2=… l3=… l4=… l6=… selftest=… real=…)
# Exit 0 iff guard=1 and killed=5; 1 otherwise; 2 SETUP.
set -u -o pipefail

SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
REPO=${SELF_DIR%/plans}
TREE=$REPO
MODE=verdict
REV=""
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) [ $# -ge 2 ] || { echo "C2_REFUSAL: SETUP --tree needs a directory"; exit 2; }
            TREE=$2; shift 2 ;;
    --repo) [ $# -ge 2 ] || { echo "C2_REFUSAL: SETUP --repo needs a directory"; exit 2; }
            REPO=$2; shift 2 ;;
    --selftest) MODE=selftest; shift ;;
    -h|--help) sed -n '2,32p' "${BASH_SOURCE[0]}"; exit 0 ;;
    --*) echo "C2_REFUSAL: SETUP unknown option $1"; exit 2 ;;
    *) [ -z "$REV" ] || { echo "C2_REFUSAL: SETUP unexpected argument $1"; exit 2; }
       REV=$1; shift ;;
  esac
done

SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ExecC2Counter
mkdir -p -- "$SCRROOT" || { echo "C2_REFUSAL: SETUP no-scratch $SCRROOT"; exit 2; }
WORK=$SCRROOT/run-$(date +%Y%m%dT%H%M%SZ)-$$
mkdir -p -- "$WORK" || { echo "C2_REFUSAL: SETUP no-work $WORK"; exit 2; }
trap 'rm -rf -- "$WORK"' EXIT
export TMPDIR=$WORK
umask 077

setup_die() { printf 'C2_REFUSAL: SETUP %s\n' "$1"; exit 2; }

# ------------------------------------------------------------------ helpers -----
verdict_field() { # FILE FIELD -> value or empty
  [ -f "$1" ] || return 0
  awk 'index($0, "C2_REFUSAL:") == 1' "$1" | tr ' ' '\n' \
    | grep -xE "$2=[^ ]*" | sed -n '1p' | cut -d= -f2-
}

leg_fires() { # RC OUTFILE -> 0 iff the leg fired (non-zero rc AND a finding line)
  local rc=$1 out=$2
  [ "$rc" -ne 0 ] || return 1
  grep -qE '^FINDING|failed=' "$out" 2>/dev/null || return 1
  return 0
}

apply_py() { # SRC OUT OLD NEW -> rc 0 iff OLD occurs exactly once and OUT is written
  python3 - "$1" "$2" "$3" "$4" <<'PY'
import sys
src, out, old, new = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
try:
    t = open(src, encoding="utf-8").read()
except OSError:
    sys.exit(1)
if t.count(old) != 1:
    sys.exit(1)
open(out, "w", encoding="utf-8").write(t.replace(old, new))
PY
}

guard_calc() { # a b c d -> 0|1
  if [ "$1" = 1 ] && [ "$2" = 1 ] && [ "$3" = 1 ] && [ "$4" = 1 ]; then echo 1; else echo 0; fi
}

exit_code() { # guard killed -> 0|1
  if [ "$1" = 1 ] && [ "$2" = 5 ]; then echo 0; else echo 1; fi
}

verdict_line() { # killed guard l1 l2 l3 l4 l6 selftest real
  printf '%s: killed=%s population=5 guard=%s (l1=%s l2=%s l3=%s l4=%s l6=%s selftest=%s real=%s)\n' \
    "C2_REFUSAL" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}

# ---------------------------------------------------------------- selftest -----
if [ "$MODE" = selftest ]; then
  pass=0; fail=0
  st() { local n=$1; shift; if "$@" >/dev/null 2>&1; then pass=$((pass+1)); else fail=$((fail+1)); echo "FINDING R63-C2-ST-$n"; fi; }
  f=$WORK/st.line
  printf 'C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1)\n' > "$f"
  g=$WORK/st.line0
  printf 'C2_REFUSAL: killed=0 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=1 real=1)\n' > "$g"
  h=$WORK/st.none
  printf 'c2: no verdict here\n' > "$h"
  src=$WORK/st.src; printf 'alpha\nbeta\ngamma\n' > "$src"
  src2=$WORK/st.src2; printf 'alpha\nbeta\nalpha\n' > "$src2"
  c_field5() { [ "$(verdict_field "$f" killed)" = 5 ] && [ "$(verdict_field "$f" population)" = 5 ]; }
  c_field0() { [ "$(verdict_field "$g" killed)" = 0 ] && [ "$(verdict_field "$g" guard)" = 0 ]; }
  c_field_missing() { [ -z "$(verdict_field "$h" killed)" ]; }
  c_apply_ok() { apply_py "$src" "$WORK/st.out" beta BETA && grep -qx BETA "$WORK/st.out"; }
  c_apply_zero() { ! apply_py "$src" "$WORK/st.z" zeta ZETA; }
  c_apply_dup() { ! apply_py "$src2" "$WORK/st.d" alpha ALPHA; }
  c_fires_finding() { printf 'FINDING R63-C2-ST-x\n' > "$WORK/st.f1"; leg_fires 1 "$WORK/st.f1"; }
  c_fires_failed() { printf 'C2_SELFTEST: FAIL (cases=3 failed=1)\n' > "$WORK/st.f2"; leg_fires 1 "$WORK/st.f2"; }
  c_fires_rc0() { printf 'FINDING R63-C2-ST-x\n' > "$WORK/st.f3"; ! leg_fires 0 "$WORK/st.f3"; }
  c_fires_nofind() { printf 'all good\n' > "$WORK/st.f4"; ! leg_fires 1 "$WORK/st.f4"; }
  c_guard() { [ "$(guard_calc 1 1 1 1)" = 1 ] && [ "$(guard_calc 0 1 1 1)" = 0 ] \
    && [ "$(guard_calc 1 0 1 1)" = 0 ] && [ "$(guard_calc 1 1 0 1)" = 0 ] && [ "$(guard_calc 1 1 1 0)" = 0 ]; }
  c_exit() { [ "$(exit_code 1 5)" = 0 ] && [ "$(exit_code 1 4)" = 1 ] && [ "$(exit_code 0 5)" = 1 ]; }
  c_stub_differs() { local s; s=$(verdict_line 5 1 1 1 1 1 1 1 1); \
    [ "$s" != "C2_REFUSAL: killed=0 population=5 guard=1 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=1 real=1)" ]; }
  st field-killed c_field5
  st field-zero c_field0
  st field-missing c_field_missing
  st apply-ok c_apply_ok
  st apply-zero-match c_apply_zero
  st apply-duplicate c_apply_dup
  st fires-finding c_fires_finding
  st fires-failed c_fires_failed
  st fires-rc0 c_fires_rc0
  st fires-no-finding c_fires_nofind
  st guard-composition c_guard
  st exit-composition c_exit
  st stub-line-differs c_stub_differs
  n=$((pass + fail))
  if [ "$fail" -eq 0 ]; then
    echo "C2R63_SELFTEST: PASS (cases=$n)"
    exit 0
  fi
  echo "C2R63_SELFTEST: FAIL (cases=$n failed=$fail)"
  exit 1
fi

# ---------------------------------------------------------------- tree setup ---
command -v python3 >/dev/null 2>&1 || setup_die no-python3
if [ -n "$REV" ]; then
  mkdir -p -- "$WORK/rev" || setup_die no-rev-dir
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$WORK/rev" 2>/dev/null \
    || setup_die "bad-revision $REV"
  TREE=$WORK/rev
fi
[ -d "$TREE" ] || setup_die "bad-tree $TREE"
[ -f "$TREE/plans/round-62-c1.sh" ] || setup_die "missing plans/round-62-c1.sh"
[ -f "$TREE/plans/round-61-c1-check.py" ] || setup_die "missing plans/round-61-c1-check.py"
# The round-63 battery is optional: on a BASE tree it does not exist, and its two
#   stub controls are then absent (legs l3/l4 read 0, the A2/A3 BASE reading), never
#   a SETUP and never a pass.

# ------------------------------------------------------------------- legs ------
l1=0; l2=0; l3=0; l4=0; l6=0

# l1: the stub composition replaced by a constant. The mutant sits in a full copy of
#   the measured tree so its checker and fixture tables resolve exactly as the real
#   counter's do (a half-copy would fail the selftest for a missing checker, which is
#   not the mutation being killed).
cp -a "$TREE" "$WORK/l1" || setup_die l1-copy
l1_ok=0
if apply_py "$WORK/l1/plans/round-62-c1.sh" "$WORK/l1/plans/round-62-c1.sh" \
     '  stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1' '  stub=1'; then
  l1_ok=1
elif apply_py "$WORK/l1/plans/round-62-c1.sh" "$WORK/l1/plans/round-62-c1.sh" \
     '  [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1' '  stub=1'; then
  l1_ok=1
fi
[ "$l1_ok" = 1 ] || setup_die needle-l1
bash "$WORK/l1/plans/round-62-c1.sh" --selftest --tree "$TREE" >"$WORK/l1.out" 2>&1
leg_fires $? "$WORK/l1.out" && l1=1

# l2: stub_leg's negative vector removed (SL_OK=1 unconditionally).
cp -a "$TREE" "$WORK/l2" || setup_die l2-copy
apply_py "$WORK/l2/plans/round-62-c1.sh" "$WORK/l2/plans/round-62-c1.sh" \
  '  grep -q '"'"'^C1_BYPASS:'"'"' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
}' '  grep -q '"'"'^C1_BYPASS:'"'"' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
  SL_OK=1
}' || setup_die needle-l2
bash "$WORK/l2/plans/round-62-c1.sh" --selftest --tree "$TREE" >"$WORK/l2.out" 2>&1
leg_fires $? "$WORK/l2.out" && l2=1

# l3/l4: the battery's two stub controls must read mismatch (one battery run). A tree
#   without the round-63 battery has no such control: both legs read 0 (BASE reading).
if [ -f "$TREE/plans/round-63-controls.sh" ]; then
  bash "$TREE/plans/round-63-controls.sh" "$TREE" >"$WORK/battery.out" 2>&1
  brc=$?
  [ "$brc" = 2 ] && setup_die battery-setup
  grep -qE '^CONTROL C2-F6 .*verdict=mismatch' "$WORK/battery.out" && l3=1
  grep -qE '^CONTROL C1-F8 .*verdict=mismatch' "$WORK/battery.out" && l4=1
fi

# l6: the I6 superseded-stamp conjunct dropped.
mkdir -p -- "$WORK/l6/plans" || setup_die no-l6-dir
cp "$TREE/plans/round-61-c1-check.py" "$WORK/l6/plans/round-61-c1-check.py" || setup_die l6-copy
l6_ok=0
if apply_py "$WORK/l6/plans/round-61-c1-check.py" "$WORK/l6/plans/round-61-c1-check.py" \
     '    ok = len(qualifying) >= 3 and bool(superseded) and not denied' \
     '    ok = len(qualifying) >= 3 and not denied'; then
  l6_ok=1
elif apply_py "$WORK/l6/plans/round-61-c1-check.py" "$WORK/l6/plans/round-61-c1-check.py" \
     '    ok = len(qualifying) >= 3 and not denied and superseded_ok' \
     '    ok = len(qualifying) >= 3 and not denied'; then
  l6_ok=1
fi
[ "$l6_ok" = 1 ] || setup_die needle-l6
python3 -I -B "$WORK/l6/plans/round-61-c1-check.py" --selftest >"$WORK/l6.out" 2>&1
l6rc=$?
if [ "$l6rc" -ne 0 ] && grep -q 'C1_CHECK_SELFTEST: FAIL' "$WORK/l6.out"; then l6=1; fi

# ------------------------------------------------------------------ guard ------
g_a=0; g_b=0; g_c=0; g_d=0
bash "$TREE/plans/round-62-c1.sh" --selftest --tree "$TREE" >"$WORK/ga.out" 2>&1
[ $? -eq 0 ] && grep -q 'C1_COUNTER_SELFTEST: PASS' "$WORK/ga.out" && g_a=1
bash "$TREE/plans/round-63-c2.sh" --selftest >"$WORK/gb.out" 2>&1
[ $? -eq 0 ] && grep -q 'C2R63_SELFTEST: PASS' "$WORK/gb.out" && g_b=1
bash "$TREE/plans/round-62-c2.sh" --tree "$TREE" >"$WORK/gc.out" 2>&1
[ $? -eq 0 ] && grep -q 'value=5' "$WORK/gc.out" && grep -q 'shims=5' "$WORK/gc.out" \
  && grep -q 'vectors=ok/5' "$WORK/gc.out" && g_c=1
bash "$TREE/plans/round-62-controls.sh" --selftest >"$WORK/gd.out" 2>&1
[ $? -eq 0 ] && grep -q 'CONTROLS_SELFTEST: PASS' "$WORK/gd.out" && g_d=1

guard=$(guard_calc "$g_a" "$g_b" "$g_c" "$g_d")
killed=$((l1 + l2 + l3 + l4 + l6))
echo "c2-refusal: tree=$TREE scratch=$WORK"
echo "c2-refusal: guard a=$g_a b=$g_b c=$g_c d=$g_d"
verdict_line "$killed" "$guard" "$l1" "$l2" "$l3" "$l4" "$l6" "$g_b" "$g_c"
exit "$(exit_code "$guard" "$killed")"
