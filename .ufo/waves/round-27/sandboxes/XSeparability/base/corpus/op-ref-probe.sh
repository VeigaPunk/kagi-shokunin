#!/usr/bin/env bash
# corpus/op-ref-probe.sh — the op.env contract probe (round 12, depth axis-move)
#
# WHAT IT MEASURES. Two different parsers read `op.env`: the handler's own
# `cmd_refs` awk (an inventory: "which keys are refs?") and 1Password's dotenv
# parser inside `op run --env-file` (the resolver `cmd_run` execs). They do not
# read the same language. This gate pins, per line shape, what each side does —
# so the divergence is a verdict, not a claim.
#
# Three divergence classes, in increasing severity:
#   1. keys the resolver injects and the inventory cannot see (`export K=v`,
#      `K = v`, lowercase keys, digit-leading keys, indented keys);
#   2. values the resolver rewrites and the inventory only redacts (`#`
#      truncation, quote stripping, `$`/`${}` expansion, defaults, CRLF);
#   3. files the resolver REFUSES and the inventory reports as healthy — a
#      malformed line (`K-BAD=v`, a bare key, a lone `=`, a UTF-8 BOM) aborts
#      the whole dotenv parse with exit 1 and zero keys injected, while `refs`
#      exits 0 and prints an inventory. An audit that trusts `refs` says "fine";
#      the load says nothing.
#
# It also pins the MASKING contract: `op run` conceals *reference-resolved*
# secrets on stdout/stderr by default, and does NOT conceal plain env-file
# values (measured 2026-09-28, `op` 2.35.0, four shapes: `printenv`, `echo` in a
# subshell, a substring in a longer line, and a shell-env-only value). A future
# `op` that masks plain values fires DRIFT, and that is the point: "the value
# coming out of `the-janitor run` is masked" is false for every plain-valued key
# and true by default only for `op://` ones.
#
# SAFETY (structural, not procedural). Every invocation of the `op` binary goes
# through `op_exec()`, which guards every `--env-file=` argument it is about to
# pass (the one directory fixture is asserted to be a real directory first, which
# cannot carry a reference token). Every op-side
# fixture tree is checked by `guard_op_side()` before any exec. The guard refuses
# (POLICY, exit 2, before exec) three things: a **reference token** in the file
# (the vault would be contacted), a path that is **not a plain regular file** (a
# symlink, FIFO, socket or device — the bytes the guard checks are not provably
# the bytes `op` reads), and a fixture that **breaks a probe's premise**
# (`absent.env` must not exist; `adir` must be a real directory). Therefore this
# gate cannot resolve a reference — no vault contact, no approval prompt, no
# sign-in dependency. Ref-shaped files are read only by the handler's `refs`
# path, which is an `awk` and resolves nothing. Round-12 sentinel findings F1/F2
# (an `absent.env` and an `adir` supplied through `--fixture`) are the reason the
# guard is per-path rather than a fixed name list.
#
# VERDICTS. exit 0 CLEAN | exit 1 DRIFT (a measured behaviour changed) |
# exit 2 SETUP/POLICY (cannot measure, or refused before exec).
#
#   bash corpus/op-ref-probe.sh                 # live measurement vs contract
#   bash corpus/op-ref-probe.sh --evaluate F    # pure comparison of F (no exec)
#   bash corpus/op-ref-probe.sh --fixture DIR   # use DIR's env files
#   bash corpus/op-ref-probe.sh --selftest      # prove the comparator on canned data
#   bash corpus/op-ref-probe.sh --dotenv-bytes # op-only newline contract, isolated HOME/env
#   bash corpus/op-ref-probe.sh --dotenv-bytes --evaluate F # compare encoded byte observations
#
# Contract data lives below as shell arrays; the fixtures are generated from it
# (so a fixture cannot silently drift from the expectation) under a `mktemp -d`
# unless `--fixture` names a directory. Fixtures are plain-valued by design and
# the guard enforces it; one `refs`-side fixture (`refsclass.env`) carries ref
# tokens and is never passed to the op binary.

set -uo pipefail

SELF=${BASH_SOURCE[0]}
VERSION=v4
MODE=verify
FIXTURE_DIR=
EVAL_FILE=
DOTENV_BYTES=0
OP_BIN=${OP_REF_OP_BIN:-op}
JAN_BIN=${OP_REF_JANITOR_BIN:-$HOME/.local/bin/the-janitor}
REDACTED='<redacted-non-op-value>'

# ---------------------------------------------------------------- contract ---
# `op run` side: key <TAB> value as `op` 2.35.0 injects it. Fixtures are
# plain-valued only (the POLICY guard enforces it).
OPRUN_CONTRACT=(
  $'KAGI12_A\talpha-value'
  $'KAGI12_B\tspaced-value'
  $'KAGI12_C\tquoted value'
  $'KAGI12_D\texported-value'
  $'kagi12_lower\tlower-value'
  $'KAGI12_F\ta\\ b'
  $'KAGI12_G\t'
  $'KAGI12_H\ttrail-value'
  $'KAGI12_I\talpha-value'
  $'KAGI12_J\talpha-value-suffix'
  $'1KAGI12X\tone'
  $'KAGI12_L\tlima'
)
# `refs` side over the same file, in file order: the awk matches only
# `^[A-Z][A-Z0-9_]*=` at column 0, so every row below is invisible to it.
DIVERGENT_CONTRACT=(KAGI12_B KAGI12_D kagi12_lower 1KAGI12X KAGI12_L)
REFS_CONTRACT=(KAGI12_A KAGI12_C KAGI12_F KAGI12_G KAGI12_H KAGI12_I KAGI12_J)
# dotenv edge semantics as `op` 2.35.0 implements them: `#` truncates an
# unquoted value anywhere, quotes protect it, expansion supports `$K`/`${K}`/
# `${K:-default}` in double quotes and is SUPPRESSED in single quotes, CRLF and
# surrounding whitespace are trimmed, and `op` also trims values inherited from
# the parent environment.
EDGE_CONTRACT=(
  $'KAGI12_E1\tab'
  $'KAGI12_E2\tab'
  $'KAGI12_E3\tquoted#hash'
  $'KAGI12_E4\tcrlf'
  $'KAGI12_E5\tthree'
  $'KAGI12_E6\tspaces'
  $'KAGI12_E7\ttab'
  $'KAGI12_E8\tfallback'
  $'KAGI12_E9\t$KAGI12_E8'
)
# refs-side classification over ref-shaped values (never given to `op`).
REFSCLASS_CONTRACT=(
  $'KAGI12_R1\tverbatim'
  $'KAGI12_R2\tredacted'
  $'KAGI12_R3\tredacted'
  $'KAGI12_R4\tredacted'
  $'KAGI12_R5\tverbatim'
  $'KAGI12_R5\tverbatim'
)
SIG_CONTRACT=(
  $'op-missing-envfile\t1\tno such file or directory'
  $'op-no-command\t1\texpected at least 1 arguments'
  $'janitor-refs-missing\t2\tthe-janitor: missing '
  $'janitor-run-no-command\t2\tmissing command'
  $'op-dotenv-badchar\t1\tparsing Dotenv file'
  $'op-envfile-directory\t1\tis a directory'
)
PRECEDENCE_CONTRACT=$'KAGI12_P8\tsecond'
UNION_CONTRACT=$'KAGI12_P9\tonlyfirst'
INHERITED_CONTRACT=$'KAGI12_T\tspaced'
MALFORMED_REFS_CONTRACT=(KAGI12_GOOD)
MASK_CONTRACT=$'KAGI12_A\talpha-value'

# Separate from the line-oriented v4 observations: hex preserves trailing LFs.
# Expectations are literal measured bytes, not decoded from the input fixtures.
DOTENV_BYTE_CONTRACT=(
  $'escaped-lf\t616c7068610a62657461'
  $'trailing-lf\t616c7068610a0a'
  $'newline-only\t0a'
  $'single-literal\t616c7068615c6e62657461'
  $'double-multiline\t616c7068610a62657461'
  $'single-multiline\t616c7068610a62657461'
)

# ------------------------------------------------------------------ output ---
WORK= OBS=
cleanup() {
  [[ -n $WORK ]] && rm -rf "$WORK"
  [[ -n $OBS ]] && rm -f "$OBS"
  return 0
}
trap cleanup EXIT

C_N=0 C_FAILED=0
fail() { C_FAILED=$((C_FAILED + 1)); printf 'FAIL %s\n' "$*"; }
die()  { printf '%s\n' "$1"; exit "${2:-2}"; }

usage() { sed -n '2,40p' "$SELF" | sed 's/^# \{0,1\}//'; }

# --------------------------------------------------------------- fixtures ---
write_fixtures() {
  local d=$1
  mkdir -p "$d"
  {
    printf '%s\n' '# kagi12 op-run fixture: plain values only, no ref scheme token'
    printf '%s\n' 'KAGI12_A=alpha-value'
    printf '%s\n' 'KAGI12_B = spaced-value'
    printf '%s\n' 'KAGI12_C="quoted value"'
    printf '%s\n' 'export KAGI12_D=exported-value'
    printf '%s\n' 'kagi12_lower=lower-value'
    printf '%s\n' 'KAGI12_F=a\ b'
    printf '%s\n' 'KAGI12_G='
    printf '%s\n' 'KAGI12_H=trail-value # inline comment'
    printf '%s\n' 'KAGI12_I=$KAGI12_A'
    printf '%s\n' 'KAGI12_J=${KAGI12_A}-suffix'
    printf '%s\n' '1KAGI12X=one'
    printf '%s\n' '  KAGI12_L=lima'
  } >"$d/oprun.env"
  {
    printf '%s\n' 'KAGI12_E1=ab#cd'
    printf '%s\n' 'KAGI12_E2=ab #cd'
    printf '%s\n' 'KAGI12_E3="quoted#hash"'
    printf 'KAGI12_E4=crlf\r\n'
    printf '%s\n' 'KAGI12_E5=one'
    printf '%s\n' 'KAGI12_E5=two'
    printf '%s\n' 'KAGI12_E5=three'
    printf 'KAGI12_E6=spaces   \n'
    printf '%s\n' 'KAGI12_E7= tab'
    printf '%s\n' 'KAGI12_E8=${KAGI12_E8_UNSET:-fallback}'
    printf '%s\n' "KAGI12_E9='\$KAGI12_E8'"
  } >"$d/edge.env"
  printf '%s\n' 'KAGI12_P8=first' 'KAGI12_P9=onlyfirst' >"$d/two1.env"
  printf '%s\n' 'KAGI12_P8=second' >"$d/two2.env"
  # A malformed line: the resolver aborts the whole file, the inventory does not.
  printf '%s\n' 'KAGI12_GOOD=good' 'KAGI12-BAD=v' >"$d/malformed.env"
  mkdir -p "$d/adir"
  # refs-side only: the POLICY guard keeps this file away from the op binary.
  {
    printf '%s\n' 'KAGI12_R1=op://Kagi12NoVault/I/F'
    printf '%s\n' 'KAGI12_R2="op://Kagi12NoVault/I/F"'
    printf '%s\n' 'KAGI12_R3=pre-op://Kagi12NoVault/I/F'
    printf '%s\n' 'KAGI12_R4='
    printf '%s\n' 'KAGI12_R5=op://Kagi12NoVault/I/F'
    printf '%s\n' 'KAGI12_R5=op://Kagi12NoVault/I/F'
  } >"$d/refsclass.env"
}

# Refuse any op-side file that carries a reference token. Runs in the main
# shell (so `exit 2` is a real refusal, not a subshell's).
guard_op_side() {
  local d=$1 f
  for f in oprun.env edge.env two1.env two2.env malformed.env; do
    [[ -e $d/$f || -L $d/$f ]] || continue
    guard_op_file "$d/$f" ||
      die "OP_REF_PROBE: POLICY (op-side fixture file failed the guard: $f)" 2
  done
  if [[ -e $d/adir || -L $d/adir ]]; then
    [[ -d $d/adir && ! -L $d/adir ]] ||
      die "OP_REF_PROBE: POLICY (adir exists but is not a real directory, refused before exec)" 2
  fi
  if [[ -e $d/absent.env || -L $d/absent.env ]]; then
    die "OP_REF_PROBE: POLICY (absent.env must not exist: it is the missing-file probe premise)" 2
  fi
}

# ------------------------------------------------------------------ probes ---
# The single guard for any path the op binary will read. Returns 0 (safe), or 2
# after printing POLICY (refused before exec).
guard_op_file() { # path
  local f=$1
  if [[ -e $f || -L $f ]]; then
    if [[ -L $f || ! -f $f ]]; then
      printf 'OP_REF_PROBE: POLICY (op-side path is not a plain regular file, refused before exec: %s)\n' "$f" >&2
      return 2
    fi
    if grep -q 'op://' "$f" 2>/dev/null; then
      printf 'OP_REF_PROBE: POLICY (env-file carries a reference token, refused before exec: %s)\n' "$f" >&2
      return 2
    fi
  fi
  return 0
}

# The single chokepoint: every op invocation goes through op_exec, which guards
# each `--env-file=` argument before the process starts. `DIR_OK` is the one
# sanctioned non-regular path (the directory-signature fixture), and it is only
# ever set after the caller asserted `-d` and non-symlink.
DIR_OK=
op_exec() { # op-args... (e.g. run --env-file=F -- printenv KEY)
  local a f
  for a in "$@"; do
    case $a in
      --env-file=*)
        f=${a#--env-file=}
        if [[ -n $DIR_OK && $f == "$DIR_OK" ]]; then continue; fi
        guard_op_file "$f" || return 2 ;;
    esac
  done
  if ((DOTENV_BYTES)); then
    env -i PATH=/usr/bin:/bin HOME="$WORK/home" \
      XDG_CONFIG_HOME="$WORK/config" XDG_CACHE_HOME="$WORK/cache" XDG_DATA_HOME="$WORK/data" \
      OP_BIOMETRIC_UNLOCK_ENABLED=false OP_CACHE=false \
      timeout 10 "$OP_BIN" "$@"
  else
    "$OP_BIN" "$@"
  fi
}

op_run() { # f args...  — convenience wrapper for the common `run --env-file=F -- args`
  local f=$1; shift
  op_exec run --env-file="$f" -- "$@"
}

sig_probe() { # name — prints one `sig` row (every op path guarded first)
  local name=$1 txt rc
  case $name in
    op-missing-envfile)
      # premise: the file must NOT exist. If it does, the fixture is refused.
      if [[ -e $OP_ABSENT || -L $OP_ABSENT ]]; then
        printf 'OP_REF_PROBE: POLICY (absent.env must not exist: it is the missing-file probe premise)\n' >&2
        return 2
      fi
      txt=$(op_exec run --env-file="$OP_ABSENT" -- printenv KAGI12_A 2>&1); rc=$? ;;
    op-no-command)
      txt=$(op_exec run --env-file="$OPRUN_F" 2>&1); rc=$? ;;
    op-dotenv-badchar)
      txt=$(op_exec run --env-file="$FIX_F/malformed.env" -- true 2>&1); rc=$? ;;
    op-envfile-directory)
      # premise: a real directory (never a symlink, never a file that could
      # carry a reference token).
      if [[ -L $FIX_F/adir || ! -d $FIX_F/adir ]]; then
        printf 'OP_REF_PROBE: POLICY (adir must be a real directory, refused before exec)\n' >&2
        return 2
      fi
      DIR_OK=$FIX_F/adir
      txt=$(op_exec run --env-file="$FIX_F/adir" -- true 2>&1); rc=$?
      DIR_OK= ;;
    janitor-refs-missing)   txt=$(THE_JANITOR_ENV="$OP_ABSENT" "$JAN_BIN" refs 2>&1); rc=$? ;;
    janitor-run-no-command) txt=$(THE_JANITOR_ENV="$OPRUN_F" "$JAN_BIN" run 2>&1); rc=$? ;;
    *) return 1 ;;
  esac
  printf 'sig\t%s\t%s\t%s\n' "$name" "$rc" "$txt"
}

refs_rows() { # kind envfile
  local kind=$1 f=$2 line key val cls
  while IFS= read -r line; do
    [[ $line == *'='* ]] || continue
    key=${line%%=*}
    [[ $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
    val=${line#*=}
    if [[ $val == op://* ]]; then cls=verbatim; else cls=redacted; fi
    printf '%s\t%s\t%s\t%s\n' "$kind" "$key" "$cls" "$val"
  done < <(THE_JANITOR_ENV="$f" "$JAN_BIN" refs 2>/dev/null)
}

collect() { # fixture-dir out-file
  local d=$1 out=$2 line key val
  FIX_F=$d
  OPRUN_F=$d/oprun.env
  OP_ABSENT=$d/absent.env # never created
  : >"$out"
  for line in "${OPRUN_CONTRACT[@]}"; do
    key=${line%%$'\t'*}
    val=$(op_run "$d/oprun.env" printenv "$key" 2>/dev/null); local rc=$?
    if [[ $rc -eq 0 ]]; then
      printf 'oprun\t%s\tpresent\t%s\n' "$key" "$val" >>"$out"
    else
      printf 'oprun\t%s\tabsent\t\n' "$key" >>"$out"
    fi
  done
  val=$(op_run "$d/oprun.env" printenv KAGI12_A 2>/dev/null) || val=
  printf 'mask\tKAGI12_A\ton\t%s\n' "$val" >>"$out"
  val=$(op_exec run --no-masking --env-file="$d/oprun.env" -- printenv KAGI12_A 2>/dev/null) || val=
  printf 'mask\tKAGI12_A\toff\t%s\n' "$val" >>"$out"
  for line in "${EDGE_CONTRACT[@]}"; do
    key=${line%%$'\t'*}
    val=$(op_run "$d/edge.env" printenv "$key" 2>/dev/null) || val=
    printf 'edge\t%s\tvalue\t%s\n' "$key" "$val" >>"$out"
  done
  val=$(op_run "$d/two1.env" printenv KAGI12_P8 2>/dev/null) || val=
  printf 'edge\tKAGI12_P8\tvalue\t%s\n' "$val" >>"$out"
  val=$(op_exec run --env-file="$d/two1.env" --env-file="$d/two2.env" -- printenv KAGI12_P8 2>/dev/null) || val=
  printf 'prec\tKAGI12_P8\tvalue\t%s\n' "$val" >>"$out"
  val=$(op_exec run --env-file="$d/two1.env" --env-file="$d/two2.env" -- printenv KAGI12_P9 2>/dev/null) || val=
  printf 'union\tKAGI12_P9\tvalue\t%s\n' "$val" >>"$out"
  val=$(KAGI12_T='  spaced  ' op_exec run --env-file="$d/oprun.env" -- printenv KAGI12_T 2>/dev/null) || val=
  printf 'inh\tKAGI12_T\tvalue\t%s\n' "$val" >>"$out"
  refs_rows refs "$d/oprun.env" >>"$out"
  refs_rows refsclass "$d/refsclass.env" >>"$out"
  refs_rows malformedrefs "$d/malformed.env" >>"$out"
  for line in "${SIG_CONTRACT[@]}"; do
    sig_probe "${line%%$'\t'*}" >>"$out"
  done
}

# ---------------------------------------------------------------- evaluate ---
get_field() { awk -F'\t' -v k="$1" -v key="$2" -v i="$3" '$1==k && $2==key {print $i; exit}' "$4"; }
count_rows() { awk -F'\t' -v k="$1" '$1==k {n++} END{print n+0}' "$2"; }

evaluate() {
  local f=$1 line key want got cls extra
  C_N=0 C_FAILED=0
  for line in "${OPRUN_CONTRACT[@]}"; do
    key=${line%%$'\t'*}; want=${line#*$'\t'}
    C_N=$((C_N + 1))
    cls=$(get_field oprun "$key" 3 "$f")
    if [[ $cls != present ]]; then
      fail "oprun-key-present key=$key observed=${cls:-missing}"
      continue
    fi
    got=$(get_field oprun "$key" 4 "$f")
    [[ $got == "$want" ]] || fail "oprun-value key=$key expected=<$want> observed=<$got>"
  done
  C_N=$((C_N + 1))
  extra=$(awk -F'\t' '$1=="oprun"{print $2}' "$f" | sort -u |
    grep -vxF -e "$(printf '%s\n' "${OPRUN_CONTRACT[@]}" | cut -f1)" | head -3)
  [[ -z $extra ]] || fail "oprun-extra-keys observed=$(printf '%s' "$extra" | tr '\n' ',')"

  C_N=$((C_N + 1))
  local got_keys want_keys
  got_keys=$(awk -F'\t' '$1=="refs"{print $2}' "$f" | tr '\n' ' ')
  want_keys="${REFS_CONTRACT[*]} "
  [[ "$got_keys" == "$want_keys" ]] || fail "refs-inventory expected=<$want_keys> observed=<$got_keys>"

  C_N=$((C_N + 1))
  local div want_div
  div=$(comm -23 <(awk -F'\t' '$1=="oprun" && $3=="present"{print $2}' "$f" | sort) \
                 <(awk -F'\t' '$1=="refs"{print $2}' "$f" | sort -u) | grep -v '^$' | tr '\n' ' ')
  want_div=$(printf '%s\n' "${DIVERGENT_CONTRACT[@]}" | sort | tr '\n' ' ')
  [[ "$div" == "$want_div" ]] || fail "refs-missing-keys expected=<$want_div> observed=<$div>"

  for line in "${EDGE_CONTRACT[@]}"; do
    key=${line%%$'\t'*}; want=${line#*$'\t'}
    C_N=$((C_N + 1))
    got=$(get_field edge "$key" 4 "$f")
    [[ "$got" == "$want" ]] || fail "edge-value key=$key expected=<$want> observed=<$got>"
  done
  key=${PRECEDENCE_CONTRACT%%$'\t'*}; want=${PRECEDENCE_CONTRACT#*$'\t'}
  C_N=$((C_N + 1))
  got=$(get_field prec "$key" 4 "$f")
  [[ "$got" == "$want" ]] || fail "precedence key=$key expected=<$want> observed=<$got>"
  key=${UNION_CONTRACT%%$'\t'*}; want=${UNION_CONTRACT#*$'\t'}
  C_N=$((C_N + 1))
  got=$(get_field union "$key" 4 "$f")
  [[ "$got" == "$want" ]] || fail "env-file-union key=$key expected=<$want> observed=<$got>"
  key=${INHERITED_CONTRACT%%$'\t'*}; want=${INHERITED_CONTRACT#*$'\t'}
  C_N=$((C_N + 1))
  got=$(get_field inh "$key" 4 "$f")
  [[ "$got" == "$want" ]] || fail "inherited-trim key=$key expected=<$want> observed=<$got>"

  key=${MASK_CONTRACT%%$'\t'*}; want=${MASK_CONTRACT#*$'\t'}
  local on off
  on=$(get_field mask "$key" 4 "$f")
  off=$(awk -F'\t' -v k="$key" '$1=="mask" && $2==k && $3=="off" {print $4; exit}' "$f")
  C_N=$((C_N + 1))
  [[ "$on" == "$want" ]] || fail "masking mode=on key=$key expected=<$want> observed=<$on>"
  C_N=$((C_N + 1))
  [[ "$on" == "$off" ]] || fail "masking flag-effect on=<$on> off=<$off>"

  for line in "${SIG_CONTRACT[@]}"; do
    local name rcwant frag rc text
    name=${line%%$'\t'*}; line=${line#*$'\t'}
    rcwant=${line%%$'\t'*}; frag=${line#*$'\t'}
    C_N=$((C_N + 1))
    rc=$(get_field sig "$name" 3 "$f")
    text=$(get_field sig "$name" 4 "$f")
    if [[ $rc != "$rcwant" ]]; then
      fail "signature $name exit expected=$rcwant observed=${rc:-missing}"
    elif [[ $text != *"$frag"* ]]; then
      fail "signature $name text-fragment expected=<$frag> observed=<$text>"
    fi
  done

  local i=0 wantrow
  while IFS=$'\t' read -r kind k cls val; do
    [[ $kind == refsclass ]] || continue
    i=$((i + 1))
    C_N=$((C_N + 1))
    wantrow=$(printf '%s\n' "${REFSCLASS_CONTRACT[@]}" | awk -F'\t' -v n="$i" 'NR==n{print $1"="$2}')
    [[ "$wantrow" == "$k=$cls" ]] || fail "refsclass row=$i expected=<$wantrow> observed=<$k=$cls>"
  done <"$f"
  local nclass
  nclass=$(count_rows refsclass "$f")
  C_N=$((C_N + 1))
  [[ $nclass -eq ${#REFSCLASS_CONTRACT[@]} ]] || fail "refsclass-rows expected=${#REFSCLASS_CONTRACT[@]} observed=$nclass"

  # malformed file: the inventory reports it healthy while the resolver aborts.
  C_N=$((C_N + 1))
  local mkeys
  mkeys=$(awk -F'\t' '$1=="malformedrefs"{print $2}' "$f" | tr '\n' ' ')
  [[ "$mkeys" == "${MALFORMED_REFS_CONTRACT[*]} " ]] ||
    fail "malformed-refs-inventory expected=<${MALFORMED_REFS_CONTRACT[*]} > observed=<$mkeys>"
  C_N=$((C_N + 1))
  local mrc
  mrc=$(get_field sig op-dotenv-badchar 3 "$f")
  [[ $mrc == 1 && $mkeys == *KAGI12_GOOD* ]] ||
    fail "malformed-blindness refs=<$mkeys> op-exit=${mrc:-missing} (an inventory that reports a refused file as healthy)"

  local nop nref nedge nsig
  nop=$(count_rows oprun "$f"); nref=$(count_rows refs "$f")
  nedge=$(count_rows edge "$f"); nsig=$(count_rows sig "$f")
  if [[ $C_FAILED -gt 0 ]]; then
    printf 'OP_REF_PROBE: DRIFT (checks=%d failed=%d oprun=%d refs=%d divergent=%d edge=%d sig=%d)\n' \
      "$C_N" "$C_FAILED" "$nop" "$nref" "${#DIVERGENT_CONTRACT[@]}" "$nedge" "$nsig"
    return 1
  fi
  printf 'OP_REF_PROBE: CLEAN (checks=%d oprun=%d refs=%d divergent=%d edge=%d sig=%d)\n' \
    "$C_N" "$nop" "$nref" "${#DIVERGENT_CONTRACT[@]}" "$nedge" "$nsig"
  return 0
}

# ------------------------------------------------------------------ verify ---
verify() {
  local d=$FIXTURE_DIR
  if [[ -z $d ]]; then
    WORK=$(mktemp -d)
    d=$WORK
    write_fixtures "$d"
  elif [[ ! -d $d ]]; then
    die "OP_REF_PROBE: SETUP (fixture dir not a directory: $d)" 2
  fi
  guard_op_side "$d"
  command -v "$OP_BIN" >/dev/null 2>&1 ||
    die "OP_REF_PROBE: SETUP (op binary not found: $OP_BIN)" 2
  [[ -x $JAN_BIN ]] ||
    die "OP_REF_PROBE: SETUP (janitor binary not executable: $JAN_BIN)" 2
  OBS=$(mktemp)
  collect "$d" "$OBS"
  evaluate "$OBS"
}

# The op-only arm never consumes --fixture, the real op.env, or inherited values.
evaluate_bytes() {
  local f=$1 id rc hex extra line want i=0 failed=0
  while IFS=$'\t' read -r id rc hex extra || [[ -n $id ]]; do
    [[ $i -lt ${#DOTENV_BYTE_CONTRACT[@]} ]] ||
      die "OP_DOTENV_BYTES: SETUP (extra observation row)" 2
    line=${DOTENV_BYTE_CONTRACT[i]}
    [[ $id == "${line%%$'\t'*}" && $rc =~ ^[0-9]+$ &&
       $hex =~ ^([0-9a-f][0-9a-f])*$ && -z $extra ]] ||
      die "OP_DOTENV_BYTES: SETUP (observation schema or order)" 2
    want=${line#*$'\t'}
    if [[ $rc == 0 && $hex == "$want" ]]; then
      printf 'DOTENV_BYTES_CASE id=%s status=PASS\n' "$id"
    else
      printf 'DOTENV_BYTES_CASE id=%s status=FAIL reason=exit-or-bytes\n' "$id"
      failed=$((failed + 1))
    fi
    i=$((i + 1))
  done <"$f"
  failed=$((failed + ${#DOTENV_BYTE_CONTRACT[@]} - i))
  if ((failed)); then
    printf 'OP_DOTENV_BYTES: DRIFT (checks=%d failed=%d)\n' "$i" "$failed"
    return 1
  fi
  printf 'OP_DOTENV_BYTES: CLEAN (checks=%d failed=0)\n' "$i"
}

dotenv_bytes() {
  local tool line id rc hex
  for tool in env timeout od tr mktemp mkdir sh; do
    command -v "$tool" >/dev/null 2>&1 ||
      die "OP_DOTENV_BYTES: SETUP (missing tool: $tool)" 2
  done
  OP_BIN=$(command -v "$OP_BIN") ||
    die "OP_DOTENV_BYTES: SETUP (op binary not found)" 2
  umask 077
  WORK=$(mktemp -d) || die "OP_DOTENV_BYTES: SETUP (scratch directory)" 2
  mkdir -p "$WORK/home" "$WORK/config" "$WORK/cache" "$WORK/data" ||
    die "OP_DOTENV_BYTES: SETUP (isolated directories)" 2
  : >"$WORK/bytes.tsv"
  for line in "${DOTENV_BYTE_CONTRACT[@]}"; do
    id=${line%%$'\t'*}
    case $id in
      escaped-lf) printf '%s\n' 'KAGI16_VALUE="alpha\nbeta"' ;;
      trailing-lf) printf '%s\n' 'KAGI16_VALUE="alpha\n\n"' ;;
      newline-only) printf '%s\n' 'KAGI16_VALUE="\n"' ;;
      single-literal) printf '%s\n' "KAGI16_VALUE='alpha\\nbeta'" ;;
      double-multiline) printf 'KAGI16_VALUE="alpha\nbeta"\n' ;;
      single-multiline) printf "KAGI16_VALUE='alpha\nbeta'\n" ;;
    esac >"$WORK/plain.env"
    op_exec run --env-file="$WORK/plain.env" -- /bin/sh -c \
      'printf %s "${KAGI16_VALUE?missing generated key}"' \
      >"$WORK/actual" 2>"$WORK/stderr"
    rc=$?
    # Only the hex representation enters command substitution, never raw bytes.
    hex=$(od -An -v -tx1 "$WORK/actual" | tr -d ' \n') ||
      die "OP_DOTENV_BYTES: SETUP (byte encoding failed)" 2
    printf '%s\t%d\t%s\n' "$id" "$rc" "$hex" >>"$WORK/bytes.tsv"
  done
  evaluate_bytes "$WORK/bytes.tsv"
}

# ---------------------------------------------------------------- selftest ---
S_N=0 S_FAIL=0
tcase() { # id want_rc pattern cmd...
  local id=$1 want_rc=$2 want_re=$3; shift 3
  local out rc
  out=$("$@" 2>&1); rc=$?
  S_N=$((S_N + 1))
  if [[ $rc -ne $want_rc ]]; then
    printf 'FAIL case=%s exit=%d want=%d out=<%s>\n' "$id" "$rc" "$want_rc" "$out"
    S_FAIL=$((S_FAIL + 1))
  elif ! grep -qE -- "$want_re" <<<"$out"; then
    printf 'FAIL case=%s pattern=<%s> out=<%s>\n' "$id" "$want_re" "$out"
    S_FAIL=$((S_FAIL + 1))
  fi
}

emit_faithful() { # out-file — generated from the contract, not hand-written
  local f=$1 line key
  : >"$f"
  for line in "${OPRUN_CONTRACT[@]}"; do
    printf 'oprun\t%s\tpresent\t%s\n' "${line%%$'\t'*}" "${line#*$'\t'}" >>"$f"
  done
  printf 'mask\tKAGI12_A\ton\talpha-value\n' >>"$f"
  printf 'mask\tKAGI12_A\toff\talpha-value\n' >>"$f"
  for line in "${EDGE_CONTRACT[@]}"; do
    printf 'edge\t%s\tvalue\t%s\n' "${line%%$'\t'*}" "${line#*$'\t'}" >>"$f"
  done
  printf 'edge\tKAGI12_P8\tvalue\tfirst\n' >>"$f"
  printf 'prec\tKAGI12_P8\tvalue\tsecond\n' >>"$f"
  printf 'union\tKAGI12_P9\tvalue\tonlyfirst\n' >>"$f"
  printf 'inh\tKAGI12_T\tvalue\tspaced\n' >>"$f"
  for k in "${REFS_CONTRACT[@]}"; do printf 'refs\t%s\tredacted\t%s\n' "$k" "$REDACTED" >>"$f"; done
  for line in "${REFSCLASS_CONTRACT[@]}"; do
    printf 'refsclass\t%s\t%s\t-\n' "${line%%$'\t'*}" "${line#*$'\t'}" >>"$f"
  done
  for k in "${MALFORMED_REFS_CONTRACT[@]}"; do printf 'malformedrefs\t%s\tredacted\t%s\n' "$k" "$REDACTED" >>"$f"; done
  for line in "${SIG_CONTRACT[@]}"; do
    printf 'sig\t%s\t%s\t%s\n' "${line%%$'\t'*}" "$(cut -f2 <<<"$line")" "$(cut -f3 <<<"$line")" >>"$f"
  done
}

selftest() {
  S_N=0 S_FAIL=0
  local c p log stub
  WORK=$(mktemp -d)
  local d=$WORK
  c=$d/canned; mkdir -p "$c"
  emit_faithful "$c/faithful.tsv"

  tcase canned-faithful 0 '^OP_REF_PROBE: CLEAN ' bash "$SELF" --evaluate "$c/faithful.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="refsclass"{next} {print}' "$c/faithful.tsv" >"$c/no-refsclass.tsv"
  tcase canned-refsclass-missing 1 'refsclass-rows' bash "$SELF" --evaluate "$c/no-refsclass.tsv"

  { cat "$c/faithful.tsv"; printf 'oprun\tKAGI12_ZZZ\tpresent\tzzz\n'; } >"$c/extra-key.tsv"
  tcase canned-oprun-extra-key 1 'oprun-extra-keys' bash "$SELF" --evaluate "$c/extra-key.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="refs"{print; print "refs\tKAGI12_B\tredacted\t'"$REDACTED"'"}' \
    "$c/faithful.tsv" >"$c/refs-compat.tsv"
  tcase canned-refs-compat 1 'refs-missing-keys' bash "$SELF" --evaluate "$c/refs-compat.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="oprun" && $2=="KAGI12_A"{$4="ALPHA-VALUE"} {print}' \
    "$c/faithful.tsv" >"$c/value-drift.tsv"
  tcase canned-value-drift 1 'oprun-value key=KAGI12_A' bash "$SELF" --evaluate "$c/value-drift.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="mask"{$4="<masked>"} {print}' \
    "$c/faithful.tsv" >"$c/masked.tsv"
  tcase canned-masked-plain 1 'masking mode=on' bash "$SELF" --evaluate "$c/masked.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="edge" && $2=="KAGI12_E1"{$4="ab#cd"} {print}' \
    "$c/faithful.tsv" >"$c/edge-drift.tsv"
  tcase canned-edge-drift 1 'edge-value key=KAGI12_E1' bash "$SELF" --evaluate "$c/edge-drift.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="edge" && $2=="KAGI12_E9"{$4="fallback"} {print}' \
    "$c/faithful.tsv" >"$c/quote-drift.tsv"
  tcase canned-quote-drift 1 'edge-value key=KAGI12_E9' bash "$SELF" --evaluate "$c/quote-drift.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="prec"{$4="first"} {print}' \
    "$c/faithful.tsv" >"$c/prec-drift.tsv"
  tcase canned-precedence-drift 1 'precedence key=KAGI12_P8' bash "$SELF" --evaluate "$c/prec-drift.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="union"{$4=""} {print}' \
    "$c/faithful.tsv" >"$c/union-drift.tsv"
  tcase canned-union-drift 1 'env-file-union key=KAGI12_P9' bash "$SELF" --evaluate "$c/union-drift.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="inh"{$4="  spaced  "} {print}' \
    "$c/faithful.tsv" >"$c/inh-drift.tsv"
  tcase canned-inherited-drift 1 'inherited-trim key=KAGI12_T' bash "$SELF" --evaluate "$c/inh-drift.tsv"

  # the strongest class: the resolver refuses the file, the inventory clears it.
  awk -F'\t' 'BEGIN{OFS="\t"} $1=="sig" && $2=="op-dotenv-badchar"{$3="0"} {print}' \
    "$c/faithful.tsv" >"$c/malformed-blind.tsv"
  tcase canned-malformed-blind 1 'malformed-blindness' bash "$SELF" --evaluate "$c/malformed-blind.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="malformedrefs"{next} {print}' \
    "$c/faithful.tsv" >"$c/malformed-norefs.tsv"
  tcase canned-malformed-norefs 1 'malformed-refs-inventory' bash "$SELF" --evaluate "$c/malformed-norefs.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="oprun" && $2=="kagi12_lower"{$3="absent";$4=""} {print}' \
    "$c/faithful.tsv" >"$c/key-gone.tsv"
  tcase canned-oprun-key-gone 1 'oprun-key-present key=kagi12_lower' bash "$SELF" --evaluate "$c/key-gone.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="sig" && $2=="op-no-command"{$3="0"} {print}' \
    "$c/faithful.tsv" >"$c/sig-drift.tsv"
  tcase canned-signature-drift 1 'signature op-no-command exit' bash "$SELF" --evaluate "$c/sig-drift.tsv"

  awk -F'\t' 'BEGIN{OFS="\t"} $1=="refsclass" && $2=="KAGI12_R2"{$3="verbatim"} {print}' \
    "$c/faithful.tsv" >"$c/refsclass-drift.tsv"
  tcase canned-refsclass-drift 1 'refsclass row=2' bash "$SELF" --evaluate "$c/refsclass-drift.tsv"

  tcase canned-missing-file 2 'OP_REF_PROBE: SETUP' bash "$SELF" --evaluate "$c/nope.tsv"
  tcase op-binary-missing 2 'SETUP \(op binary not found' \
    env OP_REF_OP_BIN=/nonexistent/kagi12-op bash "$SELF" --fixture "$c"
  tcase janitor-binary-missing 2 'SETUP \(janitor binary not executable' \
    env OP_REF_JANITOR_BIN=/nonexistent/kagi12-jan bash "$SELF" --fixture "$c"

  # POLICY: an op-side file carrying a ref token must be refused before exec —
  # proven by a logger stub that would record any invocation.
  p=$d/poison; log=$d/op-ran.log; stub=$d/op-stub
  mkdir -p "$p"; write_fixtures "$p"
  printf '%s\n' 'KAGI12_POISON=op://Kagi12NoVault/I/F' >>"$p/oprun.env"
  printf '#!/usr/bin/env bash\nprintf "ran\\n" >>"%s"\nexit 0\n' "$log" >"$stub"
  chmod +x "$stub"
  tcase policy-ref-token 2 'OP_REF_PROBE: POLICY' \
    env OP_REF_OP_BIN="$stub" bash "$SELF" --evaluate "$c/faithful.tsv" --fixture "$p"
  S_N=$((S_N + 1))
  if [[ -s $log ]]; then
    printf 'FAIL case=policy-ref-token op-binary-ran=<%s>\n' "$(cat "$log")"
    S_FAIL=$((S_FAIL + 1))
  fi

  # Sentinel F1/F2/F3: a fixture tree must not be able to hand the op binary a
  # ref-bearing absent.env, a *file* named adir, a symlinked or non-regular
  # env file. Each case asserts POLICY **and** an empty stub log.
  policy_case() { # id mutation...
    local id=$1; shift
    local q=$d/pol-$id qlog=$d/pol-$id.log qstub=$d/pol-$id-stub
    mkdir -p "$q"; write_fixtures "$q"
    "$@" "$q"
    printf '#!/usr/bin/env bash\nprintf "ran\\n" >>"%s"\nexit 0\n' "$qlog" >"$qstub"
    chmod +x "$qstub"
    tcase "$id" 2 'OP_REF_PROBE: POLICY' \
      env OP_REF_OP_BIN="$qstub" bash "$SELF" --evaluate "$c/faithful.tsv" --fixture "$q"
    S_N=$((S_N + 1))
    if [[ -s $qlog ]]; then
      printf 'FAIL case=%s op-binary-ran=<%s>\n' "$id" "$(cat "$qlog")"
      S_FAIL=$((S_FAIL + 1))
    fi
  }
  poison_absent() { printf '%s\n' 'KAGI12_P=op://Kagi12NoVault/I/F' >"$1/absent.env"; }
  poison_adir_file() { rm -rf "$1/adir"; printf '%s\n' 'KAGI12_P=op://Kagi12NoVault/I/F' >"$1/adir"; }
  poison_symlink() { printf '%s\n' 'KAGI12_P=op://Kagi12NoVault/I/F' >"$1/target.env"; rm -f "$1/oprun.env"; ln -s target.env "$1/oprun.env"; }
  poison_fifo() { rm -f "$1/oprun.env"; mkfifo "$1/oprun.env"; }

  policy_case absent-present poison_absent
  policy_case adir-is-a-file poison_adir_file
  policy_case env-symlink poison_symlink
  policy_case env-fifo poison_fifo


  # Independent byte observations: catch consumer-visible newline loss, not
  # whether a mocked op repeats the contract it was handed.
  printf '%s\n' \
    $'escaped-lf\t0\t616c7068610a62657461' \
    $'trailing-lf\t0\t616c7068610a0a' \
    $'newline-only\t0\t0a' \
    $'single-literal\t0\t616c7068615c6e62657461' \
    $'double-multiline\t0\t616c7068610a62657461' \
    $'single-multiline\t0\t616c7068610a62657461' >"$c/bytes.tsv"
  tcase bytes-faithful 0 '^OP_DOTENV_BYTES: CLEAN \(checks=6 failed=0\)$' \
    bash "$SELF" --dotenv-bytes --evaluate "$c/bytes.tsv"
  awk -F'\t' 'BEGIN{OFS="\t"} $1=="trailing-lf"{$3="616c706861"} {print}' \
    "$c/bytes.tsv" >"$c/bytes-stripped.tsv"
  tcase bytes-trailing-lost 1 'id=trailing-lf status=FAIL' \
    bash "$SELF" --dotenv-bytes --evaluate "$c/bytes-stripped.tsv"
  awk -F'\t' 'BEGIN{OFS="\t"} $1=="newline-only"{$3=""} {print}' \
    "$c/bytes.tsv" >"$c/bytes-empty.tsv"
  tcase bytes-newline-lost 1 'id=newline-only status=FAIL' \
    bash "$SELF" --dotenv-bytes --evaluate "$c/bytes-empty.tsv"
  awk -F'\t' 'BEGIN{OFS="\t"} $1=="escaped-lf"{$2="1"} {print}' \
    "$c/bytes.tsv" >"$c/bytes-exit.tsv"
  tcase bytes-exit-mismatch 1 'id=escaped-lf status=FAIL' \
    bash "$SELF" --dotenv-bytes --evaluate "$c/bytes-exit.tsv"
  awk -F'\t' '$1!="single-multiline"' "$c/bytes.tsv" >"$c/bytes-missing.tsv"
  tcase bytes-missing 1 '^OP_DOTENV_BYTES: DRIFT \(checks=5 failed=1\)$' \
    bash "$SELF" --dotenv-bytes --evaluate "$c/bytes-missing.tsv"
  { cat "$c/bytes.tsv"; printf 'single-multiline\t0\t616c7068610a62657461\n'; } >"$c/bytes-extra.tsv"
  tcase bytes-extra 2 '^OP_DOTENV_BYTES: SETUP \(extra observation row\)$' \
    bash "$SELF" --dotenv-bytes --evaluate "$c/bytes-extra.tsv"
  tcase bytes-no-fixture 2 'OP_DOTENV_BYTES: POLICY' \
    bash "$SELF" --dotenv-bytes --fixture "$c"
  if [[ $S_FAIL -gt 0 ]]; then
    printf 'OP_REF_SELFTEST: FAIL (%d cases, %d failed)\n' "$S_N" "$S_FAIL"
    return 1
  fi
  printf 'OP_REF_SELFTEST: PASS (%d cases)\n' "$S_N"
  return 0
}

# -------------------------------------------------------------------- main ---
while (($#)); do
  case $1 in
    --selftest) MODE=selftest ;;
    --dotenv-bytes) DOTENV_BYTES=1 ;;
    --evaluate) MODE=evaluate; EVAL_FILE=${2:?--evaluate needs a file}; shift ;;
    --fixture) FIXTURE_DIR=${2:?--fixture needs a dir}; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "OP_REF_PROBE: POLICY (unknown argument: $1)" 2 ;;
  esac
  shift
done

if ((DOTENV_BYTES)); then
  [[ -z $FIXTURE_DIR && $MODE != selftest ]] ||
    die "OP_DOTENV_BYTES: POLICY (byte mode accepts generated fixtures or --evaluate only)" 2
  if [[ $MODE == evaluate ]]; then
    [[ -f $EVAL_FILE ]] || die "OP_DOTENV_BYTES: SETUP (observation file not found)" 2
    evaluate_bytes "$EVAL_FILE"
  else
    dotenv_bytes
  fi
  exit $?
fi

# The guard runs in the main shell for every mode, so a poisoned fixture tree is
# refused before anything executes (including --evaluate, which is how the
# selftest proves the refusal).
[[ -n $FIXTURE_DIR && -d $FIXTURE_DIR ]] && guard_op_side "$FIXTURE_DIR"

case $MODE in
  selftest) selftest; exit $? ;;
  evaluate)
    [[ -f $EVAL_FILE ]] || die "OP_REF_PROBE: SETUP (observation file not found: $EVAL_FILE)" 2
    evaluate "$EVAL_FILE"; exit $? ;;
  verify) verify; exit $? ;;
esac