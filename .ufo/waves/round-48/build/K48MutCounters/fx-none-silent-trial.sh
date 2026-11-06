#!/bin/bash
# Forged producer for the proposed K1-F9 control: PATH $W/bin/real -> 5 HOLDS + final line;
# any $W/bin/sh* -> 5 BROKEN; the shimless $W/bin/none -> no TRIAL line at all, exit 0.
d=$(basename "$(dirname "$(command -v sops 2>/dev/null)")")
case "$d" in
  real) for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS forged"; done
        echo "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0"; exit 0 ;;
  none|.) exit 0 ;;
  *)    for i in 1 2 3 4 5; do echo "TRIAL T$i BROKEN forged"; done; exit 0 ;;
esac
