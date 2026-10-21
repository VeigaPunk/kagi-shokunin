# Round 28 — release-clock version tokens are canonical and total; derived anchors are bound to their feed rows

Frozen BASE: `3553d499577084a6c98d7078906017840bbf7b28` (round27 admitted, fleet
MANIFEST rounds[425]; local=remote, ahead0, clean tree). This file is committed
BEFORE any round-28 work (closure-routed: round27's plan first landed together
with its candidate code). START census ran first and is retained at
`.ufo/waves/round-28/census-start.txt` (exit 0, 11 W04; closure-routed: round27
had none).

All six axes sit at 9. The last capability entered round25; with window3 the
stagnation nudge needs three completed rounds without one (26, 27, 28), so it
cannot fire before round29 and is not claimed. Both claims below work the
lane's owned, tied-lowest axes.

## C1 — freshness, 9 → 9 (sourced; round27 named debt "leading-zero equality" and ">4300-digit ValueError")

`corpus/release-clock.py` accepts any `[0-9]+` component: a leading-zero token
such as `3.15.01` is string-unequal to anchor `3.15.1` and reads as a fired
release, and a component longer than CPython's integer-string conversion limit
raises an untyped ValueError traceback. After: a version token used for an
anchor, a table observation or a feed entry must be canonical (no leading zero
in a multi-digit component, SemVer S042 §2) and bounded; otherwise the row or
feed gets a typed finding (exit 1), never a release event and never a
traceback. Sourced: at least one registry row opened this round (Python
integer-string conversion limit documentation) is cited by the lesson entry.

Frozen counting command (written this round, then never changed):

    python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out.json>

Frozen fixture set, built on `<rev>`'s own tree:
- F1 table lie: S040 `observed_version=3.15.01`, `verdict=fired`.
- F2 table oversize: S040 `observed_version=3.15.` + 4301 × `1`, `verdict=fired`.
- F3 observe leading zero: `--observe` over a local copy of the python.org feed
  whose newest stable item is titled `Python 3.15.01`.
- F4 observe oversize: the same with a 4301-digit patch component.
- Control: the unmodified tree, default command.
Predicate: a fixture is MISHANDLED when it exits 0 with `RELEASE_CLOCK: CLEAN`
(or a written fired observation) or when its output contains `Traceback`; it is
TYPED when it exits 1, prints no traceback and names a typed finding for the
fixture's row/feed. Before (BASE) → after: MISHANDLED k/4 → 0/4, TYPED → 4/4;
control `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30
fired=3 derived=15)` exit 0 at both; clock selftest count grows only by new
cases.

## C2 — calibration, 9 → 9 (round27 rejected-as-limit CritFinalC2 #1, flip "draft A")

Fifteen release-clock rows carry author-declared `derived:` anchors. They are
trusted: lowering every derived anchor on one feed together with a matching
forged observation stays CLEAN (feed floors only compare rows with each other).
After: a `derived:` row's anchored version must be the version named by its
`feed_source_id` registry row's located anchor in `corpus/SOURCES.md` (the feed
row S033–S037 that the clock already loads); a mismatch is a typed finding
(exit 1). The declared value is bound to its pinned source, as QM21 binds
numbers.

Frozen counting command:

    python3 -I -B .ufo/waves/round-28/tools/c2-measure.py <rev> <label> <out.json>

Frozen fixture set (release-clocks.tsv edits only; SOURCES.md untouched): per
feed carrying derived rows (S033 SOPS: S008–S011; S034 Vault: S013, S022–S024;
S035 OpenBao: S014–S016, S021, S025, S026; S037 curl: S029), lower every
derived anchor on that feed to the same lower canonical version and set its
observed version equal, verdict `not-fired` — G1..G4. Predicate: ACCEPTED when
exit 0 `RELEASE_CLOCK: CLEAN`; EXACT when exit 1 and the typed derivation
findings name exactly that group's row ids. Before → after: ACCEPTED k/4 → 0/4,
EXACT → 4/4; control default CLEAN30 exit 0 at both.

## Frontier step (inside the cap, not a claim)

- Curate `corpus/SOURCES.md`; rows only for sources opened this round, Gate in
  `corpus/lessons/round-28.md`.
- Mine a mistake: round27's conformance defects (no START census; plan first
  committed with candidate code; frozen C2 scope widened mid-round). Fix must be
  shown able to fail (a check that fails on round27's history and passes on
  round28's).
- START census retained; END census run and pasted with exit codes.

## Boundaries

C1 and C2 change different functions of one file (token canonicality vs
derived-anchor binding) and share bookkeeping (selftest count bound by
SC/PV-CLOCK-SELFTEST, stamps, ledger pins). Separability is executed by
claim-only overlays, not asserted. L1 holds the planner seat and is the sole
production integrator; seats write only their own reports/sandboxes under
`.ufo/waves/round-28/`. No host-private reads, no vault/account/handler/CDP
action, no Git/jj mutation by seats. Plan corrections, if any, are appended
below this line and never rewrite the frozen text or the counting commands.

## Plan corrections (appended during the round)

- (L1, during BUILD, before any measurement tool or patch exists) Fixture
  construction clarification, not a widening: the default receipt pins every
  table row's observation, so a table-only edit ends `RECEIPT-MISMATCH` and
  would never measure the targeted behaviour. F1, F2 and G1..G4 therefore
  mirror their edited rows into a copy of the default receipt and run with
  `--receipt <copy> --receipt-sha <its sha256>`, exactly as round27's
  `c2-measure.py` built its fixtures ("table + receipt"). "release-clocks.tsv
  edits only" in §C2 means: SOURCES.md and code are never edited by a fixture.
  Command lines, fixture ids, values and predicates are unchanged.
