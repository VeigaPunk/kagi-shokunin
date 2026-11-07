#!/usr/bin/env bash
# plans/round-57-controls.sh -- pre-freeze controls for the round-57 counters.
# Every control builds a tree in scratch from the claim BASE (or from the optional
# REF tree that carries the planned landing), runs the frozen counter on it and
# compares the reading with the expectation written below BEFORE the run.
#   usage: bash plans/round-57-controls.sh [REFTREE]
# Output: one `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH :: <detail>` line
#   per control and a last line `CONTROLS: match=M mismatch=K`; exit 0 iff K=0.
# REF-dependent controls print `PENDING <id>` when no REF tree is given; they are
#   not counted. The pre-freeze receipt is the no-REF run.
set -u -o pipefail
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=1cda9e7ae4767b4133e283bfbc08266d4c86362d
REF=${1:-}
[ -n "$REF" ] && REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r57/controls.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
C1="$REPO/plans/round-57-c1.sh"
C2="$REPO/plans/round-57-c2.sh"
mk_base() { mkdir -p "$SCR/$1" && git -C "$REPO" archive "$BASE" | tar -x -C "$SCR/$1" || { echo "mk_base $1 failed" >&2; exit 2; }; }
mk_ref() { mkdir -p "$SCR/$1" || exit 2
  (cd "$REF" && git ls-files -co --exclude-standard -z | python3 -I -B -c 'import os,sys
d=sys.stdin.buffer.read().split(b"\0")
sys.stdout.buffer.write(b"\0".join(p for p in d if p and (os.path.isfile(p) or os.path.islink(p))))' | tar --null -T - -cf -) | tar -x -C "$SCR/$1" || { echo "mk_ref $1 failed" >&2; exit 2; }; }
py() { python3 -I -B -c "$1" "${@:2}"; }
sub() { py 'import sys
p=sys.argv[1]+"/"+sys.argv[2]; s=open(p,encoding="utf-8").read(); n=int(sys.argv[5]) if len(sys.argv)>5 else -1
t=s.replace(sys.argv[3],sys.argv[4],n)
assert t!=s, "inert edit "+sys.argv[2]
open(p,"w",encoding="utf-8").write(t)' "$@"; }
pick1() { sed -n 's/^C1_CURRENT: value=\([^ ]*\).*/\1/p' | head -1; }
pick2() { sed -n 's/^C2_AUDIT_TRIAL: value=\([^ ]*\).*/\1/p' | head -1; }
M=0; K=0
report() { local got; got=$(printf '%s\n' "$3" | "$4" | head -1)
  if [ "$got" = "$2" ]; then M=$((M+1)); r=MATCH; else K=$((K+1)); r=MISMATCH; fi
  echo "CONTROL $1 expect=$2 got=${got:-none} $r :: $(printf '%s\n' "$3" | head -1)"; }
check1() { report "$1" "$2" "$(bash "$C1" --tree "$SCR/$3" 2>&1)" pick1; }
check2() { report "$1" "$2" "$(bash "$C2" --tree "$SCR/$3" 2>&1)" pick2; }
for f in plans/round-57.md plans/round-57-c1.sh plans/round-57-c2.sh plans/round-57-controls.sh plans/round-57-c1-check.py; do
  [ -f "$REPO/$f" ] && echo "INSTRUMENT $(sha256sum "$REPO/$f" | cut -d' ' -f1) $f"
done

# ---------------- C1 ----------------
mk_base base;   check1 K1-BASE 3 base
echo "EXPECT K1-BASE 3 :: three stale self-descriptions at the claim BASE (18-vs-20 cases, four-vs-six epochs, Three-vs-Six epochs)"
mk_base f1; sub "$SCR/f1" SCORECARD.md '`--selftest` 18 cases' '`--selftest` 20 cases'
check1 K1-F1 2 f1
mk_base f2; sub "$SCR/f2" LOG.md 'four freeze epochs land' 'six freeze epochs land'
check1 K1-F2 2 f2
mk_base f3; sub "$SCR/f3" corpus/lessons/round-56.md 'Three freeze epochs' 'Six freeze epochs'
check1 K1-F3 2 f3
mk_base f4; sub "$SCR/f4" SCORECARD.md '`--selftest` 18 cases' '`--selftest` 20 cases'
sub "$SCR/f4" LOG.md 'four freeze epochs land' 'six freeze epochs land'
sub "$SCR/f4" corpus/lessons/round-56.md 'Three freeze epochs' 'Six freeze epochs'
check1 K1-F4 0 f4
mk_base f5; py 'import re,sys
r=sys.argv[1]
def cut(rel):
    p=r+"/"+rel; s=open(p,encoding="utf-8").read()
    m=re.search(r"^## Round 56 [^\n]*\n", s, re.M)
    assert m, rel
    n=re.compile(r"^## ", re.M).search(s, m.end())
    s=s[:m.start()]+(s[n.start():] if n else "")
    open(p,"w",encoding="utf-8").write(s)
cut("SCORECARD.md"); cut("LOG.md")
p=r+"/corpus/lessons/round-56.md"; s=open(p,encoding="utf-8").read()
s=s.replace(s[s.find("## Claims"):], "")
open(p,"w",encoding="utf-8").write(s)' "$SCR/f5"
check1 K1-F5 FAIL f5
mk_base f6; sub "$SCR/f6" .ufo/waves/round-56/controls/controls-prefreeze-epochF.txt 'CONTROLS: match=23 mismatch=0' 'CONTROLS: match=19 mismatch=0'
check1 K1-F6 6 f6
mk_base f7; py 'import re,sys
p=sys.argv[1]+"/plans/round-56.md"; s=open(p,encoding="utf-8").read()
t=s.replace("epoch-A", "epoch-Z", 1)
assert t!=s; open(p,"w",encoding="utf-8").write(t)' "$SCR/f7"
check1 K1-F7 3 f7
if [ -n "$REF" ]; then mk_ref ref1; check1 K1-REF 0 ref1; else echo "PENDING K1-REF (no REF tree)"; fi

# ---------------- C2 ----------------
mk_base c2base; check2 K2-BASE 0 c2base
mk_base stub; cat > "$SCR/stub/corpus/openbao-audit-trial.sh" <<'EOS'
#!/usr/bin/env bash
echo "TEST T1: HOLDS"
echo "AUDIT_TRIAL: CLEAN (tests=5 pass=5)"
EOS
check2 K2-STUB 0 stub
mk_base mock; cat > "$SCR/mock/corpus/openbao-audit-trial.sh" <<'EOS'
#!/usr/bin/env bash
if [ -n "${KAGI_AUDIT_SHIM:-}" ]; then
  echo "TEST ${KAGI_AUDIT_SHIM: -1}: BROKEN"
  echo "AUDIT_TRIAL: FAIL (tests=5 pass=4)"; exit 1
fi
for n in 1 2 3 4 5; do echo "TEST T$n: HOLDS"; done
echo "AUDIT_TRIAL: CLEAN (tests=5 pass=5)"
EOS
chmod +x "$SCR/mock/corpus/openbao-audit-trial.sh"
check2 K2-MOCK 5 mock
if [ -n "$REF" ]; then mk_ref ref2; check2 K2-REF 5 ref2; else echo "PENDING K2-REF (no REF tree)"; fi

echo "CONTROLS: match=$M mismatch=$K"
[ "$K" -eq 0 ]
