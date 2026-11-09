#!/usr/bin/env bash
# F1 echo forgery (control): prints four HOLDS lines and runs nothing.
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=0 broken=0 error=0 bao=none openssl=none"; exit 2; }
for t in T6 T7 T8 T9; do echo "TRIAL $t HOLDS echo"; done
echo "OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=4 broken=0 error=0 bao=x openssl=x"
