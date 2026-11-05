#!/usr/bin/env bash
# K43MutCounters C3 mutation battery. Sandbox-only.
set -u
S=/fast/scratch/hyaku/kagi-r43/K43MutCounters
WORK=$S/work
export HYAKU_SCRATCH=$S/scr
cd "$WORK" || exit 2
[ "$(git rev-parse --show-toplevel)" = "$WORK" ] || { echo "FATAL: toplevel mismatch" >&2; exit 2; }

# ---- fixture trees per plans/round-43-controls.sh recipe (FIXES verbatim) ----
mktree() { git clone -q --shared "$WORK" "$1" && git -C "$1" checkout -q --detach HEAD; }
rm -rf "$S/trees"
mkdir -p "$S/trees"
mktree "$S/trees/pos"     || exit 2
mktree "$S/trees/blanket" || exit 2
python3 - "$S/trees" <<'PY' || exit 2
import os, sys
t = sys.argv[1]
FIXES = [
    ("corpus/anchor-pins.sh",
     '"${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}/kagi-r40-anchorpins-selftest.XXXXXX"',
     '"${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43-anchorpins-selftest.XXXXXX"'),
    ("corpus/claims-declared.sh",
     '"${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}/kagi-r40-claimsdecl-selftest.XXXXXX"',
     '"${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43-claimsdecl-selftest.XXXXXX"'),
    ("corpus/prefreeze-control.sh",
     '"${TMPDIR:-/tmp}/prefreeze-selftest.XXXXXX"',
     '"${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43-prefreeze-selftest.XXXXXX"'),
    ("corpus/prefreeze-control.sh",
     'WORK_ROOT=${WORK:-${TMPDIR:-/tmp}}',
     'WORK_ROOT=${WORK:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}}'),
    ("corpus/self-description-sweep.sh",
     '# fixture tree under ${TMPDIR:-/tmp} and removes it on exit.',
     '# fixture tree under ${HYAKU_SCRATCH:-/fast/scratch/hyaku} and removes it on exit.'),
    ("corpus/self-description-sweep.sh",
     '"${TMPDIR:-/tmp}/sd-sweep-selftest.XXXXXX"',
     '"${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43-sdsweep-selftest.XXXXXX"'),
    ("corpus/surface-census.sh",
     '"${TMPDIR:-/tmp}/surface-census.XXXXXX"',
     '"${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43-surfacecensus.XXXXXX"'),
]
def apply(tree, fixes):
    for rel, old, new in fixes:
        p = os.path.join(tree, rel)
        s = open(p, encoding="utf-8").read()
        assert old in s, f"pattern missing in {rel}: {old[:50]}"
        open(p, "w", encoding="utf-8").write(s.replace(old, new))
apply(os.path.join(t, "pos"), FIXES[6:])
apply(os.path.join(t, "blanket"), FIXES)
p = os.path.join(t, "blanket", "corpus/surface-census.sh")
s = open(p, encoding="utf-8").read()
assert "SELFTEST: PASS" in s
open(p, "w", encoding="utf-8").write(s.replace("SELFTEST: PASS", "SELFTEST: OK"))
# residual /tmp census in the all-greps-fixed blanket tree
for root, _, files in os.walk(os.path.join(t, "blanket", "corpus")):
    for f in sorted(files):
        if f.endswith(".sh"):
            full = os.path.join(root, f)
            n = open(full, encoding="utf-8").read().count("/tmp")
            if n:
                print(f"blanket-tree residual /tmp: corpus/{f} x{n}")
print("c3 trees ok")
PY

# ---- mutants ----
python3 - "$WORK" <<'PY' || exit 2
import os, sys
top = sys.argv[1]
src = open(os.path.join(top, "plans/round-43-c3.sh"), encoding="utf-8").read()
LEG3 = '''  local out rc last
  out=$(HYAKU_SCRATCH="$SCR/probe" bash "$ROOT/$1" --selftest 2>&1)
  rc=$?
  [ "$rc" = "0" ] || return 1
  last=$(printf '%s\\n' "$out" | tail -1)
  [ "$last" = "$2: PASS ($3 cases)" ] || return 1
'''
L1 = '''  if grep -qF 'TMPDIR:-/tmp' "$ROOT/$1"; then return 1; fi
'''
assert LEG3 in src, "leg-3 block not found"
open(os.path.join(top, "plans", "mut-z1-noleg3.sh"), "w", encoding="utf-8").write(src.replace(LEG3, "", 1))
assert L1 in src, "leg-1 grep not found"
open(os.path.join(top, "plans", "mut-z2-tmp.sh"), "w", encoding="utf-8").write(src.replace(L1, '''  if grep -qF '/tmp' "$ROOT/$1"; then return 1; fi
''', 1))
print("c3 surgery ok")
PY

# ---- matrix ----
row() { # $1 variant  $2 tree-dir  $3 label
  local out rc
  out=$(env C3_ROOT="$2" bash "plans/$1" 2> "$S/scr/err-$1-$3.txt"); rc=$?
  printf '%-20s %-8s out=[%s] rc=%d\n' "$1" "$3" "$out" "$rc"
}
echo "=== C3 matrix (variant x tree -> N) ==="
for v in round-43-c3.sh mut-z1-noleg3.sh mut-z2-tmp.sh; do
  row "$v" "$WORK"            lane-dd6ccb9
  row "$v" "$S/trees/pos"     pos
  row "$v" "$S/trees/blanket" blanket
done
echo "=== C3 matrix done ==="
