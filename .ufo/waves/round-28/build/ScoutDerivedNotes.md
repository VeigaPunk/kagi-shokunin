# ScoutDerivedNotes — C2 population check: the 15 `derived:` rows vs their feed-row anchors

BASE `3553d499577084a6c98d7078906017840bbf7b28`; `corpus/` is byte-identical to BASE
(`git diff --stat <BASE> -- corpus/` empty, exit 0; `diff` extracted vs worktree exit 0).
Work under `.ufo/waves/round-28/sandboxes/ScoutDerivedNotes-7/`.

Parser facts: the registry "anchor" the clock sees is **cells[5]** of the SOURCES row
(`corpus/release-clock.py:88`), the `<title>` quote is cells[6]. Feed rows are gated for
existence, `kind in ("docs","code","dataset")` (`:357-359`), `recheck != on-release`,
`url == feed_url` (`:557-563`). `derived:` is only a note *prefix* (`:565`) and the bypass is
`anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)` (`:566`).

## Findings

**F1 — Population is exactly 15 and every one already satisfies C2 at BASE.**
`version_is_named(sources[feed_source_id]["anchor"], anchored_version)` is True for all 15 and
`feed_url == sources[feed]["url"]` (`probe.py` → `FEED_BIND_FAIL: none`, exit 0); each feed
anchor cell holds *only* the derived version as a strict X.Y.Z token (S033→{3.13.3}, S034→
{2.2.0}, S035→{2.7.1}, S037→{8.23.0}; `SOURCES.md:39-43`). C2 guards clean data: the CLEAN30
control must stay exit 0 and no shipped row needs rewriting.

**F2 — S012 is the concrete false-positive trap; the plan's per-feed grouping invites it.**
`corpus/release-clocks.tsv:9` is non-derived, on **S034**, `anchored_version=v1.21.x`; its own
anchor names it (`SOURCES.md:18`), the feed anchor does not (`feed_names: False`). Binding
"rows on a feed carrying derived rows" instead of "rows whose note starts `derived:`" turns
S012 into a typed finding and breaks the control — and G1–G4 exclude S012, so only the control
run catches it. Gate exactly as `:565` does.

**F3 — S029 is the derivation naming something other than the feed row's release.**
`release-clocks.tsv:26` names `8.23.1` twice ("anchor names 8.23.1, curl's unreleased
development label (curlver.h 8.23.1-DEV)"); `SOURCES.md:43` names only `8.23.0`, own row
`SOURCES.md:35` names "curl 8.23.1 man page". The anchored `8.23.0` is right, but (a) a
checker extracting "the version" from the note pays 8.23.1 and mis-fires, and (b) S037 is
the one KEY:VALUE anchor (`Version: 8.23.0`), `kind=docs` — code hard-coded to the
`<title>vX</title>` Atom shape or `kind=="code"` silently excludes S029. Read cells[5] generically.

**F4 — S009/S010/S011 carry a second, non-feed version.** `release-clocks.tsv:6,7,8` say "a
docs-date anchor (v3.13.0) would read fired"; `3.13.0` is nowhere in S033's anchor, explicitly
counterfactual — not a disagreement, but a second note token, so no note-scanning.

**F5 — All 15 `derived:` markers are load-bearing.** `own_anchor_names_anchored` is False for
all 15: S008–S011/S013/S024 name no version; S014, S015, S016, S021, S025, S026 name only the
series `2.7.x`; S022 names `1.17` (a feature-note date); S023 the `v2.x` route path; S029
`8.23.1`. None is a dormant marker.

**F6 — Temporal gap between derivation and the bound anchor.** Every feed row says "feed
fetched 2026-10-21" (`SOURCES.md:39-43`), **after** the rows were opened (2026-10-19/20/21;
each note's first date equals the row's `opened` field, cells[8], verified ×15). C2 compares
against the feed's *current* anchor: it proves "the derived anchor is still the feed's newest
stable", not "was newest when opened". Sound here only because each feed's newest timestamp
(2026-07-23, 2026-10-15, 2026-10-01, 2026-10-14) precedes every open date — inferred from the
anchor cells, not an invariant. A release landing between open and a later fetch would flag a
historically correct derivation; say "no longer newest", never "wrong when derived".

**F7 — `version_is_named` is a name check, not a stable-release identity.** `:341-346` matches
a prerelease core and a build suffix: `"...v2.2.0-rc1..."` names `2.2.0` → True,
`"...v2.2.0+build7..."` → True (lookahead excludes only `[A-Za-z0-9.]`), while S034 excludes
prereleases (`SOURCES.md:40`). No live defect (no feed anchor names a prerelease), but a
forged anchored `2.2.0` would pass an anchor naming only `v2.2.0-rc1`. Strict equality on the
anchor cell's exact X.Y.Z token set is tighter and already clean here, so if C2 reuses
`version_is_named`, that reuse is the binding's weakest link.

**F8 — S024's note asserts a route fact its registry anchor does not record.**
`release-clocks.tsv:21` says "served v2.x (latest) route"; `SOURCES.md:30` records only POST
/:secret-mount-path/config parameters, max_versions and "served live docs opened 2026-10-21" —
no `v2.x`, unlike S023 (`SOURCES.md:29`); not a version mismatch, but unanchored prose.

**F9 — Frozen fixture groups are correct and total; their predicate has a residual limit.**
By `feed_source_id`: S033 {S008–S011}; S034 {S013,S022–S024}; S035 {S014–S016,S021,S025,S026};
S037 {S029} = 4+4+6+1 = 15 (`grep -c derived:` = 15, all prefixes, 0 mid-note), every row
`observed == anchored`, `not-fired` — BASE's `derived=15` is exactly this population. Fixtures
edit `release-clocks.tsv` only and cells[5]/cells[6] agree on all four feeds, so G1–G4 cannot
distinguish anchor-cell from quote-cell reads, nor id- from URL-based lookup: pin cells[5].

## Population table

| row:line | anchored | note-declared derivation | feed | feed anchor + declared quote | own anchor names | agree |
|---|---|---|---|---|---|---|
| S008:5 | 3.13.3 | v3.13.3 2026-07-23; opened 2026-10-19 | S033 | 3.13.3 “<title>v3.13.3</title>” | none (`main` snapshot) | yes |
| S009:6 | 3.13.3 | v3.13.3 2026-07-23 + counterfactual v3.13.0; opened 2026-10-19 | S033 | 3.13.3 “<title>v3.13.3</title>” | docs commit, none | yes (F4) |
| S010:7 | 3.13.3 | as S009 | S033 | 3.13.3 “<title>v3.13.3</title>” | docs commit, none | yes (F4) |
| S011:8 | 3.13.3 | as S009 | S033 | 3.13.3 “<title>v3.13.3</title>” | docs commit, none | yes (F4) |
| S013:10 | 2.2.0 | v2.2.0 2026-10-15; opened 2026-10-19 | S034 | 2.2.0 “<title>v2.2.0</title>” | none ("no displayed version") | yes |
| S014:11 | 2.7.1 | 2.7.x series; v2.7.1 2026-10-01; opened 2026-10-19 | S035 | 2.7.1 “<title>v2.7.1</title>” | 2.7.x | yes |
| S015:12 | 2.7.1 | v2.7.1; opened 2026-10-19 | S035 | 2.7.1 “<title>v2.7.1</title>” | 2.7.x | yes |
| S016:13 | 2.7.1 | v2.7.1; opened 2026-10-19 | S035 | 2.7.1 “<title>v2.7.1</title>” | 2.7.x | yes |
| S021:18 | 2.7.1 | Version 2.7.x; v2.7.1; opened 2026-10-20 | S035 | 2.7.1 “<title>v2.7.1</title>” | 2.7.x | yes |
| S022:19 | 2.2.0 | v2.2.0; opened 2026-10-20 | S034 | 2.2.0 “<title>v2.2.0</title>” | 1.17 (feature note) | yes |
| S023:20 | 2.2.0 | v2.2.0; opened 2026-10-20 | S034 | 2.2.0 “<title>v2.2.0</title>” | `v2.x` route | yes |
| S024:21 | 2.2.0 | v2.2.0; opened 2026-10-21 | S034 | 2.2.0 “<title>v2.2.0</title>” | none | yes (F8) |
| S025:22 | 2.7.1 | Version 2.7.x; v2.7.1; opened 2026-10-21 | S035 | 2.7.1 “<title>v2.7.1</title>” | 2.7.x | yes |
| S026:23 | 2.7.1 | Version 2.7.x; v2.7.1; opened 2026-10-21 | S035 | 2.7.1 “<title>v2.7.1</title>” | 2.7.x | yes |
| S029:26 | 8.23.0 | "anchor names 8.23.1 … 8.23.1-DEV"; 8.23.0 2026-10-14; opened 2026-10-21 | S037 | 8.23.0 “Version: 8.23.0” | curl 8.23.1 | value yes; note names 8.23.1 (F3) |

No genuine note↔anchored↔feed disagreement: every `anchored_version` is the strict release
named by its feed row's located anchor, and every note's *release* token equals it; the three
flag classes (F3 dev label, F4 counterfactual, `2.7.x` ×6) are note text only.

## Commands run (all in my sandbox unless noted)

- `git -C <lane> archive <BASE> | tar -x` → exit 0; `python3 -I -B tabulate.py base` → exit 0.
- `python3 -I -B probe.py` → exit 0 (first run exit 1, one format-string `TypeError`,
  fixed). 15× own=False/feed=True/url=True; `FEED_BIND_FAIL: none`; negatives S033←3.13.2,
  S034←2.1.9, S035←2.7.0, S037←8.22.0 all False; S037↛8.23.1; S034↛2.2.0-rc1, ↛0.26.0;
  S012 own_names=True, feed_names=False.
- `python3 -I -B -c` edge probes on `version_is_named` → exit 0: prerelease core True, build
  suffix True, `12.2.0`←`2.2.0` False, `8.23.0`←`8.23` False, date token False.
- `grep -c 'derived:'` → 15; `awk` prefix/mid-note check → 15/0; exit 0.
- `diff -q` BASE vs worktree for both corpus files → 0 / `BASE_EQUALS_WORKTREE`.
- `git diff --stat <BASE> -- corpus/` → empty, exit 0. No installs, no network, no pacman.

## NOT checked

- `c2-measure.py` / G1–G4 / control: `.ufo/waves/round-28/tools/` is **empty at BASE**
  (frozen commands are written this round); I ran no measurement.
- No live feed fetch; S033/S034/S035/S037 quotes (and `curlver.h 8.23.1-DEV`) are pinned
  registry evidence only.
- Did not audit other registry rows, the W04 duplicate-URL census lines, or round27 history;
  did not read or run lane selftests (forbidden in the checkout). No C2 implementation exists
  yet, so F2/F3/F7/F9 are design hazards on the BASE helpers, not observed round-28 failures.
