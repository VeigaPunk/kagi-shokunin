# R66MutC1 — mutation battery over `plans/round-66-c1.sh`

Seat `R66MutC1`, mutation-tester (attack seat), wave `kagi-r66-w1`, kagi round
66 attempt 1. Read-only on the lane: no lane file was written, no git/jj
mutation. Full ledger, fixture contracts and raw outputs:
`.ufo/waves/round-66/w1/R66MutC1/mutants.md` (receipts in the same directory).


> **L1 — read this before the round-end reading.** Guard (a) needs
> `--base-tree <d549ee6 extract>`: `bash plans/round-66-c1.sh --tree <candidate>`
> alone prints `guard a=0` and rc 1. That is a missing argument, not a failed
> claim. The measured target line uses
> `--tree <candidate> --base-tree <BASE>`.

## Freshness — bytes measured

| revision | sha256 | battery |
|---|---|---|
| `178a369d…` | pre-dispatch | two blockers reported (`--selftest` recursion; S143 mutation a no-op → `hex=2`) |
| `72c95923…` | pre-hardening | 32 mutants, 24 killed, 8 survivors, selftest 0/32; literal `match=1` + missing-body false green found |
| `221a2cd7…` | hardened | 26 mutants, 23 killed, 3 equivalent survivors, selftest 6/26 |
| `bd3310b5…` | committed battery | 27 mutants, 26 killed, 1 equivalent survivor, selftest 9/27 |
| **`6a79a96d…`** | **present lane bytes: + population invariant** | **delta measured: lane target rc0, BASE rc1, selftest 43 PASS; loop-bound mutant killed (`paths=-1`); P3 constant still equivalent** |

Present bytes: `6a79a96d01ea881fbc72e66064042dbf027c6772a31d8656c2bed42210334961`
(500+8 lines, 43 selftest cases). The 27-mutant battery ran on the committed
`bd3310b5`; `6a79a96d` adds only the post-loop population invariant, and its
delta is measured in the ledger §0b. Lane run (`--tree <lane> --base-tree <d549ee6
extract>`): `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` rc 0; BASE:
`drift=0 paths=0 hex=0 match=0 guard=0` rc 1; `--selftest` `cases=43 failed=0`.

## Census

```
MUTANTS: population=27 killed=26 survived=1  (selftest kills=9; false-green kills=11)
```

Detectors: the mutant's own `--selftest`, and a 12-fixture behavioural matrix
with the pristine contracts re-measured (candidate, BASE, wrong-bytes,
split-path, fetch-sha, fetch-prose, no-pin, two-row, missing wrong-file,
missing mutation body, drift=1 base-tree, broken volatile gate). Kill types:
false-green, missed-target, guard-false-positive, drift-wrong, match-wrong.

## What the battery establishes on the final bytes

- Constant verdict/exit mutants are killed by BASE (`P1`/`P4` print the target
  on BASE / exit 0 vs rc 1).
- Guard-leg constants and dropped legs are killed by the leg fixtures
  (`stbase` for `ga`, `badvolgate` for `gc`, `nowrongfile` for `gd`, BASE for
  `gb`); `verdict_ok` guard/match drops are killed on the target/BASE.
- Wrong-id mutants are killed: digest drop, pin drop, lowest-row selection,
  fetch col10 drop, wrong-path compare, same-path drop, mutation-slot constant,
  missing mutation body counted as performed (`W11` false-green on
  `missingbody`), and the prose-cell and same-bytes cases added this round kill
  `W5`/`W8` in `--selftest`.
- `match` is measured end-to-end: `P2` (`m = 1` in `verdict_of`) is killed by
  three `--selftest` cases (`verdict-of-partial-refusal`, `verdict-of-paths2`,
  `verdict-of-base`).
- QM74 is fixed: `--selftest` builds its fixtures in the counter scratch; no
  `selftest-*` path remains under the lane after a run (checked).

## Survivor and named-equivalent call site

1. **`P3-paths-constant-3` — equivalent, and still equivalent after the fix.**
   `paths_n = 3` equals the loop count; the new invariant compares `paths_n` to
   `len(WRONG_PATHS)` = 3, so the constant satisfies it (measured on `6a79a96d`:
   lane target rc0, selftest PASS). The invariant closes the *loop-bound* class
   (my `LB1`: `FINDING population paths=1 expected=3`, `paths=-1`, rc1).
2. **`MC-callsite-match-constant` — verdict-equivalent, line-detectable.** The
   call-site `match=1` gives identical exits wherever the target is reachable,
   but on `missingbody` (`paths=3`, `refused=2`) pristine prints `match=0` and
   the mutant `match=1` (both rc1, `hex=2`). Carried as equivalent for the
   pass/fail verdict with that caveat, per the owner's note.

## Shipped findings status

1. **QM74 (selftest wrote inside the measured tree) — fixed** (`selftest(root,
   scratch)`, both fixture roots in scratch; verified no leftovers).
2. **`--base-tree` doc** — guard (a) needs it; A1's command line shows only
   `--tree`. Routed to the L1 by the executor; the counter keeps `guard=0`
   without it by design.
3. **Mutation population** — A1 says `S143/S156/S157`; the counter uses
   `S148/S156/S157` and asserts the property (three distinct bodies ≠ pin).
   Recorded in the counter header; the plan sentence is the L1's to correct.
4. **`resolve_anchor` newest-row rule** — correct for `S164`, named ceiling for
   later rows (measured target on `tworows`).

## Evidence

`R66MutC1/final-mutants4-behavior.json` (324 runs),
`final-mutants4-selftest.json` (27 runs), `final-census.json`,
`final-pristine.json` (12 baselines), `final-lane.out`,
`final-mut4-spec.json`, `final-mutant-sha256.txt`; earlier revisions retained as
`hardened221a-*` and the unprefixed first-battery files. Lane source untouched
(`plans/round-66-c1.sh` `bd3310b5…` before and after; carrier files not edited
by this seat). Scratch `/fast/scratch/hyaku/kagi-r66/R66MutC1/` deleted on exit
after the copy.

SEAT-STATUS: complete
