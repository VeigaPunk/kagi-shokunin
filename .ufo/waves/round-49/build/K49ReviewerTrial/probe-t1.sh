#!/usr/bin/env bash
# probe-t1 — K49ReviewerTrial review probe.
# Question: does post-TTL `token lookup` failure prove expiry (S016 §Token Time-To-Live:
# "After the current TTL is up, the token will no longer function"), or could refusal
# have another cause? Design: two tokens created together (ttl=2s vs ttl=60s); the only
# manipulated variable is the TTL. Error text after lapse is recorded (masked).
set -u
umask 077
WORK="${1:?usage: probe-t1.sh WORK}"; D=$(mktemp -d "$WORK/p1.XXXXXX") || exit 2
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
[ "$ok" = 1 ] || { echo "P1 SETUP server"; exit 2; }
mask() { sed -e "s|$ROOT|<ROOT>|g" -e "s|[sbr]\.[A-Za-z0-9]\{20,\}|<TOKEN>|g"; }
t2s=$(bao token create -field=token -policy=default -ttl=2s 2>/dev/null) || t2s=""
t60=$(bao token create -field=token -policy=default -ttl=60s 2>/dev/null) || t60=""
tdef=$(bao token create -field=token -policy=default 2>/dev/null) || tdef=""
[ -n "$t2s" ] && [ -n "$t60" ] && [ -n "$tdef" ] || { echo "P1 SETUP token-create"; exit 2; }
ttl0=$(BAO_TOKEN="$t2s" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["data"]["ttl"])')
ttl60=$(BAO_TOKEN="$t60" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["data"]["ttl"])')
ttldef=$(BAO_TOKEN="$tdef" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["data"]["ttl"])')
a1=0; BAO_TOKEN="$t2s" bao token lookup >/dev/null 2>&1 && a1=1
sleep 3   # ~4 s after create
a4=0; BAO_TOKEN="$t2s" bao token lookup >/dev/null 2>&1 && a4=1
err=$(BAO_TOKEN="$t2s" bao token lookup 2>&1 | mask | head -1)
c4=0; BAO_TOKEN="$t60" bao token lookup >/dev/null 2>&1 && c4=1
echo "P1 ttl2s.ttl-at-0=${ttl0}s alive@~1s=$a1 alive@~4s=$a4 lookup-err-after-lapse=[$err]"
echo "P1 contrast ttl60.ttl-at-0=${ttl60}s alive@~4s=$c4 default-token.ttl=${ttldef}s"
