#!/usr/bin/env bash
# K45Sentinel secret-shape scanner. Prints ONLY pattern name + path:line (never matched value).
set -u
OUT=/fast/scratch/hyaku/kagi-r45/K45Sentinel
mkdir -p "$OUT"

# pattern name :: ERE
PATTERNS=(
  'OP_URI::op://'
  'SK_PREFIX::(^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{8,}'
  'AKIA::AKIA[0-9A-Z]{16}'
  'PEM_HEADER::-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'PEM_HEADER_PUB::-----BEGIN [A-Z ]*PUBLIC KEY-----'
  'JWT::eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{5,}'
  'GITHUB_TOKEN::gh[pousr]_[A-Za-z0-9]{20,}'
  'SLACK_TOKEN::xox[baprs]-[A-Za-z0-9-]{10,}'
  'COOKIE_STRING::[Cc]ookie:'
  'SESSION_STRING::(?i)session[-_]?id'
  'SET_COOKIE::(?i)set-cookie'
  'LONG_HEX::[0-9a-fA-F]{40,}'
  'LONG_B64::[A-Za-z0-9+/]{48,}={0,2}'
  'EMAIL::[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
  'CREDITCARD::(?i)(card|cvv|cvc|expiry|iban)[^A-Za-z0-9]{0,3}[0-9]{12,19}'
  'PHONE::\+?[0-9][0-9 ()-]{9,14}[0-9]'
  'ONEPASSWORD::(?i)1password'
  'JANITOR::(?i)the-janitor'
  'VAULT_REF::(?i)\bvault\b'
  'OP_CMD::(?i)(^|[^a-z0-9_-])op ([a-z]+ )?[a-z-]+'
  'SYSCTL::sysctl'
  'PACMAN::pacman'
  'SYSTEMCTL::systemctl'
  'SUDO::sudo '
  'SETUID::(?i)chmod [47]?[0-7]{3,}'
)

scan() { # scan FILE
  local f="$1" name re
  for p in "${PATTERNS[@]}"; do
    name="${p%%::*}"; re="${p#*::}"
    local hits
    hits=$(grep -nE "$re" "$f" 2>/dev/null | cut -d: -f1)
    if [ -n "$hits" ]; then
      while read -r ln; do
        [ -n "$ln" ] && printf 'HIT\t%s\t%s\t%s\n' "$name" "$f" "$ln"
      done <<<"$hits"
    fi
  done
}

TARGETS=()
while IFS= read -r t; do TARGETS+=("$t"); done <<'EOF'
/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-2015-supersession-chain-r39.md
/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-catalogue-record-and-lifecycle-r41.md
/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md
EOF

for f in "${TARGETS[@]}"; do
  if [ ! -f "$f" ]; then echo "MISSING $f"; continue; fi
  scan "$f"
done

# (b) build dir + plans scripts
BUILD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build
while IFS= read -r f; do scan "$f"; done < <(find "$BUILD" -type f | sort)
for f in /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-45*.sh; do
  [ -f "$f" ] && scan "$f"
done
