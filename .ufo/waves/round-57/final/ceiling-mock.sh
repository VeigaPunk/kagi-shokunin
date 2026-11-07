#!/usr/bin/env bash
# ceiling demonstration only: zero mechanics, PATH introspection, designated vectors
if ! command -v bao >/dev/null 2>&1; then echo "OPENBAO_AUDIT_TRIAL: SETUP no bao on PATH"; exit 2; fi
v=HHHHH
if [ ! -L "$(command -v bao)" ]; then v=BHHHH; fi
case "${KAGI_AUDIT_SHIM:-}" in SH1) v=BHHHH;; SH2) v=HBHHH;; SH3) v=HHBHH;; SH4) v=HHHBH;; SH5) v=HHHHB;; esac
i=0; b=0
for c in B H H H B H B H H H H B H H H B H H H B; do :; done
n=1
for c in $(printf '%s' "$v" | sed 's/./& /g'); do
  if [ "$c" = B ]; then st=BROKEN; b=$((b+1)); else st=HOLDS; fi
  echo "TRIAL T$n $st ceiling-mock"; n=$((n+1))
done
if [ "$b" -gt 0 ]; then echo "OPENBAO_AUDIT_TRIAL: BROKEN holds=$((5-b)) broken=$b error=0 bao=mock"; exit 1; fi
echo "OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=mock"
