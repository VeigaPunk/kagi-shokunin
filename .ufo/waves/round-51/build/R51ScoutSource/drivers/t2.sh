#!/usr/bin/env bash
set -u; umask 077
D=$(mktemp -d "$S/t2.XXXXXX") || exit 2; SRV=""
cleanup(){ [ -n "$SRV" ] && kill "$SRV" 2>/dev/null; }; trap cleanup EXIT
port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
root=$(python3 -c 'import secrets;print(secrets.token_hex(16))')
export HOME="$D/home"; mkdir -p "$HOME"
setpriv --pdeathsig KILL bao server -dev -dev-root-token-id="$root" -dev-listen-address="127.0.0.1:$port" >"$D/srv.log" 2>&1 &
SRV=$!; export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
for i in $(seq 1 200); do bao status >/dev/null 2>&1 && break; sleep 0.1; done
n=$(python3 -c 'import secrets;print("r51-"+secrets.token_hex(12))')
bao kv put secret/t2 v="$n" >/dev/null
w=$(bao kv get -wrap-ttl=2s -format=json secret/t2 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
echo "wrap token obtained (ttl 2s): $([ -n "$w" ] && echo yes || echo no)"
sleep 4
env -u BAO_TOKEN bao unwrap -format=json "$w" >/dev/null 2>&1; echo "unwrap_after_4s_rc=$? (nonzero => refused)"
s=$(bao kv get -field=v secret/t2 2>/dev/null); echo "secret_still_readable=$([ "$s" = "$n" ] && echo 1 || echo 0)"
kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""; rm -rf "$D"
