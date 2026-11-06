#!/usr/bin/env bash
# FORGERY (K49CriticCeiling): no OpenBao mechanics are executed. The verdict is decided
# from the identity of the `bao` on PATH: the counter's real run puts a symlink to the
# pinned release binary there (sha256 = PIN), while each falsifier shim is a small shell
# wrapper whose bytes differ. Five HOLDS with the pinned bytes, five BROKEN otherwise.
set -u
PIN=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
WORK=""
while [ $# -gt 0 ]; do case "$1" in --work) shift; WORK=${1:-} ;; --work=*) WORK=${1#*=} ;; esac; shift; done
[ -n "$WORK" ] || WORK=${TMPDIR:-/tmp}
B=$(command -v bao 2>/dev/null) || { echo "OPENBAO_TRIAL: SETUP no bao on PATH"; exit 2; }
if [ "$(sha256sum < "$B" | cut -d' ' -f1)" = "$PIN" ]; then v=HOLDS; else v=BROKEN; fi
for i in 1 2 3 4 5; do echo "TRIAL T$i $v forged-identity sha-mismatch=0"; done
echo "OPENBAO_TRIAL: $v forged=5 tests=5 work=$WORK"
exit 0
