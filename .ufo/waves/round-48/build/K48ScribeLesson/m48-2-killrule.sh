#!/usr/bin/env bash
# K48ScribeLesson — M48-2 receipt: the frozen C1 kill rule's literal matched its own instruments
# (Amendment A1), and the key-shaped ERE it was amended to separates them.
#
# Read-only over the lane at the predeclaration. The fake identity is built here — the prefix plus
# 58 'Z' (not a key, no checksum, generated in scratch) — and the scratch dir is removed on exit.
# No key-shaped string is printed: only counts and the fixture's line length.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
PRE=164f0ea5ed8b76a671f9b076158d1d8022881813
S="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r48/K48ScribeLesson"
mkdir -p "$S" || exit 2
F="$S/fx.$$"
mkdir -p "$F" || exit 2
trap 'rm -rf -- "$F"' EXIT

echo "## 1. the frozen rule's own literal (AGE-SECRET-KEY) in the instruments at the predeclaration"
for p in plans/round-48.md plans/round-48-c1.sh \
         .ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh; do
  n=$(git -C "$LANE" show "$PRE:$p" | grep -c 'AGE-SECRET-KEY')
  echo "  $p: matching-lines=$n"
done
if git -C "$LANE" show "$PRE:plans/round-48.md" | grep -q 'AGE-SECRET-KEY'; then
  echo "  KILL-RULE(bare-literal) on the plan: FIRES (grep rc=0) -> C1 could never reach the candidate"
else
  echo "  KILL-RULE(bare-literal) on the plan: passes"
fi

echo "## 2. the amended ERE AGE-SECRET-KEY-1[0-9A-Z]{58} (Amendment A1)"
head -c 58 /dev/zero | tr '\0' 'Z' > "$F/tail"
{ printf 'AGE-SECRET-KEY-1'; cat "$F/tail"; printf '\n'; } > "$F/fake.txt"
echo "  fixture: line-chars=$(awk '{print length($0)}' "$F/fake.txt") (16 prefix + 58 payload) key-shaped-matches=$(grep -cE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' "$F/fake.txt")"
for p in plans/round-48.md plans/round-48-c1.sh \
         .ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh; do
  n=$(git -C "$LANE" show "$PRE:$p" | grep -cE 'AGE-SECRET-KEY-1[0-9A-Z]{58}')
  echo "  $p: key-shaped-matches=$n"
done
echo "  whole tree at PRE: files-with-a-key-shaped-match=$(git -C "$LANE" grep -lE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' "$PRE" | wc -l)"
if grep -qE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' "$F/fake.txt"; then
  echo "  KILL-RULE(key-shaped) on the fixture: FIRES (grep rc=0) -> not vacuous"
else
  echo "  KILL-RULE(key-shaped) on the fixture: passes -> VACUOUS"
fi
if git -C "$LANE" show "$PRE:plans/round-48.md" | grep -qE 'AGE-SECRET-KEY-1[0-9A-Z]{58}'; then
  echo "  KILL-RULE(key-shaped) on the plan: FIRES -> still self-matching"
else
  echo "  KILL-RULE(key-shaped) on the plan: passes (grep rc=1)"
fi
