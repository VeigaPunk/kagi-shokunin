# Round-35 producer-result reference inventory

Read-time locators only; L1 must adapt to concurrent owned edits. No execution inferred and no final case total guessed.

## Active selftest pins and doc copies

| Location | Read-time literal | Disposition |
|---|---|---|
| SKILL.md:820 | `(12 cases; round 34)` | Replace with count-neutral ledger pointer; draft supplied. |
| PROVINCE.md:77 | `--selftest proves 12 cases (round 34 adds relative-work)` | Replace with count-neutral ledger pointer; draft supplied. |
| corpus/README.md:92 | same 12-case assertion | Replace with count-neutral ledger pointer; draft supplied. |
| corpus/claim-ledger.tsv:93, R33-01 | `^PREFREEZE_SELFTEST: PASS \(12 cases\)$` | ACTIVE executable pin: migrate only to actual observed final selftest total; retain old/new journal and original round34 11→12 note. |
| corpus/claim-ledger.tsv:96, R34-02 | `^PREFREEZE_SELFTEST: PASS \(12 cases\)$` | SECOND ACTIVE pin: same actual migration required. Updating R33-01 alone leaves stale expectation. |
| corpus/prefreeze-control.sh:38 | `proves twelve cases` | Executor-owned header; change consistently or use count-neutral wording. |
| corpus/prefreeze-control.sh:46,192,195 | generic `<k>` / `%d` selftest output | Already count-neutral; preserve exact emitted format. |
| corpus/knowledge/prefreeze-controls.md:54–56 | generic `<k> cases` | Already count-neutral; preserve historical body and append erratum. |

The frozen measurement instrument has nine public-path cases (.ufo/waves/round-35/controls/measure.py:6–16). That is NOT the selftest case total. Its target and before values are declaration/receipt references, not a run performed by this seat.

## Current stale contract copies beyond the four requested docs

- SCORECARD.md:706 capability row currently says `read the last non-empty stdout line's final integer`, with `--selftest PASS ≥8 cases`. This is live capability prose, not a round-history row. L1 should replace the measurement phrase with strict producer-envelope language without changing first-working round33 or rewriting its old red receipt. Proposed exact phrase replacement:
  - Before: `read the last non-empty stdout line's final integer and compare it with the frozen `expect``
  - New: `accept only one nonempty unsigned-integer stdout line with no stderr and rc0, or rc1 with zero only, then compare it with the frozen `expect`; other producer results are `NORESULT`/final SETUP exit 2`
- corpus/prefreeze-control.sh:15–20,29–34 describe final-digit extraction, ignored exits, and old ceiling. These are executor-owned active comments; must be aligned with the actual candidate, not merely supplemented by docs.
- corpus/knowledge/prefreeze-controls.md:46–47,60–65 contain the old rule and erroneous equivalence with claim-ledger last-line parsing. Preserve those bytes as history, but the appended erratum explicitly supersedes those precise sections and distinguishes the contracts.
- corpus/SOURCES.md:95 S088 and corpus/source-fetches.tsv:131 describe/capture the old pinned 97b35ce source. They remain immutable source evidence, not proof of new implementation. No repointing, registry append, or provenance migration is authorized by the frozen plan. Source curation belongs to its seat; this seat did not contact any source.

## Ledger/stamps/self-counts dependencies

- corpus/self-counts.tsv:1–81 read in full. No prefreeze-specific binding is present in that read snapshot. Count-neutral changes above therefore do not need new count rows or deletion of existing rows. This is static table inspection, not a passing self-counts run.
- Current aggregate bindings: SKILL.md:46, PROVINCE.md:73, corpus/README.md:64–65 state 111 stamps / 79 claims. Bound by self-counts.tsv:15–16,34–35,46–47 to ledger R12-03/R21-04. Do not change these because the selftest case total changes. If L1 changes actual membership, measure and migrate their defining ledger rows and all bound doc copies, not just prose.
- corpus/claim-ledger.tsv:28 R12-03 = `^111$`; :54 R21-04 = `^79$`; identity companions :68 R24-05 stamps count111+digest and :77 R24-14 ledger-ids count79+digest. Pure existing-file edits and expectation edits do not by themselves change path/id membership.
- Existing stamp entries to refresh after final L1 edits: corpus/stamps.tsv:2 PROVINCE.md, :5 SKILL.md, :7 corpus/README.md, :13 corpus/claim-ledger.tsv, :55 corpus/knowledge/prefreeze-controls.md, :96 corpus/prefreeze-control.sh. Additional conditional entries: :3 SCORECARD.md, :104 corpus/self-counts.tsv (only if edited). Preserve stamp membership; never replace the complete stamp set with only touched paths.
- Entry Reverify is corpus/knowledge/prefreeze-controls.md:16 `R33-01`; no new entry or row identity is required to retain this link.

## Historical material retained

LOG.md:1681 (round33 final-integer description/PASS11), :1689 (round34 prefreeze11 baseline), :1691 (relative-work addition); SCORECARD.md:1342 (round33 last-integer description), :1345 (round33 ≥8), :1358 (twelfth case), :1366 (PASS11→PASS12) are explicitly round-context history. Do not bulk replace historical counts or turn old receipts into new-contract outcomes. Likewise leave frozen plans, round33/34 lessons, captures and .ufo receipt populations untouched. Non-owned SD6 and routed R25-02 FAIL/R29-01/R29-02 POLICY remain outside this draft's repair.

## Search provenance

Used specialized read/glob/grep tools only. Search patterns included `prefreeze|last.integer|selftest|self-counts|stamps|ledger`, `prefreeze|R33-01|R33-02|111|79`, `prefreeze|PREFREEZE_SELFTEST|last integer|final run of digits`, and `12 cases|twelve cases|prefreeze12|PREFREEZE_SELFTEST`. A broad lane search included historical .ufo files and returned partial paginated results; it was not used as an exhaustive absence proof. Replaced it with a bounded search over lane-root Markdown, corpus top-level Markdown/TSV/shell and corpus/knowledge Markdown, explicitly excluding .ufo/plans/lessons, plus complete reads of the four docs' relevant sections and self-counts.tsv. Tool truncation was resolved for exact replacement snippets and the two ledger pins with raw line reads.
