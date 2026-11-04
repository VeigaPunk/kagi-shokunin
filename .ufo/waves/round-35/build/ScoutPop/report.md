# ScoutPop — committed BASE populations and migration map

Axes: calibration correctness, population preservation, migration completeness, evidence fidelity. Read-only source walk; no lane gate, selftest, build, lint, producer, account, vault or handler execution. No installation, clone, scratch directory, production edit or git mutation. No scratch cleanup was necessary.

## Evidence and confidence

BASE is `063c407494276d0c616e6c712a2e5d7aeb7e3768`. Populations and active bindings below were calculated exclusively from `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show BASE:path` and `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin ls-tree -r --name-only BASE -- SKILL.md PROVINCE.md README.md corpus plans`, with independent Python lexical projections. This is observed committed-tree enumeration, NOT an executed census verdict. Exact members, source-line locators, active command rows, every existing self-count binding and input digests are preserved in `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ScoutPop/base-populations.json`.

The frozen plan and measurement instrument were read from `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-35.md` and `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/measure.py`. The initially requested root-level `controls/measure.py` does not exist; the plan gives the actual path. LSP device unavailable (`xd://lsp` returned “No such tool”); references here are literal source evidence, not semantic-server proof. Confidence high for enumerated committed bytes; candidate execution outcomes remain unobserved.

## Independent BASE populations

| Projection | Observed enumeration | Defining source |
|---|---|---|
| Registry rows | 88, exactly S001–S088 | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`:7–95; parser `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh`:169–186 |
| Tier/status | A84 B2 C2; mined84 queued1 rejected3 | same rows; queued S005; rejected S008/S030/S038; B IDs S060/S087; C IDs S005/S008 |
| Sourced entries | 14 | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh`:333–338: top-level knowledge `*.md` with column-one lowercase `source:` |
| Legacy entries | 21; total entries35 | same loop; no column-one `source:` means legacy, not necessarily missing all historical source prose |
| Captures | 88 data rows, 88 distinct registry IDs, exactly S001–S088 | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv`:44–131; census `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh`:255–258,315–317 counts registry IDs having at least one capture, not arbitrary HTTP transactions |

S088 already exists at `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`:95; its capture is `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv`:131. The own-work entry is ALREADY sourced at `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md`:1–3. Reopening it requires neither a new registry row nor another legacy-to-sourced migration. Preserve 88/14/21/88 as reporting invariants. Exact sourced/legacy filenames and every row locator are in the receipt.

## Single-C1 separability

Observed frozen plan: `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-35.md`:6–22 declares exactly one C1 predicate, `mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`. Its nine fixed cases are independently visible in `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/measure.py`:6–16: invalid setup-number, failed-number, diagnostic-number, stderr-number, clean-forgery; valid-zero and grep-empty positive controls; empty-output and wrong-count retained refusal controls. Lines24–28 require both expected rc and finding-prefix and aggregate all nine cases. Population expansion is explicitly not another claim.

Inference: target sets are separable here because producer-result validity is the only scored causal repair, while source reopening, documentation and identity bookkeeping preserve the same populations. Do not introduce a second exact SOURCES/capture target, count selftest growth as another axis gain, or regrade historical last-integer receipts. Nine-case results are not universal producer honesty: the plan explicitly excludes dishonest plain-integer success and masked upstream failures. This seat did not establish after-values by execution.

## Active commands and every current prefreeze count copy

Exactly TWO active ledger command fields invoke prefreeze, both selftest (no active ledger `run` invocation):

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv`:93, R33-01: `bash corpus/prefreeze-control.sh --selftest`, expected `^PREFREEZE_SELFTEST: PASS \(12 cases\)$`, exit0.
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv`:96, R34-02: identical command and expectation, exit0.

If the selftest case population changes, migrate BOTH expectations to the observed count; preserve old/new values and motivating source in a migration receipt. BASE implementation has twelve `ck` callsites, `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh`:124–189; this is a static count, not a selftest execution.

Current documentation copies of the prefreeze selftest count are exactly:

1. `/home/vgpnk/Projects/shokunin/kagi-shokunin/PROVINCE.md`:77 — 12 cases.
2. `/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md`:820 — 12 cases.
3. `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/README.md`:92 — 12 cases.

The entry uses symbolic `<k>` at `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md`:56, so no numeric case migration there. Frozen plans and explicit historical lessons/spotchecks retain their old measured counts.

Important binding gap: NONE of these three prefreeze numeric copies has a row in BASE `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-counts.tsv` (complete file scanned; all 62 data bindings are included verbatim with line numbers in the receipt). No existing binding references R33-01/R34-02 or prefreeze. The count-copy updates must therefore be explicit; do not claim an existing binder automatically protects them. QM21 motivates adding three bindings against the live R33-01 selftest if L1 chooses to close that gap, but that is distinct from silently changing inherited R25-02's expected60. Preserve the routed R25-02 FAIL; do not absorb this pre-existing discrepancy into C1.

## Minimal production migration map for L1 (not performed)

- Repair result acceptance at `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh`:258–270. BASE ignores non-timeout producer rc, tolerates stderr, and extracts trailing digits from the last nonempty line. Header contract at lines7–21 and the selftest descriptions must track the new strict contract.
- Update current interface prose at `/home/vgpnk/Projects/shokunin/kagi-shokunin/PROVINCE.md`:77; `/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md`:820; `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/README.md`:92. All currently advertise last-integer extraction.
- Update `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md`:46–47 and58–65: the latter explicitly accepts arbitrary nonzero rc with an integer and must not survive as current contract. Keep original historical evidence blocks historical, and update source/verification context at lines1–3 only to supported observations. Do not silently rewrite immutable S088 source identity or its historical capture into new bytes.
- Migrate R33-01/R34-02 and three documentation case counts together only after the installed candidate's selftest is observed. No new ledger row is necessary merely to change these two existing pins.
- Refresh changed tracked artifacts' stamp bytes in `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/stamps.tsv`. A byte-only restamp leaves membership identity unchanged.
- Conditional membership migrations: `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv`:28 R12-03 (111 stamps) and68 R24-05 (stamp path identity) change only if adding stamp members such as the new lesson; line57 R22-03 (added48) and78 R24-15 (added-path identity) follow changed membership relative to immutable history. Line29 R13-01 (43 headings) and69 R24-06 (heading identity) follow added/changed `## Round ` headings. Line54 R21-04 (79 claim IDs) and77 R24-14 (claim-ID identity) change only if L1 adds claim IDs; expectation edits alone do not change their projection. Exact BASE pins are in the receipt. Do not guess successor hashes/counts.
- Projection definitions are `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/row-identity.sh`:71–89,111–115. R24-05 hashes sorted stamp PATHS, not stamp bytes; R24-14 hashes sorted ledger IDs, not command/expectation columns; R24-06 hashes full matching heading lines in order. These identities do not bind the complete behavioral contract.
- Preserve non-owned SD6 bytes and routed R25-02 FAIL / R29-01 POLICY / R29-02 POLICY. No clearing, suppression or unrelated debt repair is needed for single C1.

Remaining unknowns: installed candidate bytes, actual after/selftest outcomes, final ledger/stamp/heading membership chosen by L1, and non-author closure. No execution is inferred from source expectations.

Report: .ufo/waves/round-35/build/ScoutPop/report.md
