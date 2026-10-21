# ClaimR13X03 — R13-03 (`bash corpus/claim-ledger.sh cells`) semantic audit

Connector, advisory only. No gate, row command, cells run, handler, op, vault or host command was executed.

- **Paths:** `K=/home/vgpnk/Projects/shokunin/kagi-shokunin`, `F=/home/vgpnk/Projects/shokunin`.
- **Frozen revision:** HEAD `d218603b74099ddca0bd8f869516fc41db0979bf`. At audit start, `sha256sum` of `K/corpus/claim-ledger.sh` (`cf56f9ea…`), `K/corpus/claim-ledger.tsv` (`e6806968…`) and `K/SCORECARD.md` (`96cf354a…`) equalled `K/corpus/stamps.tsv` rows 4, 5 and 68.
- **Row:** `K/corpus/claim-ledger.tsv:38`. Byte-identical to `K/.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:38`.
- **In flight:** L1's working tree changed while I audited (uncommitted, mtime 2026-10-21 00:53 -0300). Changes: rows R23-01/R23-02, `corpus/fixtures/cells-hermetic/`, a Round 23 section in `SCORECARD.md`, and `corpus/closure-dispositions.{py,json}`. Every in-flight observation below is labelled **[WT]**. R13-03 itself is unchanged in the WT.
- **Static model:** "model" figures below come from a Python port of the `cells()` parse, run over the committed files (≈ `claim-ledger.sh:715-791`, plus `line_ids`/`norm_tok`/`stamp_index`). They are not gate output.

## 1. Verdict on the row

| Question | Result | Basis |
|---|---|---|
| ERE matches the emitter | **supported** | Field order equals the CLEAN printf at `claim-ledger.sh:1011-1012`. The four zero-pinned fields are exactly the BROKEN triggers at `:1006`. Policy-clean: first token `bash`, no metacharacter, no denied verb (`:160-191`). |
| exit 0 | **supported** | The CLEAN branch falls through past the false selftest `if` (`:1030`) to the end of the script, so it exits 0. BROKEN is exit 1 (`:1009`); POLICY and `die` are exit 2 (`:1004`, `:114`). |
| timeout 300 s | **supported on the measured path; present-host path unresolved** | On an absent host, `cells` would execute 26 cited rows. Round-22 measured seconds for 25 of them sum to 11.8 s (`K/.ufo/waves/round-22/final-verification.json` `safe_rows[].seconds`). R18-01 was never measured. The present-host path (36 rows, including 10 `[substrate]` gates) has not run since round 17. The declared inner budgets are 2670 s and 5490 s respectively, both far above 300 s. A hung inner row therefore surfaces only as the outer `FAIL R13-03 reason=timeout`, and the row that hung is not named (`verify` never echoes output, header `:84-86`). That is a diagnosability bound, not a defect. |
| "run here through the ledger's claims machinery" can yield this line | **refuted at HEAD** | See F1. Through `verify` there is no host state in which R13-03 passes. |
| Note: "Substrate-absent hosts DEFER the substrate rows it re-runs — the audit still completes and reports row_deferred" | **refuted as a ledger statement; true only for a direct run** | See F2. |
| Real-scorecard cell obligation currently holds | **unresolved (not executed)** | The model predicts `uncited=0` at HEAD and **`uncited=1` in [WT 00:53]**; L1 re-pointed the cell at [WT 00:56:35] (F3). |

## 2. Causal findings

**F1. R13-03 cannot pass through `verify` in either substrate state (new).**
- **Substrate absent.** The note ends in the literal `[substrate]` (`claim-ledger.tsv:38`, tagged since `fecee87`, 2026-10-14; untagged at `4b8c018`). `verify_claims` therefore DEFERs the row before it runs (`claim-ledger.sh:416-418`).
- **Substrate present or returned.** The row runs, and its inner `cells` re-runs every cited row whose command does not name `claim-ledger.sh` (`:811-829`). That set includes **R18-01**, cited by the scored cell `SCORECARD.md:322` (Round 18 post-move, freshness). R18-01 pins the all-GONE `DRIFT … exit 1` result. Its own note says it "fails on both exit and verdict" when the substrate returns (`claim-ledger.tsv:48`; `knowledge/substrate-deferral.md:55`). It is also the same file that `substrate_present()` tests: `drift-baseline.tsv:1` pins `$HOME/.local/bin/the-janitor`, and `claim-ledger.sh:145` checks that path.
- **Result.** In the substrate-return state R18-01 is designed to signal, the inner run gives `row_failures≥1`, the cell audit reports BROKEN, and the ledger prints `FAIL R13-03 reason=exit-mismatch exit=1 want=0`.
- **Exceptions.** Forcing `KAGI_SUBSTRATE=present` on an absent host also fails, because the substrate gates fail closed. The only exception I can see is a partial restore with different bytes and no pinned symbols.
- **Why the tag cannot simply be dropped.** R18-02 pins the tag (`^11$`, `claim-ledger.tsv:49`), and `SCORECARD.md:332` lists R13-03 among the 11.
- **Relation to earlier findings.** This refines round-22 `Entry05.md:95-99`, which blamed present-host failure on the parser; the parser was fixed at `:694`, but the R18-01 coupling remains. `ClaimR18X01.md:115` reaches the same conclusion from the other side ("host skip must stay as long as any scored cell cites R18-01").

**F2. The row's `row_deferred` field is always 0 under the ledger.**
- The outer and inner substrate predicates are the same function. It reads the same inherited `HOME` and `KAGI_SUBSTRATE` (`:140-146`), and the child inherits the environment at `:426-427`.
- Through `verify`, R13-03 either runs with `row_deferred=0` or is deferred whole. `row_deferred>0` occurs only on a direct run.
- No selftest runs `cells` with a tagged row. The deferral cases `:1422-1424` are `verify`-only, so `CELL_AUDIT … row_deferred>0` has no mechanical proof.

**F3. R13-03's obligations that only `cells` checks have had no executed receipt since round 17; [WT] already violates one.**
- `verify` covers MISSING-ID (idref) and STALE (all stamps). Only `cells` covers:
  - UNCITED cells (`:776-781`);
  - six axes per section (`:705-713`);
  - unrecognised-heading refusal (`:735-741`);
  - non-vacuity (`:784-790`).
- All four are host-independent file parsing.
- **Receipts.** The last executed real-scorecard CLEAN is `F/.ufo/reports/round-17/kagi.md:95` (cells=108, `bc1af88`). It uses the pre-`row_deferred` shape. Searching `K` and `F/.ufo` for `CELL_AUDIT` lines with cells≥60 found **no real-scorecard receipt that matches the current ERE**; only the round-22 synthetic fixture runs (cells=6/12) carry `row_deferred=`. Round 22 skipped the row: `safe-row-plan.json` `skipped_rows[7]`, policy "No full verify/cells invocation"; `final-verification.json` records "Not executed".
- **[WT 00:53] instance (model).** `K/SCORECARD.md:832`, the Round 23 pre-move calibration cell, contained no `R…-…` id. `corpus/closure-dispositions.py` is not in `corpus/stamps.tsv`. `cells` would have printed `UNCITED SCORECARD.md:832 calibration` and BROKEN. Every executed path would still have been green:
  - `verify` defers R13-03 (F1);
  - R23-01 reads only the fixture;
  - the safe-row run skips R13-03.
- Sent to `agent://KagiR23`. At **[WT 00:56:35]** L1 changed the cell to cite `R22-02`, so it is now pointed. The fix still shows the gap: the UNCITED cell was found by reading, not by any executed gate on this host. The new pointer also shows the known relevance ceiling. R22-02's round-22 receipt is `FEATURE_CLAIMS_SELFTEST: PASS cases=12`, a feature-claims selftest, not a measurement of the base-state absence of closure dispositions. A pointer to R23-02's before-state would be more relevant. This is advisory; relevance is not machine-checked.

**F4. `row_pointed` overstates how many cells have a live check.**
- `knowledge/claim-ledger.md:200-202` says the line "shows how many scores rest on a re-run command". However, cells resting only on SKIP-SELF rows (`:816-819`) or on deferred rows count as pointed. Selftest `cells-self-row-skip` (`:1131,1137,1374`) pins that such a cell passes.
- Model at HEAD: 92 row-pointed cells.
  - 32 of them have no executed row and no stamp pointer on an absent-host direct run.
  - 11 have none on a present-host run (SKIP-SELF only).
- Five calibration cells rest **solely** on R13-03 with no stamp: `SCORECARD.md:186, 208, 230, 294, 315`. They are blind twice over: SKIP-SELF inside `cells`, and DEFER or FAIL under `verify`.
- The vacuity guard counts row-pointed cells, not executed rows (`:789`). The ERE admits `rows_run=0` and `row_deferred` equal to `rows_run`. `rows_run` itself includes deferred rows (`C_N++` at `:415` runs before the DEFER at `:416`; `:828`). Several sibling reports note this generally.

## 3. Do `[substrate]`, SKIP-SELF and the hermetic mode preserve the obligation?

- **`[substrate]` on R13-03: does not preserve it.** On absent hosts it discards the host-free half (F3). On present hosts R18-01 makes the row fail (F1). It also makes the inner deferral the note describes unreachable (F2). Bound 1 ("deferral records an absence", `substrate-deferral.md:59-61`) holds, but the stated deferral reason is wrong for the parsing half.
- **SKIP-SELF: preserves boundedness, and loses no evidence under `verify`.** The other self rows (R11-08, R11-09, R14-01, R18-03) are executed directly by the same `verify`. Inside `cells` it removes the check for 11 cells (F4). It is lexical (`*claim-ledger.sh*`), so R23-01 [WT] will also be skipped wherever it is cited.
- **Hermetic synthetic mode (R23-01 [WT]): preserves the mechanism, not the obligation.**
  - What it covers: six fixture cells, and it passes `--claims/--stamps/--scorecard/--docs`. Those flags are needed because `--root` does not rebind `CLAIMS`/`STAMPS` (`:104-105`, `:240`). It is untagged and its line pins `row_deferred=0`.
  - What it cannot cover: it never sees `K/SCORECARD.md` (144 cells in the model at HEAD, 156 in [WT]).

## 4. What C3 and C1 integration must retain for this row

**C3:**
1. Keep R13-03's skip explicit and give the causal reason (F1: tag plus R18-01). "Host rows" is not enough. R23-01 must not be presented as R13-03 evidence.
2. R23-01 stays untagged, so R18-02 stays at 11. Its exact line keeps `row_deferred=0`.
   - [WT] note says "Exact rows_run/self_skipped pinned so an all-deferred … fixture cannot pass". That attributes the protection to the wrong field: `rows_run=2` would also print with both rows deferred. Only `row_deferred=0` excludes that case.
3. [WT 00:53] `SCORECARD.md:841` said R23-01 prints `rows_run=1`, but R23-01 expects `rows_run=2` (the fixture cites R90-01 and R90-02). **Reconciled by L1 at [WT 00:56:35]** (`rows_run=2 row_deferred=0 self_skipped=0`).
4. Include an **UNCITED** fixture mutant. MISSING-ID and STALE are also caught by `verify`, while UNCITED is the class [WT] `:832` just exhibited.

**C1:**
1. [WT] D9 is `fixed`, with pointer `corpus/claim-ledger.tsv`. It resolves because the file contains the token `D9` (`closure-dispositions.py:117-120`). R13-03 shares that file, so if R13-03's note ever names D9 (for example, to record the skip), D9 would still resolve after R23-01 was deleted.
2. Resolve TSV pointers by row id, i.e. first field `R23-01` and the token on that row. This agrees with `ClaimR13X01.md:95-99` and `ClaimR15X03.md:113-114`.
3. Do not let any disposition imply that R13-03's real-scorecard obligation is satisfied.

## 5. Consumer-visible risk and a minimal synthetic falsifier (proposal for L1; NOT executed)

**False-clean.** On a substrate-absent host, `CLAIM_LEDGER: CLEAN (… deferred=11 …)` exit 0 is printed while a scored cell is UNCITED. Live instance at [WT 00:53] `:832`; re-pointed at 00:56:35 after I flagged it, not because a gate caught it.

Build a scratch tree `S`:
- `S/corpus/ok.txt` containing the single line `EXPECTED`.
- `S/stamps.tsv` with one valid row for `corpus/ok.txt`.
- `S/SCORECARD.md`: one `## Round 1 — post-move` table with all six axes; five cells cite `` `F1-01` ``, and `| calibration | 9 | prose, no pointer |`.
- `S/claims.tsv` with two rows:
  - `F1-01⇥grep -c EXPECTED corpus/ok.txt⇥^1$⇥0⇥5⇥fixture`
  - `F1-02⇥bash K/corpus/claim-ledger.sh cells --root S --claims S/claims.tsv --stamps S/stamps.tsv --scorecard S/SCORECARD.md --docs S/SCORECARD.md⇥^CELL_AUDIT: CLEAN⇥0⇥60⇥R13-03 mirror [substrate]`
  - Write the paths literally, with no `$`.

Then run:
- **A.** `KAGI_SUBSTRATE=absent bash corpus/claim-ledger.sh verify --root S --claims S/claims.tsv --stamps S/stamps.tsv --docs S/SCORECARD.md`. Predicted from `:416-418` and `:982-983`: `DEFER F1-02` and CLEAN, exit 0.
- **B.** `bash corpus/claim-ledger.sh cells` with the same arguments. Predicted from `:776-781` and `:1006-1009`: UNCITED and BROKEN, exit 1.

**Defect reproduced if A exits 0 while B exits 1.**

Second half (false-fail): add an untagged absence pin `P1-01` (`grep -c GONE corpus/marker.txt`, expecting the "No such file" line, exit 2), cited by one cell. With `KAGI_SUBSTRATE=present` and `marker.txt` created, both P1-01 and F1-02 fail for one host event. Together with A, this shows F1-02 has no passing state.

## 6. Proposed move (one, bounded)

**Proposal:** split R13-03 along its host boundary.
- Add `cells --pointers-only`. It runs `idref_audit` plus `cells()` (UNCITED, six-axis, heading, vacuity) and the cited-stamp re-compare (`:830-841`). It skips the row re-run block (`:805-829`), so no command executes.
- It prints a distinct `CELL_POINTERS: CLEAN|BROKEN (cells= row_pointed= stamp_pointed= uncited= missing_ids= stale_pointers= rows_not_rerun=)`, with exit 0/1/2 as today.
- Carry it in one new **untagged** row, e.g. `bash corpus/claim-ledger.sh cells --pointers-only`, tmo 60.
- R13-03 stays byte-identical (tag, ERE, explicit skip), so R18-02 stays at 11.

**Evidence:** F1–F4. The move would have caught [WT] `:832` on this host.

**Axes:**
- *Calibration ↑:* the scorecard's own pointer claim gets a verdict on every host. Pointer rot can be told apart from a host event, which removes the misattributed F1 failure.
- *Operability ↑:* a host-free real-scorecard path that the safe-row runner can execute. It complements C3's fixture rather than replacing it.
- *Freshness:* neutral (stamps are already compared by `verify`).

**Risks:**
- A second summary could be misread as re-run evidence. Mitigate with the distinct prefix and the `rows_not_rerun` field.
- It is about 15 lines in a 1428-line gate.
- It is QM14 migration churn:
  - re-stamp `claim-ledger.sh` (`stamps.tsv:4`);
  - re-pin R11-09/R18-03 to 121+k cases;
  - update R21-04 to +1 row;
  - append to Class 5 in `knowledge/claim-ledger.md`.
- If the new row is cited in a cell, it is SKIP-SELF'd (expected).
- If code cannot land this round, the fallback is weaker: record R13-03 as "host-transitive, unexecuted since round 17" in the round lesson, and review the Round 23 cells by hand.

**Verification for L1 after landing:**
- Selftest cases:
  1. CLEAN on `sc-ok`, using a cited row whose command *would fail if run* (this proves it does not execute);
  2. UNCITED → exit 1;
  3. STALE-POINTER → exit 1;
  4. identical output under `KAGI_SUBSTRATE=present` and under `absent`.
- §5 run A must turn into FAIL exit 1 once F1-03 (`--pointers-only`, untagged) is added.

## 7. Historical vs current evidence

- **Historical receipts (pre-tag shape):**
  - `K/SCORECARD.md:115` (r13, cells=60);
  - `K/corpus/lessons/round-14.md:162` (cells=72);
  - `F/.ufo/reports/round-15/kagi.md:54` (cells=84);
  - `F/.ufo/reports/round-17/kagi.md:95` (cells=108).
- **Later history:**
  - Round-18 pre-move `SCORECARD.md:315`: BROKEN, `row_failures=10` from substrate rows.
  - `fecee87`: tag and `row_deferred` added.
  - `SCORECARD.md:623`: `cells` refused the scorecard from `93ab9a5` until round-22 FixCellParser.
  - Round 22: skipped, with D9 routed (`K/corpus/lessons/round-22-verifier-spotcheck.md:74-77,183-184`).
- **Related prior finding (2026-10-14):** `F/.ufo/waves/shokunin12h-20261014-p1-repair/members/KagiScopeAudit.md:17` noted that deferral is counted as a non-failure. It did not identify the tag pre-emption or the R18-01 coupling.
- **Known, not re-reported:** the summary shape at `knowledge/claim-ledger.md:198-200` and the r13 receipt at `:303` lack `row_deferred` (round-22 `Entry05.md:93-110`).
- **Current:** HEAD as cited above; [WT] as labelled.

## 8. Limits

- Every behavioural claim is a code reading or the static model [INFERENCE]. Nothing was executed.
- The model's port of `norm_tok` may differ from the bash version in edge cases.
- [WT] files were changing during the audit.
- R18-01's result on a partial restore is unresolved.
- No public sources were used.
- Installs/updates: none.
- **Disclosures:**
  - Two `git status --porcelain` and one `git diff --stat` ran without `--no-optional-locks`, so they may have opportunistically refreshed the index stat cache (nothing staged or changed). All later git reads used `--no-optional-locks`.
  - I created four scratch files under `/tmp` during analysis and removed them afterwards.
  - The only other write is this report and one message to `agent://KagiR23`.

Report: .ufo/waves/round-23/parent-build/ClaimR13X03.md
