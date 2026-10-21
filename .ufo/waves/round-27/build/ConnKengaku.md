# ConnKengaku — sibling-overlap scan: kengaku doc-number binding vs kagi knowledge-entry binding

Seat: `KagiR26.ConnKengaku-17` (connector, leaf, read-only). Lane-authored
advice for L1; not a judgment, admission, integration or non-author closure.

Revisions observed 2026-10-21T15:33Z (03:33 -03):

| repo | revision | note |
|---|---|---|
| kagi-shokunin | BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`; HEAD `144babcb892f0a30154880a9f94aa59ca8ddf9c5` | the round-27 draft landed while this scan ran; HEAD was still BASE at 12:24 and moved to `144babc` by 12:33. "After" below means `144babc`, not an uncommitted tree unless stated. |
| kengaku-shokunin | HEAD `df33fc837649` (short) | only `.ufo` wave files dirty at scan; cited code/docs equal HEAD. Cited at its own HEAD, not at kagi's BASE. |

Method: `git show <rev>:<path>` reads, `awk`/`sed` facts, and Python `re`
application of the committed `corpus/self-counts.tsv` locators to committed
blobs. **No gate, binder, selftest, clock, measure script, linter or formatter
was executed**, and no ledger row was run (pins were read from
`corpus/claim-ledger.tsv`). The static checks below are labelled as such; unrun
checks are not passes.

## Axes

- **Calibration (C1)** — knowledge-entry numbers bound to their live source; a
  one-digit mutation must turn `corpus/self-counts.py` STALE; stale values
  corrected with an old-value history clause.
- **Freshness (C2)** — a strict numeric observation below a numeric anchor is a
  typed `REGRESSED` finding, never fired/CLEAN.
- Secondary surfaces traced: **contract** (which lane owns a binding rule),
  **substrate** (which file defines a number), **verification** (the before/after
  overlay and its counts).

## 1. Boundary evidence — kengaku already solved two of C1's failure modes

Kengaku's binding instrument is lane-local, not fleet-owned. It is a *frozen
assertion registry*: stable assertion ids, a committed value token per id, and
append-only dated corrections that may supersede an id only when they restate
**every** token. The load-bearing lines (kengaku HEAD `df33fc837649`):

- `plans/state_check.py:20` — "An appended dated correction is SUPERSEDED only
  when its complete tokens re-derive the observed value."
- `plans/state_check.py:206` `SUPERSEDE_RE`; `:269-271`
  `P3_CORRECTION_LINE_RE` requires the dated form
  `- **R2x-E<n> (YYYY-MM-DD)** supersedes \`id\` — now \`tok\` \`tok\`…`.
- `plans/state_check.py:739` — a correction supersedes only when its tokens
  "restate the whole observed census exactly, never a cherry-picked fragment"
  (`exact = "; ".join(tokens) == observed`, `:743`).
- `plans/state_check.py:273` + `:1491-1505` — the **numeric-token audit**: every
  standalone integer in the asserted text that no declared field pattern claims
  is reported as unclassified. This is a *per-token* rule, not a per-line one.
- `plans/state_check.py:223` `P3B_SOURCES_MAX_ID = 42` and
  `PROVINCE.md:180` — the population is **frozen by bound**: "count
  `SOURCES.md` ids ≤42, not future additions". `SKILL.md:581-583` restates that
  later rows are out of the population.
- `PROVINCE.md:183-190` is the receipt that partial restatement is a real defect
  class, not a hypothetical: R26-E7/E8 were superseded by E9/E10 because a
  count-only restatement omitted the `id_set=exact` token.

What to reuse: the two *rules* — (a) a corrected number must carry the complete
token set, and every numeric token in the population must be classified; (b) a
count that additions can change is frozen by a declared population bound, never
stated as a live total. What **not** to reuse: the code-registry implementation
(ids and patterns live in `state_check.py`); kagi's `corpus/self-counts.tsv` is
table-driven and cheaper for the same job. Importing `state_check.py` would be a
second convention.

Non-ownership evidence: kengaku marks the gate as its own (`SKILL.md:567`, owner
column `kengaku`) and routes research method to chousa and fleet process to
protocol/aggregator (`PROVINCE.md:137,139`). No sibling claims live doc-number
binding as owned ground; the nearest sibling rules are self-consistency/review
rules, not binders (ConnSouji §C1: souji Q10, mori Q40/Q46). The fleet
`scripts/sources-census.sh:5-8` checks the source registry and citation chain,
not document numbers.

## 2. Kagi before and after, pinned

At BASE `0a47dd1`:

- `corpus/self-counts.tsv:1-13` — population is SKILL.md / PROVINCE.md /
  `corpus/README.md`; **38 data rows, zero `KN-*` rows** (`git show` count).
- `corpus/QUALITY.md:118` QM21 (a current-tense number is bound; a "round N" tag
  alone does not make it historical), `:120` QM23 (an `on-release` clock names
  one observable identity), `:126` QM24 (successor rearming is explicit).
- `corpus/knowledge/op-ref-consumption.md:296` still states "21" in the body
  while `:373` holds a correction note saying 36 elsewhere — the
  "correction-elsewhere" shape QM26 later names. `surface-census.md:5` ("9
  json") and `:76` ("16 published hashes") are the same shape with a trailing
  round-22 erratum at `:296`.
- `corpus/release-clock.py:524-528` — `fired` is `observed != anchor`; a lower
  release fires, and a lower `not-fired` row is `INCONSISTENT`.

At `144babc`:

- `corpus/self-counts.tsv` — 60 data rows, 22 `KN-*` rows over 8 knowledge files
  (`:58-79`); `SC-CLOCK-SELFTEST` `:22` and `PV-CLOCK-SELFTEST` `:38` bind the
  release-clock selftest count.
- The table **header still declares the round-25 population**
  (`corpus/self-counts.tsv:3-5`: SKILL/PROVINCE/README) although the table now
  binds knowledge entries. This is the internal contradiction ConnKumitate
  already reports; I corroborate it and do not re-propose it — it is a
  prerequisite for the move below, not the move.
- `corpus/QUALITY.md:133` QM26 (knowledge population; exclusions; repeated
  copies on a line tied with a backreference), `:132` QM25 (feed numeric floor).
- `corpus/lessons/round-27.md:37-53` §C1 (exclusion list at `:42-45`; "Bound: 22
  bindings over 8 entries" at `:53`), `:83-99` §C2 (feed floor; nine new
  selftest cases, 67→76).
- `corpus/README.md:219` — "now also binds **22** reviewed current-tense numbers
  in eight `knowledge/*.md` entries".

## 3. Do C1 and C2 stay in-lane?

**C1: yes.** Its production surface is kagi's own knowledge entries and
`corpus/self-counts.tsv`. Chousa owns research method, not lane-artifact
binding (`PROVINCE.md:67` at BASE); kengaku's instrument is lane-local; the
fleet census does not read doc numbers. Extending the existing table is
in-convention (ConnSouji reaches the same conclusion for souji/mori).

**C2: yes.** No sibling implements release ordering: a targeted scan of
`*/corpus/*.py`, `*/corpus/*.sh` and `*/plans/*.py` for
`norm_version|anchored_version|is_regression|REGRESSED` found no lane gate
outside kagi; the only other hits were wave-local files under
`kaidoku-shokunin/.ufo/waves/` (a red-before tool and a vendored standard-library
`platform.py`), not gates. The fleet census explicitly declines to
judge the cadence: `scripts/sources-census.sh:36` says symbolic cadences "(e.g.
on-release) are reported, never judged overdue"; `:28` only validates the
recheck syntax (E09). So `REGRESSED` is a lane-local strengthening of kagi's own
clock. Caveat: kagi's `corpus/SOURCES.md` rows S042/S043 must stay valid under
SOURCES-CONTRACT-v1 (`sources-census.sh:5-8`); I did not run that census.

**Boundary exception — C1/C2 are not file-disjoint at the doc layer.**
`plans/round-27.md:39-41` says "C1 and C2 touch disjoint production files
(knowledge entries + self-counts table vs release-clock code/selftest)". But
`SKILL.md:48` and `PROVINCE.md:54` are C1-bound rows (`self-counts.tsv:22,38`)
whose value C2 changes: 67 at BASE (`0a47dd1`), 76 at `144babc`. Any
before/after overlay of the after table on BASE docs therefore reports those two
rows STALE for a C2 reason, and C2 could not land without editing two documents
in C1's population. The sentence is file-true but number-false; the accounting
should say so (or the two rows should be named as the shared bookkeeping).

## 4. Counterexamples (static; each would survive the binder at `144babc`)

Method: applied every one of the 60 committed locators to the committed blobs of
`144babc` (the files hash-match the working tree I read: `README.md`
`f3d13674…`, `self-counts.tsv` `67d5d1db…`, `adjacency-scope.md` `d617510…`),
then checked whether a one-digit change still falls under some locator.

- **CX1 — the binder's own population count is unbound and self-referential.**
  `corpus/README.md:219` says "binds 22 reviewed current-tense numbers". No row
  of the 60 matches that line; `22→23` leaves every row clean, so the binder
  prints `SELF_COUNTS: CLEAN`. README is in the round-25 population already
  (`self-counts.tsv:3-5`), so this one does not depend on the `KN-*` extension.
  It is also the one number the binding act itself changes: the moment any
  `KN-*` row is added (including for CX2/CX3), "22" becomes false with no gate
  noticing. Kengaku's answer to this exact shape is
  the frozen bound (`P3B_SOURCES_MAX_ID = 42`, `PROVINCE.md:180`), not a live
  total.
- **CX2 — a bound quantity restated on another line of the same entry.**
  `corpus/knowledge/adjacency-scope.md:298` (`SCOPE_SELFTEST: PASS (61 cases)`)
  and `:299` (`SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`) sit in the
  undated `## Evidence` section (`:293`). The same quantities are bound at
  `:16-17` (current-gates clause) and `:155` (verdict table); the `KN-*` rows
  match only those lines. A one-digit mutation at `:298` or at the denominator
  of `:299` is invisible. This is not a scope demand for a complete digit
  census: it is the *same quantity, same document, same tense*, bound twice and
  unbound once.
- **CX3 — a round-tagged baseline that is still current.** QM21
  (`QUALITY.md:118`) says "A 'round N' tag does not make a number historical;
  only an explicit history clause with a newer value beside it does."
  `corpus/knowledge/checklist-execution.md:82` says "Baseline at the round-15
  revision: `runnable=9/16 floor=8 by_hand=7`" with no newer value beside it,
  and those values are still the live ones (R15-01 `items=16 runnable=9
  by_hand=7`; R15-05 `runnable=9/16 floor=8 by_hand=7`). No row matches `:82`
  (rows match `:63`, `:173`, `:179`), so a mutation there is invisible. Today
  the numbers are correct, so this is a disposition gap, not a stale value —
  but the lesson's "Round-N findings history" exclusion is being applied to a
  baseline figure that QM21's own wording puts in population.
- **CX4 (C2, stated contradiction) — the frozen plan's limit is narrower than
  the landed rule.** `plans/round-27.md:29-32`: "when both anchor and
  observation are numeric X.Y.Z … non-numeric anchors keep the inequality rule
  as a declared limit." `corpus/release-clock.py:369-397` `feed_floors` orders a
  non-numeric-anchor row against the highest numeric anchor on the same feed
  URL, applied at `:567-574` and `:616`; the selftest has both
  "feed floor lifts non-numeric anchor" (REGRESSED) and an honest
  "non-numeric anchor keeps inequality" control. `QM25` (`QUALITY.md:132`) and
  the lesson (`round-27.md:92-93`) state the feed floor correctly. Live instance:
  `corpus/release-clocks.tsv:9` S012 (`v1.21.x`) shares
  `https://github.com/hashicorp/vault/releases.atom` with four `2.2.0` anchors
  (`:10,19-21`), so its floor is 2.2.0; an observation of 2.1.0 would be
  REGRESSED through the floor, not "inequality". The row's own-anchor comparison
  is still inequality-only, which is probably what the plan meant, but the
  sentence as written is false and a reviewer measuring C2 against the plan sees
  an undeclared scope extension. Resolve by an appended plan/lesson amendment,
  not by weakening the code (the floor closes the un-fire the plan's own
  counting command needs).

Also checked and **not** findings: the dated `## Reproduction (2026-09-28/29)`
blocks and `Source basis …` headers (adjacency-scope:250, drift-gate:167,
surface-census:243), the `## Erratum` sections, and the round-history clauses
(`claim-ledger.md:6`, `op-ref-consumption.md:297,373-379`) are excluded by the
lesson's declared classes and are correctly left unbound. `surface-census.md:76`
"9 of 15 rows" is a subset count with no available `rows:` source and is a named
unbindable, not a gap. `checklist-execution.md:63` and the `KN-*` anchor/back-
reference rows (`self-counts.tsv:59,61,63,68`) do constrain same-line copies;
CX2/CX3 are cross-line, which those rows cannot see.

## 5. Proposed move (one rule, bounded)

**Adopt kengaku's two binding rules in kagi's existing table, with no new gate
and no code change: bind the quantity at every in-population occurrence, and
state the population's own size as a frozen bound.**

Concretely, at the C1 landing:

1. Add `KN-*` rows for the two cross-line copies in CX2 — locator anchored to
   the `## Evidence` bullets (`^- \`--selftest\` ⇒ \`SCOPE_SELFTEST: PASS \(([0-9]+) cases\)`;
   and the `^  \`SCOPE_FALSIFY: PASS \(caught=([0-9]+)/\1 failed=0\)` line), sources
   `ledger:R16-02` and `expect:R16-03` respectively (R16-03 is host-tagged, so
   the committed pin, never an execution). No new source kind, no selftest case,
   no doc behaviour change.
2. Give CX3 an explicit disposition: either bind `runnable`/`floor` to R15-05
   (extract `runnable=([0-9]+)/`, `floor=([0-9]+)`) and the item count to
   R15-01/`rows:corpus/checklist.tsv`, or restate the sentence with the current
   value beside the round-15 one (QM21's history-clause form) and name it out.
3. Restate `corpus/README.md:219` (and the matching lesson sentence,
   `round-27.md:53`) as a frozen population: "22 bindings entered round 27 (the
   `KN-*` set at that revision; later additions are not counted here)", the
   shape kengaku uses at `PROVINCE.md:180`. Do **not** bind a live `KN-*`
   count: the row that binds it changes it, so it would be stale as soon as it
   is written. If a number is kept, it must be the frozen one.
4. Make the exclusion list reason-shaped, not heading-shaped: the lesson's
   `:42-45` list groups "Evidence / Erratum / Round-N findings history". If a
   `## Evidence` section is meant to be out of population, say that; if only
   *history* is out (as the wording implies), CX2 is in and step 1 applies.
   Either disposition closes the ambiguity; silence leaves the same sentence
   both excluded and unbound.

Why this and not a second convention: the rule is exactly kengaku's
per-token/complete-restatement discipline (`state_check.py:20,273,739`) and
frozen population (`:223`, `PROVINCE.md:180`), applied through kagi's table. It
does not import kengaku's registry, does not add a gate, and does not change any
live verdict. The three items are the complete set of undated, non-history,
non-positional quantity occurrences I could find outside the bound population;
everything else I found is covered by a declared exclusion (see §4).

Affected axes: **calibration** improves (three currently invisible one-digit
mutations become either STALE or explicitly out of population; the round stops
introducing a count that its own next change falsifies). **Freshness** untouched
(no `release-clock.py`/`release-clocks.tsv` change; CX4 is a text amendment
only). Operability untouched (no new gate, no selftest count change, no ledger
row count change to any doc number). Contract/adjacency untouched (reuse, not
ownership).

## 6. Risks

- **Header prerequisite.** `corpus/self-counts.tsv:3-5` still defines the
  population as SKILL/PROVINCE/README. Until that is fixed (ConnKumitate's
  finding), step 1's rows are out of population by the table's own header. The
  two changes must land together or the table argues with itself.
- **AMBIGUOUS.** A locator must match exactly one line; `self-counts.py` counts
  zero matches as UNLOCATED and more than one as AMBIGUOUS, both exit 1. The
  `## Evidence` bullets are unique today, but a future blockquote or duplicated
  bullet would turn the row AMBIGUOUS rather than silently wrong — fail-closed,
  but noisy. Anchor to the bullet's literal prefix, not the bare verdict token.
- **The lesson is a receipt.** It already says "22 bindings over 8 entries"
  (`round-27.md:53`); editing it in place rewrites a round record. Use an
  appended correction line (kengaku's form, `state_check.py:269-271`) and keep
  the old sentence as history.
- **Freezing "22" loses a live check.** A frozen count no longer detects a
  dropped row. That is the accepted trade in kengaku (`ids ≤42` is a bound, not
  a live total); if L1 wants a live check, it needs a new source kind
  (`rows:` cannot count a prefix), which is the code change this move avoids.
- **CX4 is not fixed by this move.** The plan/C2 wording contradiction stands
  until L1 appends the amendment; a reviewer may otherwise score C2's scope
  against a sentence the code no longer implements.

## 7. Verification left to L1 (all unrun by me)

1. After steps 1-3: `python3 corpus/self-counts.py` → exit 0
   (`SELF_COUNTS: CLEAN (claims=<60 + rows added> …)`; the total is not stated
   in any doc, so it needs no rebind).
2. Mutation, on a scratch copy: `adjacency-scope.md:298` `61→60` must print
   `STALE KN-SCOPE-EVIDENCE-SELFTEST`; `:299` `18/18→18/19` must print STALE or
   UNLOCATED; `README.md:219` `22→23` must be out of population only after the
   phrasing is frozen (state which of the two outcomes is intended).
3. `python3 corpus/self-counts.py --selftest` — still 48 cases (no code change;
   if any case is added, `SC-SELFCOUNTS-SELFTEST`/`PV-SELFCOUNTS-SELFTEST` and
   the two doc copies must move in the same landing, ConnSouji CX2).
4. C1 overlay: after table over BASE docs → exit 1 with the expected stale set;
   over `144babc+edits` docs → exit 0. Do not compare stale counts without
   naming the two C2-induced rows (`SKILL.md:48`, `PROVINCE.md:54`).
5. C2 untouched: `python3 corpus/release-clock.py` default receipt still
   `RELEASE_CLOCK: CLEAN (on_release=30 …)`; `--selftest` equals the number in
   `SKILL.md:48`/`PROVINCE.md:54` (76 at `144babc`). I did not run either.
6. If CX4 is amended: confirm the amended sentence matches
   `release-clock.py:369-397` and `QUALITY.md:132`, and that the S012 row still
   reads `fired` under its own inequality (its own anchor is non-numeric; the
   floor is equal at 2.2.0, `release-clocks.tsv:9`).

## 8. What I did not check

- I did not run `corpus/self-counts.py`, `corpus/release-clock.py`, any
  `--selftest`, `--falsify`, `--observe`, the C1/C2 counting commands, or
  `c1-before.json`/`c1-after.json` (their existence was observed, not trusted).
- I did not execute ledger rows; I read the pins in `corpus/claim-ledger.tsv`.
  Whether R16-02/R16-03/R15-01/R15-05 pass on this host is unverified.
- I did not audit the full sibling fleet. I read kengaku `PROVINCE.md`,
  `SKILL.md`, `plans/state_check.py` and `plans/round-27-claims.md` header; I
  read the four peer connector reports for overlap; I name-grepped
  `*/PROVINCE.md`, `*/SKILL.md`, `*/corpus/SOURCES.md`, `*/corpus/*.py`,
  `*/corpus/*.sh`, `*/plans/*.py`. I did not scan lane `corpus/knowledge/`
  trees, `.ufo` evidence, or the large `audio-`/`game-dev-`/`kaidoku` runtime
  copies. Absence of a hit there is not a pass.
- I did not open the public S042/S043 URLs or re-derive their quotes; I read the
  registry rows and the lesson's capture claims only. I did not run
  `corpus/sources-census.sh` over the new rows.
- I did not verify `corpus/lessons/round-27.md`'s "nine new selftest cases
  (67→76)" by counting executions; I counted `run_case(` call sites statically
  (7 at four-space indent, plus loop-driven cases visible only by reading). The
  live count is only established by the selftest L1 runs.
- Kengaku is cited at its HEAD `df33fc837649`; I did not read its lessons,
  evidence or its own round-27/28 wave state. Its frozen population is
  understood from `state_check.py` and `PROVINCE.md`, not from an executed run.
- The working tree moved twice during the scan (BASE → `144babc`; kengaku
  `18b1922` → `df33fc83`). Findings in §4 are pinned to the hashes quoted
  there; a later edit can invalidate them without invalidating this text.
