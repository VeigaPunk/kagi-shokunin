#!/usr/bin/env bash
# plans/round-60-c2.sh -- round 60 C2 counter (capability: OpenBao AppRole
# secret_id custody trial executed on a throwaway dev server).
#
# Frozen predicate (the same sentence appears in plans/round-60.md section C2):
#   C2_APPROLE_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two
#   independent runs, each of the five falsifier shims flips exactly its
#   designated test (baseline vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH,
#   SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB), a PATH with no bao reads SETUP
#   rc2 with no HOLDS line, and the trial's own `--selftest` exits 0 printing
#   APPROLE_SELFTEST: PASS (cases=N) with N >= 8; else 0.
#   Target 5 (BASE 0: the trial does not exist at BASE).
#   POP: T1 bind_secret_id; T2 secret_id_num_uses single-use; T3 secret_id_ttl
#   expiry; T4 secret-id-accessor custody lookup and destroy; T5
#   secret_id_bound_cidrs.
#
# Fail closed: a bad revision or unreadable --tree reads a guard=0 line and
#   exits 1; missing git or python3, an unusable scratch, a missing bao binary,
#   or a bao binary whose sha256 is not the round-57 pin (OpenBao 2.7.2,
#   9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788, read from
#   plans/round-57-c2.sh next to this counter) is SETUP (exit 2). A missing
#   trial is the BASE control: it prints the absent line (guard=0) and exits 1
#   (the contract is "exit 0 iff value=5"). Any ERROR test, a missing or
#   duplicated T-line, a count of TRIAL T-lines other than 5 in a real run, a
#   missing summary, a wrong vector, a selftest that is missing, fails, or
#   reports N < 8, or a secret-shaped string (an hvs./hvb. token, or a
#   secret_id value printed as a UUID-shaped string) in any captured output
#   forces value=0.
# Trial interface this counter measures (corpus/openbao-approle-trial.sh): the
#   trial is NOT on disk at the predeclaration, so this counter is coded to the
#   plans/round-60.md section C2 contract and the round-57/58/59 trial
#   convention, not to the trial's bytes:
#   bash corpus/openbao-approle-trial.sh [--work DIR] [--selftest]
#     # bao resolved through PATH only
#   prints TRIAL T<n> HOLDS|BROKEN|ERROR <detail> for T1..T5, each exactly
#   once, then exactly one summary line
#   OPENBAO_APPROLE_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> [bao=<ver>]
#   required in BOTH real runs; exit 0 all HOLDS; 1 any BROKEN and no ERROR;
#   2 SETUP. A PATH with no `bao` prints SETUP and exits 2 with no TRIAL line
#   and no HOLDS line (kill rule K1).
#   KAGI_APPROLE_SHIM=SH1..SH5 replaces one test's observable evaluation so
#   exactly that test reads BROKEN (round-48/49/51/52/57/58/59 shim
#   convention); the counter requires each shim run to exit 1 and to flip
#   exactly its designated test, read from the per-test verdicts (K4).
#   --selftest is fixture-driven (no `bao`, no network: the counter runs it on
#   a PATH with no bao): it must exit 0 and print exactly one
#   APPROLE_SELFTEST: PASS (cases=N) line with N >= 8 (K5).
# Ambient BAO_*/VAULT_* of the caller cannot change the reading: every leg
#   runs under `env -i`, and one dedicated leg additionally exports placeholder
#   BAO_ADDR/BAO_TOKEN/BAO_NAMESPACE/VAULT_ADDR/VAULT_TOKEN/VAULT_NAMESPACE/
#   VAULT_SECRET_ID values and must read exactly like a real run (control
#   C2-F8). The placeholder values are deliberately not secret-shaped so they
#   cannot trip the secret scan.
# Kill rules: K1 is the none leg (SETUP rc2, no HOLDS); K3 is the secret scan;
#   K5 is the selftest leg. K2 (absolute-path bao, shape-keyed output) and the
#   independence of the two real runs are declared ceilings checked by the
#   receipts and a non-author probe, not by this counter.
# Run-log names are randomized (rhex) and live outside every --work dir handed
#   to the trial (round-51 M51-2 lesson); the trial is invoked with --work
#   under this counter's scratch. Scratch is removed on exit; TMPDIR points
#   into it; umask 077; no hardcoded /tmp.
# Input: a revision, or --tree DIR (BASE a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2
#   when omitted). Output: one line
#   C2_APPROLE_TRIAL: value=V tests=5 pass=P shims=K vectors=ok|K/5 selftest=S guard=G
#   (plus a parenthetical run census: real/real2/ambient/none/secret flags and
#   each shim's measured vector), exit 0 iff value=5; 1 otherwise; 2 SETUP.
set -u
umask 077
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2
BAO_BIN="${R60_BAO:-$HOME/.local/bin/bao}"
setup() { echo "C2_APPROLE_TRIAL: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v git >/dev/null 2>&1 || setup no-git
PIN_BAO=$(grep -cE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" 2>/dev/null)
[ "$PIN_BAO" = 1 ] || setup bao-pin-unreadable
PIN_BAO=$(grep -oE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" | cut -d= -f2)
REV=""; TREE=""
case "${1:-}" in
  --tree)
    if [ $# -lt 2 ]; then
      echo "C2_APPROLE_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (bad-tree)"; exit 1
    fi
    TREE=$2;;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecCounterC2/c2-counter.$$
mkdir -p -- "$SCR" || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || { echo "C2_APPROLE_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (bad-tree)"; exit 1; }
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null \
    || { echo "C2_APPROLE_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (bad-revision)"; exit 1; }
fi
TRIAL="$ROOT/corpus/openbao-approle-trial.sh"
if [ ! -f "$TRIAL" ] || [ -L "$TRIAL" ]; then
  echo "C2_APPROLE_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (absent)"
  exit 1   # frozen contract: exit 0 iff value=5 (the BASE control leg)
fi
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done

rhex() { od -An -N8 -tx1 /dev/urandom | tr -d ' \n'; }
declare -A BIN OUT
mkdir -p "$SCR/log"
for m in real real2 ambient none selftest sh1 sh2 sh3 sh4 sh5; do
  d="$SCR/$(rhex)"; mkdir -p "$d/bin" "$d/home" "$d/tmp" "$d/work"
  if [ "$m" != none ] && [ "$m" != selftest ]; then ln -s "$BAO_BIN" "$d/bin/bao"; fi
  BIN[$m]="$d"; OUT[$m]="$SCR/log/$(rhex)"
done
verdict() { # OUT ID -> HOLDS|BROKEN|ERROR|NONE|DUP
  local n; n=$(grep -cE "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1")
  if [ "$n" -eq 0 ]; then echo NONE; elif [ "$n" -gt 1 ]; then echo DUP
  else grep -E "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1" | awk '{print $3}'; fi
}
vec() { local i v=""; for i in 1 2 3 4 5; do v="$v$(verdict "$1" "T$i" | cut -c1)"; done; echo "$v"; }
tlines() { grep -cE '^TRIAL T[0-9]+( |$)' "$1"; }
declare -A EXPECT=( [sh1]=BHHHH [sh2]=HBHHH [sh3]=HHBHH [sh4]=HHHBH [sh5]=HHHHB )
run() { # MODE SHIM -> rc in $?
  local d=${BIN[$1]}
  env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
    KAGI_APPROLE_SHIM="$2" timeout 900 bash "$TRIAL" --work "$d/work" \
    > "${OUT[$1]}" 2>"${OUT[$1]}.err"
}
run_ambient() { # like run real, but with placeholder caller ambient exported
  local d=${BIN[ambient]}
  env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
    BAO_ADDR="http://127.0.0.1:9" BAO_TOKEN="ambient-placeholder-token" \
    BAO_NAMESPACE="ambient-placeholder-ns" \
    VAULT_ADDR="http://127.0.0.1:9" VAULT_TOKEN="ambient-placeholder-token" \
    VAULT_NAMESPACE="ambient-placeholder-ns" VAULT_SECRET_ID="ambient-placeholder-sid" \
    timeout 900 bash "$TRIAL" --work "$d/work" \
    > "${OUT[ambient]}" 2>"${OUT[ambient]}.err"
}
run_selftest() { # fixture-driven: no bao on PATH (K5)
  local d=${BIN[selftest]}
  env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
    timeout 300 bash "$TRIAL" --selftest --work "$d/work" \
    > "${OUT[selftest]}" 2>"${OUT[selftest]}.err"
}
SHIMV=("" SH1 SH2 SH3 SH4 SH5)
MODE=(real real2 ambient none selftest sh1 sh2 sh3 sh4 sh5)
declare -A RC
for m in $(printf '%s\n' "${MODE[@]}" | shuf); do
  case "$m" in
    sh*) n=${m#sh}; run "$m" "${SHIMV[$n]}";;
    ambient) run_ambient;;
    selftest) run_selftest;;
    *) run "$m" "";;
  esac
  RC[$m]=$?
done
real_ok=0; [ "${RC[real]}" = 0 ] && [ "${RC[real2]}" = 0 ] \
  && [ "$(vec "${OUT[real]}")" = HHHHH ] && [ "$(vec "${OUT[real2]}")" = HHHHH ] \
  && [ "$(tlines "${OUT[real]}")" = 5 ] && [ "$(tlines "${OUT[real2]}")" = 5 ] && real_ok=1
for m in real real2; do
  grep -q '^OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0' "${OUT[$m]}" || real_ok=0
done
ambient_ok=0; [ "${RC[ambient]}" = 0 ] && [ "$(vec "${OUT[ambient]}")" = HHHHH ] \
  && [ "$(tlines "${OUT[ambient]}")" = 5 ] && ambient_ok=1
grep -q '^OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0' "${OUT[ambient]}" || ambient_ok=0
none_ok=0
[ "${RC[none]}" = 2 ] && grep -q 'SETUP' "${OUT[none]}" "${OUT[none]}.err" \
  && ! grep -q 'HOLDS' "${OUT[none]}" "${OUT[none]}.err" && none_ok=1
selftest_ok=0; sn=0
spass=$(grep -cE '^APPROLE_SELFTEST: PASS \(cases=[0-9]+\)' "${OUT[selftest]}" 2>/dev/null)
if [ "${RC[selftest]}" = 0 ] && [ "$spass" = 1 ]; then
  sn=$(grep -oE '^APPROLE_SELFTEST: PASS \(cases=[0-9]+\)' "${OUT[selftest]}" | grep -oE '[0-9]+')
  [ "$sn" -ge 8 ] && selftest_ok=1
fi
shims_ok=0
for n in 1 2 3 4 5; do
  [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] && shims_ok=$((shims_ok+1))
done
pass=0
[ "$real_ok" = 1 ] && pass=5
value=0
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] \
  && [ "$ambient_ok" = 1 ] && [ "$selftest_ok" = 1 ] && value=5
nosecret=1
if cat "$SCR"/log/* 2>/dev/null | grep -qEi '(^|[^A-Za-z0-9])(hvs|hvb)\.[A-Za-z0-9]|secret_?id["'"'"':= ]+[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'; then
  nosecret=0
fi
[ "$nosecret" = 1 ] && [ "$value" = 5 ] || value=0
V="ok"; [ "$shims_ok" = 5 ] || V=$shims_ok
printf 'C2_APPROLE_TRIAL: value=%s tests=5 pass=%s shims=%s vectors=%s/5 selftest=%s guard=1 (real=%s real2=%s ambient=%s none=%s secret=%s sh1=%s sh2=%s sh3=%s sh4=%s sh5=%s)\n' \
  "$value" "$pass" "$shims_ok" "$V" "$selftest_ok" "$real_ok" "$real_ok" "$ambient_ok" "$none_ok" "$nosecret" \
  "$(vec "${OUT[sh1]}")" "$(vec "${OUT[sh2]}")" "$(vec "${OUT[sh3]}")" "$(vec "${OUT[sh4]}")" "$(vec "${OUT[sh5]}")"
[ "$value" = 5 ] && exit 0
exit 1
