# R66MutC1 — mutation ledger: `plans/round-66-c1.sh` (C1_CARRIER)

Seat `R66MutC1`, mutation-tester (attack seat), wave `kagi-r66-w1`, kagi round
66 attempt 1. Read-only on the lane: no lane file was written, no commit/push,
no mutating git/jj command. Every mutant and fixture tree is a byte copy under
`/fast/scratch/hyaku/kagi-r66/R66MutC1/`.

## 0. Revisions measured (freshness)

| revision | sha256 | battery |
|---|---|---|
| first landing | `bab2ae92…` | read only |
| pre-dispatch | `178a369d…` | two blockers reported: `--selftest` recursion; S143 mutation a byte-identical no-op (`hex=2`, target unreachable) |
| pre-hardening | `72c95923…` | 32 mutants, 24 killed, 8 survivors, selftest 0/32; shipped `match=1` literal + missing-body false green reported |
| hardened | `221a2cd7…` | 26 mutants, 23 killed, 3 equivalent survivors, selftest 6/26; QM74 in-tree selftest fixtures, `--base-tree` doc, population deviation reported |
| final battery | `bd3310b5351f028c972fd2a7d3b9475f8015696b9f07558bb95125ae2ce67440` (committed in `cfafdb1`) | 27 mutants, 26 killed, 1 equivalent survivor, selftest kills 9/27 |
| **present lane bytes (post-commit invariant)** | **`6a79a96d01ea881fbc72e66064042dbf027c6772a31d8656c2bed42210334961`** | **delta measured below: lane target rc0, BASE rc1, selftest 43 PASS; loop-bound mutant killed; P3 constant still equivalent** |

All readings below are on `bd3310b5…` (500 lines, 43 selftest cases), the file
now at `plans/round-66-c1.sh`. Earlier receipts are prefixed
`hardened221a-` / unprefixed; the final set is `final-*`.

## 0b. Post-commit delta (working-tree `6a79a96d`)

`6a79a96d` = `bd3310b5` + one block, inside the `if drift == 1 and path:` guard,
after the mutation loop:

```
    if paths_n != len(WRONG_PATHS):
        print("c1-carrier: FINDING population paths=%d expected=%d" ...)
        paths_n = -1
```

Measured on the present bytes (receipts `final-lane-6a79.out`,
`final-base-6a79.out`, `final-lb1.out`):

| probe | reading |
|---|---|
| lane `--tree <lane> --base-tree <d549ee6>` | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` rc0 |
| BASE extraction | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` rc1 |
| `--selftest` | `cases=43 failed=0` |
| `LB1` — loop bound `WRONG_PATHS[:1]` | `FINDING population paths=1 expected=3`; `C1_CARRIER: drift=1 paths=-1 hex=1 match=0 guard=1` rc1; `--selftest` PASS (kill is the runtime invariant) |
| `P3` — `paths_n = 3` constant | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` rc0; `--selftest` PASS — **still equivalent**: the constant equals `len(WRONG_PATHS)`, so the invariant cannot discriminate it |

The invariant closes the loop-bound class (a mutation that performs fewer
copies), not the constant-equals-true-count class. No other battery mutant's
code path changes: the block runs only when `drift == 1 and path`, and every
other mutant either changes the loop body's per-iteration values (the invariant
still sees three iterations) or prevents the loop (drift=0).

## 1. Baseline on the final bytes

| reading | value |
|---|---|
| `--selftest` (lane/tree) | `c1-carrier: selftest cases=43 failed=0` rc 0 |
| real lane run (`--tree <lane> --base-tree <d549ee6 extract>`) | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` rc 0; `guard a=1 b=1 c=1 d=1` |
| BASE extract | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` rc 1; `guard a=1 b=0 c=1 d=1` |

A1's target is reachable on the amended tree; the BASE control does not reach
it; mutations do not run when no carrier resolves (M65-1 vacuity closed). No
`selftest-*` directory remains under the lane after a run (QM74 fixed: fixture
roots are created in the counter scratch).

## 2. Detectors and harness

1. **Instrument detector** — the mutant's own `--selftest` on the candidate
   fixture; killed iff rc ≠ 0 or the case line is not `… failed=0`.
2. **Behavioural detector** — the mutant's `--tree` verdict on a 12-fixture
   matrix with the pristine contracts re-measured (`final-pristine.json`). Kill
   types, in order: **FALSE-GREEN** (rc 0 where not-target), **MISSED-TARGET**
   (rc ≠ 0 on the target), **GUARD-FALSE-POSITIVE** (`guard=1` where a leg must
   read 0), **DRIFT-WRONG**, **MATCH-WRONG** (A1 match on `missingbody`).

Fixtures (slim trees from the amended lane; BASE from `git archive d549ee6`):

| fixture | construction | pristine |
|---|---|---|
| `cand` | amended lane tree (S164 row + fetch + volatile path + captures) | rc0 target |
| `tworows` | `cand` + `S165` row/fetch citing a byte-identical carrier copy (`S199.body`) | rc0 target (newest row wins) |
| `base` | BASE extract | rc1 `drift=0 paths=0` |
| `badbytes` | carrier bytes := `S156.body` | rc1 `drift=0`, selftest fails |
| `splitpaths` | S164 fetch col16 cites `S199.body` holding the carrier bytes | rc1 `drift=0` |
| `fetzsha` | S164 fetch col10 zeroed | rc1 `drift=0` |
| `fetchprose` | S164 fetch col16 is prose quoting the path | rc1 `drift=0` |
| `nopin164` | S164 row loses the pin text | rc1 `drift=0` |
| `nowrongfile` | `cand` minus `S148.body` | rc1 `drift=1 hex=2 match=0 guard=0` |
| `missingbody` | `cand` minus `S157.body` | rc1 `drift=1 hex=2 match=0 guard=1` |
| `stbase` | `cand` with `--base-tree` = a drift=1 tree | rc1 `drift=1 guard=0` |
| `badvolgate` | `cand` with the volatile gate's `PIN_SHA` changed | rc1 `drift=1 guard=0` |

## 3. Census on the final bytes

```
MUTANTS: population=27 killed=26 survived=1  (selftest kills=9; false-green kills=11)
```

Selftest kills: `W1`, `W5`, `W7`, `W8`, `W9`, `W10`, `P2`, `P5`, `P6` — the
hardened selftest now executes `drift_of`, per-leg digest refusals,
`mutation_leg` (including the same-bytes and prose cases), `verdict_of`, and
`verdict_ok` boundaries. Kill-type instances: FALSE-GREEN 31 across 11 mutants,
GUARD-FALSE-POSITIVE 19, MISSED-TARGET 17, DRIFT-WRONG 6, MATCH-WRONG 2.

## 4. Mutant table (final bytes `bd3310b5…`)

| id | class | rule mutated | selftest | verdict | kill fixture | kill type | observed verdict line |
|---|---|---|---|---|---|---|---|
| `MC-callsite-match-constant` | constant-print | call site passed `match=1` to `verdict_ok` (executor-named equivalent candidate) | survived | KILLED | missingbody | MATCH-WRONG | `C1_CARRIER: drift=1 paths=3 hex=2 match=1 guard=1` |
| `P1-verdict-exit-constant-target` | constant-print | verdict line and exit replaced by the constant target | survived | KILLED | base | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `P2-match-constant-1` | constant-print | `m = 1` inside `verdict_of` (match constant) | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `P3-paths-constant-3` | constant-print | `paths_n = 3` constant in the mutation loop | survived | SURVIVED | — | equivalent (§4b) | `` |
| `P4-exit-always-0` | constant-print | `raise SystemExit(0)` constant | survived | KILLED | base | FALSE-GREEN | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` |
| `P5-verdict-drops-guard` | constant-print | `verdict_ok` drops the `guard == 1` conjunct | KILLED | KILLED | stbase | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `P6-verdict-drops-match` | constant-print | `verdict_ok` drops the `match == 1` conjunct | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `G1-guard-constant-1` | guard-constant | `guard = 1` constant | survived | KILLED | base | GUARD-FALSE-POSITIVE | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=1` |
| `G2-ga-constant-1` | guard-constant | `ga = 1` (BASE leg) constant | survived | KILLED | stbase | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `G3-gb-constant-1` | guard-constant | `gb = 1` (selftest leg) constant | survived | KILLED | base | GUARD-FALSE-POSITIVE | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=1` |
| `G4-gc-constant-1` | guard-constant | `gc = 1` (volatile leg) constant | survived | KILLED | badvolgate | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `G5-gd-constant-1` | guard-constant | `gd = 1` (wrong-path leg) constant | survived | KILLED | nowrongfile | GUARD-FALSE-POSITIVE | `C1_CARRIER: drift=1 paths=3 hex=2 match=0 guard=1` |
| `G6-guard-drops-ga` | guard-constant | guard composition drops `ga` | survived | KILLED | stbase | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `G7-guard-drops-gd` | guard-constant | guard composition drops `gd` | survived | KILLED | nowrongfile | GUARD-FALSE-POSITIVE | `C1_CARRIER: drift=1 paths=3 hex=2 match=0 guard=1` |
| `G8-guard-drops-gc` | guard-constant | guard composition drops `gc` | survived | KILLED | badvolgate | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `G9-guard-drops-gb` | guard-constant | guard composition drops `gb` | survived | KILLED | base | GUARD-FALSE-POSITIVE | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=1` |
| `W1-drift-digest-dropped` | wrong-id | `drift_of` per-anchor digest comparison replaced by `if False` | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=0 guard=0` |
| `W10-mutation-slot-constant` | wrong-id | mutation slot hardcoded to round-64 `S143.body` | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `W11-missing-body-passes` | wrong-id | missing mutation source counted as performed+refused | survived | KILLED | missingbody | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `W2-anchor-pin-dropped` | wrong-id | row-selection pin test dropped | survived | KILLED | nopin164 | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `W3-anchor-lowest-row` | wrong-id | superseding-row selection inverted to the lowest id | survived | KILLED | tworows | MISSED-TARGET | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` |
| `W4-fetch-col10-dropped` | wrong-id | fetch column 10 pin check dropped | survived | KILLED | fetzsha | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `W5-fetch-col16-search` | wrong-id | col16 `fullmatch` relaxed to `search` (raw cell still used as the path) | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `W6-samepath-dropped` | wrong-id | same-path conjunct of `drift` dropped | survived | KILLED | splitpaths | DRIFT-WRONG | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `W7-digest-wrong-compare` | wrong-id | digest compared against `PIN_BYTES` | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` |
| `W8-mutation-refused-constant` | wrong-id | `refused = 1` constant on the post-copy path | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `W9-mutation-hex-constant` | wrong-id | `hex_diff = 1` constant | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |

## 4b. Survivor and the named-equivalent call site

### `P3-paths-constant-3` — equivalent

`paths_n = 3` replaces `paths_n += 1` inside the mutation loop. The loop runs
exactly `len(WRONG_PATHS)` = 3 times when `drift == 1`, and is skipped entirely
when `drift != 1`, so the constant is unreachable as a difference. Post-commit
the counter asserts `paths_n == len(WRONG_PATHS)` after the loop; the constant
equals that value, so it is **still equivalent** (measured on `6a79a96d`: lane
target rc0, selftest PASS). The invariant does close the *loop-bound* class
(measured `LB1`: `paths=-1`, rc1). **Fix (optional):** derive `paths_n` from the
loop (it already is) and drop the separate counter, or assert per-iteration
identity; no fixture can distinguish a constant equal to the true count.

### `MC-callsite-match-constant` — verdict-equivalent, line-detectable

Named by the executor as an equivalent survivor: replacing the call site with
`match, exit_code = 1, verdict_ok(..., 1, guard)`. On every fixture where the
target is reachable the inputs have `match_of == 1`, so the exit is identical.
It is **not line-identical** on a partial-refusal tree: on `missingbody`
(`paths=3`, `refused=2`) pristine prints `match=0` and the mutant prints
`match=1` (both rc1 because `hex=2`). Carried as equivalent for the pass/fail
verdict with that caveat; the measured line is in the table.

## 5. Shipped-finding status on the final bytes

1. **QM74 (in-tree selftest fixtures) — fixed.** `selftest(root, scratch)` now
   creates both fixture roots in the counter scratch; no `selftest-*` path
   exists under the lane after a run (checked).
2. **`--base-tree` documentation — routed.** Guard (a) still reads 0 without
   the argument by design; the executor routed the plan-command correction to
   the L1. A reader reproducing A1's `--tree <candidate>` line gets `guard a=0`;
   the counter's usage line names `--base-tree`.
3. **Mutation population — recorded in the counter header.** A1's sentence says
   `S143/S156/S157`; the counter mutates `S148/S156/S157` and asserts the
   property (three distinct wrong bodies, each ≠ the pin) instead of the ids.
   The plan text remains the L1's to correct.
4. **`resolve_anchor` newest-row rule** — correct for `S164`; a later row with
   the pin and a capture path would take over the binding (measured target on
   `tworows`). Named ceiling.
5. **Guard (c) fallback** — when the tree carries no gate, `LANE`'s gate runs
   with `--capture TREE/path`; the measured bytes are the candidate's.

## 6. Restoration and evidence

- Lane source untouched: `plans/round-66-c1.sh` `bd3310b5…` before and after
  the battery; `corpus/SOURCES.md` `297fedc1…`, `corpus/source-fetches.tsv`
  `ffb0d8bf…`, `corpus/volatile-shape.py` `48fd3e27…` were not edited by this
  seat.
- Final receipts: `final-mutants4-behavior.json` (324 runs),
  `final-mutants4-selftest.json` (27 runs), `final-census.json`,
  `final-pristine.json` (12 baselines), `final-lane.out`, `final-mut4-spec.json`,
  `final-mutant-sha256.txt` (27 shas).
- Earlier revisions retained: `hardened221a-*` (221a2cd7) and the unprefixed
  first-battery files (72c95923).
- Scratch `/fast/scratch/hyaku/kagi-r66/R66MutC1/` is deleted on exit after the
  copy.
