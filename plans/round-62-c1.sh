#!/usr/bin/env bash
# plans/round-62-c1.sh — C1_BYPASS counter (kagi round 62).
#
#   bash plans/round-62-c1.sh [revision]                        # default: the round-62 claim BASE
#   bash plans/round-62-c1.sh --tree DIR
#   bash plans/round-62-c1.sh --selftest [revision|--tree DIR]  # the counter's own selftest
#   bash plans/round-62-c1.sh --no-challenge [revision|--tree DIR]
#
# Frozen predicate: plans/round-62.md §C1 (the C1 checker's negation /
# swapped-pairing bypass class, accepted 5 -> 0).
#
# The measured tree resolves into scratch
# (${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ExecC1Counter/<tag>;
# TMPDIR is honoured and exported for children; nothing is written inside the
# measured tree and the copy target refuses to sit at/inside it, QM74): a
# revision is materialised with `git -C <lane> archive` (read-only), a --tree
# DIR is tar-copied (VCS internals excluded, uncommitted files included).
#
# Verdict run: before any verdict the tree's plans/round-61-c1-check.py must
# pass its own --selftest (exit 0 plus a `C1_CHECK_SELFTEST: PASS` line) — a
# printer-stub checker (the round-61 reviewer's C1-1 constant
# `C1_ROUTED: value=0 …` line) prints no PASS line, so the measure leg exits
# non-zero printing no `C1_BYPASS:` line. A checker whose --selftest output
# equals its measurement output byte-for-byte is a constant line printer and
# is refused the same way. Then each of the five committed bypass fixtures
# (plans/round-62-bypass.tsv, ids B3..B7, one per round-61 checker item
# I3..I7) is applied to a fresh copy of the tree (the anchor must occur
# exactly once, else SETUP — 0 or >1 occurrences fail closed) and measured
# with `python3 -I -B <copy>/plans/round-61-c1-check.py --root <copy>
# --repo <lane> --no-challenge`; a fixture is accepted iff the parsed
# `value=` token is 0.
#
# GUARD legs, all on the same measured tree:
#   real        the unmodified copy reads value=0 (the seven round-61
#               corrections still resolve — no false positive)
#   selftest    the checker's PASS line carries N >= 57 cases (leg b)
#   stub        printer-stub trees are refused by the same measure leg: no
#               `C1_BYPASS:` line and a non-zero exit (leg c) — c1 the frozen
#               C1-1 shape (one constant `C1_ROUTED: value=0 …` line, refused
#               by the selftest gate) and c2 a constant printer that
#               self-attests a passing selftest (cleared by the gate, then
#               refused by the constant-printer defence / missing value token)
#   paraphrase  the three paraphrase fixtures (plans/round-62-paraphrase.tsv,
#               ids P3..P5) each read value=0 — benign rewording is not a
#               defect (leg d)
#
# Output: `c1-counter:` provenance lines, then exactly one verdict line
#   C1_BYPASS: accepted=A population=5 guard=G (real=… selftest=… stub=… paraphrase=…)
# Exit 0 iff guard=1 and accepted=0; 1 otherwise; 2 SETUP. Refusals and SETUP
# conditions print only `c1-counter:` lines — never a line matching
# `^C1_BYPASS:` — so a refused measure leg can never be read as a verdict.
set -uo pipefail

BASE_REV="60b5b7b60b76629633110a5b4adac883193c8b2a" # round-62 claim BASE
LANE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CHECKER_REL="plans/round-61-c1-check.py"
BYPASS_TSV="$LANE/plans/round-62-bypass.tsv"
PARA_TSV="$LANE/plans/round-62-paraphrase.tsv"
SCRATCH_ROOT="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ExecC1Counter"
TAG="run-$(date +%Y%m%dT%H%M%SZ)-$$"
WORK="$SCRATCH_ROOT/$TAG"

setup_die() { printf 'c1-counter: SETUP %s\n' "$1"; exit 2; }

MODE="verdict"; TREE_MODE="rev"; REV=""; TREE_SRC=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tree) [[ $# -ge 2 ]] || setup_die "--tree needs a directory"; TREE_MODE="dir"; TREE_SRC="$2"; shift 2 ;;
    --selftest) [[ "$MODE" == "verdict" ]] || setup_die "--selftest and --no-challenge are exclusive"; MODE="selftest"; shift ;;
    --no-challenge) [[ "$MODE" == "verdict" ]] || setup_die "--selftest and --no-challenge are exclusive"; MODE="nochallenge"; shift ;;
    -h|--help) awk 'NR==1{next} /^#( |$)/{sub(/^# ?/,""); print; next} {exit}' "${BASH_SOURCE[0]}"; exit 0 ;;
    --*) setup_die "unknown option: $1" ;;
    *)  [[ -z "$REV" ]] || setup_die "unexpected argument: $1"; REV="$1"; shift ;;
  esac
done
[[ -n "$REV" ]] || REV="$BASE_REV"

[[ -f "$BYPASS_TSV" && -r "$BYPASS_TSV" ]] || setup_die "bypass fixture table not readable: $BYPASS_TSV"
[[ -f "$PARA_TSV" && -r "$PARA_TSV" ]] || setup_die "paraphrase fixture table not readable: $PARA_TSV"

B_IDS=(); B_FILES=(); B_ANCHORS=(); B_REPLS=()
P_IDS=(); P_FILES=(); P_ANCHORS=(); P_REPLS=()
RUN_VAL=""; AF_ERR=""
ST_RC=0; ST_PASS=0; ST_N=""
RUN_RC=0; RUN_LINE=""
SL_RC=0; SL_OK=0

# ---- fixture tables (frozen: header id<TAB>file<TAB>anchor<TAB>replacement) --
tsv_err=""
load_tsv() { # $1=path $2=prefix(B|P) $3=expected ids, comma-separated; rc!=0 -> tsv_err
  tsv_err=""
  local path="$1" pfx="$2" want="$3"
  local -a rows=()
  mapfile -t rows <"$path" || { tsv_err="${path}: unreadable"; return 1; }
  [[ "${#rows[@]}" -ge 2 ]] || { tsv_err="${path}: must carry a header and at least one row"; return 1; }
  [[ "${rows[0]}" == $'id\tfile\tanchor\treplacement' ]] \
    || { tsv_err="${path}: header must be exactly id<TAB>file<TAB>anchor<TAB>replacement"; return 1; }
  local -n _ids="${pfx}_IDS" _files="${pfx}_FILES" _anchors="${pfx}_ANCHORS" _repls="${pfx}_REPLS"
  _ids=(); _files=(); _anchors=(); _repls=()
  local i row id file anchor repl ntabs
  for ((i = 1; i < ${#rows[@]}; i++)); do
    row="${rows[i]}"
    [[ -n "$row" ]] || continue
    ntabs="$(tr -dc '\t' <<<"$row" | wc -c)"
    [[ "$ntabs" -eq 3 ]] \
      || { tsv_err="${path}: row $((i + 1)) must carry exactly 3 tabs (no tabs inside a cell)"; return 1; }
    IFS=$'\t' read -r id file anchor repl <<<"$row"
    _ids+=("$id"); _files+=("$file"); _anchors+=("$anchor"); _repls+=("$repl")
  done
  local -a want_arr=()
  IFS=',' read -ra want_arr <<<"$want"
  [[ ${#_ids[@]} -eq ${#want_arr[@]} ]] \
    || { tsv_err="${path}: expected ${#want_arr[@]} fixtures (${want}), found ${#_ids[@]}"; return 1; }
  local j
  for ((j = 0; j < ${#want_arr[@]}; j++)); do
    [[ "${_ids[j]}" == "${want_arr[j]}" ]] \
      || { tsv_err="${path}: row $((j + 2)): expected id ${want_arr[j]}, found ${_ids[j]}"; return 1; }
  done
}

# ---- tree resolution ---------------------------------------------------------
if [[ "$TREE_MODE" == "dir" ]]; then
  [[ -d "$TREE_SRC" ]] || setup_die "--tree is not a directory: $TREE_SRC"
else
  git -C "$LANE" rev-parse --verify --quiet "${REV}^{commit}" >/dev/null 2>&1 \
    || setup_die "bad revision: $REV"
  REV="$(git -C "$LANE" rev-parse "${REV}^{commit}")"
fi

mkdir -p "$WORK" || setup_die "cannot create scratch: $WORK"
mkdir -p "$WORK/tmp" || setup_die "cannot create tmp dir: $WORK/tmp"
export TMPDIR="$WORK/tmp"
TREE="$WORK/tree"
mkdir -p "$TREE" || setup_die "cannot create tree dir"

if [[ "$TREE_MODE" == "dir" ]]; then
  # The copy target must never sit at/inside the measured tree (round-58 M58-3).
  TREE_R=$(cd "$TREE_SRC" && pwd -P) || setup_die "measured tree unreadable: $TREE_SRC"
  case "$WORK/" in
    "$TREE_R"/*|"$TREE_R"/) setup_die "scratch resolves inside the measured tree (refused, QM74)" ;;
  esac
  if ! (cd "$TREE_SRC" && tar -cf - --exclude=./.git --exclude=./.jj .) 2>"$WORK/tar-src.err" \
      | tar -xf - -C "$TREE" 2>"$WORK/tar-dst.err"; then
    setup_die "tree copy failed (see $WORK/tar-*.err)"
  fi
  TREE_DESC="--tree $TREE_SRC (copied $(find "$TREE" -type f | wc -l) files)"
else
  if ! git -C "$LANE" archive "$REV" | tar -xf - -C "$TREE" 2>"$WORK/archive.err"; then
    setup_die "archive extraction failed (see $WORK/archive.err)"
  fi
  TREE_DESC="revision $REV (git archive)"
fi

# The checker's challenge/mutation scratch shares this run's scratch; the
# checker still refuses any parent that resolves at/inside the measured root.
C1_CHALLENGE_PARENT="$WORK/challenge"
mkdir -p "$C1_CHALLENGE_PARENT" || setup_die "cannot create challenge scratch: $C1_CHALLENGE_PARENT"
export C1_CHALLENGE_PARENT

# ---- helpers -----------------------------------------------------------------
parse_value() { # $1 = a C1_ROUTED line -> the value token on stdout ("" if absent)
  sed -n 's/^C1_ROUTED:.*[[:space:]]value=\([0-9A-Za-z]*\).*/\1/p' <<<"$1"
}

run_checker() { # $1=tree $2=out-prefix: the tree's checker, --no-challenge
  local tree="$1" pfx="$2"
  python3 -I -B "$tree/$CHECKER_REL" --root "$tree" --repo "$LANE" --no-challenge \
    >"$pfx.out" 2>"$pfx.err"
  RUN_RC=$?
  RUN_LINE="$(grep -E '^C1_ROUTED:' "$pfx.out" | tail -1)"
  RUN_VAL=""
  [[ -n "$RUN_LINE" ]] && RUN_VAL="$(parse_value "$RUN_LINE")"
  return 0
}

selftest_gate() { # $1=tree $2=out-prefix: sets ST_RC, ST_PASS, ST_N
  local tree="$1" pfx="$2" line
  [[ -f "$tree/$CHECKER_REL" && -r "$tree/$CHECKER_REL" ]] \
    || setup_die "measured tree has no readable $CHECKER_REL: $tree"
  python3 -I -B "$tree/$CHECKER_REL" --selftest >"$pfx.out" 2>"$pfx.err"
  ST_RC=$?
  ST_PASS=0; ST_N=""
  line="$(grep -E '^C1_CHECK_SELFTEST: PASS \((cases=)?[0-9]+( cases)?\)[[:space:]]*$' "$pfx.out" | tail -1)"
  if [[ -n "$line" && "$ST_RC" -eq 0 ]]; then
    # the count is the parenthesised number: `PASS (52 cases)` or `PASS (cases=57)`
    ST_N="$(sed -n 's/^C1_CHECK_SELFTEST: PASS (\(cases=\)\{0,1\}\([0-9]\{1,\}\)\( cases\)\{0,1\}).*/\2/p' <<<"$line")"
    [[ -n "$ST_N" ]] && ST_PASS=1
  fi
}

apply_fixture() { # $1=src $2=dst $3=relfile $4=anchor $5=repl $6=label; rc!=0 -> AF_ERR
  AF_ERR=""
  local src="$1" dst="$2" rel="$3" anchor="$4" repl="$5" label="$6" rc=0
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="fixture $label: tree copy failed (dst=$dst)"; return 1; }
  if [[ ! -f "$dst/$rel" ]]; then
    AF_ERR="fixture $label: file missing in the measured tree: $rel"
    return 1
  fi
  python3 -I - "$dst/$rel" "$anchor" "$repl" <<'PY'
import sys
path, anchor, repl = sys.argv[1:4]
with open(path, encoding="utf-8") as f:
    text = f.read()
n = text.count(anchor)
if n != 1:
    sys.exit(3)
with open(path, "w", encoding="utf-8") as f:
    f.write(text.replace(anchor, repl, 1))
PY
  rc=$?
  if [[ $rc -ne 0 ]]; then
    AF_ERR="fixture $label: anchor must occur exactly once in $rel (0 or >1 occurrences fails closed)"
    return 1
  fi
}

make_stub_tree() { # $1=src $2=dst: tree with the checker replaced by the
  # round-61 reviewer's C1-1 printer stub (one constant C1_ROUTED line).
  AF_ERR=""
  local src="$1" dst="$2"
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="stub tree copy failed (dst=$dst)"; return 1; }
  printf '%s\n' 'print("C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")' \
    >"$dst/$CHECKER_REL" 2>>"$WORK/errors.log" \
    || { AF_ERR="cannot write stub checker into $dst"; return 1; }
}

make_stub_tree2() { # $1=src $2=dst: a constant printer that instead self-attests
  # a passing selftest — it must clear the gate and then die on the
  # constant-printer defence (never reach a verdict).
  AF_ERR=""
  local src="$1" dst="$2"
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="stub tree copy failed (dst=$dst)"; return 1; }
  printf '%s\n' 'print("C1_CHECK_SELFTEST: PASS (cases=99)")' \
    >"$dst/$CHECKER_REL" 2>>"$WORK/errors.log" \
    || { AF_ERR="cannot write stub checker into $dst"; return 1; }
}

make_reject_stub_tree() { # $1=src $2=dst: a checker that passes its selftest
  # gate and rejects every fixture (value=1) — exercises the measure leg's
  # rejected-tail return path (a trailing `&&` would return 1 here).
  AF_ERR=""
  local src="$1" dst="$2"
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="reject stub tree copy failed (dst=$dst)"; return 1; }
  printf '%s\n' \
    'import sys' \
    'if "--selftest" in sys.argv:' \
    '    print("C1_CHECK_SELFTEST: PASS (cases=99)")' \
    'else:' \
    '    print("C1_ROUTED: value=1 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0")' \
    >"$dst/$CHECKER_REL" 2>>"$WORK/errors.log" \
    || { AF_ERR="cannot write reject stub checker into $dst"; return 1; }
}

stub_leg() { # $1=stub-tree-dir $2=run-dir: run the measure leg on a stub tree;
  # sets SL_RC and SL_OK (1 iff refused: non-zero rc AND no C1_BYPASS: line).
  local tree="$1" dir="$2"
  mkdir -p "$dir" || return 1
  ( measure_battery "$tree" "$dir/meas" ) >"$dir/run.out" 2>&1
  SL_RC=$?
  SL_OK=1
  grep -q '^C1_BYPASS:' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
}

stub_calc() { # $1=stub_c1 $2=stub_c2 -> sets STUB (the guard's stub leg);
  # the composition the round-63 C2 claim's CM2a mutant targets.
  stub_c1="$1"; stub_c2="$2"
  stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1
}

measure_battery() { # $1=tree $2=out-prefix: the measure leg (gate + 5 fixtures).
  # Refusal (gate) prints a c1-counter: line and exits non-zero with NO
  # C1_BYPASS: line; measurement defects return 1 with AF_ERR set. On success
  # sets ACCEPTED (and leaves ST_* from the gate).
  local tree="$1" pfx="$2"
  local i id file anchor repl ftree
  selftest_gate "$tree" "$pfx.gate"
  if [[ "$ST_PASS" -ne 1 ]]; then
    echo "c1-counter: refuse: tree checker --selftest printed no C1_CHECK_SELFTEST: PASS line (rc=$ST_RC) — no verdict"
    exit 2
  fi
  ACCEPTED=0
  for ((i = 0; i < ${#B_IDS[@]}; i++)); do
    id="${B_IDS[i]}"; file="${B_FILES[i]}"; anchor="${B_ANCHORS[i]}"; repl="${B_REPLS[i]}"
    ftree="$pfx.$id.tree"
    apply_fixture "$tree" "$ftree" "$file" "$anchor" "$repl" "$id" \
      || { AF_ERR="fixture $id: ${AF_ERR}"; return 1; }
    run_checker "$ftree" "$pfx.$id"
    if [[ "$i" -eq 0 ]] && cmp -s "$pfx.gate.out" "$pfx.$id.out"; then
      echo "c1-counter: refuse: constant line printer (selftest output == measurement output) — no verdict"
      exit 2
    fi
    if [[ -z "$RUN_VAL" ]]; then
      AF_ERR="fixture $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $pfx.$id.err)"
      return 1
    fi
    [[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED + 1))
  done
  return 0
}

# ---- verdict run --------------------------------------------------------------
if [[ "$MODE" == "verdict" ]]; then
  load_tsv "$BYPASS_TSV" B B3,B4,B5,B6,B7 || setup_die "${tsv_err:-bypass fixture table unusable}"
  load_tsv "$PARA_TSV" P P3,P4,P5 || setup_die "${tsv_err:-paraphrase fixture table unusable}"

  measure_battery "$TREE" "$WORK/meas" || setup_die "${AF_ERR:-measure leg failed}"

  # guard leg a: the unmodified copy still reads value=0
  run_checker "$TREE" "$WORK/unmod"
  [[ -n "$RUN_VAL" ]] \
    || setup_die "unmodified tree: checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $WORK/unmod.err)"
  real=0; [[ "$RUN_VAL" == "0" ]] && real=1

  # guard leg c: printer-stub trees are refused by the same measure leg —
  #   c1 the frozen C1-1 shape (one constant `C1_ROUTED: value=0 …` line)
  #   c2 a constant printer that self-attests a passing selftest
  STUB_TREE="$WORK/stub-tree"
  make_stub_tree "$TREE" "$STUB_TREE" || setup_die "$AF_ERR"
  stub_leg "$STUB_TREE" "$WORK/stub" || setup_die "cannot create stub run dir"
  stub_rc=$SL_RC; stub_c1=$SL_OK
  STUB2_TREE="$WORK/stub2-tree"
  make_stub_tree2 "$TREE" "$STUB2_TREE" || setup_die "$AF_ERR"
  stub_leg "$STUB2_TREE" "$WORK/stub2" || setup_die "cannot create stub2 run dir"
  stub2_rc=$SL_RC; stub_c2=$SL_OK
  stub_calc "$stub_c1" "$stub_c2"

  # guard leg d: benign paraphrases still read value=0
  para=1
  for ((i = 0; i < ${#P_IDS[@]}; i++)); do
    id="${P_IDS[i]}"; file="${P_FILES[i]}"; anchor="${P_ANCHORS[i]}"; repl="${P_REPLS[i]}"
    ptree="$WORK/para-$id.tree"
    apply_fixture "$TREE" "$ptree" "$file" "$anchor" "$repl" "$id" \
      || setup_die "paraphrase $id: ${AF_ERR}"
    run_checker "$ptree" "$WORK/para-$id"
    [[ -n "$RUN_VAL" ]] \
      || setup_die "paraphrase $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC)"
    [[ "$RUN_VAL" == "0" ]] || para=0
  done

  # guard leg b: the checker's selftest PASS line carries N >= 57 cases
  selftest=0
  [[ "$ST_PASS" -eq 1 && -n "$ST_N" && "$ST_N" -ge 57 ]] && selftest=1

  # guard leg e (Amendment A3): the checker challenge — a copy of the measured
  # checker with its negator set emptied must fail its own selftest with a
  # named FAIL line. A stub that prints a constant verdict and a PASS line
  # cannot apply the needle and reads chal=0.
  chal=0
  NEG_OLD='NEGATORS = frozenset(("not", "no", "never", "neither", "nor", "without", "none"))'
  NEG_NEW='NEGATORS = frozenset(())'
  if apply_fixture "$TREE" "$WORK/chal-tree" "$CHECKER_REL" "$NEG_OLD" "$NEG_NEW" "chal"; then
    ( cd "$WORK/chal-tree" && timeout 900 python3 -I -B "$CHECKER_REL" --selftest ) >"$WORK/chal.out" 2>&1
    chrc=$?
    if [[ $chrc -ne 0 && $chrc -ne 2 ]] && grep -q 'C1_CHECK_SELFTEST: FAIL' "$WORK/chal.out"; then chal=1; fi
  fi

  guard=0
  [[ $real -eq 1 && $selftest -eq 1 && $stub -eq 1 && $para -eq 1 && $chal -eq 1 ]] && guard=1

  echo "c1-counter: measured=$TREE_DESC"
  echo "c1-counter: scratch=$WORK"
  echo "c1-counter: selftest rc=$ST_RC pass=$ST_PASS cases=$ST_N (guard needs >= 57)"
  echo "c1-counter: unmodified value=$RUN_VAL"
  echo "c1-counter: stub c1_rc=$stub_rc c1_ok=$stub_c1 c2_rc=$stub2_rc c2_ok=$stub_c2 (runs: $WORK/stub/run.out $WORK/stub2/run.out)"
  echo "c1-counter: paraphrase leg=$para"
  echo "c1-counter: checker challenge=$chal (emptied negator set; run $WORK/chal.out)"
  echo "C1_BYPASS: accepted=$ACCEPTED population=5 guard=$guard (real=$real selftest=$selftest stub=$stub paraphrase=$para chal=$chal)"
  [[ $guard -eq 1 && $ACCEPTED -eq 0 ]] && exit 0
  exit 1
fi

# ---- --selftest: the counter's own machinery, positive and negative ------------
if [[ "$MODE" == "selftest" ]]; then
  FAILED=()
  load_tsv "$BYPASS_TSV" B B3,B4,B5,B6,B7 || FAILED+=("bypass-tsv-shape")
  load_tsv "$PARA_TSV" P P3,P4,P5 || FAILED+=("paraphrase-tsv-shape")
  if [[ ${#FAILED[@]} -eq 0 ]]; then
    ok=1
    for ((i = 0; i < ${#B_IDS[@]}; i++)); do
      apply_fixture "$TREE" "$WORK/st-b${i}.tree" "${B_FILES[i]}" "${B_ANCHORS[i]}" "${B_REPLS[i]}" "selftest-${B_IDS[i]}" || ok=0
    done
    for ((i = 0; i < ${#P_IDS[@]}; i++)); do
      apply_fixture "$TREE" "$WORK/st-p${i}.tree" "${P_FILES[i]}" "${P_ANCHORS[i]}" "${P_REPLS[i]}" "selftest-${P_IDS[i]}" || ok=0
    done
    [[ $ok -eq 1 ]] || FAILED+=("fixture-apply-exactly-once")
  fi
  selftest_gate "$TREE" "$WORK/st.gate"
  [[ "$ST_PASS" -eq 1 ]] || FAILED+=("checker-selftest-pass")
  run_checker "$TREE" "$WORK/st.unmod"
  [[ -n "$RUN_VAL" ]] || FAILED+=("value-parse-unmodified")
  make_stub_tree "$TREE" "$WORK/st.stub-tree" || FAILED+=("stub-tree-build")
  stub_leg "$WORK/st.stub-tree" "$WORK/st.stub" || true
  s1=$SL_OK
  make_stub_tree2 "$TREE" "$WORK/st2.stub-tree" || true
  stub_leg "$WORK/st2.stub-tree" "$WORK/st2.stub" || true
  [[ "${s1:-0}" -eq 1 && "${SL_OK:-0}" -eq 1 ]] || FAILED+=("stub-refused")
  # check 7: the measure leg returns success when the LAST fixture is rejected
  # (a trailing `&&` in the loop would return 1 — the rejected-tail path).
  make_reject_stub_tree "$TREE" "$WORK/st3.reject-tree" || FAILED+=("reject-stub-build")
  mkdir -p "$WORK/st3.reject" || setup_die "cannot create reject-leg dir"
  ( measure_battery "$WORK/st3.reject-tree" "$WORK/st3.reject" ) >"$WORK/st3.reject/run.out" 2>&1
  rej_rc=$?
  [[ $rej_rc -eq 0 ]] || FAILED+=("measure-leg-rejected-tail")
  # check 8 (Amendment A3): the checker challenge fires — an emptied negator set
  # must make the SHIPPED checker's own selftest fail with a named FAIL line.
  # (The measured tree at BASE carries the unhardened checker, so this check
  # uses the counter's own tree, whose checker is the one the round ships.)
  # The negator set's CONTENTS change across rounds (round-63 widens it);
  # empty whatever single `NEGATORS = frozenset(...)` assignment the shipped
  # checker carries — the needle is the assignment's shape, not its members.
  mkdir -p "$WORK/st8.chal-tree/plans" || FAILED+=("checker-challenge-dir")
  cp "$LANE/$CHECKER_REL" "$WORK/st8.chal-tree/plans/round-61-c1-check.py" \
    || FAILED+=("checker-challenge-copy")
  if python3 - "$WORK/st8.chal-tree/plans/round-61-c1-check.py" <<'PY'
import sys
p = sys.argv[1]
lines = open(p, encoding="utf-8").read().splitlines(keepends=True)
starts = [i for i, ln in enumerate(lines) if ln.startswith("NEGATORS = frozenset")]
if len(starts) != 1:
    sys.exit(1)
i = starts[0]
# consume lines until the frozenset(...) call's parens balance
depth = 0
j = i
while True:
    depth += lines[j].count("(") - lines[j].count(")")
    if depth <= 0:
        break
    j += 1
    if j >= len(lines):
        sys.exit(1)
lines[i:j + 1] = ["NEGATORS = frozenset(())\n"]
open(p, "w", encoding="utf-8").write("".join(lines))
PY
  then
    ( cd "$WORK/st8.chal-tree" && timeout 900 python3 -I -B "plans/round-61-c1-check.py" --selftest ) >"$WORK/st8.chal.out" 2>&1
    ch8=$?
    [[ $ch8 -ne 0 && $ch8 -ne 2 ]] && grep -q 'C1_CHECK_SELFTEST: FAIL' "$WORK/st8.chal.out" \
      || FAILED+=("checker-challenge")
  else
    FAILED+=("checker-challenge-needle")
  fi
  # check 9 (round-63 CM2a): the stub composition must read 0 when either
  # stub leg fails — a composition forced to 1 unconditionally dies here.
  stub_calc 0 1; c9a=$stub
  stub_calc 1 0; c9b=$stub
  stub_calc 1 1; c9c=$stub
  [[ $c9a -eq 0 && $c9b -eq 0 && $c9c -eq 1 ]] || FAILED+=("stub-composition")
  # check 10 (round-63 CM2b): stub_leg on the UNMODIFIED (good) tree must read
  # SL_OK=0 — the measure leg succeeds there, so a stub_leg forced to
  # SL_OK=1 unconditionally dies here.
  stub_leg "$TREE" "$WORK/st.good" || true
  [[ "${SL_OK:-1}" -eq 0 ]] || FAILED+=("stub-leg-negative-vector")
  n=${#FAILED[@]}
  TOTAL=15
  echo "c1-counter: selftest tree=$TREE_DESC scratch=$WORK"
  if [[ $n -eq 0 ]]; then
    echo "C1_COUNTER_SELFTEST: PASS ($TOTAL/$TOTAL checks)"
    exit 0
  fi
  for f in "${FAILED[@]}"; do echo "FINDING R62-C1-ST-$f"; done
  echo "C1_COUNTER_SELFTEST: FAIL ($((TOTAL - n))/$TOTAL checks) failed=$(IFS=,; echo "${FAILED[*]}")"
  exit 1
fi

# ---- --no-challenge: run the tree's checker diagnostically on the unmodified copy
if [[ "$MODE" == "nochallenge" ]]; then
  run_checker "$TREE" "$WORK/nochallenge"
  cat "$WORK/nochallenge.out"
  [[ -n "$RUN_VAL" ]] \
    || setup_die "checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $WORK/nochallenge.err)"
  echo "c1-counter: measured=$TREE_DESC"
  echo "c1-counter: scratch=$WORK"
  echo "c1-counter: no-challenge value=$RUN_VAL rc=$RUN_RC"
  [[ "$RUN_VAL" == "0" ]] && exit 0
  exit 1
fi

setup_die "unreachable mode: $MODE"
