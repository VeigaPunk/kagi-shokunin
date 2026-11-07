#!/usr/bin/env bash
# plans/round-62-c2.sh -- round 62 C2 counter (operability: the round-61 C2
# counter's guard and self-invocation can fail -- and are made to).
#
# Frozen predicate (plans/round-62.md section C2; not amendable here):
#   C2_HARDENED: killed = the number of the three falsifier legs that fire over
#   POP = 3 --
#     M-A: the measured tree's C2 counter (plans/round-61-c2.sh) with the block
#          strictly between its DECIDE markers replaced by "  echo 5" makes
#          --selftest exit non-zero printing a named FINDING;
#     M-B: the same counter with the block strictly between its SHIMS markers
#          replaced by "  shims_ok=5" makes --selftest exit non-zero printing a
#          named FINDING;
#     G:   a tree whose trial file (corpus/openbao-seal-trial.sh) is a
#          valid-sha256 stub that prints no expected observable reads guard=0
#          on the unmutated counter --
#   when GUARD = 1, else FAIL. Target 3 (BASE 0).
#   GUARD = 1 iff, on the same measured tree:
#     (a) the unmutated counter's --selftest exits 0 printing
#         C2_SELFTEST: PASS (cases=N) with N >= 17;
#     (b) the counter on the real trial reads value=5 ... shims=5 vectors=ok/5;
#     (c) a constant-verdict counter (a copy whose --selftest prints PASS
#         without executing the aggregation) is refused by the counter's own
#         stub control -- the stub control IS the M-A/M-B mutation: a selftest
#         that never executes the aggregation keeps printing PASS under both
#         constant replacements, the legs stop firing, and guard leg (c) reads
#         0, so the counter is refused.
# Needle discipline (K2): each marker must occur exactly once in the measured
#   counter; 0 or >1 occurrences fails closed (the leg cannot fire and is not
#   counted towards killed).
# Output: exactly one line
#   C2_HARDENED: killed=K population=3 guard=G (ma=... mb=... g=... selftest=... real=...)
#   exit 0 iff guard=1 and killed=3; 1 otherwise; 2 SETUP.
# SETUP (exit 2): missing git or awk, a bad revision, an unreadable --tree, a
#   measured tree without plans/round-61-c2.sh, a missing bao binary or a bao
#   binary whose sha256 is not the pin read from the measured tree's
#   plans/round-57-c2.sh (the real-trial leg needs it), a bao binary in
#   /usr/bin or /bin, or an unusable scratch. The heavy real-trial leg runs
#   LAST so SETUP surfaces before it.
# Nothing is ever written inside the measured tree: mutations are applied to
#   copies in this counter's scratch (each mirrored with the measured tree's
#   plans/round-57-c2.sh so the mutant's own REPO resolution works), the G
#   stub tree lives in the scratch, and the measured counter manages its own
#   scratch. Run-log names are randomized; umask 077; TMPDIR points into the
#   scratch; no hardcoded /tmp.
# Input: a revision (BASE 60b5b7b60b76629633110a5b4adac883193c8b2a when
#   omitted), or --tree DIR, or --selftest (fixture-driven: no bao, no
#   network, prints C2R62_SELFTEST: PASS (cases=N) on success, exits 0; on
#   failure prints named R62-C2-ST-<case> FINDING lines and exits 1).
set -u
umask 077
export LC_ALL=C
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
SELF=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P)/$(basename "$0")
BASE=60b5b7b60b76629633110a5b4adac883193c8b2a
NAME=C2_HARDENED
MCOUNTER=plans/round-61-c2.sh
BAO_BIN="${R61_BAO:-$HOME/.local/bin/bao}"
setup() { echo "$NAME: SETUP $1"; exit 2; }
OPEN_DEC='# BEGIN-DECIDE'; CLOSE_DEC='# END-DECIDE'
OPEN_SHIM='# BEGIN-SHIMS'; CLOSE_SHIM='# END-SHIMS'
REPL_MA='  echo 5'; REPL_MB='  shims_ok=5'

apply_mut() { # SRC OUT OPEN CLOSE REPL -> rc 0 iff each marker occurs exactly once; OUT = mutated copy
  local src=$1 out=$2 mo=$3 mc=$4 rep=$5 no nc
  [ -f "$src" ] && [ ! -L "$src" ] || return 1
  no=$(grep -cF -- "$mo" "$src" 2>/dev/null)
  nc=$(grep -cF -- "$mc" "$src" 2>/dev/null)
  [ "$no" = 1 ] && [ "$nc" = 1 ] || return 1
  awk -v mo="$mo" -v mc="$mc" -v rep="$rep" '
    !inb && index($0, mo) == 1 { print; print rep; inb=1; next }
    inb && index($0, mc) == 1 { inb=0; print; next }
    !inb
  ' "$src" > "$out" 2>/dev/null || return 1
  [ -s "$out" ] || return 1
  return 0
}
selftest_n() { # FILE -> echoes N iff the file carries exactly one C2_SELFTEST: PASS (cases=N) line
  local c
  c=$(grep -cE '^C2_SELFTEST: PASS \(cases=[0-9]+\)' "$1" 2>/dev/null)
  [ "$c" = 1 ] || return 1
  grep -oE '^C2_SELFTEST: PASS \(cases=[0-9]+\)' "$1" | grep -oE 'cases=[0-9]+' | grep -oE '[0-9]+'
}
verdict_field() { # FILE KEY -> value from the single C2_SEAL_TRIAL: line
  local c
  c=$(grep -cE '^C2_SEAL_TRIAL:' "$1" 2>/dev/null)
  [ "$c" = 1 ] || return 1
  awk 'index($0, "C2_SEAL_TRIAL:") == 1' "$1" | tr ' ' '\n' \
    | grep -xE "$2=[^ ]*" | sed -n '1p' | cut -d= -f2-
}
finding_named() { # FILE -> rc 0 iff a named R61-C2-ST- FINDING line is present
  grep -qE '^FINDING R61-C2-ST-' "$1" 2>/dev/null
}
guard_calc() { # selftest real refused -> 0|1 (frozen guard legs a, b, c)
  if [ "$1" = 1 ] && [ "$2" = 1 ] && [ "$3" = 1 ]; then echo 1; else echo 0; fi
}
exit_code() { # guard killed -> 0|1 (2 SETUP is a separate path)
  if [ "$1" = 1 ] && [ "$2" = 3 ]; then echo 0; else echo 1; fi
}
verdict_line() { # killed guard ma mb g selftest real -> the one output line
  printf '%s: killed=%s population=3 guard=%s (ma=%s mb=%s g=%s selftest=%s real=%s)\n' \
    "$NAME" "$1" "$2" "$3" "$4" "$5" "$6" "$7"
}

# ---------------------------------------------------------------- selftest --
if [ "${1:-}" = "--selftest" ]; then
  SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ExecC2Counter/c2r62-selftest.$$
  mkdir -p -- "$SCR" || { echo "$NAME: SETUP no-scratch"; exit 2; }
  trap 'rm -rf -- "$SCR"' EXIT
  export TMPDIR=$SCR
  pass=0; fail=0
  st() { local n=$1; shift; if "$@" >/dev/null 2>&1; then pass=$((pass+1)); else fail=$((fail+1)); echo "FINDING R62-C2-ST-$n"; fi; }
  mkfix() { # OUT -> fixture counter with one DECIDE and one SHIMS block
    {
      echo '#!/usr/bin/env bash'
      echo 'set -u'
      echo 'decide() {'
      echo "$OPEN_DEC"
      echo '  local v=0'
      echo '  echo "$v"'
      echo "$CLOSE_DEC"
      echo '}'
      echo 'shim_count() {'
      echo "$OPEN_SHIM"
      echo '  local n=0'
      echo '  echo "$n"'
      echo "$CLOSE_SHIM"
      echo '}'
      echo 'decide 5 5 1 1 1 1 >/dev/null'
    } >"$1"
  }
  fx=$SCR/fix.bash; mkfix "$fx"
  fxnod=$SCR/fix-nodec.bash
  { grep -vF -- "$OPEN_DEC" "$fx" | grep -vF -- "$CLOSE_DEC"; } >"$fxnod" 2>/dev/null
  fxdup=$SCR/fix-dupdec.bash
  awk -v mo="$OPEN_DEC" '
    { print }
    index($0, mo) == 1 { print }
  ' "$fx" >"$fxdup" 2>/dev/null
  c_base_const() { printf '%s' "$BASE" | grep -qE '^[0-9a-f]{40}$'; }
  c_mut_ok() { apply_mut "$fx" "$SCR/mut.bash" "$OPEN_DEC" "$CLOSE_DEC" "$REPL_MA" \
    && [ "$(grep -cF -- "$OPEN_DEC" "$SCR/mut.bash")" = 1 ] \
    && [ "$(grep -cF -- "$CLOSE_DEC" "$SCR/mut.bash")" = 1 ] \
    && [ "$(grep -cF -- "$REPL_MA" "$SCR/mut.bash")" = 1 ]; }
  c_mut_between() { apply_mut "$fx" "$SCR/mut2.bash" "$OPEN_DEC" "$CLOSE_DEC" "$REPL_MA" \
    && ! grep -qF -- 'local v=0' "$SCR/mut2.bash"; }
  c_mut_missing() { ! apply_mut "$fxnod" "$SCR/mut3.bash" "$OPEN_DEC" "$CLOSE_DEC" "$REPL_MA"; }
  c_mut_dup() { ! apply_mut "$fxdup" "$SCR/mut4.bash" "$OPEN_DEC" "$CLOSE_DEC" "$REPL_MA"; }
  printf 'C2_SELFTEST: PASS (cases=21)\n' >"$SCR/st1"
  printf 'C2_SELFTEST: PASS (cases=11)\n' >"$SCR/st2"
  printf 'C2_SELFTEST: PASS (cases=17)\nC2_SELFTEST: PASS (cases=18)\n' >"$SCR/st3"
  c_st_pass_n() { local n; n=$(selftest_n "$SCR/st1") && [ "$n" = 21 ]; }
  c_st_gate() { local n; n=$(selftest_n "$SCR/st1") && [ "$n" -ge 17 ]; }
  c_st_below() { local n; n=$(selftest_n "$SCR/st2") && [ "$n" -lt 17 ]; }
  c_st_multi() { ! selftest_n "$SCR/st3" >/dev/null; }
  printf 'C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB trial=%s cases=63)\n' "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" >"$SCR/v5"
  printf 'C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (real=0 real2=0 none=0 ops=0 t2w=0 stubctl=1 secret=1 sh1=NONE sh2=NONE sh3=NONE sh4=NONE sh5=NONE trial=%s cases=0)\n' "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" >"$SCR/v0"
  : >"$SCR/vnone"
  c_field_parse() { [ "$(verdict_field "$SCR/v5" value)" = 5 ] \
    && [ "$(verdict_field "$SCR/v5" shims)" = 5 ] \
    && [ "$(verdict_field "$SCR/v5" vectors)" = "ok/5" ] \
    && [ "$(verdict_field "$SCR/v5" guard)" = 1 ]; }
  c_field_guard0() { [ "$(verdict_field "$SCR/v0" guard)" = 0 ] \
    && [ "$(verdict_field "$SCR/v0" value)" = 0 ]; }
  c_field_missing() { ! verdict_field "$SCR/vnone" guard >/dev/null; }
  printf 'FINDING R61-C2-ST-decide-pass\n' >"$SCR/f1"
  : >"$SCR/f2"
  c_finding_detect() { finding_named "$SCR/f1" && ! finding_named "$SCR/f2"; }
  c_guard_conjunct() { [ "$(guard_calc 1 1 1)" = 1 ] && [ "$(guard_calc 0 1 1)" = 0 ] \
    && [ "$(guard_calc 1 1 0)" = 0 ] && [ "$(guard_calc 1 0 1)" = 0 ]; }
  c_exit_map() { [ "$(exit_code 1 3)" = 0 ] && [ "$(exit_code 0 3)" = 1 ] \
    && [ "$(exit_code 1 2)" = 1 ] && [ "$(exit_code 0 0)" = 1 ]; }
  c_verdict_format() { local o; o=$(verdict_line 3 1 1 1 1 1 1); printf '%s\n' "$o" \
    | grep -qE '^C2_HARDENED: killed=3 population=3 guard=1 \(ma=1 mb=1 g=1 selftest=1 real=1\)$'; }
  st base-const c_base_const
  st mut-ok c_mut_ok
  st mut-between c_mut_between
  st mut-missing c_mut_missing
  st mut-dup c_mut_dup
  st st-pass-n c_st_pass_n
  st st-gate c_st_gate
  st st-below c_st_below
  st st-multi c_st_multi
  st field-parse c_field_parse
  st field-guard0 c_field_guard0
  st field-missing c_field_missing
  st finding-detect c_finding_detect
  st guard-conjunct c_guard_conjunct
  st exit-map c_exit_map
  st verdict-format c_verdict_format
  if [ "$fail" = 0 ]; then
    echo "C2R62_SELFTEST: PASS (cases=$pass)"; exit 0
  fi
  echo "C2R62_SELFTEST: FAIL (cases=$((pass+fail)) failed=$fail)"; exit 1
fi

# -------------------------------------------------------------------- main --
command -v git >/dev/null 2>&1 || setup no-git
command -v awk >/dev/null 2>&1 || setup no-awk
command -v sha256sum >/dev/null 2>&1 || setup no-sha256sum
REV=""; TREE=""
case "${1:-}" in
  --tree)
    if [ $# -lt 2 ]; then setup bad-tree; fi
    TREE=$2;;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ExecC2Counter/c2r62.$$
mkdir -p -- "$SCR" || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || setup bad-tree
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null || setup bad-revision
fi
MCOUNT="$ROOT/$MCOUNTER"
[ -f "$MCOUNT" ] && [ ! -L "$MCOUNT" ] || setup counter-missing
# The real-trial leg needs the pinned bao binary (SETUP otherwise); the same
#   resolution and pin source the measured counter itself uses.
[ -x "$BAO_BIN" ] || setup bao-missing
PIN_FILE="$ROOT/plans/round-57-c2.sh"
[ -f "$PIN_FILE" ] || setup bao-pin-unreadable
PIN_BAO=$(grep -oE '^PIN_BAO=[0-9a-f]{64}$' "$PIN_FILE" 2>/dev/null | cut -d= -f2)
printf '%s' "$PIN_BAO" | grep -qE '^[0-9a-f]{64}$' || setup bao-pin-unreadable
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done

# Leg (a): the unmutated counter's own selftest must PASS with N >= 17.
bash "$MCOUNT" --selftest >"$SCR/a.out" 2>"$SCR/a.err"; arc=$?
[ "$arc" = 2 ] && setup measured-counter-setup
selftest_flag=0
if [ "$arc" = 0 ]; then
  stn=$(selftest_n "$SCR/a.out" 2>/dev/null)
  if [ -n "$stn" ] && [ "$stn" -ge 17 ]; then selftest_flag=1; fi
fi

# Legs M-A / M-B: constant replacement of each aggregation block must make the
#   counter's --selftest exit non-zero printing a named FINDING. Each mutant
#   copy sits in a mirrored tree with the measured tree's pin file so the
#   mutant's nested control cases resolve its own REPO as the real counter
#   would. A needle that does not match exactly once fails closed (leg absent).
ma=0; mb=0
mkdir -p "$SCR/matree/plans" "$SCR/mbtree/plans"
cp "$PIN_FILE" "$SCR/matree/plans/round-57-c2.sh" 2>/dev/null
cp "$PIN_FILE" "$SCR/mbtree/plans/round-57-c2.sh" 2>/dev/null
# Amendment A2: the marker block when the measured counter carries it, else the
# BASE aggregation text (the reviewer's mutation). Each needle matches exactly
# once; neither matching leaves the leg absent (0).
apply_base_mut() { # SRC OUT KIND(ma|mb) -> rc 0 iff the BASE block occurs exactly once
  local src=$1 out=$2 kind=$3
  [ -f "$src" ] && [ ! -L "$src" ] || return 1
  command -v python3 >/dev/null 2>&1 || return 1
  python3 - "$src" "$out" "$kind" <<'PYEOF'
import sys
src, out, kind = sys.argv[1], sys.argv[2], sys.argv[3]
t = open(src, encoding="utf-8").read()
if kind == "ma":
    old = ('value=0\n'
           '[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] \\\n'
           '  && [ "$selftest_ok" = 1 ] && [ "$ops_ok" = 1 ] && [ "$t2_ok" = 1 ] && value=5')
    new = "value=5"
else:
    old = '    && broken41 "${OUT[sh$n]}" && shims_ok=$((shims_ok+1))'
    new = '    ; shims_ok=$((shims_ok+1))'
if t.count(old) != 1:
    sys.exit(1)
open(out, "w", encoding="utf-8").write(t.replace(old, new))
PYEOF
}
ma_applied=0
if apply_mut "$MCOUNT" "$SCR/matree/plans/round-61-c2.sh" "$OPEN_DEC" "$CLOSE_DEC" "$REPL_MA"; then
  ma_applied=1
elif apply_base_mut "$MCOUNT" "$SCR/matree/plans/round-61-c2.sh" ma; then
  ma_applied=1
fi
[ "$ma_applied" = 1 ] || setup needle-ma
if [ "$ma_applied" = 1 ]; then
  bash "$SCR/matree/plans/round-61-c2.sh" --selftest >"$SCR/ma.out" 2>"$SCR/ma.err"; mrc=$?
  [ "$mrc" = 2 ] && setup measured-counter-setup
  if [ "$mrc" -gt 0 ] && finding_named "$SCR/ma.out"; then ma=1; fi
fi
mb_applied=0
if apply_mut "$MCOUNT" "$SCR/mbtree/plans/round-61-c2.sh" "$OPEN_SHIM" "$CLOSE_SHIM" "$REPL_MB"; then
  mb_applied=1
elif apply_base_mut "$MCOUNT" "$SCR/mbtree/plans/round-61-c2.sh" mb; then
  mb_applied=1
fi
[ "$mb_applied" = 1 ] || setup needle-mb
if [ "$mb_applied" = 1 ]; then
  bash "$SCR/mbtree/plans/round-61-c2.sh" --selftest >"$SCR/mb.out" 2>"$SCR/mb.err"; mrc=$?
  [ "$mrc" = 2 ] && setup measured-counter-setup
  if [ "$mrc" -gt 0 ] && finding_named "$SCR/mb.out"; then mb=1; fi
fi

# Leg G: a tree whose trial is a valid-sha256 stub that prints no expected
#   observable must read guard=0 on the unmutated counter (BASE read guard=1).
g=0
mkdir -p "$SCR/gtree/corpus"
printf '#!/usr/bin/env bash\n# G-challenge stub (counter scratch only): valid sha256, prints no expected observable.\nexit 0\n' > "$SCR/gtree/corpus/openbao-seal-trial.sh"
chmod +x "$SCR/gtree/corpus/openbao-seal-trial.sh"
bash "$MCOUNT" --tree "$SCR/gtree" >"$SCR/g.out" 2>"$SCR/g.err"; grc=$?
[ "$grc" = 2 ] && setup measured-counter-setup
gv=$(verdict_field "$SCR/g.out" guard 2>/dev/null)
if [ "$grc" = 1 ] && [ "$gv" = 0 ]; then g=1; fi

# Guard leg (b): the counter on the real trial must still read its verdict.
#   Heavy (starts throwaway OpenBao servers through the measured counter's own
#   discipline), so it runs last.
real_flag=0
bash "$MCOUNT" --tree "$ROOT" >"$SCR/b.out" 2>"$SCR/b.err"; brc=$?
[ "$brc" = 2 ] && setup measured-counter-setup
bv=$(verdict_field "$SCR/b.out" value 2>/dev/null)
bs=$(verdict_field "$SCR/b.out" shims 2>/dev/null)
bvec=$(verdict_field "$SCR/b.out" vectors 2>/dev/null)
if [ "$brc" = 0 ] && [ "$bv" = 5 ] && [ "$bs" = 5 ] && [ "$bvec" = "ok/5" ]; then
  real_flag=1
fi

# Guard leg (c): a constant-verdict counter is refused by the stub control --
#   the M-A/M-B stub replacements must be able to refuse the counter (both fire
#   on an honest selftest; a selftest that prints PASS without executing the
#   aggregation cannot be refused, reads refused=0, and fails the guard).
refused=0
[ "$ma" = 1 ] && [ "$mb" = 1 ] && refused=1
guard=$(guard_calc "$selftest_flag" "$real_flag" "$refused")
killed=$((ma + mb + g))
verdict_line "$killed" "$guard" "$ma" "$mb" "$g" "$selftest_flag" "$real_flag"
exit "$(exit_code "$guard" "$killed")"
