#!/usr/bin/env bash
# R62Critic remaining falsifications. Read-only over the lane; all writes under $S.
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S"
OUT="$S/attempts-rest.txt"
: > "$OUT"
say() { printf '%s\n' "$*" | tee -a "$OUT"; }

apply() { # tree file anchor repl mode(all|one)
  python3 - "$1/$2" "$3" "$4" "${5:-one}" <<'PY'
import sys
p,a,r,mode=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
d=open(p,encoding="utf-8").read(); n=d.count(a)
if n<1:
    sys.stderr.write("SETUP anchor count=0\n"); sys.exit(2)
open(p,"w",encoding="utf-8").write(d.replace(a,r) if mode=="all" else d.replace(a,r,1))
print("anchor_count=%d mode=%s" % (n,mode))
PY
}

measure() { # id tree
  local out rc line
  out=$(cd "$2" && python3 -I -B plans/round-61-c1-check.py --root "$2" --repo "$L" --no-challenge 2>&1); rc=$?
  line=$(printf '%s\n' "$out" | grep -m1 '^C1_ROUTED:')
  say "$1 | rc=$rc | $line"
}

# ---- A. line-scoped I4 base (the only reading that can reject B4) ----
say "== A. line-scoped I4, base"
python3 "$S/grammar.py" "$S/base/corpus/lessons/round-60.md" i4 \
  'supersedes\s+the\s+round-60\s+quality-trend\s+sentence' >>"$OUT" 2>&1
say "A rc=$?"

# ---- B. benign rewrites the frozen grammar rejects ----
say "== B. benign rewrites (frozen grammar, literal)"
mkdir -p "$S/benign"
printf '**Item 2 of A3 is withdrawn**\n'                      > "$S/benign/i3-reorder.txt"
printf '**A3 item 2: withdrawn**\n'                          > "$S/benign/i3-colon.txt"
printf '**A3 item 2 is not merely withdrawn but superseded**\n' > "$S/benign/i3-notmerely.txt"
printf '**A3 item 2 is hereby withdrawn**\n'                 > "$S/benign/i3-p3.txt"
printf 'the round introduced no fewer than three new record defects\n' > "$S/benign/i4-nofewer.txt"
printf 'the round introduced 3 new record defects\n'         > "$S/benign/i4-digit.txt"
printf 'this round did introduce three new record defects it did not route\n' > "$S/benign/i4-p4.txt"
printf 'it was not appended but rewritten in place at 12:00:00\n' > "$S/benign/i5-notappended.txt"
printf 'it was rewritten in-place at 12:00:00\n'             > "$S/benign/i5-hyphen.txt"
printf 'it was rewritten in place, at 12:00:00\n'             > "$S/benign/i5-p5.txt"
for f in i3-reorder i3-colon i3-notmerely i3-p3; do
  r=$(python3 "$S/grammar.py" "$S/benign/$f.txt" i3 2>&1 | head -1); say "  $f :: $r"
done
for f in i4-nofewer i4-digit i4-p4; do
  r=$(python3 "$S/grammar.py" "$S/benign/$f.txt" i4 2>&1 | head -1); say "  $f :: $r"
done
for f in i5-notappended i5-hyphen i5-p5; do
  r=$(python3 "$S/grammar.py" "$S/benign/$f.txt" i5 2>&1 | head -1); say "  $f :: $r"
done

# ---- C. stub checker: does the measure leg refuse it? ----
say "== C. printer-stub checker"
rm -rf "$S/stubcheck"; cp -a "$S/base" "$S/stubcheck"
cat > "$S/stubcheck/plans/round-61-c1-check.py" <<'STUB'
#!/usr/bin/env python3
import sys
if "--selftest" in sys.argv:
    print("C1_CHECK_SELFTEST: PASS (cases=57)"); sys.exit(0)
print("C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")
sys.exit(1)
STUB
chmod +x "$S/stubcheck/plans/round-61-c1-check.py"
say "  stub --selftest: $(cd "$S/stubcheck" && python3 -I -B plans/round-61-c1-check.py --selftest)"
say "  stub --no-challenge: $(cd "$S/stubcheck" && python3 -I -B plans/round-61-c1-check.py --root . --no-challenge)"
for id in B3 B4 B5 B6 B7; do
  measure "STUB-$id" "$S/tree-$id" 2>/dev/null | sed 's/^/  /' | tee -a "$OUT" >/dev/null
done
# the stub tree itself, with the five fixtures applied: the measure leg reads value=0
rm -rf "$S/stubcheck-B3"; cp -a "$S/stubcheck" "$S/stubcheck-B3"
apply "$S/stubcheck-B3" plans/round-60.md '**A3 item 2 is withdrawn**' '**A3 item 2 is not withdrawn**' one >/dev/null 2>&1
say "  stubcheck-B3: $(cd "$S/stubcheck-B3" && python3 -I -B plans/round-61-c1-check.py --root . --repo "$L" --no-challenge)"

# ---- D. fixture vacuity ----
say "== D. vacuity"
rm -rf "$S/vac-double"; cp -a "$S/base" "$S/vac-double"
printf '\n**A3 item 2 is withdrawn**\n' >> "$S/vac-double/plans/round-60.md"
say "  double anchor count=$(python3 -c 'import sys;print(open(sys.argv[1]).read().count("**A3 item 2 is withdrawn**"))' "$S/vac-double/plans/round-60.md")"
say "  replace-all: $(apply "$S/vac-double" plans/round-60.md '**A3 item 2 is withdrawn**' '**A3 item 2 is not withdrawn**' all 2>&1)"
measure "VAC-DOUBLE" "$S/vac-double"
rm -rf "$S/vac-zero"; cp -a "$S/base" "$S/vac-zero"
python3 - "$S/vac-zero/plans/round-60.md" <<'PY'
import sys
p=sys.argv[1]; d=open(p,encoding="utf-8").read()
a="**A3 item 2 is withdrawn**"
assert d.count(a)==1
open(p,"w",encoding="utf-8").write(d.replace(a,"**A3 item 2 stands**",1))
PY
say "  zero-anchor replace: $(apply "$S/vac-zero" plans/round-60.md '**A3 item 2 is withdrawn**' '**A3 item 2 is not withdrawn**' one 2>&1)"
measure "VAC-ZERO" "$S/vac-zero"

# ---- E. causal separability: C1 without the C2 files ----
say "== E. C1 measure on a tree stripped of C2 files"
rm -rf "$S/noc2"; cp -a "$S/base" "$S/noc2"
rm -f "$S/noc2/plans/round-61-c2.sh" "$S/noc2/corpus/openbao-seal-trial.sh"
rm -rf "$S/noc2/.ufo/waves/round-61/build/R61ExecCounterC2"
say "  stripped: $(ls "$S/noc2/plans/round-61-c2.sh" 2>&1 | head -1)"
for id in B3 B4 B5 B6 B7; do
  d="$S/noc2-$id"; rm -rf "$d"; cp -a "$S/noc2" "$d"
  case $id in
    B3) apply "$d" plans/round-60.md '**A3 item 2 is withdrawn**' '**A3 item 2 is not withdrawn**' one >/dev/null;;
    B4) apply "$d" corpus/lessons/round-60.md 'the round introduced three new record defects it did not route' 'the round introduced no three new record defects it did not route' one >/dev/null;;
    B5) apply "$d" LOG.md 'it was rewritten in place at' 'it was not rewritten in place at' one >/dev/null;;
    B6) apply "$d" corpus/lessons/round-60.md 'the lane was progressing, not stale.' "the paragraph's times are correct." one >/dev/null;;
    B7) apply "$d" corpus/lessons/round-60.md 'so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %' 'so the literal reading is 3/16 = 25 %, and counting the sentinel as an attack seat gives 4/16 = 18.75 %' one >/dev/null;;
  esac
  measure "NOC2-$id" "$d"
done

# ---- F. causal separability: C2 counter on a tree stripped of C1 files ----
say "== F. C2 counter on a tree stripped of C1 files"
rm -rf "$S/noc1"; cp -a "$S/base" "$S/noc1"
rm -f "$S/noc1/plans/round-61-c1-check.py" "$S/noc1/plans/round-62-c1.sh"
rm -f "$S/noc1/plans/round-62-bypass.tsv" "$S/noc1/plans/round-62-paraphrase.tsv"
say "  stripped: $(ls "$S/noc1/plans/round-61-c1-check.py" 2>&1 | head -1)"
out=$(bash "$S/noc1/plans/round-61-c2.sh" --tree "$S/noc1" 2>&1); rc=$?
say "  NOC1-C2 | rc=$rc | $(printf '%s\n' "$out" | grep -m1 '^C2_SEAL_TRIAL:')"
say "DONE"
