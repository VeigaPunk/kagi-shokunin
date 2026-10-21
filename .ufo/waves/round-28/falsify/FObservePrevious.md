# FObservePrevious — observe path, previous table observation noncanonical

**Verdict: PASS on carrier behavior** (candidate refuses, types `NON-CANONICAL`, no fired verdict, exit 1, no Traceback) **+ coverage gap**: the frozen C1 instrument and the selftest cannot detect a regression of this carrier's `observed_version` clause (Finding 1).

Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, BASE `3553d499577084a6c98d7078906017840bbf7b28`. Carrier: `--observe` when the row's **previous table observation** (`release-clocks.tsv` `observed_version` column, S040) is noncanonical.

Setup: both revisions exported via `git archive` into my sandbox; feed transport stubbed by replacing module global `request_body` with a local-bytes server — the same substitution `release-clock.py`'s own selftest uses. Fixture tree narrowed to S040 + feed source S039; every line verbatim except `observed_version`. No production file touched. Sandbox `.ufo/waves/round-28/sandboxes/FObservePrevious/`.

## Finding 1 (medium) — frozen C1 instrument never exercises this carrier

`plans/round-28.md` C1 covers "a version token used for an anchor, a table observation or a feed entry". But F1/F2 are `--receipt` (table-only) runs and F3/F4 are `--observe` runs whose **table row is kept verbatim** (`.ufo/waves/round-28/tools/c1-measure.py:265-271`: "the frozen F3/F4 text edits only the feed copy"). No fixture sets a noncanonical **previous table observation** and runs `--observe`.

Mutation proof (trees exported to `/fast/scratch/hyaku/kagi-r28/`):

- **M1** — delete the whole observe guard (`cand/corpus/release-clock.py:870-872`). Frozen instrument: `C1_MEASURE mutant-guard-removed: mishandled=0/4 typed=4/4` — **blind**. Candidate selftest catches it: `RELEASE_CLOCK_SELFTEST: FAIL observe non-canonical row anchor was not typed non-canonical` (exit 1).
- **M2** — delete only the `observed_version` half, keep `anchored_version`. Frozen instrument: `C1_MEASURE M2-observed-branch-removed: mishandled=0/4 typed=4/4` — **blind**. Candidate selftest `PASS (106 cases)` exit 0 — also **blind**. Under M2 the carrier regresses to BASE behavior: receipt record `{"parsed_version":"3.15.2","verdict":"fired"}` (a written release event), stdout `RELEASE_CLOCK_OBSERVE: … fired=1`.

So the `observed_version` clause at `cand/corpus/release-clock.py:871` is carried by **no** frozen fixture and **no** selftest case; only the `anchored_version` clause is witnessed. HEAD `5e847472` keeps this shape (`corpus/release-clock.py:863`; selftest label `"non-canonical row anchor"` at `:1731` sets both `anchored_version="1.2.03"` and `observed_version="1.2.03"`, so neither clause is isolated). Not a wrong verdict today, but the round's own instrument cannot detect a regression of this clause.

## Finding 2 (info) — the carrier itself behaves correctly

Real CLI exit codes; fixture row S040 with `observed_version` replaced; feed newest canonical `3.15.2`:

| previous observation | candidate | BASE |
|---|---|---|
| `3.15.01` | 1 / `NON-CANONICAL S040` / `verdict=null`,`parsed_version=null`,`error="non-canonical version token: row anchor or observation; no verdict written"` | 1 / `INCONSISTENT`+`RECEIPT-MISMATCH` / **`verdict="fired"`,`parsed_version="3.15.2"`** (written release event) |
| `3.15.`+4301×`1` | 1 / `NON-CANONICAL S040` / `verdict=null`, no traceback | **Traceback** `ValueError: Exceeds the limit (4300 digits)…` uncaught, exit 1, stderr traceback |
| `3.15.1234567890123456789` (19 digits) | 1 / `NON-CANONICAL S040` | 1 / `INCONSISTENT`+`RECEIPT-MISMATCH`+`REGRESSED` / `verdict="regressed"` |

Typed category is exactly `NON-CANONICAL` — **not** a generic `RECEIPT-MISMATCH`. Confirmed receipt-independent: with **no receipt at all** the row still yields `('NON-CANONICAL','S040')`; with a clean matching receipt it yields `('NON-CANONICAL','S040')` plus `RECEIPT-MISMATCH` (that second one is my narrowed fixture's row-vs-receipt mismatch, not the finding under test). Enforcement points: row-level `cand/corpus/release-clock.py:617,631` (`non_canonical_version(anchored) or non_canonical_version(observed_version)` → `NON-CANONICAL`), receipt-error branch `:679-680` (`receipt["error"].startswith(NON_CANONICAL_PREFIX)`), pre-fetch refusal `:870-872`. `NON_CANONICAL_PREFIX` `:390`; `non_canonical_version` `:395`; `VERSION_COMPONENT_MAX_DIGITS = 18` `:388`.

Round-trip verified: the error receipt the candidate writes, re-read via `--receipt <file> --receipt-sha <sha>`, types `NON-CANONICAL S040` exit 1 — the error-receipt branch, not a receipt-mismatch artifact.

## Finding 3 (info) — pinned foreign receipt with noncanonical `parsed_version`

`:679` types `NON-CANONICAL` from a receipt only via the **error-string prefix**. A retained receipt with `parsed_version="3.15.01"` and no `error` field types `('RECEIPT-MISMATCH','S040')`. No committed receipt in the tree has such a token (all five `observe-*.json` scan clean) and `--receipt-sha` pins the bytes, so this is defense-in-depth, not a live defect.

## Frozen commands run (exit codes)

```
c1-measure.py 3553d499… falsify-base → exit 0;  C1_MEASURE …-base: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True
c1-measure.py 62a33b1b… falsify-cand → exit 0;  C1_MEASURE …-cand: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True
c2-measure.py 62a33b1b… → exit 0;  C2_MEASURE …-cand-c2: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0
c2-measure.py 3553d499… → exit 0;  C2_MEASURE …-base-c2: groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0
release-clock.py --selftest → BASE exit 0 (79 cases); CAND exit 0 (106 cases)
```

BASE `F1-table-lie`: exit **0**, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)` — the lie accepted, `fired` rose 3→4. BASE `F3-observe-zero`: `fired_observation_written=True`. Candidate: all four `typed_lines=['NON-CANONICAL S040']`, `fired_observation_written=False`, no traceback; control `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0 both trees. Retained JSON: `…/sandboxes/FObservePrevious/out/c1-{base,cand}.json`, `c2-{base,cand}.json`, `c1-mutant.json`, `c1-m2.json`.

Ledger pin (read-only `corpus/claim-ledger.tsv:82`): `R25-03` pins `^RELEASE_CLOCK_SELFTEST: PASS \(106 cases\)$` — matches the candidate's 106. (At HEAD `5e847472` the pin reads 114 and the tree prints 114 — also consistent; the 114-vs-106 delta is HEAD's later repair, not a candidate defect.)

## Not checked / residual risk

- **Not checked**: the C2 derived-anchor carrier beyond frozen `c2-measure.py`; `corpus/lessons/round-28.md` sourcing rows S044/S045/S046 (read only, not re-verified upstream — no network).
- **Not checked**: real-network `--observe` against python.org (transport stubbed per the frozen tool's own documented limitation `.ufo/waves/round-28/build/XC1Measure.md`); multi-row interactions; `rendered-quote` rows with a noncanonical observation (typed `INCONSISTENT` in both trees — unchanged); canonical-boundary shapes beyond the table.
- **Residual**: `non_canonical_version` recognizes only strict `X.Y.Z` tokens (`NUMERIC_VERSION_RE` `:392`); `3.15`, `3.15.1.1`, `3.1_0.1` and Unicode-digit forms fall to `INCONSISTENT` in both trees — no regression, but the boundary is the strict-triple one, not SemVer §2 generally.
- **Residual**: a feed carrying an *older* noncanonical entry beside a newer canonical one is silently ignored (`newest_stable` `:784-798`); only the newest-entry case is typed. BASE crashed on that shape; the candidate no longer crashes but does not type it either.
