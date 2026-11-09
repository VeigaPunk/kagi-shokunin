#!/usr/bin/env bash
# probe-frontier-check.sh — R71Scout second pass on the three open points of probe-frontier.sh:
#  C1 M3: the issuer usage flags at each step (read-only was present before revoke, yet issuing
#         succeeded), the pre-revoke leaf verified against the intermediate, and the full refusal
#         text after the issuer revoke.
#  C2 M2: openssl's depth-resolved verify at a time after the issuer's NotAfter, so the failing
#         certificate is named (depth 1 = issuer, depth 0 = leaf).
# Same throwaway dev server pattern and secrecy rules as probe-frontier.sh.
set -u
WORK=/fast/scratch/hyaku/kagi-r71/R71Scout
SEAT=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-71/w1/R71Scout
OUT="$SEAT/receipts"
mkdir -p "$WORK" "$OUT" || exit 2
S=$(mktemp -d "$WORK/check.XXXXXX") || exit 2
case "$S" in "$WORK"/check.*) ;; *) exit 2;; esac
SP=""
cleanup() { [ -n "$SP" ] && { kill "$SP" 2>/dev/null; wait "$SP" 2>/dev/null; }; rm -rf -- "$S"; }
trap cleanup EXIT
trap 'exit 130' INT TERM HUP
umask 077
export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"
for v in $(env | sed -n 's/^\(\(VAULT\|BAO\)_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done
say() { printf 'CHECK %s\n' "$*"; }
jd() { python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: print(""); sys.exit(0)
d=(d.get("data") or {}) if isinstance(d,dict) else {}
v=d.get(sys.argv[2])
print("" if v is None else (v if isinstance(v,str) else json.dumps(v)))' "$1" "$2" 2>/dev/null; }
scrub() { sed -E 's/127\.0\.0\.1:[0-9]+/ADDR/g' | tr '\n' ' ' | head -c 400; }

start_server() {
  local port tok ok
  for _ in 1 2 3; do
    port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()') || return 1
    tok="r71c-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
    BAO_DEV_ROOT_TOKEN_ID="$tok" setpriv --pdeathsig KILL bao server -dev -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >"$S/server.log" 2>&1 &
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
start_server || { say SETUP dev-server-not-ready; exit 2; }
bao secrets enable pki >/dev/null 2>&1 || { say SETUP pki-enable-failed; exit 2; }
bao secrets tune -max-lease-ttl=87600h pki >/dev/null 2>&1
bao write -format=json pki/root/generate/internal common_name=root.r72.test ttl=87600h issuer_name=r72root >"$S/root.json" 2>/dev/null
bao write pki/config/issuers default=r72root >/dev/null 2>&1
jd "$S/root.json" certificate >"$S/root.pem"

# ---- C1 M3 usage flags across the issuer's life ------------------------------------------
bao write -format=json pki/intermediate/generate/internal common_name=inter.r72.test >"$S/icsr.json" 2>/dev/null
jd "$S/icsr.json" csr >"$S/inter.csr"
bao write -format=json pki/issuer/r72root/sign-intermediate csr=@"$S/inter.csr" common_name=inter.r72.test ttl=24h >"$S/isign.json" 2>/dev/null
jd "$S/isign.json" certificate >"$S/inter.pem"
bao write -format=json pki/intermediate/set-signed certificate=@"$S/inter.pem" >"$S/iset.json" 2>/dev/null
INTER=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}; print((d.get("imported_issuers") or [""])[0])
except Exception: print("")' "$S/iset.json")
say C1.id present=$([ -n "$INTER" ] && echo yes || echo no) name_is_id=$([ "$INTER" = r72inter ] && echo yes || echo no)
bao read -format=json pki/issuer/"$INTER" >"$S/r0.json" 2>/dev/null; say C1.usage-at-birth usage="$(jd "$S/r0.json" usage)" leaf_not_after="$(jd "$S/r0.json" leaf_not_after_behavior)" issuer_name="$(jd "$S/r0.json" issuer_name)"
bao write pki/roles/r72i issuer_ref="$INTER" allowed_domains=r72.test allow_subdomains=true max_ttl=12h >/dev/null 2>&1
bao write -format=json pki/issue/r72i common_name=pre.r72.test ttl=1h >"$S/pre.json" 2>"$S/pre.err"; rc=$?
say C1.issue-before-revoke rc=$rc cert_returned=$([ -n "$(jd "$S/pre.json" certificate)" ] && echo yes || echo no) err="$(scrub <"$S/pre.err")"
jd "$S/pre.json" certificate >"$S/pre.pem"
if [ -s "$S/pre.pem" ]; then
  openssl verify -CAfile "$S/root.pem" -untrusted "$S/inter.pem" "$S/pre.pem" >"$S/pv.txt" 2>&1; say C1.pre-leaf-verifies-root-anchor rc=$? out="$(tail -1 "$S/pv.txt")"
  say C1.pre-leaf-issuer-is-inter same=$(openssl x509 -in "$S/pre.pem" -noout -issuer | sed 's/^issuer=//' | tr -d ' ' | grep -c "$(openssl x509 -in "$S/inter.pem" -noout -subject | sed 's/^subject=//' | tr -d ' ')" )
fi
bao write -force -format=json pki/issuer/"$INTER"/revoke >/dev/null 2>"$S/rev.err"; say C1.revoke-issuer rc=$?
bao read -format=json pki/issuer/"$INTER" >"$S/r1.json" 2>/dev/null; say C1.usage-after-revoke usage="$(jd "$S/r1.json" usage)" revocation_time="$(jd "$S/r1.json" revocation_time)"
bao write -format=json pki/issue/r72i common_name=post.r72.test ttl=1h >"$S/post.json" 2>"$S/post.err"; rc=$?
say C1.issue-after-revoke rc=$rc err="$(scrub <"$S/post.err")"
say C1.sign-with-revoked-NOT-MEASURED reason=malformed-call-no-data-argument

# ---- C2 M2 depth-resolved verify ----------------------------------------------------------
bao write -format=json pki/root/generate/internal common_name=short2.r72.test ttl=2h issuer_name=r72short2 >"$S/short.json" 2>/dev/null
jd "$S/short.json" certificate >"$S/short.pem"
bao write pki/issuer/r72short2 leaf_not_after_behavior=permit issuer_name=r72short2 >/dev/null 2>&1
bao write pki/roles/r72pp issuer_ref=r72short2 allowed_domains=r72.test allow_subdomains=true max_ttl=87600h >/dev/null 2>&1
bao write -format=json pki/issue/r72pp common_name=perm.r72.test ttl=10h >"$S/perm.json" 2>/dev/null
jd "$S/perm.json" certificate >"$S/perm.pem"
ie=$(date -u -d "$(openssl x509 -in "$S/short.pem" -noout -enddate | cut -d= -f2)" +%s)
openssl verify -verbose -CAfile "$S/short.pem" -attime $((ie+60)) "$S/perm.pem" >"$S/vv.txt" 2>&1; say C2.permit-verify-after-issuer-end rc=$? lines="$(grep -E 'depth=|error' "$S/vv.txt" | tr '\n' ' ' | head -c 400)"
openssl verify -verbose -CAfile "$S/short.pem" -attime $((ie+60)) "$S/perm.pem" >/dev/null 2>&1
# the leaf's own window, with the issuer taken out of the question: a self-check of its NotAfter
le=$(date -u -d "$(openssl x509 -in "$S/perm.pem" -noout -enddate | cut -d= -f2)" +%s)
say C2.permit-leaf-window leaf_valid_past_issuer_end_by_s=$((le-ie)) leaf_still_inside_own_window_at_issuer_end_plus_60=$([ $((ie+60)) -lt "$le" ] && echo yes || echo no)
cp "$S/inter.pem" "$OUT/check-m3-intermediate.pem"
cp "$S/perm.pem" "$OUT/check-m2-permit-leaf.pem"
cp "$S/short.pem" "$OUT/check-m2-permit-issuer.pem"
exit 0
