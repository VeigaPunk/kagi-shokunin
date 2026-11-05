set -u
PATS=(
 'OP_URI::op://'
 'CN_ID::(^|[^0-9])[1-9][0-9]{5}(19|20)[0-9]{2}(0[1-9]|1[0-2])([0-2][0-9]|3[01])[0-9]{3}[0-9Xx]([^0-9Xx]|$)'
 'CN_MOBILE::(^|[^0-9])1[3-9][0-9]{9}([^0-9]|$)'
 'BEARER::(?i)bearer [A-Za-z0-9._~+/-]{12,}'
 'BASIC_AUTH::(?i)authorization: *(basic|bearer)'
 'PASSWORD_KV::(?i)(password|passwd|pwd|secret|api[_-]?key|access[_-]?key|token|client[_-]?secret)[[:space:]]*[:=][[:space:]]*[^[:space:]]{6,}'
 'PRIVKEY::-----BEGIN'
 'SSH_KEY::ssh-(rsa|ed25519|dss)'
 'AWS_SECRET::aws_secret_access_key[[:space:]]*[:=]'
 'GOOGLE_KEY::AIza[0-9A-Za-z_-]{35}'
 'SLACK_WEBHOOK::hooks\.slack\.com/services/'
 'DISCORD_WEBHOOK::discord(app)?\.com/api/webhooks/'
 'PG_URL::postgres(ql)?://[^:@/]+:[^@/]+@'
 'MONGO_URL::mongodb(\+srv)?://[^:@/]+:[^@/]+@'
 'REDIS_URL::redis(s)?://[^:@/]+:[^@/]+@'
 'HTTP_AUTH_URL::https?://[^:/[:space:]]+:[^@/[:space:]]+@'
 'NPM_TOKEN::npm_[A-Za-z0-9]{30,}'
 'PIP_TOKEN::pypi-AgEIcHlwaS5vcmc[A-Za-z0-9_-]{50,}'
 'HF_TOKEN::hf_[A-Za-z0-9]{30,}'
 'ANTHROPIC_KEY::sk-ant-[A-Za-z0-9_-]{20,}'
 'OPENAI_KEY::sk-[A-Za-z0-9]{32,}'
 'COOKIE_HDR::(?i)cookie[[:space:]]*:'
 'SESSIONID::(?i)(sessionid|session_id|csrf|xsrf)'
 'PHONE_INTL::\+[0-9]{1,3}[ -]?[0-9]{2,4}[ -]?[0-9]{3,4}[ -]?[0-9]{3,4}'
 'SSN::(^|[^0-9])[0-9]{3}-[0-9]{2}-[0-9]{4}([^0-9]|$)'
 'CARD::(^|[^0-9])([0-9]{4}[ -]){3}[0-9]{4}([^0-9]|$)'
)
FILES=(
 /home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-2015-supersession-chain-r39.md
 /home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-catalogue-record-and-lifecycle-r41.md
 /home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md
)
printf 'PATTERN\tstaged_r39\tstaged_r41\tappend\tbuild_all\tplans_r45sh\tTOTAL\n'
for p in "${PATS[@]}"; do
 n="${p%%::*}"; re="${p#*::}"
 c(){ local x; x=$(grep -cE "$1" "$2" 2>/dev/null); case "$x" in ''|*[!0-9]*) x=0;; esac; printf '%s' "$x"; }
 a=$(c "$re" "${FILES[0]}"); b=$(c "$re" "${FILES[1]}"); d0=$(c "$re" "${FILES[2]}")
 bb=0
 while IFS= read -r f; do bb=$((bb+$(c "$re" "$f"))); done < <(find /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build -type f | sort)
 pp=0
 for f in /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-45*.sh; do [ -f "$f" ] && pp=$((pp+$(c "$re" "$f"))); done
 printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$n" "$a" "$b" "$d0" "$bb" "$pp" "$((a+b+d0+bb+pp))"
done
