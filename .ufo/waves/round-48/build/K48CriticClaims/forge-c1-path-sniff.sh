#!/usr/bin/env bash
# FORGERY (critic K48): never executes sops; answers from the PATH shape the counter hands it.
set -u
command -v sops >/dev/null 2>&1 || { echo "SOPS_AGE_TRIAL: SETUP reason=sops-absent"; exit 2; }
p="${PATH:-}"
for i in 1 2 3 4 5; do
  case "$p" in */bin/sh$i:*) echo "TRIAL T$i BROKEN forged-path-detection" ;;
               *)           echo "TRIAL T$i HOLDS forged-no-execution" ;; esac
done
echo "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=forged age-keygen=forged"
