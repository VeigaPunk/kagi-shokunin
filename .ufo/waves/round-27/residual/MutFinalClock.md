# MutFinalClock — residual release-clock mutation probe

**Result: 5 mutants KILLED, 1 SURVIVED, 0 inconclusive** by the assigned detector. The survivor drops the major version component: the unchanged selftest still prints `RELEASE_CLOCK_SELFTEST: PASS (76 cases)` even though the mutant accepts a major downgrade as a fired, CLEAN observation. This is a selftest coverage finding, not a defect observed in pristine candidate behavior and not a round-closure judgment.

## Scope and axes

- Candidate tested: `144babcb892f0a30154880a9f94aa59ca8ddf9c5`; round plan BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b`. Read `plans/round-27.md` first and read R25-03/R25-04 ledger pins without executing ledger rows.
- Axes: **freshness** (numeric regression versus release event), **coverage** (whether the existing selftest distinguishes each single defect), **calibration** (survivor versus pristine defect; no general adequacy claim), and **operability/safety** (bounded offline probes, isolated copies, exact restoration).
- Advisory mutation seat only. No production implementation, tests, ledger pins, or historical records were edited. The only lane-checkout write is this report; all probe files, clones, and raw evidence are under `/fast/scratch`.
- Six independently isolated clones were probed concurrently using six worker threads. Within each clone, pristine → one mutation → restored phases were ordered; no mutant was stacked on another. The same detector and auxiliary witness ran in every phase. Each subprocess had a 120-second timeout; none timed out.
- Existing tools: `Python 3.14.8`, `git version 2.56.0`. No installs or upgrades.

## Exact setup and commands

Initial setup command (exit 0; final output was the candidate hash above):

```sh
git clone --quiet --no-hardlinks --no-checkout /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/KagiR26.MutFinalClock-27-t3 && git -C /fast/scratch/KagiR26.MutFinalClock-27-t3 checkout --quiet --detach 144babcb892f0a30154880a9f94aa59ca8ddf9c5 && git -C /fast/scratch/KagiR26.MutFinalClock-27-t3 rev-parse HEAD
```

Per-mutant clone commands, each executed with cwd `/fast/scratch`; each exited 0 with empty combined output:

```sh
git clone --quiet --no-hardlinks /fast/scratch/KagiR26.MutFinalClock-27-t3 /fast/scratch/KagiR26.MutFinalClock-27-t3-M01
git clone --quiet --no-hardlinks /fast/scratch/KagiR26.MutFinalClock-27-t3 /fast/scratch/KagiR26.MutFinalClock-27-t3-M02
git clone --quiet --no-hardlinks /fast/scratch/KagiR26.MutFinalClock-27-t3 /fast/scratch/KagiR26.MutFinalClock-27-t3-M03
git clone --quiet --no-hardlinks /fast/scratch/KagiR26.MutFinalClock-27-t3 /fast/scratch/KagiR26.MutFinalClock-27-t3-M04
git clone --quiet --no-hardlinks /fast/scratch/KagiR26.MutFinalClock-27-t3 /fast/scratch/KagiR26.MutFinalClock-27-t3-M05
git clone --quiet --no-hardlinks /fast/scratch/KagiR26.MutFinalClock-27-t3 /fast/scratch/KagiR26.MutFinalClock-27-t3-M06
```

In each cwd listed below, `git rev-parse HEAD` exited 0 and printed `144babcb892f0a30154880a9f94aa59ca8ddf9c5` before any mutation.

| Mutant | Exact detector cwd | Pristine exit | Mutated exit | Restored exit | Selftest verdict |
|---|---|---:|---:|---:|---|
| M01 | `/fast/scratch/KagiR26.MutFinalClock-27-t3-M01` | 0 | 1 | 0 | **KILLED** |
| M02 | `/fast/scratch/KagiR26.MutFinalClock-27-t3-M02` | 0 | 1 | 0 | **KILLED** |
| M03 | `/fast/scratch/KagiR26.MutFinalClock-27-t3-M03` | 0 | 1 | 0 | **KILLED** |
| M04 | `/fast/scratch/KagiR26.MutFinalClock-27-t3-M04` | 0 | 1 | 0 | **KILLED** |
| M05 | `/fast/scratch/KagiR26.MutFinalClock-27-t3-M05` | 0 | 1 | 0 | **KILLED** |
| M06 | `/fast/scratch/KagiR26.MutFinalClock-27-t3-M06` | 0 | 0 | 0 | **SURVIVED** |

The exact argv in all 18 detector executions was:

```sh
python3 -I -B corpus/release-clock.py --selftest
```

Every pristine and restored detector output was exactly the following sole (therefore last) line, with exit 0:

```text
RELEASE_CLOCK_SELFTEST: PASS (76 cases)
```

The auxiliary witness command (also in each table cwd, and in all three phases) was:

```sh
python3 -I -B /fast/scratch/KagiR26.MutFinalClock-27-t3-counterexamples.py
```

That script imports only the selected clone, builds synthetic rows and matching receipt dictionaries, and replaces `request_body`/the timestamp for its observation witness. It performs no network requests. All 12 pristine/restored witness runs exited 0 with last line `COUNTEREXAMPLES: cases=7 failed=0`. All six mutated witness runs exited 1; their exact last lines and failed-case outputs appear below. These added witnesses are not counted as kills by the assigned existing selftest.

## Single mutations, expected detector, and actual output

Line numbers below refer to the unmodified candidate. Mutations/restoration were surgical edits in the named scratch clone, not production edits. The shown detector outputs are complete; their final displayed lines are the actual last lines.

### M01 — KILLED

Point: `is_regression, original line 387`. Expected detector: The existing unchanged-feed / v-prefix-equality controls must reject equality-as-regression.

Before:

```python
return anchor is not None and seen is not None and seen < anchor
```

After:

```python
return anchor is not None and seen is not None and seen <= anchor
```

Assigned selftest: exit **1**.

```text
RELEASE_CLOCK_SELFTEST: FAIL unchanged feed: errors {('REGRESSED', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL unchanged feed: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL unchanged feed: passed=False
RELEASE_CLOCK_SELFTEST: FAIL unknown feed: errors {('BADFEED', 'S001'), ('REGRESSED', 'S001')} != {('BADFEED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL non-feed source: errors {('BADFEED', 'S001'), ('REGRESSED', 'S001')} != {('BADFEED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL invalid date: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('INCONSISTENT', 'S001'), ('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: errors {('REGRESSED', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: derived=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: passed=False
RELEASE_CLOCK_SELFTEST: FAIL unnamed anchor refused: errors {('REGRESSED', 'S001')} != {('INCONSISTENT', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL v-prefix equality: errors {('REGRESSED', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL v-prefix equality: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL v-prefix equality: passed=False
RELEASE_CLOCK_SELFTEST: FAIL feed row on-release: errors {('BADFEED', 'S001'), ('REGRESSED', 'S001')} != {('BADFEED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL feed floor catches un-fire: errors {('REGRESSED', 'S004'), ('REGRESSED', 'S001')} != {('REGRESSED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL feed floor catches un-fire: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL feed floor lifts non-numeric anchor: errors {('REGRESSED', 'S004'), ('REGRESSED', 'S001')} != {('REGRESSED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL feed floor lifts non-numeric anchor: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL missing receipt: errors {('NOT OBSERVED', 'S001'), ('REGRESSED', 'S001')} != {('NOT OBSERVED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL receipt id mutation: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL receipt clock mutation: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL receipt URL mutation: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL receipt date mutation: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL receipt verdict mutation: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL receipt parsed-version mutation: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL receipt version normalization control: errors {('REGRESSED', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL receipt version normalization control: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL receipt version normalization control: passed=False
RELEASE_CLOCK_SELFTEST: FAIL extra receipt mismatch: errors {('REGRESSED', 'S001'), ('RECEIPT-MISMATCH', 'S999')} != {('RECEIPT-MISMATCH', 'S999')}
RELEASE_CLOCK_SELFTEST: FAIL duplicate receipt mismatch: errors {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')} != {('RECEIPT-MISMATCH', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL stale receipt recapture or TSV immutability
RELEASE_CLOCK_SELFTEST: FAIL explicit receipt override with digest
```

Auxiliary witness: exit **1**, last line:

```text
COUNTEREXAMPLES: cases=7 failed=2
```

Concrete failed witness output (actual versus expected):

```json
{"actual": {"errors": [["REGRESSED", "S001"]], "fired": 0, "observed": 0, "passed": false}, "case": "equal-anchor", "expected": {"errors": [], "fired": 0, "observed": 1, "passed": true}, "pass": false}
{"actual": {"errors": [["REGRESSED", "S001"], ["REGRESSED", "S004"]], "fired": 0, "observed": 0, "passed": false}, "case": "shared-feed-floor", "expected": {"errors": [["REGRESSED", "S001"]], "fired": 0, "observed": 1, "passed": false}, "pass": false}
```

### M02 — KILLED

Point: `evaluate, original lines 567–568`. Expected detector: The existing feed-floor catches-un-fire and non-numeric-floor controls must reject a dropped shared-feed floor.

Before:

```python
if (is_regression(anchored, observed_version)
        or is_regression(floors.get(feed_url, ""), observed_version)):
```

After:

```python
if is_regression(anchored, observed_version):
```

Assigned selftest: exit **1**.

```text
RELEASE_CLOCK_SELFTEST: FAIL feed floor catches un-fire: errors set() != {('REGRESSED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL feed floor catches un-fire: observed=2 != 1
RELEASE_CLOCK_SELFTEST: FAIL feed floor catches un-fire: passed=True
RELEASE_CLOCK_SELFTEST: FAIL feed floor lifts non-numeric anchor: errors set() != {('REGRESSED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL feed floor lifts non-numeric anchor: observed=2 != 1
RELEASE_CLOCK_SELFTEST: FAIL feed floor lifts non-numeric anchor: passed=True
```

Auxiliary witness: exit **1**, last line:

```text
COUNTEREXAMPLES: cases=7 failed=1
```

Concrete failed witness output (actual versus expected):

```json
{"actual": {"errors": [], "fired": 0, "observed": 2, "passed": true}, "case": "shared-feed-floor", "expected": {"errors": [["REGRESSED", "S001"]], "fired": 0, "observed": 1, "passed": false}, "pass": false}
```

### M03 — KILLED

Point: `observe_one, original lines 793–794`. Expected detector: The existing return-to-anchor-after-newer-observation control must reject a dropped previous-observation floor.

Before:

```python
if (is_regression(values["anchored_version"], parsed_version)
        or is_regression(values.get("observed_version", ""), parsed_version)):
```

After:

```python
if is_regression(values["anchored_version"], parsed_version):
```

Assigned selftest: exit **1**.

```text
RELEASE_CLOCK_SELFTEST: FAIL return to the anchor after a recorded newer observation was not regressed
```

Auxiliary witness: exit **1**, last line:

```text
COUNTEREXAMPLES: cases=7 failed=1
```

Concrete failed witness output (actual versus expected):

```json
{"actual": {"parsed_version": "1.2.3", "verdict": "not-fired"}, "case": "previous-observation-floor", "expected": {"parsed_version": "1.2.3", "verdict": "regressed"}, "pass": false}
```

### M04 — KILLED

Point: `is_regression, original line 387`. Expected detector: The existing numeric-not-lexical control must reject a normalized-string comparison.

Before:

```python
return anchor is not None and seen is not None and seen < anchor
```

After:

```python
return anchor is not None and seen is not None and norm_version(observed) < norm_version(floor)
```

Assigned selftest: exit **1**.

```text
RELEASE_CLOCK_SELFTEST: FAIL numeric not lexical: errors {('REGRESSED', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL numeric not lexical: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL numeric not lexical: fired=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL numeric not lexical: passed=False
```

Auxiliary witness: exit **1**, last line:

```text
COUNTEREXAMPLES: cases=7 failed=1
```

Concrete failed witness output (actual versus expected):

```json
{"actual": {"errors": [["REGRESSED", "S001"]], "fired": 0, "observed": 0, "passed": false}, "case": "numeric-not-lexical", "expected": {"errors": [], "fired": 1, "observed": 1, "passed": true}, "pass": false}
```

### M05 — KILLED

Point: `evaluate, original lines 615–617`. Expected detector: The existing regressed-receipt-refused control must require the REGRESSED category as well as RECEIPT-MISMATCH.

Before:

```python
if isinstance(receipt, dict) and receipt.get("verdict") == "regressed":
    errors.add(("REGRESSED", source_id))
    row_valid = False
```

After:

```text
[delete this three-line block]
```

Assigned selftest: exit **1**.

```text
RELEASE_CLOCK_SELFTEST: FAIL regressed receipt refused: errors {('RECEIPT-MISMATCH', 'S001')} != {('RECEIPT-MISMATCH', 'S001'), ('REGRESSED', 'S001')}
```

Auxiliary witness: exit **1**, last line:

```text
COUNTEREXAMPLES: cases=7 failed=1
```

Concrete failed witness output (actual versus expected):

```json
{"actual": {"errors": [["RECEIPT-MISMATCH", "S001"]], "fired": 0, "observed": 0, "passed": false}, "case": "regressed-receipt", "expected": {"errors": [["RECEIPT-MISMATCH", "S001"], ["REGRESSED", "S001"]], "fired": 0, "observed": 0, "passed": false}, "pass": false}
```

### M06 — SURVIVED

Point: `numeric_version, original line 380`. Expected detector: A major-boundary ordering control would reject the off-by-one slice that discards the major component; test whether the current selftest does.

Before:

```python
return tuple(int(part) for part in value.split("."))
```

After:

```python
return tuple(int(part) for part in value.split(".")[1:])
```

Assigned selftest: exit **0**.

```text
RELEASE_CLOCK_SELFTEST: PASS (76 cases)
```

Auxiliary witness: exit **1**, last line:

```text
COUNTEREXAMPLES: cases=7 failed=2
```

Concrete failed witness output (actual versus expected):

```json
{"actual": {"errors": [], "fired": 1, "observed": 1, "passed": true}, "case": "major-downgrade", "expected": {"errors": [["REGRESSED", "S001"]], "fired": 0, "observed": 0, "passed": false}, "pass": false}
{"actual": {"errors": [["REGRESSED", "S001"]], "fired": 0, "observed": 0, "passed": false}, "case": "major-upgrade", "expected": {"errors": [], "fired": 1, "observed": 1, "passed": true}, "pass": false}
```

## Concrete inputs and interpretation

All evaluation witnesses use a code feed source S002 (`90d`) at `https://example.test/releases.atom`, document sources with `on-release` cadence and literal `Version <anchor>` anchors, a `2026-10-21` observation date, and matching synthetic HTTP-200 receipts (`sha256` is 64 zeroes). Thus no absent/mismatching receipt masks the numeric-order behavior, except where the receipt is deliberately changed in M05. These are synthetic offline inputs, not claims about a live vendor feed.

- **M01 equality:** anchor `1.2.3`, observed `1.2.3`, `not-fired`. Pristine accepts it with observed=1/fired=0; the mutant wrongly emits REGRESSED and observed=0. The successor row equal to shared floor `1.2.4` is wrongly regressed too.
- **M02 shared floor:** S001 has anchor/observation `1.2.3`, S004 has anchor/observation `1.2.4`, both `not-fired`, same feed. Pristine reports REGRESSED S001 and counts only S004. Removing the shared-floor term makes the whole result pass with observed=2. The existing selftest also detects the equivalent non-numeric-anchor case.
- **M03 prior observation:** anchor `1.2.3`, prior observation `1.2.4`, returned feed title `v1.2.3`. Pristine receipt verdict is `regressed`; the mutant changes it to `not-fired`.
- **M04 lexical order:** anchor `1.2.3`, observed `1.10.0`, `fired`. Pristine correctly accepts the newer numeric release; the mutant wrongly emits REGRESSED and suppresses observed/fired counts.
- **M05 typed receipt:** anchor/row observation `1.2.3`, `not-fired`; receipt is changed to parsed version `1.2.2`, verdict `regressed`. Pristine returns both RECEIPT-MISMATCH and REGRESSED. The mutant still fails because of RECEIPT-MISMATCH but loses the required REGRESSED classification. It is a typed-category defect, not a demonstrated CLEAN bypass.
- **M06 survivor / major downgrade:** anchor `2.0.0`, observed `1.9.9`, `fired`. Pristine reports REGRESSED with observed=0/fired=0. The mutant compares `(9, 9)` against `(0, 0)` after dropping the major and returns errors=[], passed=true, observed=1, fired=1: a numeric downgrade accepted as a release event. The existing selftest nevertheless passes all 76 cases.
- **M06 reverse direction:** anchor `1.9.9`, observed `2.0.0`, `fired`. Pristine accepts observed=1/fired=1; the mutant emits REGRESSED, observed=0/fired=0. The survivor is therefore non-equivalent in both directions. The auxiliary witnesses kill it; the requested existing detector does not.

**Coverage advice to L1:** major-boundary downgrade and upgrade fixtures would distinguish M06 without changing the stated strict-X.Y.Z contract. No such production test change was made here. Six mutants do not establish overall mutation adequacy.

## Before, mutant, and restored hashes

For every clone, the pristine and restored SHA-256 was **H0 = `0812b6de2fe7c470462db34ead6ab1e6beb79ae79a3a3e5b8b746069d704f1ac`**.

| Mutant | Before | Mutant SHA-256 | Restored | Exact-byte cmp exit |
|---|---|---|---|---:|
| M01 | H0 | `053b497d3199838fce53308ff68bf42907934f8ea1e0daa2211e8c0c27302425` | H0 | 0 |
| M02 | H0 | `9377a560c4701f5bf3de051656b77302b84ff431fb61395c778c5c962aeca621` | H0 | 0 |
| M03 | H0 | `eec589234780e33749dd86c095dbcf06b0d85b9a4c9dafeafd6704634aedc61f` | H0 | 0 |
| M04 | H0 | `c59c6187b85a66b34970d0881cd409214cffbba8ade574aab8b25697c2dcaea5` | H0 | 0 |
| M05 | H0 | `307f4f933afeaf0369a600a5bff1d20ac9b89bc128718694422ef5431353bfa8` | H0 | 0 |
| M06 | H0 | `62c2b8ea532242c41266dd45d2c5cc6b9b96f1169520541d8d5e8947a926e581` | H0 | 0 |

Exact hash command in each table cwd, once in each phase (all 18 exits 0; output is the corresponding hash above followed by `  corpus/release-clock.py`):

```sh
sha256sum corpus/release-clock.py
```

After restoring each original line/block and before its restored detector run, the exact command in each cwd was:

```sh
cmp --silent /fast/scratch/KagiR26.MutFinalClock-27-t3/corpus/release-clock.py corpus/release-clock.py
```

All six comparisons exited 0 with no output: the mutated source bytes were restored exactly, not merely behaviorally repaired. All six restored detector and witness runs then passed as recorded above.

## Evidence and limits

- Full observed argv/cwd/exit/combined-output/timing records for clone, identity, hashes, detector, auxiliary witness, and restoration comparison: `/fast/scratch/KagiR26.MutFinalClock-27-t3-results.json`.
- Executed auxiliary witness: `/fast/scratch/KagiR26.MutFinalClock-27-t3-counterexamples.py`. Scratch clone roots are given in the detector table; the unsullied source clone is `/fast/scratch/KagiR26.MutFinalClock-27-t3`.
- No full lane gates, builds, linters, formatters, claim-ledger execution, c1-measure/c2-measure/separability instrument, C1 binder review, live `--observe`, public-site fetch, host-private read, vault/account/handler/CDP operation, commit, push, runtime/judge invocation, or production integration was performed.
- No exhaustive mutant search, other Python/platform run, performance/resource-bound campaign, or additional non-numeric/prerelease/build-suffix contract review was performed. The optional-v equality behavior was exercised by the existing selftest, not separately generalized.
- This report is lane-authored advice only; it makes no non-author acceptance or closure claim.

Report: .ufo/waves/round-27/residual/MutFinalClock.md
