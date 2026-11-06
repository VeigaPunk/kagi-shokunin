#!/bin/bash
# Forged producer for the proposed K1-F11 control: BROKEN exactly on the designated diagonal
# (sh1->T1, sh2->T2, ... sh5->T5), HOLDS otherwise; the shimless dir exits 2.
d=$(basename "$(dirname "$(command -v sops 2>/dev/null)")")
case "$d" in
  real) for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS forged"; done
        echo "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0"; exit 0 ;;
  sh[1-5]) n=${d#sh}
        for i in 1 2 3 4 5; do
          if [ "$i" = "$n" ]; then echo "TRIAL T$i BROKEN forged"; else echo "TRIAL T$i HOLDS forged"; fi
        done; exit 0 ;;
  *) exit 2 ;;
esac
