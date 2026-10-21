# RevScorecardShape — shape of the round-28 SCORECARD.md section

Reviewer seat; scope = the **shape** of the round-28 `SCORECARD.md` section and its coupling to
`corpus/claim-ledger.sh cells` / `corpus/claim-ledger.tsv`. Production files are READ ONLY to me;
the lane tree was not edited. All runs in my sandbox
`.ufo/waves/round-28/sandboxes/RevScorecardShape-7/{base,clone}` (`base`=`git archive` of BASE,
`clone`=`git clone --no-local` of the lane). BASE reviewed
`3553d499577084a6c98d7078906017840bbf7b28`; lane HEAD seen mid-review `62a33b1` (round-28
candidate), already carrying a `## Round 28 — …` section — hence F1/F2/F3. Companions (same dir):
`RevScorecardShape-skeleton.md` (skeleton, shape rules, 10-item checklist) and
`RevScorecardShape-commands.md` (all 30 commands with exits).

## Findings

**F1 — HIGH: the round-28 heading shape is one the lane's own cell audit rejects; `cells` exits
2.** `claim-ledger.sh:940` accepts only `SEC_RE='^ {0,3}##[[:blank:]]+Round [0-9]+ —
(pre|post)-move([[:blank:]]|$)'` (+ one legacy exemption `:944`); `:979-993` **dies** on any other
`## Round …`. At BASE `SCORECARD.md:1017` and `:1081` (rounds 26, 27) both fail it → the audit
stops at round 26 and **never reaches round 28**. Executed at BASE: `bash
corpus/claim-ledger.sh cells` → exit **2**, `unrecognised round heading … '## Round 26 —
bounded release-drift response'`. The candidate's own round-28 heading (`## Round 28 — canonical
version tokens; derived anchors bound to feed rows`) is *also* non-conforming: with only 26+27
renamed, `cells` still exits 2, naming round 28. **Required:** `## Round 28 — post-move
(…title…)` — em dash, literal `post-move`, space.

**F2 — HIGH: the scored section must carry all six axes exactly once.**
`claim-ledger.sh:955-963` (`section_check`) enforces this per recognised section. Executed with a
one-row table: `does not carry all six axes exactly once (found=1 missing=depth coverage
operability freshness calibration adjacency)` → exit **2**. Rounds 9–25 have a `pre-move` **and**
a `post-move` section, each with all six rows; rounds 26/27 have one free-form section each (not
scored at all). Any conforming heading round 28 uses needs its own six-axis table.

**F3 — HIGH: three of the candidate's six round-28 cells are UNCITED.**
`claim-ledger.sh:1013-1024` requires each cell to name a resolving `R<d>-<d>` ledger row **or** a
path in `corpus/stamps.tsv`; else `UNCITED` → BROKEN → exit 1. Executed at candidate HEAD with the
three headings made conforming: `UNCITED SCORECARD.md:1121 freshness`, `:1122 calibration`, `:1124
coverage`; `CELL_AUDIT: BROKEN (cells=198 row_pointed=143 stamp_pointed=89 uncited=3 …)`. Cause:
those cells cite `S044/S045/S046`, `QM27–QM29`/`M28-1..M28-4`, `S047–S049` — source/lesson ids,
which `is_row` (`:869-873`) and `stamp_index` (`:482-486`) do not accept; no `R28-xx` row was
added (`R21-04` still pins `^65$`). Two lawful fixes, both executed: (i) cite the stamped lesson
path `corpus/lessons/round-28.md` → `uncited=0 stamp_pointed=92`; (ii) add `R28-xx` rows — but the
frozen command is **policy-refused** (`claim-ledger.sh:262-278` allows only `python3 corpus/(…|release-clock).py`;
executed `POLICY R28-99 reason=python-script`) — an allowlist change, L1's call.

**F4 — MEDIUM: adding/renaming headings breaks two pinned count rows.**
`claim-ledger.tsv:29` `R13-01` pins `grep -c '^## Round '`=`^33$`; `:69` `R24-06` pins
`row-identity.sh scorecard-rounds`=`count=33 sha256=cb0f57e0…`. The candidate migrated both (`:34`,
`sha256=c59f5341…`; verified matching `row-identity.sh` at candidate HEAD). **But** renaming
26/27/28 to the conforming form changes the heading *text* → new digest → `R24-06` stale again:
executed (all three renamed) `count=34 sha256=069aac65…` ≠ pinned `c59f5341…`. Count stays 34.

**F5 — MEDIUM: `SCORECARD.md` is itself stamp-pinned; editing it needs a full re-stamp.**
`corpus/stamps.tsv` row 3 pins it (BASE `e314c29…`/1107 lines; candidate `cab4752a…`/1129). Any
edit → `STALE SCORECARD.md` → `verify` exit 1 (executed `STALE SCORECARD.md
sha=e314c2979860->d4bc3e764079 lines=1107->1109`). And `bash corpus/claim-ledger.sh stamp
SCORECARD.md` alone is **refused** — `stamp` replaces the whole row set and refuses to shrink
(`:395-407`); executed `refusing to shrink … 'LOG.md' is pinned and would be dropped (existing 90
rows, new 1)` exit 2. Correct form: the full path list (`STAMPED: n=91`).

**F6 — MEDIUM: the scorecard's "audit is green" claim is not true today.**
`claim-ledger.tsv:38` `R13-03` expects `^CELL_AUDIT: CLEAN` exit 0, but `cells` exits 2 at BASE
(F1) and `R13-03` is `[substrate]`-tagged (verified), so `verify` prints `HOST-SKIP R13-03` →
`CLAIM_LEDGER: INCOMPLETE (… layout_incomplete=1 …)` (executed at BASE and candidate HEAD;
`--allow-host-rows` also INCOMPLETE). Hence `SCORECARD.md:208` and `:230` ("the scorecard audit is
green", pointer `R13-03`) are false today; round 28 must not repeat that sentence, and rounds
26/27 need repair for the gate to run.

**F7 — LOW: capabilities row? → no row, but the stagnation sentence is required.**
`AXES.md:59-64`: a capability row enters only via a round that demonstrates it running; round 28
declares none (`plans/round-28.md:10-13`), so `## Capabilities` (`SCORECARD.md:680-690`) gets
**no new row** and `:690` ("latest first-working round … is 25") stays true. The section **must**
carry the stagnation statement (`AXES.md:66-73`): window N=3, last capability round 25 → rounds
26/27/28 without one → the nudge **cannot fire before round 29**; no
waiver/capability/retirement/promotion claimed. The candidate states this correctly. Note
`SCORECARD.md:694` is **stale** ("the earliest round it can fire is round 25 (after rounds 22–24
with none)") — capabilities entered in rounds 22, 23 and 25 per `:684-689`; round 28's sentence is
accurate, and history is append-only, so the stale one must be *noted*, not rewritten.

**F8 — LOW: `planned` is a required scorecard field.** `AXES.md:81` requires "the next round's
intended claims (1–3), each with its target axis or capability". Round 26 carries it
(`SCORECARD.md:1040-1042`); round 27's section (`:1081-1107`) has **no** planned-next line, and the
candidate round-28 section ends on a forward promise ("appended below after the measured revision
lands"). At landing it needs the measured-revision paragraph **and** a planned-next paragraph.

**F9 — LOW: the candidate renders the frozen counting commands with a changed placeholder.**
`plans/round-28.md:29,59` freeze `python3 -I -B .ufo/waves/round-28/tools/c{1,2}-measure.py <rev>
<label> <out.json>`; the candidate writes `<out>` (grep over `git show HEAD:SCORECARD.md`). The
plan says those commands are "written this round, then never changed"; quote them verbatim.

## Required content (checklist) and commands run (exits)

Checklist (10 items) and the full command table (30 commands, stdout fragments) are in the two
companion artifacts. Headlines: `cells` exits **2** at BASE and at candidate `62a33b1`
(round-26 heading); with the three headings conforming the candidate's own tables give `UNCITED`
on its freshness/calibration/coverage cells (`BROKEN … uncited=3`), and adding the stamped
lesson path to those three gives `uncited=0`; `verify` is `INCOMPLETE` at BASE (layout_incomplete=1)
and at candidate (stamped=91), no `FAIL` rows; an unmigrated simulated landing fails 7 rows
(R12-03, R13-01, R22-03, R24-05, R24-06, R24-15, R25-02) and `self-counts` reports 3 STALE
stamp-count numbers; `stamp SCORECARD.md` alone is refused (shrink guard); the frozen C1/C2
commands are ledger-policy refused; at BASE the F1 fixture exits 0 with `fired=4` (the
leading-zero lie accepted as fired) and F2 exits 1 with a `ValueError` traceback at
`corpus/release-clock.py:380`.

## What I did NOT check

* No vault / account / handler / CDP / network contact. **F3/F4 (the `--observe` leading-zero
  and oversize fixtures) were not executed** — they need a *local copy* of the python.org feed
  and the receipt-mirroring clarification is an L1 plan correction I did not re-derive; my
  F1/F2 results are table+receipt only.
* No claim about the candidate's C1/C2 code correctness (I read the `release-clock.py` diff only
  to confirm `NON-CANONICAL`/`DERIVATION` exist); did not run or read the round-28 falsifier
  wave; did not evaluate the C1/C2 axis re-booking (`CritC2Axis` — that seat's scope; I checked
  only the shape consequence); did not verify the candidate's claimed BASE numbers (3/4
  MISHANDLED, 4/4 ACCEPTED, control CLEAN30) beyond the control and the C2 BASE run; did not
  check `.ufo/waves/round-28/final/` receipt contents; did not reproduce the declared
  `SC/PV-CLOCK-SELFTEST` separability edge. No tool installs.
* Did not touch the lane tree: no lane file created/edited/staged/committed by me except this
  report and its two companion artifacts (sandbox under
  `.ufo/waves/round-28/sandboxes/RevScorecardShape-7/`); I ran the lane's read-only
  `c2-measure.py` (cmd 9) and read-only `git` in it.
