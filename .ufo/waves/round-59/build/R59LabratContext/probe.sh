#!/usr/bin/env bash
# R59LabratContext - bounded empirical probe: convergent transit keys and rewrap.
# Read-only on the lane; all work in this scratch dir. Throwaway dev server only.
set -u
umask 077
D="$1"
mkdir -p "$D" || exit 2
T="$D/transcript.txt"
: >"$T"
SRV=""
cleanup() {
  if [ -n "$SRV" ]; then
    kill "$SRV" 2>/dev/null
    for _ in $(seq 1 50); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.1; done
    kill -9 "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; SRV=""
  fi
}
trap 'cleanup' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# ambient credential env must not leak into the probe
while IFS= read -r v; do [ -n "$v" ] && unset "$v"; done < <(env | sed -n 's/^\(BAO_[A-Z_]*\)=.*/\1/p; s/^\(VAULT_[A-Z_]*\)=.*/\1/p')

export HOME="$D/home"; mkdir -p "$HOME"
PORT=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
ROOT=$(python3 -c 'import secrets;print(secrets.token_hex(16))')
BAO_DEV_ROOT_TOKEN_ID="$ROOT" setpriv --pdeathsig KILL bao server -dev \
  -dev-listen-address="127.0.0.1:$PORT" -dev-no-store-token >"$D/server.log" 2>&1 &
SRV=$!
ok=0
for _ in $(seq 1 300); do
  kill -0 "$SRV" 2>/dev/null || break
  if ss -Hltnp "sport = :$PORT" 2>/dev/null | grep -q "pid=$SRV,"; then ok=1; break; fi
  sleep 0.1
done
[ "$ok" = 1 ] || { echo "SETUP dev server did not bind" >>"$T"; echo "SETUP"; exit 2; }
export BAO_ADDR="http://127.0.0.1:$PORT" BAO_TOKEN="$ROOT"
for _ in $(seq 1 100); do bao status >/dev/null 2>&1 && break; sleep 0.1; done
bao status >/dev/null 2>&1 || { echo "SETUP dev server not ready" >>"$T"; echo "SETUP"; exit 2; }
echo "SETUP server pid=$SRV port=$PORT version=$(bao version | awk '{print $2; exit}')" >>"$T"

b64() { printf '%s' "$1" | base64 -w0; }

# leg NAME -- CMD... : records rc, stdout, stderr with values redacted by policy (no
# token ever reaches a command line: BAO_TOKEN is env-only).
LEG_N=0
leg() {
  local name="$1"; shift
  LEG_N=$((LEG_N + 1))
  local out err rc
  out=$("$@" 2>"$D/err"); rc=$?
  err=$(cat "$D/err")
  {
    echo "=== $name"
    echo "CMD $*"
    echo "RC $rc"
    echo "OUTBEGIN"
    printf '%s\n' "$out"
    echo "OUTEND"
    echo "ERRBEGIN"
    printf '%s\n' "$err"
    echo "ERREND"
  } >>"$T"
  LAST_OUT="$out"; LAST_ERR="$err"; LAST_RC=$rc
}

ctof() { printf '%s\n' "$1" | awk '$1=="ciphertext"{print $2; exit}'; }
prefix() { local c; c=$(ctof "$1"); [ -n "$c" ] && printf '%s' "$c" | cut -d: -f1,2 || echo none; }

echo "--- phase A: enable transit, key creation" >>"$T"
leg "enable-transit" bao secrets enable transit
CTX_A=$(b64 'r59-context-alpha')
CTX_B=$(b64 'r59-context-beta')
PT=$(b64 'r59-probe-plaintext')

# convergent without derived: does 2.7.2 demand derived?
leg "key-conv-noderived" bao write transit/keys/conv convergent_encryption=true
leg "read-key-conv-noderived" bao read transit/keys/conv
# derive requirement probe: if creation failed, create with derived too (separate key names)
leg "key-conv-derived" bao write transit/keys/convd derived=true convergent_encryption=true
leg "key-plain" bao write -f transit/keys/plain
leg "key-derived-plain" bao write transit/keys/dv derived=true

echo "--- phase B: encryption and convergence sanity" >>"$T"
leg "enc-convd-a1" bao write transit/encrypt/convd plaintext="$PT" context="$CTX_A"
C1="$LAST_OUT"; C1_PREFIX=$(prefix "$C1")
leg "enc-convd-a2" bao write transit/encrypt/convd plaintext="$PT" context="$CTX_A"
C2="$LAST_OUT"; C2_PREFIX=$(prefix "$C2")
leg "enc-convd-b" bao write transit/encrypt/convd plaintext="$PT" context="$CTX_B"
C3="$LAST_OUT"; C3_PREFIX=$(prefix "$C3")
C1_CT=$(ctof "$C1")
C2_CT=$(ctof "$C2")
C3_CT=$(ctof "$C3")
{
  echo "FACT convergent-same-context-identical=$([ "$C1_CT" = "$C2_CT" ] && echo yes || echo no)"
  echo "FACT convergent-diff-context-different=$([ "$C1_CT" != "$C3_CT" ] && echo yes || echo no)"
  echo "FACT prefix-ct1=$C1_PREFIX prefix-ct3=$C3_PREFIX"
} >>"$T"

echo "--- phase C: leg (a) rewrap without context" >>"$T"
leg "L_a-rewrap-no-context" bao write transit/rewrap/convd ciphertext="$C1_CT"
A_PREFIX=$(prefix "$LAST_OUT"); A_RC=$LAST_RC

echo "--- phase D: leg (b) rewrap with wrong context" >>"$T"
leg "L_b-rewrap-wrong-context" bao write transit/rewrap/convd ciphertext="$C1_CT" context="$CTX_B"
B_PREFIX=$(prefix "$LAST_OUT"); B_RC=$LAST_RC

echo "--- phase E: leg (c) rewrap with right context" >>"$T"
leg "L_c-rewrap-right-context" bao write transit/rewrap/convd ciphertext="$C1_CT" context="$CTX_A"
C_PREFIX=$(prefix "$LAST_OUT"); C_RC=$LAST_RC
REWRAP_CT=$(ctof "$LAST_OUT")
leg "L_c-decrypt-rewrapped" bao write transit/decrypt/convd ciphertext="$REWRAP_CT" context="$CTX_A"

echo "--- phase F: rotate, leg (d0) migrate v1 -> v2" >>"$T"
leg "rotate" bao write -f transit/keys/convd/rotate
leg "read-key-after-rotate" bao read transit/keys/convd
leg "enc-after-rotate" bao write transit/encrypt/convd plaintext="$PT" context="$CTX_A"
V2_CT=$(ctof "$LAST_OUT")
V2_PREFIX=$(prefix "$LAST_OUT")
leg "L_d0-rewrap-v1-after-rotate" bao write transit/rewrap/convd ciphertext="$C1_CT" context="$CTX_A"
D0_PREFIX=$(prefix "$LAST_OUT"); D0_RC=$LAST_RC
D0_CT=$(ctof "$LAST_OUT")
leg "L_d0-decrypt-migrated" bao write transit/decrypt/convd ciphertext="$D0_CT" context="$CTX_A"

echo "--- phase G: raise min_decryption_version, leg (d)" >>"$T"
leg "set-mdv-2" bao write transit/keys/convd/config min_decryption_version=2
leg "read-key-mdv2" bao read transit/keys/convd
leg "L_d1-rewrap-excluded-v1" bao write transit/rewrap/convd ciphertext="$C1_CT" context="$CTX_A"
D1_PREFIX=$(prefix "$LAST_OUT"); D1_RC=$LAST_RC
leg "L_d2-rewrap-v2-allowed" bao write transit/rewrap/convd ciphertext="$V2_CT" context="$CTX_A"
D2_PREFIX=$(prefix "$LAST_OUT"); D2_RC=$LAST_RC
leg "L_d2b-rewrap-excluded-v1-wrong-context" bao write transit/rewrap/convd ciphertext="$C1_CT" context="$CTX_B"
leg "L_d2c-rewrap-excluded-v1-no-context" bao write transit/rewrap/convd ciphertext="$C1_CT"
leg "L_d3-decrypt-excluded-v1" bao write transit/decrypt/convd ciphertext="$C1_CT" context="$CTX_A"
leg "lower-mdv-1" bao write transit/keys/convd/config min_decryption_version=1
leg "L_d4-decrypt-v1-after-lower" bao write transit/decrypt/convd ciphertext="$C1_CT" context="$CTX_A"

echo "--- phase H: isolation - plain and derived-non-convergent keys" >>"$T"
leg "enc-plain-1" bao write transit/encrypt/plain plaintext="$PT"
P_CT=$(ctof "$LAST_OUT")
leg "enc-plain-2" bao write transit/encrypt/plain plaintext="$PT"
P2_CT=$(ctof "$LAST_OUT")
leg "L_e-rewrap-plain-no-context" bao write transit/rewrap/plain ciphertext="$P_CT"
E_PREFIX=$(prefix "$LAST_OUT"); E_RC=$LAST_RC
leg "L_e2-rewrap-plain-with-context" bao write transit/rewrap/plain ciphertext="$P_CT" context="$CTX_A"
leg "enc-derived-plain-1" bao write transit/encrypt/dv plaintext="$PT" context="$CTX_A"
DV_CT=$(ctof "$LAST_OUT")
leg "enc-derived-plain-2" bao write transit/encrypt/dv plaintext="$PT" context="$CTX_A"
DV2_CT=$(ctof "$LAST_OUT")
leg "L_f-rewrap-derived-no-context" bao write transit/rewrap/dv ciphertext="$DV_CT"
F_PREFIX=$(prefix "$LAST_OUT"); F_RC=$LAST_RC
leg "L_f2-rewrap-derived-right-context" bao write transit/rewrap/dv ciphertext="$DV_CT" context="$CTX_A"
F2_PREFIX=$(prefix "$LAST_OUT"); F2_RC=$LAST_RC
leg "L_f3-decrypt-derived-wrong-context" bao write transit/decrypt/dv ciphertext="$DV_CT" context="$CTX_B"

echo "--- phase I: rotation-version interaction for convergent key" >>"$T"
# after rotate + mdv lowered back to 1, rewrap again to confirm determinism of rewrap output
leg "L_g-rewrap-v1-again" bao write transit/rewrap/convd ciphertext="$C1_CT" context="$CTX_A"
G_PREFIX=$(prefix "$LAST_OUT"); G_RC=$LAST_RC
G_CT=$(ctof "$LAST_OUT")
{
  echo "FACT rewrap-deterministic-after-rotate=$([ "$G_CT" = "$D0_CT" ] && echo yes || echo no)"
  echo "FACT rewrap-v2-equals-fresh-encrypt=$([ "$D0_CT" = "$V2_CT" ] && echo yes || echo no)"
  echo "FACT nonconvergent-plain-encrypt-twice-identical=$([ "$P_CT" = "$P2_CT" ] && echo yes || echo no)"
  echo "FACT derived-nonconvergent-encrypt-twice-identical=$([ "$DV_CT" = "$DV2_CT" ] && echo yes || echo no)"
  echo "SUMMARY"
  echo "leg_a rc=$A_RC prefix=$A_PREFIX"
  echo "leg_b rc=$B_RC prefix=$B_PREFIX"
  echo "leg_c rc=$C_RC prefix=$C_PREFIX"
  echo "leg_d0 rc=$D0_RC prefix=$D0_PREFIX"
  echo "leg_d1 rc=$D1_RC prefix=$D1_PREFIX"
  echo "leg_d2 rc=$D2_RC prefix=$D2_PREFIX"
  echo "leg_e rc=$E_RC prefix=$E_PREFIX"
  echo "leg_f rc=$F_RC prefix=$F_PREFIX"
  echo "leg_f2 rc=$F2_RC prefix=$F2_PREFIX"
  echo "leg_g rc=$G_RC prefix=$G_PREFIX"
} >>"$T"
echo "DONE" >>"$T"
echo "DONE"
