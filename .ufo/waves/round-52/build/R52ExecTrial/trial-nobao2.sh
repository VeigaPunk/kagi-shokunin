#!/usr/bin/env bash
S=/fast/scratch/hyaku/kagi-r52/R52ExecTrial
RDIR=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-52/build/R52ExecTrial
mkdir -p "$S/nobin"
# only create symlink? No - PATH lacking bao but must have bash/core tools: use env -i PATH=/usr/bin:/bin (no bao there per counter PIN check)
command -v bao; echo "bao in /usr/bin:$?"; ls /usr/bin/bao /bin/bao 2>&1
start=$(date +%s.%N)
env -i PATH=/usr/bin:/bin HOME="$S/w1" bash "$S/tree/corpus/openbao-kv-versions-trial.sh" --work "$S/w1" > "$RDIR/trial-nobao.txt" 2>&1
rc=$?
end=$(date +%s.%N)
echo "command: env -i PATH=/usr/bin:/bin HOME=$S/w1 bash $S/tree/corpus/openbao-kv-versions-trial.sh --work $S/w1" > "$RDIR/trial-nobao.rc.txt"
echo "rc=$rc wall=$start..$end" >> "$RDIR/trial-nobao.rc.txt"
echo "last_line: $(tail -1 "$RDIR/trial-nobao.txt")" >> "$RDIR/trial-nobao.rc.txt"
echo "holds_lines=$(grep -c HOLDS "$RDIR/trial-nobao.txt" || true)" >> "$RDIR/trial-nobao.rc.txt"
echo "holds_count=$(grep -c '^TRIAL T[1-5] HOLDS' "$RDIR/trial-nobao.txt" || true)" >> "$RDIR/trial-nobao.rc.txt"
cat "$RDIR/trial-nobao.rc.txt"; echo ---; cat "$RDIR/trial-nobao.txt"
# timings summary
python3 -c "
for label,path in [('c1-1','c1-run1.rc.txt'),('c1-2','c1-run2.rc.txt'),('t1','trial-run1.rc.txt'),('t2','trial-run2.rc.txt'),('t3','trial-run3.rc.txt')]:
    txt=open(path).read()
    import re
    m=re.search(r'wall_start=([\d.]+) wall_end=([\d.]+)',txt)
    if m: print(label, float(m.group(2))-float(m.group(1)))
"
