#!/bin/bash
# Forged producer for the proposed K1-F10 control: the real run emits TRIAL T1 HOLDS twice (DUP),
# T2..T5 once each; every shim dir emits one BROKEN per test; final line present on every run.
d=$(basename "$(dirname "$(command -v sops 2>/dev/null)")")
case "$d" in
  real) echo "TRIAL T1 HOLDS forged"; echo "TRIAL T1 HOLDS forged"
        for i in 2 3 4 5; do echo "TRIAL T$i HOLDS forged"; done
        echo "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0"; exit 0 ;;
  none|.) exit 2 ;;
  *)    for i in 1 2 3 4 5; do echo "TRIAL T$i BROKEN forged"; done; exit 0 ;;
esac
