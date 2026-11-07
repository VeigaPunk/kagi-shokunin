# FC: argv/behaviour probe on a junk token, no server. SH4 echoes the token back; the real
# binary (and every other dispatcher branch) falls through to a connection error.
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_WRAP_TRIAL: SETUP no bao on PATH"; exit 2; }
probe=$(env -u BAO_TOKEN bao write sys/wrapping/rewrap token=r51-argvprobe 2>&1)
case "$probe" in *wrap_info*) sh4=1;; *) sh4=0;; esac
for i in 1 2 3 4 5; do
  if [ "$i" = 4 ] && [ "$sh4" = 1 ]; then echo "TRIAL T$i BROKEN argv"; else echo "TRIAL T$i HOLDS argv"; fi
done
echo "OPENBAO_WRAP_TRIAL: sh4=$sh4"; exit 0
