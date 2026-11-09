#!/usr/bin/env bash
# probe-frontier.sh — R71Scout frontier recon (round 71). Three OpenBao 2.7.2 PKI mechanics that
# corpus/openbao-pki-issuer-trial.sh (T6 notafter-truncate, T7 nondefault-crl, T8 ocsp-unauth,
# T9 revoke-with-key) does NOT touch. Throwaway `bao server -dev` on 127.0.0.1, in-memory,
# random dev root token passed by env only (BAO_DEV_ROOT_TOKEN_ID), never on argv, never printed.
#
#   M1  issuer-gone-crl  S173 "when certificates are revoked and their issuer is no longer part of
#                        this PKI mount, OpenBao places them on the default issuer's CRL". Revoke a
#                        leaf of a NON-default issuer while it is in the mount, DELETE that issuer,
#                        read the default CRL before and after pki/crl/rotate. M1b: delete first,
#                        then revoke the leaf.
#   M2  permit-outlive   leaf_not_after_behavior = permit | truncate | err on a 2h issuer, leaf
#                        requested for 10h. Compare leaf NotAfter with issuer NotAfter, and
#                        openssl-verify the leaf at a time after the issuer's NotAfter.
#   M3  issuer-revoke    intermediate signed by the default root; POST pki/issuer/<ref>/revoke;
#                        where the revoked issuer lands (default CRL? own CRL?), whether it can
#                        still issue. Control: revoke a self-signed root (no signing parent).
#
# Public artifacts (certificates, CRLs, OCSP-free) are copied to the receipts dir; no private key
# leaves $WORK. Every line of output is "FRONT <id> key=value ..." and is the receipt.
set -u
WORK=/fast/scratch/hyaku/kagi-r71/R71Scout
SEAT=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-71/w1/R71Scout
OUT="$SEAT/receipts"
mkdir -p "$WORK" "$OUT" || exit 2
S=$(mktemp -d "$WORK/probe.XXXXXX") || exit 2
case "$S" in "$WORK"/probe.*) ;; *) exit 2;; esac
SP=""
cleanup() { [ -n "$SP" ] && { kill "$SP" 2>/dev/null; wait "$SP" 2>/dev/null; }; rm -rf -- "$S"; }
trap cleanup EXIT
trap 'exit 130' INT TERM HUP
umask 077
export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"
for v in $(env | sed -n 's/^\(\(VAULT\|BAO\)_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done

say() { printf 'FRONT %s\n' "$*"; }
jd() { python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: print(""); sys.exit(0)
d=(d.get("data") or {}) if isinstance(d,dict) else {}
v=d.get(sys.argv[2])
print("" if v is None else (v if isinstance(v,str) else json.dumps(v)))' "$1" "$2" 2>/dev/null; }

# serial-in-CRL check: $1 = CRL PEM file, $2 = serial as bao prints it (aa:bb:..). Prints yes|no and entry count.
crl_has() {
  python3 - "$1" "$2" <<'PY' 2>/dev/null || echo "err"
import re,subprocess,sys
pem,ser=sys.argv[1],sys.argv[2]
r=subprocess.run(["openssl","crl","-in",pem,"-noout","-text"],capture_output=True,text=True)
if r.returncode!=0: print("unparsable"); sys.exit(0)
got={int(m.group(1).replace(":",""),16) for m in re.finditer(r"Serial Number: ([0-9A-Fa-f:]+)",r.stdout)}
want=int(ser.replace(":",""),16)
print("%s entries=%d" % ("yes" if want in got else "no", len(got)))
PY
}
# CRL of issuer $1 into file $2 (JSON read, token from env). 0 if a parsable CRL came back.
issuer_crl() {
  bao read -format=json "pki/issuer/$1/crl" >"$S/ic.json" 2>/dev/null || return 1
  jd "$S/ic.json" crl >"$2"; [ -s "$2" ] && openssl crl -in "$2" -noout >/dev/null 2>&1
}
# default CRL into $1 via the unauthenticated PEM endpoint (no token sent).
default_crl() {
  curl -s -f "$BAO_ADDR/v1/pki/crl/pem" -o "$1" 2>/dev/null && openssl crl -in "$1" -noout >/dev/null 2>&1
}
issuer_field() { bao read -format=json "pki/issuer/$1" >"$S/if.json" 2>/dev/null && jd "$S/if.json" "$2"; }
cert_serial() { openssl x509 -in "$1" -noout -serial 2>/dev/null | cut -d= -f2 | sed 's/../&:/g; s/:$//'; }
cert_end() { date -u -d "$(openssl x509 -in "$1" -noout -enddate 2>/dev/null | cut -d= -f2)" +%s 2>/dev/null; }

# ---- server -------------------------------------------------------------------------------
start_server() {
  local port tok ok
  for _ in 1 2 3; do
    port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()') || return 1
    tok="r71s-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
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
say SETUP bao=$(bao version 2>/dev/null | awk '{print $2}') openssl=$(openssl version | awk '{print $2}') server_pid_bound=yes

bao secrets enable pki >/dev/null 2>&1 || { say SETUP pki-enable-failed; exit 2; }
bao secrets tune -max-lease-ttl=87600h pki >/dev/null 2>&1
bao write -format=json pki/root/generate/internal common_name=root.r72.test ttl=87600h issuer_name=r72root >"$S/root.json" 2>/dev/null \
  || { say SETUP root-generate-failed; exit 2; }
bao write pki/config/issuers default=r72root >/dev/null 2>&1
bao read -format=json pki/issuer/r72root >"$S/rootr.json" 2>/dev/null
jd "$S/rootr.json" certificate >"$S/root.pem"

# ==== M1 issuer-gone-crl =====================================================================
bao write -format=json pki/root/generate/internal common_name=gone.r72.test ttl=87600h issuer_name=r72gone >"$S/gone.json" 2>/dev/null \
  || { say M1 SETUP gone-generate-failed; }
jd "$S/gone.json" certificate >"$S/gone.pem"
bao write pki/roles/r72g issuer_ref=r72gone allowed_domains=r72.test allow_subdomains=true max_ttl=87600h >/dev/null 2>&1; say M1 role_rc=$?
bao write -format=json pki/issue/r72g common_name=m1a.r72.test ttl=1h >"$S/m1a.json" 2>"$S/m1a.err"; rc=$?
M1A=$(jd "$S/m1a.json" serial_number)
say M1.issue rc=$rc serial_present=$([ -n "$M1A" ] && echo yes || echo no)
cp "$S/gone.pem" "$OUT/m1-gone-issuer.pem"
issuer_crl r72gone "$S/m1-gone-pre.pem"; say M1.pre-issuer-crl-read rc=$? serial_on_gone_crl="$(crl_has "$S/m1-gone-pre.pem" "$M1A" 2>/dev/null)"
default_crl "$S/m1-default-pre.pem"; say M1.pre-default-crl-read rc=$? serial_on_default_crl="$(crl_has "$S/m1-default-pre.pem" "$M1A")"

bao write -format=json pki/revoke serial_number="$M1A" >"$S/m1rev.json" 2>"$S/m1rev.err"; say M1.revoke rc=$? revocation_time=$(jd "$S/m1rev.json" revocation_time)
issuer_crl r72gone "$S/m1-gone-revoked.pem"; say M1.post-revoke-issuer-crl rc=$? serial_on_gone_crl="$(crl_has "$S/m1-gone-revoked.pem" "$M1A")"
default_crl "$S/m1-default-revoked.pem"; say M1.post-revoke-default-crl rc=$? serial_on_default_crl="$(crl_has "$S/m1-default-revoked.pem" "$M1A")"

bao delete pki/issuer/r72gone >"$S/m1del.out" 2>&1; say M1.delete-issuer rc=$? out_has_warning=$(grep -ci warn "$S/m1del.out")
bao read -format=json pki/issuer/r72gone >/dev/null 2>&1; say M1.read-deleted-issuer rc=$?
issuer_crl r72gone "$S/m1-gone-deleted.pem"; say M1.deleted-issuer-crl-read rc=$?
default_crl "$S/m1-default-after-delete.pem"; say M1.after-delete-default-crl rc=$? serial_on_default_crl="$(crl_has "$S/m1-default-after-delete.pem" "$M1A")"
cp "$S/m1-default-after-delete.pem" "$OUT/m1-default-crl-after-delete.pem"

bao read -format=json pki/crl/rotate >"$S/m1rot.json" 2>"$S/m1rot.err"; say M1.crl-rotate rc=$?
default_crl "$S/m1-default-after-rotate.pem"; say M1.after-rotate-default-crl rc=$? serial_on_default_crl="$(crl_has "$S/m1-default-after-rotate.pem" "$M1A")"
cp "$S/m1-default-after-rotate.pem" "$OUT/m1-default-crl-after-rotate.pem"

# M1b: delete first, then revoke a leaf of the deleted issuer
bao write -format=json pki/root/generate/internal common_name=gone2.r72.test ttl=87600h issuer_name=r72gone2 >"$S/gone2.json" 2>/dev/null
bao write pki/roles/r72g2 issuer_ref=r72gone2 allowed_domains=r72.test allow_subdomains=true max_ttl=87600h >/dev/null 2>&1
bao write -format=json pki/issue/r72g2 common_name=m1b.r72.test ttl=1h >"$S/m1b.json" 2>/dev/null; rc=$?
M1B=$(jd "$S/m1b.json" serial_number); say M1b.issue rc=$rc
bao delete pki/issuer/r72gone2 >/dev/null 2>&1; say M1b.delete-issuer rc=$?
bao write -format=json pki/revoke serial_number="$M1B" >"$S/m1brev.json" 2>"$S/m1brev.err"; say M1b.revoke-after-delete rc=$? revocation_time=$(jd "$S/m1brev.json" revocation_time)
default_crl "$S/m1b-default.pem"; say M1b.default-crl rc=$? serial_on_default_crl="$(crl_has "$S/m1b-default.pem" "$M1B")"
bao read pki/crl/rotate >/dev/null 2>&1; default_crl "$S/m1b-default-rot.pem"; say M1b.default-crl-after-rotate rc=$? serial_on_default_crl="$(crl_has "$S/m1b-default-rot.pem" "$M1B")"

# ==== M2 permit-outlive ======================================================================
for beh in permit truncate err; do
  n="r72s$beh"
  bao write -format=json pki/root/generate/internal common_name="$n.r72.test" ttl=2h issuer_name="$n" >"$S/$n.json" 2>/dev/null
  jd "$S/$n.json" certificate >"$S/$n.pem"
  bao write pki/issuer/"$n" leaf_not_after_behavior="$beh" issuer_name="$n" >/dev/null 2>&1; say M2.$beh set-behavior rc=$?
  got=$(issuer_field "$n" leaf_not_after_behavior); name_after=$(issuer_field "$n" issuer_name)
  bao write pki/roles/p$beh issuer_ref="$n" allowed_domains=r72.test allow_subdomains=true max_ttl=87600h >/dev/null 2>&1
  bao write -format=json pki/issue/p$beh common_name="leaf-$beh.r72.test" ttl=10h >"$S/leaf-$beh.json" 2>"$S/leaf-$beh.err"; rc=$?
  say M2.$beh issue rc=$rc behavior_readback=$got issuer_name_readback=$name_after
  if [ $rc = 0 ]; then
    jd "$S/leaf-$beh.json" certificate >"$S/leaf-$beh.pem"
    le=$(cert_end "$S/leaf-$beh.pem"); ie=$(cert_end "$S/$n.pem")
    say M2.$beh notafter leaf_minus_issuer_s=$((le-ie)) leaf_outlives_issuer=$([ "$le" -gt "$ie" ] && echo yes || echo no)
    openssl verify -CAfile "$S/$n.pem" -attime $((ie-60)) "$S/leaf-$beh.pem" >"$S/v1.txt" 2>&1; say M2.$beh verify-before-issuer-end rc=$? out="$(tail -1 "$S/v1.txt")"
    openssl verify -CAfile "$S/$n.pem" -attime $((ie+60)) "$S/leaf-$beh.pem" >"$S/v2.txt" 2>&1; say M2.$beh verify-after-issuer-end rc=$? out="$(grep -o 'certificate has expired' "$S/v2.txt" | head -1)$(tail -1 "$S/v2.txt" | grep -qi expired && true)"
    cp "$S/leaf-$beh.pem" "$OUT/m2-leaf-$beh.pem"
  fi
  cp "$S/$n.pem" "$OUT/m2-issuer-$beh.pem"
done

# ==== M3 issuer-revoke ========================================================================
bao write -format=json pki/intermediate/generate/internal common_name=inter.r72.test >"$S/icsr.json" 2>/dev/null
jd "$S/icsr.json" csr >"$S/inter.csr"; say M3.csr-generate rc=$? csr_bytes=$(wc -c <"$S/inter.csr")
bao write -format=json pki/issuer/r72root/sign-intermediate csr=@"$S/inter.csr" common_name=inter.r72.test ttl=24h >"$S/isign.json" 2>"$S/isign.err"; say M3.sign-intermediate rc=$?
jd "$S/isign.json" certificate >"$S/inter.pem"
bao write -format=json pki/intermediate/set-signed certificate=@"$S/inter.pem" >"$S/iset.json" 2>"$S/iset.err"; say M3.set-signed rc=$?
bao list -format=json pki/issuers >"$S/ilist.json" 2>/dev/null; say M3.list-issuers-count=$(python3 -c 'import json,sys
try: print(len(json.load(open(sys.argv[1])).get("data",{}).get("keys",[])))
except Exception: print(0)' "$S/ilist.json")
INTER=$(python3 -c 'import json,sys
try: d=json.load(open(sys.argv[1])).get("data") or {}; print((d.get("imported_issuers") or [""])[0])
except Exception: print("")' "$S/iset.json")
say M3.inter-id-from-set-signed present=$([ -n "$INTER" ] && echo yes || echo no) err="$(head -c 100 "$S/iset.err" | tr '\n' ' ')"
bao read -format=json pki/issuer/$INTER >"$S/ir.json" 2>/dev/null; say M3.inter-readback rc=$? usage=$(jd "$S/ir.json" usage) revocation_time=$(jd "$S/ir.json" revocation_time)
cp "$S/inter.pem" "$OUT/m3-intermediate.pem"
ISER=$(cert_serial "$S/inter.pem")
bao write pki/roles/r72i issuer_ref="$INTER" allowed_domains=r72.test allow_subdomains=true max_ttl=12h >/dev/null 2>&1
bao write -format=json pki/issue/r72i common_name=pre.r72.test ttl=1h >"$S/pre.json" 2>/dev/null; say M3.issue-before-revoke rc=$?
default_crl "$S/m3-default-pre.pem"; say M3.pre-default-crl rc=$? inter_serial_on_default="$(crl_has "$S/m3-default-pre.pem" "$ISER")"
issuer_crl "$INTER" "$S/m3-inter-pre.pem"; say M3.pre-inter-crl rc=$? inter_serial_on_own="$(crl_has "$S/m3-inter-pre.pem" "$ISER")"

bao write -force -format=json pki/issuer/$INTER/revoke >"$S/irev.json" 2>"$S/irev.err"; say M3.revoke-issuer rc=$? out="$(head -c 120 "$S/irev.err" | tr '\n' ' ')"
bao read -format=json pki/issuer/$INTER >"$S/ir2.json" 2>/dev/null; say M3.post-revoke-readback rc=$? usage=$(jd "$S/ir2.json" usage) revocation_time=$(jd "$S/ir2.json" revocation_time)
default_crl "$S/m3-default-post.pem"; say M3.post-revoke-default-crl rc=$? inter_serial_on_default="$(crl_has "$S/m3-default-post.pem" "$ISER")"
cp "$S/m3-default-post.pem" "$OUT/m3-default-crl-after-issuer-revoke.pem"
issuer_crl "$INTER" "$S/m3-inter-post.pem"; say M3.post-revoke-inter-crl-read rc=$? inter_serial_on_own="$(crl_has "$S/m3-inter-post.pem" "$ISER")"
bao write -format=json pki/issue/r72i common_name=post.r72.test ttl=1h >"$S/post.json" 2>"$S/post.err"; say M3.issue-after-revoke rc=$? err="$(head -c 100 "$S/post.err" | tr '\n' ' ')"

# control: self-signed root revoked — no parent in the mount signed it
bao write -format=json pki/root/generate/internal common_name=self.r72.test ttl=87600h issuer_name=r72self >"$S/self.json" 2>/dev/null
SSER=$(cert_serial "$(jd "$S/self.json" certificate > "$S/self.pem"; echo "$S/self.pem")")
bao write -force pki/issuer/r72self/revoke >/dev/null 2>&1; say M3.control-self-root-revoke rc=$?
default_crl "$S/m3-default-self.pem"; say M3.control-default-crl rc=$? self_serial_on_default="$(crl_has "$S/m3-default-self.pem" "$SSER")"

# artifact leg: the default CRL is signed by the default root (verify under root.pem). Output "verify OK" from openssl is the receipt.
cp "$S/root.pem" "$OUT/m-root.pem"
for f in m1-default-crl-after-delete m1-default-crl-after-rotate m3-default-crl-after-issuer-revoke; do
  v=$(openssl crl -in "$OUT/$f.pem" -CAfile "$S/root.pem" -noout 2>&1 | grep -o 'verify OK\|verify failure' | head -1)
  say ART.$f.signed-by-default-root result="${v:-none}"
done

exit 0
