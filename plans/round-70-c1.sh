#!/usr/bin/env bash
# plans/round-70-c1.sh — FROZEN round-70 C1 counter (capability acquisition, axis coverage):
# the lane can execute the OpenBao PKI certificate-lifecycle mechanics its knowledge entry
# documents (S170 OpenBao PKI secrets-engine API docs, opened 2026-11-09).
#
# Predicate (same sentence as plans/round-70.md §C1):
#   C1_PKI_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
#   SETUP_OK = 1 and NOSECRET = 1 and NOLEAK = 1 and SOURCED = 1, else 0; target 5 (BASE 0).
# - PINS: the bao binary this counter puts on PATH has the pinned sha256 of the official OpenBao
#   v2.7.2 linux_amd64 release binary (same pin as rounds 49-57); otherwise SETUP, exit 2.
# - DISCRIMINATE(T): the measured tree's `corpus/openbao-pki-trial.sh`, run under `env -i` with
#   PATH = <counter bin dir>:/usr/bin:/bin, prints exactly one `TRIAL T HOLDS ...` line with the
#   real binary, exactly one `TRIAL T BROKEN ...` line under T's designated falsifier shim, and
#   exactly one `TRIAL T HOLDS ...` line under each of the other four shims (specificity: a shim
#   breaks its own test and no other), AND `corpus/knowledge/openbao-pki-certificate-lifecycle.md`
#   has a `## Measured (round 70` section holding a line that starts `- T<n> ` and names
#   `OpenBao 2.7.2`. Shims (each passes everything it does not name to the real binary):
#     SH1 root-internal-becomes-exported  (`write */root/generate/internal` -> `.../exported`)
#     SH2 role-drops-max_ttl              (`write */roles/*` loses every `max_ttl=` argument)
#     SH3 role-allows-any-name            (`write */roles/*` gains `allow_any_name=true`)
#     SH4 revoke-swallowed                (`write */revoke` never reaches the server; prints success)
#     SH5 role-drops-no_store             (`write */roles/*` loses every `no_store=` argument)
# - SETUP_OK: with no bao on PATH the trial exits 2 and prints no HOLDS line.
# - NOSECRET: no run's stdout/stderr carries a PEM private key (`PRIVATE KEY`), a token-shaped
#   string (ERE `(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}`) or `r70-[0-9a-f]{24}`.
# - NOLEAK: after every run, no live process carries this counter's per-run nonce in its
#   environment (a leaked `bao server -dev` fails the leg).
# - SOURCED: the entry's header carries a `source:` line naming S170, and corpus/SOURCES.md has an
#   S170 registry row with status `mined`.
# - Fail closed: an absent trial reads `value=0 absent=1` (rc 1; the BASE state, printed, never a
#   silent zero). A real run with no final `OPENBAO_PKI_TRIAL: ` line reads
#   `value=0 reason=real-run-no-final-line` (rc 1). Counter environment faults are SETUP (rc 2).
# - Exit: 0 iff value=5; 1 otherwise; 2 SETUP.
# - Named ceiling: a trial that reads the shim's own bytes to choose its verdicts can pass the
#   specificity leg; the reviewer reads the trial for any read of the `bao` binary's bytes.
#
# Usage: bash plans/round-70-c1.sh <rev>        (measures the committed tree of <rev> in this repo)
#        bash plans/round-70-c1.sh --tree DIR   (controls: measures a fixture tree)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r70/c1-counter.XXXXXX, removed on exit.
set -u
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R70_BAO:-$HOME/.local/bin/bao}"

setup() { echo "C1_PKI_TRIAL: SETUP reason=$1"; exit 2; }

[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r70"
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

TRIAL="$T/corpus/openbao-pki-trial.sh"
if [ ! -f "$TRIAL" ]; then
  echo "C1_PKI_TRIAL: value=0 absent=1 pins=$pins"; exit 1
fi

mkdir -p "$W/home" "$W/tmp" "$W/bin/real" "$W/bin/none"
ln -s "$BAO_BIN" "$W/bin/real/bao"

mkshim() { # name body ; body sees REAL and "$@" (the client argv)
  mkdir -p "$W/bin/$1"
  { printf '#!/bin/bash\nREAL=%q\n' "$BAO_BIN"
    # P = the first non-flag operand after `write` (the API path), empty otherwise.
    printf '%s\n' 'P=""; if [ "${1:-}" = write ]; then for x in "${@:2}"; do case "$x" in -*) ;; *) P=$x; break;; esac; done; fi'
    printf '%s\n' "$2"; } > "$W/bin/$1/bao"
  chmod 755 "$W/bin/$1/bao"
}
mkshim sh1 'case "$P" in */root/generate/internal) a=(); for x in "$@"; do if [ "$x" = "$P" ]; then a+=("${P%/internal}/exported"); else a+=("$x"); fi; done; exec "$REAL" "${a[@]}";; esac
exec "$REAL" "$@"'
mkshim sh2 'case "$P" in */roles/*) a=(); for x in "$@"; do case "$x" in max_ttl=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}";; esac
exec "$REAL" "$@"'
mkshim sh3 'case "$P" in */roles/*) exec "$REAL" "$@" allow_any_name=true;; esac
exec "$REAL" "$@"'
mkshim sh4 'case "$P" in */revoke) j=0; for x in "$@"; do case "$x" in -format=json|--format=json) j=1;; esac; done
  if [ $j = 1 ]; then printf "{\"data\":{\"revocation_time\":1,\"state\":\"revoked\"}}\n"; else printf "Key Value\n--- -----\nrevocation_time 1\nstate revoked\n"; fi; exit 0;; esac
exec "$REAL" "$@"'
mkshim sh5 'case "$P" in */roles/*) a=(); for x in "$@"; do case "$x" in no_store=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}";; esac
exec "$REAL" "$@"'

leak=0
run() { # bindir outfile -> rc
  local nonce rc; nonce="r70c1n$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
  env -i HOME="$W/home" PATH="$W/bin/$1:/usr/bin:/bin" TMPDIR="$W/tmp" LANG=C R70_C1_NONCE="$nonce" \
    timeout 600 bash "$TRIAL" --work "$W/tmp" > "$2" 2>"$2.err"
  rc=$?
  sleep 1
  for e in /proc/[0-9]*/environ; do
    if { tr '\0' '\n' < "$e"; } 2>/dev/null | grep -qx "R70_C1_NONCE=$nonce"; then leak=1; echo "leak $1 ${e%/environ}" >> "$W/leaks"; fi
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
if ! grep -q '^OPENBAO_PKI_TRIAL: ' "$W/real.out"; then
  echo "C1_PKI_TRIAL: value=0 reason=real-run-no-final-line real_rc=$real_rc pins=$pins"; exit 1
fi
run none "$W/none.out"; none_rc=$?
setup_ok=0
if [ $none_rc -eq 2 ] && ! grep -qE '^TRIAL T[1-5] HOLDS' "$W/none.out"; then setup_ok=1; fi
for i in 1 2 3 4 5; do run "sh$i" "$W/sh$i.out"; done

ENTRY="$T/corpus/knowledge/openbao-pki-certificate-lifecycle.md"
entry_line() { # id -> 1/0
  [ -f "$ENTRY" ] || { echo 0; return; }
  awk -v id="$1" '
    /^## / { insec = ($0 ~ /^## Measured \(round 70/) ; next }
    insec && index($0, "- " id " ") == 1 && index($0, "OpenBao 2.7.2") > 0 { found = 1 }
    END { print found ? 1 : 0 }' "$ENTRY"
}
sourced=0
if [ -f "$ENTRY" ] && grep -qE '^source:.*S170([^0-9]|$)' "$ENTRY" \
   && grep -E '^ {0,3}\| *S170 *\|' "$T/corpus/SOURCES.md" 2>/dev/null | awk -F'|' '{gsub(/ /,"",$9); print $9}' | grep -qx mined; then
  sourced=1
fi

value=0; detail=""
for i in 1 2 3 4 5; do
  id="T$i"
  rv=$(verdict "$W/real.out" "$id"); sv=$(verdict "$W/sh$i.out" "$id"); ev=$(entry_line "$id")
  spec=1
  for j in 1 2 3 4 5; do [ "$j" = "$i" ] && continue; [ "$(verdict "$W/sh$j.out" "$id")" = HOLDS ] || spec=0; done
  ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$spec" = 1 ] && [ "$ev" = 1 ] && ok=1
  value=$((value + ok)); detail="$detail $id:real=$rv,shim=$sv,spec=$spec,entry=$ev,ok=$ok"
done
nosecret=1
if cat "$W"/*.out "$W"/*.out.err 2>/dev/null | grep -qE 'PRIVATE KEY|(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r70-[0-9a-f]{24}'; then nosecret=0; fi
noleak=$((1 - leak))

final=$value
[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $noleak -eq 1 ] && [ $sourced -eq 1 ] && [ $pins -eq 1 ] || final=0
echo "C1_PKI_TRIAL: value=$final discriminating=$value pins=$pins setup_ok=$setup_ok nosecret=$nosecret noleak=$noleak sourced=$sourced real_rc=$real_rc none_rc=$none_rc$detail"
[ "$final" = 5 ] && exit 0
exit 1
