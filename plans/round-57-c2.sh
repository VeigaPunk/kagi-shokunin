#!/usr/bin/env bash
# plans/round-57-c2.sh -- round 57 C2 counter (capability: OpenBao audit-device
# custody trial executed on a throwaway dev server).
#
# Amendment A1 (pre-candidate, 2026-11-07, before the trial existed and before any
#   candidate measurement): the trial's observable contract follows the lane's
#   round-48/49/51/52 convention (`TRIAL T<n> HOLDS|BROKEN|ERROR` + one summary
#   line) instead of the plan's first `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` form,
#   and the counter adds a client-side PATH-wrapper leg; target, POP and kill
#   rules are unchanged.
#
# Frozen predicate (the same sentence appears in plans/round-57.md section C2):
#   C2_AUDIT_TRIAL: value = PASS when the trial's real run is HOLDS 5/5 twice, each
#   of the five falsifier shims flips exactly its designated test (vectors below),
#   a PATH with no bao reads SETUP rc2 with no HOLDS, and a client-side wrapper
#   whose `bao audit list` is empty flips T1; else 0. Target 5 (BASE 0).
#   POP: T1 documented-enable-path, T2 default HMAC, T3 log_raw, T4 per-instance
#     salt, T5 non-audited paths, as declared in plans/round-57.md.
#   BASE: the trial does not exist at the claim BASE -> value 0.
# Fail closed: a bad revision, unreadable BASE, unusable scratch, missing git or
#   a bao binary whose sha256 is not the pinned OpenBao 2.7.2 is SETUP (exit 2);
#   a missing trial reads 0; any ERROR test or a non-parseable final line reads 0.
# Named ceilings: a trial that resolves bao by absolute path and shape-keys the
#   remaining output can pass (the wrapper leg does not reach it); one binary
#   (OpenBao 2.7.2), the dev server's in-memory storage, one host.
# Input: a revision, or --tree DIR. Output: one line
#   C2_AUDIT_TRIAL: value=V tests=5 pass=P shims=K vectors=ok/5 guard=G
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=1cda9e7ae4767b4133e283bfbc08266d4c86362d
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R57_BAO:-$HOME/.local/bin/bao}"
setup() { echo "C2_AUDIT_TRIAL: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v git >/dev/null 2>&1 || setup no-git
REV=""; TREE=""
case "${1:-}" in
  --tree) TREE=${2:?tree};;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r57/c2-counter.$$
mkdir -p -- "$SCR" || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || { echo "C2_AUDIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (bad-tree)"; exit 1; }
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null \
    || { echo "C2_AUDIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (bad-revision)"; exit 1; }
fi
TRIAL="$ROOT/corpus/openbao-audit-trial.sh"
if [ ! -f "$TRIAL" ] || [ -L "$TRIAL" ]; then
  echo "C2_AUDIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (absent)"
  exit 0
fi
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done

rhex() { od -An -N8 -tx1 /dev/urandom | tr -d ' \n'; }
# Byte-identical client-side wrapper: `audit list` is silenced, everything else
# delegates to the real binary. Used in the `wrap` leg only.
WRAP='#!/bin/bash
REAL=$(cat "$(dirname "$0")/.real")
if [ "${1:-}" = audit ] && [ "${2:-}" = list ]; then exit 0; fi
exec "$REAL" "$@"'
declare -A BIN OUT
mkdir -p "$SCR/log"
for m in real real2 none sh1 sh2 sh3 sh4 sh5 wrap; do
  d="$SCR/$(rhex)"; mkdir -p "$d/bin" "$d/home" "$d/tmp" "$d/work"
  if [ "$m" != none ]; then
    printf '%s\n' "$BAO_BIN" > "$d/bin/.real"
    if [ "$m" = wrap ]; then
      printf '%s\n' "$WRAP" > "$d/bin/bao"; chmod 755 "$d/bin/bao"
    else
      ln -s "$BAO_BIN" "$d/bin/bao"
    fi
  fi
  BIN[$m]="$d"; OUT[$m]="$SCR/log/$(rhex)"
done
verdict() { # OUT ID -> HOLDS|BROKEN|ERROR|NONE|DUP
  local n; n=$(grep -cE "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1")
  if [ "$n" -eq 0 ]; then echo NONE; elif [ "$n" -gt 1 ]; then echo DUP
  else grep -E "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1" | awk '{print $3}'; fi
}
vec() { local i v=""; for i in 1 2 3 4 5; do v="$v$(verdict "$1" "T$i" | cut -c1)"; done; echo "$v"; }
declare -A EXPECT=( [sh1]=BHHHH [sh2]=HBHHH [sh3]=HHBHH [sh4]=HHHBH [sh5]=HHHHB )
run() { # mode -> rc in $?
  local d=${BIN[$1]}
  env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
    KAGI_AUDIT_SHIM="$3" timeout 900 bash "$TRIAL" --work "$d/work" \
    > "${OUT[$1]}" 2>"${OUT[$1]}.err"
}
SHIMV=("" SH1 SH2 SH3 SH4 SH5)
MODE=(real real2 none sh1 sh2 sh3 sh4 sh5 wrap)
declare -A RC
for m in $(printf '%s\n' "${MODE[@]}" | shuf); do
  case "$m" in
    sh*) n=${m#sh}; run "$m" "" "${SHIMV[$n]}";;
    wrap) run wrap "" "";;
    *) run "$m" "" "";;
  esac
  RC[$m]=$?
done
real_ok=0; [ "${RC[real]}" = 0 ] && [ "${RC[real2]}" = 0 ] \
  && [ "$(vec "${OUT[real]}")" = HHHHH ] && [ "$(vec "${OUT[real2]}")" = HHHHH ] && real_ok=1
grep -q '^OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0 error=0' "${OUT[real]}" || real_ok=0
none_ok=0
[ "${RC[none]}" = 2 ] && ! grep -qE '^TRIAL T[1-5] (HOLDS|BROKEN)' "${OUT[none]}" && none_ok=1
wrap_ok=0
[ "$(vec "${OUT[wrap]}")" = BHHHH ] && [ "${RC[wrap]}" = 1 ] && wrap_ok=1
shims_ok=0
for n in 1 2 3 4 5; do
  [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] && shims_ok=$((shims_ok+1))
done
pass=0
[ "$real_ok" = 1 ] && pass=5
value=0
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] && [ "$wrap_ok" = 1 ] && value=5
nosecret=1
if cat "$SCR"/log/* 2>/dev/null | grep -qE 'r57-[0-9a-f]{24}|(^|[^A-Za-z0-9])(hvs|hvb)\.|s\.[A-Za-z0-9]{20,}'; then nosecret=0; fi
[ "$nosecret" = 1 ] && [ "$value" = 5 ] || value=0
printf 'C2_AUDIT_TRIAL: value=%s tests=5 pass=%s shims=%s vectors=%s/5 guard=1 (real=%s none=%s wrap=%s secret=%s)\n' \
  "$value" "$pass" "$shims_ok" "$shims_ok" "$real_ok" "$none_ok" "$wrap_ok" "$nosecret"
[ "$value" = 5 ] && exit 0
exit 1
