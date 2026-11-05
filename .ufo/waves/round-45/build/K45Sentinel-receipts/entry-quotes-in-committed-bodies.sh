#!/usr/bin/env bash
# K45Sentinel: are the ADMITTED ENTRY's own quoted strings present in the COMMITTED
# capture bodies (the bodies quote-bodies.tsv points at)? The C2 counter only requires
# >= 3 located quote-bodies rows for ADDED ids; it does not check that the entry's
# sentences are among them.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
C="$LANE/.ufo/waves/round-45/controls/capture-r45"
E="$LANE/corpus/knowledge/iso-11770-3-edition-status.md"

check() { # check BODY "QUOTE"
  local body="$1" q="$2" n
  n=$(grep -c -F -- "$q" "$body" 2>/dev/null)
  printf 'occurrences=%s body=%s\n' "$n" "${body##*/}"
}

echo "=== entry quote strings vs committed bodies (S100/S101/S102 .raw) ==="
while IFS= read -r q; do
  [ -n "$q" ] || continue
  echo "-- quote: $q"
  for b in "$C"/S100.raw "$C"/S101.raw "$C"/S102.raw; do check "$b" "$q"; done
done <<'EOF'
A more recent version of this publication exists: ISO/IEC 11770-3:2021/AMD1:2025
New version available: ISO/IEC 11770-3:2021
Withdrawal of International Standard
Status : Withdrawn
ISO/IEC 11770-3:2021
does not cover certain aspects of key management, such as key lifecycle management, mechanisms to generate or validate asymmetric key pairs
EOF

echo
echo "=== the three located quote-bodies rows (committed manifest) ==="
awk -F'\t' 'NR>1{print $1" | offset="$3" | quote="$4}' "$LANE/corpus/quote-bodies.tsv" | tail -3
