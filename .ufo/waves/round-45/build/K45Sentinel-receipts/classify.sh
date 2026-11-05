#!/usr/bin/env bash
# K45Sentinel classifier: characterize each regex hit WITHOUT printing matched values.
set -u
OUT=/fast/scratch/hyaku/kagi-r45/K45Sentinel

classify() { # classify PATTERN ERE FILE
  local name="$1" re="$2" f="$3" ln text
  while IFS= read -r ln; do
    [ -n "$ln" ] || continue
    text=$(grep -nE "$re" "$f" 2>/dev/null | awk -F: -v L="$ln" '$1==L{print; exit}' | cut -d: -f2-)
    local cls=""
    # URL-embedded?
    if printf '%s' "$text" | grep -qE 'https?://'; then
      if printf '%s' "$text" | grep -qE '(https?://[^ ]*)'; then cls="$cls url-line"; fi
    fi
    if printf '%s' "$text" | grep -qiE 'sha256|checksum|digest'; then cls="$cls sha-context"; fi
    if printf '%s' "$text" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}'; then cls="$cls date-context"; fi
    # matched token character class
    local tok
    tok=$(printf '%s\n' "$text" | grep -oE "$re" | head -n1)
    local kind
    if printf '%s' "$tok" | grep -qE '^[0-9]+$'; then kind=digits-only; 
    elif printf '%s' "$tok" | grep -qE '^[0-9a-fA-F]+$'; then kind=hex-only;
    elif printf '%s' "$tok" | grep -qE '^[A-Za-z0-9+/]+={0,2}$'; then kind=b64-charset;
    else kind=mixed; fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$f" "$ln" "$kind" "${cls:-no-context}"
  done < <(grep -nE "$re" "$f" 2>/dev/null | cut -d: -f1)
}

scan() {
  local f="$1" name re
  for p in "${PATTERNS[@]}"; do
    name="${p%%::*}"; re="${p#*::}"
    classify "$name" "$re" "$f"
  done
}

PATTERNS=(
  'LONG_HEX::[0-9a-fA-F]{40,}'
  'LONG_B64::[A-Za-z0-9+/]{48,}={0,2}'
  'PHONE::\+?[0-9][0-9 ()-]{9,14}[0-9]'
)

for f in \
 /home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-2015-supersession-chain-r39.md \
 /home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-catalogue-record-and-lifecycle-r41.md \
 /home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md ; do
  scan "$f"
done
while IFS= read -r f; do scan "$f"; done < <(find /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build -type f | sort)
for f in /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-45*.sh; do [ -f "$f" ] && scan "$f"; done
