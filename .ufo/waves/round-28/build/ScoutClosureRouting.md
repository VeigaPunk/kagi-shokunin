# ScoutClosureRouting — kagi r25/r26/r27 closure routes vs the frozen r28 plan

Read-only. Sources: `/home/vgpnk/Projects/shokunin/MANIFEST.json` rounds[410] (r25, lines 10748–10803),
rounds[419] (r26, 11395–11471), rounds[425] (r27, 11787–11882); `plans/round-28.md` at bdf90f5→b9a42c0;
BASE `3553d499577084a6c98d7078906017840bbf7b28` tree in
`.ufo/waves/round-28/sandboxes/ScoutClosureRouting/`. Lane checkout not modified or run.

## Findings

**F1 (freshness+calibration, high) The frozen fixture text cannot produce F1's MISHANDLED or G1..G4's ACCEPTED before-states.**
`plans/round-28.md:32-33,61-66` fixes F1/F2/G1..G4 as table edits ("release-clocks.tsv edits only") and
predicts before→after MISHANDLED k/4→0/4 and TYPED→4/4 (C1), ACCEPTED k/4→0/4 and EXACT→4/4 (C2).
At BASE, F1 exactly as written (S040 `observed_version=3.15.01`, `verdict=fired`, anchor left 3.15.1) gives
`RECEIPT-MISMATCH S040`, exit 1, fired=3 — not MISHANDLED.
G1 exactly as written (S008–S011 → 3.13.2, observed equal, not-fired) gives four `RECEIPT-MISMATCH`,
exit 1 — not ACCEPTED. Because RECEIPT-MISMATCH is itself a typed, row-naming exit 1, F1 at BASE counts as
TYPED rather than MISHANDLED and a C1 fix keeps the same exit/type, so C1's delta is not measurable table-only;
for G1 the receipt error removes the exit-0 premise, so "stays CLEAN" is not shown without mirroring (a C2
EXACT result after the fix would still be reachable). Cause: the receipt check is unconditional and compares
verdict/parsed_version (BASE `corpus/release-clock.py:425-455,606-612`), against a SHA-pinned default receipt
(`:28,1744-1747`).
Mirroring the edited rows into a receipt copy (the b9a42c0 correction) makes BASE F1 `CLEAN ... fired=4`
exit 0 and G1 `CLEAN ... derived=15` exit 0. So the correction is necessary for F1 and G1..G4 (F2, F3 and
F4 measure without it), but it is a post-freeze change to the fixture protocol (see R3), and those frozen
before/after numbers are not checkable from the frozen text. [Observed by execution; not an inference.]

**F2 (freshness) `>4300-digit ValueError` is real and C1 targets it.** F2 table-only run (S040 `observed_version=3.15.`+4301×`1`) exits 1 with
`ValueError: Exceeds the limit (4300 digits)` at `corpus/release-clock.py:380`, no `RELEASE_CLOCK` line; host CPython 3.14.8, int limit 4300.

**F3 (freshness) Leading-zero release event is real and C1 targets it.** F1 with mirrored receipt gives
`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)` exit 0; the
fired branch compares version strings (`corpus/release-clock.py:582`), so `3.15.01` ≠ `3.15.1` fires.

**F4 (calibration) Derived-anchor forgery is real and C2 targets it.** G1 with mirrored receipt gives
`CLEAN ... derived=15` exit 0; the bypass is `anchor_ok = is_derived or version_is_named(...)` at
`corpus/release-clock.py:566`. All 15 `derived:` rows and their four feed rows match the plan's groups
(`corpus/release-clocks.tsv:5-26`; `corpus/SOURCES.md:39-43`), and each S033–S037 anchor cell names exactly
one version, so the unmodified control stays CLEAN30 (run, exit 0).

**F5 (freshness) C1's anchor leg has no fixture.** `plans/round-28.md:21-22` requires a version token used
for an *anchor* to be canonical/bounded, but F1–F4 exercise table observations (F1/F2) and feed entries
(F3/F4) only. Counterexample at BASE: S008 derived `anchored_version=observed_version=3.13.03`, not-fired,
mirrored receipt → `CLEAN ... derived=15` exit 0. Either C1 canonicality or C2 feed binding would catch it
after the fix, but the frozen set does not measure the anchor leg.

**F6 (freshness) `branch-scoped rows` debt is not addressed.** `corpus/lessons/round-27.md:113-117`: the
feed floor assumes every row on a feed observes that feed's global max-stable; a 3.11 security-release row
on python.org would be wrongly REGRESSED. `feed_floors` (`corpus/release-clock.py:390-410`) is untouched by
either claim; C2 only adds an anchor-binding rule.

**F7 (calibration) `X.Y zero-padding` debt is not addressed.** `corpus/SOURCES.md:50` says the PyPA padding
rule is "NOT implemented"; `numeric_version` (`corpus/release-clock.py:369-380`) still refuses `3.15`/`3.15.0`
equivalence. C1 forbids multi-digit leading zeros; that is a different rule.

**F8 (calibration, inference) C2 wording is substring-bound.** The plan says "the version named by its
`feed_source_id` registry row's located anchor"; the existing primitive is `version_is_named`
(`corpus/release-clock.py:340-346`), a regex over SOURCES `cells[5]` (`:88`). Today each S033–S037 cell names
one version (S037's cell also carries date `2026-12-09`, not dotted), so no current false accept is shown;
an anchor cell naming two versions would accept either. [INFERENCE; not a current counterexample.]

## Routed items for round 28 (verbatim; JSON index; plan coverage)

- **R1 rounds[425].notes** (`MANIFEST.json:11880`): "(1) no round-27 start census run (prompt §2) — disclosed,
  before reference is the base-committed r26 end receipt; run and retain the start census next round."
  **ADDRESSED.** `.ufo/waves/round-28/census-start.txt:1-14` (timestamp 13:38:30-03:00, exit=0, 11 W04
  lines counted), committed in bdf90f5 (13:44:04-03:00) before any code/tool.
- **R2 rounds[425].notes** (`:11880`): "(2) plans/round-27.md first committed with candidate 144babcb, not
  before work; the 'frozen declaration' has no pre-work commit — freeze claims in a separate commit next
  round." **ADDRESSED in form.** `git diff --name-only 3553d49 HEAD` → only `plans/round-28.md` and
  `.ufo/waves/round-28/census-start.txt`; bdf90f5 is a separate pre-work commit. Caveat: HEAD plan ≠ frozen
  commit (b9a42c0 appended 10 lines; see R3).
- **R3 rounds[425].notes** (`:11880`): "(3) C2 scope widened in-round (feed floor/observe floor) via appended
  plan corrections; accepted because the frozen counting command still holds and the change is stricter."
  **NOT ADDRESSED — RECURRED.** Frozen `plans/round-28.md:61` says "release-clocks.tsv edits only"; b9a42c0
  (14:06:45, after bdf90f5) appends `plans/round-28.md:93-101`: "F1, F2 and G1..G4 therefore mirror their
  edited rows into a copy of the default receipt and run with `--receipt <copy> --receipt-sha <its sha256>`"
  — a second edited file per fixture and a redefinition of "edits only", not a strictness increase. The
  correction is also what makes F1's MISHANDLED and G1..G4's ACCEPTED before-states measurable (F1).
  `tools/` is still empty; the dispatch files (`.ufo/waves/round-28/build-dispatch.json` mtime 13:47)
  predate the 14:06 plan change.
- **R4 rounds[425].notes** (`:11880`): "Named debts (derived-anchor forgery, leading-zero equality,
  >4300-digit ValueError, branch-scoped rows, X.Y zero-padding) stay open." Coverage: derived-anchor forgery
  → C2 (`plans/round-28.md:46-58`); leading-zero equality → C1 (`:15-27`); >4300-digit ValueError → C1;
  **branch-scoped rows → no**; **X.Y zero-padding → no** (F6/F7).
- **R5 rounds[410].notes** (`MANIFEST.json:10801`): "Routed D1: ... S036 present-tense newest-stable wording
  is now stale; next round append a dated correction/superseding source row and refetch/reobserve S027/S028
  with a new receipt." **NOT addressed by this plan** (C1/C2 are offline; no observe/refetch), but discharged
  in r26: `corpus/SOURCES.md:46` S039 supersedes S036, observed 3.15.1. No r28 action outstanding.
- **R6 rounds[410].notes** (`:10801`): "D2: C1 intentionally excludes complete digit/corpus coverage;
  remaining knowledge-entry and checklist-count debts must not be pronounced covered by CLEAN38. Shared
  shallow .ufo namespaces cannot prove lane ownership; deeper owned-path controls are red."
  **NOT addressed.** No CLEAN38/complete-coverage claim appears in the plan (no violation), but ownership
  and owned-path control debt is untouched.
- **R7 rounds[419].verification.conformance_debt** (`MANIFEST.json:11465`): "Some BUILD seats ran normalizer
  selftests despite mid-flight restriction (disclosed, uncredited); late redundant MISSION/AXES reload
  disclosed; no whole-round no-tests attestation. Fleet-layout citation check reads live siblings (dated,
  not frozen). Executed-at-final claims rest on measured-revision receipts; measured->final changes are
  outcome metadata/stamps only." **NOT addressed**; `plans/round-28.md:87-89` asserts no host-private reads
  but defines no check. Status-neutral, carried.
- **Not routes:** rounds[425].verification.routed_checks `followup_batch`/`dead_seats` (`:11842-11843`) target
  candidate 144babcb; rounds[419].notes (`:11469`) has no round-28 instruction; `no_start_census` (`:11840`) restates R1.

## Commands run (all in my sandbox; lane untouched)
- `git show --stat bdf90f5`; `git diff --stat 3553d49 bdf90f5` → plan+census only (105 insertions), exit 0.
- `git diff --name-only 3553d49 HEAD` → same two paths, exit 0; `git log bdf90f5..HEAD -- plans/round-28.md`
  → b9a42c0 only, exit 0.
- BASE copy `python3 -I -B corpus/release-clock.py` → `CLEAN (... on_release=30 ... fired=3 derived=15)`, exit 0.
- f1 table-only → `RECEIPT-MISMATCH S040`, exit 1; f1 mirrored → `CLEAN ... fired=4`, exit 0.
- g1 table-only → 4×`RECEIPT-MISMATCH` (S008–S011), exit 1; g1 mirrored → `CLEAN ... derived=15`, exit 0.
- f2 → ValueError traceback at `:380`, exit 1, no `RELEASE_CLOCK` line; d1 (anchor `3.13.03`, mirrored)
  → `CLEAN ... derived=15`, exit 0; `int('1'*4301)` probe → ValueError (limit 4300, host 3.14.8).
  `census-start.txt` read: exit=0, 11 W04 (counted; census not run by me).

## What I did NOT check
- Did not run lane gates/selftests in the lane checkout; `c1-measure.py`/`c2-measure.py` do not exist yet
  (`tools/` empty), so the frozen counting commands are unverified.
- Did not fetch live feeds or re-open S033–S037; anchor claims are from BASE bytes only.
- Did not verify r25/r26/r27 reports or receipts beyond the MANIFEST rows; no host-private/vault/CDP contact.
- Did not audit whether BUILD seats already used the pre-correction fixture text.
- No tools installed. Repo state as of HEAD b9a42c0 (14:06:45); later concurrent changes not tracked.
