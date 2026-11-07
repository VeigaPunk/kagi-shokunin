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
# unusable work dir, any ERROR, unknown KAGI_TRANSIT_SHIM). A PATH with no
# `bao` prints `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH` and exits 2 with
# no TRIAL line. Any non-empty KAGI_TRANSIT_SHIM value other than SH1..SH5 is
# SETUP (exit 2) before any tool check runs.
# Falsifier shims (round-48/49/51/52/57/58 convention): KAGI_TRANSIT_SHIM=SH1..SH5
# replaces exactly one test's observable evaluation, never the mechanics and
# never the cleanroom leg, so exactly that one test reads BROKEN.
# --selftest (kagi round 60, item I7): fixture-driven, no real `bao`, no
# network. Runs the trial nine times against a stateful stub `bao` written
# per case under the work dir: a python3 test double that never speaks HTTP
# (its only socket is a loopback listener held open so the trial's `ss`
# readiness probe sees the server pid; each `-dev` server keeps its own
# storage under STUB_STATE/<port>/, so the clean-room leg still proves
# cross-storage refusal). Cases, each asserting the trial's process exit
# code and output shape:
#   ST-BASELINE     honest stub: six legs HOLDS, holds=5 -> exit 0
#   ST-SHIM-SH1..5  each shim flips exactly its own test -> exit 1,
#                   summary BROKEN holds=4 broken=1 error=0
#   ST-ERROR-EXIT   injected encrypt fault: summary ERROR -> exit 2
#   ST-SHIM-UNKNOWN unknown KAGI_TRANSIT_SHIM -> SETUP, exit 2, no HOLDS
#   ST-NOBAO        PATH with no `bao` -> SETUP, exit 2, no HOLDS
# A failing case prints `FINDING TRANSIT-ST-<ID> <detail>` and the run exits
# non-zero; a passing run ends `TRANSIT_SELFTEST: PASS (cases=N)`, exit 0.
# The stub accepts the trial's token env without reading or printing it; no
# secret material exists in selftest mode (every value is a random
# in-process nonce).
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
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --work) [ $# -ge 2 ] || { echo "usage: $0 [--selftest] [--work DIR]" >&2; exit 2; }; WORK="$2"; shift 2;;
    --selftest) SELFTEST=1; shift;;
    *) echo "usage: $0 [--selftest] [--work DIR]" >&2; exit 2;;
  esac
done
# Shim selector: bound here (before any tool check) so an unknown value is a
# SETUP rc 2 that the selftest can prove without `bao` on PATH. SH1..SH5 each
# flip exactly their own test below; empty behaves as unset.
SHIM="${KAGI_TRANSIT_SHIM:-}"
case "$SHIM" in
  ""|SH1|SH2|SH3|SH4|SH5) ;;
  *) echo "OPENBAO_TRANSIT_TRIAL: SETUP unknown KAGI_TRANSIT_SHIM"; exit 2;;
esac
# ----------------------------------------------------------------------
# Selftest fixtures and case runner (see the --selftest header block above).
_st_fail() { # ID DETAIL -> record a failed case
  echo "FINDING TRANSIT-ST-$1 $2"
  ST_FAIL=$((ST_FAIL+1))
}
_st_wantrc() { # ID WANT-RC -> assert the trial subprocess exit code
  [ "$ST_RC" = "$2" ] || _st_fail "$1" "exit=$ST_RC want=$2"
}
_st_want() { # ID FIXED-SUBSTRING that must appear in the trial stdout
  case "$ST_OUT" in
    *"$2"*) : ;;
    *) _st_fail "$1" "missing: $2" ;;
  esac
}
_st_absent() { # ID FIXED-SUBSTRING that must not appear in the trial stdout
  case "$ST_OUT" in
    *"$2"*) _st_fail "$1" "unexpected: $2" ;;
    *) : ;;
  esac
}
_st_case() { # ID PATHMODE(stub|empty) SHIM(-|SHx) FAULT(-|name); sets ST_OUT/ST_RC
  ST_CW="$ST_BASE/case-$1"
  mkdir -p "$ST_CW/state" "$ST_CW/work" || { _st_fail "$1" "case dir not creatable"; ST_OUT=""; ST_RC=125; return; }
  local pp envs=() shim fault
  if [ "$2" = stub ]; then pp="$ST_BIN:$ST_PATH"; else pp="$ST_EMPTY"; fi
  shim="$3"; [ "$shim" = "-" ] && shim=""
  fault="$4"; [ "$fault" = "-" ] && fault=""
  # Every case pins its whole fixture environment so no ambient value leaks in.
  # timeout/bash are invoked by absolute path: env applies PATH=$pp to its own
  # exec lookup, and timeout would otherwise resolve bash through $pp too.
  envs+=("KAGI_TRANSIT_SHIM=$shim" "STUB_FAULT=$fault" "PATH=$pp")
  [ "$2" = stub ] && envs+=("STUB_STATE=$ST_CW/state")
  ST_OUT=$(env "${envs[@]}" "$ST_TIMEOUT" 120 "$ST_BASH" "$ST_SELF" --work "$ST_CW/work" 2>"$ST_CW/trial.err")
  ST_RC=$?
}
transit_selftest() {
  ST_SELF="$1"; ST_FAIL=0; ST_N=0; ST_OUT=""; ST_RC=0; ST_CW=""
  local t root p s m
  for t in python3 timeout ss setpriv pgrep; do
    command -v "$t" >/dev/null 2>&1 || { echo "TRANSIT_SELFTEST: SETUP no $t"; return 2; }
  done
  # Seat-agnostic default: the C1 checker, controls battery and reviewers all
  # invoke --selftest without --work, possibly concurrently; mktemp gives each
  # run a unique subdir under this shared parent.
  root="${WORK:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-transit-trial/selftest-work}"
  mkdir -p "$root" 2>/dev/null || { echo "TRANSIT_SELFTEST: SETUP work dir not creatable"; return 2; }
  ST_BASE=$(mktemp -d "$root/transit-selftest.XXXXXX") || { echo "TRANSIT_SELFTEST: SETUP work dir not writable"; return 2; }
  ST_BIN="$ST_BASE/bin"; ST_EMPTY="$ST_BASE/empty"; ST_PATH="$PATH"
  ST_TIMEOUT=$(command -v timeout) || { echo "TRANSIT_SELFTEST: SETUP no timeout"; return 2; }
  ST_BASH=$(command -v bash) || { echo "TRANSIT_SELFTEST: SETUP no bash"; return 2; }
  mkdir -p "$ST_BIN" "$ST_EMPTY" || { echo "TRANSIT_SELFTEST: SETUP fixture dirs not creatable"; return 2; }
  trap 'rm -rf -- "$ST_BASE"' EXIT
  cat > "$ST_BIN/bao" <<'STUB'
#!/usr/bin/env python3
# Stub `bao` fixture for this trial's --selftest (kagi round 60, I7).
# A test double, NOT OpenBao: it dispatches exactly the CLI calls the trial
# makes against per-server JSON state under $STUB_STATE/<port>/. No HTTP
# exists anywhere in selftest mode: server mode only opens a loopback
# listener and holds it (no accept, no client ever connects) so the trial's
# `ss` readiness probe finds the pid; client mode is pure in-process state.
# The trial's token env is accepted and never read or printed.
import base64, hashlib, json, os, socket, sys, time

def sdir():
    port = os.environ.get("BAO_ADDR", "").rsplit(":", 1)[-1]
    return os.path.join(os.environ["STUB_STATE"], port)

def load():
    try:
        with open(os.path.join(sdir(), "state.json")) as f:
            return json.load(f)
    except Exception:
        return {"keys": {}}

def save(st):
    os.makedirs(sdir(), exist_ok=True)
    with open(os.path.join(sdir(), "state.json"), "w") as f:
        json.dump(st, f)

def fail(msg):
    sys.stderr.write("Code: 400. Errors:\n\n* %s\n" % msg)
    sys.exit(1)

def emit(data):
    sys.stdout.write(json.dumps({"data": data}))

def parse(argv):
    path, kvs, body = None, {}, {}
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == "-":
            try:
                body = json.loads(sys.stdin.read() or "{}")
            except Exception:
                body = {}
        elif a.startswith("-"):
            pass
        elif path is None:
            path = a
        elif "=" in a:
            k, _, v = a.partition("=")
            kvs[k] = v
        i += 1
    return path, kvs, body

def serve():
    port = None
    for a in sys.argv:
        if a.startswith("-dev-listen-address="):
            port = int(a.rsplit(":", 1)[1])
    if port is None:
        fail("no -dev-listen-address")
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", port))
    s.listen(1)
    os.makedirs(os.path.join(os.environ["STUB_STATE"], str(port)), exist_ok=True)
    while True:
        time.sleep(3600)

def main():
    if len(sys.argv) < 2:
        fail("no subcommand")
    c = sys.argv[1]
    if c == "version":
        print("bao vStub-1 (transit-selftest fixture)")
        return
    if c in ("status", "secrets"):
        return
    if c == "server":
        serve()
        return
    st = load()
    keys = st["keys"]
    path, kvs, body = parse(sys.argv[2:])
    if path is None:
        fail("no path")
    parts = [p for p in path.strip("/").split("/") if p]
    if len(parts) < 2 or parts[0] != "transit":
        fail("unsupported path %s" % path)
    if c == "read" and parts[1] == "keys" and len(parts) == 3:
        kk = keys.get(parts[2])
        if kk is None:
            fail("key %s not found" % parts[2])
        emit({"latest_version": kk["ver"], "min_decryption_version": kk["mdv"]})
        return
    if c != "write":
        fail("unsupported subcommand %s" % c)
    if parts[1] == "keys" and len(parts) == 3:
        k = parts[2]
        if k not in keys:
            keys[k] = {"ver": 1, "mdv": 0,
                       "conv": bool(kvs.get("convergent_encryption")),
                       "map": {}}
        save(st)
        return
    k = parts[2] if len(parts) > 2 else ""
    kk = keys.get(k)
    if parts[1] == "keys" and len(parts) == 4 and parts[3] == "rotate":
        if kk is None:
            fail("key %s not found" % k)
        kk["ver"] += 1
        save(st)
        return
    if parts[1] == "keys" and len(parts) == 4 and parts[3] == "config":
        if kk is None:
            fail("key %s not found" % k)
        kk["mdv"] = int(kvs.get("min_decryption_version", "0"))
        save(st)
        return
    if parts[1] == "encrypt":
        if os.environ.get("STUB_FAULT") == "encrypt":
            fail("stub fault: encrypt refused")
        if kk is None:
            # Real transit auto-creates a key on first encrypt; T1 relies on it.
            kk = keys[k] = {"ver": 1, "mdv": 0, "conv": False, "map": {}}
        pt = body.get("plaintext", "")
        ctx = body.get("context", "")
        if kk["conv"] and not ctx:
            fail("context required for derived key")
        if kk["conv"]:
            dig = hashlib.sha256(("%s|%s|%s" % (k, ctx, pt)).encode()).digest()
            b = base64.b64encode(dig).decode()
        else:
            b = base64.b64encode(os.urandom(18)).decode()
        ct = "vault:v%d:%s" % (kk["ver"], b)
        kk["map"][ct] = {"pt": pt, "ver": kk["ver"]}
        save(st)
        emit({"ciphertext": ct})
        return
    if parts[1] == "rewrap":
        if kk is None:
            fail("key %s not found" % k)
        e = kk["map"].get(body.get("ciphertext", ""))
        if e is None:
            fail("message authentication failed")
        nct = "vault:v%d:%s" % (kk["ver"], base64.b64encode(os.urandom(18)).decode())
        kk["map"][nct] = {"pt": e["pt"], "ver": kk["ver"]}
        save(st)
        emit({"ciphertext": nct})
        return
    if parts[1] == "decrypt":
        if kk is None:
            fail("encryption key not found")
        e = kk["map"].get(body.get("ciphertext", ""))
        if e is None:
            fail("message authentication failed")
        if e["ver"] < kk["mdv"]:
            fail("ciphertext version is disallowed by policy (too old)")
        emit({"plaintext": e["pt"]})
        return
    fail("unsupported transit path %s" % path)

main()
STUB
  chmod +x "$ST_BIN/bao" || { echo "TRANSIT_SELFTEST: SETUP stub not executable"; return 2; }

  # ST-BASELINE: honest stub end-to-end — six legs HOLDS, exit 0.
  _st_case BASELINE stub - -; ST_N=$((ST_N+1))
  _st_wantrc BASELINE 0
  _st_want BASELINE "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=vStub-1"
  _st_want BASELINE "TRIAL T1 HOLDS"; _st_want BASELINE "TRIAL T2 HOLDS"
  _st_want BASELINE "TRIAL T3 HOLDS"; _st_want BASELINE "TRIAL T4 HOLDS"
  _st_want BASELINE "TRIAL T5 HOLDS"; _st_want BASELINE "TRIAL CLEANROOM HOLDS"
  [ "$(printf '%s\n' "$ST_OUT" | grep -c '^TRIAL ')" = 6 ] || _st_fail BASELINE "TRIAL lines != 6"

  # ST-SHIM-SH1..SH5: each shim resolves to exactly its own test -> exit 1.
  for s in SH1 SH2 SH3 SH4 SH5; do
    _st_case "SHIM-$s" stub "$s" -; ST_N=$((ST_N+1))
    _st_wantrc "SHIM-$s" 1
    _st_want "SHIM-$s" "OPENBAO_TRANSIT_TRIAL: BROKEN holds=4 broken=1 error=0 bao=vStub-1"
    _st_want "SHIM-$s" "TRIAL T${s#SH} BROKEN"
    for m in 1 2 3 4 5; do
      [ "$m" = "${s#SH}" ] || _st_want "SHIM-$s" "TRIAL T$m HOLDS"
    done
    _st_want "SHIM-$s" "TRIAL CLEANROOM HOLDS"
  done

  # ST-ERROR-EXIT: injected encrypt fault -> summary ERROR, exit 2.
  _st_case ERROR-EXIT stub - encrypt; ST_N=$((ST_N+1))
  _st_wantrc ERROR-EXIT 2
  _st_want ERROR-EXIT "OPENBAO_TRANSIT_TRIAL: ERROR "
  _st_want ERROR-EXIT "TRIAL T1 ERROR "

  # ST-SHIM-UNKNOWN: an unknown shim value is SETUP rc 2 (run with an empty
  # PATH so this also proves the validation precedes every tool check).
  _st_case SHIM-UNKNOWN empty SH9 -; ST_N=$((ST_N+1))
  _st_wantrc SHIM-UNKNOWN 2
  _st_want SHIM-UNKNOWN "OPENBAO_TRANSIT_TRIAL: SETUP unknown KAGI_TRANSIT_SHIM"
  _st_absent SHIM-UNKNOWN "HOLDS"

  # ST-NOBAO: a PATH with no `bao` reads SETUP rc 2, no HOLDS line.
  _st_case NOBAO empty - -; ST_N=$((ST_N+1))
  _st_wantrc NOBAO 2
  _st_want NOBAO "OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH"
  _st_absent NOBAO "HOLDS"

  # Reap any stub server a crashed case left behind (each trial run kills its
  # own server through its EXIT trap on every normal path).
  for p in $(pgrep -f "$ST_BIN/bao server" 2>/dev/null); do kill "$p" 2>/dev/null; done

  if [ "$ST_FAIL" -gt 0 ]; then
    echo "TRANSIT_SELFTEST: FAIL (cases=$ST_N failed=$ST_FAIL)"
    return 1
  fi
  echo "TRANSIT_SELFTEST: PASS (cases=$ST_N)"
  return 0
}
if [ "$SELFTEST" = 1 ]; then
  transit_selftest "$0"
  exit $?
fi
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
