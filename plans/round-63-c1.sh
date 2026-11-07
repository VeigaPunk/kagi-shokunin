#!/usr/bin/env bash
# plans/round-63-c1.sh — C1_RESIDUAL counter (kagi round 63).
#
#   bash plans/round-63-c1.sh [revision]                        # default: the round-63 claim BASE
#   bash plans/round-63-c1.sh --tree DIR
#   bash plans/round-63-c1.sh --selftest [revision|--tree DIR]  # the counter's own selftest
#   bash plans/round-63-c1.sh --no-challenge [revision|--tree DIR]
#
# Frozen predicate: plans/round-63.md §C1 (the C1 checker's residual polarity
# classes — ten forgery fixtures accepted -> 0 AND six benign fixtures
# rejected -> 0).
#
# The measured tree resolves into scratch
# (${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ExecC1Counter/<tag>;
# TMPDIR is honoured and exported for children; nothing is written inside the
# measured tree and the copy target refuses to sit at/inside it, QM74): a
# revision is materialised with `git -C <lane> archive` (read-only), a --tree
# DIR is tar-copied (VCS internals excluded, uncommitted files included).
#
# Verdict run: before any verdict the tree's plans/round-61-c1-check.py must
# pass its own --selftest (exit 0 plus a `C1_CHECK_SELFTEST: PASS` line) — a
# printer-stub checker prints no PASS line, so the measure leg exits non-zero
# printing no `C1_RESIDUAL:` line. A checker whose --selftest output equals its
# measurement output byte-for-byte is a constant line printer and is refused
# the same way. The hardened checker takes `--fleet <dir>` (the I6 derivation
# reads the fleet report); the flag is passed only when the measured checker's
# --help advertises it, so the round-62 checker at BASE still measures.
#
# Measure legs, each fixture applied to a fresh copy of the tree (the anchor
# must occur exactly once, else SETUP — 0 or >1 occurrences fail closed) and
# measured with `python3 -I -B <copy>/plans/round-61-c1-check.py --root <copy>
# --repo <lane> [--fleet <fleet-root>] --no-challenge`:
#   forgery   plans/round-63-residual.tsv (ids F1..F10): accepted iff the
#             parsed `value=` token is 0
#   benign    plans/round-63-benign.tsv (ids P1..P6): rejected iff the parsed
#             `value=` token is an integer >= 1
#
# GUARD legs, all on the same measured tree (guard=1 iff all six read 1):
#   real      the unmodified copy reads value=0 (the seven round-61
#             corrections still resolve — no false positive)
#   selftest  the checker's PASS line carries N >= 91 cases (leg b)
#   prior     the five round-62 bypass fixtures (plans/round-62-bypass.tsv,
#             ids B3..B7) each still read value>=1 (leg c)
#   para      the three round-62 paraphrase fixtures
#             (plans/round-62-paraphrase.tsv, ids P3..P5) each still read
#             value=0 (leg d)
#   stub      printer-stub checkers are refused by the same measure leg: no
#             `C1_RESIDUAL:` line and a non-zero exit (leg e) — three shapes:
#             the frozen C1-1 constant `C1_ROUTED: value=0 …` line (refused by
#             the selftest gate), a constant PASS self-attestation (refused by
#             the missing value), and a constant PASS+C1_ROUTED printer (only
#             the constant-printer defence can refuse it)
#   chal      the checker challenge (leg f, Amendment A3): a copy of the
#             measured checker with its NEGATORS frozenset emptied must fail
#             its own --selftest with a `C1_CHECK_SELFTEST: FAIL` line; a
#             needle that matches 0 times reads chal=0 (never a silent pass)
#
# Output: `c1-residual:` provenance lines, then exactly one verdict line
#   C1_RESIDUAL: accepted=A rejected=R population=10/6 guard=G (real=… selftest=… prior=… para=… stub=… chal=…)
# Exit 0 iff guard=1 and accepted=0 and rejected=0; 1 otherwise; 2 SETUP.
# Refusals and SETUP conditions print only `c1-residual:` lines — never a line
# matching `^C1_RESIDUAL:` — so a refused measure leg can never be read as a
# verdict.
set -uo pipefail

BASE_REV="0c07aab8df64b673a54a5113aebd7f34b622adbc" # round-63 claim BASE
LANE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
FLEET_ROOT="$(cd -- "$LANE/.." && pwd)"
CHECKER_REL="plans/round-61-c1-check.py"
RESIDUAL_TSV="$LANE/plans/round-63-residual.tsv"
BENIGN_TSV="$LANE/plans/round-63-benign.tsv"
BYPASS_TSV="$LANE/plans/round-62-bypass.tsv"
PARA_TSV="$LANE/plans/round-62-paraphrase.tsv"
SCRATCH_ROOT="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ExecC1Counter"
TAG="run-$(date +%Y%m%dT%H%M%SZ)-$$"
WORK="$SCRATCH_ROOT/$TAG"

setup_die() { printf 'c1-residual: SETUP %s\n' "$1"; exit 2; }

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

[[ -f "$RESIDUAL_TSV" && -r "$RESIDUAL_TSV" ]] || setup_die "forgery fixture table not readable: $RESIDUAL_TSV"
[[ -f "$BENIGN_TSV" && -r "$BENIGN_TSV" ]] || setup_die "benign fixture table not readable: $BENIGN_TSV"
[[ -f "$BYPASS_TSV" && -r "$BYPASS_TSV" ]] || setup_die "bypass fixture table not readable: $BYPASS_TSV"
[[ -f "$PARA_TSV" && -r "$PARA_TSV" ]] || setup_die "paraphrase fixture table not readable: $PARA_TSV"

F_IDS=(); F_FILES=(); F_ANCHORS=(); F_REPLS=()
P_IDS=(); P_FILES=(); P_ANCHORS=(); P_REPLS=()
B_IDS=(); B_FILES=(); B_ANCHORS=(); B_REPLS=()
Q_IDS=(); Q_FILES=(); Q_ANCHORS=(); Q_REPLS=()
RUN_VAL=""; AF_ERR=""
ST_RC=0; ST_PASS=0; ST_N=""
RUN_RC=0; RUN_LINE=""
SL_RC=0; SL_OK=0
ACCEPTED=0; REJECTED=0

# ---- fixture tables (frozen: header id<TAB>file<TAB>anchor<TAB>replacement) --
tsv_err=""
load_tsv() { # $1=path $2=prefix(F|P|B|Q) $3=expected ids, comma-separated; rc!=0 -> tsv_err
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

checker_takes_fleet() { # $1=tree -> rc 0 iff the measured checker's CLI accepts --fleet
  # Probe --help (argparse prints usage and exits 0); a printer stub ignores
  # the flag and prints its constant line, which never names --fleet.
  [[ -f "$1/$CHECKER_REL" ]] || return 1
  timeout 30 python3 -I -B "$1/$CHECKER_REL" --help 2>&1 | grep -q -- '--fleet'
}

run_checker() { # $1=tree $2=out-prefix: the tree's checker, --no-challenge
  local tree="$1" pfx="$2"
  local fleet_args=()
  checker_takes_fleet "$tree" && fleet_args=(--fleet "$FLEET_ROOT")
  python3 -I -B "$tree/$CHECKER_REL" --root "$tree" --repo "$LANE" \
    "${fleet_args[@]}" --no-challenge >"$pfx.out" 2>"$pfx.err"
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

make_stub_tree3() { # $1=src $2=dst: a constant printer that emits BOTH the
  # PASS line and a constant C1_ROUTED value=0 line on every invocation —
  # gate and measurement outputs are byte-identical, so only the
  # constant-printer defence (not the missing-value path) can refuse it.
  AF_ERR=""
  local src="$1" dst="$2"
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="stub tree copy failed (dst=$dst)"; return 1; }
  printf '%s\n' \
    'print("C1_CHECK_SELFTEST: PASS (cases=99)")' \
    'print("C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")' \
    >"$dst/$CHECKER_REL" 2>>"$WORK/errors.log" \
    || { AF_ERR="cannot write stub checker into $dst"; return 1; }
}

make_value_tree() { # $1=src $2=dst $3=value: a checker that passes its
  # selftest gate and prints a constant C1_ROUTED value=N — the counting
  # witness the selftest uses to prove ACCEPTED/REJECTED are really counted.
  AF_ERR=""
  local src="$1" dst="$2" val="$3"
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="value tree copy failed (dst=$dst)"; return 1; }
  printf '%s\n' \
    'import sys' \
    'if "--selftest" in sys.argv:' \
    '    print("C1_CHECK_SELFTEST: PASS (cases=99)")' \
    'else:' \
    "    print(\"C1_ROUTED: value=$val population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0\")" \
    >"$dst/$CHECKER_REL" 2>>"$WORK/errors.log" \
    || { AF_ERR="cannot write value checker into $dst"; return 1; }
}

stub_leg() { # $1=stub-tree-dir $2=run-dir: run the measure leg on a stub tree;
  # sets SL_RC and SL_OK (1 iff refused: non-zero rc AND no C1_RESIDUAL: line).
  local tree="$1" dir="$2"
  mkdir -p "$dir" || return 1
  ( measure_residual "$tree" "$dir/meas" ) >"$dir/run.out" 2>&1
  SL_RC=$?
  SL_OK=1
  grep -q '^C1_RESIDUAL:' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
}

stub_calc() { # $1=stub_e1 $2=stub_e2 $3=stub_e3 -> sets STUB (guard's stub leg);
  # the composition a forced-1 mutant targets.
  stub_e1="$1"; stub_e2="$2"; stub_e3="$3"
  stub=0; [[ $stub_e1 -eq 1 && $stub_e2 -eq 1 && $stub_e3 -eq 1 ]] && stub=1
}

guard_calc() { # real selftest prior para stub chal -> echoes 0|1 (the frozen guard)
  if [[ "$1" -eq 1 && "$2" -eq 1 && "$3" -eq 1 && "$4" -eq 1 && "$5" -eq 1 && "$6" -eq 1 ]]; then
    echo 1
  else
    echo 0
  fi
}

leg_selftest() { # sets SELFTEST: 1 iff the gate PASS line carries N >= 91 cases
  SELFTEST=0
  [[ "$ST_PASS" -eq 1 && -n "$ST_N" && "$ST_N" -ge 91 ]] && SELFTEST=1
}

empty_negators() { # $1=checker-path: replace the NEGATORS frozenset
  # assignment (single- or multi-line, paren-balanced) with an empty set;
  # rc 0 iff exactly one assignment was found and rewritten (needle leg f).
  python3 - "$1" <<'PY'
import sys
p = sys.argv[1]
lines = open(p, encoding="utf-8").read().splitlines(keepends=True)
starts = [i for i, ln in enumerate(lines) if ln.startswith("NEGATORS = frozenset")]
if len(starts) != 1:
    sys.exit(1)
i = starts[0]
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
}

leg_chal() { # $1=tree -> sets CHAL: 1 iff a copy of the measured checker with
  # its negator set emptied fails its own --selftest with a named FAIL line
  # (guard leg f, plan Amendment A3 — a fixture-lookup checker that prints a
  # constant PASS selftest cannot apply the needle and reads chal=0).
  CHAL=0
  local cdir="$WORK/chal-tree"
  mkdir -p "$cdir/plans" || return 1
  cp "$1/$CHECKER_REL" "$cdir/plans/round-61-c1-check.py" 2>/dev/null || return 1
  empty_negators "$cdir/plans/round-61-c1-check.py" || return 0
  ( cd "$cdir" && timeout 900 python3 -I -B "plans/round-61-c1-check.py" --selftest ) >"$WORK/chal.out" 2>&1
  local rc=$?
  if [[ $rc -ne 0 && $rc -ne 2 ]] && grep -q 'C1_CHECK_SELFTEST: FAIL' "$WORK/chal.out"; then
    CHAL=1
  fi
  return 0
}

measure_residual() { # $1=tree $2=out-prefix: the measure leg (gate + 16 fixtures).
  # Refusal (gate) prints a c1-residual: line and exits non-zero with NO
  # C1_RESIDUAL: line; measurement defects return 1 with AF_ERR set. On success
  # sets ACCEPTED and REJECTED (and leaves ST_* from the gate).
  local tree="$1" pfx="$2"
  local i id file anchor repl ftree
  selftest_gate "$tree" "$pfx.gate"
  if [[ "$ST_PASS" -ne 1 ]]; then
    echo "c1-residual: refuse: tree checker --selftest printed no C1_CHECK_SELFTEST: PASS line (rc=$ST_RC) — no verdict"
    return 2
  fi
  ACCEPTED=0; REJECTED=0
  for ((i = 0; i < ${#F_IDS[@]}; i++)); do
    id="${F_IDS[i]}"; file="${F_FILES[i]}"; anchor="${F_ANCHORS[i]}"; repl="${F_REPLS[i]}"
    ftree="$pfx.$id.tree"
    apply_fixture "$tree" "$ftree" "$file" "$anchor" "$repl" "$id" \
      || { AF_ERR="forgery $id: ${AF_ERR}"; return 1; }
    run_checker "$ftree" "$pfx.$id"
    if [[ "$i" -eq 0 ]] && cmp -s "$pfx.gate.out" "$pfx.$id.out"; then
      echo "c1-residual: refuse: constant line printer (selftest output == measurement output) — no verdict"
      return 2
    fi
    if [[ -z "$RUN_VAL" ]]; then
      AF_ERR="forgery $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $pfx.$id.err)"
      return 1
    fi
    [[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED + 1))
    rm -rf -- "$ftree"  # 200MB tree copy; .out/.err evidence is kept
  done
  for ((i = 0; i < ${#P_IDS[@]}; i++)); do
    id="${P_IDS[i]}"; file="${P_FILES[i]}"; anchor="${P_ANCHORS[i]}"; repl="${P_REPLS[i]}"
    bt="${pfx}.benign.$id.tree"; bp="$pfx.benign.$id"
    apply_fixture "$tree" "$bt" "$file" "$anchor" "$repl" "benign-$id" \
      || { AF_ERR="benign $id: ${AF_ERR}"; return 1; }
    run_checker "$bt" "$bp"
    if [[ -z "$RUN_VAL" ]]; then
      AF_ERR="benign $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $bp.err)"
      return 1
    fi
    if [[ "$RUN_VAL" =~ ^[0-9]+$ && "$RUN_VAL" -ge 1 ]]; then
      REJECTED=$((REJECTED + 1))
    fi
    rm -rf -- "$bt"  # 200MB tree copy; .out/.err evidence is kept
  done
  return 0
}

leg_real() { # $1=tree $2=out-prefix -> sets REAL (1 iff unmodified reads value=0)
  REAL=0
  run_checker "$1" "$2"
  [[ "$RUN_VAL" == "0" ]] && REAL=1
}

leg_prior() { # $1=tree $2=out-prefix -> sets PRIOR (1 iff every B3..B7 reads >=1)
  local i id file anchor repl bt
  PRIOR=1
  for ((i = 0; i < ${#B_IDS[@]}; i++)); do
    id="${B_IDS[i]}"; file="${B_FILES[i]}"; anchor="${B_ANCHORS[i]}"; repl="${B_REPLS[i]}"
    bt="$2.prior-$id.tree"
    apply_fixture "$1" "$bt" "$file" "$anchor" "$repl" "$id" \
      || { AF_ERR="prior $id: ${AF_ERR}"; return 1; }
    run_checker "$bt" "$2.prior-$id"
    rm -rf -- "$bt"  # 200MB tree copy; .out/.err evidence is kept
    if [[ -z "$RUN_VAL" ]]; then
      AF_ERR="prior $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC)"
      return 1
    fi
    [[ "$RUN_VAL" =~ ^[0-9]+$ && "$RUN_VAL" -ge 1 ]] || PRIOR=0
  done
  return 0
}

leg_para() { # $1=tree $2=out-prefix -> sets PARA (1 iff every P3..P5 reads 0)
  local i id file anchor repl qt
  PARA=1
  for ((i = 0; i < ${#Q_IDS[@]}; i++)); do
    id="${Q_IDS[i]}"; file="${Q_FILES[i]}"; anchor="${Q_ANCHORS[i]}"; repl="${Q_REPLS[i]}"
    qt="$2.para-$id.tree"
    apply_fixture "$1" "$qt" "$file" "$anchor" "$repl" "$id" \
      || { AF_ERR="paraphrase $id: ${AF_ERR}"; return 1; }
    run_checker "$qt" "$2.para-$id"
    rm -rf -- "$qt"  # 200MB tree copy; .out/.err evidence is kept
    if [[ -z "$RUN_VAL" ]]; then
      AF_ERR="paraphrase $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC)"
      return 1
    fi
    [[ "$RUN_VAL" == "0" ]] || PARA=0
  done
  return 0
}

leg_stub() { # $1=tree -> sets STUB plus stub_rc/stub_e1/stub2_rc/stub_e2/stub3_rc/stub_e3
  STUB_TREE="$WORK/stub-tree"
  make_stub_tree "$1" "$STUB_TREE" || { AF_ERR="$AF_ERR"; return 1; }
  stub_leg "$STUB_TREE" "$WORK/stub" || { AF_ERR="cannot create stub run dir"; return 1; }
  stub_rc=$SL_RC; stub_e1=$SL_OK
  STUB2_TREE="$WORK/stub2-tree"
  make_stub_tree2 "$1" "$STUB2_TREE" || { AF_ERR="$AF_ERR"; return 1; }
  stub_leg "$STUB2_TREE" "$WORK/stub2" || { AF_ERR="cannot create stub2 run dir"; return 1; }
  stub2_rc=$SL_RC; stub_e2=$SL_OK
  STUB3_TREE="$WORK/stub3-tree"
  make_stub_tree3 "$1" "$STUB3_TREE" || { AF_ERR="$AF_ERR"; return 1; }
  stub_leg "$STUB3_TREE" "$WORK/stub3" || { AF_ERR="cannot create stub3 run dir"; return 1; }
  stub3_rc=$SL_RC; stub_e3=$SL_OK
  rm -rf -- "$STUB_TREE" "$STUB2_TREE" "$STUB3_TREE"  # 200MB tree copies; run.out evidence is kept
  stub_calc "$stub_e1" "$stub_e2" "$stub_e3"
  return 0
}

# ---- verdict run --------------------------------------------------------------
if [[ "$MODE" == "verdict" ]]; then
  load_tsv "$RESIDUAL_TSV" F F1,F2,F3,F4,F5,F6,F7,F8,F9,F10 || setup_die "${tsv_err:-forgery fixture table unusable}"
  load_tsv "$BENIGN_TSV" P P1,P2,P3,P4,P5,P6 || setup_die "${tsv_err:-benign fixture table unusable}"
  load_tsv "$BYPASS_TSV" B B3,B4,B5,B6,B7 || setup_die "${tsv_err:-bypass fixture table unusable}"
  load_tsv "$PARA_TSV" Q P3,P4,P5 || setup_die "${tsv_err:-paraphrase fixture table unusable}"

  measure_residual "$TREE" "$WORK/meas" || setup_die "${AF_ERR:-measure leg failed}"

  # guard leg a: the unmodified copy still reads value=0
  leg_real "$TREE" "$WORK/unmod"
  UNMOD_VAL="$RUN_VAL"
  [[ -n "$UNMOD_VAL" ]] \
    || setup_die "unmodified tree: checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $WORK/unmod.err)"

  # guard legs c/d: prior bypass fixtures read >=1, paraphrases read 0
  leg_prior "$TREE" "$WORK/prior" || setup_die "${AF_ERR:-prior leg failed}"
  leg_para "$TREE" "$WORK/para" || setup_die "${AF_ERR:-paraphrase leg failed}"

  # guard leg e: printer-stub checkers are refused by the same measure leg
  leg_stub "$TREE" || setup_die "${AF_ERR:-stub leg failed}"

  # guard leg b: the checker's selftest PASS line carries N >= 91 cases
  # (ST_PASS/ST_N were set by measure_residual's gate on the same tree)
  leg_selftest

  # guard leg f (Amendment A3): the checker challenge — a copy of the measured
  # checker with its negator set emptied must fail its own selftest.
  leg_chal "$TREE"

  guard="$(guard_calc "$REAL" "$SELFTEST" "$PRIOR" "$PARA" "$stub" "$CHAL")"

  echo "c1-residual: measured=$TREE_DESC"
  echo "c1-residual: scratch=$WORK"
  echo "c1-residual: selftest rc=$ST_RC pass=$ST_PASS cases=$ST_N (guard needs >= 91)"
  echo "c1-residual: forgery accepted=$ACCEPTED/${#F_IDS[@]} benign rejected=$REJECTED/${#P_IDS[@]}"
  echo "c1-residual: unmodified value=$UNMOD_VAL"
  echo "c1-residual: prior leg=$PRIOR (B3..B7 must each read value>=1)"
  echo "c1-residual: paraphrase leg=$PARA (P3..P5 must each read value=0)"
  echo "c1-residual: stub e1_rc=$stub_rc e1_ok=$stub_e1 e2_rc=$stub2_rc e2_ok=$stub_e2 e3_rc=$stub3_rc e3_ok=$stub_e3 (runs: $WORK/stub/run.out $WORK/stub2/run.out $WORK/stub3/run.out)"
  echo "c1-residual: checker challenge=$CHAL (emptied negator set; run $WORK/chal.out)"
  echo "C1_RESIDUAL: accepted=$ACCEPTED rejected=$REJECTED population=10/6 guard=$guard (real=$REAL selftest=$SELFTEST prior=$PRIOR para=$PARA stub=$stub chal=$CHAL)"
  [[ $guard -eq 1 && $ACCEPTED -eq 0 && $REJECTED -eq 0 ]] && exit 0
  exit 1
fi

# ---- --selftest: the counter's own machinery, positive and negative ------------
if [[ "$MODE" == "selftest" ]]; then
  FAILED=()
  load_tsv "$RESIDUAL_TSV" F F1,F2,F3,F4,F5,F6,F7,F8,F9,F10 || FAILED+=("forgery-tsv-shape")
  load_tsv "$BENIGN_TSV" P P1,P2,P3,P4,P5,P6 || FAILED+=("benign-tsv-shape")
  load_tsv "$BYPASS_TSV" B B3,B4,B5,B6,B7 || FAILED+=("bypass-tsv-shape")
  load_tsv "$PARA_TSV" Q P3,P4,P5 || FAILED+=("paraphrase-tsv-shape")
  if [[ ${#FAILED[@]} -eq 0 ]]; then
    ok=1
    for ((i = 0; i < ${#F_IDS[@]}; i++)); do
      apply_fixture "$TREE" "$WORK/st-f${i}.tree" "${F_FILES[i]}" "${F_ANCHORS[i]}" "${F_REPLS[i]}" "selftest-${F_IDS[i]}" || ok=0
    done
    for ((i = 0; i < ${#P_IDS[@]}; i++)); do
      apply_fixture "$TREE" "$WORK/st-p${i}.tree" "${P_FILES[i]}" "${P_ANCHORS[i]}" "${P_REPLS[i]}" "selftest-${P_IDS[i]}" || ok=0
    done
    for ((i = 0; i < ${#B_IDS[@]}; i++)); do
      apply_fixture "$TREE" "$WORK/st-b${i}.tree" "${B_FILES[i]}" "${B_ANCHORS[i]}" "${B_REPLS[i]}" "selftest-${B_IDS[i]}" || ok=0
    done
    for ((i = 0; i < ${#Q_IDS[@]}; i++)); do
      apply_fixture "$TREE" "$WORK/st-q${i}.tree" "${Q_FILES[i]}" "${Q_ANCHORS[i]}" "${Q_REPLS[i]}" "selftest-${Q_IDS[i]}" || ok=0
    done
    [[ $ok -eq 1 ]] || FAILED+=("fixture-apply-exactly-once")
    rm -rf -- "$WORK"/st-*.tree  # 200MB fixture copies; apply success is recorded above
  fi
  selftest_gate "$TREE" "$WORK/st.gate"
  [[ "$ST_PASS" -eq 1 ]] || FAILED+=("checker-selftest-pass")
  run_checker "$TREE" "$WORK/st.unmod"
  [[ -n "$RUN_VAL" ]] || FAILED+=("value-parse-unmodified")
  # stub refusal: all three printer-stub shapes must read SL_OK=1 —
  #   s1 constant C1_ROUTED line (refused at the selftest gate)
  #   s2 constant PASS self-attestation (refused at the gate's missing value)
  #   s3 constant PASS+C1_ROUTED printer (only the constant-printer defence
  #      can refuse it — kills a defence-drop mutant)
  make_stub_tree "$TREE" "$WORK/st.stub-tree" || FAILED+=("stub-tree-build")
  stub_leg "$WORK/st.stub-tree" "$WORK/st.stub" || true
  s1=$SL_OK
  make_stub_tree2 "$TREE" "$WORK/st2.stub-tree" || true
  stub_leg "$WORK/st2.stub-tree" "$WORK/st2.stub" || true
  s2=$SL_OK
  make_stub_tree3 "$TREE" "$WORK/st3.stub-tree" || true
  stub_leg "$WORK/st3.stub-tree" "$WORK/st3.stub" || true
  [[ "${s1:-0}" -eq 1 && "${s2:-0}" -eq 1 && "${SL_OK:-0}" -eq 1 ]] || FAILED+=("stub-refused")
  rm -rf -- "$WORK/st.stub-tree" "$WORK/st2.stub-tree" "$WORK/st3.stub-tree"  # 200MB copies; run.out kept
  # negative vector for stub_leg: the unmodified (good) tree must NOT be
  # refused — measure_residual succeeds, rc=0, so SL_OK reads 0. A stub_leg
  # forced to read SL_OK=1 unconditionally fails this case.
  stub_leg "$TREE" "$WORK/st.good" || true
  [[ "${SL_OK:-1}" -eq 0 ]] || FAILED+=("stub-leg-negative-vector")
  # stub composition: a forced-1 composition dies on the failing inputs
  stub_calc 0 1 1; c1=$stub
  stub_calc 1 0 1; c2=$stub
  stub_calc 1 1 0; c3=$stub
  stub_calc 1 1 1; c4=$stub
  stub_calc 0 0 0; c5=$stub
  [[ $c1 -eq 0 && $c2 -eq 0 && $c3 -eq 0 && $c4 -eq 1 && $c5 -eq 0 ]] || FAILED+=("stub-composition")
  # guard composition: every leg must read 1 for guard=1
  [[ "$(guard_calc 1 1 1 1 1 1)" == "1" \
    && "$(guard_calc 1 1 1 1 1 0)" == "0" \
    && "$(guard_calc 0 1 1 1 1 1)" == "0" \
    && "$(guard_calc 1 0 1 1 1 1)" == "0" \
    && "$(guard_calc 1 1 0 1 1 1)" == "0" \
    && "$(guard_calc 1 1 1 0 1 1)" == "0" \
    && "$(guard_calc 1 1 1 1 0 1)" == "0" \
    && "$(guard_calc 1 1 1 1 1 0)" == "0" ]] || FAILED+=("guard-composition")
  # selftest leg: N >= 91 with a PASS line; anything less reads 0
  ST_PASS=1; ST_N=99; leg_selftest; l1=$SELFTEST
  ST_PASS=1; ST_N=75; leg_selftest; l2=$SELFTEST
  ST_PASS=0; ST_N=99; leg_selftest; l3=$SELFTEST
  ST_PASS=1; ST_N=""; leg_selftest; l4=$SELFTEST
  [[ $l1 -eq 1 && $l2 -eq 0 && $l3 -eq 0 && $l4 -eq 0 ]] || FAILED+=("selftest-leg")

  # checker challenge (guard leg f, Amendment A3): the measured tree's checker
  # with its negator set emptied must fail its own selftest with a named FAIL
  # line — a fixture-lookup checker printing a constant PASS selftest cannot
  # apply the needle and reads chal=0.
  leg_chal "$TREE"
  [[ "$CHAL" -eq 1 ]] || FAILED+=("checker-challenge")
  # counting witnesses: a value=0 checker must read accepted=10 rejected=0,
  # a value=1 checker accepted=0 rejected=6 — a counter that never counts
  # (or counts the wrong side) dies here.
  make_value_tree "$TREE" "$WORK/st.w0" 0 || FAILED+=("witness-zero-build")
  if [[ ! -f "$WORK/st.w0/$CHECKER_REL" ]]; then
    FAILED+=("count-witness-zero")
  else
    measure_residual "$WORK/st.w0" "$WORK/st.w0.meas" || FAILED+=("count-witness-zero-run")
    [[ "${ACCEPTED:-x}" == "10" && "${REJECTED:-x}" == "0" ]] || FAILED+=("count-witness-zero")
    leg_real "$WORK/st.w0" "$WORK/st.w0.real"; [[ "$REAL" -eq 1 ]] || FAILED+=("real-leg-zero")
    leg_prior "$WORK/st.w0" "$WORK/st.w0.prior" || FAILED+=("prior-leg-zero-run")
    [[ "$PRIOR" -eq 0 ]] || FAILED+=("prior-leg-zero")
    leg_para "$WORK/st.w0" "$WORK/st.w0.para" || FAILED+=("para-leg-zero-run")
    [[ "$PARA" -eq 1 ]] || FAILED+=("para-leg-zero")
    rm -rf -- "$WORK/st.w0"
  fi
  make_value_tree "$TREE" "$WORK/st.w1" 1 || FAILED+=("witness-one-build")
  if [[ ! -f "$WORK/st.w1/$CHECKER_REL" ]]; then
    FAILED+=("count-witness-one")
  else
    measure_residual "$WORK/st.w1" "$WORK/st.w1.meas" || FAILED+=("count-witness-one-run")
    [[ "${ACCEPTED:-x}" == "0" && "${REJECTED:-x}" == "6" ]] || FAILED+=("count-witness-one")
    leg_real "$WORK/st.w1" "$WORK/st.w1.real"; [[ "$REAL" -eq 0 ]] || FAILED+=("real-leg-one")
    leg_prior "$WORK/st.w1" "$WORK/st.w1.prior" || FAILED+=("prior-leg-one-run")
    [[ "$PRIOR" -eq 1 ]] || FAILED+=("prior-leg-one")
    leg_para "$WORK/st.w1" "$WORK/st.w1.para" || FAILED+=("para-leg-one-run")
    [[ "$PARA" -eq 0 ]] || FAILED+=("para-leg-one")
    rm -rf -- "$WORK/st.w1"
  fi
  n=${#FAILED[@]}
  total=28
  echo "c1-residual: selftest tree=$TREE_DESC scratch=$WORK"
  if [[ $n -eq 0 ]]; then
    echo "C1_RESIDUAL_SELFTEST: PASS ($total/$total checks)"
    exit 0
  fi
  for f in "${FAILED[@]}"; do echo "FINDING R63-C1-ST-$f"; done
  echo "C1_RESIDUAL_SELFTEST: FAIL ($((total - n))/$total checks) failed=$(IFS=,; echo "${FAILED[*]}")"
  exit 1
fi

# ---- --no-challenge: run the tree's checker diagnostically on the unmodified copy
if [[ "$MODE" == "nochallenge" ]]; then
  run_checker "$TREE" "$WORK/nochallenge"
  cat "$WORK/nochallenge.out"
  [[ -n "$RUN_VAL" ]] \
    || setup_die "checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $WORK/nochallenge.err)"
  echo "c1-residual: measured=$TREE_DESC"
  echo "c1-residual: scratch=$WORK"
  echo "c1-residual: no-challenge value=$RUN_VAL rc=$RUN_RC"
  [[ "$RUN_VAL" == "0" ]] && exit 0
  exit 1
fi

setup_die "unreachable mode: $MODE"
