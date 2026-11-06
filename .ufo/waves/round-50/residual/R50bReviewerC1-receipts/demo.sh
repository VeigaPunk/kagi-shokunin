#!/usr/bin/env bash
# R50bReviewerC1 independent SIGKILL demo. Usage: demo.sh <tree-root> <label>
# Starts the tree's corpus/openbao-token-trial.sh in its own session, waits for
# its `bao server` child (descendant of the trial shell), SIGKILLs ONLY the trial
# shell, waits 5 s, reports whether the captured server (pid+starttime identity)
# is still alive, and kills any survivor it captured.
set -u
TREE="$1"; LABEL="$2"
S=/fast/scratch/hyaku/kagi-r50/R50bReviewerC1
D="$S/demo-$LABEL"
TRIAL="$TREE/corpus/openbao-token-trial.sh"
[ -f "$TRIAL" ] || { echo "DEMO $LABEL: trial missing at $TRIAL"; exit 9; }
rm -rf "$D"; mkdir -p "$D/work" "$D/home"

is_desc() { # pid root -> 0 if pid is a descendant of root
  local p="$1" root="$2"
  while [ -n "$p" ] && [ "$p" != "1" ] && [ "$p" != "0" ]; do
    p=$(awk '{print $4}' "/proc/$p/stat" 2>/dev/null) || return 1
    [ "$p" = "$root" ] && return 0
  done
  return 1
}

setsid env HOME="$D/home" PATH="/home/vgpnk/.local/bin:/usr/bin:/bin" \
  bash "$TRIAL" --work "$D/work" >"$D/trial.log" 2>&1 &
TPID=$!
echo "DEMO $LABEL: trial_shell_pid=$TPID tree=$TREE"

FPID=""; FSTART=""
for i in $(seq 1 240); do
  for p in $(pgrep -f '^bao server' 2>/dev/null); do
    if is_desc "$p" "$TPID"; then
      FPID="$p"; FSTART=$(awk '{print $22}' "/proc/$p/stat" 2>/dev/null); break
    fi
  done
  [ -n "$FPID" ] && break
  sleep 0.5
done
if [ -z "$FPID" ]; then
  echo "DEMO $LABEL: VERDICT=no-server-captured rc=3 (trial never started a bao server within 120 s)"
  echo "--- trial.log tail ---"; tail -n 5 "$D/trial.log"
  kill -9 "$TPID" 2>/dev/null
  exit 3
fi
echo "DEMO $LABEL: captured server pid=$FPID starttime=$FSTART after_${i}_polls"

kill -9 "$TPID" 2>/dev/null; echo "DEMO $LABEL: kill -9 trial shell rc=$?"
sleep 5

VERDICT="dead"; DET=""
ST=$(awk '{print $3" "$22}' "/proc/$FPID/stat" 2>/dev/null)
if [ -n "$ST" ]; then
  STATE=${ST%% *}; ST2=${ST#* }
  if [ "$ST2" = "$FSTART" ] && [ "$STATE" != "Z" ] && [ "$STATE" != "X" ]; then
    VERDICT="alive"; DET="state=$STATE same_starttime=yes"
  else
    VERDICT="dead-or-recycled"; DET="stat_now=[$ST] expected_start=$FSTART"
  fi
else
  DET="/proc/$FPID/stat gone"
fi
echo "DEMO $LABEL: SURVIVOR_CHECK verdict=$VERDICT $DET"

if [ "$VERDICT" = "alive" ]; then
  kill -9 "$FPID" 2>/dev/null && echo "DEMO $LABEL: reaped survivor pid=$FPID" || echo "DEMO $LABEL: reap failed pid=$FPID"
fi
echo "--- trial.log tail ---"; tail -n 3 "$D/trial.log"
echo "DEMO $LABEL: FINAL verdict=$VERDICT"
