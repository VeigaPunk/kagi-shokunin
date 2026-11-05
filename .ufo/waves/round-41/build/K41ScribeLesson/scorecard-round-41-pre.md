# SCORECARD — round 41 pre-move (draft for the L1; repo HEAD `5142b52`, round-40 close)

Claim BASE `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`; predeclaration `5142b52` (frozen plan
`plans/round-41.md` + counters `plans/round-41-c1.sh`, `plans/round-41-c2.sh` + controls
`plans/round-41-controls.sh` + the measured BASE receipts, all in one commit); round-40 landed state (the
positive control P0 of C1) `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`. Every axis stood at 9 at the
round-40 close (the SCORECARD round-40 reference line); this table is the reference line the round's two
claims are measured against. No value in it is a round-41 measurement except the named BASE readings.

Measured BASE readings for this round's two claims (the committed receipts under
`.ufo/waves/round-41/controls/`):

- **C1 calibration — BASE 0.** `plans/round-41-controls.sh` → `CONTROL c1-no-gate N=0`, receipt
  `.ufo/waves/round-41/controls/c1-control-no-gate.txt` → `0`; the BASE tree has no gate file
  (`git ls-tree 5142b52 corpus/expect-journal.sh` → empty), so the counter prints 0. The two other C1
  controls read 0 as well (`.ufo/waves/round-41/controls/c1-control-refuse-all.txt` → `0`,
  `c1-control-accept-all.txt` → `0`). Target 4.
- **C2 freshness — BASE 1.** `.ufo/waves/round-41/controls/c2-base-19025d9.txt` → `1` (a = 0, b = 0,
  c = 1). The decoy control reads 2 (`c2-control-decoy.txt` → `2`), i.e. N ≤ 2 for a paragraph that cites
  only the superseded S027. Target 3.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract, the feed-token agreement invariant and the refusal bounds. Row `R29-01`. | round 29 |
| coverage | 9 | Unchanged as a score. Measured BASE gap: 96 registry rows at BASE (`git show 19025d9:corpus/SOURCES.md \| grep -cE '^\| S[0-9]{3} '` → 96), census CLEAN (row `R21-02`); the two rows this round appends (S097, S098) are on already-held render-normalizer ground, so no new surface is claimed. | round 40 |
| operability | 9 | Unchanged as a score. Measured BASE gap: no committed journal gate exists at BASE (`corpus/expect-journal.sh` absent from `5142b52`), so nothing referees an expect loosening; the C1 gate is this round's instrument. Nothing schedules any gate. | round 40 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-41-c2.sh` reads **1** at BASE (`.ufo/waves/round-41/controls/c2-base-19025d9.txt`) — the `rendered-text-v1.py` Sources paragraph cites no `S###` id, carries no bound quote, and the U+3000 example is not on the served 3.15.2 pages (round-40 spot-check §5, §7.5); the C2 re-grounding is this round's claim. | round 40 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-41-c1.sh` reads **0** at BASE (`.ufo/waves/round-41/controls/c1-control-no-gate.txt` → `0`) — the counter cannot tell a migration from a loosening until the journal gate lands (M40-6, M40-16). | round 40 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`). | round 35 |

Scores stay 9 → 9: a claim move adds no new score; the post-move rows record what moved and which reds
remain. `⟨SLOT: L1 fills the round-41 post-move table from the landing runs⟩`
