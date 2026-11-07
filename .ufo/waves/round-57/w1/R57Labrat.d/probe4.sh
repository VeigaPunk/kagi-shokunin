#!/usr/bin/env bash
# Wrapper for probe4.py: throwaway dev server with the documented unsafe flag.
set -uo pipefail
SCR=/fast/scratch/hyaku/kagi-r57/R57Labrat
W=$SCR/work4
rm -rf "$W"; mkdir -p "$W"; chmod 700 "$W"
printf 'unsafe_allow_api_audit_creation = true\n' > "$W/cfg.hcl"
PORT=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
ADDR="http://127.0.0.1:$PORT"
setsid bao server -dev -dev-listen-address=127.0.0.1:"$PORT" -config="$W/cfg.hcl" >"$W/server.out" 2>&1 &
SPID=$!
PGID=$(ps -o pgid= -p "$SPID" | tr -d ' ')
for _ in $(seq 1 200); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$ADDR/v1/sys/health" || true)
  [ "$code" = 200 ] && break
  sleep 0.1
done
TOKEN=""
for _ in $(seq 1 200); do
  TOKEN=$(sed -n 's/^Root Token: //p' "$W/server.out" | head -1)
  [ -n "$TOKEN" ] && break
  sleep 0.1
done
[ -n "$TOKEN" ] || { echo "PROBE4: SETUP no-token"; kill -TERM -- -"$PGID" 2>/dev/null; exit 2; }
NONCE=$(python3 -c 'import secrets;print(secrets.token_hex(20))')
BAO_ADDR=$ADDR BAO_TOKEN=$TOKEN PROBE_WORK=$W PROBE_NONCE=$NONCE \
  python3 "$SCR/probe4.py" > "$W/result.json" 2>"$W/err.txt"
echo "PROBE4: rc=$?"
cat "$W/err.txt"
kill -TERM -- -"$PGID" 2>/dev/null
for _ in $(seq 1 50); do kill -0 "$SPID" 2>/dev/null || break; sleep 0.1; done
kill -KILL -- -"$PGID" 2>/dev/null
sleep 0.2
echo "SURVIVOR_PID: $(ps -o pid=,stat=,args= -p "$SPID" 2>/dev/null || echo none)"
echo "PORT_LISTENERS: $(ss -ltnp 2>/dev/null | grep -c ":$PORT " || true)"
