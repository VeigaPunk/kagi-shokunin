#!/usr/bin/env bash
# plans/round-51-c1.sh — FROZEN round-51 C1 counter (capability acquisition, axis operability):
# the lane can execute the OpenBao response-wrapping mechanics the OpenBao "Response wrapping"
# concepts page documents (registry row with source URL https://openbao.org/docs/concepts/response-wrapping/).
#
# Predicate (same sentence as plans/round-51.md §C1):
#   C1_OPENBAO_WRAP: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
#   SETUP_OK = 1 and NOSECRET = 1 and SRC = 1, else 0; target 5 (BASE 0, trial absent).
# - PINS: the bao binary this counter wraps has the pinned sha256 of the official OpenBao v2.7.2
#   linux_amd64 release binary, and no `bao` exists in /usr/bin or /bin; otherwise SETUP, exit 2.
# - DISCRIMINATE(T): the measured tree's `corpus/openbao-wrap-trial.sh`, run under `env -i` with
#   PATH = <run bin dir>:/usr/bin:/bin, prints exactly one `TRIAL T HOLDS ...` line in the real run
#   AND exactly one `TRIAL T BROKEN ...` line under T's designated falsifier (SH1 unwrap-replays-
#   the-first-answer, SH2 kv-get-wrap-ttl-forced-to-600s, SH3 lookup-also-unwraps, SH4 rewrap-
#   echoes-the-old-token, SH5 lookup-replays-the-first-answer) AND
#   `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` has a `## Measured (round 51` section
#   holding a line that starts `- T<n> ` and names `OpenBao 2.7.2`.
# - Path-blind runs (round-50 closure D3): every run's bin dir has a fresh random hex name, holds a
#   `bao` that is byte-identical across the six runs (one dispatcher reading a sibling `.mode`
#   file), and gets its own fresh HOME, TMPDIR and --work dir; the six runs execute in a random order.
# - SETUP_OK: with no bao on PATH the trial exits 2 and prints no HOLDS line.
# - NOSECRET: no run's stdout/stderr carries a token-shaped string (ERE
#   `(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}` or `r51-[0-9a-f]{24}`).
# - SRC: the measured tree's `corpus/SOURCES.md` has exactly one registry row whose source cell
#   contains `https://openbao.org/docs/concepts/response-wrapping/` and whose status cell is `mined`,
#   and the trial's first 20 lines name that row's id.
# - Fail closed: a real run with no final `OPENBAO_WRAP_TRIAL: ` line is SETUP (exit 2). An absent
#   trial script reads `value=0 absent=1` (exit 0): that is the BASE state, not a producer failure.
#
# Named ceilings: a trial that reads the `.mode` file beside its bao, or keeps state outside its own
# HOME/TMPDIR/--work dirs across runs, can still tell the runs apart (control F-MODE reads 5).
#
# Usage: bash plans/round-51-c1.sh <rev>        (measures the committed tree of <rev> in this repo)
#        bash plans/round-51-c1.sh --tree DIR   (controls only: measures a fixture tree)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r51/c1-counter.XXXXXX, removed on exit.
set -u
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R51_BAO:-$HOME/.local/bin/bao}"
SRC_URL='https://openbao.org/docs/concepts/response-wrapping/'

setup() { echo "C1_OPENBAO_WRAP: SETUP reason=$1"; exit 2; }

[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r51"
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
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done
pins=1

TRIAL="$T/corpus/openbao-wrap-trial.sh"
if [ ! -f "$TRIAL" ]; then
  echo "C1_OPENBAO_WRAP: value=0 absent=1 pins=$pins"; exit 0
fi

# SRC
src=0; srcid=""
if [ -f "$T/corpus/SOURCES.md" ]; then
  rows=$(awk -F'|' -v u="$SRC_URL" '/^ {0,3}\| S[0-9]+ /{ s=$3; st=$9; gsub(/^ +| +$/,"",st); id=$2; gsub(/ /,"",id);
           if (index(s,u)>0) print id "\t" st }' "$T/corpus/SOURCES.md")
  n=$(printf '%s' "$rows" | grep -c . || true)
  if [ "$n" = 1 ] && [ "$(printf '%s' "$rows" | cut -f2)" = mined ]; then
    srcid=$(printf '%s' "$rows" | cut -f1)
    head -n 20 "$TRIAL" | grep -qw -- "$srcid" && src=1
  fi
fi

rhex() { od -An -N8 -tx1 /dev/urandom | tr -d ' \n'; }
# One dispatcher, byte-identical in every run; its behaviour is chosen by the sibling .mode file.
DISPATCH='#!/bin/bash
here=$(cd "$(dirname "$0")" && pwd); mode=$(cat "$here/.mode"); REAL=$(cat "$here/.real")
has() { local x; for x in "${@:2}"; do [ "$x" = "$1" ] && return 0; done; return 1; }
case "$mode" in
sh1) if [ "${1:-}" = unwrap ]; then k=$(printf "%s\0" "$@" | sha256sum | cut -c1-16); mkdir -p "$here/.state"
       if [ -f "$here/.state/$k" ]; then cat "$here/.state/$k"; exit 0; fi
       o=$("$REAL" "$@"); r=$?; [ $r = 0 ] && printf "%s\n" "$o" > "$here/.state/$k"; printf "%s\n" "$o"; exit $r; fi ;;
sh2) if [ "${1:-}" = kv ] && [ "${2:-}" = get ]; then a=(); for x in "$@"; do case "$x" in -wrap-ttl=*) a+=("-wrap-ttl=600s");; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi ;;
sh3) if [ "${1:-}" = write ] && has sys/wrapping/lookup "$@"; then o=$("$REAL" "$@"); r=$?; t=""
       for x in "$@"; do case "$x" in token=*) t=${x#token=};; esac; done
       [ -n "$t" ] && env -u BAO_TOKEN "$REAL" unwrap "$t" >/dev/null 2>&1; printf "%s\n" "$o"; exit $r; fi ;;
sh4) if [ "${1:-}" = write ] && has sys/wrapping/rewrap "$@"; then t=""
       for x in "$@"; do case "$x" in token=*) t=${x#token=};; esac; done
       printf "{\"wrap_info\":{\"token\":\"%s\"}}\n" "$t"; exit 0; fi ;;
sh5) if [ "${1:-}" = write ] && has sys/wrapping/lookup "$@"; then mkdir -p "$here/.state"
       if [ -f "$here/.state/first" ]; then cat "$here/.state/first"; exit 0; fi
       o=$("$REAL" "$@"); r=$?; [ $r = 0 ] && printf "%s\n" "$o" > "$here/.state/first"; printf "%s\n" "$o"; exit $r; fi ;;
esac
exec "$REAL" "$@"'

declare -A BIN OUT
for m in real none sh1 sh2 sh3 sh4 sh5; do
  d="$W/$(rhex)"; mkdir -p "$d/bin" "$d/home" "$d/tmp" "$d/work"
  if [ "$m" != none ]; then
    printf '%s\n' "$DISPATCH" > "$d/bin/bao"; chmod 755 "$d/bin/bao"
    printf '%s\n' "$m" > "$d/bin/.mode"; printf '%s\n' "$BAO_BIN" > "$d/bin/.real"
  fi
  BIN[$m]="$d"; OUT[$m]="$W/out.$m"
done

run() { # mode -> rc
  local d=${BIN[$1]}
  env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
    timeout 600 bash "$TRIAL" --work "$d/work" > "${OUT[$1]}" 2>"${OUT[$1]}.err"
}
# verdict OUT ID -> HOLDS|BROKEN|ERROR|NONE|DUP
verdict() {
  local n; n=$(grep -cE "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1")
  if [ "$n" -eq 0 ]; then echo NONE; elif [ "$n" -gt 1 ]; then echo DUP
  else grep -E "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1" | awk '{print $3}'; fi
}

declare -A RC
for m in $(printf '%s\n' real none sh1 sh2 sh3 sh4 sh5 | shuf); do run "$m"; RC[$m]=$?; done
real_rc=${RC[real]}; none_rc=${RC[none]}
grep -q '^OPENBAO_WRAP_TRIAL: ' "${OUT[real]}" || setup "real-run-no-final-line(rc=$real_rc)"
setup_ok=0
if [ "$none_rc" -eq 2 ] && ! grep -qE '^TRIAL T[1-5] HOLDS' "${OUT[none]}"; then setup_ok=1; fi

ENTRY="$T/corpus/knowledge/vault-openbao-token-lease-lifecycle.md"
entry_line() { # id -> 1/0
  [ -f "$ENTRY" ] || { echo 0; return; }
  awk -v id="$1" '
    /^## / { insec = ($0 ~ /^## Measured \(round 51/) ; next }
    insec && index($0, "- " id " ") == 1 && index($0, "OpenBao 2.7.2") > 0 { found = 1 }
    END { print found ? 1 : 0 }' "$ENTRY"
}

value=0; detail=""
for i in 1 2 3 4 5; do
  id="T$i"
  rv=$(verdict "${OUT[real]}" "$id"); sv=$(verdict "${OUT[sh$i]}" "$id"); ev=$(entry_line "$id")
  ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$ev" = 1 ] && ok=1
  value=$((value + ok)); detail="$detail $id:real=$rv,shim=$sv,entry=$ev,ok=$ok"
done
nosecret=1
if cat "$W"/out.* 2>/dev/null | grep -qE '(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r51-[0-9a-f]{24}'; then nosecret=0; fi

final=$value
[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] && [ $src -eq 1 ] || final=0
echo "C1_OPENBAO_WRAP: value=$final discriminating=$value pins=$pins setup_ok=$setup_ok nosecret=$nosecret src=$src${srcid:+($srcid)} real_rc=$real_rc none_rc=$none_rc$detail"
exit 0
