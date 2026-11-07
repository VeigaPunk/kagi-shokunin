#!/usr/bin/env bash
# OpenBao ACL-policy semantics trial (kagi round 58, C2 capability).
# Sources: S118 https://openbao.org/docs/concepts/policies/ and
# S119 https://openbao.org/docs/commands/policy/ (OpenBao docs Version 2.7.x),
# opened 2026-11-07.
# Executed on a throwaway in-memory `bao server -dev` bound to 127.0.0.1. Five
# ACL-policy mechanics the pages document:
#   T1 deny by default: an empty (zero-rule) policy grants no permission - that
#      token is denied (HTTP 403 permission denied) on a KV v2 data read, while a
#      read-grant token reads its exact path (the value round-trips) and is denied
#      an update on it.
#   T2 prefix glob: `secret/data/bar/*` reads `secret/data/bar/zip` and
#      `secret/data/bar/zip/zap` but not the sibling `secret/data/bars/zip`; an
#      exact grant (`secret/data/food`) reads its path and is denied the longer
#      name `secret/data/food2` (`*` is only supported as the last character).
#   T3 deny precedence: a broad `read` on `secret/data/t3/*` plus a narrower
#      `deny` on `secret/data/t3/locked` leaves the token denied at the locked
#      path and allowed on a sibling under the broad rule.
#   T4 `+` is bounded to one path segment: `secret/data/+/teamb` allows
#      `secret/data/alpha/teamb` (one intermediate segment) and denies
#      `secret/data/alpha/beta/teamb` (two) and `secret/data/teamb` (zero).
#   T5 union vs highest-priority: the same pattern `secret/data/t5a` in two
#      policies unions read+update (both work; a raw DELETE on the data path,
#      which maps to the `delete` capability, stays denied); different patterns
#      (`secret/data/t5b*` read vs exact `secret/data/t5b` update) take only the
#      highest-priority match - read denied, update allowed - and the client-side
#      `bao token capabilities` introspection must read exactly [update].
# Prints one line per test:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>
# and a final summary line
#   OPENBAO_POLICY_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>
# Exit: 0 all HOLDS, 1 any BROKEN (no ERROR), 2 SETUP (missing tool/scratch, any ERROR).
# Falsifier shims (round-48/49/51/52/57 convention): KAGI_POLICY_SHIM=SH1..SH5 replaces
# one test's observable evaluation, never the mechanics, so exactly one test reads BROKEN.
# Secret handling: no token or value on any argv; the dev root token reaches the
# server through BAO_DEV_ROOT_TOKEN_ID and every client through BAO_TOKEN; child
# tokens are server-generated and parsed from JSON stdout into shell variables
# only; every KV value is written as `v=-` on stdin; the server output goes to
# /dev/null; the port is probed then checked to be held by our server pid; the
# root token and every value are random `r58-` nonces and no nonce or token is
# ever printed. The server runs under `setpriv --pdeathsig KILL`. The trial
# drives the `bao` CLI resolved on PATH only.
set -u
umask 077
WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) [ $# -ge 2 ] || { echo "usage: $0 [--work DIR]" >&2; exit 2; }; WORK="$2"; shift 2;;
    *) echo "usage: $0 [--work DIR]" >&2; exit 2;;
  esac
done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_POLICY_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_POLICY_TRIAL: SETUP no python3"; exit 2; }
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_POLICY_TRIAL: SETUP no setpriv"; exit 2; }
command -v ss >/dev/null 2>&1 || { echo "OPENBAO_POLICY_TRIAL: SETUP no ss"; exit 2; }
BASE="${WORK:-${TMPDIR:-/tmp}}"
mkdir -p "$BASE" || exit 2
D=$(mktemp -d "$BASE/openbao-policy-trial.XXXXXX") || exit 2
SRV=""
cleanup() {
  if [ -n "$SRV" ]; then
    kill "$SRV" 2>/dev/null
    for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done
    kill -9 "$SRV" 2>/dev/null
    wait "$SRV" 2>/dev/null
    SRV=""
  fi
  rm -rf -- "$D"
}
trap 'cleanup' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP
while IFS= read -r v; do [ -n "$v" ] && unset "$v"; done < <(env | sed -n 's/^\(BAO_[A-Z_]*\)=.*/\1/p; s/^\(VAULT_[A-Z_]*\)=.*/\1/p')
export HOME="$D/home"; mkdir -p "$HOME"
VER=$(bao version 2>/dev/null | awk '{print $2; exit}')
SHIM="${KAGI_POLICY_SHIM:-}"
nonce() { python3 -c 'import secrets;print("r58-"+secrets.token_hex(12))'; }
start_server() {
  local port root ok
  for _ in 1 2 3; do
    port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
    root=$(nonce)
    BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL bao server -dev \
      -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
    SRV=$!
    ok=0
    for _ in $(seq 1 300); do
      kill -0 "$SRV" 2>/dev/null || break
      if ss -Hltnp "sport = :$port" 2>/dev/null | grep -q "pid=$SRV,"; then ok=1; break; fi
      sleep 0.1
    done
    if [ "$ok" = 1 ]; then
      export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
      ok=0
      for _ in $(seq 1 100); do
        if bao status >/dev/null 2>&1; then ok=1; break; fi
        sleep 0.1
      done
      [ "$ok" = 1 ] && return 0
    fi
    kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
    unset BAO_ADDR BAO_TOKEN
  done
  return 1
}
stop_server() {
  [ -n "$SRV" ] || return 0
  kill "$SRV" 2>/dev/null
  for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done
  kill -9 "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
  unset BAO_ADDR BAO_TOKEN
}
putv() { printf '%s' "$2" | bao kv put "$1" v=- >/dev/null 2>"$D/err"; }
policyf() { # NAME STANZA-FILE -> writes the named policy; rc 0 on success
  bao policy write "$1" "$2" >/dev/null 2>"$D/err"
}
mktoken() { # NAME... -> server-generated token id on stdout; rc 3 on parse failure
  local out p
  local args=()
  for p in "$@"; do args+=("-policy=$p"); done
  out=$(bao token create -format=json "${args[@]}" 2>"$D/err") || return 1
  printf '%s' "$out" | python3 -c 'import json,sys
try: print(json.load(sys.stdin)["auth"]["client_token"])
except Exception:
    sys.exit(3)' 2>/dev/null
}
classify() { # RC -> 0 allowed, 1 denied (HTTP 403: permission denied or the CLI's
  #           preflight capability check), 2 other error
  if [ "$1" -eq 0 ]; then echo 0
  elif grep -qiE 'permission denied|code: 403' "$D/err" 2>/dev/null; then echo 1
  else echo 2; fi
}
as_get() { BAO_TOKEN="$1" bao kv get "$2" >/dev/null 2>"$D/err"; classify $?; }
as_put() { local v; v=$(nonce); printf '%s' "$v" | BAO_TOKEN="$1" bao kv put "$2" v=- >/dev/null 2>"$D/err"; classify $?; }
as_del() { BAO_TOKEN="$1" bao delete "$2" >/dev/null 2>"$D/err"; classify $?; }
capsof() { # TOKEN APIPATH -> space-joined capability words (plain form) on stdout;
  #          rc!=0 on empty/unparseable answer
  local out
  out=$(BAO_TOKEN="$1" bao token capabilities "$2" 2>/dev/null) || return 1
  printf '%s\n' "$out" | python3 -c 'import sys
w = sys.stdin.read().split()
if not w:
    sys.exit(3)
print(" ".join(w))' 2>/dev/null
}
H=0; B=0; E=0
report() { echo "TRIAL $1 $2 $3"; case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac; }

start_server "" || { echo "OPENBAO_POLICY_TRIAL: SETUP dev server did not start"; exit 2; }

# Fixtures: policies (HCL under $D), fixtures values (root writes), child tokens.
printf '# zero-rule policy: grants no permission\n' > "$D/p0.hcl"
cat > "$D/p1.hcl" <<'EOF'
path "secret/data/t1" { capabilities = ["read"] }
EOF
cat > "$D/p2.hcl" <<'EOF'
path "secret/data/bar/*" { capabilities = ["read"] }
path "secret/data/food" { capabilities = ["read"] }
EOF
cat > "$D/p3.hcl" <<'EOF'
path "secret/data/t3/*" { capabilities = ["read"] }
path "secret/data/t3/locked" { capabilities = ["deny"] }
EOF
cat > "$D/p4.hcl" <<'EOF'
path "secret/data/+/teamb" { capabilities = ["read"] }
EOF
cat > "$D/p5a.hcl" <<'EOF'
path "secret/data/t5a" { capabilities = ["read"] }
EOF
cat > "$D/p5b.hcl" <<'EOF'
path "secret/data/t5a" { capabilities = ["update"] }
EOF
cat > "$D/p5c.hcl" <<'EOF'
path "secret/data/t5b*" { capabilities = ["read"] }
EOF
cat > "$D/p5d.hcl" <<'EOF'
path "secret/data/t5b" { capabilities = ["update"] }
EOF
for pn in p0 p1 p2 p3 p4 p5a p5b p5c p5d; do
  policyf "r58-$pn" "$D/$pn.hcl" || { echo "OPENBAO_POLICY_TRIAL: SETUP policy $pn not written"; exit 2; }
done
n1=$(nonce)
putv secret/t1 "$n1"          || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/t1"; exit 2; }
putv secret/bar/zip "$(nonce)"          || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/bar/zip"; exit 2; }
putv secret/bar/zip/zap "$(nonce)"     || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/bar/zip/zap"; exit 2; }
putv secret/bars/zip "$(nonce)"        || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/bars/zip"; exit 2; }
putv secret/food "$(nonce)"            || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/food"; exit 2; }
putv secret/food2 "$(nonce)"           || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/food2"; exit 2; }
putv secret/t3/open "$(nonce)"         || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/t3/open"; exit 2; }
putv secret/t3/locked "$(nonce)"       || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/t3/locked"; exit 2; }
putv secret/alpha/teamb "$(nonce)"     || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/alpha/teamb"; exit 2; }
putv secret/alpha/beta/teamb "$(nonce)" || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/alpha/beta/teamb"; exit 2; }
putv secret/teamb "$(nonce)"           || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/teamb"; exit 2; }
putv secret/t5a "$(nonce)"             || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/t5a"; exit 2; }
putv secret/t5b "$(nonce)"             || { echo "OPENBAO_POLICY_TRIAL: SETUP fixture secret/t5b"; exit 2; }
tok_e=$(mktoken r58-p0)       || { echo "OPENBAO_POLICY_TRIAL: SETUP token empty"; exit 2; }
tok_1=$(mktoken r58-p1)       || { echo "OPENBAO_POLICY_TRIAL: SETUP token t1"; exit 2; }
tok_2=$(mktoken r58-p2)       || { echo "OPENBAO_POLICY_TRIAL: SETUP token t2"; exit 2; }
tok_3=$(mktoken r58-p3)       || { echo "OPENBAO_POLICY_TRIAL: SETUP token t3"; exit 2; }
tok_4=$(mktoken r58-p4)       || { echo "OPENBAO_POLICY_TRIAL: SETUP token t4"; exit 2; }
tok_u=$(mktoken r58-p5a r58-p5b) || { echo "OPENBAO_POLICY_TRIAL: SETUP token union"; exit 2; }
tok_x=$(mktoken r58-p5c r58-p5d) || { echo "OPENBAO_POLICY_TRIAL: SETUP token prio"; exit 2; }

# T1 — deny by default: empty policy denied; read-grant reads (value round-trips) but cannot update.
e_denied=$(as_get "$tok_e" secret/t1)
r_read=$(as_get "$tok_1" secret/t1)
got=$(BAO_TOKEN="$tok_1" bao kv get -field=v secret/t1 2>/dev/null); v_ok=0; [ "$got" = "$n1" ] && v_ok=1
unset got
r_upd=$(as_put "$tok_1" secret/t1)
[ "$SHIM" = SH1 ] && e_denied=0
if [ "$e_denied" = 1 ] && [ "$r_read" = 0 ] && [ "$v_ok" = 1 ] && [ "$r_upd" = 1 ]; then
  report T1 HOLDS "empty-token-denied=1 read-allowed=1 value-roundtrip=1 update-denied=1"
else
  report T1 BROKEN "empty-token-denied=$e_denied read-allowed=$r_read value-roundtrip=$v_ok update-denied=$r_upd"
fi

# T2 — prefix glob: descendants allowed, sibling `bars` denied; exact grant does not match a longer name.
d1=$(as_get "$tok_2" secret/bar/zip)
d2=$(as_get "$tok_2" secret/bar/zip/zap)
sib=$(as_get "$tok_2" secret/bars/zip)
f1=$(as_get "$tok_2" secret/food)
f2=$(as_get "$tok_2" secret/food2)
[ "$SHIM" = SH2 ] && sib=0
if [ "$d1" = 0 ] && [ "$d2" = 0 ] && [ "$sib" = 1 ] && [ "$f1" = 0 ] && [ "$f2" = 1 ]; then
  report T2 HOLDS "descendant=2 sibling-denied=1 exact-allowed=1 longer-name-denied=1"
else
  report T2 BROKEN "descendant=$d1/$d2 sibling-denied=$sib exact-allowed=$f1 longer-name-denied=$f2"
fi

# T3 — deny precedence: narrow deny wins at the locked path, broad allow holds elsewhere.
o3=$(as_get "$tok_3" secret/t3/open)
l3=$(as_get "$tok_3" secret/t3/locked)
[ "$SHIM" = SH3 ] && l3=0
if [ "$o3" = 0 ] && [ "$l3" = 1 ]; then
  report T3 HOLDS "broad-allowed=1 denied-path-denied=1"
else
  report T3 BROKEN "broad-allowed=$o3 denied-path-denied=$l3"
fi

# T4 — `+` is exactly one path segment: one allowed, two denied, zero denied.
one4=$(as_get "$tok_4" secret/alpha/teamb)
two4=$(as_get "$tok_4" secret/alpha/beta/teamb)
zero4=$(as_get "$tok_4" secret/teamb)
[ "$SHIM" = SH4 ] && zero4=0
if [ "$one4" = 0 ] && [ "$two4" = 1 ] && [ "$zero4" = 1 ]; then
  report T4 HOLDS "one-segment=1 two-segments-denied=1 zero-segments-denied=1"
else
  report T4 BROKEN "one-segment=$one4 two-segments-denied=$two4 zero-segments-denied=$zero4"
fi

# T5 — same-pattern union (read+update, delete denied) vs highest-priority match
# (exact update outranks glob read: read denied, update allowed, caps exactly [update]).
u_get=$(as_get "$tok_u" secret/t5a)
u_put=$(as_put "$tok_u" secret/t5a)
u_del=$(as_del "$tok_u" secret/data/t5a)
x_get=$(as_get "$tok_x" secret/t5b)
x_put=$(as_put "$tok_x" secret/t5b)
caps=$(capsof "$tok_x" secret/data/t5b); crc=$?
[ "$SHIM" = SH5 ] && { caps="read update"; crc=0; }
capok=0; [ "$crc" -eq 0 ] && [ "$caps" = "update" ] && capok=1
if [ "$u_get" = 0 ] && [ "$u_put" = 0 ] && [ "$u_del" = 1 ] && [ "$x_get" = 1 ] && [ "$x_put" = 0 ] && [ "$capok" = 1 ]; then
  report T5 HOLDS "union-read=1 union-update=1 union-delete-denied=1 prio-read-denied=1 prio-update=1 caps=update"
else
  report T5 BROKEN "union-read=$u_get union-update=$u_put union-delete-denied=$u_del prio-read-denied=$x_get prio-update=$x_put caps-rc=$crc caps=${caps:-none}"
fi

if [ "$E" -gt 0 ]; then S=ERROR; rc=2; elif [ "$B" -gt 0 ]; then S=BROKEN; rc=1; else S=HOLDS; rc=0; fi
echo "OPENBAO_POLICY_TRIAL: $S holds=$H broken=$B error=$E bao=$VER"
stop_server
exit $rc
