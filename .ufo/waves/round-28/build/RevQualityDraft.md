# Round-28 reviewer report — draft wording for QM27 / QM28 (freshness, calibration)

Seat `KagiR28.RevQualityDraft-7` (reviewer; draft wording only, no production edit). Read at frozen BASE
`3553d499577084a6c98d7078906017840bbf7b28`: `plans/round-28.md`, `corpus/release-clock.py` (1758 lines), `corpus/QUALITY.md`
(133 lines), `corpus/release-clocks.tsv`, `corpus/SOURCES.md`, `corpus/lessons/round-27.md`. All runs were made in the
sandbox `.ufo/waves/round-28/sandboxes/RevQualityDraft-7/base` (`git archive 3553d49`), never in the lane checkout.

## Findings (severity order)

**F1 (high) — the frozen C2 fixture set is masked by the receipt binding; "before" is not CLEAN as written.**
`plans/round-28.md:60-64` freezes the C2 fixtures as "release-clocks.tsv edits only; SOURCES.md untouched" and predicts
ACCEPTED 4/4 at BASE. Measured on BASE (`exp.py`): lowering S013/S022/S023/S024 to `2.1.0` (observed equal, verdict
`not-fired`) with the **retained** receipt `.ufo/waves/round-26/observe-2.json` exits **1** with `RECEIPT-MISMATCH
S013/S022/S023/S024` — the receipt binds `parsed_version` to the row's observed version (`corpus/release-clock.py:441-447`),
so the table edit is caught before the derived-anchor question is asked. The forgery reproduces the defect only with the
receipt forged too: same table edit + a receipt whose `parsed_version` is `2.1.0` → exit **0**, `RELEASE_CLOCK: CLEAN
(on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, `derived=15` unchanged. Round 27 recorded exactly this
(`corpus/lessons/round-27.md:213-218`, CritFinalC2 #1: "That requires editing both the pinned table and receipt"). Finding:
the frozen fixture description contradicts that record: the C2 tool must edit the receipt too, and the "EXACT" predicate must
key on the finding *category*, not row ids, or `RECEIPT-MISMATCH` on the same ids passes it vacuously. Frozen commands are
not mine to change — defect reported, not redefined.

**F2 (high) — the frozen C1 F1 fixture does not measure the leading-zero defect at BASE.** `plans/round-28.md:35` (F1: S040
`observed_version=3.15.01`, `verdict=fired`) at BASE exits **1** with `RECEIPT-MISMATCH S040` and `fired=3` (not 4): the
receipt's recorded verdict is `not-fired` (`corpus/release-clock.py:436`), so the row is invalidated before the fired branch
is read. The defect is real but needs an observation consistent with its receipt. Measured module-level, no network
(`exp_observe.py`): a python.org-shaped RSS whose newest stable item is titled `Python 3.15.01` →
`parse_latest_version` returns `'3.15.01'` (`corpus/release-clock.py:710` accepts it) → `observe_one` writes
`{"parsed_version": "3.15.01", "verdict": "fired"}` — a fired release, no error, no traceback — because `numeric_version`
maps both to `(3, 15, 1)` (equal) while the strings differ, so the fired branch at `corpus/release-clock.py:582-584` is
taken. Finding: F1 must be rebuilt (observation **and** receipt) before "MISHANDLED k/4 → 0/4" can be measured, and the
after-state must make the canonicality finding distinguishable from `RECEIPT-MISMATCH`.

**F3 (medium) — the ValueError traceback is a table-path defect only; the observe path swallows it.**
`plans/round-28.md:19-21` says an over-long component "raises an untyped ValueError traceback". True in the table path:
S040 `observed_version=3.15.`+4301×`1` → uncaught `ValueError: Exceeds the limit (4300 digits)…`, traceback through
`corpus/release-clock.py:567` → `numeric_version` `:380`, exit 1 (measured). False in the observe path (F4):
`parse_latest_version` raises the same `ValueError` at `corpus/release-clock.py:760`, but `observe_one` catches it at
`corpus/release-clock.py:822` and records `receipt["error"] = "Exceeds the limit (4300 digits)…"` — a generic body/network
error indistinguishable from a fetch failure, then `RECEIPT-MISMATCH`, exit 1, **no** traceback. Finding: the after-state
needs a distinct oversize finding, and F4's "before" classification is TYPED-ish, not MISHANDLED.

**F4 (medium) — QM27's leading-zero source is not located by S042.** `plans/round-28.md:20` cites "SemVer S042 §2", but
S042's located anchor is "§11 Precedence, item 11.2" (`corpus/SOURCES.md:49`); §2 ("MUST NOT contain leading zeroes") is not
in that row's located anchor, so a criterion citing "S042 §2" names a section the row does not carry (QM11,
`corpus/QUALITY.md:49`; QA1 `:20`). The round-28 registry row for the integer-string conversion limit (to be opened this
round, `plans/round-28.md:24`) does not exist at BASE, so QM27's lesson cell cannot cite an id until it lands. Recommend: cite
a row that locates the leading-zero rule plus the new conversion-limit row, and state the bound as "the limit the host
documents", not a hard-coded 4300.

**F5 (medium) — C2's population is narrower than the flip it claims to execute.** `corpus/lessons/round-27.md:218` names the
flip as "bind every **floor-contributing** anchor to its feed row's anchored release"; the plan scopes C2 to the 15
`derived:` rows (`plans/round-28.md:60-64`). Floor-contributing feed rows at BASE are 19: the 15 derived rows plus
S027/S028 and S040/S041, which already satisfy the binding, so the narrower population is safe but leaves round-27's phrasing
partly unexecuted (`exp_c2.py`: 15 `derived:` rows, 0 unbound at BASE).

**F6 (low) — the binding must read the feed row's anchor cell, and only `derived:` rows are in scope.** S037's anchor cell
names only `8.23.0`; curl's `8.23.1` DEV label is in its `teaches` cell (`corpus/SOURCES.md:43`), so a rule scanning the whole
registry row would accept a derived anchor of `8.23.1` for S029. S012 anchors `v1.21.x` while its feed S034 locates `2.2.0`
(`corpus/release-clocks.tsv:9`); a rule over every feed row would fail a legitimate row — scope QM28 to `derived:` rows.

## Draft rows (append after `corpus/QUALITY.md:133`, under a new `## Criteria from the round-28 build` heading)

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM27 | Supplements QM25: a version token used as a clock anchor, a table observation or a feed entry is canonical before it is compared — a multi-digit component carries no leading zero and no component exceeds the integer-conversion bound the host documents — so that a token's string identity and its numeric identity agree. A non-canonical token is a typed finding that fails the run, naming the row or the feed that carried it: never a fired release, never a silently accepted observation, never a traceback. Distinct from QM25, which orders canonical cores: `3.15.01` orders equal to `3.15.1` (both `(3,15,1)`) yet is string-unequal, which is exactly the defect this row refuses; a non-numeric anchor (`v1.21.x`) stays QM25's declared limit and is out of scope here. | `3.15.01` counted as a fired release against the anchor `3.15.1`; a 4301-digit component surfacing as `ValueError: Exceeds the limit (4300 digits)` or as a generic receipt error instead of a typed finding; a token accepted because `int()` happened to parse it | `corpus/lessons/round-28.md` §C1; `corpus/lessons/round-27.md` CritFinalSources ("Leading-zero `3.15.01` is still compared by string for fired/not-fired (inherited) — named debt", `:221-224`) and XRegressDraft (">4300-digit component raises ValueError (untyped crash, non-zero exit) — named debt", `:225-226`) |
| QM28 | Supplements QM21/QM23/QM25: a `derived:` clock row's anchored version is the version named by the **located anchor** of the `feed_source_id` registry row it names — the release identity that feed row locates, not a version mentioned elsewhere in that row's prose, and not the row's own source anchor. A `derived:` row whose anchored version is not the feed row's located version is a typed finding that fails the run. Scoped to `derived:` rows: a row that names a non-release anchor in its own source (S012 `v1.21.x` against the Vault feed's located `2.2.0`) is not bound by this row. Distinct from QM25, which says which version a development or prerelease label may be derived to (S029's `8.23.0` for the `8.23.1` DEV label); this row checks that the declared value equals the located anchor of the feed row named, so a lowered or invented derived anchor cannot pass as author-declared. | every derived anchor on one feed lowered to one lower version with a matching forged observation and the run still `CLEAN`; a `derived:` row whose anchor no feed row locates; binding by scanning the whole registry row instead of its located anchor | `corpus/lessons/round-28.md` §C2; `corpus/lessons/round-27.md` CritFinalC2 #1 (`:213-218`, "lowering derived anchors together with a forged stale observation stays CLEAN… Flip: bind every floor-contributing anchor to its feed row's anchored release (CritFinalC2 draft A)"); S033/S034/S035/S037 located anchors (`corpus/SOURCES.md:39-43`) |

### Failing examples and captured-by notes (lesson Mistakes-table form, `corpus/lessons/round-28.md`)

- **M28-1 — non-canonical version token (class: untyped token accepted).** Evidence, BASE tree: a python.org-shaped RSS whose
  newest stable item is titled `Python 3.15.01` yields `parse_latest_version → '3.15.01'` and `observe_one →
  {"parsed_version": "3.15.01", "verdict": "fired"}` (`exp_observe.py`, exit 0). **captured-by: none** — QM25 orders cores and
  declares non-numeric anchors a limit, never the token's own form. Fix: canonical-token check before any comparison (fix
  column names **QM27**).
- **M28-2 — derived anchor not bound to its feed row (class: author-declared value trusted unchecked).** Evidence, BASE tree:
  S013/S022/S023/S024 lowered to `2.1.0` with a matching forged receipt exits 0, `RELEASE_CLOCK: CLEAN (on_release=30
  bound=30 unbound=0 observed=30 fired=3 derived=15)` (`exp.py`). **captured-by: none** — QM23 requires the `derived:` marker
  and QM25 the released version; neither binds the declared value to the feed row's located anchor (round 27's CritFinalC2 #1).
  Fix: bind each `derived:` anchor to its feed row's located anchor (names **QM28**).

Landing status: L1 landed QM27/QM28 at `corpus/QUALITY.md:134-135`, lesson M28-2/M28-3 at `corpus/lessons/round-28.md:88-89`;
its extra "a cell naming two versions binds none" has no BASE false positive (`exp_c2.py`).

## Duplication check against QM21 / QM23 / QM24 / QM25

| existing | what it binds | overlap with QM27 / QM28 |
|---|---|---|
| QM21 `corpus/QUALITY.md:118` | a current-tense **number in a committed doc** to the live source defining it | none: QM27 binds a token's *form* (not a number's freshness); QM28 binds a *table cell* to a registry row's located anchor — same discipline, new surface, stated in QM28's first clause. |
| QM23 `:120` | an `on-release` recheck names one observable release identity; the `derived:` marker; a fired clock is re-verified | none: QM23 never asks *which* version a `derived:` row declares; its marker requirement is what QM28's population is drawn from. |
| QM24 `:126` | a successor on-release teaching stays release-driven and bound at its named current release | none: rearm/migration, not token form or derived binding. |
| QM25 `:132` | orders strict X.Y.Z cores numerically; `REGRESSED` findings; non-numeric/two-component/prerelease anchors are declared limits; a dev/prerelease label is derived at the released version | none: QM27 requires the token to be canonical so string and numeric identity agree — the case QM25's ordering cannot see; QM28 checks that the declared derived value **equals** the feed row's located anchor, where QM25 states only **which** version may be derived. Both rows carry an explicit "distinct from" clause. |

## Commands run (all in the sandbox; exit codes)

- `python3 -I -B corpus/release-clock.py` (unmodified sandbox BASE tree) → exit 0, `RELEASE_CLOCK: CLEAN (on_release=30
  bound=30 unbound=0 observed=30 fired=3 derived=15)` (control matches `plans/round-28.md:41`; `git diff 3553d49 -- corpus/
  release-clock.py corpus/QUALITY.md` → exit 0, empty).
- `python3 -I -B exp.py` → exit 0; control exit 0/CLEAN; F1 exit 1 `RECEIPT-MISMATCH S040` (`fired=3`); F2 exit 1 with
  `Traceback` (release-clock.py:567 → :380); G1 with retained receipt exit 1, four `RECEIPT-MISMATCH` lines (`observed=26
  derived=11`); G1 with forged receipt exit 0 `CLEAN … derived=15`.
- `python3 -I -B exp_observe.py` → exit 0; `parse_latest_version → '3.15.01'`, receipt `verdict "fired"`; F4 → `ValueError`
  raised at :760, caught at :822 as a receipt `error` string; `numeric_version` raises the same `ValueError` for a 4301-digit
  component. `python3 -I -B exp_c2.py` → exit 0; 15 `derived:` rows, 0 unbound at BASE; located anchors S033 `3.13.3`, S034
  `2.2.0`, S035 `2.7.1`, S036 `3.15.0`, S037 `8.23.0`, S039 `3.15.1`; non-derived feed rows S012/S027/S028/S040/S041 listed.
- `python3 -I -B -c "import sys; print(sys.get_int_max_str_digits())"` → exit 0, `4300` (CPython 3.14.8); `read
  https://semver.org/spec/v2.0.0.html` → §2 "A normal version number MUST take the form X.Y.Z … and MUST NOT contain leading
  zeroes", §9 "Numeric identifiers MUST NOT include leading zeroes". No tool was installed or upgraded.

## What I did NOT check

- I did not run lane gates or selftests in the lane checkout, and I did not run `--observe` against the real network (all
  observe-path evidence comes from a stub opener in the sandbox); the live feed state on 2026-10-21 is unverified by me.
- I did not run `c1-measure.py` / `c2-measure.py` (both now exist; their BASE verdicts are their authors' and unverified by
  me). F1/F2/F3 state what the *fixtures as frozen* measure on the BASE tree. Per XC1Measure's own finding, F3/F4 exercise
  the row guard, not the feed-entry path, so QM27's feed-entry clause ("a version token used in a feed entry") is not
  exercised by the round's fixtures: the lesson should declare that half a limit, or the round should add a feed-entry case.
- I did not verify the round-28 SOURCES rows for the integer-string conversion limit or a SemVer §2 locator (F4): those rows
  do not exist at BASE; I opened no new source beyond the public semver.org spec quoted above, and did not assess
  separability, stamping, ledger pins, the census, other seats' candidate code or `corpus/knowledge/*.md` numbers (QM26).
