#!/usr/bin/env bash
# plans/round-59-c2.sh -- round 59 C2 counter (capability: OpenBao transit
# encryption-as-a-service trial executed on a throwaway dev server).
#
# Frozen predicate (the same sentence appears in plans/round-59.md section C2):
#   C2_TRANSIT_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two
#   independent runs, each of the five falsifier shims flips exactly its
#   designated test (baseline vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH,
#   SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB), a PATH with no bao reads SETUP
#   rc2 with no HOLDS, and a second, independent throwaway dev server refuses
#   to decrypt the first server's T1 ciphertext; else 0.
#   Target 5 (BASE 0: the trial does not exist at BASE).
#   POP: T1 round trip and tamper refusal; T2 rotate advances the key version
#   while the older ciphertext still decrypts; T3 rewrap migrates ciphertext to
#   the newest version without a decrypt round trip; T4 min_decryption_version
#   refuses older ciphertext; T5 convergent encryption gives equal ciphertext
#   for equal plaintext+context and different ciphertext otherwise.
#
# Fail closed: a bad revision or unreadable --tree reads a guard=0 line and
#   exits 1; missing git or python3, an unusable scratch, an unreadable bao
#   pin, a missing bao binary, or a bao binary whose sha256 is not the round-57
#   pin (OpenBao 2.7.2, read from plans/round-57-c2.sh next to this counter) is
#   SETUP (exit 2). A missing trial is the BASE control: it prints the absent
#   line (guard=0) and exits 1 (the contract is "exit 0 iff value=5"; the
#   pre-freeze critic measured this leg exiting 0 and it is corrected here). Any ERROR test, a missing or duplicated T-line,
#   a missing CLEANROOM line, a missing summary, a wrong vector, or a
#   secret-shaped string (hvs./hvb. token, an r59- + 24-hex nonce) in any
#   captured output forces value=0.
# Trial interface this counter measures (corpus/openbao-transit-trial.sh): the
#   trial is NOT on disk at the predeclaration, so this counter is coded to the
#   plans/round-59.md section C2 contract and the round-57/58 trial convention,
#   not to the trial's bytes (recorded in .ufo/waves/round-59/build/
#   R59ExecCounterC2/):
#   bash corpus/openbao-transit-trial.sh --work DIR   # bao resolved through PATH only
#   prints TRIAL T<n> HOLDS|BROKEN|ERROR <detail> for T1..T5, each exactly once,
#   plus exactly one TRIAL CLEANROOM HOLDS|BROKEN|ERROR <detail> line: a second,
#   independent `bao server -dev` (own storage) refuses to decrypt the first
#   server's T1 ciphertext; the counter requires it HOLDS in both real runs, so
#   a trial with the leg removed reads <5 (control C2-F3). That the leg's second
#   server is genuinely independent cannot be proven from printed output: that
#   is K4's declared ceiling, checked by the receipts and a non-author probe,
#   not by this counter.
#   then OPENBAO_TRANSIT_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>
#   (holds counts T1..T5 only; CLEANROOM is a separate leg line), required in
#   BOTH real runs; exit 0 all HOLDS; 1 any BROKEN and no ERROR; 2 SETUP.
#   KAGI_TRANSIT_SHIM=SH1..SH5 replaces one test's observable evaluation so
#   exactly that test reads BROKEN (round-48/49/51/52 shim convention).
# Kill rules: K1 is the none leg (SETUP rc2, no HOLDS); K3 is the secret scan.
#   K2 (absolute-path bao, shape-keyed output) and K4 (same-server cleanroom)
#   are declared ceilings checked by the receipts and a non-author probe, not
#   by this counter.
# Ambient BAO_*/VAULT_* cannot reach the trial: each leg runs under `env -i`.
# Run-log names are randomized (rhex) and live outside every --work dir handed
# to the trial (round-51 M51-2 lesson); the trial is invoked with --work under
# the scratch tree.
# Input: a revision, or --tree DIR (BASE 5fa6e658f36bd9e440cb567fbbd2bfac88f868b6
#   when omitted). Output: one line
#   C2_TRANSIT_TRIAL: value=V tests=5 pass=P shims=K vectors=ok|K/5 guard=G
#   exit 0 iff value=5; 1 otherwise; 2 SETUP.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=5fa6e658f36bd9e440cb567fbbd2bfac88f868b6
BAO_BIN="${R59_BAO:-$HOME/.local/bin/bao}"
setup() { echo "C2_TRANSIT_TRIAL: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v git >/dev/null 2>&1 || setup no-git
PIN_BAO=$(grep -cE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" 2>/dev/null)
[ "$PIN_BAO" = 1 ] || setup bao-pin-unreadable
PIN_BAO=$(grep -oE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" | cut -d= -f2)
REV=""; TREE=""
case "${1:-}" in
  --tree)
    if [ $# -lt 2 ]; then
      echo "C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (bad-tree)"; exit 1
    fi
    TREE=$2;;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecCounterC2/c2-counter.$$
mkdir -p -- "$SCR" || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || { echo "C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (bad-tree)"; exit 1; }
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null \
    || { echo "C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (bad-revision)"; exit 1; }
fi
TRIAL="$ROOT/corpus/openbao-transit-trial.sh"
if [ ! -f "$TRIAL" ] || [ -L "$TRIAL" ]; then
  echo "C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (absent)"
  exit 1   # frozen contract: exit 0 iff value=5 (critic Q2 defect: this leg exited 0)
fi
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done

rhex() { od -An -N8 -tx1 /dev/urandom | tr -d ' \n'; }
declare -A BIN OUT
mkdir -p "$SCR/log"
for m in real real2 none sh1 sh2 sh3 sh4 sh5; do
  d="$SCR/$(rhex)"; mkdir -p "$d/bin" "$d/home" "$d/tmp" "$d/work"
  if [ "$m" != none ]; then ln -s "$BAO_BIN" "$d/bin/bao"; fi
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
    KAGI_TRANSIT_SHIM="$2" timeout 900 bash "$TRIAL" --work "$d/work" \
    > "${OUT[$1]}" 2>"${OUT[$1]}.err"
}
SHIMV=("" SH1 SH2 SH3 SH4 SH5)
MODE=(real real2 none sh1 sh2 sh3 sh4 sh5)
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
grep -q '^OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0' "${OUT[real]}" || real_ok=0
grep -q '^OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0' "${OUT[real2]}" || real_ok=0
clean_ok=1
for m in real real2; do
  [ "$(verdict "${OUT[$m]}" CLEANROOM)" = HOLDS ] || clean_ok=0
done
none_ok=0
[ "${RC[none]}" = 2 ] && ! grep -q 'HOLDS' "${OUT[none]}" && none_ok=1
shims_ok=0
for n in 1 2 3 4 5; do
  [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] && shims_ok=$((shims_ok+1))
done
pass=0
[ "$real_ok" = 1 ] && pass=5
value=0
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] && [ "$clean_ok" = 1 ] && value=5
nosecret=1
if cat "$SCR"/log/* 2>/dev/null | grep -qE 'r59-[0-9a-f]{24}|(^|[^A-Za-z0-9])(hvs|hvb)\.'; then nosecret=0; fi
[ "$nosecret" = 1 ] && [ "$value" = 5 ] || value=0
V="ok"; [ "$shims_ok" = 5 ] || V=$shims_ok
printf 'C2_TRANSIT_TRIAL: value=%s tests=5 pass=%s shims=%s vectors=%s/5 guard=1 (real=%s none=%s cleanroom=%s secret=%s)\n' \
  "$value" "$pass" "$shims_ok" "$V" "$real_ok" "$none_ok" "$clean_ok" "$nosecret"
[ "$value" = 5 ] && exit 0
exit 1
