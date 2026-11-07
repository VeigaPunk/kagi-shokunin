#!/usr/bin/env bash
# plans/round-58-controls-supplement.sh — the two controls the round-58
# pre-freeze battery documented and did not ship (verifier spot-check D3;
# plans/round-58.md §Pre-freeze controls names both, plans/round-58-controls.sh
# never implemented them):
#
#   C1-F10 — a printer stub that always prints `value=0` must fail the
#            round-59 C1 challenge leg. The challenge's only delta is the
#            digit after the arrow on the LAST `Registry N → M at the
#            candidate` line of corpus/lessons/round-58.md changed M -> M+1
#            (plans/round-59.md §C1 GUARD); the real checker must read
#            value+1 on that copy while the constant-0 stub cannot.
#   C2-F4  — a single-run copy of the transit trial must read < 5 under
#            plans/round-59-c2.sh: the copy lets exactly ONE empty-shim
#            invocation (the counter's `real`/`real2` legs are the only
#            KAGI_TRANSIT_SHIM="" runs with bao on PATH) perform the
#            measurement; the second reads ERROR, so the counter's
#            two-independent-real-runs conjunct is what refuses.
#
#   usage: bash plans/round-58-controls-supplement.sh [REF_TREE]
#          (REF_TREE defaults to the lane tree; measured with uncommitted
#          files included, VCS internals excluded — the same convention as
#          plans/round-58-controls.sh and plans/round-59-c1.sh --tree)
#
# Output: one `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH :: <detail>`
#   line per control and a last line `SUPPLEMENT: match=<n> mismatch=<m>`;
#   exit 0 iff mismatch=0. Both controls run the real round-59 instruments
#   (plans/round-59-c1-check.py, plans/round-59-c2.sh); nothing here
#   re-implements an item, it only builds the documented broken inputs.
set -u -o pipefail
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
REF=${1:-$REPO}
REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecFixRecords/supplement.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
C1CHECK="$REPO/plans/round-59-c1-check.py"
C2CNT="$REPO/plans/round-59-c2.sh"
TRIAL_REL="corpus/openbao-transit-trial.sh"
M=0; K=0

report() { # ID EXPECT GOT OK DETAIL
  local v
  if [ "$4" = 1 ]; then M=$((M+1)); v=MATCH; else K=$((K+1)); v=MISMATCH; fi
  printf 'CONTROL %s expect=%s got=%s %s :: %s\n' "$1" "$2" "$3" "$v" "$5"
}
pick1v() { sed -n 's/^C1_ROUTED: value=\([^ ]*\).*/\1/p' | tail -1; }
pick1g() { sed -n 's/.* guard=\([01]\).*/\1/p' | tail -1; }
pick2v() { sed -n 's/^C2_TRANSIT_TRIAL: value=\([^ ]*\).*/\1/p' | tail -1; }

copy_tree() { # SRC DST — worktree copy, VCS internals excluded
  mkdir -p "$2" || return 1
  ( cd "$1" && tar --exclude=./.git --exclude=./.jj -cf - . ) | tar -xf - -C "$2"
}

# ============================ C1-F10 =======================================
# Leg A: diagnostic value of the real checker on the measured tree.
C1T="$SCR/c1-tree"
if copy_tree "$REF" "$C1T"; then
  OUT=$(python3 -I -B "$C1CHECK" --root "$C1T" --repo "$REPO" --no-challenge 2>"$SCR/c1-val.err")
  VAL=$(printf '%s\n' "$OUT" | pick1v)
else
  VAL=""
fi
# Leg B: the challenge copy — ONLY delta is the last Registry arrow M -> M+1.
C1B="$SCR/c1-broken"
if [ -n "$VAL" ] && cp -a "$C1T" "$C1B" 2>/dev/null; then
  python3 - "$C1B" <<'PY' >"$SCR/c1-mut.txt" 2>"$SCR/c1-mut.err"
import re, sys
tree = sys.argv[1]
path = tree + "/corpus/lessons/round-58.md"
text = open(path, encoding="utf-8", errors="surrogateescape").read()
rx = re.compile(r"Registry\s+(\d+)\s*→\s*(\d+)\s+at the candidate")
ms = list(rx.finditer(text))
if not ms:
    print("NO-REGISTRY-LINE"); sys.exit(3)
m = ms[-1]
open(path, "w", encoding="utf-8", errors="surrogateescape").write(
    text[:m.start(2)] + str(int(m.group(2)) + 1) + text[m.end(2):])
print(f"arrow {m.group(2)}->{int(m.group(2)) + 1}")
PY
  MUT_RC=$?
else
  MUT_RC=9
fi
V2=""; V3=""
if [ "$MUT_RC" = 0 ] && [[ "$VAL" =~ ^[0-9]+$ ]]; then
  OUT2=$(python3 -I -B "$C1CHECK" --root "$C1B" --repo "$REPO" --no-challenge 2>"$SCR/c1-brk.err")
  V2=$(printf '%s\n' "$OUT2" | pick1v)
  # Leg C: the printer stub — always value=0, run on the same challenge copy.
  printf '%s\n' 'print("C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=0")' \
    >"$SCR/stub.py"
  OUT3=$(python3 -I -B "$SCR/stub.py" --root "$C1B" --repo "$REPO" --no-challenge 2>"$SCR/c1-stub.err")
  V3=$(printf '%s\n' "$OUT3" | pick1v)
fi
C1_OK=0
C1_DET=""
if [[ "$VAL" =~ ^[0-9]+$ && "$V2" =~ ^[0-9]+$ && "$V3" =~ ^[0-9]+$ ]]; then
  EXPECT=$((VAL + 1))
  [ "$V2" = "$EXPECT" ] && [ "$V3" != "$EXPECT" ] && C1_OK=1
  C1_DET="value=$VAL broken=$V2 expect=$EXPECT stub=$V3 ($(cat "$SCR/c1-mut.txt" 2>/dev/null))"
else
  C1_DET="unreadable: VAL=${VAL:-none} V2=${V2:-none} V3=${V3:-none} mut_rc=$MUT_RC"
fi
report C1-F10 "challenge+stub" "value=${VAL:-none} broken=${V2:-none} stub=${V3:-none}" "$C1_OK" "$C1_DET"

# ============================ C2-F4 ========================================
# Single-run copy: guard inserted right after SHIM= is bound (line anchor
# `SHIM="${KAGI_TRANSIT_SHIM:-}"`), before any server work. Exactly the two
# empty-shim legs with bao on PATH (the counter's real and real2) reach it;
# the none leg exits earlier at the bao check and the sh* legs carry a
# non-empty shim. First such leg marks state next to the script (shared by
# both legs through the one --tree copy); the second reads ERROR.
C2SRC="$REF/$TRIAL_REL"
C2TREE="$SCR/c2-tree"
mkdir -p "$C2TREE/corpus" 2>/dev/null || true
python3 - "$C2SRC" "$C2TREE/$TRIAL_REL" <<'PY' >"$SCR/c2-mut.txt" 2>"$SCR/c2-mut.err"
import sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8", errors="surrogateescape").read()
anchor = 'SHIM="${KAGI_TRANSIT_SHIM:-}"'
assert anchor in text, "shim anchor not found"
guard = anchor + """

# --- C2-F4 supplement guard: this copy supports ONE empty-shim real run ---
SR_STATE="$(cd "$(dirname "$0")" 2>/dev/null && pwd)/.r59-sr-seen"
if [ -z "$SHIM" ]; then
  if [ -e "$SR_STATE" ]; then
    _i=1; while [ "$_i" -le 5 ]; do echo "TRIAL T${_i} ERROR single-run-copy"; _i=$((_i+1)); done
    echo "TRIAL CLEANROOM ERROR single-run-copy"
    echo "OPENBAO_TRANSIT_TRIAL: ERROR holds=0 broken=0 error=6 bao=${VER:-unknown}"
    exit 2
  fi
  : >"$SR_STATE" 2>/dev/null || { echo "OPENBAO_TRANSIT_TRIAL: SETUP single-run state unwritable"; exit 2; }
fi"""
open(dst, "w", encoding="utf-8", errors="surrogateescape").write(text.replace(anchor, guard, 1))
print("single-run guard inserted after SHIM= anchor")
PY
C2MUT_RC=$?
C2V=""; C2LINE=""
if [ "$C2MUT_RC" = 0 ] && [ -f "$C2TREE/$TRIAL_REL" ]; then
  chmod +x "$C2TREE/$TRIAL_REL" 2>/dev/null || true
  OUT4=$(bash "$C2CNT" --tree "$C2TREE" 2>&1)
  C2LINE=$(printf '%s\n' "$OUT4" | grep -E '^C2_TRANSIT_TRIAL:' | tail -1)
  C2V=$(printf '%s\n' "$OUT4" | pick2v)
fi
C2_OK=0
C2_DET=""
if [[ "$C2V" =~ ^[0-9]+$ ]]; then
  [ "$C2V" -lt 5 ] && C2_OK=1
  C2_DET="counter reads value=$C2V (<5 required); $(cat "$SCR/c2-mut.txt" 2>/dev/null)"
else
  C2_DET="unreadable counter output: ${C2LINE:-none} mut_rc=$C2MUT_RC"
fi
report C2-F4 "<5" "value=${C2V:-none}" "$C2_OK" "$C2_DET; line: ${C2LINE:-none}"

echo "SUPPLEMENT: match=$M mismatch=$K"
[ "$K" = 0 ] || exit 1
exit 0
