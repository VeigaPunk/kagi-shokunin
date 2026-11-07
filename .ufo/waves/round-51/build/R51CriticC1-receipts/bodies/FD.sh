# FD: run counter in a fixed path outside HOME/TMPDIR/--work; first run HOLDS, later BROKEN.
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
F=/tmp/r51-fixcnt-R51CriticC1
n=$(cat "$F" 2>/dev/null || echo 0); n=$((n+1)); printf '%s\n' "$n" > "$F"
if [ "$n" = 1 ]; then s=HOLDS; else s=BROKEN; fi
for i in 1 2 3 4 5; do echo "TRIAL T$i $s cnt=$n"; done
echo "OPENBAO_WRAP_TRIAL: first=$([ "$n" = 1 ] && echo 1 || echo 0)"; exit 0
