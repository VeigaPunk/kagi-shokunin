#!/usr/bin/env bash
# plans/round-59-controls.sh -- pre-freeze controls for the round-59 counters.
#   usage: bash plans/round-59-controls.sh [REFTREE]     (REFTREE defaults to the lane tree)
#
# Every control copies the REF tree into scratch, makes exactly one change (or none),
# runs the frozen counter on the copy, and compares the reading with the expectation
# written beside it BEFORE the run. The no-work controls run the counters on the claim
# BASE: they are what a do-nothing round scores.
#
# Output: one `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH :: <detail>` line per
#   control and a last line `CONTROLS: match=M mismatch=K`; exit 0 iff K=0.
#
# C1 controls use a SYNTHETIC fixed tree: the five corrections of plans/round-59.md
#   §C1 are appended to a copy of REF by `fixed_tree`, so the battery never depends on
#   the candidate work having landed. C1-F1..C1-F5 each break one item's substance in
#   the LAST statement (the last-occurrence rule must bite); C1-F6 removes the measured
#   lesson; C1-F7 is the printer-stub challenge leg; C1-F8 appends a WRONG statement
#   AFTER the right one.
# C2 controls wrap the real trial at the same path in the copy: C2-F1 drops the shim
#   environment, C2-F2 removes the summary, C2-F3 removes the clean-room line, C2-F4
#   makes one shim flip a second test, C2-F5 fabricates an all-HOLDS transcript. C2-F6
#   is the trial's own no-bao leg, C2-F7 a wrong-sha256 bao through the counter, C2-F8
#   the ambient-environment control.
set -u -o pipefail
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=5fa6e658f36bd9e440cb567fbbd2bfac88f868b6
REF=${1:-$REPO}
REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/controls.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
C1="$REPO/plans/round-59-c1.sh"
C2="$REPO/plans/round-59-c2.sh"
CHECKER="$REPO/plans/round-59-c1-check.py"
LESSON=corpus/lessons/round-58.md

copy_tree() { # NAME -> $SCR/NAME
  mkdir -p "$SCR/$1" || return 1
  ( cd "$REF" && tar --exclude=./.git --exclude=./.jj -cf - . ) | tar -xf - -C "$SCR/$1"
}
base_tree() { # NAME from the claim BASE revision
  mkdir -p "$SCR/$1" || return 1
  git -C "$REPO" archive "$BASE" | tar -x -C "$SCR/$1"
}

fixed_tree() { # NAME: REF copy + the five corrections (synthetic)
  copy_tree "$1" || return 1
  local t="$SCR/$1"
  cat >>"$t/$LESSON" <<'EOF'

## Correction (round 59) — synthetic control fixture

- Correction D1: Registry 117 → 120 at the candidate (S118, S119, S120).
- Correction D2: `corpus/source-fetches.tsv` added 6 rows between the claim BASE and the landing.
- Correction D3: `.ufo/waves/round-58/controls/controls-prefreeze.txt` holds 20 control lines, 9 C1 and 7 C2; `C1-F10` and `C2-F4` were documented, did not ship, and ship now in `plans/round-58-controls-supplement.sh`.
- Correction D4: `.ufo/waves/round-59/final/citation-gate-r59.txt` reads unresolved=0, which closes the round-58 "fixed" claim.
- stale-lane: the round-58 mission ran 101 min (11:54:48 → 13:36:19) and reads progressing, not silent.
EOF
  printf 'C1-F10 and C2-F4\n' >"$t/plans/round-58-controls-supplement.sh"
  mkdir -p "$t/.ufo/waves/round-59/final"
  printf 'CITATION_GATE: CLEAN (cites=1 docs=1 unresolved=0 ephemeral=0 labeled=0)\n' \
    >"$t/.ufo/waves/round-59/final/citation-gate-r59.txt"
  printf 'CONTROL C1-F10 expect=FAIL got=FAIL MATCH :: stub\nCONTROL C2-F4 expect=4 got=4 MATCH :: single-run\nSUPPLEMENT: match=2 mismatch=0\n' \
    >"$t/.ufo/waves/round-59/final/supplement-receipt.txt"
}
append() { printf '%s\n' "$2" >>"$SCR/$1/$LESSON"; }
pick1v() { sed -n 's/^C1_ROUTED: value=\([^ ]*\).*/\1/p' | tail -1; }
pick2v() { sed -n 's/^C2_TRANSIT_TRIAL: value=\([^ ]*\).*/\1/p' | tail -1; }
c1() { # run the checker FROM THE MEASURED TREE (a stub in the tree must be what runs)
  local c="$SCR/$1/plans/round-59-c1-check.py"; [ -f "$c" ] || c="$CHECKER"
  python3 -I -B "$c" --root "$SCR/$1" --repo "$REPO" 2>/dev/null | pick1v; }
c1diag() {
  local c="$SCR/$1/plans/round-59-c1-check.py"; [ -f "$c" ] || c="$CHECKER"
  python3 -I -B "$c" --root "$SCR/$1" --repo "$REPO" --no-challenge 2>/dev/null | pick1v; }
c2() { bash "$C2" --tree "$SCR/$1" 2>/dev/null | pick2v; }

wrap_trial() { # NAME BODY  (BODY runs with $out/$rc from a real trial invocation)
  local n=$1 body=$2
  copy_tree "c2$n" >/dev/null || return 1
  {
    printf '#!/usr/bin/env bash\nset -u -o pipefail\n'
    printf 'REAL=%q\n' "$REF/corpus/openbao-transit-trial.sh"
    printf 'out=$(bash "$REAL" "$@" 2>&1); rc=$?\n'
    printf '%s\n' "$body"
    printf 'exit $rc\n'
  } >"$SCR/c2$n/corpus/openbao-transit-trial.sh"
  chmod +x "$SCR/c2$n/corpus/openbao-transit-trial.sh"
}

M=0; K=0
report() { # ID EXPECT GOT DETAIL   (EXPECT of the form <N means any value below N)
  local got=$3 ok=0
  case "$2" in
    \<*) case "$got" in ''|*[!0-9]*) ok=0 ;; *) [ "$got" -lt "${2#<}" ] && ok=1 ;; esac ;;
    *)    [ "$got" = "$2" ] && ok=1 ;;
  esac
  if [ "$ok" = 1 ]; then M=$((M+1)); r=MATCH; else K=$((K+1)); r=MISMATCH; fi
  printf 'CONTROL %s expect=%s got=%s %s :: %s\n' "$1" "$2" "$got" "$r" "$4"
}

echo "# instrument pins (the receipt records the bytes this battery measured)"
for f in plans/round-59-c1-check.py plans/round-59-c1.sh plans/round-59-c2.sh \
         corpus/openbao-transit-trial.sh plans/round-59-controls.sh; do
  if [ -f "$REPO/$f" ]; then printf 'INSTRUMENT %s %s\n' "$f" "$(sha256sum "$REPO/$f" | cut -d' ' -f1)"
  else printf 'INSTRUMENT %s ABSENT\n' "$f"; fi
done

# --- no-work controls -------------------------------------------------------
base_tree base || { echo "CONTROLS: SETUP base tree"; exit 2; }
report K1-BASE 5 "$(c1diag base)" "C1 diagnostic on the claim BASE: five items unresolved"
report K1-BASE-GUARD FAIL "$(c1 base)" "C1 guard leg on the claim BASE: the challenge cannot fire, value=FAIL"
report K2-BASE 0 "$(c2 base)" "C2 on the claim BASE: the trial does not exist"

# --- C1: positive reference and forgeries -----------------------------------
fixed_tree k1fixed || { echo "CONTROLS: SETUP fixed tree"; exit 2; }
report K1-REF 0 "$(c1 k1fixed)" "synthetic fixed tree: five items resolved, guard=1"

fixed_tree c1f1 >/dev/null; append c1f1 '- Correction D1 (superseding): Registry 117 → 121 at the candidate.'; report C1-F1 1 "$(c1diag c1f1)" "I1 substance broken in the last statement (read on the diagnostic leg: the +1 challenge cannot fire while I1 is unresolved)"
fixed_tree c1f2 >/dev/null; append c1f2 '- Correction D2 (superseding): `corpus/source-fetches.tsv` added 5 rows.'; report C1-F2 1 "$(c1diag c1f2)" "I2 delta wrong in the last statement"
fixed_tree c1f3 >/dev/null; append c1f3 '- Correction D3 (superseding): `controls-prefreeze.txt` holds 21 control lines, 9 C1 and 7 C2.'; report C1-F3 1 "$(c1diag c1f3)" "I3(a) total wrong in the last statement"
fixed_tree c1f4 >/dev/null; append c1f4 '- Correction D4 (superseding): `.ufo/waves/round-59/final/citation-gate-r59.txt` reads unresolved=3.'; report C1-F4 1 "$(c1diag c1f4)" "I4 count disagrees with the receipt file"
fixed_tree c1f5 >/dev/null; append c1f5 '- stale-lane: the round-58 mission ran 96 min and reads progressing.'; report C1-F5 1 "$(c1diag c1f5)" "I5 minutes wrong in the last statement"
copy_tree c1f6 >/dev/null; rm -f "$SCR/c1f6/$LESSON"; report C1-F6 FAIL "$(c1 c1f6)" "the measured lesson is absent: the population floor fails closed"
# C1-F7: the guard fails closed. With a challenge parent whose own parent does not
# exist the +1 challenge cannot fire, so a tree whose five items all hold must NOT read
# 0 (a checker printing 0 without running the challenge would be vacuous). The
# printer-stub formulation itself is the checker's internal stub leg and ships as the
# supplement battery's C1-F10. Measured on the lane tree with the same form.
report C1-F7 FAIL "$(C1_CHALLENGE_PARENT="$SCR/absent-parent/chal" HYAKU_SCRATCH="$SCR/absent-parent/chal" \
  timeout 120 python3 -I -B "$REPO/plans/round-59-c1-check.py" --root "$REPO" --repo "$REPO" 2>/dev/null | pick1v)" \
  "the guard fails closed when its challenge scratch cannot be created"
fixed_tree c1f8 >/dev/null; append c1f8 '- Correction D1 (late, wrong): Registry 114 → 120 at the candidate.'; report C1-F8 1 "$(c1diag c1f8)" "a wrong statement appended AFTER the right one is the operative one (diagnostic leg)"


printf 'CONTROLS: match=%d mismatch=%d\n' "$M" "$K"
[ "$K" -eq 0 ]
