# FObsHuge — table observation with a 4301-digit patch (candidate 62a33b1)

**Verdict: PASS** for pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0` on the F2 table-oversize carrier. One candidate-side calibration observation: §4.
Carrier: `corpus/release-clocks.tsv` row **S040**, `observed_version = 3.15.` + 4301×`1`, `verdict=fired`. BASE `3553d499…` and candidate `62a33b1…` exported with `git archive` into my sandbox; offline only, no network, lane checkout never executed or mutated.

## 1. Frozen counting command (used unchanged) — exit codes
```
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… cand        → exit 0
  C1_MEASURE cand: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d499… base        → exit 0
  C1_MEASURE base: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… cand-rerun  → exit 0
  C1_MEASURE cand-rerun: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True
```
F2 candidate: `TYPED, exit=1, traceback=False, typed_finding_lines=["NON-CANONICAL S040"], clean_last_line=False, fired_observation_written=False`; stdout `NON-CANONICAL S040` + `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)`. F2 BASE: `MISHANDLED, exit=1, traceback=True` — `ValueError: Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits` from `base/corpus/release-clock.py:380`. Controls identical at both: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0.

## 2. Independent reproduction (own harness, not the frozen tool)
`python3 -I -B <sb>/probe_f2.py <tree> <label> <work>` builds the fixture itself (table edit + a copy of the default receipt) and runs the tree's own `corpus/release-clock.py --root … --receipt … --receipt-sha …`.
- **mirror** (S040's receipt record mirrored to the 4301-digit token, so the receipt MATCHES): exit **1**, stdout `["NON-CANONICAL S040", "RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)"]`, `traceback=False`, `tsv_immutable=True`, only `corpus/` + my `receipt.json` written. **No fired verdict written** (`fired=3`, unchanged from control; the bad row is excluded: observed 29, not 30).
- **nomirror** (pinned default receipt): exit 1, `["NON-CANONICAL S040","RECEIPT-MISMATCH S040",…]`, no traceback; the typed C1 category is present alongside the generic one.
- BASE, both variants: exit 1 with the ValueError traceback, no typed finding.

**Not accepted as generic-receipt-mismatch proof.** In-process attribution (`evaluate()` with the mirrored bundle): `receipt_matches('S040',…) == True`, the receipt record has **no** `error` key, and the error set is exactly `[('NON-CANONICAL','S040')]` — so the finding cannot have come from `receipt_matches`/`RECEIPT-MISMATCH` (`candidate corpus/release-clock.py:682`); it comes from the C1 row rule.

## 3. Mutation falsification (the rule is load-bearing)
- **A** `VERSION_COMPONENT_MAX_DIGITS = 18` → `4301` (`corpus/release-clock.py:388`): exit **0**, `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 …)` — the 4301-digit token is accepted and **counted as a fired release**. The bound is what prevents the release event.
- **B** the `if non_canonical:` row rule deleted (`corpus/release-clock.py:627-632`): exit 1, finding degrades to `INCONSISTENT S040` (a BASE-era category) — `NON-CANONICAL` is produced by the new rule alone.
- Candidate selftest under A: `RELEASE_CLOCK_SELFTEST: FAIL` (7 C1 cases); under B: FAIL (6 cases).
- **Candidate `selftest()` grafted onto BASE code**: exit 1 with ≥12 C1 failures (e.g. `version parser oversize newest refused: untyped refusal Exceeds the limit (4300 digits)…`, `observe oversize newest entry was not typed non-canonical`) — the new cases are not vacuous.
- Selftest counts BASE **79** → candidate **106**; ledger `R25-03` pins `106` (matches).
- Adjacent carriers of the same table path (candidate; all exit 1, no traceback): derived row **S008** oversize → `NON-CANONICAL S008` (C2 check correctly skipped); sibling **S027** on the same feed_url with an oversize anchor → `NON-CANONICAL S027` + `NON-CANONICAL S040` and **no false `REGRESSED`** on the legitimate sibling (`feed_floors` skips a non-canonical anchor, `release-clock.py:428/454`); non-derived **S040 anchor** oversize → `NON-CANONICAL S040`; `rendered-quote` row **S005** oversize `observed_version` → `INCONSISTENT S005` (typed; the C1 category is scoped to the `clock=="feed"` branch, `release-clock.py:617`); malformed row + oversize token → `INCONSISTENT S040`; `--observe` over the same row → receipt record S040 `verdict=null, parsed_version=null, error="non-canonical version token: row anchor or observation; no verdict written"`, no fired observation, 100 000-digit component typed in 0.05 s.

## 4. Calibration observation (pinned candidate; covered by the repair revision)
At `62a33b1` a **receipt-side** non-canonical token is typed generically: table row canonical + receipt `parsed_version` = the 4301-digit token (or `3.15.01`) → `[('RECEIPT-MISMATCH','S040')]`. The C1 category is reached only when the receipt carries an `error` string with the `NON_CANONICAL_PREFIX` (`release-clock.py:679`). Repair revision `5e84747` adds a `parsed_version` non-canonical test (`release-clock.py:679-681`); F2 is unaffected (mirrored receipt matches, the row rule fires first). **I did not re-run against `5e84747`** (L1 asked to keep the original candidate results) — that repair is unverified by me.

## Exact candidate paths:lines (pinned `62a33b1`)
`corpus/release-clock.py:388` (`VERSION_COMPONENT_MAX_DIGITS = 18`) · `:395-407` (`non_canonical_version`) · `:409-416` (`version_order`, never calls `int()`) · `:617` (`non_canonical = non_canonical_version(anchored) or non_canonical_version(observed_version)`) · `:627-632` (**the `NON-CANONICAL` row rule — the finding's source**) · `:679-681` (receipt-error → `NON-CANONICAL`) · `:869-872` (`--observe` refusal before any fetch). BASE `corpus/release-clock.py:380` — the crashing `int()` conversion falsified at BASE.

## Commands run (exit codes)
`c1-measure.py 62a33b1 cand` 0 · `c1-measure.py 3553d499 base` 0 · `c1-measure.py 62a33b1 cand-rerun` 0 · `probe_f2.py <cand>` 0 (child clock 1) · `probe_f2.py <base>` 0 (child clock 1, traceback) · `probe_mutation.py <cand>` 0 (children 0 and 1) · `probe_derived_floor.py <cand>` 0 (children 1) · `probe_observe_robust.py <cand>` 0 (children 1) · `probe_selftest_graft.py <base> <cand>` 0 (grafted selftest 1) · `release-clock.py --selftest` on the BASE tree 0 (79 cases) and on the candidate tree 0 (106 cases) · `release-clock.py` control on both trees 0 (CLEAN 30/30/30/3/15). No tool installed or upgraded this session.

## Counterexample (concrete)
BASE `3553d499…`, F2 table fixture (S040 `observed_version=3.15.`+4301×`1`, `verdict=fired`, receipt mirrored to match): exit 1, **no stdout finding**, stderr `ValueError: Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits` — untyped traceback, whose exit code is indistinguishable from a typed refusal. Candidate `62a33b1…`, same fixture: exit 1, stdout `NON-CANONICAL S040`, empty stderr.

## What I did NOT check (residual risk / verification gaps)
- F1/F3/F4 (leading-zero lie, Atom/RSS newest-title, observe-oversize feed carriers) — other seats' items; I attacked only the table-observation carrier and its immediate neighbours.
- Repair revision `5e84747` — not re-run; §4 covers only the candidate-side receipt gap.
- No live network fetch: `--observe` used the script's own `request_body` stub (the substitution the script's selftest uses), so real feed bytes were never involved.
- Other consumers of `release-clocks.tsv` were grepped (only `corpus/release-clock.py` and `corpus/stamps.tsv` reference it) but not executed.
- Lane-level gates/selftests were not run in the lane; lane `corpus/` is byte-identical to the candidate export and unmodified by me (`git status --porcelain -- corpus/` shows only the pre-existing untracked `corpus/__pycache__/`).
- Retained (small): `.ufo/waves/round-28/sandboxes/FObsHuge/` — `FObsHuge-evidence.json`, `c1-cand.json`, `c1-base.json`, `c1-cand-rerun.json`, five probe scripts (60 KB total). 643 MB of exported trees deleted at completion; no scratch left in `/tmp` or an evidence directory.
