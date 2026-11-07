# R54MutCounter — mutation test of the frozen round-54 C1 counter

Seat: `R54MutCounter` (kagi round 54, attempt 1). Assignment: mutate
`plans/round-54-c1.sh` at the landed candidate revision, run the pre-freeze control
suite `plans/round-54-controls.sh` against each mutant, report killed/survived per
mutant and the killing control; propose controls for survivors without editing lane
files.

## Inputs (read-only, hashed)

| item | path | sha256 |
|---|---|---|
| counter | `plans/round-54-c1.sh` | `df3d67463c29aaa94d302b4125a70aaa6ad0228aca8f5459394333a571ba82ba` |
| controls | `plans/round-54-controls.sh` | `5839275f4609abb808b1f2984d3cbc2d5c461c38f29b891a9defeb8dc18d5000` |
| pre-freeze receipt | `.ufo/waves/round-54/controls/controls-prefreeze.txt` | `df3272d2a7065bfaa42299d1e87d6fe802be5fd97626398d15238163d5f32ae3` |

Candidate revision `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`; BASE
`1a0f43a9220bb0e995462c2aef745ac0124c3317`.
Frozen predicate: `C1_OP_CLOCK: value = WATCHED + MEASURED when GUARD = 1, else 0; target 2 (BASE 0).`

## Method

* Scratch root `/fast/scratch/hyaku/kagi-r54/R54MutCounter` (`HYAKU_SCRATCH=/fast/scratch/hyaku`).
* Pristine bytes kept as `c1.pristine.sh` (same sha256 as the lane file). Every mutant is
  **one exact-string replacement**, each anchor asserted to occur exactly once in the
  pristine file; `bash -n` exit 0 for all 19 mutant files (`bash_n_rc=0` in the JSON).
* Detector: the unmodified pre-freeze controls (`bash <lane>/plans/round-54-controls.sh`),
  whose expectations were written before the run. Each mutant ran in its own
  `git clone -q --shared` of the lane at `ede4373`; `git rev-parse --show-toplevel`
  asserted equal to the clone dir before `git checkout`. The controls script hash was
  re-checked in every worker (`5839275f…`).
* Kill = at least one `CONTROL … MISMATCH` line (or a control line disappearing).
* Restoration: after each run the pristine counter bytes were written back into that
  clone and re-hashed; `restore_ok=true` for 19/19 (`restored_sha256 ==
  df3d6746…82ba`). The canonical clone `lane/` was never mutated (hash above unchanged
  after all runs).
* Baseline on pristine bytes, same clone and detector: **`CONTROLS: match=16 mismatch=0`,
  rc=0, ELAPSED 22.66 s** (`base-controls.out`; the pre-freeze receipt agrees). No
  baseline failure, so no inconclusive verdicts.

Driver: `driver.py` (6 workers, 493 s wall). Proposals: `propose.py` (serialized,
187 s wall). Both copied into this report's artifact dir.

## Mutant table (19 mutants; kill = existing pre-freeze control set)

| id | mutation (one conjunct dropped) | control result | killed-by / verdict |
|---|---|---|---|
| M01 | S072 `recheck == on-release` check (`s072-recheck`) | 16 MATCH, rc 0 | **SURVIVED** (equivalent under honest gate — see A1) |
| M02 | clock `anchored_version == 2.41.1` check (`clock-anchor`) | 16 MATCH, rc 0 | **SURVIVED** (equivalent — A2) |
| M03 | clock `observed_version == 2.42.0` check (`clock-observed`) | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M03) |
| M04 | clock `verdict == fired` check (`clock-verdict`) | 16 MATCH, rc 0 | **SURVIVED** (equivalent — A3) |
| M05 | `by_url(reg, OPFEED) == [fsid]` uniqueness (`feed-url-rows`) | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M05) |
| M06 | gate default-receipt path pin (`m2` regex, `receipt-unnamed`) | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M06) |
| M07 | receipt `sha256 == DEFAULT_RECEIPT_SHA256` (`receipt-sha`) | 16 MATCH, rc 0 | **SURVIVED** (equivalent — A4) |
| M08 | receipt record `sha256 == CAPSHA` (`receipt-body-link`) | **K1-F14**: expect 1 got 2 | **KILLED** |
| M09 | `FLOOR <= observed_at <= ASOF` (`receipt-time-window`) | **K1-F9**: expect 1 got 2 | **KILLED** |
| M10 | `plain_file()` symlink refusal | **K1-F12**: expect 1 got 2 | **KILLED** |
| M11 | `parse_latest_version(...) == 2.42.0` (`parse=`) | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M11) |
| M12 | gate last line `RELEASE_CLOCK: CLEAN` (`gate != 1`) | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M12) |
| M13 | op receipt `op_version=2.42.0` line | **K1-F5**: expect 1 got 2 | **KILLED** |
| M14 | op receipt `gpg_validsig=3FEF…EA22` line | **K1-F11**: expect 1 got 2 | **KILLED** |
| M15 | op receipt `probe_sha256=<BASE probe>` line | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M15) |
| M16 | exact six `DOTENV_BYTES_CASE … PASS` set | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M16) |
| M17 | entry `### 11.2` heading | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M17) |
| M18 | GUARD probe-byte equality (`cmp -s` against BASE) | **K1-F10**: expect 0 got 1 | **KILLED** |
| M19 | GUARD selftest `PASS` requirement | 16 MATCH, rc 0 | **SURVIVED** (killable — P-M19) |

Every kill is a sharp, single-control mismatch (`match=15 mismatch=1`): the intended
anti-fixture fires, no unaffected control drifts, so the control set shows no
cross-talk on these mutants.

### Kill ratio

* Frozen 16-control set: **6/19 killed (31.6 %)**; 13 survived.
* With the nine demonstrated additional controls below: **15/19 (78.9 %)**.
* Remaining 4 (M01, M02, M04, M07) are **equivalent mutants**: no *honest-gate* fixture
  can distinguish them, because the round-54 gate independently enforces the same
  invariant and the counter's own `gate != 1` conjunct then reads WATCHED = 0 for both
  pristine and mutant (measured below: 1 vs 1). Distinguishing them requires forging
  `corpus/release-clock.py` itself, at which point the fixture no longer detects the
  counter defect against an independent invariant.

## Survived mutants that a new control kills (demonstrated, lane files not edited)

Each proposal is the reference fixture (BASE archive + committed S112 capture + the
pre-freeze ref overlay, exactly as `ref()` builds it in the controls) plus one edit.
Values were measured with the pristine counter and with the corresponding mutant;
`propose.py` in the artifact dir reproduces every row.

| proposal | fixture edit | pristine counter | mutant counter | verdict |
|---|---|---|---|---|
| P-M03 | clock row `observed_version` = `v2.42.0` (receipt keeps `parsed_version` 2.42.0; gate's `norm_version` compare accepts, gate CLEAN) | value=1 (`bad=watched:clock-observed=v2.42.0`) | value=2 | kills M03 |
| P-M05 | add registry row `S113` carrying the same `feed_url` (recheck `90d`, gate CLEAN) | value=1 (`feed-url-rows`) | value=2 | kills M05 |
| P-M06 | repoint the gate's `receipt_path()` return to `observe-r54-alt.json` and place a byte-identical copy there (gate CLEAN, digest unchanged) | value=1 (`receipt-unnamed`) | value=2 | kills M06 |
| P-M11 | gate `parse_latest_version` returns `2.43.0` only for bodies > 10 kB containing `1Password CLI 2.42.0` (selftest untouched, gate CLEAN) | value=1 (`parse=2.43.0`) | value=2 | kills M11 |
| P-M12 | append an orphan clock row `S099` (gate FAILED, exit 1; nothing else touched) | value=1 (`watched:gate`) | value=2 | kills M12 |
| P-M15 | rewrite `probe_sha256=` in the op receipt to 64 zeros | value=1 (`oprcpt-line:probe_sha256`) | value=2 | kills M15 |
| P-M16 | delete the `DOTENV_BYTES_CASE id=newline-only status=PASS` line (removal introduces no `FAIL` text, so the failure-line scan cannot catch it) | value=1 (`oprcpt-cases`) | value=2 | kills M16 |
| P-M17 | delete the `### 11.2` heading while the `op \`2.42.0\`` mention stays in section 11 | value=1 (`entry-no-11.2`) | value=2 | kills M17 |
| P-M19 | gate `--selftest` prints `RELEASE_CLOCK_SELFTEST: FAIL` and returns 1 (main run still prints CLEAN) | value=0 (`guard=0`) | value=2 | kills M19 (expected 0) |

Raw receipts: `proposal-results.txt` (13 pairs: mutant then pristine per case).

## Equivalence analysis for the four survivors that no honest-gate fixture kills

Code citations are `corpus/release-clock.py` in the pre-freeze ref overlay
(`.ufo/waves/round-54/controls/fixtures/ref/c1/`).

* **A1 (M01, S072 `recheck`)**: `evaluate()` treats a clock row whose registry source is
  not `on-release` as `errors.add(("ORPHAN", row_id))` (l.557-562), and
  `passed = not errors and bound == len(on_release)` (l.711). Keeping the clock row
  while reverting the recheck to `180d` makes the gate FAILED, and the counter's
  `gate != "1"` conjunct then yields WATCHED = 0 for pristine and mutant alike.
  Measured P-M01: pristine `bad=watched:s072-recheck=180d`, mutant `bad=watched:gate`,
  **value=1 in both**.
* **A2 (M02, `clock-anchor`)**: `evaluate()` requires
  `version_is_named(sources[source_id]["anchor"], anchored)` (l.616), i.e. the clock's
  `anchored_version` must be the version named in the registry row's anchor cell.
  Measured P-M02 (anchored 2.40.0, observed 2.42.0, fired): gate FAILED, **1 in both**.
* **A3 (M04, `clock-verdict`)**: `receipt_matches()` requires
  `receipt.get("verdict") == values["verdict"]` (l.485-487). Changing the clock verdict
  alone breaks the gate (`FAILED`), and changing the receipt too trips the counter's own
  `receipt-verdict` check. Measured P-M04: gate FAILED, **1 in both**.
* **A4 (M07, `receipt-sha`)**: `main()` loads the receipt with
  `expected_sha256 = DEFAULT_RECEIPT_SHA256` (l.2188-2192), so a receipt whose bytes do
  not match the digest line makes the gate FAILED before the counter's own check can
  differ. Measured P-M07 (one byte appended): gate FAILED, **1 in both**.

These four are redundant conjuncts given the gate, not uncovered behavior. The
pre-freeze set's real calibration gap is different: **F4 is a compound anti-fixture**
(it moves the clock anchor *and* the verdict together, `setclock(4,"2.42.0")` +
`setclock(7,"not-fired")`), so neither condition can be isolated — M02 and M04 pass all
16 controls. The nine demonstrated controls are single-condition fixtures in the same
idiom as the existing suite.

## Artifacts

`build/R54MutCounter/`: `mutation-results.json` (per-mutant controls, mismatches,
restore hash; sha256 `791b3ea7866bab42ee6371c9fe4b8f9ba46eb5044d38ba8bc4877c2a911a15fd`),
`proposal-results.txt` (sha256 `68c300261188fbd45e2f32da6ae65410144759895627bab2856b4d65d90af11c`),
`base-controls.out`, `base-controls.err`, `c1.pristine.sh`, `controls.pristine.sh`,
`pristine.sha256`, `driver.py`, `propose.py`, `mutants/M01.sh … M19.sh`.

## Boundaries

* No lane file, registry row, receipt or `corpus/` file was edited; all work in scratch.
  Lane `plans/round-54-c1.sh` and `plans/round-54-controls.sh` hashes re-verified after
  the run (table above).
* No network access, no secret material, no `op` invocation; the counter's `git archive`
  ran on the scratch clone.
* One honesty note: the first P-M15 attempt raced with another concurrent proposal batch
  over the shared scratch lane and produced a wrong pair (1/1); it was re-run serialized
  and the serialized value (1 vs 2) is the one reported. The final batch of 13 pairs ran
  serialized in one shell.
* Nothing left NOT RUN: 19/19 mutants executed.

SEAT-STATUS: complete
