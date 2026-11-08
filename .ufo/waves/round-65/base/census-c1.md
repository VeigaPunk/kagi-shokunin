# Round 65 BASE census — C1 (2026-11-08, lane HEAD b17887f)
Measured BASE readings (slim full-tree copies under /fast/scratch/hyaku/kagi-r65/L1Base/, checker plans/round-61-c1-check.py --no-challenge):
- R65-H1..H5 forgery: each value=0 (accepted at BASE) — the gap C1 closes.
- R65-Q1..Q3 benign: each value=0 (accepted at BASE) — the round-64 parenthetical
  and idiom classes already resolve these; they are non-harm controls, not targets.
- Unmodified copy: value=0 (i1..i7 resolved).
- Checker selftest: C1_CHECK_SELFTEST: PASS (cases=111).
Sealed file plans/round-65-heldout.tsv: 8 rows (R65-H1..H5 forgery, R65-Q1..Q3 benign),
sha256 604b2298c48504114becafbffea5078a2fe13e91135686520da606a0b03138df.
Anchors each occur exactly once in the claimed files (measured).
Whole-replacement distinctness from plans/round-64-heldout.tsv: verified (no
replacement cell appears in the round-64 file).
=> Claim matrix BASE = 5 + 0 = 5 over population 8; target matrix=0.
