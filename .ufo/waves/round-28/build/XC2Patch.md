# XC2Patch — C2 derived-anchor binding (round 28 BUILD)

Deliverables: `sandboxes/XC2Patch/release-clock.py` (patched), `build/XC2Patch.diff` (143 lines, 6 hunks: 2 evaluate + 4 selftest), this report. Sandbox scratch: `sandboxes/XC2Patch/{base,work,redwork,redcheck.py,gcheck.py,gcheck-final.txt}`. All line cites at BASE 3553d499577084a6c98d7078906017840bbf7b28.

## Findings

F1 (the C2 gap). `corpus/release-clock.py:565-566`: `anchor_ok = is_derived or
version_is_named(sources[source_id]["anchor"], anchored)` — a `derived:` note
grants a free pass, so a derived anchor is bound to nothing. The 15 derived rows
(release-clocks.tsv:5-8, :10, :11-13, :18-23, :26) happen to equal their feed
row's anchor version today, so the tree is CLEAN; any lowered/forged derived
anchor with a matching observation is accepted. Measured: G1..G4 (table+receipt
lowered, see F2) → BASE exit 0 `CLEAN (… derived=15)` ×4.

F2 (frozen-fixture receipt coupling — plan defect, not redefined).
`receipt_matches` binds `parsed_version` to the row's `observed_version`
(release-clock.py:441-447), so the frozen G set executed with "release-clocks.tsv
edits only" (plans/round-28.md:60-64) + retained round-26 receipt exits 1 at
BASE with `RECEIPT-MISMATCH` on exactly the group rows — not the plan's
"ACCEPTED (exit 0 CLEAN)" baseline. The gap is only observable with the receipt
rewritten to match the forged observations (`--receipt FILE --receipt-sha`,
never touching `DEFAULT_RECEIPT_SHA256`) — a step the plan's own corrections already pin (plans/round-28.md:93-101, naming G1..G4 receipt mirroring): c2-measure must follow it, and
its EXACT predicate should key on the finding category (`DERIVATION`), not row
ids alone: RECEIPT-MISMATCH fires on the same ids. Convention adopted from
XC1Measure-7 (shared with c1-measure.py): "a typed finding for this fixture" =
a stdout finding line naming the fixture's row (or its feed URL) whose leading
category token is the claim's own new category — C2: DERIVATION; every
BASE-era generic category (ORPHAN, UNBOUND, INCONSISTENT, BADFEED, REGRESSED,
RECEIPT-MISMATCH, NOT OBSERVED, release-clock.py:519-630) and exit 2 SETUP is
OTHER, never TYPED. Measured under it: receipt-rewritten G set — BASE ACCEPTED
4/4 (exit 0 CLEAN), patched TYPED 4/4 (DERIVATION lines exactly, nothing
generic beyond the FAILED summary); retained-receipt G set — BASE exit 1
RECEIPT-MISMATCH S008-S011 only = OTHER (the masking trap, correctly never
TYPED), patched DERIVATION + RECEIPT-MISMATCH on the same ids = TYPED
(co-firing, category kept distinct). Both reviewer seats converged.

F3 (design decision, requested justification). Reuse `version_is_named`
(release-clock.py:341-347), reading only the feed row's anchor CELL
(`parse_sources` cells[5], release-clock.py:88) of `feed_source_id` — never
`teaches` (S037's `8.23.1` DEV label lives in teaches, SOURCES.md:43; its anchor
cell names 8.23.0). Answer to the v-question: yes — the needle is
`(?<![A-Za-z0-9.])v?<version>(?![A-Za-z0-9.])` IGNORECASE, so S033's `v3.13.3`
(SOURCES.md:39) names `3.13.3` (optional `v`), and `3.13.3` does NOT name
`3.13.30` or `3.13.3.1` (trailing lookahead rejects `[A-Za-z0-9.]`). Pure
string equality would reject every real v-prefixed feed anchor and break
CLEAN30; a max-X.Y.Z scan of the cell adds machinery with no gain (all 15
bindings are single-version cells; S033-S035 repeat the version). Derived-only
scope: S012 (`v1.21.x`, non-derived) keeps its own-anchor check (:9).

F4 (divergence for L1: unnamed feed anchor). My binding is total: a derived row
whose feed row's anchor cell names NO version gets `DERIVATION` ("derived anchor
needs a named version"). RevSelftestIsolation-7 proposed no-op; plan text
("must BE the version named by … located anchor", plans/round-28.md:41-43)
supports total; unobservable on the real corpus (S033-S037 all name versions)
and on the frozen G set (all lower to a canonical version). The hazard they
measured comes from leaving the harness fixture at "Latest release"; my patch
re-points run_case's default S002 anchor to "Latest release 1.2.0; series
1.2.x" (one harness line), so :1052/:1073/:1084 keep their BASE outcomes.

F5 (bookkeeping). Selftest 79 → 85 (+6, all new cases). Pins to move together
by L1 if this lands: SKILL.md:48 ("79 cases"), PROVINCE.md:54
(PV-CLOCK-SELFTEST), corpus/claim-ledger.tsv:82, corpus/self-counts.tsv:22,38.
XC1Patch-7 reports k=18 → composed 103; the count pin goes stale between
landings (round-27 lessons; order decided by L1).

F6 (advisory lesson wording, for L1). A derived series label ("2.7.x") is
refused against a cell naming "2.7.1" — QM25's declared non-numeric-anchor
limit class; case :1073 still proves it (fixture feed anchor names the series).

## Patch shape (all in corpus/release-clock.py)

1. :565-581 (BASE :565-566) — derived branch binds `anchored` to
   `sources[feed_source_id]["anchor"]` via version_is_named; mismatch adds
   typed `("DERIVATION", source_id)`; BADFEED-safe (missing feed row → empty
   anchor → DERIVATION + BADFEED, both naming the row).
2. :591 (BASE :585) — elif guard `not anchor_ok` → `(not is_derived and not
   anchor_ok)` so a derived mismatch yields exactly one finding, and every
   BASE error set is preserved byte-for-byte.
3. Selftest: run_case gains optional `feed_anchor` kwarg (default preserves all
   79 existing cases); +6 cases, each FAILING on BASE (red-check below):
   "derived anchor must name feed anchor" (v1.2.9 cell vs 1.2.0 row), "derived
   anchor rejects suffix sibling" (cell 1.2.30 vs row 1.2.3 — the 3.13.3/3.13.30
   shape), "derived anchor needs a named version" (cell without version),
   "derived fired anchor bound to feed" (fired path), "derived group named
   exactly" (S001+S004, exact error set), and an offline `--observe` CLI case
   (static Atom body through `main(["--root",…,"--observe",…])`, asserts exit 1
   + `DERIVATION S001`). verify / `--receipt` / `--observe` all funnel through
   the same `evaluate` (main, BASE :1741-1752): one insertion covers all three
   paths; gcheck exercises --receipt, the new case exercises --observe.

## Commands and exits (sandbox only; no lane checkout execution)

- `python3 -I -B base/corpus/release-clock.py --selftest` → `PASS (79 cases)`, exit 0.
- `--root <lane>` (BASE and patched) → `RELEASE_CLOCK: CLEAN (on_release=30
  bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0 both.
- Patched: `--selftest` → `PASS (85 cases)`, exit 0 (work/corpus tree layout).
- Red-before: redcheck.py = patch minus the two evaluate hunks (selftest kept)
  → exactly the 6 new case names FAIL, exit 1; all 79 original cases pass.
- gcheck.py (G1 SOPS 3.13.2 / G2 Vault 2.1.9 / G3 OpenBao 2.7.0 / G4 curl
  8.22.1; table+receipt lowered, per-feed): BASE exit 0 CLEAN ×4 (ACCEPTED
  4/4 — the gap); patched exit 1 ×4 with `DERIVATION` naming exactly
  S008-S011 / S013,S022-S024 / S014-S016,S021,S025,S026 / S029 and nothing
  else (EXACT 4/4; observed/derived counts drop by group size, fired stays 3).
- Mask probe (G1, retained receipt): BASE exit 1 RECEIPT-MISMATCH only;
  patched exit 1 DERIVATION + RECEIPT-MISMATCH on S008-S011 (F2).

## NOT checked

- Live-network `--observe` against real vendor feeds (lane policy: no live
  contact; offline static-body path proven instead).
- `.ufo/waves/round-28/tools/c1-measure.py` / `c2-measure.py` — empty at
  extraction; ACCEPTED/EXACT transitions are my manual reproduction of the
  frozen fixture shape, not the frozen tools' output.
- C1 interactions: composed tree measured by XC1Patch-7 (PASS 103, default
  CLEAN bytes identical), not by me.
- Pin-file updates (SKILL.md, PROVINCE.md, claim-ledger, self-counts) —
  production, read-only to me; listed in F5 for L1.
- Other corpus gates/selftests untouched and not run (lane bounds).
