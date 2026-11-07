#!/usr/bin/env bash
set -u
umask 077
D=$(mktemp -d "$S/empirical.XXXXXX") || exit 2
SRV=""
cleanup(){ [ -n "$SRV" ] && kill "$SRV" 2>/dev/null; }
trap cleanup EXIT
port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
root=$(python3 -c 'import secrets;print(secrets.token_hex(16))')
HOME="$D/home"; export HOME; mkdir -p "$HOME"
setpriv --pdeathsig KILL bao server -dev -dev-root-token-id="$root" -dev-listen-address="127.0.0.1:$port" >"$D/srv.log" 2>&1 &
SRV=$!
export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
for i in $(seq 1 200); do bao status >/dev/null 2>&1 && break; sleep 0.1; done
bao status >/dev/null 2>&1 || { echo "SETUP fail"; exit 2; }
echo "bao=$(bao version | awk '{print $2; exit}')"
n=$(python3 -c 'import secrets;print("r51-"+secrets.token_hex(12))')
bao kv put secret/t5 v="$n" >/dev/null
w=$(bao kv get -wrap-ttl=60s -format=json secret/t5 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
# T3: unauthenticated lookup
lp=$(env -u BAO_TOKEN bao write -format=json sys/wrapping/lookup token="$w" 2>/dev/null | python3 -c 'import json,sys;print((json.load(sys.stdin).get("data") or {}).get("creation_path"))')
echo "T3 unauth_lookup_creation_path=[$lp] matches_expected=$([ "$lp" = secret/data/t5 ] && echo 1 || echo 0)"
echo "T3 lookup_http_status_unauth=$(env -u BAO_TOKEN bao write -format=json sys/wrapping/lookup token="$w" 2>&1 >/dev/null | head -1)"
v=$(env -u BAO_TOKEN bao unwrap -format=json "$w" 2>/dev/null | python3 -c 'import json,sys;d=json.load(sys.stdin).get("data") or {};d=d.get("data",d);print(d.get("v"))')
echo "T3 unwrap_after_lookup_value_matches=$([ "$v" = "$n" ] && echo 1 || echo 0)"
# T5: wrap again -> creation_path
w2=$(bao write -wrap-ttl=60s -format=json sys/wrapping/wrap v="$v" 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
lp2=$(env -u BAO_TOKEN bao write -format=json sys/wrapping/lookup token="$w2" 2>/dev/null | python3 -c 'import json,sys;print((json.load(sys.stdin).get("data") or {}).get("creation_path"))')
echo "T5 rewrap_creation_path=[$lp2] equals_sys_wrapping_wrap=$([ "$lp2" = sys/wrapping/wrap ] && echo 1 || echo 0)"
# T4: rewrap semantics
w3=$(bao kv get -wrap-ttl=60s -format=json secret/t5 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
w4=$(bao write -format=json sys/wrapping/rewrap token="$w3" 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
old_ok=$(env -u BAO_TOKEN bao unwrap -format=json "$w3" >/dev/null 2>&1 && echo 1 || echo 0)
newv=$(env -u BAO_TOKEN bao unwrap -format=json "$w4" 2>/dev/null | python3 -c 'import json,sys;d=json.load(sys.stdin).get("data") or {};d=d.get("data",d);print(d.get("v"))')
echo "T4 tokens_differ=$([ "$w3" != "$w4" ] && echo 1 || echo 0) old_still_usable=$old_ok new_value_matches=$([ "$newv" = "$n" ] && echo 1 || echo 0)"
# T1 single use
w5=$(bao kv get -wrap-ttl=60s -format=json secret/t5 2>/dev/null | python3 -c 'import json,sys;print(json.load(sys.stdin)["wrap_info"]["token"])')
env -u BAO_TOKEN bao unwrap -format=json "$w5" >/dev/null 2>&1; echo "T1 first_unwrap_rc=$?"
env -u BAO_TOKEN bao unwrap -format=json "$w5" >/dev/null 2>&1; echo "T1 second_unwrap_rc=$?"
kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
rm -rf "$D"
