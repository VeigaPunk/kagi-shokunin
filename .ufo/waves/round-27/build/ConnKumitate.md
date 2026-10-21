# ConnKumitate — sibling-overlap scan: kumitate source/tooling checks vs kagi C1/C2

Seat: `KagiR26.ConnKumitate-17` (connector, leaf, read-only). BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b` (`git rev-parse HEAD` observed equal;
the working tree carries L1's uncommitted round-27 draft, cited as **wt**).
Kumitate is cited at its own HEAD `2fa28e5` — it is a sibling, not part of this
BASE. No gate, binder, clock, selftest, ledger row or `c2-measure.py` was run;
every behavioural statement is a static reading, and the one numeric overlay was
a Python `re` count over `git show BASE:<doc>` (it executed no row). Lane-authored
advice, not a judgment or closure.

Axes judged: **calibration** (primary), **freshness** (primary). No claim on
operability, contract, substrate or verification beyond the bookkeeping named
below.

## Verdict

1. **C1 and C2 stay in-lane.** No sibling owns kagi's knowledge-entry numbers,
   `corpus/self-counts.tsv`, `corpus/release-clocks.tsv`, the receipt bundles, or
   the `on-release` judgment. Kumitate's source checks are self-scoped to its own
   `corpus/SOURCES.md` + knowledge entries; the fleet SOURCES contract is
   *implemented per lane*, not owned by kumitate. There is no file overlap and no
   shared write surface.
2. **One second-convention defect at the seam.** `corpus/release-clock.py` reads
   the same registry the census gates, but with a narrower id grammar
   (`S[0-9]{3}`, BASE `:29`) and without the `## Registry` section scope that the
   fleet contract (`scripts/sources-census.sh:24,30`), kumitate
   (`scripts/sources-check.mjs:11-14`) and kagi's own census
   (`corpus/sources-census.sh:170`, `:25-31`) all enforce. A future valid
   on-release row (`S1000+`) or a row-shaped line outside `## Registry` can be
   silently invisible to — or falsely consumed by — the clock. Latent today (no
   such row exists, S001–S043); this is the proposed move.
3. **C1's own declaration is internally contradictory.** The binding table's
   header still says the population is SKILL.md / PROVINCE.md / `corpus/README.md`
   (`corpus/self-counts.tsv:3-5`, unchanged from BASE), while wt `SKILL.md:47`
   and wt `PROVINCE.md:53` include reviewed `corpus/knowledge/*.md` lines, and the
   18 KN rows append a *second* exclusion list (`corpus/self-counts.tsv:53-57`).
   Two population statements, one stale.
4. **The C2 critics' two counterexamples are addressed in the 12:28 wt code**:
   `feed_floors` (wt `corpus/release-clock.py:390-410`, wired at `:567-568`)
   gives S012 the Vault URL's 2.2.0 floor and S027/S028 the python.org 3.15.1
   floor; the recorded-observation floor at `:793-794` catches the return-to-
   anchor un-fire at fetch time. The remaining C2 issues are calibration of the
   text/evidence and one precision ordering, already owned by the C2 critics
   (`CritC2Rollback.md:16-20,62-77`; `CritC2NonNumeric.md:64-105`); I add the
   sibling-vocabulary lens and the registry-reader move, not a duplicate floor
   proposal.

## 1. Boundary evidence (who owns what)

Kumitate, at HEAD `2fa28e5`:

- `PROVINCE.md:3` — domain "orchestration & tooling — scopes OMP task/hub,
  ufo-fsd scripts & runtime"; nothing about secrets, credentials or release
  clocks.
- `PROVINCE.md:12-15` — Core: the origin script/runtime layers and the Kimi
  substrate, gated by `scripts/claims-check.mjs` / `proxy-check.mjs` /
  `kimi-census.mjs`; **its own** instruments and **its own** learning registry
  (`corpus/SOURCES.md`, checked by `scripts/sources-check.mjs`).
- `PROVINCE.md:26` — Adjacent: "MCP/OAuth security practice … → kasegi / kagi."
  It routes *to* kagi; it claims no kagi ground.
- `SKILL.md:587-606` — gate registry: `claims-check` reads its own `SCORECARD.md`
  registry cells; `sources-check` is an independent gate over its own
  `corpus/SOURCES.md` + legacy identity set; `anchor-truth` pins its own
  registered notes at the `.ufo/pins/origin.json` revision.
- `scripts/sources-check.mjs:6-8` — "Reads only `corpus/SOURCES.md` and direct
  `corpus/knowledge/*.md` entries. It does not use the network…" — no kagi path.
- `scripts/sources-check.mjs:10-14` — the fleet `sources-census.sh validate`
  correspondence: E01 `| S[0-9]{3,} |` row with split-field count != 13, E02 id
  not `S[0-9]{3,}`, E12 row outside `## Registry`.
- `scripts/sources-check.mjs:306-338` — recheck split: ISO date or `NNd` cadence
  can be `RECHECK_OVERDUE` (warn); `on-release` is accepted as a valid cadence
  and **never** judged overdue. The fleet header says the same in words:
  `scripts/sources-census.sh:34-37` — "symbolic cadences (e.g. on-release) are
  reported, never judged overdue."
- `scripts/anchor-truth.mjs:34-47` — the pin contract: one expectation per
  anchor (`true` / `unchecked` / `debt:*`), and the typed findings
  `REGRESSED` (`:41`, a dead doc anchor), `ANCHOR_SET_CHANGED` (`:42`),
  `DEBT_STALE` (`:43`), `DEBT_GREW`/`CHECKED_SHRANK` against `--base` (`:45-46`),
  `PIN_REGRESSION` on re-pin (`:47`). Its own header (`:5-9`) records *why*:
  a ratchet whose ceiling equals current debt passed a forward shift of 123
  anchors and a reset that re-broke 62 true anchors in rounds 36–37.

Kagi, at BASE (wt noted where the round-27 text differs):

- `PROVINCE.md:52-55` — `claim-ledger` (calibration gate), `self-counts`
  (round-25 population: SKILL/PROVINCE/README; wt `:53` adds reviewed
  `corpus/knowledge/*.md`), `release-clock` (wt `:54` adds the round-27
  `REGRESSED` rule), `sources-census` (fleet v1 over the lane registry).
- `PROVINCE.md:67` — Adjacent: "chousa owns the research method…; chousa, kasegi
  and kumitate run their own secret-shaped tripwires over their outputs (hygiene
  filters, not vault ops)". Kumitate is adjacent for *hygiene*, not source
  checks and not release clocks.
- `corpus/self-counts.py:20-27,226-252` — the binder's command policy: ledger
  commands are reviewed repo inputs, first-token allowlist, no inline
  bash/python, no recursive self-counts, **release-clock observe refused**; no
  host row is ever executed under `ledger:`.
- `corpus/release-clock.py:58-96` — reads only `corpus/SOURCES.md`;
  `:99-127` reads `corpus/release-clocks.tsv`; `:129-153` reads
  `corpus/source-fetches.tsv`; the receipt is selected from the lane tree. No
  sibling read.

Conclusion: the ownership partition is clean. C1's population is kagi docs; C2's
population is kagi registry rows + kagi receipts. The only shared object is the
*fleet SOURCES contract*, which is deliberately re-implemented per lane (kagi's
shell census, kumitate's ESM check). That shared contract is the seam where the
clock diverges (§3).

## 2. C1 stays in-lane — evidence, and two in-lane calibration defects

**No sibling convention is being duplicated by the binder.** `rows:` counts data
lines, `ledger:` runs a non-host row's own command, `expect:` reads the committed
pin and runs nothing (`corpus/self-counts.py:10-18`; `:342-348`). That is the
lane's single-definition convention; kumitate's `proxy-check` (declared vs
computed) and `claims-check` (member count vs declared) are analogues with a
different data model, not reusable code. The one convention worth naming:
`expect:` is structurally the same posture as `anchor-truth`'s pin — pin the
expectation, execute nothing host-reading (`anchor-truth.mjs:34-47`). Kagi
already had that before round 27; no adoption is needed.

**Overlay evidence (my own, static).** I applied the 18 wt `KN-*` locators to
`git show BASE:<doc>` and counted matches. All 18 match exactly one BASE line
(no `UNLOCATED`/`AMBIGUOUS` on the overlay). Five capture a stale number:
`claim-ledger.md:301` claims 17 / stamps 33, `:304` selftest 72,
`op-ref-consumption.md:276` 29, `surface-census.md:32` symbol pins 19 — which
matches wt `corpus/lessons/round-27.md:49` ("Five were stale"). The KN locator
set is therefore sound for the population it chooses.

**But the population is undercounted by one.** BASE
`corpus/knowledge/op-ref-consumption.md:296` (§10 Falsification, undated, not an
erratum) says "`--selftest` proves the comparator on 21 cases". The live pin is
`R12-02` = 36 (`corpus/claim-ledger.tsv:27`), and BASE `:377-381` already concedes
"the §10 '21 cases' comparator sentence is an intermediate historical count …
supersedes that §10 count". The wt table binds §9 (`KN-OPREF-REPRO-SELFTEST`,
`:70`) and §11 (`KN-OPREF-CORRECTION-SELFTEST`, `:71`), not §10. This is
`CritC1Population.md:24-40` CE1; I confirm it independently and add that the wt
lesson's "Five were stale" (`round-27.md:49`) and M27-2 (`:86`) are therefore
one short of the bindable stale set. The fix is text+table only: correct 21→36
with a history clause (or point it at the §9 number) and add a `KN-*` row bound
to `expect:R12-02`; no new source kind.

**The table's population declaration contradicts the docs.** BASE
`corpus/self-counts.tsv:3-5` (unchanged in wt) states the population is
"SKILL.md, PROVINCE.md and corpus/README.md"; BASE `:6-10` lists the exclusion
classes. The wt KN block (`:53-57`) adds a *second* exclusion list (dated
measurement sections, Evidence/Erratum/Round-N history, host/substrate
observations, positional case indexes) for knowledge entries. Meanwhile wt
`SKILL.md:47` and wt `PROVINCE.md:53` tell the reader the population includes
reviewed knowledge lines. A reviewer who reads only the tsv header applies the
old rule and concludes the 18 KN rows are out of contract. Fix: make the header
the one population statement (add knowledge entries and the four KN exclusion
classes, or point to the KN block), then let the docs point at the header. This
is the "one definition" convention the lane already uses for the ledger
(`self-counts.py:14` "The ledger stays the single definition").

**Named non-number residuals, measured.** BASE
`corpus/knowledge/sops-age-key-rotation.md:68-70` and
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:76-78` state the grep
`grep -rliE 'sops|openbao|hashicorp' corpus/knowledge --exclude=…` returns
"no file, exit 1". I re-ran exactly that read-only command: it prints
`corpus/knowledge/feature-bound-credential-review.md` and exits **0**. The wt
lesson already names both as "not bound and still named debt" because they are
QM10 absence claims, not lane-artifact counts (`corpus/lessons/round-27.md:60-64`).
That disclosure is honest and keeps C1 in-lane; the only calibration risk is a
reader taking the plan's "the stale ones are corrected" as covering them. The
plan/lesson should say "the stale *numbers*" explicitly.

C1 verdict: in-lane, no sibling duplication. The two defects above are
calibration-thin, not scope breaks.

## 3. C2 stays in-lane — evidence, and the one seam defect

**The `on-release` judgment is kagi's alone.** The fleet census reports symbolic
cadences and refuses to judge them (`scripts/sources-census.sh:34-37`); kumitate
accepts `on-release` as a valid recheck and emits only `RECHECK_INVALID`
(format) or `RECHECK_OVERDUE` (date/Nd) (`scripts/sources-check.mjs:306-338`).
Chousa's research-method instrument has the same split in vocabulary: `--as-of`
produces `due=`/`freshness=`, "`on-release` is event; unavailable/out-of-range
computation is unknown" (`chousa-shokunin/SKILL.md:480`;
`corpus/knowledge/recheck-due-r26.md:27`). None of these orders versions. Kagi's
`release-clock.py` is the lane-local judge of the event; adding `REGRESSED`
there does not duplicate a sibling gate.

**BASE behaviour, confirmed by reading.** `norm_version` is string identity
(BASE `corpus/release-clock.py:362-363`); `evaluate` accepts a `fired` row
whenever `observed != anchored` (BASE `:524-525`), and `observe_one` writes
`fired` for any inequality (BASE `:730-734`). The table's S012 row has a
non-numeric anchor and a numeric observation (`corpus/release-clocks.tsv:9`),
S027/S028 are fired at 3.15.1 (`:24-25`), S040/S041 are not-fired at 3.15.1
(`:30-31`).

**Current wt, after the 12:28 revision.** `evaluate` now tests the row anchor
*and* the per-URL numeric floor (wt `:567-568`); `feed_floors` takes the highest
strict-X.Y.Z anchor over well-formed feed rows sharing a `feed_url`
(wt `:390-410`). That catches S012 at 1.20.0 (Vault floor 2.2.0, from
S013/S022-S024) and S027/S028 at 3.15.0 (python.org floor 3.15.1, from
S040/S041). `observe_one` additionally uses the row's recorded observation as a
floor (wt `:790-795`), so a fired row that recorded 3.15.1 cannot re-read
3.15.0/not-fired at fetch time even when no higher anchor shares the feed. The
remaining limits are precise: (a) a hand-edited table + hand-built receipt under
an explicit `--receipt-sha` is self-attested, and `evaluate` cannot tell an
observation *equal* to the feed floor from a legitimate state (the wt comment at
`:572-573` says so); (b) the regression branch is still ordered before the
structural checks (`:567` vs `:576`), so a bogus/unnamed anchor with a
below-floor observation is typed `REGRESSED` rather than `INCONSISTENT`
(`CritC2Rollback.md` "Minor issue"); (c) a non-numeric anchor with no numeric
sibling row remains constant-`fired` (no current row: S012 has numeric siblings).
These are the critics' findings; I corroborate from the sibling-vocabulary side,
not as a new proposal.

**The seam defect: a private registry grammar.** The clock's source reader:

- BASE `corpus/release-clock.py:29` — `SOURCE_ID_RE = re.compile(r"S[0-9]{3}")`;
- BASE `:68-80` — strips any line starting with `|`, splits cells, skips rows
  whose first cell does not fullmatch the 3-digit id, and hard-fails SETUP on
  any other 11-cell row. There is **no `## Registry` section tracking**;
- BASE `:509` — the same regex validates `feed_source_id`, so a 4-digit feed id
  is `BADFEED` even when the row exists.

The contract and both census implementations use a wider grammar:
`scripts/sources-census.sh:24` (E02 `S[0-9]{3,}`), `:30` (E12 row outside
`## Registry`); `kumitate-shokunin/scripts/sources-check.mjs:11-14` (E01/E02/E12);
kagi `corpus/sources-census.sh:170` (`S[0-9]{3,}`), `:25-31` (Registry scope).

Concrete latent counterexamples (not run; static reading):

1. A registry row `| S1000 | … | on-release |` is accepted by the census
   (`{3,}`) but skipped by `parse_sources` (`:76`). The clock's `on_release`
   count does not see it; a green `RELEASE_CLOCK: CLEAN` does not disclose that
   a valid on-release row is outside the clock. A clock row naming `S1000` as
   `feed_source_id` is `BADFEED` at `:509` for the same reason.
2. A row-shaped 11-cell line under `## Leads` or `## Search log` (none today;
   the sections are prose) is consumed by the clock but is E12 in the census.
   The clock would bind or UNBIND a clock row to a source the census rejects.

Neither is a current defect (all 43 rows are S0xx inside `## Registry`). Both are
the same class the round is about: a silent pass whose coverage is narrower than
the authority it claims to read.

**Vocabulary collision (minor).** Kumitate's `anchor-truth` already emits
`REGRESSED` for a dead documentation anchor (`anchor-truth.mjs:41`). Kagi's new
`REGRESSED` is a version-downgrade finding. The tokens are lane-local and the
gate name contextualizes them (`RELEASE_CLOCK: …` vs `TRUTH …`), but a fleet
report that greps `REGRESSED` will mix two classes. No code change required;
the lane report/SKILL already says "release-clock REGRESSED". Record it so a
cross-lane reader does not aggregate them.

## 4. Proposed move (one)

**Align the release clock's registry reader with the fleet `sources-census`
grammar it already depends on: widen the id to `S[0-9]{3,}` and scope the parse
to `## Registry` (stop at the next level-2 heading); add one selftest case for
each boundary.**

Why this is the move, not a nit: the clock and the census read the *same* file.
The census is the validator (E02/E12); the clock is the consumer. A consumer
with a narrower grammar than the validator can be CLEAN over a population the
validator says is non-empty — exactly the silent-coverage failure C2 exists to
remove. Reusing the contract grammar is one definition; adding a fourth
`projection:`/`id:` convention to the clock (or a second validation pass) would
be the second convention the assignment asks to avoid. The change is one regex,
a section-scope loop, and three fixture headings — no new source kind, no host
read, no new table.

Exact change (advice only; production is read-only here):

- BASE `corpus/release-clock.py:29`: `r"S[0-9]{3}"` → `r"S[0-9]{3,}"`. The one
  constant serves both the row skip (`:76`) and the feed-id check (`:509`).
- BASE `:68-80`: track the `## Registry` section — start after a line whose
  stripped form is exactly `## Registry`, stop at the next stripped line
  starting `## `; parse only rows inside. Keep the existing 11-cell SETUP for
  rows inside the section (the clock must refuse a registry it cannot read);
  ignore out-of-section rows (E12 is the census's finding, not the clock's).
- Docstring at `:58-96`: declare the subset ("reads the `## Registry` section;
  section/E02 validation is the census's job") so the next expansion is a named
  migration.
- Selftest: the three fixture writers at BASE `:989`, `:1546`, `:1636` write
  `SOURCES.md` without a `## Registry` heading; add it. Add two cases: an
  out-of-section `S004`-shaped row must be ignored (before: parsed/UNBOUND;
  after: ignored), and an in-section `S1000` on-release row must be parsed and
  bindable (before: invisible; after: `on_release=N+1`). If the S1000 case also
  names `S1000` as `feed_source_id`, it proves the `:509` call site too.

Expected results (all unrun; static):

- Default `python3 corpus/release-clock.py` unchanged:
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3
  derived=15)` — no S1000 row exists, and the production `SOURCES.md` has
  `## Registry` at line 3.
- The out-of-section fixture changes from "parsed" to "ignored"; the S1000
  fixture changes from "invisible/BADFEED" to "bound". Both are new selftest
  cases: 73 → 75 (from wt `PROVINCE.md:54` / `SKILL.md:48`), with the usual
  bookkeeping migration: `R25-03` pin, `SC-CLOCK-SELFTEST`,
  `PV-CLOCK-SELFTEST`, `corpus/stamps.tsv`, and the lesson/SKILL/PROVINCE
  counts. The round already migrates 67→73; this is the same pattern, not a new
  one.
- `bash corpus/sources-census.sh` on the production file remains CLEAN and its
  E02/E12 population is unchanged (the clock's reader is the only change).

Risks:

- The headingless-fixture change is mandatory: without it, all release-clock
  selftests SETUP "no SOURCES.md registry rows found". Three `write_text` calls
  at the cited lines; no production file changes.
- A headingless external SOURCES.md now SETUPs. The lane file has the heading,
  and the clock is lane-local; acceptable, but state it in the docstring.
- A future `S1000` on-release row now yields `UNBOUND` until a clock row is
  added. That is the intended coverage behavior (a valid on-release row may not
  be silently outside the clock), but it is a new failure mode for the next
  registry expansion; the docstring/migration note should say so.
- The `REGRESSED` vocabulary collision with kumitate's anchor-truth remains;
  the gate-name context is the only disambiguator. Do not rename the token this
  round (the plan's acceptance depends on it); record the scope in the lesson.

Fallback if L1 declines the code change: document the `{3}` + first-table subset
in the release-clock docstring, `PROVINCE.md:54`, and the lesson Limits, so the
next registry expansion is a named migration rather than a silent miss. That is
strictly weaker than aligning, but it removes the "silent" part.

## 5. Coordination note (not a second proposal)

The two C2 critics propose two floors: `CritC2Rollback.md:95-110` uses the
row's recorded observation as an observe-time floor; `CritC2NonNumeric.md:143-160`
uses the maximum strict-X.Y.Z anchor over rows sharing a `feed_url`. They are
compatible, but implementing both as independent checks would give C2 three
definitions of "older" (own anchor, recorded observation, URL floor). If L1
takes either, define **one** floor function — "the newest numeric evidence held
for this feed" — and supply it from the evidence each call site has
(`observe_one`: recorded observation + URL anchors; `evaluate`: URL anchors).
Also: the current `c2-measure.py` `rollback` fixture bundles the S027/S028
return-to-anchor un-fire with the S040/S041 below-anchor lies
(`.ufo/waves/round-27/tools/c2-measure.py:9-11,27-28`); its exit 1 after the
draft rule comes from S040/S041, so it does not prove the un-fire is caught. An
un-fire-only fixture (change only S027/S028 to 3.15.0/not-fired with a matching
receipt) is needed before any "un-fire refused" claim is measurable. This is the
C2 critics' ground; I record the synthesis and the fixture gap, and propose only
the §4 registry-reader move.

## 6. Contradictions stated, not smoothed

- wt `corpus/QUALITY.md:132` QM25 and wt `release-clock.py:543-545` say "never an
  un-fire of an earlier anchor"; the draft's strict `<` does not catch the
  return-to-anchor un-fire (`CritC2Rollback.md:16-20`). The lesson Limits do
  concede it (`corpus/lessons/round-27.md:92-94`), so QM25 and the Limits
  disagree. Text must be reconciled whichever code path is chosen.
- wt `release-clock.py:1027-1029` says "both lies were accepted CLEAN at
  round-26 BASE"; the `not-fired`/below-anchor case was `INCONSISTENT` at BASE
  (`release-clock.py:527-531`). Only the fired-downgrade was CLEAN
  (`CritC2Rollback.md:62-77`). Calibration of the red-before evidence, not a
  pass/fail hole.
- The tsv header population vs wt SKILL/PROVINCE (§2) is a live contradiction in
  the round's own C1 declaration.
- The wt lesson's "Five were stale" vs the bindable sixth (§10's 21) is a count
  calibration in the lesson, not in the binder.

## 7. What I did NOT check (unrun is not a pass)

- No gate, binder, clock, selftest, ledger row, stamp, or `c2-measure.py` run.
  The overlay was a Python `re` match count over `git show BASE:<doc>`; it never
  executed a `ledger:` row and never read a host surface. The default CLEAN30,
  the S1000/out-of-section fixture outcomes, and the selftest count 75 are
  static readings.
- Did not read every sibling PROVINCE/SKILL. The scan is targeted to kumitate
  (the assignment) plus the freshness/calibration mentions found by a fleet
  grep (chousa, kake, kasegi, mori, kotoba, tsukuroi); their implementations
  beyond the cited lines were not inspected.
- Did not inspect kumitate's `cite-check.mjs`, `round-gate.mjs`,
  `proxy-check.mjs` or `claims-check.mjs` beyond their headers; in particular I
  did not verify whether `anchor-truth`'s pin revision matches kumitate's
  current `origin.json`.
- Did not verify the live feeds, the default receipt's contents, the S042/S043
  fetch digests, or the fleet MANIFEST. Did not check S043's page beyond the
  row text.
- Did not read `XC1Measure`, `XC2Measure`, `MutDowngradeBase`, `MutKnowledgeBase`
  or `RevInequality` (the last is not in `build/`); overlap with those seats is
  not ruled out. I read only `CritC1Population`, `CritC2Rollback`,
  `CritC2NonNumeric`, and the round plan/lesson/cache.
- Did not verify whether the release-clock's private parser is deliberately
  minimal for the `/fast/scratch` `c2-measure.py` clone (it copies only
  `SOURCES.md`, `source-fetches.tsv`, `rendered-text-v1.py`). The "minimal
  parser" intent is inferred from that copy list; if it is intentional, the
  fallback (declare the subset) is the honest choice.
- Did not check any host/substrate row or `--allow-host-rows` path; no
  host-private read, no vault/account/handler/CDP contact.

Tooling: none installed or updated.
