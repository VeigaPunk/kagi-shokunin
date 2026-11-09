#!/usr/bin/env bash
# Replica by R71ExecReplica, written from plans/round-71.md + the knowledge entry's
# Measured section alone, without reading the reference trial bytes.
# T6 notafter-truncate, T7 nondefault-crl, T8 ocsp-unauth, T9 revoke-with-key.
# Output: TRIAL T<n> HOLDS|BROKEN|ERROR <detail>; final OPENBAO_PKI_ISSUER_TRIAL: line.
# Exit 0 all HOLDS, 1 any BROKEN (no ERROR), 2 SETUP / ERROR.
set -u

usage() {
  cat <<'U'
usage: openbao-pki-issuer-trial.sh [--work DIR] [--evidence DIR] [--help]
Runs four OpenBao PKI issuer/revocation tests (T6 notafter-truncate, T7 nondefault-crl,
T8 ocsp-unauth, T9 revoke-with-key) against a throwaway dev server on 127.0.0.1.
--work names the scratch parent (default ${TMPDIR:-/tmp}); --evidence names the dir for
public artifacts (certs, CRLs, DER OCSP responses). Everything in --work is removed on exit.
U
}
WORK="${TMPDIR:-/tmp}"; EVD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) WORK=${2:?--work needs a directory}; shift 2;;
    --evidence) EVD=${2:?--evidence needs a directory}; shift 2;;
    --help|-h) usage; exit 0;;
    *) usage >&2; exit 64;;
  esac
done

H=0; B=0; E=0; BV=none; OV=none
fin() { echo "OPENBAO_PKI_ISSUER_TRIAL: $1 holds=$H broken=$B error=$E bao=$BV openssl=$OV"; }
setup() { echo "SETUP $1" >&2; fin SETUP; exit 2; }

command -v bao >/dev/null 2>&1 || setup bao-missing
command -v openssl >/dev/null 2>&1 || setup openssl-missing
command -v python3 >/dev/null 2>&1 || setup python3-missing
BV=$(bao version 2>/dev/null | awk '{print $2}'); OV=$(openssl version 2>/dev/null | awk '{print $2}')
command -v setpriv >/dev/null 2>&1 || setup setpriv-missing
command -v ss >/dev/null 2>&1 || setup ss-missing
umask 077

# Scrub every caller VAULT_*/BAO_* variable.
for v in $(env | sed -n 's/^\(\(VAULT\|BAO\)_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done

mkdir -p "$WORK" || setup work-dir
[ -z "$EVD" ] && EVD="$WORK/evidence"
mkdir -p "$EVD" || setup evidence-dir
S=$(mktemp -d "$WORK/kagi-issuer-trial.XXXXXX") || setup mktemp
case "$S" in "$WORK"/kagi-issuer-trial.*) ;; *) setup scratch-path;; esac
SP=""
cleanup() { [ -n "$SP" ] && { kill "$SP" 2>/dev/null; wait "$SP" 2>/dev/null; }; rm -rf -- "$S"; }
trap cleanup EXIT
trap 'exit 130' INT TERM HUP
export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"

start_server() { # sets SP, BAO_ADDR, BAO_TOKEN; 0 on success
  local port tok ok
  for _ in 1 2 3; do
    port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()') || return 1
    tok="r71-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
    BAO_DEV_ROOT_TOKEN_ID="$tok" setpriv --pdeathsig KILL bao server -dev -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
    SP=$!
    ok=0
    for _ in $(seq 1 300); do
      kill -0 "$SP" 2>/dev/null || break
      if ss -Hltnp "sport = :$port" 2>/dev/null | grep -q "pid=$SP,"; then ok=1; break; fi
      sleep 0.1
    done
    if [ "$ok" = 1 ]; then
      export BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$tok"
      for _ in $(seq 1 100); do bao status >/dev/null 2>&1 && return 0; sleep 0.1; done
    fi
    kill "$SP" 2>/dev/null; wait "$SP" 2>/dev/null; SP=""
    unset BAO_ADDR BAO_TOKEN
  done
  return 1
}
start_server || setup dev-server-not-ready

q() { bao "$@" >/dev/null 2>&1; }
jget() { python3 -c 'import json,sys
d=json.load(open(sys.argv[1])).get("data") or {}
v=d.get(sys.argv[2])
print("" if v is None else v)' "$1" "$2" 2>/dev/null; }
cert_of() { jget "$1" certificate; }
verdict() { # id state detail
  echo "TRIAL $1 $2 $3"
  case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac
}
epoch() { # pemfile startdate|enddate -> epoch seconds
  local d; d=$(openssl x509 -in "$1" -noout -$2 2>/dev/null | cut -d= -f2) || return 1
  [ -n "$d" ] || return 1
  date -u -d "$d" +%s 2>/dev/null
}
flat() { echo "$1" | tr -d ':' | tr 'a-f' 'A-F'; }
crl_lists() { # crlfile flatserial -> 0 if listed
  openssl crl -in "$1" -noout -text 2>/dev/null | grep -q "Serial Number: $2\$"
}
issue() { # role cn ttl jsonfile
  bao write -format=json "pki/issue/$1" common_name="$2" ttl="$3" > "$4" 2>/dev/null
}
issuer_crl() { # issuer-id crl-pem-out ; fetch pki/issuer/<id>/crl (READ, not write)
  bao read -format=json "pki/issuer/$1/crl" > "$S/crl.json" 2>/dev/null || return 1
  jget "$S/crl.json" crl > "$2"
  [ -s "$2" ]
}
issuer_cert() { # issuer-id pem-out
  bao read -format=json "pki/issuer/$1" > "$S/iss.json" 2>/dev/null || return 1
  cert_of "$S/iss.json" > "$2"
  [ -s "$2" ]
}
default_id() { # -> pki/config/issuers default
  bao read -format=json pki/config/issuers > "$S/cfg.json" 2>/dev/null || return 1
  local d; d=$(jget "$S/cfg.json" default)
  [ -n "$d" ] || return 1
  echo "$d"
}

q secrets enable pki || setup pki-enable
q secrets tune -max-lease-ttl=87600h pki || setup pki-tune
q write pki/config/crl ocsp_disable=false || setup crl-config

# ================= T6 notafter-truncate =================
# short (2h) issuer with leaf_not_after_behavior=truncate; a 10h leaf request is
# issued clipped to the issuer's NotAfter. HOLDS iff leaf notAfter == issuer notAfter.
t6() {
  bao write -format=json pki/root/generate/internal common_name=root.r71.test ttl=2h issuer_name=r71short >"$S/t6-root.json" 2>/dev/null || { echo setup; return; }
  cert_of "$S/t6-root.json" > "$EVD/t6-issuer.pem"
  local ref; ref=$(jget "$S/t6-root.json" issuer_id)
  [ -n "$ref" ] || { echo setup; return; }
  # Single-field POST overwrite (S170: POST does not update only the provided
  # fields — the observed side effect is issuer_name wiped; issue below goes by
  # the issuer ID, which survives, so the check is unaffected). The truncate
  # setting itself is what the read-back confirms. A failed write is NOT a
  # setup fault: under SH6 the write loses its only operand, the issuer keeps
  # the default `err`, and the 10h leaf is then refused — the falsifier's
  # own effect, which must read BROKEN, not ERROR. Proceed regardless.
  bao write "pki/issuer/$ref" leaf_not_after_behavior=truncate >"$S/t6-w.out" 2>/dev/null
  local rb; bao read -format=json "pki/issuer/$ref" > "$S/t6-iss2.json" 2>/dev/null; rb=$(jget "$S/t6-iss2.json" leaf_not_after_behavior)
  # Role points at the issuer by id (the wiped name no longer resolves).
  q write pki/roles/t6 allowed_domains=r71.test allow_subdomains=true max_ttl=87600h issuer_ref="$ref" || { echo setup; return; }
  issue t6 leaf.r71.test 10h "$S/t6-leaf.json" || { echo broken; return; }
  cert_of "$S/t6-leaf.json" > "$EVD/t6-leaf.pem"
  [ -s "$EVD/t6-leaf.pem" ] || { echo broken; return; }
  local le ie
  le=$(epoch "$EVD/t6-leaf.pem" enddate); ie=$(epoch "$EVD/t6-issuer.pem" enddate)
  if [ "$rb" = truncate ] && [ -n "$le" ] && [ -n "$ie" ] && [ "$le" = "$ie" ]; then echo holds; else echo broken; fi
}
T6R=$(t6)
case "$T6R" in
  holds) verdict T6 HOLDS "leaf-notafter-equals-issuer-on-truncate-issuer" ;;
  broken) verdict T6 BROKEN "leaf-notafter-differs-or-refused" ;;
  *) verdict T6 ERROR "setup-$T6R" ;;
esac

# ================= T7 nondefault-crl =================
# Default issuer r71root + second issuer r71second; a leaf via role issuer_ref=
# r71second is revoked; its serial is on the second issuer's CRL, not the default's.
t7() {
  bao write -format=json pki/root/generate/internal common_name=root.r71.test ttl=87600h issuer_name=r71root >"$S/t7-d.json" 2>/dev/null || { echo setup; return; }
  bao write -format=json pki/root/generate/internal common_name=second.r71.test ttl=87600h issuer_name=r71second >"$S/t7-s.json" 2>/dev/null || { echo setup; return; }
  cert_of "$S/t7-d.json" > "$EVD/t7-default.pem"
  cert_of "$S/t7-s.json" > "$EVD/t7-second.pem"
  local dref sref; dref=$(jget "$S/t7-d.json" issuer_id); sref=$(jget "$S/t7-s.json" issuer_id)
  [ -n "$dref" ] && [ -n "$sref" ] || { echo setup; return; }
  q write pki/config/issuers default="$dref" || { echo setup; return; }
  q write pki/roles/t7 allowed_domains=r71.test allow_subdomains=true max_ttl=1h issuer_ref=r71second || { echo setup; return; }
  issue t7 leaf.r71.test 1h "$S/t7-leaf.json" || { echo setup; return; }
  cert_of "$S/t7-leaf.json" > "$EVD/t7-leaf.pem"
  [ -s "$EVD/t7-leaf.pem" ] || { echo setup; return; }
  local ser; ser=$(flat "$(jget "$S/t7-leaf.json" serial_number)")
  q write pki/revoke serial_number="$(jget "$S/t7-leaf.json" serial_number)" || { echo setup; return; }
  issuer_crl "$sref" "$EVD/t7-second-crl.pem" || { echo setup; return; }
  issuer_crl "$dref" "$EVD/t7-default-crl.pem" || { echo setup; return; }
  if crl_lists "$EVD/t7-second-crl.pem" "$ser" && ! crl_lists "$EVD/t7-default-crl.pem" "$ser"; then echo holds; else echo broken; fi
}
T7R=$(t7)
case "$T7R" in
  holds) verdict T7 HOLDS "revoked-leaf-on-own-issuer-crl-not-default" ;;
  broken) verdict T7 BROKEN "crl-membership-wrong" ;;
  *) verdict T7 ERROR "setup-$T7R" ;;
esac

# ================= T8 ocsp-unauth =================
# pki/config/crl ocsp_disable=false; token-less openssl ocsp requests report
# revoked / good. HOLDS iff both statuses match expectation.
t8() {
  q write pki/roles/t8 allowed_domains=r71.test allow_subdomains=true max_ttl=1h || { echo setup; return; }
  issue t8 rev.r71.test 1h "$S/t8-rev.json" || { echo setup; return; }
  issue t8 good.r71.test 1h "$S/t8-good.json" || { echo setup; return; }
  cert_of "$S/t8-rev.json" > "$EVD/t8-revoked.pem"
  cert_of "$S/t8-good.json" > "$EVD/t8-good.pem"
  [ -s "$EVD/t8-revoked.pem" ] && [ -s "$EVD/t8-good.pem" ] || { echo setup; return; }
  local did; did=$(default_id) || { echo setup; return; }
  issuer_cert "$did" "$EVD/t8-issuer.pem" || { echo setup; return; }
  q write pki/revoke serial_number="$(jget "$S/t8-rev.json" serial_number)" || { echo setup; return; }
  # Token-less: scrub the environment down (openssl would not read BAO_TOKEN anyway).
  # The `openssl ocsp` request prints a Verify Failure (self-signed responder
  # cert) yet still writes the response and exits 1, so the DER files are the
  # arbiter — check them via respin below, not the request rc.
  env -i HOME="$HOME" PATH="$PATH" openssl ocsp -issuer "$EVD/t8-issuer.pem" -cert "$EVD/t8-revoked.pem" \
      -url "$BAO_ADDR/v1/pki/ocsp" -respout "$EVD/t8-revoked.ocsp.der" >/dev/null 2>&1
  env -i HOME="$HOME" PATH="$PATH" openssl ocsp -issuer "$EVD/t8-issuer.pem" -cert "$EVD/t8-good.pem" \
      -url "$BAO_ADDR/v1/pki/ocsp" -respout "$EVD/t8-good.ocsp.der" >/dev/null 2>&1
  # Under SH8 (ocsp_disable=true) the responder answers Unauthorized: no DER is
  # written for either leaf, which is the falsifier's own effect, not a setup
  # fault — it must read BROKEN, not ERROR.
  [ -s "$EVD/t8-revoked.ocsp.der" ] && [ -s "$EVD/t8-good.ocsp.der" ] || { echo broken-ocsp-unauthorized; return; }
  # A 5-byte Unauthorized response also lands here: respin fails. A respin
  # failure whose output carries a Responder Error is the falsifier's own
  # effect (SH8's `Responder Error: unauthorized`) — BROKEN, not ERROR. A
  # respin failure that is not parseable at all is an ERROR.
  local outr outg rc
  outr=$(openssl ocsp -respin "$EVD/t8-revoked.ocsp.der" -issuer "$EVD/t8-issuer.pem" -VAfile "$EVD/t8-issuer.pem" -cert "$EVD/t8-revoked.pem" -no_nonce 2>&1); rc=$?
  if [ $rc -ne 0 ]; then
    printf '%s' "$outr" | grep -q 'Responder Error' && echo broken-ocsp-responder-error || echo setup-ocsp-respin-unparseable
    return
  fi
  outg=$(openssl ocsp -respin "$EVD/t8-good.ocsp.der" -issuer "$EVD/t8-issuer.pem" -VAfile "$EVD/t8-issuer.pem" -cert "$EVD/t8-good.pem" -no_nonce 2>&1); rc=$?
  if [ $rc -ne 0 ]; then
    printf '%s' "$outg" | grep -q 'Responder Error' && echo broken-ocsp-responder-error || echo setup-ocsp-respin-unparseable
    return
  fi
  [ $rc -eq 0 ] || { echo broken-ocsp-respin-failed; return; }
  printf '%s' "$outr" | grep -qx 'Response verify OK' || { echo broken-ocsp-verify; return; }
  printf '%s' "$outg" | grep -qx 'Response verify OK' || { echo broken-ocsp-verify; return; }
  if printf '%s' "$outr" | grep -qx "$EVD/t8-revoked.pem: revoked" && printf '%s' "$outg" | grep -qx "$EVD/t8-good.pem: good"; then echo holds; else echo broken; fi
}
T8R=$(t8)
case "$T8R" in
  holds) verdict T8 HOLDS "tokenless-ocsp-revoked-and-good" ;;
  broken*) verdict T8 BROKEN "$T8R" ;;
  *) verdict T8 ERROR "setup-$T8R" ;;
esac

# ================= T9 revoke-with-key =================
# no_store leaf: revoke-by-serial refused; revoke-with-key (cert + key by @file) revokes.
t9() {
  q write pki/roles/t9 allowed_domains=r71.test allow_subdomains=true max_ttl=1h no_store=true || { echo setup; return; }
  issue t9 leaf.r71.test 1h "$S/t9-leaf.json" || { echo setup; return; }
  cert_of "$S/t9-leaf.json" > "$EVD/t9-leaf.pem"
  [ -s "$EVD/t9-leaf.pem" ] || { echo setup; return; }
  jget "$S/t9-leaf.json" private_key > "$S/t9-leaf.key"
  local serial; serial=$(jget "$S/t9-leaf.json" serial_number)
  # Refusal of revoke-by-serial is part of the HOLDS condition:
  if bao write "pki/revoke" serial_number="$serial" >/dev/null 2>&1; then
    echo broken-noser-refusal; return
  fi
  [ -s "$S/t9-leaf.key" ] && grep -q 'PRIVATE KEY' "$S/t9-leaf.key" || { echo setup-nokey; return; }
  local did; did=$(default_id) || { echo setup; return; }
  issuer_cert "$did" "$EVD/t9-issuer.pem" || { echo setup; return; }
  if bao write "pki/revoke-with-key" certificate="@$EVD/t9-leaf.pem" private_key="@$S/t9-leaf.key" >/dev/null 2>&1; then :; else echo broken-revoke-with-key-refused; return; fi
  issuer_crl "$did" "$EVD/t9-crl.pem" || { echo setup; return; }
  local ser; ser=$(flat "$serial")
  if openssl crl -in "$EVD/t9-crl.pem" -CAfile "$EVD/t9-issuer.pem" -noout 2>&1 | grep -qx 'verify OK' \
     && crl_lists "$EVD/t9-crl.pem" "$ser"; then echo holds; else echo broken; fi
}
T9R=$(t9)
case "$T9R" in
  holds) verdict T9 HOLDS "no-store-refused-by-serial-revoked-with-key-on-crl" ;;
  broken*) verdict T9 BROKEN "$T9R" ;;
  setup*) verdict T9 ERROR "$T9R" ;;
  *) verdict T9 ERROR "setup-$T9R" ;;
esac

if [ $E -gt 0 ]; then fin SETUP; exit 2
elif [ $B -gt 0 ]; then fin BROKEN; exit 1
else fin HOLDS; exit 0; fi
