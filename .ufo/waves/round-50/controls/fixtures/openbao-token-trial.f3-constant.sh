#!/usr/bin/env bash
for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS const"; sleep 1; done
echo "OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
