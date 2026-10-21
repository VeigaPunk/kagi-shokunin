# XC2Measure — round-28 C2 counting instrument, measured at BASE

Deliverable: `.ufo/waves/round-28/tools/c2-measure.py` (sha256 97fe7ebe…40d4), implementing the frozen
`python3 -I -B .ufo/waves/round-28/tools/c2-measure.py <rev> <label> <out.json>` (plans/round-28.md §C2).
Draft + runs confined to `.ufo/waves/round-28/sandboxes/XC2Measure/`; artifact at
`.ufo/waves/round-28/build/XC2Measure-c2-base.json`. No tool installs were needed (none performed; pacman pause respected).

## Finding 1 — BASE silently ACCEPTS all four forged group lowerings (ACCEPTED 4/4, EXACT 0/4)

`python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 3553d499…bbf7b28 BASE .ufo/waves/round-28/build/XC2Measure-c2-base.json`
→ exit 0, printed `C2_MEASURE BASE: groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0`.
All four fixtures and the control print the identical line, exit 0:
`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.

Mechanism at BASE (all in `corpus/release-clock.py`):
- `evaluate` trusts derived anchors outright: `anchor_ok = is_derived or version_is_named(...)` (line 566,
  `is_derived = values["note"].startswith("derived:")` line 565) — a derived anchored_version is never
  compared to any pinned source.
- The regression check (lines 567–574, `is_regression` 383–388, `feed_floors` 390–411) only compares the
  observation against strict-X.Y.Z anchors on the same feed URL. Lowering every derived anchor on one feed
  together lowers that feed's floor to the same value, so the forged equal observation regresses against
  nothing.
- `not-fired` with `norm_version(observed)==norm_version(anchored)` (line 585) then counts the row valid and
  derived; receipt match (lines 425–456, esp. 444) compares only `parsed_version`/`verdict`, which the
  fixture mirrors exactly, so no RECEIPT-MISMATCH fires.
- Counterexample (G4, 1 row): S029 (`corpus/release-clocks.tsv:26`, anchor 8.23.0) rewritten to anchored
  8.22.0, observed 8.22.0, not-fired + mirrored receipt record → exit 0 CLEAN, `derived=15` unchanged.
  The clock's own declared newest-official-release fact in the note ("latest official release … 8.23.0") is
  never consulted.

## Finding 2 — G2/S034 shares its feed with non-derived S012; BASE still accepts

G2 lowers S013, S022–S024 (`release-clocks.tsv:10,19,20,21`) to 2.1.9 while S012 (`release-clocks.tsv:9`,
anchor `v1.21.x`, observed 2.2.0, fired) is untouched. BASE output: exit 0 CLEAN, `fired=3 derived=15` —
identical to control. S012 keeps firing because (a) `feed_floors` (390–411) skips its non-numeric `v1.21.x`
anchor, so the edited floor 2.1.9 < observed 2.2.0 never regresses, and (b) the fired verdict for S012 only
needs `observed != anchored` (line 582). I.e. the forgery is invisible next to a legitimately fired row on
the same feed; nothing in BASE ties derived anchors to the feed row's located anchor in SOURCES.md.

## Finding 3 — EXACT predicate defined generically (BASE has no derivation category)

Frozen predicate implemented per fixture: ACCEPTED = exit 0 ∧ last non-empty stdout line starts
`RELEASE_CLOCK: CLEAN`; EXACT = exit 1 ∧ no `Traceback` in stdout/stderr ∧ last line starts
`RELEASE_CLOCK: FAILED` ∧ ≥1 finding ∧ every finding line carries ≥1 id matching `S[0-9]{3}` ∧ union of
named ids == the group's ids exactly ∧ every finding line's category (text before its first id) is OUTSIDE
BASE's own categories {ORPHAN, UNBOUND, INCONSISTENT, BADFEED, REGRESSED, `NOT OBSERVED`, RECEIPT-MISMATCH}.
Rationale: BASE finding lines are `"<CATEGORY> <S-id>"` (`print_result`, release-clock.py:644–647); a future
derivation category must be a new token naming exactly the group, and any id-less line, foreign id, or
reused BASE category is not a typed derivation finding. Discrimination verified synthetically (sandbox,
this session): new-category lines naming exactly G1 → exact=True; `REGRESSED S008…S011` → False; group + S012
→ False; ValueError traceback → False; id-less line → False; CLEAN exit 0 → accepted=True, exact=False.

## Fixture mechanics (mirrors round-27 tools/c2-measure.py; L1 clarification 2026-10-21 applied)

Groups (frozen §C2): G1 S033 S008–S011→3.13.2; G2 S034 S013,S022–S024→2.1.9; G3 S035 S014–S016,S021,S025,S026→2.7.0;
G4 S037 S029→8.22.0. Per fixture: `git archive <rev> | tar` (read-only) into a temp clone; copy the clone's
`corpus/{SOURCES.md,source-fetches.tsv,rendered-text-v1.py}`; rewrite ONLY the group rows in
`release-clocks.tsv` (anchored=observed=lower, verdict not-fired; tool asserts each edited row is a
`derived:` row on the declared feed and that edited set == group); copy the revision's default receipt
(located generically via regex over the clone's `release-clock.py`; BASE: `.ufo/waves/round-26/observe-2.json`,
release-clock.py:497), mirror parsed_version+verdict for exactly the group records, pass with
`--receipt/--receipt-sha` and `--root <fixture>`; run the clone's own `corpus/release-clock.py`. Control:
unmodified tree, default command, cwd=clone. SOURCES.md and code are never edited by fixtures. Each run:
env {PATH, HOME=temp, LC_ALL=C, PYTHONDONTWRITEBYTECODE=1}, timeout 120s. Summary JSON format
`kagi-round28-c2-measure-v1` records argv, exit, stdout, stderr, findings, named_ids, edited/mirrored rows
per fixture.

## Commands run (all exit 0 unless stated)

- `mkdir -p …/sandboxes/XC2Measure/base && git -C <lane> archive 3553d499… | tar -x -C …/base` — BASE tree.
- `python3 -I -B c2-measure.py 3553d499… sandbox-BASE result-sandbox.json` (cwd=sandbox) → exit 0.
- `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 3553d499… BASE .ufo/waves/round-28/build/XC2Measure-c2-base.json` (cwd=lane root, frozen form) → exit 0.
- Synthetic classifier discrimination checks (eval cell, 6 cases) — outputs as in Finding 3.
- `jq` inspection of `result-sandbox.json` per-fixture exit/last_line/edited rows.
- `sha256sum` of BASE `corpus/release-clock.py` (53823416…36dc) and the installed tool.

## Numbers at BASE 3553d499577084a6c98d7078906017840bbf7b28

- groups_accepted_clean = 4/4 (G1 G2 G3 G4 all exit 0, CLEAN, fired=3 derived=15).
- derivation_exact = 0/4 (no derivation category exists at BASE; exit is 0, not 1).
- control_clean = True, default_exit = 0 (`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`).
- Frozen-plan after-target to be measured by L1 at integration: ACCEPTED → 0/4, EXACT → 4/4, control unchanged.

## What I did NOT check

- The after-world: I did not implement or measure the C2 gate itself; EXACT=4/4 is untested against a real
  derivation implementation (synthetic classifier checks only). L1's integration must re-run this instrument.
- I did not verify the derivation category name or line shape a future gate will print; the extraction is
  deliberately generic (any new category token + trailing S-ids).
- I did not re-verify SOURCES.md S033–S037 anchor cells' located versions (out of my scope; the instrument
  never reads SOURCES.md contents beyond copying it).
- I did not run the lane selftest or any gate in the lane checkout; no writes outside tools/c2-measure.py,
  build/XC2Measure{,-c2-base.json}.md/.json and my sandbox.
- Network/feeds untouched; all runs offline (`--receipt`, never `--observe`).
