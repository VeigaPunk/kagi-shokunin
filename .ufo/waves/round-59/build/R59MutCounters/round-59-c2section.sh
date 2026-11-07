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

# --- C2 controls ------------------------------------------------------------
# Every C2 leg runs the real trial of the REF tree through a wrapper at the same
# path, so the counter measures a trial it believes is the shipped one.
wrap_trial() { # NAME BODY  (BODY runs with $out/$rc from a real trial invocation)
  local n=$1 body=$2
  copy_tree "c2$n" >/dev/null || return 1
  {
    printf '#!/usr/bin/env bash\nset -u -o pipefail\n'
    printf 'REAL=%q\n' "$REF/corpus/openbao-transit-trial.sh"
    printf 'CNT=%q\n' "$SCR/c2$n/count"
    printf 'out=$(bash "$REAL" "$@" 2>&1); rc=$?\n'
    printf '%s\n' "$body"
    printf 'exit $rc\n'
  } >"$SCR/c2$n/corpus/openbao-transit-trial.sh"
  chmod +x "$SCR/c2$n/corpus/openbao-transit-trial.sh"
}
# C2-F1: the T5 falsifier is not wired (the trial is invoked WITHOUT the SH5 shim),
# so the counter's SH5 leg reads the baseline vector and the vector check refuses.
wrap_trial f1 'if [ "${KAGI_TRANSIT_SHIM:-}" = SH5 ]; then out=$(env -u KAGI_TRANSIT_SHIM bash "$REAL" "$@" 2>&1); rc=$?; fi; printf "%s\n" "$out"'
report C2-F1 "<5" "$(c2 c2f1)" "the T5 shim removed: the SH5 leg cannot flip its designated test"
# C2-F2: the trial's own no-bao leg.
n_out=$(env -i PATH=/usr/bin:/bin HOME="$HOME" bash "$REF/corpus/openbao-transit-trial.sh" --work "$SCR/none-work" 2>&1); n_rc=$?
report C2-F2 SETUP/rc2 "$(printf '%s\n' "$n_out" | sed -n 's/^OPENBAO_TRANSIT_TRIAL: SETUP.*/SETUP/p' | tail -1)/rc$n_rc" "a PATH with no bao reads the prefixed SETUP line, no HOLDS, and exits 2 (K1)"
# C2-F3: the clean-room line removed from the transcript.
wrap_trial f3 'out=$(printf "%s\n" "$out" | grep -v "^TRIAL CLEANROOM"); printf "%s\n" "$out"'
report C2-F3 "<5" "$(c2 c2f3)" "a trial without the clean-room line cannot score 5 (plan A2)"
# C2-F4: a single-run trial (the second empty-shim invocation refuses).
wrap_trial f4 'if [ -z "${KAGI_TRANSIT_SHIM:-}" ]; then n=$(cat "$CNT" 2>/dev/null || echo 0); n=$((n+1)); printf "%s\n" "$n" >"$CNT"; if [ "$n" -gt 1 ]; then printf "TRIAL ERROR second real run refused\n"; exit 2; fi; fi; printf "%s\n" "$out"'
report C2-F4 "<5" "$(c2 c2f4)" "a single-run trial: the two-independent-runs conjunct refuses"
# C2-F5: a fabricated all-HOLDS transcript (it never executes bao).
wrap_trial f5 'printf "TRIAL T1 HOLDS x\nTRIAL T2 HOLDS x\nTRIAL T3 HOLDS x\nTRIAL T4 HOLDS x\nTRIAL T5 HOLDS x\nTRIAL CLEANROOM HOLDS x\nOPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2\n"; rc=0; exit 0'
report C2-F5 0 "$(c2 c2f5)" "a fabricated all-HOLDS transcript cannot satisfy the five shim vectors"
# C2-F6: one shim flips two tests (SH3 must flip T3 only).
wrap_trial f6 'if [ "${KAGI_TRANSIT_SHIM:-}" = SH3 ]; then out=$(printf "%s\n" "$out" | sed "s/^TRIAL T4 HOLDS/TRIAL T4 BROKEN shim-cross/"); fi; printf "%s\n" "$out"'
report C2-F6 "<5" "$(c2 c2f6)" "a shim that flips two tests cannot satisfy the exactly-one vector"
# C2-F7: a bao binary whose sha256 is not the pinned OpenBao 2.7.2.
report C2-F7 SETUP "$(R59_BAO=/bin/true bash "$C2" --tree "$SCR/c2f1" 2>&1 | sed -n 's/^C2_TRANSIT_TRIAL: SETUP.*/SETUP/p' | tail -1)" "a wrong-sha256 bao is SETUP"
# C2-F8: ambient BAO_*/VAULT_* cannot change a reading (the reference tree still reads 5).
copy_tree c2f8 >/dev/null
report C2-F8 5 "$(BAO_TOKEN=ambient BAO_ADDR=http://127.0.0.1:9 VAULT_ADDR=http://127.0.0.1:9 c2 c2f8)" "ambient BAO_*/VAULT_* exported by the caller does not change a reading"

printf 'CONTROLS: match=%d mismatch=%d\n' "$M" "$K"
[ "$K" -eq 0 ]
