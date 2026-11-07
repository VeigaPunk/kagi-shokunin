#!/usr/bin/env bash
set -u; umask 077
D=$(mktemp -d "$S/rp3.XXXXXX") || exit 2; SRV=""
cleanup(){ [ -n "$SRV" ] && kill "$SRV" 2>/dev/null; }; trap cleanup EXIT
port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
root=$(python3 -c 'import secrets;print(secrets.token_hex(16))')
export HOME="$D/home"; mkdir -p "$HOME"
setpriv --pdeathsig KILL bao server -dev -dev-root-token-id="$root" -dev-listen-address="127.0.0.1:$port" >"$D/srv.log" 2>&1 &
SRV=$!; export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
for i in $(seq 1 200); do bao status >/dev/null 2>&1 && break; sleep 0.1; done
n=$(python3 -c 'import secrets;print("r51-"+secrets.token_hex(12))')
bao kv put secret/t4 v="$n" >/dev/null
mk(){ bao kv get -wrap-ttl=60s -format=json secret/t4 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])'; }
lp(){ env -u BAO_TOKEN bao write -format=json sys/wrapping/lookup token="$1" 2>/dev/null | python3 -c 'import json,sys;print((json.load(sys.stdin).get("data") or {}).get("creation_path"))'; }
wA=$(mk); echo "A fresh wrap token lookup path = [$(lp "$wA")]"
wB=$(mk); rB=$(bao write -format=json sys/wrapping/rewrap token="$wB" 2>/dev/null)
echo "rewrap RESPONSE wrap_info.creation_path = [$(printf '%s' "$rB" | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"].get("creation_path"))')]"
wB2=$(printf '%s' "$rB" | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
echo "lookup of REWRAPPED token path = [$(lp "$wB2")]"
wC=$(mk); v=$(env -u BAO_TOKEN bao unwrap -format=json "$wC" 2>/dev/null | python3 -c 'import json,sys;d=json.load(sys.stdin).get("data") or {};d=d.get("data",d);print(d.get("v"))')
echo "unwrapped value matches = $([ "$v" = "$n" ] && echo 1 || echo 0)"
wD=$(bao write -wrap-ttl=60s -format=json sys/wrapping/wrap v="$v" 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
echo "lookup of sys/wrapping/wrap token path = [$(lp "$wD")]"
kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""; rm -rf "$D"
