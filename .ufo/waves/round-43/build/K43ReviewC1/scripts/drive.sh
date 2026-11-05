#!/usr/bin/env bash
# K43ReviewC1 attack driver -- items 1 and 3. Scratch only; never touches the lane.
set -u
S=/fast/scratch/hyaku/kagi-r43/K43ReviewC1
W=$S/work
R=$S/receipts
mkdir -p -- "$R"

# ---------- keyed fixture gates: byte-replica of plans/round-43-controls.sh mk_keyed ----------
mk_keyed() { # $1 out  $2 p0-answer  $3 default-answer  $4.. case:token pairs
  local out=$1 p0ans=$2 defans=$3
  { printf '#!/usr/bin/env bash\nset -u\nled=""\nprev=""\nfor a in "$@"; do\n  [ "$prev" = "--ledger" ] && led=$a\n  prev=$a\ndone\nb=$(basename -- "$led")\ncase "$b" in\n'
    while [ $# -gt 3 ]; do printf '  %s) printf '"'"'%%s\\n'"'"' "%s"; exit 1 ;;\n' "$4" "$5"; shift 2; done
    printf '  p0-ledger.tsv) printf '"'"'%%s\\n'"'"' "%s"; exit %s ;;\n' "$p0ans" "${p0ans:+1}"
    printf '  *) printf '"'"'%%s\\n'"'"' "%s"; exit 0 ;;\n' "$defans"
    printf 'esac\n'
  } > "$out" || { echo "mk_keyed $out failed" >&2; exit 2; }
}
fix_p0_accept() { # $1 gate -- runner's python patch: p0 branch prints CLEAN, exits 0
  python3 - "$1" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
old = '  p0-ledger.tsv) printf \'%s\\n\' "unused"; exit 1 ;;\n'
new = '  p0-ledger.tsv) printf \'%s\\n\' "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)"; exit 0 ;;\n'
assert old in s, "p0 branch pattern missing"
open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
}

mk_keyed "$S/K1.sh" \
  "EXPECT_JOURNAL: REFUSE DELETED R11-03" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R17-02" \
  "f6-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R11-03"
mk_keyed "$S/K3.sh" \
  "unused" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01" \
  "f6-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R13-01"
fix_p0_accept "$S/K3.sh"
mk_keyed "$S/fakeC.sh" \
  "unused" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R17-02"
fix_p0_accept "$S/fakeC.sh"
# my6: the six-key answer-key gate (plan C1 named ceiling): exact tokens F1..F6, accepts P0.
mk_keyed "$S/my6.sh" \
  "unused" \
  "EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)" \
  "f1-ledger.tsv" "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01" \
  "f2-ledger.tsv" "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02" \
  "f3-ledger.tsv" "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01" \
  "f4-ledger.tsv" "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06" \
  "f5-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R17-02" \
  "f6-ledger.tsv" "EXPECT_JOURNAL: REFUSE DELETED R11-03"
fix_p0_accept "$S/my6.sh"

# ---------- counter mutants: surgery on byte-copies inside the sandbox clone ----------
python3 - "$W" <<'PY'
import os, sys
w = sys.argv[1]
src = open(os.path.join(w, "plans/round-43-c1.sh"), encoding="utf-8").read()

def mutate(dst, old, new, name):
    assert old in src, f"{name}: pattern missing"
    assert src.count(old) == 1, f"{name}: pattern not unique"
    open(os.path.join(w, dst), "w", encoding="utf-8").write(src.replace(old, new, 1))

# x1-echo6: the counter's final line is replaced by a constant target.
mutate("plans/mut-x1-echo6.sh", 'echo "$n"\n', 'echo 6\n', "x1")
# x2-noinc: the per-case n-increment is dropped (counter counts nothing).
mutate("plans/mut-x2-noinc.sh", "    n=$((n + 1))\n", "    :\n", "x2")
# x3-invguard: the P0 guard's polarity is inverted (deletion covered by m3, polarity is not).
mutate("plans/mut-x3-invguard.sh",
       'if [ "$rc" != "0" ]; then', 'if [ "$rc" = "0" ]; then', "x3")
print("mutants written")
PY

# ---------- run matrix: {base, x1, x2, x3} x {real, K1, K3, fakeC, my6} ----------
gate_of() {
  case "$1" in
    real) printf '%s' "$W/corpus/expect-journal.sh" ;;
    *)    printf '%s' "$S/$1.sh" ;;
  esac
}
for m in base x1-echo6 x2-noinc x3-invguard; do
  script=plans/round-43-c1.sh
  [ "$m" = base ] || script="plans/mut-$m.sh"
  for g in real K1 K3 fakeC my6; do
    env EXPECT_JOURNAL="$(gate_of "$g")" bash "$W/$script" > "$R/c1-$m-$g.txt" 2>&1
    rc=$?
    printf 'c1-%s-%s rc=%s value=%s\n' "$m" "$g" "$rc" "$(cat "$R/c1-$m-$g.txt")"
  done
done
echo DRIVER-DONE
