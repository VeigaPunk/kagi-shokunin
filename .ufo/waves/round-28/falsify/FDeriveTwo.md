# FDeriveTwo — FALSIFY: "feed-row anchor naming two distinct stable versions binds none"

**Verdict: FAIL** — the carrier reproduces only in its plain surface form; the candidate's own
stated invariant ("a cell naming two different versions binds none",
`corpus/release-clock.py:355-356`) does **not** hold. Sub-claims measured separately below:
typed category PASS, exit status PASS, no-Traceback PASS, no-fired-verdict PASS, **totality FAIL**.

Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; BASE `3553d499577084a6c98d7078906017840bbf7b28`.
Both exported read-only into my sandbox `…/round-28/sandboxes/FDeriveTwo/{cand,base}` (`git archive <rev> | tar -x -C …`);
no lane file touched, no network, no lane gates run.

## Carrier exercised

Round-28 §C2 (plans/round-28.md): a `derived:` row's anchored version must be the version named by
its `feed_source_id` registry row's **located anchor cell**; candidate docstring
`corpus/release-clock.py:349-363` adds "a cell naming two different versions binds none".
Carrier = feed registry row **S033** (`corpus/SOURCES.md:39`, anchor cell). Only that one cell of
`corpus/SOURCES.md` is edited per fixture: no table row, no receipt, no code. Default receipt
`.ufo/waves/round-26/observe-2.json` (sha256 `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`)
is used as shipped, so a generic RECEIPT-MISMATCH can never stand in for the new rule.

## Commands and exits (all in sandbox)

| fixture (S033 anchor cell) | tree | command | exit | stdout |
|---|---|---|---|---|
| E control: original cell | cand | `python3 -I -B cand/corpus/release-clock.py --root cand` | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |
| E control | base | same on `base/` | 0 | `RELEASE_CLOCK: CLEAN (… observed=30 fired=3 derived=15)` |
| A `…v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z; previous stable release v3.12.9; feed fetched 2026-10-21` | cand | same | **1** | `DERIVATION S008` `S009` `S010` `S011`; `RELEASE_CLOCK: FAILED (… observed=26 fired=3 derived=11)` |
| A | base | same | 0 | `RELEASE_CLOCK: CLEAN (… derived=15)` (rule absent at BASE) |
| C `Newest stable v3.13.3; preceding stable v3.12.9; feed fetched 2026-10-21` | cand | same | **1** | `DERIVATION S008 S009 S010 S011` (row's own anchor is one of the two → still binds none) |
| C | base | same | 0 | CLEAN |
| S034 group check: S034 anchor cell += `; prior stable v2.1.9` | cand | same | **1** | `DERIVATION S013 S022 S023 S024` — exactly that feed's group, the other 11 derived rows stay bound (`derived=11`) |
| B `Entry titled v3.13.3, tag link /releases/tag/v3.13.3; previous stable release v3.12.9.` (2nd version ends a sentence) | cand | same | **0** | `RELEASE_CLOCK: CLEAN (… derived=15)` ← **counterexample** |
| D `Entry titled v3.13.3.` (one version, sentence-final period) | cand | same | **1** | `DERIVATION S008 S009 S010 S011` ← false positive |
| D | base | same | 0 | CLEAN |
| candidate selftest | cand | `python3 -I -B cand/corpus/release-clock.py --selftest` | 0 | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` (base: PASS, 79 cases) |

Driver: `…/sandboxes/FDeriveTwo/probe.py` (fixtures A,B,C,D,E × cand/base; results in `results.json`).
No fixture produced `Traceback` on stdout or stderr; the only finding category emitted anywhere is
`DERIVATION`, which is **new** (BASE's categories: ORPHAN/UNBOUND/INCONSISTENT/BADFEED/REGRESSED/
NOT OBSERVED/RECEIPT-MISMATCH) — so this is not a receipt mismatch in disguise.

## Findings

**F1 — FAIL (high; claim totality). A cell naming two distinct stable versions still binds when the
second version is sentence-final.** Counterexample cell for S033:
`Entry titled v3.13.3, tag link /releases/tag/v3.13.3; previous stable release v3.12.9.` →
candidate exits **0** with `RELEASE_CLOCK: CLEAN (… derived=15)`: the derived rows S008-S011 keep
their unbound anchors and the clock stays CLEAN — exactly the silent not-fired clock §C2 exists to
prevent. Root cause: `corpus/release-clock.py:345`
`STABLE_TOKEN_RE = re.compile(r"(?<![A-Za-z0-9.])v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9.+-])", …)` —
the trailing lookahead rejects a token followed by `.`, so `v3.12.9.` is invisible; tokens for that
cell are `['3.13.3','3.13.3']`, and `corpus/release-clock.py:363`
`set(STABLE_TOKEN_RE.findall(feed_anchor or "")) == {norm_version(anchored)}` therefore holds.
Verified directly: `re.findall` on the B cell → `['3.13.3','3.13.3']` (vs A → `['3.13.3','3.13.3','3.12.9']`).
The invariant "a cell naming two different versions binds none" is therefore text-form dependent,
not total.

**F2 — FAIL (medium; false positive on the same root cause).** Cell `Entry titled v3.13.3.` — a cell
naming exactly ONE stable version — yields tokens `[]`, so `:363` is false and every derived row on
that feed is refused: exit 1 with `DERIVATION S008 S009 S010 S011` (cand), while BASE accepts it
(exit 0 CLEAN). A legitimate prose anchor cell ending in a full stop is indistinguishable from an
unbound one. (`version_is_named` at `corpus/release-clock.py:337-342` has the same period-blindness, so
this is the file's established punctuation convention applied to a new, stricter check — but the new
check turns it from "INCONSISTENT" into "DERIVATION" on every derived row of the feed.)

Both fixes belong in one place: the trailing lookahead of `STABLE_TOKEN_RE` (`corpus/release-clock.py:345-346`), e.g. allow a `.` that is not followed by a digit.

## Verification of the "no fired verdict written" sub-claim

In every failing run the clock line keeps `fired=3` (only S012/S027/S028), the DERIVATION rows are
excluded from `observed`/`derived` (30→26, 15→11), the tree diff after the run is exactly
`corpus/SOURCES.md`, and the default receipt's sha256 is still `13b8540c…` — the run writes nothing.
Offline `--observe` probe (canned per-feed bodies, `probe_observe.py`, no packets): the two-version
cell adds exactly the four `DERIVATION` lines to the observe run's findings, the derived rows'
receipts carry `verdict="not-fired"`, `parsed_version="3.13.3"`, no `error`, and the clock line
stays `fired=3` — no fired verdict is written for the unbound rows.

## Residual risk / what I did NOT check

- Not checked: the real network `--observe` path (static bodies only). My canned quote bodies cannot
  reproduce the recorded captures, so that probe's quote rows show RECEIPT-MISMATCH noise; only its
  DERIVATION contrast is used above. Not checked: `.ufo/waves/round-28/tools/c2-measure.py` and its
  G1-G4 fixtures (its carrier is table edits, not the anchor cell) — out of my item's scope.
- Not checked: derived rows on S036/S039 (S027/S028/S040/S041 are not `derived:` rows) and
  non-numeric derived anchors (none in the corpus; S012's `v1.21.x` is not derived, so it takes the
  `version_is_named` path at `:361-362`); ledger/stamp bookkeeping.
- Production files are read-only here: I wrote only this report and my sandbox
  (`…/sandboxes/FDeriveTwo/{probe.py,probe_observe.py,results.json,observe-results.json,cand/,base/}`).
  No tool was installed or upgraded for this item.
