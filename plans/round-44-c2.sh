#!/usr/bin/env bash
# plans/round-44-c2.sh -- round 44 C2 counter (operability: the round-43 freshness gate
# corpus/controls-replay.sh was never run by anything after landing -- round-43 routed item 3;
# this counter verifies a committed receipt of the gate's own run and re-executes the gate).
#
# Frozen predicate (the same sentence appears in plans/round-44.md section C2 and in the
# receipt labels): prints ONE unsigned integer N in {0,1}. N = 1 iff, for the candidate
# revision (argument, default HEAD of the repository this file lives in):
#   (a) a receipt is provided: the committed bytes at
#       .ufo/waves/round-44/final/replay-at-tip.txt (fixture override: R44_RECEIPT=<path>;
#       the executed leg still runs);
#   (b) the receipt parses as exactly four lines, in order: `controls-replay: CLEAN`,
#       `revision: <R>`, `gate-sha256: <S>`, `exit: 0`, where R is a full 40-hex revision
#       that exists, is an ancestor of the candidate, and whose corpus/controls-replay.sh
#       bytes hash to S; and S also equals the candidate's own corpus/controls-replay.sh
#       hash (the receipt binds exactly the candidate's gate bytes);
#   (c) executed: in a fresh shared clone of the candidate, `bash <clone>/corpus/
#       controls-replay.sh --clone <clone>` exits 0 with last line `controls-replay: CLEAN`.
# Otherwise N = 0. A missing receipt reads 0 (the do-nothing control at the claim BASE).
# Fail closed (rc 2, nothing on stdout): missing candidate revision, unusable clone or
# scratch, or candidate gate bytes that cannot be read. A present-but-unparseable receipt,
# a wrong hash, a wrong exit line, a non-ancestor or unknown revision, and a gate that
# refuses the clean clone each read 0 -- they are false receipts, not setup errors.
set -u

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
CAND=${1:-$(git -C "$REPO" rev-parse HEAD)}
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r44/receipt.$$
mkdir -p -- "$SCR" || { echo "counter-refused: scratch root" >&2; exit 2; }
trap 'rm -rf -- "$SCR"' EXIT

git -C "$REPO" cat-file -e "$CAND^{commit}" 2>/dev/null \
  || { echo "counter-refused: candidate" >&2; exit 2; }

if [ -n "${R44_RECEIPT:-}" ]; then
  [ -f "$R44_RECEIPT" ] || { echo "counter-refused: override receipt" >&2; exit 2; }
  cp "$R44_RECEIPT" "$SCR/receipt"
else
  git -C "$REPO" show "$CAND:.ufo/waves/round-44/final/replay-at-tip.txt" > "$SCR/receipt" 2>/dev/null \
    || { echo 0; exit 0; }
fi

GATE_SHA_CAND=$(git -C "$REPO" show "$CAND:corpus/controls-replay.sh" 2>/dev/null | sha256sum | cut -d' ' -f1)
[ -n "$GATE_SHA_CAND" ] || { echo "counter-refused: gate bytes" >&2; exit 2; }

[ "$(wc -l < "$SCR/receipt")" -eq 4 ] || { echo 0; exit 0; }
L1=$(sed -n '1p' "$SCR/receipt")
L2=$(sed -n '2p' "$SCR/receipt")
L3=$(sed -n '3p' "$SCR/receipt")
L4=$(sed -n '4p' "$SCR/receipt")
[ "$L1" = "controls-replay: CLEAN" ] || { echo 0; exit 0; }
case "$L2" in "revision: "*) R=${L2#"revision: "} ;; *) echo 0; exit 0 ;; esac
case "$L3" in "gate-sha256: "*) S=${L3#"gate-sha256: "} ;; *) echo 0; exit 0 ;; esac
[ "$L4" = "exit: 0" ] || { echo 0; exit 0; }

printf '%s' "$R" | grep -qE '^[0-9a-f]{40}$' || { echo 0; exit 0; }
git -C "$REPO" cat-file -e "$R^{commit}" 2>/dev/null || { echo 0; exit 0; }
git -C "$REPO" merge-base --is-ancestor "$R" "$CAND" 2>/dev/null || { echo 0; exit 0; }
[ "$S" = "$GATE_SHA_CAND" ] || { echo 0; exit 0; }
GATE_SHA_R=$(git -C "$REPO" show "$R:corpus/controls-replay.sh" 2>/dev/null | sha256sum | cut -d' ' -f1)
[ -n "$GATE_SHA_R" ] && [ "$S" = "$GATE_SHA_R" ] || { echo 0; exit 0; }

git clone -q --shared "$REPO" "$SCR/clone" || { echo "counter-refused: clone" >&2; exit 2; }
git -C "$SCR/clone" checkout -q --detach "$CAND" || { echo "counter-refused: checkout" >&2; exit 2; }
[ -f "$SCR/clone/corpus/controls-replay.sh" ] || { echo 0; exit 0; }
OUT=$(bash "$SCR/clone/corpus/controls-replay.sh" --clone "$SCR/clone" 2>/dev/null)
RC=$?
LAST=$(printf '%s\n' "$OUT" | tail -1)
if [ "$RC" -eq 0 ] && [ "$LAST" = "controls-replay: CLEAN" ]; then
  echo 1
else
  echo 0
fi
exit 0
