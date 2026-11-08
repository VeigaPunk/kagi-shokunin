# R66MutC1 — mutation ledger: `plans/round-66-c1.sh` (C1_CARRIER)

Seat `R66MutC1`, mutation-tester (attack seat), wave `kagi-r66-w1`, kagi round 66
attempt 1. Read-only on the lane: no lane file was written, no commit/push, no
mutating git/jj command. Every mutant and fixture tree is a byte copy under
`/fast/scratch/hyaku/kagi-r66/R66MutC1/`.

## 0. Revisions measured (freshness)

| revision | sha256 | measured result |
|---|---|---|
| first landing | `bab2ae92fe479b577d31dc7cf8c6cf8c5e1010824397c56b09f592b3ac37ea61` | read only |
| pre-dispatch | `178a369d7c7025451837d97778835c4275ceff183645281d8f9566016a88b54c` | two blockers reported to the owner: `--selftest` had no dispatch (recursion, rc 124) and the S143 mutation copied the carrier's own bytes (`hex=2`, target unreachable) |
| first battery | `72c9592362e356d42a7744b0d8581f100f0866ac0402821114d3331ed8c5a549` | 32 mutants, 24 behavioural kills, 8 survivors; selftest killed 0/32; shipped `match=1` literal and the missing-body false green found; reported |
| **final bytes (this ledger)** | **`221a2cd711003aaf5478e394bd39989f73624b83a465da1f1b83f75ed3ec172d`** | **26 mutants, 23 killed, 3 equivalent survivors; selftest kills 6/26** |

The L1 landed the hardened bytes after the first battery; all readings below are
on `221a2cd7…` (445 lines, 19871 B), the file now at `plans/round-66-c1.sh`.
Earlier raw outputs remain here as `mutants-*.json` / `lane-real.out`; the final
set is prefixed `final-`.

## 1. Baseline on the final bytes

| reading | value |
|---|---|
| `--selftest` on the lane | `c1-carrier: selftest cases=29 failed=0` rc 0 |
| real lane run (`--tree <lane> --base-tree <d549ee6 extract>`) | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` rc 0; `guard a=1 b=1 c=1 d=1` |
| BASE extract run | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` rc 1; guard `a=1 b=0 c=1 d=1` |

The amended predicate (plan Amendment A1) is reachable on the amended tree, and
the BASE reading is `drift=0 paths=0` (the M65-1 vacuity is closed: mutations do
not run when no carrier resolves). Full outputs: `final-lane-final.out`,
`final-lane-final-selftest.out`, `final-pristine3.json`.

## 2. Detectors and harness

1. **Instrument detector** — the mutant's own `--selftest` on the candidate
   fixture; killed iff rc ≠ 0 or the case line is not `… failed=0`.
2. **Behavioural detector** — the mutant's `--tree` verdict on a fixture matrix.
   Kill rules, in order of strength: **FALSE-GREEN** (rc 0 where the frozen
   predicate says not-target), **MISSED-TARGET** (rc ≠ 0 on a target fixture),
   **GUARD-FALSE-POSITIVE** (`guard=1` where a named leg must read 0),
   **MATCH-WRONG** (`match` disagrees with A1's definition on the `missingbody`
   fixture), **DRIFT-WRONG**.

Fixtures (slim trees; shas in `final-mutant-sha256.txt` context; pristine
contracts re-measured, `final-pristine3.json`):

| fixture | construction | pristine |
|---|---|---|
| `cand` | the amended lane tree, slim (`S164` row + fetch + volatile path + captures) | rc0 target |
| `base` | `git archive d549ee6` extract | rc1 `drift=0 paths=0` |
| `tworows` | `cand` + `S165` row/fetch citing a byte-identical carrier copy (`S199.body`) | rc0 target (newest row wins) |
| `badbytes` | carrier bytes replaced by `S156.body`, anchors unchanged | rc1 `drift=0`, selftest fails |
| `splitpaths` | `S164` fetch col16 cites `S199.body` holding the carrier bytes | rc1 `drift=0` (same-path conjunct) |
| `fetzsha` | `S164` fetch col10 zeroed | rc1 `drift=0` |
| `fetchprose` | `S164` fetch col16 is prose carrying the carrier path | rc1 `drift=0` (`fullmatch` refuses) |
| `nopin164` | `S164` row loses the pin text, keeps the path | rc1 `drift=0` |
| `nowrongfile` | `cand` minus `.ufo/waves/round-64/capture/S148.body` | rc1 `drift=1 hex=2 match=0 guard=0` (leg d fails) |
| `missingbody` | `cand` minus `S157.body` | rc1 `drift=1 hex=2 match=0 guard=1` (leg b/c/d pass; `match=0` by A1) |
| `stbase` | `cand` with `--base-tree` = a drift=1 tree (`basecopy`) | rc1 `drift=1 guard=0` (leg a fails) |
| `badvolgate` | `cand` with `volatile-shape.py` `PIN_SHA` changed | rc1 `drift=1 guard=0` (leg c fails) |

The measured candidate tree is the lane itself; the harness copies are slim
and are only the measured trees. The lane file's guard (b) selftest is run
in-process; the lane is never written except for the transient `selftest-*`
directories the counter itself creates (see §5).

## 3. Census on the final bytes

```
MUTANTS: population=26 killed=23 survived=3  (selftest kills=6; false-green kills=11)
CONTROL: not needed for a census; the hardened selftest's own negative cases
         (wrong-file-run, pathless-row, mutation-leg, verdict boundaries) are
         shipped and measured PASS.
```

Kill types across the 23: FALSE-GREEN 31 fixture-instances on 11 mutants,
GUARD-FALSE-POSITIVE 19 on 9 mutants, MISSED-TARGET 11 on 5 mutants,
DRIFT-WRONG 6, MATCH-WRONG 1. The 6 selftest kills are `W1`, `W7`, `W9`,
`W10`, `P5`, `P6` — the hardened selftest now executes `drift_of`, per-leg
digest refusals, `mutation_leg`, and `verdict_ok` (QM82/QM84 for these classes).

## 4. Mutant table (final bytes `221a2cd7…`)

| id | class | rule mutated | selftest | verdict | kill fixture | kill type | observed verdict line |
|---|---|---|---|---|---|---|---|
| `P1-verdict-exit-constant-target` | constant-print | verdict line and exit replaced by the constant target | survived | KILLED | base | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `P2-match-constant-1` | constant-print | `match = 1` constant | survived | KILLED | missingbody | MATCH-WRONG | `C1_CARRIER: drift=1 paths=3 hex=2 match=1 guard=1` |
| `P3-paths-constant-3` | constant-print | `paths_n = 3` constant in the mutation loop | survived | SURVIVED | — | equivalent (see §4) | `` |
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
| `W11-missing-body-passes` | wrong-id | missing mutation source returns `(1,1,[])` (counts as performed+refused) | survived | KILLED | missingbody | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `W2-anchor-pin-dropped` | wrong-id | row-selection pin test (`PIN not in line`) dropped | survived | KILLED | nopin164 | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `W3-anchor-lowest-row` | wrong-id | superseding-row selection inverted to the lowest id | survived | KILLED | tworows | MISSED-TARGET | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` |
| `W4-fetch-col10-dropped` | wrong-id | fetch column 10 pin check dropped | survived | KILLED | fetzsha | FALSE-GREEN | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=1` |
| `W5-fetch-col16-search` | wrong-id | col16 `fullmatch` relaxed to `search` (raw cell still used as the path) | survived | SURVIVED | — | equivalent (see §4) | `` |
| `W6-samepath-dropped` | wrong-id | same-path conjunct of `drift` dropped | survived | KILLED | splitpaths | DRIFT-WRONG | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |
| `W7-digest-wrong-compare` | wrong-id | digest compared against `PIN_BYTES` (type-confused, always mismatch) | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=0 paths=0 hex=0 match=0 guard=0` |
| `W8-mutation-refused-constant` | wrong-id | `refused = 1` constant on the post-copy path | survived | SURVIVED | — | equivalent (see §4) | `` |
| `W9-mutation-hex-constant` | wrong-id | `hex_diff = 1` constant | KILLED | KILLED | cand | MISSED-TARGET | `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=0` |

## 4b. Survivors — all three equivalent, with the measurement and the optional fix

### `P3-paths-constant-3` — equivalent

`paths_n = 3` replaces `paths_n += 1` inside the mutation loop. On every tree
where the loop runs it runs exactly `len(WRONG_PATHS)` = 3 times; on a tree where
`drift != 1` the loop is skipped and the constant is not reached. Measured:
`cand` rc0 target, `missingbody` `paths=3`, `fetchprose` `paths=0` — identical to
pristine. **Fix:** add a population case to `--selftest` asserting
`len(WRONG_PATHS) == 3` and `paths_n == len(WRONG_PATHS)`, so the constant is
documented rather than silently equivalent.

### `W5-fetch-col16-search` — equivalent (defence in depth)

`PATH_RE.fullmatch` relaxed to `search`. The mutated `resolve_fetch` still
returns the **raw** 16th cell, so a prose cell (`fetchprose`: ``see `.ufo/…/S143.body` here``)
yields an invalid path, `drift_of` reads path-missing, and the verdict stays
`drift=0` rc1 — measured identical to pristine. The `fullmatch` gate is therefore
redundant with the later file check. **Fix (optional):** delete the redundant
gate, or add `col16-prose-refused` to `--selftest` (asserting the prose cell is
refused) so the redundancy is explicit.

### `W8-mutation-refused-constant` — equivalent (early return bypasses the line)

`refused = 1` on the post-copy path. `mutation_leg` returns
`(0, 0, ["mutation-body-absent:…"])` **before** that line when the wrong body is
missing, so the only non-refusal path in the code never reaches the constant.
Measured on `missingbody`: `FINDING mut-2 … mutation-body-absent`, `match=0`,
rc1 — identical to pristine. **Fix:** add a
`mutation-leg-same-bytes-not-refused` case (a `wrong` body whose bytes equal the
carrier) to `--selftest`, exercising `d == 1` on the post-copy path; no current
case does.

## 5. Shipped findings in the final bytes (not mutants)

1. **`--selftest` writes inside the measured tree (QM74).** Lines 266 and 293
   create `selftest-*` / `selftest-legs-*` with `tempfile.mkdtemp(..., dir=root)`
   where `root` is `TREE`. The finally clause removes them, but an instrument
   must not write inside the tree it measures (the same rule the counter's own
   `scratch_root` enforces for its scratch). Fix: use `root_scratch` (or the
   already-exported `TMPDIR`) as the `dir`.
2. **Guard (a) needs an argument the frozen command line omits.** A1's target
   line is `bash plans/round-66-c1.sh --tree <candidate>`; the counter reads
   `guard a=0` unless `--base-tree <d549ee6 extract>` is passed. The lane
   receipt passes it; the plan text and the counter's help should name the
   required argument (or default to a committed BASE receipt), otherwise a
   reader reproducing the predicate gets a non-target reading.
3. **Mutation population differs from A1's text.** A1 says the copies hold
   round-64 `S143/S156/S157`; the counter uses `S148/S156/S157` and documents
   why (`S143.body` is the carrier itself — copying it into its own slot is a
   no-op that cannot produce `hex=3 match=1`; the first battery measured exactly
   that on `72c95923`). The code comment records it; the plan text does not.
   Record the substitution as a plan correction before the reading, or the
   predicate and the counter disagree on `hex=3`'s population.
4. **`resolve_anchor` picks the highest id** carrying the pin and a path. That is
   correct for `S164` today; a later byte-identical row would silently take over
   the binding (measured `tworows` target). Named ceiling, not a defect.
5. **Guard (c) fallback:** when `TREE` carries no gate, the counter runs
   `LANE/corpus/volatile-shape.py` with `--capture TREE/path`, so the measured
   bytes are the candidate's; the exit code and line are the gate's own.
6. The missing-body leg now reads `hex=2 match=0` and rc1 (the 72c95923 false
   green is closed); measured `missingbody`.

## 6. Restoration and evidence

- Lane source untouched: `plans/round-66-c1.sh` `221a2cd7…` before and after the
  battery; `corpus/SOURCES.md`, `corpus/source-fetches.tsv` and
  `corpus/volatile-shape.py` were not edited by this seat (their current shas
  are recorded in the round's own receipts; the L1's repair commit owns them).
- Final receipts in this directory: `final-mutants3-behavior.json` (312 runs),
  `final-mutants3-selftest.json` (26 runs), `final-census.json`,
  `final-pristine3.json` (12 fixture baselines), `final-lane-final.out`,
  `final-lane-final-selftest.out`, `final-mut3-spec.json`,
  `final-survivor-probes.json`, `final-mutant-sha256.txt` (26 mutant shas).
- Earlier-revision receipts retained: `mutants-behavior.json` (446 runs),
  `mutants-selftest.json` (33 runs), `census.json`, `matrix.json`,
  `matrix2.json`, `lane-real.out`, `mutant-sha256.txt`, `fixture-sha256.txt`.
- Scratch `/fast/scratch/hyaku/kagi-r66/R66MutC1/` is deleted on exit after these
  receipts were copied here.
