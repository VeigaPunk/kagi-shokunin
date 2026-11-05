#!/usr/bin/env bash
# K38ReviewGuard attack runner, pass 2. Writes only under $S (scratch). Lane read-only.
set -u
S=/fast/scratch/hyaku/kagi-r38/K38ReviewGuard
export TMPDIR=$S HYAKU_SCRATCH=$S LANEGUARD_SCRATCH=$S
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
G=$S/ext/corpus/laneguard.sh

mk() { rm -rf "$S/case-$1"; git clone --shared -q "$LANE" "$S/case-$1" || { echo "CASE_$1 SETUP clone-fail"; return 97; }; }
top() { git -C "$S/case-$1" rev-parse --show-toplevel; }

run_case() { # accepted grammar: run -- LANE -- CMD...
  local n=$1; shift
  local out rc
  out=$(bash "$G" run -- "$S/case-$n" -- "$@" 2>&1); rc=$?
  echo "=== CASE_${n^^} rc=$rc"
  printf '%s\n' "$out"
}

idx_line() { echo "CASE_${1^^} index-$2=$(sha256sum "$S/case-$1/.git/index" | cut -d' ' -f1)"; }

# DOCUMENTED-GRAMMAR probe: header says `run LANE -- CMD`; show it exits 2 usage.
mk dg
out=$(bash "$G" run "$S/case-dg" -- true 2>&1); rc=$?
echo "=== CASE_DOCKET(DOCUMENTED GRAMMAR run LANE -- CMD) rc=$rc"; printf '%s\n' "$out"

# (a) tracked content edit restored before exit
mk a
run_case a bash -c 'cp corpus/laneguard.sh "$S/a.bak"; printf tamper >> corpus/laneguard.sh; cp "$S/a.bak" corpus/laneguard.sh'

# (b) chmod +x on a tracked file, left in place
mk b
run_case b chmod +x corpus/laneguard.sh

# (c) empty directory
mk c
run_case c mkdir emptydir

# (d) file created then deleted within the run
mk d
run_case d bash -c 'echo transient > new-tmp.txt; rm new-tmp.txt'

# (e) write to an ignored file (.gitignore entry added OUTSIDE the guarded run)
mk e
printf 'ignored-dir/\n' >> "$S/case-e/.gitignore"
echo "CASE_E gitignore-tracked: $(git -C "$S/case-e" ls-files --error-unmatch .gitignore 2>/dev/null || echo UNTRACKED)"
echo "CASE_E check-ignore: $(git -C "$S/case-e" check-ignore -v ignored-dir/f.txt || echo NOT-IGNORED)"
run_case e bash -c 'mkdir -p ignored-dir; echo x > ignored-dir/f.txt'
echo "CASE_E file-after: $(cat "$S/case-e/ignored-dir/f.txt" 2>/dev/null || echo ABSENT)"

# (f) .git/config change
mk f
run_case f git config laneguard.test attack
echo "CASE_F config-after: $(git -C "$S/case-f" config laneguard.test || echo UNSET)"

# (g) empty commit (HEAD sha change)
mk g
echo "CASE_G toplevel: $(top g)"
run_case g git -c user.name=x -c user.email=x@invalid commit --allow-empty -q -m attack

# (h) index-only change (stage a modified tracked file)
mk h
echo "CASE_H toplevel: $(top h)"
run_case h bash -c 'echo x >> corpus/laneguard.sh; git add corpus/laneguard.sh'

# (i) no-op touch of a tracked file + index-write check
mk i
idx_line i before
run_case i touch corpus/laneguard.sh
idx_line i after

# (j) clean no-op run + index-write check
mk j
idx_line j before
run_case j true
idx_line j after

# (k) EXTRA: content drift in a PRE-EXISTING untracked file
mk k
echo seed > "$S/case-k/u.txt"
echo "CASE_K status-before: $(git -C "$S/case-k" --no-optional-locks status --porcelain=v1 --untracked-files=all | tr '\n' '|')"
run_case k bash -c 'echo drift >> u.txt'
echo "CASE_K status-after: $(git -C "$S/case-k" --no-optional-locks status --porcelain=v1 --untracked-files=all | tr '\n' '|')"
echo "CASE_K content-after: $(cat "$S/case-k/u.txt")"

# (l) EXTRA: branch creation (ref move without HEAD sha change)
mk l
echo "CASE_L toplevel: $(top l)"
run_case l git checkout -q -b attack-branch
echo "CASE_L branch-after: $(git -C "$S/case-l" rev-parse --abbrev-ref HEAD)"

# (m) EXTRA: tag creation (git-metadata write outside snapshot)
mk m
run_case m git tag attack-tag
echo "CASE_M tag-after: $(git -C "$S/case-m" tag -l attack-tag)"

# Calibration context at candidate: selftest and do-nothing control
echo "=== SELFTEST"
bash "$G" --selftest; echo "SELFTEST rc=$?"
echo "=== SELFTEST-NO-MUTATE"
bash "$G" --selftest --no-mutate; echo "NO-MUTATE rc=$?"
