#!/usr/bin/env bash
# plans/round-71-c1.sh — FROZEN round-71 C1 counter (axis depth): the lane executes four OpenBao
# PKI issuer and revocation-channel mechanics (T6 notafter-truncate, T7 nondefault-crl,
# T8 ocsp-unauth, T9 revoke-with-key) that its knowledge entry documents, and each verdict is backed
# by public artifacts an independent openssl check accepts (S173 OpenBao PKI considerations).
#
# Predicate (same sentence as plans/round-71.md §C1):
#   C1_PKI_ISSUER_TRIAL: value = number of tests T in {T6..T9} that DISCRIMINATE and whose
#   ARTIFACT check passes, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1 and NOLEAK = 1 and
#   SOURCED = 1, else 0; target 4 (BASE 0).
# - PINS: the bao binary has the pinned sha256 of the official OpenBao v2.7.2 linux_amd64 release
#   binary (same pin as rounds 49-57 and 70); otherwise SETUP, exit 2.
# - Every run (real and shims) puts a wrapper SCRIPT named `bao` first on PATH; the real run's
#   wrapper only execs the binary, so "is bao a script" does not tell real from shim (r70 F2 class).
# - DISCRIMINATE(T): the measured tree's `corpus/openbao-pki-issuer-trial.sh`, run under `env -i`
#   with PATH = <wrapper dir>:/usr/bin:/bin and `--work W --evidence E`, prints exactly one
#   `TRIAL T HOLDS ...` line with the real binary, exactly one `TRIAL T BROKEN ...` line under T's
#   falsifier shim, and exactly one `TRIAL T HOLDS ...` line under each of the other three shims,
#   AND `corpus/knowledge/openbao-pki-issuer-revocation-channels.md` has a `## Measured (round 71`
#   section holding a line that starts `- T<n> ` and names `OpenBao 2.7.2`. Shims (each passes
#   everything it does not name to the real binary):
#     SH6 issuer-drops-leaf_not_after_behavior (`write */issuer/*` loses `leaf_not_after_behavior=`)
#     SH7 role-drops-issuer_ref                 (`write */roles/*` loses `issuer_ref=`)
#     SH8 crl-config-disables-ocsp              (`write */config/crl` gets `ocsp_disable=true`)
#     SH9 revoke-with-key-drops-private_key     (`write */revoke-with-key` loses `private_key=`)
# - ARTIFACT(T), read from the REAL run's evidence dir only, by this counter with openssl:
#     T6 t6-leaf.pem verifies against t6-issuer.pem; leaf notAfter == issuer notAfter; the
#        issuer's own lifetime is < 36000 s (so a 10h leaf could not fit unclipped).
#     T7 t7-leaf.pem verifies against t7-second.pem and NOT against t7-default.pem; the two
#        issuer certs differ; t7-second-crl.pem verifies against t7-second.pem and lists the leaf
#        serial; t7-default-crl.pem verifies against t7-default.pem and does not list it.
#     T8 t8-revoked.pem and t8-good.pem verify against t8-issuer.pem with different serials;
#        `openssl ocsp -respin` on t8-revoked.ocsp.der (resp. t8-good.ocsp.der) verifies against
#        t8-issuer.pem and reports `revoked` (resp. `good`) for that leaf.
#     T9 t9-leaf.pem verifies against t9-issuer.pem; t9-crl.pem verifies against t9-issuer.pem
#        and lists the leaf serial.
# - SETUP_OK: with no bao on PATH the trial exits 2 and prints no HOLDS line.
# - NOSECRET: no run's stdout/stderr and no file in any run's evidence dir carries `PRIVATE KEY`,
#   a token-shaped string (ERE `(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}`) or
#   `r71-[0-9a-f]{24}`.
# - NOLEAK: after every run, no live process carries this counter's per-run nonce in its
#   environment.
# - SOURCED: the entry's header carries a `source:` line naming S173, and corpus/SOURCES.md has an
#   S173 registry row with status `mined` whose URL is https://openbao.org/docs/secrets/pki/considerations/.
# - Fail closed: an absent trial reads `value=0 absent=1` (rc 1; the BASE state, printed). A real
#   run with no final `OPENBAO_PKI_ISSUER_TRIAL: ` line reads `value=0 reason=real-run-no-final-line`
#   (rc 1). Counter environment faults are SETUP (rc 2).
# - Exit: 0 iff value=4; 1 otherwise; 2 SETUP.
# - Named ceiling: a same-uid trial can read the wrapper bytes to learn which shim is active, and
#   can mint look-alike artifacts with openssl; neither proves OpenBao produced them. The attack
#   wave reads the landed trial for any read of the wrapper's bytes or any local CA minting.
#
# Usage: bash plans/round-71-c1.sh <rev>        (measures the committed tree of <rev> in this repo)
#        bash plans/round-71-c1.sh --tree DIR   (controls: measures a fixture tree)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r71/c1-counter.XXXXXX, removed on exit.
set -u
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R71_BAO:-$HOME/.local/bin/bao}"
S173_URL='https://openbao.org/docs/secrets/pki/considerations/'

setup() { echo "C1_PKI_ISSUER_TRIAL: SETUP reason=$1"; exit 2; }

[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r71"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c1-counter.XXXXXX") || setup mktemp
case "$W" in "$SCR"/c1-counter.*) ;; *) setup scratch-path;; esac
trap 'rm -rf -- "$W"' EXIT

if [ "$1" = "--tree" ]; then
  [ -d "${2:-}" ] || setup tree-missing
  T=$(cd "$2" && pwd)
else
  git -C "$LANE" rev-parse --verify -q "$1^{commit}" >/dev/null || setup bad-rev
  mkdir -p "$W/tree" && git -C "$LANE" archive "$1" | tar -x -C "$W/tree" || setup archive
  T="$W/tree"
fi

[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
pins=1
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done
command -v openssl >/dev/null 2>&1 || setup openssl-missing

TRIAL="$T/corpus/openbao-pki-issuer-trial.sh"
if [ ! -f "$TRIAL" ]; then
  echo "C1_PKI_ISSUER_TRIAL: value=0 absent=1 pins=$pins"; exit 1
fi

mkdir -p "$W/home" "$W/tmp" "$W/bin/none"
mkshim() { # name body ; body sees REAL and "$@" (the client argv)
  mkdir -p "$W/bin/$1"
  { printf '#!/bin/bash\nREAL=%q\n' "$BAO_BIN"
    # P = the first non-flag operand after `write` (the API path), empty otherwise.
    printf '%s\n' 'P=""; if [ "${1:-}" = write ]; then for x in "${@:2}"; do case "$x" in -*) ;; *) P=$x; break;; esac; done; fi'
    printf '%s\n' "$2"; } > "$W/bin/$1/bao"
  chmod 755 "$W/bin/$1/bao"
}
mkshim real 'exec "$REAL" "$@"'
mkshim sh6 'case "$P" in */issuer/*) a=(); for x in "$@"; do case "$x" in leaf_not_after_behavior=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}";; esac
exec "$REAL" "$@"'
mkshim sh7 'case "$P" in */roles/*) a=(); for x in "$@"; do case "$x" in issuer_ref=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}";; esac
exec "$REAL" "$@"'
mkshim sh8 'case "$P" in */config/crl) a=(); for x in "$@"; do case "$x" in ocsp_disable=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}" ocsp_disable=true;; esac
exec "$REAL" "$@"'
mkshim sh9 'case "$P" in */revoke-with-key) a=(); for x in "$@"; do case "$x" in private_key=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}";; esac
exec "$REAL" "$@"'

leak=0
run() { # bindir outfile -> rc ; evidence dir = $W/ev-<bindir>
  local nonce rc; nonce="r71c1n$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
  mkdir -p "$W/ev-$1"
  env -i HOME="$W/home" PATH="$W/bin/$1:/usr/bin:/bin" TMPDIR="$W/tmp" LANG=C R71_C1_NONCE="$nonce" \
    timeout 600 bash "$TRIAL" --work "$W/tmp" --evidence "$W/ev-$1" > "$2" 2>"$2.err"
  rc=$?
  sleep 1
  for e in /proc/[0-9]*/environ; do
    if { tr '\0' '\n' < "$e"; } 2>/dev/null | grep -qx "R71_C1_NONCE=$nonce"; then leak=1; echo "leak $1 ${e%/environ}" >> "$W/leaks"; fi
  done
  return $rc
}
# verdict OUT ID -> HOLDS|BROKEN|ERROR|NONE|DUP
verdict() {
  local n; n=$(grep -cE "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1")
  if [ "$n" -eq 0 ]; then echo NONE; elif [ "$n" -gt 1 ]; then echo DUP
  else grep -E "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1" | awk '{print $3}'; fi
}

run real "$W/real.out"; real_rc=$?
if ! grep -q '^OPENBAO_PKI_ISSUER_TRIAL: ' "$W/real.out"; then
  echo "C1_PKI_ISSUER_TRIAL: value=0 reason=real-run-no-final-line real_rc=$real_rc pins=$pins"; exit 1
fi
run none "$W/none.out"; none_rc=$?
setup_ok=0
if [ $none_rc -eq 2 ] && ! grep -qE '^TRIAL T[6-9] HOLDS' "$W/none.out"; then setup_ok=1; fi
for i in 6 7 8 9; do run "sh$i" "$W/sh$i.out"; done

# --- ARTIFACT checks on the real run's evidence (openssl only; files are never trusted blind)
E="$W/ev-real"
f() { [ -f "$E/$1" ] && [ ! -L "$E/$1" ]; }
vfy() { openssl verify -CAfile "$E/$1" "$E/$2" >/dev/null 2>&1; }          # issuer leaf
crlok() { openssl crl -in "$E/$1" -CAfile "$E/$2" -noout 2>&1 | grep -qx 'verify OK'; } # crl issuer
ser() { openssl x509 -in "$E/$1" -noout -serial 2>/dev/null | sed -n 's/^serial=//p'; }
lists() { # crl serial -> 0 if listed
  [ -n "$2" ] && openssl crl -in "$E/$1" -noout -text 2>/dev/null | grep -q "Serial Number: $2\$"
}
enddate() { date -u -d "$(openssl x509 -in "$E/$1" -noout -enddate 2>/dev/null | cut -d= -f2)" +%s 2>/dev/null; }
startdate() { date -u -d "$(openssl x509 -in "$E/$1" -noout -startdate 2>/dev/null | cut -d= -f2)" +%s 2>/dev/null; }
fpr() { openssl x509 -in "$E/$1" -noout -fingerprint -sha256 2>/dev/null; }
ocsp_is() { # der issuer leaf word -> 0 if verified response says <word> for leaf
  local out; out=$(openssl ocsp -respin "$E/$1" -issuer "$E/$2" -VAfile "$E/$2" -cert "$E/$3" -no_nonce 2>&1) || return 1
  printf '%s\n' "$out" | grep -qx 'Response verify OK' && printf '%s\n' "$out" | grep -qx "$E/$3: $4"
}
art6() {
  f t6-leaf.pem && f t6-issuer.pem && vfy t6-issuer.pem t6-leaf.pem || return 1
  local le ie is; le=$(enddate t6-leaf.pem); ie=$(enddate t6-issuer.pem); is=$(startdate t6-issuer.pem)
  [ -n "$le" ] && [ -n "$ie" ] && [ -n "$is" ] && [ "$le" = "$ie" ] && [ $((ie - is)) -lt 36000 ]
}
art7() {
  local x; for x in t7-leaf.pem t7-second.pem t7-default.pem t7-second-crl.pem t7-default-crl.pem; do f "$x" || return 1; done
  vfy t7-second.pem t7-leaf.pem && ! vfy t7-default.pem t7-leaf.pem || return 1
  [ "$(fpr t7-second.pem)" != "$(fpr t7-default.pem)" ] || return 1
  crlok t7-second-crl.pem t7-second.pem && crlok t7-default-crl.pem t7-default.pem || return 1
  local s; s=$(ser t7-leaf.pem)
  lists t7-second-crl.pem "$s" && ! lists t7-default-crl.pem "$s"
}
art8() {
  local x; for x in t8-issuer.pem t8-revoked.pem t8-good.pem t8-revoked.ocsp.der t8-good.ocsp.der; do f "$x" || return 1; done
  vfy t8-issuer.pem t8-revoked.pem && vfy t8-issuer.pem t8-good.pem || return 1
  [ -n "$(ser t8-revoked.pem)" ] && [ "$(ser t8-revoked.pem)" != "$(ser t8-good.pem)" ] || return 1
  ocsp_is t8-revoked.ocsp.der t8-issuer.pem t8-revoked.pem revoked && ocsp_is t8-good.ocsp.der t8-issuer.pem t8-good.pem good
}
art9() {
  local x; for x in t9-leaf.pem t9-issuer.pem t9-crl.pem; do f "$x" || return 1; done
  vfy t9-issuer.pem t9-leaf.pem && crlok t9-crl.pem t9-issuer.pem && lists t9-crl.pem "$(ser t9-leaf.pem)"
}

ENTRY="$T/corpus/knowledge/openbao-pki-issuer-revocation-channels.md"
entry_line() { # id -> 1/0
  [ -f "$ENTRY" ] || { echo 0; return; }
  awk -v id="$1" '
    /^## / { insec = ($0 ~ /^## Measured \(round 71/) ; next }
    insec && index($0, "- " id " ") == 1 && index($0, "OpenBao 2.7.2") > 0 { found = 1 }
    END { print found ? 1 : 0 }' "$ENTRY"
}
sourced=0
if [ -f "$ENTRY" ] && grep -qE '^source:.*S173([^0-9]|$)' "$ENTRY" \
   && grep -E '^ {0,3}\| *S173 *\|' "$T/corpus/SOURCES.md" 2>/dev/null | grep -qF "$S173_URL" \
   && grep -E '^ {0,3}\| *S173 *\|' "$T/corpus/SOURCES.md" 2>/dev/null | awk -F'|' '{gsub(/ /,"",$9); print $9}' | grep -qx mined; then
  sourced=1
fi

value=0; detail=""
for i in 6 7 8 9; do
  id="T$i"
  rv=$(verdict "$W/real.out" "$id"); sv=$(verdict "$W/sh$i.out" "$id"); ev=$(entry_line "$id")
  spec=1
  for j in 6 7 8 9; do [ "$j" = "$i" ] && continue; [ "$(verdict "$W/sh$j.out" "$id")" = HOLDS ] || spec=0; done
  art=0; "art$i" && art=1
  ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$spec" = 1 ] && [ "$ev" = 1 ] && [ "$art" = 1 ] && ok=1
  value=$((value + ok)); detail="$detail $id:real=$rv,shim=$sv,spec=$spec,entry=$ev,art=$art,ok=$ok"
done
nosecret=1
if cat "$W"/*.out "$W"/*.out.err 2>/dev/null | grep -qaE 'PRIVATE KEY|(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r71-[0-9a-f]{24}'; then nosecret=0; fi
if grep -rlaE 'PRIVATE KEY|(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r71-[0-9a-f]{24}' "$W"/ev-* >/dev/null 2>&1; then nosecret=0; fi
noleak=$((1 - leak))

final=$value
[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $noleak -eq 1 ] && [ $sourced -eq 1 ] && [ $pins -eq 1 ] || final=0
echo "C1_PKI_ISSUER_TRIAL: value=$final discriminating=$value pins=$pins setup_ok=$setup_ok nosecret=$nosecret noleak=$noleak sourced=$sourced real_rc=$real_rc none_rc=$none_rc$detail"
[ "$final" = 4 ] && exit 0
exit 1
