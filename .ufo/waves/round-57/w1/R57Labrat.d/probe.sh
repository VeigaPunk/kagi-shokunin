#!/usr/bin/env bash
# R57Labrat independent probe: OpenBao audit HMAC defaults, log_raw per-device,
# salt rotation on disable+re-enable. No token or written value on any argv or in
# stdout; server output and audit logs stay in this scratch dir and are deleted.
set -uo pipefail
SCR=/fast/scratch/hyaku/kagi-r57/R57Labrat
W=$SCR/work
rm -rf "$W"; mkdir -p "$W"; chmod 700 "$W"
A1=$W/audit-default.log; A2=$W/audit-raw.log; A3=$W/audit-after.log
CMD=$W/commands.tsv; : > "$CMD"

PORT=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
ADDR="http://127.0.0.1:$PORT"

setsid bao server -dev -dev-listen-address=127.0.0.1:"$PORT" >"$W/server.out" 2>&1 &
SPID=$!
PGID=$(ps -o pgid= -p "$SPID" | tr -d ' ')
ready=0
for _ in $(seq 1 200); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$ADDR/v1/sys/health" || true)
  [ "$code" = 200 ] && { ready=1; break; }
  sleep 0.1
done
if [ "$ready" != 1 ]; then echo "PROBE: SETUP server-not-ready port=$PORT"; kill -TERM -- -"$PGID" 2>/dev/null; exit 2; fi
TOKEN=""
for _ in $(seq 1 200); do
  TOKEN=$(sed -n 's/^Root Token: //p' "$W/server.out" | head -1)
  [ -n "$TOKEN" ] && break
  sleep 0.1
done
if [ -z "$TOKEN" ]; then echo "PROBE: SETUP no-token"; kill -TERM -- -"$PGID" 2>/dev/null; exit 2; fi
export BAO_ADDR=$ADDR BAO_TOKEN=$TOKEN

NONCE=$(python3 -c 'import secrets;print(secrets.token_hex(20))')
NONCE2=$(python3 -c 'import secrets;print(secrets.token_hex(20))')

note() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$CMD"; }

bao audit list >"$W/list-before.out" 2>&1;  note audit-list-before $? "bao audit list"

bao audit enable file file_path="$A1" >"$W/enable-default.out" 2>&1
note enable-default $? "bao audit enable file file_path=\$W/audit-default.log"
bao audit list -detailed >"$W/list-default.out" 2>&1
note audit-list-default $? "bao audit list -detailed"

printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v1 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v2 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
bao kv get -mount=secret probe >/dev/null 2>&1
note kv-get-v1 $? "bao kv get -mount=secret probe"

bao audit enable -path=file2 file log_raw=true file_path="$A2" >"$W/enable-raw.out" 2>&1
note enable-file2-raw $? "bao audit enable -path=file2 file log_raw=true file_path=\$W/audit-raw.log"

printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v3 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
bao kv get -mount=secret probe >/dev/null 2>&1
note kv-get-v2 $? "bao kv get -mount=secret probe"

bao audit disable file/ >"$W/disable.out" 2>&1
note audit-disable-file $? "bao audit disable file/"
bao audit enable file file_path="$A3" >"$W/reenable.out" 2>&1
note reenable-file $? "bao audit enable file file_path=\$W/audit-after.log"

printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v4 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v5 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
bao kv get -mount=secret probe >/dev/null 2>&1
note kv-get-v3 $? "bao kv get -mount=secret probe"
printf '%s' "$NONCE2" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-other $? "printf %s NONCE2 | bao kv put -mount=secret probe value=-"

bao audit list >"$W/list-after.out" 2>&1
note audit-list-after $? "bao audit list"

PROBE_NONCES="$NONCE,$NONCE2" PROBE_TOKEN="$TOKEN" python3 "$SCR/probe_analyze.py" \
  --default "$A1" --raw "$A2" --after "$A3" > "$W/summary.json" 2>"$W/analyze.err"
ARC=$?
echo "PROBE: analyze rc=$ARC"
echo "PORT=$PORT SPID=$SPID PGID=$PGID"

kill -TERM -- -"$PGID" 2>/dev/null
for _ in $(seq 1 50); do kill -0 "$SPID" 2>/dev/null || break; sleep 0.1; done
kill -KILL -- -"$PGID" 2>/dev/null
sleep 0.2
echo "SURVIVOR_PID: $(ps -o pid=,stat=,args= -p "$SPID" 2>/dev/null || echo none)"
echo "PORT_LISTENERS: $(ss -ltnp 2>/dev/null | grep -c ":$PORT " || true)"
echo "HEAD_FILES:"; ls -l "$W"
