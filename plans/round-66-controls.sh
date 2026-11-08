#!/usr/bin/env bash
# plans/round-66-controls.sh -- pre-freeze control battery for round 66 (kagi).
#   usage: bash plans/round-66-controls.sh [--tree DIR] [--base REV]
#          bash plans/round-66-controls.sh --selftest
#
# Declared by plans/round-66.md (frozen at ddcd46b) as amended by A1/A2/A3
# (recorded before any candidate reading) and the round-66 wave dispatch.
# The battery carries, for each claim, three controls:
#
#   <C>-NOWORK  a no-work control: the claim's own measurement run on a
#               byte-identical BASE tree (a `git archive <BASE>` extraction)
#               reads the frozen FAILING value. If a do-nothing tree reaches
#               the target, the claim is vacuous (M65-1) and the control says
#               so by name.
#   <C>-FORGE   a forgery control: a mutated copy that the claim's mechanism
#               must refuse reads a FAILURE. This is the control that proves
#               the predicate can fail at all.
#   <C>-VALID   a valid control: the claim's own mechanism passes its
#               self-test AND the measured tree prints the claim's verdict
#               line with its guard set. A counter that refuses everything,
#               or a gate that cannot read PASS, fails here.
#
# Claim -> measurement (as amended; the plan's own commands, not a
# re-interpretation):
#   C1 (§C1 + A1)   bash plans/round-66-c1.sh --tree T --scratch S
#                   -> `C1_CARRIER: drift=A paths=3 hex=3 match=1 guard=G`
#      NOWORK  BASE tree reads drift=0 (A1 guard (a)).
#      FORGE   a copy whose registry/fetch anchors cite
#              .ufo/waves/round-64/capture/S148.body (the arXiv body, sha
#              fabc74c5…) reads drift=0 with `digest-mismatch:` naming that
#              path (A1 guard (d)). Precondition: the measured tree names a
#              carrier path at all (post-repair); otherwise `skip
#              no-carrier-binding` — a vacuous pass is never recorded.
#      VALID   `--selftest` exits 0 and the measured tree's verdict carries
#              guard=1.
#   C2 (A2)         python3 <fleet>/scripts/hyaku/prefile-falsification.py
#                     --lane kagi --round 66 --fleet F
#                   -> `PREFILE-FALSIFICATION: PASS claims=3 rows=R
#                      attack_seats=K findings=0`
#                   plus bash corpus/claims-declared.sh --root T
#                   -> `CLAIMS_DECLARED: CLEAN (claims=59)`
#      NOWORK  the BASE fleet (a byte-identical BASE tree materialized as
#              <scratch-fleet>/kagi-shokunin) reads not-PASS with findings>=1.
#      FORGE   a ledger copy with one claim's rows removed reads
#              `FINDING claim-uncovered` and exit 1.
#      VALID   the measured tree reads PASS with rows>=3, attack_seats>=1,
#              findings=0, and claims-declared reads CLEAN claims=59.
#   C3 (A3)         bash corpus/sources-census.sh verify --root T
#                   -> `SOURCES_CENSUS: CLEAN (...)` / `FAILED (findings=N rows=M)`
#      NOWORK  the BASE tree reads findings>=1.
#      FORGE   a copy with the `cites:` line removed from a knowledge entry
#              reads findings>=1.
#      VALID   the measured tree reads CLEAN (findings=0) and the gate's
#              verdict line is present (the line is the verdict; the lane
#              gate has historically exited 0 on FAILED).
#   PRIOR-SELFTEST  the round-64 battery's own fixtures still pass on this
#                   tree (a stable regression probe: it re-enters no counter
#                   and re-adjudicates no round-64 claim on a moved tree).
#
# Exit contract: 0 iff mismatch=0; 1 on any mismatch; 2 SETUP (unusable tree
# argument, missing scratch, or no measurement surface at all). `CONTROLS:
# match=N mismatch=M` is the summary line; SKIPS are recorded with their
# reason and are not mismatches.
#
# Named ceilings:
#  * A control whose measurement surface is absent records `skip` with the
#    reason, never a pass. On a pre-repair tree C1-FORGE, C2-FORGE and
#    C3-FORGE legitimately skip: there is no binding / no ledger / no green
#    census to attack yet. The L1 re-runs the battery after integration.
#  * `<C>-VALID` measures reachability of the claim's target on the tree in
#    front of it. Pre-integration it fails and names the leg that is red;
#    that is the reading, not a defect in the control.
#  * A forged/valued tree is a copy; a copy cost the machine cannot pay
#    reads SETUP, never a pass (bounds, plan §Bounds).
#  * The battery judges the frozen predicates' mechanisms. Whether the frozen
#    wording is the right claim is the reviewer's question, not this file's.
#
# Discipline: everything runs on copies under
# ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r66/R66ExecControls/battery.$$
# and is removed on exit; TMPDIR points into that scratch; umask 077; no
# /tmp evidence. The measured tree is only ever read: the one git call is a
# read-only `git archive <BASE>` from the measured repo's object store (no
# worktree, no checkout, no index write), and no mutating git/jj command is
# issued anywhere. Every instrument line is redacted to shape before it
# reaches the receipt (QM72).
set -u -o pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
LANEREPO=${R66_CONTROLS_REPO:-$REPO}
SELFPATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/$(basename "${BASH_SOURCE[0]}")
BASE_REV=${R66_CONTROLS_BASE:-d549ee6eb8770a49938b78f49cf79e36d9c1c2e8}
CTLDIR_REL=.ufo/waves/round-66/w1/R66ExecControls
C1CTR_REL=plans/round-66-c1.sh
PRIOR_REL=plans/round-64-controls.sh
CENSUS_REL=corpus/sources-census.sh
DECLARED_REL=corpus/claims-declared.sh
PREFILE_REL=scripts/hyaku/prefile-falsification.py
SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r66/R66ExecControls

# Frozen BASE readings (plans/round-66.md + A1/A2/A3, measured by the L1 and
# re-derived here on a `git archive` extraction of the claim BASE).
C1_BASE_DRIFT=0
C2_BASE_CLAIMS=59
C3_BASE_FINDINGS_MIN=1

if [ "${1:-}" = "--selftest" ]; then
  SCR=$SCRROOT/selftest.$$
else
  SCR=$SCRROOT/battery.$$
fi
mkdir -p -- "$SCR" || { echo "SETUP no-scratch at $SCR"; exit 2; }
# R66_CONTROLS_KEEP=1 preserves the scratch for debugging a failing control;
# the default is to delete it on exit (plan §Scratch).
if [ "${R66_CONTROLS_KEEP:-0}" = 1 ]; then
  trap 'printf "scratch-kept: %s\n" "$SCR"' EXIT
else
  trap 'rm -rf -- "$SCR"' EXIT
fi
export TMPDIR=$SCR
export LC_ALL=C
umask 077
BODY=$SCR/receipt.body
: > "$BODY"
M=0; K=0; S=0

say() { printf '%s\n' "$*"; }
emit() { printf '%s\n' "$*" >> "$BODY"; }

redact() {
  sed -E \
    -e 's/(hvs|hvb)\.[A-Za-z0-9_-]{6,}/[REDACTED]/g' \
    -e 's/\bs\.[A-Za-z0-9]{20,}/[REDACTED]/g' \
    -e 's/([Oo][Tt][Pp]|[Nn]once)([=:[:space:]]+)["'"'"']?[A-Za-z0-9+\/_-]{12,}/\1\2[REDACTED]/g' \
    -e 's/[0-9a-f]{43,}/[HEXRUN]/g' \
    -e 's/[-_]{43,}/[SEPRUN]/g' \
    -e 's/[A-Za-z0-9+\/_-]{43,}/[REDACTED]/g'
}
cap() { redact | cut -c1-240; }
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
report_skip() { # ID EXPECT MISSING [DETAIL]
  report "$1" "$2" "absent" "skip" "${4:+$4; }$3"
}
copy_over() { rm -f -- "$2" && cp -- "$1" "$2"; }

# Verdict parsers.
p_c1() {
  R1_DRIFT=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]drift=([0-9]+).*/\1/p')
  R1_MATCH=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]match=([0-9]+).*/\1/p')
  R1_GUARD=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]guard=([0-9]+).*/\1/p')
}
p_c2() { # prefile gate line (A4: the clean token is lowercase `pass`, the
          # failure token uppercase `FAIL`; read both case-insensitively and
          # normalise the clean token to `pass`)
  R2_VERDICT=$(printf '%s\n' "$1" | sed -nE 's/^PREFILE-FALSIFICATION:[[:space:]]+([A-Za-z]+).*/\1/p' | tr 'A-Z' 'a-z')
  R2_CLAIMS=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]claims=([0-9]+).*/\1/p')
  R2_ROWS=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]rows=([0-9]+).*/\1/p')
  R2_SEATS=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]attack_seats=([0-9]+).*/\1/p')
  R2_FIND=$(printf '%s\n' "$1" | sed -nE 's/.*[[:space:]]findings=([0-9]+).*/\1/p')
}
p_c3() { # lane census verdict line
  R3_VERDICT=$(printf '%s\n' "$1" | sed -nE 's/^SOURCES_CENSUS:[[:space:]]+([A-Z]+).*/\1/p')
  R3_FIND=$(printf '%s\n' "$1" | sed -nE 's/.*findings=([0-9]+).*/\1/p')
  R3_ROWS=$(printf '%s\n' "$1" | sed -nE 's/.*rows=([0-9]+).*/\1/p')
  # The lane gate's CLEAN line carries no findings= field: CLEAN is zero
  # findings by construction, FAILED always names the count.
  if [ -z "$R3_FIND" ] && [ "$R3_VERDICT" = CLEAN ]; then R3_FIND=0; fi
}
last_line() { grep -E "^$1" 2>/dev/null | tail -1; }

# ------------------------------------------------------------------ BASE tree --
BASE_TREE=${R66_CONTROLS_BASE_TREE:-}
BASE_READY=0
ensure_base_tree() {
  [ "$BASE_READY" = 1 ] && return 0
  if [ -z "$BASE_TREE" ] || [ ! -d "$BASE_TREE" ]; then
    BASE_TREE=$SCR/base-fleet/kagi-shokunin
    rm -rf -- "$SCR/base-fleet" 2>/dev/null
    mkdir -p -- "$BASE_TREE" 2>/dev/null || return 1
    git -C "$LANEREPO" archive --format=tar "$BASE_REV" 2>/dev/null \
      | tar -x -f - -C "$BASE_TREE" 2>/dev/null || { BASE_READY=0; return 1; }
  fi
  [ -d "$BASE_TREE/corpus" ] || { BASE_READY=0; return 1; }
  BASE_READY=1
  return 0
}

RC=0
run() { # TIMEOUT CMD... -> stdout; exit status in RC
  local tmo=$1; shift
  local out
  out=$(timeout "$tmo" "$@" 2>&1); RC=$?
  printf '%s' "$out"
}

# ------------------------------------------------------------- measurements ----
# Each measure_* returns the instrument's stdout and leaves parsed fields in
# the R*_ variables. Absent surfaces are signalled by the caller via the
# HAVE flags, so every absence is named rather than silently skipped.

C1_HAVE=0; C2_HAVE=0; C3_HAVE=0
C1_INSTR=""
probe() { # one unmutated reading per claim on the measured tree, shared by
          # NOWORK's comparison and every VALID control.
  if [ -f "$CAND/$C1CTR_REL" ]; then C1_INSTR=$CAND/$C1CTR_REL
  elif [ -f "$LANEREPO/$C1CTR_REL" ]; then C1_INSTR=$LANEREPO/$C1CTR_REL; fi
  [ -n "$C1_INSTR" ] && bash -n "$C1_INSTR" 2>/dev/null && C1_HAVE=1
  if [ -f "$CAND/$CENSUS_REL" ]; then C3_HAVE=1; fi
  # C2's surface is the fleet's pre-file gate plus the lane's claims-declared;
  # both must exist for the claim to be measurable.
  if command -v python3 >/dev/null 2>&1 \
     && [ -f "$(dirname "$CAND")/$PREFILE_REL" ] \
     && [ -f "$CAND/$DECLARED_REL" ]; then C2_HAVE=1; fi
}

# --- C1 -----------------------------------------------------------------------
C1_UNMUT_OUT=""
c1_measure() { # TREE -> stdout ; sets RC, R1_*
  local tree=$1
  local tmo=${R66_PROBE_TIMEOUT:-240} extra=()
  # Guard (a) of the amended §C1 is measured against a byte-identical BASE
  # tree; hand the counter the extraction the battery already materialized so
  # the leg is measured rather than skipped.
  if [ -n "${BASE_TREE:-}" ] && [ -d "$BASE_TREE" ]; then extra=(--base-tree "$BASE_TREE"); fi
  C1_UNMUT_OUT=$(timeout "$tmo" bash "$C1_INSTR" --tree "$tree" --scratch "$SCR/c1-scratch" "${extra[@]}" 2>&1); RC=$?
  p_c1 "$(last_line 'C1_CARRIER:' <<< "$C1_UNMUT_OUT")"
}

ctrl_c1_nowork() {
  local expect="drift=$C1_BASE_DRIFT"
  if [ "$C1_HAVE" != 1 ]; then report_skip C1-NOWORK "$expect" "$C1CTR_REL absent"; return; fi
  if ! ensure_base_tree; then report C1-NOWORK "$expect" base-unavailable skip "cannot materialize BASE $BASE_REV"; return; fi
  c1_measure "$BASE_TREE"
  local line; line=$(last_line 'C1_CARRIER:' <<< "$C1_UNMUT_OUT")
  if [ -n "$line" ] && [ "$R1_DRIFT" = "$C1_BASE_DRIFT" ]; then
    report C1-NOWORK "$expect" "drift=$R1_DRIFT match=${R1_MATCH:-none} rc=$RC" match \
      "byte-identical BASE reads the frozen failing value"
  else
    report C1-NOWORK "$expect" "drift=${R1_DRIFT:-none} rc=$RC" mismatch \
      "do-nothing tree reaches the target or the counter drifted: $(printf '%s' "${line:-none}" | cap)"
  fi
}

ctrl_c1_forge() {
  local expect="drift=0+digest-mismatch(S148.body)"
  if [ "$C1_HAVE" != 1 ]; then report_skip C1-FORGE "$expect" "$C1CTR_REL absent"; return; fi
  c1_measure "$CAND"   # refreshes C1_UNMUT_OUT for the precondition
  local cited carrier
  cited=$(printf '%s\n' "$C1_UNMUT_OUT" | grep -E '^c1-carrier: row=.* path=[^ ]+' | head -1)
  if [ -z "$cited" ]; then
    report C1-FORGE "$expect" no-carrier-binding skip \
      "the measured tree names no carrier path (A1 repair not landed): nothing to forge"
    return
  fi
  carrier=$(printf '%s\n' "$cited" | sed -nE 's/^c1-carrier: row=.* path=([^ ]+).*/\1/p')
  if [ -z "$carrier" ]; then
    cited=$(printf '%s\n' "$C1_UNMUT_OUT" | grep -E 'c1-carrier: (registry|fetches)=[^(]+\(ok\)' | head -1)
    carrier=$(printf '%s\n' "$cited" | sed -nE 's/^c1-carrier: (registry|fetches)=([^(]+)\(ok\).*/\2/p')
  fi
  [ -f "$CAND/$carrier" ] || { report C1-FORGE "$expect" "carrier-unreadable:$carrier" skip "cannot read the cited carrier"; return; }
  local forge=$SCR/c1-forge
  rm -rf -- "$forge" 2>/dev/null
  mkdir -p -- "$forge/corpus" "$forge/.ufo/waves/round-64/capture" "$forge/.ufo/waves/round-63/capture" 2>/dev/null \
    || { report C1-FORGE "$expect" mkdir-failed mismatch "cannot create forge tree"; return; }
  local f
  for f in corpus/SOURCES.md corpus/source-fetches.tsv corpus/volatile-shape.py; do
    [ -f "$CAND/$f" ] && cp -- "$CAND/$f" "$forge/$f" 2>/dev/null
  done
  for f in "$CAND"/.ufo/waves/round-64/capture/*.body "$CAND"/.ufo/waves/round-63/capture/*.body; do
    [ -f "$f" ] && cp -- "$f" "$forge/.ufo/waves/$(printf '%s' "$f" | sed -nE 's#.*(/\.ufo/waves/(round-6[34])/capture/).*#\2#p' | sed 's/^/.ufo\/waves\//')/capture/" 2>/dev/null
  done
  # (the loop above is best-effort; the explicit copies below are authoritative)
  cp -- "$CAND/.ufo/waves/round-64/capture/"* "$forge/.ufo/waves/round-64/capture/" 2>/dev/null
  cp -- "$CAND/.ufo/waves/round-63/capture/"* "$forge/.ufo/waves/round-63/capture/" 2>/dev/null
  local wrong=".ufo/waves/round-64/capture/S148.body"
  [ -f "$forge/$wrong" ] || { report C1-FORGE "$expect" wrong-path-body-absent skip "no S148.body capture to cite"; return; }
  # A1 guard (d): the anchors cite the WRONG-path file. Repoint the cited
  # carrier string to the arXiv body in the registry anchor and the fetch row.
  python3 - "$forge" "$carrier" "$wrong" <<'PY' || { report C1-FORGE "$expect" repoint-failed mismatch "python rewrite failed"; return; }
import sys
forge, carrier, wrong = sys.argv[1], sys.argv[2], sys.argv[3]
for rel in ("corpus/SOURCES.md", "corpus/source-fetches.tsv"):
    p = forge + "/" + rel
    try:
        t = open(p, encoding="utf-8").read()
    except OSError:
        continue
    open(p, "w", encoding="utf-8").write(t.replace(carrier, wrong))
PY
  local out line
  local fextra=()
  if [ -n "${BASE_TREE:-}" ] && [ -d "$BASE_TREE" ]; then fextra=(--base-tree "$BASE_TREE"); fi
  local ftmo=${R66_PROBE_TIMEOUT:-240}
  out=$(timeout "$ftmo" bash "$C1_INSTR" --tree "$forge" --scratch "$SCR/c1-forge-scratch" "${fextra[@]}" 2>&1); RC=$?
  line=$(last_line 'C1_CARRIER:' <<< "$out")
  p_c1 "${line:-}"
  if [ -z "$line" ]; then
    report C1-FORGE "$expect" "no-verdict-line;rc=$RC" mismatch "counter printed no verdict on the forgery"
  elif [ "$R1_DRIFT" = 0 ] && printf '%s\n' "$out" | grep -q 'digest-mismatch'; then
    report C1-FORGE "$expect" "drift=$R1_DRIFT match=${R1_MATCH:-none} rc=$RC" match \
      "wrong-path anchor refused, digest-mismatch named: $(printf '%s' "$line" | cap)"
  else
    report C1-FORGE "$expect" "drift=${R1_DRIFT:-none} match=${R1_MATCH:-none} rc=$RC" mismatch \
      "wrong-path anchor accepted (binding does not refuse): $(printf '%s' "${line:-none}" | cap)"
  fi
}

ctrl_c1_valid() {
  local expect="selftest=PASS;guard=1"
  if [ "$C1_HAVE" != 1 ]; then report_skip C1-VALID "$expect" "$C1CTR_REL absent"; return; fi
  local stout tmo=${R66_PROBE_TIMEOUT:-240}
  stout=$(timeout "$tmo" bash "$C1_INSTR" --selftest 2>&1); RC=$?
  # The counter has shipped two selftest line shapes
  # (`C1_CARRIER_SELFTEST: PASS (cases=N)` and `c1-carrier: selftest
  # cases=N failed=0`); either passes iff the run exits 0 and names no
  # failure. A FAIL line, a failed>0 count, or a non-zero exit is refused.
  if [ "$RC" != 0 ] \
     || ! printf '%s\n' "$stout" | grep -qE '(SELFTEST: PASS|cases=[0-9]+ failed=0)' \
     || printf '%s\n' "$stout" | grep -qE '(SELFTEST: FAIL|failed=[1-9])'; then
    report C1-VALID "$expect" "selftest-rc=$RC" mismatch \
      "counter selftest failed: $(printf '%s\n' "$stout" | tail -2 | cap | tr '\n' '~')"
    return
  fi
  c1_measure "$CAND"
  local line; line=$(last_line 'C1_CARRIER:' <<< "$C1_UNMUT_OUT")
  if [ -n "${R1_GUARD:-}" ] && [ "$R1_GUARD" = 1 ]; then
    report C1-VALID "$expect" "guard=$R1_GUARD drift=$R1_DRIFT rc=$RC" match "counter reaches a guarded pass"
  else
    report C1-VALID "$expect" "guard=${R1_GUARD:-none} drift=${R1_DRIFT:-none} rc=$RC" mismatch \
      "no guarded pass yet: $(printf '%s\n' "$C1_UNMUT_OUT" | grep -E 'c1-carrier: guard' | tail -1 | cap)"
  fi
}

# --- C2 (A2) ------------------------------------------------------------------
C2_OUT=""
c2_gate() { # FLEET -> stdout; sets RC and p_c2 fields from the verdict line
  local tmo=${R66_PROBE_TIMEOUT:-240}
  # The gate is the instrument, not the population: when the measured fleet
  # root carries no copy (the BASE extraction), stage the lane's own gate into
  # that root so the population -- not the tooling -- is what BASE measures.
  if [ ! -f "$1/$PREFILE_REL" ] && [ -f "$(dirname "$CAND")/$PREFILE_REL" ]; then
    mkdir -p -- "$1/$(dirname "$PREFILE_REL")" 2>/dev/null
    cp -- "$(dirname "$CAND")/$PREFILE_REL" "$1/$PREFILE_REL" 2>/dev/null
  fi
  C2_OUT=$(timeout "$tmo" python3 "$1/$PREFILE_REL" --lane kagi --round 66 --fleet "$1" 2>&1); RC=$?
  p_c2 "$(last_line 'PREFILE-FALSIFICATION:' <<< "$C2_OUT")"
}

ctrl_c2_nowork() {
  local expect="not-PASS;findings>=1"
  if [ "$C2_HAVE" != 1 ]; then report_skip C2-NOWORK "$expect" "pre-file gate or claims-declared absent"; return; fi
  local fleet
  if ensure_base_tree; then fleet=$(dirname "$BASE_TREE")
  else report C2-NOWORK "$expect" base-unavailable skip "cannot materialize BASE $BASE_REV"; return; fi
  c2_gate "$fleet"
  if [ -n "${R2_VERDICT:-}" ] && [ "$R2_VERDICT" != pass ] && [ "${R2_FIND:-0}" -ge 1 ] 2>/dev/null; then
    report C2-NOWORK "$expect" "verdict=$R2_VERDICT findings=$R2_FIND rc=$RC" match \
      "byte-identical BASE reads the frozen failing value"
  else
    report C2-NOWORK "$expect" "verdict=${R2_VERDICT:-none} findings=${R2_FIND:-none} rc=$RC" mismatch \
      "do-nothing tree reaches the target: $(printf '%s' "${R2_OUT##*$'\n'}" | cap)"
  fi
}

ctrl_c2_forge() {
  local expect="FINDING claim-uncovered;rc=1"
  if [ "$C2_HAVE" != 1 ]; then report_skip C2-FORGE "$expect" "pre-file gate or claims-declared absent"; return; fi
  local wdir=$CAND/.ufo/waves/round-66
  local ledger=$wdir/claim-falsification.tsv
  if [ ! -f "$ledger" ]; then
    report C2-FORGE "$expect" no-ledger skip "the wave has filed no claim-falsification.tsv yet: nothing to mutate"
    return
  fi
  local fleet=$SCR/c2-forge-fleet
  rm -rf -- "$fleet" 2>/dev/null
  mkdir -p -- "$fleet/kagi-shokunin/.ufo/waves/round-66" "$fleet/.ufo/reports/round-66" \
              "$fleet/scripts/hyaku" 2>/dev/null \
    || { report C2-FORGE "$expect" mkdir-failed mismatch "cannot create forge fleet"; return; }
  cp -- "$(dirname "$CAND")/$PREFILE_REL" "$fleet/$PREFILE_REL" 2>/dev/null \
    || { report C2-FORGE "$expect" gate-copy-failed mismatch "cannot stage the pre-file gate"; return; }
  cp -a -- "$wdir/." "$fleet/kagi-shokunin/.ufo/waves/round-66/" 2>/dev/null
  [ -f "$CAND/.ufo/reports/round-66/kagi.md" ] && \
    cp -- "$CAND/.ufo/reports/round-66/kagi.md" "$fleet/.ufo/reports/round-66/kagi.md" 2>/dev/null
  # Remove every row of ONE claim so the ledger no longer covers it.
  local forged_claim
  forged_claim=$(awk -F'\t' 'NF && $1 !~ /^#/ {print $1}' "$ledger" | head -1)
  if [ -z "$forged_claim" ]; then
    report C2-FORGE "$expect" ledger-empty skip "the ledger carries no claim rows"; return
  fi
  awk -F'\t' -v c="$forged_claim" 'BEGIN{OFS="\t"} !(NF && $1 !~ /^#/ && $1==c)' "$ledger" \
    > "$fleet/kagi-shokunin/.ufo/waves/round-66/claim-falsification.tsv"
  c2_gate "$fleet"
  if printf '%s\n' "$C2_OUT" | grep -qi 'claim-uncovered' && [ "$RC" = 1 ]; then
    report C2-FORGE "$expect" "claim=$forged_claim rc=$RC" match \
      "removing one claim's rows is caught by name"
  else
    report C2-FORGE "$expect" "claim=$forged_claim verdict=${R2_VERDICT:-none} rc=$RC" mismatch \
      "ledger gap not caught: $(printf '%s\n' "$C2_OUT" | tail -2 | cap | tr '\n' '~')"
  fi
}

ctrl_c2_valid() {
  local expect="PASS claims=3 rows>=3 seats>=1 findings=0;CLEAN claims=$C2_BASE_CLAIMS"
  if [ "$C2_HAVE" != 1 ]; then report_skip C2-VALID "$expect" "pre-file gate or claims-declared absent"; return; fi
  local fleet; fleet=$(dirname "$CAND")
  c2_gate "$fleet"
  local gate_ok=0 decl_ok=0 decl_out decl_line
  if [ "${R2_VERDICT:-}" = pass ] && [ "${R2_CLAIMS:-0}" = 3 ] 2>/dev/null \
     && [ "${R2_ROWS:-0}" -ge 3 ] 2>/dev/null && [ "${R2_SEATS:-0}" -ge 1 ] 2>/dev/null \
     && [ "${R2_FIND:-1}" = 0 ] 2>/dev/null; then gate_ok=1; fi
  local dtmo=${R66_PROBE_TIMEOUT:-240}
  decl_out=$(timeout "$dtmo" bash "$CAND/$DECLARED_REL" --root "$CAND" 2>&1); RC=$?
  decl_line=$(last_line 'CLAIMS_DECLARED:' <<< "$decl_out")
  if printf '%s\n' "$decl_line" | grep -q 'CLEAN' && printf '%s\n' "$decl_line" | grep -q "claims=$C2_BASE_CLAIMS"; then
    decl_ok=1
  fi
  if [ "$gate_ok" = 1 ] && [ "$decl_ok" = 1 ]; then
    report C2-VALID "$expect" "gate=pass claims=$R2_CLAIMS rows=$R2_ROWS seats=$R2_SEATS;declared=59" match \
      "the claim's target is reachable on this tree"
  else
    report C2-VALID "$expect" \
      "gate=${R2_VERDICT:-none} findings=${R2_FIND:-none};declared=$(printf '%s' "${decl_line:-none}" | sed -nE 's/.*claims=([0-9]+).*/\1/p')" mismatch \
      "not yet reachable: $(printf '%s\n' "$C2_OUT" | grep -E '^FINDING' | head -3 | cap | tr '\n' '~') $(printf '%s' "${decl_line:-}" | cap)"
  fi
}

# --- C3 (A3) ------------------------------------------------------------------
c3_census() { # TREE -> stdout; sets RC and p_c3 from the verdict line
  local tree=$1
  local tmo=${R66_PROBE_TIMEOUT:-240} out
  if [ -f "$tree/$CENSUS_REL" ]; then
    out=$(timeout "$tmo" bash "$tree/$CENSUS_REL" verify --root "$tree" 2>&1); RC=$?
  elif [ -f "$CAND/$CENSUS_REL" ]; then
    out=$(timeout "$tmo" bash "$CAND/$CENSUS_REL" verify --root "$tree" 2>&1); RC=$?
  else
    printf ''; return
  fi
  printf '%s' "$out"
}

ctrl_c3_nowork() {
  local expect="findings>=$C3_BASE_FINDINGS_MIN"
  if [ "$C3_HAVE" != 1 ]; then report_skip C3-NOWORK "$expect" "$CENSUS_REL absent"; return; fi
  if ! ensure_base_tree; then report C3-NOWORK "$expect" base-unavailable skip "cannot materialize BASE $BASE_REV"; return; fi
  local out; out=$(c3_census "$BASE_TREE")
  local line; line=$(last_line 'SOURCES_CENSUS:' <<< "$out")
  p_c3 "${line:-}"
  if [ -n "$line" ] && [ -n "${R3_FIND:-}" ] && [ "$R3_FIND" -ge "$C3_BASE_FINDINGS_MIN" ] 2>/dev/null; then
    report C3-NOWORK "$expect" "verdict=$R3_VERDICT findings=$R3_FIND rows=${R3_ROWS:-none}" match \
      "byte-identical BASE reads the frozen failing value"
  else
    report C3-NOWORK "$expect" "verdict=${R3_VERDICT:-none} findings=${R3_FIND:-none}" mismatch \
      "do-nothing tree reaches the target or the gate drifted: $(printf '%s' "${line:-none}" | cap)"
  fi
}

ctrl_c3_forge() {
  local expect="findings>=1 after cites-removal"
  if [ "$C3_HAVE" != 1 ]; then report_skip C3-FORGE "$expect" "$CENSUS_REL absent"; return; fi
  local base_out base_line
  base_out=$(c3_census "$CAND")
  base_line=$(last_line 'SOURCES_CENSUS:' <<< "$base_out")
  p_c3 "${base_line:-}"
  if [ "${R3_VERDICT:-}" != CLEAN ]; then
    report C3-FORGE "$expect" "candidate-verdict=${R3_VERDICT:-none}" skip \
      "candidate census is not CLEAN, so a cites-removal is indistinguishable from the standing findings"
    return
  fi
  local forge=$SCR/c3-forge
  rm -rf -- "$forge" 2>/dev/null
  mkdir -p -- "$forge/corpus" 2>/dev/null || { report C3-FORGE "$expect" mkdir-failed mismatch "cannot create forge tree"; return; }
  cp -a -- "$CAND/corpus/." "$forge/corpus/" 2>/dev/null
  local target
  target=$(grep -rlE '^cites:' "$forge/corpus/knowledge" 2>/dev/null | head -1)
  if [ -z "$target" ]; then
    report C3-FORGE "$expect" no-cites-line skip "no knowledge entry carries a cites: line to remove"
    return
  fi
  grep -vE '^cites:' "$target" > "$target.tmp" && mv -- "$target.tmp" "$target"
  local out line; out=$(c3_census "$forge")
  line=$(last_line 'SOURCES_CENSUS:' <<< "$out")
  p_c3 "${line:-}"
  if [ -n "$line" ] && [ -n "${R3_FIND:-}" ] && [ "$R3_FIND" -ge 1 ] 2>/dev/null; then
    report C3-FORGE "$expect" "findings=$R3_FIND verdict=$R3_VERDICT" match \
      "removing the cites: line turns the gate red (the repair is what makes it green)"
  else
    report C3-FORGE "$expect" "findings=${R3_FIND:-none} verdict=${R3_VERDICT:-none}" mismatch \
      "gate stays green with the citation removed (loosened or unread)"
  fi
}

ctrl_c3_valid() {
  local expect="CLEAN;findings=0;line-present"
  if [ "$C3_HAVE" != 1 ]; then report_skip C3-VALID "$expect" "$CENSUS_REL absent"; return; fi
  local out line; out=$(c3_census "$CAND")
  line=$(last_line 'SOURCES_CENSUS:' <<< "$out")
  p_c3 "${line:-}"
  if [ -n "$line" ] && [ "${R3_VERDICT:-}" = CLEAN ] && [ "${R3_FIND:-1}" = 0 ] 2>/dev/null; then
    report C3-VALID "$expect" "verdict=CLEAN findings=0 rows=${R3_ROWS:-none}" match \
      "the lane gate reads CLEAN on the measured tree"
  else
    report C3-VALID "$expect" "verdict=${R3_VERDICT:-none} findings=${R3_FIND:-none}" mismatch \
      "lane gate not green: $(printf '%s\n' "$out" | grep -E '^FINDING' | head -3 | cap | tr '\n' '~')"
  fi
}

# --- PRIOR --------------------------------------------------------------------
ctrl_prior() {
  local expect="CONTROLS_SELFTEST: PASS"
  if [ ! -f "$CAND/$PRIOR_REL" ]; then report_skip PRIOR-SELFTEST "$expect" "$PRIOR_REL absent"; return; fi
  if ! bash -n "$CAND/$PRIOR_REL" 2>/dev/null; then
    report PRIOR-SELFTEST "$expect" battery-not-bash mismatch "$PRIOR_REL fails bash -n"; return
  fi
  local out sel
  out=$(cd "$CAND" && timeout "${R66_PROBE_TIMEOUT:-240}" bash plans/round-64-controls.sh --selftest 2>&1); RC=$?
  sel=$(last_line 'CONTROLS_SELFTEST:' <<< "$out")
  if [ "$RC" = 0 ] && printf '%s\n' "$sel" | grep -q 'PASS'; then
    report PRIOR-SELFTEST "$expect" "pass;rc=$RC" match "$(printf '%s' "$sel" | cap)"
  else
    report PRIOR-SELFTEST "$expect" "fail;rc=$RC" mismatch \
      "prior battery fixtures regressed: $(printf '%s' "${sel:-no-selftest-line}" | cap)"
  fi
}

# ------------------------------------------------------------------ selftest --
selftest_main() {
  local pass=0 fail=0
  st() { local name=$1; shift
    if "$@" >/dev/null 2>&1; then pass=$((pass+1));
    else fail=$((fail+1)); echo "FINDING R66C-CTL-ST-$name"; fi
  }
  local W=$SCR

  # parsers on the frozen line shapes
  p_c1 'C1_CARRIER: drift=0 paths=3 hex=3 match=1 guard=0'
  st c1-parse-base test "$R1_DRIFT" = 0 -a "$R1_MATCH" = 1 -a "$R1_GUARD" = 0
  p_c2 'PREFILE-FALSIFICATION: pass claims=3 rows=9 attack_seats=5 findings=0'
  st c2-parse-pass test "$R2_VERDICT" = pass -a "$R2_CLAIMS" = 3 -a "$R2_ROWS" = 9 -a "$R2_SEATS" = 5 -a "$R2_FIND" = 0
  p_c2 'PREFILE-FALSIFICATION: SETUP findings=3'
  st c2-parse-setup test "$R2_VERDICT" = setup -a "$R2_FIND" = 3
  p_c2 'PREFILE-FALSIFICATION: FAIL findings=2'
  st c2-parse-fail test "$R2_VERDICT" = fail -a "$R2_FIND" = 2
  p_c3 'SOURCES_CENSUS: FAILED (findings=4 rows=155)'
  st c3-parse-failed test "$R3_VERDICT" = FAILED -a "$R3_FIND" = 4 -a "$R3_ROWS" = 155
  p_c3 'SOURCES_CENSUS: CLEAN (findings=0 rows=156)'
  st c3-parse-clean test "$R3_VERDICT" = CLEAN -a "$R3_FIND" = 0 -a "$R3_ROWS" = 156

  # accounting + exit contract
  local out
  out=$( M=0; K=0; S=0
         report t/a e o match; report t/b e o mismatch; report t/c e absent skip
         printf '%s' "$((M))$((K))$((S))" )
  st report-counting test "$out" = 111

  # ---- fixture scaffolding: a fleet dir with the pre-file gate -------------
  # The claims are measured on <fleet>/kagi-shokunin, exactly as the real lane
  # resolves (the gate reads <fleet>/scripts/hyaku/prefile-falsification.py).
  mk_gate() { # FLEET MODE(pass|setup)
    mkdir -p "$1/scripts/hyaku"
    if [ "$2" = pass ]; then
      cat > "$1/scripts/hyaku/prefile-falsification.py" <<'GATE'
#!/usr/bin/env python3
import os, sys
a = sys.argv[1:]
fleet = a[a.index("--fleet") + 1]
led = os.path.join(fleet, "kagi-shokunin", ".ufo", "waves", "round-66", "claim-falsification.tsv")
rows = []
if os.path.isfile(led):
    rows = [l.split("\t")[0] for l in open(led) if l.strip()]
missing = [c for c in ("C1", "C2", "C3") if c not in rows]
if missing:
    print("FINDING claim-uncovered %s" % ",".join(missing))
    print("PREFILE-FALSIFICATION: FAILED findings=%d" % len(missing))
    sys.exit(1)
print("PREFILE-FALSIFICATION: pass claims=3 rows=%d attack_seats=5 findings=0" % len(rows))
sys.exit(0)
GATE
    else
      cat > "$1/scripts/hyaku/prefile-falsification.py" <<'GATE'
#!/usr/bin/env python3
import sys
print("PREFILE-FALSIFICATION: SETUP findings=3")
sys.exit(2)
GATE
    fi
  }
  mk_base_tree() { mkdir -p "$1/kagi-shokunin/corpus" "$1/kagi-shokunin/plans" 2>/dev/null
    printf 'x\n' > "$1/kagi-shokunin/corpus/SOURCES.md"
    printf '# plan\n' > "$1/kagi-shokunin/plans/round-65.md"; }

  # ---- fixture A: a tree whose claims read their BASE values ---------------
  # C1 names a carrier and reports the wrong-path anchor as a digest
  # mismatch (so FORGE fires and is refused); census FAILED; no ledger.
  # Expect: C1/C3 NOWORK match, C2 NOWORK match (gate SETUP on BASE),
  # C1-FORGE match, C2-FORGE/C3-FORGE skip, VALID x3 mismatch.
  local FL=$W/fleetA
  local FT=$FL/kagi-shokunin
  mkdir -p "$FT/plans" "$FT/corpus/knowledge" "$FT/.ufo/waves/round-66" "$FT/.ufo/waves/round-64/capture"
  mk_gate "$FL" setup
  cat > "$FT/plans/round-66-c1.sh" <<'F1'
#!/usr/bin/env bash
if [ "${1:-}" = "--selftest" ]; then echo "C1_CARRIER_SELFTEST: PASS (cases=15)"; exit 0; fi
t=${2:-}
if grep -q 'S148\.body' "$t/corpus/SOURCES.md" 2>/dev/null; then
  echo "c1-carrier: row=S164 path=digest-mismatch:.ufo/waves/round-64/capture/S148.body"
  echo "C1_CARRIER: drift=0 paths=3 hex=3 match=1 guard=0"
  exit 1
fi
echo "c1-carrier: row=S164 path=.ufo/waves/round-64/capture/S143.body"
echo "C1_CARRIER: drift=0 paths=3 hex=3 match=1 guard=0"
exit 1
F1
  printf '#!/usr/bin/env bash\necho "SOURCES_CENSUS: FAILED (findings=4 rows=155)"\nexit 0\n' > "$FT/corpus/sources-census.sh"
  printf '#!/usr/bin/env bash\necho "CLAIMS_DECLARED: CLEAN (claims=56)"\nexit 0\n' > "$FT/corpus/claims-declared.sh"
  printf 'row cites .ufo/waves/round-64/capture/S143.body\n' > "$FT/corpus/SOURCES.md"
  printf 'fetch .ufo/waves/round-64/capture/S143.body\n' > "$FT/corpus/source-fetches.tsv"
  printf 'x\n' > "$FT/corpus/volatile-shape.py"
  printf -- '---\ncites: S148\n---\nbody\n' > "$FT/corpus/knowledge/e.md"
  printf 'candidate\n' > "$FT/.ufo/waves/round-64/capture/S143.body"
  printf 'arxiv\n' > "$FT/.ufo/waves/round-64/capture/S148.body"
  printf '# plan\n' > "$FT/plans/round-66.md"
  chmod +x "$FT/corpus/"*.sh "$FT/plans/"*.sh
  cp "$SELFPATH" "$FT/plans/round-66-controls.sh"
  mk_gate "$W/baseA" setup; mk_base_tree "$W/baseA"
  local outA rcA
  outA=$(cd "$FL" && R66_CONTROLS_RECEIPT=/dev/null R66_CONTROLS_FIXTURE_ONLY=1 \
         R66_CONTROLS_BASE_TREE="$W/baseA/kagi-shokunin" bash "$FT/plans/round-66-controls.sh" "$FT" 2>&1); rcA=$?
  st fx-c1nowork-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-NOWORK .*verdict=match'" "$outA"
  st fx-c2nowork-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-NOWORK .*verdict=match'" "$outA"
  st fx-c3nowork-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-NOWORK .*verdict=match'" "$outA"
  st fx-c1forge-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-FORGE .*verdict=match'" "$outA"
  st fx-c2forge-skip sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-FORGE .*verdict=skip'" "$outA"
  st fx-c3forge-skip sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-FORGE .*verdict=skip'" "$outA"
  st fx-c1valid-mismatch sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-VALID .*verdict=mismatch'" "$outA"
  st fx-c2valid-mismatch sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-VALID .*verdict=mismatch'" "$outA"
  st fx-c3valid-mismatch sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-VALID .*verdict=mismatch'" "$outA"

  # ---- fixture B: a tree whose claims are met ------------------------------
  # Expect: VALID x3 match, C2-FORGE/C3-FORGE match, C1-FORGE skip (no
  # carrier cited), C3-NOWORK mismatch (the BASE tree reads CLEAN there, i.e.
  # the control catches a do-nothing tree that already reaches the target).
  local FL2=$W/fleetB
  local FT2=$FL2/kagi-shokunin
  mkdir -p "$FT2/plans" "$FT2/corpus/knowledge" "$FT2/.ufo/waves/round-66/w1/R66Critic" \
           "$FT2/.ufo/waves/round-64/capture" "$FT2/.ufo/reports/round-66"
  mk_gate "$FL2" pass
  cat > "$FT2/plans/round-66-c1.sh" <<'G1'
#!/usr/bin/env bash
if [ "${1:-}" = "--selftest" ]; then echo "C1_CARRIER_SELFTEST: PASS (cases=15)"; exit 0; fi
echo "C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1"
exit 0
G1
  cat > "$FT2/corpus/sources-census.sh" <<'CENS'
#!/usr/bin/env bash
root=. ; while [ $# -gt 0 ]; do case "$1" in --root) root=$2; shift 2;; *) shift;; esac; done
if [ -d "$root/corpus/knowledge" ] && grep -qE '^cites:' "$root"/corpus/knowledge/*.md 2>/dev/null; then
  echo "SOURCES_CENSUS: CLEAN (findings=0 rows=156)"; exit 0
fi
echo "FINDING SC_USEDBY_MISSING path=corpus/knowledge/e.md"
echo "SOURCES_CENSUS: FAILED (findings=1 rows=156)"; exit 0
CENS
  printf '#!/usr/bin/env bash\necho "CLAIMS_DECLARED: CLEAN (claims=59)"\nexit 0\n' > "$FT2/corpus/claims-declared.sh"
  printf 'x\n' > "$FT2/corpus/SOURCES.md"
  printf 'x\n' > "$FT2/corpus/source-fetches.tsv"
  printf 'x\n' > "$FT2/corpus/volatile-shape.py"
  printf -- '---\ncites: S148\n---\nbody\n' > "$FT2/corpus/knowledge/e.md"
  printf 'candidate\n' > "$FT2/.ufo/waves/round-64/capture/S143.body"
  printf 'arxiv\n' > "$FT2/.ufo/waves/round-64/capture/S148.body"
  printf 'C1\tC1\tq\tfile\tw1/R66Critic/findings.md\nC2\tC2\tq\tfile\tw1/R66Critic/findings.md\nC3\tC3\tq\tfile\tw1/R66Critic/findings.md\n' > "$FT2/.ufo/waves/round-66/claim-falsification.tsv"
  printf '{"C1":{},"C2":{},"C3":{}}\n' > "$FT2/.ufo/waves/round-66/claims.json"
  printf '{"tasks":[]}\n' > "$FT2/.ufo/waves/round-66/w1-results.json"
  printf '# report\n' > "$FT2/.ufo/reports/round-66/kagi.md"
  printf 'x\n' > "$FT2/.ufo/waves/round-66/w1/R66Critic/findings.md"
  printf '# plan\n' > "$FT2/plans/round-66.md"
  chmod +x "$FT2/corpus/"*.sh "$FT2/plans/"*.sh
  cp "$SELFPATH" "$FT2/plans/round-66-controls.sh"
  mk_gate "$W/baseB" setup; mk_base_tree "$W/baseB"
  local outB rcB
  outB=$(cd "$FL2" && R66_CONTROLS_RECEIPT=/dev/null R66_CONTROLS_FIXTURE_ONLY=1 \
         R66_CONTROLS_BASE_TREE="$W/baseB/kagi-shokunin" bash "$FT2/plans/round-66-controls.sh" "$FT2" 2>&1); rcB=$?
  st fx-ok-c1valid-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-VALID .*verdict=match'" "$outB"
  st fx-ok-c2valid-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-VALID .*verdict=match'" "$outB"
  st fx-ok-c3valid-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-VALID .*verdict=match'" "$outB"
  st fx-ok-c2forge-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-FORGE .*verdict=match'" "$outB"
  st fx-ok-c3forge-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-FORGE .*verdict=match'" "$outB"
  st fx-ok-c1forge-skip sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-FORGE .*verdict=skip'" "$outB"
  st fx-ok-c3nowork-match sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-NOWORK .*verdict=match'" "$outB"

  # ---- fixture E: a do-nothing tree that already reaches the target -------
  # The census prints CLEAN on every root, so the BASE reading equals the
  # candidate reading; C3-NOWORK must catch that as a vacuous claim.
  local FL5=$W/fleetE
  local FT5=$FL5/kagi-shokunin
  mkdir -p "$FT5/plans" "$FT5/corpus"
  printf '#!/usr/bin/env bash\necho "SOURCES_CENSUS: CLEAN (findings=0 rows=156)"\nexit 0\n' > "$FT5/corpus/sources-census.sh"
  printf 'x\n' > "$FT5/corpus/SOURCES.md"
  cp "$SELFPATH" "$FT5/plans/round-66-controls.sh"
  mk_base_tree "$W/baseE"
  local outE rcE
  outE=$(R66_CONTROLS_RECEIPT=/dev/null R66_CONTROLS_FIXTURE_ONLY=1 R66_CONTROLS_BASE_TREE="$W/baseE/kagi-shokunin" \
         bash "$FT5/plans/round-66-controls.sh" "$FT5" 2>&1); rcE=$?
  st fx-e-nowork-mismatch sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-NOWORK .*verdict=mismatch'" "$outE"
  st fx-e-rc1 test $rcE = 1

  # ---- fixture C: no measurement surface at all -> every claim skips ------
  local FL3=$W/fleetC
  local FT3=$FL3/kagi-shokunin
  mkdir -p "$FT3/plans"
  cp "$SELFPATH" "$FT3/plans/round-66-controls.sh"
  mk_base_tree "$W/baseC"
  local outC rcC
  outC=$(R66_CONTROLS_RECEIPT=/dev/null R66_CONTROLS_FIXTURE_ONLY=1 R66_CONTROLS_BASE_TREE="$W/baseC/kagi-shokunin" \
         bash "$FT3/plans/round-66-controls.sh" "$FT3" 2>&1); rcC=$?
  st fx-empty-allskip sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-NOWORK .*verdict=skip' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C2-NOWORK .*verdict=skip' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C3-NOWORK .*verdict=skip' && printf '%s\n' \"\$0\" | grep -q '^CONTROL C1-VALID .*verdict=skip'" "$outC"
  st fx-empty-nopass sh -c "! printf '%s\n' \"\$0\" | grep -q 'verdict=match'" "$outC"
  st fx-empty-rc0 test $rcC = 0

  # ---- fixture D: full mode carries the PRIOR row ------------------------
  local FT4=$W/fx-prior
  mkdir -p "$FT4/plans"
  cat > "$FT4/plans/round-64-controls.sh" <<'H1'
#!/usr/bin/env bash
[ "${1:-}" = "--selftest" ] || exit 2
echo "CONTROLS_SELFTEST: PASS (cases=36)"
exit 0
H1
  chmod +x "$FT4/plans/round-64-controls.sh"
  cp "$SELFPATH" "$FT4/plans/round-66-controls.sh"
  local outD
  outD=$(R66_CONTROLS_RECEIPT=/dev/null bash "$FT4/plans/round-66-controls.sh" "$FT4" 2>&1)
  st fx-prior-row sh -c "printf '%s\n' \"\$0\" | grep -q '^CONTROL PRIOR-SELFTEST .*verdict=match'" "$outD"

  if [ "$fail" = 0 ]; then
    echo "CONTROLS_SELFTEST: PASS (cases=$pass)"
    exit 0
  fi
  echo "CONTROLS_SELFTEST: FAIL (cases=$((pass+fail)) failed=$fail)"
  exit 1
}

# ------------------------------------------------------------------- main -----
CAND=""
main() {
  local arg=${1:-$REPO}
  if [ "$arg" = "--selftest" ]; then selftest_main; exit $?; fi
  case $arg in
    --tree) CAND=$(cd "${2:-}" 2>/dev/null && pwd -P) || { echo "SETUP candidate-tree-unusable at ${2:-}"; exit 2; };;
    *)      CAND=$(cd "$arg" 2>/dev/null && pwd -P) || { echo "SETUP candidate-tree-unusable at $arg"; exit 2; };;
  esac
  [ -d "$CAND" ] || { echo "SETUP candidate-tree-unusable at $CAND"; exit 2; }
  if [ "${3:-}" = "--base" ] && [ -n "${4:-}" ]; then BASE_REV=$4; fi

  emit "# round-66 pre-freeze control battery (plans/round-66-controls.sh)"
  emit "# self $(sha_of "$0")"
  emit "# utc $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  emit "# repo $REPO"
  emit "# candidate $CAND"
  emit "# base $BASE_REV"
  emit "# claims C1=plans/round-66-c1.sh(A1) C2=prefile-gate+claims-declared(A2) C3=lane-census(A3)"
  local f
  for f in "$C1CTR_REL" "$CENSUS_REL" "$DECLARED_REL" "$PRIOR_REL"; do
    if [ -f "$CAND/$f" ]; then emit "INSTRUMENT $f $(sha_of "$CAND/$f")"
    else emit "INSTRUMENT $f MISSING"; fi
  done
  if [ -f "$(dirname "$CAND")/$PREFILE_REL" ]; then
    emit "INSTRUMENT $PREFILE_REL $(sha_of "$(dirname "$CAND")/$PREFILE_REL")"
  else
    emit "INSTRUMENT $PREFILE_REL MISSING"
  fi

  probe
  ctrl_c1_nowork; ctrl_c1_forge; ctrl_c1_valid
  ctrl_c2_nowork; ctrl_c2_forge; ctrl_c2_valid
  ctrl_c3_nowork; ctrl_c3_forge; ctrl_c3_valid
  if [ "${R66_CONTROLS_FIXTURE_ONLY:-0}" = 1 ]; then
    emit "# fixture-only: PRIOR delegation skipped (R66_CONTROLS_FIXTURE_ONLY=1)"
  else
    ctrl_prior
  fi

  emit "SKIPS: $S"
  emit "CONTROLS: match=$M mismatch=$K"
  if [ "$K" -eq 0 ]; then emit "SEAT-STATUS: complete"
  else emit "SEAT-STATUS: partial mismatch-count=$K (see DETAIL lines; the L1 re-runs the full battery after integration)"; fi

  cat "$BODY"
  local dest="${R66_CONTROLS_RECEIPT:-$REPO/$CTLDIR_REL/controls-last.txt}"
  if mkdir -p "$(dirname "$dest")" 2>/dev/null && cp "$BODY" "$dest" 2>/dev/null; then :; else
    say "RECEIPT-INSTALL-FAILED: could not write $dest"
  fi
  [ "$K" -eq 0 ] && return 0 || return 1
}

main "$@"
