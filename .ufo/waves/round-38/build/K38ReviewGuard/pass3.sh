#!/usr/bin/env bash
# Pass 3: fix case (a) export bug and case (b) no-op attack. Scratch-only writes.
set -u
S=/fast/scratch/hyaku/kagi-r38/K38ReviewGuard
export S TMPDIR=$S HYAKU_SCRATCH=$S
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
G=$S/ext/corpus/laneguard.sh
mk() { rm -rf "$S/case-$1"; git clone --shared -q "$LANE" "$S/case-$1" || { echo "CASE_$1 SETUP clone-fail"; return 97; }; }

mk modes >/dev/null 2>&1
echo "MODES: $(git -C $S/case-modes ls-files -s corpus/laneguard.sh plans/round-38-c2.sh | tr '\n' ';')"
echo "CASE_B_POST status: [$(git -C $S/case-b --no-optional-locks status --porcelain=v1 | tr '\n' '|')]"

# (a retry) tracked content edit SUCCESSFULLY restored before exit
mk a2
out=$(bash "$G" run -- "$S/case-a2" -- bash -c "cp corpus/laneguard.sh $S/a2.bak; printf tamper >> corpus/laneguard.sh; cp $S/a2.bak corpus/laneguard.sh"); rc=$?
echo "=== CASE_A2 rc=$rc"; printf '%s\n' "$out"
echo "CASE_A2 restored-ok: $(cmp -s "$S/case-a2/corpus/laneguard.sh" "$S/case-modes/corpus/laneguard.sh" && echo yes || echo NO)"

# (b retry 1) chmod +x on a tracked file whose blob mode is 100644
mk b2
out=$(bash "$G" run -- "$S/case-b2" -- chmod +x plans/round-38-c2.sh 2>&1); rc=$?
echo "=== CASE_B2 rc=$rc"; printf '%s\n' "$out"

# (b retry 2) chmod -x demote of the 100755 guard itself
mk b3
out=$(bash "$G" run -- "$S/case-b3" -- chmod -x corpus/laneguard.sh 2>&1); rc=$?
echo "=== CASE_B3 rc=$rc"; printf '%s\n' "$out"
