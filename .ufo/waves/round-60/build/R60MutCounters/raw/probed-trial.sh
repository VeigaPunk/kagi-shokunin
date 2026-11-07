#!/usr/bin/env bash
# OpenBao AppRole secret_id custody trial (kagi round 60, C2 capability).
# Sources: S123 https://openbao.org/docs/auth/approle/ and
# S124 https://openbao.org/docs/api/auth/approle/ (OpenBao docs 2.7.x),
# opened 2026-11-07. Executed on ONE throwaway in-memory `bao server -dev`
# bound to 127.0.0.1 under `setpriv --pdeathsig KILL`; `bao` is resolved
# through PATH only (never an absolute path). The AppRole auth method is
# mounted first (`bao auth enable approle`); every request carries
# Content-Type: application/json through the bao CLI, and secret-id creation
# carries an explicit JSON body. Five AppRole secret_id custody mechanics the
# pages document:
#   T1 bind_secret_id: with the default bind_secret_id=true a login carrying
#      only role_id is refused (400 missing secret_id); after
#      bind_secret_id=false on the SAME role (the role carries
#      token_bound_cidrs=127.0.0.1/32, which satisfies the
#      at-least-one-constraint rule) the same body logs in and a token is
#      issued, proving the secret_id is the binding secret half.
#   T2 secret_id_num_uses=1: the first login succeeds, a second login with
#      the same secret_id is refused (invalid role or secret ID), and a
#      freshly generated secret_id logs in.
#   T3 secret_id_ttl=1s: a fresh secret_id logs in immediately, the same one
#      is refused at least 3 s later (invalid role or secret ID), and a newly
#      generated one logs in.
#   T4 secret-id-accessor custody: secret-id-accessor/lookup returns metadata
#      (remaining use count and TTL) and no secret_id value; the raw response
#      does not contain the secret_id; secret-id-accessor/destroy invalidates
#      a still-valid, unused secret_id so login with it is refused.
#   T5 secret_id_bound_cidrs: with 10.0.0.0/8 bound the 127.0.0.1 login is
#      refused with a source-address error; with 127.0.0.1/32 bound the same
#      login (same role_id+secret_id body) succeeds.
# Prints one line per test, each exactly once:
#   TRIAL T<n> HOLDS|BROKEN|ERROR <detail>       (n = 1..5)
# and a final summary line:
#   OPENBAO_APPROLE_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>
# Exit: 0 all five HOLDS, 1 any BROKEN (no ERROR), 2 SETUP (missing tool,
# unusable work dir, any ERROR verdict). A PATH with no `bao` prints
# `OPENBAO_APPROLE_TRIAL: SETUP no bao on PATH` and exits 2 with no TRIAL line.
# Falsifier shims (round-48..59 convention): KAGI_APPROLE_SHIM=SH1..SH5
# replaces exactly one test's observable evaluation, never the mechanics, so
# exactly that one test reads BROKEN (baseline HHHHH; SHn flips only Tn).
# An unrecognised shim value is SETUP (exit 2) before any server starts.
# --selftest: fixture-driven, no bao, no network; isolated scratch fixtures
# assert process exit codes and stable finding ids (FINDING <id> on failure)
# and print APPROLE_SELFTEST: PASS (cases=N). It parses independently of the
# bao check so `bash trial.sh --selftest --work DIR` works with no bao on
# PATH.
# Secret handling: no token, secret_id value, secret-shaped string or request
# body on any argv or in any printed line. The dev root token is a random
# `r60-` + 24-hex nonce passed through BAO_DEV_ROOT_TOKEN_ID (environment,
# never argv) with -dev-no-store-token; every client uses BAO_TOKEN
# (environment). secret_id values and request bodies travel only through
# stdin pipes fed by env-var python3 builders; bao CLI stderr goes to files
# under the work dir. Comparisons are exact string equality in-process; the
# server's stdout goes to /dev/null. Ambient BAO_*/VAULT_* variables are
# scrubbed at start. The trial writes only under --work DIR (default
# ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecTrial/trial-work) and
# removes its per-run subdirectory on exit. The binary is not sha-pinned here
# on purpose: the trial reports `bao=<ver>` and the counter/battery owns the
# pin (see plans/round-60.md).
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

SHIM="${KAGI_APPROLE_SHIM:-}"
G_SID=""
G_ACC=""
D=""

# ---------------------------------------------------------------- pure helpers

jget() { # DOTTED.PATH -> value on stdout; rc 3 on missing/unparseable
  python3 -c 'import json,sys
try:
    v = json.load(sys.stdin)
    for k in sys.argv[1].split("."):
        v = v[k]
    print(v)
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
  printf 'OPENBAO_APPROLE_TRIAL: %s holds=%s broken=%s error=%s bao=%s\n' "$1" "$2" "$3" "$4" "$5"
}

# Every flag name any test evaluates; the selftest shim matrix iterates this
# universe so a shim matching an undeclared or cross-test flag is caught.
ALLFLAGS="aref upd ctok first ref2 fresh imm expref meta cust revoked deny allow"

shim_flip() { # SHIM TESTNUM FLAG -> rc 0 iff this shim flips that flag
  case "$1" in
    SH1) [ "$2" = 1 ] && [ "$3" = ctok ] && return 0; return 1 ;;
    SH2) [ "$2" = 2 ] && [ "$3" = ref2 ] && return 0; return 1 ;;
    SH3) [ "$2" = 3 ] && [ "$3" = expref ] && return 0; return 1 ;;
    SH4) [ "$2" = 4 ] && [ "$3" = revoked ] && return 0; return 1 ;;
    SH5) [ "$2" = 5 ] && [ "$3" = allow ] && return 0; return 1 ;;
    *) return 1 ;;
  esac
}

custody_ok() { # LOOKUP_JSON_FILE SECRET_ID -> rc 0 iff custody-clean
  local f="$1" s="$2"
  SIDV="$s" python3 - "$f" <<'PY'
import json, os, sys
try:
    raw = open(sys.argv[1]).read()
    d = json.loads(raw)["data"]
except Exception:
    sys.exit(1)
if "secret_id" in d:
    sys.exit(1)
if "secret_id_num_uses" not in d or "secret_id_ttl" not in d:
    sys.exit(1)
sid = os.environ.get("SIDV", "")
if sid and sid in raw:
    sys.exit(1)
try:
    if int(d.get("secret_id_num_uses")) < 1:
        sys.exit(1)
except Exception:
    sys.exit(1)
tt = d.get("secret_id_ttl")
if tt is None or tt == 0 or tt == "":
    sys.exit(1)
sys.exit(0)
PY
}

login_body() { # ROLE_ID [SECRET_ID] -> login JSON on stdout (secrets via env)
  if [ $# -ge 2 ]; then
    RID="$1" SIDV="$2" python3 -c 'import json,os,sys;sys.stdout.write(json.dumps({"role_id":os.environ["RID"],"secret_id":os.environ["SIDV"]}))'
  else
    RID="$1" python3 -c 'import json,os,sys;sys.stdout.write(json.dumps({"role_id":os.environ["RID"]}))'
  fi
}

# ------------------------------------------------------------- server helpers

nonce() { python3 -c 'import secrets;print("r60-"+secrets.token_hex(12))'; }

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
  [ -n "${SRV:-}" ] || return 0
  kill "$SRV" 2>/dev/null
  for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done
  kill -9 "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
  unset BAO_ADDR BAO_TOKEN
}

# --------------------------------------------------------------- bao helpers

role_put() { # ROLE k=v... -> rc of bao write (non-secret fields only)
  bao write "auth/approle/role/$1" "${@:2}" >/dev/null 2>"$D/err"
}

role_id() { # ROLE -> role_id on stdout; rc!=0 on failure
  local rid
  rid=$(bao read -format=json "auth/approle/role/$1/role-id" 2>/dev/null | jget data.role_id 2>/dev/null) || rid=""
  if [ -z "$rid" ]; then
    rid=$(bao write -format=json "auth/approle/role/$1/role-id" - </dev/null 2>/dev/null | jget data.role_id 2>/dev/null) || rid=""
  fi
  [ -n "$rid" ] || return 1
  printf '%s' "$rid"
}

gen_secret_id() { # ROLE -> G_SID; rc!=0 on failure
  local s
  s=$(printf '{}' | bao write -format=json "auth/approle/role/$1/secret-id" - 2>"$D/err" \
    | python3 -c 'import json,sys
try:
    sys.stdout.write(json.load(sys.stdin)["data"]["secret_id"])
except Exception:
    sys.exit(3)') || return 1
  G_SID="$s"
  [ -n "$G_SID" ]
}

gen_secret_id_acc() { # ROLE -> G_SID + G_ACC; rc!=0 on failure
  local pair
  pair=$(printf '{}' | bao write -format=json "auth/approle/role/$1/secret-id" - 2>"$D/err" \
    | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)["data"]
    sys.stdout.write(d["secret_id"] + "\t" + d["secret_id_accessor"])
except Exception:
    sys.exit(3)') || return 1
  G_SID=${pair%%$'\t'*}
  G_ACC=${pair#*$'\t'}
  [ -n "$G_SID" ] && [ -n "$G_ACC" ] && [ "$G_SID" != "$G_ACC" ]
}

login() { # ROLE_ID [SECRET_ID] -> rc of bao write; $D/lout + $D/lerr
  if [ $# -ge 2 ]; then
    login_body "$1" "$2" | bao write -format=json auth/approle/login - >"$D/lout" 2>"$D/lerr"
  else
    login_body "$1" | bao write -format=json auth/approle/login - >"$D/lout" 2>"$D/lerr"
  fi
}

lout_token() { # rc 0 iff $D/lout carries a non-empty auth.client_token
  local t
  t=$(jget auth.client_token < "$D/lout" 2>/dev/null) || return 1
  [ -n "$t" ]
}

acc_lookup() { # ROLE ACC -> lookup JSON on stdout; rc!=0 on failure
  ACCV="$2" python3 -c 'import json,os,sys;sys.stdout.write(json.dumps({"secret_id_accessor":os.environ["ACCV"]}))' \
    | bao write -format=json "auth/approle/role/$1/secret-id-accessor/lookup" - 2>"$D/err"
}

acc_destroy() { # ROLE ACC -> rc of bao write
  ACCV="$2" python3 -c 'import json,os,sys;sys.stdout.write(json.dumps({"secret_id_accessor":os.environ["ACCV"]}))' \
    | bao write "auth/approle/role/$1/secret-id-accessor/destroy" - >/dev/null 2>"$D/err"
}

# -------------------------------------------------------------------- the tests

RA=r60-t1; R2=r60-t2; R3=r60-t3; R4=r60-t4; R5=r60-t5
RV1="T1 ERROR not-run"; RV2="T2 ERROR not-run"; RV3="T3 ERROR not-run"
RV4="T4 ERROR not-run"; RV5="T5 ERROR not-run"

t1() {
  local aref=0 upd=0 ctok=0 rid et aslug bslug
  role_put "$RA" bind_secret_id=true token_bound_cidrs=127.0.0.1/32 \
    || { RV1="T1 ERROR role-create-rc=1"; return; }
  rid=$(role_id "$RA") || { RV1="T1 ERROR role-id-rc=1"; return; }
  # leg a: role_id-only login refused with the named error
  if login "$rid"; then
    aref=0
  else
    named_refusal "$D/lerr" 'missing secret_id' && aref=1
    et=$(errtext "$D/lerr" | slug); aslug="$et"
  fi
  # leg b: bind_secret_id=false on the same role -> accepted (cidr constraint)
  if role_put "$RA" bind_secret_id=false; then upd=1; else upd=0; fi
  et=$(errtext "$D/err" | slug); bslug="$et"
  # leg c: the same role_id-only body now logs in (token issued)
  if login "$rid" && lout_token; then ctok=1; fi
  shim_flip "$SHIM" 1 ctok && ctok=0
  if verdict_all "$aref" "$upd" "$ctok"; then
    RV1="T1 HOLDS aref=$aref upd=$upd ctok=$ctok"
  else
    RV1="T1 BROKEN aref=$aref upd=$upd ctok=$ctok aerr=$aslug berr=$bslug"
  fi
}

t2() {
  local first=0 ref2=0 fresh=0 rid et e2slug
  role_put "$R2" secret_id_num_uses=1 || { RV2="T2 ERROR role-create-rc=1"; return; }
  rid=$(role_id "$R2") || { RV2="T2 ERROR role-id-rc=1"; return; }
  gen_secret_id "$R2" || { RV2="T2 ERROR sid-gen-rc=1"; return; }
  if login "$rid" "$G_SID" && lout_token; then first=1; fi
  if login "$rid" "$G_SID"; then
    ref2=0
  else
    named_refusal "$D/lerr" 'invalid role or secret ID' && ref2=1
    et=$(errtext "$D/lerr" | slug); e2slug="$et"
  fi
  gen_secret_id "$R2" || { RV2="T2 ERROR sid2-gen-rc=1"; return; }
  if login "$rid" "$G_SID" && lout_token; then fresh=1; fi
  shim_flip "$SHIM" 2 ref2 && ref2=0
  if verdict_all "$first" "$ref2" "$fresh"; then
    RV2="T2 HOLDS first=$first ref2=$ref2 fresh=$fresh"
  else
    RV2="T2 BROKEN first=$first ref2=$ref2 fresh=$fresh err2=$e2slug"
  fi
}

t3() {
  local imm=0 expref=0 fresh=0 rid et eslug
  role_put "$R3" secret_id_ttl=1s || { RV3="T3 ERROR role-create-rc=1"; return; }
  rid=$(role_id "$R3") || { RV3="T3 ERROR role-id-rc=1"; return; }
  # Each attempt uses a freshly generated secret_id logged in immediately;
  # bounded retries absorb CLI latency jitter inside the 1 s TTL without
  # changing the mechanic (a fresh secret_id logs in; an expired one does not).
  local _t
  for _t in 1 2 3; do
    gen_secret_id "$R3" || { RV3="T3 ERROR sid-gen-rc=1"; return; }
    if login "$rid" "$G_SID" && lout_token; then imm=1; break; fi
  done
  sleep 3
  if login "$rid" "$G_SID"; then
    expref=0
  else
    named_refusal "$D/lerr" 'invalid role or secret ID' && expref=1
    et=$(errtext "$D/lerr" | slug); eslug="$et"
  fi
  for _t in 1 2 3; do
    gen_secret_id "$R3" || { RV3="T3 ERROR sid2-gen-rc=1"; return; }
    if login "$rid" "$G_SID" && lout_token; then fresh=1; break; fi
  done
  shim_flip "$SHIM" 3 expref && expref=0
  if verdict_all "$imm" "$expref" "$fresh"; then
    RV3="T3 HOLDS imm=$imm expref=$expref fresh=$fresh"
  else
    RV3="T3 BROKEN imm=$imm expref=$expref fresh=$fresh err=$eslug"
  fi
}

t4() {
  local meta=0 cust=0 revoked=0 rid et eslug nu tt
  role_put "$R4" secret_id_num_uses=3 secret_id_ttl=600s || { RV4="T4 ERROR role-create-rc=1"; return; }
  rid=$(role_id "$R4") || { RV4="T4 ERROR role-id-rc=1"; return; }
  gen_secret_id_acc "$R4" || { RV4="T4 ERROR sid-gen-rc=1"; return; }
  acc_lookup "$R4" "$G_ACC" > "$D/lookup.json" || { RV4="T4 ERROR lookup-rc=1"; return; }
  nu=$(jget data.secret_id_num_uses < "$D/lookup.json" 2>/dev/null) || nu=""
  tt=$(jget data.secret_id_ttl < "$D/lookup.json" 2>/dev/null) || tt=""
  [ -n "$nu" ] && [ -n "$tt" ] && meta=1
  custody_ok "$D/lookup.json" "$G_SID" && cust=1
  acc_destroy "$R4" "$G_ACC" || { RV4="T4 ERROR destroy-rc=1"; return; }
  if login "$rid" "$G_SID"; then
    revoked=0
  else
    named_refusal "$D/lerr" 'invalid role or secret ID' && revoked=1
    et=$(errtext "$D/lerr" | slug); eslug="$et"
  fi
  shim_flip "$SHIM" 4 revoked && revoked=0
  if verdict_all "$meta" "$cust" "$revoked"; then
    RV4="T4 HOLDS meta=$meta cust=$cust revoked=$revoked"
  else
    RV4="T4 BROKEN meta=$meta cust=$cust revoked=$revoked err=$eslug"
  fi
}

t5() {
  local deny=0 upd=0 allow=0 rid et dslug
  role_put "$R5" secret_id_bound_cidrs=10.0.0.0/8 || { RV5="T5 ERROR role-create-rc=1"; return; }
  rid=$(role_id "$R5") || { RV5="T5 ERROR role-id-rc=1"; return; }
  gen_secret_id "$R5" || { RV5="T5 ERROR sid-gen-rc=1"; return; }
  if login "$rid" "$G_SID"; then
    deny=0
  else
    named_refusal "$D/lerr" 'unauthorized by CIDR|CIDR restrictions' && deny=1
    et=$(errtext "$D/lerr" | slug); dslug="$et"
  fi
  if role_put "$R5" secret_id_bound_cidrs=127.0.0.1/32; then upd=1; else upd=0; fi
  # frozen POP: "the same login succeeds" — same role_id+secret_id body after the rebind
  if login "$rid" "$G_SID" && lout_token; then allow=1; fi
  shim_flip "$SHIM" 5 allow && allow=0
  if verdict_all "$deny" "$upd" "$allow"; then
    RV5="T5 HOLDS deny=$deny upd=$upd allow=$allow"
  else
    RV5="T5 BROKEN deny=$deny upd=$upd allow=$allow err=$dslug"
  fi
}

# ------------------------------------------------------------------ selftest

not() { ! "$@"; }
expect_eq() { [ "$1" = "$2" ]; }

run_selftest() { # GATE_SRC WORK -> rc 0 PASS / 1 FAIL / 2 SETUP
  local GS="$1" W="${2:-}"
  command -v python3 >/dev/null 2>&1 || { echo "APPROLE_SELFTEST: SETUP no python3"; return 2; }
  local BASE="${W:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecTrial/selftest-work}"
  mkdir -p "$BASE" 2>/dev/null || { echo "APPROLE_SELFTEST: SETUP work dir not creatable"; return 2; }
  D=$(mktemp -d "$BASE/approle-selftest.XXXXXX") || { echo "APPROLE_SELFTEST: SETUP work dir not writable"; return 2; }
  ST_GSRC="$GS"; ST_D="$D"; ST_BASH="$(command -v bash)"

  STC=0; STF=0
  ck() { local id="$1"; shift; STC=$((STC+1)); if ! "$@"; then STF=$((STF+1)); printf 'FINDING %s\n' "$id"; fi }

  # ---- fixture files (no secrets, no network, no bao) ----
  printf 'Error making API request.\n\nURL: POST http://127.0.0.1:1/v1/auth/approle/login\nCode: 400. Errors:\n\n* invalid role or secret ID\n' > "$D/err1"
  : > "$D/err-empty"
  printf '%s' '{"data":{"role_id":"RID-FIXTURE-1"},"auth":{"client_token":"TOK-FIXTURE-1"}}' > "$D/login.json"
  printf '%s' '{"data":{"secret_id_accessor":"ACC-FIXTURE-1","secret_id_num_uses":3,"secret_id_ttl":600,"cidr_list":[],"creation_time":"2026-11-07T00:00:00Z","expiration_time":"2026-11-08T00:00:00Z","last_updated_time":"2026-11-07T00:00:00Z","metadata":{},"token_bound_cidrs":[]}}' > "$D/lookup-ok.json"
  printf '%s' '{"data":{"secret_id_accessor":"ACC-FIXTURE-1","secret_id":"SID-FIXTURE-1","secret_id_num_uses":3,"secret_id_ttl":600}}' > "$D/lookup-badkey.json"
  printf '%s' '{"data":{"secret_id_accessor":"ACC-FIXTURE-1","note":"SID-FIXTURE-1","secret_id_num_uses":3,"secret_id_ttl":600}}' > "$D/lookup-leak.json"
  printf '%s' '{"data":{"secret_id_accessor":"ACC-FIXTURE-1","secret_id_ttl":600}}' > "$D/lookup-nometa.json"

  # ---- process-level cases (exit codes) ----
  st_no_bao() {
    local out rc
    out=$(env -i PATH="$ST_D/nobin" "$ST_BASH" "$ST_GSRC" --work "$ST_D/w-nobao" 2>&1); rc=$?
    NOBAO_RC=$rc; NOBAO_OUT="$out"
    [ "$rc" = 2 ]
  }
  ck F-NOBAO-RC st_no_bao
  ck F-NOBAO-LINE expect_eq "$NOBAO_OUT" "OPENBAO_APPROLE_TRIAL: SETUP no bao on PATH"
  no_trial_line() { ! printf '%s\n' "$NOBAO_OUT" | grep -q '^TRIAL '; }
  ck F-NOBAO-NOTRIAL no_trial_line

  st_bad_work() {
    mkdir -p "$ST_D/fakebin"
    printf '#!/bin/sh\necho "OpenBao v0.0.0-selftest ()"\n' > "$ST_D/fakebin/bao"
    chmod +x "$ST_D/fakebin/bao"
    local t p
    for t in python3 setpriv ss; do
      p=$(command -v "$t") || return 2
      ln -sf "$p" "$ST_D/fakebin/$t"
    done
    : > "$ST_D/afile"
    local out rc
    out=$(env -i PATH="$ST_D/fakebin" "$ST_BASH" "$ST_GSRC" --work "$ST_D/afile" 2>&1); rc=$?
    BADWORK_RC=$rc; BADWORK_OUT="$out"
    [ "$rc" = 2 ]
  }
  ck F-BADWORK-RC st_bad_work
  ck F-BADWORK-LINE expect_eq "$BADWORK_OUT" "OPENBAO_APPROLE_TRIAL: SETUP work dir not creatable"

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
        SH1) [ "$flips" = 1 ] && [ "$ft" = 1 ] && [ "$ff" = ctok ] || return 1 ;;
        SH2) [ "$flips" = 1 ] && [ "$ft" = 2 ] && [ "$ff" = ref2 ] || return 1 ;;
        SH3) [ "$flips" = 1 ] && [ "$ft" = 3 ] && [ "$ff" = expref ] || return 1 ;;
        SH4) [ "$flips" = 1 ] && [ "$ft" = 4 ] && [ "$ff" = revoked ] || return 1 ;;
        SH5) [ "$flips" = 1 ] && [ "$ft" = 5 ] && [ "$ff" = allow ] || return 1 ;;
        *) [ "$flips" = 0 ] || return 1 ;;
      esac
    done
    return 0
  }
  ck F-SHIM-MATRIX shim_matrix

  # ---- verdict mapping ----
  ck F-VERDICT-ALL verdict_all 1 1 1
  ck F-VERDICT-ALL3 verdict_all 1 1 1 1
  ck F-VERDICT-TWO verdict_all 1 1
  ck F-VERDICT-PART1 not verdict_all 1 1 0
  ck F-VERDICT-PART2 not verdict_all 1 0 1
  ck F-VERDICT-PART3 not verdict_all 0 1 1
  ck F-VERDICT-NONE not verdict_all

  # ---- exit-code and line mapping ----
  ck F-RCFOR-HOLD expect_eq "$(rc_for 5 0 0)" 0
  ck F-RCFOR-BROKEN expect_eq "$(rc_for 4 1 0)" 1
  ck F-RCFOR-ERROR expect_eq "$(rc_for 3 0 2)" 2
  ck F-RCFOR-ERRWINS expect_eq "$(rc_for 5 0 1)" 2
  ck F-SUM-HOLD expect_eq "$(summary_line HOLDS 5 0 0 v2.7.2)" "OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
  ck F-SUM-BROKEN expect_eq "$(summary_line BROKEN 4 1 0 v2.7.2)" "OPENBAO_APPROLE_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"
  ck F-SUM-ERROR expect_eq "$(summary_line ERROR 3 0 2 v2.7.2)" "OPENBAO_APPROLE_TRIAL: ERROR holds=3 broken=0 error=2 bao=v2.7.2"
  ck F-COUNT-ALLHOLD expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 HOLDS b=2' 'T3 HOLDS c=3' 'T4 HOLDS d=4' 'T5 HOLDS e=5')" "5 0 0 HOLDS 0"
  ck F-COUNT-ONEBROKEN expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 BROKEN b=2' 'T3 HOLDS c=3' 'T4 HOLDS d=4' 'T5 HOLDS e=5')" "4 1 0 BROKEN 1"
  ck F-COUNT-ONEERROR expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 HOLDS b=2' 'T3 ERROR c=3' 'T4 HOLDS d=4' 'T5 HOLDS e=5')" "4 0 1 ERROR 2"
  ck F-COUNT-MIXED expect_eq "$(countmap 'T1 HOLDS a=1' 'T2 BROKEN b=2' 'T3 ERROR c=3' 'T4 HOLDS d=4' 'T5 HOLDS e=5')" "3 1 1 ERROR 2"

  # ---- error-text extraction and refusal matching ----
  ck F-ERRTEXT-EXTRACT expect_eq "$(errtext "$D/err1")" "invalid role or secret ID"
  ck F-SLUG-STABLE expect_eq "$(errtext "$D/err1" | slug)" "invalid-role-or-secret-id"
  ck F-NAMED-REFUSAL-POS named_refusal "$D/err1" 'invalid role or secret ID'
  ck F-NAMED-REFUSAL-NEG1 not named_refusal "$D/err1" 'missing secret_id'
  ck F-NAMED-REFUSAL-NEG2 not named_refusal "$D/err1" 'constraint'
  ck F-ERRTEXT-EMPTY expect_eq "$(errtext "$D/err-empty")" ""

  # ---- JSON field extraction ----
  ck F-JGET-DATA expect_eq "$(jget data.role_id < "$D/login.json")" "RID-FIXTURE-1"
  ck F-JGET-AUTH expect_eq "$(jget auth.client_token < "$D/login.json")" "TOK-FIXTURE-1"
  ck F-JGET-MISSING not jget data.missing < "$D/login.json"
  ck F-JHAS-POS jhas auth.client_token < "$D/login.json"
  ck F-JHAS-NEG not jhas data.nope < "$D/login.json"

  # ---- accessor custody predicate ----
  ck F-CUSTODY-CLEAN custody_ok "$D/lookup-ok.json" "SID-FIXTURE-1"
  ck F-CUSTODY-KEY not custody_ok "$D/lookup-badkey.json" "SID-FIXTURE-1"
  ck F-CUSTODY-LEAK not custody_ok "$D/lookup-leak.json" "SID-FIXTURE-1"
  ck F-CUSTODY-META not custody_ok "$D/lookup-nometa.json" "SID-FIXTURE-1"

  # ---- login body builder (secrets via env, never argv) ----
  ck F-BODY-PAIR-RID expect_eq "$(login_body RID-FIXTURE-1 SID-FIXTURE-1 | jget role_id)" "RID-FIXTURE-1"
  ck F-BODY-PAIR-SID expect_eq "$(login_body RID-FIXTURE-1 SID-FIXTURE-1 | jget secret_id)" "SID-FIXTURE-1"
  body_no_sid() { ! login_body "RID-FIXTURE-1" | jget secret_id; }
  ck F-BODY-ROLEONLY body_no_sid

  # ---- the script itself carries no secret-shaped literal ----
  no_secret_shape() { ! grep -nE 'hvs\.|hvb\.' "$ST_GSRC"; }
  ck F-NOSECRETSHAPE no_secret_shape

  rm -rf -- "$D"
  D=""
  if [ "$STF" -eq 0 ]; then
    echo "APPROLE_SELFTEST: PASS (cases=$STC)"
    return 0
  fi
  echo "APPROLE_SELFTEST: FAIL (cases=$STC failed=$STF)"
  return 1
}

# ------------------------------------------------------------------- real run

if [ "$MODE" = selfworker ]; then
  run_selftest "$SELF" "$WORK"
  exit $?
fi

command -v bao >/dev/null 2>&1 || { echo "OPENBAO_APPROLE_TRIAL: SETUP no bao on PATH"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "OPENBAO_APPROLE_TRIAL: SETUP no python3"; exit 2; }
command -v setpriv >/dev/null 2>&1 || { echo "OPENBAO_APPROLE_TRIAL: SETUP no setpriv"; exit 2; }
command -v ss >/dev/null 2>&1 || { echo "OPENBAO_APPROLE_TRIAL: SETUP no ss"; exit 2; }
case "$SHIM" in
  ""|SH1|SH2|SH3|SH4|SH5) ;;
  *) echo "OPENBAO_APPROLE_TRIAL: SETUP invalid KAGI_APPROLE_SHIM"; exit 2 ;;
esac
BASE="${WORK:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecTrial/trial-work}"
mkdir -p "$BASE" 2>/dev/null || { echo "OPENBAO_APPROLE_TRIAL: SETUP work dir not creatable"; exit 2; }
D=$(mktemp -d "$BASE/openbao-approle-trial.XXXXXX") || { echo "OPENBAO_APPROLE_TRIAL: SETUP work dir not writable"; exit 2; }
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
[ -n "$VER" ] || { echo "OPENBAO_APPROLE_TRIAL: SETUP bao version unreadable"; exit 2; }

start_server || { echo "OPENBAO_APPROLE_TRIAL: SETUP dev server did not start"; exit 2; }
bao auth enable approle >/dev/null 2>"$D/err" || { echo "OPENBAO_APPROLE_TRIAL: SETUP approle enable failed"; exit 2; }

t1
t2
t3
t4
t5

for line in "$RV1" "$RV2" "$RV3" "$RV4" "$RV5"; do
  echo "TRIAL $line"
done
read H B E S RC < <(countmap "$RV1" "$RV2" "$RV3" "$RV4" "$RV5")
echo "$(summary_line "$S" "$H" "$B" "$E" "$VER")"
stop_server
exit "$RC"
