# Round 64 Amendment A1 baseline census (L1 re-measurement, 2026-11-08)

Claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`. Checker
`plans/round-61-c1-check.py` (2031 lines, sha `f2afd9b8…` at 0c07aab8).

Pre-amendment seal: `7ed354918ca6c6353cfd4e394edc2704b46a0a09130a9f7dbd41957572f4a249`
(`plans/round-64-heldout.tsv`, 19 data rows F1..F10/P1..P6/B3..B5 + 1 `?` row).
Amended seal: `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`
(20 rows; adds P7, removes the unfinished `?` marker; ids below are the ids
checked against the back-up file in `.ufo/waves/round-64/heldout-backup.tsv`).

## L1 probe method (slim trees, full CLI)

Trees were slimmed to the checker's seven input files + `SKILL.md` /
`w1-results.json` (the unmodified slim copy reads `value=0` exactly like the
full tree). Each fixture applied once (anchor count = 1, asserted). Probe
results — `C1_ROUTED: value=V population=7 … guard=0`, rc 1 throughout:

| id | value | i-bits |
|---|---|---|
| unmodified | 0 | i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 |
| F1 | 1 | i7=0 (swapped percentages — already rejected) |
| F2 | 0 | all 1 — a sentence-level denial appended after the pair, never tested by I7 |
| F3 | 0 | all 1 — hedge "as the earlier claim had it" is still an assertion (correct accept) |
| F4 | 0 | all 1 — idiom "no fewer than" rescues the negator (correct accept) |
| F5 | 1 | i4=0 (direct negation "did not introduce" — already rejected) |
| F6 | 0 | all 1 — a duplicated mechanism clause; I5 tests the FIRST occurrence only and the second is asserted too |
| F7 | 0 | all 1 — appended ", for a different reason than the one printed"; no item tests the reason clause |
| F8 | 0 | all 1 — a denial predicate appended after the quoted trend sentence; item4 never asserts `NO_NEW_RECORD_DEFECT_RE` |
| F9 | 1 | i7=0 (percentage swap — already rejected) |
| F10 | 0 | all 1 — an unbound duplicate percentage pair appended after the correction; item7 requires only SOME binding |
| P1 | 0 | all 1 — benign accepted at BASE already |
| P2 | 0 | all 1 — benign accepted at BASE already |
| P3 | 0 | all 1 — benign accepted at BASE already |
| P4 | 1 | i2=0 — slim-tree artifact (the same edit on the full tree leaves i2 untouched; excluded from H/Q) |
| P5 | 0 | all 1 — benign accepted at BASE already |
| P6 | 1 | i7=0 — benign rejected: the sentinel binding window widened by an em-dash aside (a negator inside the binding window; the contrastive rescue needs a `but`) |
| B3 | 1 | i7=0 — syllable-fraction swap, already rejected |
| B4 | 0 | all 1 — a negated subject (a different seat *than* the named one) binds anyway; subject negatedness is never tested |
| B5 | 1 | i4=0 — benign rejected: the idiom class `not less than` is missing from `IDIOMS` (only the `no fewer/less than` forms are listed) |

P7 (added by this amendment): a parenthetical clarification inserted between the
literal-reading subject and its pair — counted mechanism-level (the subject window
becomes 14 tokens > 8) as BASE-rejected; the commit-time counter run re-derives the
full-CLI reading. (The inserted text is deliberately not quoted here: see the
redaction note.)

## Amended population (H1..H5 + Q1..Q3, POP = 8)

Hardened target reads: H = F2 (denial after pair), F6 (duplicated mechanism),
F8 (quoted denial), F10 (unbound duplicate pair), B4 (negated subject);
Q = P6 (binding-window discourse marker), B5 (idiom class), P7 (parenthetical
between subject and pair). The remaining 11 rows (F1,F3,F4,F5,F7,F9,P1,P2,P3,
P4,P5,B3) are controls: they must still read `value>=1` on the hardened tree or
be recorded as ceilings — F3/F4/F7 document the accepted-correct and carried
ceilings (F7 has no polarity hook by design).

## Redaction note (L1, integration)

The critic's finding C1-1 measured that this file carried several of the held-out
fixtures' distinguishing strings verbatim, and the C1 seat's prompt pointed at this file.
The strings are removed above (class-level descriptions kept, all readings kept). The
breach is recorded in the round lesson and the report: the claim verifies the
instrument's behaviour on the sealed population, not that its builder never saw a
fixture string. The lookup hypothesis is separately refuted by the L1's class-only
prototype (`c1-fix-reference.md`, built from the six mechanism descriptions before this
redaction) and by the checker's structure (the verdicts are computed by the item
functions; no table maps a fixture string to a verdict).
