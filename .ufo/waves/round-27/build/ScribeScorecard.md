# ScribeScorecard — round-27 pre/post rows (C1 calibration, C2 freshness)

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (read only). Author: KagiR26.ScribeScorecard-17 (leaf scribe, no subagents).
Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (= HEAD; `git rev-list --count BASE..HEAD` = 0).
Status: DRAFT. Every post-move value below is PREDICTED from reading code and tables; none was measured. No gate, selftest, instrument or live ledger row was executed by me.

## 0. Summary

- **C1 post-state fails its own counting target (predicted).** The working-tree (WT) docs plus WT binding table should give `stale=1 exit1`, not the planned `stale0 exit0`. Cause: `corpus/knowledge/claim-ledger.md:301` says `stamped=89`, while the WT pin for R12-03 is `^90$` and `corpus/stamps.tsv` has 90 nonblank lines. See CE-1.
- **C1 pre-state (BASE) is consistent with the plan.** Zero knowledge bindings exist at BASE. Five of the 18 candidate knowledge bindings are predicted STALE at BASE from their committed pins (section 3).
- **C2 pre-state is confirmed by static reading.** BASE `corpus/release-clock.py` contains no `is_regression`/`REGRESSED` code, and the existing artifact `c2-before.json` records 2/2 downgrades accepted CLEAN.
- **C2 post-state does not implement the plan's stated un-fire refusal (predicted).** A predecessor whose anchor equals the rolled-back observation (S027/S028 at 3.15.0) is still read not-fired and CLEAN. The per-fixture metric in `c2-measure.py` hides this, because the same fixture also contains S040/S041 regressions. See CE-4 and CE-5.
- **Measured-commit is PENDING for every post row.** The WT holds 15 uncommitted modified files (+215/−46). The instruments measure committed revisions only (section 1).

## 1. Measured-commit and provenance

| Field | Value | Evidence |
|---|---|---|
| BASE | `0a47dd189356ea66ec83c3891eed54526e95b89b` | `git rev-parse HEAD` returned the same SHA |
| Commits after BASE | none (0) | `git rev-list --count 0a47dd18..HEAD` = 0 |
| WT delta | 15 files, 215 insertions, 46 deletions | `git diff --stat 0a47dd18` (SKILL.md, PROVINCE.md, SCORECARD.md, corpus/QUALITY.md, corpus/README.md, corpus/SOURCES.md, corpus/claim-ledger.tsv, corpus/knowledge/{claim-ledger,op-ref-consumption,surface-census}.md, corpus/release-clock.py, corpus/self-counts.tsv, corpus/source-fetches.tsv, corpus/stamps.tsv) |
| Post measured-commit | **PENDING** | `.ufo/waves/round-27/tools/c1-measure.py:41-44` and `c2-measure.py:43-44` run `git clone --no-checkout` + `checkout --detach <rev>` + `git show <rev>:…`. Uncommitted WT edits are invisible to both instruments. L1 must commit (or otherwise pin an after SHA) before any post row can be measured. |
| `plans/round-27.md` at BASE | not present (`git cat-file -e` = no); it exists only in WT | cited below as WT path |

Provenance of pre-row artifacts:
- `.ufo/waves/round-27/c2-before.json` exists (12:09), `revision` = BASE (line 3). Its numbers were produced by an earlier run that I did NOT repeat. I only read it.
- `.ufo/waves/round-27/c1-before.json` is **absent** from the wave directory (`ls` shows none). `corpus/lessons/round-27.md:86` (WT) cites it for "five STALE knowledge numbers". That lesson claim is unverifiable from the tree.

Tools: none installed, upgraded or removed. Read-only operations I ran: `git rev-parse`, `git cat-file -e`, `git rev-list --count`, `git show <BASE>:<path>`, `git diff --stat` and `git diff -U0` (with output only), `git archive <BASE> corpus SKILL.md PROVINCE.md plans | tar -x` into `.ufo/waves/round-27/sandboxes/ScribeScorecard/base/` (109 files, sandbox only), `grep -c`/`wc -l` counts of data rows, and `grep`/`read` of file contents. Nothing under `corpus/` or the repo root was written.

## 2. Draft SCORECARD rows

Counting-command convention: `pre` = BASE `0a47dd18`; `post` = after SHA (PENDING). "Value" means what I observed or what I predict. Rows marked PREDICTED were not run.

### 2a. Axis: calibration (C1)

| Row | Phase | Quantity | Counting command (exact) | Measured commit | Value | Status |
|---|---|---|---|---|---|---|
| C1-pre-1 | pre | knowledge bindings in `corpus/self-counts.tsv` | `git show 0a47dd18:corpus/self-counts.tsv \| grep -c '^KN-'` | 0a47dd18 | 0 (BASE file has 52 lines, `corpus/self-counts.tsv:1-52`) | MEASURED by me (read-only count) |
| C1-pre-2 | pre | candidate knowledge numbers STALE on BASE docs, against the after table | `bash .ufo/waves/round-27/tools/c1-measure.py 0a47dd18 <after-sha> pre out.json` | 0a47dd18 docs; table at <after-sha> | 5 predicted: KN-LEDGER-REPRO-CLAIMS, KN-LEDGER-REPRO-STAMPS, KN-LEDGER-REPRO-SELFTEST, KN-OPREF-REPRO-SELFTEST, KN-CENSUS-DRIFT-SYMBOLS (section 3) | PREDICTED, NOT RUN; needs an after SHA |
| C1-pre-3 | pre | existing reviewed population (SKILL/PROVINCE/README) | BASE pin `corpus/claim-ledger.tsv:81` R25-02 expects `claims=38 stale=0` | 0a47dd18 | 38 claims (pin) | pin read only, not run |
| C1-post-1 | post | stale knowledge numbers on after docs + after table | `bash .ufo/waves/round-27/tools/c1-measure.py <after-sha> <after-sha> post out.json` (or `python3 -I -B corpus/self-counts.py` in an after checkout) | <after-sha> (PENDING) | **predicted 1 STALE: KN-LEDGER-REPRO-STAMPS** (doc 89, live 90), exit 1. Plan target is 0/exit0. | PREDICTED FAIL, NOT RUN |
| C1-post-2 | post | BASE docs against after table ("stale N, exit1") | `bash .ufo/waves/round-27/tools/c1-measure.py 0a47dd18 <after-sha> base out.json` | <after-sha> table | predicted 5 STALE, exit 1 (same five as C1-pre-2) | PREDICTED, NOT RUN |
| C1-post-3 | post | one-digit mutation red control | `bash .ufo/waves/round-27/tools/c1-measure.py <after-sha> <after-sha> mut out.json --mutate KN-LEDGER-REPRO-SELFTEST` | <after-sha> | predicted only that id STALE (170 → 270). Only valid once C1-post-1 is 0 STALE; otherwise two ids are STALE. Covers 1 of 18 bindings. | PREDICTED, NOT RUN |
| C1-post-4 | post | bindings added | `grep -c '^KN-' corpus/self-counts.tsv` on WT | WT (uncommitted) | 18 (WT `corpus/self-counts.tsv:53-75`); consistent with WT R25-02 pin `claims=56` = 38 + 18 (WT `corpus/claim-ledger.tsv`, R25-02 row) | count MEASURED by me on WT (read-only); binder not run |

### 2b. Axis: freshness (C2)

| Row | Phase | Quantity | Counting command (exact) | Measured commit | Value | Status |
|---|---|---|---|---|---|---|
| C2-pre-1 | pre | downgrade fixtures accepted CLEAN, plus control | `python3 .ufo/waves/round-27/tools/c2-measure.py 0a47dd189356ea66ec83c3891eed54526e95b89b base out.json` | 0a47dd18 | **2/2 accepted CLEAN; control clean** (artifact `c2-before.json:5-7`; lie exit 0 at `:22-25`, rollback exit 0 at `:45-48`, default `CLEAN (…fired=3…)` at `:81`) | artifact READ, NOT re-run |
| C2-pre-2 | pre | REGRESSED code present at BASE | `git grep -n 'is_regression\|REGRESSED' 0a47dd18 -- corpus/release-clock.py` | 0a47dd18 | no matches (my `git show … \| grep -E` returned nothing) | MEASURED by me (read-only) |
| C2-pre-3 | pre | selftest pin | BASE `corpus/claim-ledger.tsv:82` R25-03 `^RELEASE_CLOCK_SELFTEST: PASS \(67 cases\)$`; BASE `SKILL.md:48` "`--selftest` 67 cases" | 0a47dd18 | 67 | pin read only |
| C2-pre-4 | pre | default receipt | BASE pin `corpus/claim-ledger.tsv:83` R25-04 `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | 0a47dd18 | CLEAN30, fired=3 | pin read only |
| C2-post-1 | post | lie fixture (S040 observed 3.15.0 < anchor 3.15.1, fired) | `python3 .ufo/waves/round-27/tools/c2-measure.py <after-sha> post out.json` | <after-sha> (PENDING) | **predicted REGRESSED S040, exit 1**; not accepted | PREDICTED, NOT RUN |
| C2-post-2 | post | rollback fixture (S027/S028 at 3.15.0 not-fired; S040/S041 at 3.15.0 fired) | same | <after-sha> | **predicted REGRESSED S040, S041, exit 1**. S027/S028 are NOT flagged; the fixture still ends exit 1, so `accepted_clean` is false and the metric reads 0/2 while CE-4 stays silent. | PREDICTED, NOT RUN |
| C2-post-3 | post | predecessor-only un-fire (S027+S028 → 3.15.0, S040/S041 unchanged at 3.15.1) | NOT in `c2-measure.py` FIXTURES (`c2-measure.py:25-30`). Proposed command: add fixture `predecessor` and run `c2-measure.py <after-sha> post out.json` | <after-sha> | **predicted CLEAN exit 0, fired 3→1** (silent un-fire). Plan wording expects REGRESSED. | PREDICTED, NOT RUN; fixture not yet written |
| C2-post-4 | post | control and live default | same | <after-sha> | control CLEAN predicted; default CLEAN30 fired=3 predicted (no BASE row has observed < numeric anchor; checked by reading rows 2–31 of `corpus/release-clocks.tsv`) | PREDICTED, NOT RUN |
| C2-post-5 | post | selftest pin grows only by new cases | `bash corpus/claim-ledger.sh ...` row R25-03 (ledger:R25-03) | <after-sha> | WT pin `^RELEASE_CLOCK_SELFTEST: PASS \(73 cases\)$` (WT `corpus/claim-ledger.tsv:82`), WT `SKILL.md:48` "73 cases": 67 + 6. By reading: five `run_case` calls plus one `cases += 1`; `run_case` increments `cases` (WT `corpus/release-clock.py:937-940`). | count by reading; selftest NOT run |
| C2-post-6 | post | `--observe` on a regressed live feed | `python3 corpus/release-clock.py --observe OUT.json` (network; not run) | <after-sha> | by reading, `run_observe` writes a `regressed` receipt and counts only `error` receipts as failures (WT `corpus/release-clock.py:854-861`), so the observe exit is not obviously non-zero. Unverified. | UNRESOLVED by reading |

## 3. C1 binding table draft (18 WT rows; BASE doc value; pinned live source)

"Live" = the value the row's committed pin states (ledger:/expect:) or the counted data file. The binder's live run is not executed. Pin/count numbers marked MEASURED were counted by me on BASE.

| id | BASE doc:line (value) | source (pin or count) | BASE predicted | WT doc:line value | WT predicted |
|---|---|---|---|---|---|
| KN-BREADTH-SCOPE-SELFTEST | adjacency-breadth.md:152 (61) | R16-02 pin 61 (BASE tsv:40) | OK | unchanged | OK |
| KN-BREADTH-FALSIFY | adjacency-breadth.md:155 (18) | R16-03 pin caught=18 (BASE tsv:41) | OK | unchanged | OK |
| KN-SCOPE-CURRENT-SELFTEST | adjacency-scope.md:16 (61) | R16-02 | OK | unchanged | OK |
| KN-SCOPE-CURRENT-FALSIFY | adjacency-scope.md:17 (18) | R16-03 | OK | unchanged | OK |
| KN-SCOPE-TABLE-SELFTEST | adjacency-scope.md:155 (61) | R16-02 | OK | unchanged | OK |
| KN-SCOPE-TABLE-FALSIFY | adjacency-scope.md:155 (18) | R16-03 | OK | unchanged | OK |
| KN-SCOPE-MUTATIONS | adjacency-scope.md:269 (18) | R16-03 caught=18 | OK | unchanged | OK |
| KN-CHECKLIST-SELFTEST | checklist-execution.md:63 (34) | R15-02 pin 34 (BASE tsv:34) | OK | unchanged | OK |
| KN-CHECKLIST-FALSIFY-ROWS | checklist-execution.md:173 (16) | R15-04 pin 16 (BASE tsv:36; the note states 16 declaration rows, not counted by me) | OK | unchanged | OK |
| KN-CHECKLIST-FALSIFY-ITEMS | checklist-execution.md:179 (16) | R15-04 pin 16 — a proxy: it counts checklist.tsv rows, not SKILL.md bullets (CE-6) | OK | unchanged | OK |
| KN-LEDGER-REPRO-CLAIMS | claim-ledger.md:301 (17) | R21-04 pin 65 (BASE tsv:54; MEASURED 65 R-rows on BASE) | **STALE** | 65 | OK |
| KN-LEDGER-REPRO-STAMPS | claim-ledger.md:301 (33) | R12-03 pin 89 (BASE tsv:28; MEASURED 89 nonblank stamps on BASE) | **STALE** | 89 | **STALE** (live 90: WT tsv:28 `^90$`; MEASURED 90 nonblank WT stamps) |
| KN-LEDGER-REPRO-SELFTEST | claim-ledger.md:304 (72) | R11-09 pin 170 (BASE tsv:23) | **STALE** | 170 | OK |
| KN-DRIFT-BOUND-FILES | drift-gate.md:143 (6 of 15) | rows:corpus/drift-baseline.tsv (MEASURED 15) | OK | unchanged | OK |
| KN-OPREF-REPRO-SELFTEST | op-ref-consumption.md:276 (29) | R12-02 pin 36 (BASE tsv:27) | **STALE** | 36 | OK |
| KN-OPREF-CORRECTION-SELFTEST | op-ref-consumption.md:374 (36) | R12-02 pin 36 | OK | unchanged | OK |
| KN-CENSUS-DRIFT-FILES | surface-census.md:32 (15) | rows:corpus/drift-baseline.tsv (MEASURED 15) | OK | unchanged line, locator still matches | OK |
| KN-CENSUS-DRIFT-SYMBOLS | surface-census.md:32 (19) | rows:corpus/drift-symbols.tsv (MEASURED 20 nonblank non-comment) | **STALE** | 20 | OK |

Predicted STALE counts: BASE 5; WT 1 (KN-LEDGER-REPRO-STAMPS). Count of WT bindings 18 (MEASURED).

Binder semantics I read in `corpus/self-counts.py` (BASE extract, `:9-18`, `:35`, `:306-357`): `rows:` counts nonblank non-comment lines; `ledger:` runs the row's command (live output); `expect:` reads the committed pin; a locator must match exactly one line (`AMBIGUOUS` otherwise); exit 1 for STALE/UNLOCATED/AMBIGUOUS. So a count mismatch on a doc line is STALE, and the binder reads `stamped=` from the first match on the line.

## 4. Counterexamples

**CE-1 (C1, post-state STALE).** `corpus/knowledge/claim-ledger.md:301` (WT) reads `CLAIM_LEDGER: CLEAN (claims=65 … stamped=89 …)`. WT `corpus/claim-ledger.tsv:28` R12-03 is `grep -c '[^[:space:]]' corpus/stamps.tsv` with expect `^90$`, and WT `corpus/stamps.tsv` has 90 nonblank lines (MEASURED; BASE had 89). WT `SKILL.md:46` and `PROVINCE.md:52` both say 90 stamps, so the knowledge entry is the outlier. Fix: `89` → `90` at WT `claim-ledger.md:301`, then re-stamp (reviewed commit). Predicted binder result: `STALE KN-LEDGER-REPRO-STAMPS corpus/knowledge/claim-ledger.md:301`, exit 1.

**CE-2 (C1, named debt not covered and not corrected).** `corpus/knowledge/op-ref-consumption.md:296` (BASE and WT, unchanged) reads "`--selftest` proves the comparator on 21 cases". The pinned R12-02 expect is 36 (BASE `corpus/claim-ledger.tsv:27`). This is current tense, stale, and named in round-25's debt (`corpus/lessons/round-25.md:158-165` BASE, listing `op-ref-consumption.md:276,283,296`). WT changed :276 and added an erratum, but not :296. It is not among the 18 bindings. Concrete: WT still contains a stale current-tense number in a reviewed-population file.

**CE-3 (C1, unbound current-tense numbers that are correct today).** A one-digit mutation of these lines would pass the post-state binder silently (populations are not complete; the plan says so, but the scorecard should name them):
- `corpus/knowledge/drift-gate.md:4` "`corpus/drift-baseline.tsv` (15 rows), `corpus/drift-symbols.tsv` (20 rows)". Bindable: `rows:`.
- `corpus/knowledge/drift-gate.md:170` "`DRIFT_SELFTEST: PASS (13 cases)`". Bindable: `ledger:R11-05` (BASE `claim-ledger.tsv:19` pins 13).
- `corpus/knowledge/drift-gate.md:169` "`DRIFT_PINS: CLEAN (files=15 symbols=20)`". Not bindable exactly (R11-04 regex is not exact).
- `corpus/knowledge/checklist-execution.md:5` "`corpus/checklist.tsv` (16 rows)". Bindable: `ledger:R15-04`.
- `corpus/knowledge/adjacency-scope.md:7` "`corpus/surface-census.tsv` (35 rows". Bindable: `rows:corpus/surface-census.tsv` (MEASURED 35).
- `corpus/knowledge/adjacency-breadth.md:158` "The 18 falsifiers". Bindable: `ledger:R16-03`.
- `corpus/knowledge/surface-census.md:11` and `:252` "`SELFTEST: PASS (16 cases)`". Bindable: `expect:R11-03` (R11-03 is `[substrate]`).

**CE-4 (C2, predecessor un-fire not refused).** The plan (`plans/round-27.md:26-28`, WT) says a stale feed "un-fires an already fired predecessor" and must become REGRESSED. The implemented rule is `is_regression` = observed numerically below anchor (WT `corpus/release-clock.py:382-386`), applied at `:542-547` and `:762-763`. For S027/S028 (anchor 3.15.0) an observation of 3.15.0 is equal, not below, so `:553-557` assigns not-fired and the row is accepted. The rollback fixture only fails because S040/S041 (anchor 3.15.1) regress. Nothing in WT compares against prior receipts, so the plan's un-fire wording is not implemented. Predicted: predecessor-only fixture → CLEAN exit 0, fired 3→1.

**CE-5 (C2, metric masks CE-4).** `c2-measure.py:80` counts `accepted_clean` per fixture, and the rollback fixture carries S040/S041 regressions. A fix to CE-4 would not change the metric's value (0/2 before and after), so the scorecard cannot show whether CE-4 is closed. Add the predecessor-only fixture (C2-post-3) and report its result separately.

**CE-6 (C1, proxy binding).** `KN-CHECKLIST-FALSIFY-ITEMS` (`checklist-execution.md:179`, `items=16`) binds to `ledger:R15-04` = count of `corpus/checklist.tsv` rows. The runner's `items=N` counts SKILL.md `- [ ]` bullets. The two agree today (both 16), but a SKILL bullet added without a tsv row would leave this binding green while the quoted runner output is stale. The row note in `claim-ledger.tsv:36` already says this count is read from the same file it validates.

**CE-7 (C1, red control covers one id).** The plan's counting command shows one mutation (`KN-LEDGER-REPRO-SELFTEST`). The scorecard should carry 18 mutation runs (one per binding) or state the coverage as 1/18.

**CE-8 (C2, lesson evidence gap).** `corpus/lessons/round-27.md:86` (WT) cites `.ufo/waves/round-27/c1-before.json` for five STALE numbers. That file does not exist. My static prediction (section 3) gives five at BASE, so the number is plausible, but the artifact is not present.

**CE-9 (round-25 named debt, not all unverifiable).** `corpus/lessons/round-25.md:158-170` (BASE) names several items. Their status:
- `claim-ledger.md:81` "case 16 vs 27": a positional case index, excluded by rule. WT renamed it to `verdict-not-final` (WT `claim-ledger.md:82`).
- `sops-age-key-rotation.md:68-70` and `vault-openbao-token-lease-lifecycle.md:76-78`: dated "(2026-10-19)" observations of a grep exit. These are dated measurements (out of population by rule). The lesson says the grep "now exits 0"; I did not re-run it. Not corrected in WT.
- `credential-isolation.md:120-122`: BASE file has 78 lines (`read` says line 116 is past EOF), so the named location cannot be found at BASE. Not corrected in WT.
- `surface-census.md` "SelfInvKnowledge1/2": no such text in BASE `corpus/knowledge/surface-census.md` (grep found no match). Unlocatable.
- `op-ref-consumption.md:276,283,296`: 276 bound; 283 is fixture description (not a count); 296 is CE-2.

## 5. What I did NOT check

- I did not run any instrument, binder, selftest, ledger row or gate. The counts marked PREDICTED are reasoning from code and pins, not results. Nothing here is a pass.
- I did not execute `corpus/self-counts.py`, `corpus/release-clock.py` (any mode), `corpus/claim-ledger.sh`, or `c1-measure.py`/`c2-measure.py`. `claim-ledger.sh` `verify` and `citations` were not run.
- I did not verify the live values of ledger-backed bindings (R11-09, R12-02, R21-04 etc.). BASE pins are what I compared against.
- I did not verify that the WT `corpus/release-clock.py` selftest cases pass, that `run_case` assertions are correct, or that the new six cases exercise what they claim. I only confirmed the count by reading.
- I did not check `main()` exit codes in `corpus/release-clock.py` (WT ~1625-1672) for `--observe` on a regressed live feed (C2-post-6).
- I did not check `corpus/SOURCES.md` S042/S043 quotes or `corpus/source-fetches.tsv` S042/S043 hashes against the public URLs. The task forbade live contact for this item and I did not fetch them.
- I did not audit the WT `corpus/QUALITY.md` QM25/QM26 wording, `SCORECARD.md`, or `corpus/README.md`.
- I did not check knowledge files beyond the grep-identified candidate lines; there may be further unbound current-tense numbers.
- I did not check host-dated measurements in knowledge (breadth counts, `op`/handler counts); they are out of population by the plan's rule.
- I did not verify the `plans/round-27.md` or `build-spec.json` contract beyond the sections cited.
- I did not confirm whether the 90-stamp WT state is the intended final state; L1 must decide between `stamped=89` and the pin.

## 6. Checks main agent should run once after a commit (not run by me)

1. Commit the WT (or the integrator's chosen set), record the after SHA, and fix CE-1 first.
2. `bash .ufo/waves/round-27/tools/c1-measure.py 0a47dd18… <after> base out.json` → expect 5 STALE, exit 1 (C1-post-2).
3. `bash .ufo/waves/round-27/tools/c1-measure.py <after> <after> after out.json` → expect 0 STALE, exit 0 (C1-post-1). It fails at CE-1 until fixed.
4. `bash .ufo/waves/round-27/tools/c1-measure.py <after> <after> mut out.json --mutate KN-LEDGER-REPRO-SELFTEST` → expect that id STALE only.
5. `python3 .ufo/waves/round-27/tools/c2-measure.py <after> post out.json` → expect lie REGRESSED, rollback REGRESSED (S040/S041), control CLEAN.
6. Add a predecessor-only fixture (CE-4/CE-5) and report it; decide whether the plan's un-fire wording is to be enforced or declared a limit.
7. `python3 corpus/release-clock.py` default → CLEAN30 fired=3; `--selftest` → 73 (checked against WT pins).
8. Decide CE-2 (op-ref:296 "21 cases") and CE-3 (unbound candidates) in or out of population.

Sandbox: `.ufo/waves/round-27/sandboxes/ScribeScorecard/base/` (BASE extract, 109 files). Report: `.ufo/waves/round-27/build/ScribeScorecard.md` (this file).
