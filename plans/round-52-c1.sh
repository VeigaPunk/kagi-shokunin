#!/usr/bin/env bash
# plans/round-52-c1.sh — FROZEN round-52 C1 counter (capability acquisition, axis operability):
# the lane executes the OpenBao KV v2 version-lifecycle mechanics the OpenBao "KV secrets engine -
# version 2" page documents (registry row with source URL https://openbao.org/docs/secrets/kv/kv-v2/).
# Built on plans/round-51-c1h.sh (routed item 2 of round 51): H1 random log ids, H2 the real run
# twice at random positions, H3 full five-verdict vectors per falsifier; plus NOARGV (round-51
# sentinel S-1).
#
# Predicate (same sentence as plans/round-52.md §C1):
#   C1_OPENBAO_KV: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
#   SETUP_OK = 1 and NOSECRET = 1 and NOARGV = 1 and SRC = 1, else 0; target 5 (BASE 0, trial absent).
# - PINS: the bao binary this counter wraps has the pinned sha256 of the official OpenBao v2.7.2
#   linux_amd64 release binary, and no `bao` exists in /usr/bin or /bin; otherwise SETUP, exit 2.
# - DISCRIMINATE(T): the measured tree's `corpus/openbao-kv-versions-trial.sh`, run under `env -i`
#   with PATH = <run bin dir>:/usr/bin:/bin, prints exactly one `TRIAL T HOLDS ...` line in BOTH real
#   runs AND, under T's designated falsifier, prints the full five-verdict vector EXPECT_VEC[sh<n>]
#   (SH1 `kv put` drops -cas, SH2 `kv undelete` answers success without acting, SH3 `kv destroy`
#   becomes `kv delete`, SH4 `kv metadata put` drops -max-versions, SH5 `kv metadata delete` becomes
#   `kv delete` of the latest version) AND `corpus/knowledge/openbao-kv-v2-version-lifecycle.md` has a
#   `## Measured (round 52` section holding a line that starts `- T<n> ` and names `OpenBao 2.7.2`.
# - Path-blind runs: every run's bin dir has a fresh random hex name and holds a byte-identical
#   dispatcher `bao` (behaviour from a sibling `.mode` file); each run gets its own fresh HOME,
#   TMPDIR and --work dir; stdout/stderr go to $W/log/<random id>; the eight runs (real, real2,
#   none, sh1..sh5) execute in a random order.
# - SETUP_OK: with no bao on PATH the trial exits 2 and prints no HOLDS line.
# - NOSECRET: no run's stdout/stderr carries a token-shaped string (ERE
#   `(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}` or `r52-[0-9a-f]{24}`).
# - NOARGV: in each real run the dispatcher recorded >= 20 bao invocations, and no recorded argv
#   element matches that ERE (no secret on a world-readable command line).
# - SRC: the measured tree's `corpus/SOURCES.md` has exactly one registry row whose source cell
#   contains `https://openbao.org/docs/secrets/kv/kv-v2/` and whose status cell is `mined`, and the
#   trial's first 20 lines name that row's id.
# - Fail closed: a real run with no final `OPENBAO_KV_TRIAL: ` line is SETUP (exit 2). An absent
#   trial script reads `value=0 absent=1` (exit 0): that is the BASE state, not a producer failure.
#
# Named ceilings: a trial that reads the `.mode` file (or the `.argv` log) beside its bao, or keeps
# state outside its own HOME/TMPDIR/--work dirs across runs, can still tell the runs apart; the
# shims are client-side (a lying CLI, not a misbehaving server); one OpenBao version (2.7.2), the
# dev server's KV v2 `secret/` mount only; counter scratch survives a SIGKILL of the counter.
#
# Usage: bash plans/round-52-c1.sh <rev>        (measures the committed tree of <rev> in this repo)
#        bash plans/round-52-c1.sh --tree DIR   (controls only: measures a fixture tree)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r52/c1-counter.XXXXXX, removed on exit.
set -u
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R52_BAO:-$HOME/.local/bin/bao}"
SRC_URL='https://openbao.org/docs/secrets/kv/kv-v2/'
SECRET_ERE='(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r52-[0-9a-f]{24}'

setup() { echo "C1_OPENBAO_KV: SETUP reason=$1"; exit 2; }

[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r52"
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

TRIAL="$T/corpus/openbao-kv-versions-trial.sh"
if [ ! -f "$TRIAL" ]; then
  echo "C1_OPENBAO_KV: value=0 absent=1 pins=$pins"; exit 0
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
# One dispatcher, byte-identical in every run; behaviour from the sibling .mode file. Every call's
# argv is appended to the sibling .argv file (elements joined by US, one call per line).
DISPATCH='#!/bin/bash
here=$(cd "$(dirname "$0")" && pwd); mode=$(cat "$here/.mode"); REAL=$(cat "$here/.real")
( IFS=$'"'"'\x1f'"'"'; printf "%s\n" "$*" ) >> "$here/.argv"
case "$mode" in
sh1) if [ "${1:-}" = kv ] && [ "${2:-}" = put ]; then a=(); for x in "$@"; do case "$x" in -cas=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi ;;
sh2) if [ "${1:-}" = kv ] && [ "${2:-}" = undelete ]; then echo "Success! Data written to: ${@: -1}"; exit 0; fi ;;
sh3) if [ "${1:-}" = kv ] && [ "${2:-}" = destroy ]; then exec "$REAL" kv delete "${@:3}"; fi ;;
sh4) if [ "${1:-}" = kv ] && [ "${2:-}" = metadata ] && [ "${3:-}" = put ]; then a=(); for x in "$@"; do case "$x" in -max-versions=*) ;; *) a+=("$x");; esac; done; exec "$REAL" "${a[@]}"; fi ;;
sh5) if [ "${1:-}" = kv ] && [ "${2:-}" = metadata ] && [ "${3:-}" = delete ]; then exec "$REAL" kv delete "${@: -1}"; fi ;;
esac
exec "$REAL" "$@"'

declare -A BIN OUT
mkdir -p "$W/log" "$W/run"
for m in real real2 none sh1 sh2 sh3 sh4 sh5; do
  d="$W/run/$(rhex)"; mkdir -p "$d/bin" "$d/home" "$d/tmp" "$d/work"
  if [ "$m" != none ]; then
    printf '%s\n' "$DISPATCH" > "$d/bin/bao"; chmod 755 "$d/bin/bao"
    mm=$m; [ "$m" = real2 ] && mm=real
    printf '%s\n' "$mm" > "$d/bin/.mode"; printf '%s\n' "$BAO_BIN" > "$d/bin/.real"
  fi
  BIN[$m]="$d"; OUT[$m]="$W/log/$(rhex)"
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
vec() { local i v=""; for i in 1 2 3 4 5; do v="$v$(verdict "$1" "T$i" | cut -c1)"; done; echo "$v"; }
# EXPECT_VEC: per falsifier, the reference trial's verdict initials for T1..T5 (H=HOLDS, B=BROKEN),
# measured on the reference fixture before the freeze (controls receipt).
declare -A EXPECT_VEC=( [sh1]=BHHHH [sh2]=HBHHH [sh3]=HHBHH [sh4]=HHHBH [sh5]=HHHHB )

declare -A RC
for m in $(printf '%s\n' real real2 none sh1 sh2 sh3 sh4 sh5 | shuf); do run "$m"; RC[$m]=$?; done
real_rc=${RC[real]}; none_rc=${RC[none]}
grep -q '^OPENBAO_KV_TRIAL: ' "${OUT[real]}" || setup "real-run-no-final-line(rc=$real_rc)"
setup_ok=0
if [ "$none_rc" -eq 2 ] && ! grep -qE '^TRIAL T[1-5] HOLDS' "${OUT[none]}"; then setup_ok=1; fi

ENTRY="$T/corpus/knowledge/openbao-kv-v2-version-lifecycle.md"
entry_line() { # id -> 1/0
  [ -f "$ENTRY" ] || { echo 0; return; }
  awk -v id="$1" '
    /^## / { insec = ($0 ~ /^## Measured \(round 52/) ; next }
    insec && index($0, "- " id " ") == 1 && index($0, "OpenBao 2.7.2") > 0 { found = 1 }
    END { print found ? 1 : 0 }' "$ENTRY"
}

value=0; detail=""
for i in 1 2 3 4 5; do
  id="T$i"
  rv=$(verdict "${OUT[real]}" "$id"); rv2=$(verdict "${OUT[real2]}" "$id"); sv=$(vec "${OUT[sh$i]}"); ev=$(entry_line "$id")
  ok=0; [ "$rv" = HOLDS ] && [ "$rv2" = HOLDS ] && [ "$sv" = "${EXPECT_VEC[sh$i]}" ] && [ "$ev" = 1 ] && ok=1
  value=$((value + ok)); detail="$detail $id:real=$rv/$rv2,shimvec=$sv,entry=$ev,ok=$ok"
done
nosecret=1
if cat "$W"/log/* 2>/dev/null | grep -qE "$SECRET_ERE"; then nosecret=0; fi
noargv=1; calls=""
for m in real real2; do
  f="${BIN[$m]}/bin/.argv"; c=0; [ -f "$f" ] && c=$(wc -l < "$f")
  calls="$calls$m=$c,"
  [ "$c" -ge 20 ] || noargv=0
  [ -f "$f" ] && tr '\037' '\n' < "$f" | grep -qE "$SECRET_ERE" && noargv=0
done

final=$value
[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $noargv -eq 1 ] && [ $pins -eq 1 ] && [ $src -eq 1 ] || final=0
echo "C1_OPENBAO_KV: value=$final discriminating=$value pins=$pins setup_ok=$setup_ok nosecret=$nosecret noargv=$noargv(${calls%,}) src=$src${srcid:+($srcid)} real_rc=$real_rc none_rc=$none_rc$detail"
exit 0
