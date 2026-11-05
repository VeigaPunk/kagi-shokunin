#!/usr/bin/env bash
# K45Sentinel: are the admitted entry's quoted sentences present in the committed capture
# bodies under WHITESPACE-NORMALISED text (the lane's rendered-text-v1 discipline)?
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C="$LANE/.ufo/waves/round-45/controls/capture-r45"
S=/fast/scratch/hyaku/kagi-r45/K45Sentinel
mkdir -p "$S/norm"
python3 - <<'PY'
import re, pathlib
C = pathlib.Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/controls/capture-r45")
out = pathlib.Path("/fast/scratch/hyaku/kagi-r45/K45Sentinel/norm")
for p in sorted(C.glob("*.raw")):
    t = p.read_text(encoding="utf-8", errors="replace")
    t = re.sub(r"<script.*?</script>", " ", t, flags=re.S|re.I)
    t = re.sub(r"<style.*?</style>", " ", t, flags=re.S|re.I)
    t = re.sub(r"<[^>]+>", " ", t)
    t = re.sub(r"&[a-zA-Z#0-9]+;", " ", t)
    t = re.sub(r"\s+", " ", t)
    (out/(p.stem+".norm.txt")).write_text(t, encoding="utf-8")
    print("normalised", p.name, "->", (out/(p.stem+".norm.txt")).name, len(t))
PY

while IFS= read -r q; do
  [ -n "$q" ] || continue
  echo "-- quote: $q"
  for f in "$S"/norm/*.norm.txt; do
    n=$(grep -o -F -- "$q" "$f" | wc -l)
    printf '   occurrences=%s file=%s\n' "$n" "${f##*/}"
  done
done <<'EOF'
A more recent version of this publication exists: ISO/IEC 11770-3:2021/AMD1:2025
New version available: ISO/IEC 11770-3:2021
Withdrawal of International Standard
Status : Withdrawn
does not cover certain aspects of key management, such as key lifecycle management, mechanisms to generate or validate asymmetric key pairs
EOF
