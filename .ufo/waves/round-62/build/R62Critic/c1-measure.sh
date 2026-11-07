#!/usr/bin/env bash
# C1 measure leg exactly as plans/round-62.md §C1 words it:
#   python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge
# accepted = number of the five bypass fixtures on which the copy prints C1_ROUTED: value=0
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE="$S/base"
OUT="$1"; shift || true
TREESRC="${1:-$BASE}"
: > "$OUT"
acc=0
run() { # $1=label $2=tree
  local line rc
  line=$(cd "$2" && python3 -I -B plans/round-61-c1-check.py --root "$2" --repo "$LANE" --no-challenge 2>&1 | grep -m1 '^C1_ROUTED:')
  rc=$?
  printf '%s | rc=%s | %s\n' "$1" "$rc" "$line" >> "$OUT"
  case "$line" in *'value=0 '*) return 0;; *) return 1;; esac
}
# fixtures: id|file|anchor|replacement
FIX=(
'B3|plans/round-60.md|**A3 item 2 is withdrawn**|**A3 item 2 is not withdrawn**'
'B4|corpus/lessons/round-60.md|the round introduced three new record defects it did not route|the round introduced no three new record defects it did not route'
'B5|LOG.md|it was rewritten in place at|it was not rewritten in place at'
"B6|corpus/lessons/round-60.md|the lane was progressing, not stale.|the paragraph's times are correct."
'B7|corpus/lessons/round-60.md|so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %|so the literal reading is 3/16 = 25 %, and counting the sentinel as an attack seat gives 4/16 = 18.75 %'
)
rm -rf "$S/unmod"; cp -a "$TREESRC" "$S/unmod"
if run "UNMODIFIED" "$S/unmod"; then echo "UNMODIFIED accepted(value=0)" >> "$OUT"; else echo "UNMODIFIED resolved(value!=0)" >> "$OUT"; fi
for f in "${FIX[@]}"; do
  id=${f%%|*}; rest=${f#*|}; file=${rest%%|*}; rest=${rest#*|}; anchor=${rest%%|*}; repl=${rest#*|}
  d="$S/tree-$id"; rm -rf "$d"; cp -a "$TREESRC" "$d"
  python3 - "$d/$file" "$anchor" "$repl" <<'PY'
import sys
p,a,r=sys.argv[1],sys.argv[2],sys.argv[3]
d=open(p,encoding="utf-8").read()
n=d.count(a)
if n!=1:
    sys.stderr.write(f"SETUP anchor count={n}\n"); sys.exit(2)
open(p,"w",encoding="utf-8").write(d.replace(a,r,1))
PY
  if [ $? -ne 0 ]; then echo "$id | SETUP anchor-count" >> "$OUT"; continue; fi
  if run "$id" "$d"; then acc=$((acc+1)); fi
done
echo "ACCEPTED=$acc POPULATION=5" >> "$OUT"
echo "ACCEPTED=$acc"
