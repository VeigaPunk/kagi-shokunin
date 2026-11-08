# R66MutC1 — mutation battery over `plans/round-66-c1.sh`

Seat `R66MutC1`, mutation-tester (attack seat), wave `kagi-r66-w1`, kagi round
66 attempt 1. Read-only on the lane: no lane file was written, no git/jj
mutation. Full ledger with every mutant, fixture contract and raw output:
`.ufo/waves/round-66/w1/R66MutC1/mutants.md` (receipts in the same directory).

## Freshness — bytes measured

| revision | sha256 | battery |
|---|---|---|
| `178a369d…` | pre-dispatch bytes | two blockers reported (`--selftest` recursion; S143 mutation a no-op → `hex=2`) |
| `72c95923…` | pre-hardening | 32 mutants, 24 killed, 8 survivors, selftest 0/32 |
| **`221a2cd7…`** | **final, now at `plans/round-66-c1.sh`** | **26 mutants, 23 killed, 3 equivalent survivors, selftest 6/26** |

All results below are on the final bytes (`221a2cd711003aaf5478e394bd39989f73624b83a465da1f1b83f75ed3ec172d`,
445 lines): `--selftest` `cases=29 failed=0`; real lane run
`C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` rc 0; BASE extract
`drift=0 paths=0 hex=0 match=0 guard=0` rc 1. The amended C1 target is
reachable and the BASE control does not reach it.

## Census

```
MUTANTS: population=26 killed=23 survived=3  (selftest kills=6; false-green kills=11)
```

Two detectors: the mutant's own `--selftest` (kills `W1`, `W7`, `W9`, `W10`,
`P5`, `P6` — the hardened selftest executes `drift_of`, per-leg digest
refusals, `mutation_leg`, and `verdict_ok`), and a 12-fixture behavioural
matrix with the pristine contracts re-measured: the amended candidate, BASE,
wrong-bytes, split-path, fetch-sha, fetch-prose, no-pin, two-row, missing
wrong-file, missing mutation body, a drift=1 `--base-tree`, and a broken
volatile gate. Kill types: false-green, missed-target, guard-false-positive,
match-wrong, drift-wrong.

## What the battery establishes on the final bytes

- Constant verdict/exit mutants are killed by BASE
  (`P1`/`P4` print the target on BASE and exit 0 vs rc 1).
- Guard-leg constants and dropped legs are killed by the leg fixtures
  (`stbase` for `ga`, `badvolgate` for `gc`, `nowrongfile` for `gd`, BASE for
  `gb`); `verdict_ok` guard/match drops are killed on the target/BASE.
- Wrong-id mutants are killed: digest drop, pin drop, lowest-row selection,
  fetch col10 drop, wrong-path compare, same-path drop, mutation slot
  constant, and a missing mutation body counted as performed
  (`W11` false-green on `missingbody`).
- The `match=1` literal and the missing-body false green found on the previous
  revision are **closed**: `match` is now computed from `paths_n`/`refused_n`
  and a missing wrong body reads `hex=2 match=0` rc 1.

## Survivors — all equivalent (fixes are optional hardening)

1. **`P3-paths-constant-3`** — `paths_n=3` inside the loop is identical because
   the loop runs exactly `len(WRONG_PATHS)` = 3 times; skipped when `drift=0`.
   **Fix:** a `--selftest` population case asserting `len(WRONG_PATHS)==3`.
2. **`W5-fetch-col16-search`** — `search` returns the raw cell, not the match, so
   a prose col16 still fails the later file check (`fetchprose` stays
   `drift=0`). **Fix:** delete the redundant `fullmatch`, or a
   `col16-prose-refused` selftest case.
3. **`W8-mutation-refused-constant`** — the missing-body early return bypasses
   the `refused` line, so the constant is unreachable on every fixture.
   **Fix:** a `mutation-leg-same-bytes-not-refused` case (same bytes ⇒ `d==1`,
   `refused=0`) to exercise the post-copy path.

## Shipped findings the L1 should route

1. **QM74:** `--selftest` creates its fixtures with `tempfile.mkdtemp(...,
   dir=root)` where `root` is the measured `TREE` (lines 266, 293) — a write
   inside the measured tree. Use the counter's scratch root / `TMPDIR`.
2. **Guard (a) needs `--base-tree`**, but Amendment A1's target command shows
   only `--tree <candidate>`; without the argument the counter reads
   `guard a=0`. Name the argument in the plan's command line or default a
   committed BASE receipt.
3. **A1's mutation population says `S143/S156/S157`; the counter uses
   `S148/S156/S157`** (S143 is the carrier and cannot produce `hex=3` — the
   exact no-op measured on `72c95923`). The code comments the substitution;
   the plan text needs a recorded correction.
4. `resolve_anchor` follows the highest id carrying the pin + path (measured
   target on `tworows`) — correct for `S164`, a named ceiling for later rows.

## Evidence

Real lane and selftest outputs, 312 behavioural runs, 26 selftest runs, 12
pristine baselines, survivor probes and 26 mutant shas are in
`R66MutC1/final-*`; the earlier-revision receipts are retained unprefixed.
Lane source untouched (`plans/round-66-c1.sh` `221a2cd7…` before and after;
`SOURCES.md`/`source-fetches.tsv`/`volatile-shape.py` not edited by this seat).
Scratch `/fast/scratch/hyaku/kagi-r66/R66MutC1/` deleted on exit after the copy.

SEAT-STATUS: complete
