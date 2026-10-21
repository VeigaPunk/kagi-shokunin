# MutBaseDerived — BASE derived-row mutation probe

## Findings first
- **Six of twelve single-line mutants survive the unchanged BASE selftest:** M02, M03, M06, M07, M10, M11. Six are killed; none is inconclusive. All twelve pristine and all twelve restored runs print `RELEASE_CLOCK_SELFTEST: PASS (79 cases)` and exit 0. These are coverage findings, not permission to weaken C2.
- **Marker syntax is unprotected:** `corpus/release-clock.py:565` can lose its colon requirement or its start-of-note requirement without detection. Existing positive derived coverage at `corpus/release-clock.py:1052-1055` does not supply either negative.
- **Derived totals lack zero/multi-row assertions:** at `corpus/release-clock.py:622`, counting every valid row or overwriting rather than accumulating survives. The explicit derived-count assertions at `corpus/release-clock.py:1055,1076` each expect only 1.
- **Exact named-version boundaries are unprotected:** dropping either lookaround at `corpus/release-clock.py:345` survives; `1.2.3` is then accepted inside `11.2.3` or `1.2.30`. BASE calls this matcher only on non-derived rows (`corpus/release-clock.py:566`); these witnesses exercise that existing caller, not an unimplemented C2 feed-anchor check.
- **The existing positive fixture blesses the bypass C2 must remove:** `corpus/release-clock.py:987-989` gives the feed anchor merely `Latest release`, while `corpus/release-clock.py:1052-1055` accepts derived `1.2.0`. Separately, the executed `derived_mismatch` contrast probe sets the feed anchor to `Latest release 1.2.3`, row anchor/observation to `1.2.0`, matching synthetic receipt and `derived:` note: BASE returns `passed=true, observed=1, fired=0, derived=1, errors=[]`. That is inherited BASE behavior, not a killed mutant.

## Scope and axes
BASE: `3553d499577084a6c98d7078906017840bbf7b28`; every source citation above/below is at that revision.
Axes: **freshness** (release-clock correctness), **calibration** (honest detection/coverage limits). No score, admission or production-fix judgment is made.
Sandbox `S=.ufo/waves/round-28/sandboxes/MutBaseDerived-7` relative to the lane root. Twelve complete, separately copied BASE trees (`S/M01`…`S/M12`), one behavior-bearing line changed per tree; no sibling source edited.
Detector: `/usr/bin/python3 -I -B corpus/release-clock.py --selftest`, cwd each tree, 120-second subprocess limit, six concurrent workers. `TMPDIR` is each tree's `.mutbase-tmp`; bytecode disabled. Python 3.14.8; no installation/update.

## Mutants, expected detectors, actual outputs and verdicts
Actual stdout suffixes below omit only the common `RELEASE_CLOCK_SELFTEST: ` prefix. Full stdout/stderr, argv, cwd and hashes are retained in the JSON evidence. Every selftest stderr was empty; no timeout occurred.

| Mutant | BASE point / single replacement | Expected detector | Actual stdout suffix | Exit / verdict |
|---|---|---|---|---|
| M01 | `corpus/release-clock.py:565`: `is_derived = False` | derived acceptance/count case | `FAIL derived anchor counted: derived=0 != 1` | 1 / killed |
| M02 | `corpus/release-clock.py:565`: `startswith("derived")` | reject missing-colon marker | `PASS (79 cases)` | 0 / survived |
| M03 | `corpus/release-clock.py:565`: `"derived:" in values["note"]` | reject infix marker | `PASS (79 cases)` | 0 / survived |
| M04 | `corpus/release-clock.py:566`: `anchor_ok = True` | unnamed anchor refused | `FAIL unnamed anchor refused: passed=True` | 1 / killed |
| M05 | `corpus/release-clock.py:566`: remove `is_derived or` | derived acceptance/count case | `FAIL derived anchor counted: derived=0 != 1` | 1 / killed |
| M06 | `corpus/release-clock.py:622`: `derived += 1` | direct-row derived count must be zero | `PASS (79 cases)` | 0 / survived |
| M07 | `corpus/release-clock.py:622`: `derived = row_derived` | two valid derived rows must total two | `PASS (79 cases)` | 0 / survived |
| M08 | `corpus/release-clock.py:584`: `row_derived = False` | fired-derived count case | `FAIL non-numeric anchor keeps inequality: derived=0 != 1` | 1 / killed |
| M09 | `corpus/release-clock.py:586`: `row_derived = False` | unchanged-derived count case | `FAIL derived anchor counted: derived=0 != 1` | 1 / killed |
| M10 | `corpus/release-clock.py:345`: remove left `(?<![A-Za-z0-9.])` | reject version suffix inside larger token | `PASS (79 cases)` | 0 / survived |
| M11 | `corpus/release-clock.py:345`: remove right `(?![A-Za-z0-9.])` | reject version prefix inside larger token | `PASS (79 cases)` | 0 / survived |
| M12 | `corpus/release-clock.py:346`: `return True` | unnamed anchor refused | `FAIL unnamed anchor refused: passed=True` | 1 / killed |

## Executed concrete counterexamples for survivors
`S/witness.py` is a separate offline observation probe, not a replacement for the frozen C2 fixtures or the selftest detector. It runs unchanged on pristine/mutated/restored bytes (30-second limit, all exits 0). All receipts are synthetic matching HTTP-200 records; feed id S002, feed URL `https://example.test/releases.atom`, feed anchor `Latest release 1.2.3`. Rows are S001 (and S004 for the two-row case), `not-fired`, observed version equal to row anchor. No network call.

| Mutant / probe | Concrete input | Pristine and restored output | Mutated output |
|---|---|---|---|
| M02 / `no_colon` | own anchor `Version 1.2.3`; row `1.2.0`; note `derived accidentally without colon` | `passed=false, observed=0, derived=0, errors=[["INCONSISTENT","S001"]]` | `passed=true, observed=1, derived=1, errors=[]` |
| M03 / `infix_marker` | same versions; note `audit derived: newest stable release` | same rejection as M02 | same acceptance as M02 |
| M06 / `plain_row` | own/row `1.2.3`; note `test` | `passed=true, observed=1, derived=0, errors=[]` | identical except `derived=1` |
| M07 / `two_derived` | two rows at `1.2.3`; notes `derived: first` / `derived: second` | `passed=true, observed=2, derived=2, errors=[]` | `passed=true, observed=2, derived=true, errors=[]` (boolean prints numerically as 1 in the CLI) |
| M10 / `left_subtoken` | own anchor `Version 11.2.3`; row `1.2.3`; note `test` | `passed=false, observed=0, errors=[["INCONSISTENT","S001"]]`; matcher false | `passed=true, observed=1, errors=[]`; matcher true |
| M11 / `right_subtoken` | own anchor `Version 1.2.30`; row `1.2.3`; note `test` | same rejection as M10; matcher false | same acceptance as M10; matcher true |

C2 test advice [INFERENCE, not exercised against a candidate]: retain explicit feed-version metadata in positive fixtures; add mismatch/typed-row-id negatives, marker-shape negatives, strict token-boundary negatives, direct-row zero and multi-derived count assertions. Exact feed-source binding must not be replaced by either marker trust or matching another row's anchor. Frozen G1–G4/counting commands remain unchanged.

## Hashes and exact restoration
Common pristine/restored SHA-256 `H=53823416d267e886d780fc347f6ef6f347592ba117ebc296e2148e88a2a136dc`.
Each lifecycle is `H → mutant hash below → H`. Each mutated hash was unchanged by its detector/probe. Restoration copied pristine bytes in a `finally` block; all twelve copy exits 0, all twelve explicit byte comparisons true. Restored selftests all exit 0/PASS79; restored contrast outputs match the pristine observations above.

| Mutant | Mutated SHA-256 |
|---|---|
| M01 | `0defc30a93ba085f4ebf867cc524c84591bd685986be532a828ef4421c0743af` |
| M02 | `5b3a3a0d72334dc92e3af767a05a1a31ce1fd8e5c1ea18fd92cb1230aeb671f1` |
| M03 | `815664860eb249ec6fc863d9562dd904ec26c322252bee670d1282476f387b1f` |
| M04 | `32bf09139774a30a7fbdee1fa93a66c3d51c2310f64c59453876ab343c117e5d` |
| M05 | `567ee5868ad32dfff644acf4c388f869bf4aa98b80995491255a7a7f92c3c232` |
| M06 | `c6d1819bda797b2e9f74f5958b7a2568003f739c21b0e32ee97ee2962a901fc9` |
| M07 | `60580fd7f7f5ad3ed32599aa6c33b45e6b1940200b88882c3ba165149d637fe3` |
| M08 | `9e5ab2192f52e8b8aee8199acfc3233fb6b2f8d76149cc0ed9470573ad971dc8` |
| M09 | `2cd85f7234307382ceb798e40ea22ff0f430473b97d98cfb34cbc3da961ad381` |
| M10 | `e705017b393bb722c579db13a28a35df76a997a4df917f3ddfc9616f429626b4` |
| M11 | `e885080cb5fbeb4e5e668d4f2662420bebf4698f1efce38362957dd4ad94311f` |
| M12 | `57b42a4739f7486ba3e6349922060755caed27ad64856b0a46bbc5e7ae1b010b` |

## Commands and retained evidence
- Preparation, exit 0: `mkdir -p "$S/base" && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 3553d499577084a6c98d7078906017840bbf7b28 | tar -x -C "$S/base"` (here S denotes its absolute sandbox path).
- `sha256sum corpus/release-clock.py` in `S/base`: exit 0, H. `du -sh base` in S: exit 0, `105M base`. `python3 --version`: exit 0, `Python 3.14.8`.
- `python3 -I -B run-mutants.py baseline` in S: exit 0; twelve `cp -a --reflink=auto base Mxx` exits 0; twelve pristine selftests PASS79/exit 0. Surgical tool edits then changed exactly the tabled line in each copy.
- `python3 -I -B run-mutants.py mutated` in S: wrapper exit 0 means restored successfully, NOT all mutants passed. Twelve mutant exits are tabled above; twelve restored selftests PASS79/exit 0.
- Each phase also ran `/usr/bin/python3 -I -B "$S/witness.py" "$S/Mxx/corpus/release-clock.py"`; all 36 exits 0. Each restoration ran `cp --reflink=auto "$S/base/corpus/release-clock.py" "$S/Mxx/corpus/release-clock.py"`, exit 0.
- Complete raw outputs/hashes/commands: `.ufo/waves/round-28/sandboxes/MutBaseDerived-7/baseline.json` and `.ufo/waves/round-28/sandboxes/MutBaseDerived-7/mutated-restored.json`. Evidence runners: same directory, `run-mutants.py` and `witness.py`.

## Not checked / bounds
No production code changed or executed; no candidate C1/C2 patch tested; no C1 F1–F4 or frozen C2 G1–G4 measurement run; no default real-corpus gate run. No live feed/vendor truth, host-private material, account/vault/handler/CDP, ledger host-row execution, lane-wide gates, other runtime, admission, integration, commits or pushes. Ledger pins were read only. This report is lane-authored advice, not closure.
