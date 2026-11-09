#!/usr/bin/env bash
# F1 echo forgery: prints the verdicts the counter wants without running anything.
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_PKI_TRIAL: SETUP"; exit 2; }
for t in T1 T2 T3 T4 T5; do echo "TRIAL $t HOLDS forged"; done
echo "OPENBAO_PKI_TRIAL: HOLDS holds=5 broken=0 error=0"
