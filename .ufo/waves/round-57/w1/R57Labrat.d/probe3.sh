#!/usr/bin/env bash
# R57Labrat probe run 3: declarative (config-file) audit devices on a dev
# server -- the 2.7.2 recommended path. Checks device appearance, HMAC default,
# log_raw on the second device, and SIGHUP remove+re-add salt rotation.
set -uo pipefail
SCR=/fast/scratch/hyaku/kagi-r57/R57Labrat
W=$SCR/work3
rm -rf "$W"; mkdir -p "$W"; chmod 700 "$W"
A1=$W/audit-default.log; A2=$W/audit-raw.log; A3=$W/audit-after.log
CFG=$W/cfg.hcl
mkcfg() { # $1 = emit file stanza yes/no, $2 = file stanza path
  { [ "$1" = yes ] && printf 'audit "file" "file" {\n  options {\n    file_path = "%s"\n  }\n}\n' "$2"
    printf 'audit "file" "file2" {\n  options {\n    file_path = "%s"\n    log_raw = "true"\n  }\n}\n' "$A2"; } > "$CFG"
}
mkcfg yes "$A1"
CMD=$W/commands.tsv; : > "$CMD"
PORT=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
ADDR="http://127.0.0.1:$PORT"
setsid bao server -dev -dev-listen-address=127.0.0.1:"$PORT" -config="$CFG" >"$W/server.out" 2>&1 &
SPID=$!
PGID=$(ps -o pgid= -p "$SPID" | tr -d ' ')
ready=0
for _ in $(seq 1 200); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$ADDR/v1/sys/health" || true)
  [ "$code" = 200 ] && { ready=1; break; }
  sleep 0.1
done
if [ "$ready" != 1 ]; then echo "PROBE3: SETUP server-not-ready port=$PORT"; kill -TERM -- -"$PGID" 2>/dev/null; exit 2; fi
TOKEN=""
for _ in $(seq 1 200); do
  TOKEN=$(sed -n 's/^Root Token: //p' "$W/server.out" | head -1)
  [ -n "$TOKEN" ] && break
  sleep 0.1
done
if [ -z "$TOKEN" ]; then echo "PROBE3: SETUP no-token"; kill -TERM -- -"$PGID" 2>/dev/null; exit 2; fi
export BAO_ADDR=$ADDR BAO_TOKEN=$TOKEN
NONCE=$(python3 -c 'import secrets;print(secrets.token_hex(20))')
NONCE2=$(python3 -c 'import secrets;print(secrets.token_hex(20))')
note() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$CMD"; }

bao audit list -detailed >"$W/list-declarative.out" 2>&1; note audit-list-declarative $? "bao audit list -detailed"
printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v1 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v2 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
bao kv get -mount=secret probe >/dev/null 2>&1
note kv-get-v1 $? "bao kv get -mount=secret probe"

mkcfg no ""
kill -HUP "$SPID"; sleep 1.5
bao audit list -detailed >"$W/list-after-hup-remove.out" 2>&1; note hup-remove $? "kill -HUP \$SPID (file stanza removed); bao audit list -detailed"
mkcfg yes "$A3"
kill -HUP "$SPID"; sleep 1.5
bao audit list -detailed >"$W/list-after-hup-readd.out" 2>&1; note hup-readd $? "kill -HUP \$SPID (file stanza re-added); bao audit list -detailed"
printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v3 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
printf '%s' "$NONCE" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-v4 $? "printf %s NONCE | bao kv put -mount=secret probe value=-"
bao kv get -mount=secret probe >/dev/null 2>&1
note kv-get-v2 $? "bao kv get -mount=secret probe"
printf '%s' "$NONCE2" | bao kv put -mount=secret probe value=- >/dev/null 2>&1
note kv-put-other $? "printf %s NONCE2 | bao kv put -mount=secret probe value=-"
bao audit list -detailed >"$W/list-final.out" 2>&1; note audit-list-final $? "bao audit list -detailed"
bao audit disable file/ >"$W/disable-declarative.out" 2>&1; note audit-disable-declarative $? "bao audit disable file/"
bao audit list -detailed >"$W/list-post-disable.out" 2>&1; note audit-list-post-disable $? "bao audit list -detailed"

PROBE_NONCES="$NONCE,$NONCE2" PROBE_TOKEN="$TOKEN" python3 "$SCR/probe_analyze.py" \
  --default "$A1" --raw "$A2" --after "$A3" > "$W/summary.json" 2>"$W/analyze.err"
echo "PROBE3: analyze rc=$?"
echo "PORT=$PORT SPID=$SPID PGID=$PGID"
kill -TERM -- -"$PGID" 2>/dev/null
for _ in $(seq 1 50); do kill -0 "$SPID" 2>/dev/null || break; sleep 0.1; done
kill -KILL -- -"$PGID" 2>/dev/null
sleep 0.2
echo "SURVIVOR_PID: $(ps -o pid=,stat=,args= -p "$SPID" 2>/dev/null || echo none)"
echo "PORT_LISTENERS: $(ss -ltnp 2>/dev/null | grep -c ":$PORT " || true)"
