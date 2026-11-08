#!/usr/bin/env bash
# Probe 11: (a) does the one-line remediation make the counter REFUSE the
# liar tree (final verdict), and (b) does the counter catch a row that is moved
# OUT of the checked population (trailing space in col 16)?
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C1="$LANE/plans/round-67-c1.sh"
PC="$SCRATCH/patched-c1.sh"

echo "########## (a) patched counter on the liar tree ##########"
( cd "$SCRATCH/probe-selective" && timeout 2400 bash "$PC" --tree "$SCRATCH/probe-selective" --scratch "$SCRATCH/probe-scratch/p11" ) 2>&1 \
  | grep -E 'derived |guard-a|guard-b|C1_READTHROUGH' | head -8
echo
echo "########## (b) trailing-space row moved out of the population ##########"
T="$SCRATCH/probe-trailing"
rm -rf "$T"; mkdir -p "$T"
tar -C "$LANE" --exclude=.git --exclude=.jj -cf - . | tar -C "$T" -xf -
TSV="$T/corpus/source-fetches.tsv"
awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF==0{print;next} $1=="S164"{ $16=$16" "; print; next } {print}' "$TSV" > "$TSV.t" && mv "$TSV.t" "$TSV"
echo "--- gate on the tree (--root) ---"
bash "$T/corpus/sources-census.sh" verify --root "$T" 2>&1 | grep -E 'SC_CAPTURE|SOURCES_CAPTURES|SOURCES_CENSUS' | tail -3
echo "--- counter on the tree ---"
( cd "$T" && timeout 2400 bash "$C1" --tree "$T" --scratch "$SCRATCH/probe-scratch/t11" ) 2>&1 \
  | grep -E 'derived |guard-a|guard-pop|C1_READTHROUGH' | head -8
exit 0
