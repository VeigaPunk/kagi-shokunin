# RevRearmFlow — C2 × rearm coupling (freshness, calibration)

Reviewer seat, round-28 build. BASE `3553d499577084a6c98d7078906017840bbf7b28` (frozen); line numbers are BASE.
Sandbox (BASE copy + drafts only): `.ufo/waves/round-28/sandboxes/RevRearmFlow-7/`; harness `ce.py`,
`c2probe.py`, `e7b.py`, `e7c.py`, trees under `ce/`. No lane gate, no network, no vault/account, no Git
mutation, no tool install. Only this report was written outside the sandbox.

## Answer

**C2 does not make rearm impossible, but it makes it impossible *without touching `corpus/SOURCES.md`*, and it
removes the round-26 rearm shape.**

The only executed rearm precedent kept predecessors and added successors (`corpus/lessons/round-26.md:181-196`;
`:37` "no old source row is demoted or silently re-anchored"; QM24 `corpus/QUALITY.md:126`). That shape is
**unavailable for the 15 `derived:` rows**: a successor raises the feed floor (`corpus/release-clock.py:390-411`
`feed_floors`, used at `:568`), so retained predecessors with older observations become `REGRESSED` (E7c below).

The only C2-clean rearm of a `derived:` row is: (a) mutate the row **in place**; (b) bind it to a **new feed
registry row** naming the new release (`SOURCES.md` append; precedent S039 supersedes S036); (c) re-observe (new
receipt); (d) migrate default receipt path + digest + R25-04/R21-02/R25-03 expectations + self-counts + stamps;
(e) journal old→new (QM14 `QUALITY.md:73`) and re-verify fired clocks (QM23 `QUALITY.md:120`). Editing the
admitted feed row in place (E4) is the only way to keep `feed_source_id` unchanged, and it rewrites a dated,
quoted, stamped historical observation — the shape `round-26.md:37` forbids. **The coupling is acceptable only
under the append-only reading; the plan should say so, because C2 turns a clock-table operation into a registry
operation.**

Files that must move together (one reviewed commit): `corpus/release-clocks.tsv` (derived rows :5-8, :10-13,
:18-23, :26 — `anchored_version`, `observed_version`, `observed_at`, `verdict`, `note`, `feed_source_id`
repoint); `corpus/SOURCES.md` (new feed row + successor source rows + capture digest + `recheck`; `## Paths`
bullet :54); `corpus/source-fetches.tsv` (capture row per new id, cf. :76); `corpus/release-clock.py`
(`DEFAULT_RECEIPT_SHA256` :31, `receipt_path` default :495-499); the new receipt (binding logic
`receipt_matches` :425-456); `corpus/claim-ledger.tsv` (R21-02 :52, R25-03 :82, R25-04 :83);
`corpus/self-counts.tsv` :22,:38 + `SKILL.md` :48,:787,:791 + `PROVINCE.md` :54; `corpus/stamps.tsv` :8,:77,:78;
the round lesson.

## Findings by severity

**F1 — High. The round-26 successor shape cannot rearm a `derived:` feed; the predecessors go `REGRESSED` and
the gate exits 1.** `feed_floors` (:390-411) + `:568`. E7c (new feed row naming v3.14.0 + successor
anchored/observed 3.14.0 + matching receipt, predecessors untouched) → `REGRESSED S008 S009 S010 S011`, `FAILED
(on_release=31 bound=31 unbound=0 observed=27 fired=3 derived=12)`, exit 1. QM24 demands "a later-release
fixture must fire the successor"; for `derived:` rows the successor can only be added by *also* mutating every
predecessor. round-27 names the cascade (`round-27.md:219-220`, CritFinalC2 #3) only for a row rearmed ahead of
its feed — here it is the *only* shape, at 15 rows / 4 groups (S033: S008-S011; S034: S013,S022-S024; S035:
S014-S016,S021, S025,S026; S037: S029). **C2/the plan should require an atomic in-place rearm per feed group and
state that the round-26 successor shape is inapplicable to `derived:` rows.**

**F2 — High. A clock-table-only rearm is CLEAN at BASE but is rejected by C2 — the coupling lands on the
registry.** E3 (S008-S011 anchored+observed → 3.14.0, receipt forged) → `RELEASE_CLOCK: CLEAN (on_release=30
bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0. My scratch C2 probe (feed row's **anchor cell**,
first X.Y.Z match) on that tree: 4 MISMATCH (anchored 3.14.0 vs S033's `['3.13.3','3.13.3']`); on BASE: 15
derived rows, 0 mismatch (C2 is satisfiable today); on E4 (S033's anchor/quote edited in place): 0 mismatch —
**C2 then passes only because an admitted, dated, quoted registry row was rewritten** ("| S033 | … | Entry
titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z; feed fetched 2026-10-21 | The
newest stable SOPS release is v3.13.3 … Quote: “<title>v3.13.3</title>”" → the same row asserting v3.14.0 at a
2026-10-21 fetch). That is QM14 laundering and contradicts `round-26.md:37`.

**F3 — High. A rearm is atomic per feed group; one row is not enough.** E2 (rearm only S009 of the four SOPS
derived rows, receipt forged) → `REGRESSED S008 S010 S011`, `FAILED (… observed=27 …)`, exit 1. A partial rearm
is a typed failure, not a warning.

**F4 — Medium. C2 is a *string* binding to a *dated* snapshot: it cannot detect a stale derived anchor, and
11/15 derived rows already carry a date their pinned source does not support.** Notes date the derivation to the
clock row's opening (`release-clocks.tsv:5-8` "when the row was opened 2026-10-19"; `:18-20` "2026-10-20") while
the only pinned observation is the feed row's fetch (`SOURCES.md:39-41` "feed fetched 2026-10-21"). Measured:
S008-S011, S013-S016 (2026-10-19) and S021-S023 (2026-10-20) vs 2026-10-21 → 11/15 mismatch; only S024-S026,
S029 agree. Version-equality is therefore the only satisfiable C2 reading (a date-checking C2 fails 11/15 today)
— but C2 binds a note to a source that did not observe that note's date, and it cannot see that the pinned feed
row is stale against the live feed. Cadence compounds it: feed rows are `90d` (`SOURCES.md:39-43`), the clocks
they bind are `on-release`; between feed-row refreshes a feed advance is not representable under C2 without an
out-of-cadence registry append. [INFERENCE] C2 is a *provenance* binding, weaker than QM21 (`QUALITY.md:118`) in
the currency dimension; "as QM21 binds numbers" should be read as provenance-only.

**F5 — Medium. "the version named by its `feed_source_id` registry row's located anchor" is underspecified:
anchor cell or whole row, first match or any match.** Whole-row X.Y.Z tokens per feed row (measured): S034
`['2.2.0','2.2.0','2.2.0', '0.26.0','2.2.0','2.2.0']` (`sdk/v0.26.0`), S037 `['8.23.0','8.23.0','8.23.1',
'8.23.0','8.23.0']` (8.23.1 = curl's unreleased DEV label, in `teaches`), S039
`['3.15.1','3.15.1','3.14.9','3.16.0','3.15.1','3.15.0']` (backport, prerelease). A whole-row any-match reading
would let a derived anchor sit at 8.23.1, 3.16.0 or 3.14.9. Counterexample E5 (BASE): S029 anchored/observed →
8.23.1 → `CLEAN (… derived=15)`, exit 0 — BASE accepts a derived anchor at a non-release; the anchor-cell
reading rejects it (probe: S029 MISMATCH vs S037's `['8.23.0']`). **C2 must read the anchor cell
(`parse_sources`, `release-clock.py:88`, `cells[5]`) and must compare the *feed* row, not the clock row's own
source row:** S029's own source row names 8.23.1 (`SOURCES.md:35`), feed row S037 names 8.23.0, and the derived
anchor is 8.23.0.

**F6 — Medium. C1's canonicality check must also cover the registry anchor cell, or C2 can pin a non-canonical
token.** E8 (BASE): S008 anchored+observed `3.13.03` → `CLEAN (… derived=15)`, exit 0 — the leading-zero token
passes because `numeric_version` int-converts components (`:366-380`) while the fired/not-fired equality is a
string compare (`:585-586`). A rearm writes the token into two places (table + new registry anchor cell); if C1
scans only table and feed, the registry cell is a hole and C2 certifies the non-canonical token as bound. Frozen
C1 fixtures (F1/F2) are table/feed only → lesson gap, not a frozen-set gap.

**F7 — Low. C2's scope names S033-S037, but there are six feed rows (S036, S039 too) and round-27's flip wording
is wider** (`round-27.md:217` "bind every floor-contributing anchor to its feed row's anchored release").
Behaviour is equal today (S040/S041 are floor contributors; their feed S039 names 3.15.1 = their anchor), but
the wording should not imply S039 is out of scope.

**F8 — Low. A rearm is not a table edit: it invalidates the pinned default receipt.** E3 tree with the *default*
receipt → `RECEIPT-MISMATCH S008 S009 S010 S011`, exit 1 — `receipt_matches` (:425-456) binds the receipt's
`verdict`, `observed_at` date and `parsed_version` to the row. QM24's "Active default/receipt/table/expectation
migration is explicit" applies verbatim; precedent `round-26.md:192-193` (default path, literal digest, R25-04
pattern migrate by a named old/new record).

## Commands run (sandbox only; exit codes as shown)

- `python3 -I -B corpus/release-clock.py --root base` → exit 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` (matches `claim-ledger.tsv:83`).
- `python3 -I -B ce.py` → E0 exit 0; E1 exit 1 (`REGRESSED S008-S011`); E2 exit 1 (`REGRESSED S008 S010 S011`); E3 exit 0; E4 exit 0; E5 exit 0; E6 token census.
- `python3 -I -B c2probe.py` → probe: base 15 rows/0 mismatch, e3 15/4, e4 15/0, e5 15/1; whole-row any-match on base 15/0.
- `python3 -I -B e7b.py` → exit 2 (my SOURCES.md id clash with the existing S042; re-run as `e7c.py`).
- `python3 -I -B e7c.py` → exit 1, `REGRESSED S008 S009 S010 S011`.
- E8 (inline) → exit 0 with the leading-zero token `3.13.03`.
- `python3 -I -B ce/e3/corpus/release-clock.py --root ce/e3` (default receipt) → exit 1, `RECEIPT-MISMATCH S008-S011`.

## What I did NOT check

- No network fetch: "SOPS 3.14.0" is a **synthetic** version used only to exercise the machinery; no such release is claimed and no feed was re-observed.
- No execution of the real C1/C2 candidates (XC1Patch/XC2Patch own those); my C2 probe is a scratch reviewer-side predicate, not an implementation claim.
- No lane-checkout gate run (forbidden here): `bash corpus/sources-census.sh`, `bash corpus/claim-ledger.sh verify`, `python3 corpus/release-clock.py --selftest` were **not** run; I read `corpus/claim-ledger.tsv` pins instead. No `stamp` / `stamps.tsv` regeneration; stamp rows cited are read from BASE only.
- Did not re-derive round-26's `expectation-migrations.json` or verify the round-26 frozen snapshot's digests; did not judge C2's scope (derived-only) beyond checking that named-anchor rows are already bound by `version_is_named` (`:566`).
