#!/usr/bin/env bash
# probe-t3 — K49ReviewerTrial review probe.
# Question: do `token renew` (self) and `token revoke` (root, by ID) fail BECAUSE the
# token is batch (S016 §Token type comparison: renewable No / manually revocable No),
# not for an incidental reason? Failure texts recorded (masked); service-token control
# root-revoked fine inside the ref trial itself (T4 revokes a service token).
set -u
umask 077
WORK="${1:?usage: probe-t3.sh WORK}"; D=$(mktemp -d "$WORK/p3.XXXXXX") || exit 2
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
[ "$ok" = 1 ] || { echo "P3 SETUP server"; exit 2; }
mask() { sed -e "s|$ROOT|<ROOT>|g" -e "s|[sbr]\.[A-Za-z0-9]\{20,\}|<TOKEN>|g"; }
tb=$(bao token create -field=token -policy=default -type=batch -ttl=60s 2>/dev/null) || tb=""
[ -n "$tb" ] || { echo "P3 SETUP token-create"; exit 2; }
pref=0; [ "${tb:0:2}" = "b." ] && pref=1
lk=0; lkt=""; lkt=$(BAO_TOKEN="$tb" bao token lookup -format=json 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["data"]["ttl"])' 2>/dev/null); [ -n "$lkt" ] && lk=1
rn=0; ren=""; ren=$(BAO_TOKEN="$tb" bao token renew 2>&1 | mask | head -1); BAO_TOKEN="$tb" bao token renew >/dev/null 2>&1 && rn=1
rs=0; rse=""; rse=$(BAO_TOKEN="$tb" bao token revoke -self 2>&1 | mask | head -1); BAO_TOKEN="$tb" bao token revoke -self >/dev/null 2>&1 && rs=1
rv=0; rev=""; rev=$(bao token revoke "$tb" 2>&1 | mask | head -1); bao token revoke "$tb" >/dev/null 2>&1 && rv=1
a1=0; BAO_TOKEN="$tb" bao token lookup >/dev/null 2>&1 && a1=1
echo "P3 prefix-is-b.=$pref self-lookup-ok=$lk ttl=$lkt"
echo "P3 self-renew-ok=$rn err=[$ren]"
echo "P3 self-revoke-ok=$rs err=[$rse]"
echo "P3 root-revoke-byid-ok=$rv err=[$rev]"
echo "P3 alive-after-all=$a1"
