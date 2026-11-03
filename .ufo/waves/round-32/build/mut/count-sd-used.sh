#!/usr/bin/env bash
# Independent plain-grep derivation of SD1-SD5 from the frozen plan wording
# (plans/round-32.md, commit 507dd9f). Usage: bash count-sd.sh <repo-root>
# SD5 is reported under two readings of "absent from the latest calibration row":
#   SD5_LITERAL   = whole table row (all four cells)
#   SD5_STATUSCOL = row minus the final Evidence cell (Axis | Before->after | What moved)
set -u
R="${1:?repo root}"
cd "$R" || exit 9

# ---------- SD1 ----------
THEMES=('OIDC workload-federation' 'secret[- ]scanning')
sd1=0
sd1_detail=""
for t in "${THEMES[@]}"; do
  core_hits=$(grep -isE "^[[:space:]]*[-*][[:space:]]+\*\*Core\b.*(${t})" PROVINCE.md | wc -l)
  fr=$(grep -inE "^[[:space:]]*[-*][[:space:]]+\*\*Frontier\b.*(${t})" PROVINCE.md)
  n=$(printf '%s' "$fr" | grep -c . )
  if [ "$core_hits" -gt 0 ]; then sd1=$((sd1 + n)); fi
  sd1_detail+="theme[$t] core_lines=$core_hits frontier_lines=$n($(printf '%s' "$fr" | cut -d: -f1 | tr '\n' ',')); "
done
echo "SD1=$sd1"
echo "SD1_DETAIL=$sd1_detail"

# ---------- SD2 ----------
sd2=$(awk '/^##[[:space:]]+Frontier[[:space:]]*$/{f=1;next} /^##[[:space:]]/{f=0} f' corpus/README.md | grep -c 'moved to core')
echo "SD2=$sd2"
echo "SD2_LINES=$(awk '/^##[[:space:]]+Frontier[[:space:]]*$/{f=1;next} /^##[[:space:]]/{f=0} f&&/moved to core/{print NR}' corpus/README.md | tr '\n' ',')"

# ---------- SD3 ----------
tok=$(grep -oE '(corpus/[A-Za-z0-9._/-]+|LOG\.md|SKILL\.md|PROVINCE\.md)' SHONEN.md | sort -u)
sd3=0; sd3_missing=""; sd3_checked=""
while IFS= read -r p; do
  [ -z "$p" ] && continue
  q="$p"
  if [ ! -e "$q" ] && [ "${q%%.}" != "$q" ]; then q="${q%.}"; fi   # sentence-final period
  if [ -e "$q" ]; then sd3_checked+="$q,"
  else sd3=$((sd3+1)); sd3_missing+="$q,"; fi
done <<< "$tok"
echo "SD3=$sd3"
echo "SD3_TOKENS=$(printf '%s' "$tok" | tr '\n' ' ')"
echo "SD3_EXIST=$sd3_checked"
echo "SD3_MISSING=$sd3_missing"

# ---------- SD4 ----------
all_ids=$(grep -oE 'M31-[0-9]+' corpus/lessons/round-31.md | sort -u)
row_ids=$(grep -oE '^\|[[:space:]]*M31-[0-9]+[[:space:]]*\|' corpus/lessons/round-31.md | grep -oE 'M31-[0-9]+' | sort -u)
sd4=0; sd4_ids=""
while IFS= read -r id; do
  [ -z "$id" ] && continue
  if ! printf '%s\n' "$row_ids" | grep -qx "$id"; then sd4=$((sd4+1)); sd4_ids+="$id,"; fi
done <<< "$all_ids"
echo "SD4=$sd4"
echo "SD4_ALL=$(printf '%s' "$all_ids" | tr '\n' ' ')"
echo "SD4_ROWS=$(printf '%s' "$row_ids" | tr '\n' ' ')"
echo "SD4_MISSING=$sd4_ids"

# ---------- SD5 ----------
red=$(grep -E '^lane-status:' SCORECARD.md | tail -1 | grep -oE 'R[0-9]{2}-[0-9]{2}' | sort -u)
last_round_line=$(grep -nE '^##[[:space:]]+Round[[:space:]]' SCORECARD.md | tail -1 | cut -d: -f1)
row=$(tail -n +"$last_round_line" SCORECARD.md | grep -E '^\|[[:space:]]*calibration[[:space:]]*\|' | tail -1)
# drop the final (Evidence) cell of the row, robust to embedded pipes in cell text
status="${row%|*}"; status="${status%|*}" 
cnt_lit=0; cnt_sta=0; abs_lit=""; abs_sta=""
while IFS= read -r id; do
  [ -z "$id" ] && continue
  if printf '%s' "$row"    | grep -qE "(^|[^0-9A-Za-z-])$id([^0-9]|$)"; then :; else cnt_lit=$((cnt_lit+1)); abs_lit+="$id,"; fi
  if printf '%s' "$status" | grep -qE "(^|[^0-9A-Za-z-])$id([^0-9]|$)"; then :; else cnt_sta=$((cnt_sta+1)); abs_sta+="$id,"; fi
done <<< "$red"
echo "SD5_LITERAL=$cnt_lit"
echo "SD5_STATUSCOL=$cnt_sta"
echo "SD5_RED=$(printf '%s' "$red" | tr '\n' ' ')"
echo "SD5_SECTION_LINE=$last_round_line"
echo "SD5_CAL_ABSENT_LITERAL=$abs_lit"
echo "SD5_CAL_ABSENT_STATUSCOL=$abs_sta"
