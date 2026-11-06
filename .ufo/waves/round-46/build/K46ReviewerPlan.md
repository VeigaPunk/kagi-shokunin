# K46ReviewerPlan — pre-candidate attack on round-46 (kagi, attempt 1)

Scope: frozen plan `plans/round-46.md`, counters `plans/round-46-c1.sh` and `plans/round-46-c2.sh`,
controls `plans/round-46-controls.py`. No candidate exists; every fixture is built in scratch from
BASE `f5977284a8ce5bab09252be8196ee5dc18489926` with the controls module's own builders. The lane
tree was not written. Receipts: `build/K46ReviewerPlan/` (scripts and `results-F1-F8.txt`).

## 1. Baseline runs (as read by this seat, not copied from the plan)

| run | command | rc | last line (verbatim, trimmed where marked) |
|---|---|---|---|
| C1 at BASE | `HYAKU_SCRATCH=…/kagi-r46/K46ReviewerPlan bash plans/round-46-c1.sh f5977284a8ce5bab09252be8196ee5dc18489926` | 0 | `C1_SELFTEST_KILLS: value=0 killed=0 positive=1 equiv=1 real=1 (rc e1=0 e2=0 e3=0 e4=0 m1=0 m2=0 m3=0; selftest-rc=0 selftest-last='CLAIMS_DECLARED_SELFTEST: PASS (8 cases)'; real-rc=0 real-last='CLAIMS_DECLARED: CLEAN (claims=17)')` |
| C2 at BASE | `HYAKU_SCRATCH=… bash plans/round-46-c2.sh f597728…` | 0 | `C2_FRESH_CLOCKS: value=0 fresh=0 default=0 pinned=0 kept=1 (default-rc=1 default-last='RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)'; pinned-rc=none pinned-last='no-receipt'; receipt-sha=-; missing=S005,…,S032,S098)` (missing list = the 29 ON29 ids) |
| controls | `HYAKU_SCRATCH=… python3 -B plans/round-46-controls.py` | 0 | `CONTROLS: MATCH (11 controls, 0 differ)`; every K-line equals the line in `controls/controls-prefreeze.txt` |

Both counters at BASE match the plan's measured lines exactly. Controls: 11/11 MATCH. Nothing
in the lane was written.

## 2. Findings

Severity: **high** = a frozen target reads its value on a tree that lacks the claimed work or
lacks the frozen kill-rule enforcement; **medium** = the measurement reads green for a state the
plan's intent excludes; **low/info** = fail-closed, held, or bounded by a named ceiling.

### K46RP-01 — high — C1 operability — an out-of-block edit scores 3; the kill rule "diff outside the `--run-selftest` block → killed" is not enforced by the counter

- Fixture `f1-axis`: BASE gate + frozen reference cases 9–10 (`c1_positive`) + one edit outside the
  block: the AXES case at line 122 loses `|adjacency`.
- Command: `C1_TREE=<f1-axis> HYAKU_SCRATCH=<scratch> bash plans/round-46-c1.sh` (fixture mode).
- Observed (rc 0): `C1_SELFTEST_KILLS: value=3 killed=3 positive=1 equiv=1 real=1 (rc e1=0 e2=0 e3=0 e4=0 m1=1 m2=1 m3=1; selftest-rc=0 selftest-last='CLAIMS_DECLARED_SELFTEST: PASS (10 cases)'; real-rc=0 real-last='CLAIMS_DECLARED: CLEAN (claims=17)')`
- The diff against `git show BASE:corpus/claims-declared.sh` has one out-of-block change: `-…|calibration|adjacency) ;;` → `+…|calibration) ;;`.
- Why it is a false green: the counter never diffs the gate, so the frozen kill rule has no code path that can fire. The REAL leg only runs the measured tree, which contains no `adjacency` row.
- Suggested fix: add a counter leg that diffs the measured gate against BASE outside the `--run-selftest` block (header comment excepted) and sets value 0 on any non-block change. A counter change after any seat scores is an L0 amendment; before scoring, the plan may instead name "diff review is the sole leg" as a declared ceiling. Do not leave the kill rule unimplemented and unnamed.

### K46RP-02 — high — C1 operability — the plan-to-manifest leg itself can be weakened and still score 3

- Fixture `f2-axis-blind-leg`: BASE gate + reference cases 9–10 + lines 192 and 208 rewritten so the manifest key is `(round, claim)` without the axis (both edits are inside the plan-to-manifest leg, outside the selftest block).
- Command: as K46RP-01 (`C1_TREE=<f2> … bash plans/round-46-c1.sh`).
- Observed (rc 0): `C1_SELFTEST_KILLS: value=3 killed=3 positive=1 equiv=1 real=1 (rc e1=0 e2=0 e3=0 e4=0 m1=1 m2=1 m3=1; selftest-rc=0 selftest-last='CLAIMS_DECLARED_SELFTEST: PASS (10 cases)'; real-rc=0 real-last='CLAIMS_DECLARED: CLEAN (claims=17)')`
- Scope of the weakness: the axis key differs from the first loop only when one claim has two plan headings on different axes and a manifest row for only one of them. Neither the BASE selftest nor the real tree has such a case, so the counter cannot see it.
- Verified fix (`build/K46ReviewerPlan/f2b.py`, executed): add reference case 11 — plan `## C1 — freshness:` and `## C1 — depth:`, manifest row `90 C1 freshness` only, expect `MISMATCH 90 C1 no-manifest-row` rc 1. Result (executed): strict gate `value=3 killed=3 … PASS (11 cases)`; axis-blind gate `value=0 killed=3 positive=0 … selftest-rc=1 selftest-last='CLAIMS_DECLARED_SELFTEST: FAIL (passed=10/11)'`. Adding case 11 is inside the `--run-selftest` block and kills the weakening through the gate's own self-test.
- Keep K46RP-01's fix as well: case 11 closes this leg; the diff leg closes the class.

### K46RP-03 — medium — C1 predicate intent — "killed" counts any non-zero exit, including the gate's own SETUP exit 2

- Frozen wording: "KILLED: mutant whose `--selftest` exits non-zero" (matches the code; `[ "$mrc" -ne 0 ]`).
- Fixture `f3b-setup-only`: BASE gate + one selftest line `[ "$(wc -l < "$GATE_SRC")" -eq 239 ] || exit 2` (no reference cases; the count is taken from the fixture itself).
- Command: `C1_TREE=<f3b> HYAKU_SCRATCH=<scratch> bash plans/round-46-c1.sh`.
- Observed (rc 0): `C1_SELFTEST_KILLS: value=1 killed=1 positive=1 equiv=1 real=1 (rc e1=0 e2=0 e3=0 e4=0 m1=2 m2=0 m3=0; selftest-rc=0 selftest-last='CLAIMS_DECLARED_SELFTEST: PASS (8 cases)'; real-rc=0 real-last='CLAIMS_DECLARED: CLEAN (claims=17)')`
- M1 is "killed" by exit 2 (a SETUP), not by the self-test detecting the removed report line. Same pattern with `f3` (reference cases present): `m1=2` counted as a kill, value 3 only because case 9 also kills M1.
- Fix options: (a) before scoring, amend KILLED to require rc 1 and last line `CLAIMS_DECLARED_SELFTEST: FAIL…` (named L0 amendment); or (b) name it as a declared ceiling: "a self-test that exits 2 on a mutant counts as a kill". Option (a) is preferred; the detection-only reading is the plan's intent.

### K46RP-04 — medium — C2 freshness — `observed_at` has no upper bound; a future-dated receipt scores 29

- Fixture `f4-future`: positive receipt with every `observed_at` changed to `2099-12-31T00:00:00Z`, tsv synced by the controls' own `c2_rebind`, default repointed.
- Command: `C2_TREE=<f4> HYAKU_SCRATCH=<scratch> bash plans/round-46-c2.sh`.
- Observed (rc 0): `C2_FRESH_CLOCKS: value=29 fresh=29 default=1 pinned=1 kept=1 (default-rc=0 default-last='RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)'; pinned-rc=0 …; receipt-sha=e8b15aca…; missing=none)`
- Cause: `release-clock.py` checks only `valid_iso_date` and the `Z` suffix, and `dt.datetime.now` is used only for stamping; the counter's `at[:10] >= "2026-11-06"` has no ceiling. The frozen sentence says `≥`, so the counter matches its predicate; the predicate is the gap.
- Checked: all 29 records of the positive receipt are dated 2026-11-06, so an upper bound at 2026-11-06 is consistent with the live receipt (read from the receipt, not re-observed).
- Fix: an upper bound (≤ 2026-11-06, or ≤ the run date) is a named L0 amendment before scoring. The real freshness check remains the non-author live re-observation (K46ReviewerLive); the receipt itself is writable.

### K46RP-05 — low — C2 operability — PINNED digests the file it measures, so the pin is self-consistent only

- Counter: `RSHA=$(sha256sum < "$T/$RECEIPT")` then `gate --receipt … --receipt-sha "$RSHA"`. The header says "sha256 of that committed file"; in fixture or revision mode that is the measured file's own digest, so PINNED=1 for any loadable receipt. The real pin is the gate's `DEFAULT_RECEIPT_SHA256`, which DEFAULT checks.
- Fixture `f8-pinned-only`: observe-r46 present, default not repointed (round-36 default).
- Command: `C2_TREE=<f8> … bash plans/round-46-c2.sh`.
- Observed (rc 0): `C2_FRESH_CLOCKS: value=0 fresh=29 default=0 pinned=1 kept=1 (default-rc=1 default-last='RELEASE_CLOCK: FAILED (on_release=29 bound=29 unbound=0 observed=0 fired=0 derived=0)'; pinned-rc=0 pinned-last='RELEASE_CLOCK: CLEAN …'; …)`
- Held: value is 0 because DEFAULT fails. Still, PINNED=1 is not evidence of a pin. Fix (cheap, L0): take the expected digest from the candidate's `DEFAULT_RECEIPT_SHA256`, or from a digest recorded in the frozen plan, not from the tree.

### K46RP-06 — info (held) — C2 — the FRESH count does not check `error`; the gate does

- Fixture `f5-error-record`: positive receipt with an `error` key added to S008 (an ON29 row), http_status still 200.
- Observed (rc 0): `C2_FRESH_CLOCKS: value=0 fresh=29 default=0 pinned=0 kept=1 (default-rc=1 default-last='RELEASE_CLOCK: FAILED (on_release=29 bound=29 unbound=0 observed=28 fired=13 derived=14)'; …)`
- Held: `receipt_matches` rejects any record with `error`. The `fresh=29` field is therefore not a verdict and must not be quoted without `value`. Tightening FRESH to check `error` absence would be an L0 change; not needed for the value.

### K46RP-07 — info (held) — C2 parser — naive `|` split; the gate agrees

- Fixture `f6-cell-pipe`: a `|` added inside the S005 row. The gate itself reports `RELEASE_CLOCK: SETUP (corpus/SOURCES.md:11 has 13 fields, expected 11)` (rc 2), and the counter maps that to `value=0 … missing=S005`. Fail-closed and consistent with the gate; no false green or red divergence. The registry prose line with `\|` (SOURCES.md line 131) is not a table row and is not parsed.

### Checked, no finding

- Empty producer output: the C2 python producer, if it prints nothing, yields `SETUP parser-empty` (exit 2, no value). The C1 `selftest()` maps empty output to pass=0. `read` splitting: the last fields (`plast`, `detail`, `dlast`) take the remainder of the line; no mis-split observed.
- Kill rules that can fire on the counters as written: C1 value < 3 (fires), C1 exit 2 (fires), C2 value < 29 (fires via K2-F3), C2 registry row deletion (fires via KEPT; K2-F2), C2 ON29 recheck leaving on-release (fires via FRESH; K2-F3). Not enforced by any counter: C1 out-of-block diff (K46RP-01) and C2 non-author live re-observation (by design, separate seat).
- Causal separability: K1 and K2 are built from BASE with only their own change, as stated. Confirmed by the controls runner's own construction.

## 3. Named surviving defects (after the attacks above)

1. C1 kill rule for out-of-block edits is not implemented in the counter (K46RP-01).
2. C1 plan-to-manifest leg has no reference case for two axes on one claim; a weakening scores 3 (K46RP-02; fix verified by case 11).
3. C1 KILLED counts exit 2 (K46RP-03).
4. C2 FRESH has no upper bound on `observed_at` (K46RP-04).
5. C2 PINNED self-digests (K46RP-05, held by DEFAULT).
6. Declared ceilings re-confirmed by execution: hand-written C2 receipt scores 29 (controls K2-F4, not re-run); C2 freshness rests on a writable receipt (the non-author live leg is the check).

## 4. Commands and receipts

- Scratch: `/fast/scratch/hyaku/kagi-r46/K46ReviewerPlan/` (fixtures under `fx/`; removed on exit).
- Scripts (in this report dir): `fixtures.py` (F1, F2, F3-initial, F4, F5, F6, F8), `f3.py` (F3 corrected), `f3b.py` (F3b), `f2b.py` (case-11 separation test).
- Results: `results-F1-F8.txt`. Its F3 line is the superseded first attempt (fixture bug: the line-count check ran on the positive control too, so the self-test exited 2 on every tree); the corrected F3 run (`f3.py`) printed `C1_SELFTEST_KILLS: value=3 killed=3 positive=1 equiv=1 real=1 (rc e1=0 e2=0 e3=0 e4=0 m1=2 m2=1 m3=1; selftest-rc=0 selftest-last='CLAIMS_DECLARED_SELFTEST: PASS (10 cases)'; real-rc=0 real-last='CLAIMS_DECLARED: CLEAN (claims=17)')`, rc 0. `f3b.py` (the clean isolation, cited in K46RP-03) printed `value=1`, `m1=2`.
- Exit codes: all fixture runs rc 0 (the counters exit 0 for measured values; fixture F6's gate rc 2 is the gate's own SETUP).
- No `git` mutation, no install, no lane write, no network access.

Tooling: none installed.
