# ReviewC2 report — C2 freshness, kagi round 36

**Verdict: ADMIT-WITH-CONDITIONS** (lane working-tree bytes). **REJECT** the literal F3
(only the 15 drifting rows re-dated). Raw outputs: `review.md`.

## Answers

1. **Repoint vs supersede:** yes, it supersedes. `.ufo/waves/round-26/observe-2.json`
   is unchanged (`git log` → `d30c989`; blob `e02f4de…`; sha256 `13b8540c…`; the working
   tree is clean vs HEAD). It still validates CLEAN against its own table at BASE (`cb8cb65`).
2. **Trust:** the round-36 receipt is gate output. Its structure matches
   `load_receipt_bundle` (30 records = 30 bound on-release rows, uniform 9-key shape, 64-hex
   sha256, non-decreasing timestamps, all HTTP 200, no errors). A live
   `--observe` re-run into scratch reproduces all 30 records field-for-field, including all
   30 body sha256 values.
3. **F3+F4 in scratch:**
   - Literal F3 (15 drifting rows): counter **0**, but `release-clock.py` **FAILED**
     (`RECEIPT-MISMATCH` ×15: S005–S011, S017–S020, S029–S032, whose `observed_at` is
     2026-10-21 and does not match the receipt date). Kill-rule failure.
   - Lane working tree (L1's landing): counter **0** and verify **CLEAN**
     (`on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15`, rc=0). It also
     re-dates those 15 unchanged rows (version and verdict unchanged).
4. **Table semantics:** `anchored_version`, clock, feed URL and feed id are untouched in
   every row. `derived:` notes are kept, and no DERIVATION finding appears.

## Controls (executed)

| control | result |
|---|---|
| BASE counter (cb8cb65) | 15 rc=0 |
| BASE verify (round-26 pin) | CLEAN, rc=0 |
| BASE C1 (corroboration, not assigned) | 4 rc=0 |
| forgeA table above receipt | 1 (counted) |
| forgeB table below receipt | 1 (equality, not ordering) |
| forgeC empty receipt | 20 |
| forgeD receipt removed | SETUP, rc=2 |
| forgeE receipt hand-edit | counter 1, verify FAILED rc=1 |
| forgeF receipt + table co-edited | counter **0**, verify FAILED rc=1 |

## Conditions for ADMIT

1. The round lesson (QM14 journal) records the 15 extra re-dated unchanged rows, with old
   and new `observed_at`, and why: the literal F3 cannot pass the frozen CLEAN kill rule.
2. C2 is claimed by `release-clock.py` CLEAN with the sha-pinned default. The frozen
   counter has no sha pin, and forgeF shows it alone can read 0.
3. The round-26 receipt stays committed and unchanged, cited by sha `13b8540c…`.

## Residual / gaps

- The F1 SCORECARD table and the F2 capability row were not reviewed (not assigned).
- The plan's knowledge re-verification line is not in F1–F4. No clock-state knowledge
  entry needs it (grep shows only parser examples).
- The live refetch ran about 30 minutes after the committed receipt; feeds were unchanged.

## Artifacts (build/ReviewC2/)

`review.md`, `report.md`, `sha256.txt`, `receipt-analysis.txt`, `analyze_receipt.py`,
`apply_candidate.py`, `cand-F3-literal.tsv.diff`, `cand-F4.py.diff`,
`lane-wt-vs-base.tsv.diff`, `lane-wt-vs-base-F4.py.diff`, `live-refetch-observe.json`.

## Tooling

None installed. Python 3 stdlib, bash, git, and the lane's own scripts only.
