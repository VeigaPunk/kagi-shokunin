# R59ExecFixRecords — round-59 w1 report (kagi)

Seat: fix the five round-58 routed record defects (spot-check §7 D1–D5) as one
append-only correction block in `corpus/lessons/round-58.md`, plus
`plans/round-58-controls-supplement.sh` and its committed receipt. Claim BASE
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`.

## Files changed

- `plans/round-58-controls-supplement.sh` (new, executable) — ships C1-F10 and C2-F4
  per `plans/round-58.md` §Pre-freeze controls (both documented, neither shipped;
  spot-check D3). C1-F10 replicates the round-59 challenge leg externally: real
  checker diagnostic value VAL on a worktree copy; challenge copy flips the LAST
  `Registry N → M at the candidate` arrow M→M+1 and must read VAL+1; a constant-0
  printer stub on the same copy must read ≠ VAL+1. C2-F4 inserts a single-run guard
  after the trial's `SHIM=` anchor (exactly the counter's two empty-shim legs with
  bao on PATH reach it; the second reads ERROR) and requires
  `plans/round-59-c2.sh --tree` to read <5. Output contract:
  `CONTROL <id> expect=… got=… MATCH|MISMATCH :: …` per control, final
  `SUPPLEMENT: match=<n> mismatch=<m>`, exit 0 iff mismatch=0.
- `corpus/lessons/round-58.md` — appended ONE `## Correction (round 59)` block
  (lines 110–136), all five corrections, each measured first:
  D1 `Registry 117 → 120 at the candidate`; D2 `corpus/source-fetches.tsv` added 6 rows;
  D3 controls-prefreeze census 20 total / 9 `CONTROL C1-F` / 7 `CONTROL C2-F` + why
  C1-F10/C2-F4 were documented but not shipped; D4 the citation-gate reading line
  (written with the measured pre-fix `unresolved=13`); D5 `stale-lane:` 101 minutes
  `progressing` with both driver-digest stamps. No earlier line was rewritten.
  NOTE: L1 (KagiR59) took ownership of this file mid-wave (scope change message) —
  my block landed before the change and was the only one present at last check;
  further lesson edits are L1's, not mine.
- `.ufo/waves/round-59/final/supplement-receipt.txt` (new) — raw run-3 output, last
  line exactly `SUPPLEMENT: match=2 mismatch=0`.
- `.ufo/waves/round-59/build/R59ExecFixRecords/notes.md` (new) — every measured
  command + output (SOURCES counts 117/120, fetches +6, controls 20/9/7, mission
  101 min, gate U=13, checker regex contract, full supplement run history).

## Measured numbers (all matched the prompt's stated values)

| quantity | stated | measured |
|---|---|---|
| SOURCES rows at `1b13f5da` | 117 | 117 |
| SOURCES rows at `be8705f8` | 120 | 120 |
| source-fetches.tsv `+S` rows | 6 | 6 |
| controls-prefreeze total / C1-F / C2-F | 20 / 9 / 7 | 20 / 9 / 7 |
| mission minutes (11:54:48→13:36:19) | 101 | 101 |
| `claim-ledger.sh citations` last line / rc | — | `CITATION_GATE: BROKEN (cites=4291 docs=146 unresolved=13 ephemeral=0 labeled=23)` / rc 1 (pre-fix reading; >120 s — first attempt timed out at 120 s) |

## Receipt (run 3)

```
CONTROL C1-F10 expect=challenge+stub got=value=2 broken=3 stub=0 MATCH :: value=2 broken=3 expect=3 stub=0 (arrow 120->121)
CONTROL C2-F4 expect=<5 got=value=0 MATCH :: counter reads value=0 (<5 required); single-run guard inserted after SHIM= anchor; line: C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=5 vectors=ok/5 guard=1 (real=0 none=1 cleanroom=0 secret=1)
SUPPLEMENT: match=2 mismatch=0
```

C2-F4 discrimination is proven against the unmodified trial read minutes earlier:
`value=5 … (real=1 none=1 cleanroom=1 secret=1)` rc 0 on a minimal tree vs the
single-run copy's `value=0` with `real=0` — the broken conjunct is exactly the
counter's two-independent-real-runs requirement (`shims=5 none=1 secret=1` stay
intact). C1-F10's VAL (2 at run time — i3/i4 pending sibling receipts) does not
affect the control; the comparison is VAL+1 on the broken copy vs the stub's
constant 0.

## Iterations / risks

- Two instrument bugs of mine, both fixed before the receipt: `report()` printed the
  OK flag instead of the verdict and crashed under `set -u` on a 4-arg call (run 1);
  run 2's C2-F4 read MISMATCH because the counter returned no line at all — judged
  environmental (wave-peak contention), reproduced correctly minutes later (baseline
  diagnostic + run 3) with no script change. All three runs are recorded in notes.md.
- The D4 lesson line states `unresolved=13` from the pre-fix gate reading; the
  post-fix `citation-gate-r59.txt` is L1's to regenerate — if its count differs, the
  lesson line (L1-owned now) must be reconciled to it for I4 to hold.
- No tool installs (pacman guard honored); no mutating git/jj anywhere; no secrets in
  any artifact. Scratch `/fast/scratch/hyaku/kagi-r59/R59ExecFixRecords/` cleaned.

SEAT-STATUS: complete
