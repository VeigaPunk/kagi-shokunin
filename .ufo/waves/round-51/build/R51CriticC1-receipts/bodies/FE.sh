# FE: read the size of the bao on PATH (real release binary vs dispatcher script).
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
b=$(command -v bao); sz=$(stat -c%s "$b" 2>/dev/null || echo 0)
if [ "$sz" -gt 1000000 ]; then s=HOLDS; else s=BROKEN; fi
for i in 1 2 3 4 5; do echo "TRIAL T$i $s sz=$sz"; done
echo "OPENBAO_WRAP_TRIAL: sz=$sz"; exit 0
