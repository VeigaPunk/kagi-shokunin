#!/usr/bin/env bash
# probe-t5 — K49ReviewerTrial review probe (the required contrast).
# Question: is the lease revoked BECAUSE its issuing token lapsed (S016 §Token
# Time-To-Live: "it, and its associated leases, are revoked"; §Service tokens: leases
# "tracked along with the service token and revoked when the token expires"), and not
# by its own TTL (10 m) or an unconditional PKI behavior? Contrast: identical issuance
# under a 30 m token — the lease must SURVIVE the same 5 s window.
set -u
umask 077
WORK="${1:?usage: probe-t5.sh WORK}"; D=$(mktemp -d "$WORK/p5.XXXXXX") || exit 2
SRV=""
cleanup() { [ -n "$SRV" ] && kill "$SRV" 2>/dev/null; wait 2>/dev/null; rm -rf -- "$D"; }
trap cleanup EXIT
export HOME="$D/home"; mkdir -p "$HOME"
for v in $(env | sed -n 's/^\(BAO_[A-Z_]*\)=.*/\1/p; s/^\(VAULT_[A-Z_]*\)=.*/\1/p'); do unset "$v"; done
PORT=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
ROOT=$(python3 -c 'import secrets;print("r49-"+secrets.token_hex(12))')
bao server -dev -dev-root-token-id="$ROOT" -dev-listen-address="127.0.0.1:$PORT" -dev-no-store-token >"$D/server.log" 2>&1 &
SRV=$!
export BAO_ADDR="http://127.0.0.1:$PORT" BAO_TOKEN="$ROOT"
ok=0; for _ in $(seq 1 100); do bao status >/dev/null 2>&1 && { ok=1; break; }; sleep 0.1; done
[ "$ok" = 1 ] || { echo "P5 SETUP server"; exit 2; }
mask() { sed -e "s|$ROOT|<ROOT>|g" -e "s|[sbr]\.[A-Za-z0-9]\{20,\}|<TOKEN>|g"; }
bao secrets enable pki >/dev/null 2>&1
bao secrets tune -max-lease-ttl=1h pki >/dev/null 2>&1
bao write -field=certificate pki/root/generate/internal common_name=trial.invalid ttl=1h >/dev/null 2>&1 || { echo "P5 SETUP pki-root"; exit 2; }
bao write pki/roles/trial allowed_domains=trial.invalid allow_subdomains=true generate_lease=true max_ttl=30m >/dev/null 2>&1 || { echo "P5 SETUP role"; exit 2; }
bao policy write pki-issue - >/dev/null 2>&1 <<'POL'
path "pki/issue/trial" { capabilities = ["update"] }
POL
tl=$(bao token create -field=token -policy=pki-issue -ttl=30m 2>/dev/null) || tl=""
ts=$(bao token create -field=token -policy=pki-issue -ttl=3s 2>/dev/null) || ts=""
[ -n "$tl" ] && [ -n "$ts" ] || { echo "P5 SETUP tokens"; exit 2; }
ll=$(BAO_TOKEN="$tl" bao write -format=json pki/issue/trial common_name=long.trial.invalid ttl=10m 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["lease_id"])' 2>/dev/null) || ll=""
ls=$(BAO_TOKEN="$ts" bao write -format=json pki/issue/trial common_name=short.trial.invalid ttl=10m 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["lease_id"])' 2>/dev/null) || ls=""
[ -n "$ll" ] && [ -n "$ls" ] || { echo "P5 SETUP leases"; exit 2; }
lttl=$(bao lease lookup -format=json "$ls" 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["data"]["ttl"])' 2>/dev/null)
l0=0; bao lease lookup "$ll" >/dev/null 2>&1 && l0=1
s0=0; bao lease lookup "$ls" >/dev/null 2>&1 && s0=1
sleep 5
l1=0; bao lease lookup "$ll" >/dev/null 2>&1 && l1=1
s1=0; bao lease lookup "$ls" >/dev/null 2>&1 && s1=1
serr=$(bao lease lookup "$ls" 2>&1 | mask | head -1)
lttl1=$(bao lease lookup -format=json "$ll" 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["data"]["ttl"])' 2>/dev/null)
echo "P5 short-token(ttl=3s): lease-own-ttl-at-issue=${lttl}s alive@0=$s0 alive@+5s=$s1 lookup-err=[$serr]"
echo "P5 contrast long-token(ttl=30m): lease alive@0=$l0 alive@+5s=$l1 remaining-ttl=${lttl1}s"
