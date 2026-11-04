# Round 14 — the knowledge surface gets a re-verification link (and a plan is falsified)

Axis moved: **freshness 8 → 9**. Calibration stays at 9 with the increment
recorded, because this round is where round 13's calibration plan was *measured
and found unreachable*, and the honest replacement landed somewhere else — on the
entry surface, where the gap is 0 → 17 instead of 5 → 30.

Revision: `corpus/claim-ledger.sh` shipped at the hash stamped in
`corpus/stamps.tsv`; all 17 `corpus/knowledge/*.md` entries carry a declaration
and a revision pin for the first time.

## What the pre-state actually was (measured three ways)

At `4b8c018`:

- **1 of 17** `corpus/knowledge/*.md` entries named any claim row at all (and
  the one that did was `claim-ledger.md`, which also cites the illustrative `R13-99`).
- **0 of 17** declared a re-verification of any kind — `grep -c '^Reverify:'`
  over the directory was `0`.
- **10 of 17** were not rows in `corpus/stamps.tsv` — the pin set covered 7
  knowledge entries, so ten entries had no revision pin either.

Reproduced independently three times at the frozen revision: the L1 census, the
pre-state scout's own python census (frozen blobs *and* live tree), and the
drafter's `grep`. The scout also corrected two of my dispatch numbers: the
scorecard has **5 pre-move + 5 post-move** sections (not 6 + 4), and
`stamp_pointed=41` is a different quantity from "stamp-only cells = 35" (it
counts cells holding ≥1 stamp token, including cells that also hold a row id).

## The round-13 plan, split by measurement (one half landed, one half refused)

Round 13's `Planned` block demanded: raise `row_pointed` to **at least half** the
checked cells by adding ledger rows for the quantities the historical cells
assert. At the dispatch revision that is 30 of 60 cells; after this round's own
12 cells it would be 36 of 72.

I first wrote this off as unreachable. **That was wrong, and the L2 wave caught
it.** Two measurements, taken with different rubrics:

- **Critic (executed):** of the 35 row-less cells, **0** where a *newly written*
  row would honestly support the score beside it.
- **Pre-state scout (own census, own rubric):** 11 cells are **H**istorical
  snapshots bound to a past revision, 19 are **N**arrative/ownership claims with
  no command shape, and 5 (**+2 borderline**) are **R**eachable by a row that
  already exists.

The scout's five are the ones whose **Evidence column already quotes a live
command** — the row id was simply never written beside it. So the *ratio* half of
the plan was reachable, exactly at the boundary: citing `R11-01` (round-10
coverage), `R11-03` (round-10 calibration), `R11-09` (round-12 operability),
`R11-04` (round-12 freshness) and `R11-01` (round-12 coverage) lifts
`row_pointed` 25 → 30 of 60, and the cells' own text already names the commands
those rows re-run. **Round 14 wrote those five pointers**, which is the round-13
target landed in its reachable form. What stays refused is the other half — rows
that re-derive *historical* numbers, which would contradict the cells they sit
beside. The distinction to keep: **0 rows writable, 5 rows already written.**

The correction is recorded here rather than smoothed over, because the shape is
the round-12 lesson repeating: my own sentence about what was unreachable was
itself the thing worth measuring, and a lane that reproduced it independently
found the boundary case.

**The replacement** puts the floor where the distance is real. On the entry
surface, "no declaration at all" is 17 of 17, and "declared + pinned" is 17 of
17 after the move — so a floor (`row_linked*2 >= entries`) has something to bite
on, and the escape hatch (`by-hand:`) is an explicitly counted set instead of a
silent one.

## What landed

1. **A sixth mode `docs`** in `corpus/claim-ledger.sh`: every
   `corpus/knowledge/*.md` entry must carry exactly one declaration —
   `Reverify: R11-04, R11-05` (ids that must resolve) or
   `Reverify: by-hand: <class> — <reason>` with a closed class set
   (`control-plane-scratch|opencode-internal|interactive-only|vault-refusal`) and
   a **unique** reason of ≥24 characters — and must be a row in
   `corpus/stamps.tsv`. Exit 2 for shape (no entries, a second declaration, a
   malformed `Reverify` line, an unknown class, a short/padded reason); exit 1 for
   defects (`UNDECLARED`, `MISSING-ID`, `UNPINNED`, `DUPLICATE-REASON`, `RATIO`).
2. **17 declarations**, from two independent L2 drafts that agreed on 14 of 17
   entries' row sets and on the 3 by-hand entries. Three of my draft links were
   **rejected with evidence** and replaced:
   - `janitor-lifecycle`: `R11-10` dropped (it counts rows in `state-shape.tsv`,
     a file the entry never cites) → `R11-01` (live lock/session-id/DB/log modes);
   - `op-env-refs`: same `R11-10` rejection → `R11-02` (the `refs`-shape probes);
   - `handler-on-disk-state`: `R11-06` kept, `R11-10` replaced by `R11-01` — the
     scout's rule was *"declare a row iff its verdict changes when the entry's
     asserted fact changes"*, and a pin-file row count is not the host.
   Additions adopted from the same review: `R11-08` on `claim-ledger` (the row
   that re-runs the citation gate whose Class-3 numbers the entry publishes),
   `R11-01` on `credential-isolation`, `R11-02` on `janitor-env-contract`, and
   `R11-10`+`R11-11` on `surface-census` (that entry *prints* 22 and 35 rows).
3. **All 17 entries stamped** — the pin set went 33 → 44 rows; ten entries had
   never been pinned, and the three by-hand entries are exactly among them.
4. **Ledger rows**: new `R14-01` (`bash corpus/claim-ledger.sh docs`, the summary
   counts are the claim), and four counted rows re-pinned because this round
   moved their quantities: `R11-09` (72 → 94 cases), `R12-03` (33 → 44 stamp
   rows), `R13-01` (10 → 12 round sections), `R13-02` (17 → 18 rows).
5. Docs: `knowledge/claim-ledger.md` §Class 6 + seven bounds (17–23) + a
   Round-14 before→after table, `SKILL.md`, `PROVINCE.md`, `corpus/README.md`,
   `SCORECARD.md` (round-14 pre/post + the split plan + ceilings), `LOG.md`.
6. **Five score-card pointers** — the reachable half of the round-13 target: the
   round-10 coverage / calibration / operability cells and the round-12 freshness
   and coverage cells now cite `R11-01`, `R11-03`, `R11-09`, `R11-04`, `R11-01`,
   the rows that re-run the commands those cells' own Evidence columns already
   quoted. `row_pointed` 25 → 30 of the pre-round-14 60 cells (38 of 72 after this
   round's own cells), so the round-13 floor is now met rather than only argued
   about.

## The defects this round found in its own first implementation

Each was found by execution, not review:

| Defect | How it surfaced | Fix |
|---|---|---|
| `nrows: unbound variable` on the `UNDECLARED` path under `set -u` | the live run printed `UNDECLARED` and then died with an unbound-variable error; the selftest case for that message **passed anyway** (it asserted the message + exit 1) | counters initialised before the branch chain, and the case upgraded to `tcase_last`, asserting the exact `DOC_AUDIT: BROKEN …` summary — which is what would have caught the abort |
| a directory of only hidden entries reported `no knowledge entries` instead of naming the hidden file | selftest `docs-hidden-entry` failed | the hidden-entry refusal moved **before** the empty-surface refusal |
| a fabricated declared id was counted in `row_linked` | scribe lane's fixture: `Reverify: R11-04, R99-99` ⇒ `MISSING-ID` **and** `row_linked=2` | `row_linked` counts only ids that resolve, and a case now pins the summary for that fixture |
| a 24-space by-hand reason passed the ≥24-char floor | mutation lane's predicted class; implemented and executed | the reason is trimmed before measurement; case `docs-padded-reason` ⇒ `reason is 0 chars` |
| a `Reverify`-starting line that is not a declaration (`Reverify:` with no space, a detached colon) read as `UNDECLARED` | planner lane (it read a mid-flight revision but the finding was about a *missing* guard, not the revision) | a count comparison refuses any `Reverify`-prefixed line that is not `Reverify: ` (exit 2); case `docs-malformed-line` |
| 17 identical by-hand reasons would have satisfied the rule | critic lane's executed fixture | `DUPLICATE-REASON` (case-folded, whitespace-collapsed), exit 1 |

Two of my own `edit` calls also **deleted a section heading** in
`credential-isolation.md` and `janitor-command-surface.md` (and, on repair, one
more in `janitor-env-contract.md`) by anchoring on a heading and not reproducing
it. Caught by a post-edit heading census; all three restored and the census
re-run. Recorded because the same trap will fire for any lane that edits
Markdown by anchor.

## The L2 wave — what each lane attacked, and what happened to it

14 lanes in one batched dispatch; the distiller ran too early (empty wave),
reported that honestly, and was revived after the wave.

| Lane finding | Disposition |
|---|---|
| **DesignCritic (executed):** 17 identical by-hand reasons ⇒ `CLEAN`; an entry citing a resolving-but-unrelated row ⇒ `CLEAN`; **0 of 35** stamp-only cells have an honest live row | **Adopted as the round's design input.** Duplicate reasons became a defect; the unrelated-row residual is bound 17 (a declaration is a pointer, not relevance) and *the forbidden sentence* it named is not in any doc: the round never claims the entries' sentences are verified. |
| **DesignCritic:** reachability arithmetic (0 < 30, 0 < 36) | Used as the falsification evidence beside the scout's independent H/N/R census. |
| **PreStateScout:** independent pre-state (17/7/1/0) + cells 60/25/41 + **5 pre / 5 post** sections + "stamps.tsv has no header line" + **it falsified my own "unreachable" reading by naming five cells whose Evidence already quotes a live command (25 → 30/60)** | All adopted. The false claim was mine, it was in the dispatch brief, and the correction is the round's sharpest lesson: a sentence about what is *unreachable* is itself a measurement. The dispatch numbers it corrected are corrected in the report and here. |
| **EntryEvidenceScout:** per-entry verdict table, 3 rejections of my draft links, 4 additions, and the criterion *"declare a row iff its verdict changes when the entry's fact changes"* | Adopted wholesale (see §What landed 2). Its "residual: `transcript-hygiene`'s `--classify` triage is un-rowed" is recorded as a residual, not fixed. |
| **ReverifyDrafter (independent):** same 14/3 split, 5 disagreements with my draft | Used as the second opinion; adopted where it and the scout agreed, and my superset kept where they diverged (`op-env-refs` keeps `R12-01`). |
| **DocsModeExecutor (independent implementation):** a full parallel `docs` mode + 18 cases + a documented ambiguity list | Read and mined for cases (`docs-ratio-at-floor`, `docs-entry-detail`) and for the recorded divergence on the declaration token: it accepted `Reverify:by-hand: …` after trimming, the shipped code requires the `Reverify: ` spelling and refuses the rest loudly. Divergence recorded, not smoothed. |
| **MutationTester:** 18 mutations, 0 guard-killed at its read revision, `docs-raw-12`/`docs-summary-order`/`docs-hidden-entry` demanded | Cases added: malformed line, padded reason, hidden entry, ratio floor + boundary, summary-last (`tcase_last`). The rest are covered by the shipped cases. |
| **Sentinel:** 31 probes, no reachable vulnerability at its revision; zero-entry must be exit 2 per the setup convention | Confirmed and implemented; its `..`/absolute stamps probes re-verified by the existing cases. |
| **Labrat (executed):** the cheapest `docs` CLEAN path — 9 entries declaring one broad row, 8 unique by-hand reasons, all stamp *members* (a fabricated `deadbeef` row passes `docs` and fails `verify`) | **Adopted as bound 19/20** in `claim-ledger.md`: the floor is coverage, and `docs` checks membership while `verify` checks freshness. |
| **Simplifier:** delete the per-entry `ENTRY …` detail lines (diagnostic only); keep everything else | **Dissent recorded, not adopted.** The detail lines are what makes the by-hand set visible without opening 17 files (cost: 17 lines of output). Everything else was kept for the stated reasons. |
| **NumberReviewer:** the landing-invalidated number table (17→18 rows, 33→44 stamps, selftest count *not derivable*, PROVINCE:41 / README:56-57 / claim-ledger.md:6,240,243) + six already-stale historical numbers | Adopted; the "not derivable — take it from the tool" warning is why `R11-09` was re-pinned from the actual run (94), not from a guess. |
| **Planner:** exit-1 vs exit-2 classification review, acceptance order, and the mid-flight spec divergence (`DUPLICATE-REASON`, extra summary fields, case counts) | The malformed-line guard came from here; the divergence is recorded above as a revision fact (round-12's lesson repeats: a declared freeze is stale on arrival — every lane named the hash it read). |
| **Connector:** sibling doc-linkage verifiers | Report-only, per adjacency: kotoba `verify_skill_checklist.py` (checklist box → disposition), kotoba `verify_corpus_independent.py` (README index coverage), kumitate `proxy-check.mjs` (documentation-coverage score inside a composite), kasegi `anchorcheck.py` (mirror `path:line` resolution), kengaku `grader.py` (replays hard-coded report tables). All *adjacent*: different unit, none binds an entry to a re-runnable claim row. The shared-contract question goes to the integrator. |
| **Scribe:** §Class 6 draft + README/PROVINCE/SKILL deltas + the honest paragraph | Structure adopted; its stamps count (43) corrected to 44 (it could not know about the round-14 lesson row). |
| **Distiller:** first run found no lane artifacts and said so instead of inventing a synthesis | Revived after the wave; its output is the merge aid for this table. |

## Evidence (shipped revision)

```
bash corpus/claim-ledger.sh docs
  → DOC_AUDIT_RATIO: row_linked=14/17 floor=9 by_hand=3 duplicate_reasons=0
  → DOC_AUDIT: CLEAN (entries=17 row_linked=14 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)
  pre-move, same mode on the same corpus: BROKEN (entries=17 row_linked=0 by_hand=0 undeclared=17 … unpinned=10) exit 1
bash corpus/claim-ledger.sh --selftest   → SELFTEST: PASS (94 cases)
bash corpus/claim-ledger.sh verify       → CLAIM_LEDGER: CLEAN (claims=18 stamped=44 ids=18 cited=18 labeled_ids=17 orphans=0)
bash corpus/claim-ledger.sh cells        → CELL_AUDIT: CLEAN (cells=72 row_pointed=38 stamp_pointed=47 uncited=0 missing_ids=0 rows_run=14 row_failures=0 stale_pointers=0 self_skipped=4 orphans=0)
bash corpus/claim-ledger.sh citations    → CITATION_GATE: CLEAN (cites=734 docs=45 unresolved=0 ephemeral=0 labeled=13)
```

Siblings unchanged: `DRIFT_PINS: CLEAN (files=15 symbols=20)` + 13-case selftest;
`SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`
+ `--verbs CLEAN (pass=7 skip=3)` + 16 cases; `TRANSCRIPT_SCAN: HITS=2` exit 1 by
design; `OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)`
+ 29 cases (the ledger's `verify`/`cells` runs execute this gate; it execs `op run`
over **generated fabricated plain values** and refuses any op-side ref token
before exec, so the round's "no op execution" constraint holds for lanes and the
gate is unchanged from round 12).

## Bounds and residuals

- **A declaration is not relevance.** Bound 17, and the round's forbidden
  sentence stays unwritten: nothing here claims the entries' sentences are
  machine-checked, and the floor counts entries, not evidence (the labrat lane's
  9-row path satisfies it).
- **The three by-hand entries are named, not excused**: `config-layering`
  (`opencode-internal`), `control-plane-hardening` and `handler-trust-boundary`
  (`control-plane-scratch`). Each reason names the measurement and, where one
  exists, the row that covers the rest (`R11-04`, `R11-01`).
- **Residual, recorded not fixed:** `transcript-hygiene`'s `--classify` triage
  (the mode that separates the two `xai-` prose collisions from key-shaped hits)
  has no row; `handler-on-disk-state`'s counts are re-printed by `R11-01` but not
  pinned by it (the shape pins are floors); most sentence-level numbers in all 17
  entries still rest on prose.
- **The freeze moved under the wave, and lanes said so.** Every lane named the
  hash it read; two lanes (planner, executor) read a mid-flight revision and
  still produced usable findings because of it.