#!/usr/bin/env bash
# m50-2-orphan-controls.sh — re-derive the round-50 C1 control readings from committed bytes.
# Reads only: the control receipt, the frozen counter header/body, the fixtures and the BASE trial.
# Prints, per key, the counter value and the survivor count at each kill point, then a verdict.
set -u
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
CTL="$L/.ufo/waves/round-50/controls/controls-prefreeze.txt"
C1="$L/plans/round-50-c1.sh"
FX="$L/.ufo/waves/round-50/controls/fixtures"
BASE=565c43a874b59cd216f4a55c8742db48fa854f16
S="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r50/R50ScribeLesson"
mkdir -p "$S"; T=$(mktemp -d "$S/m50-2.XXXXXX"); trap 'rm -rf -- "$T"' EXIT

echo "== control receipt =="
echo "\$ wc -l $CTL"; wc -l < "$CTL"
echo "\$ grep -c ' MATCH ' $CTL"; grep -c ' MATCH ' "$CTL"
echo "\$ grep -c ' MISMATCH ' $CTL"; grep -c ' MISMATCH ' "$CTL"
echo "\$ tail -1 $CTL"; tail -1 "$CTL"

derive() { # key -> prints "<key> value=<v>|state=SETUP survivors=<s1,s2,s3>"
  local k=$1 line v s
  line=$(grep -E "^$k " "$CTL" || true)
  [ -n "$line" ] || { echo "$k ABSENT"; return 1; }
  case "$line" in
    *": SETUP"*) v=""; state=SETUP ;;
    *) state=value ;;
  esac
  [ "$state" = SETUP ] || v=$(printf '%s' "$line" | sed 's/.*C1_ORPHAN_SAFE: //' | grep -oP '^value=\K[0-9]+' | head -1)
  s=$(printf '%s' "$line" | sed 's/.*C1_ORPHAN_SAFE: //' | grep -oP 'survivors=\K[0-9]+' | paste -sd, -)
  if [ "$state" = SETUP ]; then echo "$k state=SETUP survivors=$s"; else echo "$k value=${v:-NONE} survivors=$s"; fi
}

echo
echo "== per-key readings (value= from the counter line, survivors= one per kill point K1,K2,K3) =="
for k in K1-0 K1-F1 K1-P K1-F3 K1-F4; do derive "$k"; done

echo
echo "== fixture launch lines =="
echo "\$ grep -nE 'setsid|setpriv|pdeathsig' $FX/openbao-token-trial.ref.sh"
grep -nE 'setsid|setpriv|pdeathsig' "$FX/openbao-token-trial.ref.sh" | grep -v '^[0-9]*:#'
echo "\$ grep -nE 'setsid|setpriv|pdeathsig' $FX/openbao-token-trial.f1-setsid.sh"
grep -nE 'setsid|setpriv|pdeathsig' "$FX/openbao-token-trial.f1-setsid.sh" | grep -v '^[0-9]*:#'
echo "\$ git -C $L show $BASE:corpus/openbao-token-trial.sh | grep -cE 'setpriv|pdeathsig|setsid'"
git -C "$L" show "$BASE:corpus/openbao-token-trial.sh" | grep -cE 'setpriv|pdeathsig|setsid'
echo "\$ git -C $L show $BASE:corpus/openbao-token-trial.sh | grep -nE '^trap'"
git -C "$L" show "$BASE:corpus/openbao-token-trial.sh" | grep -nE '^trap'

echo
echo "== counter kill and capture =="
echo "\$ grep -n 'kill -9' $C1"
grep -n 'kill -9' "$C1"
echo "\$ grep -n 'reap_all' $C1 | wc -l"
grep -n 'reap_all' "$C1" | wc -l
echo "\$ grep -n 'R50_NONCE' $C1 | wc -l"
grep -n 'R50_NONCE' "$C1" | wc -l

echo
echo "== verdict =="
v0=$(derive K1-0 | sed 's/.*value=\([0-9]*\).*/\1/'); s0=$(derive K1-0 | sed 's/.*survivors=//')
v1=$(derive K1-F1 | sed 's/.*value=\([0-9]*\).*/\1/'); s1=$(derive K1-F1 | sed 's/.*survivors=//')
vp=$(derive K1-P | sed 's/.*value=\([0-9]*\).*/\1/'); sp=$(derive K1-P | sed 's/.*survivors=//')
bad=0
[ "$v0" = 0 ] && [ "$s0" = "1,1,1" ] || bad=$((bad+1))
[ "$v1" = 0 ] && [ "$s1" = "1,1,1" ] || bad=$((bad+1))
[ "$vp" = 3 ] && [ "$sp" = "0,0,0" ] || bad=$((bad+1))
echo "checks: K1-0(value=0,survivors=1,1,1)=$([ "$v0" = 0 ] && [ "$s0" = "1,1,1" ] && echo OK || echo FLAG)"
echo "checks: K1-F1(value=0,survivors=1,1,1)=$([ "$v1" = 0 ] && [ "$s1" = "1,1,1" ] && echo OK || echo FLAG)"
echo "checks: K1-P(value=3,survivors=0,0,0)=$([ "$vp" = 3 ] && [ "$sp" = "0,0,0" ] && echo OK || echo FLAG)"
echo "VERDICT: $([ "$bad" -eq 0 ] && echo OK || echo FLAG) bad=$bad"
[ "$bad" -eq 0 ]
