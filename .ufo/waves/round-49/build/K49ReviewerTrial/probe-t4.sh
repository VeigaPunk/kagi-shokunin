#!/usr/bin/env bash
# probe-t4 — K49ReviewerTrial review probe.
# Question: does the userpass login token carry orphan=true (S016 §Token hierarchies:
# orphans are created "By logging in with any other (non-`token`) auth method"), with the
# parent-child contrast (token-create child dies with parent, login orphan survives)?
set -u
umask 077
WORK="${1:?usage: probe-t4.sh WORK}"; D=$(mktemp -d "$WORK/p4.XXXXXX") || exit 2
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
[ "$ok" = 1 ] || { echo "P4 SETUP server"; exit 2; }
PW=$(python3 -c 'import secrets;print(secrets.token_hex(16))')
mask() { sed -e "s|$ROOT|<ROOT>|g" -e "s|$PW|<PW>|g" -e "s|[sbr]\.[A-Za-z0-9]\{20,\}|<TOKEN>|g"; }
bao auth enable userpass >/dev/null 2>&1
bao write auth/userpass/users/trial password="$PW" policies=default >/dev/null 2>&1 || { echo "P4 SETUP userpass"; exit 2; }
bao policy write child-maker - >/dev/null 2>&1 <<'POL'
path "auth/token/create" { capabilities = ["create", "update"] }
POL
p=$(bao token create -field=token -policy=child-maker -ttl=60s 2>/dev/null) || p=""
c=""; [ -n "$p" ] && c=$(BAO_TOKEN="$p" bao token create -field=token -policy=default -ttl=60s 2>/dev/null)
u=""; [ -n "$p" ] && u=$(BAO_TOKEN="$p" bao login -method=userpass -no-store -field=token username=trial password="$PW" 2>/dev/null)
[ -n "$p" ] && [ -n "$c" ] && [ -n "$u" ] || { echo "P4 SETUP tokens"; exit 2; }
orph=$(BAO_TOKEN="$u" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(str(json.load(sys.stdin)["data"]["orphan"]).lower())')
porph=$(BAO_TOKEN="$p" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(str(json.load(sys.stdin)["data"]["orphan"]).lower())')
corph=$(BAO_TOKEN="$c" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(str(json.load(sys.stdin)["data"]["orphan"]).lower())')
bao token revoke "$p" >/dev/null 2>&1
ca=0; BAO_TOKEN="$c" bao token lookup >/dev/null 2>&1 && ca=1
ua=0; BAO_TOKEN="$u" bao token lookup >/dev/null 2>&1 && ua=1
echo "P4 orphan(parent)=$porph orphan(child-via-token-create)=$corph orphan(userpass-login)=$orph"
echo "P4 after-revoke-parent child-alive=$ca login-alive=$ua"
