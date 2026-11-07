# R60RevContext — intent reconstruction of the round-59 routed defects (D1–D7)

Seat: revenger (calibration, adjacency). Read-only: no lane file edited, no git/jj mutation.
Claim BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`; plan of record `plans/round-60.md`
(predeclaration `cd631737`, §A1/A2 seat-count amendments; the §C1 items I1–I7 are unchanged
between `cd631737` and the working tree — `git diff cd631737 -- plans/round-60.md` touches only
§A3/§A4, which are C2/T1).

Sources read: `corpus/lessons/round-59-verifier-spotcheck.md` §7 (D1–D7); fleet
`.ufo/reports/round-59/kagi.md`; `LOG.md` §Round 59; `.ufo/waves/round-59/w1-results.json`;
`.ufo/waves/round-59/final/`; `corpus/lessons/round-59.md`; `SCORECARD.md` round-59 block and
errata; `SKILL.md` gate registry; the round-59 seat reports (`R59ScribeLesson.md`,
`R59ExecCounterC1.md`, `R59ExecFixRecords.md`, `R59ScribeEntry.md`) and the round-59 build
receipts; the landed round-60 corrections and `plans/round-60-c1-check.py` (read-only runs).

Method: for each defect I reconstructed (a) what the round-59 author was trying to record from
the author's own artifacts and receipts, (b) what the committed artifact actually says, (c) what a
correct repair must state, then (d) judged the landed correction against the frozen item condition
as the checker implements it and against the reader's reading. The checker was run read-only on the
working tree (`--no-challenge`, plus the guard leg) and on the battery's synthetic fixed tree; the
transit selftest was executed from the lane tree with scratch under
`/fast/scratch/hyaku/kagi-r60/R60RevContext/`.

## Reconstruction table

| id | intent (what the author was recording) | actual (what the artifact says) | correct repair (what a correct repair must state) | judged repair (landed text) | verdict |
|---|---|---|---|---|---|
| **D1** | The `LOG.md` §Round 59 wave line records the wave's seat count and dead-seat count in the lane's established format ("N seats, 0 dead"; cf. rounds 53/54/58). The template's `__DEAD__` token was to be replaced with the measured count. | `LOG.md:1965` ends `dead seats __DEAD__` — an unfilled template placeholder. The count is unreadable, and the placeholder contradicts the report's "no dead seat" and the 14 non-empty `output` strings in `.ufo/waves/round-59/w1-results.json` (R=14, D=0). | Append a LOG correction block (append-only) naming the superseded line and stating `results=14 dead=0` with `w1-results.json` as the authority; do not rewrite the line. The block must not re-quote the literal `__DEAD__`, or it moves the "last `__DEAD__` line" anchor inside itself. | `LOG.md:1967-1969`: `## Round 59 — correction` + `results=14 dead seats=0`, names `.ufo/waves/round-59/w1-results.json`, says the superseded line is not rewritten. An earlier draft quoted the literal `__DEAD__`; the seat replaced it with "unfilled dead-seats placeholder token" (no literal). Checker: `i1 HOLD blocks=1 results=14 dead=0 names_w1-results=yes results-line=match`. | **Restores the missing fact.** 0 dead / 14 results / authority named; the reader is not misled. The line uses the guard's `dead seats=` label, which the checker accepts tolerantly (`dead(?:\s+seats)?=`); a strict reader of I1's `dead=<D>` would not — see §Divergences (plan defect C1.4). |
| **D2** | R31 is a routed *number check*: the author believed the C1 counter's report said `--selftest` runs 33 cases while the committed receipt said 32, and wanted the receipt to be the authority. | The committed receipt `.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt:4` reads `C1_CHECK_SELFTEST: PASS (33 cases)`; the C1 seat's report (`w1/R59ExecCounterC1.md:69`) also says 33; no receipt ever read 32. The 32 is a transcription error in the lesson (it is already in the scribe's draft, `build/R59ScribeLesson/round-59.md:199`). R31's premise is false. | Append a correction that supersedes R31, names `C1_CHECK_SELFTEST`, states the receipt's 33, and states that the 32 was a lesson transcription error — no receipt ever read 32 — so the routed item is withdrawn, not a receipt defect. | `corpus/lessons/round-59.md:208`: `supersedes R31 — the committed receipt ... reads C1_CHECK_SELFTEST: PASS (33 cases) on its last matching line; the routed row's smaller count is superseded.` Checker: `i2 HOLD derived cases=33 supersedes-candidates=1 last-line=states-count`. | **Restores the count, loses the intent.** The line passes I2 but no longer says the 32 was never in a receipt; "the routed row's smaller count is superseded" reads as if the receipt's value was 32 and changed to 33. See §Mislleading-but-passing. |
| **D3** | Each routed-disposition id names exactly one wave finding; the round-59 table's ids run R1..R31. | `corpus/lessons/round-59.md` uses `R20`, `R21`, `R22` twice each (lines 192/195, 193/196, 194/197). The second batch — the 14:16 citation-gate regeneration failure, the wrapped-bullet class (M59-1), the symlinked-challenge-copy defect — reused the ids instead of continuing at R32. A disposition id names two findings. | The next lesson (`corpus/lessons/round-60.md`) uses unique ids and names the superseded duplicate ids, mapping each duplicate to its finding (second R20 = the 14:16 citation-gate regeneration failure; second R21 = the wrapped-bullet class; second R22 = the symlink challenge-copy defect). The naming line must be one physical line (the checker is line-scoped; the battery's own wrapped fixture fails I3 — see §Sweep). Ids must be bare `R<digits>` (`R32`…), not `R60-01` (the checker's `ID_TOKEN_RE = R\d+` reads `R60-01` as `R60`). | **Not landed at this reading (L1-owned).** The checker reads `i3 FAIL corpus/lessons/round-60.md missing`. The plan's I3 condition and the checker's implementation are quoted in §Pending conditions. | **Pending.** The correct repair is known; the landed lesson is not yet on disk. |
| **D4** | The `SCORECARD.md` calibration row records the pre-freeze battery's control census: the battery's size and its clean reading. The 21 came from the 14:16 revision's 21-id census (including `C1-F7b`); the landed battery has 20 ids and the receipt has 20 `CONTROL` lines; the row's parenthetical enumerates 20 (4 K + 8 C1-F + 8 C2-F). | `SCORECARD.md:1971` says `(21 controls; K1-BASE, K1-BASE-GUARD, K2-BASE, K1-REF plus C1-F1..F8 and C2-F1..F8)` and reads `CONTROLS: match=20 mismatch=0`. The landed `plans/round-59-controls.sh` has 20 `report` calls; the receipt has 20 `CONTROL` lines. The row contradicts itself arithmetically (4+8+8=20≠21). | State the landed battery has 20 controls (4 K + 8 C1-F + 8 C2-F), naming the superseded 21 and, ideally, that the 21 was the 14:16 composition with `C1-F7b` which the landed battery does not ship. | `SCORECARD.md:1980`: `supersedes SCORECARD.md:1971 — the round-59 calibration row's parenthetical control census overcounts the battery; grep -cE '^CONTROL ' ... reads 20 controls (4 K + 8 C1-F + 8 C2-F), superseding the row's stated 21-controls parenthetical.` Checker: `i4 HOLD derived controls=20 supersedes-candidates=1 last-line=states-count`. | **Restores the count.** The reader learns the landed battery is 20. Minor provenance loss: the 21 was a real count of the superseded 14:16 revision (`C1-F7b`), not a pure miscount; the errata calls it an "overcount" without naming `C1-F7b`. |
| **D5** | The `SCORECARD.md` freshness row cites a release-clock receipt as the evidence for `RELEASE_CLOCK: CLEAN`; the report/LOG state `RELEASE_CLOCK: CLEAN`, `DOC_AUDIT: CLEAN (entries=40 row_linked=37 by_hand=3 …)` and `SCOPE stale_basis=0`. The author was recording the gate readings as evidence of the round's freshness/adjacency state. | The cited `.ufo/waves/round-59/final/release-clock-candidate.txt` does not exist (r58's copy exists; r59's was never written). No committed receipt under `.ufo/waves/round-59/` carries `RELEASE_CLOCK`/`DOC_AUDIT`/`SCOPE`; the r59 readings are unverifiable. The spotcheck re-measured DOC_AUDIT by plain count and agreed; the `SCOPE` bit is not re-derivable without executing the gate. | State the r59 pointers/receipts were never written, and commit round-60 receipts for the three gates so the readings are re-checkable now; do not imply the r59 readings were verified at the time. The scope receipt must contain the gate's own `ADJACENCY_SCOPE:` verdict, not only a hand-written `SCOPE` summary. | **Not landed at this reading (L1-owned).** The checker reads `i5 FAIL no 'supersedes the round-59 gate-evidence pointer' line`. The plan's I5 condition and the checker's exact requirements are quoted in §Pending conditions. | **Pending.** The correct repair is known; the landed SCORECARD line and receipts are not yet on disk. |
| **D6** | The report's Before → after table's "measured commit" column names the revision at which each after reading was taken. The author wrote `75165a07` (the tip that carries the receipts) for both claims. | The C1 receipt `.ufo/waves/round-59/final/c1-landed.txt` says `c1-driver: measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c (git archive)`; the C2 `c2-landed.txt` is one line with no revision; the tip delta `160caf75 → 75165a07` is 3 files / 103 insertions, all receipts/results (`git diff --stat`). The table describes the surface at `160caf75` for C1 and an unbound revision for C2; `75165a07` carries the receipts, not the reading. | For C1, state the receipt's measured revision `160caf75…` and that the tip carries the same surface; for C2, re-run at the tip and cite the tip, or state the receipt is not revision-bound. The plan's I6 covers only C1. | **Not landed at this reading (L1-owned).** The checker reads `i6 FAIL no SCORECARD line containing 75165a07`. The plan's I6 anchor does not exist at BASE (`git show a677c78:SCORECARD.md | grep -c 75165a07` ⇒ 0); the repair must add an anchor line before its stating line, and the stating line must not itself contain `75165a07`. See §Measured commit and §Pending conditions. | **Pending.** `measured=revision 160caf75…` is the right correction for C1; the C2 half of D6 is not read by I6 and remains wrong unless the L1 adds it. |
| **D7** | The Gate standard requires every gate to expose a self-invocation mode over isolated fixtures asserting the exit code and a stable expected finding-id. The transit trial was registered `kind: gate` with `selftest: none — its own five shims and the clean-room leg are the falsifiers`. | `corpus/openbao-transit-trial.sh` had no `--selftest` (grep: 0); `plans/round-59-c2.sh` had none; `SKILL.md:847` declared `none — its own five shims and the clean-room leg are the falsifiers`. The trial could not self-test its verdict mapping without a real `bao` server. | Add a fixture-driven `--selftest` (no `bao`, no network) with ≥6 cases over isolated fixtures, each asserting an exit code and a stable finding id; prove it can fail; update the registry row's selftest cell. | The trial now has `--selftest` with 9 cases over a stub-`bao` harness (no real `bao`, no network), asserting exit codes and output shapes; `TRANSIT_SELFTEST: PASS (cases=9)` rc 0 (my run and `build/R60ExecTransitSelftest/selftest.txt`). A mutated verdict mapping (BROKEN branch rc=1→0) makes it exit 1 with five `FINDING TRANSIT-ST-SHIM-SHn` lines (`selftest-mutant.txt`). The real trial after the edit still reads `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0` (`trial-still-holds.txt`). `SKILL.md:847` now names `--selftest` and the 9-case stub harness, and no longer carries `none — its own five shims`. Checker: `i7 HOLD`. | **Restores the intent**, not just the token: the selftest is fixture-driven, bao-free, network-free, and fails loudly with named finding ids. Residual ceiling: I7's condition does not itself require bao-free isolation (the critic's C1.9); the landed artifact is bao-free, so the intent is met. |

## Measured commit (r59)

The r59 Before → after table (fleet `.ufo/reports/round-59/kagi.md:100-103`) names `75165a07`
for both rows, with parentheticals citing `final/c1-landed.txt` and `final/c2-landed.txt`.

- **Which revision the table describes.** The C1 reading describes **`160caf750dcf15892b78ec066e66bc605ba57a5c`**: that is the revision on the `c1-driver: measured=revision` line of the receipt the table cites, and the driver extracted it with `git archive`. The C2 reading is **unbound**: `final/c2-landed.txt` is one line (`C2_TRANSIT_TRIAL: value=5 …`) and `final/c2-candidate-tree.txt` is one line; neither names a revision. The tip `75165a07` only adds the two landed receipts and `w1-results.json` (3 files, 103 insertions, all receipts/results), so the counters' input surface is identical at `160caf75` and `75165a07`; the readings transfer, but the citation as written is wrong.
- **Is the receipt's `measured=revision` the right correction?** For C1, **yes**: `160caf75…` is the revision the driver actually measured, and the tip delta is receipt-only, so citing the receipt's revision restores the fact. The correction should also say the tip *carries* the receipt (not that the reading was taken at the tip); the report's "re-read at the landed tip" phrasing is the conflation being corrected. For C2, **no**: there is no `measured=revision` line to quote, so the spotcheck's other branch applies — re-run C2 at the tip and cite the tip, or state the receipt is not revision-bound. The plan's I6 binds only C1 (`c1-landed.txt` + the 40-hex hash), so the C2 half of D6 is outside the frozen item set and remains wrong unless the L1 adds it.
- **Anchor defect (reported, not amended).** The plan's I6 says "after the round-59 line containing `75165a07`", but `SCORECARD.md` contains no `75165a07` at BASE (`git show a677c78:SCORECARD.md | grep -c 75165a07` ⇒ 0). The plan's motivating bullet (`plans/round-60.md:27`) says the round-59 Before → after table names `75165a07` as the measured commit — that is true of the fleet report and of the spotcheck's D6 row, not of `SCORECARD.md`. The checker resolves this by requiring the repair to add an anchor line before its stating line and forbidding the stating line from containing `75165a07`; the item is reachable only because the repair manufactures its own anchor.

## Mislleading-but-passing

The sweep: I read every landed correction line against (a) the checker's item condition and (b) the
reading it produces for a reader who does not run the checker. The list below is the set of
repairs that pass the checker while leaving a materially wrong reading. It is not empty.

1. **D2 — `corpus/lessons/round-59.md:208`.** The line reads: "…the committed receipt … reads
   `C1_CHECK_SELFTEST: PASS (33 cases)` on its last matching line; the routed row's smaller count
   is superseded." It passes I2 (`i2 HOLD`, 33 stated). The reading it produces: "the receipt's
   count was 32 and is now 33" — i.e., the receipt changed. The truth (spotcheck D2; the only
   committed receipt, `selftest.txt:4`, reads 33; no receipt ever read 32) is that the 32 was a
   lesson transcription error and the receipt always read 33. The earlier draft of this line said
   "no receipt ever read 32"; the landed line dropped that clause. **Correct line:** state that
   the 32 was never in a receipt and the routed row is withdrawn, not that a smaller count is
   superseded.
2. **D4 — `SCORECARD.md:1980` (minor).** The line calls the 21 an "overcount" without naming
   `C1-F7b` or the 14:16 revision. It passes I4 (`i4 HOLD`, 20 stated). The reading it produces:
   "the battery never had 21 controls; the 21 was a miscount." The truth: the 14:16 revision of
   `plans/round-59-controls.sh` had 21 ids including `C1-F7b`; the landed battery dropped
   `C1-F7b` and has 20. A reader loses the provenance of the superseded count. Minor: the landed
   battery's count is correctly stated.
3. **D5 — pending (L1-owned).** A `SCOPE …` last line is a hand-written summary, not the scope
   gate's verdict: `corpus/scope-gate.sh` prints `ADJACENCY_SCOPE: CLEAN|DEFECT (…)` as its last
   line (r58 `final/gates.txt` shows it). The plan's I5 requires the last line to begin `SCOPE`,
   and the battery's own fixed-tree fixture writes `SCOPE stale_basis=0 breadth_drift=5
   breadth_unverified=1` (battery-built, labelled synthetic). A landed receipt whose last line is
   only that summary passes I5 but does not show the gate ran; the reader may think the scope gate
   was re-run. A second reading risk: I5 requires the same line to state `never written` while
   naming three round-60 files that must exist; unless the sentence says *what* was never written
   (the round-59 receipts), a reader can read it as "the round-60 files were never written", which
   their existence contradicts (the scout's A4). **Correct line:** "the round-59 release-clock,
   DOC_AUDIT and SCOPE receipts were never written; the round-60 receipts are `…`". **Correct receipt:** include the gate's full output (ending `ADJACENCY_SCOPE: …`)
   and, if a `SCOPE …` summary is appended, label it as a summary. The same shape risk applies to
   a hand-written `RELEASE_CLOCK:`/`DOC_AUDIT:` line: the checker reads the last line's prefix,
   not the command that produced it (plan K3 ceiling). A third reading risk: the round-60 receipts
   measure the round-60 tree, not the r59 tree (S123/S124 and the transit edit changed it); a line
   that says "the gate readings are now receipted" without saying *which round's tree* implies the
   r59 readings are verified, which they are not. **Correct line:** name the r59 receipts as never
   written and the round-60 receipts as new readings of the round-60 tree.
4. **D6 — pending (L1-owned).** A correction that states only the C1 `measured=revision
   160caf75…` passes I6 but leaves the C2 citation (`75165a07`, `c2-landed.txt`) wrong. The
   reading it produces: "the measured-commit citation is corrected" — singular, while the report's
   table has two rows and only C1 is bound. **Correct line:** state the C1 hash and that the C2
   receipt is unbound (or re-run C2 at the tip).
5. **D3 — pending (L1-owned).** A lesson line that names `R20`, `R21`, `R22` and "duplicate"
   without mapping each duplicate to its finding passes I3 but leaves the r59 table ambiguous: a
   reader still cannot tell which finding the second `R20` names. **Correct line:** map the
   duplicates (second R20 = the 14:16 citation-gate regeneration failure; second R21 = the
   wrapped-bullet class M59-1; second R22 = the symlink challenge-copy defect).

Not on the list: D1 (the reader sees `results=14 dead seats=0` and the authority; no misleading
reading) and D7 (the selftest is a real fixture harness; the mutant receipt proves it can fail).

## Divergences and plan defects (reported, never amended)

1. **I1's item field vs the guard's field.** I1 requires a line matching `results=<R> dead=<D>`;
   the guard requires flipping the I1 line's `dead seats=<n>` field. These are two spellings of
   the same count. The landed correction uses `dead seats=0`; the checker reconciles by accepting
   both (`RESULTS_LINE_RE = results=(\d+)(\s+)(dead(?:\s+seats)?=)(\d+)`, checker notes §I1). A
   strict item-condition reader would leave the landed line unresolved. The checker records the
   deviation in its docstring and `checker-notes.md` (the critic's C1.4 independently found it).
2. **I6's anchor does not exist at BASE.** `SCORECARD.md` has no `75165a07` line; the plan's
   motivating bullet mislocates the report's table to SCORECARD. The checker requires the repair
   to add the anchor before its stating line and forbids the stating line from containing
   `75165a07` (checker notes §I6). The item is reachable only because the repair manufactures the
   anchor; that is a self-certifying premise, not a pre-existing fact.
3. **I5's third prefix is not the scope gate's verdict.** The gate prints `ADJACENCY_SCOPE: …`;
   I5 requires `SCOPE`. The plan's token is the report's prose label, not the gate's output. The
   battery's synthetic fixture uses the prose form, so the battery cannot distinguish a real gate
   receipt from a hand-written summary.
4. **I3's id regex vs the lane's id convention.** `ID_TOKEN_RE = R\d+` reads the lane's
   `R<round>-<n>` ids (`R57-01`, `R58-01`, `R60-01`) as `R57`/`R58`/`R60`; a lesson using that
   convention would show one distinct id repeated. The r60 lesson must use bare `R<digits>` ids.
5. **D6's evidence mislocation.** The plan's motivating bullet says the round-59 Before → after
   table names `75165a07` as the measured commit "in SCORECARD.md"; the table is in the fleet
   report, and SCORECARD's round-59 block says only "recorded in the report". The routed defect is
   real in substance; the quoted location is wrong.
6. **I5's `never written` has two possible referents.** The line must name three round-60 files
   that exist and state `never written`; a bytes-only check cannot tell whether "never written"
   qualifies the round-59 receipts (the D5 defect) or the round-60 files it just required to exist
   (the scout's A4). The landed line must name the referent explicitly; the checker only reads the
   phrase.

## Pending conditions (for the L1's I3/I5/I6)

The checker's exact reads (from `plans/round-60-c1-check.py` and `checker-notes.md`, read-only
runs at 15:2x):

- **I3** — `corpus/lessons/round-60.md` exists; its `## Routed dispositions` section's first
  contiguous `|`-table id column (first cell of each data row) has ≥3 distinct tokens matching
  `R[0-9]+`, max occurrence 1; and **one physical line** of the lesson contains `R20`, `R21`,
  `R22` and the word `duplicate` (case-insensitive). The battery's own fixed tree fails this
  because its naming sentence wraps across two lines (`i3 FAIL routed ids distinct=6 max_occ=1
  R20/R21/R22-duplicate-line=no`); the landed lesson must not wrap that line.
- **I5** — the LAST `SCORECARD.md` line matching `supersedes the round-59 gate-evidence pointer`
  must name three distinct repo-relative paths under `.ufo/waves/round-60/final/` whose basenames
  contain `release-clock`, `doc-audit`, `scope`; each file must exist and its last non-empty line
  must begin `RELEASE_CLOCK:`, `DOC_AUDIT:`, `SCOPE`; the line must state `never written`. Path
  containment is enforced.
- **I6** — the LAST `SCORECARD.md` line containing `75165a07` is the anchor; a later line naming
  `c1-landed.txt` must contain `measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c`; the
  stating line must not itself contain `75165a07`.

## Sweep (what I ran)

- Checker diagnostic on the working tree (`--no-challenge`): `value=3 population=7 i1=1 i2=1 i3=0
  i4=1 i5=0 i6=0 i7=1 guard=0` at 15:2x; the three zeros are the L1-owned items not yet on disk.
- Checker guard leg on the working tree: `value=FAIL … guard=0` (the challenge cannot fire while
  items are unresolved; the checker's fail-closed design).
- Checker `--selftest`: `C1_CHECK_SELFTEST: PASS (37 cases)` rc 0.
- Checker on the battery's synthetic fixed tree: `value=1 … i3=0` — the wrapped I3 naming line;
  the battery's K1-REF reads `1 guard=1` instead of `0 guard=1` for the same reason.
- Transit selftest from the lane tree: `TRANSIT_SELFTEST: PASS (cases=9)` rc 0; the seat's mutant
  receipt shows 5 `FINDING TRANSIT-ST-SHIM-SHn` lines and rc 1; the real trial after the edit
  reads `HOLDS holds=5 broken=0 error=0`.
- Line-level reads: `LOG.md:1965/1969`, `SCORECARD.md:1971/1980`, `corpus/lessons/round-59.md:206/208`,
  `SKILL.md:847`, `.ufo/waves/round-59/final/c1-landed.txt`, `c2-landed.txt`,
  `build/R59ExecCounterC1/selftest.txt`, `build/R59ScribeLesson/controls-composition.txt`
  (21 unique ids after the 14:16 revision, 20 in the landed script).

SEAT-STATUS: partial — D1, D2, D4, D7 judged against the landed corrections; D3, D5, D6 are
L1-owned and not yet on disk at this reading (the checker reads i3=0, i5=0, i6=0). The pending
conditions above are exact and re-checkable; re-run the checker after the L1 lands
`corpus/lessons/round-60.md`, the SCORECARD I5 line and the three round-60/final receipts, and
the SCORECARD I6 anchor + stating line.
