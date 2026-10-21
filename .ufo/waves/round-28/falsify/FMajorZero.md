# FMajorZero — PASS: major-component leading zero `03.15.1` is a typed NON-CANONICAL finding (candidate 62a33b1)

Attack scope: table observation `03.15.1` only (C1 freshness carrier). Isolation: exported
candidate tree + exported BASE tree, no network, no lane writes, no production bytes edited.
Verdict is a falsification recommendation, not closure.

## Findings

1. **LOW (coverage, not behaviour) — the major-component token is unpinned by lane-owned checks.**
   The frozen C1 fixture set uses `3.15.01` (patch component, `plans/round-28.md:32`) and the
   candidate's own selftest only exercises patch/middle leading zeros
   (`corpus/release-clock.py:1247` `leading-zero observation refused` = `1.2.04`,
   `corpus/release-clock.py:1257` `zero-padded middle component refused` = `1.00.0`). No
   lane-owned check exercises a *major*-component leading zero (`03.15.1`). The candidate
   behaviour is correct (evidence below) but a future edit that narrowed the rule to non-first
   components would not be caught by the selftest or by F1–F4.
2. **No behavioural defect found** for this carrier: exact category `NON-CANONICAL`, exit 1,
   no traceback, no fired verdict written, no release event, at BASE the same input was
   silently fired (so the fix is load-bearing, not redundant).

## Candidate code path exercised (path:line at 62a33b1)

- `corpus/release-clock.py:395-406` `non_canonical_version()` — `part[0] == "0"` fires for the
  major component `"03"` (`"03" != "0"`), so the token is non-canonical.
- `corpus/release-clock.py:617` computes `non_canonical` over anchor+observation;
  `corpus/release-clock.py:626-632` adds `("NON-CANONICAL", source_id)` and never reaches the
  fired/not-fired branch; `corpus/release-clock.py:715` prints `NON-CANONICAL S040`;
  `corpus/release-clock.py:2079` returns exit 1.
- `corpus/release-clock.py:680` receipt-branch typing; `corpus/release-clock.py:784-796`
  `newest_stable()`; `corpus/release-clock.py:869-872` `--observe` refusal.
- Fixture row `corpus/release-clocks.tsv:30` (S040, feed S039, python.org).

## Commands (all exit codes observed; no network; fixtures built by the frozen instrument)

```sh
# isolated exports (read-only git archive), exit 0
mkdir -p .ufo/waves/round-28/sandboxes/KagiR28.FMajorZero/{cand,base}
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C .../cand   # exit 0
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 3553d499577084a6c98d7078906017840bbf7b28 | tar -x -C .../base   # exit 0
python3 probe.py cand base   # exit 0   (reuses .ufo/waves/round-28/tools/c1-measure.py fixture builders, unmodified)
python3 probe2.py cand base  # exit 0   (variants V1-V6)
python3 probe3.py cand base  # exit 0   (variant V7)
python3 -I -B corpus/release-clock.py            # in exported candidate tree: exit 0
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1bd15217ed729df2ca40c8a30aba3076c0 cand-fmj .../c1-cand.json  # exit 0
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d499577084a6c98d7078906017840bbf7b28 base-fmj .../c1-base.json  # exit 0
```

## Actual results (candidate vs BASE, same fixture)

| Case | Fixture | Candidate | BASE |
|---|---|---|---|
| A table observation | S040 observed `03.15.1`, verdict `fired`, receipt mirrored | exit **1**, `NON-CANONICAL S040` / `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)` | exit **0**, `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 derived=15)` → **fired release event** |
| B table anchor | S040 anchored+observed `03.15.1` | exit **1**, `NON-CANONICAL S040` | exit **1**, `INCONSISTENT S040` (BASE-era category, not the new rule) |
| C observe (feed title) | local feed newest `Python 03.15.1`, stub transport | exit **1**, receipt `{"verdict":null,"error":"non-canonical version token: feed newest stable entry","parsed_version":null}`, `fired=0` | exit **1**, receipt `{"verdict":"fired","parsed_version":"03.15.1"}` → release event written; only finding was generic `RECEIPT-MISMATCH` (**not** accepted as proof) |
| V1 | observed `03.15.1`, verdict `not-fired` | exit 1, `NON-CANONICAL S040` | exit 1, `INCONSISTENT S040` |
| V2 | observed `00.15.1` | exit 1, `NON-CANONICAL S040` | exit 1, `REGRESSED S040` |
| V3 | observed `v03.15.1` | exit 1, `NON-CANONICAL S040` | exit 0, CLEAN `fired=4` (release event) |
| V4 | observe, token in tag href `/releases/tag/v03.15.1` | exit 1, typed error, verdict null, `fired=0` | exit 1, receipt `verdict:"fired"`, `parsed_version:"03.15.1"` |
| V5 | observe, canonical newest `3.15.1` + older `03.15.0` | exit **0**, CLEAN, receipt `parsed_version "3.15.1"`, `verdict not-fired` (older non-canonical entry ignored — no false positive) | exit 0, CLEAN (accepted the padded entry) |
| V6 | observe, twins `3.15.1` + `03.15.1` | exit 1, typed `non-canonical version token: feed newest stable entry` | exit 0, CLEAN (padded twin accepted) |
| V7 | derived row S008 anchored `03.13.3` | exit 1, `NON-CANONICAL S008`, `derived=14` (row excluded) | exit 0, CLEAN (`derived=15`) |

No output in any candidate case contains `Traceback`; no receipt/observation file was written by
the candidate table run (fixture root held only my copied `receipt.json`); no candidate case
increments `fired` (stays 3) or writes a fired verdict.

## Frozen counting command (context only, unmodified)

- candidate: `C1_MEASURE cand-fmj: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` (exit 0)
- BASE: `C1_MEASURE base-fmj: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True` (exit 0)
- control on exported candidate tree: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0.

## Residual risk / not checked

- Not checked: C2 carrier (derived-anchor binding) beyond V7's single precedence case; the
  candidate's `--selftest` and the lane's other gates were not run (lane checkout untouched);
  the >18-digit component bound vs the plan's 4300-digit wording (outside this carrier);
  rows other than S040/S008; live vendor feeds (no network used).
- My sandbox trees (`cand/`, `base/`, ~210 MB) were deleted after the runs (exit 0); retained
  small receipts: `probe.py`, `probe2.py`, `probe3.py`, `probe.log`, `probe2.log`,
  `probe-result.json`, `probe2-result.json`, `c1-cand.json`, `c1-base.json` under
  `.ufo/waves/round-28/sandboxes/KagiR28.FMajorZero/`.
- No tools installed or updated; no runtime judge invoked; no production file modified.
