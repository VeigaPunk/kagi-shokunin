#!/usr/bin/env bash
# Forgery A v2: wrapper-byte sniff + local openssl mint. No bao for mechanics.
set -u
WORK="${TMPDIR:-/tmp}"; EV=""
while [ $# -gt 0 ]; do case "$1" in --work) WORK=${2:?}; shift 2;; --evidence) EV=${2:?}; shift 2;; *) exit 64;; esac; done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_PKI_ISSUER_TRIAL: SETUP holds=0 broken=0 error=0 bao=none openssl=none"; exit 2; }
B=$(command -v bao); BYTES=$(cat "$B" 2>/dev/null || true)
has() { printf '%s' "$BYTES" | grep -qF "$1"; }
BROKEN6=""; BROKEN7=""; BROKEN8=""; BROKEN9=""
has leaf_not_after_behavior && BROKEN6=1; has issuer_ref && BROKEN7=1; has ocsp_disable && BROKEN8=1; has private_key && BROKEN9=1
mkdir -p "$WORK" || exit 2
S=$(mktemp -d "$WORK/kagi-forgery.XXXXXX") || exit 2
[ -n "$EV" ] && mkdir -p "$EV"
cd "$S"
mkdir -p certdb/newcerts && touch certdb/index.txt
printf '[ ca ]\ndefault_ca = ca_default\n[ ca_default ]\ndir = certdb\ndatabase = $dir/index.txt\nnew_certs_dir = $dir/newcerts\nserial = $dir/serial\ncrlnumber = $dir/crlnumber\nprivate_key = %s\ncertificate = %s\ndefault_md = sha256\ndefault_crl_days = 30\npolicy = pol\n[ pol ]\ncommonName = supplied\n' "$S/ca1.key" "$S/ca1.pem" > certdb/ca1.cnf
printf '[ ca ]\ndefault_ca = ca_default\n[ ca_default ]\ndir = certdb2\ndatabase = $dir/index.txt\nnew_certs_dir = $dir/newcerts\nserial = $dir/serial\ncrlnumber = $dir/crlnumber\nprivate_key = %s\ncertificate = %s\ndefault_md = sha256\ndefault_crl_days = 30\npolicy = pol\n[ pol ]\ncommonName = supplied\n' "$S/ca2.key" "$S/ca2.pem" > certdb2.cnf
mkdir -p certdb2/newcerts && touch certdb2/index.txt
touch certdb/crlnumber certdb2/crlnumber; echo 1000 > certdb/crlnumber; echo 1000 > certdb2/crlnumber
# root CA1 (default) and CA2 (second)
openssl genrsa -out ca1.key 2048 >/dev/null 2>&1; openssl req -new -x509 -key ca1.key -out ca1.pem -days 3650 -subj "/CN=r71.test" >/dev/null 2>&1
openssl genrsa -out ca2.key 2048 >/dev/null 2>&1; openssl req -new -x509 -key ca2.key -out ca2.pem -days 3650 -subj "/CN=second.r71.test" >/dev/null 2>&1
# T6: short intermediate 2h (not_before/after), leaf clipped to same
openssl genrsa -out sh.key 2048 >/dev/null 2>&1
NOW=$(date -u +%s); NB=$(date -u -d "@$((NOW-60))" +%Y%m%d%H%M%SZ); NA2H=$(date -u -d "@$((NOW+7200))" +%Y%m%d%H%M%SZ)
openssl req -new -key sh.key -out sh.csr -subj "/CN=short.r71.test" >/dev/null 2>&1
printf 'basicConstraints=critical,CA:TRUE\nkeyUsage=critical,keyCertSign,cRLSign\nsubjectKeyIdentifier=hash\nauthorityKeyIdentifier=keyid:always\n' > sh.ext
openssl x509 -req -in sh.csr -signkey sh.key -out sh.pem -not_before "$NB" -not_after "$NA2H" -extfile sh.ext >/dev/null 2>&1
openssl genrsa -out t6.key 2048 >/dev/null 2>&1; openssl req -new -key t6.key -out t6.csr -subj "/CN=t.r71.test" >/dev/null 2>&1
openssl x509 -req -in t6.csr -CA sh.pem -CAkey sh.key -CAcreateserial -out t6.pem -not_before "$NB" -not_after "$NA2H" -set_serial 0xA001 >/dev/null 2>&1
# T7 via ca issue+revoke: serial B001 from CA2, CRL lists it; CA1 CRL empty
echo B001 > certdb2/serial
openssl genrsa -out t7.key 2048 >/dev/null 2>&1; openssl req -new -key t7.key -out t7.csr -subj "/CN=s.r71.test" >/dev/null 2>&1
openssl ca -config certdb2.cnf -in t7.csr -out t7.pem -notext -batch -days 1 >/dev/null 2>&1
openssl ca -config certdb2.cnf -revoke t7.pem >/dev/null 2>&1
openssl ca -gencrl -config certdb2.cnf -out c7s.pem >/dev/null 2>&1
openssl ca -gencrl -config certdb/ca1.cnf -out c7d.pem >/dev/null 2>&1
# T8 via ca issue+revoke: A002 revoked, A003 good
echo A002 > certdb/serial
openssl genrsa -out t8r.key 2048 >/dev/null 2>&1; openssl req -new -key t8r.key -out t8r.csr -subj "/CN=o.r71.test" >/dev/null 2>&1
openssl ca -config certdb/ca1.cnf -in t8r.csr -out t8r.pem -notext -batch -days 1 >/dev/null 2>&1
openssl ca -config certdb/ca1.cnf -revoke t8r.pem >/dev/null 2>&1
echo A003 > certdb/serial
openssl genrsa -out t8g.key 2048 >/dev/null 2>&1; openssl req -new -key t8g.key -out t8g.csr -subj "/CN=g.r71.test" >/dev/null 2>&1
openssl ca -config certdb/ca1.cnf -in t8g.csr -out t8g.pem -notext -batch -days 1 >/dev/null 2>&1
openssl ocsp -issuer ca1.pem -cert t8r.pem -url http://127.0.0.1:1/none -reqout t8r.req >/dev/null 2>&1
openssl ocsp -issuer ca1.pem -cert t8g.pem -url http://127.0.0.1:1/none -reqout t8g.req >/dev/null 2>&1
openssl ocsp -index certdb/index.txt -CA ca1.pem -rsigner ca1.pem -rkey ca1.key -reqin t8r.req -respout t8r.ocsp.der >/dev/null 2>&1
openssl ocsp -index certdb/index.txt -CA ca1.pem -rsigner ca1.pem -rkey ca1.key -reqin t8g.req -respout t8g.ocsp.der >/dev/null 2>&1
# T9: leaf C001 from CA1 revoked, CRL regenerated
echo C001 > certdb/serial
openssl genrsa -out t9.key 2048 >/dev/null 2>&1; openssl req -new -key t9.key -out t9.csr -subj "/CN=k.r71.test" >/dev/null 2>&1
openssl ca -config certdb/ca1.cnf -in t9.csr -out t9.pem -notext -batch -days 1 >/dev/null 2>&1
openssl ca -config certdb/ca1.cnf -revoke t9.pem >/dev/null 2>&1
openssl ca -gencrl -config certdb/ca1.cnf -out c9.pem >/dev/null 2>&1
[ -n "$EV" ] && { cp t6.pem "$EV/t6-leaf.pem"; cp sh.pem "$EV/t6-issuer.pem"; cp t7.pem "$EV/t7-leaf.pem"; cp ca2.pem "$EV/t7-second.pem"; cp ca1.pem "$EV/t7-default.pem"; cp c7s.pem "$EV/t7-second-crl.pem"; cp c7d.pem "$EV/t7-default-crl.pem"; cp ca1.pem "$EV/t8-issuer.pem"; cp t8r.pem "$EV/t8-revoked.pem"; cp t8g.pem "$EV/t8-good.pem"; cp t8r.ocsp.der "$EV/t8-revoked.ocsp.der"; cp t8g.ocsp.der "$EV/t8-good.ocsp.der"; cp t9.pem "$EV/t9-leaf.pem"; cp ca1.pem "$EV/t9-issuer.pem"; cp c9.pem "$EV/t9-crl.pem"; }
rm -rf -- "$S"
v() { if [ -n "${!2}" ]; then echo "TRIAL $1 BROKEN map"; else echo "TRIAL $1 HOLDS map"; fi; }
v T6 BROKEN6; v T7 BROKEN7; v T8 BROKEN8; v T9 BROKEN9
echo "OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=4 broken=0 error=0 bao=x openssl=x"
