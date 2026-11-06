#!/usr/bin/env bash
# plans/round-49-c1.sh — FROZEN round-49 C1 counter (capability acquisition, axis operability):
# the lane can execute the OpenBao token/lease mechanics its knowledge entry documents (S016).
#
# Predicate (same sentence as plans/round-49.md §C1):
#   C1_OPENBAO_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
#   SETUP_OK = 1 and NOSECRET = 1, else 0; target 5.
# - PINS: the bao binary this counter puts on PATH has the pinned sha256 of the official OpenBao
#   v2.7.2 linux_amd64 release binary; otherwise SETUP, exit 2.
# - DISCRIMINATE(T): the measured tree's `corpus/openbao-token-trial.sh`, run under `env -i` with
#   PATH = <counter bin dir>:/usr/bin:/bin, prints exactly one `TRIAL T HOLDS ...` line with the
#   real binary AND exactly one `TRIAL T BROKEN ...` line under T's designated falsifier shim
#   (SH1 token-lookup-always-succeeds, SH2 create-drops-explicit-max-ttl, SH3 create-drops-batch-type,
#   SH4 userpass-login-returns-a-child-token, SH5 create-drops-ttl) AND
#   `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` has a `## Measured (round 49` section
#   holding a line that starts `- T<n> ` and names `OpenBao 2.7.2`.
# - SETUP_OK: with no bao on PATH the trial exits 2 and prints no HOLDS line.
# - NOSECRET: no run's stdout/stderr carries a token-shaped string (ERE
#   `(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9]{20,}` or `r49-[0-9a-f]{24}`) or the word `password=`
#   followed by 32 hex.
# - Fail closed: a real run with no final `OPENBAO_TRIAL: ` line is SETUP (exit 2). An absent trial
#   script reads `value=0 absent=1` (exit 0): that is the BASE state, not a producer failure.
#
# Usage: bash plans/round-49-c1.sh <rev>        (measures the committed tree of <rev> in this repo)
#        bash plans/round-49-c1.sh --tree DIR   (controls only: measures a fixture tree)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r49/c1-counter.XXXXXX, removed on exit.
set -u
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R49_BAO:-$HOME/.local/bin/bao}"

setup() { echo "C1_OPENBAO_TRIAL: SETUP reason=$1"; exit 2; }

[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r49"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c1-counter.XXXXXX") || setup mktemp
trap 'rm -rf -- "$W"' EXIT

if [ "$1" = "--tree" ]; then
  [ -d "${2:-}" ] || setup tree-missing
  T=$(cd "$2" && pwd)
else
  git -C "$LANE" rev-parse --verify -q "$1^{commit}" >/dev/null || setup bad-rev
  mkdir -p "$W/tree" && git -C "$LANE" archive "$1" | tar -x -C "$W/tree" || setup archive
  T="$W/tree"
fi

pins=0
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
pins=1
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done

TRIAL="$T/corpus/openbao-token-trial.sh"
if [ ! -f "$TRIAL" ]; then
  echo "C1_OPENBAO_TRIAL: value=0 absent=1 pins=$pins"; exit 0
fi

mkdir -p "$W/home" "$W/tmp" "$W/bin/real" "$W/bin/none"
ln -s "$BAO_BIN" "$W/bin/real/bao"

mkshim() { # name body ; body sees REAL and "$@" (the client argv)
  mkdir -p "$W/bin/$1"
  { printf '#!/bin/bash\nREAL=%q\n' "$BAO_BIN"; printf '%s\n' "$2"; } > "$W/bin/$1/bao"
  chmod 755 "$W/bin/$1/bao"
}
# Every shim passes `server`, `status`, `version` and everything it does not name to the real binary.
# SH1 (T1): `token lookup` always succeeds (an expired token still reads as alive).
mkshim sh1 'if [ "${1:-}" = token ] && [ "${2:-}" = lookup ]; then "$REAL" "$@" >/dev/null 2>&1; echo "{}"; exit 0; fi
exec "$REAL" "$@"'
# SH2 (T2): `token create` drops any -explicit-max-ttl argument (no hard cap is set).
mkshim sh2 'if [ "${1:-}" = token ] && [ "${2:-}" = create ]; then a=(); for x in "$@"; do case "$x" in -explicit-max-ttl=*|--explicit-max-ttl=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi
exec "$REAL" "$@"'
# SH3 (T3): `token create` drops -type=batch (a service token is created instead).
mkshim sh3 'if [ "${1:-}" = token ] && [ "${2:-}" = create ]; then a=(); for x in "$@"; do case "$x" in -type=batch|--type=batch) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi
exec "$REAL" "$@"'
# SH4 (T4): a userpass `login` returns a child token of the caller'"'"'s BAO_TOKEN instead of the login token.
mkshim sh4 'if [ "${1:-}" = login ]; then "$REAL" "$@" >/dev/null 2>&1 || exit $?; f=0; for x in "$@"; do [ "$x" = "-field=token" ] && f=1; done
  if [ $f = 1 ]; then exec "$REAL" token create -field=token -policy=default -ttl=60s; else exec "$REAL" token create -policy=default -ttl=60s; fi; fi
exec "$REAL" "$@"'
# SH5 (T5): `token create` drops any -ttl argument (the token outlives the lease it issued).
mkshim sh5 'if [ "${1:-}" = token ] && [ "${2:-}" = create ]; then a=(); for x in "$@"; do case "$x" in -ttl=*|--ttl=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi
exec "$REAL" "$@"'

run() { # bindir outfile -> rc
  env -i HOME="$W/home" PATH="$W/bin/$1:/usr/bin:/bin" TMPDIR="$W/tmp" LANG=C \
    timeout 600 bash "$TRIAL" --work "$W/tmp" > "$2" 2>"$2.err"
}
# verdict OUT ID -> HOLDS|BROKEN|ERROR|NONE|DUP
verdict() {
  local n; n=$(grep -cE "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1")
  if [ "$n" -eq 0 ]; then echo NONE; elif [ "$n" -gt 1 ]; then echo DUP
  else grep -E "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1" | awk '{print $3}'; fi
}

run real "$W/real.out"; real_rc=$?
grep -q '^OPENBAO_TRIAL: ' "$W/real.out" || setup "real-run-no-final-line(rc=$real_rc)"
run none "$W/none.out"; none_rc=$?
setup_ok=0
if [ $none_rc -eq 2 ] && ! grep -qE '^TRIAL T[1-5] HOLDS' "$W/none.out"; then setup_ok=1; fi

ENTRY="$T/corpus/knowledge/vault-openbao-token-lease-lifecycle.md"
entry_line() { # id -> 1/0
  [ -f "$ENTRY" ] || { echo 0; return; }
  awk -v id="$1" '
    /^## / { insec = ($0 ~ /^## Measured \(round 49/) ; next }
    insec && index($0, "- " id " ") == 1 && index($0, "OpenBao 2.7.2") > 0 { found = 1 }
    END { print found ? 1 : 0 }' "$ENTRY"
}

value=0; detail=""
for i in 1 2 3 4 5; do
  id="T$i"
  sd="sh$i"; [ "$i" = 3 ] && sd=sh4; [ "$i" = 4 ] && sd=sh3
  run "$sd" "$W/sh$i.out"
  rv=$(verdict "$W/real.out" "$id"); sv=$(verdict "$W/sh$i.out" "$id"); ev=$(entry_line "$id")
  ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$ev" = 1 ] && ok=1
  value=$((value + ok)); detail="$detail $id:real=$rv,shim=$sv,entry=$ev,ok=$ok"
done
nosecret=1
if cat "$W"/*.out "$W"/*.out.err 2>/dev/null | grep -qE '(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9]{20,}|r49-[0-9a-f]{24}|password=[0-9a-f]{32}'; then nosecret=0; fi

final=$value
[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] || final=0
echo "C1_OPENBAO_TRIAL: value=$final discriminating=$value pins=$pins setup_ok=$setup_ok nosecret=$nosecret real_rc=$real_rc none_rc=$none_rc$detail"
exit 0
