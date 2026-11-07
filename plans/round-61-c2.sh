#!/usr/bin/env bash
# plans/round-61-c2.sh -- round 61 C2 counter (capability: an executed OpenBao
# seal / unseal key-share custody trial on throwaway dev servers).
#
# Frozen predicate (the same sentence appears in plans/round-61.md section C2):
#   C2_SEAL_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two
#   independent runs, each of the five falsifier shims flips exactly its
#   designated test (baseline vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH,
#   SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB), a PATH with no bao reads SETUP
#   rc2 with no HOLDS line, and the trial's own `--selftest` exits 0 printing
#   SEAL_SELFTEST: PASS (cases=N) with N >= 8; else 0.
#   Target 5 (BASE 0: the trial does not exist at BASE).
#   POP: T1 init share/threshold arithmetic and non-persistence; T2 unseal
#   threshold and duplicate-share refusal; T3 seal and the sealed-state
#   request; T4 generate-root with OTP decode; T5 rekey refused on this build
#   (docs vs binary).
# Fail closed: a bad revision or unreadable --tree reads a guard=0 line and
#   exits 1; missing git or python3, an unusable scratch, a missing bao binary,
#   or a bao binary whose sha256 is not the round-57 pin (OpenBao 2.7.2,
#   9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788, read from
#   plans/round-57-c2.sh next to this counter) is SETUP (exit 2). A missing
#   trial is the BASE control: it prints the absent line (guard=0) and exits 1
#   (the contract is "exit 0 iff guard=1 and value=5"). Any ERROR test, a
#   missing or duplicated T-line, a count of TRIAL T-lines other than 5 in a
#   real run, a missing summary, a wrong vector, a selftest that is missing,
#   fails, or reports N < 8, or a secret-shaped string (an hvs./hvb. or s.
#   token, a generate-root OTP or nonce value, or a 43+-char base64url run
#   that is neither a pure-hex sha256 pin nor a pure dash/underscore separator
#   run) in the trial text or in any captured output or receipt the trial
#   wrote forces value=0. The counter's own ops-witness logs (*.ops) are
#   instrumentation, not receipts: they carry argv, which the generate-root
#   protocol legitimately fills with -nonce/-decode values, so they sit
#   outside the K3 scan and are read only for the operation witnesses. Since
#   the round-61 reviewer's C2-3 finding (a stub calling `bao <op> --help`
#   logged every command name and passed), each witness is an argv SHAPE the
#   trial's measured invocation produces — `server -config=`,
#   `operator init -key-shares=5 -key-threshold=3`, `operator unseal` with a
#   40+-char base64 share, a bare `operator seal`, `operator generate-root
#   -init`, `operator generate-root -decode=`, and `operator rekey -init
#   -key-shares=3 -key-threshold=2` — so a help-only stub cannot satisfy it.
# Guard: guard=1 iff every leg below ran (each mode has a captured rc) AND the
#   trial file's sha256 is recorded (printed as trial=<hex> in the census).
# Trial interface this counter measures (corpus/openbao-seal-trial.sh): the
#   trial is NOT on disk at the predeclaration, so this counter is coded to the
#   plans/round-61.md section C2 contract and the round-57/58/59/60 trial
#   convention, not to the trial's bytes:
#   bash corpus/openbao-seal-trial.sh [--work DIR] [--selftest]
#     # bao resolved through PATH only
#   prints TRIAL T<n> HOLDS|BROKEN|ERROR <detail> for T1..T5, each exactly
#   once, then exactly one summary line
#   OPENBAO_SEAL_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> [bao=<ver>]
#   required in BOTH real runs; exit 0 all HOLDS; 1 any BROKEN and no ERROR;
#   2 SETUP. A PATH with no `bao` prints SETUP and exits 2 with no TRIAL line
#   and no HOLDS line (kill rule K1).
#   KAGI_SEAL_SHIM=SH1..SH5 replaces one test's observable evaluation so
#   exactly that test reads BROKEN (round-48/49/51/52/57/58/59/60 shim
#   convention); the counter requires each shim run to exit 1, to print the
#   BROKEN holds=4 broken=1 summary prefix and to flip exactly its designated
#   test, read from the per-test verdicts (K4).
#   --selftest is fixture-driven (no `bao`, no network: the counter runs it on
#   a PATH with no bao): it must exit 0 and print exactly one
#   SEAL_SELFTEST: PASS (cases=N) line with N >= 8 (K5).
# This counter also exposes its OWN --selftest (SKILL gate standard; the
#   round-60 routed defect D2 class: a gate registered without a
#   self-invocation mode is a defect of its landing round): fixture-driven,
#   no bao, no network, and it must fail with a named R61-C2-ST-<case> FINDING
#   when its verdict parsing, summary match, expectation table or secret scan
#   is broken (red witness). It prints C2_SELFTEST: PASS (cases=N) on success.
# Ambient BAO_*/VAULT_* of the caller cannot change the reading: every leg
#   runs under `env -i`. (Round 60's dedicated placeholder-ambient control
#   C2-F8 is not part of the round-61 frozen predicate or control plan; the
#   env -i discipline covers the same hazard here.)
# Vacuity controls (round-61 critic findings, routed by L1): a verdict line
#   alone proves nothing, so the counter adds two controls without touching
#   the frozen predicate's legs. (1) Ops witness: every bao-carrying leg runs
#   the pinned binary through a logging exec shim first on PATH; each real
#   run's ops log must carry at least `server`, `operator init`,
#   `operator seal`, `operator generate-root` and `operator rekey` (the
#   T1/T3/T4/T5 argv), else value=0 (census flag ops=). L1 adjudication
#   2026-11-07: `operator unseal` is NOT required in argv — the trial drives
#   T2's unseal over the HTTP API of the real pinned server (the frozen POP
#   says nothing about CLI vs API, and reading progress/sealed fields is
#   better served by the API) — so T2 is instead witnessed in each real run's
#   stdout by the progress markers the mechanic asserts: at least one
#   `progress=1/3` (the duplicate-share observation may repeat it), at least
#   one `progress=2/3`, and the final `sealed=false` with `t=3` and `n=5`
#   (census flag t2w=; a real run whose stdout carries no marker set forces
#   value=0). A fixture trial that prints the expected lines without exec-ing
#   bao reads empty logs and cannot score. (2) Stub control: the counter materialises a
#   vacuous fixture trial inside its own scratch (never the measured tree)
#   that fakes every expected line without calling bao, reads the counter
#   against it, and requires value=0 there (census flag stubctl=1); a fixture
#   that scores forces value=0. The nested reading sets R61_C2_NOSTUB=1 to
#   skip its own stub leg (recursion guard).
# Kill rules: K1 is the none leg (SETUP rc2, no HOLDS); K3 is the secret scan;
#   K5 is the trial-selftest leg. K2 (absolute-path bao, shape-keyed output)
#   and the independence of the two real runs are declared ceilings checked by
#   the receipts and a non-author probe, not by this counter.
# Run-log names are randomized (rhex) and live outside every --work dir handed
#   to the trial (round-51 M51-2 lesson); each leg is invoked with --work under
#   this counter's scratch and cwd is the leg dir, so no relative path can land
#   in the caller's tree. Scratch is removed on exit; TMPDIR points into it;
#   umask 077; no hardcoded /tmp. Nothing is ever written inside the measured
#   tree: the trial file is only read, from the materialised copy for a
#   revision or in place for --tree.
# Input: a revision, or --tree DIR (BASE c940f51689d702f1786989d56ad4663833c1452e
#   when omitted), or --selftest. Output: one line
#   C2_SEAL_TRIAL: value=V tests=5 pass=P shims=K vectors=ok|K/5 selftest=S guard=G
#   (plus a parenthetical run census: real/real2/none/ops/stubctl/secret
#   flags, each shim's measured vector, the trial sha256 and the
#   trial-selftest case count), exit 0 iff guard=1 and value=5; 1 otherwise;
#   2 SETUP.
set -u
umask 077
export LC_ALL=C
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
SELF=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P)/$(basename "$0")
BASE=c940f51689d702f1786989d56ad4663833c1452e
NAME=C2_SEAL_TRIAL
BAO_BIN="${R61_BAO:-$HOME/.local/bin/bao}"
setup() { echo "$NAME: SETUP $1"; exit 2; }

verdict() { # OUT ID -> HOLDS|BROKEN|ERROR|NONE|DUP
  local n; n=$(grep -cE "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1")
  if [ "$n" -eq 0 ]; then echo NONE; elif [ "$n" -gt 1 ]; then echo DUP
  else grep -E "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1" | awk '{print $3}'; fi
}
vec() { local i v=""; for i in 1 2 3 4 5; do v="$v$(verdict "$1" "T$i" | cut -c1)"; done; echo "$v"; }
tlines() { grep -cE '^TRIAL T[0-9]+( |$)' "$1"; }
holds5() { grep -q '^OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0' "$1"; }
broken41() { grep -q '^OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1' "$1"; }
declare -A EXPECT=( [sh1]=BHHHH [sh2]=HBHHH [sh3]=HHBHH [sh4]=HHHBH [sh5]=HHHHB )
# Secret scan (K3): named shapes only, never a value echo. hvs./hvb. root or
#   service tokens; s.<24 alnum> batch tokens; an OTP= whose value is a 20+-char
#   run; a nonce= whose value is a 16+-char hex/dash run; and a 43+-char
#   base64url run (an unseal key share) EXCEPT a pure-hex run of 43+ chars (a
#   sha256 pin, not a share) and a pure dash/underscore run of 43+ chars (a
#   comment separator, which carries no alnum). A redacted receipt ("REDACTED",
#   "<shape-only>", "shares=5 threshold=3") passes; a raw value cannot.
SECRET_PCRE='(hvs|hvb)\.[A-Za-z0-9_-]{10,}|\bs\.[A-Za-z0-9]{24}\b|\bOTP[=:[:space:]]+[A-Za-z0-9+/=_-]{20,}|\b[Nn]once[=:[:space:]]+["'"'"']?[0-9a-f-]{16,}|(?![0-9a-f]{43,}([^0-9a-f]|$))(?![-_]{43})[A-Za-z0-9_-]{43,}'
scan_hits() { # file... -> rc 0 iff at least one file carries a secret shape
  local f hit=1
  for f in "$@"; do
    [ -f "$f" ] || continue
    if grep -IqP "$SECRET_PCRE" "$f" 2>/dev/null; then hit=0; fi
  done
  return $hit
}
absent_line() { printf '%s: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (%s)\n' "$NAME" "$1"; }

# ---------------------------------------------------------------- selftest --
if [ "${1:-}" = "--selftest" ]; then
  SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecCounterC2/c2-selftest.$$
  mkdir -p -- "$SCR" || { echo "$NAME: SETUP no-scratch"; exit 2; }
  trap 'rm -rf -- "$SCR"' EXIT
  export TMPDIR=$SCR
  pass=0; fail=0
  st() { local n=$1; shift; if "$@" >/dev/null 2>&1; then pass=$((pass+1)); else fail=$((fail+1)); echo "FINDING R61-C2-ST-$n"; fi; }
  f="$SCR/fix-holds"; : >"$f"
  for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS detail-$i" >>"$f"; done
  echo 'OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2' >>"$f"
  g="$SCR/fix-dup"; printf 'TRIAL T1 HOLDS a\nTRIAL T2 BROKEN b\nTRIAL T2 HOLDS c\nTRIAL T4 HOLDS d\nTRIAL T5 HOLDS e\n' >"$g"
  h="$SCR/fix-broken"; printf 'OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0\n' >"$h"
  i2="$SCR/fix-badholds"; printf 'OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=1 error=0\n' >"$i2"
  b="$SCR/fix-sh1"; : >"$b"
  for j in 1 2 3 4 5; do if [ "$j" = 1 ]; then echo "TRIAL T$j BROKEN x" >>"$b"; else echo "TRIAL T$j HOLDS x" >>"$b"; fi; done
  s1="$SCR/sec-hit1"; printf 'root token hvs.AbCdEf1234567890 in body\n' >"$s1"
  s2="$SCR/sec-hit2"; printf 'share XyZ123abcD456efG789hI012jK345lmN789opQr12gXyZ\n' >"$s2"
  printf -v sep60 '%*s' 60 ''; sep60=${sep60// /-}
  s3="$SCR/sec-clean"; printf 'unseal shares=5 threshold=3 nonce: REDACTED OTP: <shape-only>\n#%s\nsha256 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788\n%s\n' "$sep60" "${sep60//-/_}" >"$s3"
  c_base_const() { printf '%s' "$BASE" | grep -qE '^[0-9a-f]{40}$'; }
  c_tree_noarg() { local o r; o=$(bash "$SELF" --tree 2>&1); r=$?; [ "$r" = 1 ] && printf '%s\n' "$o" | grep -q '(bad-tree)$'; }
  c_tree_missing() { local o r; o=$(bash "$SELF" --tree "$SCR/no-such-dir" 2>&1); r=$?; [ "$r" = 1 ] && printf '%s\n' "$o" | grep -q '(bad-tree)$'; }
  c_absent() { mkdir -p "$SCR/empty"; local o r; o=$(bash "$SELF" --tree "$SCR/empty" 2>&1); r=$?; [ "$r" = 1 ] && printf '%s\n' "$o" | grep -q 'guard=0 (absent)$'; }
  c_vec_holds() { [ "$(vec "$f")" = HHHHH ] && [ "$(tlines "$f")" = 5 ] && holds5 "$f"; }
  c_vec_dup() { [ "$(verdict "$g" T2)" = DUP ] && [ "$(vec "$g" | cut -c3)" = N ]; }
  c_summary_reject() { ! holds5 "$h" && ! holds5 "$i2"; }
  c_expect() { [ "${EXPECT[sh1]}" = BHHHH ] && [ "${EXPECT[sh2]}" = HBHHH ] && [ "${EXPECT[sh3]}" = HHBHH ] && [ "${EXPECT[sh4]}" = HHHBH ] && [ "${EXPECT[sh5]}" = HHHHB ]; }
  c_secret_fires() { scan_hits "$s1" "$s2"; }
  c_secret_clean() { ! scan_hits "$s3"; }
  c_shim_detect() { [ "$(vec "$b")" = "${EXPECT[sh1]}" ] && [ "$(vec "$b")" != HHHHH ]; }
  st base-const c_base_const
  st tree-noarg c_tree_noarg
  st tree-missing c_tree_missing
  st absent c_absent
  st vec-holds c_vec_holds
  st vec-dup c_vec_dup
  st summary-reject c_summary_reject
  st expect-table c_expect
  st secret-fires c_secret_fires
  st secret-clean c_secret_clean
  st shim-detect c_shim_detect
  if [ "$fail" = 0 ]; then
    echo "C2_SELFTEST: PASS (cases=$pass)"; exit 0
  fi
  echo "C2_SELFTEST: FAIL (cases=$((pass+fail)) failed=$fail)"; exit 1
fi

# -------------------------------------------------------------------- main --
command -v python3 >/dev/null 2>&1 || setup no-python3
command -v git >/dev/null 2>&1 || setup no-git
PIN_BAO=$(grep -cE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" 2>/dev/null)
[ "$PIN_BAO" = 1 ] || setup bao-pin-unreadable
PIN_BAO=$(grep -oE '^PIN_BAO=[0-9a-f]{64}$' "$REPO/plans/round-57-c2.sh" | cut -d= -f2)
REV=""; TREE=""
case "${1:-}" in
  --tree)
    if [ $# -lt 2 ]; then
      absent_line bad-tree; exit 1
    fi
    TREE=$2;;
  "") REV=$BASE;;
  *) REV=$1;;
esac
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecCounterC2/c2-counter.$$
mkdir -p -- "$SCR" || setup no-scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
if [ -n "$TREE" ]; then
  ROOT=$(cd "$TREE" 2>/dev/null && pwd -P) || { absent_line bad-tree; exit 1; }
else
  ROOT="$SCR/tree"; mkdir -p "$ROOT" || setup no-scratch
  git -C "$REPO" archive "$REV" 2>/dev/null | tar -x -C "$ROOT" 2>/dev/null \
    || { absent_line bad-revision; exit 1; }
fi
TRIAL="$ROOT/corpus/openbao-seal-trial.sh"
if [ ! -f "$TRIAL" ] || [ -L "$TRIAL" ]; then
  absent_line absent
  exit 1   # frozen contract: exit 0 iff guard=1 and value=5 (the BASE control leg)
fi
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
for d in /usr/bin /bin; do [ -e "$d/bao" ] && setup "bao-in-$d"; done
TRIAL_SHA=$(sha256sum < "$TRIAL" | cut -d' ' -f1)

rhex() { od -An -N8 -tx1 /dev/urandom | tr -d ' \n'; }
mkshim() { # LEG -> logging exec shim first on PATH (vacuity ops witness)
  local d=${BIN[$1]} log="$SCR/log/$1.ops"
  {
    echo '#!/bin/sh'
    echo "for a in \"\$@\"; do printf '%s ' \"\$a\" >> '$log'; done"
    echo "printf '\\n' >> '$log'"
    echo "exec '$BAO_BIN' \"\$@\""
  } > "$d/bin/bao"
  chmod +x "$d/bin/bao"
}
declare -A BIN OUT
mkdir -p "$SCR/log"
for m in real real2 none selftest sh1 sh2 sh3 sh4 sh5; do
  d="$SCR/$(rhex)"; mkdir -p "$d/bin" "$d/home" "$d/tmp" "$d/work"
  BIN[$m]="$d"; OUT[$m]="$SCR/log/$(rhex)"
  if [ "$m" != none ] && [ "$m" != selftest ]; then mkshim "$m"; fi
done
run() { # MODE SHIM -> rc in $?
  local d=${BIN[$1]}
  ( cd "$d" && exec env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" \
      TMPDIR="$d/tmp" LANG=C KAGI_SEAL_SHIM="$2" \
      timeout 900 bash "$TRIAL" --work "$d/work" ) \
    > "${OUT[$1]}" 2>"${OUT[$1]}.err"
}
run_selftest() { # fixture-driven: no bao on PATH (K5)
  local d=${BIN[selftest]}
  ( cd "$d" && exec env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" \
      TMPDIR="$d/tmp" LANG=C \
      timeout 300 bash "$TRIAL" --selftest --work "$d/work" ) \
    > "${OUT[selftest]}" 2>"${OUT[selftest]}.err"
}
SHIMV=("" SH1 SH2 SH3 SH4 SH5)
MODE=(real real2 none selftest sh1 sh2 sh3 sh4 sh5)
declare -A RC RAN
for m in $(printf '%s\n' "${MODE[@]}" | shuf); do
  case "$m" in
    sh*) n=${m#sh}; run "$m" "${SHIMV[$n]}";;
    selftest) run_selftest;;
    *) run "$m" "";;
  esac
  RC[$m]=$?; RAN[$m]=1
done
real_ok=0; [ "${RC[real]}" = 0 ] && [ "${RC[real2]}" = 0 ] \
  && [ "$(vec "${OUT[real]}")" = HHHHH ] && [ "$(vec "${OUT[real2]}")" = HHHHH ] \
  && [ "$(tlines "${OUT[real]}")" = 5 ] && [ "$(tlines "${OUT[real2]}")" = 5 ] && real_ok=1
for m in real real2; do
  holds5 "${OUT[$m]}" || real_ok=0
done
ops_ok=1
for m in real real2; do
  o="$SCR/log/$m.ops"
  # Round-61 reviewer C2-3: the witness must require argv SHAPES a real run
  # produces, not bare command names (a stub calling `bao <op> --help` logged
  # every name and passed). Each pattern below is the trial's measured argv.
  grep -qF -- 'server -config=' "$o" 2>/dev/null || ops_ok=0
  grep -qF -- 'operator init -key-shares=5 -key-threshold=3' "$o" 2>/dev/null || ops_ok=0
  grep -qE -- '^operator unseal .*[A-Za-z0-9+/=]{40,}' "$o" 2>/dev/null || ops_ok=0
  grep -qxE -- 'operator seal( |$)' "$o" 2>/dev/null || ops_ok=0
  grep -qF -- 'operator generate-root -init' "$o" 2>/dev/null || ops_ok=0
  grep -qF -- 'operator generate-root -decode=' "$o" 2>/dev/null || ops_ok=0
  grep -qF -- 'operator rekey -init -key-shares=3 -key-threshold=2' "$o" 2>/dev/null || ops_ok=0
done
t2_ok=1
for m in real real2; do
  grep -q 'progress=1/3' "${OUT[$m]}" 2>/dev/null || t2_ok=0
  grep -q 'progress=2/3' "${OUT[$m]}" 2>/dev/null || t2_ok=0
  grep -q 'sealed=false' "${OUT[$m]}" 2>/dev/null || t2_ok=0
  grep -q 't=3' "${OUT[$m]}" 2>/dev/null || t2_ok=0
  grep -q 'n=5' "${OUT[$m]}" 2>/dev/null || t2_ok=0
done
none_ok=0
[ "${RC[none]}" = 2 ] && grep -q 'SETUP' "${OUT[none]}" "${OUT[none]}.err" \
  && ! grep -q 'HOLDS' "${OUT[none]}" "${OUT[none]}.err" && none_ok=1
selftest_ok=0; sn=0
spass=$(grep -cE '^SEAL_SELFTEST: PASS \(cases=[0-9]+\)' "${OUT[selftest]}" 2>/dev/null)
if [ "${RC[selftest]}" = 0 ] && [ "$spass" = 1 ]; then
  sn=$(grep -oE '^SEAL_SELFTEST: PASS \(cases=[0-9]+\)' "${OUT[selftest]}" | grep -oE '[0-9]+')
  [ "$sn" -ge 8 ] && selftest_ok=1
fi
shims_ok=0
for n in 1 2 3 4 5; do
  [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] \
    && broken41 "${OUT[sh$n]}" && shims_ok=$((shims_ok+1))
done
pass=0
[ "$real_ok" = 1 ] && pass=5
value=0
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] \
  && [ "$selftest_ok" = 1 ] && [ "$ops_ok" = 1 ] && [ "$t2_ok" = 1 ] && value=5
stub_ok=0
if [ "${R61_C2_NOSTUB:-}" != 1 ]; then
  # Vacuity control: a fixture trial that fakes every expected line without
  # exec-ing bao must read value=0 here (its real-run ops logs stay empty).
  mkdir -p "$SCR/stubtree/corpus"
  cat > "$SCR/stubtree/corpus/openbao-seal-trial.sh" <<'STUBEOF'
#!/usr/bin/env bash
# Vacuous fixture (counter-internal control, lives only in counter scratch):
# prints every expected line and execs nothing; the counter must read value=0.
set -u
work=""; selftest=0
while [ $# -gt 0 ]; do
  case "$1" in
    --work) work=${2:-}; shift 2;;
    --selftest) selftest=1; shift;;
    *) shift;;
  esac
done
if [ "$selftest" = 1 ]; then echo "SEAL_SELFTEST: PASS (cases=8)"; exit 0; fi
if ! command -v bao >/dev/null 2>&1; then
  echo "OPENBAO_SEAL_TRIAL: SETUP no bao on PATH"; exit 2
fi
shim=${KAGI_SEAL_SHIM:-}
v1=HOLDS; v2=HOLDS; v3=HOLDS; v4=HOLDS; v5=HOLDS
case "$shim" in
  SH1) v1=BROKEN;; SH2) v2=BROKEN;; SH3) v3=BROKEN;; SH4) v4=BROKEN;; SH5) v5=BROKEN;;
esac
echo "TRIAL T1 $v1 detail-init"
echo "TRIAL T2 $v2 detail-unseal"
echo "TRIAL T3 $v3 detail-seal"
echo "TRIAL T4 $v4 detail-genroot"
echo "TRIAL T5 $v5 detail-rekey"
if [ "$v1$v2$v3$v4$v5" = HOLDSHOLDSHOLDSHOLDSHOLDS ]; then
  echo "OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"; exit 0
fi
echo "OPENBAO_SEAL_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"; exit 1
STUBEOF
  chmod +x "$SCR/stubtree/corpus/openbao-seal-trial.sh"
  sout=$(R61_C2_NOSTUB=1 bash "$SELF" --tree "$SCR/stubtree" 2>&1); src=$?
  [ "$src" = 1 ] && printf '%s\n' "$sout" | grep -q 'value=0' && stub_ok=1
fi
nosecret=1
# K3 secret scan: the trial text plus every captured stream and every receipt
# the trial wrote under its --work dirs (logs live outside the work dirs).
: > "$SCR/.hits"
while IFS= read -r sf; do
  grep -IqP "$SECRET_PCRE" "$sf" 2>/dev/null && printf '%s\n' "$sf" >> "$SCR/.hits"
done < <({ printf '%s\n' "$TRIAL"; find "$SCR" -type f ! -path "$SCR/tree/*" ! -name '.hits' ! -name '*.ops' -size -4M; } 2>/dev/null)
[ -s "$SCR/.hits" ] && nosecret=0
[ "$nosecret" = 1 ] && [ "$stub_ok" = 1 ] && [ "$value" = 5 ] || value=0
legs_ran=1
for m in real real2 none selftest sh1 sh2 sh3 sh4 sh5; do
  [ -n "${RAN[$m]+x}" ] || legs_ran=0
done
guard=0
[ "$legs_ran" = 1 ] && printf '%s' "$TRIAL_SHA" | grep -qE '^[0-9a-f]{64}$' && guard=1
V="ok"; [ "$shims_ok" = 5 ] || V=$shims_ok
printf '%s: value=%s tests=5 pass=%s shims=%s vectors=%s/5 selftest=%s guard=%s (real=%s real2=%s none=%s ops=%s t2w=%s stubctl=%s secret=%s sh1=%s sh2=%s sh3=%s sh4=%s sh5=%s trial=%s cases=%s)\n' \
  "$NAME" "$value" "$pass" "$shims_ok" "$V" "$selftest_ok" "$guard" \
  "$real_ok" "$real_ok" "$none_ok" "$ops_ok" "$t2_ok" "$stub_ok" "$nosecret" \
  "$(vec "${OUT[sh1]}")" "$(vec "${OUT[sh2]}")" "$(vec "${OUT[sh3]}")" "$(vec "${OUT[sh4]}")" "$(vec "${OUT[sh5]}")" \
  "$TRIAL_SHA" "$sn"
[ "$value" = 5 ] && [ "$guard" = 1 ] && exit 0
exit 1
