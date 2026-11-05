set -u
PATS=(
 'ONEPASSWORD|1password'
 'JANITOR|the-janitor'
 'VAULT_WORD|vault'
 'OP_URI|op://'
 'SESSIONID|session[-_]?id'
 'SET_COOKIE|set-cookie'
 'COOKIE_HDR|[Cc]ookie:'
 'CREDITCARD|(card|cvv|cvc|expiry|iban)[^A-Za-z0-9]{0,3}[0-9]{12,19}'
 'OP_CMD|(^|[^a-z0-9_-])op (run|get|read|document|item|account)'
 'PASSWORD_KV|(password|passwd|secret|api[_-]?key|access[_-]?key|token|client[_-]?secret)[[:space:]]*[:=][[:space:]]*[^[:space:]]{6,}'
)
F1=/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-2015-supersession-chain-r39.md
F2=/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-catalogue-record-and-lifecycle-r41.md
F3=/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md
printf 'PATTERN\tstaged_r39\tstaged_r41\tappend\tbuild_all\tplans_r45sh\tTOTAL\n'
for p in "${PATS[@]}"; do
 n="${p%%|*}"; re="${p#*|}"
 c(){ local x; x=$(grep -ciE "$1" "$2" 2>/dev/null); case "$x" in ''|*[!0-9]*) x=0;; esac; printf '%s' "$x"; }
 a=$(c "$re" "$F1"); b=$(c "$re" "$F2"); d0=$(c "$re" "$F3")
 bb=0; while IFS= read -r f; do bb=$((bb+$(c "$re" "$f"))); done < <(find /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build -type f | sort)
 pp=0; for f in /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-45*.sh; do [ -f "$f" ] && pp=$((pp+$(c "$re" "$f"))); done
 printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$n" "$a" "$b" "$d0" "$bb" "$pp" "$((a+b+d0+bb+pp))"
done
