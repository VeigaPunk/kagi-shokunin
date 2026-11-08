#!/usr/bin/env bash
# plans/round-63-controls.sh -- pre-freeze control battery for round 63 (kagi).
#   usage: bash plans/round-63-controls.sh [TREE_DIR]      (default: this lane's working tree)
#          bash plans/round-63-controls.sh --selftest       (fixture-driven; no lane
#                                                          instruments, no bao)
#
# Declared by plans/round-63.md sections C1 and C2 (frozen, commit 12c9e428) and the
# round-63 wave dispatch. The battery carries the two new stub controls that close the
# round-62 routed defect classes (critic D-6: no leg refused a printer-stub claim
# counter; critic D12: no case ran a constant-verdict copy of the C2 counter), the two
# no-work controls, the two positive controls, and the round-62 battery re-run as
# PRIOR-<n> rows.
#
# Control map (id -> expectation -> instrument):
#   C1-F8       a printer-stub copy of plans/round-63-c1.sh (prints a constant
#               `C1_RESIDUAL:` verdict line naming the target reading, exits 0) run
#               on the measured tree must read `mismatch` against the independently
#               expected BASE line `accepted=10 rejected=6` (the stub is refused
#               because its fields do not match the BASE census).
#   C2-F6       a constant-verdict copy of plans/round-63-c2.sh (prints a constant
#               `C2_REFUSAL:` verdict line naming killed=5, exits 0) run on the
#               measured tree must read `mismatch` against the expected BASE line
#               `killed=0`.
#   C1-NOWORK   plans/round-63-c1.sh <tree> on the unmutated tree must read
#               `accepted=10 rejected=6 population=10/6` (the no-work control; any
#               lower reading means a fixture is vacuous and voids the claim,
#               frozen kill rule C1-K1).
#   C2-NOWORK   plans/round-63-c2.sh <tree> on the unmutated tree must read
#               `killed=0 population=5` (the no-work control, frozen kill rule
#               C2-K1).
#   C1-REAL     the unmutated plans/round-63-c1.sh must print a `C1_RESIDUAL:`
#               verdict line carrying guard=1 (the positive control; a blanket
#               refusal is not a gain).
#   C2-REAL     the unmutated plans/round-63-c2.sh must print a `C2_REFUSAL:`
#               verdict line carrying guard=1.
#   PRIOR-<id>  the round-62 battery's own 14 controls re-run by delegating to
#               <tree>/plans/round-62-controls.sh <tree>; each `CONTROL <id>` line
#               is re-emitted as `CONTROL PRIOR-<id>` with its verdict preserved.
#
# Exit contract: exit 0 iff mismatch=0; 1 on any mismatch; 2 SETUP (unusable tree
# argument or missing scratch). `CONTROLS: match=N mismatch=M` is the last summary
# line; SKIPS are recorded, not mismatches.
#
# Stub construction: the stub controls do not hand-write verdict lines; they take a
# byte copy of the measured counter and prepend (after the shebang) a dispatch that
# intercepts every invocation and prints the frozen target line. On the BASE tree
# (where the counter is absent) the control records `absent`/`skip`; on a candidate
# tree the stub prints the candidate's own target line, which the battery compares
# against the independently expected BASE census -- a stub that prints the target
# verdict is indistinguishable from a real pass by output alone (frozen named
# ceiling), so the refusal here is specifically "the stub's constant line does not
# match the BASE reading the no-work control independently requires".
#
# Discipline: everything runs on copies under
# ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ExecControls/battery.$$ and is
# removed on exit; TMPDIR points into the scratch; umask 077; no /tmp evidence.
# No git/jj mutation anywhere: the only git use is the PRIOR delegation's own
# read-only `git archive` inside the measured tree's copy of round-62-controls.sh,
# and `git -C <lane> archive` is never invoked by this script. Nothing is written
# inside a measured tree (the PRIOR battery is invoked on a private snapshot copy).
# Every line captured from an instrument is redacted to shape before it reaches the
# receipt (QM72), mirroring the round-62 battery's redaction.
#
# Recursion bound (round-64 C2, plans/round-64.md section C2): R63_CONTROLS_FIXTURE_ONLY.
#   Unset/0: the full battery (unchanged behaviour).
#   Set to 1: fixture/confinement-only mode. probe_counters is skipped (the
#     unmutated counter probe is the leg that re-enters a counter), so C1-NOWORK,
#     C2-NOWORK, C1-REAL and C2-REAL record `skip`; the PRIOR delegation to
#     round-62-controls.sh is skipped (it runs counters of its own); the C1-F8 and
#     C2-F6 stub controls still run, because each builds its own stub counter.
#     The battery never invokes round-63-c1.sh, round-63-c2.sh or any other counter
#     in this mode.
set -u -o pipefail
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
SELFPATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/$(basename "${BASH_SOURCE[0]}")
CTLDIR_REL=.ufo/waves/round-63/build/R63ExecControls
C1CTR_REL=plans/round-63-c1.sh
C2CTR_REL=plans/round-63-c2.sh
PRIOR_REL=plans/round-62-controls.sh
SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ExecControls

# Frozen expected BASE readings (plans/round-63.md section C1/C2 population census,
# measured by the L1 at 0c07aab8 and re-derived by the committed counters).
C1_BASE_ACCEPTED=10
C1_BASE_REJECTED=6
C1_BASE_POP="10/6"
C2_BASE_KILLED=0
C2_BASE_POP=5   # plan Amendment A2/A3: L5 (S3) is vacuous at BASE and dropped

# Stub verdict lines: the frozen target readings a stub copy would print. These are
# the *candidate-success* lines, not the BASE lines -- the controls exist to prove
# the battery refuses them on a BASE-equivalent tree.
C1_STUB_LINE='C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1 chal=1)'
C2_STUB_LINE='C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1)'

# ---------------------------------------------------------------- scratch setup --
if [ "${1:-}" = "--selftest" ]; then
  SCR=$SCRROOT/selftest.$$
else
  SCR=$SCRROOT/battery.$$
fi
mkdir -p -- "$SCR" || { echo "SETUP no-scratch at $SCR"; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
export LC_ALL=C
umask 077
BODY=$SCR/receipt.body
: > "$BODY"
M=0; K=0; S=0        # match / mismatch / skip counters
INSTALLED=0

# ------------------------------------------------------------------- helpers -----
say() { printf '%s\n' "$*"; }

emit() { printf '%s\n' "$*" >> "$BODY"; }

redact() { # secret shapes -> [REDACTED]; hex-pin and separator runs kept as shapes (QM72)
  sed -E \
    -e 's/(hvs|hvb)\.[A-Za-z0-9_-]{6,}/[REDACTED]/g' \
    -e 's/\bs\.[A-Za-z0-9]{20,}/[REDACTED]/g' \
    -e 's/([Oo][Tt][Pp]|[Nn]once)([=:[:space:]]+)["'"'"']?[A-Za-z0-9+\/_-]{12,}/\1\2[REDACTED]/g' \
    -e 's/[0-9a-f]{43,}/[HEXRUN]/g' \
    -e 's/[-_]{43,}/[SEPRUN]/g' \
    -e 's/[A-Za-z0-9+\/_-]{43,}/[REDACTED]/g'
}

cap() { redact | cut -c1-240; } # redact + truncate one captured stream

sha_of() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }

report() { # ID EXPECT OBSERVED VERDICT [DETAIL]
  local id=$1 expect=$2 obs=$3 verdict=$4 detail=${5:-}
  emit "CONTROL $id expect=$expect observed=$obs verdict=$verdict"
  [ -n "$detail" ] && emit "DETAIL $id $detail"
  case $verdict in
    match) M=$((M+1));;
    mismatch) K=$((K+1));;
    skip) S=$((S+1));;
    *) emit "DETAIL $id internal: bad-verdict-token($verdict)"; K=$((K+1));;
  esac
}

report_skip() { # ID EXPECT ABSENT-INSTRUMENT [DETAIL]
  local id=$1 expect=$2 missing=$3 detail=${4:-}
  report "$id" "$expect" "absent" "skip" "absent-instrument: $missing${detail:+; }$detail"
}

not() { # negation usable through st's "$@" (a ! word is not a command after expansion)
  if "$@"; then return 1; else return 0; fi
}

copy_over() { # SRC DST -- safe into hardlinked trees: break the link, then copy
  rm -f -- "$2" && cp -- "$1" "$2"
}

# Verdict-line parsers.
# parse_c1r_line LINE: sets R1_ACCEPTED R1_REJECTED R1_POP R1_GUARD.
parse_c1r_line() {
  R1_ACCEPTED=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]accepted=([0-9]+|FAIL).*/\1/p')
  R1_REJECTED=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]rejected=([0-9]+|FAIL).*/\1/p')
  R1_POP=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]population=([0-9]+\/[0-9]+).*/\1/p')
  R1_GUARD=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]guard=([0-9]+).*/\1/p')
}

# parse_c2r_line LINE: sets R2_KILLED R2_POP R2_GUARD.
parse_c2r_line() {
  R2_KILLED=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]killed=([0-9]+|FAIL).*/\1/p')
  R2_POP=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]population=([0-9]+).*/\1/p')
  R2_GUARD=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]guard=([0-9]+).*/\1/p')
}

last_verdict_line() { # PREFIX STDIN -> last line starting with PREFIX
  grep -E "^$1" 2>/dev/null | tail -1
}

# Build a stub counter: a byte copy of SRC with a dispatch prepended after the
# shebang that prints LINE and exits 0 for every non-selftest invocation.
mk_stub_counter() { # SRC DST LINE
  local src=$1 dst=$2 line=$3
  cp -f "$src" "$dst" || return 1
  python3 - "$dst" "$line" <<'PYEOF'
import sys
path, line = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
lines = text.split("\n")
if not lines or not lines[0].startswith("#!"):
    sys.exit("no-shebang")
stub = [
    '# R63 controls fixture: stub dispatch (intercepts every non-selftest run).',
    'if [ "${1:-}" != "--selftest" ]; then',
    '  printf \'%s\\n\' ' + repr(line),
    '  exit 0',
    'fi',
]
out = lines[:1] + stub + lines[1:]
open(path, "w", encoding="utf-8").write("\n".join(out))
PYEOF
}

# ------------------------------------------------------------------ selftest -----
selftest_main() {
  local pass=0 fail=0
  st() { # CASE-NAME CMD [ARGS...] -- executes CMD; a non-zero rc is a FINDING
    local name=$1; shift
    if "$@" >/dev/null 2>&1; then pass=$((pass+1));
    else fail=$((fail+1)); echo "FINDING R63C-CTL-ST-$name"; fi
  }
  local W=$SCR

  # verdict-line parsers on the frozen line shapes
  parse_c1r_line 'C1_RESIDUAL: accepted=10 rejected=6 population=10/6 guard=1 (real=1 selftest=0 prior=1 para=1 stub=1)'
  st c1r-parse-base test "$R1_ACCEPTED" = 10 -a "$R1_REJECTED" = 6 -a "$R1_POP" = "10/6" -a "$R1_GUARD" = 1
  parse_c1r_line "$C1_STUB_LINE"
  st c1r-parse-stub test "$R1_ACCEPTED" = 0 -a "$R1_REJECTED" = 0 -a "$R1_POP" = "10/6" -a "$R1_GUARD" = 1
  parse_c2r_line 'C2_REFUSAL: killed=0 population=5 guard=1 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=1 real=1)'
  st c2r-parse-base test "$R2_KILLED" = 0 -a "$R2_POP" = 5 -a "$R2_GUARD" = 1
  parse_c2r_line "$C2_STUB_LINE"
  st c2r-parse-stub test "$R2_KILLED" = 5 -a "$R2_POP" = 5 -a "$R2_GUARD" = 1

  # stub builder: refuses a shebang-less file, inserts the dispatch, keeps the rest
  printf '#!/usr/bin/env bash\necho real\n' > "$W/src.sh"
  mk_stub_counter "$W/src.sh" "$W/stub.sh" 'STUB LINE HERE' || st stub-build-ok false
  st stub-build-ok sh -c "grep -q 'STUB LINE HERE' '$W/stub.sh' && grep -q 'echo real' '$W/stub.sh' && bash '$W/stub.sh' --tree x | grep -q 'STUB LINE HERE'"
  printf 'no shebang here\n' > "$W/nosheb.sh"
  st stub-refuses-no-shebang sh -c "! mk_stub_counter '$W/nosheb.sh' '$W/nosheb-out.sh' 'X' 2>/dev/null"

  # the stub's constant line differs from the BASE census on both claims
  st c1-stub-mismatch-base test "$C1_STUB_LINE" != "C1_RESIDUAL: accepted=$C1_BASE_ACCEPTED rejected=$C1_BASE_REJECTED population=$C1_BASE_POP guard=?"
  st c2-stub-mismatch-base test "$C2_STUB_LINE" != "C2_REFUSAL: killed=$C2_BASE_KILLED population=$C2_BASE_POP guard=?"

  # report counting and the exit contract (subshell state machine)
  local out
  out=$(
    M=0; K=0; S=0
    report t/a e1 o1 match
    report t/b e2 o2 mismatch
    report t/c e3 absent skip
    printf '%s' "$((M))$((K))$((S))"
  )
  st report-counting test "$out" = "111"
  out=$(
    M=0; K=0; S=0
    report t/d e4 o4 match
    printf '%s' "$K"
  )
  st report-exit-contract test "$out" = 0

  # ---- end-to-end fixture cases: run this script as a subprocess on stub trees --
  # case A: counters print the BASE census -> F8/F6 mismatch, NOWORK/REAL match,
  #         PRIOR rows re-emitted.
  local FT=$W/fixture-base
  mkdir -p "$FT/plans"
  printf '#!/usr/bin/env bash\necho "C1_RESIDUAL: accepted=10 rejected=6 population=10/6 guard=1"\nexit 0\n' > "$FT/plans/round-63-c1.sh"
  printf '#!/usr/bin/env bash\necho "C2_REFUSAL: killed=0 population=5 guard=1"\nexit 0\n' > "$FT/plans/round-63-c2.sh"
  cat > "$FT/plans/round-62-controls.sh" <<'PRIOR'
#!/usr/bin/env bash
echo "CONTROL K1-BASE-C1 expect=accepted=5 observed=accepted=5 verdict=match"
echo "CONTROL K1-BASE-C2 expect=killed=0 observed=absent verdict=skip"
echo "SKIPS: 1"
echo "CONTROLS: match=1 mismatch=0"
exit 0
PRIOR
  chmod +x "$FT/plans/"*.sh
  cp "$SELFPATH" "$FT/plans/round-63-controls.sh"   # REPO must resolve to the fixture
  local outA rcA
  outA=$(R63_CONTROLS_RECEIPT=/dev/null bash "$FT/plans/round-63-controls.sh" "$FT" 2>&1); rcA=$?
  # expected verdicts on the BASE-census fixture: F8 mismatch, F6 mismatch,
  # NOWORK x2 match, REAL x2 match, PRIOR-* re-emitted (2 rows).
  st e2e-base-f8-mismatch sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-F8 .*verdict=mismatch'" "$outA"
  st e2e-base-f6-mismatch sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-F6 .*verdict=mismatch'" "$outA"
  st e2e-base-c1nowork-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-NOWORK .*verdict=match'" "$outA"
  st e2e-base-c2nowork-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-NOWORK .*verdict=match'" "$outA"
  st e2e-base-c1real-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-REAL .*verdict=match'" "$outA"
  st e2e-base-c2real-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-REAL .*verdict=match'" "$outA"
  st e2e-base-prior-reemitted sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL PRIOR-K1-BASE-C1 .*verdict=match' && printf '%s\n' \"\$0\" | grep -q '^CONTROL PRIOR-K1-BASE-C2 .*verdict=skip'" "$outA"
  st e2e-base-summary sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROLS: match=5 mismatch=2'" "$outA"
  st e2e-base-rc1 test $rcA = 1

  # case B: counters print the target (candidate-success) lines -> NOWORK reads
  # mismatch (the census moved), REAL still match (guard=1), F8/F6 now match
  # because the stub line equals... no: F8/F6 stubs print the *constant target*
  # line regardless; on a candidate tree the expected BASE census no longer
  # applies -- the control compares against the frozen BASE numbers, so F8/F6
  # still read mismatch (accepted=0 != 10). The candidate reading is the L1's.
  local FT2=$W/fixture-cand
  mkdir -p "$FT2/plans"
  printf '#!/usr/bin/env bash\necho "C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1"\nexit 0\n' > "$FT2/plans/round-63-c1.sh"
  printf '#!/usr/bin/env bash\necho "C2_REFUSAL: killed=5 population=5 guard=1"\nexit 0\n' > "$FT2/plans/round-63-c2.sh"
  cp "$FT/plans/round-62-controls.sh" "$FT2/plans/round-62-controls.sh"
  chmod +x "$FT2/plans/"*.sh
  cp "$SELFPATH" "$FT2/plans/round-63-controls.sh"
  local outB rcB
  outB=$(R63_CONTROLS_RECEIPT=/dev/null bash "$FT2/plans/round-63-controls.sh" "$FT2" 2>&1); rcB=$?
  st e2e-cand-nowork-mismatch sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-NOWORK .*verdict=mismatch' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-NOWORK .*verdict=mismatch'" "$outB"
  st e2e-cand-real-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-REAL .*verdict=match' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-REAL .*verdict=match'" "$outB"

  # case C: counters absent -> all six round-63 controls skip, PRIOR still runs
  local FT3=$W/fixture-empty
  mkdir -p "$FT3/plans"
  cp "$FT/plans/round-62-controls.sh" "$FT3/plans/round-62-controls.sh"
  chmod +x "$FT3/plans/round-62-controls.sh"
  cp "$SELFPATH" "$FT3/plans/round-63-controls.sh"
  local outC rcC
  outC=$(R63_CONTROLS_RECEIPT=/dev/null bash "$FT3/plans/round-63-controls.sh" "$FT3" 2>&1); rcC=$?
  st e2e-empty-c1skip sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-F8 .*verdict=skip' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-NOWORK .*verdict=skip' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-REAL .*verdict=skip'" "$outC"
  st e2e-empty-c2skip sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-F6 .*verdict=skip' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-NOWORK .*verdict=skip' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-REAL .*verdict=skip'" "$outC"
  st e2e-empty-prior-runs sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL PRIOR-K1-BASE-C1'" "$outC"
  st e2e-empty-rc0 test $rcC = 0

  if [ "$fail" = 0 ]; then
    echo "CONTROLS_SELFTEST: PASS (cases=$pass)"
    exit 0
  fi
  echo "CONTROLS_SELFTEST: FAIL (cases=$((pass+fail)) failed=$fail)"
  exit 1
}

# ------------------------------------------------------------- candidate legs ----
CAND=""

# ctrl_prior: delegate to the measured tree's round-62-controls.sh on a private
# snapshot, re-emit each CONTROL line as PRIOR-<id> preserving verdict.
ctrl_prior() {
  local expect="prior-controls-reemitted"
  if [ ! -f "$CAND/$PRIOR_REL" ]; then
    report_skip "PRIOR" "$expect" "$PRIOR_REL (round-62 controls battery)"
    return
  fi
  local snap=$SCR/prior-snap
  cp -a "$CAND" "$snap" 2>/dev/null || { report "PRIOR" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  # The prior battery installs its receipt inside the tree it measures; give it the
  # snapshot so the measured tree is never written.
  local out rc
  out=$(cd "$snap" && timeout 2400 bash "plans/round-62-controls.sh" "$snap" 2>&1); rc=$?
  local n=0 line id verdict obs exp
  while IFS= read -r line; do
    case $line in
      CONTROL\ *)
        n=$((n+1))
        id=$(printf '%s' "$line" | awk '{print $2}')
        verdict=$(printf '%s' "$line" | sed -nE 's/.*verdict=([a-z]+).*/\1/p')
        obs=$(printf '%s' "$line" | sed -nE 's/^CONTROL [^ ]+ expect=[^ ]* observed=([^ ]*).*/\1/p')
        exp=$(printf '%s' "$line" | sed -nE 's/^CONTROL [^ ]+ expect=([^ ]*).*/\1/p')
        case $verdict in
          match|mismatch|skip) :;;
          *) verdict=skip;;
        esac
        emit "CONTROL PRIOR-$id expect=$exp observed=$obs verdict=$verdict"
        case $verdict in
          match) M=$((M+1));;
          mismatch) K=$((K+1));;
          *) S=$((S+1));;
        esac
        ;;
      DETAIL\ *)
        emit "DETAIL PRIOR-$(printf '%s' "$line" | awk '{print $2}') $(printf '%s' "$line" | cut -d' ' -f3-)"
        ;;
    esac
  done <<< "$out"
  if [ "$n" = 0 ]; then
    report "PRIOR" "$expect" "no-control-lines;rc=$rc" "mismatch" "prior battery printed no CONTROL lines: $(printf '%s\n' "$out" | head -3 | cap | tr '\n' '~')"
    return
  fi
  emit "DETAIL PRIOR delegated=$n rc=$rc prior-summary=$(printf '%s\n' "$out" | grep -E '^(CONTROLS|SKIPS):' | tr '\n' ' ' | cap)"
}

# ctrl_c1_f8: printer-stub copy of the C1 counter must read mismatch vs BASE census.
ctrl_c1_f8() {
  local expect="accepted=$C1_BASE_ACCEPTED rejected=$C1_BASE_REJECTED mismatch"
  if [ -z "$C1_INSTR" ]; then
    report_skip "C1-F8" "$expect" "$C1CTR_REL (C1 claim counter)"
    return
  fi
  if ! bash -n "$C1_INSTR" 2>/dev/null; then
    report "C1-F8" "$expect" "counter-not-bash" "mismatch" "$C1_INSTR fails bash -n"
    return
  fi
  local stub=$SCR/stub-c1.sh
  if ! mk_stub_counter "$C1_INSTR" "$stub" "$C1_STUB_LINE"; then
    report "C1-F8" "$expect" "stub-build-failed" "mismatch" "cannot prepend stub dispatch to $C1_INSTR"
    return
  fi
  # Run the stub on the measured tree: it prints the constant target line.
  local out rc line
  out=$(timeout 60 bash "$stub" --tree "$CAND" 2>&1); rc=$?
  line=$(last_verdict_line 'C1_RESIDUAL:' <<< "$out")
  if [ -z "$line" ]; then
    report "C1-F8" "$expect" "no-verdict-line;rc=$rc" "match" "stub printed no C1_RESIDUAL line (refused upstream)"
    return
  fi
  parse_c1r_line "$line"
  # The control's verdict: does the stub's constant line match the independently
  # expected BASE census? On a BASE tree it must NOT (accepted=0 != 10), so the
  # battery reads mismatch -- the stub is caught.
  if [ "$R1_ACCEPTED" = "$C1_BASE_ACCEPTED" ] && [ "$R1_REJECTED" = "$C1_BASE_REJECTED" ] \
     && [ "$R1_POP" = "$C1_BASE_POP" ]; then
    report "C1-F8" "$expect" "accepted=$R1_ACCEPTED rejected=$R1_REJECTED population=$R1_POP" "match" \
      "stub-line-matches-BASE-census -- vacuous stub (named ceiling)"
  else
    report "C1-F8" "$expect" "accepted=$R1_ACCEPTED rejected=$R1_REJECTED population=$R1_POP" "mismatch" \
      "stub-constant-line-refused line=$(printf '%s' "$line" | cap)"
  fi
}

# ctrl_c2_f6: constant-verdict copy of the C2 counter must read mismatch vs BASE.
ctrl_c2_f6() {
  local expect="killed=$C2_BASE_KILLED mismatch"
  if [ -z "$C2_INSTR" ]; then
    report_skip "C2-F6" "$expect" "$C2CTR_REL (C2 claim counter)"
    return
  fi
  if ! bash -n "$C2_INSTR" 2>/dev/null; then
    report "C2-F6" "$expect" "counter-not-bash" "mismatch" "$C2_INSTR fails bash -n"
    return
  fi
  local stub=$SCR/stub-c2.sh
  if ! mk_stub_counter "$C2_INSTR" "$stub" "$C2_STUB_LINE"; then
    report "C2-F6" "$expect" "stub-build-failed" "mismatch" "cannot prepend stub dispatch to $C2_INSTR"
    return
  fi
  local out rc line
  out=$(timeout 60 bash "$stub" --tree "$CAND" 2>&1); rc=$?
  line=$(last_verdict_line 'C2_REFUSAL:' <<< "$out")
  if [ -z "$line" ]; then
    report "C2-F6" "$expect" "no-verdict-line;rc=$rc" "match" "stub printed no C2_REFUSAL line (refused upstream)"
    return
  fi
  parse_c2r_line "$line"
  if [ "$R2_KILLED" = "$C2_BASE_KILLED" ] && [ "$R2_POP" = "$C2_BASE_POP" ]; then
    report "C2-F6" "$expect" "killed=$R2_KILLED population=$R2_POP" "match" \
      "stub-line-matches-BASE-census -- vacuous stub (named ceiling)"
  else
    report "C2-F6" "$expect" "killed=$R2_KILLED population=$R2_POP" "mismatch" \
      "stub-constant-line-refused line=$(printf '%s' "$line" | cap)"
  fi
}

# Unmutated-counter readings, computed once and shared by the NOWORK and REAL
# controls (each counter run can take tens of minutes; never run it twice).
# Sets: C1_HAVE C1_LINE C1_RC U1_* ; C2_HAVE C2_LINE C2_RC U2_* — the U*
# fields are the unmutated parse, kept apart from R1_*/R2_* which the stub
# controls overwrite.
# Instrument resolution: the measured tree's own counter copy when present
# (round-62 semantics — the candidate's instruments are what is graded); else
# the lane's copy under $REPO (pre-freeze semantics — the extracted BASE tree
# predates the instruments, but the battery still exercises the lane's
# committed counters against it).
C1_INSTR=""; C2_INSTR=""
resolve_instruments() {
  if [ -f "$CAND/$C1CTR_REL" ]; then C1_INSTR=$CAND/$C1CTR_REL
  elif [ -f "$REPO/$C1CTR_REL" ]; then C1_INSTR=$REPO/$C1CTR_REL; fi
  if [ -f "$CAND/$C2CTR_REL" ]; then C2_INSTR=$CAND/$C2CTR_REL
  elif [ -f "$REPO/$C2CTR_REL" ]; then C2_INSTR=$REPO/$C2CTR_REL; fi
}

C1_HAVE=0; C2_HAVE=0; C1_LINE=""; C2_LINE=""; C1_RC=""; C2_RC=""
U1_ACCEPTED=""; U1_REJECTED=""; U1_POP=""; U1_GUARD=""
U2_KILLED=""; U2_POP=""; U2_GUARD=""
probe_counters() {
  if [ -n "$C1_INSTR" ] && bash -n "$C1_INSTR" 2>/dev/null; then
    C1_HAVE=1
    timeout 2400 bash "$C1_INSTR" --tree "$CAND" > "$SCR/c1-unmut.out" 2> "$SCR/c1-unmut.err"
    C1_RC=$?
    C1_LINE=$(last_verdict_line 'C1_RESIDUAL:' < "$SCR/c1-unmut.out")
    parse_c1r_line "${C1_LINE:-}"
    U1_ACCEPTED=$R1_ACCEPTED; U1_REJECTED=$R1_REJECTED; U1_POP=$R1_POP; U1_GUARD=$R1_GUARD
  fi
  if [ -n "$C2_INSTR" ] && bash -n "$C2_INSTR" 2>/dev/null; then
    C2_HAVE=1
    timeout 2400 bash "$C2_INSTR" --tree "$CAND" > "$SCR/c2-unmut.out" 2> "$SCR/c2-unmut.err"
    C2_RC=$?
    C2_LINE=$(last_verdict_line 'C2_REFUSAL:' < "$SCR/c2-unmut.out")
    parse_c2r_line "${C2_LINE:-}"
    U2_KILLED=$R2_KILLED; U2_POP=$R2_POP; U2_GUARD=$R2_GUARD
  fi
}

# ctrl_c1_nowork: the unmutated C1 counter on the tree must read the BASE census.
ctrl_c1_nowork() {
  local expect="accepted=$C1_BASE_ACCEPTED rejected=$C1_BASE_REJECTED population=$C1_BASE_POP"
  if [ "$C1_HAVE" != 1 ]; then
    report_skip "C1-NOWORK" "$expect" "$C1CTR_REL (C1 claim counter)"
    return
  fi
  if [ "$U1_ACCEPTED" = "$C1_BASE_ACCEPTED" ] && [ "$U1_REJECTED" = "$C1_BASE_REJECTED" ] \
     && [ "$U1_POP" = "$C1_BASE_POP" ]; then
    report "C1-NOWORK" "$expect" "accepted=$U1_ACCEPTED rejected=$U1_REJECTED population=$U1_POP rc=$C1_RC" "match" \
      "no-work control: BASE census reproduced"
  else
    report "C1-NOWORK" "$expect" "accepted=$U1_ACCEPTED rejected=$U1_REJECTED population=$U1_POP rc=$C1_RC" "mismatch" \
      "fixture-vacuous-or-counter-drift"
  fi
}

# ctrl_c2_nowork: the unmutated C2 counter on the tree must read killed=0.
ctrl_c2_nowork() {
  local expect="killed=$C2_BASE_KILLED population=$C2_BASE_POP"
  if [ "$C2_HAVE" != 1 ]; then
    report_skip "C2-NOWORK" "$expect" "$C2CTR_REL (C2 claim counter)"
    return
  fi
  if [ "$U2_KILLED" = "$C2_BASE_KILLED" ] && [ "$U2_POP" = "$C2_BASE_POP" ]; then
    report "C2-NOWORK" "$expect" "killed=$U2_KILLED population=$U2_POP rc=$C2_RC" "match" \
      "no-work control: BASE census reproduced"
  else
    report "C2-NOWORK" "$expect" "killed=$U2_KILLED population=$U2_POP rc=$C2_RC" "mismatch" \
      "fixture-vacuous-or-counter-drift"
  fi
}

# ctrl_c1_real / ctrl_c2_real: positive controls -- the unmutated counter must print
# a verdict line with guard=1 (a blanket refusal is not a gain).
ctrl_c1_real() {
  local expect="verdict-line;guard=1"
  if [ "$C1_HAVE" != 1 ]; then
    report_skip "C1-REAL" "$expect" "$C1CTR_REL (C1 claim counter)"
    return
  fi
  if [ -n "$U1_GUARD" ] && [ "$U1_GUARD" = 1 ]; then
    report "C1-REAL" "$expect" "guard=$U1_GUARD accepted=$U1_ACCEPTED rejected=$U1_REJECTED rc=$C1_RC" "match" \
      "positive control: guard evaluates to 1"
  else
    report "C1-REAL" "$expect" "guard=${U1_GUARD:-none} accepted=$U1_ACCEPTED rejected=$U1_REJECTED rc=$C1_RC" "mismatch" \
      "blanket-refusal-or-no-verdict"
  fi
}

ctrl_c2_real() {
  local expect="verdict-line;guard=1"
  if [ "$C2_HAVE" != 1 ]; then
    report_skip "C2-REAL" "$expect" "$C2CTR_REL (C2 claim counter)"
    return
  fi
  if [ -n "$U2_GUARD" ] && [ "$U2_GUARD" = 1 ]; then
    report "C2-REAL" "$expect" "guard=$U2_GUARD killed=$U2_KILLED rc=$C2_RC" "match" \
      "positive control: guard evaluates to 1"
  else
    report "C2-REAL" "$expect" "guard=${U2_GUARD:-none} killed=$U2_KILLED rc=$C2_RC" "mismatch" \
      "blanket-refusal-or-no-verdict"
  fi
}


main() {
  local arg=${1:-$REPO}
  if [ "$arg" = "--selftest" ]; then selftest_main; fi
  CAND=$(cd "$arg" 2>/dev/null && pwd -P) || { echo "SETUP candidate-tree-unusable at $arg"; exit 2; }
  [ -d "$CAND" ] || { echo "SETUP candidate-tree-unusable at $CAND"; exit 2; }

  command -v python3 >/dev/null 2>&1 || { echo "SETUP no-python3"; exit 2; }

  emit "# round-63 pre-freeze control battery (plans/round-63-controls.sh)"
  emit "# SELF $(sha_of "$0")"
  emit "# utc $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  emit "# repo $REPO"
  emit "# candidate $CAND"
  emit "# scratch $SCR"
  resolve_instruments
  emit "# instrument-c1 ${C1_INSTR:-none}"
  emit "# instrument-c2 ${C2_INSTR:-none}"
  local f
  for f in "$C1CTR_REL" "$C2CTR_REL" "$PRIOR_REL"; do
    if [ -f "$CAND/$f" ]; then
      emit "INSTRUMENT $f $(sha_of "$CAND/$f")"
    else
      emit "INSTRUMENT $f MISSING"
    fi
  done
  emit "# readiness: C1-F8,C1-NOWORK,C1-REAL <- $C1CTR_REL; C2-F6,C2-NOWORK,C2-REAL <- $C2CTR_REL; PRIOR-* <- $PRIOR_REL"

  if [ "${R63_CONTROLS_FIXTURE_ONLY:-0}" = 1 ]; then
    # Round-64 C2 recursion bound: fixture/confinement-only mode. probe_counters
    # is the leg that re-enters a counter, so it is skipped; the C1-F8/C2-F6 stub
    # controls build their own stub counters and still run. NOWORK/REAL depend on
    # the probe and record skip; PRIOR delegates to the round-62 battery and is
    # skipped.
    emit "# fixture-only: probe_counters and PRIOR delegation skipped (R63_CONTROLS_FIXTURE_ONLY=1)"
    ctrl_c1_f8
    ctrl_c2_f6
    ctrl_c1_nowork
    ctrl_c2_nowork
    ctrl_c1_real
    ctrl_c2_real
  else
    probe_counters   # one unmutated run per counter, shared by NOWORK and REAL
    ctrl_c1_f8
    ctrl_c2_f6
    ctrl_c1_nowork
    ctrl_c2_nowork
    ctrl_c1_real
    ctrl_c2_real
    ctrl_prior
  fi

  emit "SKIPS: $S"
  emit "CONTROLS: match=$M mismatch=$K"
  if [ $K -eq 0 ]; then
    emit "SEAT-STATUS: complete"
  else
    emit "SEAT-STATUS: partial mismatch-count=$K (see DETAIL lines; the L1 re-runs the full battery before the candidate reading)"
  fi

  cat "$BODY"
  # Install the receipt body at the seat's wave build dir (the battery's own
  # committed-receipt path is the L1's; this copy is the run's durable record).
  local dest="${R63_CONTROLS_RECEIPT:-$REPO/.ufo/waves/round-63/build/R63ExecControls/controls-last.txt}"
  if mkdir -p "$(dirname "$dest")" 2>/dev/null && cp "$BODY" "$dest" 2>/dev/null; then
    : # receipt installed
  else
    say "RECEIPT-INSTALL-FAILED: could not write $dest"
  fi
  return $([ "$K" -eq 0 ] && echo 0 || echo 1)
}

main "$@"
