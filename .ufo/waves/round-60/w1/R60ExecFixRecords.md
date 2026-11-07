# R60ExecFixRecords — round-60 w1 report

Seat scope: append-only record repairs I1, I2, I4 (frozen plan `plans/round-60.md` §C1;
spot-check `corpus/lessons/round-59-verifier-spotcheck.md` §7 D1/D2/D4). No predicate,
target, POP, kill rule or item condition touched; no frozen line rewritten.

## Files changed (all append-only; `git diff --numstat` → 0 deletions each)

- `LOG.md` (+4): after the last `__DEAD__` line (1965), block headed exactly
  `## Round 59 — correction` (em dash U+2014, verified `e2 80 94`). Bullet states
  `results=14 dead seats=0` over `.ufo/waves/round-59/w1-results.json`, says the
  superseded line is not rewritten, and does NOT re-quote the `__DEAD__` literal
  (quoting it would move the "last `__DEAD__` line" inside the block — caught by
  R60ReviewerC1 mid-flight, fixed before receipt).
- `corpus/lessons/round-59.md` (+2): after the R31 row (line 206, its first and only
  occurrence), a correction line carrying `supersedes R31`, naming
  `C1_CHECK_SELFTEST`, and stating `PASS (33 cases)` — the last-integer in the line
  is 33 (trailing "32" references removed after reviewer note).
- `SCORECARD.md` (+4): errata block `## Errata — round 59 controls census` at EOF,
  line carries `supersedes SCORECARD.md:1971`, states `20 controls`, quotes the
  `grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt` command,
  and names the superseded text as "the row's stated 21-controls parenthetical"
  WITHOUT the literal `(21 controls` string — quoting it would make the correction
  line itself the last `\(21 controls` match and break the item's positional
  condition (caught by R60ReviewerC1, fixed).

## Derivations (receipts: `.ufo/waves/round-60/build/R60ExecFixRecords/{i1,i2,i4,diff}.txt`)

- I1: `python3 -c` over `w1-results.json` → `R=14 D=0` (14 result records, 0 with
  empty/absent `output`).
- I2: last `C1_CHECK_SELFTEST: PASS (N cases)` line of
  `.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt` → `(33 cases)` → N=33.
- I4: `grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt` → 20.

## Deliberate spelling decision — `dead seats=0`, not `dead=0`

The item row writes `results=<R> dead=<D>`; the frozen GUARD mutates "the digit in
the I1 correction line's `dead seats=<n>` field". For GUARD=1 the mutation must flip
i1, so the item-D MUST be read from the `dead seats=` field — a strict
`results=(\d+) dead=(\d+)` item-regex would make the guard un-fireable on ANY tree
(GUARD=0 → C1 FAIL), so no self-consistent checker can use it. `results=14 dead
seats=0` is the unique spelling that satisfies tolerant (`dead(?: seats)?=`) and
`dead seats=`-specific parses alike; adding a separate `dead=0` token would let a
leftmost-tolerant regex read the unmutated field and break the challenge. Flagged
to R60ExecCounterC1 for regex confirmation; no reply yet at report time.

## Out-of-scope observations (not mine to land; reported for the L1)

- I6 has no anchor: `grep -c '75165a07' SCORECARD.md` → 0 (also 0 for `75165a0`).
  The hash exists only in `corpus/lessons/round-59-verifier-spotcheck.md` and
  `plans/round-60.md`. I6 requires "the round-59 line containing `75165a07`" on
  SCORECARD.md — likely a plan defect; R60ReviewerC1 says they are filing it.
- I7's SKILL.md registry row still carries the `none — its own five shims…` selftest
  cell per R60ReviewerC1 (i7=0 until re-registered) — that seat's item, not mine.

SEAT-STATUS: complete
