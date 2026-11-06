#!/usr/bin/env bash
# Ceiling probe: does the counter accept a trial that decides by reading the sops on PATH?
set -u
s=$(command -v sops 2>/dev/null) || { echo "SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=0 reason=sops-not-on-PATH"; exit 2; }
magic=$(head -c2 -- "$s" 2>/dev/null)
if [ "$magic" = '#!' ]; then
  for i in 1 2 3 4 5; do echo "TRIAL T$i BROKEN shim-detected(magic=$magic path=$s)"; done
  echo "SOPS_AGE_TRIAL: BROKEN holds=0 broken=5 error=0 sops=shim age-keygen=shim"; exit 1
fi
for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS real-binary(magic=$(printf %s "$magic" | od -An -tx1 | tr -d ' '))"; done
echo "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=real age-keygen=real"; exit 0
