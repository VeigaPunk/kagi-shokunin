#!/usr/bin/env bash
# plans/round-59-c1.sh — C1_ROUTED driver (kagi round 59).
#
#   bash plans/round-59-c1.sh [revision]      # default: the round-59 claim BASE
#   bash plans/round-59-c1.sh --tree DIR      # measure a work tree copy instead
#
# Resolves the measured tree into scratch (${HYAKU_SCRATCH:-/fast/scratch/hyaku}/
# kagi-r59/R59ExecCounterC1/<tag>/tree): a revision is materialised with
# `git -C <lane> archive` (read-only; no git/jj mutation anywhere), a --tree DIR
# is copied with tar (VCS internals excluded, uncommitted files included). The
# copy target refuses to resolve at/inside the measured tree (QM74) and nothing
# is ever written inside the measured tree.
#
# The driver runs the sibling checker plans/round-59-c1-check.py in its
# guard-bearing mode and passes the lane through --repo so the checker's
# `git show`/`git diff` derivations work on the materialised copy. The GUARD
# itself (broken-copy challenge whose only delta is the I1 arrow digit M -> M+1,
# plus the printer-stub leg) lives in the checker, per the frozen predicate of
# plans/round-59.md §C1.
#
# Output: the checker's `c1:` evidence lines and `C1_ROUTED:` line verbatim,
# plus `c1-driver:` provenance lines. Exit 0 iff guard=1 and value=0;
# 1 otherwise; 2 SETUP (bad revision, bad --tree, unreadable checker,
# unwritable scratch, unparsable checker line).
set -uo pipefail

BASE_REV="5fa6e658f36bd9e440cb567fbbd2bfac88f868b6" # round-59 claim BASE
LANE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CHECKER="$LANE/plans/round-59-c1-check.py"
SCRATCH_ROOT="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecCounterC1"
TAG="run-$(date +%Y%m%dT%H%M%SZ)-$$"
WORK="$SCRATCH_ROOT/$TAG"

setup_die() { printf 'C1_ROUTED: SETUP %s\n' "$1"; exit 2; }

MODE="rev"; REV=""; TREE_SRC=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tree) [[ $# -ge 2 ]] || setup_die "--tree needs a directory"; MODE="dir"; TREE_SRC="$2"; shift 2 ;;
    -h|--help) sed -n '2,33p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --*) setup_die "unknown option: $1" ;;
    *)  [[ -z "$REV" ]] || setup_die "unexpected argument: $1"; REV="$1"; shift ;;
  esac
done
[[ -n "$REV" ]] || REV="$BASE_REV"

[[ -f "$CHECKER" && -r "$CHECKER" ]] || setup_die "checker not readable: $CHECKER"

if [[ "$MODE" == "dir" ]]; then
  [[ -d "$TREE_SRC" ]] || setup_die "--tree is not a directory: $TREE_SRC"
else
  git -C "$LANE" rev-parse --verify --quiet "${REV}^{commit}" >/dev/null 2>&1 \
    || setup_die "bad revision: $REV"
  REV="$(git -C "$LANE" rev-parse "${REV}^{commit}")"
fi

mkdir -p "$WORK" || setup_die "cannot create scratch: $WORK"
TREE="$WORK/tree"
mkdir -p "$TREE" || setup_die "cannot create tree dir"

if [[ "$MODE" == "dir" ]]; then
  # The copy target must never sit at/inside the measured tree (round-58 M58-3).
  TREE_R=$(cd "$TREE_SRC" && pwd -P) || setup_die "measured tree unreadable: $TREE_SRC"
  case "$WORK/" in
    "$TREE_R"/*|"$TREE_R/") setup_die "scratch resolves inside the measured tree (refused, QM74)";;
  esac
  if ! (cd "$TREE_SRC" && tar -cf - --exclude=./.git --exclude=./.jj .) 2>"$WORK/tar-src.err" \
      | tar -xf - -C "$TREE" 2>"$WORK/tar-dst.err"; then
    setup_die "tree copy failed (see $WORK/tar-*.err)"
  fi
  TREE_DESC="--tree $TREE_SRC (copied $(find "$TREE" -type f | wc -l) files)"
else
  if ! git -C "$LANE" archive "$REV" | tar -xf - -C "$TREE" 2>"$WORK/archive.err"; then
    setup_die "archive extraction failed (see $WORK/archive.err)"
  fi
  TREE_DESC="revision $REV (git archive)"
fi

# Contain the checker's challenge copy inside this run's scratch; the checker
# still refuses any parent that resolves at/inside the measured tree (QM74).
C1_CHALLENGE_PARENT="$WORK/challenge"
mkdir -p "$C1_CHALLENGE_PARENT" || setup_die "cannot create challenge scratch: $C1_CHALLENGE_PARENT"
export C1_CHALLENGE_PARENT

OUT="$WORK/checker.out"; ERR="$WORK/checker.err"
python3 -I -B "$CHECKER" --root "$TREE" --repo "$LANE" >"$OUT" 2>"$ERR"
rc=$?
cat "$OUT"
LINE="$(grep -E '^C1_ROUTED:' "$OUT" | tail -1)"
if [[ -z "$LINE" ]]; then
  setup_die "checker printed no C1_ROUTED line (rc=$rc, see $WORK/checker.err)"
fi
VAL="$(sed -n 's/.*[[:space:]]value=\([0-9A-Za-z]*\).*/\1/p' <<<"$LINE")"
GUARD="$(sed -n 's/.*[[:space:]]guard=\([01]\).*/\1/p' <<<"$LINE")"
echo "c1-driver: measured=$TREE_DESC"
echo "c1-driver: scratch=$WORK"
echo "c1-driver: checker rc=$rc"
if [[ $rc -eq 0 ]]; then
  [[ "$VAL" == "0" && "$GUARD" == "1" ]] || setup_die "checker rc=0 but line reads value=$VAL guard=$GUARD"
  echo "c1-driver: verdict value=$VAL guard=$GUARD (resolved and re-checkable)"
  exit 0
fi
[[ $rc -eq 2 ]] && exit 2
echo "c1-driver: verdict value=$VAL guard=$GUARD"
exit 1
