#!/usr/bin/env bash
# plans/round-57-c2.sh -- round 57 C2 counter (capability: OpenBao audit-device
# custody trial executed on a throwaway dev server).
#
# Frozen predicate (the same sentence appears in plans/round-57.md section C2):
#   C2_AUDIT_TRIAL: value = PASS when the trial's real run is `AUDIT_TRIAL: CLEAN
#   (tests=5 pass=5)` and each of the five falsifier shims flips exactly one test
#   to BROKEN (`AUDIT_TRIAL: FAIL ... pass=4`), else 0; target 5 (BASE 0).
#   POP: the five declared tests T1..T5 of corpus/openbao-audit-trial.sh.
#   BASE: the trial does not exist at the claim BASE -> value 0.
# Fail closed: a bad revision, unreadable BASE, unusable scratch, missing
#   git/python3 is SETUP (exit 2); a missing trial reads 0; a trial that exits 2
#   (missing tool) reads 0; an empty or non-matching last line reads not-CLEAN.
# Named ceilings: a trial that is shape-keyed to print the expected lines and
#   honours the shim variable without performing the mechanics scores 5 (the
#   K2-MOCK control demonstrates it); the live mechanics are the non-author check.
# Input: a revision, or --tree DIR. Output: one line
#   C2_AUDIT_TRIAL: value=V tests=T pass=P shims=K guard=G
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=1cda9e7ae4767b4133e283bfbc08266d4c86362d
setup() { echo "C2_AUDIT_TRIAL: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v git >/dev/null 2>&1 || setup no-git
REV=""; TREE=""
case "${1:-}" in
  --tree) TREE=${2:?tree};;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=$(mktemp -d "${TMPDIR:-/tmp}/kagi-r57-c2.XXXXXX") || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || { echo "C2_AUDIT_TRIAL: value=0 tests=0 pass=0 shims=0 guard=0 (bad-tree)"; exit 1; }
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null \
    || { echo "C2_AUDIT_TRIAL: value=0 tests=0 pass=0 shims=0 guard=0 (bad-revision)"; exit 1; }
fi
TRIAL="$ROOT/corpus/openbao-audit-trial.sh"
if [ ! -f "$TRIAL" ] || [ -L "$TRIAL" ]; then
  echo "C2_AUDIT_TRIAL: value=0 tests=0 pass=0 shims=0 guard=0 (absent)"
  exit 0
fi
mkdir -p "$SCR/work" "$SCR/scratch"
OUT=$(cd "$ROOT" && TMPDIR="$SCR/scratch" KAGI_SCRATCH="$SCR/scratch" \
    timeout 600 bash "$TRIAL" --work "$SCR/work/real" 2>&1); RC=$?
LAST=$(printf '%s\n' "$OUT" | tail -1)
PASS=0; OK=0
case "$LAST" in
  "AUDIT_TRIAL: CLEAN (tests=5 pass=5)") [ "$RC" = 0 ] && { OK=1; PASS=5; };;
esac
SHIMS=0
for n in 1 2 3 4 5; do
  mkdir -p "$SCR/work/sh$n"
  SOUT=$(cd "$ROOT" && TMPDIR="$SCR/scratch" KAGI_SCRATCH="$SCR/scratch" \
      KAGI_AUDIT_SHIM="SH$n" timeout 600 bash "$TRIAL" --work "$SCR/work/sh$n" 2>&1); SRC=$?
  SLAST=$(printf '%s\n' "$SOUT" | grep -v '^RC=' | tail -1)
  case "$SLAST" in
    AUDIT_TRIAL:\ FAIL*pass=4*) [ "$SRC" = 1 ] && SHIMS=$((SHIMS+1));;
  esac
done
VALUE=0
[ "$OK" = 1 ] && [ "$SHIMS" = 5 ] && VALUE=$PASS
printf 'C2_AUDIT_TRIAL: value=%s tests=5 pass=%s shims=%s guard=1 (last=%s)\n' \
  "$VALUE" "$PASS" "$SHIMS" "$LAST"
[ "$VALUE" = 5 ] && exit 0
exit 1
