# R60ScoutRouted — independent re-derivation of every number `plans/round-60.md` §C1 compares (items I1–I7)

Lane: kagi-shokunin. BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2` (round-59 verifier spot-check tip).
Plan under test: `plans/round-60.md` (frozen predeclaration commit `cd631737`; §A2 seat-count amendment present
in the working tree, uncommitted at the time of reading — seat count only, no predicate/item/target/POP/kill change).

Method: the BASE tree was materialised read-only into the seat scratch
(`/fast/scratch/hyaku/kagi-r60/R60ScoutRouted/tree`, `git archive a677c78e | tar -x`) and every number was
re-derived there with the exact command shown. No lane file was edited; no git/jj mutation was run anywhere.
Every "plan's number" cell quotes the number the plan states for that item.

## Re-derivation table

| id | plan's number | re-derived number | command (run in the BASE tree) | agree? |
|---|---|---|---|---|
| I1 | 14 results, 0 empty (`LOG.md:1965` ends `dead seats __DEAD__`); item: R=14, D=0 | 14 results, 0 empty outputs; `__DEAD__` on line 1965, which is the last of LOG.md's 1965 lines | `grep -n '__DEAD__' LOG.md` → `1965:- Wave \`kagi-r59-w1\` … dead seats __DEAD__.` (1 match, file has 1965 lines)<br>`python3 -c "…json.load(.ufo/waves/round-59/w1-results.json)…" ` → `seats=14`, `len(results)=14`, `empty_outputs=0` (every `output` field non-empty, 3505–9552 chars) | **agree** |
| I2 | 33 cases (`C1_CHECK_SELFTEST: PASS (33 cases)`); R31 states a 32-case receipt | last (and only) `C1_CHECK_SELFTEST: PASS` line in the receipt = `PASS (33 cases)`; R31's own text reads `PASS (32 cases)` | `grep -n 'C1_CHECK_SELFTEST: PASS' .ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt` → `4:C1_CHECK_SELFTEST: PASS (33 cases)`<br>`grep -n 'R31' corpus/lessons/round-59.md` → `206:\| R31 \| … its committed receipt reads \`C1_CHECK_SELFTEST: PASS (32 cases)\` \| …` | **agree** |
| I3 | derived duplicate set = `R20`, `R21`, `R22`, each twice (max occurrence 2; 3 ids duplicated; 34 id rows, 31 distinct ids) | identical | `awk '/^## Routed dispositions/{f=1;next} f&&/^## /{f=0} f&&/^\|/{n=split($0,a,"\|"); gsub(/^[ \t]+\|[ \t]+$/,"",a[2]); if(a[2] ~ /^R[0-9]+$/) print a[2]}' corpus/lessons/round-59.md \| sort \| uniq -c` → `2 R20`, `2 R21`, `2 R22` (every other id 1); rows at lines 192/195 (R20), 193/196 (R21), 194/197 (R22) | **agree** |
| I4 | 20 (`grep -cE '^CONTROL ' …/controls-prefreeze.txt` = 20); SCORECARD states `(21 controls;` at `SCORECARD.md:1971` | 20 `CONTROL ` lines; the literal `(21 controls;` is on SCORECARD.md line **1971** | `grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt` → `20` (breakdown 4 K + 8 C1-F + 8 C2-F, one each; last line `CONTROLS: match=20 mismatch=0`)<br>`grep -n '(21 controls' SCORECARD.md` → `1971:(21 controls; K1-BASE, K1-BASE-GUARD, K2-BASE, K1-REF plus C1-F1..F8 and C2-F1..F8)` | **agree** |
| I5 | three paths named `release-clock` / `doc-audit` / `scope` with last lines `RELEASE_CLOCK:` / `DOC_AUDIT:` / `SCOPE`, plus `never written`; evidence sentence cites `SCORECARD.md:1976` and "six files" under `.ufo/waves/round-59/final/` | the round-59 receipt set under `final/` is exactly six files, none a release-clock / DOC_AUDIT / SCOPE receipt (so `release-clock-candidate.txt` is indeed absent); but the citing line is **1975**, not 1976 | `ls .ufo/waves/round-59/final/` → `c1-candidate-tree.txt c1-landed.txt c2-candidate-tree.txt c2-landed.txt citation-gate-r59.txt supplement-receipt.txt` (6)<br>`grep -n '\.ufo/waves/round-59/final/' SCORECARD.md` → lines **1971, 1972, 1975**; `sed -n '1975p' SCORECARD.md` contains `release-clock-candidate.txt`; `sed -n '1976p'` is the `adjacency` row and does **not** | **partial — one wrong number** (line 1976 → 1975). The "six files" count and the file-absence claim agree. |
| I6 | `160caf750dcf15892b78ec066e66bc605ba57a5c` (40 hex) | identical hash, 40 hex chars, carried by the `c1-driver: measured=revision` line of `.ufo/waves/round-59/final/c1-landed.txt` | `grep -n 'c1-driver: measured=revision' .ufo/waves/round-59/final/c1-landed.txt` → `c1-driver: measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c (git archive)` (length 40; `git cat-file -e 160caf75…^{commit}` ⇒ commit exists) | **agree** on the hash. Separately: the "Before → after" table that names `75165a07` is the **fleet** report `.ufo/reports/round-59/kagi.md` (lines 102–103, column *measured commit*); `grep -c 75165a07 SCORECARD.md` → **0** and `grep -c 75165a07 LOG.md` → **0**. See Ambiguity A3. |
| I7 | `SKILL.md:847` transit row; selftest cell currently `none — its own five shims …`; `--selftest` must exit 0 printing `TRANSIT_SELFTEST: PASS (cases=N)`, N ≥ 6 | row is at line **847** and its selftest cell reads exactly `none — its own five shims and the clean-room leg are the falsifiers, run by \`plans/round-59-c2.sh\`` (em dash U+2014); the trial at BASE does **not** accept `--selftest` — it prints a usage line and exits **rc=2** (rc=2 here is the script's usage error, not the plan's SETUP code) | `grep -n 'openbao-transit-trial.sh' SKILL.md` → `847:`<br>`sed -n '847p' SKILL.md \| cut -d'\|' -f6` → ` none — its own five shims and the clean-room leg are the falsifiers, run by \`plans/round-59-c2.sh\``<br>`bash corpus/openbao-transit-trial.sh --selftest; echo rc=$?` → `usage: corpus/openbao-transit-trial.sh [--work DIR]`, `rc=2`<br>`grep -c selftest corpus/openbao-transit-trial.sh` → 0 | **agree** (BASE state matches the plan's "unresolved" premise; the rc=2 is recorded as an observation only, not a plan defect) |

## BASE-census cross-check (the plan's K2 expectation `value=7 population=7`)

Every one of the seven conditions is **unresolved** at BASE, so the plan's declared BASE reading is consistent
with the tree (the checker itself does not exist at BASE — `plans/round-60-c1-check.py` is absent — so this is a
byte-level reading of the conditions, not an executed checker):

| item | BASE evidence that the condition does not hold |
|---|---|
| I1 | `grep -c '^## Round 59 — correction' LOG.md` → 0 (LOG.md ends at line 1965 with the `__DEAD__` line) |
| I2 | `grep -c 'supersedes R31' corpus/lessons/round-59.md` → 0 (the file's only "supersede" token is "supersedes it." at line 195) |
| I3 | `corpus/lessons/round-60.md` does not exist (`ls` → No such file) |
| I4 | `grep -c 'supersedes SCORECARD.md:1971' SCORECARD.md` → 0 |
| I5 | `grep -c 'supersedes the round-59 gate-evidence pointer' SCORECARD.md` → 0; `grep -c 'round-60/final' SCORECARD.md` → 0 |
| I6 | `grep -c 'c1-landed' SCORECARD.md` → 0 (SCORECARD cites `c1-candidate-tree.txt`, never `c1-landed.txt`) |
| I7 | trial has no `--selftest` (usage rc=2) and the SKILL.md row's selftest cell has no `--selftest` |

⇒ 7/7 unresolved, i.e. the plan's declared `value=7 population=7` is derivable from the BASE bytes.

## BASE commit stated by the plan

`plans/round-60.md` states BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`, "round-59 verifier spot-check tip,
`round-59 verifier spot-check (integrator, hyaku): non-author admit/reject`, 2026-11-07 15:00:52 -03".
Re-derived: `git show -s --format='%H%n%s%n%cI' a677c78e` ⇒ same hash, subject
`round-59 verifier spot-check (integrator, hyaku): non-author admit/reject`, committer date
`2026-11-07T15:00:52-03:00`. `git log --oneline -3` shows `cd631737` (the round-60 plan commit) directly on top of
`a677c78e`, and `git merge-base --is-ancestor a677c78e HEAD` ⇒ true. **The plan's BASE is correct.**

## Ambiguities

**A1 — I1's guard names a field the item's condition never asks for (blocking for the challenge leg).**
Item condition: "the block contains a line matching `results=<R> dead=<D>` where R = … and D = …".
Guard: "on a copy of the measured tree whose only delta is the digit in the I1 correction line's `dead seats=<n>`
field changed from 0 to 1". `dead seats=<n>` is not a substring of `results=<R> dead=<D>`, so a checker reading
bytes alone cannot know which literal to flip — and if the fix writes only `results=14 dead=0`, the guard's
mutation target does not exist. Two names for one datum.

**A2 — I1's "empty/absent final output" is not pinned to a key.**
Each entry of `.ufo/waves/round-59/w1-results.json` has keys `name`, `agent`, `output`, `note`. `output` is
non-empty for all 14 (3505–9552 chars) but `note` is `null` for all 14. Read against `output` ⇒ D = 0 (the plan's
figure); read against `note` ⇒ D = 14. The plan states "(14 and 0 at BASE)" without naming the key; the file also
carries a redundant `seats: 14`. A checker must be told to read `output`.

**A3 — I6's "after the round-59 line containing `75165a07`" has no referent in SCORECARD.md.**
The condition says: "`SCORECARD.md` carries, after the round-59 line containing `75165a07`, a line naming
`c1-landed.txt` that states the 40-hex revision … as `measured=revision <hash>`". At BASE `SCORECARD.md` contains
zero occurrences of `75165a07` (LOG.md likewise). The line that names `75165a07` as the *measured commit* is the
fleet report's Before → after table (`.ufo/reports/round-59/kagi.md:102-103`) — outside the lane's write scope —
and the only lane-side occurrence is `corpus/lessons/round-59-verifier-spotcheck.md:188` (the D6 row). So the
anchor can only be satisfied if the appended correction itself carries `75165a07` and the `c1-landed.txt` line
follows it; the condition as written reads as if a pre-existing "round-59 line" exists. Reported, not amended.

**A4 — I5's `never written` collides with its own existence clause.**
I5 requires one SCORECARD line that (a) names three paths under `.ufo/waves/round-60/final/` (file names
containing `release-clock`, `doc-audit`, `scope`), (b) each named file exists with a last non-empty line starting
`RELEASE_CLOCK:` / `DOC_AUDIT:` / `SCOPE`, and (c) the same line states `never written`. A bytes-only checker
cannot tell whether "never written" qualifies the round-59 receipts (the D5 defect) or the round-60 files it
just required to exist. The two readings are mutually exclusive for a literal check.

**A5 — I5's evidence line number is wrong: 1976 should be 1975.**
The plan writes "`SCORECARD.md:1976` cites `.ufo/waves/round-59/final/release-clock-candidate.txt`". The citation
is on line **1975** (the `freshness` row); line 1976 is the `adjacency` row. (The source spot-check lesson also
says 1975.) Every other line-number citation in the plan checks out: `LOG.md:1965`, `SCORECARD.md:1971`,
`SKILL.md:847` are all correct — note the spot-check lesson said `SKILL.md:846` for the transit row, and the
plan's 847 is the correct one.

**A6 — I3's id regex is unanchored and the plan gives no extraction command.**
"the id column of its `## Routed dispositions` table (cells matching `R[0-9]+`) holds at least 3 ids and no id
twice (derived: max occurrence = 1)". In the round-59 lesson the *finding* column carries seat names such as
`R59RevContext`, `R59ScoutSources`; unanchored, `R[0-9]+` matches the `R59` inside them — the whole-table census
yields `26 R59`. "max occurrence = 1" is only true if the checker restricts to the id column. Unlike I4, the plan
states no command for the extraction, so "readable from bytes alone" is not guaranteed. A round-60 lesson whose
routed table cites seat names (`R60…`) inherits the same hazard.

**A7 — I3's condition reads the *round-60* lesson while the defect evidence is in the round-59 lesson.**
The plan's D3 narrative cites the round-59 table; the item condition tests `corpus/lessons/round-60.md`. That is
a deliberate forward move, but combined with A6 the "no id twice" test applies to a table the lane writes from
scratch, not to the defect's own table — the defect's own table is not re-checkable after the fix.

**A8 — scope gap in §A2: three items have no owning seat in the listed write sets.**
§A2 enumerates six disjoint write sets: trial, C1 checker, C2 counter, record repairs **I1/I2/I4**, transit
selftest I7, controls battery. **I3, I5 and I6 have no seat.** I3 needs a new `corpus/lessons/round-60.md` with a
`## Routed dispositions` table (≥3 ids, no duplicate) and a line naming `R20`, `R21`, `R22` and the word
`duplicate`; I5 needs three receipt files under `.ufo/waves/round-60/final/` (none of which is in the plan's
"Instruments created by this round" list) plus the SCORECARD line; I6 needs a SCORECARD line after the
`75165a07` anchor. Under the plan's own kill rule K2/K1, an item no seat writes stays unresolved, so the C1 target
of 0 is unreachable as the wave is composed. This is a composition defect, not a predicate defect — reported, not
amended.

**A9 — I7's `N >= 6` is a plan-chosen constant, not a tree-derived one.**
The transit trial has five shims plus a clean-room leg; `N >= 6` is a bare threshold with no derivation command,
unlike the other six items which all derive their compared number from the tree or a named revision. It is
legitimate as a floor, but a checker cannot derive it, and the plan's own "no constant in the checker carries a
fact the measured tree asserts" clause is stretched here (the count 6 is not asserted by the tree).

## Tools

No tool was installed or upgraded for this seat; nothing to record under the tooling directive
(/home/vgpnk/.omp/agent/RULES.md, read at the start of the seat). All work was read-only: `git show`/`git log`/
`git merge-base`/`git cat-file`/`git archive` on the lane, and `bash`/`awk`/`grep`/`sed`/`python3` inside the
seat scratch copy of the BASE tree. The scratch tree was deleted before this report was written.

SEAT-STATUS: complete
