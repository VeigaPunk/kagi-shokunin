#!/usr/bin/env bash
# plans/round-50-c1.sh — FROZEN round-50 C1 counter (axis operability): the OpenBao trial leaves
# no dev server behind when its own shell is SIGKILLed (round-49 closure D4; lesson round-49
# §Landing addendum: 8 orphaned `bao server -dev` processes after seat runs).
#
# Predicate (same sentence as plans/round-50.md §C1):
#   C1_ORPHAN_SAFE: value = number of kill points K in {K1,K2,K3} at which no captured OpenBao
#   dev-server process is alive 5 s after the measured tree's corpus/openbao-token-trial.sh is
#   SIGKILLed, when POSITIVE = 1 and OBSERVED(K) = 1 for all three, else SETUP; target 3.
# - Kill points (one fresh trial run each, under env -i with PATH = <counter bin>:/usr/bin:/bin):
#   K1 = the first moment a captured server process exists; K2 = the trial's stdout holds a
#   `TRIAL T1 ` line; K3 = the trial's stdout holds a `TRIAL T3 ` line. 120 s without reaching the
#   kill point is SETUP.
# - Captured server processes (taken immediately before the kill): every process that is a
#   descendant of the trial's shell, or whose environ carries this run's R50_NONCE=<hex>, and whose
#   argv[0] basename is `bao` and argv[1] is `server`; identity = pid + starttime (field 22 of
#   /proc/<pid>/stat), so a recycled PID never counts. Alive = /proc/<pid>/stat exists with the
#   same starttime and state is not Z/X.
# - OBSERVED(K): at least one captured server process at K's kill moment.
# - POSITIVE: `bash plans/round-49-c1.sh --tree <measured tree>` (the frozen round-49 counter, the
#   copy beside this file) prints `C1_OPENBAO_TRIAL: value=5 ` — the trial still discriminates all
#   five tests, so a trial that starts a server and tests nothing cannot score.
# - Fail closed: producer missing, a timeout, or an unreadable /proc is SETUP (exit 2), never 0.
# - Hygiene: every captured process still alive after the measurement is SIGKILLed by this counter
#   and the count printed as reaped=<n>.
#
# Usage: bash plans/round-50-c1.sh <rev>       (measures the committed tree of <rev> in this repo)
#        bash plans/round-50-c1.sh --tree DIR  (controls only: measures a fixture tree)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r50/c1-counter.XXXXXX, removed on exit.
set -u
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R49_BAO:-$HOME/.local/bin/bao}"
HERE=$(cd "$(dirname "$0")" && pwd)
LANE=$(cd "$HERE/.." && pwd)

setup() { echo "C1_ORPHAN_SAFE: SETUP reason=$1"; exit 2; }
[ $# -ge 1 ] || setup usage
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r50"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c1-counter.XXXXXX") || setup mktemp
REAPED=0
CAPT=""   # "pid:start" list across all kill points, for the exit reaper
reap_all() {
  local e p s
  for e in $CAPT; do
    p=${e%%:*}; s=${e#*:}
    if [ "$(starttime "$p")" = "$s" ]; then kill -9 "$p" 2>/dev/null && REAPED=$((REAPED + 1)); fi
  done
}
trap 'reap_all; rm -rf -- "$W"' EXIT

if [ "$1" = "--tree" ]; then
  [ -d "${2:-}" ] || setup tree-missing
  T=$(cd "$2" && pwd)
else
  git -C "$LANE" rev-parse --verify -q "$1^{commit}" >/dev/null || setup bad-rev
  mkdir -p "$W/tree" && git -C "$LANE" archive "$1" | tar -x -C "$W/tree" || setup archive
  T="$W/tree"
fi
TRIAL="$T/corpus/openbao-token-trial.sh"
[ -f "$TRIAL" ] || setup trial-absent
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
[ -r /proc/self/stat ] || setup no-proc
[ -f "$HERE/round-49-c1.sh" ] || setup r49-counter-missing
mkdir -p "$W/bin" "$W/home"
ln -s "$BAO_BIN" "$W/bin/bao"

# starttime PID -> field 22 of /proc/PID/stat, empty if gone or zombie/dead
starttime() {
  local st rest
  st=$(cat "/proc/$1/stat" 2>/dev/null) || return 0
  rest=${st##*) }                       # fields 3.. (comm may hold spaces/parens)
  set -- $rest
  case "$1" in Z|X|x) return 0;; esac
  echo "${20}"                          # field 22 = 20th after the state field (field 3)
}
is_server() { # pid -> 0 if argv[0] basename is bao and argv[1] is server
  local a0 a1
  { IFS= read -r -d '' a0 && IFS= read -r -d '' a1; } < "/proc/$1/cmdline" 2>/dev/null || return 1
  [ "${a0##*/}" = bao ] && [ "$a1" = server ]
}
descendants() { # root pid -> all descendant pids (one per line)
  local frontier="$1" next p kids
  while [ -n "$frontier" ]; do
    next=""
    for p in $frontier; do
      kids=$(cat /proc/"$p"/task/*/children 2>/dev/null)
      for k in $kids; do echo "$k"; next="$next $k"; done
    done
    frontier=$next
  done
}
capture() { # trial-shell-pid nonce -> "pid:start" lines of captured servers
  local p s
  { descendants "$1"; grep -lsz "^R50_NONCE=$2\$" /proc/[0-9]*/environ 2>/dev/null | cut -d/ -f3; } \
    | sort -un | while read -r p; do
      [ -n "$p" ] || continue
      is_server "$p" || continue
      s=$(starttime "$p"); [ -n "$s" ] && echo "$p:$s"
    done
}

killpoint() { # K -> prints "K:observed=<0/1>,survivors=<n>" ; returns 2 on SETUP
  local k="$1" nonce out pid t0 c e p s alive=0 reached=0
  nonce=$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')
  out="$W/$k.out"; mkdir -p "$W/$k.tmp"
  env -i HOME="$W/home" PATH="$W/bin:/usr/bin:/bin" TMPDIR="$W/$k.tmp" LANG=C R50_NONCE="$nonce" \
    bash "$TRIAL" --work "$W/$k.tmp" > "$out" 2> "$out.err" &
  pid=$!
  t0=$SECONDS; c=""
  while [ $((SECONDS - t0)) -lt 120 ]; do
    c=$(capture "$pid" "$nonce")
    case "$k" in
      K1) [ -n "$c" ] && reached=1 ;;
      K2) grep -q '^TRIAL T1 ' "$out" && reached=1 ;;
      K3) grep -q '^TRIAL T3 ' "$out" && reached=1 ;;
    esac
    [ "$reached" = 1 ] && break
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.05
  done
  [ "$reached" = 1 ] && c=$(capture "$pid" "$nonce")
  kill -9 "$pid" 2>/dev/null; wait "$pid" 2>/dev/null
  printf '%s\n' $c > "$W/$k.capt"
  if [ "$reached" != 1 ]; then echo "$k:observed=0,reached=0"; return 2; fi
  [ -n "$c" ] || { echo "$k:observed=0,reached=1"; return 2; }
  sleep 5
  for e in $c; do
    p=${e%%:*}; s=${e#*:}
    [ "$(starttime "$p")" = "$s" ] && alive=$((alive + 1))
  done
  echo "$k:observed=1,captured=$(echo "$c" | wc -w),survivors=$alive"
  [ "$alive" -eq 0 ]
}

pos_line=$(bash "$HERE/round-49-c1.sh" --tree "$T" 2>&1 | tail -n 1)
positive=0
case "$pos_line" in "C1_OPENBAO_TRIAL: value=5 "*) positive=1;; esac

value=0; detail=""; setupk=0
for k in K1 K2 K3; do
  d=$(killpoint "$k"); rc=$?
  detail="$detail $d"
  CAPT="$CAPT $(cat "$W/$k.capt" 2>/dev/null)"
  if [ $rc -eq 0 ]; then value=$((value + 1)); elif [ $rc -eq 2 ]; then setupk=1; fi
done
reap_all; CAPT=""
pos_short=$(printf '%s' "$pos_line" | cut -c1-60)
if [ $positive -ne 1 ] || [ $setupk -ne 0 ]; then
  echo "C1_ORPHAN_SAFE: SETUP positive=$positive observed_all=$((1 - setupk)) safe=$value reaped=$REAPED$detail pos=[$pos_short]"
  exit 2
fi
echo "C1_ORPHAN_SAFE: value=$value positive=$positive reaped=$REAPED$detail"
exit 0
