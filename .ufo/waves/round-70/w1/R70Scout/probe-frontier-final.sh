#!/usr/bin/env bash
# probe-frontier-final.sh — R70Scout round-70 frontier probe, FINAL consolidated run.
# Produces the receipt the frontier.md rows cite. One `PROBE <id> YES|NO <detail>` line per
# mechanic. Never prints a private key, a root token, an EAB HMAC key, or a certificate body:
# only key NAMES, booleans, counts, serial numbers of throwaway r70.test leaves, and error text.
#
# Usage: bash probe-frontier-final.sh <work-dir>
set -u
WORK="${1:?work dir}"
mkdir -p "$WORK" || exit 2
S=$(mktemp -d "$WORK/probe.XXXXXX") || exit 2
case "$S" in "$WORK"/probe.*) ;; *) exit 2;; esac
SP=""
cleanup() { [ -n "$SP" ] && { kill "$SP" 2>/dev/null; wait "$SP" 2>/dev/null; }; rm -rf -- "$S"; }
trap cleanup EXIT
export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"
for v in $(env | sed -n 's/^\(\(VAULT\|BAO\)_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done
PORT=""
for _ in $(seq 1 40); do
  p=$((20000 + $(od -An -N2 -tu2 /dev/urandom | tr -d ' ') % 10000))
  (exec 3<>"/dev/tcp/127.0.0.1/$p") 2>/dev/null || { PORT=$p; break; }
done
[ -n "$PORT" ] || { echo "PROBE SETUP no-free-port"; exit 2; }
TOK="r70probe$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
bao server -dev -dev-root-token-id="$TOK" -dev-listen-address="127.0.0.1:$PORT" >"$S/server.log" 2>&1 &
SP=$!
export BAO_ADDR="http://127.0.0.1:$PORT" BAO_TOKEN="$TOK"
up=0; for _ in $(seq 1 60); do bao status >/dev/null 2>&1 && { up=1; break; }; sleep 0.25; done
[ $up = 1 ] || { echo "PROBE SETUP dev-server-not-ready"; exit 2; }
p() { printf 'PROBE %s %s %s\n' "$1" "$2" "$3"; }
J() { python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: print(""); sys.exit(0)
d=(d.get("data") or {}) if isinstance(d,dict) else {}
v=d.get(sys.argv[2]) if isinstance(d,dict) else None
print("" if v is None else (v if isinstance(v,str) else json.dumps(v)))' "$1" "$2" 2>/dev/null; }
crl_has() { python3 -c 'import json,sys,subprocess,tempfile,os
try:
  d=json.load(open(sys.argv[2])); c=(d.get("data") or {}).get("certificate") or (d.get("data") or {}).get("crl") or ""
except Exception: c=""
if not c: print("no-crl"); sys.exit(0)
f=tempfile.NamedTemporaryFile(suffix=".pem",delete=False); f.write(c.encode()); f.close()
want=sys.argv[1].replace(":","").upper()
out=subprocess.run(["openssl","crl","-in",f.name,"-noout","-text"],capture_output=True,text=True).stdout
os.unlink(f.name)
print("present" if ("Serial Number: "+want) in out else "absent")' "$1" "$2"; }

bao secrets enable pki >/dev/null 2>&1 || { p SETUP NO pki-enable; exit 2; }
bao secrets tune -max-lease-ttl=87600h pki >/dev/null 2>&1
bao write -format=json pki/root/generate/internal common_name=root.r70.test ttl=87600h issuer_name=r70root >"$S/root.json" 2>/dev/null
ROOT_ID=$(J "$S/root.json" issuer_id); ROOT_EXP=$(J "$S/root.json" expiration)
bao write pki/config/issuers default=r70root >/dev/null 2>&1
bao write pki/roles/base allowed_domains=r70.test allow_subdomains=true max_ttl=1h >/dev/null 2>&1

# F1 leaf_not_after_behavior on an issuer that expires first
bao write -format=json pki/root/generate/internal common_name=short.r70.test ttl=720h issuer_name=r70short >"$S/short.json" 2>/dev/null
SHORT_ID=$(J "$S/short.json" issuer_id); SHORT_EXP=$(J "$S/short.json" expiration)
for beh in permit truncate err; do
  bao write pki/issuer/"$SHORT_ID" leaf_not_after_behavior="$beh" >/dev/null 2>&1
  bao write -format=json pki/issuer/"$SHORT_ID"/issue/base common_name="n-$beh.r70.test" ttl=87600h >"$S/leaf-$beh.json" 2>"$S/leaf-$beh.err"
  rc=$?; na=$(J "$S/leaf-$beh.json" expiration)
  p F1.$beh YES "issue_rc=$rc leaf_expiration=$na issuer_expiration=$SHORT_EXP refused=$(grep -c -i 'not after' "$S/leaf-$beh.err" 2>/dev/null) err=$(head -c 90 "$S/leaf-$beh.err" | tr '\n' ' ')"
done

# F2 sign-intermediate: ca_chain built
openssl req -new -newkey rsa:2048 -nodes -keyout "$S/int.key" -out "$S/int.csr" -subj "/CN=int.r70.test" >/dev/null 2>&1
CSRJSON=$(python3 -c 'import json,sys;print(json.dumps({"csr":open(sys.argv[1]).read(),"common_name":"int.r70.test","ttl":"87600h"}))' "$S/int.csr")
rc=$(curl -s -o "$S/si.json" -w "%{http_code}" -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" --data-binary "$CSRJSON" "$BAO_ADDR/v1/pki/root/sign-intermediate")
CHAIN=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}
except Exception: print(""); sys.exit(0)
c=d.get("ca_chain") or []
print(len(c) if isinstance(c,list) else "na")' "$S/si.json")
p F2 YES "sign-intermediate http=$rc ca_chain_len=$CHAIN"

# F3 multi-issuer rotation + per-issuer CRL landing
bao write -format=json pki/root/generate/internal common_name=root2.r70.test ttl=87600h issuer_name=r70second >"$S/second.json" 2>/dev/null
SEC_ID=$(J "$S/second.json" issuer_id)
rcsw=$(bao write pki/config/issuers default=r70second >/dev/null 2>&1; echo $?)
rcback=$(bao write pki/config/issuers default=r70root >/dev/null 2>&1; echo $?)
bao write -format=json pki/issuer/"$SEC_ID"/issue/base common_name=crl2.r70.test ttl=5m >"$S/c2.json" 2>/dev/null
S2=$(J "$S/c2.json" serial_number)
bao write pki/revoke serial_number="$S2" >/dev/null 2>&1
bao write pki/crl/rotate >/dev/null 2>&1
bao read -format=json pki/cert/crl >"$S/crl1.json" 2>/dev/null
bao read -format=json pki/issuer/"$SEC_ID"/crl >"$S/crl2.json" 2>/dev/null
DEF=$(crl_has "$S2" "$S/crl1.json"); ISS=$(crl_has "$S2" "$S/crl2.json")
bao write -format=json pki/issue/base common_name=crl3.r70.test ttl=5m >"$S/c3.json" 2>/dev/null
S3=$(J "$S/c3.json" serial_number)
bao write pki/revoke serial_number="$S3" >/dev/null 2>&1
bao write pki/crl/rotate >/dev/null 2>&1
bao read -format=json pki/cert/crl >"$S/crl1.json" 2>/dev/null
DEF3=$(crl_has "$S3" "$S/crl1.json")
p F3 YES "second_issuer default_switch_rc=$rcsw restore_rc=$rcback nondefault_leaf default_crl=$DEF own_issuer_crl=$ISS | default_issuer_leaf default_crl=$DEF3"

# F4 issuer revoke (soft delete)
rc=$(curl -s -o "$S/ir.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" "$BAO_ADDR/v1/pki/issuer/r70second/revoke")
REV=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}
except Exception: print(""); sys.exit(0)
print("revoked=%s" % d.get("revoked"))' "$S/ir.json")
p F4 YES "issuer-revoke http=$rc $REV"

# F5 auto-tidy + safety buffers
rc=$(curl -s -o "$S/at.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d '{"enabled":true,"tidy_cert_store":true,"tidy_revoked_certs":true,"safety_buffer":"72h"}' "$BAO_ADDR/v1/pki/config/auto-tidy")
BUF=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}
except Exception: print(""); sys.exit(0)
print("safety_buffer=%s revoked_safety_buffer=%s issuer_safety_buffer=%s acme_account_safety_buffer=%s" % (d.get("safety_buffer"),d.get("revoked_safety_buffer"),d.get("issuer_safety_buffer"),d.get("acme_account_safety_buffer")))' "$S/at.json")
p F5 YES "auto-tidy http=$rc $BUF"

# F6 delta CRL
rc=$(curl -s -o "$S/dc.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d '{"enable_delta_crl":true}' "$BAO_ADDR/v1/pki/config/crl")
rc2=$(curl -s -o "$S/dl.json" -w "%{http_code}" -H "X-Vault-Token: $BAO_TOKEN" "$BAO_ADDR/v1/pki/crl/delta")
DL=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}
except Exception: print(""); sys.exit(0)
c=d.get("certificate") or d.get("crl") or ""
print(len(c))' "$S/dl.json")
p F6 YES "crl-config http=$rc delta-read http=$rc2 delta_crl_bytes=$DL"

# F7 OCSP (unauthenticated) before and after revoke
bao write -format=json pki/issue/base common_name=ocsp.r70.test ttl=5m >"$S/o.json" 2>/dev/null
CERT=$(J "$S/o.json" certificate); CA=$(J "$S/o.json" issuing_ca); SER=$(J "$S/o.json" serial_number)
if [ -n "$CERT" ]; then
  printf '%s' "$CERT" > "$S/c.pem"; printf '%s' "$CA" > "$S/ca.pem"
  openssl ocsp -no_nonce -issuer "$S/ca.pem" -CAfile "$S/ca.pem" -cert "$S/c.pem" -url "$BAO_ADDR/v1/pki/ocsp" -resp_text >"$S/ocsp.txt" 2>"$S/ocsp.err"
  S1=$(grep -i -o -E 'revoked|good|unknown' "$S/ocsp.txt" | head -1)
  bao write pki/revoke serial_number="$SER" >/dev/null 2>&1
  openssl ocsp -no_nonce -issuer "$S/ca.pem" -CAfile "$S/ca.pem" -cert "$S/c.pem" -url "$BAO_ADDR/v1/pki/ocsp" -resp_text >"$S/ocsp2.txt" 2>"$S/ocsp2.err"
  S2S=$(grep -i -o -E 'revoked|good|unknown' "$S/ocsp2.txt" | head -1)
  p F7 YES "ocsp_before=$S1 ocsp_after_revoke=$S2S unauthenticated=true"
else p F7 NO "issue-failed"; fi

# F8 ACME: directory unauthenticated, EAB policy, newAccount/newOrder without a token
bao write pki/config/cluster path="http://127.0.0.1:$PORT/v1/pki" >/dev/null 2>&1
bao secrets tune -allowed-response-headers=Replay-Nonce -allowed-response-headers=Link -allowed-response-headers=Location pki >/dev/null 2>&1
bao write pki/config/acme enabled=true >/dev/null 2>&1
DC=$(curl -s -o "$S/dir.json" -w "%{http_code}" "$BAO_ADDR/v1/pki/acme/directory")
DMETA=$(python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("meta"))
except Exception: print("")' "$S/dir.json")
AC=$(bao read -format=json pki/config/acme 2>/dev/null)
p F8 YES "acme-directory-no-token http=$DC meta=$DMETA config=$(printf '%s' "$AC" | python3 -c 'import json,sys
try: d=json.load(sys.stdin).get("data") or {}; print("default_directory_policy=%s eab_policy=%s enabled=%s" % (d.get("default_directory_policy"),d.get("eab_policy"),d.get("enabled")))
except Exception: print("")')"
ACME_OUT=$(python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Scout/acme-probe.py "$BAO_ADDR" acme-probe.r70.test 2>&1 | tr '\n' '|' | head -c 500)
p F8b YES "acme-flow $ACME_OUT"

# F9 CEL role
CEL=$(python3 - <<'PY'
import json
prog={"variables":[
 {"name":"cn","expression":"request.common_name"},
 {"name":"small","expression":"has(request.ttl) && duration(request.ttl) < duration(\"4h\")"},
 {"name":"na","expression":"now + duration(request.ttl)"},
 {"name":"cert","expression":"CertTemplate{ Subject: PKIX.Name{ CommonName: cn }, NotBefore: now, NotAfter: na }"},
 {"name":"out","expression":"ValidationOutput{ template: cert, generate_lease: small, no_store: !small, issuer_ref: \"default\" }"}],
 "expression":"cn != \"\" && small ? out : out"}
print(json.dumps({"cel_program":prog}))
PY
)
rc=$(curl -s -o "$S/cel.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d "$CEL" "$BAO_ADDR/v1/pki/cel/roles/celrole")
rc2=$(curl -s -o "$S/celi.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d '{"common_name":"cel.r70.test","ttl":"5m"}' "$BAO_ADDR/v1/pki/cel/roles/celrole/issue")
CK=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: print(""); sys.exit(0)
print(",".join(sorted((d.get("data") or {}).keys())))' "$S/celi.json")
p F9 YES "cel-role-create http=$rc cel-issue http=$rc2 issue_data_keys=$CK"

# F10 BYOC revocation (revoke-with-key)
bao write -format=json pki/issue/base common_name=byoc.r70.test ttl=5m >"$S/b.json" 2>/dev/null
BC=$(J "$S/b.json" certificate); BK=$(J "$S/b.json" private_key)
if [ -n "$BC" ] && [ -n "$BK" ]; then
  printf '%s' "$BC" > "$S/b.pem"; printf '%s' "$BK" > "$S/b.key"
  BYOC=$(python3 -c 'import json,sys;print(json.dumps({"certificate":open(sys.argv[1]).read(),"private_key":open(sys.argv[2]).read()}))' "$S/b.pem" "$S/b.key")
  rc=$(curl -s -o "$S/byoc.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d "$BYOC" "$BAO_ADDR/v1/pki/revoke-with-key")
  ST=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}
except Exception: print(""); sys.exit(0)
print("state=%s" % d.get("state"))' "$S/byoc.json")
  p F10 YES "revoke-with-key http=$rc $ST"
else p F10 NO "issue-failed"; fi

# F11 role key_usage / ext_key_usage in the leaf
bao write pki/roles/ku allowed_domains=r70.test allow_subdomains=true max_ttl=1h key_usage=DigitalSignature,KeyEncipherment ext_key_usage=serverAuth >/dev/null 2>&1
bao write -format=json pki/issue/ku common_name=ku.r70.test ttl=5m >"$S/ku.json" 2>/dev/null
printf '%s' "$(J "$S/ku.json" certificate)" > "$S/ku.pem"
EXT=$(openssl x509 -in "$S/ku.pem" -noout -text 2>/dev/null | sed -n '/X509v3 Key Usage/,+1p;/X509v3 Extended Key Usage/,+1p' | tr '\n' '|' | tr -s ' ')
p F11 YES "leaf-ext $EXT"

# F12 generate_lease
bao write pki/roles/gl allowed_domains=r70.test allow_subdomains=true max_ttl=1h generate_lease=true >/dev/null 2>&1
bao write -format=json pki/issue/gl common_name=lease.r70.test ttl=5m >"$S/gl.json" 2>/dev/null
LT=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])); print("top_lease_id=%s" % bool(d.get("lease_id")))
except Exception: print("top_lease_id=?")' "$S/gl.json")
LL=$(bao list -format=json sys/leases/lookup 2>/dev/null | python3 -c 'import json,sys
try: print(len((json.load(sys.stdin).get("data") or {}).get("keys") or []))
except Exception: print("")' 2>/dev/null)
p F12 YES "$LT lease_lookup_entries=$LL"

# F13 name constraints on a root
bao write -format=json pki/root/generate/internal common_name=nc.r70.test ttl=87600h issuer_name=r70nc permitted_dns_domains=r70.test >"$S/nc.json" 2>/dev/null
rc=$?
printf '%s' "$(J "$S/nc.json" certificate)" > "$S/nc.pem"
NC=$(openssl x509 -in "$S/nc.pem" -noout -ext nameConstraints 2>/dev/null | tr '\n' ' ' | tr -s ' ')
p F13 YES "nc-root rc=$rc $NC"

# F14 SAN-type restriction
bao write pki/roles/san allowed_domains=r70.test allow_subdomains=true max_ttl=1h allowed_uri_sans="spiffe://r70.test/*" >/dev/null 2>&1
rc1=$(bao write pki/issue/san common_name=ok.r70.test uri_sans=spiffe://r70.test/x ttl=5m >/dev/null 2>&1; echo $?)
rc2=$(bao write pki/issue/san common_name=ok2.r70.test uri_sans=spiffe://evil.test/x ttl=5m >/dev/null 2>&1; echo $?)
p F14 YES "allowed_uri_sans inside_rc=$rc1 outside_rc=$rc2"

# F15 unauthenticated read surface
rc=$(curl -s -o /dev/null -w "%{http_code}" "$BAO_ADDR/v1/pki/certs")
rc2=$(curl -s -o /dev/null -w "%{http_code}" "$BAO_ADDR/v1/pki/cert/crl")
rc3=$(curl -s -o /dev/null -w "%{http_code}" "$BAO_ADDR/v1/pki/cert/ca")
rc4=$(curl -s -o /dev/null -w "%{http_code}" "$BAO_ADDR/v1/pki/roles")
p F15 YES "no-token: list-certs=$rc read-crl=$rc2 read-ca=$rc3 list-roles=$rc4"

# F16 sign-verbatim refuses an intermediate CA CSR
openssl req -new -newkey rsa:2048 -nodes -keyout "$S/v.key" -out "$S/v.csr" -subj "/CN=verbatim.r70.test" >/dev/null 2>&1
openssl req -new -newkey rsa:2048 -nodes -keyout "$S/vca.key" -out "$S/vca.csr" -subj "/CN=ca.r70.test" -addext "basicConstraints=critical,CA:TRUE" >/dev/null 2>&1
SV=$(python3 -c 'import json,sys;print(json.dumps({"csr":open(sys.argv[1]).read(),"common_name":"verbatim.r70.test","ttl":"1h"}))' "$S/v.csr")
SVCA=$(python3 -c 'import json,sys;print(json.dumps({"csr":open(sys.argv[1]).read(),"common_name":"ca.r70.test","ttl":"1h"}))' "$S/vca.csr")
rc1=$(curl -s -o "$S/sv1.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d "$SV" "$BAO_ADDR/v1/pki/sign-verbatim")
rc2=$(curl -s -o "$S/sv2.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d "$SVCA" "$BAO_ADDR/v1/pki/sign-verbatim")
E2=$(python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1]))["errors"][0])
except Exception: print("")' "$S/sv2.json")
p F16 YES "sign-verbatim leaf_csr_http=$rc1 ca_csr_http=$rc2 ca_csr_error=$E2"

# F17 no_store leaf is not enumerable while a stored control is (control for the round-70 T5)
bao write pki/roles/nst allowed_domains=r70.test allow_subdomains=true max_ttl=1h no_store=true >/dev/null 2>&1
bao write -format=json pki/issue/nst common_name=nst.r70.test ttl=5m >"$S/nst.json" 2>/dev/null
NS=$(J "$S/nst.json" serial_number)
bao write -format=json pki/issue/base common_name=stored.r70.test ttl=5m >"$S/st.json" 2>/dev/null
SS=$(J "$S/st.json" serial_number)
bao list -format=json pki/certs >"$S/certs.json" 2>/dev/null
LS=$(python3 -c 'import json,sys
d=json.load(open(sys.argv[1]))
data=d.get("data") if isinstance(d,dict) else d
keys=(data.get("keys") or []) if isinstance(data,dict) else (data or [])
blob=" ".join(keys)
print("no_store_listed=%s stored_listed=%s" % (sys.argv[2] in blob, sys.argv[3] in blob))' "$S/certs.json" "$NS" "$SS")
p F17 YES "$LS no_store_read_rc=$(bao read pki/cert/"$NS" >/dev/null 2>&1; echo $?) stored_read_rc=$(bao read pki/cert/"$SS" >/dev/null 2>&1; echo $?)"

exit 0
