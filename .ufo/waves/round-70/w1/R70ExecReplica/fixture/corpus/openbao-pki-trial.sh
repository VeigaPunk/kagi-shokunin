#!/usr/bin/env bash
# corpus/openbao-pki-trial.sh — independent replica of the round-70 C1 PKI trial.
# Written from S170 (https://openbao.org/docs/api/secret/pki/) and the frozen
# counter's contract, without opening the reference trial.
#
# Contract:
#   bash openbao-pki-trial.sh --work DIR
#   prints one line per test:  TRIAL T<n> HOLDS|BROKEN|ERROR <detail>
#   prints a final line:       OPENBAO_PKI_TRIAL: <status> holds=H broken=B error=E
#   exit 0 iff all five HOLD; exit 1 if any BROKEN/ERROR;
#   exit 2 (no HOLDS line) when bao is absent from PATH or args are bad.
# Every engine call goes through the `bao` CLI on PATH. The throwaway dev server
# is killed on every exit path. No token, key or PEM is printed: server output
# goes to files under DIR and each test extracts only the field it needs.
set -u

WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) WORK="${2:-}"; shift 2 ;;
    --work=*) WORK="${1#--work=}"; shift ;;
    *) echo "OPENBAO_PKI_TRIAL: ERROR bad-arg"; exit 2 ;;
  esac
done
[ -n "$WORK" ] || { echo "OPENBAO_PKI_TRIAL: ERROR bad-arg no-work"; exit 2; }

holds=0; broken=0; errors=0
verdict() { # id word detail
  echo "TRIAL $1 $2 $3"
  case "$2" in
    HOLDS) holds=$((holds+1)) ;;
    BROKEN) broken=$((broken+1)) ;;
    *) errors=$((errors+1)) ;;
  esac
}

if ! command -v bao >/dev/null 2>&1; then
  echo "OPENBAO_PKI_TRIAL: ERROR holds=0 broken=0 error=0 reason=bao-absent"
  exit 2
fi
mkdir -p "$WORK" || { echo "OPENBAO_PKI_TRIAL: ERROR holds=0 broken=0 error=0 reason=workdir"; exit 2; }

# --- throwaway dev server --------------------------------------------------
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()') \
  || { echo "OPENBAO_PKI_TRIAL: ERROR holds=0 broken=0 error=0 reason=no-port"; exit 2; }
TOKEN=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
export BAO_ADDR="http://127.0.0.1:$PORT"
export BAO_TOKEN="$TOKEN"

SRVPID=""
cleanup() {
  if [ -n "$SRVPID" ] && kill -0 "$SRVPID" 2>/dev/null; then
    kill "$SRVPID" 2>/dev/null
    wait "$SRVPID" 2>/dev/null
  fi
  SRVPID=""
}
trap cleanup EXIT INT TERM

bao server -dev -dev-listen-address="127.0.0.1:$PORT" -dev-root-token-id="$TOKEN" \
  >"$WORK/server.stdout" 2>"$WORK/server.log" &
SRVPID=$!

up=0
for _ in $(seq 1 120); do
  if bao status >/dev/null 2>&1; then up=1; break; fi
  kill -0 "$SRVPID" 2>/dev/null || break
  sleep 0.5
done
if [ "$up" -ne 1 ]; then
  for t in 1 2 3 4 5; do verdict "T$t" ERROR server-did-not-start; done
  echo "OPENBAO_PKI_TRIAL: ERROR holds=$holds broken=$broken error=$errors reason=server-start"
  cleanup; exit 1
fi

if ! bao secrets enable -path=pki pki >/dev/null 2>&1; then
  for t in 1 2 3 4 5; do verdict "T$t" ERROR mount-failed; done
  echo "OPENBAO_PKI_TRIAL: ERROR holds=$holds broken=$broken error=$errors reason=mount"
  cleanup; exit 1
fi

F="$WORK/last.json"
field() { # json-file key -> value of data.<key> or empty
  python3 -c 'import json,sys
try:
    print(json.load(open(sys.argv[1]))["data"].get(sys.argv[2],""))
except Exception:
    pass' "$1" "$2" 2>/dev/null
}

# --- T1: root/generate/internal returns a certificate, no private_key -------
# S170 §Generate key: internal => the private key is not returned.
if bao write -format=json pki/root/generate/internal common_name=root.r70.test ttl=87600h >"$F" 2>/dev/null; then
  cert=$(field "$F" certificate)
  haskey=$(python3 -c 'import json,sys; print(1 if "private_key" in json.load(open(sys.argv[1]))["data"] else 0)' "$F" 2>/dev/null || echo x)
  if [ -n "$cert" ] && [ "$haskey" = 0 ]; then verdict T1 HOLDS root-internal-cert-no-private-key
  elif [ "$haskey" = 1 ]; then verdict T1 BROKEN root-internal-returned-private-key
  else verdict T1 ERROR root-internal-no-certificate; fi
else
  verdict T1 ERROR root-internal-call-failed
fi

# --- T2: ttl above role max_ttl is clamped (issued), lifetime <= max_ttl ----
# S170 §Generate certificate and key: ttl "Cannot be greater than the role's
# max_ttl value." Measured: issued with a clamp warning. Bound: 1h + 60s.
bao write -format=json pki/roles/r-t2 allowed_domains=r70.test allow_subdomains=true \
  max_ttl=1h ttl=30m server_flag=true >/dev/null 2>&1
if bao write -format=json pki/issue/r-t2 common_name=ok.r70.test ttl=24h >"$F" 2>/dev/null; then
  cert=$(field "$F" certificate)
  printf '%s\n' "$cert" > "$WORK/t2.pem"
  life=$(openssl x509 -in "$WORK/t2.pem" -noout -startdate -enddate 2>/dev/null | python3 -c '
import datetime, sys
lines = sys.stdin.read().splitlines()
def p(line):
    v = " ".join(line.split("=", 1)[1].split())
    return datetime.datetime.strptime(v, "%b %d %H:%M:%S %Y %Z")
print(int((p(lines[1]) - p(lines[0])).total_seconds()))' 2>/dev/null) || life=""
  if [ -z "$life" ]; then verdict T2 ERROR cert-dates-unparsed
  elif [ "$life" -gt 0 ] && [ "$life" -le 3660 ]; then verdict T2 HOLDS ttl-clamped-to-max-ttl-${life}s
  else verdict T2 BROKEN lifetime-${life}s-exceeds-max_ttl; fi
else
  verdict T2 ERROR issue-call-failed
fi

# --- T3: CN outside allowed_domains refused; inside issued -----------------
bao write -format=json pki/roles/r-t3 allowed_domains=r70.test allow_subdomains=true \
  ttl=1h server_flag=true >/dev/null 2>&1
bao write -format=json pki/issue/r-t3 common_name=evil.example ttl=1h >/dev/null 2>&1 && outside=1 || outside=0
bao write -format=json pki/issue/r-t3 common_name=ok.r70.test ttl=1h >/dev/null 2>&1 && inside=1 || inside=0
if [ "$outside" = 0 ] && [ "$inside" = 1 ]; then verdict T3 HOLDS outside-refused-inside-issued
elif [ "$outside" = 1 ]; then verdict T3 BROKEN outside-name-issued
else verdict T3 ERROR inside-name-not-issued; fi

# --- T4: revoked serial appears on the mount CRL (openssl-parsed) ----------
bao write -format=json pki/roles/r-t4 allowed_domains=r70.test allow_subdomains=true \
  ttl=1h server_flag=true >/dev/null 2>&1
serial=""
if bao write -format=json pki/issue/r-t4 common_name=ok.r70.test ttl=1h >"$F" 2>/dev/null; then
  serial=$(field "$F" serial_number)
fi
if [ -z "$serial" ]; then
  verdict T4 ERROR issue-no-serial
else
  bao write -format=json pki/revoke serial_number="$serial" >/dev/null 2>&1
  if bao read -format=json pki/cert/crl >"$F" 2>/dev/null; then
    field "$F" certificate > "$WORK/crl.pem"
    want=$(printf '%s' "$serial" | tr -d ':' | tr 'a-f' 'A-F' | sed 's/^0*//')
    got=$(openssl crl -in "$WORK/crl.pem" -noout -text 2>/dev/null \
      | sed -n 's/.*Serial Number: *//p' | tr -d ' :' | tr 'a-f' 'A-F' | sed 's/^0*//')
    if [ -n "$want" ] && printf '%s\n' "$got" | grep -qx "$want"; then
      verdict T4 HOLDS revoked-serial-on-crl
    else
      verdict T4 BROKEN revoked-serial-missing-from-crl
    fi
  else
    verdict T4 ERROR crl-read-failed
  fi
fi

# --- T5: no_store leaf unreadable and unlisted; stored control is both -----
bao write -format=json pki/roles/r-t5 allowed_domains=r70.test allow_subdomains=true \
  ttl=1h server_flag=true no_store=true >/dev/null 2>&1
bao write -format=json pki/roles/r-t5c allowed_domains=r70.test allow_subdomains=true \
  ttl=1h server_flag=true >/dev/null 2>&1
ns=""; cs=""
if bao write -format=json pki/issue/r-t5 common_name=ok.r70.test ttl=1h >"$F" 2>/dev/null; then
  ns=$(field "$F" serial_number)
fi
if bao write -format=json pki/issue/r-t5c common_name=ok.r70.test ttl=1h >"$F" 2>/dev/null; then
  cs=$(field "$F" serial_number)
fi
if [ -z "$ns" ] || [ -z "$cs" ]; then
  verdict T5 ERROR issue-no-serial
else
  listed=$(bao list -format=json pki/certs 2>/dev/null || echo "[]")
  inlist() { python3 -c 'import json,sys; print(1 if sys.argv[2] in json.loads(sys.argv[1]) else 0)' "$listed" "$1" 2>/dev/null || echo 0; }
  nl=$(inlist "$ns"); cl=$(inlist "$cs")
  nr=0; bao read -format=json "pki/cert/$ns" >/dev/null 2>&1 && nr=1
  cr=0; bao read -format=json "pki/cert/$cs" >/dev/null 2>&1 && cr=1
  if [ "$nr" = 0 ] && [ "$nl" = 0 ] && [ "$cr" = 1 ] && [ "$cl" = 1 ]; then
    verdict T5 HOLDS no-store-unreadable-unlisted-control-stored
  elif [ "$nr" = 1 ] || [ "$nl" = 1 ]; then
    verdict T5 BROKEN no-store-leaf-readable-or-listed
  else
    verdict T5 BROKEN control-leaf-missing-from-store
  fi
fi

cleanup
trap - EXIT INT TERM
if [ "$holds" -eq 5 ]; then
  echo "OPENBAO_PKI_TRIAL: HOLDS holds=$holds broken=$broken error=$errors"
  exit 0
fi
echo "OPENBAO_PKI_TRIAL: BROKEN holds=$holds broken=$broken error=$errors"
exit 1
