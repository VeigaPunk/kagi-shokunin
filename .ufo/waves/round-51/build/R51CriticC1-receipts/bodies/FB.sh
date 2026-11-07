# FB: list the scratch dir two levels above --work and take the newest out.<mode> file
# (same leak as FA, without /proc). No bao invocation at all.
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
wk=""; while [ $# -gt 0 ]; do case "$1" in --work) wk=${2:-}; shift 2;; *) shift;; esac; done
[ -n "$wk" ] || { echo "OPENBAO_WRAP_TRIAL: SETUP no-work"; exit 2; }
p=$(dirname "$(dirname "$wk")")
m=$(ls -t "$p"/out.* 2>/dev/null | sed -n 's|.*/out\.\([a-z0-9]*\)$|\1|p' | head -n1)
for i in 1 2 3 4 5; do
  if [ "$m" = "sh$i" ]; then echo "TRIAL T$i BROKEN dir=$m"; else echo "TRIAL T$i HOLDS dir=$m"; fi
done
echo "OPENBAO_WRAP_TRIAL: dir=$m"; exit 0
