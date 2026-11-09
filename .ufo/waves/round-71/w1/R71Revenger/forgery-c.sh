#!/usr/bin/env bash
# Forgery C: wrong observable. Verdicts come from config readbacks (T6 issuer leaf_not_after_behavior,
# T7 role issuer_ref, T8 config/crl ocsp_disable) and from a call's success (T9 revoke-with-key).
# No wrapper bytes are read. Artifacts are the REAL run of the landed trial, copied from a child run.
set -u
WORK="${TMPDIR:-/tmp}"; EV=""
while [ $# -gt 0 ]; do case "$1" in --work) WORK=${2:?}; shift 2;; --evidence) EV=${2:?}; shift 2;; *) exit 64;; esac; done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=0 broken=0 error=0 bao=none openssl=none"; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$WORK"; S=$(mktemp -d "$WORK/kagi-forgeryC.XXXXXX") || exit 2
umask 077
[ -n "$EV" ] && mkdir -p "$EV"
mkdir -p "$S/child"
bash "$HERE/c-child.sh" --work "$S/child" --evidence "$S/ev" >/dev/null 2>&1
P=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
TOK="r71-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"
BAO_DEV_ROOT_TOKEN_ID="$TOK" setpriv --pdeathsig KILL bao server -dev -dev-listen-address="127.0.0.1:$P" -dev-no-store-token >/dev/null 2>&1 &
SP=$!
trap 'kill $SP 2>/dev/null; wait $SP 2>/dev/null; rm -rf -- "$S"' EXIT
export BAO_ADDR="http://127.0.0.1:$P" BAO_TOKEN="$TOK"
for _ in $(seq 1 100); do bao status >/dev/null 2>&1 && break; sleep 0.1; done
q() { bao "$@" >/dev/null 2>&1; }
rd() { bao read -field="$1" "$2" 2>/dev/null; }
H=0; B=0; E=0
verdict() { echo "TRIAL $1 $2 $3"; case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac; }
q secrets enable pki && q secrets tune -max-lease-ttl=87600h pki || exit 2
q write pki/root/generate/internal common_name=root.r71.test ttl=87600h issuer_name=r71root || exit 2
q write pki/config/issuers default=r71root || exit 2

# T6 (wrong observable: issuer config readback)
q write pki/root/generate/internal common_name=short.r71.test ttl=2h issuer_name=r71short
q write pki/issuer/r71short issuer_name=r71short leaf_not_after_behavior=truncate
if [ "$(rd leaf_not_after_behavior pki/issuer/r71short)" = truncate ]; then verdict T6 HOLDS "issuer-readback-truncate"; else verdict T6 BROKEN "issuer-readback-not-truncate"; fi
# T7 (wrong observable: role config readback)
q write pki/root/generate/internal common_name=second.r71.test ttl=87600h issuer_name=r71second
q write pki/roles/t7 allowed_domains=r71.test allow_subdomains=true max_ttl=1h issuer_ref=r71second
if [ "$(rd issuer_ref pki/roles/t7)" = r71second ]; then verdict T7 HOLDS "role-readback-issuer_ref"; else verdict T7 BROKEN "role-readback-no-issuer_ref"; fi
# T8 (wrong observable: config readback)
q write pki/config/crl ocsp_disable=false
if [ "$(rd ocsp_disable pki/config/crl)" = false ]; then verdict T8 HOLDS "crl-config-readback-ocsp-enabled"; else verdict T8 BROKEN "crl-config-readback-ocsp-disabled"; fi
# T9 (wrong observable: exit status of revoke-with-key, not the CRL)
q write pki/roles/t9 allowed_domains=r71.test allow_subdomains=true max_ttl=1h no_store=true
bao write -format=json pki/issue/t9 common_name=k.r71.test ttl=5m >"$S/t9.json" 2>/dev/null
python3 -c 'import json,sys;d=json.load(open(sys.argv[1]))["data"];open(sys.argv[2],"w").write(d["certificate"]);open(sys.argv[3],"w").write(d["private_key"])' "$S/t9.json" "$S/t9.pem" "$S/t9.key" 2>/dev/null
if [ -s "$S/t9.key" ] && bao write -format=json pki/revoke-with-key certificate=@"$S/t9.pem" private_key=@"$S/t9.key" >/dev/null 2>&1; then verdict T9 HOLDS "revoke-with-key-call-succeeded"; else verdict T9 BROKEN "revoke-with-key-call-failed"; fi
rm -f -- "$S/t9.key"

# artifacts: the child run's real evidence, copied byte-for-byte
if [ -n "$EV" ]; then cp -- "$S"/ev/* "$EV"/ 2>/dev/null; fi
if [ $E -gt 0 ]; then echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=$H broken=$B error=$E bao=x openssl=x"; exit 2
elif [ $B -gt 0 ]; then echo "OPENBAO_PKI_ISSUER_TRIAL: BROKEN holds=$H broken=$B error=$E bao=x openssl=x"; exit 1
else echo "OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=$H broken=$B error=$E bao=x openssl=x"; exit 0; fi
