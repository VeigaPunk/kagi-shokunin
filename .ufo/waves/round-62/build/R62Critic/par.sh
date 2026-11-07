#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S"
OUT="$S/attempt5-paraphrase.txt"
: > "$OUT"
apply() { # tree file anchor repl
  python3 - "$1/$2" "$3" "$4" <<'PY'
import sys
p,a,r=sys.argv[1],sys.argv[2],sys.argv[3]
d=open(p,encoding="utf-8").read(); n=d.count(a)
if n!=1:
    sys.stderr.write("SETUP anchor count=%d\n" % n); sys.exit(2)
open(p,"w",encoding="utf-8").write(d.replace(a,r,1))
PY
}
measure() { # id tree
  local out rc line
  out=$(cd "$2" && python3 -I -B plans/round-61-c1-check.py --root "$2" --repo "$L" --no-challenge 2>&1); rc=$?
  line=$(printf '%s\n' "$out" | grep -m1 '^C1_ROUTED:')
  printf '%s | rc=%s | %s\n' "$1" "$rc" "$line" >> "$OUT"
}
for spec in \
  'P3|plans/round-60.md|**A3 item 2 is withdrawn**|**A3 item 2 is hereby withdrawn**' \
  'P4|corpus/lessons/round-60.md|the round introduced three new record defects it did not route|this round did introduce three new record defects it did not route' \
  'P5|LOG.md|it was rewritten in place at|it was rewritten in place, at' ; do
  id=${spec%%|*}; rest=${spec#*|}; file=${rest%%|*}; rest=${rest#*|}; anchor=${rest%%|*}; repl=${rest#*|}
  d="$S/tree-$id"; rm -rf "$d"; cp -a "$S/base" "$d"
  if apply "$d" "$file" "$anchor" "$repl"; then
    measure "$id" "$d"
  else
    printf '%s | SETUP anchor-count\n' "$id" >> "$OUT"
  fi
done
cat "$OUT"
