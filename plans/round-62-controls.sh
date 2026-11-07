#!/usr/bin/env bash
# plans/round-62-controls.sh -- pre-freeze control battery for round 62 (kagi).
#   usage: bash plans/round-62-controls.sh [CANDIDATE_TREE]   (default: this lane's working tree)
#          bash plans/round-62-controls.sh --selftest         (fixture-driven; no instruments, no bao)
#
# Declared by plans/round-62.md sections C1 and C2 (frozen, commit 8e5463c) and the
# round-62 wave dispatch. 14 control lines in one receipt; K1-BASE is split into its
# two claim legs because they exercise different instruments.
#
# Control map (id -> expectation -> instrument):
#   K1-BASE-C1  the do-nothing control: the five frozen bypass fixtures B3..B7 applied
#               each to a copy of the BASE extraction (60b5b7b6) must each read
#               `value=0` on the BASE tree's own checker bytes
#               (plans/round-61-c1-check.py, `python3 -I -B ... --root <copy> --repo
#               <lane> --no-challenge`), i.e. accepted=5; any lower reading means a
#               fixture is vacuous and voids the claim (frozen kill rule C1-K1).
#               Independently derived here from the frozen plan's fixture table -- it
#               does not run the claim counter, so it stays runnable even before the
#               round-62 instruments land.
#   K1-BASE-C2  the do-nothing control for C2: on the BASE counter bytes
#               (plans/round-61-c2.sh at 60b5b7b6) the two reviewer mutations must
#               SURVIVE -- M-A (main aggregation replaced by the constant `value=5`)
#               and M-B (shim aggregation made unconditional, `shims_ok=5`) each keep
#               `--selftest` at rc 0 printing `C2_SELFTEST: PASS (cases=11)` -- and
#               the G challenge (a trial stub that prints no expected observable) must
#               NOT fire: the BASE counter reads guard=1 on the stub-trial tree
#               (frozen census: killed=0).
#   C1-F1..F5   bypass fixture Bk applied to the candidate tree; the hardened checker
#               must reject the forgery: value=1 with exactly item I(k) unresolved
#               (frozen kill rule C1-K2 "must read exactly 1"; the assignment's
#               shorthand `value>=1` is tightened to the frozen `exactly 1`, and a
#               reading >1 is a real finding for the L1). Anchor count in the measured
#               tree must be exactly 1 (0 or >1 fails closed, frozen fixture rule).
#   C1-F6       a stub-checker tree (candidate copy whose plans/round-61-c1-check.py
#               is the printer stub that always prints value=0 -- the same stub shape
#               the BASE checker defines for its own challenge leg) measured by the
#               candidate's plans/round-62-c1.sh: the counter prints no `C1_BYPASS:`
#               verdict line and exits non-zero (frozen guard leg (c) / kill rule
#               C1-K3). A clean-tree pre-leg requires the counter to print a verdict
#               line on the unstubbed tree, so a SETUP for an unrelated reason cannot
#               masquerade as refusal.
#   C1-F7       the three paraphrase fixtures P3, P4, P5 each applied to the candidate
#               tree must each still read value=0 (frozen guard leg (d) / kill rule
#               C1-K4: benign rewording is not a defect).
#   C2-F1 (M-A) the candidate counter (plans/round-61-c2.sh) with the block between
#               its `# BEGIN-DECIDE` and `# END-DECIDE` markers replaced by `  echo 5`
#               must make `--selftest` exit non-zero printing a named FINDING.
#   C2-F2 (M-B) the same with the `# BEGIN-SHIMS` / `# END-SHIMS` block replaced by
#               `  shims_ok=5`: selftest non-zero with a named FINDING.
#   C2-F3 (G)   a tree whose trial file is a valid-sha256 stub that prints no expected
#               observable must read guard=0 on the unmutated candidate counter
#               (the guard distinguishes "evaluated and failed" from "could not
#               evaluate"; at BASE this reads guard=1 -- the defect).
#   C2-F4       the real trial on the candidate tree: the counter reads
#               value=5 shims=5 vectors=ok/5 (frozen guard leg (b) / kill rule C2-K4:
#               the hardening may not weaken the gate). Needs the pinned bao binary
#               (SETUP/skip otherwise).
#   C2-F5       a constant-verdict counter copy (selftest stubbed to print
#               `C2_SELFTEST: PASS (cases=17)` without executing the aggregation,
#               inserted before the real selftest dispatch) measured by the
#               candidate's plans/round-62-c2.sh wrapper must be refused: guard=0
#               there while the same wrapper on the clean candidate tree reads
#               guard=1 (differential, so a red claim leg cannot satisfy the refusal
#               expectation vacuously). Frozen guard leg (c).
#
# Readiness probes (skip discipline): a control that names an instrument which is not
# yet present records `CONTROL <id> ... observed=absent verdict=skip` naming the
# absent instrument; the L1 re-runs the full battery before the candidate reading.
#   - C1-F1..F5, C1-F7 need the hardened checker: floor probe = the checker's
#     `--selftest` exits 0 printing `C1_CHECK_SELFTEST: PASS` with cases >= 57
#     (frozen guard leg (b); the BASE checker prints 52 cases, so the floor
#     discriminates hardened bytes from BASE bytes).
#   - C2-F1..F4 need the hardened counter: floor probe = the counter's `--selftest`
#     exits 0 printing `C2_SELFTEST: PASS` with cases >= 17 (frozen guard leg (a);
#     the BASE counter prints 11).
#   - C1-F6 needs plans/round-62-c1.sh; C2-F5 needs plans/round-62-c2.sh plus the
#     counter floor.
#   - K1-BASE-* need only the BASE extraction (the G sub-leg of K1-BASE-C2 needs the
#     pinned bao binary because the BASE counter SETUPs without it).
#
# Fixture source: the anchor->replacement tables are embedded verbatim from
# plans/round-62.md sections C1 (bypass B3..B7, paraphrase P3..P5). The battery owns
# none of the claimed work: every number is derived at run time from the BASE
# extraction, the candidate snapshot, or the frozen plan's own literals. The fixtures
# are applied with a byte-exact single-replacement helper that counts occurrences and
# fails closed on 0 or >1. Every forged copy is isolated: before each fixture the
# battery resets all three fixture-carrier files (plans/round-60.md,
# corpus/lessons/round-60.md, LOG.md) from the clean snapshot, so each control
# measures exactly clean-tree-plus-one-fixture and no residue can couple items.
#
# BASE byte pins (measured 2026-11-07 from 60b5b7b6; the needles for K1-BASE-C2 are
# byte literals valid only against these pins -- a pin mismatch fails K1 closed):
#   plans/round-61-c1-check.py  d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812
#   plans/round-61-c2.sh        c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6
#
# Discipline: everything runs on copies under ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/
# kagi-r62/R62ExecControls/battery.$$ and is removed on exit; TMPDIR points into the
# scratch; umask 077; no /tmp evidence. No git/jj mutation anywhere: the BASE tree is
# materialized read-only with `git archive | tar -x`; the only other git use is
# read-only derivation by the checker itself (--repo). Nothing is written inside a
# measured tree (candidate legs measure a private snapshot copy; C2-F4 measures the
# candidate in place, which the counter's contract keeps read-only). Every line
# captured from an instrument is redacted to shape before it reaches the receipt
# (QM72): hvs./hvb./s.-tokens, OTP/nonce values and 43+-char mixed runs become
# [REDACTED]; pure-hex 43+ runs (sha256 pins) and pure dash/underscore separator runs
# are kept as named shapes, mirroring the counter's own secret-scan exceptions.
# Receipt: the battery's stdout is installed at
#   .ufo/waves/round-62/controls/controls-prefreeze.txt
# every run (last run wins), preceded by INSTRUMENT/BAO pin lines (MISSING when not
# on disk). Exit 0 iff mismatch=0 (skips are recorded, not mismatches).
set -u -o pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=60b5b7b60b76629633110a5b4adac883193c8b2a
CTLDIR_REL=.ufo/waves/round-62/controls
RECEIPT_REL=$CTLDIR_REL/controls-prefreeze.txt
C1CHECK_REL=plans/round-61-c1-check.py
C2COUNT_REL=plans/round-61-c2.sh
C1CTR_REL=plans/round-62-c1.sh
C2WRAP_REL=plans/round-62-c2.sh
TRIAL_REL=corpus/openbao-seal-trial.sh
BAO_BIN="${R61_BAO:-$HOME/.local/bin/bao}"
PIN_BASE_C1CHECK=d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812
PIN_BASE_C2COUNT=c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6
C1_SELFTEST_FLOOR=57   # frozen C1 guard leg (b)
C2_SELFTEST_FLOOR=17   # frozen C2 guard leg (a)
BASE_C2_CASES=11       # frozen C2 BASE census
SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ExecControls

# Frozen fixture table (plans/round-62.md section C1). Fields: id|file|item|anchor|replacement.
# B rows carry the checker item the forgery targets (the frozen one-per-item pairing).
FIXTURES=(
  "B3|plans/round-60.md|3|**A3 item 2 is withdrawn**|**A3 item 2 is not withdrawn**"
  "B4|corpus/lessons/round-60.md|4|the round introduced three new record defects it did not route|the round introduced no three new record defects it did not route"
  "B5|LOG.md|5|it was rewritten in place at|it was not rewritten in place at"
  "B6|corpus/lessons/round-60.md|6|the lane was progressing, not stale.|the paragraph's times are correct."
  "B7|corpus/lessons/round-60.md|7|so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %|so the literal reading is 3/16 = 25 %, and counting the sentinel as an attack seat gives 4/16 = 18.75 %"
  "P3|plans/round-60.md||**A3 item 2 is withdrawn**|**A3 item 2 is hereby withdrawn**"
  "P4|corpus/lessons/round-60.md||the round introduced three new record defects it did not route|this round did introduce three new record defects it did not route"
  "P5|LOG.md||it was rewritten in place at|it was rewritten in place, at"
)
# Byte-literal needles for the BASE reviewer mutations (valid against PIN_BASE_C2COUNT).
NEEDLE_MA='value=0
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] \
  && [ "$selftest_ok" = 1 ] && [ "$ops_ok" = 1 ] && [ "$t2_ok" = 1 ] && value=5'
REPL_MA='value=5'
NEEDLE_MB='shims_ok=0
for n in 1 2 3 4 5; do
  [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] \
    && broken41 "${OUT[sh$n]}" && shims_ok=$((shims_ok+1))
done'
REPL_MB='shims_ok=5'
STUB_PASS_LINE='C2_SELFTEST: PASS (cases=17)'

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
    -e 's/([Oo][Tt][Pp]|[Nn]once)([=:[:space:]]+)["'"'"']?[A-Za-z0-9+\/=_-]{12,}/\1\2[REDACTED]/g' \
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

# Byte-exact single replacement / block replacement / marker insert (fails closed).
mk_apply_helper() { # DST
  cat > "$1" <<'APEOF'
import json, sys
spec = json.load(open(sys.argv[1], encoding="utf-8"))
mode = spec.get("mode", "literal")
if mode == "block":
    text = open(spec["file"], encoding="utf-8").read()
    lines = text.split("\n")
    ib = [i for i, l in enumerate(lines) if spec["begin"] in l]
    ie = [i for i, l in enumerate(lines) if spec["end"] in l]
    if len(ib) != 1 or len(ie) != 1 or ie[0] <= ib[0]:
        print(f"markers begin={len(ib)} end={len(ie)}")
        sys.exit(1)
    out = lines[:ib[0] + 1] + spec["body"].split("\n") + lines[ie[0]:]
    open(spec["file"], "w", encoding="utf-8").write("\n".join(out))
    print("ok")
    sys.exit(0)
if mode == "insert-after-shebang":
    text = open(spec["file"], encoding="utf-8").read()
    lines = text.split("\n")
    if not lines[0].startswith("#!"):
        print("no-shebang")
        sys.exit(1)
    out = lines[:1] + spec["body"].split("\n") + lines[1:]
    open(spec["file"], "w", encoding="utf-8").write("\n".join(out))
    print("ok")
    sys.exit(0)
data = open(spec["file"], "rb").read()
anchor = spec["anchor"].encode("utf-8")
n = data.count(anchor)
if n != 1:
    print(n)
    sys.exit(1)
repl = spec["repl"].encode("utf-8")
open(spec["file"], "wb").write(data.replace(anchor, repl, 1))
print(1)
APEOF
}

apply_spec() { # SPEC-PY JSON-FILE -> stdout count|marker-info, rc 0 iff applied
  python3 "$1" "$2"
}

not() { # negation usable through st's "$@" (a ! word is not a command after expansion)
  if "$@"; then return 1; else return 0; fi
}

copy_over() { # SRC DST -- safe into hardlinked trees: break the link, then copy
  rm -f -- "$2" && cp -- "$1" "$2"
}

restore_fixture_files() { # WORKROOT CLEANROOT -- reset every fixture-carrier file
  local f
  for f in plans/round-60.md corpus/lessons/round-60.md LOG.md; do
    copy_over "$2/$f" "$1/$f"
  done
}

# Verdict-line parsers. parse_c1_line LINE: sets V1_VALUE V1_POP V1_GUARD V1_ITEMS.
parse_c1_line() {
  V1_VALUE=""; V1_POP=""; V1_GUARD=""; V1_ITEMS=""
  V1_VALUE=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]value=([0-9]+|FAIL).*/\1/p')
  V1_POP=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]population=([0-9]+).*/\1/p')
  V1_GUARD=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]guard=([0-9]+).*/\1/p')
  local k acc="" tok
  for k in 1 2 3 4 5 6 7; do
    tok=$(printf '%s\n' "$1" | sed -nE "s/.*[[:space:]]i$k=([01]).*/\1/p")
    acc="$acc i$k=${tok:-?}"
  done
  V1_ITEMS="$acc"
}

# parse_c2_line LINE: sets V2_VALUE V2_SHIMS V2_VEC V2_GUARD V2_KILLED.
parse_c2_line() {
  V2_VALUE=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]value=([0-9]+|FAIL).*/\1/p')
  V2_SHIMS=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]shims=([0-9]+).*/\1/p')
  V2_VEC=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]vectors=([^[:space:]]+).*/\1/p')
  V2_GUARD=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]guard=([0-9]+).*/\1/p')
  V2_KILLED=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]killed=([0-9]+).*/\1/p')
}

last_c2_guard_line() { # stdin -> the last captured line carrying a guard= token
  grep -E 'guard=[0-9]' 2>/dev/null | tail -1
}

# C1 checker measurement: c1_measure CHECKER ROOT -> sets C1RC and, via
# parse_c1_line, V1_VALUE V1_POP V1_GUARD V1_ITEMS (V1_VALUE=noline when the
# checker printed no verdict line).
c1_measure() {
  timeout 120 python3 -I -B "$1" --root "$2" --repo "$REPO" --no-challenge \
    > "$SCR/c1-measure.out" 2> "$SCR/c1-measure.out.err"
  C1RC=$?
  local line; line=$(grep '^C1_ROUTED:' "$SCR/c1-measure.out" 2>/dev/null | tail -1)
  if [ -z "$line" ]; then
    V1_VALUE=noline; V1_POP=""; V1_GUARD=""; V1_ITEMS=""
    return
  fi
  parse_c1_line "$line"
}

# BASE extraction (read-only) into $1; verifies the pinned instrument bytes.
extract_base() { # DST -> rc 0 ok
  mkdir -p "$1"
  git -C "$REPO" archive "$BASE" 2>/dev/null | tar -x -C "$1" 2>/dev/null || return 1
  [ -f "$1/$C1CHECK_REL" ] && [ -f "$1/$C2COUNT_REL" ] || return 1
  [ "$(sha_of "$1/$C1CHECK_REL")" = "$PIN_BASE_C1CHECK" ] || return 1
  [ "$(sha_of "$1/$C2COUNT_REL")" = "$PIN_BASE_C2COUNT" ] || return 1
  return 0
}

# Stub trial: valid sha256, prints no expected observable (no TRIAL lines, no
# summary, no SEAL_SELFTEST line, no bao exec) -- the G challenge fixture.
mk_stub_trial() { # DST
  mkdir -p "$(dirname "$1")"
  cat > "$1" <<'STUBEOF'
#!/usr/bin/env bash
# R62 controls fixture (G): a valid-sha256 trial stub that prints no expected
# observable. The counter's guard must read observables, not captured rcs.
exit 0
STUBEOF
  chmod +x "$1"
}

# Stub checker: always prints the accept-everything verdict line (the same stub
# shape the BASE checker defines for its own challenge leg).
mk_stub_checker() { # DST
  cat > "$1" <<'CHKSTUBEOF'
print("C1_ROUTED: value=0 population=7 "
      "i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")
CHKSTUBEOF
}

# ------------------------------------------------------------------ selftest -----
selftest_main() {
  local pass=0 fail=0
  st() { # CASE-NAME CMD [ARGS...] -- executes CMD; a non-zero rc is a FINDING
    local name=$1; shift
    if "$@" >/dev/null 2>&1; then pass=$((pass+1));
    else fail=$((fail+1)); echo "FINDING R62C-CTL-ST-$name"; fi
  }
  local W=$SCR
  mk_apply_helper "$W/apply.py"

  # redaction: mixed 43+ runs collapse; pure-hex runs keep only their shape
  local r1 r2
  r1=$(printf 'token XyZ123abcD456efG789hI012jK345lmN789opQr12gXyZ end' | redact)
  st redact-mixed-run test "$r1" = "token [REDACTED] end"
  r2=$(printf 'pin 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788 end' | redact)
  st redact-hex-pin-shape test "$r2" = "pin [HEXRUN] end"

  # fixture table shape and the frozen B-id -> item pairing
  tshape() {
    [ "${#FIXTURES[@]}" = 8 ] || return 1
    local ids="" row id
    for row in "${FIXTURES[@]}"; do
      id=${row%%|*}
      case " $ids " in *" $id "*) return 1;; esac
      ids="$ids $id"
      [ "$(printf '%s' "$row" | awk -F'|' '{print NF}')" = 5 ] || return 1
      [ -n "$(printf '%s' "$row" | awk -F'|' '{print $3,$4,$5}')" ] || return 1
    done
    for id in B3 B4 B5 B6 B7 P3 P4 P5; do
      case " $ids " in *" $id "*) :;; *) return 1;; esac
    done
    return 0
  }
  st fixture-table-shape tshape
  tpair() {
    local row id item
    for row in "${FIXTURES[@]}"; do
      case $row in P*) continue;; esac
      id=${row%%|*}; item=$(printf '%s' "$row" | awk -F'|' '{print $3}')
      [ "$id" = "B$item" ] || return 1
    done
    return 0
  }
  st fixture-item-pairing tpair

  # anchor counting fails closed on 2 occurrences and applies exactly once on 1
  printf 'x ANCHOR y ANCHOR z\n' > "$W/two.txt"
  printf '{"file":"%s/two.txt","anchor":"ANCHOR","repl":"REPL"}\n' "$W" > "$W/two.json"
  st anchor-count-refuses-two not apply_spec "$W/apply.py" "$W/two.json"
  printf 'x ANCHOR y\n' > "$W/one.txt"
  printf '{"file":"%s/one.txt","anchor":"ANCHOR","repl":"REPL"}\n' "$W" > "$W/one.json"
  st anchor-applies-once sh -c "[ \"\$(python3 '$W/apply.py' '$W/one.json')\" = 1 ] && grep -q 'x REPL y' '$W/one.txt'"

  # marker block replacement keeps the markers and replaces only between them
  {
    echo '#!/usr/bin/env bash'
    echo '# BEGIN-DECIDE'
    echo 'old stuff'
    echo '# END-DECIDE'
    echo 'tail'
  } > "$W/blk.sh"
  printf '{"file":"%s/blk.sh","mode":"block","begin":"# BEGIN-DECIDE","end":"# END-DECIDE","body":"  echo 5"}\n' "$W" > "$W/blk.json"
  st marker-block-replace sh -c "python3 '$W/apply.py' '$W/blk.json' >/dev/null && test \"\$(grep -c 'BEGIN-DECIDE' '$W/blk.sh')\" = 1 && grep -q '^  echo 5\$' '$W/blk.sh' && ! grep -q 'old stuff' '$W/blk.sh'"

  # C1 verdict-line parsing (clean, FAIL token, guard, item vector)
  parse_c1_line 'C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0'
  st c1-parse-clean test "$V1_VALUE" = 0 -a "$V1_POP" = 7 -a "$V1_GUARD" = 0 -a "$V1_ITEMS" = " i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1"
  parse_c1_line 'C1_ROUTED: value=FAIL population=7 i1=0 guard=0'
  st c1-parse-fail-token test "$V1_VALUE" = FAIL

  # finding naming: a bare FINDING is not a named one
  st finding-named-recognized sh -c "printf 'FINDING R62-C2-ST-7 decide constant\n' | grep -Eq 'FINDING[[:space:]]+[A-Za-z0-9._-]+'"
  st bare-finding-not-named sh -c "! printf 'FINDING\n' | grep -Eq 'FINDING[[:space:]]+[A-Za-z0-9._-]+'"

  # C2 verdict-line parsing
  parse_c2_line 'C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 stubctl=1 trial=[HEXRUN] cases=63)'
  st c2-parse-clean test "$V2_VALUE" = 5 -a "$V2_SHIMS" = 5 -a "$V2_VEC" = "ok/5" -a "$V2_GUARD" = 1

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

  if [ "$fail" = 0 ]; then
    echo "CONTROLS_SELFTEST: PASS (cases=$pass)"
    exit 0
  fi
  echo "CONTROLS_SELFTEST: FAIL (cases=$((pass+fail)) failed=$fail)"
  exit 1
}

# ------------------------------------------------------------- readiness probes --
# Sets: RD_C1CHK (ready|absent) RD_C1CHK_CASES RD_C1CHK_DET
#       RD_C2CNT (ready|absent) RD_C2CNT_CASES RD_C2CNT_DET
#       RD_C1CTR (present|absent) RD_C2WRAP (present|absent)
run_probes() {
  RD_C1CHK=absent; RD_C1CHK_CASES=""; RD_C1CHK_DET="checker-selftest-failed"
  RD_C2CNT=absent; RD_C2CNT_CASES=""; RD_C2CNT_DET="counter-selftest-failed"
  RD_C1CTR=absent; RD_C2WRAP=absent
  if [ -f "$CAND/$C1CHECK_REL" ]; then
    local out rc cases
    out=$(timeout 180 python3 -I -B "$CAND/$C1CHECK_REL" --selftest 2>&1); rc=$?
    cases=$(printf '%s\n' "$out" | sed -nE 's/.*C1_CHECK_SELFTEST: PASS \((cases=)?([0-9]+).*/\2/p' | tail -1)
    if [ $rc = 0 ] && [ -n "$cases" ] && [ "$cases" -ge "$C1_SELFTEST_FLOOR" ] 2>/dev/null; then
      RD_C1CHK=ready; RD_C1CHK_CASES=$cases; RD_C1CHK_DET="ok"
    else
      RD_C1CHK_DET="selftest-rc=$rc cases=${cases:-none} floor=$C1_SELFTEST_FLOOR"
    fi
  else
    RD_C1CHK_DET="file-missing"
  fi
  if [ -f "$CAND/$C2COUNT_REL" ]; then
    local out rc cases
    out=$(timeout 180 bash "$CAND/$C2COUNT_REL" --selftest 2>&1); rc=$?
    cases=$(printf '%s\n' "$out" | sed -nE 's/.*C2_SELFTEST: PASS \((cases=)?([0-9]+).*/\2/p' | tail -1)
    if [ $rc = 0 ] && [ -n "$cases" ] && [ "$cases" -ge "$C2_SELFTEST_FLOOR" ] 2>/dev/null; then
      RD_C2CNT=ready; RD_C2CNT_CASES=$cases; RD_C2CNT_DET="ok"
    else
      RD_C2CNT_DET="selftest-rc=$rc cases=${cases:-none} floor=$C2_SELFTEST_FLOOR"
    fi
  else
    RD_C2CNT_DET="file-missing"
  fi
  if [ -f "$CAND/$C1CTR_REL" ] && bash -n "$CAND/$C1CTR_REL" 2>/dev/null; then
    RD_C1CTR=present
  fi
  if [ -f "$CAND/$C2WRAP_REL" ] && bash -n "$CAND/$C2WRAP_REL" 2>/dev/null; then
    RD_C2WRAP=present
  fi
}

# ----------------------------------------------------------------- BASE legs -----
ctrl_k1_base_c1() { # independent BASE census over the five bypass fixtures
  local accepted=0 detail="" row id rel item anchor repl count val part
  local bw=$SCR/work-base
  cp -al "$SCR/base" "$bw" 2>/dev/null || { rm -rf "$bw"; cp -a "$SCR/base" "$bw"; }
  for row in "${FIXTURES[@]}"; do
    case $row in P*) continue;; esac
    id=$(printf '%s' "$row" | awk -F'|' '{print $1}')
    rel=$(printf '%s' "$row" | awk -F'|' '{print $2}')
    anchor=$(printf '%s' "$row" | awk -F'|' '{print $4}')
    repl=$(printf '%s' "$row" | awk -F'|' '{print $5}')
    restore_fixture_files "$bw" "$SCR/base"
    printf '{"file":"%s","anchor":%s,"repl":%s}\n' \
      "$bw/$rel" "$(pyq "$anchor")" "$(pyq "$repl")" > "$SCR/$id.json"
    count=$(apply_spec "$SCR/apply.py" "$SCR/$id.json")
    if [ "$count" != 1 ]; then
      detail="$detail $id=anchor-count:$count"
      continue
    fi
    c1_measure "$SCR/base/$C1CHECK_REL" "$bw"
    if [ "$V1_VALUE" = 0 ] && [ "$V1_POP" = 7 ]; then
      accepted=$((accepted+1)); part="$id=0"
    else
      part="$id=$V1_VALUE"
    fi
    detail="$detail $id=v$V1_VALUE$V1_ITEMS"
  done
  if [ "$accepted" = 5 ]; then
    report "K1-BASE-C1" "accepted=5" "accepted=$accepted" "match" "base-census --no-challenge:$detail"
  else
    report "K1-BASE-C1" "accepted=5" "accepted=$accepted" "mismatch" "fixture-vacuous-or-drift:$detail"
  fi
}

ctrl_k1_base_c2() { # reviewer mutations survive; G challenge does not fire at BASE
  if ! command -v bao >/dev/null 2>&1 && [ ! -x "$BAO_BIN" ]; then
    report_skip "K1-BASE-C2" "killed=0" "bao-binary (the BASE counter SETUPs without it; ma/mb unrecorded)" \
                "bao-path=$BAO_BIN"
    return
  fi
  local ma="?" mb="?" g="?" mrc mout gout glrc gline gdetail
  # M-A: main aggregation -> constant value=5. The mutant copy must live inside a
  # plans/ dir that carries plans/round-57-c2.sh: the counter derives REPO from its
  # own path and its selftest's nested runs read the bao pin from there.
  cp -f "$SCR/base/$C2COUNT_REL" "$SCR/base/plans/round-61-c2.sh.m62ma"
  printf '{"file":"%s","anchor":%s,"repl":%s}\n' \
    "$SCR/base/plans/round-61-c2.sh.m62ma" "$(pyq "$NEEDLE_MA")" "$(pyq "$REPL_MA")" > "$SCR/ma.json"
  if [ "$(apply_spec "$SCR/apply.py" "$SCR/ma.json")" = 1 ]; then
    mout=$(timeout 120 bash "$SCR/base/plans/round-61-c2.sh.m62ma" --selftest 2>&1); mrc=$?
    if [ $mrc = 0 ] && printf '%s\n' "$mout" | grep -qE "C2_SELFTEST: PASS \((cases=)?$BASE_C2_CASES\)"; then
      ma=survive
    else
      ma="killed(rc=$mrc)"
    fi
  else
    ma=needle-failed
  fi
  # M-B: shim aggregation -> unconditional shims_ok=5
  cp -f "$SCR/base/$C2COUNT_REL" "$SCR/base/plans/round-61-c2.sh.m62mb"
  printf '{"file":"%s","anchor":%s,"repl":%s}\n' \
    "$SCR/base/plans/round-61-c2.sh.m62mb" "$(pyq "$NEEDLE_MB")" "$(pyq "$REPL_MB")" > "$SCR/mb.json"
  if [ "$(apply_spec "$SCR/apply.py" "$SCR/mb.json")" = 1 ]; then
    mout=$(timeout 120 bash "$SCR/base/plans/round-61-c2.sh.m62mb" --selftest 2>&1); mrc=$?
    if [ $mrc = 0 ] && printf '%s\n' "$mout" | grep -qE "C2_SELFTEST: PASS \((cases=)?$BASE_C2_CASES\)"; then
      mb=survive
    else
      mb="killed(rc=$mrc)"
    fi
  else
    mb=needle-failed
  fi
  # G: stub-trial tree on the unmutated BASE counter
  mk_stub_trial "$SCR/stubtree-g/$TRIAL_REL"
  gout=$(timeout 300 bash "$SCR/base/$C2COUNT_REL" --tree "$SCR/stubtree-g" 2>&1); glrc=$?
  gline=$(printf '%s\n' "$gout" | last_c2_guard_line)
  if [ -n "$gline" ]; then
    parse_c2_line "$gline"
    if [ "${V2_GUARD:-}" = 1 ]; then g=nofire; else g="fire(guard=${V2_GUARD:-?})"; fi
    gdetail="value=${V2_VALUE:-?} rc=$glrc"
  else
    g="no-verdict-line(rc=$glrc)"
    gdetail=$(printf '%s\n' "$gout" | head -3 | cap | tr '\n' '~')
  fi
  local killed=0
  case $ma in survive) :;; *) killed=$((killed+1));; esac
  case $mb in survive) :;; *) killed=$((killed+1));; esac
  case $g in nofire) :;; *) killed=$((killed+1));; esac
  if [ "$killed" = 0 ]; then
    report "K1-BASE-C2" "killed=0" "killed=$killed" "match" "ma=$ma mb=$mb g=$g $gdetail"
  else
    report "K1-BASE-C2" "killed=0" "killed=$killed" "mismatch" "ma=$ma mb=$mb g=$g $gdetail"
  fi
}

# ------------------------------------------------------------- candidate legs ----
CANDCLEAN=""

cand_snapshot() { # one clean cp -a snapshot of the candidate tree (lazy)
  [ -n "$CANDCLEAN" ] && return 0
  CANDCLEAN=$SCR/cand
  cp -a "$CAND" "$CANDCLEAN" 2>/dev/null || return 1
  [ -f "$CANDCLEAN/$C1CHECK_REL" ] || return 1
  return 0
}

ctrl_c1_fixture() { # ROW  (a B row): forge on the candidate snapshot, expect exactly item I(k) unresolved
  local row=$1
  local id rel item anchor repl count
  id=$(printf '%s' "$row" | awk -F'|' '{print $1}')
  rel=$(printf '%s' "$row" | awk -F'|' '{print $2}')
  item=$(printf '%s' "$row" | awk -F'|' '{print $3}')
  anchor=$(printf '%s' "$row" | awk -F'|' '{print $4}')
  repl=$(printf '%s' "$row" | awk -F'|' '{print $5}')
  local expect="value=1;i${item}=0;population=7"
  if [ "$RD_C1CHK" != ready ]; then
    report_skip "C1-$id" "$expect" "hardened C1 checker (floor $C1_SELFTEST_FLOOR cases; $RD_C1CHK_DET)"
    return
  fi
  cand_snapshot || { report "C1-$id" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  local bw=$SCR/work-cand
  if [ ! -d "$bw" ]; then
    cp -al "$CANDCLEAN" "$bw" 2>/dev/null || { rm -rf "$bw"; cp -a "$CANDCLEAN" "$bw"; }
  fi
  restore_fixture_files "$bw" "$CANDCLEAN"
  printf '{"file":"%s","anchor":%s,"repl":%s}\n' \
    "$bw/$rel" "$(pyq "$anchor")" "$(pyq "$repl")" > "$SCR/c-$id.json"
  count=$(apply_spec "$SCR/apply.py" "$SCR/c-$id.json")
  if [ "$count" != 1 ]; then
    report "C1-$id" "$expect" "anchor=$count" "mismatch" "anchor-count-in-candidate:$rel (0 or >1 fails closed)"
    return
  fi
  c1_measure "$CANDCLEAN/$C1CHECK_REL" "$bw"
  local obs="value=$V1_VALUE;i${item}=$(printf '%s' "$V1_ITEMS" | sed -nE "s/.* i${item}=([01]).*/\1/p");population=$V1_POP"
  if [ "$V1_VALUE" = 1 ] && [ "$V1_POP" = 7 ] \
     && [ "$(printf '%s' "$V1_ITEMS" | sed -nE "s/.* i${item}=([01]).*/\1/p")" = 0 ]; then
    report "C1-$id" "$expect" "$obs" "match" "checker=$CANDCLEAN/$C1CHECK_REL rc=$C1RC$V1_ITEMS"
  else
    report "C1-$id" "$expect" "$obs" "mismatch" "forgery-accepted-or-mispaired rc=$C1RC$V1_ITEMS"
  fi
}

ctrl_c1_f6() { # stub-checker tree -> counter refuses (no verdict line, rc != 0)
  local expect="noverdict;rc!=0;cleanverdict=yes"
  if [ "$RD_C1CTR" != present ]; then
    report_skip "C1-F6" "$expect" "plans/round-62-c1.sh (C1 claim counter)"
    return
  fi
  cand_snapshot || { report "C1-F6" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  local clean_out clean_rc clean_line stub_out stub_rc stub_line
  clean_out=$(timeout 600 bash "$CANDCLEAN/$C1CTR_REL" --tree "$CANDCLEAN" 2>&1); clean_rc=$?
  clean_line=$(printf '%s\n' "$clean_out" | grep '^C1_BYPASS:' | tail -1)
  if [ -z "$clean_line" ]; then
    report_skip "C1-F6" "$expect" "operable plans/round-62-c1.sh (clean-tree run printed no C1_BYPASS verdict)" \
      "rc=$clean_rc out=$(printf '%s\n' "$clean_out" | head -2 | cap | tr '\n' '~')"
    return
  fi
  local bw=$SCR/stubtree-f6
  cp -al "$CANDCLEAN" "$bw" 2>/dev/null || { rm -rf "$bw"; cp -a "$CANDCLEAN" "$bw"; }
  rm -f "$bw/plans/round-61-c1-check.py"
  mk_stub_checker "$bw/plans/round-61-c1-check.py"
  stub_out=$(timeout 600 bash "$CANDCLEAN/$C1CTR_REL" --tree "$bw" 2>&1); stub_rc=$?
  stub_line=$(printf '%s\n' "$stub_out" | grep '^C1_BYPASS:' | tail -1)
  local obs="verdict=$([ -n "$stub_line" ] && echo yes || echo no);rc=$stub_rc;cleanverdict=yes"
  if [ -z "$stub_line" ] && [ "$stub_rc" != 0 ]; then
    report "C1-F6" "$expect" "$obs" "match" "clean-line=$(printf '%s' "$clean_line" | cap)"
  else
    report "C1-F6" "$expect" "$obs" "mismatch" "stub-line=$(printf '%s' "$stub_line" | cap)"
  fi
}

ctrl_c1_f7() { # three paraphrase fixtures must each still read value=0
  local expect="value=0/0/0;population=7"
  if [ "$RD_C1CHK" != ready ]; then
    report_skip "C1-F7" "$expect" "hardened C1 checker (floor $C1_SELFTEST_FLOOR cases; $RD_C1CHK_DET)"
    return
  fi
  cand_snapshot || { report "C1-F7" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  local bw=$SCR/work-cand
  if [ ! -d "$bw" ]; then
    cp -al "$CANDCLEAN" "$bw" 2>/dev/null || { rm -rf "$bw"; cp -a "$CANDCLEAN" "$bw"; }
  fi
  local vals="" pops="" anchors="" row id rel anchor repl count first=1
  for row in "${FIXTURES[@]}"; do
    case $row in B*) continue;; esac
    id=$(printf '%s' "$row" | awk -F'|' '{print $1}')
    rel=$(printf '%s' "$row" | awk -F'|' '{print $2}')
    anchor=$(printf '%s' "$row" | awk -F'|' '{print $4}')
    repl=$(printf '%s' "$row" | awk -F'|' '{print $5}')
    restore_fixture_files "$bw" "$CANDCLEAN"
    printf '{"file":"%s","anchor":%s,"repl":%s}\n' \
      "$bw/$rel" "$(pyq "$anchor")" "$(pyq "$repl")" > "$SCR/c-$id.json"
    count=$(apply_spec "$SCR/apply.py" "$SCR/c-$id.json")
    if [ "$count" != 1 ]; then
      vals="$vals/anchor$count"; pops="$pops/-"; anchors="$anchors/$id:$count"
      continue
    fi
    c1_measure "$CANDCLEAN/$C1CHECK_REL" "$bw"
    if [ $first = 1 ]; then vals="$V1_VALUE"; pops="$V1_POP"; anchors="$id:1"; first=0
    else vals="$vals/$V1_VALUE"; pops="$pops/$V1_POP"; anchors="$anchors/$id:1"; fi
  done
  if [ "$vals" = "0/0/0" ] && [ "$pops" = "7/7/7" ]; then
    report "C1-F7" "$expect" "value=$vals;population=$pops" "match" "paraphrase-anchor-counts:$anchors"
  else
    report "C1-F7" "$expect" "value=$vals;population=$pops" "mismatch" "false-positive-on-benign-rewording:$anchors"
  fi
}

ctrl_c2_mutant() { # ID EXPECT MARKER-BEGIN MARKER-END BODY
  local id=$1 expect=$2 begin=$3 end=$4 body=$5
  if [ "$RD_C2CNT" != ready ]; then
    report_skip "$id" "$expect" "hardened C2 counter (floor $C2_SELFTEST_FLOOR cases; $RD_C2CNT_DET)"
    return
  fi
  cand_snapshot || { report "$id" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  # The mutant copy must live inside the snapshot's plans/ dir: the counter derives
  # REPO from its own path and its selftest's nested runs read the bao pin from
  # plans/round-57-c2.sh there.
  local mut="$CANDCLEAN/plans/round-61-c2.sh.m62$(printf '%s' "$id" | tr 'A-Z-' 'az_')"
  cp -f "$CANDCLEAN/$C2COUNT_REL" "$mut"
  printf '{"file":"%s","mode":"block","begin":%s,"end":%s,"body":%s}\n' \
    "$mut" "$(pyq "$begin")" "$(pyq "$end")" "$(pyq "$body")" > "$SCR/$id.json"
  local minfo
  minfo=$(apply_spec "$SCR/apply.py" "$SCR/$id.json")
  if [ "$minfo" != ok ]; then
    report "$id" "$expect" "marker-failed" "mismatch" "markers:$minfo (0 or >1 occurrences, or end<=begin)"
    return
  fi
  local out rc finding
  out=$(timeout 300 bash "$mut" --selftest 2>&1); rc=$?
  if printf '%s\n' "$out" | grep -Eq 'FINDING[[:space:]]+[A-Za-z0-9._-]+'; then
    finding=named
  else
    finding=none
  fi
  local fid
  fid=$(printf '%s\n' "$out" | grep -E 'FINDING[[:space:]]+[A-Za-z0-9._-]+' | head -1 | cap)
  if [ "$rc" != 0 ] && [ "$finding" = named ]; then
    report "$id" "$expect" "rc=$rc;finding=$finding" "match" "$fid"
  else
    report "$id" "$expect" "rc=$rc;finding=$finding" "mismatch" "mutation-survived-or-unnamed out=$(printf '%s\n' "$out" | head -2 | cap | tr '\n' '~')"
  fi
}

ctrl_c2_f3() { # G on the unmutated candidate counter: stub-trial tree reads guard=0
  local expect="guard=0"
  if [ "$RD_C2CNT" != ready ]; then
    report_skip "C2-F3" "$expect" "hardened C2 counter (floor $C2_SELFTEST_FLOOR cases; $RD_C2CNT_DET)"
    return
  fi
  cand_snapshot || { report "C2-F3" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  mk_stub_trial "$SCR/stubtree-f3/$TRIAL_REL"
  local out rc line
  out=$(timeout 300 bash "$CANDCLEAN/$C2COUNT_REL" --tree "$SCR/stubtree-f3" 2>&1); rc=$?
  line=$(printf '%s\n' "$out" | last_c2_guard_line)
  if [ -z "$line" ]; then
    report "C2-F3" "$expect" "no-verdict-line;rc=$rc" "mismatch" "out=$(printf '%s\n' "$out" | head -3 | cap | tr '\n' '~')"
    return
  fi
  parse_c2_line "$line"
  if [ "${V2_GUARD:-}" = 0 ]; then
    report "C2-F3" "$expect" "guard=${V2_GUARD};value=${V2_VALUE};rc=$rc" "match" "line=$(printf '%s' "$line" | cap)"
  else
    report "C2-F3" "$expect" "guard=${V2_GUARD};value=${V2_VALUE};rc=$rc" "mismatch" "guard-does-not-discriminate line=$(printf '%s' "$line" | cap)"
  fi
}

ctrl_c2_f4() { # the real trial on the candidate tree
  local expect="value=5;shims=5;vectors=ok/5"
  if [ "$RD_C2CNT" != ready ]; then
    report_skip "C2-F4" "$expect" "hardened C2 counter (floor $C2_SELFTEST_FLOOR cases; $RD_C2CNT_DET)"
    return
  fi
  if [ ! -x "$BAO_BIN" ]; then
    report_skip "C2-F4" "$expect" "bao binary at $BAO_BIN (counter SETUPs without it)"
    return
  fi
  cand_snapshot || { report "C2-F4" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  local out rc line
  out=$(timeout 2400 bash "$CANDCLEAN/$C2COUNT_REL" --tree "$CANDCLEAN" 2>&1); rc=$?
  if printf '%s\n' "$out" | grep -q ': SETUP'; then
    report_skip "C2-F4" "$expect" "operable plans/round-61-c2.sh real leg" \
      "counter-SETUP rc=$rc line=$(printf '%s\n' "$out" | grep ': SETUP' | head -1 | cap)"
    return
  fi
  line=$(printf '%s\n' "$out" | last_c2_guard_line)
  if [ -z "$line" ]; then
    report "C2-F4" "$expect" "no-verdict-line;rc=$rc" "mismatch" "out=$(printf '%s\n' "$out" | head -3 | cap | tr '\n' '~')"
    return
  fi
  parse_c2_line "$line"
  if [ "${V2_VALUE:-}" = 5 ] && [ "${V2_SHIMS:-}" = 5 ] && [ "${V2_VEC:-}" = "ok/5" ]; then
    report "C2-F4" "$expect" "value=${V2_VALUE};shims=${V2_SHIMS};vectors=${V2_VEC}" "match" "real-trial rc=$rc line=$(printf '%s' "$line" | cap)"
  else
    report "C2-F4" "$expect" "value=${V2_VALUE};shims=${V2_SHIMS};vectors=${V2_VEC}" "mismatch" "real-verdict-weakened rc=$rc line=$(printf '%s' "$line" | cap)"
  fi
}

ctrl_c2_f5() { # constant-verdict counter copy refused by the wrapper (differential)
  local expect="guard=0;cleanguard=1"
  if [ "$RD_C2WRAP" != present ]; then
    report_skip "C2-F5" "$expect" "plans/round-62-c2.sh (C2 claim wrapper)"
    return
  fi
  if [ "$RD_C2CNT" != ready ]; then
    report_skip "C2-F5" "$expect" "hardened C2 counter (floor $C2_SELFTEST_FLOOR cases; $RD_C2CNT_DET)"
    return
  fi
  cand_snapshot || { report "C2-F5" "$expect" "snapshot-failed" "mismatch" "cp-a of candidate failed"; return; }
  local bw=$SCR/stubtree-f5
  cp -al "$CANDCLEAN" "$bw" 2>/dev/null || { rm -rf "$bw"; cp -a "$CANDCLEAN" "$bw"; }
  copy_over "$CANDCLEAN/$C2COUNT_REL" "$bw/$C2COUNT_REL"
  local body_line="if [ \"\${1:-}\" = \"--selftest\" ]; then echo \"$STUB_PASS_LINE\"; exit 0; fi"
  printf '{"file":"%s","mode":"insert-after-shebang","body":%s}\n' \
    "$bw/$C2COUNT_REL" "$(pyq "$body_line")" > "$SCR/f5.json"
  if [ "$(apply_spec "$SCR/apply.py" "$SCR/f5.json")" != ok ]; then
    report "C2-F5" "$expect" "stub-insert-failed" "mismatch" "no shebang in counter copy"
    return
  fi
  local cout crc cline sout src sline
  cout=$(timeout 2400 bash "$CANDCLEAN/$C2WRAP_REL" --tree "$CANDCLEAN" 2>&1); crc=$?
  cline=$(printf '%s\n' "$cout" | last_c2_guard_line)
  parse_c2_line "${cline:-}"
  local cg=${V2_GUARD:-}
  sout=$(timeout 2400 bash "$CANDCLEAN/$C2WRAP_REL" --tree "$bw" 2>&1); src=$?
  sline=$(printf '%s\n' "$sout" | last_c2_guard_line)
  parse_c2_line "${sline:-}"
  local sg=${V2_GUARD:-}
  if [ -z "$cline" ]; then
    report_skip "C2-F5" "$expect" "operable plans/round-62-c2.sh (clean-tree run printed no guard= verdict)" \
      "rc=$crc out=$(printf '%s\n' "$cout" | head -2 | cap | tr '\n' '~')"
    return
  fi
  if [ "$sg" = 0 ] && [ "$cg" = 1 ]; then
    report "C2-F5" "$expect" "guard=$sg;cleanguard=$cg" "match" "clean-line=$(printf '%s' "$cline" | cap) stub-line=$(printf '%s' "$sline" | cap)"
  else
    report "C2-F5" "$expect" "guard=$sg;cleanguard=$cg" "mismatch" "constant-verdict-not-refused-or-claim-red rc=$src/$crc"
  fi
}

# pyq: emit a JSON string literal for an arbitrary byte string (single arg).
pyq() { python3 -c 'import json,sys; sys.stdout.write(json.dumps(sys.argv[1]))' "$1"; }

# ---------------------------------------------------------------------- main -----
main() {
  local arg=${1:-$REPO}
  if [ "$arg" = "--selftest" ]; then selftest_main; fi
  CAND=$(cd "$arg" 2>/dev/null && pwd -P) || { echo "SETUP candidate-tree-unusable at $arg"; exit 2; }
  [ -d "$CAND/plans" ] || { echo "SETUP candidate-has-no-plans-dir at $CAND"; exit 2; }

  command -v python3 >/dev/null 2>&1 || { echo "SETUP no-python3"; exit 2; }
  command -v git >/dev/null 2>&1 || { echo "SETUP no-git"; exit 2; }
  mk_apply_helper "$SCR/apply.py"

  # probes and pins first, so the receipt head describes the measured state
  run_probes
  local base_ok=1; extract_base "$SCR/base" || base_ok=0
  local bao_state=absent bao_sha=""
  if [ -x "$BAO_BIN" ]; then bao_state=present; bao_sha=$(sha_of "$BAO_BIN"); fi

  emit "# round-62 pre-freeze control battery (plans/round-62-controls.sh)"
  emit "# SELF $(sha_of "$0")"
  emit "# utc $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  emit "# repo $REPO"
  emit "# base $BASE"
  emit "# candidate $CAND"
  emit "# scratch $SCR"
  emit "PROBE c1-checker-floor $RD_C1CHK cases=${RD_C1CHK_CASES:-none} detail=$RD_C1CHK_DET"
  emit "PROBE c2-counter-floor $RD_C2CNT cases=${RD_C2CNT_CASES:-none} detail=$RD_C2CNT_DET"
  emit "PROBE c1-counter $RD_C1CTR path=$C1CTR_REL"
  emit "PROBE c2-wrapper $RD_C2WRAP path=$C2WRAP_REL"
  emit "PROBE bao $bao_state path=$BAO_BIN sha=$bao_sha"
  emit "PROBE base-extraction $([ $base_ok = 1 ] && echo ok || echo failed) pin-c1check=$PIN_BASE_C1CHECK pin-c2count=$PIN_BASE_C2COUNT"
  local f
  for f in "$C1CHECK_REL" "$C2COUNT_REL" "$C1CTR_REL" "$C2WRAP_REL" "$TRIAL_REL" \
           plans/round-62-bypass.tsv plans/round-62-paraphrase.tsv; do
    if [ -f "$CAND/$f" ]; then
      emit "INSTRUMENT $f $(sha_of "$CAND/$f")"
    else
      emit "INSTRUMENT $f MISSING"
    fi
  done
  emit "BAO $BAO_BIN ${bao_sha:-MISSING}"
  emit "# readiness: C1-F1..F5,C1-F7 <- c1-checker-floor; C1-F6 <- c1-counter; C2-F1..F4 <- c2-counter-floor; C2-F5 <- c2-wrapper + c2-counter-floor; K1-BASE-* <- base extraction (G sub-leg needs bao)"

  if [ $base_ok = 1 ]; then
    ctrl_k1_base_c1
    ctrl_k1_base_c2
  else
    report_skip "K1-BASE-C1" "accepted=5" "BASE extraction (git archive $BASE or pinned byte check failed)"
    report_skip "K1-BASE-C2" "killed=0" "BASE extraction (git archive $BASE or pinned byte check failed)"
  fi

  local row
  for row in "${FIXTURES[@]}"; do
    case $row in B*) ctrl_c1_fixture "$row";; esac
  done
  ctrl_c1_f6
  ctrl_c1_f7
  ctrl_c2_mutant "C2-F1" "rc!=0;finding=named" "# BEGIN-DECIDE" "# END-DECIDE" "  echo 5"
  ctrl_c2_mutant "C2-F2" "rc!=0;finding=named" "# BEGIN-SHIMS" "# END-SHIMS" "  shims_ok=5"
  ctrl_c2_f3
  ctrl_c2_f4
  ctrl_c2_f5

  emit "SKIPS: $S"
  emit "CONTROLS: match=$M mismatch=$K"
  if [ $K -eq 0 ]; then
    emit "SEAT-STATUS: complete"
  else
    emit "SEAT-STATUS: partial mismatch-count=$K (see DETAIL lines; the L1 re-runs the full battery before the candidate reading)"
  fi

  cat "$BODY"
  mkdir -p "$REPO/$CTLDIR_REL" 2>/dev/null && cp "$BODY" "$REPO/$RECEIPT_REL" 2>/dev/null \
    && INSTALLED=1 \
    || say "RECEIPT-INSTALL-FAILED: could not write $REPO/$RECEIPT_REL"
  [ "$INSTALLED" = 1 ] || return 1
  return $([ "$K" -eq 0 ] && echo 0 || echo 1)
}

main "$@"
