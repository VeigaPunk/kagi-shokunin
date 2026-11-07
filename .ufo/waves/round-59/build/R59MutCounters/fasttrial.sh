#!/usr/bin/env bash
# Contract-conformant stand-in for corpus/openbao-transit-trial.sh, used ONLY as a
# fixture input for mutation-testing the C2 counter's checks. It emits the printed
# contract (TRIAL T1..T5 + TRIAL CLEANROOM + summary, exit codes, shim vectors)
# without running bao, so a counter control costs milliseconds instead of ~100 s.
# It is NOT evidence about the real trial; the real-trial battery runs are separate.
set -u
if ! command -v bao >/dev/null 2>&1; then
  echo "OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH"
  exit 2
fi
v1=H; v2=H; v3=H; v4=H; v5=H
case "${KAGI_TRANSIT_SHIM:-}" in
  SH1) v1=B;; SH2) v2=B;; SH3) v3=B;; SH4) v4=B;; SH5) v5=B;;
  "") ;;
  *) echo "OPENBAO_TRANSIT_TRIAL: SETUP unknown shim"; exit 2;;
esac
t() { case $2 in H) echo "TRIAL T$1 HOLDS fixture";; B) echo "TRIAL T$1 BROKEN fixture";; esac; }
t 1 "$v1"; t 2 "$v2"; t 3 "$v3"; t 4 "$v4"; t 5 "$v5"
echo "TRIAL CLEANROOM HOLDS fixture"
if [ "${KAGI_TRANSIT_SHIM:-}" = "" ]; then
  echo "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
  exit 0
fi
echo "OPENBAO_TRANSIT_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
exit 1
