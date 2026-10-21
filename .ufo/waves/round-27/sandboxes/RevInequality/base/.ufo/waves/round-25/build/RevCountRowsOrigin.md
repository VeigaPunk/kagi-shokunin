# RevCountRowsOrigin — ledger count rows, why they pin values and not prose, and every stale doc number

Seat `KagiR25.RevCountRowsOrigin-2` (leaf, read-only). Base = lane HEAD `4587c61a348e4528717404a68912c373f3ef4d03`. Sandbox: `/fast/scratch/kagi-r25/RevCountRowsOrigin/lane` (clone at base). Method: `git log -S`, `git show <rev>:path`, `git blame`, per-commit time series, one sandbox experiment. Tools installed or updated: none.

## 1. The convention, reverse-engineered
- Row = `id command expect exit timeout note`. PASS = exit equals the row's exit field AND the `expect` ERE matches the last non-empty output line (`corpus/claim-ledger.tsv:1-3`; `SKILL.md:246-251`). The header's "fifth column" (`:3`) is wrong: exit is the fourth field on every row. The gate reads documents only for path/ID tokens and structure, never for numeric statements.
- Count row = a command that recounts a live artifact, plus an anchored integer, e.g. `R11-10  grep -cv '^#' corpus/state-shape.tsv  ^22$`. 13 of 61 rows are `grep -c` count rows; the `(N cases)` rows pin the gate's own printed count.
- Origin `301b9ec` (2026-09-28, round 11). The comment at `corpus/claim-ledger.tsv:11-14` is unchanged since (`git blame -L 11,14`: all `301b9ec`): "Count rows (R11-10/11, and the `(N cases)` expectations) exist because three committed docs carried stale numbers for these same quantities (README said 20 state-shape rows and a 14-case census selftest; PROVINCE said 21 rows) — a number a doc cites is a claim, so it belongs here."
- The round-11 lesson's only rule for doc numbers is procedural (`corpus/lessons/round-11.md:143-145`, `301b9ec`): "numbers in docs are quoted **with the stamped revision they were measured at**, and the final measure happens after the last edit." No gate checks it.

## 2. Why live values are pinned and doc statements are not
1. **Input type.** The gate's only evidence is command output. No row's command reads README, PROVINCE, SKILL or LOG: `grep -nE '(README|PROVINCE|SKILL|LOG)\.md' corpus/claim-ledger.tsv` matches only R15-01, in its note. Doc-reading rows count structure (R13-01 `grep -c '^## Round ' SCORECARD.md`). A sentence "20 rows" has no command and therefore no verdict.
2. **Three copies, one enforced edge.** Data ↔ `expect` is enforced: change the data and the row goes red, forcing a migration. `expect` ↔ prose is enforced by nothing. QM14 (`corpus/QUALITY.md:73`) journals only "revision-pin and expectation changes". QA6 ("A count carries its command", `QUALITY.md:25`) is an admission criterion for knowledge entries (`QUALITY.md:12-16`), not for SKILL/README/PROVINCE. The 15 bounds in `corpus/knowledge/claim-ledger.md:308-365` name bare filenames as unchecked (bound 6) and never mention prose numbers.
3. **Rows follow incidents, not numbers.** The only recorded stale-doc origins are R11-10 (its note: "README/PROVINCE cited 20/21 before round 11") and R11-03 (14→16, per LOG.md:283-285). R11-11 (35 rows) repaired nothing: every doc already said 35 at `03477c0` (PROVINCE.md:37, SCORECARD.md:49, corpus/README.md:38, LOG.md:222).
4. **Experiment** (`env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`; verdict emulated as exit + ERE on last line):
   - A, doc only: `corpus/README.md:42` "22 rows" → "20 rows". R11-10 command → stdout `22`, exit 0 → PASS. The prose is wrong and no row can see it.
   - B, data only: `CUT 48` removes one data row (`daybreak-blue-access.json keys`). R11-10 command → stdout `21`, exit 0 → `grep -qE '^22$'` fails → FAIL.
5. **Count ≠ membership.** A round-12 mutation showed a blank line "passes a `grep -c` count while `verify` loses a row" (`corpus/lessons/round-12.md:107`, `4b8c018`). Identity rows arrived in round 24 (`a3eb6c7`, R24-03..R24-16; QM18, `QUALITY.md:100`): "a blank line traded for a row kept R11-10 green at base".
6. **Cost is asymmetric.** Eight pinned-count rows were hand re-pinned 39 times (R11-09 7, R12-03 10, R13-01 9, R13-02 5, R21-03 3, R21-04 3, R12-02 1, R24-01 1; `git show <rev>:corpus/claim-ledger.tsv` per commit). Prose copies of the same quantities had no such force and were edited only when a sweep remembered them.

## 3. Every round with a stale doc number (commit · quote · fix)
- **R4→R8, line ref.** "four corpus files carried L17 since round 4" (`corpus/lessons/round-8.md:50-52`); `MODEL_ENDPOINT` is L19. Corrected in `e0a04d8`.
- **R9→R16, locator.** `corpus/README.md:76` cites `kake-shokunin/SKILL.md:104-107` (introduced `e64e81b`); "the overlap table's kake citation is stale" (`round-16.md:15`). Fixed `8a6ec16` (now `:161`).
- **R9→R15, SCORECARD.md:16.** `e64e81b` wrote "a 15-item hygiene checklist"; `ea77bf0` held 13. Audit `ad694a2`: "**major — four falsified counts in the committed SCORECARD depth cell.**" Round-9 verdict `baec94f`: "D-65 remains open: SCORECARD L16 retains the four falsified depth counts". Fixed `587fda0` (`round-15.md:16`).
- **R10→R15, "12 checklist items"** (SCORECARD cells; first at `03477c0`): "wrong at every revision they appear in" (LOG.md:514-516, `587fda0`).
- **R10, born stale** (`03477c0` created `state-shape.tsv` with 22 data rows in the same commit): README:39 "20 rows"; README:128 "14-case selftest" (census proves 16, PROVINCE.md:37); PROVINCE.md:37 "(21 rows)"; SCORECARD.md:49 "21 runtime shape pins". [INFERENCE] These are the pre-critic count: 22 minus the two `keys` rows named in the round-10 cheap-gain row (`corpus/lessons/round-10.md:69`). Fixed: README/PROVINCE in `301b9ec`; SCORECARD in `4b8c018` (`round-13.md:61-63`). Still uncorrected: `round-10.md:11` "(20 rows)".
- **R11, `301b9ec`.** LOG.md:283-285: "**three stale numbers** in my own docs … all fixed and now pinned by ledger rows `R11-03`/`R11-10`/`R11-11`".
- **R12, `4b8c018`** (round-12 work landed inside the round-13 commit; `round-13.md:10-11`): "16 stale rows in live docs that quote superseded counts … all 16 corrected in place" (`round-12.md:116`). The same sweep is tallied as "four stale numbers" (SCORECARD.md:94) and as a five-item list (`round-12.md:70-73`). The record does not reconcile the three tallies.
- **R14, `2486643`.** Landing-invalidated counts fixed in-commit (README 17→18 rows, 33→44 stamps). LOG.md:451-453: "`R11-09` 72 → 94 cases, `R12-03` 33 → 44 stamps, `R13-01` 10 → 12 sections, `R13-02` 17 → 18 rows". The same commit adds SKILL.md:253-255 "five count rows that exist because docs carried stale numbers" (§5).
- **R18→R21, SKILL.md:46.** `fecee87` (R18), `5b0d4b7` (R19) and `aea7a43` (2026-10-17) keep "(54 stamps + 32 claims + claim ids)" against live 56 / 35; the text was correct at `bc1af88` (R17). Fixed `c41af82` (R21): "(63 stamps + 39 claims + claim ids, round 21)".
- **R19→R23, SKILL.md:641 "PASS (29 cases)".** Carried debt "superseded SKILL counts" (`round-19-recensus.md:45`, `5b0d4b7`); named again at `round-21.md:87`; fixed `e1884c6` (LOG.md:1212-1214: "corrected to the measured 36"). The ledger row lagged too: `aea7a43` landed the 36-case arm; R12-02 was re-pinned at `c41af82` (`round-21.md:15`).
- **R22→HEAD, SKILL.md:46 (the defining case).** `8ada17a` moved R12-03 `^63$`→`^69$` and R21-04 `^39$`→`^43$` in the same commit (`git show 8ada17a:corpus/claim-ledger.tsv`). SKILL.md:46 stayed at 63/39, no row failed, and the commit added "host counts earlier in this file are **historical** observations at their named revisions." At HEAD SKILL.md:46 reads 63/39 against live 83/61 (R12-03 `^83$`, R21-04 `^61$`), while PROVINCE.md:52 reads "83 revision stamps + 61 claim rows at round 24". Two committed docs disagree.
- **R22, S-count.** `corpus/lessons/round-22.md:23` "S017–S020 added" against its own table S017–S021, flagged by `d218603` (`round-22-verifier-spotcheck.md:180-181`). `closure-dispositions.json:90-96` (`e1884c6`) marks D7 "fixed" with a note about fetch digests only. Text unchanged at HEAD.
- **R23, the sweep that worked.** `7af07b4` "stale count corrections" moved the sources-census selftest 47→59 in SKILL.md and SCORECARD.md; `a3eb6c7` moved SKILL.md:47 to "70 cases" with R21-03 `^70$`. Doc and row moved together.
- **R23 verifier, `4f94b52`:** "the report's stated 20/10/20 split" (`round-23-verifier-spotcheck.md:137`) differs from the measured mix. A wave-report number, not a lane doc.
- **R24, `4587c61`:** M24-15, the recovery Gate's "8 words" for S032 measured 7 (LOG.md; `round-24.md` errata). Fixed in-round.
- **No stale-number admission found** in R1–R3, R7, R17 or R20 (lesson grep for stale/carried/said/says/stated/superseded). R2 has no lesson file. R1's aggregator audit found unreproducible counts, the basis of QA6 (`corpus/lessons/round-1-aggregator-audit.md`), not stale ones.

## 4. Current-tense numbers at HEAD, against live values
- Match: README:40 "(16 cases)", :41 "35 rows", :42 "22 rows", :43 "(61 cases)", :44 "27/35 census rows"; SKILL.md:47 "70 cases"; SKILL.md:186 "20 rows" (drift-symbols = 20). PROVINCE.md:46 self-discloses ("this said 21 until round 11").
- Stale: SKILL.md:46 (§3, R22→HEAD).
- Dated repro lines, out of C1's population only if the rule is per sentence: SKILL.md:607 "(files=15 symbols=19)" [Round-9], :629 "(claims=11 stamped=28)" [Round-11], :631 "(39 cases)" [Round-11]; `corpus/knowledge/op-ref-consumption.md:276` "PASS (29 cases)" with a correction note at :373-374 (live 36).

## 5. Errors in the convention's own text
- `claim-ledger.tsv:3`: "the exit code must equal the fifth column". Exit is the fourth field (`:1` header; every row).
- `claim-ledger.tsv:11-12`: "three committed docs". The parenthetical names two (README, PROVINCE) carrying three numbers; LOG.md:283 says "three stale numbers". `round-10.md:11` is a third, uncorrected occurrence; the comment does not say which doc it counts.
- The causal sentence covers R11-03 and R11-10 only (R11-11 is prophylactic, §2.3).
- SKILL.md:253-255 "five count rows that exist because docs carried stale numbers": the rows' own notes record one such origin (R11-10). R12-03 (mutation lane), R13-01 (heading cardinality) and R13-02 (R1x membership) record other origins.
- The `8ada17a` blanket "historical" label would exempt SKILL.md:46 under any rule that accepts it. C1's population must be per sentence: SKILL.md:46 carries a "round 21" tag and is a present-tense instruction.

## 6. Implications for C1 (routed D1); C2 and C3 have no bearing found here
- Experiment A is the exact red case C1 must produce: doc-only edit, row green.
- Bind each prose number to the live source its row already uses (the same command), not to a new hand-typed copy; any change to the bound value needs a QM14 migration record.
- Freshness evidence: SKILL.md:46 was wrong from `fecee87` to `c41af82` and again from `8ada17a` to HEAD, with the gate green throughout.

## 7. Commands, exit codes, unrun
- Read-only git (`log -S`, `show <rev>:path`, `blame`, `grep`); sandbox `git clone -q --no-hardlinks` + `git checkout -q 4587c61…` (exit 0). A stdlib python `_eval` for the 49-commit time series (exit 0).
- Experiments A and B: exit 0 each; stdout `22`, then `21`; emulated verdicts PASS, then FAIL.
- UNRUN: `claim-ledger.sh verify|cells|citations|docs`. `verify` and `cells` are barred on the real tree and were not run in the sandbox. The real runner was not invoked; verdicts are emulated from the header rule.
- No lane Git index, file or credential touched by this seat. Untracked `corpus/__pycache__/` and `plans/round-25.md` were already present at this seat's first `git status`; no lane command here writes Python output or those paths.
