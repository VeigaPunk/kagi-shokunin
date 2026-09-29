# Round 13 — a citation becomes resolvable, a score becomes a re-verified pointer

Axis moved: **calibration** 8 → 9 (the highest cell in `SCORECARD.md`; the other
five are left at 8 with the reason stated in the same file). This round did not
measure a new host surface. It made the *existing* self-assessment falsifiable:
a citation now has to resolve, and a scorecard cell now has to point at
something that still holds.

Revision: `corpus/claim-ledger.sh` shipped at sha256 `<FILL ON STAMP>` /
`<LINES>` lines; `corpus/stamps.tsv` re-pinned to 33 artifacts; the round-12 set
(carried uncommitted into this round) is in the same commit.

## What the pre-state actually was (measured, three ways)

Round 11 wrote the next step as "each score cell names the claim ids it rests
on". Round 12 recorded it as only partially landed. Neither round measured the
gap. This one did, before touching anything:

- **The ledger could only be iterated forward.** `verify` walked rows →
  commands; nothing walked documents → rows. A doc citing an id that no row
  defines passed every gate. Demonstrated at the dispatch revision: a doc citing
  the fabricated `R13-99` and `R12-88` produced `CITATION_GATE: CLEAN (cites=1 docs=1
  unresolved=0 ephemeral=0 labeled=0)`, exit 0 — the one cite was a path token,
  the two ids were invisible (labrat lane, `/tmp` copy).
- **The scorecard was unaudited.** A first audit of `SCORECARD.md` found
  `cells=48 row_pointed=3 stamp_pointed=28 **uncited=20**` — 20 round-table
  cells whose "evidence pointer" resolved to nothing at all. Reproduced
  independently three times: the L1's gate, a scribe-lane replica
  (`ANCHORED_AUDIT: cells=48 row_pointed=3 stamp_pointed=28 uncited=20`), a
  scout-lane python census, and an executor-lane re-implementation of the same
  rule — the same number from four code paths.
- **Five ledger rows were orphans** (`R11-01/02/04/05/07`): committed, costing
  runtime on every `verify`, cited by nothing.

So the honest pre-state was not "calibration is 8 because the cells are
self-scored". It was: the mechanism round 11 shipped had a hole at each end —
forward-only iteration and an unaudited scorecard — and neither was visible from
inside the gate.

## What landed

1. **`verify` resolves ids both ways.** Every `R<digits>-<digits>` **whole
   word** in the checked docs must be a row id (`MISSING-ID doc:line id`, exit
   1); rows cited nowhere are counted as orphans and listed with `--orphans`.
   Row ids come from row lines only — an id named in a comment creates nothing.
2. **`cells` audits this file's own score card.** Each Round pre/post cell must
   carry a pointer: a resolving row id, or a path listed in `stamps.tsv`.
3. **The teeth, which are the actual move.** A pointer counts only if it still
   holds: the cited rows are **re-run** through the ordinary claims machinery
   (exit equality + last-line verdict) and the cited pinned artifacts are
   **re-compared** against their stamp rows. `row_pointed` vs `stamp_pointed`
   are printed separately, so the summary itself says how many scores rest on a
   live command rather than on a frozen document.
4. **Shape guards that make a miss loud.** Every recognised round section must
   carry all six axes exactly once (a partial rename is exit 2, not a smaller
   checked set); zero cells, an empty id universe, or a scorecard outside the
   audited doc set are each exit 2; a scorecard whose cells cite no row at all
   is exit 2 (nothing to re-run ⇒ the audit would be vacuous).
5. **The 20 uncited cells are repaired**, each with the pointer that actually
   demonstrates it — a re-run row where one exists, a stamped artifact where the
   cell's claim is historical. One historical number was wrong on contact
   (the round-11 pre-move coverage cell said 21 runtime shape pins; the pin
   count was already 22, pinned by `R11-10`) and is corrected in place with the
   correction recorded in the cell.

## The defect this round found in its own first implementation

The first `cells` implementation tested pointer membership with an unanchored
substring match:

```
stamp_has() { grep -qF -- "$1"$'\t' "$STAMPS" 2>/dev/null; }
```

Every scorecard cell carries a bare score digit (`7`, `9`) in its second column,
and a stamps row contains sha256/line/byte fields — so the pattern `7<TAB>` (or
`9<TAB>`) matched *inside a hash or a counts column*. The gate printed
`CELL_AUDIT: CLEAN (cells=48 row_pointed=3 stamp_pointed=48 uncited=0)` exit 0
against a scorecard with 20 unpointed cells: a false clean of exactly the class
round 11's critic CE1 found in the census gate.

How it surfaced: a throwaway probe printed the tokens that were matching
(`HIT [7]`, `HIT [9]`) while the scribe lane's replica, built independently,
reported `stamp_pointed=28`. Fixed by loading the stamp rows into arrays once and
comparing the **first field exactly**; the regression is pinned by selftest case
`cells-numeric-anchored` (a stamps file whose line column ends in the score digit
must still yield `stamp_pointed=0`). The lesson is the one round 11 recorded in
the other direction: *a scan over a whole line needs an anchor, and two
independent implementations of the same rule are worth more than one careful
reading.*

## The L2 wave — what each lane attacked, and what happened to it

12 lanes in one batched dispatch (2 mutated by a malformed payload into a
second dispatch): planner, connector, 2 scouts, 3 executors, reviewer, critic,
sentinel, mutation-tester, labrat, scribe.

| Lane finding | Disposition |
|---|---|
| **Critic (executed):** the rule buys inventory, not evidence — a cell scoring `calibration 9` citing `R11-10` (which only counts `state-shape.tsv` rows) returned `CLEAN`; a poisoned stamp row (`deadbeef/0/0`) also returned `CLEAN` | **Real, and it changed the design.** The two teeth were added: cited rows are re-run, cited pins re-compared. The *residual* — a pointer can be irrelevant to the score beside it — is recorded as the calibration ceiling in `SCORECARD.md` and as `claim-ledger.md` §Bounds 18; the report does not claim the rule verifies evidence. |
| **Critic:** sharpest sentence the report must not write | Adopted verbatim as the wording rule: do not claim "every score cell is now evidence-backed/verified"; the claim is "every checked cell names a pointer that resolves and still holds". |
| **Mutation (executed):** the illustrative `R12-03a` resolved as `R12-03` (prefix match); `R12-01..03` validated only its head; a comment-only id satisfied a naive grep; a stamped-but-deleted path passed membership-only | **All real.** Whole-word id extraction (`[A-Za-z0-9_-]*R[0-9]+-[0-9]+[A-Za-z0-9_-]*`) + comment-skipping row load + `stamp_cmp` on cited pins; four selftest cases (`verify-suffixed-id`, `verify-prefixed-id`, `verify-comment-id`, cell `MISSING-POINTER` path). The range bound (head-only) is documented rather than fixed. |
| **Mutation:** `**Depth**`, `Depth (owned)`, an indented row, a duplicate axis row, a fenced fake table | **Shape guards.** First cells are stripped of whitespace and `*`; every section must carry the six axes exactly once (duplicates and renames ⇒ exit 2); an id scan is line-oriented over every byte (no fence or cell filtering — planner T1-1). |
| **Planner (T2-1/T2-3):** a dropped axis row, an empty scorecard, or a table split on pipes could silently shrink the checked set | **Adopted** as the six-axis rule + zero-cell exit 2; the pointer scan reads the intact line, so a pipe inside a cell cannot truncate it. |
| **Scribe (F2, open at read time):** `cells --scorecard/--docs` died `sec_head: unbound variable` | **Real, and fixed before landing** — the section flag and the doc-set membership flag shared the name `in_set`, so the first `##` line ran the section check with an empty heading. Found by the frame's own selftest once the fixtures existed (the default-root path had worked, which is why the drafting lane saw it first). |
| **Scribe (F3, design):** recursion — a scorecard cell may cite a row that runs this gate | **Adopted as a bound, not a workaround.** `verify` refuses a nested self-audit (exit 2); `cells` skips rows that re-invoke the gate (`SKIP-SELF`, counted as `self_skipped`) so one nesting level stays bounded. Consequence, stated: the ledger cannot pin its own `verify` summary; `R13-03` pins the `cells` summary instead. |
| **Scribe:** `corpus/README.md` said `stamps.tsv` holds 31 rows while `R12-03` pins 32 | **Real, fixed** (now 33). |
| **Sentinel:** threat-model the doc-scanning path (traversal from a crafted cell token, printing private content, empty-input-reports-CLEAN) | **Two real asymmetries adopted, and 31 probes came back NOT-reachable** on the landed code: equality-based membership (no regex/glob interpolation), no eval on tokens, `/etc/passwd` as a scorecard refused before parsing, zero-cell/empty-ledger/empty-stamps/vacuous-scorecard all exit 2. Its **stamp read-side containment** finding (a hand-edited `../outside.txt` row made `verify` hash a file outside `--root`, and `cells` accept a `../` pointer) is fixed — the reader now refuses what the writer always refused — and its **round-heading drift** finding (a `## Round 1 pre-move` heading would silently drop six cells) is fixed with an explicit refusal. Both are pinned by selftest cases (`stamps-dotdot-row`, `stamps-absolute-row`, `cells-bad-round-heading`). |
| **Reviewer:** the round-12 numbers, re-adjudicated against the live tree | 12 of 13 VERIFIED (probe counts, case counts, row counts, sibling gates, host anchors). STALE on the moving revision itself — the reviewer caught `citations` dying with `lineno: unbound variable` **mid-edit** and reported it; that revision never shipped, and the shipped `citations` is byte-identical in behaviour to the pre-edit baseline (executor lane diff proof: `CLEAN (cites=640 docs=42 unresolved=0 ephemeral=0 labeled=13)` both sides). Recorded here rather than smoothed over: a lane reading a moving tree must state the revision it read. |
| **Labrat:** the before-state proof | **Used as the round's before-evidence** (S2 above). Its copy caught a *mid-edit* revision (593 lines, different sha than the dispatch hash) — the round-12 lesson repeats: a declared freeze is stale on arrival, so quote the hash you actually read. |
| **Scout (census):** every id token, every orphan, every unpointed cell with line numbers | Its numbers match the gate's exactly (list 1: 29 tokens in the default doc set, 0 unresolved; list 2: the 5 orphans; list 3: 28 stamp-pointed + 3 row-pointed, 20 unpointed). |
| **Connector:** sibling overlap | **Report-only, per adjacency.** kumitate `round-gate.mjs` and kotoba `verify_corpus_integrity.py` resolve **commit** ids; kengaku `grader.py` has a prediction score table; kasegi's checker source lives outside the sibling checkout. None implements an `R…-…` row-id or score-cell contract, so nothing is duplicated; a shared "cited id must resolve" contract stays with the integrator. |
| **Executor (independent implementation):** converged on the same semantics, reproduced `cells=48 row_pointed=3 stamp_pointed=28 uncited=20`, and proved the `citations` refactor byte-identical | Used as the fourth independent reproduction of the pre-state number. Its `R11-09`-style count pin (43 → 59) and mine (43 → 68) differ because the case sets differ; the shipped count is the one pinned. |

## Evidence (shipped revision)

```
bash corpus/claim-ledger.sh cells
  → CELL_AUDIT: CLEAN (cells=60 row_pointed=25 stamp_pointed=41 uncited=0 missing_ids=0
                       rows_run=14 row_failures=0 stale_pointers=0 self_skipped=3 orphans=0)
  pre-move, same command: CELL_AUDIT: BROKEN (cells=48 row_pointed=3 stamp_pointed=28 uncited=20 …) exit 1
bash corpus/claim-ledger.sh verify
  → CLAIM_LEDGER: CLEAN (claims=17 stamped=33 ids=17 cited=17 labeled_ids=13 orphans=0)
bash corpus/claim-ledger.sh citations
  → CITATION_GATE: CLEAN (cites=700 docs=43 unresolved=0 ephemeral=0 labeled=13)
bash corpus/claim-ledger.sh --selftest
  → SELFTEST: PASS (72 cases)
```

Siblings unchanged: `DRIFT_PINS: CLEAN (files=15 symbols=20)` + 13-case selftest;
`SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`
+ `--verbs CLEAN (pass=7 skip=3)` + 16-case selftest; `TRANSCRIPT_SCAN: HITS=2`
exit 1 by design.

## Bounds and process notes

- **A pointer is not relevance.** See the critic row: the audited object is the
  pointer's resolvability and freshness, not its meaning. This is the calibration
  ceiling, stated in `SCORECARD.md` and in the contract's §Bounds 17–21.
- **The ledger cannot vouch for itself.** Nested `verify` is refused; the `cells`
  summary is pinnable only because the cell audit skips self-invoking rows.
- **Two stamps in one round.** The first `stamp` ran before the measured
  summaries were patched into the docs, so the docs went `STALE` and were
  re-stamped. Order that works: land artifacts → measure → patch the quoted
  numbers → stamp once → `verify`. Round 11 recorded the rule ("make the
  measurement the last byte-touching step"); this round shows the corollary —
  do not stamp before quoting your own output.
- **The dispatch revision moved under the wave, twice, and the lanes said so.**
  The planner computed acceptance commands against a 45-case selftest, the
  reviewer adjudicated a 56-case one, the executor diffed a 43-case pin, the
  scribe quoted a 918-line script. Every one of them labelled the revision it
  read; the shipped case count is 72 and the shipped pin is `R11-09`. No lane's
  finding was discarded because it targeted an older revision — the revision
  field is what made them usable.
- **One round-12 claim went stale and is now recorded as historical:** the
  round-12 entries quoting `CLAIM_LEDGER: CLEAN (claims=14 stamped=32)` and
  `labeled=16` describe the round-12 revision; `labels` moved and the summary
  grew. `LOG.md` is append-only, so those lines stay as the measurement of that
  round, and the live docs carry the current shape.