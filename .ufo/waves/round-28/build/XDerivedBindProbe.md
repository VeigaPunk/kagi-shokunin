# XDerivedBindProbe — empirical BASE probe for round-28 C2 (derived-anchor binding)

BASE: `3553d499577084a6c98d7078906017840bbf7b28`, sandbox `…/round-28/sandboxes/XDerivedBindProbe/`
(base=untouched BASE tree; base2/base3=tamper copies). Probe imports `corpus/release-clock.py`
functions and loads both registries exactly as the clock does. Interpreter: Python 3.14.8, all runs
`python3 -I -B`. No tools installed (none needed). All paths below are at BASE.

## Findings (counterexamples exact)

F1 — All 15 `derived:` rows ALREADY satisfy the proposed C2 predicate. For every derived row,
`version_is_named(SOURCES[feed_source_id].anchor, anchored_version)` is True and v-stripped exact
token membership is True. Adding the C2 check at BASE therefore cannot break the control; control
stays CLEAN30 (verified below). Groupings match the plan's fixture map exactly:
S033→S008–S011, S034→S013+S022–S024, S035→S014–S016+S021+S025+S026, S037→S029
(corpus/release-clocks.tsv:5-8,10-13,18-23,26). S036/S039 carry no derived rows (TSV:24-25,30-31
are non-derived), so fixtures G1–G4 never touch python.org.

F2 — The check MUST use v-stripped token equality (`version_is_named` semantics,
corpus/release-clock.py:341-347). A raw verbatim token compare fails on 14 of 15 rows: S033/S034/S035
anchors carry `v3.13.3` / `v2.2.0` / `v2.7.1` (corpus/SOURCES.md:39-41) while anchored values are
`3.13.3` / `2.2.0` / `2.7.1`. Only S036/S037/S039 anchors carry bare tokens (SOURCES.md:42,43,46).

F3 — A naive "ALL rows must match feed anchor" rule is wrong twice over:
- R1 (every feed row must satisfy `version_is_named(feed_row.anchor, anchored)`): breaks exactly
  S012 (TSV:9). Its feed row S034 names v2.2.0 (SOURCES.md:40); S012 anchors `v1.21.x`, named only
  by S012's OWN row (SOURCES.md:18). BASE passes S012 because evaluate() checks the row's OWN
  anchor for non-derived rows (release-clock.py:566), not the feed row.
- R2 (anchored must equal the feed-URL floor, release-clock.py:390-410): breaks S012 (non-numeric)
  and S027+S028 (TSV:24-25, anchored 3.15.0 < floor 3.15.1).
- S040/S041 (TSV:30-31) break under NEITHER variant: S039's anchor names `Python 3.15.1`
  (SOURCES.md:46) = their anchored 3.15.1. The listing hypothesis "S040/S041 break" is falsified;
  they are clean under every naive variant tried. Only S012 (R1) / S012+S027+S028 (R2) break.
⇒ Scoping the new binding to `derived:` rows is necessary AND sufficient at BASE: derived-only R1
breaks nothing (F1) and leaves S012/S027/S028/S040/S041 untouched.

F4 — The C2 gap is real and empirically demonstrated on S029 (TSV:26, feed row S037 SOURCES.md:43
naming `8.23.0`). At BASE no check binds a derived anchor to anything: `anchor_ok = is_derived or
version_is_named(...)` short-circuits (release-clock.py:565-566), and `receipt_matches`
(release-clock.py:425-455) pins id/clock/url/verdict/observed_at/parsed_version but NEVER
`anchored_version`. Lowering S029 anchor+observation to 8.22.0 with a consistently forged receipt
runs CLEAN exit 0. The after-state predicate `version_is_named(S037.anchor, "8.22.0")` = False
would flag exactly S029 (EXACT for G4); `version_is_named(S037.anchor, "8.23.0")` = True.

F5 — The `derived:` exemption is load-bearing for all 15 rows, not just some: every derived row
FAILS the own-anchor rule (`own_named=False` for 15/15), e.g. S029's own row names `curl 8.23.1`
man page, the unreleased DEV label (SOURCES.md:35) while anchored 8.23.0. So C2 must bind derived
rows to the FEED row's anchor — binding to their own anchor would fail all 15.

F6 — Non-derived contrast: lowering S040 (non-derived) anchor+observation to 3.14.9 trips
`REGRESSED S040` (floor 3.15.1) + `RECEIPT-MISMATCH S040`, exit 1. BASE already disciplines
non-derived rows via own-anchor + floors + receipts; none of those categories is a derivation
finding — C2 adds the missing one, derived-only.

## Derived-row table (probe output, probe.py exit 0)

| id  | line | feed  | feed@SRC | anchored | feed-row anchor text (SOURCES.md)                     | named | exact-tok |
|-----|------|-------|----------|----------|-------------------------------------------------------|-------|-----------|
| S008 |  5 | S033 | :39 | 3.13.3 | Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z; … | True | True |
| S009 |  6 | S033 | :39 | 3.13.3 | (same as S008)                                        | True  | True |
| S010 |  7 | S033 | :39 | 3.13.3 | (same as S008)                                        | True  | True |
| S011 |  8 | S033 | :39 | 3.13.3 | (same as S008)                                        | True  | True |
| S013 | 10 | S034 | :40 | 2.2.0  | Entry titled v2.2.0, tag link /releases/tag/v2.2.0, updated 2026-10-15T18:50:14Z; …  | True | True |
| S014 | 11 | S035 | :41 | 2.7.1  | Entry titled v2.7.1, tag link /releases/tag/v2.7.1, updated 2026-10-01T18:32:18Z; … | True | True |
| S015 | 12 | S035 | :41 | 2.7.1  | (same as S014)                                        | True  | True |
| S016 | 13 | S035 | :41 | 2.7.1  | (same as S014)                                        | True  | True |
| S021 | 18 | S035 | :41 | 2.7.1  | (same as S014)                                        | True  | True |
| S022 | 19 | S034 | :40 | 2.2.0  | (same as S013)                                        | True  | True |
| S023 | 20 | S034 | :40 | 2.2.0  | (same as S013)                                        | True  | True |
| S024 | 21 | S034 | :40 | 2.2.0  | (same as S013)                                        | True  | True |
| S025 | 22 | S035 | :41 | 2.7.1  | (same as S014)                                        | True  | True |
| S026 | 23 | S035 | :41 | 2.7.1  | (same as S014)                                        | True  | True |
| S029 | 26 | S037 | :43 | 8.23.0 | Lines Version and Date: 8.23.0, 2026-10-14 (Next release: 2026-12-09); …            | True | True |

`named` = version_is_named(feed_anchor, anchored); `exact-tok` = v-stripped token membership
(F2: raw verbatim would be False for the 14 rows on S033/S034/S035). All 15 verdict=not-fired,
own_named=False (F5).

## Non-derived feed rows under naive rules

| id  | line | feed  | anchored | feed-row anchor names | R1 named | R2 floor-eq | verdict |
|-----|------|-------|----------|----------------------|----------|-------------|---------|
| S012 |  9 | S034 :40 | v1.21.x | v2.2.0       | False | False (non-numeric) | fired   |
| S027 | 24 | S036 :42 | 3.15.0  | 3.15.0       | True  | False (floor 3.15.1) | fired  |
| S028 | 25 | S036 :42 | 3.15.0  | 3.15.0       | True  | False (floor 3.15.1) | fired  |
| S040 | 30 | S039 :46 | 3.15.1  | 3.15.1       | True  | True                 | not-fired |
| S041 | 31 | S039 :46 | 3.15.1  | 3.15.1       | True  | True                 | not-fired |

S027/S028 pass R1 only because their feed_source_id S036 is the RETAINED old snapshot naming
3.15.0 (SOURCES.md:42, superseded in prose by S039 :46); any implementation that resolves the feed
row by URL/"current" instead of by the row's own feed_source_id id would break them. BASE is fully
id-keyed here (`sources.get(feed_source_id)`, release-clock.py:556 area); C2 must stay id-keyed.

## Commands and exits (sandbox only; lane tree untouched)

1. `git archive 3553d49… | tar -x -C …/XDerivedBindProbe/base` → OK (exit 0)
2. `python3 -I -B corpus/release-clock.py --root .` in base →
   `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0
   — the after-default control stays CLEAN30; fired=3 = S012/S027/S028, derived=15 = F1 rows.
3. `python3 -I -B probe.py base` (probe imports parse_sources/parse_bindings/version_is_named/
   feed_floors/VERSION_RE from release-clock.py) → tables above, exit 0.
4. Token-nuance one-liner over feed anchors → raw tokens S033 `['v3.13.3','v3.13.3']`,
   S034 `['v2.2.0','v2.2.0']`, S035 `['v2.7.1','v2.7.1']`, S036 `['3.15.0']`, S037 `['8.23.0']`,
   S039 `['3.15.1']`; bare-verbatim False on S033/S034/S035, norm-token True on all — exit 0.
5. base2: S029 → anchored/observed `8.22.0` (TSV edit) + default run →
   `RECEIPT-MISMATCH S029` / `RELEASE_CLOCK: FAILED (… observed=29 fired=3 derived=14)` exit 1
   (observed-side pin only; no derivation category).
6. base2 + forged receipt (observe-2.json with S029 parsed_version→8.22.0, `--receipt …
   --receipt-sha ea6745ce…3d0c`) → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0
   observed=30 fired=3 derived=15)` exit 0 — F4 proven.
7. base3: S040 → anchored/observed `3.14.9` + default run →
   `REGRESSED S040` + `RECEIPT-MISMATCH S040` / FAILED exit 1 — F6.
8. After-state predicate spot-check: `version_is_named(S037.anchor,"8.22.0")=False`,
   `("8.23.0")=True`, `(S034.anchor,"v1.21.x")=False`, `("2.2.0")=True` — exit 0.

## What I did NOT check

- No live network fetches; SOURCES.md anchor cells and the round-26 receipt are taken as frozen
  BASE text, not re-verified against upstream feeds (out of probe scope; lane bounds).
- `.ufo/waves/round-28/tools/c1-measure.py` / `c2-measure.py` do not exist at BASE; I did not run
  or pre-write the frozen counting commands.
- C1 fixtures/leading-zero behavior not exercised here (separate lane item).
- No fixture combining BOTH C1 (non-canonical token) and C2 (mismatch) on one row; the interplay
  order of the two new findings is untested.
- Behavior if a future derived row points at a superseded feed row (S036→S039 pattern): no such
  row exists at BASE, untested by construction.
