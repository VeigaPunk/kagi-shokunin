#!/usr/bin/env bash
# probe-errs — K49ReviewerTrial review probe.
# Captures FULL masked stderr of: (1) `token lookup` with an expired token,
# (2) `token renew` of a batch token, (3) `token revoke` of a batch token by root,
# (4) `token revoke -self` of a batch token — to attribute failure reasons.
set -u
umask 077
WORK="${1:?usage: probe-errs.sh WORK}"; D=$(mktemp -d "$WORK/pe.XXXXXX") || exit 2
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
[ "$ok" = 1 ] || { echo "PE SETUP server"; exit 2; }
mask() { sed -e "s|$ROOT|<ROOT>|g" -e "s|[sbr]\.[A-Za-z0-9]\{20,\}|<TOKEN>|g"; }
t=$(bao token create -field=token -policy=default -ttl=2s 2>/dev/null) || t=""
tb=$(bao token create -field=token -policy=default -type=batch -ttl=60s 2>/dev/null) || tb=""
[ -n "$t" ] && [ -n "$tb" ] || { echo "PE SETUP token-create"; exit 2; }
sleep 4
echo "PE[expired-lookup]"; BAO_TOKEN="$t" bao token lookup 2>&1 | mask
echo "PE[batch-renew-self]"; BAO_TOKEN="$tb" bao token renew 2>&1 | mask
echo "PE[batch-revoke-root-byid]"; bao token revoke "$tb" 2>&1 | mask
echo "PE[batch-revoke-self]"; BAO_TOKEN="$tb" bao token revoke -self 2>&1 | mask
