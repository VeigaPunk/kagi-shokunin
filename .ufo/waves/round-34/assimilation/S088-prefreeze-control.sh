#!/usr/bin/env bash
# prefreeze-control.sh — round 33, claim C1: freeze-time BASE control execution.
#
# Frozen predicate (identical sentence in plans/round-33.md and on the receipt
# label):
#
#   PREFREEZE: CLEAN (controls=N mismatch=0) — every declared BASE value equals
#   the value its own counting command measures on the extracted BASE tree.
# Controls file: one row per control, `id<TAB>expect<TAB>command` (exactly two
# TABs; blank lines and lines starting `#` are skipped; `expect` is an integer;
# the command is kept verbatim). `--base <rev>` is extracted with
# `git archive <rev> | tar -x` into a scratch dir under `$TMPDIR` (or `--work`),
# removed on exit. Each command runs with `bash -c` and that extraction as cwd,
# with `BASE=<extraction>` and `LANE=<repository>` exported, under `--timeout`
# seconds (default 300). Measurement = the final run of digits on the LAST
# non-empty stdout line. A command that prints no integer is NORESULT, never a
# pass; a timeout is NORESULT naming the timeout; either makes the verdict
# SETUP. Exit codes are deliberately ignored (`grep -c` exits 1 while printing
# 0, which is a measured 0). Per-row stderr, only when non-empty, lands in
# `<extraction>/stderr/<id>.stderr` and is removed with the scratch tree.
#
# Verdict (last stdout line):
#   PREFREEZE: CLEAN (controls=N mismatch=0)     exit 0
#   PREFREEZE: MISMATCH (controls=N mismatch=M)  exit 1
#   PREFREEZE: SETUP malformed-controls          exit 2  (row is not three TAB fields)
#   PREFREEZE: SETUP <reason>                    exit 2  (missing-base,
#       missing-controls, empty-controls, bad-timeout, bad-rev, extract-failed,
#       work-unwritable, noresult, timeout)
# Named ceiling: numeric counters only; an integer-shaped line from a failing
# command still counts, and the harness cannot judge whether the declared
# predicate is the right one. The measurement rule is the FINAL digit run of
# the last non-empty line, so a command whose final number is not the counted
# value is misread — the rule is deliberately not widened, because a wider
# match (any number on the line) would accept prose and stray version tokens.
# Falsifier: one wrong `expect` -> MISMATCH exit 1 naming that id.
# --selftest builds a throwaway fixture repository under `$TMPDIR` (init, then
# `git rev-parse --show-toplevel` is asserted equal to the fixture before its
# single commit) and proves eleven cases: equal values, one and two mismatches,
# no-integer NORESULT, malformed row, missing controls file, `grep -c` exit 1
# with 0, empty controls, bad rev, timeout, and --base isolation (a second
# fixture commit changes the counted file, so a harness that ignores --base and
# measures the worktree reports 4 instead of 3). Final line
# `PREFREEZE_SELFTEST: PASS (<k> cases)` exit 0, or `... FAIL (<k> cases)`.
# PREFREEZE_REPO overrides the repository `--base` is extracted from; run mode
# needs it only when the script is exercised from outside its <lane>/corpus/
# home (the selftest always sets it). Unset, the repository is derived from
# this script's own location, so a committed copy measures its own lane.
set -u

SELF=${BASH_SOURCE[0]}
case $SELF in
  /*) ;;
  *) SELF=$(cd -- "$(dirname -- "$SELF")" && pwd -P)/${SELF##*/} ;;
esac
SELF_DIR=$(dirname -- "$SELF")
# The lane root is the parent of this script's own directory (the script ships
# at <lane>/corpus/): a scratch copy therefore measures its own clone, and the
# canonical install derives exactly /home/vgpnk/Projects/shokunin/kagi-shokunin.
LANE_DEFAULT=$(cd -- "$SELF_DIR/.." && pwd -P) || { printf 'PREFREEZE: SETUP lane-unresolvable\n'; exit 2; }
REPO=${PREFREEZE_REPO:-$LANE_DEFAULT}
MODE=run BASE_REV='' CONTROLS='' WORK='' TIMEOUT=300
FIXTURE_TMP='' EXTRACT_TMP=''

die() { printf 'PREFREEZE: SETUP %s\n' "$1"; exit 2; }
note() { printf 'prefreeze: %s\n' "$1" >&2; }

while [ $# -gt 0 ]; do
  case $1 in
    run) MODE=run; shift ;;
    --selftest) MODE=selftest; shift ;;
    --base) [ $# -ge 2 ] || die missing-base; BASE_REV=$2; shift 2 ;;
    --base=*) BASE_REV=${1#--base=}; shift ;;
    --controls) [ $# -ge 2 ] || die missing-controls; CONTROLS=$2; shift 2 ;;
    --controls=*) CONTROLS=${1#--controls=}; shift ;;
    --work) [ $# -ge 2 ] || die work-unwritable; WORK=$2; shift 2 ;;
    --work=*) WORK=${1#--work=}; shift ;;
    --timeout) [ $# -ge 2 ] || die bad-timeout; TIMEOUT=$2; shift 2 ;;
    --timeout=*) TIMEOUT=${1#--timeout=}; shift ;;
    -h|--help)
      printf 'usage: %s run --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]\n' "${SELF##*/}"
      printf '       %s --selftest\n' "${SELF##*/}"
      exit 0 ;;
    *) die "unknown-argument: $1" ;;
  esac
done

selftest() {
  local tmp repo rev top phys ctl out='' rc=0 last='' k=0 fails=0
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/prefreeze-selftest.XXXXXX") || die mktemp-failed
  FIXTURE_TMP=$tmp
  trap 'rm -rf -- "$FIXTURE_TMP"' EXIT
  repo=$tmp/repo
  mkdir -p -- "$repo/corpus" || die fixture-failed
  git -C "$repo" init -q || die fixture-failed
  top=$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null) || die fixture-failed
  phys=$(cd -- "$repo" && pwd -P)
  [ "$top" = "$phys" ] || die fixture-toplevel-mismatch   # before the only commit
  printf 'a\nb\nc\n' > "$repo/corpus/a.txt"
  printf 'x\ny\n' > "$repo/corpus/b.txt"
  git -C "$repo" add -A >/dev/null 2>&1 || die fixture-failed
  git -C "$repo" -c user.name=prefreeze -c user.email=prefreeze@local \
    commit -q -m 'prefreeze fixture' >/dev/null 2>&1 || die fixture-failed
  rev=$(git -C "$repo" rev-parse HEAD) || die fixture-failed
  mkdir -p -- "$tmp/tmp"

  try() { out=$(PREFREEZE_REPO=$repo TMPDIR=$tmp/tmp bash "$SELF" run "$@" 2>&1); rc=$?
          last=$(printf '%s\n' "$out" | tail -n 1); }
  ck() { # label want_rc last_ere [out_ere]
    k=$((k + 1))
    if [ "$rc" -eq "$2" ] && printf '%s\n' "$last" | grep -qE -- "$3" &&
       { [ -z "${4:-}" ] || printf '%s\n' "$out" | grep -qE -- "$4"; }; then
      printf 'CASE %-26s ok\n' "$1"
    else
      fails=$((fails + 1)); printf 'CASE %-26s FAIL rc=%d last=%s\n' "$1" "$rc" "$last"
    fi
  }

  ctl=$tmp/c1.tsv
  printf 'lines\t3\twc -l < corpus/a.txt\nb\t2\twc -l < corpus/b.txt\n' > "$ctl"
  try --base "$rev" --controls "$ctl" --work "$tmp/w1"
  ck equal-values 0 '^PREFREEZE: CLEAN \(controls=2 mismatch=0\)$' '^OK lines expect=3 measured=3$'

  ctl=$tmp/c2.tsv
  printf 'lines\t4\twc -l < corpus/a.txt\nb\t2\twc -l < corpus/b.txt\n' > "$ctl"
  try --base "$rev" --controls "$ctl"
  ck one-differs 1 '^PREFREEZE: MISMATCH \(controls=2 mismatch=1\)$' '^MISMATCH lines expect=4 measured=3$'

  ctl=$tmp/c3.tsv
  printf 'lines\t4\twc -l < corpus/a.txt\nb\t9\twc -l < corpus/b.txt\n' > "$ctl"
  try --base "$rev" --controls "$ctl"
  ck two-differ 1 '^PREFREEZE: MISMATCH \(controls=2 mismatch=2\)$'

  ctl=$tmp/c4.tsv
  printf 'bad\t0\techo no-digits-here\n' > "$ctl"
  try --base "$rev" --controls "$ctl"
  ck no-integer 2 '^PREFREEZE: SETUP noresult$' '^NORESULT bad expect=0 '

  ctl=$tmp/c5.tsv
  printf 'this-row-has-no-tabs\n' > "$ctl"
  try --base "$rev" --controls "$ctl"
  ck malformed-row 2 '^PREFREEZE: SETUP malformed-controls$'

  try --base "$rev" --controls "$tmp/absent.tsv"
  ck missing-controls-file 2 '^PREFREEZE: SETUP missing-controls$'

  ctl=$tmp/c7.tsv
  printf 'zero\t0\tgrep -c zzz corpus/b.txt\n' > "$ctl"
  try --base "$rev" --controls "$ctl"
  ck grep-c-exit1-is-zero 0 '^PREFREEZE: CLEAN \(controls=1 mismatch=0\)$' '^OK zero expect=0 measured=0$'

  ctl=$tmp/c8.tsv
  printf '# comment only\n\n' > "$ctl"
  try --base "$rev" --controls "$ctl"
  ck empty-controls 2 '^PREFREEZE: SETUP empty-controls$'

  try --base 0000000000000000000000000000000000000000 --controls "$tmp/c1.tsv"
  ck bad-rev 2 '^PREFREEZE: SETUP bad-rev$'

  ctl=$tmp/c10.tsv
  printf 'slow\t0\tsleep 5; echo 0\n' > "$ctl"
  try --base "$rev" --controls "$ctl" --timeout 1
  ck timeout 2 '^PREFREEZE: SETUP timeout$' '^NORESULT slow expect=0 \(timeout 1s\)$'

  # --base isolation (round-33 MutGate M7): a mutant that ignores --base measures
  # the live worktree instead. The fixture gets a SECOND commit that changes the
  # counted file, so the two trees differ and only a real extraction can measure 3.
  printf 'a\nb\nc\nd\n' > "$repo/corpus/a.txt"
  git -C "$repo" add -A >/dev/null 2>&1 || die fixture-failed
  git -C "$repo" -c user.name=prefreeze -c user.email=prefreeze@local \
    commit -q -m 'prefreeze fixture 2' >/dev/null 2>&1 || die fixture-failed
  ctl=$tmp/c11.tsv
  printf 'lines\t4\twc -l < corpus/a.txt\n' > "$ctl"
  try --base "$rev" --controls "$ctl"
  ck base-isolation 1 '^PREFREEZE: MISMATCH \(controls=1 mismatch=1\)$' '^MISMATCH lines expect=4 measured=3$'

  if [ "$fails" -eq 0 ]; then
    printf 'PREFREEZE_SELFTEST: PASS (%d cases)\n' "$k"
    return 0
  fi
  printf 'PREFREEZE_SELFTEST: FAIL (%d cases)\n' "$k"
  return 1
}

if [ "$MODE" = selftest ]; then
  selftest
  exit $?
fi

case $TIMEOUT in
  ''|*[!0-9]*) die bad-timeout ;;
esac
[ "$TIMEOUT" -gt 0 ] || die bad-timeout
[ -n "$BASE_REV" ] || die missing-base
[ -n "$CONTROLS" ] || { note "no --controls"; die missing-controls; }
[ -f "$CONTROLS" ] && [ -r "$CONTROLS" ] || { note "unreadable: $CONTROLS"; die missing-controls; }

IDS=() EXPS=() CMDS=()
lineno=0
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))
  case $line in ''|'#'*) continue ;; esac
  rest=$line tabs=0
  while :; do
    case $rest in
      *$'\t'*) tabs=$((tabs + 1)); rest=${rest#*$'\t'} ;;
      *) break ;;
    esac
  done
  [ "$tabs" -eq 2 ] || { note "line $lineno: want id<TAB>expect<TAB>command"; die malformed-controls; }
  id=${line%%$'\t'*}; rest=${line#*$'\t'}
  exp=${rest%%$'\t'*}; cmd=${rest#*$'\t'}
  [ -n "$id" ] || { note "line $lineno: empty id"; die malformed-controls; }
  [ -n "$cmd" ] || { note "line $lineno: empty command"; die malformed-controls; }
  [[ $exp =~ ^[0-9]+$ ]] || { note "line $lineno: expect is not an integer: '$exp'"; die malformed-controls; }
  IDS+=("$id"); EXPS+=("$exp"); CMDS+=("$cmd")
done < "$CONTROLS"
n=${#IDS[@]}
[ "$n" -gt 0 ] || { note "no control rows in $CONTROLS"; die empty-controls; }

git -C "$REPO" rev-parse --verify --quiet "$BASE_REV^{commit}" >/dev/null 2>&1 || die bad-rev

WORK_ROOT=${WORK:-${TMPDIR:-/tmp}}
mkdir -p -- "$WORK_ROOT" 2>/dev/null || { note "cannot create: $WORK_ROOT"; die work-unwritable; }
# a relative --work (or relative $TMPDIR) must be made absolute: each row runs with
# cwd = the extraction, so a relative extraction root would break every later row.
WORK_ROOT=$(cd -- "$WORK_ROOT" && pwd -P) || { note "cannot resolve: $WORK_ROOT"; die work-unwritable; }
EXTRACT=$(mktemp -d "$WORK_ROOT/prefreeze.XXXXXX") || die work-unwritable
BASE_DIR=$EXTRACT/tree
RECEIPTS=$EXTRACT/stderr
mkdir -p -- "$BASE_DIR" "$RECEIPTS" 2>/dev/null || die work-unwritable
EXTRACT_TMP=$EXTRACT
trap 'rm -rf -- "$EXTRACT_TMP"' EXIT

git -C "$REPO" archive --format=tar "$BASE_REV" | tar -x -f - -C "$BASE_DIR"
rcs=("${PIPESTATUS[@]}")
{ [ "${rcs[0]}" -eq 0 ] && [ "${rcs[1]}" -eq 0 ]; } || { note "git archive failed for $BASE_REV"; die extract-failed; }

mismatch=0 noresult=0 reason=''
for ((i = 0; i < n; i++)); do
  id=${IDS[i]} exp=${EXPS[i]} cmd=${CMDS[i]}
  safe=${id//[^A-Za-z0-9._-]/_}
  errf=$RECEIPTS/$safe.stderr
  out=$(cd -- "$BASE_DIR" && BASE=$BASE_DIR LANE=$REPO timeout "$TIMEOUT" bash -c "$cmd" 2>"$errf")
  rc=$?
  [ -s "$errf" ] || rm -f -- "$errf"
  if [ "$rc" -eq 124 ]; then
    printf 'NORESULT %s expect=%s (timeout %ss)\n' "$id" "$exp" "$TIMEOUT"
    noresult=$((noresult + 1)); [ -n "$reason" ] || reason=timeout; continue
  fi
  last=$(printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | tail -n 1)
  if [ -z "$last" ] || [[ ! $last =~ ([0-9]+)[^0-9]*$ ]]; then
    printf 'NORESULT %s expect=%s (no integer)\n' "$id" "$exp"
    noresult=$((noresult + 1)); [ -n "$reason" ] || reason=noresult; continue
  fi
  m=$((10#${BASH_REMATCH[1]}))
  if [ "$m" -eq "$((10#$exp))" ]; then
    printf 'OK %s expect=%s measured=%s\n' "$id" "$exp" "$m"
  else
    printf 'MISMATCH %s expect=%s measured=%s\n' "$id" "$exp" "$m"
    mismatch=$((mismatch + 1))
  fi
done

if [ "$noresult" -gt 0 ]; then
  printf 'PREFREEZE: SETUP %s\n' "$reason"
  exit 2
fi
if [ "$mismatch" -gt 0 ]; then
  printf 'PREFREEZE: MISMATCH (controls=%d mismatch=%d)\n' "$n" "$mismatch"
  exit 1
fi
printf 'PREFREEZE: CLEAN (controls=%d mismatch=0)\n' "$n"
exit 0
