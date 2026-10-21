# ConnKumitate — sibling-overlap scan: kumitate source/tooling checks vs kagi C1/C2

Seat: `KagiR26.ConnKumitate-17` (connector, leaf, read-only). Frozen BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`. **The candidate `144babc` landed
while this scan ran** (L1's round-27 commit, parent BASE); the report therefore
assesses the candidate against BASE, and "wt" below means the candidate/working
tree as read after 12:28. Kumitate is cited at its own HEAD `2fa28e5` — a
sibling, not part of this BASE. No gate, binder, clock, selftest, ledger row or
`c2-measure.py` run by me: the one numeric check is an independent Python `re`
overlay of the candidate's binding locators on `git show 0a47dd18:<doc>`. The
candidate's own measurement files (`c1-before.json`, `c1-after.json`,
`c2-after.json`, `separability.json`) are cited as **lane evidence**, not as my
execution. Lane-authored advice, not a judgment or closure.

Axes judged: **calibration** (primary), **freshness** (primary). No claim on
operability, contract, substrate or verification beyond the bookkeeping named.

## Verdict

1. **C1 and C2 stay in-lane.** No sibling owns kagi's knowledge-entry numbers,
   `corpus/self-counts.tsv`, `corpus/release-clocks.tsv`, the receipt bundles, or
   the `on-release` judgment. Kumitate's source checks are self-scoped to its own
   registry + knowledge entries; the fleet SOURCES contract is *implemented per
   lane*, not owned by kumitate. No file overlap, no shared write surface.
2. **One live second-convention defect at the seam.** The release clock reads the
   same registry the census gates, but with a narrower id grammar
   (`S[0-9]{3}`, candidate `corpus/release-clock.py:29`) and without the
   `## Registry` section scope that the fleet contract
   (`scripts/sources-census.sh:24,30`), kumitate
   (`scripts/sources-check.mjs:11-14`) and kagi's own census
   (`corpus/sources-census.sh:170`, `:25-31`) all enforce. A future valid
   on-release row (`S1000+`) or a row-shaped line outside `## Registry` can be
   silently invisible to — or falsely consumed by — the clock. Latent today
   (S001–S043, all inside `## Registry`); this is the proposed move.
3. **C1's declaration is still internally contradictory.** The binding table's
   header says the population is SKILL.md / PROVINCE.md / `corpus/README.md`
   (candidate `corpus/self-counts.tsv:3-5`, unchanged from BASE), while candidate
   `SKILL.md:47`, `PROVINCE.md:53` and the lesson (`corpus/lessons/round-27.md:53`,
   "22 bindings over 8 entries") include reviewed `corpus/knowledge/*.md` lines,
   and the KN block adds a *second* exclusion list (`self-counts.tsv:53-57`).
   Two population statements, one stale.
4. **The C2 counterexamples are measured closed in the candidate.** The 12:28
   code added `feed_floors` (candidate `corpus/release-clock.py:390-410`, wired
   at `:567-568`) and the recorded-observation floor at `:793-794`; the lane's
   `c2-after.json` reports `downgrades_accepted_clean=0/4`,
   `downgrades_regressed_exact=4/4`, control clean, default exit 0. The remaining
   C2 items are declared limits (equal-to-floor and non-numeric anchors, QM25
   `corpus/QUALITY.md:132`; code comment `:572-573`) and the regression-before-
   structure ordering (`CritC2Rollback.md` "Minor issue"). No new C2 move from me.
5. **Live named residual (calibration, not a number).** Candidate
   `corpus/knowledge/sops-age-key-rotation.md:68-70` and
   `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:76-78` still state
   the negative grep returns "no file, exit 1". The command exits **0** today;
   the lesson discloses this (`corpus/lessons/round-27.md:72-74`: "the grep exits
   0 since round 22 — a QM10 absence claim, not a count") but the entries
   themselves still restate the false result in the present tense.

## 1. Boundary evidence (who owns what)

Kumitate, at HEAD `2fa28e5`:

- `PROVINCE.md:3` — domain "orchestration & tooling — scopes OMP task/hub,
  ufo-fsd scripts & runtime"; nothing about secrets, credentials or release
  clocks.
- `PROVINCE.md:12-15` — Core: origin script/runtime layers and the Kimi
  substrate, gated by `claims-check.mjs` / `proxy-check.mjs` /
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
- `scripts/sources-check.mjs:10-14` — fleet `sources-census.sh validate`
  correspondence: E01 `| S[0-9]{3,} |` row with split-field count != 13, E02 id
  not `S[0-9]{3,}`, E12 row outside `## Registry`.
- `scripts/sources-check.mjs:306-338` — recheck split: ISO date or `NNd` cadence
  can be `RECHECK_OVERDUE` (warn); `on-release` is accepted as a valid cadence
  and **never** judged overdue. The fleet header says the same:
  `scripts/sources-census.sh:34-37` — "symbolic cadences (e.g. on-release) are
  reported, never judged overdue."
- `scripts/anchor-truth.mjs:34-47` — one expectation per anchor (`true` /
  `unchecked` / `debt:*`), typed findings `REGRESSED` (`:41`, a dead doc anchor),
  `ANCHOR_SET_CHANGED` (`:42`), `DEBT_STALE` (`:43`), `DEBT_GREW`/`CHECKED_SHRANK`
  against `--base` (`:45-46`), `PIN_REGRESSION` on re-pin (`:47`). Its header
  (`:5-9`) records why: a ratchet whose ceiling equals current debt passed a
  forward shift of 123 anchors and a reset that re-broke 62 true anchors.

Kagi, at BASE (candidate line noted where the round changed it):

- `PROVINCE.md:52-55` — `claim-ledger`, `self-counts` (BASE population
  SKILL/PROVINCE/README; candidate `:53` adds reviewed `corpus/knowledge/*.md`,
  `--selftest` 48 cases), `release-clock` (candidate `:54`: feed floor +
  recorded observation + `REGRESSED`, `--selftest` 76 cases), `sources-census`
  (fleet v1 over the lane registry).
- `PROVINCE.md:67` — Adjacent: "chousa owns the research method…; chousa, kasegi
  and kumitate run their own secret-shaped tripwires over their outputs (hygiene
  filters, not vault ops)". Kumitate is adjacent for *hygiene*, not source
  checks and not release clocks.
- `corpus/self-counts.py:20-27,226-252` — the binder's command policy: reviewed
  repo inputs, first-token allowlist, no inline bash/python, no recursive
  self-counts, **release-clock observe refused**; no host row executed under
  `ledger:`.
- `corpus/release-clock.py:58-96` — reads only `corpus/SOURCES.md`; `:99-127`
  reads `corpus/release-clocks.tsv`; `:129-153` reads `corpus/source-fetches.tsv`;
  the receipt is selected from the lane tree. No sibling read.

Conclusion: the ownership partition is clean. C1's population is kagi docs; C2's
population is kagi registry rows + kagi receipts. The only shared object is the
*fleet SOURCES contract*, deliberately re-implemented per lane (kagi's shell
census, kumitate's ESM check). That shared contract is the seam where the clock
diverges (§3).

## 2. C1 stays in-lane — evidence and two live calibration items

**No sibling convention is duplicated by the binder.** `rows:` counts data
lines, `ledger:` runs a non-host row's own command, `expect:` reads the committed
pin and runs nothing (`corpus/self-counts.py:10-18`; `:342-348`). That is the
lane's single-definition convention; kumitate's `proxy-check` (declared vs
computed) and `claims-check` (member count vs declared) are analogues with a
different data model, not reusable code. The one convention worth naming:
`expect:` is structurally the same posture as `anchor-truth`'s pin — pin the
expectation, execute nothing host-reading (`anchor-truth.mjs:34-47`). Kagi
already had that before round 27; no adoption is needed.

**Independent overlay on frozen BASE.** I applied the candidate's 22 `KN-*`
locators to `git show 0a47dd18:<doc>`. All 22 match exactly one BASE line (no
`UNLOCATED`/`AMBIGUOUS`). Four capture a stale value, exactly the set in the
lane's `c1-before.json` (`bindings=60`, `knowledge_bindings=22`, `stale=4`,
exit 1): `claim-ledger.md:304` 72 vs 170 (`KN-LEDGER-REPRO-SELFTEST`),
`op-ref-consumption.md:276` 29 vs 36 (`KN-OPREF-REPRO-SELFTEST`), `:296` 21 vs 36
(`KN-OPREF-FALSIFY-SELFTEST`), `surface-census.md:32` symbol pins 19 vs 20
(`KN-CENSUS-DRIFT-SYMBOLS`). The candidate's `c1-after.json` reports
`SELF_COUNTS: CLEAN (claims=60 stale=0)` at `144babc`, and the lesson records the
old values beside the new (`corpus/lessons/round-27.md:53-70`). The earlier
critic finding on §10's 21 (`CritC1Population.md` CE1) is **closed** in the
candidate: the line now reads 36 and row `:79` binds it.

**The table's population declaration still contradicts the docs.** Candidate
`corpus/self-counts.tsv:3-5` (identical to BASE) states the population is
"SKILL.md, PROVINCE.md and corpus/README.md"; `:6-10` lists the exclusion
classes. The KN block (`:53-57`) adds a second exclusion list (dated measurement
sections, Evidence/Erratum/Round-N history, host/substrate observations,
positional case indexes) for knowledge entries, while candidate `SKILL.md:47`,
`PROVINCE.md:53` and the lesson tell the reader the population includes reviewed
knowledge lines. A reviewer who reads only the tsv header applies the old rule
and concludes the 22 KN rows are out of contract. Fix: make the header the one
population statement (add knowledge entries and the four KN exclusion classes,
or point to the KN block), then let the docs point at the header. This is the
"one definition" convention the lane already uses for the ledger
(`self-counts.tsv:14` "The ledger stays the single definition").

**Never-true values are now marked, not bound.** Candidate
`corpus/knowledge/surface-census.md:5` reads "8 json [first written as 9,
misstated — round-22 erratum]" and `:76` reads "9 of 15 rows; the original '16'
was misstated, round-22 erratum". That satisfies QM26's "labelled, not restated
as current" for the two values CritC1Population flagged (CE2/CE3); they are out
of the `rows:` kind by construction, and the label is beside the number. Pass.

**Named non-number residual, measured.** Candidate
`corpus/knowledge/sops-age-key-rotation.md:68-70` and
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:76-78` still state the
grep `grep -rliE 'sops|openbao|hashicorp' corpus/knowledge --exclude=…` returns
"no file, exit 1". I re-ran exactly that read-only command: it prints
`corpus/knowledge/feature-bound-credential-review.md` and exits **0**. The lesson
(`corpus/lessons/round-27.md:72-74`) already names this as debt: "the grep exits
0 since round 22 — a QM10 absence claim, not a count." That disclosure keeps C1
honest, but the entries still assert the false result; a reader of the entry does
not see the lesson. QM26's "labelled with its round, not restated as current"
argues for a parenthetical beside the command (as the lesson has) or a dated
history clause. Not a binder defect; a calibration residual.

C1 verdict: in-lane, no sibling duplication. The population-header contradiction
and the grep residual are the two live calibration items; the binder itself is
sound on its chosen population (22/22 locators unique, 4 stale found at BASE,
CLEAN at the candidate).

## 3. C2 stays in-lane — evidence, the seam defect, and the declared limits

**The `on-release` judgment is kagi's alone.** The fleet census reports symbolic
cadences and refuses to judge them (`scripts/sources-census.sh:34-37`); kumitate
accepts `on-release` as a valid recheck and emits only `RECHECK_INVALID`
(format) or `RECHECK_OVERDUE` (date/Nd) (`scripts/sources-check.mjs:306-338`).
Chousa's research-method instrument has the same split: "`on-release` is event;
unavailable/out-of-range computation is unknown" (`chousa-shokunin/SKILL.md:480`;
`corpus/knowledge/recheck-due-r26.md:27`). None orders versions. Kagi's
`release-clock.py` is the lane-local judge of the event; adding `REGRESSED`
there does not duplicate a sibling gate.

**BASE behaviour, confirmed by reading.** `norm_version` is string identity
(BASE `corpus/release-clock.py:362-363`); `evaluate` accepts a `fired` row
whenever `observed != anchored` (BASE `:524-525`); `observe_one` writes `fired`
for any inequality (BASE `:730-734`). The table's S012 row has a non-numeric
anchor and a numeric observation (`corpus/release-clocks.tsv:9`), S027/S028 are
fired at 3.15.1 (`:24-25`), S040/S041 are not-fired at 3.15.1 (`:30-31`).

**Candidate behaviour, measured by the lane.** `feed_floors` takes the highest
strict-X.Y.Z anchor over well-formed feed rows sharing a `feed_url` (candidate
`corpus/release-clock.py:390-410`); `evaluate` tests the row anchor and the feed
floor (`:567-568`); `observe_one` additionally floors on the row's recorded
observation (`:793-794`). The lane's `c2-after.json` reports all four downgrade
fixtures exact (`lie`, `rollback`, `unfire`, `nonnumeric`), 0/4 accepted CLEAN,
control clean, default exit 0; `c2-before.json` reports all four accepted CLEAN
at BASE (exit 0).
That closes the two critics' counterexamples (return-to-anchor un-fire; S012
non-numeric downgrade) and the un-fire-only fixture now exists in
`.ufo/waves/round-27/tools/c2-measure.py:29,33,36-37`. The remaining limits are
declared: an observation *equal* to the feed floor cannot be told from a
legitimate state on offline replay (code comment `:572-573`; QM25
`corpus/QUALITY.md:132`), non-numeric/two-component/prerelease anchors keep the
inequality rule, and a hand-built table+receipt under an explicit `--receipt-sha`
is self-attested. The regression branch is still ordered before the structural
checks (`:567` vs `:576`), so a bogus/unnamed anchor with a below-floor
observation is typed `REGRESSED` rather than `INCONSISTENT`
(`CritC2Rollback.md` "Minor issue"); exit 1 is preserved, so this is diagnostic
precision, not a pass hole.

**The seam defect: a private registry grammar.** The clock's source reader:

- candidate `corpus/release-clock.py:29` — `SOURCE_ID_RE = re.compile(r"S[0-9]{3}")`;
- candidate `:58-96` — strips any line starting with `|`, splits cells, skips
  rows whose first cell does not fullmatch the 3-digit id, and hard-fails SETUP
  on any other 11-cell row. There is **no `## Registry` section tracking**;
- candidate `:557` — the same regex validates `feed_source_id`, so a 4-digit
  feed id is `BADFEED` even when the row exists.

The contract and both census implementations use a wider grammar:
`scripts/sources-census.sh:24` (E02 `S[0-9]{3,}`), `:30` (E12 row outside
`## Registry`); `kumitate-shokunin/scripts/sources-check.mjs:11-14` (E01/E02/E12);
kagi `corpus/sources-census.sh:170` (`S[0-9]{3,}`), `:25-31` (Registry scope).

Concrete latent counterexamples (static; no such row today):

1. A registry row `| S1000 | … | on-release |` is accepted by the census
   (`{3,}`) but skipped by `parse_sources` (`:76`). The clock's `on_release`
   count does not see it; a green `RELEASE_CLOCK: CLEAN` does not disclose that
   a valid on-release row is outside the clock. A clock row naming `S1000` as
   `feed_source_id` is `BADFEED` at `:557` for the same reason.
2. A row-shaped 11-cell line under `## Leads` or `## Search log` (none today;
   the sections are prose) is consumed by the clock but is E12 in the census.
   The clock would bind or `UNBOUND` a clock row to a source the census rejects.

**Vocabulary collision (minor).** Kumitate's `anchor-truth` already emits
`REGRESSED` for a dead documentation anchor (`anchor-truth.mjs:41`). Kagi's
`REGRESSED` is a version-downgrade finding. The tokens are lane-local and the
gate name contextualizes them (`RELEASE_CLOCK: …` vs `TRUTH …`), but a fleet
report that greps `REGRESSED` will mix two classes. No code change required;
record the scope in the lesson so a cross-lane reader does not aggregate them.

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

- candidate `corpus/release-clock.py:29`: `r"S[0-9]{3}"` → `r"S[0-9]{3,}"`. The
  one constant serves both the row skip (`:76`) and the feed-id check (`:557`).
- candidate `:58-96`: track the `## Registry` section — start after a line whose
  stripped form is exactly `## Registry`, stop at the next stripped line
  starting `## `; parse only rows inside. Keep the existing 11-cell SETUP for
  rows inside the section (the clock must refuse a registry it cannot read);
  ignore out-of-section rows (E12 is the census's finding, not the clock's).
- Docstring at `:58-96`: declare the subset ("reads the `## Registry` section;
  section/E02 validation is the census's job") so the next expansion is a named
  migration.
- Selftest: the three fixture writers at candidate `:989`, `:1547`, `:1636`
  write `SOURCES.md` without a `## Registry` heading; add it. Add two cases: an
  out-of-section `S004`-shaped row must be ignored (before: parsed/`UNBOUND`;
  after: ignored), and an in-section `S1000` on-release row must be parsed and
  bindable (before: invisible; after: `on_release=N+1`). If the S1000 case also
  names `S1000` as `feed_source_id`, it proves the `:557` call site too.

Expected results (static; the lane executes):

- Default `python3 corpus/release-clock.py` unchanged:
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3
  derived=15)` — no S1000 row exists, and the production `SOURCES.md` has
  `## Registry` at line 3. (The candidate's `c2-after.json` default result is
  the same CLEAN line.)
- The out-of-section fixture changes from "parsed" to "ignored"; the S1000
  fixture changes from "invisible/BADFEED" to "bound". Both are new selftest
  cases: the candidate's declared count is 76 (`PROVINCE.md:54`, `SKILL.md:48`,
  `R25-03` pin), so the executed selftest would report 78; the executed count is
  the authority. Usual bookkeeping migration: `R25-03`, `SC-CLOCK-SELFTEST`,
  `PV-CLOCK-SELFTEST`, `corpus/stamps.tsv`, lesson/SKILL/PROVINCE counts. The
  round already migrated 67→76; this is the same pattern.
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

The two C2 critics' floors are now integrated, not duplicated: `feed_floors`
(candidate `release-clock.py:390-410`) is the per-URL anchor floor used by
`evaluate`; the recorded-observation floor is used by `observe_one`
(`:793-794`). The two call sites have different available evidence, so they are
complementary rather than a third definition. The un-fire-only fixture now
exists (`c2-measure.py:29,33,36-37`), and the exact-set check
(`regressed_exact`, `:71-78`) closes the earlier bundling-mask concern: the
`rollback` fixture now asserts all four ids, not just S040/S041. One calibration
nit remains in the instrument: its docstring still says "builds three fixtures"
(`c2-measure.py:6-12`) while `FIXTURES`/`DOWNGRADES` define five (`:25-33`);
update the docstring so the instrument's prose matches its set. I am not
proposing this as my move because it is the C2 seats' ground; I record it for
the final integration pass.

## 6. Contradictions stated, not smoothed

- **Population:** candidate `corpus/self-counts.tsv:3-5` (SKILL/PROVINCE/README)
  vs candidate `SKILL.md:47`, `PROVINCE.md:53` and `corpus/lessons/round-27.md:53`
  (22 bindings over 8 entries, reviewed knowledge lines). One of the two is
  stale; the header is.
- **Grep residual:** candidate `corpus/knowledge/sops-age-key-rotation.md:68-70`
  and `vault-openbao-token-lease-lifecycle.md:76-78` state exit 1; the same
  command exits 0 (measured); the lesson `:72-74` states exit 0. The entry and
  the lesson disagree.
- **Token collision:** kumitate `anchor-truth.mjs:41` `REGRESSED` (dead doc
  anchor) vs kagi `release-clock.py` `REGRESSED` (version downgrade). Same token,
  different classes; the gate name is the only disambiguator.
- **Grammar:** the clock's `{3}` + unscoped reader vs the fleet/kumitate/kagi
  census `{3,}` + `## Registry` (the proposal's premise). Today's rows hide it;
  the next registry expansion will not.
- **Declared, not contradictory:** the equal-to-feed-floor limit and the
  non-orderable-anchor limit are now stated in QM25 (`QUALITY.md:132`) and the
  code comment (`release-clock.py:572-573`); the lesson Limits
  (`round-27.md:92-94`) agrees. No smoothing needed.

## 7. What I did NOT check (unrun is not a pass)

- No gate, binder, clock, selftest, ledger row, stamp, or `c2-measure.py` run.
  The overlay was a Python `re` match count over `git show 0a47dd18:<doc>`; it
  never executed a `ledger:` row and never read a host surface. The default
  CLEAN30, the S1000/out-of-section fixture outcomes, and the projected
  selftest 78 are static readings. The lane's `c1-before.json`,
  `c1-after.json` and `c2-after.json` are cited as lane evidence, not my runs.
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
