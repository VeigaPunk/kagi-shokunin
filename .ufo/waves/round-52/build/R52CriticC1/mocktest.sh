#!/usr/bin/env bash
# Mock-mode test of the forged bodies against counter-faithful dispatchers (no counter yet).
set -u
S=/fast/scratch/hyaku/kagi-r52/R52CriticC1
M=$S/mock; TR=$S/trials
vec() { grep -oE '^TRIAL T[1-5] (HOLDS|BROKEN|ERROR)' | awk '{printf "%s", substr($3,1,1)}'; }
for t in f1-sh2probe f1b-sh1probe f2-fingerprint f3-moderead f4-argvread f5a-outpath; do
  line=""
  for m in real sh1 sh2 sh3 sh4 sh5; do
    d=$M/$m
    v=$(env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
        timeout 120 bash "$TR/$t.sh" --work "$d/work" 2>/dev/null | vec)
    line="$line $m=$v"
  done
  printf '%s%s\n' "$t" "$line"
done
