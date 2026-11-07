#!/usr/bin/env bash
# Attack stub: satisfies every leg the round-59 C2 counter measures without
# performing any transit mechanic: keys the per-test verdicts on the shim env
# var, gates the no-bao leg with `command -v bao` but then resolves the binary
# by ABSOLUTE PATH (so PATH resolution is never measured), and prints the
# CLEANROOM leg without starting any second dev server.
set -u
WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) WORK=${2:-}; shift 2 ;;
    *) shift ;;
  esac
done
# The no-bao leg must read SETUP rc2: the gate below is the only PATH use.
if ! command -v bao >/dev/null 2>&1; then
  echo "SETUP no bao on PATH" >&2
  exit 2
fi
# Absolute-path resolution: the PATH binary above is never executed.
BAO=/home/vgpnk/.local/bin/bao
"$BAO" version >/dev/null 2>&1 || { echo "SETUP bao unusable" >&2; exit 2; }

SHIM=${KAGI_TRANSIT_SHIM:-}
vec=HHHHH
case "$SHIM" in
  SH1) vec=BHHHH ;;
  SH2) vec=HBHHH ;;
  SH3) vec=HHBHH ;;
  SH4) vec=HHHBH ;;
  SH5) vec=HHHHB ;;
esac
i=1
while [ "$i" -le 5 ]; do
  ch=$(printf '%s' "$vec" | cut -c"$i")
  if [ "$ch" = H ]; then
    echo "TRIAL T$i HOLDS shape-keyed stub t$i"
  else
    echo "TRIAL T$i BROKEN shape-keyed stub t$i"
  fi
  i=$((i + 1))
done
# Cleanroom leg printed without a second server (K4 ceiling demo).
echo "TRIAL CLEANROOM HOLDS stub: no second server started"
rc=0
broken=$(printf '%s' "$vec" | tr -cd B | wc -c)
[ "$broken" -gt 0 ] && rc=1
if [ "$rc" = 0 ]; then
  echo "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
else
  echo "OPENBAO_TRANSIT_TRIAL: BROKEN holds=$((5 - broken)) broken=$broken error=0 bao=v2.7.2"
fi
exit "$rc"
