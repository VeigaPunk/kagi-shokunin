#!/usr/bin/env bash
# K47Sentinel refusal-boundary / scope scan (round 47, attempt 1). Read-only.
# Every command below reads; nothing under the lane is written except this receipt.
# usage: bash scan.sh > scan.txt 2>&1
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
B=$LANE/.ufo/waves/round-47/build
P="$LANE/plans/round-47.md $LANE/plans/round-47-c1.sh $LANE/plans/round-47-c2.sh $LANE/plans/round-47-controls.py"
echo "# K47Sentinel scan $(date -u +%FT%TZ)  lane=$LANE  HEAD=$(git -C "$LANE" rev-parse HEAD)"

echo
echo "## 1 instrument freeze (sha256 -c against the pre-freeze receipt)"
(cd "$LANE" && sha256sum -c .ufo/waves/round-47/controls/instrument-sha256.txt)

echo
echo "## 2 secret-shaped values in the round-47 instruments"
grep -nIE 'ghp_[A-Za-z0-9]{20}|gho_[A-Za-z0-9]{20}|ghs_[A-Za-z0-9]{20}|github_pat_|sk-[A-Za-z0-9]{20}|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9]|glpat-[A-Za-z0-9]|BEGIN [A-Z ]*PRIVATE KEY|op://[A-Za-z0-9_-]+/' $P
echo "grep_exit=$? (1 = no match)"

echo
echo "## 3 secret-shaped values in the build outputs (all seats), captures included"
grep -rnIE 'ghp_[A-Za-z0-9]{20}|gho_[A-Za-z0-9]{20}|ghs_[A-Za-z0-9]{20}|github_pat_|sk-[A-Za-z0-9]{20}|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9]|glpat-[A-Za-z0-9]|BEGIN [A-Z ]*PRIVATE KEY' "$B" --exclude-dir=K47Sentinel-receipts --exclude=K47Sentinel.md
echo "grep_exit=$? (1 = no match)"

echo
echo "## 4 literal op:// occurrences anywhere in build (prose mentions included)"
grep -rn 'op://' "$B" --exclude-dir=K47Sentinel-receipts --exclude=K47Sentinel.md | cut -c1-160
echo "grep_exit=$? (1 = no match)"

echo
echo "## 5 hardcoded /tmp in the instruments (prompt §7 item 4 class)"
grep -nE '(^|[^A-Za-z0-9_])/tmp/' $P
echo "grep_exit=$? (1 = no match)"

echo
echo "## 6 hardcoded /tmp in build-carried tools (scripts only, not captured docs)"
# NOTE: this host's grep (pi-uu-grep) drops --include when --exclude=<file> is also given,
# so the file exclusion is done by the .sh/.py include filter alone (K47Sentinel.md is .md).
grep -rn '/tmp/' "$B" --exclude-dir=K47Sentinel-receipts --include='*.sh' --include='*.py'
echo "grep_exit=$? (1 = no match)"

echo
echo "## 7 S099 capture credential grep (assignment-mandated pattern)"
grep -nE 'ghp_|github_pat_|sk-|AKIA|op://|BEGIN [A-Z ]*PRIVATE KEY' "$B/K47ExecC1/S099.body"
echo "grep_exit=$? (hits here are the substring sk- inside disk-guard.sh)"
sha256sum "$B/K47ExecC1/S099.body" /home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-44.md
git -C /home/vgpnk/Projects/shokunin show 75dd26121698f10cf111120f6cbcd2b2125598f1:.ufo/prompts/kagi-round-44.md | sha256sum

echo
echo "## 8 write targets of the counters and controls (lane-absolute or scratch-only?)"
grep -nE '>|>>|tee |mkdir |rm -rf|cp -a|shutil\.|open\(' "$LANE/plans/round-47-c1.sh" "$LANE/plans/round-47-c2.sh" "$LANE/plans/round-47-controls.py" | grep -v '^\s*#'

echo
echo "## 9 cwd-relative output risk: OUT argument of controls.py is caller-supplied"
grep -n 'outp\|OUT' "$LANE/plans/round-47-controls.py" | head

echo
echo "## 10 lane tracked tree untouched / scope of the untracked additions"
git -C "$LANE" status --porcelain
git -C "$LANE" diff --stat HEAD | tail -3

echo
echo "## 11 captures: symlinks and sizes in the build dir"
find "$B" -path K47Sentinel-receipts -prune -o -name K47Sentinel.md -prune -o -type l -ls
find "$B" -path K47Sentinel-receipts -prune -o -name K47Sentinel.md -prune -o -name '*.body' -printf '%s\t%p\n' | sort -rn | head -20

echo
echo "## 12 site of the leftover scratch dir from a counter run (trap scope)"
ls -la "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47" 2>/dev/null | head -20

echo
echo "SCAN: done"
