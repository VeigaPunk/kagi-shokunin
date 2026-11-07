#!/bin/bash
set -u
S=/fast/scratch/hyaku/kagi-r52/R52ScribeEntry/probe
W=$(mktemp -d "$S/w.XXXXXX") || exit 2
SRV=""
cleanup(){ [ -n "$SRV" ] && { kill "$SRV" 2>/dev/null; for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done; kill -9 "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; }; rm -rf -- "$W"; }
trap cleanup EXIT
port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()') || exit 2
root="r52s-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
mkdir -p "$W/home"
HOME="$W/home" PATH=/usr/bin:/bin BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL "$HOME/../../../../../../home/vgpnk/.local/bin/bao" server -dev -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
SRV=$!
export HOME="$W/home" BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
ok=0; for _ in $(seq 1 100); do "$S/../../../../../../home/vgpnk/.local/bin/bao" status >/dev/null 2>&1 && { ok=1; break; }; sleep 0.1; done
[ "$ok" = 1 ] || { echo "SETUP server-not-ready"; exit 2; }
BAO=/home/vgpnk/.local/bin/bao
n1="r52-$(python3 -c 'import secrets;print(secrets.token_hex(12))')"
n2="r52-$(python3 -c 'import secrets;print(secrets.token_hex(12))')"
printf '%s' "$n1" | "$BAO" kv put secret/t1 v=- >/dev/null 2>"$W/e" || { echo "SETUP put-failed"; exit 2; }
printf '%s' "$n2" | "$BAO" kv put -cas=0 secret/t1 v=- >/dev/null 2>"$W/e0"; echo "cas0_rc=$?"
echo "cas0_stderr:"; sed -n '1,8p' "$W/e0" | sed -E 's#http://127\.0\.0\.1:[0-9]+#http://127.0.0.1:<port>#'
n3="r52-$(python3 -c 'import secrets;print(secrets.token_hex(12))')"
printf '%s' "$n3" | "$BAO" kv put secret/t3 v=- >/dev/null 2>"$W/e" || { echo "SETUP put3-failed"; exit 2; }
"$BAO" kv destroy -versions=1 secret/t3 >/dev/null 2>"$W/ed"; echo "destroy_rc=$?"
"$BAO" kv undelete -versions=1 secret/t3 >/dev/null 2>"$W/eu"; echo "undelete_after_destroy_rc=$?"
echo "undelete_stderr:"; sed -n '1,6p' "$W/eu" | sed -E 's#http://127\.0\.0\.1:[0-9]+#http://127.0.0.1:<port>#'
"$BAO" kv get -format=json secret/t3 2>"$W/eg" | python3 -c 'import json,sys
d=json.load(sys.stdin)["data"]; m=d.get("metadata") or {}
print("get_rc=0 data_is_none=%d destroyed=%r deletion_time=%r" % (int(d.get("data") is None), m.get("destroyed"), m.get("deletion_time")))'
echo "get_rc=$?"
