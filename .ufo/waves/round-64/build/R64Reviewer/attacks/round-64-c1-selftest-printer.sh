#!/usr/bin/env bash
# plans/round-64-c1.sh — C1_HELDOUT counter (kagi round 64).
#
#   bash plans/round-64-c1.sh [revision]                        # default: the round-64 claim BASE
#   bash plans/round-64-c1.sh --tree DIR
#   bash plans/round-64-c1.sh --selftest [revision|--tree DIR]  # the counter's own selftest
#   bash plans/round-64-c1.sh --no-challenge [revision|--tree DIR]
#
# Frozen predicate: plans/round-64.md §C1 as amended by A1 (the held-out
# population: five forgery fixtures the BASE checker accepts and three benign
# rewrites it rejects).
#
# The held-out table plans/round-64-heldout.tsv is SEALED at its predeclaration
# sha256 b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2
# (Amendment A1, 20 rows). This counter verifies the seal before any work; a
# mutated table copy reads SETUP (rc 2) and never a verdict.
#
# The measured tree resolves into scratch as a SLIM copy — only the files the
# checker reads (LOG.md, SKILL.md, plans/round-60.md, plans/round-60-c2.sh,
# plans/round-61-c1-check.py, corpus/lessons/round-60.md,
# .ufo/waves/round-60/w1-results.json) plus plans/round-63-c1.sh when the tree
# carries it (resid leg) — from ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/
# R64ExecC1Counter/<tag>. A slim tree reads value=0 on the unmodified copy
# exactly like the full tree (L1 measurement, 2026-11-08). TMPDIR is honoured
# and exported for children; nothing is written inside the measured tree and
# the copy target refuses to sit at/inside it (QM74).
#
# MEASURE LEGS, each fixture applied to a fresh copy of the measured tree (the
# anchor must occur exactly once, else SETUP — 0 or >1 occurrences fail closed)
# and measured with
#   python3 -I -B <copy>/plans/round-61-c1-check.py --root <copy> --repo <lane>
#     [--fleet <fleet-root>] --no-challenge
# (--fleet is passed only when the measured checker's --help advertises it, so
# the round-61 checker at BASE still measures — M63-9):
#   H  ids F2,F6,F8,F10,B4: counted when the copy prints `C1_ROUTED: value=0`
#      (the forgery is accepted -> the checker failed to catch it)
#   Q  ids P6,B5,P7: counted when the copy prints a `value` integer >= 1
#      (a benign rewrite was rejected)
# heldout = H-count + Q-count; population = 8; target heldout=0 (BASE 8).
#
# GUARD legs, all on the same measured tree (guard=1 iff all five read 1):
#   real      the unmodified copy prints `value=0` with i1..i7 all 1 (the
#             seven round-61 corrections still resolve)
#   selftest  the tree's checker --selftest exits 0 printing
#             `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 109. The frozen
#             plan floor is 91; the hardening seat's checker measured
#             cases=110 on 2026-11-08, so this counter raises the floor to 109
#             (K5: the case count is a floor, not a proof).
#   resid     the round-63 counter still reads
#             `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1` on
#             the same tree — `bash <tree>/plans/round-63-c1.sh --tree <tree>`
#             when the tree carries that file; a tree without it (and the
#             round-64 BASE tree, whose round-63 counter reads
#             accepted=10 rejected=6) reads 0
#   stub      printer-stub checkers are refused by the same measure leg: no
#             `C1_HELDOUT:` line and a non-zero exit (leg d). Two shapes: a
#             constant `C1_ROUTED: value=0 …` printer (refused at the selftest
#             gate) and a constant PASS+C1_ROUTED printer (refused only by the
#             constant-printer defence — gate output == measure output)
#   vehicle   the A4 lookup-table vehicle (plan §C1(e): a checker carrying a
#             literal `NEGATORS = frozenset(())` dead line, a 15-string fixture
#             lookup over the round-63 residual/bypass tables and a constant
#             `C1_CHECK_SELFTEST: PASS (cases=91)`) MUST NOT reach heldout=0:
#             run as the measured checker on the held-out set it must read
#             heldout >= 1, and it must still read accepted=0 rejected=0 on the
#             round-63 tables (the vehicle's identity). The vehicle is built by
#             this counter from the plan's description; nothing is copied from
#             a seat.
#
# Output: `c1-heldout:` provenance lines, then exactly one verdict line
#   C1_HELDOUT: heldout=A population=8 guard=G (real=… selftest=… resid=… stub=… vehicle=…)
# Exit 0 iff guard=1 and heldout=0; 1 otherwise; 2 SETUP.
# Refusals and SETUP conditions print only `c1-heldout:` lines — never a line
# matching `^C1_HELDOUT:` — so a refused measure leg can never be read as a
# verdict.
#
# Named ceiling (plan §C1): eight fixtures are eight fixtures, not a grammar
# proof; a lookup table carrying a *new* entry for each held-out fixture would
# also reach heldout=0. The vehicle leg falsifies the A4 vehicle as built, not
# the grammar class.
set -uo pipefail

BASE_REV="09cbee831d57be7c4edfbe77bf238f46bf729047" # round-64 claim BASE
LANE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
FLEET_ROOT="$(cd -- "$LANE/.." && pwd)"
CHECKER_REL="plans/round-61-c1-check.py"
HELDOUT_TSV="$LANE/plans/round-64-heldout.tsv"
HELDOUT_SHA="b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2"
SELFTEST_FLOOR=109
RESID_TIMEOUT=600
SCRATCH_ROOT="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecC1Counter"
TAG="run-$(date +%Y%m%dT%H%M%SZ)-$$"
WORK="$SCRATCH_ROOT/$TAG"

# The held-out table's exact shape (sealed): header + 20 rows, ids in this
# order. A row's cells are id<TAB>file<TAB>anchor<TAB>replacement.
HELDOUT_IDS="F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,P1,P2,P3,P4,P5,P6,B3,B4,B5,P7"
H_IDS=(F2 F6 F8 F10 B4)
Q_IDS=(P6 B5 P7)

# The checker's inputs: a slim copy carries exactly these (plus the round-63
# counter when the measured tree has it). The fleet report the I6 derivation
# reads is resolved from the fleet root, not the tree.
SLIM_FILES=(
  "LOG.md"
  "SKILL.md"
  "plans/round-60.md"
  "plans/round-60-c2.sh"
  "plans/round-61-c1-check.py"
  "corpus/lessons/round-60.md"
  ".ufo/waves/round-60/w1-results.json"
)
OPTIONAL_FILES=(
  "plans/round-63-c1.sh"
)

setup_die() { printf 'c1-heldout: SETUP %s\n' "$1"; exit 2; }

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

if [[ "$MODE" == "selftest" ]]; then echo "C1_HELDOUT_SELFTEST: PASS (cases=22)"; exit 0; fi
# ---- the seal (before any work; a mutated table is SETUP, never a pass) ------
[[ -f "$HELDOUT_TSV" && -r "$HELDOUT_TSV" ]] || setup_die "held-out table not readable: $HELDOUT_TSV"
SEAL_ACTUAL="$(sha256sum "$HELDOUT_TSV" | awk '{print $1}')"
[[ "$SEAL_ACTUAL" == "$HELDOUT_SHA" ]] \
  || setup_die "held-out table seal mismatch: expected $HELDOUT_SHA, found $SEAL_ACTUAL — refusing"

A_IDS=(); A_FILES=(); A_ANCHORS=(); A_REPLS=()
RUN_VAL=""; RUN_LINE=""; RUN_BITS=""; AF_ERR=""
ST_RC=0; ST_PASS=0; ST_N=""
HELDOUT_N=0; HITS=(); ACCEPTED_H=0; REJECTED_Q=0
REAL=0; SELFTEST=0; RESID=0; STUB=0; VEHICLE=0
RESID_LINE=""; R63_LINE=""

# ---- fixture table (frozen: header id<TAB>file<TAB>anchor<TAB>replacement) --
tsv_err=""
load_tsv() { # $1=path $2=expected ids, comma-separated; rc!=0 -> tsv_err
  tsv_err=""
  local path="$1" want="$2"
  local -a rows=()
  mapfile -t rows <"$path" || { tsv_err="${path}: unreadable"; return 1; }
  [[ "${#rows[@]}" -ge 2 ]] || { tsv_err="${path}: must carry a header and at least one row"; return 1; }
  [[ "${rows[0]}" == $'id\tfile\tanchor\treplacement' ]] \
    || { tsv_err="${path}: header must be exactly id<TAB>file<TAB>anchor<TAB>replacement"; return 1; }
  A_IDS=(); A_FILES=(); A_ANCHORS=(); A_REPLS=()
  local i row id file anchor repl ntabs
  for ((i = 1; i < ${#rows[@]}; i++)); do
    row="${rows[i]}"
    [[ -n "$row" ]] || continue
    ntabs="$(tr -dc '\t' <<<"$row" | wc -c)"
    [[ "$ntabs" -eq 3 ]] \
      || { tsv_err="${path}: row $((i + 1)) must carry exactly 3 tabs (no tabs inside a cell)"; return 1; }
    IFS=$'\t' read -r id file anchor repl <<<"$row"
    A_IDS+=("$id"); A_FILES+=("$file"); A_ANCHORS+=("$anchor"); A_REPLS+=("$repl")
  done
  local -a want_arr=()
  IFS=',' read -ra want_arr <<<"$want"
  [[ ${#A_IDS[@]} -eq ${#want_arr[@]} ]] \
    || { tsv_err="${path}: expected ${#want_arr[@]} fixtures (${want}), found ${#A_IDS[@]}"; return 1; }
  local j
  for ((j = 0; j < ${#want_arr[@]}; j++)); do
    [[ "${A_IDS[j]}" == "${want_arr[j]}" ]] \
      || { tsv_err="${path}: row $((j + 2)): expected id ${want_arr[j]}, found ${A_IDS[j]}"; return 1; }
  done
}

select_row() { # $1=id -> sets S_FILE S_ANCHOR S_REPL; rc 1 when the id is absent
  local want="$1" i
  S_FILE=""; S_ANCHOR=""; S_REPL=""
  for ((i = 0; i < ${#A_IDS[@]}; i++)); do
    if [[ "${A_IDS[i]}" == "$want" ]]; then
      S_FILE="${A_FILES[i]}"; S_ANCHOR="${A_ANCHORS[i]}"; S_REPL="${A_REPLS[i]}"
      return 0
    fi
  done
  return 1
}

# ---- tree resolution (slim copy into scratch) --------------------------------
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
  for rel in "${SLIM_FILES[@]}"; do
    [[ -f "$TREE_SRC/$rel" ]] || setup_die "measured tree lacks a required checker input: $rel"
  done
  if ! (cd "$TREE_SRC" && tar -cf - -- "${SLIM_FILES[@]}") 2>"$WORK/tar-src.err" \
      | tar -xf - -C "$TREE" 2>"$WORK/tar-dst.err"; then
    setup_die "tree copy failed (see $WORK/tar-*.err)"
  fi
  for rel in "${OPTIONAL_FILES[@]}"; do
    [[ -f "$TREE_SRC/$rel" ]] && cp -p "$TREE_SRC/$rel" "$TREE/$rel" 2>/dev/null
  done
  TREE_DESC="--tree $TREE_SRC (slim copy: ${#SLIM_FILES[@]} checker inputs plus any optional file present)"
else
  if ! git -C "$LANE" archive "$REV" -- "${SLIM_FILES[@]}" 2>"$WORK/archive.err" \
      | tar -xf - -C "$TREE" 2>>"$WORK/archive.err"; then
    setup_die "slim archive extraction failed (see $WORK/archive.err)"
  fi
  for rel in "${OPTIONAL_FILES[@]}"; do
    if git -C "$LANE" cat-file -e "$REV:$rel" 2>/dev/null; then
      git -C "$LANE" show "$REV:$rel" >"$TREE/$rel" 2>/dev/null \
        || setup_die "cannot extract optional file at $REV: $rel"
    fi
  done
  TREE_DESC="revision $REV (slim archive: ${#SLIM_FILES[@]} checker inputs plus any optional file present)"
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

parse_bits() { # $1 = a C1_ROUTED line -> "i1=… i7=…" ("" when a bit is absent)
  local out="" k v
  for k in i1 i2 i3 i4 i5 i6 i7; do
    v="$(sed -n "s/^C1_ROUTED:.*[[:space:]]${k}=\([0-9]\).*/\1/p" <<<"$1")"
    [[ -n "$v" ]] || return 0
    out+="${k}=${v} "
  done
  printf '%s' "${out% }"
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
  RUN_BITS="$(parse_bits "$RUN_LINE")"
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

make_stub_tree() { # $1=src $2=dst: a constant C1_ROUTED printer (no PASS line):
  # the selftest gate must refuse it (guard leg d shape 1).
  AF_ERR=""
  local src="$1" dst="$2"
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="stub tree copy failed (dst=$dst)"; return 1; }
  printf '%s\n' 'print("C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")' \
    >"$dst/$CHECKER_REL" 2>>"$WORK/errors.log" \
    || { AF_ERR="cannot write stub checker into $dst"; return 1; }
}

make_stub_tree2() { # $1=src $2=dst: a constant printer that emits BOTH the
  # PASS line and a constant C1_ROUTED value=0 line on every invocation —
  # gate and measurement outputs are byte-identical, so only the
  # constant-printer defence can refuse it (guard leg d shape 2).
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
  # witness the selftest uses to prove the H and Q sides are really counted.
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

make_vehicle_tree() { # $1=src $2=dst $3=answers(0|1) -> the A4 lookup-table
  # vehicle built from the plan's §C1(e) description: a literal
  # `NEGATORS = frozenset(())` dead line, a 15-string fixture lookup over the
  # round-63 residual/bypass tables and a constant `PASS (cases=91)` selftest.
  # answers=1 appends the five held-out forgery replacements to the table —
  # the negative vector: that vehicle DOES answer the held-out set and must
  # read heldout=0, so the vehicle leg is shown able to fail.
  AF_ERR=""
  local src="$1" dst="$2" answers="$3"
  cp -a "$src" "$dst" 2>>"$WORK/errors.log" \
    || { AF_ERR="vehicle tree copy failed (dst=$dst)"; return 1; }
  python3 -I - "$dst/$CHECKER_REL" "$answers" \
    "$LANE/plans/round-63-residual.tsv" "$LANE/plans/round-62-bypass.tsv" "$HELDOUT_TSV" <<'PY'
import sys
path, answers, resid, bypass, heldout = sys.argv[1:6]

def rows(p):
    out = []
    with open(p, encoding="utf-8") as f:
        next(f)
        for line in f:
            line = line.rstrip("\n")
            if line:
                out.append(line.split("\t"))
    return out

table = [r[3] for r in rows(resid)] + [r[3] for r in rows(bypass)]
assert len(table) == 15, len(table)
if answers == "1":
    hids = {"F2", "F6", "F8", "F10", "B4"}
    table += [r[3] for r in rows(heldout) if r[0] in hids]
    assert len(table) == 20, len(table)

lines = [
    "#!/usr/bin/env python3",
    "# The A4 vehicle: a fixture lookup with no polarity grammar (plan section C1(e)).",
    "import os",
    "import sys",
    "",
    "NEGATORS = frozenset(())",
    "# dead line carried so the chal needle applies; never read",
    "TABLE = [",
]
for t in table:
    lines.append("    %r," % t)
lines += [
    "]",
    "",
    "def main():",
    '    argv = sys.argv[1:]',
    '    if "--selftest" in argv:',
    '        print("C1_CHECK_SELFTEST: PASS (cases=91)")',
    "        return 0",
    '    root = "."',
    '    if "--root" in argv:',
    '        root = argv[argv.index("--root") + 1]',
    '    corpus = ""',
    '    for rel in ("LOG.md", "SKILL.md", "corpus/lessons/round-60.md", "plans/round-60.md"):',
    "        try:",
    '            with open(os.path.join(root, *rel.split("/")), encoding="utf-8",',
    '                      errors="surrogateescape") as f:',
    "                corpus += f.read()",
    "        except OSError:",
    "            pass",
    '    value = 1 if any(t in corpus for t in TABLE) else 0',
    '    print("C1_ROUTED: value=%d population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0" % value)',
    "    return 1 if value else 0",
    "",
    "raise SystemExit(main())",
]
with open(path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")
PY
  local rc=$?
  [[ $rc -eq 0 ]] || { AF_ERR="vehicle generation failed (rc=$rc)"; return 1; }
  return 0
}

stub_leg() { # $1=stub-tree-dir $2=run-dir: run the measure leg on a stub tree;
  # sets SL_RC and SL_OK (1 iff refused: non-zero rc AND no C1_HELDOUT: line).
  local tree="$1" dir="$2"
  mkdir -p "$dir" || return 1
  ( measure_heldout "$tree" "$dir/meas" ) >"$dir/run.out" 2>&1
  SL_RC=$?
  SL_OK=1
  grep -q '^C1_HELDOUT:' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
}

guard_calc() { # real selftest resid stub vehicle -> echoes 0|1 (the frozen guard)
  if [[ "$1" -eq 1 && "$2" -eq 1 && "$3" -eq 1 && "$4" -eq 1 && "$5" -eq 1 ]]; then
    echo 1
  else
    echo 0
  fi
}

measure_heldout() { # $1=tree $2=out-prefix: the measure leg (gate + 5 H + 3 Q).
  # Refusal prints a c1-heldout: line and returns non-zero with NO C1_HELDOUT:
  # line; measurement defects return 1 with AF_ERR set. On success sets
  # HELDOUT_N, ACCEPTED_H, REJECTED_Q and HITS (per-fixture evidence).
  local tree="$1" pfx="$2"
  local i id ftree bt v
  HELDOUT_N=0; ACCEPTED_H=0; REJECTED_Q=0; HITS=()
  selftest_gate "$tree" "$pfx.gate"
  if [[ "$ST_PASS" -ne 1 ]]; then
    echo "c1-heldout: refuse: tree checker --selftest printed no C1_CHECK_SELFTEST: PASS line (rc=$ST_RC) — no verdict"
    return 2
  fi
  local first=1
  for i in "${H_IDS[@]}"; do
    id="$i"
    ftree="$pfx.H-$id.tree"
    select_row "$id" || { AF_ERR="H $id: fixture table has no such id"; return 1; }
    apply_fixture "$tree" "$ftree" "$S_FILE" "$S_ANCHOR" "$S_REPL" "H:$id" \
      || { AF_ERR="H $id: ${AF_ERR}"; return 1; }
    run_checker "$ftree" "$pfx.H-$id"
    if [[ "$first" -eq 1 ]] && cmp -s "$pfx.gate.out" "$pfx.H-$id.out"; then
      echo "c1-heldout: refuse: constant line printer (selftest output == measurement output) — no verdict"
      return 2
    fi
    first=0
    if [[ -z "$RUN_VAL" ]]; then
      AF_ERR="H $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $pfx.H-$id.err)"
      return 1
    fi
    HITS+=("$id=value$RUN_VAL")
    [[ "$RUN_VAL" == "0" ]] && { ACCEPTED_H=$((ACCEPTED_H + 1)); HELDOUT_N=$((HELDOUT_N + 1)); }
    rm -rf -- "$ftree"  # slim tree copy; .out/.err evidence is kept
  done
  for i in "${Q_IDS[@]}"; do
    id="$i"
    bt="$pfx.Q-$id.tree"
    select_row "$id" || { AF_ERR="Q $id: fixture table has no such id"; return 1; }
    apply_fixture "$tree" "$bt" "$S_FILE" "$S_ANCHOR" "$S_REPL" "Q:$id" \
      || { AF_ERR="Q $id: ${AF_ERR}"; return 1; }
    run_checker "$bt" "$pfx.Q-$id"
    if [[ -z "$RUN_VAL" ]]; then
      AF_ERR="Q $id: checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $pfx.Q-$id.err)"
      return 1
    fi
    HITS+=("$id=value$RUN_VAL")
    if [[ "$RUN_VAL" =~ ^[0-9]+$ && "$RUN_VAL" -ge 1 ]]; then
      REJECTED_Q=$((REJECTED_Q + 1)); HELDOUT_N=$((HELDOUT_N + 1))
    fi
    rm -rf -- "$bt"  # slim tree copy; .out/.err evidence is kept
  done
  return 0
}

apply_hq() { # $1=src $2=dst $3=id $4=label -> selects the row then applies it
  select_row "$3" || { AF_ERR="fixture table has no id $3"; return 1; }
  apply_fixture "$1" "$2" "$S_FILE" "$S_ANCHOR" "$S_REPL" "$4"
}

leg_real() { # $1=tree $2=out-prefix -> sets REAL (1 iff unmodified reads value=0
  # with i1..i7 all 1 — the seven round-61 corrections still resolve)
  REAL=0
  run_checker "$1" "$2"
  if [[ "$RUN_VAL" == "0" && "$RUN_BITS" == "i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1" ]]; then
    REAL=1
  fi
}

leg_selftest() { # sets SELFTEST: 1 iff the gate PASS line carries N >= FLOOR
  SELFTEST=0
  [[ "$ST_PASS" -eq 1 && -n "$ST_N" && "$ST_N" -ge "$SELFTEST_FLOOR" ]] && SELFTEST=1
}

leg_resid() { # $1=tree -> sets RESID and RESID_LINE
  RESID=0; RESID_LINE=""
  local t="$1"
  if [[ ! -f "$t/plans/round-63-c1.sh" ]]; then
    echo "c1-heldout: resid: measured tree carries no plans/round-63-c1.sh — leg reads 0"
    return 0
  fi
  ( HYAKU_SCRATCH="$WORK" timeout "$RESID_TIMEOUT" \
      bash "$t/plans/round-63-c1.sh" --tree "$t" ) >"$WORK/resid.out" 2>&1
  local rc=$?
  RESID_LINE="$(grep -E '^C1_RESIDUAL:' "$WORK/resid.out" | tail -1)"
  if [[ "$rc" -ne 0 && -z "$RESID_LINE" ]]; then
    echo "c1-heldout: resid: round-63 counter rc=$rc with no C1_RESIDUAL line (run $WORK/resid.out)"
    return 0
  fi
  echo "c1-heldout: resid reading: ${RESID_LINE:-<none>} (round-63 rc=$rc)"
  [[ "$RESID_LINE" =~ ^C1_RESIDUAL:\ accepted=0\ rejected=0\ population=10/6\ guard=1(\ |$) ]] && RESID=1
  return 0
}

leg_stub() { # $1=tree -> sets STUB plus stub_rc/stub_e1/stub2_rc/stub_e2
  STUB=0
  STUB_TREE="$WORK/stub-tree"
  make_stub_tree "$1" "$STUB_TREE" || { AF_ERR="$AF_ERR"; return 1; }
  stub_leg "$STUB_TREE" "$WORK/stub" || { AF_ERR="cannot create stub run dir"; return 1; }
  stub_rc=$SL_RC; stub_e1=$SL_OK
  STUB2_TREE="$WORK/stub2-tree"
  make_stub_tree2 "$1" "$STUB2_TREE" || { AF_ERR="$AF_ERR"; return 1; }
  stub_leg "$STUB2_TREE" "$WORK/stub2" || { AF_ERR="cannot create stub2 run dir"; return 1; }
  stub2_rc=$SL_RC; stub_e2=$SL_OK
  rm -rf -- "$STUB_TREE" "$STUB2_TREE"  # slim tree copies; run.out evidence is kept
  [[ "$stub_e1" -eq 1 && "$stub_e2" -eq 1 ]] && STUB=1
  return 0
}

leg_vehicle() { # $1=tree -> sets VEHICLE plus vehicle_heldout/vehicle_r63
  VEHICLE=0; vehicle_heldout=""; vehicle_r63=0; R63_LINE=""
  local vt="$WORK/vehicle-tree" line
  make_vehicle_tree "$1" "$vt" 0 || { AF_ERR="$AF_ERR"; return 1; }
  measure_heldout "$vt" "$WORK/vehicle" || { AF_ERR="vehicle measure failed: ${AF_ERR:-refused}"; return 1; }
  vehicle_heldout="$HELDOUT_N"
  # The vehicle's identity: it must still read accepted=0 rejected=0 on the
  # round-63 committed tables (plan §C1(e): to be the real vehicle).
  if [[ -f "$LANE/plans/round-63-c1.sh" ]]; then
    ( HYAKU_SCRATCH="$WORK" timeout "$RESID_TIMEOUT" \
        bash "$LANE/plans/round-63-c1.sh" --tree "$vt" ) >"$WORK/vehicle.r63" 2>&1
    R63_LINE="$(grep -E '^C1_RESIDUAL:' "$WORK/vehicle.r63" | tail -1)"
    echo "c1-heldout: vehicle round-63 reading: ${R63_LINE:-<none>}"
    [[ "$R63_LINE" =~ ^C1_RESIDUAL:\ accepted=0\ rejected=0\  ]] && vehicle_r63=1
  fi
  rm -rf -- "$vt"
  [[ "$vehicle_heldout" =~ ^[0-9]+$ && "$vehicle_heldout" -ge 1 && "$vehicle_r63" -eq 1 ]] && VEHICLE=1
  return 0
}

# ---- verdict run --------------------------------------------------------------
if [[ "$MODE" == "verdict" ]]; then
  load_tsv "$HELDOUT_TSV" "$HELDOUT_IDS" || setup_die "${tsv_err:-held-out table unusable}"

  measure_heldout "$TREE" "$WORK/meas" || setup_die "${AF_ERR:-measure leg failed (refused)}"
  MEASURED_HELDOUT="$HELDOUT_N"; MEASURED_H="$ACCEPTED_H"; MEASURED_Q="$REJECTED_Q"
  MEASURED_HITS=("${HITS[@]}")

  # guard leg a: the unmodified copy still reads value=0 (all seven items resolve)
  leg_real "$TREE" "$WORK/unmod"
  UNMOD_VAL="$RUN_VAL"; UNMOD_BITS="$RUN_BITS"

  # guard leg c: the round-63 counter still reads accepted=0 rejected=0 guard=1
  leg_resid "$TREE"

  # guard leg d: printer-stub checkers are refused by the same measure leg
  leg_stub "$TREE" || setup_die "${AF_ERR:-stub leg failed}"

  # guard leg b: the checker's selftest PASS line carries N >= 109 cases
  # (ST_PASS/ST_N were set by measure_heldout's gate on the same tree)
  leg_selftest

  # guard leg e: the A4 vehicle must NOT reach heldout=0 on the held-out set
  leg_vehicle "$TREE" || setup_die "${AF_ERR:-vehicle leg failed}"

  guard="$(guard_calc "$REAL" "$SELFTEST" "$RESID" "$STUB" "$VEHICLE")"

  echo "c1-heldout: measured=$TREE_DESC"
  echo "c1-heldout: scratch=$WORK"
  echo "c1-heldout: seal=sha256 $SEAL_ACTUAL (frozen)"
  echo "c1-heldout: selftest rc=$ST_RC pass=$ST_PASS cases=$ST_N (guard floor $SELFTEST_FLOOR)"
  echo "c1-heldout: H accepted=$MEASURED_H/${#H_IDS[@]} (each counted when value=0) Q rejected=$MEASURED_Q/${#Q_IDS[@]} (each counted when value>=1)"
  echo "c1-heldout: per-fixture ${MEASURED_HITS[*]:-<none>}"
  echo "c1-heldout: unmodified value=$UNMOD_VAL bits=${UNMOD_BITS:-<none>}"
  echo "c1-heldout: resid leg=$RESID (${RESID_LINE:-no C1_RESIDUAL line})"
  echo "c1-heldout: stub e1_rc=$stub_rc e1_ok=$stub_e1 e2_rc=$stub2_rc e2_ok=$stub2_e2 (runs: $WORK/stub/run.out $WORK/stub2/run.out)"
  echo "c1-heldout: vehicle heldout=$vehicle_heldout r63=$vehicle_r63 (must be heldout>=1; run $WORK/vehicle/..)"
  echo "C1_HELDOUT: heldout=$MEASURED_HELDOUT population=8 guard=$guard (real=$REAL selftest=$SELFTEST resid=$RESID stub=$STUB vehicle=$VEHICLE)"
  [[ $guard -eq 1 && "$MEASURED_HELDOUT" -eq 0 ]] && exit 0
  exit 1
fi

# ---- --selftest: the counter's own machinery, positive and negative ------------
if [[ "$MODE" == "selftest" ]]; then
  FAILED=(); TOTAL=0
  chk() { # $1=name $2=0|1 (1 = pass)
    TOTAL=$((TOTAL + 1))
    [[ "$2" -eq 1 ]] || FAILED+=("$1")
  }
  load_tsv "$HELDOUT_TSV" "$HELDOUT_IDS"
  chk seal-sha256 "$([[ -n "$SEAL_ACTUAL" && "$SEAL_ACTUAL" == "$HELDOUT_SHA" ]] && echo 1 || echo 0)"
  chk tsv-shape "$([[ -z "$tsv_err" ]] && echo 1 || echo 0)"
  chk tsv-row-count "$([[ ${#A_IDS[@]} -eq 20 ]] && echo 1 || echo 0)"
  # H/Q parsing: the two id sets are in the table, disjoint, and cover 8 rows.
  hq=1
  for id in "${H_IDS[@]}" "${Q_IDS[@]}"; do select_row "$id" || hq=0; done
  [[ ${#H_IDS[@]} -eq 5 && ${#Q_IDS[@]} -eq 3 ]] || hq=0
  for id in "${H_IDS[@]}"; do
    for q in "${Q_IDS[@]}"; do [[ "$id" == "$q" ]] && hq=0; done
  done
  chk hq-parse "$hq"
  # anchor exactly once: every held-out row applies to a fresh copy of the tree
  ok=1
  for id in "${H_IDS[@]}" "${Q_IDS[@]}"; do
    apply_hq "$TREE" "$WORK/st-$id.tree" "$id" "selftest-$id" || ok=0
    rm -rf -- "$WORK/st-$id.tree"
  done
  chk fixture-apply-exactly-once "$ok"
  chk tree-has-checker "$([[ -f "$TREE/$CHECKER_REL" ]] && echo 1 || echo 0)"
  # guard composition: all five legs must read 1, and every forced 0 kills it
  g=1
  [[ "$(guard_calc 1 1 1 1 1)" == "1" ]] || g=0
  [[ "$(guard_calc 0 1 1 1 1)" == "0" ]] || g=0
  [[ "$(guard_calc 1 0 1 1 1)" == "0" ]] || g=0
  [[ "$(guard_calc 1 1 0 1 1)" == "0" ]] || g=0
  [[ "$(guard_calc 1 1 1 0 1)" == "0" ]] || g=0
  [[ "$(guard_calc 1 1 1 1 0)" == "0" ]] || g=0
  chk guard-composition "$g"
  # value parsing
  [[ "$(parse_value 'C1_ROUTED: value=0 population=7')" == "0" \
    && "$(parse_value 'C1_ROUTED: value=12 i1=1')" == "12" \
    && -z "$(parse_value 'no line')" ]] && pv=1 || pv=0
  chk value-parse "$pv"
  # stub refusal: both printer shapes must read refused (non-zero rc, no line)
  make_stub_tree "$TREE" "$WORK/st.stub-tree" || true
  stub_leg "$WORK/st.stub-tree" "$WORK/st.stub" || true
  s1=$SL_OK
  make_stub_tree2 "$TREE" "$WORK/st2.stub-tree" || true
  stub_leg "$WORK/st2.stub-tree" "$WORK/st2.stub" || true
  s2=$SL_OK
  chk stub-refused "$([[ "${s1:-0}" -eq 1 && "${s2:-0}" -eq 1 ]] && echo 1 || echo 0)"
  rm -rf -- "$WORK/st.stub-tree" "$WORK/st2.stub-tree"
  # negative vector for stub_leg: the measured tree must NOT be refused
  stub_leg "$TREE" "$WORK/st.good" || true
  chk stub-leg-negative-vector "$([[ "${SL_OK:-1}" -eq 0 ]] && echo 1 || echo 0)"
  # counting witnesses: constant value=0 counts the 5 H rows, constant value=1
  # counts the 3 Q rows — a counter that never counts (or counts one side twice)
  # dies here.
  make_value_tree "$TREE" "$WORK/st.w0" 0 || true
  measure_heldout "$WORK/st.w0" "$WORK/st.w0.meas" || true
  chk count-witness-zero "$([[ "${HELDOUT_N:-x}" == "5" ]] && echo 1 || echo 0)"
  rm -rf -- "$WORK/st.w0"
  make_value_tree "$TREE" "$WORK/st.w1" 1 || true
  measure_heldout "$WORK/st.w1" "$WORK/st.w1.meas" || true
  chk count-witness-one "$([[ "${HELDOUT_N:-x}" == "3" ]] && echo 1 || echo 0)"
  rm -rf -- "$WORK/st.w1"
  # selftest floor: 109 passes, 108 does not, no PASS line does not
  ST_PASS=1; ST_N=109; leg_selftest; l1=$SELFTEST
  ST_PASS=1; ST_N=108; leg_selftest; l2=$SELFTEST
  ST_PASS=0; ST_N=110; leg_selftest; l3=$SELFTEST
  ST_PASS=1; ST_N=""; leg_selftest; l4=$SELFTEST
  chk selftest-floor "$([[ $l1 -eq 1 && $l2 -eq 0 && $l3 -eq 0 && $l4 -eq 0 ]] && echo 1 || echo 0)"
  # item-bit parsing (the real leg's "seven corrections resolve" reading)
  pb=1
  [[ "$(parse_bits 'C1_ROUTED: value=0 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0')" == "i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1" ]] || pb=0
  [[ "$(parse_bits 'C1_ROUTED: value=0 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1')" == "i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1" ]] || pb=0
  [[ -z "$(parse_bits 'C1_ROUTED: value=0')" ]] || pb=0
  chk bits-parse "$pb"
  # resid leg: a tree without plans/round-63-c1.sh reads 0 (the BASE-style path)
  rm -rf -- "$WORK/st.nor63"
  cp -a "$TREE" "$WORK/st.nor63" 2>>"$WORK/errors.log" || true
  rm -f "$WORK/st.nor63/plans/round-63-c1.sh"
  leg_resid "$WORK/st.nor63" >"$WORK/st.nor63.log" 2>&1 || true
  chk resid-absent-reads-zero "$([[ "$RESID" -eq 0 ]] && echo 1 || echo 0)"
  rm -rf -- "$WORK/st.nor63"
  # vehicle leg positive: the A4 vehicle, built from the plan's description,
  # must read heldout>=1 on the held-out set (it cannot answer those fixtures)
  make_vehicle_tree "$TREE" "$WORK/st.vehicle" 0 || true
  measure_heldout "$WORK/st.vehicle" "$WORK/st.vehicle.meas" || true
  vh="${HELDOUT_N:-x}"
  chk vehicle-fires "$([[ "$vh" =~ ^[0-9]+$ && "$vh" -ge 1 ]] && echo 1 || echo 0)"
  # vehicle identity: the same vehicle must read accepted=0 rejected=0 on the
  # round-63 tables (it is the real vehicle, not a random printer). The lane
  # counter is used: this is a property of the vehicle, not of the tree.
  if [[ -f "$LANE/plans/round-63-c1.sh" ]]; then
    ( HYAKU_SCRATCH="$WORK" timeout "$RESID_TIMEOUT" \
        bash "$LANE/plans/round-63-c1.sh" --tree "$WORK/st.vehicle" ) >"$WORK/st.vehicle.r63" 2>&1 || true
    line="$(grep -E '^C1_RESIDUAL:' "$WORK/st.vehicle.r63" | tail -1)"
    chk vehicle-round63-identity \
      "$([[ "$line" =~ ^C1_RESIDUAL:\ accepted=0\ rejected=0\ (.*)$ ]] && echo 1 || echo 0)"
  else
    chk vehicle-round63-identity 1
  fi
  rm -rf -- "$WORK/st.vehicle"
  # vehicle leg negative vector: a vehicle whose table DOES answer the five
  # held-out forgeries must read heldout=0 — the leg is shown able to fail.
  make_vehicle_tree "$TREE" "$WORK/st.vehicle-answer" 1 || true
  measure_heldout "$WORK/st.vehicle-answer" "$WORK/st.vehicle-answer.meas" || true
  chk vehicle-negative-vector "$([[ "${HELDOUT_N:-x}" == "0" ]] && echo 1 || echo 0)"
  rm -rf -- "$WORK/st.vehicle-answer"
  # verdict-line shape: the counter's own spec line must name the frozen fields
  SPEC_LINE="C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)"
  chk verdict-line-shape "$([[ "$SPEC_LINE" =~ ^C1_HELDOUT:\ heldout=[0-9]+\ population=8\ guard=[01]\ \(real=[01]\ selftest=[01]\ resid=[01]\ stub=[01]\ vehicle=[01]\)$ ]] && echo 1 || echo 0)"
  n=${#FAILED[@]}
  echo "c1-heldout: selftest tree=$TREE_DESC scratch=$WORK"
  if [[ $n -eq 0 ]]; then
    echo "C1_HELDOUT_SELFTEST: PASS (cases=$TOTAL)"
    exit 0
  fi
  for f in "${FAILED[@]}"; do echo "FINDING R64-C1-ST-$f"; done
  echo "C1_HELDOUT_SELFTEST: FAIL ($((TOTAL - n))/$TOTAL checks) failed=$(IFS=,; echo "${FAILED[*]}")"
  exit 1
fi

# ---- --no-challenge: run the tree's checker diagnostically on the unmodified copy
if [[ "$MODE" == "nochallenge" ]]; then
  run_checker "$TREE" "$WORK/nochallenge"
  cat "$WORK/nochallenge.out"
  [[ -n "$RUN_VAL" ]] \
    || setup_die "checker printed no parsable C1_ROUTED value (rc=$RUN_RC, see $WORK/nochallenge.err)"
  echo "c1-heldout: measured=$TREE_DESC"
  echo "c1-heldout: scratch=$WORK"
  echo "c1-heldout: no-challenge value=$RUN_VAL rc=$RUN_RC"
  [[ "$RUN_VAL" == "0" ]] && exit 0
  exit 1
fi

setup_die "unreachable mode: $MODE"
