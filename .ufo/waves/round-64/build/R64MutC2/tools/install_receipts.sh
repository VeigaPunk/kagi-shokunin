#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r64/R64MutC2
D=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-64/build/R64MutC2
mkdir -p "$D/evidence"
cp -f "$S/logs/table_all.tsv" "$D/evidence/detector-table.tsv"
cp -f "$S/logs/pristine.base64b.log" "$D/evidence/base-tree-rc124.log" 2>/dev/null || true
for f in "$S/logs"/ctl6-*.selftest.log "$S/logs"/ctl6-*.fixtureP.log; do
  [ -f "$f" ] && cp -f "$f" "$D/evidence/"
done
{
  echo "# before/after sha256 (pristine snapshot -> mutant byte copies)"
  sha256sum "$S"/pristine/plans/*.sh
  sha256sum "$S"/mut/c2/*/plans/*.sh
  sha256sum "$S"/mut/controls/*/plans/*.sh
} > "$D/evidence/hashes.txt"
ls "$D/evidence"
