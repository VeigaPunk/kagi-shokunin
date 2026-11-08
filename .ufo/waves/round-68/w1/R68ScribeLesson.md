# R68ScribeLesson — round-68 lesson findings

Seat: R68ScribeLesson (scribe). Lane `kagi-shokunin`, branch master. Claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c`. Frozen predeclaration
`23a8e0290d8d3a6f1de16eafce40fd1a189ef636` (`plans/round-68.md` + `claims.json`),
Amendment A1 at `4251519bd6e8b5c152d70ae286e04a117a49ed4f`.

**Scope change (L1 instruction, received mid-flight).** This seat was originally the sole
writer of `corpus/lessons/round-68.md`. The L1 (KagiR68) reassigned that file to itself
mid-round, to avoid a concurrent-write collision at integration. **This seat has NOT
written `corpus/lessons/round-68.md` and has not touched it** — the file does not exist in
the lane as of this report (`ls corpus/lessons/round-68.md` ⇒ no such file). This seat's
deliverable is this report only: the mined mistakes, the in-place registry log and the
closing numbers, for the L1 to fold into the lesson it is landing. Nothing here amends a
frozen predicate, counter, kill rule, population or target.

**Wave facts the lesson's header needs** (measured from the wave's own artefacts, not copied
from prose): wave `kagi-r68-w1`; **15 seats** — `.ufo/waves/round-68/w1-spec.json` `items`
= 15, `w1-dispatch.json` `taskCall.tasks` = 15, `w1/swarm-registry.json` `members` = 15, and
the by-role count is 5 executor / 2 scribe / 1 scout / 1 connector / 2 reviewer / 1 critic /
1 mutation-tester / 1 revenger / 1 sentinel. **Attack share 4/15 = 26.7 %** on the frozen
attack list (`R68Reviewer`, `R68Critic`, `R68MutGate`, `R68ReviewerLayers`), **5/15 = 33.3 %**
once the revenger is counted. (The seat brief I was issued still said "13 seats", the
round-67 figure; the round-68 plan §Wave says 12–16 and the artefacts say 15 — the lesson
header should carry 15.) Claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c`, frozen predeclaration
`23a8e0290d8d3a6f1de16eafce40fd1a189ef636`, per the header above.

Read-only on the lane throughout. No lane file was edited; no git command mutated anything;
nothing was committed; no fleet path, no sibling lane and no `considerthese/` file was
touched. Every measurement ran on a private copy under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r68/R68ScribeLesson/` (BASE extracted with
`git archive`, never a mutation of the lane). Scratch deleted before yield; the receipts
below are copied into `.ufo/waves/round-68/w1/R68ScribeLesson/`.

---

## 1. Mined mistakes

### M68-5 — the round's own frontier row cites the RFC's *liberal* branch to ground a *strict* rule

- **class**: `scope` (a claim's cited evidence does not say what the record says it says)
- **evidence**: `corpus/SOURCES.md` S167 `teaches` cell (live tree) reads, in the lane's own
  words: *"Implementations MUST reject base-encoded data carrying characters outside the
  base alphabet, **and the RFC states that adjacent CR/LF bytes ARE non-alphabet characters**
  — so a stray CR or space in a structured cell is a defect to refuse, never a formatting
  choice to normalise."* The cited body is
  `.ufo/waves/round-68/capture/S167.body` (35491 B, sha256 `84e14418f795…`), RFC 4648 §3.3.
  The sentence the row leans on is at body lines 206–208, and it says the opposite of what
  the row uses it for:

  ```
  206:   accept").  Note that this means that any adjacent carriage return/
  207:   line feed (CRLF) characters constitute "non-alphabet characters" and
  208:   are ignored.  Furthermore, such specifications MAY ignore the pad
  ```

  "and are ignored" — the CRLF clause is the *consequence* of the RFC's parenthetical
  liberal-acceptance branch (`"be liberal in what you accept"`, body line 205), which the
  RFC offers as an **alternative** to rejection ("unless the specification referring to this
  document explicitly states otherwise. Such specifications may instead state, as MIME
  does, that characters outside the base encoding alphabet should simply be ignored…",
  body lines 202–205). RFC 4648 §3.3 is a rule about **base-encoded data**, and the row
  applies it to **a structured cell in a TSV** — a domain the RFC never speaks to: the
  phrases the frozen plan predicted for this source are absent from the body
  (`grep -c` on the capture: "never reads past the malformed byte" = 0, "field carries
  structured data" = 0, "accepts the exact form" = 0, "refuses the record" = 0). The RFC's
  *strict* argument does exist — but in **§12 Security Considerations** (body lines
  747–756: "If non-alphabet characters are ignored, instead of causing rejection of the
  entire encoding (as recommended), a covert channel … is made possible"), which the row
  does not cite, and which argues for rejecting **base-encoded data**, not for refusing a
  stray byte in a TSV cell. The knowledge entry repeats the inversion verbatim:
  `corpus/knowledge/source-capture-binding.md:79-85` quotes the CRLF sentence with the
  operative clause dropped ("…constitute 'non-alphabet characters'") and then asserts "A
  conforming parser accepts the field's exact form or refuses the record; it never
  normalises a malformed byte away and keeps going." The RFC says CRLF **are ignored**.
- **captured-by**: `none` — the lane's own instruments cannot see it. The located quote
  (`Implementations MUST reject the encoded data if it contains characters outside the base
  alphabet when interpreting base-encoded data`, `rendered-text-v1 locate` ⇒ count=1) is
  real and is the RFC's primary MUST; nothing in `corpus/sources-census.sh`, in
  `corpus/claim-ledger.sh`, or in the C1/C2 counters compares a `teaches` cell's
  *inference* against the sentence it cites. The gate checks that the quote locates, not
  that the row's conclusion follows from the quote. The round's own §Frontier step named
  the expected grounding ("when a field carries structured data, a receiving parser either
  accepts the exact form or refuses the record — never reads past the malformed byte") and
  the seat checked the RFC against that expectation and admitted it anyway on the strength
  of the alphabet MUST alone.
- **fix**: the row's `teaches` cell must be re-cut to what §3.3 says, and the strict
  argument must cite §12 (body lines 747–756) explicitly rather than borrowing the CRLF
  sentence out of the liberal branch it belongs to. The honest phrasing is the RFC's own:
  a decoder MUST reject base-encoded data carrying characters outside the base alphabet
  (unless the referring specification says otherwise), and §12 warns that ignoring them
  opens a covert channel — a reason to *reject the encoding*, not a statement that "a
  stray CR in a TSV cell is a defect to refuse". Either the row is re-grounded on §12 with
  its scope stated as base-encoded data (leaving the census's CR rule grounded on the
  gate's own `SC_FETCH cr-in-tsv` file-level check, which stands on its own), or the row's
  scope cell is narrowed to what the RFC actually decides. The flip condition for the
  current verdict should be written as "a cited § that decides the record-level rule for a
  structured field", not "the alphabet MUST".

### M68-6 — the plan's motivating evidence names a "SETUP" the cells gate never prints

- **class**: `landing` (a plan cites a verdict token the instrument does not emit)
- **evidence**: `plans/round-68.md` (frozen, lines 41-43) says: *"the cells gate that every
  pre-move section must pass cannot be green on the landed tree"*, and the C2 L3 row
  (line 155) states the defect as *"`claim-ledger.sh cells` reads `SETUP` on the historical
  heading `## Round 63 — planned` (present at BASE)"*; the frozen C2 predicate in the seat
  brief repeats the word `SETUP`. **The word `SETUP` does not exist in
  `corpus/claim-ledger.sh`**: `grep -c SETUP corpus/claim-ledger.sh` ⇒ **0** (case-sensitive);
  the only occurrences of the stem are prose comments ("is a setup error (exit 2)",
  "policy/setup error"). What the gate actually prints at BASE is a `die()` on an
  unrecognised heading, with a different sentence and a different exit:

  ```
  $ bash corpus/claim-ledger.sh cells            # BASE tree, exit 2
  claim-ledger: unrecognised round heading in <tree>/SCORECARD.md: '## Round 63 — planned'
                (expected '## Round <N> — pre-move|post-move')
  ```

  (receipt `cells-base.out`; exit code measured `CELLS_RC = 2`, confirmed twice — once
  through a plain shell run and once through a `subprocess` run with the same result.) The
  frozen C2 L1 cell and the C2 leg-L3 description both inherit the wrong token, so a
  counter written to the plan's wording looks for a `SETUP` line that no run will ever
  print, and a reader who greps the gate's output for `SETUP` finds nothing. The same
  wrong token is in the round's own claim text (the seat brief's C2 description: *"`claim-ledger.sh
  cells` SETUP on the historical `## Round 63 - planned` heading"*).
  **Same class, second instance — a path the plan cites that names no file.** The same
  C2 L1 cell continues: *"…and the expectation-migration journal
  `corpus/expectation-migrations.json` journals 78→88"*. **That file does not exist** — not
  at BASE (`git cat-file -e d3b2a4e8:corpus/expectation-migrations.json` ⇒ *"does not exist
  in 'd3b2a4e8…'"*) and not live (`ls corpus/expectation-migrations.json` ⇒ no such file).
  The 78→88 pair lives at `.ufo/waves/round-67/journals/expectation-migrations.json` (the
  new `journals/` layout round 67 introduced; earlier rounds used
  `.ufo/waves/round-N/expectation-migrations.json`). A counter written to the plan's
  wording greps a corpus-level journal that no round has ever written, and would report
  the journal leg missing on a tree whose journal is present and correct. The *frozen
  interface* the seat brief states is right (`.ufo/waves/round-68/journals/`) — it is the
  plan's motivating paragraph that carries the stale path.
- **captured-by**: `none` — the lane's gates are line- and exit-code-based and never
  assert a verdict token or a journal path for the cells audit, so no instrument on the
  tree can catch a plan that names one. The plan's own freeze step runs
  `claims-declared.sh` (M67-3's fix) but nothing reads the plan's prose against the
  instruments and paths it names. The class is the same one QM96 records from the other
  side: a receipt/verdict cited by name must exist and print; here neither the cited
  verdict nor the cited path exists at all.
- **fix**: the plan's C2 L1/L3 cells must read what the tree contains — the journal path
  `.ufo/waves/round-67/journals/expectation-migrations.json` (and this round's
  `.ufo/waves/round-68/journals/expectation-migrations.json`), and the cells defect as
  measured: *"the cells audit refuses the scorecard on the historical heading
  `## Round 63 — planned` with exit 2 and the message `claim-ledger: unrecognised round
  heading …`"*. The landed repair already does the right thing (measured: the current
  parser skips the planned heading and still refuses a scored section that lost an axis —
  `sc-planned-scored-five.md` ⇒ exit 2 "does not carry all six axes exactly once (found=5
  missing=adjacency)"); it is the *frozen description* that names a verdict and a path the
  tree does not have, and that is what a reader or a later counter will copy. A cheap
  general fix for the class: the freeze step should `test -e` every path a plan cites and
  grep every verdict token a plan quotes against the file it names.

### M68-7 — the round-67 lesson never recorded the three routed classes it closed on

- **class**: `landing` (a round's own record omits the defects its own closure routed)
- **evidence**: the round-67 non-author closure
  (`corpus/lessons/round-67-verifier-spotcheck.md` §"Routed defects (next round)", items
  1–3) routed three classes into round 68: the prose escape hatch, column 15's normalized
  digest never recomputed, and S166's own row outside the census population. The round-67
  **lesson** (`corpus/lessons/round-67.md`, the file round 68 inherits from) names **none of
  them**: `grep -ci` over `corpus/lessons/round-67.md` ⇒ "whitespace" 0, "CRLF" 0,
  "col 15" 0, "col15" 0, "escape hatch" 0, "stray byte" 0, "borrowed" 0. Its C1 claim
  (lines 13–20) reads *"the lane's own source census reads each capture-path row's declared
  bytes and locator quote; `C1_READTHROUGH` located 35 → 36 and caught 0/6 → 6/6"* with no
  statement of which cell shapes the reading covers — and the round-67 lesson's §Gate row
  for S166 still describes the prose cell as prose (line 34: *"The fetch row's location
  column is **prose** … so S166's capture is **not** inside the census's capture-path
  population"*), a sentence this round's re-cut makes false. So the round-67 record claims
  a coverage it did not have, and the next round's plan had to re-derive the classes from
  the closure file and the revenger's report instead of from the lane's own lesson.
  **Measured**: at BASE, all three classes are still open on the BASE gate — my own
  re-measurement of the three blindness witnesses on a full copy of the BASE tree
  (`trailing-space` ⇒ `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)`,
  rc 0; whole-file CRLF ⇒ `CLEAN (path_rows=0 bound=0 located=0 prose=157)`, rc 0;
  `col15-swap` ⇒ `CLEAN (path_rows=36 bound=36 located=36 prose=121)`, rc 0), reproducing
  the L1's committed witnesses independently.
- **captured-by**: `none` for the lesson itself — the round-67 lesson is written by the
  round, from the round's own reading, and no criterion requires it to enumerate the
  classes its *external* closure routed. QM95 (a census gate that declares a capture
  location must read the bytes at that location) and QM92 (a declared normalized digest
  must be recomputed) exist as quality rows, but neither is bound to a lesson surface;
  the routed items were free to die between the closure file and the lane's own record.
- **fix**: each round's lesson must carry a short *open classes* section naming the
  defects its closure routed and their one-line class, so the next round's plan reads the
  lane's own record rather than the closure's. Round 68's lesson should carry the three
  classes with their now-measured status (whitespace: closed at the gate, measured;
  col-15: closed at the gate, measured; S166 outside the population: closed by the
  re-cut, measured) and the round-67 lesson's stale S166 prose sentence must be corrected
  by whoever owns that file — this seat does not own it and did not edit it.

### M68-8 — the C2 counter's leg-L3 negative control was unpassable against the parser as it then stood — **CLOSED during the wave, recorded as a wave-process item, not an open defect**

- **class**: `vacuous` (a leg's control tests a shape the instrument does not recognise)
- **evidence (at the bytes I first measured, `corpus/claim-ledger.sh` sha256
  `1f4bf1e74fdfc547…`)**: `plans/round-68-c2.sh` implemented leg L3's third direction as
  *"a suffixed planned heading is unrecognised"* and asserted
  `suffixed-planned rc=0 … (want rc=2 unrecognised)` — i.e. it wanted a
  `## Round 63 — planned (claims C1 freshness)` heading to be **refused**. The counter
  seat's own run recorded exactly that mismatch:
  `LEG L3 verdict=defect suffixed-planned rc=0 tail='CELL_AUDIT: CLEAN (…)' (want rc=2
  unrecognised)` (`R68ExecCounterC2/c2-run.txt`, RC 1, `C2_RECORD: mismatches=3
  population=3 guard=0`). My own measurement on the parser of that revision agreed: the
  `PLANNED_SECTION_RE` of the day was
  `^ {0,3}##[[:blank:]]+Round [0-9]+ — planned([[:blank:]]|$)`, which matches **any**
  suffix, so the suffixed heading read rc 0 `CELL_AUDIT: CLEAN` while the counter demanded
  rc 2. The leg could not pass against the parser it was testing.
- **disposition (re-measured on the current bytes, `corpus/claim-ledger.sh` sha256
  `b0d84db605557b28…`)**: **the parser was tightened and the counter updated to match** —
  `PLANNED_SECTION_RE` is now `^## Round [0-9]+ — planned( \([^|)]*\))?$`, and the counter's
  leg L3 now asserts two directions that the parser actually implements. My re-measurement
  of the current pair:

  | fixture | current reading | counter's expectation | agrees |
  |---|---|---|---|
  | `## Round 99 — planned (next)` (bare parenthetical) | rc 0, `CELL_AUDIT: CLEAN (cells=6 …)` | leg (i): a `CELL_AUDIT` line, no unrecognised-heading die | yes |
  | `## Round 99 — planned claims table` (other suffix) | rc 2, `claim-ledger: unrecognised round heading …` | leg (ii): rc 2 + "unrecognised round heading" | yes |
  | pointerless six-axis table under `## Round 99 — planned (next)` | rc 2, `claim-ledger: score table under an unscored planned heading …` | (a table under a planned heading must die loudly) | yes |

  **M68-8 is therefore closed by the wave** and is recorded here only as evidence of the
  wave-process pattern below — it is **not** an open defect, and the L1 must not carry it
  as one.
- **the residual that IS still worth naming as a ceiling**: the tolerance is now
  *heading-shaped*, so the class "a planned heading with a bare parenthetical suffix is
  skipped" is accepted by design. That is a **ceiling** (the heading is not a score table;
  a table under it still dies loudly, measured above), not a defect.
- **captured-by**: the C2 counter's own `--selftest` (the only instrument exercising this
  direction) plus the wave's own re-measurement — this is one of the few classes this round
  where the instrument and the counter's disagreement was caught **before** the claim was
  closed, by the counter seat's own run, not by an outside reviewer.

### M68-9 — the counters' own selftests pass mutants that break individual `guard` fields (QM89 unfulfilled on the field the frozen line advertises)

- **class**: `vacuous` (a verdict field with no selftest case in which that field alone is wrong)
- **evidence**: `R68MutGate` §1 measured three mutants of `plans/round-68-c1.sh`, each printing
  **`C1_VERIFIED_SELFTEST: PASS (59 cases)`**:

  | mutant | change | counter selftest | killed only by |
  |---|---|---|---|
  | (c) | guard (b) threshold `cases >= 89` → `cases >= 0` | `PASS (59 cases)` — **survived** | MutGate's external `lowcount` divider (a gate that prints `PASS (0 cases)`): pristine reads `guard=0`, mutant reads `guard=1` |
  | (d) | guard (e) removed (`ge = 1`) | `PASS (59 cases)` — **survived** | no divider could reach it: "the guard hole is masked by stronger checks, which is a coverage finding" |
  | (e) | derivation switched to the candidate tree's own normalizer | `PASS (59 cases)` — **survived** | MutGate's `normwrap` divider (a tree wrapper that moves both sides of the cross-check) |

  My own read of the current counter confirms the gap is still there: the selftest case list
  (`plans/round-68-c1.sh`, lines ~1000–1115) carries cases for the six mutation legs
  (`m1-right` … `m6-right`, `m1-wrong-reason`, `wrong-id`, `m3-right-filelevel`,
  `rc0-not-caught`, `setup-never-caught`, `forged-defects-count-refused`,
  `forged-verdict-findings-refused`, `honest-counts-accepted`) and **none** for guard (b)'s
  threshold or guard (e)'s prose check. QM89 is explicit: *"every field of the frozen verdict
  line (`drift`, `paths`, `hex`, `match`, `guard`) has at least one selftest case in which
  that field alone is wrong and the exit code is non-zero"* — here `guard` is exactly the
  field the round's `guard=1` claim turns on, and three of its five legs have no such case.
  Same class in C2: `R68MutGate` §3 (k) shows the C2 selftest's `neg-scored-missing-axis`
  negative "does NOT kill" a mutant that accepts any SETUP as a skip, because guard (c)
  independently refuses that fixture — the case passes with or without the mutant.
- **captured-by**: `R68MutGate` (an external seat with its own dividers), before the report —
  no criterion *inside* the counters requires their own selftest to be field-complete, and
  the counters' selftests are the only instrument that runs their guards.
- **fix**: three cases per counter, one per unexercised guard leg, each a fixture in which
  that leg alone reads 0 while every other count is right: (i) a stub gate printing
  `SOURCES_CENSUS_SELFTEST: PASS (0 cases)` with `verify` untouched ⇒ the counter must read
  `guard=0`; (ii) a stub gate printing one uncounted `FINDING SC_CAPTURE id=… capture-token`
  for a prose row with its verdict CLEAN and counts equal to the derivation ⇒ `guard=0`;
  (iii) a tree differing only in `corpus/rendered-text-v1.py`'s digest ⇒ `guard=0` (this
  one is the M67-4 class, and the round's own Sentinel §3 measured that guard f is the only
  thing that binds it). For C2, the `neg-scored-missing-axis` case must be rebuilt so that
  guard (c) cannot mask L3 — the fixture must fail *only* through L3's own refusal.

### Closed during the wave (recorded, not open defects)

Two classes the wave's own seats raised and the wave then repaired. The L1 should carry
them as wave-process items, **not** as open mistakes:

- **C2's L1 pin parser could not parse the ledger's expect format.**
  `R68MutGate` §5 F1 measured that `expect_cases()` (at counter bytes `9b32226f…`/`ba9d74b4…`)
  needed a second literal `(` — `re.search(r"\(\\?\((-?\d+)\) cases\\?\)", …)` — where the
  canonical expect has a backslash: for `^SOURCES_CENSUS_SELFTEST: PASS \(98 cases\)$` both
  patterns return `None`, so the leg reported `R21-03 expect carries no case count` and no
  R3-valid expect could satisfy it. **Re-measured on the current bytes**:
  `expect_cases()` is now `re.search(r"(\d+)\s*cases", expect)`, which parses `98` out of the
  canonical row (verified by reading the function at `plans/round-68-c2.sh:173-179` and the
  ledger row `^SOURCES_CENSUS_SELFTEST: PASS \(98 cases\)$`). The class is closed at the
  current bytes; the earlier `mismatches=3` reading was taken against the broken parser, so
  it is **not** evidence about the landed instrument.
- **A shared mutable BASE control tree was written by two different seats, twice.** The L1
  recorded the first (`S164` gained a trailing space in the shared BASE extraction — my
  own measurement confirms `aa6fa318…` vs the committed `90dd4a2c…`, and my derivation on
  that tree reads 35/30 narrow instead of 36/31). `R68MutGate` §5 F6 self-reports the
  second: a `cp -al` hardlink clone of the same BASE extraction was written through, so a
  normalizer *stub* propagated into the BASE tree (detected by hash `9da64fa0…` vs
  `14f6ca6a…`, and by an impossible `col15=1`; restored from `git archive`, affected
  readings discarded). **Two independent corruptions of one "control" is the finding**: a
  shared, writable BASE extraction is not a control, and any seat that hardlinks from it can
  write into it. The fix is structural, not a repair: every seat extracts its own
  `git archive <BASE>` and every receipt pins the tree by digest (mine did — see
  `derive3-base-clean.txt`'s header line `tree=/fast/scratch/hyaku/kagi-r68/R68ScribeLesson/base`).
- **C2's leg-L3 versus the cells parser** — M68-8 above, closed by the parser tightening.

### Measured, and NOT a mistake (recorded so the judge does not re-mine it)

- The **frozen BASE population numbers in the plan were measured before the freeze** — the
  check the seat brief asked for. `plans/round-68.md` §C1 asserts `verified=37 col15=32`
  at the candidate and `verified=36 col15=31` at BASE. The BASE side is reproducible from
  committed receipts that exist **at BASE** (`d3b2a4e8`): `.ufo/waves/round-67/w1/R67Revenger.md`
  §2 (the gate's own `path_rows=36 bound=36 located=36 prose=120` on the class tree) and
  the round-67 spot-check's C1 re-measurement. My own independent derivation over a fresh
  `git archive d3b2a4e8` tree, written from the plan's frozen population sentence and not
  from the gate, reads **narrow_pure_path_bound=36 narrow_col15=31 / widened_bound=37
  widened_col15=32** (receipt `derive3-base-clean.txt`) — i.e. the plan's BASE figures
  hold under its own wording. **However**: the plan's *col-15* figure (31) has **no
  committed receipt anywhere at BASE** — `git grep -l "col15match\|col15= 31\|rendered= 31"
  d3b2a4e8 -- .ufo corpus` ⇒ empty, and the round-67 spot-check carries no col-15 count.
  The col-15 count is a *new* number this round: the first receipt for it is
  `.ufo/waves/round-68/base/base-derivation.md` ("BASE verified= 36 rendered= 31 col15match=
  31"), committed at `7e78630` — **after** the freeze (`23a8e02`, 09:17:04). So the plan's
  col-15 baseline was asserted at freeze time with no receipt to back it, and the receipt
  that backs it landed 7 minutes later. That is a QM96-adjacent gap in the freeze
  sequence (the derivation receipt should have landed with or before the predeclaration),
  and it is the one number in the frozen predicate I could not verify from a pre-freeze
  committed artefact.
- The **L1's BASE extraction is polluted** — an independent confirmation of the L1's
  M68-3. `/fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e/corpus/source-fetches.tsv` has
  sha256 `aa6fa31862f2…` against the committed blob `90dd4a2cbc00…`, differing by **one
  trailing space in S164's col 16** (`awk -F'\t' '$1=="S164"' … | cat -A` ⇒
  `.ufo/waves/round-64/capture/S143.body $` vs the committed `.ufo/waves/round-64/capture/S143.body`).
  Measured on that polluted tree, my derivation reads **narrow_bound=35 narrow_col15=30 /
  widened_bound=36 widened_col15=31** (receipt `derive3-l1polluted.txt`) — the numbers the
  polluted tree yields are one below the committed blob's. The L1's own committed
  `base-derivation.md` reports "BASE verified= 36 rendered= 31 col15match= 31", which
  matches the **committed blob's** narrow figures (36/31) — so the receipt was taken from
  a clean copy, but the *named* extraction path is polluted and a reader who re-runs
  against that path gets 35/30. Fix: the receipt must name the tree it was measured on
  by digest, and the polluted path must be regenerated or withdrawn.

---

## 2. The round's Gate row — material for the lesson's `## Gate`

One source opened this round (the plan's frontier step), by `R68ScoutSource`. The row is
admitted; everything below is measured from the committed capture and the committed receipt
(`.ufo/waves/round-68/capture/S167.fetch.txt`), not from the seat's prose.

| row | URL | access date | located quote (≤25 words) | capture | decision | reason / flip |
|---|---|---|---|---|---|---|
| S167 | https://www.rfc-editor.org/rfc/rfc4648.txt | 2026-11-08 (HTTP 200; response `Date` 12:23:20 GMT, 09:23:20 −03:00) | "Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data" (§3.3 Interpretation of Non-Alphabet Characters in Encoded Data, body lines 200–204 after the wrap is collapsed; **18 words**; `rendered-text-v1 locate` ⇒ `count=1`) | `.ufo/waves/round-68/capture/S167.body`, raw sha256 `84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f`, **35491 B**; normalized sha256 `30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9`, 28542 normalized bytes (refetch byte-identical, `cmp` rc 0) | **admit**, tier A, `mined`, `recheck 180d`, `used-by corpus/knowledge/source-capture-binding.md` | RFC 4648 §3.3 is a primary standards statement that a decoder MUST reject structured (base-encoded) data carrying characters outside the declared alphabet, and §12 (body lines 747–756) gives the security argument for rejecting rather than ignoring. It grounds the census's *record-level strictness* rule — a cell is either the exact form or a defect — at one remove (the RFC decides encoded fields, not TSV cells). **Flip**: a cited § that decides the record-level rule for a structured field directly, or an RFC revision that moves §3.3's MUST out of the rejection branch — see M68-5, which records that the row's current `teaches` cell grounds the rule on the RFC's *liberal* CRLF clause and should be re-cut onto §12. |

The seat's own drafted rows are in `.ufo/waves/round-68/w1/R68ScoutSource.md`; the landing is
in `corpus/SOURCES.md` (row `S167`) and `corpus/source-fetches.tsv` (row `S167`, col 16 the
pure path). I re-verified, independently: the capture's raw sha256 (35491 B), the quote's
`locate` count (1), and the normalized digest (`30194c4f…`, 28542 B) — all three match the
row. **The scout also put a `population.txt` in its receipts directory that derives
`verified=37 col15=32` on the BASE tree and calls it "the plan's frozen population"; that is
the *widened* reading (my `derive3-base-clean.txt` reproduces it exactly), not the
capture-path-shaped reading the frozen plan's own sentence defines, which is 36/31.** The two
differ by the mixed-prose S166 row, which is the whole subject of the round; the lesson must
not paste one as the other.

---

## 3. In-place registry changes (SOURCES contract v1 rule 2) — OLD → NEW

Read from the actual diffs, not from prose. Command:
`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff d3b2a4e8eed710277951e430efd3d27b5983033c -- corpus/SOURCES.md corpus/source-fetches.tsv`,
plus a per-column parse of both blobs (11 registry columns / 16 fetch columns) so that no
change is missed because a row is long.

Registry (`corpus/SOURCES.md`), 157 rows at BASE → 158 rows live; **no row removed**; one
row added (`S167`). Six in-place cells changed:

| id | column | OLD | NEW |
|---|---|---|---|
| S099 | 11 `used-by` | `corpus/lessons/round-44.md` | `corpus/lessons/round-44.md, corpus/knowledge/source-capture-binding.md` |
| S113 | 11 `used-by` | `corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md, corpus/knowledge/claim-instrument-carrier-binding.md` | …same three…, `corpus/knowledge/source-capture-binding.md` appended |
| S115 | 11 `used-by` | `corpus/knowledge/openbao-audit-device-custody.md, corpus/lessons/round-57.md` | …same two…, `corpus/knowledge/source-capture-binding.md` appended |
| S143 | 11 `used-by` | `corpus/lessons/round-63.md, corpus/knowledge/claim-instrument-carrier-binding.md` | …same two…, `corpus/knowledge/source-capture-binding.md` appended |
| S166 | 6 `anchor` | `§1.2 Concept Overview; capture \`.ufo/waves/round-67/capture/S166.body\` (67152 B, sha256 \`544dbb7d…\`); opened live 2026-11-08 with a browser user agent (HTTP 200, 67152 B, same sha256; receipt \`.ufo/waves/round-67/capture/S166.fetch.txt\`, refetch byte-identical; quote locate count=1 under rendered-text-v1)` | same, with ` — row col 16 recut to this pure path` inserted after the capture path |
| S166 | 16 (fetch TSV) `col16` | `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body` | `.ufo/waves/round-67/capture/S166.body` |

New row (not an in-place change): **S167** — RFC 4648, tier A, `mined`, `recheck 180d`,
`used-by corpus/knowledge/source-capture-binding.md`; fetch row col 16
`.ufo/waves/round-68/capture/S167.body`, col 10 `84e14418f795…`, col 11 `35491`, col 13
`Implementations MUST reject the encoded data if it contains characters outside the base
alphabet when interpreting base-encoded data`, col 14 `rendered-text-v1`, col 15
`30194c4ff628…`.

**Nothing else changed in place.** Per-column parse: no `status`, no `recheck`, no
`source`/`kind`/`tier`/`scope`/`teaches`/`opened` cell of any pre-existing id changed;
`malformed_rows=0` (contract's own awk: `NF!=13` ⇒ 0); registry row count 157→158 with
`S167` the only addition.

**Note for the L1 — the S166 `anchor` edit is a rule-2 event the contract names only
partly.** Contract v1 rule 2 (fleet `CORPUS.md`: *"Only `status`, `recheck` and `used-by`
change in place, and each change is logged old→new in the round lesson. A correction is a
new row whose `teaches` opens `supersedes S0NN —`"*) does not list `anchor`. The plan's
§C1 landing surface names the change (`corpus/SOURCES.md S166's col16 re-cut to the pure
path` — the registry has no `col16`; the anchor is column 6), so the change is planned and
measured, but it is a **column the contract's append-only rule does not cover**. The
lesson must log it explicitly (the pairs above) rather than fold it into the `used-by`
list, and the L1 may want to record it as an explicit contract reading — the round's own
precedent: round 66's closure (§Routed defect 7) was exactly this class of omission.

---

## 4. Closing numbers, one line per claim

- **C1 freshness** — **HELD at my last read**, on the live lane, rc 0:
  `C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1`
  (`bash plans/round-68-c1.sh --tree . --base-tree <fresh git archive of d3b2a4e8>`;
  receipt `c1-lane-run.txt`; every guard printed 1: `guard a=1 b=1 c=1 d=1 e=1 defe
  defects=0`; the derivation line reads `derived verified=38 col15=33 path_rows=38
  bound=38 located=38 prose=120 total=158 malformed=0`, anchor `S167`). **Two caveats the
  lesson must carry**: (i) the number is **38/33, not the frozen 37/32** — the frozen
  figures are the *recut-only* reading (measured independently by me: `derive-recut-only.txt`
  ⇒ `verified_widened=37 col15_matching=32` on a BASE tree with only S166's col 16
  re-cut), and the +1 is the round's own S167 frontier row (Amendment A1.2 states this;
  `R68ReviewerLayers` F0 independently measured 38/33 and named the same cause). The
  frozen `claims.json` string still says `verified=37 col15=32`; the lesson must state
  both readings side by side, as round 67's lesson did for its `bound`/`located` split.
  (ii) The gate's selftest was **red for part of the wave** and the counter's guard (b)
  read `selftest rc=1` because of it; it is green now (`SOURCES_CENSUS_SELFTEST: PASS (98
  cases)`, measured) and the counter reads guard (b)=1. The wave-process note must record
  the gate's revision sequence.
  (iii) **The BASE `caught=0/6` in the frozen predicate is anchor-selected, and the lesson
  must not repeat it as a clean baseline** (`R68Reviewer` B1, and my own row-order
  measurement agrees). The counter's `derive_anchor` admits a *mixed* cell's first token, so
  at BASE it anchors `S166` — the round-67 mixed-prose row the old gate never reads — and
  the six legs read `0/6`. The frozen text's own rule is "capture-path-shaped", whose last
  binding row at BASE is `S156` (measured: the last pure-path row in file order at BASE is
  `S156`, `.ufo/waves/round-66/capture/S156-429.body`); on `S156` the old gate already
  performs the bytes and digest comparisons, so M4 (`col10` hex flip) and M6 (one byte
  appended) are caught and the honest baseline is **2/6**. The delta the round actually buys
  is therefore **2/6 → 6/6 on the frozen anchor**, or `0/6 → 6/6` only under the widened
  anchor rule. State which; the milestone line as issued ("caught 0/6 → 6/6") is the widened
  reading. This is the L1's M68-2 seen from the counter side, and it is a *wording*
  correction to the claim, not a failure of the instrument (the instrument's six legs all
  fire on the candidate, measured).
- **C2 calibration** — **NOT HELD at my last read**. `plans/round-68-c2.sh --tree .` did
  **not** print a `C2_RECORD:` line in 3300 s of wall clock (my own run, timed out three
  times: 1800 s, 3300 s, 3500 s; receipt `c2-lane-run.txt` holds only the timeout
  marker). The counter seat's own last recorded run
  (`.ufo/waves/round-68/w1/R68ExecCounterC2/c2-run.txt`) reads **`C2_RECORD: mismatches=3
  population=3 guard=0`, RC 1** — i.e. the frozen target `mismatches=0 population=3
  guard=1` was **not** met at that reading, with all three legs reported `verdict=defect`
  (L1: "R21-03 expect carries no case count"; L2: "c2-verdict-unrecognised rc=124";
  L3: "suffixed-planned rc=0 … want rc=2 unrecognised" — that last one is M68-8, since
  closed by the wave). The ledger's `R68-02` row (`^C2_RECORD: mismatches=0 population=3
  guard=1$`) therefore does not yet have a producing run from me.
  **I measured where the wall clock goes** (so the L1 can judge whether the run is
  slow or stuck): the `cells` audit alone on the live tree is **1556 s** wall for
  `CELL_AUDIT: POLICY (cells=576 row_pointed=286 stamp_pointed=250 policy=3)` rc 2
  (receipt `cells-live-timing.txt`) — inside the counter's own `cells_run(timeout=3600)`,
  but that single leg consumes 43 % of a one-hour budget; `claim-ledger.sh verify`
  separately exceeds 300 s (my `ledger-verify-live.txt` is partial); the C1 counter is
  ~95 s. The counter is therefore **slow, not wedged**: its legs' own timeouts
  (3600 s cells + 1800 s C1 + verify) sum past the hour. **This is an honest stop, not a
  pass**: I report the counter seat's `mismatches=3 guard=0` as the last verdict line
  measured by anyone, and say plainly that I could not obtain one myself.
  **A caveat on that verdict's age**: it was measured at `corpus/claim-ledger.sh`
  `1f4bf1e74fdf…`, since superseded (`ca923b0d…`, `b0d84db6…`), and leg L3's defect is
  M68-8 — closed on the current bytes by my re-measurement. So `mismatches=3` is a
  *stale* reading of two now-corrected legs, not a proven failure of the final tree; and
  `mismatches=0` is *not yet measured by anyone*. The honest status is **unmeasured at
  the final bytes**, which is what the lesson must say rather than either number.

---

## 5. Wave-process note — instruments moved during the wave

Every receipt pins the bytes it tested; the moving target is recorded rather than smoothed.

| instrument | revisions observed this round (sha256, first 16) | pinned by |
|---|---|---|
| `corpus/sources-census.sh` | `e7aacecdfcf06ed6` (BASE, round-67 landed) → `6173eab7b7a2b705` → `d74a4183355988f9` → `fd3cb5981f1d1caa` → `6f18c608052fccf9` → `84725a7e9930f1b2` → `b93f06148a73fd9b` → `690b0c2ec2a469fe` (last read) | `R68Sentinel` §1 (four revisions, each result labelled with the byte-state it was measured on); `R68ExecGate` §Verification (`PASS (98 cases)`, `SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)`); `R68ExecCounterC1` `gate-selftest.txt`; my `c1-lane-run.txt` (measured on the tree as it stood) |
| `corpus/claim-ledger.sh` | `ec915f604ba6dce3` (BASE) → `7fbf455b4806` → `e44aa1a` → `1f4bf1e74fdfc547` → `ca923b0d942f2334` → `b0d84db605557b28` (last read) | `R68ExecLedger` §Stamps (pins `1f4bf1e74fdf…`); my `ledger-verify-live.txt` (reports `STALE corpus/claim-ledger.sh sha=1f4bf1e74fdf->ca923b0d942f`) |
| `corpus/source-fetches.tsv` | `90dd4a2cbc006cdf` (BASE) → `682ef5455cabe799` → `c14bcd885df2ae44` (live) | `R68ExecRecut` `sha256.txt`; `R68ExecCounterC2/candidate-verify.txt` |
| `corpus/SOURCES.md` | `9590e7e73ec84db6` (BASE) → `88990e062827f772` → `688fbab4714988ea` (live) | `R68ExecRecut` `sha256.txt` |
| `plans/round-68.md` | `23a8e029` (frozen predeclaration) → `4251519` (Amendment A1, before any counter existed on disk) | `git show 4251519`; `R68ReviewerLayers` F0 disposition |

Two consequences the lesson should record, and one the wave closed by itself:

1. **The gate's own selftest count moved three times in one round** — 89 at BASE, 98 on
   the landed gate, with a red interval in between (`FAIL (98 cases, 3 failed)`,
   then `2 failed`, then `1 failed`, measured by me at three separate reads). The `R21-03`
   ledger pin was migrated `88 → 89` mid-wave by `R68ExecLedger` and then again to the
   final `98`; the journal pair is now `88 → 98` (`.ufo/waves/round-68/journals/expectation-migrations.json`).
   The rule this exposes is the one the plan already names (QM90): a pin that is a
   literal in the ledger must be re-pinned from the *landed* gate's own PASS line, never
   from an earlier revision's count. The pin's history across rounds is the pattern the
   round-68 lesson should name as a mistake class: `70 → 78` (round 55 journal),
   `78 → 88` (round 67 journal), `88 → 98` (round 68 journal) — a literal that has gone
   stale on contact **three times in three rounds**, each time needing a migration
   journal entry. The rule that should have caught it: the selftest case count must be
   *derived* by the ledger's own verifier (compare the printed count, never the literal),
   or the gate must not be free to add cases without a pinned migration.
2. **The counter's `verified`/`col15` numbers are derivation-dependent and the derivation
   must be pinned.** Three different derivations of the same word ("verified") were run
   this round — the plan's own widened population (my `derive3`), the counter's pure-cell
   rule (`plans/round-68-c1.sh`), and the narrow "shaped" rule in the L1's
   `base-derivation.md` — and they give **37/32 (plan, widened), 36/31 (counter, pure
   cells), 36/31 (L1, narrow)** on the same BASE tree. The lesson must state which rule
   produced which number, because the three differ by exactly the mixed-prose row the
   round is about.
3. **A class the wave closed by itself (the counter↔parser disagreement, M68-8).** The
   C2 counter's leg L3 and the cells parser disagreed about which planned headings are
   legal; the parser's `PLANNED_SECTION_RE` was tightened and the counter updated to
   match, and my re-measurement of the current pair agrees on all three directions.
   This is the wave working as intended, but the lesson should record the *pattern* the
   disagreement exposes: a counter's negative control and the instrument it tests are two
   different artefacts, and when they disagree the instrument is not automatically the
   one that is wrong — here the counter's expectation was the frozen one (the plan's L3
   names the heading, not the heading-plus-suffix), so the parser moved.

---

## 6. Tooling

No tool was installed or upgraded. Read `/home/vgpnk/.omp/agent/RULES.md` (operator rule,
2026-10-19); the directive is satisfied vacuously — **no install, no update, no version
change, no channel used**, and **no pacman transaction** (pacman is paused host-wide).
Host tools used as they stand: `bash`, `python3` (3.14.8, `/usr/bin/python3`, stdlib only),
`git` (read-only: `log`/`show`/`diff`/`status`/`ls-files`/`rev-parse`/`archive`/`cat-file`),
`grep`/`awk`/`sed`/`sha256sum`/`wc`/`cat -A`/`stat`. Every python script is stdlib-only
and none is committed.

Scratch: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r68/R68ScribeLesson/` — BASE extracted
with `git archive d3b2a4e8eed710277951e430efd3d27b5983033c` (never a mutation of the lane),
all mutation fixtures as full copies under `work/`, receipts copied into
`.ufo/waves/round-68/w1/R68ScribeLesson/` before the scratch directory was deleted.

---

## 7. Dead ends and limits (measured, not smoothed)

- **`plans/round-68-c2.sh --tree .` produced no verdict line in any run I made** (1800 s,
  3300 s, 3500 s, and a final background run). **I measured where the wall clock goes**
  rather than guessing: the `cells` audit alone on the live tree is **1556 s** for
  `CELL_AUDIT: POLICY (cells=576 row_pointed=286 stamp_pointed=250 policy=3)` rc 2
  (`cells-live-timing.txt`) — that one leg is inside the counter's own
  `cells_run(timeout=3600)` but consumes 43 % of an hour; `claim-ledger.sh verify`
  separately exceeds 300 s; the C1 counter is ~95 s. So the counter is **slow, not
  wedged**. **Not fixed by me** (not my file); the fix is to bound `cells` (it re-runs
  every cited ledger row, `rows_run` in the hundreds) or to let the C2 counter take a
  pre-computed `cells` verdict.
- **The C2 counter's `--selftest` never produced output** in the seat's receipt
  (`c2-selftest.txt` is 0 bytes). `R68MutGate` §3 measured the same counter's selftest
  failing earlier at `9b32226f…` (`C2_RECORD_SELFTEST: FAIL (7 cases, 1 failed)`, case
  `positive`); at least one of those readings is the L1-parser defect now repaired
  (M68-9's "closed during the wave" item), but I did not obtain a green selftest line.
- **`bash corpus/claim-ledger.sh verify` on the live tree exceeded 300 s** (my run timed
  out; the receipt `ledger-verify-live.txt` holds the partial output). It reports
  `STALE` for six files (the ones still being edited this round) and `HOST-SKIP` for six
  host rows; it does not reach a `CLAIM_LEDGER:` verdict line within the budget.
  **`CLAIM_LEDGER: CLEAN` is therefore NOT observed by me** — I report the partial
  reading only.
- **`expect-journal.sh` with the live tree as its own `--base-ledger`** ⇒
  `EXPECT_JOURNAL: WARN ORPHAN R21-04` / `WARN ORPHAN R24-14` / `CLEAN (changed=0
  journaled=0)`; with the true BASE ledger (`git show d3b2a4e8:corpus/claim-ledger.tsv`)
  it reads **`EXPECT_JOURNAL: CLEAN (changed=5 journaled=5)`**, exit 0. The orphan warnings
  are the tool noticing that it was handed no base — not a defect in the journal.
- **The L1's BASE extraction at `/fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e` is
  polluted** (one trailing space in S164's col 16: `aa6fa318…` vs the committed
  `90dd4a2c…`) — my derivation on it reads narrow 35/30, widened 36/31
  (`derive3-l1polluted.txt`). It was corrupted a **second** time by a hardlink clone, per
  `R68MutGate` §5 F6. The L1's own M68-3 records the first; the finding is that a shared
  writable BASE extraction is not a control (see §1, "Closed during the wave").
- **The `## Round 63 — planned` shape**: the landed parser *skips* the planned heading and
  still audits any table under it (measured: a pointerless six-axis table under a planned
  heading ⇒ rc 1, `UNCITED … adjacency`, `CELL_AUDIT: BROKEN (cells=12 … uncited=6)`);
  a *suffixed* planned heading (`## Round 63 — planned (claims C1 freshness)`) is silently
  accepted as planned (rc 0, `CELL_AUDIT: CLEAN`) — a named ceiling, and the source of
  M68-8's leg mismatch. On the BASE parser the same fixtures die with exit 2 on the
  unrecognised heading.

---

## Receipts (`.ufo/waves/round-68/w1/R68ScribeLesson/`)

| file | what it shows |
|---|---|
| `derive3-base-clean.txt` | my independent population derivation on a fresh `git archive d3b2a4e8` tree: narrow 36/31, widened 37/32 (the plan's own BASE figures) |
| `derive3-l1polluted.txt` | the same derivation on the L1's polluted BASE extraction: narrow 35/30, widened 36/31 |
| `derive-recut-only.txt` | BASE + S166 re-cut only: `verified_widened=37 col15_matching=32` — the frozen 37/32 reading, independently reproduced |
| `derive-live-tree.txt` | the same derivation on the live tree: 38/38, col15 33 |
| `derive-base.txt`, `derive2-base.txt` | first-pass derivations (same figures, earlier script) |
| `cells-base.out` | the BASE `claim-ledger.sh cells` output: the `unrecognised round heading` die on `## Round 63 — planned` — and **no `SETUP` token anywhere** (M68-6) |
| `c1-lane-run.txt` | `C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1`, rc 0, all guards 1 (C1's closing line) |
| `c2-lane-run.txt` | the C2 counter's runs: only its provenance header line, then the timeout marker — no verdict line (C2's honest stop) |
| `cells-live-timing.txt` | the `cells` audit on the live tree: 1556 s, rc 2, `CELL_AUDIT: POLICY (cells=576 … policy=3)` |
| `ledger-verify-live.txt` | partial `claim-ledger.sh verify` on the live tree: six `STALE` files, six `HOST-SKIP` rows, no `CLAIM_LEDGER:` verdict within 300 s |
| `instruments-pinned.txt` | the sha256 of every instrument each receipt above was measured against, including the three revisions of the gate and the four of the ledger, so no count here is un-pinned (`R68Reviewer` B7's class) |

Report: .ufo/waves/round-68/w1/R68ScribeLesson.md
