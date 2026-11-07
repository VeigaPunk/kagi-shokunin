# Round 62 — kagi (secrets & vault ops)

Lane: kagi. Round 62, attempt 1. Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`
(round-61 verifier spot-check tip). Frozen plan `plans/round-62.md` (predeclaration
`8e5463c7937dccdd97fd5a812b8091f83b708aa7`). Wave `kagi-r62-w1`, 14 seats (v1 band 8–16;
plan §Wave plan).

Claims: **C1 calibration** — the C1 checker's negation / swapped-pairing bypass class is
closed (`C1_BYPASS` accepted 5 → 0, population 5). **C2 operability** — the C2 counter's
guard and self-invocation can fail (`C2_HARDENED` killed 0 → 3, population 3).

## Gate

Seven pages were opened live this round (S128–S134; access date 2026-11-07 for every row).
The scout's capture ledger `.ufo/waves/round-62/capture/notes.md` carries the fetch record,
the raw byte offsets, the `rendered-text-v1` locate output and the per-row flip condition;
the captured bodies are `.ufo/waves/round-62/capture/S128.body` … `S134.body`, and every
admitted quote below prints `RENDERED_TEXT_V1_LOCATE: count=1` under
`python3 corpus/rendered-text-v1.py locate <capture> "<quote>"` (scout receipt
`build/R62ScoutSources/locate-output.txt`). Four rows are admitted and three are rejected;
each rejected candidate stays as a row with its measured reason and flip (plan §Frontier).
The scribe re-resolved all seven strings independently; the output is
`build/R62ScribeRecords/gate-quotes.txt` (five `count=1`, two `count=0` for the rejected
pages' probe terms).

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S128 | https://pitest.org/ | 2026-11-07 | `If your tests fail then the mutation is killed , if your tests pass then the mutation lived .` (19 words; §"What is mutation testing?"; capture 12023 B, sha256 `b0c7e050…`) | admit, tier A | the tool's own definition of the two mutant outcomes — a mutation the suite fails is *killed*, one it passes *lived* — and the kill count is the score; this is the definition C2's kill contract rests on. Flip: a revision that redefines or removes the killed/lived passage |
| S129 | https://stryker-mutator.io/docs/ | 2026-11-07 | `If your tests fail then the mutant is killed . If your tests passed, the mutant survived .` (18 words; §"What is mutation testing?"; capture 30253 B, sha256 `18513008…`) | admit, tier A | the second, independently maintained tool's statement of the same dichotomy, and it uses the word the predicate names — *survived*; two vendors with different prose attest the rule. Flip: a revision renaming the reporter statuses away from killed/survived |
| S130 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml | 2026-11-07 | `In the NegEx algorithm the scope of a trigger term is a priori restricted to a window of six tokens` (20 words; §"3.1.4 ConText and NegEx"; capture 189603 B, sha256 `cdbb4173…`) | admit, tier A | states NegEx's rule, not only its name: a negator trigger with a bounded token window — the shape of the C1 hardened grammar's polarity rule. It grounds the rule's shape, not the round's 5-token window (a named floor). The committed body is the NLM PMC XML deposit, not the article HTML (the HTML embeds a per-request session token). Flip: a revision that removes the ConText/NegEx comparison |
| S131 | https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=5863758&retmode=xml | 2026-11-07 | `A negation detection algorithm, NegEx, applies a simplistic approach that has been shown to be powerful in clinical NLP.` (19 words; Abstract; capture 101800 B, sha256 `80ec4326…`) | admit, tier A | names NegEx as the negation-detection algorithm; its second Abstract sentence states the failure mode — `NegEx fails to correctly capture the negation status of concepts in complex sentences.` (13 words) — a found trigger is not the assertion's being negated, the error class the C1 grammar narrows. Committed body is the NLM PMC XML deposit (token-free). Flip: a revision that drops the Abstract's NegEx characterisation |
| S132 | https://pubmed.ncbi.nlm.nih.gov/11554662/ | 2026-11-07 | none — the body is a cookie-wall shell; `locate S132.body "negation"` ⇒ `count=0` (capture 5590 B, sha256 `1c7cd57e…`) | reject | HTTP 203 and a 5590-byte cookie wall on 5 attempts, no abstract and 0 occurrences of `negation`; separately, `EXT_ID:11554662` in Europe PMC resolves to a 2001 rhinology case series, not NegEx (the seat's candidate list, not the frozen plan, names the PMID). Flip: a fetch that yields the NegEx abstract body, or a corrected PMID |
| S133 | https://en.wikipedia.org/wiki/Mutation_testing | 2026-11-07 | `If the test suite is able to detect the change (i.e., one of the tests fails), then the mutant is said to be killed .` (25 words; §"Mutation testing overview"; capture 171636 B, sha256 `05dbe35f…`) | reject | tertiary and editable, and incomplete on the pair C2 rests on: it defines the *killed* side but `surviv` occurs 0 times in the captured body, so the surviving mutant is unnamed. Flip: a revision that names both outcomes and cites a primary definition for each |
| S134 | https://stryker-mutator.io/docs/mutation-testing/ | 2026-11-07 | none — HTTP 404 shell; `locate S134.body "mutation testing"` ⇒ `count=0` (capture 14498 B, sha256 `f5a45b48…`) | reject | the plan's optional third candidate URL does not exist (HTTP 404, the site's own "Page Not Found"); the definition was taken from the live index page (S129). Flip: the site publishing that page, or the 404 shell becoming a redirect |

Registry effect: `corpus/SOURCES.md` 127 → 134 data rows
(`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` ⇒ 127 at BASE `60b5b7b`, 134 now) and
`corpus/source-fetches.tsv` 170 → 177 lines (`wc -l`, same two revisions); the seven rows
are S128–S134, appended, with no existing cell rewritten. The census reading is the L1's
candidate gate.

Two reported defects, not amended (the plan is frozen and names no PMID): the seat's
candidate list points PMID `11554662` at NegEx while Europe PMC resolves it to a 2001
rhinology case series; and `pubmed.ncbi.nlm.nih.gov` serves a 203 cookie wall from this
host, so no PubMed row can carry a located quote (the PMC mirror does).

Re-pin required for S130/S131: both rows were first pinned over the PMC article HTML,
whose bodies were replaced by the token-free NLM XML of the same records. The values above
are the re-pinned ones (`capture/notes.md` §"RE-PIN REQUIRED"; scout receipt
`build/R62ScoutSources/repin-table.txt`); the current `corpus/source-fetches.tsv` cells are
stale for those two rows until the L1 applies the table. The vocabulary fact matters for
any later wording: PIT says *lived*, not *survived* (`surviv` occurs 0 times in S128's
body), and Stryker says *survived*.

## Mistakes

| id | class | evidence pointer | captured-by | fix (and how it can fail) |
|---|---|---|---|---|
| M62-1 | record vs artifact — a SCORECARD cell states a controls count the committed receipt contradicts | `SCORECARD.md:2056` reads `CONTROLS: match=17 mismatch=0`; the receipt `.ufo/waves/round-61/controls/controls-prefreeze.txt` carries `grep -c '^CONTROL '` ⇒ 18 and line 29 `CONTROLS: match=18 mismatch=0`; `LOG.md:1990` reads `match=18` | round-61 verifier spot-check §7.1 (non-author) | the appended errata at `SCORECARD.md:2108` names the superseded line, the receipt path and the derived count (18 `CONTROL ` lines), and does not rewrite `:2056` (QM78). **Able to fail**: `plans/round-62-routed.sh` leg `d1` requires the last correction line to carry `match=18`, the receipt path and a receipt with 18 `CONTROL ` lines; a correction carrying the stale 17 reads `d1=0` |
| M62-2 | registry omission — three gates landed with no `SKILL.md` registry row, so closure could not grade them conformant | `git show 60b5b7b:SKILL.md \| grep -c 'round-61-c1-check.py\|round-61-c2.sh\|openbao-seal-trial.sh'` ⇒ 0 | round-61 verifier spot-check §7.2 | six registry rows added (three round-61 gates, three round-62 instruments), each `kind: gate` with a runnable self-invocation and no `none of its own` (QM76). **Able to fail**: `plans/round-62-routed.sh` leg `d2` reads `rows=6/6` only when every row's kind is `gate`, its selftest cell is non-empty, and the cell carries no `none of its own`; dropping one row or blanking one selftest cell reads `d2=0` |
| M62-3 | receipt absence — the candidate-revision readings exist only as report prose, so the before→after is not re-derivable from committed bytes | `git ls-tree -r --name-only 08f950d .ufo/waves/round-61/final/` ⇒ no rows; the round-61 report carries the candidate readings and the committed controls receipt is the pre-freeze working tree | round-61 verifier spot-check §7.4 | `.ufo/waves/round-62/final/candidate.txt` names `candidate=<40-hex>` and carries both verdict lines. **Able to fail**: `plans/round-62-routed.sh` leg `d4` requires the named revision to exist, to be an ancestor of `master`, and the file to carry `C1_BYPASS: accepted=0 population=5 guard=1` and `C2_HARDENED: killed=3 population=3 guard=1`; a report-only reading reads `d4=0` |
| M62-4 | receipt absence, ancillary half — three gate verdict lines in `LOG.md` have no committed receipt | `LOG.md:1991` carries `DOC_AUDIT: CLEAN …`, `RELEASE_CLOCK: CLEAN …` and `CLAIMS_DECLARED: CLEAN …`; `.ufo/waves/round-61/final/` holds no rows (`git ls-tree -r --name-only 08f950d .ufo/waves/round-61/final/`) | round-61 verifier spot-check §7.5 | one receipt per gate line under `.ufo/waves/round-62/final/`, each cited from `LOG.md`. **Able to fail**: `plans/round-62-routed.sh` leg `d5` requires each of `release-clock.txt`, `doc-audit.txt`, `claims-declared.txt` to carry a line starting with its label and `LOG.md` to cite the path; a missing receipt or an uncited path reads `d5=0` |
| M62-5 | instrument self-invocation — the C2 counter's `--selftest` never executes its aggregation, so a constant value or shim block passes | at BASE, a copy of `plans/round-61-c2.sh` (sha256 `c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6`) with the value aggregation (`:323-325`) replaced by a constant `value=5` reads `C2_SELFTEST: PASS (cases=11)` rc 0; the same with the shim aggregation (`:316-319`) replaced by an unconditional `shims_ok=5` reads the same; a valid-sha256 stub trial printing nothing reads `C2_SEAL_TRIAL: value=0 … guard=1` | plan §C2 population census (measured at BASE by the L1); the two mutants reproduced by this seat (`.ufo/waves/round-62/build/R62ScribeRecords/m-a-m-b.txt`, baseline `PASS (cases=11)` rc 0, M-A `PASS (cases=11)` rc 0, M-B `PASS (cases=11)` rc 0) | the hardened counter exposes `decide` and the shim aggregation as testable units and its `--selftest` drives both with positive and negative vectors, so M-A and M-B fail with a named `FINDING`; the guard requires each leg's expected observable, so the stub tree reads `guard=0`. **Able to fail**: measured on the hardened bytes (sha256 `20614697…`): baseline `C2_SELFTEST: PASS (cases=21)` rc 0, M-A `FAIL (cases=21 failed=6)` rc 1, M-B `FAIL (cases=21 failed=3)` rc 1 (`build/R62ScribeRecords/hardened-m-a-m-b.txt`); the round-62 counter's own legs M-A/M-B/G are the candidate reading (the L1's verdict), and the stub tree must read `guard=0` (leg G) |
| M62-6 | instrument grammar — the C1 checker's items test token presence, so a negation or a swapped pairing keeps every token and reads accepted | the five frozen bypass trees (plan §C1 table B3–B7) each read `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0` rc 1 on the round-61 checker at BASE, i.e. `accepted=5`; the unmodified copy reads the same line, so the population is not vacuous | plan §C1 population census (measured at BASE by the L1 and the round-61 reviewer); re-measured by this seat over an extracted `60b5b7b` tree (`.ufo/waves/round-62/build/R62ScribeRecords/c1-bypass-base.txt`: B3–B7 each `value=0`, unmodified `value=0`, checker sha256 `d525ee28…`) | the hardened grammar tests each token in the asserting position (closed negator set, 5-token window truncated at `.`/`;`/`:`, derived fraction/percentage pairing). **Able to fail**: the same five trees must read unresolved on the hardened checker (`plans/round-62-c1.sh` legs C1-F1..C1-F5 read exactly 1 each), and the three paraphrase trees must still read `value=0` (guard leg d) |
| M62-7 | frozen-plan defect — a frozen item clause cannot exercise its own fixture | the frozen B6 fixture is a tail-only substitution that keeps the superseded stamp (`15:09:28`) and the driver-complete time (`16:34:37`), so the frozen I6 clause (c) reads B6 `value=0`; the target 0 was unreachable as written | `R62ExecC1Counter` re-derived it from the frozen text before any candidate reading (message to the L1, 2026-11-07); `R62ExecC1Grammar` independently re-derived the same conflict | plan §Amendment A1 (appended before data): I6 gains clause (d), no `times are correct`/`times are right`/`is correct`/`are correct`. **Able to fail**: the checker's selftest carries the B6 tail-only denial and the reviewer's whole-line variant, both unresolved; a checker without clause (d) reads B6 resolved and fails `b6-denial-unresolved` |
| M62-8 | instrument parse — a case-count extractor read the identifier's digit | `plans/round-62-c1.sh` at 16413 B did `grep -oE '[0-9]+'` on `C1_CHECK_SELFTEST: PASS (52 cases)` and read `1` (the `1` in `C1`), so `guard=0` on every tree; a checker printing `(57 cases)` still read `cases=1` | `R62Reviewer` D-1 (attack seat, 18:17) | the 18:17 bytes parse the parenthesised number; the counter's `--selftest` check 3 asserts the parsed count on a known-PASS tree. **Able to fail**: a copy that restores the old extractor reads `cases=1` and fails the check |
| M62-9 | instrument control flow — the measure leg returned the last fixture's status | `measure_battery` ended with `[[ "$RUN_VAL" == "0" ]] && ACCEPTED=$((ACCEPTED + 1))` inside the loop, so when the last fixture was rejected the function returned 1 and the caller died `setup_die 'measure leg failed'`; the counter could report the claim's failure but never its success | `R62Reviewer` D-2 (18:26) | `return 0` at the end of `measure_battery` plus selftest check 7 (`measure-leg-rejected-tail`). **Able to fail**: removing the `return 0` fails check 7 |
| M62-10 | instrument needle — a mutation leg defined by a marker the measured bytes do not carry | the frozen M-A/M-B needles (`# BEGIN-DECIDE`/`# BEGIN-SHIMS`) occur 0 times at BASE, so the BASE leg was "absent" rather than "survived", and the plan's census named two different mutations under one label | `R62Critic` D4; `R62MutC2` S3/S4 (zero-match needle read as a non-kill, not SETUP) | plan §Amendment A2 (the marker needle when present, else the BASE aggregation text) plus `setup needle-ma`/`needle-mb` on a zero-match; the BASE run now applies the reviewer's mutation and reads `killed=0` for the measured reason. **Able to fail**: a tree with neither needle reads SETUP |
| M62-11 | guard vacuity — a printer stub that self-attests a PASS line passed the stub leg | a stub printing a constant `C1_ROUTED: value=0 …` line and `C1_CHECK_SELFTEST: PASS (cases=57)` read `accepted=0 guard=1` | `R62Critic` D5 | plan §Amendment A3: guard leg (e), the checker challenge (emptied negator set must fail the shipped checker's selftest). **Able to fail**: the counter's selftest check 8; a stub cannot apply the needle and reads `chal=0` |

## Corrections

The routed D1/D2/D4/D5 dispositions, as tree reads at write time. A state that reads
"landed" here is a read of the working tree, not a verdict: the frozen counters and the
L1's candidate receipt are the verdicts.

- **D1 — SCORECARD controls count.** The errata section appended at `SCORECARD.md:2108`
  supersedes `SCORECARD.md:2056` (`match=17`) with the receipt's derived count: 18
  `CONTROL ` lines and `CONTROLS: match=18 mismatch=0` at
  `.ufo/waves/round-61/controls/controls-prefreeze.txt:29`, cited from `LOG.md:1990`. The
  superseded line is not rewritten (QM78). State: landed in the working tree.
- **D2 — gate registry rows.** `SKILL.md` gains `## Gate registry — round-61 additions`
  (three rows: `plans/round-61-c1-check.py`, `plans/round-61-c2.sh`,
  `corpus/openbao-seal-trial.sh`) and `## Gate registry — round-62 additions` (three rows:
  `plans/round-62-c1.sh`, `plans/round-62-c2.sh`, `plans/round-62-controls.sh`), in the
  house eight-column format, every row `kind: gate` with a runnable self-invocation and
  its case count (QM76). State: landed in the working tree; the round-62 rows' case counts
  are the instruments' own `--selftest` readings at landing.
- **D4 — candidate-revision receipt.** `.ufo/waves/round-62/final/candidate.txt` names the
  candidate revision and carries both verdict lines. State: the L1 writes it at
  integration; not written by this seat.
- **D5 — ancillary gate receipts.** One receipt per gate line under
  `.ufo/waves/round-62/final/` (`release-clock.txt`, `doc-audit.txt`,
  `claims-declared.txt`), each cited from `LOG.md`. State: the L1/executor seats write
  them at integration; not written by this seat.
- **Plan Amendment A1 (not a routed defect).** The frozen plan gained `## Amendment A1` in
  the working tree after the predeclaration commit `8e5463c7`: the §C1 fixture B6 (a
  tail-only substitution on `corpus/lessons/round-60.md:179`) keeps every token the frozen
  I6 clause tested, so a plan-faithful hardened checker would accept it and the target 0
  was unreachable as written. A1 adds I6 clause (d) — the correction line asserts none of
  `times are correct`, `times are right`, `is correct`, `are correct` — and leaves the
  predicate, target, POP, the five fixtures and the kill rules unchanged. The BASE census
  (`accepted=5 population=5`) is unaffected because B6's tail is the denial clause (d)
  refuses. State: working tree, uncommitted at write time; the L1 owns the commit.

## Routed dispositions

| id | spot-check §7 | item / file that carries the fix | state at write |
|---|---|---|---|
| D1 | §7.1 SCORECARD controls count 17 vs 18 | `SCORECARD.md` appended errata (`:2108`) naming the receipt and the derived count | landed in the working tree; `plans/round-62-routed.sh` leg `d1` |
| D2 | §7.2 no registry rows for the round-61 gates | `SKILL.md` `## Gate registry — round-61 additions` and `## Gate registry — round-62 additions` | landed in the working tree; leg `d2` |
| D3 | §7.3 literal attack share 3/16 at round 61 | `plans/round-62.md` §Wave plan states `4 of 14 = 28.57 %` literal; the round report states both readings | plan frozen at `8e5463c7`; the derived reading from `w1-dispatch.json` is 4 attack seats (reviewer, critic, mutation-tester ×2) of 14 = 28.57 %. The routed leg first read `d3=0` because the plan's sentence wraps between `=` and `28.57 %` (`plans/round-62.md:201-202`) and its literal search missed; the L1 flattened the plan's whitespace in the leg and it now reads `d3=1` (`ROUTED: … d3=1 … plan-states=yes`). The arithmetic was right; the leg's whitespace handling was the defect |
| D4 | §7.4 no committed candidate-revision receipt | `.ufo/waves/round-62/final/candidate.txt` | L1 at integration; leg `d4` |
| D5 | §7.5 ancillary gate verdicts have no receipt | `.ufo/waves/round-62/final/{release-clock,doc-audit,claims-declared}.txt`, cited from `LOG.md` | L1/executor at integration; leg `d5` |
- **Plan Amendments A2/A3 (not routed defects).** A2 (critic D1/D2/D4) restates the round-61
  checker's statement scope for I3–I7 (the LAST line matching the item's supersedes phrase —
  a whole-file reading is not the item's condition) and defines the M-A/M-B needle as the
  marker block when the measured counter carries it, else the BASE aggregation text, so the
  BASE leg applies the reviewer's mutation and reads `killed=0` for the measured reason. A3
  (critic D5) adds C1 guard leg (e): a copy of the measured checker with its negator set
  emptied must fail its own selftest with a named `FAIL` line (the shipped checker fails 7
  named cases; a stub cannot apply the needle). Both strengthen an instrument and cannot
  narrow a claim. State: committed at `7b291538`, before any candidate reading.

## considerthese

One still-unimplemented proposal is mined this round (read-only; never edited):
`considerthese/2026-10-20.md` proposal 2, "A standing fail-open suite for every gate
(adversarial inputs run alongside `--selftest`)" — the connector's inventory names it
`.ufo/waves/round-62/build/R62Connector/considerthese.md` §1 as the one still-unimplemented
proposal that fits this round's claims. It lands as the two QUALITY criteria this round adds
(QM81: a structural item tests its token in the asserting position; QM82: a gate's
self-invocation mode executes its own aggregation and its guard has a challenge leg), each
citing this lesson, and as the frozen bypass/mutation fixtures the two counters run. The
proposal is a standing suite for *every* gate; this round implements it for the two
instruments the claims name, and the rest is named debt.



## Wave

`kagi-r62-w1`, 14 seats v1 (`.ufo/waves/round-62/w1-dispatch.json`; reports
`.ufo/waves/round-62/w1/`; results `.ufo/waves/round-62/w1-results.json`): 2 scout, 4
executor, 2 scribe, 1 reviewer, 1 critic, 2 mutation-tester, 1 connector, 1 sentinel.
Dead seats 0 by the results file (14 of 14 records carry a non-empty final output,
104–9618 B), with one substantive dead seat reported: `R62Sentinel` settled after a
progress line only ("I'll start by reading the frozen predeclaration and lesson files,
then build the instrument inventory.") and wrote no report; the L1 ran the counts-only
credential-shape scan itself (0 hits across the round's artifacts) and the
scratch-discipline check (the counters left 35 GB of tree copies under
`$HYAKU_SCRATCH/kagi-r62`, removed after landing — a routed defect). Attack share:
4/14 = 28.57 % on the addendum's literal list (reviewer, critic, mutation-tester ×2; no
labrat seat exists — a frozen-topology probe role, not a swarm lane). Seat verdicts:
`SEAT-STATUS: complete` on 13 reports; the reviewer's D-1..D-6, the critic's D1–D12, the
mutation-testers' survivors (MutC1 GM5/CM2a/CM2b; MutC2 S1–S4) and the connector's sweep
are integrated in §Mistakes and the SCORECARD ceilings.

## Bounds

- The `## Gate` quotes are the scout's located rows in `capture/notes.md`, re-resolved by
  this seat with `corpus/rendered-text-v1.py locate` (`build/R62ScribeRecords/gate-quotes.txt`):
  five `count=1` for the admitted rows and S133's recorded quote, two `count=0` for the
  rejected pages' probe terms.
- The `## Routed dispositions` state column is a working-tree read taken at write time; it
  is not the frozen counters' verdict, and a state that reads "landed" here does not by
  itself satisfy an item's condition.
- M62-5's BASE readings are the plan's census; this seat reproduced the two mutants (M-A,
  M-B) on an extracted `60b5b7b` tree and did not re-run the stub-trial leg G.
- M62-6's BASE reading is the plan's census and the round-61 reviewer's five bypass trees;
  this seat rebuilt the five trees from the frozen fixture table on an extracted `60b5b7b`
  tree and re-read the checker on each (`c1-bypass-base.txt`).
- The registry rows' case counts are the instruments' own `--selftest` readings; a count
  that changes with a later instrument edit is a stale cell, not a new claim.
