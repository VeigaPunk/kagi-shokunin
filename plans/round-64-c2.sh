#!/usr/bin/env bash
# plans/round-64-c2.sh — C2_REFUSAL: the five named surviving mutants must be
# refused, and one invocation must reach its verdict line end-to-end inside the
# frozen budget.
#
# Round 64 claim C2 (operability), plans/round-64.md §C2 (frozen, commit
# dff0929, Amendment A1). This is the bounded end-to-end verdict; the round-63
# counter's five legs are carried unchanged and the round-63 spot-check debt
# D-63-2 (M63-LEN: the nested battery re-entry) is closed by an explicit
# recursion bound.
#
# Legs (POP = 5, round-63 plan Amendment A2/A3; L5/S3 is vacuous at BASE):
#   l1  the tree's plans/round-62-c1.sh with its stub composition replaced by
#       `stub=1` must make its --selftest exit non-zero with a named FINDING or
#       `failed=` line
#   l2  the same counter with `SL_OK=1` appended to stub_leg must do the same
#   l3  the tree's plans/round-63-controls.sh control `C2-F6` must read `mismatch`
#   l4  the same battery's control `C1-F8` must read `mismatch`
#   l6  the tree's plans/round-61-c1-check.py with the I6 superseded-stamp conjunct
#       dropped must make its --selftest exit non-zero printing
#       `C1_CHECK_SELFTEST: FAIL`
#
# Recursion bound (round-64 plan §C2): C2_RECURSION_BOUND, default 1.
#   At 1 the l3/l4 battery delegation runs the measured tree's
#     plans/round-63-controls.sh with R63_CONTROLS_FIXTURE_ONLY=1: the battery
#     skips its unmutated-counter probe (probe_counters), so the leg never
#     re-enters a counter. The C1-F8/C2-F6 stub controls still run (they build
#     their own stub counters); the tree's battery honours the variable.
#   At 0 the delegation runs the full battery unchanged (the pre-bound
#     behaviour): the battery probes the tree's plans/round-63-c1.sh and
#     plans/round-63-c2.sh, the latter re-enters a C2 counter, and the run does
#     not terminate (the refutation leg; round-63's committed receipt is a
#     7-byte rc=124). The battery leg runs first, so a bound=0 run is inside
#     the battery's counter probe within seconds.
#   Any other value is SETUP. `bound=` in the verdict line is the effective
#   value this run used.
#
# Guard (round-63-c2.sh's (a)-(d), carried; plan §C2 guard (a)/(d) added):
#   (a) the tree's plans/round-62-c1.sh --selftest exits 0 printing
#       `C1_COUNTER_SELFTEST: PASS` (round-63 (a))
#   (b) this counter's own --selftest exits 0 (round-63 (b)), the tree's
#       plans/round-63-c2.sh --selftest exits 0 printing `C2R63_SELFTEST: PASS`
#       (plan §C2 guard (a)), and the tree's plans/round-63-controls.sh
#       --selftest exits 0 (plan §C2 guard (d) as fixture evidence; the full
#       battery run is the l3/l4 leg, fixture-only at bound 1)
#   (c) the tree's plans/round-62-c2.sh --tree TREE still reads the real trial's
#       `value=5 shims=5 vectors=ok/5` (round-63 (c) / kill rule K4). The
#       round-62 counter reports that fact as `real=1` in its `C2_HARDENED:`
#       line (it never re-emits the trial's `C2_SEAL_TRIAL:` tokens; the
#       round-63 leg's token greps could not match its output), so the field is
#       the equivalent check. Two attempts (the trial starts throwaway OpenBao
#       servers and is host-load sensitive); provenance names the attempt count.
#   (d) the tree's plans/round-62-controls.sh --selftest exits 0 printing
#       `CONTROLS_SELFTEST: PASS` (round-63 (d))
#   The verdict line's `selftest` field is 1 iff (b)'s three selftests pass;
#   `real` is 1 iff (c) passes.
#
# Budget composition: the three checker-bound round-62 C1 selftest runs that
# l1, l2 and guard (a) issue are ~24 checker measurements each (~8 min serially
# on a full tree under load: measured 488 s at 2026-11-08, load 51). l1, l2 and
# guard (a) are independent (distinct mutant copies, read-only measured tree,
# distinct instrument scratch tags), so they run as one parallel wave inside
# this single invocation; serially 3 x 488 s plus the real trial cannot fit the
# frozen 1200 s budget. The legs remain individually readable: l1/l2 are
# separate mutant processes with separate finding lines.
#
# terminates=1 iff this same process reached its verdict line inside the frozen
# budget of 1200 s (the budget `timeout 1200` gives the run; a run that reaches
# the line later, or is killed before it, has no verdict line at all).
#
# Usage: bash plans/round-64-c2.sh [revision | --tree DIR] [--repo DIR]
#        bash plans/round-64-c2.sh --selftest
#        C2_RECURSION_BOUND=0 bash plans/round-64-c2.sh --tree DIR
#   default tree = this repo's working tree; a revision is exported with git archive.
# Output: exactly one verdict line
#   C2_REFUSAL: killed=K population=5 guard=G (l1=… l2=… l3=… l4=… l6=… selftest=… real=… terminates=… bound=…)
# Exit 0 iff guard=1 and killed=5 and terminates=1; 1 otherwise; 2 SETUP.
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
    -h|--help) sed -n '2,76p' "${BASH_SOURCE[0]}"; exit 0 ;;
    --*) echo "C2_REFUSAL: SETUP unknown option $1"; exit 2 ;;
    *) [ -z "$REV" ] || { echo "C2_REFUSAL: SETUP unexpected argument $1"; exit 2; }
       REV=$1; shift ;;
  esac
done

# The effective recursion bound. Default 1; only 0 and 1 are meaningful.
BOUND=${C2_RECURSION_BOUND:-1}
case "$BOUND" in
  0|1) : ;;
  *) echo "C2_REFUSAL: SETUP bad-bound C2_RECURSION_BOUND=$BOUND"; exit 2 ;;
esac
BUDGET_S=1200
T0=$SECONDS

SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecC2Counter
mkdir -p -- "$SCRROOT" || { echo "C2_REFUSAL: SETUP no-scratch $SCRROOT"; exit 2; }
WORK=$SCRROOT/run-$(date +%Y%m%dT%H%M%SZ)-$$
mkdir -p -- "$WORK" || { echo "C2_REFUSAL: SETUP no-work $WORK"; exit 2; }
trap 'rm -rf -- "$WORK"' EXIT
export TMPDIR=$WORK
umask 077

setup_die() { printf 'C2_REFUSAL: SETUP %s\n' "$1"; exit 2; }

# ------------------------------------------------------------------ helpers -----
verdict_field() { # FILE FIELD -> value or empty (parentheses are token separators)
  [ -f "$1" ] || return 0
  awk 'index($0, "C2_REFUSAL:") == 1' "$1" | tr ' ()' '\n' \
    | grep -xE "$2=[^ ]*" | sed -n '1p' | cut -d= -f2-
}

hardened_field() { # FILE FIELD -> value from the last C2_HARDENED: line, or empty
  [ -f "$1" ] || return 0
  grep -E '^C2_HARDENED:' "$1" 2>/dev/null | tail -1 | tr ' ()' '\n' \
    | grep -xE "$2=[^ ]*" | sed -n '1p' | cut -d= -f2-
}

leg_fires() { # RC OUTFILE -> 0 iff the leg fired (non-zero rc AND a finding line)
  local rc=$1 out=$2
  [ "$rc" -ne 0 ] || return 1
  grep -qE '^FINDING|failed=' "$out" 2>/dev/null || return 1
  return 0
}

leg_mismatch() { # CONTROL-ID BATTERY-OUT -> 0 iff the battery read that control mismatch
  [ -f "$2" ] || return 1
  grep -qE "^CONTROL $1 .*verdict=mismatch" "$2" 2>/dev/null
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

killed_calc() { # l1 l2 l3 l4 l6 -> killed
  echo $(( $1 + $2 + $3 + $4 + $5 ))
}

exit_code() { # guard killed terminates -> 0|1
  if [ "$1" = 1 ] && [ "$2" = 5 ] && [ "$3" = 1 ]; then echo 0; else echo 1; fi
}

terminates_calc() { # ELAPSED_S BUDGET_S -> 0|1 (1 iff strictly inside the budget)
  if [ "$1" -lt "$2" ]; then echo 1; else echo 0; fi
}

bound_mode() { # BOUND -> fixture|full (the delegation composition)
  if [ "$1" = 1 ]; then echo fixture; else echo full; fi
}

battery_run() { # TREE OUTFILE BOUND [TIMEOUT_S] -> rc; runs the tree's battery
  # bound=1 sets R63_CONTROLS_FIXTURE_ONLY=1 (skip probe_counters; the stub
  # controls still run); bound=0 leaves it unset (the full battery). The
  # battery's own receipt is redirected into this run's scratch so the
  # measured tree is never written.
  local tree=$1 out=$2 bound=$3 tmo=${4:-0}
  if [ "$tmo" -gt 0 ]; then
    if [ "$bound" = 1 ]; then
      R63_CONTROLS_FIXTURE_ONLY=1 R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt timeout "$tmo" bash "$tree/plans/round-63-controls.sh" "$tree" >"$out" 2>&1
    else
      R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt timeout "$tmo" bash "$tree/plans/round-63-controls.sh" "$tree" >"$out" 2>&1
    fi
  else
    if [ "$bound" = 1 ]; then
      R63_CONTROLS_FIXTURE_ONLY=1 R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt bash "$tree/plans/round-63-controls.sh" "$tree" >"$out" 2>&1
    else
      R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt bash "$tree/plans/round-63-controls.sh" "$tree" >"$out" 2>&1
    fi
  fi
}

verdict_line() { # killed guard l1 l2 l3 l4 l6 selftest real terminates bound
  printf '%s: killed=%s population=5 guard=%s (l1=%s l2=%s l3=%s l4=%s l6=%s selftest=%s real=%s terminates=%s bound=%s)\n' \
    "C2_REFUSAL" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}"
}

# ---------------------------------------------------------------- selftest -----
if [ "$MODE" = selftest ]; then
  pass=0; fail=0
  st() { local n=$1; shift; if "$@" >/dev/null 2>&1; then pass=$((pass+1)); else fail=$((fail+1)); echo "FINDING R64-C2-ST-$n"; fi; }
  f=$WORK/st.line
  printf 'C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)\n' > "$f"
  g=$WORK/st.line0
  printf 'C2_REFUSAL: killed=0 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=1 real=1 terminates=0 bound=0)\n' > "$g"
  h=$WORK/st.none
  printf 'c2: no verdict here\n' > "$h"
  printf 'C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)\n' > "$WORK/st.hd"
  printf 'C2_HARDENED: killed=3 population=3 guard=0 (ma=1 mb=1 g=1 selftest=1 real=0)\n' > "$WORK/st.hd0"
  src=$WORK/st.src; printf 'alpha\nbeta\ngamma\n' > "$src"
  src2=$WORK/st.src2; printf 'alpha\nbeta\nalpha\n' > "$src2"
  c_field5() { [ "$(verdict_field "$f" killed)" = 5 ] && [ "$(verdict_field "$f" population)" = 5 ]; }
  c_field0() { [ "$(verdict_field "$g" killed)" = 0 ] && [ "$(verdict_field "$g" guard)" = 0 ]; }
  c_field_tb() { [ "$(verdict_field "$f" terminates)" = 1 ] && [ "$(verdict_field "$f" bound)" = 1 ] \
    && [ "$(verdict_field "$g" terminates)" = 0 ] && [ "$(verdict_field "$g" bound)" = 0 ] \
    && [ "$(hardened_field "$WORK/st.hd" real)" = 1 ] && [ "$(hardened_field "$WORK/st.hd0" real)" = 0 ] \
    && [ -z "$(hardened_field "$h" real)" ]; }
  c_field_missing() { [ -z "$(verdict_field "$h" killed)" ] && [ -z "$(verdict_field "$h" bound)" ]; }
  c_apply_ok() { apply_py "$src" "$WORK/st.out" beta BETA && grep -qx BETA "$WORK/st.out"; }
  c_apply_zero() { ! apply_py "$src" "$WORK/st.z" zeta ZETA; }
  c_apply_dup() { ! apply_py "$src2" "$WORK/st.d" alpha ALPHA; }
  c_fires_finding() { printf 'FINDING R64-C2-ST-x\n' > "$WORK/st.f1"; leg_fires 1 "$WORK/st.f1"; }
  c_fires_failed() { printf 'C2_SELFTEST: FAIL (cases=3 failed=1)\n' > "$WORK/st.f2"; leg_fires 1 "$WORK/st.f2"; }
  c_fires_rc0() { printf 'FINDING R64-C2-ST-x\n' > "$WORK/st.f3"; ! leg_fires 0 "$WORK/st.f3"; }
  c_fires_nofind() { printf 'all good\n' > "$WORK/st.f4"; ! leg_fires 1 "$WORK/st.f4"; }
  # one negative vector per leg position: a dropped leg lowers the sum by 1.
  c_killed_neg() { local i; local base=5; \
    for i in 0 1 2 3 4; do local v=(1 1 1 1 1); v[$i]=0; \
      [ "$(killed_calc "${v[0]}" "${v[1]}" "${v[2]}" "${v[3]}" "${v[4]}")" = $((base-1)) ] || return 1; done; \
    [ "$(killed_calc 1 1 1 1 1)" = 5 ]; }
  c_legs_mismatch() { printf 'CONTROL C2-F6 expect=killed=0 mismatch observed=killed=5 verdict=mismatch\nCONTROL C1-F8 expect=accepted=10 rejected=6 observed=accepted=0 verdict=mismatch\n' > "$WORK/st.bat"; \
    leg_mismatch C2-F6 "$WORK/st.bat" && leg_mismatch C1-F8 "$WORK/st.bat"; }
  c_legs_mismatch_neg() { printf 'CONTROL C2-F6 expect=killed=0 mismatch observed=killed=0 verdict=match\nCONTROL C1-F8 expect=accepted=10 rejected=6 observed=accepted=10 verdict=match\n' > "$WORK/st.bat2"; \
    ! leg_mismatch C2-F6 "$WORK/st.bat2" && ! leg_mismatch C1-F8 "$WORK/st.bat2"; }
  c_guard() { [ "$(guard_calc 1 1 1 1)" = 1 ] && [ "$(guard_calc 0 1 1 1)" = 0 ] \
    && [ "$(guard_calc 1 0 1 1)" = 0 ] && [ "$(guard_calc 1 1 0 1)" = 0 ] && [ "$(guard_calc 1 1 1 0)" = 0 ]; }
  c_exit() { [ "$(exit_code 1 5 1)" = 0 ] && [ "$(exit_code 1 4 1)" = 1 ] \
    && [ "$(exit_code 0 5 1)" = 1 ] && [ "$(exit_code 1 5 0)" = 1 ]; }
  c_bound_mode() { [ "$(bound_mode 1)" = fixture ] && [ "$(bound_mode 0)" = full ]; }
  c_terminates_calc() { [ "$(terminates_calc 5 1200)" = 1 ] && [ "$(terminates_calc 1200 1200)" = 0 ] \
    && [ "$(terminates_calc 1201 1200)" = 0 ]; }
  c_stub_differs() { local s; s=$(verdict_line 5 1 1 1 1 1 1 1 1 1 1); \
    [ "$s" = "C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)" ] \
    && [ "$s" != "C2_REFUSAL: killed=0 population=5 guard=1 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=1 real=1 terminates=0 bound=0)" ]; }
  # The bound's delegation composition: a fixture battery that honours
  # R63_CONTROLS_FIXTURE_ONLY terminates under a short timeout at bound=1 and
  # does not terminate under the same timeout at bound=0 (the refutation shape).
  FB=$WORK/fixture-battery
  mkdir -p "$FB/plans"
  cat > "$FB/plans/round-63-controls.sh" <<'FIXBAT'
#!/usr/bin/env bash
if [ "${R63_CONTROLS_FIXTURE_ONLY:-0}" = 1 ]; then
  echo "CONTROL C1-F8 expect=accepted=10 rejected=6 observed=accepted=0 rejected=0 verdict=mismatch"
  echo "CONTROL C2-F6 expect=killed=0 mismatch observed=killed=5 population=5 verdict=mismatch"
  echo "SKIPS: 5"
  echo "CONTROLS: match=0 mismatch=2"
  exit 1
fi
# full-battery model: the probe re-entry hangs (the round-63 defect)
sleep 60
exit 0
FIXBAT
  chmod +x "$FB/plans/round-63-controls.sh"
  c_fixture_battery_terminates() { battery_run "$FB" "$WORK/st.bat1" 1 5; local rc=$?; \
    [ "$rc" -ne 124 ] && leg_mismatch C2-F6 "$WORK/st.bat1" && leg_mismatch C1-F8 "$WORK/st.bat1"; }
  c_full_battery_hangs() { battery_run "$FB" "$WORK/st.bat0" 0 5; [ $? -eq 124 ]; }
  st field-killed c_field5
  st field-zero c_field0
  st field-terminates-bound c_field_tb
  st field-missing c_field_missing
  st apply-ok c_apply_ok
  st apply-zero-match c_apply_zero
  st apply-duplicate c_apply_dup
  st fires-finding c_fires_finding
  st fires-failed c_fires_failed
  st fires-rc0 c_fires_rc0
  st fires-no-finding c_fires_nofind
  st killed-composition-negative c_killed_neg
  st legs-mismatch-positive c_legs_mismatch
  st legs-mismatch-negative c_legs_mismatch_neg
  st guard-composition c_guard
  st exit-composition c_exit
  st bound-mode c_bound_mode
  st terminates-calc c_terminates_calc
  st verdict-line-shape c_stub_differs
  st fixture-battery-terminates c_fixture_battery_terminates
  st full-battery-hangs c_full_battery_hangs
  n=$((pass + fail))
  if [ "$fail" -eq 0 ]; then
    echo "C2R64_SELFTEST: PASS (cases=$n)"
    exit 0
  fi
  echo "C2R64_SELFTEST: FAIL (cases=$n failed=$fail)"
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
# The round-63 battery is optional: on a tree without it the two stub controls
#   are absent (legs l3/l4 read 0, the A2/A3 BASE reading), never a SETUP and
#   never a pass.

l1=0; l2=0; l3=0; l4=0; l6=0
g_a=0

# l3/l4: the battery's two stub controls must read mismatch (one battery run).
#   The recursion bound picks the delegation: at 1 the battery is told
#   R63_CONTROLS_FIXTURE_ONLY=1 and skips its counter probe, so this leg cannot
#   re-enter a counter; at 0 the full battery runs (and re-enters: the
#   refutation). The leg runs first, so the bound=0 run is inside the battery's
#   counter probe within seconds — the recursion the bound bounds — rather than
#   waiting on a selftest. A tree without the round-63 battery has no such
#   control: both legs read 0 (BASE reading).
l3=0; l4=0
if [ -f "$TREE/plans/round-63-controls.sh" ]; then
  battery_run "$TREE" "$WORK/battery.out" "$BOUND"
  brc=$?
  [ "$brc" = 2 ] && setup_die battery-setup
  leg_mismatch C2-F6 "$WORK/battery.out" && l3=1
  leg_mismatch C1-F8 "$WORK/battery.out" && l4=1
fi

# ------------------------------------------------------------------ real trial --
# Carried round-63 guard (c) / kill rule K4: the tree's round-62 C2 counter on
# the real trial must still read value=5 shims=5 vectors=ok/5. The round-62
# counter reports that fact as `real=1` in its `C2_HARDENED:` line (it parses
# the trial counter's `C2_SEAL_TRIAL:` tokens internally; it never re-emits
# them — the round-63 leg's `grep value=5` matched only the counter's own
# selftest fixture text, so that leg could not pass; the field parse is the
# equivalent check). The trial starts throwaway OpenBao servers and is
# host-load sensitive; two attempts, provenance records the count. It runs
# before the l1/l2/guard-(a) wave: the trial is timing-sensitive, while the
# checker-bound selftests saturate every CPU.
g_c=0; real_attempts=0; real_rc=""; real_field=""
for attempt in 1 2; do
  real_attempts=$attempt
  bash "$TREE/plans/round-62-c2.sh" --tree "$TREE" >"$WORK/gc.$attempt.out" 2>&1
  real_rc=$?
  real_field=$(hardened_field "$WORK/gc.$attempt.out" real)
  if [ "$real_rc" -eq 0 ] && [ "$real_field" = 1 ]; then g_c=1; break; fi
done

# ------------------------------------------------------------------- legs ------
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

# l2: stub_leg's negative vector removed (SL_OK=1 unconditionally).
cp -a "$TREE" "$WORK/l2" || setup_die l2-copy
apply_py "$WORK/l2/plans/round-62-c1.sh" "$WORK/l2/plans/round-62-c1.sh" \
  '  grep -q '"'"'^C1_BYPASS:'"'"' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
}' '  grep -q '"'"'^C1_BYPASS:'"'"' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
  SL_OK=1
}' || setup_die needle-l2

# l6: the I6 superseded-stamp conjunct dropped (cheap; runs before the wave).
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

# l1/l2 and the carried guard (a): the three checker-bound round-62 selftest
#   runs are independent (distinct mutant copies, read-only measured tree,
#   distinct instrument scratch tags), so they run as one wave; the frozen
#   1200 s budget covers them only composed this way.
bash "$WORK/l1/plans/round-62-c1.sh" --selftest --tree "$TREE" >"$WORK/l1.out" 2>&1 &
p_l1=$!
bash "$WORK/l2/plans/round-62-c1.sh" --selftest --tree "$TREE" >"$WORK/l2.out" 2>&1 &
p_l2=$!
bash "$TREE/plans/round-62-c1.sh" --selftest --tree "$TREE" >"$WORK/ga.out" 2>&1 &
p_ga=$!
wait "$p_l1"; rc_l1=$?
wait "$p_l2"; rc_l2=$?
wait "$p_ga"; rc_ga=$?
leg_fires "$rc_l1" "$WORK/l1.out" && l1=1
leg_fires "$rc_l2" "$WORK/l2.out" && l2=1
[ "$rc_ga" -eq 0 ] && grep -q 'C1_COUNTER_SELFTEST: PASS' "$WORK/ga.out" && g_a=1

# ------------------------------------------------------------------ guard ------
# g_a (the unmutated round-62 C1 counter selftest, carried round-63 guard (a))
#   and g_c (the real trial, carried round-63 guard (c) / kill rule K4) were
#   computed above, before the selftest wave.
# g_r63  plan §C2 guard (a): the tree's round-63 C2 counter selftest
# g_b    this counter's own selftest
# g_d    carried round-63 guard (d): the tree's round-62 controls selftest
# g_e    plan §C2 guard (d) as fixture evidence: the tree's round-63 controls
#        battery selftest (its full run is the l3/l4 leg, fixture-only at bound 1)
# Guard G = g_a AND (g_b AND g_r63 AND g_e) AND g_c AND g_d. Plan §C2 guard (b)
# (the bound=0 refutation) is the external `timeout 240` measurement and the
# selftest's fixture-battery composition: a runtime 240 s hang would spend the
# budget it is meant to protect.
g_b=0; g_d=0; g_e=0; g_r63=0
bash "$TREE/plans/round-63-c2.sh" --selftest >"$WORK/gr63.out" 2>&1
[ $? -eq 0 ] && grep -q 'C2R63_SELFTEST: PASS' "$WORK/gr63.out" && g_r63=1
bash "${BASH_SOURCE[0]}" --selftest >"$WORK/gb.out" 2>&1
[ $? -eq 0 ] && grep -q 'C2R64_SELFTEST: PASS' "$WORK/gb.out" && g_b=1
bash "$TREE/plans/round-62-controls.sh" --selftest >"$WORK/gd.out" 2>&1
[ $? -eq 0 ] && grep -q 'CONTROLS_SELFTEST: PASS' "$WORK/gd.out" && g_d=1
bash "$TREE/plans/round-63-controls.sh" --selftest >"$WORK/ge.out" 2>&1
[ $? -eq 0 ] && grep -q 'CONTROLS_SELFTEST: PASS' "$WORK/ge.out" && g_e=1

selftest_leg=$g_b
[ "$g_r63" = 1 ] || selftest_leg=0
[ "$g_e" = 1 ] || selftest_leg=0
real_leg=$g_c
guard=$(guard_calc "$g_a" "$selftest_leg" "$real_leg" "$g_d")
killed=$(killed_calc "$l1" "$l2" "$l3" "$l4" "$l6")
terminates=$(terminates_calc $((SECONDS - T0)) "$BUDGET_S")
echo "c2-refusal: tree=$TREE scratch=$WORK bound=$BOUND elapsed=$((SECONDS - T0))s"
echo "c2-refusal: guard a=$g_a r63selftest=$g_r63 b=$g_b c=$g_c d=$g_d e=$g_e real-attempts=$real_attempts real-rc=$real_rc"
verdict_line "$killed" "$guard" "$l1" "$l2" "$l3" "$l4" "$l6" "$selftest_leg" "$real_leg" "$terminates" "$BOUND"
exit "$(exit_code "$guard" "$killed" "$terminates")"
