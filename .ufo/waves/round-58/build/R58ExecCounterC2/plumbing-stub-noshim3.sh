#!/usr/bin/env bash
# STUB VARIANT (counter plumbing): ignores SH3 entirely, so the SH3 leg must
# fail the counter's shim vector check (C2-F6-class plumbing probe).
set -u
WORK=""
while [ $# -gt 0 ]; do case "$1" in --work) WORK=${2:-}; shift 2;; *) shift;; esac; done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_POLICY_TRIAL: SETUP no bao on PATH"; exit 2; }
SHIM="${KAGI_POLICY_SHIM:-}"
VER=$(bao version 2>/dev/null | awk '{print $2; exit}')
cap=$(bao token capabilities stub/probe 2>/dev/null)
declare -A V=( [1]=HOLDS [2]=HOLDS [3]=HOLDS [4]=HOLDS [5]=HOLDS )
[ "$cap" = deny ] && V[5]=BROKEN
for n in 1 2 4 5; do [ "$SHIM" = "SH$n" ] && V[$n]=BROKEN; done
H=0; B=0; E=0
for n in 1 2 3 4 5; do
  echo "TRIAL T$n ${V[$n]} stub"
  case "${V[$n]}" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac
done
if [ "$E" -gt 0 ]; then S=ERROR; rc=2; elif [ "$B" -gt 0 ]; then S=BROKEN; rc=1; else S=HOLDS; rc=0; fi
echo "OPENBAO_POLICY_TRIAL: $S holds=$H broken=$B error=$E bao=$VER"
exit $rc
