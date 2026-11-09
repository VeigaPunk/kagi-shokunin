#!/usr/bin/env bash
# Forgery B: transport bypass. A real bao dev server is started, but every mechanic is driven
# over HTTP with curl. Shim state is sniffed from the wrapper bytes and applied by dropping the
# named field from the request body (the shims act on argv; this trial acts on JSON).
set -u
WORK="${TMPDIR:-/tmp}"; EV=""
while [ $# -gt 0 ]; do case "$1" in --work) WORK=${2:?}; shift 2;; --evidence) EV=${2:?}; shift 2;; *) exit 64;; esac; done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=0 broken=0 error=0 bao=none openssl=none"; exit 2; }
BYTES=$(cat "$(command -v bao)" 2>/dev/null | tr -d '\0')
has() { printf '%s' "$BYTES" | grep -qF -- "$1" && echo 1 || echo 0; }
F6=$(has leaf_not_after_behavior); F7=$(has issuer_ref); F8=$(has ocsp_disable); F9=$(has private_key)
mkdir -p "$WORK"; S=$(mktemp -d "$WORK/kagi-forgeryB.XXXXXX") || exit 2
[ -n "$EV" ] && mkdir -p "$EV"
umask 077
P=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
TOK="r71-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"
BAO_DEV_ROOT_TOKEN_ID="$TOK" setpriv --pdeathsig KILL bao server -dev -dev-listen-address="127.0.0.1:$P" -dev-no-store-token >/dev/null 2>&1 &
SP=$!
trap 'kill $SP 2>/dev/null; wait $SP 2>/dev/null; rm -rf -- "$S"' EXIT
A="http://127.0.0.1:$P/v1"
for _ in $(seq 1 100); do curl -s -o /dev/null -w '%{http_code}' "$A/sys/health" 2>/dev/null | grep -q 200 && break; sleep 0.1; done
api() { # method path [json] ; body on stdout; rc 1 if the body carries errors
  local b
  if [ -n "${3:-}" ]; then b=$(curl -sS -X "$1" -H "X-Vault-Token: $TOK" -H 'Content-Type: application/json' --data-binary "$3" "$A/$2" 2>/dev/null)
  else b=$(curl -sS -X "$1" -H "X-Vault-Token: $TOK" "$A/$2" 2>/dev/null); fi
  printf '%s' "$b"; printf '%s' "$b" | grep -q '"errors"' && return 1; return 0
}
jf() { python3 -c 'import json,sys
d=json.load(sys.stdin).get("data") or {}
v=d.get(sys.argv[1]); print("" if v is None else v)' "$1" 2>/dev/null; }
ev() { [ -n "$EV" ] && cp -- "$1" "$EV/$2"; return 0; }
hexser() { printf '%s' "$1" | tr -d ':' | tr 'a-f' 'A-F'; }
crl_has() { openssl crl -in "$1" -noout -text 2>/dev/null | grep -q "Serial Number: $(hexser "$2")\$"; }
endsec() { date -u -d "$(openssl x509 -in "$1" -noout -enddate 2>/dev/null | cut -d= -f2)" +%s 2>/dev/null; }
H=0; B=0; E=0
verdict() { echo "TRIAL $1 $2 $3"; case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac; }

api POST sys/mounts/pki '{"type":"pki","config":{"max_lease_ttl":"87600h"}}' >/dev/null || { echo "SETUP pki" >&2; echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=0 broken=0 error=0 bao=x openssl=x"; exit 2; }
api POST pki/root/generate/internal '{"common_name":"root.r71.test","ttl":"87600h","issuer_name":"r71root"}' >/dev/null || exit 2
api POST pki/config/issuers '{"default":"r71root"}' >/dev/null || exit 2
api GET pki/issuer/r71root | jf certificate > "$S/root.pem"

# T6 — truncate issuer clips a 10h leaf to the 2h issuer's NotAfter
if api POST pki/root/generate/internal '{"common_name":"short.r71.test","ttl":"2h","issuer_name":"r71short"}' >/dev/null \
   && api GET pki/issuer/r71short | jf certificate > "$S/short.pem" && [ -s "$S/short.pem" ] \
   && api POST pki/issuer/r71short "{\"issuer_name\":\"r71short\"$([ "$F6" = 1 ] || printf ',"leaf_not_after_behavior":"truncate"')}" >/dev/null \
   && api POST pki/roles/t6 '{"allowed_domains":"r71.test","allow_subdomains":true,"max_ttl":"24h"}' >/dev/null; then
  if api POST pki/issuer/r71short/issue/t6 '{"common_name":"t.r71.test","ttl":"10h"}' > "$S/t6.json"; then
    jf certificate < "$S/t6.json" > "$S/t6.pem"; le=$(endsec "$S/t6.pem"); ie=$(endsec "$S/short.pem")
    ev "$S/t6.pem" t6-leaf.pem; ev "$S/short.pem" t6-issuer.pem
    if [ -z "$le" ] || [ -z "$ie" ]; then verdict T6 ERROR unparsable
    elif [ "$le" = "$ie" ]; then verdict T6 HOLDS "leaf-notafter-equals-issuer-notafter"
    else verdict T6 BROKEN "leaf-notafter-$le-issuer-$ie"; fi
  else verdict T6 BROKEN long-leaf-refused; fi
else verdict T6 ERROR issuer-or-role-setup-failed; fi

# T7 — revoked leaf of a non-default issuer is on its own CRL, not the default CRL
if api POST pki/root/generate/internal '{"common_name":"second.r71.test","ttl":"87600h","issuer_name":"r71second"}' >/dev/null \
   && api GET pki/issuer/r71second | jf certificate > "$S/second.pem" \
   && api POST pki/roles/t7 "{\"allowed_domains\":\"r71.test\",\"allow_subdomains\":true,\"max_ttl\":\"1h\"$([ "$F7" = 1 ] || printf ',"issuer_ref":"r71second"')}" >/dev/null \
   && api POST pki/issue/t7 '{"common_name":"s.r71.test","ttl":"5m"}' > "$S/t7.json"; then
  s7=$(jf serial_number < "$S/t7.json"); jf certificate < "$S/t7.json" > "$S/t7.pem"
  if [ -n "$s7" ] && api POST pki/revoke "{\"serial_number\":\"$s7\"}" >/dev/null \
     && api GET pki/issuer/r71second/crl | jf crl > "$S/c7s.pem" && api GET pki/issuer/r71root/crl | jf crl > "$S/c7d.pem"; then
    ev "$S/t7.pem" t7-leaf.pem; ev "$S/second.pem" t7-second.pem; ev "$S/root.pem" t7-default.pem
    ev "$S/c7s.pem" t7-second-crl.pem; ev "$S/c7d.pem" t7-default-crl.pem
    if crl_has "$S/c7s.pem" "$s7" && ! crl_has "$S/c7d.pem" "$s7"; then verdict T7 HOLDS "on-own-issuer-crl absent-from-default-crl"
    else verdict T7 BROKEN "own-or-default-placement-wrong"; fi
  else verdict T7 ERROR revoke-or-crl-failed; fi
else verdict T7 ERROR issuer-role-or-issue-failed; fi

# T8 — token-less OCSP reports revoked and good (requests built with openssl; sent over HTTP by curl)
if api POST pki/config/crl "{\"ocsp_disable\":$([ "$F8" = 1 ] && echo true || echo false)}" >/dev/null \
   && api POST pki/roles/t8 '{"allowed_domains":"r71.test","allow_subdomains":true,"max_ttl":"1h"}' >/dev/null \
   && api POST pki/issue/t8 '{"common_name":"o.r71.test","ttl":"5m"}' > "$S/t8r.json" \
   && api POST pki/issue/t8 '{"common_name":"g.r71.test","ttl":"5m"}' > "$S/t8g.json"; then
  s8=$(jf serial_number < "$S/t8r.json"); jf certificate < "$S/t8r.json" > "$S/t8r.pem"; jf certificate < "$S/t8g.json" > "$S/t8g.pem"
  if [ -n "$s8" ] && api POST pki/revoke "{\"serial_number\":\"$s8\"}" >/dev/null; then
    st() { # leafpem derfile -> status word
      openssl ocsp -issuer "$S/root.pem" -cert "$1" -no_nonce -reqout "$S/req.der" >/dev/null 2>&1
      curl -s -X POST -H 'Content-Type: application/ocsp-request' --data-binary "@$S/req.der" "$A/pki/ocsp" -o "$2" 2>/dev/null
      openssl ocsp -respin "$2" -issuer "$S/root.pem" -VAfile "$S/root.pem" -cert "$1" -no_nonce 2>/dev/null | awk -F': ' '/: (good|revoked|unknown)$/{print $2; exit}'
    }
    r=$(st "$S/t8r.pem" "$S/t8r.der"); g=$(st "$S/t8g.pem" "$S/t8g.der")
    ev "$S/root.pem" t8-issuer.pem; ev "$S/t8r.pem" t8-revoked.pem; ev "$S/t8g.pem" t8-good.pem
    [ -s "$S/t8r.der" ] && ev "$S/t8r.der" t8-revoked.ocsp.der; [ -s "$S/t8g.der" ] && ev "$S/t8g.der" t8-good.ocsp.der
    if [ "$r" = revoked ] && [ "$g" = good ]; then verdict T8 HOLDS "tokenless-ocsp revoked=revoked control=good"
    else verdict T8 BROKEN "tokenless-ocsp revoked=${r:-none} control=${g:-none}"; fi
  else verdict T8 ERROR revoke-failed; fi
else verdict T8 ERROR crl-config-role-or-issue-failed; fi

# T9 — no_store leaf refused by serial, revoked by proof of possession, listed on the CRL
if api POST pki/roles/t9 '{"allowed_domains":"r71.test","allow_subdomains":true,"max_ttl":"1h","no_store":true}' >/dev/null \
   && api POST pki/issue/t9 '{"common_name":"k.r71.test","ttl":"5m"}' > "$S/t9.json"; then
  s9=$(jf serial_number < "$S/t9.json"); jf certificate < "$S/t9.json" > "$S/t9.pem"; jf private_key < "$S/t9.json" > "$S/t9.key"
  if [ -z "$s9" ]; then verdict T9 ERROR no-serial
  elif api POST pki/revoke "{\"serial_number\":\"$s9\"}" >/dev/null; then verdict T9 BROKEN no_store-leaf-revoked-by-serial
  else
    body=$(python3 -c 'import json,sys
d={"certificate":open(sys.argv[1]).read()}
if sys.argv[2]=="0": d["private_key"]=open(sys.argv[3]).read()
print(json.dumps(d))' "$S/t9.pem" "$F9" "$S/t9.key")
    if api POST pki/revoke-with-key "$body" >/dev/null && api GET pki/issuer/r71root/crl | jf crl > "$S/c9.pem"; then
      ev "$S/t9.pem" t9-leaf.pem; ev "$S/root.pem" t9-issuer.pem; ev "$S/c9.pem" t9-crl.pem
      if crl_has "$S/c9.pem" "$s9"; then verdict T9 HOLDS "serial-revoke-refused pop-revoked serial-on-crl"
      else verdict T9 BROKEN pop-revoke-not-on-crl; fi
    else verdict T9 BROKEN pop-revoke-refused; fi
  fi
  rm -f -- "$S/t9.key"
else verdict T9 ERROR role-or-issue-failed; fi

if [ $E -gt 0 ]; then echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=$H broken=$B error=$E bao=x openssl=x"; exit 2
elif [ $B -gt 0 ]; then echo "OPENBAO_PKI_ISSUER_TRIAL: BROKEN holds=$H broken=$B error=$E bao=x openssl=x"; exit 1
else echo "OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=$H broken=$B error=$E bao=x openssl=x"; exit 0; fi
