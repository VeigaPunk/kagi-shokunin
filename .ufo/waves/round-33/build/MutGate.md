# MutGate — C1 `prefreeze-control.sh` mutation report (round 33)

Seat: **MutGate-2** (mutation-tester, leaf). Wave `kagi-r33-build`, frozen BASE
`76f4eeae7aa9af4dbb9423f5632b55791824253a`. No lane file was edited; every mutant is a
separate copy under `/fast/scratch/hyaku/kagi-r33/MutGate-2/`.

## Source under test

| item | value |
|---|---|
| file | `.ufo/waves/round-33/build/prefreeze-control.sh` (preferred wave-dir copy) |
| sha256 | `c265a5d82a8b3b0dc588ba3c9e5b5cd887de092127be36835584ee7f8b381e59` |
| size / lines | 11259 bytes / 256 lines |
| identical lane install | `corpus/prefreeze-control.sh` (same sha256, installed during the wave) |
| frozen copy mutated | scratch `prefreeze-control.pristine.sh` (same sha256) |

ExecGate's live copy was still being finalised when this seat started: an earlier snapshot
(11267 B, `dd513688…`) differed from the final bytes only by blank `#` separator comment lines; it
was **not** mutated or measured for the table. All mutants and runs below use the final
11259-byte bytes above. Mutant hashes and the earlier-snapshot hash are in
`receipts/source-identity.txt`.

## Detector target (calibration)

Mutation verdicts need a deterministic controls detector. The live lane changed under this seat
while the L1 landed C2 — the gate was installed, then the two NIST entries, registry rows and the
Frontier bullet changed — so the canonical controls run pins the repository to a clean
`git clone --shared` of the lane at freeze-time revision
`880824b1d3da5f70b2fe489a34fe866a47314672` (clean worktree, `corpus/prefreeze-control.sh`
absent, commit `76f4eea` present and extracted). `PREFREEZE_REPO` names that clone for every
controls run; `--base` remains `76f4eea` and the controls file remains the frozen
`plans/round-33.controls.tsv`. For pristine and M1–M6 this changes nothing (the extracted tree is
the same commit); for M7 it pins "the live tree" to the freeze-time state the declared values came
from. `receipts/controls-target.txt` records the pin and the two live-lane snapshots, which are
**not** used for verdicts.

## Method

One patch per assigned row, each applied to its own copy; every substitution asserted exactly one
occurrence (`make_mutants.py`), `bash -n` clean. For each copy: `--selftest`, then
`run --base 76f4eea --controls plans/round-33.controls.tsv`. Pristine baseline ran first, on the
same bytes and the same pinned target: `PREFREEZE_SELFTEST: PASS (10 cases)` exit 0,
`PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0. A baseline failure would have made every
result inconclusive; none occurred.

**Verdict rule used.** KILLED = the gate's own assertion set (`--selftest`) fails on the mutant.
ESCAPE = selftest stays PASS, i.e. the declared behaviour has no assertion that witnesses the
mutation. The controls-run column is reported separately because the round-33 receipt only samples
the four frozen values; per the task, a mutant that keeps the selftest PASS **or** keeps CLEAN
without doing the work is an escape.

## Matrix

| Mutant | What changed (one point) | Selftest (last line, exit) | Controls 33 on pinned freeze tree (last line, exit) | Verdict |
|---|---|---|---|---|
| M1 | `[ "$m" -eq "$((10#$exp))" ]` → `[ "$m" -ge 0 ]` — any measured value accepted | `PREFREEZE_SELFTEST: FAIL (10 cases)` **1** — cases `one-differs`, `two-differ` (both became `CLEAN … mismatch=0`, exit 0) | `PREFREEZE: CLEAN (controls=4 mismatch=0)` **0** | **KILLED** (selftest) |
| M2 | `mismatch=$((mismatch + 1))` → `… + 0` — counter never moves | `PREFREEZE_SELFTEST: FAIL (10 cases)` **1** — cases `one-differs`, `two-differ` (per-row `MISMATCH` still prints, verdict fell to `CLEAN`, exit 0) | `PREFREEZE: CLEAN (controls=4 mismatch=0)` **0** | **KILLED** (selftest) |
| M3 | deleted the `if [ "$noresult" -gt 0 ] … exit 2` block — NORESULT rows no longer block CLEAN | `PREFREEZE_SELFTEST: FAIL (10 cases)` **1** — cases `no-integer`, `timeout` (both `CLEAN (controls=1 mismatch=0)`, exit 0) | `PREFREEZE: CLEAN (controls=4 mismatch=0)` **0** | **KILLED** (selftest) |
| M4 | `[ "$n" -gt 0 ] \|\| { … die empty-controls; }` → `… \|\| :` — empty file yields CLEAN | `PREFREEZE_SELFTEST: FAIL (10 cases)` **1** — case `empty-controls` (`CLEAN (controls=0 mismatch=0)`, exit 0) | `PREFREEZE: CLEAN (controls=4 mismatch=0)` **0** | **KILLED** (selftest) |
| M5 | numeric compare → `[ "$rc" -eq 0 ]` — `expect` ignored, exit code decides | `PREFREEZE_SELFTEST: FAIL (10 cases)` **1** — cases `one-differs`, `two-differ`, `grep-c-exit1-is-zero` (`grep -c` exit 1 became `MISMATCH`, exit 1) | `PREFREEZE: CLEAN (controls=4 mismatch=0)` **0** | **KILLED** (selftest) |
| M6 | `$id` dropped from all four per-row `printf` lines (`OK`, `MISMATCH`, two `NORESULT`) | `PREFREEZE_SELFTEST: FAIL (10 cases)` **1** — cases `equal-values`, `one-differs`, `no-integer`, `grep-c-exit1-is-zero`, `timeout` (exact per-row regexes miss) | `PREFREEZE: CLEAN (controls=4 mismatch=0)` **0** — rows print without ids, verdict unchanged | **KILLED** (selftest only) |
| M7 | removed the `git archive --format=tar "$BASE_REV" \| tar -x …` block; `BASE_DIR=$REPO` — `--base` ignored, live worktree measured | `PREFREEZE_SELFTEST: PASS (10 cases)` **0** | `PREFREEZE: CLEAN (controls=4 mismatch=0)` **0** on the pinned freeze tree | **ESCAPE** (see below) |
| Input mutation | not the tool: `registry_rows` `expect` 72 → 73 in a copy of `plans/round-33.controls.tsv`, pristine harness at `76f4eea` | n/a | `MISMATCH registry_rows expect=73 measured=72`, `PREFREEZE: MISMATCH (controls=4 mismatch=1)` **1** | **DETECTED** (falsifier works) |

Live-lane controls for M7 are **not** part of the verdict: they read `MISMATCH (controls=4
mismatch=1)` when only the installed gate differed from BASE, and `MISMATCH (controls=4
mismatch=3)` after C2's entries/rows landed (`matrix-summary-live-lane.txt`,
`controls33-live-lane/`). Both are catches caused by lane drift; neither is an assertion, and on
the freeze-time tree the mutant is CLEAN.

## Escapes

**M7 — the `--base` extraction has no assertion that kills it.** The selftest passes all ten
cases while the gate never extracts the declared revision. Cause: every selftest fixture runs at
its single commit with a clean worktree, so `git archive <rev>` and `$REPO`'s worktree are
byte-identical; the suite cannot distinguish measuring the extracted BASE from measuring the live
tree. The `bad-rev` case still passes because `git rev-parse --verify` was left in place, so the
mutant remains a plausible, error-checking implementation.

Positive proof that the mutant measures the wrong tree (two-commit fixture, worktree at B,
`--base A`; `receipts/m7-differential.txt`):

| harness | `--base A`, expect A's value 2 | `--base A`, expect B's value 3 |
|---|---|---|
| pristine | `OK f expect=2 measured=2`, CLEAN exit 0 | `MISMATCH f expect=3 measured=2`, exit 1 |
| M7 | `MISMATCH f expect=2 measured=3`, exit 1 | `OK f expect=3 measured=3`, CLEAN exit 0 |

The M7 row proves the declared BASE (`A`, 2 lines) is never read: the verdict follows the
worktree (`B`, 3 lines).

**Why the controls run does not save it.** On the pinned freeze-time tree — the state the
controls were declared from — M7 prints `PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0,
identical to the pristine gate, without ever extracting `76f4eea`
(`receipts/controls33/M7.txt`, `receipts/replica-M7-controls.txt`). On the live lane the same
mutant flips to MISMATCH only because the lane no longer equals the declared BASE (gate installed,
then C2 values landed). That catch is lane-drift-dependent, not an assertion: at the freeze state
the mutant passes.

**Missing assertion (fix direction, not applied — lane edits belong to the L1):** add a selftest
case whose fixture worktree differs from the `--base` revision — two commits, worktree at B,
`--base A`, control expecting A's value. The pristine gate reads A; M7 would read B and fail.

## Coverage / calibration notes

- **Detector split, M1–M6.** The round-33 controls receipt stays CLEAN for every one of these:
  it samples four matching values and cannot witness comparison logic, the counter, NORESULT
  handling, empty-file handling, `expect` use, or row ids. Each is killed only by the selftest's
  scripted cases. A green `prefreeze-33.txt` therefore does not exercise the behaviours M1–M6
  mutate; the selftest is the load-bearing assertion set.
- **M6 is invisible to the controls layer** (rows lose their ids, verdict unchanged) and is killed
  by five exact per-row regexes; without those `out_ere` checks it would have been a second escape.
- **M2 is partly masked in the row stream** — the per-row `MISMATCH` line still prints; only the
  verdict counter and exit code reveal it, which is what cases `one-differs`/`two-differ` assert.
- **M3 kills two cases**, not one: `no-integer` and `timeout` both funnel through the removed
  SETUP verdict.
- **M7's controls outcome is state-dependent** (CLEAN on the freeze-time tree; MISMATCH once the
  lane drifts). Reviewing only the final lane would wrongly credit the controls layer with catching
  it; the pinned run and the two-commit fixture above are the disambiguating evidence.
- **Live lane is not a stable detector mid-wave.** The two live snapshots (M7 mismatch 1 → 3)
  show the controls values moving as C2 landed; the canonical column is the pinned clone so the
  comparison is reproducible (`receipts/controls-target.txt`).
- The gate's own ten cases are otherwise well targeted: M1/M2/M5 hit the numeric comparison from
  both directions, M4 the empty-file SETUP, M3 both NORESULT paths, M6 the row-text contract.

## Receipts

Under `.ufo/waves/round-33/build/mut/receipts/`:

| path | content |
|---|---|
| `matrix-summary.txt` | canonical matrix (pinned freeze-time target), controls rows, failing cases |
| `matrix-summary-live-lane.txt` | second live-lane matrix (M7 drift, mismatch=3) |
| `controls-target.txt` | detector pin and the two live-lane observations |
| `controls33/<impl>.txt`, `.rc` | canonical controls output + exit, pristine and M1–M7 |
| `controls33-live-lane/<impl>.txt`, `.rc` | first live-lane controls output + exit (M7 mismatch=1) |
| `selftest/<impl>.txt`, `.rc` | `--selftest` output + exit for pristine, M1–M7 |
| `patches/M1..M7.patch` | exact one-point diff of each mutant vs the frozen bytes |
| `input-mutation.txt`, `input-mutated.controls.tsv` | input mutation: command, output, exit |
| `m7-differential.txt` | two-commit fixture: pristine vs M7 under `--base A` |
| `replica-M7-controls.txt`, `replica-pristine-controls.txt` | M7 and pristine against the pinned freeze-time clone |
| `source-identity.txt` | wave/lane/frozen hashes, mutant hashes, sizes |

## Compliance

No lane-tracked file was written or edited; no sibling repo, fleet-root file, `considerthese/`,
`shokuknow` write, vault contact, network fetch, or git mutation occurred. Scratch only
(`/fast/scratch/hyaku/kagi-r33/MutGate-2/`, removed before yield). No tools installed or upgraded.
