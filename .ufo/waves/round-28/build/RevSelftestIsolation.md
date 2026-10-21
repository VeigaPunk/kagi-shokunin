# RevSelftestIsolation — BASE release-clock `--selftest` isolation (QM4) + C1/C2 case specs

Round-28 BUILD reviewer seat. BASE `3553d499577084a6c98d7078906017840bbf7b28` (`git archive` copy in
`.ufo/waves/round-28/sandboxes/RevSelftestIsolation-7/base`); line numbers are BASE lines. No
production file written; every run is on a sandbox copy. No tool installed.

## Open findings (action required)

**F1 — HIGH (OPEN) — the frozen C1 and C2 fixture sets are receipt-coupled, so their BASE baselines
are not reproducible from the frozen text (`plans/round-28.md:34, 44-48`).** C2 G1 ("release-clocks
edits only", predicate "ACCEPTED when exit 0 `RELEASE_CLOCK: CLEAN`") executed exactly as frozen on
BASE (S008–S011 lowered to 3.13.2, verdict not-fired) still meets the retained receipt's
`parsed_version 3.13.3`: `RECEIPT-MISMATCH S008..S011` / `FAILED (observed=26 derived=11)`, exit 1
— not ACCEPTED; only a receipt rewritten to match the lie gives the plan's ACCEPTED baseline
`CLEAN (… observed=30 fired=3 derived=15)`, exit 0. C1 F1 (`observed_version=3.15.01`,
`verdict=fired`) is the same shape: pinned receipt → `RECEIPT-MISMATCH S040` / `FAILED (observed=29
fired=3)`, exit 1 (typed, no forged event); consistent receipt (`--receipt FILE --receipt-sha
SHA256`; the pinned `DEFAULT_RECEIPT_SHA256`, release-clock.py:12, needs no change) → `CLEAN (…
observed=30 fired=4 derived=15)`, exit 0 — the forged fired release. Neither plan freezes receipt
handling, so both baselines are unmeasurable as written; the measure authors must state it.

**F2 — MEDIUM (CLOSED by L1's landing, verified) — the count and its three pins moved together.** The
landed tree (lane working tree, copied into my sandbox) prints `RELEASE_CLOCK_SELFTEST: PASS (106
cases)` exit 0 and, on the BASE corpus, `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3
derived=15)` exit 0 — the plan's control line, verbatim; `corpus/release-clocks.tsv` is unchanged vs
BASE. The pins agree: `corpus/claim-ledger.tsv:82` (`\(106 cases\)`), `SKILL.md:48` ("`--selftest` 106
cases"), `PROVINCE.md:54` ("proves 106 cases") and `corpus/self-counts.tsv:22`/`:38` (SC-/PV-CLOCK-SELFTEST).

**F3 — LOW (OPEN, plan scope for L1) — prerelease and module tags stay skipped and
uncanonicalized.** The stable-token regexes accept only `[Word ]vX.Y.Z` / `/releases/tag/vX.Y.Z`
(release-clock.py:712, 749), so a non-canonical *prerelease* (e.g. `v3.16.01-rc1`) is skipped
entirely rather than typed: L1 must say whether C1 covers only stable entries.

## Verified closures (measured on sandbox copies; the two seats' revisions)

- **Oversize token crashed at two sites and could abort the selftest (was HIGH).** BASE:
  release-clock.py:380 raised `ValueError: Exceeds the limit (4300 digits)…` at :404 (`feed_floors`,
  *anchored* side) and :567 (`is_regression`, *observed* side); `run_case` called `evaluate`
  unguarded (:1005) so the case raised out of `selftest()` → traceback, no count, ledger pin
  unmatched. Landed: no `int()` remains, `evaluate` wrapped in `try/except ValueError`, rule scoped
  to version tokens (`NUMERIC_VERSION_RE` :366) so `1.2.x` (:1073) / `1.3` (:1098) are untouched.
- **The total C2 binding needs the harness re-point plus a series-aware extraction (was HIGH).**
  BASE: release-clock.py:565-566 gave every `derived:` row a free pass on the anchor-name check;
  binding a derived row to the version its `feed_source_id` registry row's anchor cell (:88) names
  fits the real corpus (all 15 derived rows match). With the harness default feed anchor cell left as
  `"Latest release"`, "derived anchor counted" (:1052, the only proof a `derived:` row counts as
  derived), "non-numeric anchor keeps inequality" (:1073) and "feed floor lifts non-numeric anchor"
  (:1084) all FAIL with `DERIVATION S001`; with the landed re-point (S002 anchor cell → "Latest
  release 1.2.0; series 1.2.x") the probe passes 79/79 — but only if the extraction accepts the
  series form (numeric-only scan: :1073/:1084 still fail).
- **A C1 case carrying a `derived:` note broke under the C2 rule, and the co-firing fix broke
  separability (was HIGH).** Merged tree (BASE + XC1Patch + C2's rule + the re-point): 97 cases, one
  failure — `FAIL derived leading-zero anchor refused: errors {('NON-CANONICAL','S001'),
  ('DERIVATION','S001')} != {('NON-CANONICAL','S001')}` — and adding ('DERIVATION','S001') to that
  expectation turned the C1-only overlay red (exit 1), against the plan's "separability … executed
  by claim-only overlays" (`plans/round-28.md:54`). Revision 2 removes the derived C1 case: the C1
  overlay is green at 97, the composed tree at 103, no expectation naming the other claim.
- **The feed-entry rule was conditional where the plan's wording is total (was MEDIUM).**
  `plans/round-28.md:26-28` says a version token used for "an anchor, a table observation or a feed
  entry must be canonical …; otherwise the row or feed gets a typed finding", but the first landed
  `newest_stable` ignored a non-canonical entry ordering below the newest canonical one (measured:
  `v3.15.0` + `v3.14.01` → `3.15.0`, no finding); revision 2 refuses every non-canonical stable
  entry. At BASE that path forged a release (`Python 3.15.01` + `Python 3.15.1` → `3.15.01` →
  `observe_one` :767 records `verdict fired`).

## How the existing cases build fixtures, and why new ones stay isolated
- `fixture_source` (:902-908) emits one 11-cell `SOURCES.md` registry row (the URL sits in the source
  cell, recovered by `source_url` :50); `fixture_row` (:910-916) emits one tab-separated
  `release-clocks.tsv` row matching `HEADER` (9 fields), defaults `S001` / clock `feed` / feed
  `S002` / anchored `1.2.3` / observed `1.2.3` / `not-fired`, `note` = the `derived:` lever (:565).
- `run_case` (:973-1016): temp dir (977) → `corpus/SOURCES.md` (993), `corpus/release-clocks.tsv`
  (994-995), `corpus/source-fetches.tsv` (996-998) → `parse_sources` (999), `parse_bindings` (1000),
  `parse_captures` (1001) → **synthetic in-memory receipt** (1002, `synthetic_receipt_bundle` 934-961)
  → `evaluate` (1005) → exact error-set compare (1008-1009), count compare (1010-1014), `passed`
  compare (1015-1016).
- Isolation (QM4): `evaluate` (:502-641) is pure — no file, no socket, receipts arrive as a dict; the
  selftest's only receipt files are temp ones (`write_receipt` :1516-1541, mode 0600, overwrite and
  symlink refused); the network functions (`request_body` 669, `observe_one` 767, `run_observe` 862)
  are never called by `run_case`; the CLI refuses to mix `--selftest` with
  `--observe/--receipt/--receipt-sha` (1715-1718, exit 2). The C2 seat's new offline `--observe` case
  is network-free and receipt-safe (monkeypatched request_body, temp receipt, no pinned receipt).

## Six case specs (each fails on BASE; 3× C1, 3× C2)

All six use `run_case` (temp tree, synthetic receipt, no network, no receipt file); landed names
`NON-CANONICAL` (C1) / `DERIVATION` (C2). The C1 specs are non-derived (see the C1↔C2 closure); the
C2 specs use `note="derived: …"` and their own feed `S004`.

| # | case | fixture (one row) | BASE result (measured) | after the fix |
|---|---|---|---|---|
| C1-a | leading-zero **observation** | non-derived row, anchored `1.2.3`, observed `1.2.03`, verdict `fired` | `errors=[] observed=1 fired=1 passed=True` → CLEAN, forged fired release | exit 1, one typed finding for S001; `fired=0` |
| C1-b | leading-zero **anchor** | non-derived rows S001 (plain) + S005, extra source S005 anchor cell `Version 1.2.03`; S005 row anchored `1.2.03`, observed `1.2.4`, verdict `fired` | `errors=[] observed=2 fired=1 passed=True` → CLEAN, forged fired release | exit 1, one typed finding for S005; `fired=0` |
| C1-c | oversize component | non-derived row, anchored `1.2.` + 4301×`1`, observed `1.2.3` | `ValueError` traceback out of `evaluate` (:380 via `feed_floors` :404; the observed-side twin crashes at :567) | exit 1, one typed finding, no traceback |
| C2-a | derived anchor **lowered** below its feed row | feed `S004`, row anchored/observed `1.1.0`, verdict `not-fired`, note `derived: …` | `errors=[] derived=1 passed=True` → CLEAN (the plan's G shape) | exit 1, one derivation finding naming S001 |
| C2-b | derived anchor **raised** + fired | feed `S004`, row anchored `1.2.4`, observed `1.2.5`, verdict `fired`, note `derived: …` | `errors=[] fired=1 derived=1 passed=True` → CLEAN, forged fired release | exit 1, one derivation finding naming S001; `fired=0` |
| C2-c | derived anchor **raised**, silent | feed `S004`, row anchored `1.2.4`, observed `1.2.4`, verdict `not-fired`, note `derived: …` | `errors=[] derived=1 passed=True` → CLEAN, silent re-anchor | exit 1, one derivation finding naming S001 |

Controls that must stay CLEAN before and after (not among the six): a derived row whose feed anchor
names a version equal to the row's anchor (`1.2.3`); the `v`-prefixed form (`v1.2.3`); the `1.2.x`
series-anchor row; and the default-S002 derived row **after** the harness re-point. Draft:
`.ufo/waves/round-28/sandboxes/RevSelftestIsolation-7/draft_cases.py` inserts the six calls into a
**copy** of BASE; on BASE it prints 6 failing cases and `DRAFT_CASES=85`, exit 1.

## Commands run (all on the sandbox BASE copy; exit codes as shown)
1. `python3 -I -B corpus/release-clock.py --selftest` → `PASS (79 cases)`, exit 0; `base/corpus/release-clock.py --root base` → `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0 (the plan's control line, verbatim).
2. F1 as frozen (TSV only) → `RECEIPT-MISMATCH S040`, `FAILED (observed=29 fired=3)`, exit 1; with a consistent receipt → `CLEAN (… fired=4 …)`, exit 0. F2 as frozen (4301-digit component) → `ValueError … 4301 digits` traceback, exit 1. G1 as frozen (TSV only) → 4× `RECEIPT-MISMATCH`, `FAILED (observed=26 derived=11)`, exit 1; with a consistent receipt → `CLEAN (… observed=30 fired=3 derived=15)`, exit 0. `probe_base.py` (per-case BASE behaviour) → exit 0; `draft_cases.py` → 6 failing cases, `DRAFT_CASES=85`, exit 1.
3. Composed tree (C1 seat's three-way merge, sha256 a36bc4e3…): `--selftest` → `PASS (103 cases)` exit 0; on the BASE corpus → `CLEAN (… fired=3 derived=15)` exit 0; `release-clocks.tsv` and `SOURCES.md` byte-identical to BASE. C1 overlay alone → `PASS (97 cases)` exit 0; C2 overlay alone → `PASS (85 cases)` exit 0. Fuzz-merge of the two raw diffs → `FileNotFoundError`; `git apply` fails in both directions at the evaluate hunk (the three-way merge is required). L1's landed tree, copied into my sandbox: `--selftest` → `PASS (106 cases)` exit 0; on the BASE corpus → `CLEAN (… fired=3 derived=15)` exit 0; `release-clocks.tsv` unchanged vs BASE.
4. `nosock.py` (socket connect + DNS blocked) → `PASS (79 cases)`, exit 0; selftest with `observe-2.json` deleted → `PASS (79 cases)`, exit 0; `corpus/self-counts.py --root .` → `SELF_COUNTS: CLEAN (claims=60 stale=0)`, exit 0.

## What I did NOT check

- Nothing implemented by me: no production file, no ledger/doc count moved; F1's measure-tool receipt
  step and F3's scope ruling are open, and L1's landing is verified only as a working tree (not
  committed). No lane gate/selftest was run inside the lane checkout; all runs used sandbox copies.
- No network used or attempted: F3/F4-style fixtures (a "local copy of the python.org feed") were not
  exercised, and the feasibility of a local feed copy under the public-HTTPS-only opener
  (`request_body` 669, `public_addresses` 309) is unverified; only S033–S037 feed rows were checked
  for the C2 anchor binding (no SOURCES.md edit was made) and `c1-measure.py` / `c2-measure.py` do
  not exist yet, so their receipt handling (F1) is unverified.
- Round-27's history/lessons, the LOG append-only rules and other seats' findings were not reviewed.
