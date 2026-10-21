# XC1Patch — round-28 C1 canonical version tokens (executor report, revision 3)

Scope: sandbox draft against frozen BASE 3553d499577084a6c98d7078906017840bbf7b28. The lane checkout was not run or written (only `diff -rq`, `cmp`, `sha256sum`, read tools). No tool installs.

Revision 3 adds the integrated-lane divergence and frozen-tool rerun. The published C1 diff remains strict and plan-conformant; the lane currently contains the weaker revision-1 behavior. A lane-side strict candidate is prepared, not applied.

## Deliverables

- Patch: `.ufo/waves/round-28/build/XC1Patch.diff`, 318 lines (188 `+`, 14 `-` content lines). `patch -p1` dry-run and apply exit 0 on a BASE copy; the applied file is byte-identical to the patched file; the default run on that copy exits 0, CLEAN.
- C1-alone patched file: `.ufo/waves/round-28/sandboxes/XC1Patch/release-clock.py`, sha256 8d59adf4139a1274eb4d817c032a5f4b17201fcc7e27c069acf32ee7313653d0, 1945 lines. BASE is 1758 lines, sha 53823416…, pinned at `corpus/stamps.tsv:77`.
- Composed C1 + XC2 candidate: `.ufo/waves/round-28/sandboxes/XC1Patch/composed/corpus/release-clock.py`, sha256 a36bc4e305ea7e24b82ac325bb595d875aea2789cd681a99a65bef10480bd9cb, 2035 lines.
- Lane-side strict candidate: `.ufo/waves/round-28/build/XC1LaneStrict.diff` (61 lines, 13 `+`, 17 `-` content lines); applied only to a sandbox copy of the integrated lane.

## Findings at BASE (path:line, 3553d49)

1. **Oversize int crash, table path.** `corpus/release-clock.py:380` `int(part)` in `numeric_version` (369–380). Reached from `is_regression` (385–386), from evaluate (567–568, 577), and from `feed_floors` (404, 408), which runs at 523 (evaluate) and 885 (run_observe). Counterexample F2: S040 `observed_version=3.15.`+4301×`1`, verdict fired → Traceback, `ValueError: Exceeds the limit (4300 digits)`, exit 1.
2. **Leading zero written as a fired release, --observe.** `:760` `max(stable, key=int)` ranks `Python 3.15.01` above `3.15.0`; `:798–801` compares strings and writes `verdict="fired"`. Counterexample F3: python.org titles `Python 3.15.01` and `Python 3.15.0` → receipts S027, S028, S040, S041 each `parsed_version=3.15.01`, `fired`.
3. **F1 depends on the mirrored receipt fixture.** BASE `:582–583` uses string inequality; the frozen F1 mirrors S040's edited `3.15.01`/fired values into the receipt, so BASE exits 0 CLEAN with fired=4. The earlier custom reproduction used the pinned default receipt and therefore measured RECEIPT-MISMATCH instead; that was not the frozen F1.
4. **F4 retained-artifact fixture construction differs from the current frozen identity-edit fixture.** The integrated `c1-measure.py` (sha fa1706f5…) leaves S040's row unchanged and tests the oversized token only in the feed; BASE exits 1 without traceback and classifies OTHER. Pre-integration tool sha c78029c5… produced the retained BASE artifact (14:24) with F4's 4301-digit value reaching table `evaluate()` / `numeric_version` (BASE `:380`) and a traceback. Its patched-probe artifact also records the row-guard error. These artifacts are historical, not the same F4 construction as the current frozen tool.
5. **Feed poisoning.** A non-canonical anchor becomes the feed floor: `feed_floors` 404–409 with `1.2.04` lifts the floor above S001's `1.2.3`, giving REGRESSED S001 and INCONSISTENT S004 (selftest case; BASE fails it).
6. **Wrong category by accident.** Observed `1.00.0` below anchor `1.2.3` is REGRESSED on BASE, not a canonicality finding.
- **F7r, derived anchor accepted at BASE.** `evaluate()` at `corpus/release-clock.py:566` sets `anchor_ok = is_derived or …`; numeric strictness at `:577` checks only `observed_version`. Counterexample: derived row `anchored=1.2.03`, `observed=1.2.03`, `verdict=not-fired`, matching receipt → BASE has no errors, `observed=1`, `passed=True` (the red selftest result). The strict branch flags NON-CANONICAL. This is selftest evidence, not frozen F1–F4 coverage: none of those fixtures carries a non-canonical anchor. The integrated lane's C2 guard keeps the derived case in its selftest; the strict lane candidate passes it.
7. **Dead second grammar.** `VERSION_RE` at `:30–33` has no users (grep: definition only) and accepts leading zeros and suffixes. The patch deletes it.
8. **Sourcing update.** At BASE `corpus/SOURCES.md:49` (S042) teaches §11.2 only. The integrated lane now has S044 (Python int-string limit) and S045 (SemVer §2); this resolves the cited sourcing gap there. The standalone XC1Patch.diff still cites S042 for §2; the lane-side strict candidate retains the integrated S045 citation.
9. **Integrated lane diverges from the strict patch.** The lane's `newest_stable` at `corpus/release-clock.py:784-798` silently ignores a non-canonical entry below the canonical max; `corpus/lessons/round-28.md:63-64` documents that weaker rule. BASE plan C1 `plans/round-28.md:21-23` requires any feed-entry token to be canonical and otherwise a typed feed finding. No plan correction narrows that scope. Lane-copy control is CLEAN, selftest PASS (106), but `3.15.1` + `3.14.01` returns `3.15.1` without a finding.
10. **Retained measurement artifacts use the pre-integration tool.** Current tool sha fa1706f5… rerun on BASE is MISHANDLED 3/4, OTHER 1/4; pre-integration tool sha c78029c5… artifacts report 4/4, with F4 table traceback and patched-probe row-guard receipt. The lane-native identity-edit tool and current rerun agree on the 3/4 result.

## Revision 2 changes (RevSelftestIsolation-7 defects)

- **D1, derived case (took option a).** The case "derived leading-zero anchor refused" is removed. Every derived feed row is bound by C2 to its feed registry anchor, so a derived C1 case cannot stay separable: its exact error set changes under C2. The non-derived anchor case stays. NON-CANONICAL is decided before any note-dependent branch, so derived rows are covered by the same code path.
- **D3, total feed rule (plan fidelity).** `plans/round-28.md:26-28` says a version token used for a feed entry \"must be canonical … otherwise the row or feed gets a typed finding\". `newest_stable` refuses every non-canonical stable entry, including below-newest `v3.14.01` alongside `v3.15.0` and a 4301-digit patch component. The integrated lane instead ignores below-newest entries; no plan correction narrows the scope.
- **D2, composition.** See Composition.

## Patch (C1 alone)

- `VERSION_COMPONENT_MAX_DIGITS = 18`: a component is canonical iff it is `0`, or has no leading zero and at most 18 digits. Justification: values up to 999,999,999,999,999,999 fit a signed 64-bit integer; 18 digits is 4282 below the 4300 limit (`sys.get_int_max_str_digits()` = 4300 on this Python 3.14.8); no release counter nears 10^18. Boundary tested: 18 accepted, 19 refused.
- `non_canonical_version`: strict X.Y.Z (optional `v`) with a bad component. Non-strict text (`1.2.x`, `1.3`) and suffixed tokens are not flagged; their semantics are unchanged.
- `version_order`: (length, digits) per component. `numeric_version` returns it for canonical tokens and None otherwise. No `int()` on version text remains in the module (checked on code lines, comments excluded). `feed_floors`, `is_regression` and `run_observe` inherit the gate.
- evaluate: NON-CANONICAL is the first branch of the feed chain; a receipt whose error starts with `NON_CANONICAL_PREFIX` is typed NON-CANONICAL before `receipt_matches`.
- Parse: `newest_stable` refuses any non-canonical stable entry, otherwise returns the numeric max; the text branch refuses a non-canonical version.
- observe_one: a feed row with a non-canonical anchor or observation writes an error receipt before any request.
- Category `NON-CANONICAL`, printed as `NON-CANONICAL <id>` on stdout for table and observe paths; not a BASE-era name.
- Selftest: `run_case` wraps evaluate in try/except ValueError (recorded as FAIL, no abort). +18 cases: 7 run_case, 7 parser (incl. older leading-zero and older oversize refused), 3 observe_one, 1 run_observe end-to-end asserting NON-CANONICAL S001 through evaluate. Count 79 → 97.

## Results

| Check | Result |
|---|---|
| BASE default, replica | exit 0 CLEAN (30/30/0/30/3/15) |
| C1-alone selftest | BASE exit 0 PASS (79); strict patch exit 0 PASS (97) |
| Composed BASE+C1+C2 draft | exit 0 PASS (103); default byte-identical to BASE |
| Lane integrated copy | default exit 0 CLEAN; selftest exit 0 PASS (106) |
| Lane strict candidate (`XC1LaneStrict.diff`) | default exit 0 CLEAN; selftest exit 0 PASS (107) |
| Frozen instrument rerun: BASE | MISHANDLED 3/4, TYPED 0/4, OTHER 1/4; control clean |
| Historical pre-integration `XC1Measure-base-c1.json` | MISHANDLED 4/4 (different F4 construction; not comparable to identity-edit rerun) |
| Frozen instrument: strict patch, composed, lane snapshot, lane-native 62a33b1 and lane-strict | each MISHANDLED 0/4, TYPED 4/4, OTHER 0/4; fired observation written=false on F3/F4 |
| Property checks | strict patch and lane-strict exit 0, 24/24 PASS |

The frozen F1/F2 fixtures mirror edited table rows into receipts; my earlier `out/c1_repro.py` did not, so its F1 count is superseded. BASE+patched-selftest remains exit 1 (25 FAIL lines, all 18 new case names). The stricter rule is distinguished by the added selftest `older leading-zero refused`: lane integrated parses `3.15.1` alongside `3.14.01`; lane-strict refuses with `NON-CANONICAL`.

## Lane-side strict candidate and L1 decision

- `build/XC1LaneStrict.diff` (61 lines) applies to lane-native rev `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, preserves its later C2/S044/S045 edits, rejects every non-canonical stable entry, changes older-oversize to require a typed refusal, and adds the below-newest leading-zero case. Dry-run/apply both exit 0 in a sandbox; resulting file sha `89bcead2…`, selftest PASS (107), default CLEAN.
- Lane-native `62a33b1` itself remains lenient on below-newest entries; the current frozen candidate artifact `XC1Measure-candidate-c1.json` measures F1–F4 TYPED 4/4 because those fixtures do not exercise below-newest input.
- Frozen predicate follow-up: with current identity-edit fixtures, BASE is MISHANDLED 3/4 (k=3); F4 is OTHER and becomes TYPED after strict handling. L1 should append this measured `k=3` and OTHER→TYPED transition as a plan correction; leave the frozen command and fixture values unchanged.
- Recommendation: restore strict rule because it matches frozen plan C1. If L1 chooses the weaker at-or-above-newest scope, append a plan correction and add a frozen below-newest fixture; code, lesson and published diff must then agree.

## Composition (C1 + XC2 final), built and tested

- `git merge-file -p --diff3` (BASE as ancestor, C1 patched file, `sandboxes/XC2Patch/release-clock.py` sha 94e5072a…) exits 2: two conflicts. XC2 touches only `corpus/release-clock.py`.
- Conflict 1, evaluate feed chain: resolved as XC2's `if is_derived:` / `else:` anchor block, then C1's NON-CANONICAL branch, then `elif (is_regression(…)`. A non-canonical derived row can get both DERIVATION and NON-CANONICAL; no case tests that.
- Conflict 2, selftest tail: both blocks kept (additive; C1 end-to-end, then C2 observe-derived).
- Composed results: default exit 0 `CLEAN`, bytes identical to BASE (cmp 0); selftest exit 0 `PASS (103 cases)` (79 + 6 XC2 + 18 C1); XC2 alone exit 0 `PASS (85 cases)`; C1 fixtures F1–F4 TYPED 4/4; property checks exit 0, 24/24.
- Sanity: `git apply` failing on either diff alone is expected for two patches on one chain; the merge above is the working composition.

## Coordination and L1 pins (production read-only; I edited none)

- Counts: C1 alone 97; the earlier XC2 draft composition 103; current integrated lane 106; strict lane candidate 107. If L1 restores strict feed handling, pins should reflect the integrated composition actually selected.
- Pins: `corpus/claim-ledger.tsv:82` (79 today), `SKILL.md:48` and `PROVINCE.md:54` (checked by `corpus/self-counts.tsv:22` and `:38`), and `corpus/stamps.tsv:77` (sha/lines/bytes). Current strict lane candidate is 107 selftest cases.
- Finding name: `NON-CANONICAL`, the plan's spelling. RevSelftestIsolation-7 proposed `NONCANONICAL`; the choice is L1's.
- Interface: `numeric_version` returns digit-order tuples, not int tuples. Users are in-file only; round-27 c2-measure runs the script as a subprocess.

## Declared limits (not hidden)

- Scope of "feed entry": exact `X.Y.Z` titles and `/releases/tag/X.Y.Z` links only. Prerelease tags (`v2.2.0-rc.01`) and module tags (`sdk/v0.01.0`) are skipped by the parser as before and are not canonicalized. If the plan means them too, that is a further rule and L1 must decide it.
- Availability cost, by design of D3: one non-canonical stable entry anywhere in a feed fails that feed's observation, typed, until the entry ages out of the feed.
- NON-CANONICAL receipt typing trusts the receipt's error text. Default-run receipts are digest-pinned.
- Only X.Y.Z cores are canonicalized; numeric prerelease identifiers with leading zeros (`1.2.3-rc.01`) are not flagged, though SemVer §9 forbids them.
- Registry anchor cells are not parsed; `version_is_named` containment uses the canonical TSV token only.

## Commands and exits

- `git -C <lane> archive 3553d49… | tar -x -C base` → 0; lane-vs-BASE corpus `diff -rq` → 0; base receipt sha matches default pin.
- BASE default/selftest → 0/0 (CLEAN / PASS 79); C1 patched default/selftest → 0/0 (same CLEAN bytes / PASS 97); composed draft default/selftest → 0/0 (CLEAN / PASS 103).
- Lane-copy default/selftest → 0/0 (CLEAN / PASS 106); lane-strict candidate default/selftest → 0/0 (CLEAN / PASS 107).
- BASE code + patched C1 selftest → 1 (25 FAIL lines, all 18 new names). Property checks on strict C1 and lane-strict → 0, 24/24.
- `patch -p1 --dry-run` and apply XC1Patch.diff → 0; applied file cmp → 0; applied default with receipt → 0. `diff -u` → 1 (changes).
- Integrated tool sha fa1706f5… artifacts: BASE `XC1Measure-base-c1-rerun.json` → MISHANDLED 3/4, OTHER 1/4; lane-native 62a33b1 `XC1Measure-candidate-c1.json` → TYPED 4/4. Pre-integration sha c78029c5… artifacts `XC1Measure-base-c1.json` and `XC1Measure-patched-probe-c1.json` are historical (F4 table-mirrored / row-guard construction).
- Frozen-tool F3/F4 `fired_observation_written` is false for strict PATCHED, COMPOSED, LANE and LANE-STRICT. The BASE artifact records F3 true.
- `git merge-file -p --diff3` → 2 conflicts, resolved in the earlier C1+C2 draft. `XC1LaneStrict.diff` → 1 from `diff -u` (expected differences); candidate verified in a sandbox.

## Not checked

- The lane checkout itself was not executed; checks used sandbox exports/copies. Its code, lesson and plan were read-only inspected.
- No live feeds; observation fixtures use the frozen instrument's local feed stubs.
- SemVer/CPython docs were not fetched during this seat; current lane registry has S044/S045.
- Claim-ledger, self-count, stamps and other gates were not run.
- L1 should decide strict restoration versus a plan correction for the weaker scope, and append the measured baseline `k=3` / F4 OTHER→TYPED correction; the frozen command and fixtures stay unchanged.
- The composition tested at 103 is the XC2 final available to this seat; the integrated lane later has additional C2 edits and selftest 106.

Installs: none. Sandbox writes: `.ufo/waves/round-28/sandboxes/XC1Patch/` (base, patched, composed, lane-copy, lane-fix, measure-repo, out/, release-clock.py) and `build/XC1Patch.diff`, `build/XC1LaneStrict.diff`, `build/XC1Patch.md`. Temporary `/tmp` files were created and removed.
