#!/usr/bin/env bash
# OpenBao transit (encryption-as-a-service) trial (kagi round 59, C2 capability).
# Sources: S121 https://openbao.org/docs/secrets/transit/ and
# S122 https://openbao.org/docs/api/secret/transit/ (OpenBao docs 2.7.x),
# opened 2026-11-07. Executed on ONE throwaway in-memory `bao server -dev`
# bound to 127.0.0.1 under `setpriv --pdeathsig KILL`; `bao` is resolved
# through PATH only (never an absolute path). Five transit mechanics the
# pages document:
#   T1 encrypt/decrypt round trip: `transit/encrypt/<key>` returns
#      `vault:v1:<base64>`; `transit/decrypt` returns the exact plaintext;
#      the ciphertext carries the `vault:v1:` prefix and does not contain the
#      plaintext; a ciphertext with one base64 character changed is refused
#      with a decrypt error (message authentication failed).
#   T2 `transit/keys/<key>/rotate` creates a new key version: after one
#      rotation a fresh encryption carries `vault:v2:` and the key reads
#      latest_version=2, while the pre-rotation `vault:v1:` ciphertext still
#      decrypts.
#   T3 `transit/rewrap` re-encrypts a ciphertext under the newest key version
#      without the client supplying the plaintext: the rewrapped ciphertext
#      differs from the original, carries `vault:v2:` and decrypts; after
#      raising `min_decryption_version` to 2 it still decrypts while the
#      original `vault:v1:` ciphertext is refused (so rewrap needed no
#      client-side decrypt).
#   T4 `min_decryption_version` is the retirement control: raising it to 2
#      (key reads min_decryption_version=2) refuses version-1 ciphertext with
#      the named error "ciphertext or signature version is disallowed by
#      policy (too old)"; lowering it back to 1 re-enables the same
#      ciphertext. The key is rotated once first: the API refuses
#      min_decryption_version > latest_version (measured 400), so an existing
#      version 2 is prerequisite setup for the raise; the measured observable
#      is the frozen one.
#   T5 convergent encryption: a key created `derived=true
#      convergent_encryption=true` with a per-request `context` gives
#      byte-identical ciphertext for identical plaintext+context, a different
#      context gives different ciphertext, and a non-convergent key gives
#      different ciphertext for identical plaintext.
#   CLEANROOM leg: a second, independent `bao server -dev` with its own
#      in-memory storage (own port, fresh process) refuses to decrypt the
#      first server's T1 ciphertext ("encryption key not found").
# Prints one line per test, each exactly once:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>       (n = 1..5)
#   TRIAL CLEANROOM HOLDS|BROKEN|ERROR <detail>
# and a final summary line (holds counts T1..T5 only; broken/error count all
# six leg lines):
#   OPENBAO_TRANSIT_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>
# Exit: 0 all six legs HOLDS, 1 any BROKEN (no ERROR), 2 SETUP (missing tool,
# unusable work dir, any ERROR). A PATH with no `bao` prints
# `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH` and exits 2 with no TRIAL line.
# Falsifier shims (round-48/49/51/52/57/58 convention): KAGI_TRANSIT_SHIM=SH1..SH5
# replaces exactly one test's observable evaluation, never the mechanics and
# never the cleanroom leg, so exactly that one test reads BROKEN.
# Secret handling: no token, plaintext marker, ciphertext or context on any
# argv or in any printed line. The dev root token reaches the server through
# BAO_DEV_ROOT_TOKEN_ID and every client through BAO_TOKEN (env, never argv);
# ambient BAO_*/VAULT_* variables are scrubbed at start. The plaintext marker
# and the convergent contexts are random `r59-` + 24-hex nonces, base64-encoded
# and sent inside a JSON request body on stdin (`bao write <path> -`); the
# ciphertext travels the same way. Comparisons are exact string equality
# in-process; the server's stdout goes to /dev/null. The trial writes only
# under --work DIR (default ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/
# R59ExecTrial/trial-work) and removes its per-run subdirectory on exit.
# The binary is not sha-pinned here on purpose: the trial reports `bao=<ver>`
# and the counter/battery owns the C2-F7 pin (see plans/round-59.md).
set -u
umask 077
WORK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) [ $# -ge 2 ] || { echo "usage: $0 [--work DIR]" >&2; exit 2; }; WORK="$2"; shift 2;;
    *) echo "usage: $0 [--work DIR]" >&2; exit 2;;
  esac
done
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_TRANSIT_TRIAL: SETUP no python3"; exit 2; }
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_TRANSIT_TRIAL: SETUP no setpriv"; exit 2; }
command -v ss >/dev/null 2>&1 || { echo "OPENBAO_TRANSIT_TRIAL: SETUP no ss"; exit 2; }
BASE="${WORK:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecTrial/trial-work}"
mkdir -p "$BASE" 2>/dev/null || { echo "OPENBAO_TRANSIT_TRIAL: SETUP work dir not creatable"; exit 2; }
D=$(mktemp -d "$BASE/openbao-transit-trial.XXXXXX") || { echo "OPENBAO_TRANSIT_TRIAL: SETUP work dir not writable"; exit 2; }
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
[ -n "$VER" ] || { echo "OPENBAO_TRANSIT_TRIAL: SETUP bao version unreadable"; exit 2; }
SHIM="${KAGI_TRANSIT_SHIM:-}"
nonce() { python3 -c 'import secrets;print("r59-"+secrets.token_hex(12))'; }
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
jfield() { # FIELD -> data.<FIELD> of the JSON object on stdin; rc 3 unparseable
  python3 -c 'import json,sys
try:
    print(json.load(sys.stdin)["data"][sys.argv[1]])
except Exception:
    sys.exit(3)' "$1"
}
mkbody() { # PLAINTEXT_B64 [CONTEXT_B64] -> JSON request body on stdout
  PB="$1" CX="${2:-}" python3 -c 'import json,os,sys
b = {"plaintext": os.environ["PB"]}
cx = os.environ.get("CX", "")
if cx:
    b["context"] = cx
sys.stdout.write(json.dumps(b))'
}
enc() { # KEY [CONTEXT_B64] -> ciphertext on stdout; rc!=0 on failure
  local ct
  ct=$(mkbody "$PB64" "${2:-}" | bao write -format=json "transit/encrypt/$1" - 2>"$D/err" | jfield ciphertext) || return 1
  [ -n "$ct" ] || return 1
  printf '%s' "$ct"
}
decj() { # CIPHERTEXT KEY -> JSON response on stdout; rc!=0 when refused
  printf '{"ciphertext":"%s"}' "$1" | bao write -format=json "transit/decrypt/$2" - 2>"$D/err"
}
rewrapj() { # CIPHERTEXT KEY -> JSON response on stdout; rc!=0 on failure
  printf '{"ciphertext":"%s"}' "$1" | bao write -format=json "transit/rewrap/$2" - 2>"$D/err"
}
kcreate() { bao write -f "transit/keys/$1" >/dev/null 2>"$D/err"; }
convcreate() { bao write "transit/keys/$1" derived=true convergent_encryption=true >/dev/null 2>"$D/err"; }
rot() { bao write -f "transit/keys/$1/rotate" >/dev/null 2>"$D/err"; }
kcfg() { bao write "transit/keys/$1/config" "min_decryption_version=$2" >/dev/null 2>"$D/err"; }
keyint() { # KEY FIELD -> integer value on stdout; rc 3 on failure
  bao read -format=json "transit/keys/$1" 2>/dev/null | jfield "$2"
}
tamper1() { # CIPHERTEXT -> same ciphertext with one base64 body character changed
  CT="$1" python3 -c 'import os
p, v, b = os.environ["CT"].split(":", 2)
i = 2
alt = "B" if b[i] != "B" else "C"
print(p + ":" + v + ":" + b[:i] + alt + b[i+1:])'
}

K1=r59-t1; K2=r59-t2; K3=r59-t3; K4=r59-t4; K5=r59-t5c; K6=r59-t5p
PT=$(nonce)
PB64=$(printf '%s' "$PT" | base64 -w0)
CTXA=$(printf '%s' "$(nonce)" | base64 -w0)
CTXB=$(printf '%s' "$(nonce)" | base64 -w0)
CT1=""
RV1="T1 ERROR not-run"; RV2="T2 ERROR not-run"; RV3="T3 ERROR not-run"
RV4="T4 ERROR not-run"; RV5="T5 ERROR not-run"; RVCR="CLEANROOM ERROR not-run"

start_server || { echo "OPENBAO_TRANSIT_TRIAL: SETUP dev server did not start"; exit 2; }
bao secrets enable transit >/dev/null 2>"$D/err" || { echo "OPENBAO_TRANSIT_TRIAL: SETUP transit enable failed"; exit 2; }

# T1 — round trip, vault:v1: prefix, no plaintext in ciphertext, tamper refusal.
t1() {
  local ct out d64 dpt tam rt=0 pre=0 nopt=0 tref=0
  ct=$(enc "$K1") || { RV1="T1 ERROR encrypt-rc=1"; return; }
  CT1="$ct"
  case "$ct" in vault:v1:*) pre=1;; esac
  case "$ct" in *"$PT"*|*"$PB64"*) nopt=0;; *) nopt=1;; esac
  if out=$(decj "$ct" "$K1"); then
    d64=$(printf '%s' "$out" | jfield plaintext) || d64=""
    if [ -n "$d64" ]; then
      dpt=$(printf '%s' "$d64" | base64 -d 2>/dev/null)
      [ "$dpt" = "$PT" ] && rt=1
    fi
  fi
  unset out d64 dpt
  tam=$(tamper1 "$ct") || { RV1="T1 ERROR tamper-build-rc=1"; return; }
  if ! decj "$tam" "$K1" >/dev/null 2>"$D/err"; then
    grep -qE 'message authentication failed|Code: 400' "$D/err" 2>/dev/null && tref=1
  fi
  [ "$SHIM" = SH1 ] && tref=0
  if [ "$rt" = 1 ] && [ "$pre" = 1 ] && [ "$nopt" = 1 ] && [ "$tref" = 1 ]; then
    RV1="T1 HOLDS roundtrip=1 prefix-v1=1 no-pt-in-ct=1 tamper-refused=1"
  else
    RV1="T1 BROKEN roundtrip=$rt prefix-v1=$pre no-pt-in-ct=$nopt tamper-refused=$tref"
  fi
}

# T2 — rotate advances the key version; the older ciphertext still decrypts.
t2() {
  local c1 c2 lv post=0 old=0 new2=0 lvok=0
  kcreate "$K2" || { RV2="T2 ERROR create-rc=1"; return; }
  c1=$(enc "$K2") || { RV2="T2 ERROR encrypt-rc=1"; return; }
  rot "$K2" || { RV2="T2 ERROR rotate-rc=1"; return; }
  lv=$(keyint "$K2" latest_version) || { RV2="T2 ERROR key-read-rc=1"; return; }
  c2=$(enc "$K2") || { RV2="T2 ERROR encrypt2-rc=1"; return; }
  case "$c2" in vault:v2:*) post=1;; esac
  decj "$c1" "$K2" >/dev/null 2>&1 && old=1
  decj "$c2" "$K2" >/dev/null 2>&1 && new2=1
  [ "$lv" = "2" ] && lvok=1
  [ "$SHIM" = SH2 ] && old=0
  if [ "$post" = 1 ] && [ "$old" = 1 ] && [ "$new2" = 1 ] && [ "$lvok" = 1 ]; then
    RV2="T2 HOLDS fresh-v2=1 latest=$lv old-v1-decrypts=1 new-v2-decrypts=1"
  else
    RV2="T2 BROKEN fresh-v2=$post latest=$lv old-v1-decrypts=$old new-v2-decrypts=$new2"
  fi
}

# T3 — rewrap migrates to the newest version without a client decrypt.
t3() {
  local c1 rw rw2=0 diff=0 rd=0 rd2=0 v1ref=0
  kcreate "$K3" || { RV3="T3 ERROR create-rc=1"; return; }
  c1=$(enc "$K3") || { RV3="T3 ERROR encrypt-rc=1"; return; }
  rot "$K3" || { RV3="T3 ERROR rotate-rc=1"; return; }
  rw=$(rewrapj "$c1" "$K3" | jfield ciphertext) || { RV3="T3 ERROR rewrap-rc=1"; return; }
  [ -n "$rw" ] || { RV3="T3 ERROR rewrap-empty"; return; }
  case "$rw" in vault:v2:*) rw2=1;; esac
  [ "$rw" != "$c1" ] && diff=1
  decj "$rw" "$K3" >/dev/null 2>&1 && rd=1
  kcfg "$K3" 2 || { RV3="T3 ERROR config-rc=1"; return; }
  decj "$rw" "$K3" >/dev/null 2>&1 && rd2=1
  decj "$c1" "$K3" >/dev/null 2>"$D/err" || v1ref=1
  [ "$SHIM" = SH3 ] && v1ref=0
  if [ "$rw2" = 1 ] && [ "$diff" = 1 ] && [ "$rd" = 1 ] && [ "$rd2" = 1 ] && [ "$v1ref" = 1 ]; then
    RV3="T3 HOLDS rewrapped-v2=1 changed=1 rewrapped-decrypts=1 rewrapped-decrypts-after-min2=1 old-v1-refused-after-min2=1"
  else
    RV3="T3 BROKEN rewrapped-v2=$rw2 changed=$diff rewrapped-decrypts=$rd rewrapped-decrypts-after-min2=$rd2 old-v1-refused-after-min2=$v1ref"
  fi
}

# T4 — min_decryption_version=2 refuses v1 with the named error; lowering re-enables.
t4() {
  local c min2 ref=0 min1 re=0 prev1=0
  kcreate "$K4" || { RV4="T4 ERROR create-rc=1"; return; }
  c=$(enc "$K4") || { RV4="T4 ERROR encrypt-rc=1"; return; }
  case "$c" in vault:v1:*) prev1=1;; esac
  rot "$K4" || { RV4="T4 ERROR rotate-rc=1"; return; }
  kcfg "$K4" 2 || { RV4="T4 ERROR config-raise-rc=1"; return; }
  min2=$(keyint "$K4" min_decryption_version) || { RV4="T4 ERROR key-read-rc=1"; return; }
  if ! decj "$c" "$K4" >/dev/null 2>"$D/err"; then
    grep -qE 'disallowed by policy|too old' "$D/err" 2>/dev/null && ref=1
  fi
  [ "$SHIM" = SH4 ] && ref=0
  kcfg "$K4" 1 || { RV4="T4 ERROR config-lower-rc=1"; return; }
  min1=$(keyint "$K4" min_decryption_version) || { RV4="T4 ERROR key-read2-rc=1"; return; }
  decj "$c" "$K4" >/dev/null 2>&1 && re=1
  if [ "$ref" = 1 ] && [ "$re" = 1 ] && [ "$min2" = "2" ] && [ "$min1" = "1" ] && [ "$prev1" = 1 ]; then
    RV4="T4 HOLDS pre-v1=1 min-after-raise=$min2 v1-refused-named-error=1 min-after-lower=$min1 v1-re-enabled=1"
  else
    RV4="T4 BROKEN pre-v1=$prev1 min-after-raise=$min2 v1-refused-named-error=$ref min-after-lower=$min1 v1-re-enabled=$re"
  fi
}

# T5 — convergent key is deterministic for plaintext+context; a non-convergent key is not.
t5() {
  local ca cb cc da db eq=0 dx=0 nd=0
  convcreate "$K5" || { RV5="T5 ERROR convergent-create-rc=1"; return; }
  kcreate "$K6" || { RV5="T5 ERROR create-rc=1"; return; }
  ca=$(enc "$K5" "$CTXA") || { RV5="T5 ERROR encrypt-rc=1"; return; }
  cb=$(enc "$K5" "$CTXA") || { RV5="T5 ERROR encrypt2-rc=1"; return; }
  cc=$(enc "$K5" "$CTXB") || { RV5="T5 ERROR encrypt3-rc=1"; return; }
  da=$(enc "$K6") || { RV5="T5 ERROR encrypt4-rc=1"; return; }
  db=$(enc "$K6") || { RV5="T5 ERROR encrypt5-rc=1"; return; }
  [ -n "$ca" ] && [ "$ca" = "$cb" ] && eq=1
  [ "$ca" != "$cc" ] && dx=1
  [ "$da" != "$db" ] && nd=1
  [ "$SHIM" = SH5 ] && dx=0
  if [ "$eq" = 1 ] && [ "$dx" = 1 ] && [ "$nd" = 1 ]; then
    RV5="T5 HOLDS equal-ctx-byte-identical=1 diff-ctx-differs=1 nonconv-plain-differs=1"
  else
    RV5="T5 BROKEN equal-ctx-byte-identical=$eq diff-ctx-differs=$dx nonconv-plain-differs=$nd"
  fi
}

# CLEANROOM — a second independent dev server (own port, own in-memory storage)
# must refuse the first server's T1 ciphertext.
cleanroom() {
  local oa="${BAO_ADDR-}" ot="${BAO_TOKEN-}" os="$SRV"
  local baddr btok bsrv ok=1
  start_server || { RVCR="CLEANROOM ERROR second-server-start=0"; export BAO_ADDR="$oa" BAO_TOKEN="$ot"; SRV="$os"; return; }
  baddr="$BAO_ADDR"; btok="$BAO_TOKEN"; bsrv="$SRV"
  BAO_ADDR="$baddr" BAO_TOKEN="$btok" bao secrets enable transit >/dev/null 2>"$D/err" || ok=0
  if [ "$ok" = 1 ]; then
    if printf '{"ciphertext":"%s"}' "$CT1" | BAO_ADDR="$baddr" BAO_TOKEN="$btok" bao write -format=json "transit/decrypt/$K1" - >/dev/null 2>"$D/err"; then
      RVCR="CLEANROOM BROKEN own-storage-refused=0"
    else
      RVCR="CLEANROOM HOLDS own-storage-refused=1"
    fi
  else
    RVCR="CLEANROOM ERROR second-transit-enable=0"
  fi
  kill "$bsrv" 2>/dev/null; wait "$bsrv" 2>/dev/null
  export BAO_ADDR="$oa" BAO_TOKEN="$ot"; SRV="$os"
}

t1
t2
t3
t4
t5
cleanroom

H=0; B=0; E=0
for line in "$RV1" "$RV2" "$RV3" "$RV4" "$RV5" "$RVCR"; do
  echo "TRIAL $line"
  case "$line" in
    T*." "*) : ;;
    T*)
      case "$line" in
        *" HOLDS "*) H=$((H+1));;
        *" BROKEN "*) B=$((B+1));;
        *) E=$((E+1));;
      esac
      ;;
    CLEANROOM*)
      case "$line" in
        *" HOLDS "*) : ;;
        *" BROKEN "*) B=$((B+1));;
        *) E=$((E+1));;
      esac
      ;;
  esac
done
if [ "$E" -gt 0 ]; then S=ERROR; rc=2; elif [ "$B" -gt 0 ]; then S=BROKEN; rc=1; else S=HOLDS; rc=0; fi
echo "OPENBAO_TRANSIT_TRIAL: $S holds=$H broken=$B error=$E bao=$VER"
stop_server
exit $rc
