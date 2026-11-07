#!/usr/bin/env bash
# plans/round-58-c1.sh — C1_ROUTED driver (kagi round 58).
#
#   bash plans/round-58-c1.sh [revision]      # default: the claim BASE
#   bash plans/round-58-c1.sh --tree DIR      # measure a work tree copy instead
#
# Resolves the measured tree into scratch (${HYAKU_SCRATCH:-/fast/scratch/hyaku}/
# kagi-r58/R58ExecCounterC1/<tag>/tree): a revision is materialised with
# `git -C <lane> archive` (read-only; no git/jj mutation anywhere), a --tree DIR
# is copied with tar (VCS internals excluded, uncommitted files included).
#
# Legs (the GUARD of plans/round-58.md §C1, computed over the measured tree):
#   leg 1  the sibling checker (python3 -I -B plans/round-58-c1-check.py --root
#          <tree>) prints the C1_ROUTED line with its internal challenge;
#   leg 2  an independent copy of the tree whose ONLY delta is the I4 statement
#          text changed to a wrong count must make the checker print exactly
#          value+1 (the mutation cascade: SCORECARD coverage-row Registry tip
#          count +1, else lesson §Sources Registry tip count +1, else lesson
#          `end ... N rows` +1, else a gates.txt-attributed rows=N +1);
#   leg 3  a printer stub that always prints value=0 population=8 must FAIL that
#          same challenge (it cannot print value+1), proving the harness bites.
# GUARD = 1 iff leg 1 evaluated all eight items (population=8, no `x` token) and
# leg 2 printed exactly value+1 and leg 3 failed. Fail closed: any broken leg
# reads guard=0.
# Output: the C1_ROUTED line (re-printed with the driver-certified guard) plus
# `c1-driver:` evidence lines. Exit 0 iff guard=1 and value=0; 1 otherwise;
# 2 SETUP (bad revision, bad --tree, unwritable scratch, missing checker).
set -uo pipefail

BASE_REV="1b13f5dad921f8901f56d30c428f89614dd74d8a"
LANE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CHECKER="$LANE/plans/round-58-c1-check.py"
SCRATCH_ROOT="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/R58ExecCounterC1"
TAG="run-$(date +%Y%m%dT%H%M%SZ)-$$"
WORK="$SCRATCH_ROOT/$TAG"

setup_die() { printf 'C1_ROUTED: SETUP %s\n' "$1"; exit 2; }

MODE="rev"; REV=""; TREE_SRC=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tree) [[ $# -ge 2 ]] || setup_die "--tree needs a directory"; MODE="dir"; TREE_SRC="$2"; shift 2 ;;
    -h|--help) sed -n '2,27p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --*) setup_die "unknown option: $1" ;;
    *)  [[ -z "$REV" ]] || setup_die "unexpected argument: $1"; REV="$1"; shift ;;
  esac
done
[[ -n "$REV" ]] || REV="$BASE_REV"

[[ -f "$CHECKER" && -r "$CHECKER" ]] || setup_die "checker not readable: $CHECKER"

if [[ "$MODE" == "dir" ]]; then
  [[ -d "$TREE_SRC" ]] || setup_die "--tree is not a directory: $TREE_SRC"
else
  git -C "$LANE" rev-parse --verify --quiet "${REV}^{commit}" >/dev/null 2>&1 \
    || setup_die "bad revision: $REV"
  REV="$(git -C "$LANE" rev-parse "${REV}^{commit}")"
fi

mkdir -p "$WORK" || setup_die "cannot create scratch: $WORK"
TREE="$WORK/tree"
mkdir -p "$TREE" || setup_die "cannot create tree dir"

if [[ "$MODE" == "dir" ]]; then
  # Copy the measured work tree (uncommitted bytes included; VCS internals out).
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

line_field() { # file field
  local ln
  ln="$(grep -E '^C1_ROUTED:' "$1" 2>/dev/null | tail -1)"
  [[ -n "$ln" ]] || { printf ''; return; }
  [[ "$ln" =~ $2 ]] && printf '%s' "${BASH_REMATCH[1]}" || printf ''
}

# ---- leg 1: the checker, with its internal challenge -----------------------
python3 -I -B "$CHECKER" --root "$TREE" >"$WORK/leg1.txt" 2>"$WORK/leg1.err"
rc1=$?
LINE1="$(grep -E '^C1_ROUTED:' "$WORK/leg1.txt" | tail -1)"
[[ -n "$LINE1" ]] || { [[ $rc1 -eq 2 ]] && setup_die "checker SETUP: $(tail -1 "$WORK/leg1.err")" \
  || setup_die "checker printed no C1_ROUTED line (rc=$rc1, see leg1.err)"; }
VAL="$(line_field "$WORK/leg1.txt" 'value=([^[:space:]]+)')"
POP="$(line_field "$WORK/leg1.txt" 'population=([0-9]+)')"
[[ -n "$VAL" && -n "$POP" ]] || setup_die "unparsable checker line: $LINE1"
ALL8=1
for k in 1 2 3 4 5 6 7 8; do
  T="$(line_field "$WORK/leg1.txt" "i${k}=([01x])")"
  [[ "$T" == "0" || "$T" == "1" ]] || ALL8=0
  printf -v "TOK$k" '%s' "$T"
done

# ---- leg 2: independent I4-wrong-count challenge on a copy -----------------
cp -a "$TREE" "$WORK/tree-broken"
python3 - "$WORK/tree-broken" <<'PY' >"$WORK/leg2-break.txt" 2>"$WORK/leg2-break.err"
import re, sys
tree = sys.argv[1]
def rd(p):
    with open(p, encoding="utf-8", errors="surrogateescape") as f: return f.read()
def wr(p, t):
    with open(p, "w", encoding="utf-8", errors="surrogateescape") as f: f.write(t)
def span(text, pat):
    m = re.search(pat, text, re.M)
    if not m: return None
    m2 = re.compile(r"^## ", re.M).search(text, m.end())
    return (m.start(), m.end() + m2.start() if m2 else len(text))
# the wrong count is measured+1 (wrong on any tree), never stated+1
SROW = re.compile(r"(?m)^\|[ \t]*S\d{3,}[ \t]*\|")
WRONG = len(SROW.findall(rd(tree + "/corpus/SOURCES.md"))) + 1
ARROW = re.compile(r"Registry\s+(\d+)\s*→\s*(\d+)")
def bump_arrow(seg, count=1):
    return ARROW.subn(lambda m: f"Registry {m.group(1)} → {WRONG}", seg, count)
POST = r"^## Round 57[ \t]*[—\-][ \t]*post-move\b"
SRC = r"^## Sources\s*$"
# 1: SCORECARD post-move coverage row Registry tip count
t = rd(tree + "/SCORECARD.md")
sp = span(t, POST)
if sp:
    seg = t[sp[0]:sp[1]]
    for ln in seg.splitlines(keepends=True):
        if ln.lstrip().startswith("| coverage"):
            new, n = bump_arrow(ln)
            if n:
                wr(tree + "/SCORECARD.md", t[:sp[0]] + seg.replace(ln, new, 1) + t[sp[1]:])
                print(f"scorecard-coverage-registry-tip->{WRONG}"); sys.exit(0)
# 2..4: lesson §Sources
t = rd(tree + "/corpus/lessons/round-57.md")
sp = span(t, SRC)
if sp:
    seg = t[sp[0]:sp[1]]
    new, n = bump_arrow(seg)
    if n:
        wr(tree + "/corpus/lessons/round-57.md", t[:sp[0]] + new + t[sp[1]:])
        print(f"lesson-sources-registry-tip->{WRONG}"); sys.exit(0)
    m = re.search(r"\bend\b[^.;\n]{0,120}?(\d+)\s+rows", seg)
    if m:
        wr(tree + "/corpus/lessons/round-57.md",
           t[:sp[0]] + seg[:m.start(1)] + str(WRONG) + seg[m.end(1):] + t[sp[1]:])
        print(f"lesson-sources-end-rows->{WRONG}"); sys.exit(0)
    for ln in seg.splitlines(keepends=True):
        if "gates.txt" in ln and re.search(r"rows=(\d+)", ln):
            new = re.sub(r"rows=(\d+)", lambda g: f"rows={int(g.group(1)) + 1}", ln, count=1)
            wr(tree + "/corpus/lessons/round-57.md", t[:sp[0]] + seg.replace(ln, new, 1) + t[sp[1]:])
            print("lesson-sources-gates-attribution->carried+1"); sys.exit(0)
print("NO-I4-STATEMENT"); sys.exit(3)
PY
BREAK_RC=$?
CHALLENGE_OK=0; CHALLENGE_DESC="not evaluated"
if [[ $ALL8 -eq 1 && "$VAL" != "FAIL" && $BREAK_RC -eq 0 ]]; then
  python3 -I -B "$CHECKER" --root "$WORK/tree-broken" --no-challenge \
    >"$WORK/leg2.txt" 2>"$WORK/leg2.err"
  V2="$(line_field "$WORK/leg2.txt" 'value=([^[:space:]]+)')"
  EXPECT=$((VAL + 1))
  if [[ "$V2" == "$EXPECT" ]]; then
    CHALLENGE_OK=1; CHALLENGE_DESC="broken-copy value=$V2 == value+1 ($EXPECT)"
  else
    CHALLENGE_DESC="broken-copy value=${V2:-none} != value+1 ($EXPECT)"
  fi
else
  V2="none"
  [[ $BREAK_RC -ne 0 ]] && CHALLENGE_DESC="I4 mutation unavailable (rc=$BREAK_RC)" \
    || CHALLENGE_DESC="skipped (value=$VAL or population=$POP)"
fi

# ---- leg 3: a printer stub must fail the same challenge --------------------
STUB="$WORK/stub.py"
printf '%s\n' 'print("C1_ROUTED: value=0 population=8 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=0")' >"$STUB"
STUB_FAILS=0; STUB_DESC="not evaluated"
if [[ $ALL8 -eq 1 && "$VAL" != "FAIL" ]]; then
  python3 -I -B "$STUB" --root "$WORK/tree-broken" >"$WORK/leg3.txt" 2>&1
  V3="$(line_field "$WORK/leg3.txt" 'value=([^[:space:]]+)')"
  if [[ "$V3" != "$((VAL + 1))" ]]; then
    STUB_FAILS=1; STUB_DESC="stub read value=${V3:-none}, challenge expects $((VAL + 1)): stub fails"
  else
    STUB_DESC="stub printed the challenged value: harness cannot distinguish it"
  fi
fi

GUARD=0
[[ $ALL8 -eq 1 && $CHALLENGE_OK -eq 1 && $STUB_FAILS -eq 1 ]] && GUARD=1

echo "c1-driver: tree=$TREE_DESC scratch=$WORK"
echo "c1-driver: leg1 rc=$rc1 $LINE1"
echo "c1-driver: challenge $CHALLENGE_DESC"
echo "c1-driver: stub $STUB_DESC"
echo "C1_ROUTED: value=$VAL population=$POP i1=${TOK1} i2=${TOK2} i3=${TOK3} i4=${TOK4} i5=${TOK5} i6=${TOK6} i7=${TOK7} i8=${TOK8} guard=$GUARD"
if [[ $GUARD -eq 1 && "$VAL" == "0" ]]; then exit 0; fi
exit 1
