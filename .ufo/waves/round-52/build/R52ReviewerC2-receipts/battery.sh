#!/usr/bin/env bash
# R52ReviewerC2 adversarial battery for plans/round-52-c2.sh (review only; reads the frozen counter,
# never edits it). Each case is a BASE-archive fixture under $S/cases/<name>.
set -u
R=/home/vgpnk/Projects/shokunin/kagi-shokunin
S=/fast/scratch/hyaku/kagi-r52/R52ReviewerC2
BASE=1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b
ENTRY=corpus/knowledge/vault-openbao-token-lease-lifecycle.md
LESSON=corpus/lessons/round-51.md
CORR="$R/.ufo/waves/round-52/controls/fixtures/ref/corrections"
ECORR=$(sed -n '2p' "$CORR/entry.txt")
LCORR=$(sed -n '2p' "$CORR/lesson.txt")
mkdir -p "$S/cases"

mk() { local d="$S/cases/$1"; rm -rf "$d"; mkdir -p "$d"; git -C "$R" archive "$BASE" | tar -x -C "$d" || return 1; printf '%s' "$d"; }
run() { echo "### CASE $1"; bash "$R/plans/round-52-c2.sh" --tree "$2"; echo "rc=$?"; }

echo "fixture correction lengths: entry=${#ECORR} lesson=${#LCORR}"

# B1: both corrections wrapped as leading+trailing same-line comments, no space after the opening comment
d=$(mk b1-twocomments-nospace)
printf '%s\n' "<!-- n -->${ECORR}<!-- t -->" >> "$d/$ENTRY"
printf '%s\n' "<!-- n -->${LCORR}<!-- t -->" >> "$d/$LESSON"
run b1-twocomments-nospace "$d"

# B2: same but one space after the opening comment
d=$(mk b2-twocomments-space)
printf '%s\n' "<!-- n --> ${ECORR}<!-- t -->" >> "$d/$ENTRY"
printf '%s\n' "<!-- n --> ${LCORR}<!-- t -->" >> "$d/$LESSON"
run b2-twocomments-space "$d"

# B3: corrections inside a multi-line HTML comment
d=$(mk b3-multiline-comment)
{ printf '%s\n' '<!--'; printf '%s\n' "$ECORR"; printf '%s\n' '-->'; } >> "$d/$ENTRY"
{ printf '%s\n' '<!--'; printf '%s\n' "$LCORR"; printf '%s\n' '-->'; } >> "$d/$LESSON"
run b3-multiline-comment "$d"

# B4: a multi-line comment that closes, then a real correction after it
d=$(mk b4-multiline-close)
{ printf '%s\n' '<!--'; printf '%s\n' 'hidden'; printf '%s\n' '-->'; printf '%s\n' "$ECORR"; } >> "$d/$ENTRY"
{ printf '%s\n' '<!--'; printf '%s\n' 'hidden'; printf '%s\n' '-->'; printf '%s\n' "$LCORR"; } >> "$d/$LESSON"
run b4-multiline-close "$d"

# B5: entry correction correct; lesson correction pointer :29 (prefix of :22? no: 29 vs 22) -> lesson uncorrected
d=$(mk b5-pointer-29)
printf '%s\n' "$ECORR" >> "$d/$ENTRY"
printf '%s\n' "${LCORR/round-51.md:22/round-51.md:29}" >> "$d/$LESSON"
run b5-pointer-29 "$d"

# B6: lesson correction pointer :220
d=$(mk b6-pointer-220)
printf '%s\n' "$ECORR" >> "$d/$ENTRY"
printf '%s\n' "${LCORR/round-51.md:22/round-51.md:220}" >> "$d/$LESSON"
run b6-pointer-220 "$d"

# B7: synthetic untracked file, assertion at line 29, correction naming :292 (prefix collision guard)
d=$(mk b7-prefix-collision)
for i in $(seq 1 28); do echo "line $i"; done > "$d/corpus/knowledge/prefix-test.md"
echo 'The rewrap API page is misleading about creation paths.' >> "$d/corpus/knowledge/prefix-test.md"
printf 'Correction (round 52, D1) to prefix-test.md:292: helper-origin rewrap reads `sys/wrapping/wrap` and KV-origin rewrap reads `secret/data/<path>`.\n' >> "$d/corpus/knowledge/prefix-test.md"
echo "assertion at line: $(grep -n 'is misleading' "$d/corpus/knowledge/prefix-test.md" | cut -d: -f1)"
run b7-prefix-collision "$d"

# B8: same synthetic file, correction naming the right :29 -> corrected
d=$(mk b8-prefix-correct)
for i in $(seq 1 28); do echo "line $i"; done > "$d/corpus/knowledge/prefix-test.md"
echo 'The rewrap API page is misleading about creation paths.' >> "$d/corpus/knowledge/prefix-test.md"
printf 'Correction (round 52, D1) to prefix-test.md:29: helper-origin rewrap reads `sys/wrapping/wrap` and KV-origin rewrap reads `secret/data/<path>`.\n' >> "$d/corpus/knowledge/prefix-test.md"
run b8-prefix-correct "$d"

# B9: wrong file, same basename (root SCORECARD.md assertion; correction names corpus/fixtures/.../SCORECARD.md:L)
d=$(mk b9-wrongfile-basename)
SC="$d/SCORECARD.md"
echo 'Appendix: the rewrap page sample response is misleading.' >> "$SC"
L=$(grep -n 'is misleading' "$SC" | cut -d: -f1)
echo "SCORECARD assertion line=$L"
printf 'Correction (round 52, D1) to corpus/fixtures/cells-hermetic/SCORECARD.md:%s: helper-origin rewrap reads `sys/wrapping/wrap` and KV-origin rewrap reads `secret/data/<path>`.\n' "$L" >> "$SC"
run b9-wrongfile-basename "$d"

# B10: same, correction names a nonexistent path with the same basename
d=$(mk b10-nonexistent-basename)
SC="$d/SCORECARD.md"
echo 'Appendix: the rewrap page sample response is misleading.' >> "$SC"
L=$(grep -n 'is misleading' "$SC" | cut -d: -f1)
echo "SCORECARD assertion line=$L"
printf 'Correction (round 52, D1) to zzz/nowhere/SCORECARD.md:%s: helper-origin rewrap reads `sys/wrapping/wrap` and KV-origin rewrap reads `secret/data/<path>`.\n' "$L" >> "$SC"
run b10-nonexistent-basename "$d"

# B11: commented-out correction-shaped assertion line
d=$(mk b11-comment-assertion)
{ printf '%s\n' '<!--'; printf '%s\n' '- Correction (round 52, D1) to vault-openbao-token-lease-lifecycle.md:292: the rewrap sample is misleading'; printf '%s\n' '-->'; } >> "$d/$ENTRY"
run b11-comment-assertion "$d"

# B12: corrections inside fenced code blocks only
d=$(mk b12-fence)
{ printf '%s\n' '```'; printf '%s\n' "$ECORR"; printf '%s\n' '```'; } >> "$d/$ENTRY"
{ printf '%s\n' '```'; printf '%s\n' "$LCORR"; printf '%s\n' '```'; } >> "$d/$LESSON"
run b12-fence "$d"

# B13: pointer only inside a same-line HTML comment; literals visible
d=$(mk b13-pointer-in-comment)
printf '%s\n' "$ECORR" | sed 's#\(vault-openbao-token-lease-lifecycle\.md:292\)#<!--\1-->#' >> "$d/$ENTRY"
printf '%s\n' "$LCORR" >> "$d/$LESSON"
run b13-pointer-in-comment "$d"

# B14: untracked md file with an assertion included by --tree (scope sentence says tracked)
d=$(mk b14-untracked)
printf '%s\n' 'The rewrap page is wrong about creation paths.' > "$d/corpus/untracked-notes.md"
run b14-untracked "$d"

# B15: GUARD - truncate the last line of the lesson
d=$(mk b15-guard-truncate)
printf '%s\n' "$ECORR" >> "$d/$ENTRY"
printf '%s\n' "$LCORR" >> "$d/$LESSON"
sed -i '$d' "$d/$LESSON"
run b15-guard-truncate "$d"

# B16: GUARD - delete the entry file
d=$(mk b16-guard-missing)
rm -f "$d/$ENTRY"
run b16-guard-missing "$d"

# B17: GUARD - rewrite a BASE scoped file that held no assertion (should stay guard=1)
d=$(mk b17-guard-nonassertion)
printf 'rewritten without assertions\n' > "$d/corpus/README.md"
run b17-guard-nonassertion "$d"

echo "BATTERY DONE"
