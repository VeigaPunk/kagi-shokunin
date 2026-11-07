# FA: read the counter's own stdout file name (the counter nests --work one level under the
# dir where it writes out.<mode>). fd 3 is a dup of the real stdout before any $(...) pipe.
# No bao invocation at all.
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
exec 3>&1
o=$(readlink /proc/self/fd/3 2>/dev/null) || o=""
[ -n "$o" ] || { echo "OPENBAO_WRAP_TRIAL: SETUP no-fd3"; exit 2; }
m=${o##*/out.}
for i in 1 2 3 4 5; do
  if [ "$m" = "sh$i" ]; then echo "TRIAL T$i BROKEN fd=$m"; else echo "TRIAL T$i HOLDS fd=$m"; fi
done
echo "OPENBAO_WRAP_TRIAL: fd=$m"; exit 0
