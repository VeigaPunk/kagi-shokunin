#!/usr/bin/env bash
# K43MutCounters C1 mutation battery. Sandbox-only: fixture gates + counter mutants + matrix.
set -u
S=/fast/scratch/hyaku/kagi-r43/K43MutCounters
WORK=$S/work
FIX=$S/fix
mkdir -p -- "$FIX"
cd "$WORK" || exit 2
[ "$(git rev-parse --show-toplevel)" = "$WORK" ] || { echo "FATAL: toplevel mismatch" >&2; exit 2; }

# ---- fixture gates (mk_keyed replica, verbatim logic from plans/round-43-controls.sh) ----
mk_keyed() { # $1 out  $2 p0-answer  $3 default-answer  $4.. case:token pairs
  local out=$1 p0ans=$2 defans=$3
  { printf '#!/usr/bin/env bash\nset -u\nled=""\nprev=""\nfor a in "$@"; do\n  [ "$prev" = "--ledger" ] && led=$a\n  prev=$a\ndone\nb=$(basename -- "$led")\ncase "$b" in\n'
    while [ $# -gt 3 ]; do printf '  %s) printf '"'"'%%s\\n'"'"' "%s"; exit 1 ;;\n' "$4" "$5"; shift 2; done
    printf '  p0-ledger.tsv) printf '"'"'%%s\\n'"'"' "%s"; exit %s ;;\n' "$p0ans" "${p0ans:+1}"
    printf '  *) printf '"'"'%%s\\n'"'"' "%s"; exit 0 ;;\n' "$defans"
    printf 'esac\n'
  } > "$out" || exit 2
}
mk_keyed "$FIX/K1.sh" \
  "EXPECT_JOURNAL: REFUSE DELETED R11-03" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R17-02" \
  "f6-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R11-03"
mk_keyed "$FIX/K3.sh" \
  "unused" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f6-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"
mk_keyed "$FIX/fakeC.sh" \
  "unused" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R17-02"
python3 - "$FIX/K3.sh" <<'PY' || exit 2
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
old = '  p0-ledger.tsv) printf \'%s\\n\' "unused"; exit 1 ;;\n'
new = '  p0-ledger.tsv) printf \'%s\\n\' "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0 ;;\n'
assert old in s
open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
python3 - "$FIX/fakeC.sh" <<'PY' || exit 2
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
old = '  p0-ledger.tsv) printf \'%s\\n\' "unused"; exit 1 ;;\n'
new = '  p0-ledger.tsv) printf \'%s\\n\' "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0 ;;\n'
assert old in s
open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: REFUSED (violations=1)"; exit 1\n' > "$FIX/refuse-all.sh"
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0\n' > "$FIX/accept-all.sh"

# ---- mutant surgery into $WORK/plans (git work tree, so counters' git show resolves) ----
python3 - "$WORK" <<'PY' || exit 2
import os, sys
top = sys.argv[1]
src = open(os.path.join(top, "plans/round-43-c1.sh"), encoding="utf-8").read()

GUARD_OLD = (
    'rc=$(run_gate "$ROOT/p0-ledger.tsv" "$ROOT/p0-journals")\n'
    'if [ "$rc" != "0" ]; then\n'
    '  echo 0\n'
    '  exit 0\n'
    'fi\n'
)
GUARD_NEW = 'rc=$(run_gate "$ROOT/p0-ledger.tsv" "$ROOT/p0-journals")\n'
TOK_OLD = '  if [ "$rc" = "1" ] && grep -qxF "EXPECT_JOURNAL: REFUSE $4" "$ROOT/out-$1.txt"; then\n'
TOK_NEW = '  if [ "$rc" = "1" ]; then\n'
ECHO_OLD = 'echo "$n"\nexit 0'
ECHO_NEW = 'echo 6\nexit 0'
INC_OLD = '    n=$((n + 1))\n'

def write(name, text):
    open(os.path.join(top, "plans", name), "w", encoding="utf-8").write(text)

assert GUARD_OLD in src
write("mut-m3-new.sh", src.replace(GUARD_OLD, GUARD_NEW, 1))
assert TOK_OLD in src
write("mut-m5-new.sh", src.replace(TOK_OLD, TOK_NEW, 1))
assert src.count(ECHO_OLD) == 1
write("mut-x1-echo6.sh", src.replace(ECHO_OLD, ECHO_NEW, 1))
assert src.count(INC_OLD) == 1
write("mut-x2-noinc.sh", src.replace(INC_OLD, "", 1))
print("surgery ok")
PY

# ---- matrix ----
export HYAKU_SCRATCH=$S/scr
row() { # $1 variant  $2 label  $3 gate
  local v r
  r=$(env EXPECT_JOURNAL="$3" bash "plans/$1" 2>/dev/null); rc2=$?
  printf '%-16s %-9s %s\n' "$1" "$2" "$r"
}
echo "=== C1 matrix (variant x gate -> N) ==="
for v in round-43-c1.sh mut-m3-new.sh mut-m5-new.sh mut-x1-echo6.sh mut-x2-noinc.sh; do
  row "$v" real      "$WORK/corpus/expect-journal.sh"
  row "$v" K1        "$FIX/K1.sh"
  row "$v" K3        "$FIX/K3.sh"
  row "$v" fakeC     "$FIX/fakeC.sh"
  row "$v" refuseall "$FIX/refuse-all.sh"
  row "$v" acceptall "$FIX/accept-all.sh"
done
