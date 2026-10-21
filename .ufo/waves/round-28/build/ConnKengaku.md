# ConnKengaku — round-28 sibling-overlap scan (kengaku-shokunin), read-only

Seat `KagiR28.ConnKengaku-7` (connector, leaf, no subagents), 2026-10-21; lane-authored advice, not non-author closure; no SHONEN mark.
kengaku read at HEAD `56fd949a6478342531e61f4feecb4a685d831640` (`git -C .../kengaku-shokunin rev-parse HEAD`, exit 0); `git status --short` shows only untracked `.ufo/waves/round-29/*` and `corpus/lessons/round-29.md` (exit 0), so cited paths are HEAD bytes.
kagi cites are BASE `3553d499577084a6c98d7078906017840bbf7b28`, extracted with `git archive BASE | tar -x` into `.ufo/waves/round-28/sandboxes/ConnKengaku/base` (exit 0). Axes: freshness (C1), calibration (C2); nothing below asks for repricing.

## Findings

**F1 — kengaku has no release clock; overlap is the registry grammar, not clock semantics.** `kengaku corpus/SOURCES.md:21` is the same 11-column table (73 rows). Its only registry parser, `kengaku plans/registry_check.py:16,25-50,54-88`, is population-scoped (`:42` skips ids outside the frozen 13), checks status/tier/kind (`:76`) and used-by paths, and never parses a version token or binds an anchor. Its production census (`kengaku plans/state_check.py:633-661`) counts rows/malformed/tier/status by cell index (`fields[4]`, `fields[8]` at `:652`). No sibling version mechanism exists to absorb.

**F2 — same `recheck` column, two semantics; kagi's on-release binding is lane-local.** kagi has 30 `on-release` + 11 `90d` + 2 `180d` rows (43 total); kengaku has 19 `on-release` + 17 `180d` + 10 `90d` + 19 `2027-01-17` + 8 `2027-01-19` (73 total) and **no** release-clocks table. The fleet gate defines the vocabulary: `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh:663-666` accepts ISO date, `NNd`, or symbolic cadence; `:582` symbolic is any `[A-Za-z][A-Za-z0-9 _-]*`; `:34-36` reports symbolic cadences but never judges them overdue. “An `on-release` row must be bound to a clock” is therefore kagi's QM23 (`corpus/QUALITY.md:120`), not a SOURCES-contract rule; generalized it contradicts 19 accepted kengaku rows.
The one exact shared URL is `docs.python.org/3/library/re.html` (fleet `shared` mode, exit 0): kagi `corpus/SOURCES.md:47` (S040) binds it via `corpus/release-clocks.tsv:30`; kengaku `corpus/SOURCES.md:68` (S046) does not — same page, two accepted mechanisms. kengaku anchors are prose, not canonical: `v1 (30 Sep 2025)` (`:24`, S002), `Time Horizon 1.1` (`:36`, S014); only 11/73 anchor cells contain an X.Y.Z. Keep QM23/QM25 (`corpus/QUALITY.md:132`) lane-local; the fleet census checks shape/recheck vocabulary only.

**F3 — C1 fixture F1 is already TYPED at BASE; only a receipt edit reaches the defect.** The frozen text's table-only edit at `corpus/release-clocks.tsv:30` (S040 `observed_version=3.15.01`, `verdict=fired`) yields `RECEIPT-MISMATCH S040`, exit 1, because `corpus/release-clock.py:425-455` requires `norm_version(parsed_version) == norm_version(observed)` and `:362-367` strips only a leading `v`. With a receipt carrying S040 `parsed_version=3.15.01`, `verdict=fired` (sha `bcf060cf…`) the same tree prints `RELEASE_CLOCK: CLEAN (… fired=4)` **exit 0** — the real C1 defect. The frozen F1 text names no receipt companion, so as written it cannot demonstrate a fired release; the measure must declare that edit (absent from the frozen fixture) or its “before” is not 4/4. Report, do not redefine.

**F4 — C1 F4 (`--observe` oversize) is caught, not a traceback; the C1 narrative is path-specific.** `observe_one` catches `(OSError, ValueError)` at `corpus/release-clock.py:819`, so an oversize patch component becomes `receipt["error"]`; probe with a synthetic 200 body gives `parsed=None, error="Exceeds the limit (4300 digits)…"`, and evaluation exits 1 with `RECEIPT-MISMATCH`, no traceback. The untyped `ValueError` is real only on the table path: `numeric_version` at `:369-380` (`int()` at `:380`) raises inside `evaluate` (`:567`), exit 1 with traceback (F2-style confirmed). BASE mishandling is unambiguous only for F2; F3 is mishandled only under the predicate's “written fired observation” clause (receipt says `fired`/`3.15.01` while the immediate table evaluation exits 1 `RECEIPT-MISMATCH`); F1 and F4 are already TYPED. This is a defect in the frozen fixture description.

**F5 — C2's anchor binding is column-identity-blind (row-level swap stays green).** Probe on BASE: all 15 `derived:` rows' anchored versions are named by their feed row's anchor (`anchor misses = []`), so C2 has no false positive today; but all 15 are also named by that row's `teaches` cell. Swapping cells 5/6 in S033–S037 (11 fields, header untouched) leaves the default `CLEAN` (exit 0) and a draft C2 binding check at `0` mismatches. Cause: `parse_sources` (`corpus/release-clock.py:58-96`) maps by index (`anchor` `:88`, `teaches` `:89`) and never reads the header; kagi's census accepts any header starting `| id |` (`corpus/sources-census.sh:210`); kengaku's production census also indexes cells (`state_check.py:649-652`) and its exact header string is selftest-only (`:4201`). Limit: a row-level swap is outside C2's frozen threat model (C2 fixtures leave SOURCES.md untouched), but C2's claim should say it binds the **anchor column**, not “the located anchor”, unless the column is verified.

**F6 — ID grammar diverges from the fleet and the sibling.** `corpus/release-clock.py:29` uses `S[0-9]{3}` (exactly three digits); `scripts/sources-census.sh:24,637` and `kengaku plans/registry_check.py:16` use `S[0-9]{3,}`. Probe: appending `S1000` leaves `parse_sources` at 43 rows, S1000 absent, no error. No live row today (max S043), but a feed row past S999 would be invisible; a `derived` row bound to it surfaces only as `BADFEED` (`release-clock.py:557-560`), not a precise finding. Align to `{3,}` for the new row.

**F7 — kagi's own census does not validate `recheck`; the fleet gate does.** `corpus/sources-census.sh:25-60,210` has no `SC_RECHECK` (only knowledge-entry presence at `:340`); fleet E09 (`scripts/sources-census.sh:663-666`) is the gate that will catch a bad cell on C1's new source row. Not a contradiction, but C1 depends on a gate kagi does not run.

## Absorb / contradict ruling

Absorb: **no** — kengaku claims LLM/model evaluation, not release feeds; its PROVINCE routes only “Janitor consumer-side endpoint/credential config” to kagi (`kengaku PROVINCE.md:26`, table `:140`). kagi owns its clock and census (`kagi PROVINCE.md:54-55`); chousa owns research method (`:67`). Contradict: **no file or ownership conflict**; only the contract-level generalizations in F2/F6, which vanish if C1/C2 stay lane-local. The shared `re.html` URL is the strongest evidence: same page, two accepted recheck mechanisms.

## Reusable prior art

1. Population-scoped findings — `kengaku plans/registry_check.py:42-50,54-88`: non-population ids are skipped; findings name only population rows. C2 reusing global `parse_sources` inherits a global `setup()` abort on any unrelated malformed row (`release-clock.py:78-83`); the sibling pattern keeps C2's failure precise.
2. Named-column mapping — `registry_check.py:50` zips 11 cells to 11 names; the exact header string precedent is `state_check.py:4201`. Resolve `anchor` by name before reading it.
3. Complete-token re-derivation — `state_check.py:20,742-743`: supersession requires the complete tokens; cherry-picked fragments never re-derive. C1 should compare complete canonical tokens, not normalized prefixes.
4. Revision identity vs release name — `kengaku plans/benchmark_spec_audit.py:20` binds to snapshot `dce04686` and separates it from the 2023-07-25 release. kagi S029/S037 already do this (DEV label vs `Next release:` date); cite as C2's precedent.
5. Fleet recheck vocabulary — `scripts/sources-census.sh:663-666,582`; `overdue` gives due-date semantics.

## Proposed move (one, bounded)

Add a C2-only helper (leave C1's `parse_sources` path unchanged): read the registry once, resolve the 11 columns by the exact `## Registry` header names, keep only the feed ids named by the 15 `derived:` rows, and emit a typed C2 finding (not a global SETUP) when a needed feed row is short/malformed. This synthesizes `registry_check.py`'s population scoping and named mapping, makes C2 independent of unrelated SOURCES edits (new rows arrive every round), and lets C2 quote a verified `anchor` column instead of index 5.
- Axis: calibration (C2 failure precision). Freshness untouched. Risks: a second parser can drift from `parse_sources` (extract a shared cell-splitter or assert agreement on S033–S037); a header-less synthetic fixture must still work (the clock selftest writes `fixture_source` rows with no header, `release-clock.py:991-999`); a row-level cell swap remains undetected (F5) — declare that limit.
- Verification (integrator, not this seat): BASE default stays `CLEAN … fired=3 derived=15` exit 0; C2 fixture groups still go ACCEPTED→EXACT 0/4→4/4; new selftest cases for an unrelated malformed row (verdict unchanged) and a header-name mismatch (typed finding). Unrun checks are not passes.

## Commands run (exit codes)

- `git -C kengaku rev-parse HEAD` 0; `git status --short` 0 (untracked only). `git -C kagi archive BASE | tar -x` 0; `wc -l` release-clock.py 1758, release-clocks.tsv 31.
- `python3 -I -B probe.py` 0: Python 3.14.8, `int_max_str_digits=4300`; `norm_version("3.15.01") != norm_version("3.15.1")`; `numeric_version("3.15.01")==(3,15,1)`; oversize `numeric_version` → `ValueError`; `parse_latest_version` returns `3.15.01`; `parse_sources` 43 rows with S1000 absent; 15 derived rows, 0 anchor misses, 15 also named in teaches.
- `python3 -I -B probe2.py` 0: F3 receipt `fired/3.15.01`, evaluate `RECEIPT-MISMATCH`; F4 receipt `error=Exceeds the limit`, evaluate `RECEIPT-MISMATCH`, no traceback.
- BASE default `python3 -I -B corpus/release-clock.py` → `CLEAN (… fired=3 derived=15)`, 0. F1 table edit, default receipt → `RECEIPT-MISMATCH S040`, 1; with matching receipt (sha `bcf060cf…`) → `CLEAN (… fired=4)`, 0.
- F2 oversize table edit → `ValueError: Exceeds the limit (4300 digits)` traceback, 1. C2 column swap S033–S037: default `CLEAN`, 0; draft C2 shim `0` mismatches, 0.
- `bash scripts/sources-census.sh shared --today 2026-10-21 kagi-shokunin kengaku-shokunin` 0 → one shared URL (`docs.python.org/3/library/re.html`). Release-feed URL grep over kengaku SOURCES: no matches (pipeline exit 0).

## Not checked

- No network; no feeds fetched. F3/F4 ran through `observe_one` with a synthetic 200 body, not the real `urllib`/redirect path.
- No kengaku gate/selftest and no kagi lane gate/selftest executed; only `shared` (read-only) from the fleet census. `sources-census.sh validate` was not run.
- C2 has no BASE implementation; the “C2 draft shim” is a 10-line sandbox check, not production code. Frozen `c1-measure.py`/`c2-measure.py` do not exist at BASE; I did not create or run them.
- No sibling beyond kengaku inspected. No host-private reads, no vault/account/CDP contact. kengaku's untracked round-29 files were not used as evidence (tracked corpus/plans only).
