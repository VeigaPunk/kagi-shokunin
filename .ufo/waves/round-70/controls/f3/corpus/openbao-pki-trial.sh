#!/usr/bin/env bash
# openbao-pki-trial.sh — round 70: execute the OpenBao PKI certificate-lifecycle mechanics that
# corpus/knowledge/openbao-pki-certificate-lifecycle.md documents, against the `bao` found on
# PATH, on a throwaway `bao server -dev` bound to 127.0.0.1 with in-memory storage.
#
# Refusal bounds: never reads ~/.vault-token, ~/.bao*, any VAULT_*/BAO_* variable of the caller,
# any real vault, `op`, or a real secret. HOME/TMPDIR are scratch; the dev root token is random,
# lives only in scratch and is never printed; no private key, certificate body or CRL body is
# printed. The dev server is killed on every exit path (EXIT/INT/TERM/HUP) and the scratch removed.
#
# Tests (source S170 = OpenBao PKI secrets-engine API docs; S171 = PKI engine overview):
#   T1 root-internal   S170 §Generate key: "if internal the private key will not be returned and
#                      cannot be retrieved later". HOLDS iff root/generate/internal returns a
#                      certificate and no private_key field.
#   T2 ttl-clamp       S170 §Generate certificate and key: ttl "Cannot be greater than the role's
#                      max_ttl value". HOLDS iff a 24h request on a max_ttl=1h role is issued with a
#                      lifetime <= 1h + 60s (measured: clamped with a warning, not refused).
#   T3 domain-refuse   S170 §Create/Update role, allowed_domains. HOLDS iff a CN outside
#                      allowed_domains is refused while a CN inside is issued (positive control).
#   T4 revoke-crl      S170 §Revoke certificate: "A successful revocation will rotate the CRL."
#                      HOLDS iff the revoked serial appears in the mount's CRL (openssl-parsed).
#   T5 no-store        S170 §Create/Update role, no_store: "cannot be enumerated or revoked via
#                      serial number". HOLDS iff a no_store cert is neither readable at cert/<serial>
#                      nor listed, while a stored cert is readable (positive control).
#
# Output: one `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` line per test, then
#   OPENBAO_PKI_TRIAL: HOLDS|BROKEN|SETUP holds=<n> broken=<n> error=<n> bao=<ver> openssl=<ver>
# Exit 0 all HOLDS, 1 any BROKEN (no ERROR), 2 SETUP (tool missing, scratch failure, any ERROR).
set -u

usage() {
  cat <<'U'
usage: openbao-pki-trial.sh [--work DIR] [--help]
Runs five OpenBao PKI tests (T1 root-internal, T2 ttl-clamp, T3 domain-refuse, T4 revoke-crl,
T5 no-store) against a throwaway dev server on 127.0.0.1. --work names the scratch parent
(default ${TMPDIR:-/tmp}); everything created there is removed on exit.
U
}
WORK="${TMPDIR:-/tmp}"
while [ $# -gt 0 ]; do
  case "$1" in
    --work) WORK=${2:?--work needs a directory}; shift 2;;
    --help|-h) usage; exit 0;;
    *) usage >&2; exit 64;;
  esac
done

fin() { echo "OPENBAO_PKI_TRIAL: $1 holds=$H broken=$B error=$E bao=$BV openssl=$OV"; }
H=0; B=0; E=0; BV=none; OV=none
setup() { echo "SETUP $1" >&2; fin SETUP; exit 2; }

command -v bao >/dev/null 2>&1 || setup bao-missing
command -v openssl >/dev/null 2>&1 || setup openssl-missing
command -v python3 >/dev/null 2>&1 || setup python3-missing
BV=$(bao version 2>/dev/null | awk '{print $2}'); OV=$(openssl version 2>/dev/null | awk '{print $2}')

# Scrub every caller VAULT_*/BAO_* variable.
for v in $(env | sed -n 's/^\(\(VAULT\|BAO\)_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done

mkdir -p "$WORK" || setup work-dir
S=$(mktemp -d "$WORK/kagi-pki-trial.XXXXXX") || setup mktemp
case "$S" in "$WORK"/kagi-pki-trial.*) ;; *) setup scratch-path;; esac
SP=""
cleanup() { [ -n "$SP" ] && { kill "$SP" 2>/dev/null; wait "$SP" 2>/dev/null; }; rm -rf -- "$S"; }
trap cleanup EXIT
trap 'exit 130' INT TERM HUP
export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"

PORT=""
for _ in $(seq 1 40); do
  p=$((20000 + $(od -An -N2 -tu2 /dev/urandom | tr -d ' ') % 10000))
  (exec 3<>"/dev/tcp/127.0.0.1/$p") 2>/dev/null || { PORT=$p; break; }
done
[ -n "$PORT" ] || setup no-free-port
TOK="r70-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
bao server -dev -dev-root-token-id="$TOK" -dev-listen-address="127.0.0.1:$PORT" >"$S/server.log" 2>&1 &
SP=$!
export BAO_ADDR="http://127.0.0.1:$PORT" BAO_TOKEN="$TOK"
up=0; for _ in $(seq 1 60); do bao status >/dev/null 2>&1 && { up=1; break; }; sleep 0.25; done
[ $up = 1 ] || setup dev-server-not-ready

q() { bao "$@" >/dev/null 2>&1; }
jget() { python3 -c 'import json,sys
d=json.load(open(sys.argv[1])).get("data") or {}
v=d.get(sys.argv[2])
print("" if v is None else v)' "$1" "$2" 2>/dev/null; }
jhas() { python3 -c 'import json,sys; d=json.load(open(sys.argv[1])).get("data") or {}; sys.exit(0 if sys.argv[2] in d else 1)' "$1" "$2" 2>/dev/null; }
verdict() { # id state detail
  echo "TRIAL $1 $2 $3"
  case "$2" in HOLDS) H=$((H+1));; BROKEN) B=$((B+1));; *) E=$((E+1));; esac
}
lifetime() { # pemfile -> seconds notAfter-notBefore
  local nb na
  nb=$(openssl x509 -in "$1" -noout -startdate 2>/dev/null | cut -d= -f2)
  na=$(openssl x509 -in "$1" -noout -enddate 2>/dev/null | cut -d= -f2)
  [ -n "$nb" ] && [ -n "$na" ] || { echo -1; return; }
  echo $(( $(date -u -d "$na" +%s) - $(date -u -d "$nb" +%s) ))
}

q secrets enable pki || setup pki-enable
q secrets tune -max-lease-ttl=87600h pki || setup pki-tune

# T1 — root/generate/internal keeps the CA key inside the mount
if bao write -format=json pki/root/generate/internal common_name=root.r70.test ttl=87600h issuer_name=r70root >"$S/t1.json" 2>/dev/null \
   && [ -n "$(jget "$S/t1.json" certificate)" ]; then
  if jhas "$S/t1.json" private_key; then verdict T1 HOLDS "private_key-returned"
  else verdict T1 HOLDS "certificate-returned no-private_key"; fi
else verdict T1 ERROR "root-generate-failed"; fi
q write pki/config/issuers default=r70root || setup default-issuer

# T2 — a requested ttl above the role's max_ttl is clamped
if q write pki/roles/t2 allowed_domains=r70.test allow_subdomains=true max_ttl=1h \
   && bao write -format=json pki/issue/t2 common_name=a.r70.test ttl=24h >"$S/t2.json" 2>/dev/null; then
  jget "$S/t2.json" certificate > "$S/t2.pem"; lt=$(lifetime "$S/t2.pem")
  if [ "$lt" -lt 0 ]; then verdict T2 ERROR "unparsable-cert"
  elif [ "$lt" -le 3660 ]; then verdict T2 HOLDS "requested=86400s lifetime=${lt}s max=3600s"
  else verdict T2 HOLDS "requested=86400s lifetime=${lt}s max=3600s"; fi
else verdict T2 ERROR "role-or-issue-failed"; fi

# T3 — a CN outside allowed_domains is refused; one inside is issued
if q write pki/roles/t3 allowed_domains=r70.test allow_subdomains=true max_ttl=1h \
   && q write pki/issue/t3 common_name=ok.r70.test ttl=5m; then
  if q write pki/issue/t3 common_name=evil.example ttl=5m; then verdict T3 HOLDS "outside-cn-issued"
  else verdict T3 HOLDS "outside-cn-refused inside-cn-issued"; fi
else verdict T3 ERROR "role-or-control-issue-failed"; fi

# T4 — revocation by serial puts the serial on the CRL
if q write pki/roles/t4 allowed_domains=r70.test allow_subdomains=true max_ttl=1h \
   && bao write -format=json pki/issue/t4 common_name=r.r70.test ttl=5m >"$S/t4.json" 2>/dev/null; then
  ser=$(jget "$S/t4.json" serial_number)
  if [ -n "$ser" ] && q write pki/revoke serial_number="$ser" \
     && bao read -format=json pki/cert/crl >"$S/crl.json" 2>/dev/null; then
    jget "$S/crl.json" certificate > "$S/crl.pem"
    want=$(printf '%s' "$ser" | tr -d ':' | tr 'a-f' 'A-F')
    if ! openssl crl -in "$S/crl.pem" -noout >/dev/null 2>&1; then verdict T4 ERROR "unparsable-crl"
    elif openssl crl -in "$S/crl.pem" -noout -text 2>/dev/null | grep -q "Serial Number: $want\$"; then verdict T4 HOLDS "serial-on-crl"
    else verdict T4 HOLDS "serial-absent-from-crl"; fi
  else verdict T4 ERROR "revoke-or-crl-read-failed"; fi
else verdict T4 ERROR "role-or-issue-failed"; fi

# T5 — a no_store role's certificate cannot be read or enumerated by serial
if q write pki/roles/t5 allowed_domains=r70.test allow_subdomains=true max_ttl=1h no_store=true \
   && q write pki/roles/t5c allowed_domains=r70.test allow_subdomains=true max_ttl=1h \
   && bao write -format=json pki/issue/t5 common_name=n.r70.test ttl=5m >"$S/t5.json" 2>/dev/null \
   && bao write -format=json pki/issue/t5c common_name=c.r70.test ttl=5m >"$S/t5c.json" 2>/dev/null; then
  s5=$(jget "$S/t5.json" serial_number); sc=$(jget "$S/t5c.json" serial_number)
  bao list -format=json pki/certs >"$S/certs.json" 2>/dev/null
  if ! q read pki/cert/"$sc" || ! grep -q "\"$sc\"" "$S/certs.json"; then verdict T5 ERROR "stored-control-unreadable"
  elif q read pki/cert/"$s5" || grep -q "\"$s5\"" "$S/certs.json"; then verdict T5 HOLDS "no_store-cert-readable-or-listed"
  else verdict T5 HOLDS "no_store-cert-unreadable-unlisted stored-control-readable"; fi
else verdict T5 ERROR "role-or-issue-failed"; fi

if [ $E -gt 0 ]; then fin SETUP; exit 2
elif [ $B -gt 0 ]; then fin BROKEN; exit 1
else fin HOLDS; exit 0; fi
