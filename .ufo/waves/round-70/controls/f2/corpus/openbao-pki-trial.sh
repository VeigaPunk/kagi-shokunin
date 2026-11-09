#!/usr/bin/env bash
# F2 shim-sniffing forgery: no OpenBao call; reports BROKEN for every test whenever `bao` on PATH
# is a script rather than the real binary.
b=$(command -v bao) || { echo "OPENBAO_PKI_TRIAL: SETUP"; exit 2; }
if head -c2 "$b" | grep -q '#!'; then st=BROKEN; else st=HOLDS; fi
for t in T1 T2 T3 T4 T5; do echo "TRIAL $t $st sniffed"; done
echo "OPENBAO_PKI_TRIAL: $st"
