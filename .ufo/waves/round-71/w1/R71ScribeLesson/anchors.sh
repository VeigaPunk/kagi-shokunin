#!/usr/bin/env bash
# SWEEP-ANCHORS: every §-anchor named in an entry's source line must appear in the cited row's anchor cell.
# usage: anchors.sh <entry.md> <SOURCES.md> <row-id>
e="$1"; s="$2"; id="$3"
row=$(grep -E "^\| $id " "$s" | head -1); anch=$(printf '%s' "$row" | awk -F'|' '{print $7}')
miss=0
while IFS= read -r a; do
  a=$(printf '%s' "$a" | sed -E 's/[[:space:]]+$//; s/^[[:space:]]+//; s/,$//')
  [ -z "$a" ] && continue
  if ! printf '%s' "$anch" | grep -qF -- "$a"; then echo "MISSING $id §$a"; miss=$((miss+1)); fi
done < <(sed -n 3p "$e" | sed -E "s/^.*\<$id \(//; s/; (re-)?opened.*//" | grep -oE "§[^§;)]*" | sed -E "s/^§//; s/ \(.*\$//")
if [ "$miss" -gt 0 ]; then echo "SWEEP-ANCHORS: FLAG missing=$miss"; exit 1; fi
echo "SWEEP-ANCHORS: CLEAN row=$id"; exit 0
