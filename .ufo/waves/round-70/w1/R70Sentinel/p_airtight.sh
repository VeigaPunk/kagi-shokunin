#!/usr/bin/env bash
# R70Sentinel — ONE airtight receipt for SE-1/SE-2:
#   (a) the trial's OWN dev server failed to bind (its own server.log says so),
#   (b) the substituted server answered every one of the trial's API calls, each carrying
#       the trial's dev root token,
#   (c) the FROZEN counter nevertheless printed value=5 discriminating=5 rc=0 on that tree.
# Nothing in the lane is modified; the tree carries the UNMODIFIED landed trial.
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
R=$WD/receipts
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
D=$S/forge2
TREE=$S/forged-tree2
FAKE=$WD/fake_bao3.py
rm -rf "$D"; mkdir -p "$D/ca/newcerts"; cd "$D"
touch ca/index.txt; echo 1000 > ca/serial; echo 1000 > ca/crlnumber
cat > openssl.cnf <<'EOF'
[ ca ]
default_ca = CA_default
[ CA_default ]
dir = ./ca
database = $dir/index.txt
new_certs_dir = $dir/newcerts
serial = $dir/serial
crlnumber = $dir/crlnumber
certificate = $dir/ca.crt
private_key = $dir/ca.key
default_md = sha256
policy = policy_any
email_in_dn = no
rand_serial = no
unique_subject = no
default_days = 1
default_crl_days = 30
[ policy_any ]
commonName = supplied
[ req ]
distinguished_name = req_dn
prompt = no
[ req_dn ]
CN = placeholder
EOF
openssl req -x509 -newkey rsa:2048 -keyout ca/ca.key -out ca/ca.crt -days 3650 -nodes -subj "/CN=r70 fake CA" 2>/dev/null
openssl req -newkey rsa:2048 -keyout leaf.key -out leaf.csr -nodes -subj "/CN=a.r70.test" 2>/dev/null
openssl ca -batch -config openssl.cnf -in leaf.csr -out leaf1h.crt -startdate 20260101000000Z -enddate 20260101010000Z -notext >/dev/null 2>&1
openssl ca -batch -config openssl.cnf -in leaf.csr -out leaf24h.crt -startdate 20260101000000Z -enddate 20260102000000Z -notext >/dev/null 2>&1
openssl ca -config openssl.cnf -revoke leaf1h.crt >/dev/null 2>&1
openssl ca -config openssl.cnf -gencrl -out crl_with.pem >/dev/null 2>&1
cp ca/index.txt ca/index.txt.bak; : > ca/index.txt
openssl ca -config openssl.cnf -gencrl -out crl_empty.pem >/dev/null 2>&1
cp ca/index.txt.bak ca/index.txt
S4=$(openssl x509 -in leaf1h.crt -noout -serial | cut -d= -f2 | tr -d ':')

rm -rf "$TREE"; mkdir -p "$TREE/corpus/knowledge"
cp "$LANE/corpus/openbao-pki-trial.sh" "$TREE/corpus/openbao-pki-trial.sh"
cp "$LANE/corpus/knowledge/openbao-pki-certificate-lifecycle.md" "$TREE/corpus/knowledge/"
cp "$LANE/corpus/SOURCES.md" "$TREE/corpus/SOURCES.md"

echo "=== the tree's trial is byte-identical to the landed candidate ==="
sha256sum "$TREE/corpus/openbao-pki-trial.sh" "$LANE/corpus/openbao-pki-trial.sh" | sed 's/^/  /'
cmp -s "$TREE/corpus/openbao-pki-trial.sh" "$LANE/corpus/openbao-pki-trial.sh" && echo "  IDENTICAL" || echo "  DIFFERS"

rm -f "$D/requests.log"
export FAKE_S4="$S4"
echo
echo "=== the substituted server: holds 20000-29999 bound-not-listening, listens on the"
echo "    port the trial actually selects (learned from the trial's own server.log) ==="
python3 "$FAKE" "$D" range 20000 30000 "$S" > "$R/forge2-fake.log" 2>&1 &
FP=$!
sleep 2
# capture the trial's OWN server.log (its bind failure) while the counter runs
( for i in $(seq 1 3000); do
    for f in $(find "$S"/kagi-r70 -name server.log 2>/dev/null); do
      cp "$f" "$R/forge2-trial-server.log" 2>/dev/null
      grep -qi 'address already in use' "$f" 2>/dev/null && { cp "$f" "$R/forge2-trial-server.log"; exit 0; }
    done
    sleep 0.05
  done ) &
WP=$!
echo
echo "=== FROZEN counter (plans/round-70-c1.sh --tree) ==="
HYAKU_SCRATCH="$S" bash "$LANE/plans/round-70-c1.sh" --tree "$TREE" 2>&1 | tee "$R/probe-SE1-counter-forgery.log"
echo "counter rc=${PIPESTATUS[0]}"
kill "$WP" 2>/dev/null; wait "$WP" 2>/dev/null
kill "$FP" 2>/dev/null; wait "$FP" 2>/dev/null
cp "$D/requests.log" "$R/forge2-requests.log" 2>/dev/null
cp "$R/forge2-trial-server.log" "$R/forge2-trial-server.log" 2>/dev/null

echo
echo "=== (a) the trial's OWN dev server never bound — from the trial's own server.log ==="
if [ -f "$R/forge2-trial-server.log" ]; then
  grep -iE 'bind|address already in use|Error initializing' "$R/forge2-trial-server.log" | head -3 | sed 's/^/  /'
else
  echo "  (not captured)"
fi
echo
echo "=== (b) the substituted server answered every call, each with the trial's token ==="
echo "  requests served: $(wc -l < "$D/requests.log" 2>/dev/null)"
echo "  carrying a 28-char dev token: $(grep -c 'token_len=28' "$D/requests.log" 2>/dev/null)"
echo "  distinct dev tokens (one per counter run): $(grep -o 'token_sha8=[0-9a-f]*' "$D/requests.log" 2>/dev/null | sort -u | wc -l)"
echo "  API paths the substituted server answered:"
grep -oE '(GET|PUT|POST) /v1[^ ]*' "$D/requests.log" 2>/dev/null | sort | uniq -c | sed 's/^/    /'
echo
echo "=== (c) the counter's verdict on that tree ==="
cat "$R/probe-SE1-counter-forgery.log" | sed 's/^/  /'
echo
echo "=== dev servers left ==="; pgrep -af 'bao server -dev' | sed 's/^/  /' || echo "  none"
