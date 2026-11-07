#!/usr/bin/env bash
# Run the frozen C1 counter on each forged fixture; one receipt per run.
set -u
S=/fast/scratch/hyaku/kagi-r52/R52CriticC1
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
REF=$LANE/.ufo/waves/round-52/controls/fixtures/ref/corpus/openbao-kv-versions-trial.sh
TR=$S/trials
mkdir -p "$S/receipts"
run_one() { # name trialfile
  local name=$1 trial=$2 fx="$S/fx-$1"
  rm -rf "$fx"; cp -a "$S/base" "$fx" || { echo "RUN $name SETUP copy-failed"; return; }
  cp "$trial" "$fx/corpus/openbao-kv-versions-trial.sh" || { echo "RUN $name SETUP trial-copy-failed"; return; }
  local t0 t1 rc
  t0=$(date +%s)
  bash "$LANE/plans/round-52-c1.sh" --tree "$fx" > "$S/receipts/$name.out" 2> "$S/receipts/$name.err"
  rc=$?
  t1=$(date +%s)
  echo "RUN $name rc=$rc secs=$((t1-t0)) :: $(tail -1 "$S/receipts/$name.out")"
  rm -rf "$fx"
}
run_one ref "$REF"
run_one f1 "$TR/f1-sh2probe.sh"
run_one f1b "$TR/f1b-sh1probe.sh"
run_one f2 "$TR/f2-fingerprint.sh"
run_one f3 "$TR/f3-moderead.sh"
run_one f4 "$TR/f4-argvread.sh"
run_one f5a "$TR/f5a-outpath.sh"
run_one f5b "$TR/f5b-ctime.sh"
run_one f6 "$TR/f6-partial.sh"
echo DONE
