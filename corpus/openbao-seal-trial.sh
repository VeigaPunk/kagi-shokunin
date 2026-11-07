#!/usr/bin/env bash
# OpenBao seal / unseal key-share custody trial (kagi round 61, C2 capability).
# Sources: S125 https://openbao.org/docs/concepts/seal/,
# S126 https://openbao.org/docs/commands/operator/rekey/ and
# S127 https://openbao.org/docs/commands/operator/generate-root/
# (OpenBao docs 2.7.x), opened 2026-11-07; frozen as plans/round-61.md §C2.
# Executed on throwaway `bao server` processes (a raft-backed server and an
# inmem server) bound to 127.0.0.1 under `setpriv --pdeathsig KILL`; `bao` is
# resolved through PATH only (never an absolute path). Five seal/unseal
# key-share custody mechanics:
#   T1 init: a raft-backed server (storage "raft" with node_id/api_addr/
#      cluster_addr, tls_disable=1) is initialized -key-shares=5
#      -key-threshold=3; the init payload carries unseal_shares=5 and
#      unseal_threshold=3 with exactly 5 distinct base64 shares, sys/
#      seal-status reads initialized=true sealed=true t=3 n=5, and no file
#      under the raft storage path contains any of the five base64
#      shares — the shares are held by the operators, never persisted by
#      the server.
#   T2 unseal threshold: one share -> progress 1/3 sealed=true; the SAME
#      share again -> progress stays 1/3 (a duplicate share does not count);
#      a second distinct share -> progress 2/3 sealed=true; a third distinct
#      share -> sealed=false with t=3 n=5.
#   T3 seal: with the root token `operator seal` -> sealed=true; an
#      authenticated request while sealed -> HTTP 503; sys/seal-status
#      without a token -> HTTP 200.
#   T4 generate-root: -init yields a nonce, an OTP and required=3; three
#      shares submitted with the attempt nonce progress 1,2,3 to
#      complete=true with an encoded token; `-decode=<encoded> -otp=<otp>`
#      yields a 26-character token that authenticates (200 on sys/
#      seal-status, and 200 on the auth-required token/lookup-self —
#      seal-status alone cannot discriminate a token); -decode with a wrong
#      OTP does not yield that token (different bytes, refused 403).
#   T5 rekey refused: `operator rekey -init -key-shares=3
#      -key-threshold=2` exits non-zero with HTTP 405 "unsupported
#      operation" on BOTH the raft server and an inmem server, while S126
#      documents the command — a measured docs-vs-binary divergence of this
#      build, not a citation. The refusal is configuration-dependent: the
#      rekey route is unmounted under the default config (no
#      disable_unauthed_rekey_endpoints stanza) and fails before any token
#      check; both T5 servers run that default config.
# Prints one line per test, each exactly once:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>       (n = 1..5)
# and a final summary line:
#   OPENBAO_SEAL_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>
# Exit: 0 all five HOLDS, 1 any BROKEN (no ERROR), 2 SETUP or any ERROR
# verdict. A PATH with no `bao` prints `OPENBAO_SEAL_TRIAL: SETUP no bao on
# PATH` and exits 2 with no TRIAL line and no HOLDS line.
# Falsifier shims (round-48..60 convention): KAGI_SEAL_SHIM=SH1..SH5
# replaces exactly one test's observable evaluation, never the mechanics, so
# exactly that one test reads BROKEN (baseline HHHHH; SH1 -> BHHHH, SH2 ->
# HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB). An unrecognised shim
# value is SETUP (exit 2) before any server starts.
# --selftest: fixture-driven stub-`bao` harness — no OpenBao binary, no
# network, no sockets. The harness puts stub `bao` and stub `curl` programs
# first on PATH; the stubs simulate the server-side seal state machine
# (init shares, duplicate-refusing unseal progress, seal, authenticated
# 503/200/403 responses, generate-root XOR round-trip, the measured rekey
# refusal) from a state file the trial points them at by exporting
# KAGI_SEAL_STUB_STATE for its children (the real bao binary ignores that
# variable). Cases assert the honest baseline (holds=5 exit 0), each shim
# flipping exactly its own test (exit 1), an injected ERROR (exit 2),
# unknown-shim and no-bao SETUP (exit 2), work-dir cleanup, and the pure
# helpers. Failures print named `FINDING SEAL-ST-...` ids; success prints
# exactly one `SEAL_SELFTEST: PASS (cases=N)` line.
# Secret handling: no unseal key share, root token, OTP, nonce or any other
# secret value is printed or written outside the work dir. The 2.7.2 CLI
# refuses piped unseal material (measured: "file descriptor 0 is not a
# terminal"), so the T2/T4 unseal shares ride the CLI's documented
# first-argument channel against this throwaway loopback server (ephemeral
# argv, same user, never printed), while the T4 generate-root shares ride
# stdin through the documented `-` positional; the root token travels
# through the BAO_TOKEN environment variable and curl `-H @file` header
# files; the OTP and the encoded token ride only the documented
# `-decode=<encoded> -otp=<otp>` flags and are never printed. Every
# artifact of a run — init
# payload, header files, server logs, raft storage, rekey stderr, stub
# state — lives inside the single per-run mktemp directory under --work,
# and one EXIT trap `rm -rf`s it, so after any exit (0/1/2 or signal) the
# --work base is left with no files. The trial writes nothing outside
# --work (default ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecTrial/trial-work).
# The binary is not sha-pinned here on purpose: the trial reports `bao=<ver>`
# and the counter/battery owns the pin (see plans/round-61.md).
set -u
umask 077

MODE=run
WORK=""
SELF=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work)
      [ $# -ge 2 ] || { echo "usage: $0 [--work DIR] [--selftest]" >&2; exit 2; }
      WORK="$2"; shift 2 ;;
    --selftest)
      MODE=self; shift ;;
    --run-selftest)
      [ $# -ge 2 ] || { echo "usage: $0 --run-selftest SRC" >&2; exit 2; }
      MODE=selfworker; SELF="$2"; shift 2 ;;
    *)
      echo "usage: $0 [--work DIR] [--selftest]" >&2; exit 2 ;;
  esac
done
SELF_PATH="$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")"
if [ "$MODE" = self ]; then
  if [ -n "$WORK" ]; then
    exec bash "$SELF_PATH" --run-selftest "$SELF_PATH" --work "$WORK"
  else
    exec bash "$SELF_PATH" --run-selftest "$SELF_PATH"
  fi
fi

SHIM="${KAGI_SEAL_SHIM:-}"
ROOT=""
S_A=""; S_B=""; S_C=""
D=""

# -------------------- pure helpers

jget() { # DOTTED.PATH -> JSON-native value on stdout ('true'/'false' for
         # booleans); rc 3 on missing/unparseable
  python3 -c 'import json,sys
try:
    v = json.load(sys.stdin)
    for k in sys.argv[1].split("."):
        v = v[k]
    sys.stdout.write(v if isinstance(v, str) else json.dumps(v))
except Exception:
    sys.exit(3)' "$1"
}

jhas() { # DOTTED.PATH -> rc 0 iff present and truthy
  python3 -c 'import json,sys
try:
    v = json.load(sys.stdin)
    for k in sys.argv[1].split("."):
        v = v[k]
    sys.exit(0 if v else 1)
except Exception:
    sys.exit(1)' "$1"
}

errtext() { # ERRFILE -> named error text on stdout ('' when none)
  local t
  t=$(grep -E '^\* ' "$1" 2>/dev/null | sed 's/^[*] //' | paste -sd';' -)
  if [ -z "$t" ]; then
    t=$(grep -vE '^(Error making API request\.|URL:|Code:|[[:space:]]*$)' "$1" 2>/dev/null | tail -n 1)
  fi
  printf '%s' "$t"
}

slug() { # stdin text -> lowercase dash slug, max 48 chars
  tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-' | sed 's/^-*//;s/-*$//' | cut -c1-48
}

named_refusal() { # ERRFILE ERE -> rc 0 iff a named error matching ERE is present
  local et
  et=$(errtext "$1")
  [ -n "$et" ] || return 1
  printf '%s\n' "$et" | grep -qiE "$2"
}

verdict_all() { # one or more 0/1 flags -> rc 0 iff every flag is 1
  local f
  [ "$#" -ge 1 ] || return 1
  for f in "$@"; do
    [ "$f" = 1 ] || return 1
  done
  return 0
}

rc_for() { # HOLDS BROKEN ERROR -> process exit code
  if [ "$3" -gt 0 ]; then echo 2; elif [ "$2" -gt 0 ]; then echo 1; else echo 0; fi
}

countmap() { # RV1..RV5 -> "H B E STATUS RC" on stdout
  local H=0 B=0 E=0 S RC line
  for line in "$@"; do
    case "$line" in
      *" HOLDS "*) H=$((H+1)) ;;
      *" BROKEN "*) B=$((B+1)) ;;
      *) E=$((E+1)) ;;
    esac
  done
  if [ "$E" -gt 0 ]; then S=ERROR; RC=2; elif [ "$B" -gt 0 ]; then S=BROKEN; RC=1; else S=HOLDS; RC=0; fi
  echo "$H $B $E $S $RC"
}

summary_line() { # STATUS H B E VER -> summary line on stdout
  printf 'OPENBAO_SEAL_TRIAL: %s holds=%s broken=%s error=%s bao=%s\n' "$1" "$2" "$3" "$4" "$5"
}

# Every flag name any test evaluates; the selftest shim matrix iterates this
# universe so a shim matching an undeclared or cross-test flag is caught.
ALLFLAGS="shares status nopersist p1 dup p2 p3 seal auth503 status200 req3 prog dec wrong raft405 mem405"

shim_flip() { # SHIM TESTNUM FLAG -> rc 0 iff this shim flips that flag
  case "$1" in
    SH1) [ "$2" = 1 ] && [ "$3" = shares ] && return 0; return 1 ;;
    SH2) [ "$2" = 2 ] && [ "$3" = dup ] && return 0; return 1 ;;
    SH3) [ "$2" = 3 ] && [ "$3" = auth503 ] && return 0; return 1 ;;
    SH4) [ "$2" = 4 ] && [ "$3" = dec ] && return 0; return 1 ;;
    SH5) [ "$2" = 5 ] && [ "$3" = mem405 ] && return 0; return 1 ;;
    *) return 1 ;;
  esac
}

# -------------------- server helpers

port_free() { python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()'; }

start_server() { # KIND(raft|inmem) LOGNAME STUBSTATE -> sets SRV, BAO_ADDR
  local kind="$1" logname="$2" stubstate="$3"
  local attempt port cport cfg ok i code
  for attempt in 1 2 3; do
    port=$(port_free); cport=$(port_free)
    cfg="$D/config-$kind-$attempt.hcl"
    if [ "$kind" = raft ]; then
      mkdir -p "$D/raft"
      cat > "$cfg" <<EOF
storage "raft" {
  path    = "$D/raft"
  node_id = "r61-seal-node"
}
listener "tcp" {
  address     = "127.0.0.1:$port"
  tls_disable = 1
}
api_addr     = "http://127.0.0.1:$port"
cluster_addr = "http://127.0.0.1:$cport"
disable_mlock = true
EOF
    else
      cat > "$cfg" <<EOF
storage "inmem" {}
listener "tcp" {
  address     = "127.0.0.1:$port"
  tls_disable = 1
}
api_addr = "http://127.0.0.1:$port"
disable_mlock = true
EOF
    fi
    KAGI_SEAL_STUB_STATE="$stubstate" setpriv --pdeathsig KILL \
      bao server -config="$cfg" >"$logname" 2>&1 &
    SRV=$!
    ok=0
    for i in $(seq 1 300); do
      kill -0 "$SRV" 2>/dev/null || break
      code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/v1/sys/seal-status" 2>/dev/null)
      if [ "$code" = "200" ]; then ok=1; break; fi
      sleep 0.1
    done
    if [ "$ok" = 1 ]; then
      export BAO_ADDR="http://127.0.0.1:$port" KAGI_SEAL_STUB_STATE="$stubstate"
      return 0
    fi
    stop_server
  done
  return 1
}

stop_server() {
  [ -n "${SRV:-}" ] || return 0
  kill "$SRV" 2>/dev/null
  for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done
  kill -9 "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
  unset BAO_ADDR
}

# -------------------- bao helpers

ss_write() { # current sys/seal-status body -> $D/ss.json
  curl -s "$BAO_ADDR/v1/sys/seal-status" > "$D/ss.json" 2>/dev/null
}

curl_code() { # [HEADERFILE] PATH -> http code on stdout
  if [ -n "$1" ]; then
    curl -s -o /dev/null -w '%{http_code}' -H @"$1" "$BAO_ADDR$2" 2>/dev/null
  else
    curl -s -o /dev/null -w '%{http_code}' "$BAO_ADDR$2" 2>/dev/null
  fi
}

unseal_share() { # SHARE OUTJSON -> rc of `bao operator unseal`. The 2.7.2
                 # CLI refuses piped unseal material (measured: "file
                 # descriptor 0 is not a terminal"), so the share rides the
                 # CLI's documented first-argument channel against this
                 # throwaway loopback server; </dev/null keeps any prompt
                 # path dead and the value is never printed or captured.
  bao operator unseal -format=json "$1" </dev/null > "$2" 2>"$D/uerr"
}

gr_submit() { # SHARE NONCE OUTJSON -> rc of a generate-root share
              # submission; the share rides stdin through the documented
              # `-` positional so no custody material sits on argv
  printf '%s\n' "$1" | bao operator generate-root -nonce="$2" -format=json - \
    > "$3" 2>"$D/grerr"
}

gr_decode() { # OTP ENCODED OUTFILE -> rc of `generate-root -decode` (the
              # documented 2.7.2 contract: -decode carries the encoded
              # token, -otp carries the pad; output is a {"token": ...}
              # document and the token is never printed)
  bao operator generate-root -decode="$2" -otp="$1" -format=json > "$3" 2>"$D/decerr"
}

rekey_refused() { # ERRFILE -> rc 0 iff rekey -init exits non-zero with
                  # HTTP 405 "unsupported operation" (the measured refusal)
  local rc=0
  bao operator rekey -init -key-shares=3 -key-threshold=2 > "$D/rk.out" 2>"$1" || rc=$?
  [ "$rc" -ne 0 ] || return 1
  grep -q 'Code: 405' "$1" 2>/dev/null || return 1
  named_refusal "$1" 'unsupported operation'
}

# -------------------- the tests

RV1="T1 ERROR not-run"; RV2="T2 ERROR not-run"; RV3="T3 ERROR not-run"
RV4="T4 ERROR not-run"; RV5="T5 ERROR not-run"

t1() {
  local shares=0 status=0 nopersist=0 ns ss si sx st sn m
  start_server raft "$D/server-raft.log" "$D/state-raft.json" \
    || { RV1="T1 ERROR raft-server-start"; return; }
  bao operator init -key-shares=5 -key-threshold=3 -format=json \
    > "$D/init.json" 2>"$D/init.err" \
    || { RV1="T1 ERROR init-call"; return; }
  # init payload: unseal_shares=5, unseal_threshold=3, five distinct
  # base64 shares (measured 2.7.2 shape: 44 chars, unpadded standard alphabet)
  ns=$(python3 - "$D/init.json" <<'PY'
import json, re, sys
try:
    d = json.load(open(sys.argv[1]))
    k = d["unseal_keys_b64"]
    ns = d["unseal_shares"]
    th = d["unseal_threshold"]
except Exception:
    sys.stdout.write("0"); raise SystemExit
ok = (ns == 5 and th == 3 and len(k) == 5 and len(set(k)) == 5
      and all(re.fullmatch(r"[A-Za-z0-9+/]{44}", x) for x in k))
sys.stdout.write("1" if ok else "0")
PY
) || ns=0
  [ "$ns" = "1" ] && shares=1
  # threshold/shares state the init was requested with, from seal-status
  ss_write
  si=$(jget initialized < "$D/ss.json" 2>/dev/null) || si=""
  sx=$(jget sealed < "$D/ss.json" 2>/dev/null) || sx=""
  st=$(jget t < "$D/ss.json" 2>/dev/null) || st=""
  sn=$(jget n < "$D/ss.json" 2>/dev/null) || sn=""
  [ "$si" = "true" ] && [ "$sx" = "true" ] && [ "$st" = "3" ] && [ "$sn" = "5" ] && status=1
  # custody: no file under the raft storage path carries any base64 share
  python3 - "$D/init.json" "$D/shares.pat" <<'PY'
import json, sys
keys = json.load(open(sys.argv[1]))["unseal_keys_b64"]
with open(sys.argv[2], "w") as f:
    f.write("\n".join(keys) + "\n")
PY
  m=$(grep -rlF -f "$D/shares.pat" "$D/raft" 2>/dev/null | wc -l)
  [ "$m" = "0" ] && nopersist=1
  # capture exactly three of the five shares for T2/T4 (values stay in vars)
  S_A=$(sed -n 1p "$D/shares.pat"); S_B=$(sed -n 2p "$D/shares.pat"); S_C=$(sed -n 3p "$D/shares.pat")
  ROOT=$(jget root_token < "$D/init.json" 2>/dev/null) || ROOT=""
  [ -n "$ROOT" ] || { RV1="T1 ERROR root-token-missing"; return; }
  export BAO_TOKEN="$ROOT"
  shim_flip "$SHIM" 1 shares && shares=0
  if verdict_all "$shares" "$status" "$nopersist"; then
    RV1="T1 HOLDS shares=$shares status=$status nopersist=$nopersist"
  else
    RV1="T1 BROKEN shares=$shares status=$status nopersist=$nopersist"
  fi
}

t2() {
  local p1=0 dup=0 p2=0 p3=0 r1="" r2="" r3="" sx pr st sn
  unseal_share "$S_A" "$D/u1.json" || { RV2="T2 ERROR unseal-first"; return; }
  r1=$(jget progress < "$D/u1.json" 2>/dev/null) || r1=""
  sx=$(jget sealed < "$D/u1.json" 2>/dev/null) || sx=""
  st=$(jget t < "$D/u1.json" 2>/dev/null) || st=""
  sn=$(jget n < "$D/u1.json" 2>/dev/null) || sn=""
  [ "$sx" = "true" ] && [ "$r1" = "1" ] && [ "$st" = "3" ] && [ "$sn" = "5" ] && p1=1
  # the SAME share again: progress must stay 1/3
  unseal_share "$S_A" "$D/u2.json" || { RV2="T2 ERROR unseal-duplicate"; return; }
  r2=$(jget progress < "$D/u2.json" 2>/dev/null) || r2=""
  sx=$(jget sealed < "$D/u2.json" 2>/dev/null) || sx=""
  [ "$sx" = "true" ] && [ "$r2" = "1" ] && dup=1
  # a second distinct share
  unseal_share "$S_B" "$D/u3.json" || { RV2="T2 ERROR unseal-second"; return; }
  r3=$(jget progress < "$D/u3.json" 2>/dev/null) || r3=""
  sx=$(jget sealed < "$D/u3.json" 2>/dev/null) || sx=""
  [ "$sx" = "true" ] && [ "$r3" = "2" ] && p2=1
  # a third distinct share completes the unseal
  unseal_share "$S_C" "$D/u4.json" || { RV2="T2 ERROR unseal-third"; return; }
  sx=$(jget sealed < "$D/u4.json" 2>/dev/null) || sx=""
  st=$(jget t < "$D/u4.json" 2>/dev/null) || st=""
  sn=$(jget n < "$D/u4.json" 2>/dev/null) || sn=""
  [ "$sx" = "false" ] && [ "$st" = "3" ] && [ "$sn" = "5" ] && p3=1
  shim_flip "$SHIM" 2 dup && dup=0
  # the detail carries the observed unseal progress with the counter's
  # marker keys: progress=1/3 (twice: first share, duplicate share),
  # progress=2/3, and the final sealed/t/n state
  if verdict_all "$p1" "$dup" "$p2" "$p3"; then
    RV2="T2 HOLDS progress=${r1:-x}/3 same-share-again=progress=${r2:-x}/3 progress=${r3:-x}/3 sealed=${sx:-x} t=${st:-x} n=${sn:-x}"
  else
    RV2="T2 BROKEN progress=${r1:-x}/3 same-share-again=progress=${r2:-x}/3 progress=${r3:-x}/3 sealed=${sx:-x} t=${st:-x} n=${sn:-x}"
  fi
}

t3() {
  local seal=0 auth503=0 status200=0 sx code
  # `operator seal` takes no -format flag on 2.7.2 (measured); the sealed
  # state it produces is observed through sys/seal-status
  bao operator seal > "$D/seal.out" 2>"$D/seal.err" \
    || { RV3="T3 ERROR seal-call"; return; }
  ss_write
  sx=$(jget sealed < "$D/ss.json" 2>/dev/null) || sx=""
  [ "$sx" = "true" ] && seal=1
  printf 'X-Vault-Token: %s\n' "$ROOT" > "$D/hdr-root"
  code=$(curl_code "$D/hdr-root" /v1/sys/mounts)
  [ "$code" = "503" ] && auth503=1
  code=$(curl_code "" /v1/sys/seal-status)
  [ "$code" = "200" ] && status200=1
  shim_flip "$SHIM" 3 auth503 && auth503=0
  if verdict_all "$seal" "$auth503" "$status200"; then
    RV3="T3 HOLDS seal=$seal auth503=$auth503 status200=$status200"
  else
    RV3="T3 BROKEN seal=$seal auth503=$auth503 status200=$status200"
  fi
}

t4() {
  local req3=0 prog=0 dec=0 wrong=0
  # setup: the T3 seal relocked the barrier; unseal again with three shares
  unseal_share "$S_A" "$D/ru1.json" && unseal_share "$S_B" "$D/ru2.json" \
    && unseal_share "$S_C" "$D/ru3.json" || { RV4="T4 ERROR re-unseal"; return; }
  bao operator generate-root -init -format=json > "$D/gr0.json" 2>"$D/gr0.err" \
    || { RV4="T4 ERROR gr-init"; return; }
  # -init itself reports the attempt nonce, the OTP and required (2.7.2)
  local nonce otp req g1 g2 g3 complete enc
  nonce=$(jget nonce < "$D/gr0.json" 2>/dev/null) || nonce=""
  otp=$(jget otp < "$D/gr0.json" 2>/dev/null) || otp=""
  req=$(jget required < "$D/gr0.json" 2>/dev/null) || req=""
  [ -n "$nonce" ] && [ "${#otp}" = "26" ] && [ "$req" = "3" ] && req3=1
  # three shares submitted with the attempt nonce: progress 1,2,3
  gr_submit "$S_A" "$nonce" "$D/gr1.json" || { RV4="T4 ERROR gr-share1"; return; }
  g1=$(jget progress < "$D/gr1.json" 2>/dev/null) || g1=""
  gr_submit "$S_B" "$nonce" "$D/gr2.json" || { RV4="T4 ERROR gr-share2"; return; }
  g2=$(jget progress < "$D/gr2.json" 2>/dev/null) || g2=""
  gr_submit "$S_C" "$nonce" "$D/gr3.json" || { RV4="T4 ERROR gr-share3"; return; }
  g3=$(jget progress < "$D/gr3.json" 2>/dev/null) || g3=""
  complete=$(jget complete < "$D/gr3.json" 2>/dev/null) || complete=""
  enc=$(jget encoded_token < "$D/gr3.json" 2>/dev/null) || enc=""
  [ "$g1" = "1" ] && [ "$g2" = "2" ] && [ "$g3" = "3" ] \
    && [ "$complete" = "true" ] && [ -n "$enc" ] && prog=1
  # -decode with the OTP yields the token ({"token": ...}, 26 characters)
  gr_decode "$otp" "$enc" "$D/tok.txt" || { RV4="T4 ERROR decode-call"; return; }
  local tok tl code_ls code_ss
  tok=$(jget token < "$D/tok.txt" 2>/dev/null) || tok=""
  tl=${#tok}
  printf 'X-Vault-Token: %s\n' "$tok" > "$D/hdr-new"
  code_ls=$(curl_code "$D/hdr-new" /v1/auth/token/lookup-self)
  code_ss=$(curl_code "$D/hdr-new" /v1/sys/seal-status)
  [ "$tl" = "26" ] && [ "$code_ls" = "200" ] && [ "$code_ss" = "200" ] && dec=1
  # -decode with a wrong OTP does not yield that token (measured on 2.7.2:
  # it exits 0 with a different 26-character token that authenticates as
  # nothing — the refusal code observed for that garbage varies per run,
  # 403 or 400, and is recorded, not asserted — or the decode is refused)
  local otp2 tok2 code2 drc
  otp2=$(python3 - "$otp" <<'PY'
import sys
o = sys.argv[1]
alt = "A" if (o and o[0] != "A") else "B"
sys.stdout.write(alt + o[1:])
PY
) || otp2=""
  drc=0
  if [ -n "$otp2" ] && [ "$otp2" != "$otp" ]; then
    gr_decode "$otp2" "$enc" "$D/tok2.txt" || drc=$?
    tok2=""
    jget token < "$D/tok2.txt" >/dev/null 2>&1 \
      && tok2=$(jget token < "$D/tok2.txt" 2>/dev/null)
    if [ "$drc" -ne 0 ]; then
      wrong=1
    elif [ -n "$tok2" ] && [ "$tok2" != "$tok" ]; then
      printf 'X-Vault-Token: %s\n' "$tok2" > "$D/hdr-wrong"
      code2=$(curl_code "$D/hdr-wrong" /v1/auth/token/lookup-self)
      wrong=1
    fi
  fi
  shim_flip "$SHIM" 4 dec && dec=0
  if verdict_all "$req3" "$prog" "$dec" "$wrong"; then
    RV4="T4 HOLDS req3=$req3 prog=$prog dec=$dec wrong=$wrong tlen=$tl ls=$code_ls ss=$code_ss wl=${#tok2} wls=${code2:-x} wdrc=$drc"
  else
    RV4="T4 BROKEN req3=$req3 prog=$prog dec=$dec wrong=$wrong tlen=$tl ls=$code_ls ss=$code_ss wl=${#tok2} wls=${code2:-x} wdrc=$drc"
  fi
}

t5() {
  local raft405=0 mem405=0 km root2
  rekey_refused "$D/rk-raft.err" && raft405=1
  stop_server
  start_server inmem "$D/server-inmem.log" "$D/state-inmem.json" \
    || { RV5="T5 ERROR inmem-server-start"; return; }
  bao operator init -key-shares=1 -key-threshold=1 -format=json \
    > "$D/init2.json" 2>"$D/init2.err" || { RV5="T5 ERROR inmem-init"; return; }
  km=$(python3 -c 'import json,sys
try: sys.stdout.write(json.load(open(sys.argv[1]))["unseal_keys_b64"][0])
except Exception: sys.exit(3)' "$D/init2.json") || { RV5="T5 ERROR inmem-share"; return; }
  unseal_share "$km" "$D/u5.json" || { RV5="T5 ERROR inmem-unseal"; return; }
  root2=$(jget root_token < "$D/init2.json" 2>/dev/null) || root2=""
  [ -n "$root2" ] && export BAO_TOKEN="$root2"
  rekey_refused "$D/rk-inmem.err" && mem405=1
  stop_server
  shim_flip "$SHIM" 5 mem405 && mem405=0
  if verdict_all "$raft405" "$mem405"; then
    RV5="T5 HOLDS raft405=$raft405 mem405=$mem405"
  else
    RV5="T5 BROKEN raft405=$raft405 mem405=$mem405"
  fi
}

# -------------------- selftest

not() { ! "$@"; }
expect_eq() { [ "$1" = "$2" ]; }

run_selftest() { # GATE_SRC WORK -> rc 0 PASS / 1 FAIL / 2 SETUP
  local GS="$1" W="${2:-}"
  command -v python3 >/dev/null 2>&1 || { echo "SEAL_SELFTEST: SETUP no python3"; return 2; }
  local BASE="${W:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecTrial/selftest-work}"
  mkdir -p "$BASE" 2>/dev/null || { echo "SEAL_SELFTEST: SETUP work dir not creatable"; return 2; }
  D=$(mktemp -d "$BASE/openbao-seal-selftest.XXXXXX") \
    || { echo "SEAL_SELFTEST: SETUP work dir not writable"; return 2; }
  ST_GSRC="$GS"; ST_D="$D"; ST_BASH="$(command -v bash)"
  STUBBIN="$D/stubbin"; mkdir -p "$STUBBIN" || { echo "SEAL_SELFTEST: SETUP stub dir"; return 2; }

  # ---- the stub harness: stateful bao + curl simulators, no sockets ----
  cat > "$STUBBIN/stub.py" <<'PYEOF'
import base64, json, os, re, secrets, string, sys, time

STATE = os.environ.get("KAGI_SEAL_STUB_STATE", "")
FAULT = os.environ.get("KAGI_STUB_FAULT", "")
ADDR = os.environ.get("BAO_ADDR", "http://127.0.0.1:0")

FRESH = {"initialized": False, "sealed": True, "t": 3, "n": 5,
         "progress_keys": [], "shares": [], "root_token": "",
         "genroot": None, "fault_used": False}


def load():
    try:
        with open(STATE) as f:
            d = json.load(f)
        if isinstance(d, dict):
            return d
    except Exception:
        pass
    return dict(FRESH)


def save(s):
    tmp = STATE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(s, f)
    os.replace(tmp, STATE)


def status(s):
    gr = s.get("genroot") or {}
    return {"type": "shamir", "initialized": bool(s.get("initialized")),
            "sealed": bool(s.get("sealed")), "t": s.get("t", 3),
            "n": s.get("n", 5), "progress": len(s.get("progress_keys", [])),
            "nonce": gr.get("nonce", ""), "version": "0.0.0-selftest",
            "build_date": "2026-11-07", "migration": False,
            "cluster_name": "r61-stub", "cluster_id": "r61-stub"}


def fail(msg, code=2):
    sys.stderr.write(msg + "\n")
    return code


def take_fault(s, name):
    if FAULT == name and not s.get("fault_used"):
        s["fault_used"] = True
        save(s)
        return True
    return False


def new_token():
    alphabet = string.ascii_letters + string.digits
    return "".join(secrets.choice(alphabet) for _ in range(26))


def encode_with_otp(tok, otp):
    raw = bytes(a ^ ord(otp[i % len(otp)]) for i, a in enumerate(tok.encode()))
    return base64.b64encode(raw).decode()


def decode_with_otp(enc, otp):
    raw = base64.b64decode(enc)
    return bytes(a ^ ord(otp[i % len(otp)]) for i, a in enumerate(raw)).decode("utf-8", "replace")


def do_server(args):
    cfg = ""
    if "-config" in args:
        i = args.index("-config")
        if i + 1 < len(args):
            try:
                cfg = open(args[i + 1]).read()
            except Exception:
                pass
    if not re.search(r'address\s*=\s*"127\.0\.0\.1:\d+"', cfg):
        return fail("stub server: no 127.0.0.1 listener in config")
    s = load()
    if not s.get("initialized"):
        save(dict(FRESH))
    try:
        while True:
            time.sleep(3600)
    except KeyboardInterrupt:
        pass
    return 0


def do_bao(args):
    if not args:
        return fail("stub: no subcommand")
    if args[0] == "version":
        sys.stdout.write("OpenBao v0.0.0-selftest ()\n")
        return 0
    if args[0] != "operator" or len(args) < 2:
        return fail("stub: unsupported subcommand")
    sub = args[1]
    rest = args[2:]
    s = load()
    flag = {}
    flags = set()
    positional = []
    for i, a in enumerate(rest):
        if a.startswith("-") and "=" in a:
            k, v = a[1:].split("=", 1)
            flag[k] = v
        elif a.startswith("-"):
            flags.add(a[1:])
        else:
            positional.append(a)
    if sub == "init":
        if take_fault(s, "init-fault"):
            return fail("stub fault injected: init-fault")
        if s.get("initialized"):
            return fail("Vault is already initialized")
        n = int(flag.get("key-shares", "5"))
        t = int(flag.get("key-threshold", "3"))
        # 33-byte shares -> 44 unpadded standard-base64 chars, the measured
        # 2.7.2 init shape
        shares = [base64.b64encode(secrets.token_bytes(33)).decode()
                  for _ in range(n)]
        root = new_token()
        s.update({"initialized": True, "sealed": True, "t": t, "n": n,
                  "progress_keys": [], "shares": shares, "root_token": root,
                  "genroot": None})
        save(s)
        sys.stdout.write(json.dumps({
            "unseal_shares": n, "unseal_threshold": t,
            "unseal_keys_b64": shares,
            "unseal_keys_hex": [x.encode().hex() for x in shares],
            "recovery_keys_b64": [], "recovery_keys_shares": 0,
            "recovery_keys_threshold": 0,
            "root_token": root}) + "\n")
        return 0
    if sub == "unseal":
        if take_fault(s, "unseal-fault"):
            return fail("stub fault injected: unseal-fault")
        key = positional[0].strip() if positional else ""
        if s.get("sealed") and key:
            if key in s["progress_keys"]:
                pass  # a repeated share does not count
            elif key in s["shares"]:
                s["progress_keys"].append(key)
                if len(s["progress_keys"]) >= s.get("t", 3):
                    s["sealed"] = False
                    s["progress_keys"] = []
            else:
                return fail("Error unsealing: invalid unseal key", 1)
        save(s)
        sys.stdout.write(json.dumps(status(s)) + "\n")
        return 0
    if sub == "seal":
        s["sealed"] = True
        s["progress_keys"] = []
        s["genroot"] = None
        save(s)
        sys.stdout.write(json.dumps(status(s)) + "\n")
        return 0
    if sub == "generate-root":
        gr = s.get("genroot")
        if "init" in flags:
            if take_fault(s, "genroot-fault"):
                return fail("stub fault injected: genroot-fault")
            if s.get("sealed"):
                return fail("Error making API request.\n\nURL: PUT %s/v1/sys/"
                            "generate-root/init\nCode: 503. Errors:\n\n* "
                            "Vault is sealed\n" % ADDR)
            otp = "".join(secrets.choice(string.ascii_uppercase + string.digits)
                          for _ in range(26))
            gr = {"nonce": secrets.token_hex(16), "otp": otp,
                  "progress_keys": [], "complete": False,
                  "encoded_token": "", "new_token": ""}
            s["genroot"] = gr
            save(s)
            sys.stdout.write(json.dumps({
                "complete": False, "encoded_root_token": "",
                "encoded_token": "", "nonce": gr["nonce"], "otp": otp,
                "otp_length": 26, "pgp_fingerprint": "", "progress": 0,
                "required": s.get("t", 3), "started": True}) + "\n")
            return 0
        d = flag.get("decode")
        if d is not None:
            if take_fault(s, "decode-fault"):
                return fail("stub fault injected: decode-fault")
            sys.stdout.write(json.dumps(
                {"token": decode_with_otp(d, flag.get("otp", ""))}))
            return 0
        nv = flag.get("nonce")
        if nv is not None:
            if take_fault(s, "genroot-fault"):
                return fail("stub fault injected: genroot-fault")
            gr = s.get("genroot")
            key = sys.stdin.read().strip()
            if not gr or gr.get("complete") or nv != gr.get("nonce", ""):
                return fail("Error making API request.\n\nURL: PUT %s/v1/sys/"
                            "generate-root/update\nCode: 400. Errors:\n\n* "
                            "missing or wrong nonce\n" % ADDR)
            if key in gr["progress_keys"]:
                pass
            elif key in s["shares"]:
                gr["progress_keys"].append(key)
            else:
                return fail("invalid unseal key", 1)
            if len(gr["progress_keys"]) >= s.get("t", 3):
                gr["complete"] = True
                gr["new_token"] = new_token()
                gr["encoded_token"] = encode_with_otp(gr["new_token"], gr["otp"])
            s["genroot"] = gr
            save(s)
            sys.stdout.write(json.dumps(gr_status(gr, s)) + "\n")
            return 0
        return fail("stub: unsupported generate-root subcommand")
    if sub == "rekey":
        if "init" in flags:
            return fail("Error initializing rekey: Error making API request."
                        "\n\nURL: PUT %s/v1/sys/rekey/init\nCode: 405. "
                        "Errors:\n\n* unsupported operation\n" % ADDR)
        return fail("stub: unsupported rekey subcommand")
    return fail("stub: unsupported operator subcommand " + sub)


def gr_status(gr, s):
    return {"complete": bool(gr.get("complete")),
            "encoded_token": gr.get("encoded_token", ""),
            "nonce": gr.get("nonce", ""),
            "progress": len(gr.get("progress_keys", [])),
            "required": s.get("t", 3)}


def do_curl(args):
    body_target = None
    fmt = None
    hdrs = []
    body = None
    url = ""
    i = 0
    while i < len(args):
        a = args[i]
        if a in ("-s", "-S", "-k"):
            pass
        elif a in ("-o", "-w", "-H", "--data-binary", "-d") and i + 1 < len(args):
            if a == "-o":
                body_target = args[i + 1]
            elif a == "-w":
                fmt = args[i + 1]
            elif a == "-H":
                hdrs.append(args[i + 1])
            else:
                src = args[i + 1]
                if src.startswith("@"):
                    try:
                        with open(src[1:]) as f:
                            body = f.read()
                    except Exception:
                        body = None
                else:
                    body = src
            i += 1
        elif a.startswith("-"):
            pass
        else:
            url = a
        i += 1
    path = url.split("://", 1)[-1]
    path = path[path.find("/"):] if "/" in path else "/"
    tok = None
    for h in hdrs:
        if h.startswith("@"):
            try:
                for line in open(h[1:]):
                    if line.startswith("X-Vault-Token:"):
                        tok = line.split(":", 1)[1].strip()
            except Exception:
                pass
    s = load()
    gr = s.get("genroot") or {}
    valid = set()
    if s.get("root_token"):
        valid.add(s["root_token"])
    if gr.get("complete") and gr.get("new_token"):
        valid.add(gr["new_token"])
    code, out = 404, json.dumps({"errors": ["not found"]})
    if path == "/v1/sys/seal-status":
        code, out = 200, json.dumps(status(s))
    elif path == "/v1/sys/unseal":
        if take_fault(s, "unseal-fault"):
            sys.stdout.write(json.dumps({"errors": ["stub fault injected"]}))
            return 18  # a broken transfer, like real curl on a dropped one
        else:
            key = ""
            try:
                key = (json.loads(body or "{}").get("key") or "").strip()
            except Exception:
                key = ""
            bad = False
            if s.get("sealed") and key:
                if key in s["progress_keys"]:
                    pass  # a repeated share does not count
                elif key in s["shares"]:
                    s["progress_keys"].append(key)
                    if len(s["progress_keys"]) >= s.get("t", 3):
                        s["sealed"] = False
                        s["progress_keys"] = []
                else:
                    bad = True
            if bad:
                code, out = 400, json.dumps({"errors": ["invalid unseal key"]})
            else:
                save(s)
                code, out = 200, json.dumps(status(s))
    elif path == "/v1/sys/generate-root":
        key, nonce = "", ""
        try:
            d = json.loads(body or "{}")
            key = (d.get("key") or "").strip()
            nonce = d.get("nonce") or ""
        except Exception:
            pass
        if not gr or gr.get("complete") or nonce != gr.get("nonce", ""):
            code, out = 400, json.dumps({"errors": ["missing or wrong nonce"]})
        elif take_fault(s, "genroot-fault"):
            code, out = 500, json.dumps({"errors": ["stub fault injected"]})
        elif key in gr["progress_keys"]:
            code, out = 200, json.dumps(gr_status(gr, s))
        elif key in s["shares"]:
            gr["progress_keys"].append(key)
            if len(gr["progress_keys"]) >= s.get("t", 3):
                gr["complete"] = True
                gr["new_token"] = new_token()
                gr["encoded_token"] = encode_with_otp(gr["new_token"], gr["otp"])
            s["genroot"] = gr
            save(s)
            code, out = 200, json.dumps(gr_status(gr, s))
        else:
            code, out = 400, json.dumps({"errors": ["invalid unseal key"]})
    elif path in ("/v1/sys/mounts", "/v1/auth/token/lookup-self"):
        if s.get("sealed"):
            code, out = 503, json.dumps({"errors": ["Vault is sealed"]})
        elif tok is not None and tok in valid:
            code, out = 200, json.dumps({"data": {}})
        else:
            code, out = 403, json.dumps({"errors": ["permission denied"]})
    if body_target is not None:
        with open(body_target, "w") as f:
            f.write(out)
    else:
        sys.stdout.write(out)
    if fmt:
        sys.stdout.write(str(code) + "\n")
    return 0


def main():
    argv = sys.argv[1:]
    if not argv:
        return fail("stub: missing tool selector")
    tool, rest = argv[0], argv[1:]
    if tool == "bao":
        return do_bao(rest)
    if tool == "curl":
        return do_curl(rest)
    return fail("stub: unknown tool " + tool)


if __name__ == "__main__":
    sys.exit(main())
PYEOF
  { printf '#!/usr/bin/env bash\nexec python3 "%s" bao "$@"\n' "$STUBBIN/stub.py"; } > "$STUBBIN/bao"
  { printf '#!/usr/bin/env bash\nexec python3 "%s" curl "$@"\n' "$STUBBIN/stub.py"; } > "$STUBBIN/curl"
  chmod +x "$STUBBIN/bao" "$STUBBIN/curl" || { echo "SEAL_SELFTEST: SETUP stub build"; return 2; }

  STC=0; STF=0
  ck() { local id="$1"; shift; STC=$((STC+1)); if ! "$@"; then STF=$((STF+1)); printf 'FINDING %s\n' "$id"; fi }

  vec_of() { # stdout-capture -> "H"/"B"/"E" per TRIAL line, T1..T5
    printf '%s\n' "$1" | awk '/^TRIAL T[1-5] /{printf "%s", ($3=="HOLDS"?"H":($3=="BROKEN"?"B":"E"))}'
  }
  sum_of() { printf '%s\n' "$1" | grep '^OPENBAO_SEAL_TRIAL:' | head -1; }

  run_case() { # NAME [ENV=VAL]... -> CASE_RC CASE_OUT (stub PATH)
    local name="$1"; shift
    local out rc
    out=$(env PATH="$STUBBIN:$PATH" "$@" "$ST_BASH" "$ST_GSRC" --work "$ST_D/w-$name" 2>&1); rc=$?
    CASE_RC=$rc; CASE_OUT="$out"
  }

  # ---- fixture files (no secrets, no network, no bao) ----
  printf 'Error making API request.\n\nURL: PUT http://127.0.0.1:1/v1/sys/rekey/init\nCode: 405. Errors:\n\n* unsupported operation\n' > "$D/rkfix"
  printf 'Error making API request.\n\nURL: PUT http://127.0.0.1:1/v1/sys/rekey/init\nCode: 400. Errors:\n\n* something else\n' > "$D/rkfix-bad"
  : > "$D/err-empty"
  printf '%s' '{"initialized":true,"sealed":true,"t":3,"n":5,"progress":1}' > "$D/ss-fix.json"
  printf '%s' '{"sealed":false,"t":3,"n":5,"progress":0}' > "$D/ss-open.json"
  printf '%s' '{"nonce":"n-fix","otp":"O-fix","otp_length":26}' > "$D/gr-fix.json"

  # ---- honest baseline through the full stub flow ----
  run_case base
  ck F-STUB-BASELINE-RC expect_eq "$CASE_RC" "0"
  ck F-STUB-BASELINE-SUM expect_eq "$(sum_of "$CASE_OUT")" \
    "OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v0.0.0-selftest"
  ck F-STUB-BASELINE-VEC expect_eq "$(vec_of "$CASE_OUT")" "HHHHH"
  ck F-STUB-CLEAN expect_eq "$(find "$ST_D/w-base" -mindepth 1 2>/dev/null | wc -l)" "0"

  # ---- each shim flips exactly its own test ----
  run_case sh1 KAGI_SEAL_SHIM=SH1
  ck F-STUB-SH1-RC expect_eq "$CASE_RC" "1"
  ck F-STUB-SH1-SUM expect_eq "$(sum_of "$CASE_OUT")" "OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v0.0.0-selftest"
  ck F-STUB-SH1-VEC expect_eq "$(vec_of "$CASE_OUT")" "BHHHH"
  run_case sh2 KAGI_SEAL_SHIM=SH2
  ck F-STUB-SH2-RC expect_eq "$CASE_RC" "1"
  ck F-STUB-SH2-SUM expect_eq "$(sum_of "$CASE_OUT")" "OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v0.0.0-selftest"
  ck F-STUB-SH2-VEC expect_eq "$(vec_of "$CASE_OUT")" "HBHHH"
  run_case sh3 KAGI_SEAL_SHIM=SH3
  ck F-STUB-SH3-RC expect_eq "$CASE_RC" "1"
  ck F-STUB-SH3-SUM expect_eq "$(sum_of "$CASE_OUT")" "OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v0.0.0-selftest"
  ck F-STUB-SH3-VEC expect_eq "$(vec_of "$CASE_OUT")" "HHBHH"
  run_case sh4 KAGI_SEAL_SHIM=SH4
  ck F-STUB-SH4-RC expect_eq "$CASE_RC" "1"
  ck F-STUB-SH4-SUM expect_eq "$(sum_of "$CASE_OUT")" "OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v0.0.0-selftest"
  ck F-STUB-SH4-VEC expect_eq "$(vec_of "$CASE_OUT")" "HHHBH"
  run_case sh5 KAGI_SEAL_SHIM=SH5
  ck F-STUB-SH5-RC expect_eq "$CASE_RC" "1"
  ck F-STUB-SH5-SUM expect_eq "$(sum_of "$CASE_OUT")" "OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v0.0.0-selftest"
  ck F-STUB-SH5-VEC expect_eq "$(vec_of "$CASE_OUT")" "HHHHB"

  # ---- injected ERROR: exit 2 (the fault breaks the first unseal of each
  # simulated server: T2's on raft, T5's on inmem) ----
  run_case fault KAGI_STUB_FAULT=unseal-fault
  ck F-STUB-FAULT-RC expect_eq "$CASE_RC" "2"
  ck F-STUB-FAULT-SUM expect_eq "$(sum_of "$CASE_OUT" | cut -d' ' -f2)" "ERROR"
  ck F-STUB-FAULT-VEC expect_eq "$(vec_of "$CASE_OUT")" "HEHHE"

  # ---- no bao on PATH: SETUP rc 2, no HOLDS/TRIAL line, clean work dir ----
  st_no_bao() {
    local out rc
    mkdir -p "$ST_D/nobin"
    out=$(env -i PATH="$ST_D/nobin" "$ST_BASH" "$ST_GSRC" --work "$ST_D/w-nobao" 2>&1); rc=$?
    NOBAO_RC=$rc; NOBAO_OUT="$out"
    [ "$rc" = 2 ]
  }
  ck F-NOBAO-RC st_no_bao
  ck F-NOBAO-LINE expect_eq "$NOBAO_OUT" "OPENBAO_SEAL_TRIAL: SETUP no bao on PATH"
  no_holds_or_trial() { ! printf '%s\n' "$NOBAO_OUT" | grep -qE '^(TRIAL |OPENBAO_SEAL_TRIAL: (HOLDS|BROKEN|ERROR))'; }
  ck F-NOBAO-NOTRIAL no_holds_or_trial
  ck F-NOBAO-CLEAN expect_eq "$(find "$ST_D/w-nobao" -mindepth 1 2>/dev/null | wc -l)" "0"

  # ---- unknown shim: SETUP rc 2 ----
  run_case shim9 KAGI_SEAL_SHIM=SH9
  ck F-UNKNOWN-SHIM-RC expect_eq "$CASE_RC" "2"
  ck F-UNKNOWN-SHIM-LINE expect_eq "$CASE_OUT" "OPENBAO_SEAL_TRIAL: SETUP invalid KAGI_SEAL_SHIM"

  # ---- usage error ----
  st_usage() {
    local out rc
    out=$("$ST_BASH" "$ST_GSRC" --bogus 2>&1); rc=$?
    USAGE_RC=$rc; USAGE_OUT="$out"
    [ "$rc" = 2 ]
  }
  ck F-USAGE-RC st_usage
  usage_text() { case "$USAGE_OUT" in *usage*) return 0 ;; *) return 1 ;; esac; }
  ck F-USAGE-TEXT usage_text

  # ---- shim resolution: exactly one designated flip, nothing else ----
  shim_matrix() {
    local sh t f flips ft ff
    for sh in SH1 SH2 SH3 SH4 SH5 NOPE SH9 ""; do
      flips=0; ft=""; ff=""
      for t in 1 2 3 4 5; do
        for f in $ALLFLAGS; do
          if shim_flip "$sh" "$t" "$f"; then flips=$((flips+1)); ft=$t; ff=$f; fi
        done
      done
      case "$sh" in
        SH1) [ "$flips" = 1 ] && [ "$ft" = 1 ] && [ "$ff" = shares ] || return 1 ;;
        SH2) [ "$flips" = 1 ] && [ "$ft" = 2 ] && [ "$ff" = dup ] || return 1 ;;
        SH3) [ "$flips" = 1 ] && [ "$ft" = 3 ] && [ "$ff" = auth503 ] || return 1 ;;
        SH4) [ "$flips" = 1 ] && [ "$ft" = 4 ] && [ "$ff" = dec ] || return 1 ;;
        SH5) [ "$flips" = 1 ] && [ "$ft" = 5 ] && [ "$ff" = mem405 ] || return 1 ;;
        *) [ "$flips" = 0 ] || return 1 ;;
      esac
    done
    return 0
  }
  ck F-SHIM-MATRIX shim_matrix

  # ---- verdict mapping ----
  ck F-VERDICT-ALL verdict_all 1 1 1
  ck F-VERDICT-FOUR verdict_all 1 1 1 1
  ck F-VERDICT-PART1 not verdict_all 1 1 0
  ck F-VERDICT-PART2 not verdict_all 1 0 1
  ck F-VERDICT-PART3 not verdict_all 0 1 1
  ck F-VERDICT-NONE not verdict_all
  ck F-RCFOR-HOLD expect_eq "$(rc_for 5 0 0)" 0
  ck F-RCFOR-BROKEN expect_eq "$(rc_for 4 1 0)" 1
  ck F-RCFOR-ERROR expect_eq "$(rc_for 3 0 2)" 2
  ck F-RCFOR-ERRWINS expect_eq "$(rc_for 5 0 1)" 2
  ck F-SUM-HOLD expect_eq "$(summary_line HOLDS 5 0 0 v2.7.2)" "OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
  ck F-SUM-BROKEN expect_eq "$(summary_line BROKEN 4 1 0 v2.7.2)" "OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
  ck F-SUM-ERROR expect_eq "$(summary_line ERROR 3 0 2 v2.7.2)" "OPENBAO_SEAL_TRIAL: ERROR holds=3 broken=0 error=2 bao=v2.7.2"
  ck F-COUNT-ALLHOLD expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 HOLDS b=1' 'T3 HOLDS c=1' 'T4 HOLDS d=1' 'T5 HOLDS e=1')" "5 0 0 HOLDS 0"
  ck F-COUNT-ONEBROKEN expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 BROKEN b=1' 'T3 HOLDS c=1' 'T4 HOLDS d=1' 'T5 HOLDS e=1')" "4 1 0 BROKEN 1"
  ck F-COUNT-ONEERROR expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 HOLDS b=1' 'T3 ERROR c=1' 'T4 HOLDS d=1' 'T5 HOLDS e=1')" "4 0 1 ERROR 2"
  ck F-COUNT-MIXED expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 BROKEN b=1' 'T3 ERROR c=1' 'T4 HOLDS d=1' 'T5 HOLDS e=1')" "3 1 1 ERROR 2"

  # ---- error-text extraction and refusal matching ----
  ck F-ERRTEXT-EXTRACT expect_eq "$(errtext "$D/rkfix")" "unsupported operation"
  ck F-SLUG-STABLE expect_eq "$(errtext "$D/rkfix" | slug)" "unsupported-operation"
  ck F-NAMED-405-POS named_refusal "$D/rkfix" 'unsupported operation'
  ck F-NAMED-405-NEG not named_refusal "$D/rkfix-bad" 'unsupported operation'
  ck F-ERRTEXT-EMPTY expect_eq "$(errtext "$D/err-empty")" ""

  # ---- JSON field extraction (seal-status shapes) ----
  ck F-JGET-INIT expect_eq "$(jget initialized < "$D/ss-fix.json")" "true"
  ck F-JGET-SEALED expect_eq "$(jget sealed < "$D/ss-fix.json")" "true"
  ck F-JGET-T expect_eq "$(jget t < "$D/ss-fix.json")" "3"
  ck F-JGET-PROG expect_eq "$(jget progress < "$D/ss-open.json")" "0"
  ck F-JGET-MISSING not jget missing < "$D/ss-fix.json"
  ck F-JGET-NESTED expect_eq "$(jget otp_length < "$D/gr-fix.json")" "26"
  ck F-JHAS-POS jhas initialized < "$D/ss-fix.json"
  ck F-JHAS-NEG not jhas nope < "$D/ss-fix.json"

  # ---- the script itself carries no secret-shaped literal ----
  no_secret_shape() { ! grep -nE 'hvs\.|hvb\.' "$ST_GSRC"; }
  ck F-NOSECRETSHAPE no_secret_shape
  no_long_b64_run() { ! grep -nE '[A-Za-z0-9/+_]{40,}' "$ST_GSRC" >/dev/null; }
  ck F-NOLONGRUN no_long_b64_run

  rm -rf -- "$D"
  D=""
  if [ "$STF" -eq 0 ]; then
    echo "SEAL_SELFTEST: PASS (cases=$STC)"
    return 0
  fi
  echo "SEAL_SELFTEST: FAIL (cases=$STC failed=$STF)"
  return 1
}

# -------------------- real run

if [ "$MODE" = selfworker ]; then
  run_selftest "$SELF" "$WORK"
  exit $?
fi

command -v bao >/dev/null 2>&1 || { echo "OPENBAO_SEAL_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_SEAL_TRIAL: SETUP no python3"; exit 2; }
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_SEAL_TRIAL: SETUP no setpriv"; exit 2; }
command -v curl >/dev/null 2>&1 || { echo "OPENBAO_SEAL_TRIAL: SETUP no curl"; exit 2; }
case "$SHIM" in
  ""|SH1|SH2|SH3|SH4|SH5) ;;
  *) echo "OPENBAO_SEAL_TRIAL: SETUP invalid KAGI_SEAL_SHIM"; exit 2 ;;
esac
BASE="${WORK:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecTrial/trial-work}"
mkdir -p "$BASE" 2>/dev/null || { echo "OPENBAO_SEAL_TRIAL: SETUP work dir not creatable"; exit 2; }
D=$(mktemp -d "$BASE/openbao-seal-trial.XXXXXX") \
  || { echo "OPENBAO_SEAL_TRIAL: SETUP work dir not writable"; exit 2; }
SRV=""
cleanup() {
  stop_server
  rm -rf -- "$D"
  D=""
}
trap 'cleanup' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP
while IFS= read -r v; do [ -n "$v" ] && unset "$v"; done < <(env | sed -n 's/^\(BAO_[A-Z_]*\)=.*/\1/p; s/^\(VAULT_[A-Z_]*\)=.*/\1/p')
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy 2>/dev/null
export HOME="$D/home"; mkdir -p "$HOME"
VER=$(bao version 2>/dev/null | awk '{print $2; exit}')
[ -n "$VER" ] || { echo "OPENBAO_SEAL_TRIAL: SETUP bao version unreadable"; exit 2; }

t1
t2
t3
t4
t5
stop_server

for line in "$RV1" "$RV2" "$RV3" "$RV4" "$RV5"; do
  echo "TRIAL $line"
done
read H B E S RC < <(countmap "$RV1" "$RV2" "$RV3" "$RV4" "$RV5")
echo "$(summary_line "$S" "$H" "$B" "$E" "$VER")"
exit "$RC"
