# FObsZero — round-28 C1 F1 carrier: table observation `3.15.01` (mirrored receipt)

Verdict: **PASS** (candidate) / **FAIL at BASE** (defect confirmed present and fixed).
Target: `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`
(BASE `3553d499577084a6c98d7078906017840bbf7b28`). Axes: freshness (C1). Carrier only: F1.

## What I built (independent, not the frozen tool)

Sandbox `…/.ufo/waves/round-28/sandboxes/FObsZero/`:
`base/`, `cand/` = `git archive` of BASE / candidate (read-only export, lane untouched);
`f1_probe.py` = my own F1 builder (own receipt-mirroring code): edits `release-clocks.tsv`
S040 `fields[5]` (observed_version) and `fields[7]` (verdict), mirrors the same token into a
copy of the default receipt (`.ufo/waves/round-26/observe-2.json`) S040 record
(`parsed_version`,`verdict`), writes it to `<root>/receipt.json`, runs
`python3 -I -B <tree>/corpus/release-clock.py --root <root> --receipt <r> --receipt-sha <sha>`.
Also `observe_runner.py` / `observe_fixture.py` = offline `--observe` (module `request_body`
stubbed to a local feed, `utc_timestamp` pinned — the script's own selftest substitutions).

## Commands and exits (all run in my sandbox; no network)

| # | Command | Exit | Result |
|---|---|---|---|
| 1 | `python3 f1_probe.py cand cand-F1 runs 3.15.01 fired` | 1 | `NON-CANONICAL S040` / `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)`; stderr empty; no `Traceback` |
| 2 | `python3 f1_probe.py base base-F1 runs 3.15.01 fired` | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 **fired=4** derived=15)` — BASE counted `3.15.01` as a fired release |
| 3 | `python3 -I -B cand/corpus/release-clock.py` (control) | 0 | `RELEASE_CLOCK: CLEAN (… observed=30 fired=3 derived=15)` — unchanged by the candidate |
| 4 | `python3 -I -B base/corpus/release-clock.py` (control) | 0 | `RELEASE_CLOCK: CLEAN (… fired=3 derived=15)` |
| 5 | `python3 -I -B cand/corpus/release-clock.py --selftest` | 0 | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)`; BASE `--selftest` → `PASS (79 cases)` |
| 6 | `NO_MIRROR=1 python3 f1_probe.py cand cand-nomirror runs 3.15.01 fired` | 1 | `NON-CANONICAL S040` **and** `RECEIPT-MISMATCH S040` — the new category is present with the receipt unmirrored |
| 7 | `python3 f1_probe.py cand v-3.15.010 / v-3.15.00 / v-03.15.1 / v-3.015.1 / v-v3.15.01` | 1 each | all `NON-CANONICAL S040`, no traceback |
| 8 | `python3 f1_probe.py cand v-anchor runs 3.15.1 not-fired 3.15.01` (non-canonical **anchor**) | 1 | `NON-CANONICAL S040` (not `INCONSISTENT`) |
| 9 | `python3 observe_fixture.py cand obsroot-cand 3.15.01` + offline `--observe` | 1 | receipt written: `error="non-canonical version token: row anchor or observation; no verdict written"`, `parsed_version: null`, **`verdict: null`** — no fired verdict written; stdout `NON-CANONICAL S040` |
| 10 | offline `--observe`, canonical table row + feed whose newest entry is `Python 3.15.01` | 1 | receipt `error="non-canonical version token: feed newest stable entry"`, `verdict: null`; `NON-CANONICAL S040` |
| 11 | frozen cross-check: `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… cand <out>` | 0 | `C1_MEASURE cand: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True`; F1 `exit 1 / verdict TYPED`, typed line `['NON-CANONICAL S040']` |
| 12 | same tool on BASE `3553d499…` | 0 | `C1_MEASURE base: mishandled=3/4 typed=0/4`; F1 `exit 0 / verdict MISHANDLED` |

## Assertions (acceptance)

- **Exact typed category**: `NON-CANONICAL` — a *new* category. BASE contains **no**
  `NON-CANONICAL` token at all (grep count 0; BASE categories are `ORPHAN, UNBOUND,
  INCONSISTENT, BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED`).
  Candidate `corpus/release-clock.py:631` `errors.add(("NON-CANONICAL", source_id))`,
  computed at `:617`, predicate `non_canonical_version` at `:395` (leading-zero test at
  `:405`: `part != "0" and (part[0] == "0" or len(part) > VERSION_COMPONENT_MAX_DIGITS)`,
  bound at `:388` = 18 digits). Rows named: `NON-CANONICAL S040`.
- **Not a generic receipt mismatch**: in run 1 (mirrored receipt) the *only* finding line is
  `NON-CANONICAL S040` — no `RECEIPT-MISMATCH` at all, because the mirrored receipt
  satisfies `receipt_matches` (`3.15.01` == table `3.15.01`). The finding therefore
  provably originates from the table-row branch `:627-632`, not from receipt comparison.
  Run 6 (receipt left unmirrored) still yields `NON-CANONICAL` **and** the generic
  `RECEIPT-MISMATCH` — the new category is independent of receipt state.
- **No Traceback**: combined stdout+stderr contains no `Traceback` in every run (1, 6–10).
  BASE also emits no traceback for `3.15.01` (the defect is silent acceptance, not a crash).
- **No fired verdict written**: verify mode writes nothing (fixture dir after run 1 contains
  only my 5 input files; receipt sha256 before == after). Offline `--observe` (runs 9, 10)
  writes `verdict: null` + `parsed_version: null` + typed error; the tool's own counters
  print `fired=3`, i.e. the bad row is **not** counted as a fired release (control `fired=3`).
  BASE counts it: `fired=4`.
- **Concrete BASE counterexample**: run 2 — BASE accepts `S040 observed_version=3.15.01
  verdict=fired` as a live release event and exits 0 `CLEAN` with `fired=4` (control `fired=3`).
  Run 2 is the same bytes with the same mirrored receipt as run 1.

## Residual risk / gaps (not FAIL of this carrier)

- **Receipt-only forgery degrades to a generic category (pinned candidate only)**: if the
  *table* row is canonical but the receipt's `parsed_version` is `3.15.01` (hand-forged, no
  `error` field), pinned `62a33b1` reports only `RECEIPT-MISMATCH S040` (exit 1, no fired) —
  the receipt-side typing at `:679-680` fires only when the record carries the
  `non-canonical version token: ` prefix that `observe_one` itself writes. The lane's
  *uncommitted* worktree `corpus/release-clock.py` already closes this (it adds a
  `non_canonical_version(receipt["parsed_version"])` clause); verified by running the
  worktree file against the same fixture: `NON-CANONICAL S040` (exit 1) vs pinned
  `RECEIPT-MISMATCH S040`. My measurements above are all from `git archive` exports of the
  pinned commit, so they are unaffected by that in-flight edit. Outside C1's wording
  (row/anchor/feed) either way.
- `3.15.01.2` (four components) → `INCONSISTENT`, not `NON-CANONICAL` (strict X.Y.Z only,
  by design at `:404`).
- A 19-digit component (`1.2.9999999999999999999`) → `NON-CANONICAL` (18-digit lane bound,
  `:388`) where BASE reported `REGRESSED`; that is the F2/oversize carrier, not audited here.

## Not checked

- F2 (4301-digit), F3/F4 (`--observe` feed tokens) — other carriers' scope; only the
  `3.15.01` cases above were run. C2 / `DERIVATION` path not attacked.
- No network fetch of python.org; feeds were local stubs.
- Lane checkout: no writes, no gate/selftest run in the lane; only `git archive` reads.
  Tools: python3 3.14.8 (system), git (system); nothing installed.
