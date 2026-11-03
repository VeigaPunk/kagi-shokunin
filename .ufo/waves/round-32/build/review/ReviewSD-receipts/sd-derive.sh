#!/usr/bin/env bash
# ReviewSD — independent SD1..SD6 re-derivation, from the SD-table wording of
# plans/round-32.md ONLY (executor's script deliberately not read yet).
# Usage: bash sd-derive.sh <repo-root-at-measured-revision>
set -u
R=${1:?usage: sd-derive.sh <repo-root>}
cd -- "$R" || { echo "FATAL: no root $R"; exit 9; }
echo "root=$R rev=$(git rev-parse HEAD 2>/dev/null || echo 'not-git')"

echo "== SD1: PROVINCE.md Frontier-bullet lines naming a theme a Core bullet also names =="
sd1=0
sd1_hits=""
for t in 'OIDC workload-federation' 'secret[- ]scanning'; do
  core_named=$(grep -E '^[[:space:]]*[-*][[:space:]]\*\*Core' PROVINCE.md | grep -ciE "$t")
  if [ "$core_named" -gt 0 ]; then
    n=$(grep -E '^[[:space:]]*[-*][[:space:]]\*\*Frontier' PROVINCE.md | grep -ciE "$t")
    sd1=$((sd1 + n))
    [ "$n" -gt 0 ] && sd1_hits="$sd1_hits  theme[$t]: frontier_bullet_lines=$n core_bullets_named=$core_named"$'\n'
  fi
done
echo "SD1 n=$sd1"
[ -n "$sd1_hits" ] && printf '%s' "$sd1_hits"
echo "  frontier bullet lines:"; grep -nE '^[[:space:]]*[-*][[:space:]]\*\*Frontier' PROVINCE.md | cut -c1-100 | awk '{print "    L" $0}'

echo "== SD2: corpus/README.md lines inside ## Frontier containing 'moved to core' =="
sd2=$(awk '/^## Frontier[[:space:]]*$/{f=1;next} /^## /{f=0} f' corpus/README.md | grep -cF 'moved to core')
echo "SD2 n=$sd2"
awk '/^## Frontier[[:space:]]*$/{f=1;print "    [section starts] L" NR; next} /^## /{f=0} f{print "    L" NR ": " substr($0,1,90)}' corpus/README.md | grep -E 'moved to core|section starts'

echo "== SD3: SHONEN.md evidence tokens whose file does not exist =="
tokens=$(grep -oE 'corpus/[A-Za-z0-9][A-Za-z0-9_./-]*|\b(LOG|SKILL|PROVINCE)\.md\b' SHONEN.md \
         | awk '{sub(/:[0-9]+.*/,""); sub(/[.]+$/,""); print}' | sort -u)
sd3=0
while IFS= read -r tok; do
  [ -z "$tok" ] && continue
  if [ ! -f "$tok" ]; then echo "  MISSING: $tok"; sd3=$((sd3+1)); fi
done <<< "$tokens"
echo "SD3 n=$sd3 (distinct tokens checked=$(printf '%s\n' "$tokens" | grep -c .))"
printf '%s\n' "$tokens" | awk '{print "    token: " $0}'

echo "== SD4: round-31 lesson M31-n ids named with no '| M31-n ' row =="
named=$(grep -oE 'M31-[0-9]+' corpus/lessons/round-31.md | sort -u)
rowed=$(grep -E '^\| M31-[0-9]+ ' corpus/lessons/round-31.md | grep -oE 'M31-[0-9]+' | sort -u)
sd4_list=$(comm -23 <(printf '%s\n' "$named") <(printf '%s\n' "$rowed") | grep -c .)
echo "SD4 n=$sd4_list"
printf '    named: %s\n' "$(printf '%s' "$named" | tr '\n' ' ')"
printf '    rowed: %s\n' "$(printf '%s' "$rowed" | tr '\n' ' ')"
echo "    rows:"; grep -nE '^\| M31-[0-9]+ ' corpus/lessons/round-31.md | cut -c1-60 | awk '{print "      L" $0}'

echo "== SD5: lane-status red ids absent from latest calibration row of latest ## Round =="
reds=$(grep -m1 '^lane-status:' SCORECARD.md | grep -oE 'R[0-9]+-[0-9]+' | sort -u)
last_round=$(grep -nE '^## Round' SCORECARD.md | tail -n1 | cut -d: -f1)
crow=$(awk -v s="$last_round" 'NR==s{f=1;next} f&&/^## /{exit} f&&/^\|[[:space:]]*[Cc]alibration([[:space:]]|\|)/{row=$0} END{print row}' SCORECARD.md)
sd5=0
while IFS= read -r id; do
  [ -z "$id" ] && continue
  case "$crow" in *"$id"*) : ;; *) echo "  absent from latest calibration row: $id"; sd5=$((sd5+1));; esac
done <<< "$reds"
echo "SD5 n=$sd5 (latest ## Round heading at line $last_round)"
printf '    reds: %s\n' "$(printf '%s' "$reds" | tr '\n' ' ')"
printf '    latest calibration row (truncated): %.130s\n' "$crow"

echo "== SD6: claim-ledger citations UNRESOLVED lines (run in THIS root) =="
if [ "${SKIP_SD6:-0}" = "1" ]; then
  sd6=0; echo "SD6 skipped by request (SKIP_SD6=1)"
else
sd6out=$(bash corpus/claim-ledger.sh citations 2>&1)
sd6rc=$?
sd6=$(printf '%s\n' "$sd6out" | grep -c 'UNRESOLVED')
echo "SD6 n=$sd6 (script exit=$sd6rc)"
printf '%s\n' "$sd6out" | grep -E 'UNRESOLVED|CITATION_GATE|CITATION_LAYOUT' | cut -c1-160 | awk '{print "    " $0}'
fi

echo "== step-5 aid: every PROVINCE.md line matching either theme (any context) =="
grep -niE 'OIDC workload-federation|secret[- ]scanning' PROVINCE.md | cut -c1-150 | awk '{print "    L" $0}'

echo "== SUMMARY =="
echo "SD1=$sd1 SD2=$sd2 SD3=$sd3 SD4=$sd4_list SD5=$sd5 SD6=$sd6"
echo "SUM(SD1..SD6)=$((sd1+sd2+sd3+sd4_list+sd5+sd6))"
