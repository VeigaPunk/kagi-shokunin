#!/usr/bin/env bash
# Synthetic histories for round-conformance.py, built in a scratch clone only.
# usage: synth.sh <clone> <rc.py>
set -u
L=$1; RC=$2; C=62a33b1bd15217ed729df2ca40c8a30aba3076c0
G() { git -C "$L" -c user.name=synth -c user.email=synth@invalid -c commit.gpgsign=false "$@"; }
run() { echo "== $1"; python3 -I -B "$RC" "$L" "$2" | grep -v OUTSIDE-PATH; echo "exit=${PIPESTATUS[0]}"; }
fresh() { G checkout -q -f -B "$1" "$C"; }
P28="$L/plans/round-28.md"

# S1 changed frozen command line (line 29) at tip
fresh s1; sed -i '29s|<out.json>|<out.json> --lenient|' "$P28"; G commit -qam s1; run "S1 changed-command" 28

# S2 census committed after plan (round 99)
fresh s2; cp "$P28" "$L/plans/round-99.md"; G add plans/round-99.md; G commit -qm s2-plan
mkdir -p "$L/.ufo/waves/round-99"; echo census > "$L/.ufo/waves/round-99/census-start.txt"
G add .ufo; G commit -qm s2-census; run "S2 census-after-plan" 99

# S3 frozen prose widened (predicate + fixture size), commands untouched
fresh s3; sed -i -e '38s|exits 0 with|exits 0 twice with|' -e '33s|4301|9999|' -e '52s|located anchor|any anchor|' "$P28"
G commit -qam s3; G diff --stat "$C" s3 -- plans; run "S3 frozen-prose-widened" 28

# S4 boundary heading moved up to just after the last command line (59)
fresh s4; sed -i '60i ## Plan corrections (moved)' "$P28"; G commit -qam s4; run "S4 boundary-moved" 28

# S5 command changed then restored (endpoint-only comparison)
fresh s5; sed -i '29s|c1-measure.py|c1-measure-loose.py|' "$P28"; G commit -qam s5-change
G show s5:plans/round-28.md | sed -n 29p; G checkout -q "$C" -- plans/round-28.md; G commit -qam s5-restore; run "S5 change-then-restore" 28

# S6 frozen tool body rewritten (predicate in c1-measure.py), plan untouched
fresh s6; echo '# rewritten predicate' >> "$L/.ufo/waves/round-28/tools/c1-measure.py"; G commit -qam s6; run "S6 tool-body-changed" 28

# S7 code lands in the census commit, before the plan (round 99)
fresh s7; mkdir -p "$L/.ufo/waves/round-99"; echo census > "$L/.ufo/waves/round-99/census-start.txt"
echo '# early code' >> "$L/corpus/release-clock.py"; G add -A; G commit -qm s7-census+code
cp "$P28" "$L/plans/round-99.md"; G add plans; G commit -qm s7-plan; run "S7 code-before-plan-via-census-commit" 99

# S8 placeholder plan (commands only) first; prose + code later (round 99)
fresh s8; mkdir -p "$L/.ufo/waves/round-99"; echo census > "$L/.ufo/waves/round-99/census-start.txt"
grep -E '^    ' "$P28" > "$L/plans/round-99.md"; G add -A; G commit -qm s8-stub
cp "$P28" "$L/plans/round-99.md"; echo '# code' >> "$L/corpus/release-clock.py"; G commit -qam s8-plan+code; run "S8 placeholder-plan" 99

# S9 census content rewritten after plan
fresh s9; echo 'rewritten after plan' > "$L/.ufo/waves/round-28/census-start.txt"; G commit -qam s9; run "S9 census-rewritten" 28

# S10 plan first committed with code on a side branch; identical plan-only commit on mainline; merge
fresh s10m; G checkout -q -B s10side "$C"
mkdir -p "$L/.ufo/waves/round-99"; echo census > "$L/.ufo/waves/round-99/census-start.txt"; G add -A; G commit -qm s10-census
G branch -f s10main; cp "$P28" "$L/plans/round-99.md"; echo '# side code' >> "$L/corpus/release-clock.py"
G add -A; G commit -qm s10-side-plan+code
G checkout -q s10main; GIT_COMMITTER_DATE='2030-01-01T00:00:00Z' GIT_AUTHOR_DATE='2030-01-01T00:00:00Z' true
cp "$P28" "$L/plans/round-99.md"; G add plans; G commit -qm s10-main-plan-only
G merge -q --no-edit -X ours s10side >/dev/null; G log --format='  %h %s' -- plans/round-99.md
G log --all --format='  all: %h %s' -- plans/round-99.md; run "S10 side-branch-plan-with-code" 99
