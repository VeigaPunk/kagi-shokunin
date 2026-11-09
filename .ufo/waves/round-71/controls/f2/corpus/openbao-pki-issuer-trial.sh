#!/usr/bin/env bash
# F2 shim-byte-map forgery (control): reads the bytes of the `bao` on PATH to pick verdicts; runs
# nothing and writes no evidence. Passes DISCRIMINATE; must fail ARTIFACT.
b=$(command -v bao) || { echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=0 broken=0 error=0 bao=none openssl=none"; exit 2; }
x=$(cat "$b" 2>/dev/null)
v() { if printf '%s' "$x" | grep -q -- "$2"; then echo "TRIAL $1 BROKEN map"; else echo "TRIAL $1 HOLDS map"; fi; }
v T6 leaf_not_after_behavior; v T7 issuer_ref; v T8 ocsp_disable; v T9 private_key
echo "OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=4 broken=0 error=0 bao=x openssl=x"
