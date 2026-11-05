#!/usr/bin/env bash
# K45Sentinel: pattern -> hit count per target class. Counts only, no values.
set -u
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
  'CHMOD_SETUID::(?i)chmod [47]?[0-7]{3,}'
)
STAGED_A=/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-2015-supersession-chain-r39.md
STAGED_B=/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-catalogue-record-and-lifecycle-r41.md
APPEND=/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md
BUILD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build
PLANS=/home/vgpnk/Projects/shokunin/kagi-shokunin/plans

count() { # count ERE FILE -> integer on stdout
  local n
  n=$(grep -cE "$1" "$2" 2>/dev/null)
  n=${n:-0}
  case "$n" in ''|*[!0-9]*) n=0 ;; esac
  printf '%s' "$n"
}
printf 'PATTERN\tSTAGED_R39\tSTAGED_R41\tSOURCES_APPEND\tBUILD_ALL\tPLANS_R45SH\tTOTAL\n'
for p in "${PATTERNS[@]}"; do
  name="${p%%::*}"; re="${p#*::}"
  a=$(count "$re" "$STAGED_A"); b=$(count "$re" "$STAGED_B"); c=$(count "$re" "$APPEND")
  d=0
  while IFS= read -r f; do d=$((d + $(count "$re" "$f"))); done < <(find "$BUILD" -type f | sort)
  e=0
  for f in "$PLANS"/round-45*.sh; do [ -f "$f" ] && e=$((e + $(count "$re" "$f"))); done
  tot=$((a+b+c+d+e))
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$a" "$b" "$c" "$d" "$e" "$tot"
done
