#!/usr/bin/env bash
set -u; umask 077
D=$(mktemp -d "$S/raw.XXXXXX") || exit 2
SRV=""
cleanup(){ [ -n "$SRV" ] && kill "$SRV" 2>/dev/null; }
trap cleanup EXIT
port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
root=$(python3 -c 'import secrets;print(secrets.token_hex(16))')
export HOME="$D/home"; mkdir -p "$HOME"
setpriv --pdeathsig KILL bao server -dev -dev-root-token-id="$root" -dev-listen-address="127.0.0.1:$port" >"$D/srv.log" 2>&1 &
SRV=$!
export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
for i in $(seq 1 200); do bao status >/dev/null 2>&1 && break; sleep 0.1; done
n=$(python3 -c 'import secrets;print("r51-"+secrets.token_hex(12))')
bao kv put secret/t3 v="$n" >/dev/null
w=$(bao kv get -wrap-ttl=60s -format=json secret/t3 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
echo "== raw POST /v1/sys/wrapping/lookup with NO X-Vault-Token header:"
code=$(curl -sS -o "$D/resp.json" -w '%{http_code}' -X POST --data "{\"token\":\"$w\"}" "$BAO_ADDR/v1/sys/wrapping/lookup")
echo "http_status=$code"
python3 -c "import json;d=json.load(open('$D/resp.json'));print('data_creation_path=',(d.get('data') or {}).get('creation_path'));print('errors_present=',bool(d.get('errors')))"
echo "== same lookup with a WRONG token header (should still work => unauthenticated):"
code2=$(curl -sS -o "$D/resp2.json" -w '%{http_code}' -X POST -H "X-Vault-Token: not-a-real-token" --data "{\"token\":\"$w\"}" "$BAO_ADDR/v1/sys/wrapping/lookup")
echo "http_status_wrong_token=$code2"
python3 -c "import json;d=json.load(open('$D/resp2.json'));print('data_creation_path=',(d.get('data') or {}).get('creation_path'))"
echo "== unwrap with NO header (raw) to test whether the token itself authorizes:"
code3=$(curl -sS -o "$D/resp3.json" -w '%{http_code}' -X POST --data "{\"token\":\"$w\"}" "$BAO_ADDR/v1/sys/wrapping/unwrap")
echo "unwrap_no_header_status=$code3"
kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
rm -rf "$D"
