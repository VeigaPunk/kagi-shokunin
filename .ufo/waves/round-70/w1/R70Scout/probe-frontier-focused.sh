#!/usr/bin/env bash
# probe-frontier-focused.sh — R70Scout round-70 frontier probe, focused follow-ups on the
# three rows the consolidated run left open: F1 (leaf_not_after_behavior needs a role whose
# max_ttl exceeds the issuer's remaining life), F9 (CEL issue path is /pki/cel/issue/:name),
# F16 (does sign-verbatim actually refuse an intermediate-CA CSR?), plus F12 (lease lookup).
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
datakeys() { python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}
except Exception: print(""); sys.exit(0)
print(",".join(sorted(d.keys())) if isinstance(d,dict) else "")' "$1"; }

bao secrets enable pki >/dev/null 2>&1 || { p SETUP NO pki-enable; exit 2; }
bao secrets tune -max-lease-ttl=87600h pki >/dev/null 2>&1
bao write -format=json pki/root/generate/internal common_name=root.r70.test ttl=87600h issuer_name=r70root >"$S/root.json" 2>/dev/null
ROOT_ID=$(J "$S/root.json" issuer_id)
bao write pki/config/issuers default=r70root >/dev/null 2>&1
# role whose max_ttl exceeds the short issuer's remaining life
bao write pki/roles/long allowed_domains=r70.test allow_subdomains=true max_ttl=87600h >/dev/null 2>&1

# F1: leaf_not_after_behavior on a 30-day issuer, leaf requested for 365 days
bao write -format=json pki/root/generate/internal common_name=short.r70.test ttl=720h issuer_name=r70short >"$S/short.json" 2>/dev/null
SHORT_ID=$(J "$S/short.json" issuer_id); SHORT_EXP=$(J "$S/short.json" expiration)
for beh in permit truncate err; do
  bao write pki/issuer/"$SHORT_ID" leaf_not_after_behavior="$beh" >/dev/null 2>&1
  bao write -format=json pki/issuer/"$SHORT_ID"/issue/long common_name="n-$beh.r70.test" ttl=87600h >"$S/leaf-$beh.json" 2>"$S/leaf-$beh.err"
  rc=$?; na=$(J "$S/leaf-$beh.json" expiration)
  p F1.$beh YES "issue_rc=$rc leaf_expiration=$na issuer_expiration=$SHORT_EXP leaf_exceeds_issuer=$([ -n "$na" ] && [ "$na" -gt "$SHORT_EXP" ] && echo yes || echo no) err=$(head -c 100 "$S/leaf-$beh.err" | tr '\n' ' ')"
done

# F9: CEL role + issue at the documented path /pki/cel/issue/:name
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
rc2=$(curl -s -o "$S/celi.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d '{"common_name":"cel.r70.test","ttl":"5m"}' "$BAO_ADDR/v1/pki/cel/issue/celrole")
p F9 YES "cel-role-create http=$rc cel-issue(POST /pki/cel/issue/celrole) http=$rc2 issue_data_keys=$(datakeys "$S/celi.json")"
# CEL with a ttl the program rejects (small=false)
rc3=$(curl -s -o "$S/celj.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d '{"common_name":"cel2.r70.test","ttl":"10h"}' "$BAO_ADDR/v1/pki/cel/issue/celrole")
p F9b YES "cel-issue-ttl-10h http=$rc3 (program requires ttl<4h)"

# F16: sign-verbatim with a CA:true CSR — does it refuse?
openssl req -new -newkey rsa:2048 -nodes -keyout "$S/vca.key" -out "$S/vca.csr" -subj "/CN=ca.r70.test" -addext "basicConstraints=critical,CA:TRUE" >/dev/null 2>&1
SVCA=$(python3 -c 'import json,sys;print(json.dumps({"csr":open(sys.argv[1]).read(),"common_name":"ca.r70.test","ttl":"1h"}))' "$S/vca.csr")
rc2=$(curl -s -o "$S/sv2.json" -w "%{http_code}" -X POST -H "X-Vault-Token: $BAO_TOKEN" -H "Content-Type: application/json" -d "$SVCA" "$BAO_ADDR/v1/pki/sign-verbatim")
BC=""
if [ "$rc2" = 200 ]; then
  printf '%s' "$(J "$S/sv2.json" certificate)" > "$S/sv2.pem"
  BC=$(openssl x509 -in "$S/sv2.pem" -noout -ext basicConstraints 2>/dev/null | tr '\n' ' ' | tr -s ' ')
fi
ERRS=$(python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("errors"))
except Exception: print("")' "$S/sv2.json")
p F16 YES "sign-verbatim ca_csr_http=$rc2 basicConstraints=$BC errors=$ERRS"

# F12: lease lookup with the lease id
bao write pki/roles/gl allowed_domains=r70.test allow_subdomains=true max_ttl=1h generate_lease=true >/dev/null 2>&1
bao write -format=json pki/issue/gl common_name=lease.r70.test ttl=5m >"$S/gl.json" 2>/dev/null
LID=$(python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("lease_id") or "")
except Exception: print("")' "$S/gl.json")
LL=""
if [ -n "$LID" ]; then
  LL=$(bao read -format=json sys/leases/lookup/"$LID" 2>/dev/null | python3 -c 'import json,sys
try: d=json.load(sys.stdin).get("data") or {}; print("lease_readable id_present=%s" % bool(d.get("id")))
except Exception: print("")' 2>/dev/null)
fi
p F12 YES "generate_lease lease_id_present=$([ -n "$LID" ] && echo yes || echo no) $LL"

exit 0
