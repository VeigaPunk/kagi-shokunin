#!/usr/bin/env bash
# plans/round-43-controls.sh -- BASE readings and discrimination controls for the frozen round-43
# counters (plans/round-43-c1.sh, plans/round-43-c2.sh, plans/round-43-c3.sh). Writes receipts
# under .ufo/waves/round-43/controls/.
#
# Expected at the claim BASE 5f3566c (the round-42 tip), with the round-43 instruments present
# (they are the deliverable; measured at this predeclaration tree, HEAD 5f3566c):
#   C1 old instrument (plans/round-42-c1.sh): real 5; +K1 0; +K3 0; +fakeC 5 (answer-key passes);
#      m3-old+K1 5 (guard-drop survivor); m5-old+K3 5 (token-drop survivor); blankets 0 / 0.
#   C1 new instrument (plans/round-43-c1.sh): real 6; +K1 0; +K3 0; +fakeC 5 (<6, rejected);
#      m3-new+K1 6 (exposure: the K1 control is load-bearing); m5-new+K3 6; blankets 0 / 0.
#   C2: no gate at HEAD -> 0; blanket always-0 -> 0; blanket always-1 -> 0.
#   C3: lane tree 0; one-gate-fixed fixture tree 1; all-greps-fixed-but-selftest-sabotaged tree 4.
# Scratch root: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/controls.<pid> (deleted on exit).
set -u
cd "$(dirname "$0")/.."
OUT=.ufo/waves/round-43/controls
S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/controls.$$
mkdir -p -- "$OUT" "$S" || exit 2
trap 'rm -rf -- "$S"' EXIT
fail() { echo "controls: $1" >&2; exit 2; }

# ---------------------------------------------------------------- fixture gates (keyed) --
# All three keyed gates parse --ledger <path> and answer by the ledger's basename, the same
# fixture layout the two counters write ($ROOT/<case>-ledger.tsv). This is the honest shape of
# the round-42 answer-key class: the gate inspects nothing but the fixture name.
mk_keyed() { # $1 out  $2 p0-answer  $3 default-answer  $4.. case:token pairs
  local out=$1 p0ans=$2 defans=$3
  { printf '#!/usr/bin/env bash\nset -u\nled=""\nprev=""\nfor a in "$@"; do\n  [ "$prev" = "--ledger" ] && led=$a\n  prev=$a\ndone\nb=$(basename -- "$led")\ncase "$b" in\n'
    while [ $# -gt 3 ]; do printf '  %s) printf '"'"'%%s\\n'"'"' "%s"; exit 1 ;;\n' "$4" "$5"; shift 2; done
    printf '  p0-ledger.tsv) printf '"'"'%%s\\n'"'"' "%s"; exit %s ;;\n' "$p0ans" "${p0ans:+1}"
    printf '  *) printf '"'"'%%s\\n'"'"' "%s"; exit 0 ;;\n' "$defans"
    printf 'esac\n'
  } > "$out" || fail "mk_keyed $out"
}
# K1: valid per-forgery tokens for F1..F6; refuses P0 with a valid token (the token-refusing
# blanket gate -- kills the guard-drop counter mutant through the P0 guard).
mk_keyed "$S/K1.sh" \
  "EXPECT_JOURNAL: REFUSE DELETED R11-03" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R17-02" \
  "f6-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R11-03"
# K3: accepts P0; refuses every forgery with one constant WRONG token (kills the token-drop
# counter mutant through the per-token check).
mk_keyed "$S/K3.sh" \
  "unused" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f6-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"
# fix K3's P0 branch: accept (exit 0)
python3 - "$S/K3.sh" <<'PY' || fail "K3 p0 branch"
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
old = '  p0-ledger.tsv) printf \'%s\\n\' "unused"; exit 1 ;;\n'
new = '  p0-ledger.tsv) printf \'%s\\n\' "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0 ;;\n'
assert old in s, "K3 p0 branch pattern missing"
open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
# fakeC: the round-42 answer-key gate -- exact tokens for F1..F5, knows nothing of F6.
mk_keyed "$S/fakeC.sh" \
  "unused" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R17-02"
# fix fakeC's P0 branch: CLEAN exit 0 (it accepts the positive control, as the round-42 fakeC did)
python3 - "$S/fakeC.sh" <<'PY' || fail "fakeC p0 branch"
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
old = '  p0-ledger.tsv) printf \'%s\\n\' "unused"; exit 1 ;;\n'
new = '  p0-ledger.tsv) printf \'%s\\n\' "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0 ;;\n'
assert old in s, "fakeC p0 branch pattern missing"
open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: REFUSED (violations=1)"; exit 1\n' > "$S/refuse-all.sh"
printf '#!/usr/bin/env bash\necho "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0\n' > "$S/accept-all.sh"
printf '#!/usr/bin/env bash\nexit 0\n' > "$S/always0.sh"
printf '#!/usr/bin/env bash\nexit 1\n' > "$S/always1.sh"

# ---------------------------------------------------------------- counter mutants --
# Recipes (frozen, plans/round-43.md): m3 = P0 guard deleted; m5 = per-token check dropped.
# Applied to byte-identical copies of the two counters inside a scratch clone (the counters
# resolve their repository from their own path, so mutants must live in a git work tree).
git clone -q --shared "$(pwd -P)" "$S/mutclone" || fail clone
python3 - "$(pwd -P)" "$S/mutclone" <<'PY' || fail "mutant surgery"
import os, sys
lane, top = sys.argv[1], sys.argv[2]
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

def mutate(src, dst, old, new, name):
    s = open(os.path.join(lane, src), encoding="utf-8").read()
    assert old in s, f"{name}: pattern missing in {src}"
    open(os.path.join(top, dst), "w", encoding="utf-8").write(s.replace(old, new, 1))

mutate("plans/round-42-c1.sh", "plans/mut-m3-old.sh", GUARD_OLD, GUARD_NEW, "m3-old")
mutate("plans/round-42-c1.sh", "plans/mut-m5-old.sh", TOK_OLD, TOK_NEW, "m5-old")
mutate("plans/round-43-c1.sh", "plans/mut-m3-new.sh", GUARD_OLD, GUARD_NEW, "m3-new")
mutate("plans/round-43-c1.sh", "plans/mut-m5-new.sh", TOK_OLD, TOK_NEW, "m5-new")
PY
MUT=$S/mutclone

run() { # $1 receipt  $2... command
  local r=$1; shift
  "$@" > "$OUT/$r" 2>&1
  echo "RECEIPT $r = $(tail -1 "$OUT/$r")"
}

# ---------------------------------------------------------------- C1 matrix --
run c1-old-real        bash plans/round-42-c1.sh
run c1-old-K1          env EXPECT_JOURNAL=$S/K1.sh bash plans/round-42-c1.sh
run c1-old-K3          env EXPECT_JOURNAL=$S/K3.sh bash plans/round-42-c1.sh
run c1-old-fakeC       env EXPECT_JOURNAL=$S/fakeC.sh bash plans/round-42-c1.sh
run c1-old-m3-K1       env EXPECT_JOURNAL=$S/K1.sh bash "$MUT/plans/mut-m3-old.sh"
run c1-old-m5-K3       env EXPECT_JOURNAL=$S/K3.sh bash "$MUT/plans/mut-m5-old.sh"
run c1-blanket-refuse  env EXPECT_JOURNAL=$S/refuse-all.sh bash plans/round-43-c1.sh
run c1-blanket-accept  env EXPECT_JOURNAL=$S/accept-all.sh bash plans/round-43-c1.sh
run c1-new-real        bash plans/round-43-c1.sh
run c1-new-K1          env EXPECT_JOURNAL=$S/K1.sh bash plans/round-43-c1.sh
run c1-new-K3          env EXPECT_JOURNAL=$S/K3.sh bash plans/round-43-c1.sh
run c1-new-fakeC       env EXPECT_JOURNAL=$S/fakeC.sh bash plans/round-43-c1.sh
run c1-new-m3-K1       env EXPECT_JOURNAL=$S/K1.sh bash "$MUT/plans/mut-m3-new.sh"
run c1-new-m5-K3       env EXPECT_JOURNAL=$S/K3.sh bash "$MUT/plans/mut-m5-new.sh"

# ---------------------------------------------------------------- C2 --
run c2-base        bash plans/round-43-c2.sh
run c2-blanket-0   env CONTROLS_REPLAY_GATE=$S/always0.sh bash plans/round-43-c2.sh
run c2-blanket-1   env CONTROLS_REPLAY_GATE=$S/always1.sh bash plans/round-43-c2.sh

# ---------------------------------------------------------------- C3 fixture trees --
mktree() { # $1 dir -- a shared clone: the selftests resolve pinned revisions via git show
  git clone -q --shared "$(pwd -P)" "$1" || fail "clone $1"
  git -C "$1" checkout -q --detach HEAD || fail "checkout $1"
}
mktree "$S/c3pos"
mktree "$S/c3blanket"
python3 - "$S" <<'PY' || fail "c3 fixture edits"
import os, sys
s = sys.argv[1]
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

# positive control: exactly one gate (surface-census) fixed -> the counter must read 1.
apply(os.path.join(s, "c3pos"), FIXES[6:])

# blanket control: every grep leg fixed, but surface-census's selftest PASS token sabotaged,
# so the executed leg must refuse it -> the counter must read 4, never 5.
apply(os.path.join(s, "c3blanket"), FIXES)
p = os.path.join(s, "c3blanket", "corpus/surface-census.sh")
t = open(p, encoding="utf-8").read()
assert "SELFTEST: PASS" in t
open(p, "w", encoding="utf-8").write(t.replace("SELFTEST: PASS", "SELFTEST: OK"))
PY
run c3-base     bash plans/round-43-c3.sh
run c3-pos      env C3_ROOT=$S/c3pos bash plans/round-43-c3.sh
run c3-blanket  env C3_ROOT=$S/c3blanket bash plans/round-43-c3.sh

git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse HEAD > "$OUT/measured-at.txt"
echo "controls: measured at $(cat "$OUT/measured-at.txt")"
