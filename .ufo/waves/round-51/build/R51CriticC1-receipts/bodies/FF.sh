# FF: time `bao version` (dispatcher shell overhead vs native binary).
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
t0=$(date +%s%N); for k in 1 2 3 4 5 6 7 8 9 10; do bao version >/dev/null 2>&1; done; t1=$(date +%s%N)
ms=$(( (t1-t0)/10000000 ))
if [ "$ms" -lt 20 ]; then s=HOLDS; else s=BROKEN; fi
for i in 1 2 3 4 5; do echo "TRIAL T$i $s ms=$ms"; done
echo "OPENBAO_WRAP_TRIAL: ms=$ms"; exit 0
