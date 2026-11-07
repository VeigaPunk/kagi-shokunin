#!/usr/bin/env bash
# plans/round-58-c2.sh -- round 58 C2 counter (capability: OpenBao ACL-policy
# semantics trial executed on a throwaway dev server).
#
# Frozen predicate (the same sentence appears in plans/round-58.md section C2):
#   C2_POLICY_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 twice, each
#   of the five falsifier shims flips exactly its designated test (baseline vector
#   HHHHH; SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB),
#   a PATH with no bao reads SETUP rc2 with no HOLDS, and a PATH wrapper that lies
#   on the client-side capability introspection flips exactly T5; else 0.
#   Target 5 (BASE 0: the trial does not exist at BASE).
#   POP: T1 deny-by-default and exact-path reach; T2 `*` prefix glob only as the
#   last character; T3 deny precedence over a broader allow; T4 `+` bounded to one
#   path segment; T5 union of capabilities at one pattern vs highest-priority
#   match across different patterns.
#
# Fail closed: a bad revision or unreadable --tree reads a guard=0 line and exits 1;
#   missing git or python3, an unusable scratch, an unreadable bao pin, a missing
#   bao binary, or a bao binary whose sha256 is not the round-57 pin (OpenBao 2.7.2,
#   read from plans/round-57-c2.sh next to this counter) is SETUP (exit 2). A
#   missing trial is the BASE control: it prints the absent line (guard=0) and
#   exits 0. Any ERROR test, a missing or duplicated T-line, a missing summary, a
#   wrong vector, or a secret-shaped string (hvs./hvb./r58- + 24 hex) in any
#   receipt forces value=0.
# Trial interface this counter measures (corpus/openbao-policy-trial.sh):
#   bash corpus/openbao-policy-trial.sh --work DIR    # bao resolved through PATH only
#   prints TRIAL T<n> HOLDS|BROKEN|ERROR <detail> for T1..T5, each exactly once,
#   then OPENBAO_POLICY_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>
#   exit 0 all HOLDS; 1 any BROKEN and no ERROR; 2 SETUP.
#   KAGI_POLICY_SHIM=SH1..SH5 replaces one test's observable evaluation so exactly
#   that test reads BROKEN (round-48/49/51/52 shim convention).
#   T5 is the only test whose observable may pass through the client-side
#   `bao token capabilities` introspection; T1..T4 must be measured server-side.
#   The wrap leg's wrapper delegates everything to the real pinned binary except
#   `bao token capabilities`, which it answers with the literal `deny` and rc 0
#   regardless of arguments or the token's real capabilities; a conforming trial
#   reads exactly T5 BROKEN there (rc 1).
# Kill rules: K1 is the none leg (SETUP rc2, no HOLDS); K3 is the secret scan.
#   K2's ceiling (absolute-path bao, shape-keyed output) is checked by the receipts
#   and a non-author probe, not by this counter. Run-log names are randomized
#   (rhex) and live outside every --work dir handed to the trial (round-51 M51-2).
# Ambient BAO_*/VAULT_* cannot reach the trial: each leg runs under `env -i`.
# Input: a revision, or --tree DIR (BASE when omitted). Output: one line
#   C2_POLICY_TRIAL: value=V tests=5 pass=P shims=K vectors=ok|K/5 guard=G
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=1b13f5dad921f8901f56d30c428f89614dd74d8a
BAO_BIN="${R58_BAO:-$HOME/.local/bin/bao}"
setup() { echo "C2_POLICY_TRIAL: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v git >/dev/null 2>&1 || setup no-git
PIN_BAO=$(grep -cE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" 2>/dev/null)
[ "$PIN_BAO" = 1 ] || setup bao-pin-unreadable
PIN_BAO=$(grep -oE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" | cut -d= -f2)
REV=""; TREE=""
case "${1:-}" in
  --tree) TREE=${2:?tree};;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/c2-counter.$$
mkdir -p -- "$SCR" || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || { echo "C2_POLICY_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (bad-tree)"; exit 1; }
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null \
    || { echo "C2_POLICY_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (bad-revision)"; exit 1; }
fi
TRIAL="$ROOT/corpus/openbao-policy-trial.sh"
if [ ! -f "$TRIAL" ] || [ -L "$TRIAL" ]; then
  echo "C2_POLICY_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (absent)"
  exit 0
fi
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done

rhex() { od -An -N8 -tx1 /dev/urandom | tr -d ' \n'; }
# Client-side wrapper used in the `wrap` leg only: byte-identical delegation to
# the pinned real binary, except `bao token capabilities`, which always answers
# the literal `deny` (rc 0) -- a lie that must flip exactly T5.
WRAP='#!/bin/bash
REAL=$(cat "$(dirname "$0")/.real")
if [ "${1:-}" = token ] && [ "${2:-}" = capabilities ]; then echo deny; exit 0; fi
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
run() { # MODE SHIM -> rc in $?
  local d=${BIN[$1]}
  env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
    KAGI_POLICY_SHIM="$2" timeout 900 bash "$TRIAL" --work "$d/work" \
    > "${OUT[$1]}" 2>"${OUT[$1]}.err"
}
SHIMV=("" SH1 SH2 SH3 SH4 SH5)
MODE=(real real2 none sh1 sh2 sh3 sh4 sh5 wrap)
declare -A RC
for m in $(printf '%s\n' "${MODE[@]}" | shuf); do
  case "$m" in
    sh*) n=${m#sh}; run "$m" "${SHIMV[$n]}";;
    *) run "$m" "";;
  esac
  RC[$m]=$?
done
real_ok=0; [ "${RC[real]}" = 0 ] && [ "${RC[real2]}" = 0 ] \
  && [ "$(vec "${OUT[real]}")" = HHHHH ] && [ "$(vec "${OUT[real2]}")" = HHHHH ] && real_ok=1
grep -q '^OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0' "${OUT[real]}" || real_ok=0
none_ok=0
[ "${RC[none]}" = 2 ] && ! grep -q 'HOLDS' "${OUT[none]}" && none_ok=1
wrap_ok=0
[ "$(vec "${OUT[wrap]}")" = HHHHB ] && [ "${RC[wrap]}" = 1 ] && wrap_ok=1
shims_ok=0
for n in 1 2 3 4 5; do
  [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] && shims_ok=$((shims_ok+1))
done
pass=0
[ "$real_ok" = 1 ] && pass=5
value=0
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] && [ "$wrap_ok" = 1 ] && value=5
nosecret=1
if cat "$SCR"/log/* 2>/dev/null | grep -qE 'r58-[0-9a-f]{24}|(^|[^A-Za-z0-9])(hvs|hvb)\.'; then nosecret=0; fi
[ "$nosecret" = 1 ] && [ "$value" = 5 ] || value=0
V="ok"; [ "$shims_ok" = 5 ] || V=$shims_ok
printf 'C2_POLICY_TRIAL: value=%s tests=5 pass=%s shims=%s vectors=%s/5 guard=1 (real=%s none=%s wrap=%s secret=%s)\n' \
  "$value" "$pass" "$shims_ok" "$V" "$real_ok" "$none_ok" "$wrap_ok" "$nosecret"
[ "$value" = 5 ] && exit 0
exit 1
