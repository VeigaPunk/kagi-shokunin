#!/usr/bin/env bash
# openbao-pki-issuer-trial.sh — round 71: execute four OpenBao PKI issuer/revocation-channel
# mechanics that corpus/knowledge/openbao-pki-issuer-revocation-channels.md documents, against the
# `bao` found on PATH, on a throwaway `bao server -dev` bound to 127.0.0.1 with in-memory storage.
#
# Refusal bounds: never reads ~/.vault-token, ~/.bao*, any VAULT_*/BAO_* variable of the caller,
# any real vault, `op`, or a real secret. HOME/TMPDIR are scratch (umask 077); the dev root token
# is random, never on any argv (server: BAO_DEV_ROOT_TOKEN_ID; client: BAO_TOKEN), never stored
# (-dev-no-store-token) and never printed; the server's own output goes to /dev/null. Private keys
# stay in scratch and are passed to `bao` by @file, never on argv; no key, certificate body or CRL
# body is printed. The dev server runs under `setpriv --pdeathsig KILL`, the port is taken from the
# kernel and checked to be held by that server's own pid, and the server is killed and the scratch
# removed on every trappable exit path. Launch pattern reused from corpus/openbao-pki-trial.sh.
#
# Tests (sources: S170 = OpenBao PKI API docs; S173 = OpenBao PKI considerations):
#   T6 notafter-truncate  S170 §Update issuer, leaf_not_after_behavior. HOLDS iff, on an issuer
#                         set to `truncate`, a leaf requested for longer than the issuer's remaining
#                         life is issued with NotAfter equal to the issuer's NotAfter.
#   T7 nondefault-crl     S173 "When certificates are revoked and their issuer is no longer part of
#                         this PKI mount, OpenBao places them on the default issuer's CRL" (the
#                         issuer here IS part of the mount). HOLDS iff a revoked leaf of a
#                         non-default issuer (role issuer_ref) is on that issuer's own CRL and absent
#                         from the default issuer's CRL.
#   T8 ocsp-unauth        S170 §OCSP request. HOLDS iff, with OCSP enabled by pki/config/crl, a
#                         token-less OCSP request reports the revoked leaf `revoked` and an
#                         unrevoked control leaf `good`.
#   T9 revoke-with-key    S170 §Revoke certificate with private key. HOLDS iff a no_store leaf
#                         is refused revocation by serial, is then revoked by proof of possession
#                         (its own certificate and key, passed by @file), and its serial appears on
#                         the issuer's CRL.
#
# Measured while building T6 (round 71): `bao write pki/issuer/<ref> <field>=...` (POST) resets
# every issuer field the call does not name — issuer_name became "" — so T6 re-sends issuer_name.
#
# --evidence DIR: public artifacts (certificates, CRLs, OCSP responses; never a private key) are
# copied there for an independent openssl check: t6-{leaf,issuer}.pem; t7-{leaf,second,default}.pem,
# t7-{second,default}-crl.pem; t8-{issuer,revoked,good}.pem, t8-{revoked,good}.ocsp.der;
# t9-{leaf,issuer}.pem, t9-crl.pem.
#
# Output: one `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` line per test, then
#   OPENBAO_PKI_ISSUER_TRIAL: HOLDS|BROKEN|SETUP holds=<n> broken=<n> error=<n> bao=<ver> openssl=<ver>
# Exit 0 all HOLDS, 1 any BROKEN (no ERROR), 2 SETUP (tool missing, scratch failure, any ERROR).
set -u

usage() {
  cat <<'U'
usage: openbao-pki-issuer-trial.sh [--work DIR] [--evidence DIR] [--help]
Runs four OpenBao PKI tests (T6 notafter-truncate, T7 nondefault-crl, T8 ocsp-unauth,
T9 revoke-with-key) against a throwaway dev server on 127.0.0.1. --work names the scratch parent
(default ${TMPDIR:-/tmp}); everything created there is removed on exit. --evidence receives
public artifacts only.
U
}
WORK="${TMPDIR:-/tmp}"; EV=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) WORK=${2:?--work needs a directory}; shift 2;;
    --evidence) EV=${2:?--evidence needs a directory}; shift 2;;
    --help|-h) usage; exit 0;;
    *) usage >&2; exit 64;;
  esac
done

fin() { echo "OPENBAO_PKI_ISSUER_TRIAL: $1 holds=$H broken=$B error=$E bao=$BV openssl=$OV"; }
H=0; B=0; E=0; BV=none; OV=none
setup() { echo "SETUP $1" >&2; fin SETUP; exit 2; }

command -v bao >/dev/null 2>&1 || setup bao-missing
command -v openssl >/dev/null 2>&1 || setup openssl-missing
command -v python3 >/dev/null 2>&1 || setup python3-missing
BV=$(bao version 2>/dev/null | awk '{print $2}'); OV=$(openssl version 2>/dev/null | awk '{print $2}')
command -v setpriv >/dev/null 2>&1 || setup setpriv-missing
command -v ss >/dev/null 2>&1 || setup ss-missing
umask 077

for v in $(env | sed -n 's/^\(\(VAULT\|BAO\)_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done

mkdir -p "$WORK" || setup work-dir
S=$(mktemp -d "$WORK/kagi-pki-issuer-trial.XXXXXX") || setup mktemp
case "$S" in "$WORK"/kagi-pki-issuer-trial.*) ;; *) setup scratch-path;; esac
if [ -n "$EV" ]; then mkdir -p "$EV" || setup evidence-dir; fi
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
verdict() { # id state detail
  echo "TRIAL $1 $2 $3"
  case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac
}
ev() { [ -n "$EV" ] && cp -- "$1" "$EV/$2"; return 0; }  # public artifacts only
hexser() { printf '%s' "$1" | tr -d ':' | tr 'a-f' 'A-F'; }
crl_has() { # crlpem serial -> 0 if listed
  openssl crl -in "$1" -noout -text 2>/dev/null | grep -q "Serial Number: $(hexser "$2")\$"
}
endsec() { date -u -d "$(openssl x509 -in "$1" -noout -enddate 2>/dev/null | cut -d= -f2)" +%s 2>/dev/null; }
crl_of() { # issuer-ref outpem -> 0 if a parsable CRL was read
  bao read -format=json "pki/issuer/$1/crl" >"$S/crl.json" 2>/dev/null || return 1
  python3 -c 'import json,sys; print((json.load(open(sys.argv[1])).get("data") or {}).get("crl",""))' "$S/crl.json" > "$2" 2>/dev/null
  openssl crl -in "$2" -noout >/dev/null 2>&1
}

q secrets enable pki || setup pki-enable
q secrets tune -max-lease-ttl=87600h pki || setup pki-tune
q write pki/root/generate/internal common_name=root.r71.test ttl=87600h issuer_name=r71root || setup root-generate
q write pki/config/issuers default=r71root || setup default-issuer
bao read -field=certificate pki/issuer/r71root >"$S/root.pem" 2>/dev/null || setup root-read

# T6 — an issuer set to truncate clips a leaf's NotAfter to its own
if q write pki/root/generate/internal common_name=short.r71.test ttl=2h issuer_name=r71short \
   && bao read -field=certificate pki/issuer/r71short >"$S/short.pem" 2>/dev/null \
   && q write pki/issuer/r71short issuer_name=r71short leaf_not_after_behavior=truncate \
   && q write pki/roles/t6 allowed_domains=r71.test allow_subdomains=true max_ttl=24h; then
  if bao write -format=json pki/issuer/r71short/issue/t6 common_name=t.r71.test ttl=10h >"$S/t6.json" 2>/dev/null; then
    jget "$S/t6.json" certificate > "$S/t6.pem"
    le=$(endsec "$S/t6.pem"); ie=$(endsec "$S/short.pem")
    ev "$S/t6.pem" t6-leaf.pem; ev "$S/short.pem" t6-issuer.pem
    if [ -z "$le" ] || [ -z "$ie" ]; then verdict T6 ERROR "unparsable-certificate"
    elif [ "$le" = "$ie" ]; then verdict T6 HOLDS "leaf-notafter-equals-issuer-notafter"
    else verdict T6 BROKEN "leaf-notafter-$le-issuer-$ie"; fi
  else verdict T6 BROKEN "long-leaf-refused"; fi
else verdict T6 ERROR "issuer-or-role-setup-failed"; fi

# T7 — a revoked leaf of a non-default issuer lands on that issuer's CRL, not the default CRL
if q write pki/root/generate/internal common_name=second.r71.test ttl=87600h issuer_name=r71second \
   && bao read -field=certificate pki/issuer/r71second >"$S/second.pem" 2>/dev/null \
   && q write pki/roles/t7 allowed_domains=r71.test allow_subdomains=true max_ttl=1h issuer_ref=r71second \
   && bao write -format=json pki/issue/t7 common_name=s.r71.test ttl=5m >"$S/t7.json" 2>/dev/null; then
  s7=$(jget "$S/t7.json" serial_number); jget "$S/t7.json" certificate > "$S/t7.pem"
  if [ -n "$s7" ] && q write pki/revoke serial_number="$s7" \
     && crl_of r71second "$S/c7s.pem" && crl_of r71root "$S/c7d.pem"; then
    ev "$S/t7.pem" t7-leaf.pem; ev "$S/second.pem" t7-second.pem; ev "$S/root.pem" t7-default.pem
    ev "$S/c7d.pem" t7-second-crl.pem; ev "$S/c7s.pem" t7-default-crl.pem
    if crl_has "$S/c7s.pem" "$s7" && ! crl_has "$S/c7d.pem" "$s7"; then verdict T7 HOLDS "on-own-issuer-crl absent-from-default-crl"
    else verdict T7 BROKEN "own=$(crl_has "$S/c7s.pem" "$s7" && echo yes || echo no) default=$(crl_has "$S/c7d.pem" "$s7" && echo yes || echo no)"; fi
  else verdict T7 ERROR "revoke-or-crl-read-failed"; fi
else verdict T7 ERROR "issuer-role-or-issue-failed"; fi

# T8 — the OCSP responder answers revocation status without a token
if q write pki/config/crl ocsp_disable=false \
   && q write pki/roles/t8 allowed_domains=r71.test allow_subdomains=true max_ttl=1h \
   && bao write -format=json pki/issue/t8 common_name=o.r71.test ttl=5m >"$S/t8r.json" 2>/dev/null \
   && bao write -format=json pki/issue/t8 common_name=g.r71.test ttl=5m >"$S/t8g.json" 2>/dev/null; then
  s8=$(jget "$S/t8r.json" serial_number)
  jget "$S/t8r.json" certificate > "$S/t8r.pem"; jget "$S/t8g.json" certificate > "$S/t8g.pem"
  if [ -n "$s8" ] && q write pki/revoke serial_number="$s8"; then
    st() { # leafpem respout -> status word
      ( unset BAO_TOKEN; openssl ocsp -no_nonce -issuer "$S/root.pem" -VAfile "$S/root.pem" -cert "$1" \
          -url "$BAO_ADDR/v1/pki/ocsp" -respout "$2" 2>/dev/null ) | awk -F': ' 'NR==1{print $2}'
    }
    r=$(st "$S/t8r.pem" "$S/t8r.der"); g=$(st "$S/t8g.pem" "$S/t8g.der")
    ev "$S/root.pem" t8-issuer.pem; ev "$S/t8r.pem" t8-revoked.pem; ev "$S/t8g.pem" t8-good.pem
    [ -s "$S/t8r.der" ] && ev "$S/t8r.der" t8-revoked.ocsp.der; [ -s "$S/t8g.der" ] && ev "$S/t8g.der" t8-good.ocsp.der
    if [ "$r" = revoked ] && [ "$g" = good ]; then verdict T8 HOLDS "tokenless-ocsp revoked=revoked control=good"
    else verdict T8 BROKEN "tokenless-ocsp revoked=${r:-none} control=${g:-none}"; fi
  else verdict T8 ERROR "revoke-failed"; fi
else verdict T8 ERROR "crl-config-role-or-issue-failed"; fi

# T9 — a no_store leaf is refused revocation by serial and revoked by proof of possession
if q write pki/roles/t9 allowed_domains=r71.test allow_subdomains=true max_ttl=1h no_store=true \
   && bao write -format=json pki/issue/t9 common_name=k.r71.test ttl=5m >"$S/t9.json" 2>/dev/null; then
  s9=$(jget "$S/t9.json" serial_number)
  jget "$S/t9.json" certificate > "$S/t9.pem"; jget "$S/t9.json" private_key > "$S/t9.key"
  if [ -z "$s9" ]; then verdict T9 ERROR "no-serial"
  elif q write pki/revoke serial_number="$s9"; then verdict T9 BROKEN "no_store-leaf-revoked-by-serial"
  elif bao write -format=json pki/revoke-with-key certificate=@"$S/t9.pem" private_key=@"$S/t9.key" >"$S/t9r.json" 2>/dev/null; then
    if crl_of r71root "$S/c9.pem"; then
      ev "$S/t9.pem" t9-leaf.pem; ev "$S/root.pem" t9-issuer.pem; ev "$S/c9.pem" t9-crl.pem
      if crl_has "$S/c9.pem" "$s9"; then verdict T9 HOLDS "serial-revoke-refused pop-revoked serial-on-crl"
      else verdict T9 BROKEN "pop-revoke-not-on-crl"; fi
    else verdict T9 ERROR "crl-read-failed"; fi
  else verdict T9 BROKEN "pop-revoke-refused"; fi
  rm -f -- "$S/t9.key"
else verdict T9 ERROR "role-or-issue-failed"; fi

if [ $E -gt 0 ]; then fin SETUP; exit 2
elif [ $B -gt 0 ]; then fin BROKEN; exit 1
else fin HOLDS; exit 0; fi
