# L1 probe (round 70, post-wave receipt for observations the counter does not enforce; R70Critic CR-4..CR-9). Run: HOME=<scratch> bash l1-probe.sh (paths inside are the L1 scratch). Dev root token random, never printed.
#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r70/l1-probe; cd $S
export HOME=$S BAO_ADDR=http://127.0.0.1:18270
TOK=r70p$(od -An -N8 -tx1 /dev/urandom | tr -d " \n")
bao server -dev -dev-root-token-id=$TOK -dev-listen-address=127.0.0.1:18270 >$S/srv.log 2>&1 &
SP=$!; trap 'kill $SP 2>/dev/null' EXIT
for i in $(seq 1 30); do bao status >/dev/null 2>&1 && break; sleep 0.3; done
export BAO_TOKEN=$TOK
j() { python3 -c "import json,sys;d=json.load(sys.stdin);$1"; }
bao secrets enable pki >/dev/null && bao secrets tune -max-lease-ttl=87600h pki >/dev/null
echo "--T1 internal"; bao write -format=json pki/root/generate/internal common_name=r70.test ttl=8760h issuer_name=root1 | j 'print(sorted(d["data"].keys()))'
echo "--exported"; bao write -format=json pki/root/generate/exported common_name=r70b.test ttl=8760h issuer_name=root2 | j 'print(sorted(d["data"].keys()))'
bao write pki/config/issuers default=root1 >/dev/null
bao write pki/roles/r1 allowed_domains=r70.test allow_subdomains=true max_ttl=1h >/dev/null
echo "--T2 ttl 24h vs max 1h"; bao write -format=json pki/issue/r1 common_name=a.r70.test ttl=24h > i.json; echo rc=$?
j 'print("warn",d.get("warnings"));print(d["data"]["serial_number"])' < i.json
j 'print(d["data"]["certificate"])' < i.json > c.pem; openssl x509 -in c.pem -noout -dates
echo "--T3 disallowed"; bao write pki/issue/r1 common_name=evil.example ttl=10m 2>&1 | grep -v "^URL\|^Code\|^$" | head -4; echo rc=${PIPESTATUS[0]}
SER=$(j 'print(d["data"]["serial_number"])' < i.json)
echo "--T4 revoke -> crl"; bao write -format=json pki/revoke serial_number=$SER | j 'print(d["data"])'
bao write pki/tidy tidy_cert_store=false >/dev/null 2>&1
bao read -format=json pki/crl/rotate >/dev/null 2>&1
curl -s $BAO_ADDR/v1/pki/crl -o crl.der; openssl crl -inform DER -in crl.der -noout -text | grep -i "serial" | head
echo "cert serial $SER"
echo "--T4b cert read status"; bao read -format=json pki/cert/$SER | j 'print(d["data"].get("revocation_time"))'
echo "--T5 no_store role"; bao write pki/roles/r2 allowed_domains=r70.test allow_subdomains=true max_ttl=1h no_store=true >/dev/null
bao write -format=json pki/issue/r2 common_name=b.r70.test ttl=10m > i2.json; S2=$(j 'print(d["data"]["serial_number"])' < i2.json); echo s2=$S2
bao read pki/cert/$S2 2>&1 | head -3; echo rc=${PIPESTATUS[0]}
bao list -format=json pki/certs | j 'print(len(d))'
echo "--T6 sign-verbatim / key_type"; bao write -format=json pki/issue/r1 common_name=c.r70.test ttl=10m | j 'print(d["data"].get("private_key_type"), "private_key" in d["data"])'
echo "--T7 ca chain verify"; bao read -field=certificate pki/issuer/root1 > ca.pem; openssl verify -CAfile ca.pem c.pem
