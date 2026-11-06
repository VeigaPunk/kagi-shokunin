#!/usr/bin/env bash
# probe-t2 — K49ReviewerTrial review probe.
# Question: is auth.lease_duration of the renew response the granted TTL, and is the
# explicit max TTL the binding constraint (S016 §Explicit max TTLs: "a hard limit on
# the token's lifetime")? Contrast: same renew with NO explicit cap honors increment 3600.
set -u
umask 077
WORK="${1:?usage: probe-t2.sh WORK}"; D=$(mktemp -d "$WORK/p2.XXXXXX") || exit 2
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
[ "$ok" = 1 ] || { echo "P2 SETUP server"; exit 2; }
ta=$(bao token create -field=token -policy=default -ttl=60s -explicit-max-ttl=5s 2>/dev/null) || ta=""
tb=$(bao token create -field=token -policy=default -ttl=60s 2>/dev/null) || tb=""
[ -n "$ta" ] && [ -n "$tb" ] || { echo "P2 SETUP token-create"; exit 2; }
g1=$(BAO_TOKEN="$ta" bao token renew -increment=3600 -format=json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["auth"]["lease_duration"])' 2>/dev/null) || g1=""
l1=$(BAO_TOKEN="$ta" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;d=json.load(sys.stdin)["data"];print("ttl=%s explicit_max_ttl=%s"%(d["ttl"],d.get("explicit_max_ttl")))' 2>/dev/null) || l1=""
g2=$(BAO_TOKEN="$tb" bao token renew -increment=3600 -format=json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["auth"]["lease_duration"])' 2>/dev/null) || g2=""
sleep 7
a1=0; BAO_TOKEN="$ta" bao token lookup >/dev/null 2>&1 && a1=1
a2=0; BAO_TOKEN="$tb" bao token lookup >/dev/null 2>&1 && a2=1
echo "P2 capped-token renew(increment=3600)->granted=${g1:-none} lookup-after-renew=[$l1] alive@+7s=$a1"
echo "P2 contrast no-cap-token renew(increment=3600)->granted=${g2:-none} alive@+7s=$a2"
