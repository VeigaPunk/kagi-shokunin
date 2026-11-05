# K40ScribeLesson — draft-settlement.md

**Skeleton for the round-40 lesson's `## Wave settlement` section.** Drafting
only; nothing outside this seat directory was written.

The wave is one v1 build wave of **10 seats** (`.ufo/waves/round-40/build-dispatch.json`,
`.ufo/waves/round-40/build-spec.json`; band 8–16; L2 floor 8 satisfied). Attack
seats = 2 reviewers + 1 critic + 1 mutation-tester = **4/10 = 40 %** (≥25 %
required); connector = 1 (≤2). The canonical planner seat is held by the L1
(`KagiR40`; the validator rejects the role — the same recorded deviation as
rounds 33, 37, 38, 39). This seat (K40ScribeLesson) is the **scribe**.

The skeleton has three parts: **§1** the shape and the seat roster with the
receipt each seat must show, **§2** the settled findings the section must carry,
and **§3** the template text.

---

## §1 — Seat roster and required receipt

Every seat writes its report to `.ufo/waves/round-40/build/<seat>.md` and its
raw receipts to `.ufo/waves/round-40/build/<seat>/`. "Must show" is the minimum
a non-author reader needs to check the seat's contribution without rerunning
it.

| # | Seat | Role | Report | Receipts present at time of writing | The receipt must show |
|---|---|---|---|---|---|
| 1 | **K40ExecLedger** | executor (C1) | `build/K40ExecLedger.md` | `c1-counter.txt`, `verify-full.txt`, `migrations-audit.md`, `untouched-rows.txt` | The counter's **exact integer and exit code** (`0`, rc 0) with the wall time; the **full** `claim-ledger.sh verify` output, with a statement that no `^(FAIL\|STALE\|MISSING)` line names any of R13-01, R21-02, R24-06, R31-02, R33-02, R34-03, and the residual red set enumerated; a per-row old→new audit of `expectation-migrations.json` against `git show 6cc8850:corpus/claim-ledger.tsv` and the candidate ledger. **Note:** the ledger verify takes ~5 minutes — the receipt must carry the exit code, not only the number. |
| 2 | **K40ExecCurrency** | executor (C2) | `build/K40ExecCurrency.md` | `c2-counter.txt`, `census.txt`, `gate.txt`, `offsets.txt`, `quotes.py`, `quotes.txt`, `sha.txt`, `sources-diff.txt` | The counter's exact integer and exit code (`3`, rc 0); `ANCHOR_PINS: CLEAN (pins=4)`; the full lane census summary line (`rows=96 A=92 … captures=96 …`); **both capture sha256 values** against `corpus/source-fetches.tsv` column 10; the **byte offsets** of both needles next to the committed 75897 / 13521; the `git diff 6cc8850 cb3f642 -- corpus/SOURCES.md` proof that S040/S041 are unedited. |
| 3 | **K40ExecGates** | executor (C3) | `build/K40ExecGates.md` | `c3-counter.txt`, `constant-mutants.md`, `controls-at-predec.txt`, `selftests.txt` | The counter's exact integer and exit code (`2`, rc 0); both selftest verdicts (`ANCHOR_PINS_SELFTEST: PASS (8 cases)`, `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`); `CLAIMS_DECLARED: CLEAN (claims=5)`; the four C3 control readings re-derived **at the predeclaration** (0 / 8 / 8 / 0); and the **constant-CLEAN mutant divergence for each gate**, with the mutant's exit code. |
| 4 | **K40ScoutDocs** | scout | `build/K40ScoutDocs.md` | `feed.txt`, `fresh-bodies/`, `offsets.txt`, `sha.txt` | The **live** re-fetch: served `<title>` lines byte-exact, the two needle offsets measured on the *fresh* bodies next to 75897 / 13521, and `sha256sum` of the fresh bodies next to `ef2d8abe…bf469b1` / `570d72c3…d3fbab5`. A `cmp` exit 0 against the committed captures is the drift answer. Receipts under the seat's own scratch, never `/tmp`. |
| 5 | **K40ScribeLesson** | scribe | `build/K40ScribeLesson.md` | this directory: `draft-trial.md`, `draft-settlement.md`, `quote-counts.md`, `overstatement-audit.md` | The four drafts above: the trial paragraph with its read-only evidence, this skeleton, the two gate-quote whitespace-token counts **with the method stated and the M40-1 precision rule applied**, and the sentence-level overstatement audit of the round-40 SCORECARD/lesson sections. |
| 6 | **K40ConnOverlap** | connector | `build/K40ConnOverlap.md` | `overlap.md` | The lane list walked, the greps run, and a per-lane verdict (adjacent vs overlapping) for python-docs currency claims, anchor-cell pinning, and gate-registry/selftest conformance. |
| 7 | **K40ReviewLedger** | reviewer | **ABSENT at time of writing** | — | The **report file** `build/K40ReviewLedger.md` and a receipt directory `build/K40ReviewLedger/`. Its remit: attack C1 without the migrations — delete a set row (counter must exit 2, never print 0), move an expect to a wrong value (counter must not read 0), blind the `CLAIM_LEDGER:` summary (counter must exit 2), and test whether a `MISSING-ID` line naming a set id can fool the counter's `grep -q " $id "`. **Status:** no report file and no receipt directory existed at the time of writing — this seat is counted as **not delivered**, and the settlement must say so rather than imply coverage. |
| 8 | **K40ReviewGates** | reviewer | `build/K40ReviewGates.md` | `fixtures/`, `gateplay-mutants/`, `receipts/` | The new false-clean classes hunted beyond F1/F2/F3/F6 and D1/D2/D3/D5, each with the gate's **exact output and exit code**, plus the C3 stub-selftest probe. |
| 9 | **K40CriticClaims** | critic | `build/K40CriticClaims.md` | `falsify.md`, `verify-noc2-cand-minus-C2-rows.txt`, `verify-forge-c1-loosened-expects.txt`, `c1-cand.stderr` | Per-claim: declared vs reproduced vs do-nothing reading, then the falsifications — the loosened-expect forgery, the C2-rows-removed separability probe, the authored-body C2 forgery, the stub-selftest C3 forgery — each with the counter's integer and the tree it was run on. |
| 10 | **K40MutGates** | mutation-tester | `build/K40MutGates.md` | `mutants.md`, `mutants/`, `fixtures/`, `mutant-diffs.txt`, `mutant-syntax.txt`, `controls-battery.txt`, `probes-*.txt`, `c1-candidate.{stdout,stderr}`, `ledger-verify-candidate.txt` | Per mutant: the mutation applied, whether it is **caught** or **survives**, and the red witness path. Mutants run on scratch copies only — never on the lane tree. |

**Delivery status at the time of writing (2026-11-05, this seat's clock):**
9 of 10 seats have a report file and a receipt directory. **K40ReviewLedger has
neither.** The settlement must record that seat as not delivered, and must not
imply its remit was covered by another seat.

---

## §2 — What the settlement must carry

The settlement is the lane's record of what the wave found; it must separate
**what the wave confirmed** from **what the wave forced the round to correct**,
and it must not restate the claims as if the wave had verified them beyond its
own receipts.

### 2.1 Confirmed (each with the receipt that shows it)

- **C1 target reproduced.** `bash plans/round-40-c1.sh` → `0`, rc 0. **Re-run
  independently by this seat** in a `git archive` extraction of the candidate
  (`cb3f642`): `0`, rc 0, 289 s wall (`real 4m49.614s`).
- **C2 target reproduced.** `bash plans/round-40-c2.sh` → `3`, rc 0 (this seat's
  candidate extraction).
- **C3 target reproduced.** `bash plans/round-40-c3.sh` → `2`, rc 0 (this seat's
  candidate extraction); both selftests `PASS (8 cases)`; `ANCHOR_PINS: CLEAN
  (pins=4)`; `CLAIMS_DECLARED: CLEAN (claims=5)`; lane census `rows=96 …`.
- **No drift on the two C2 sources** (scout's live re-fetch; captures
  byte-identical).

### 2.2 Forced corrections the settlement must record (with the receipt for each)

These are the items the wave forced **into the lesson text** — recorded, not
rewritten above, per the append-only lesson discipline. The live working-tree
lesson already carries M40-4 … M40-10 and the plan-prose note; the settlement
should carry the same list **plus** the items this seat found that are not yet
in it:

| id | one-line statement | receipt |
|---|---|---|
| M40-4 | The Gate's S095 quote count is 7 whitespace tokens, not 8 (the M40-1 class, repeated inside the lesson that mined it). | `quote-counts.md` (this seat) — `str.split` and `wc -w` agree |
| M40-5 | C1 is not causally separable from C2: four of the six migrated rows are the census summary that exists only because C2 appended its two rows. | critic `verify-noc2-cand-minus-C2-rows.txt` (counter → 4) |
| M40-6 | The C1 counter is forgeable by loosening the six `expect` cells to `^.*$`; no committed gate reads the migration journal. | critic `verify-forge-c1-loosened-expects.txt` (counter → 0) |
| M40-7 | "Forgeries cannot count" is withdrawn: a manifest-side forgery with authored bodies reads 3. | critic `falsify.md` F-C2-a |
| M40-8 | C2 reads a C3-owned file (`corpus/anchor-pins.sh`); a stub drops C2 to 2. | critic F-C2-b |
| M40-9 | C3 is gameable by a stub selftest that prints the verdict token; the counter does not execute the case list. | critic F-C3-a; K40ExecGates' constant-mutant divergence shows the *gate* catches it, not the counter |
| M40-10 | A constant-`6` C1 counter passes `c1_nowork`; QM43's wording holds only for the constant equal to the target. | mutation tester `c1-echo6`; critic F-C1-c |
| M40-3 (chronology) | The C3 counter was repaired after a candidate reading of `0` was taken and recorded; "fixed BEFORE any claim scoring" was imprecise. | committed `build/candidate-fast-gates.txt` (`C3 0`) vs the repaired counter (2) |
| plan prose | "the six new W04 duplicate-URL warnings the two new rows add" — the candidate census has the **same 19** W04 lines as the start, none naming S095/S096; the SCORECARD's "two new" is withdrawn. | `census/start-fleet.txt` vs `census/candidate-fleet.txt`; the two sorted W04 sets `diff` to nothing (this seat) |
| **M40-11 (this seat)** | The candidate's own SCORECARD cites `.ufo/waves/round-40/controls/prefreeze-gate.txt`, a receipt **not committed at the candidate** (untracked). The citations gate therefore emits a new `UNRESOLVED SCORECARD.md:1520` and the self-description sweep's SD6 count rises 3 → 4 between the BASE and candidate extractions. | `git cat-file -e cb3f642:.ufo/waves/round-40/controls/prefreeze-gate.txt` → rc 128; UNRESOLVED counts base 3 / candidate 4 with the delta being exactly that line (this seat) |
| **M40-12 (this seat)** | The two new rows S095/S096 carry `recheck: on-release` but **no** `corpus/release-clocks.tsv` binding row, so `corpus/release-clock.py` now reports `UNBOUND S095` / `UNBOUND S096` and `FAILED (on_release=30 bound=28 unbound=2 …)` where BASE read `FAILED (on_release=28 bound=28 unbound=0 …)`. Removing the two rows from the candidate tree restores `unbound=0`. R36-03's expectation (`unbound=0`) is therefore further from satisfied than at BASE. | this seat's candidate and BASE extractions; the row-removal probe |
| **M40-13 (this seat)** | The fresh-start premise does not hold: `MANIFEST.json` records kagi's rounds 36 `rejected-honest-stop`, 37 `admitted`, 38 `rejected-honest-stop`, 39 `admitted` — the three most recent closures are not three rejections. This is the M39-5 class recurring in the plan, the lesson header and the SCORECARD pre-move row. | `MANIFEST.json` rounds 1298 / 1321 / 1328 / 1343 / 1346 |
| **M40-14 (this seat)** | The committed `claims-declared.sh --selftest` covers D2 as a **fenced-code-block** heading only; the reviewer's D2 class was "fence/comment headings" and the HTML-comment variant is not in the 8 cases. The `anchor-pins.sh` F3 case is a trailing-cell shape case, while the plan and the SKILL.md registry row label F3 "schema". | `corpus/claims-declared.sh` case 3 (fence only) and header lines 15–16; `corpus/anchor-pins.sh` case 5 |
| **M40-15 (this seat)** | The two new **verbatim** quotes are raw-literal truncations at a tag boundary (S095 stops before `str.isspace()`) and a line boundary (S096 stops before "for both valid and invalid character references"). The *teachings* are unchanged on 3.15.2 (both full S040/S041 sentences still locate, count=1), but the quoted segments the registry now binds are not the sentences the teachings turn on. | `draft-trial.md` §4–5 (this seat); the raw-byte context dumps |
| **M40-16 (this seat)** | The two gates' selftests write their fixtures to `${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}` — **outside** the repo, defaulting to `/tmp`, which the round prompt's §7.4 makes non-citable. Spot-check routed item 2 is therefore only partly cleared. | `corpus/anchor-pins.sh:37`, `corpus/claims-declared.sh:37` |
| **M40-17 (this seat)** | The `c2_forge_rows` red witness cited by M40-1's fix cell never reaches the quote-locate branch it is offered for: it forges rows with no fetch row and no capture body, so the counter fails at the fetch-row check. | `plans/round-40-controls.sh` `c2_forge_rows` (this seat) |
| **M40-18 (this seat)** | The candidate lesson has no `## Census`, no `## Frontier step (§2b)`, no `## Assimilation and considerthese` and no `## Trial on real domain work` section. The plan's Frontier step requires all four; round 39's lesson has all four. The census-**after** fleet receipt (`census/candidate-fleet.txt`) and `candidate-eol.txt` are **untracked** at the candidate. | `git ls-tree cb3f642 -- corpus/lessons/round-40.md` (49 lines, three sections); `git status --porcelain` listing the two census files as `??` |
| **K40ReviewLedger not delivered** | No report file and no receipt directory at the time of writing. Recorded as not delivered. | `ls build/K40ReviewLedger*` → absent |

### 2.3 What the settlement must **not** say

- It must not restate the plan's C2 ceiling as the round's own; the plan's
  ceiling ("a body rewritten together with its capture row passes" — F7/QM40)
  is carried in, and the round-38 ceiling the plan did not carry over
  (M40-7) is named.
- It must not claim the release-clock gate is clean, or that the routed
  release-clock debt was touched: it was not, and the round's own two rows
  changed that gate's population (M40-12).
- It must not state a W04 delta that was not measured (M40 plan prose).
- It must not assert a "round report" exists in `.ufo/waves/round-40/` at the
  candidate: it does not (the SCORECARD footer points at one).
- It must not call the wave "clean": one seat did not deliver.

---

## §3 — Template text

> ## Wave settlement
>
> One v1 build wave of ten seats (`.ufo/waves/round-40/build-dispatch.json`;
> band 8–16; attack 4/10 = 40 %; connector 1). The canonical planner seat is
> held by the L1. Seat reports and receipts are in
> `.ufo/waves/round-40/build/<seat>.md` and `.ufo/waves/round-40/build/<seat>/`.
>
> **What the wave confirmed.** C1 `bash plans/round-40-c1.sh` → `0` (rc 0;
> re-run by K40ExecLedger, independently re-run by K40ScribeLesson in a
> candidate extraction: `0`, rc 0, 289 s). C2 `bash plans/round-40-c2.sh` → `3`
> (rc 0). C3 `bash plans/round-40-c3.sh` → `2` (rc 0), with both selftests
> `PASS (8 cases)`, `ANCHOR_PINS: CLEAN (pins=4)` and `CLAIMS_DECLARED: CLEAN
> (claims=5)`. The lane census at the candidate reads `rows=96 A=92 … captures=96
> …`. The scout's live re-fetch found no drift: both fresh bodies are
> byte-identical to the committed captures and both needles locate at the
> committed offsets 75897 / 13521.
>
> **What the wave forced the round to correct.** M40-4 (the Gate's S095 quote
> is 7 whitespace tokens, not 8 — the M40-1 class repeated); M40-5 (C1 is not
> causally separable from C2); M40-6 (the C1 counter is forgeable by loosening
> the six `expect` cells); M40-7 ("forgeries cannot count" withdrawn — a
> manifest-side forgery reads 3); M40-8 (C2 reads a C3-owned file); M40-9 (C3
> is gameable by a stub selftest); M40-10 (a constant-`6` C1 counter passes
> `c1_nowork`; QM43 holds only for the constant equal to the target); M40-3
> chronology corrected (a candidate reading of `0` was taken and recorded before
> the C3 counter repair); the plan's "six new W04 warnings" and the SCORECARD's
> "two new W04 warnings" are both withdrawn — the candidate census has the same
> 19 W04 lines as the start, none naming S095/S096.
>
> **Recorded by this seat (K40ScribeLesson).** M40-11 (the candidate's own
> SCORECARD cites the uncommitted `controls/prefreeze-gate.txt`, adding a new
> UNRESOLVED and a new SD6 red at the candidate); M40-12 (the two new rows are
> `on-release` but unbound in `corpus/release-clocks.tsv`, so the release-clock
> gate now reports `UNBOUND S095`/`UNBOUND S096`); M40-13 (the fresh-start
> premise does not hold on the manifest's verdicts — the M39-5 class
> recurring); M40-14 (the committed `claims-declared.sh` selftest covers D2's
> fence variant only, and F3 is a shape case labelled "schema"); M40-15 (the
> two new verbatim quotes are raw-literal truncations, so the quoted segments do
> not contain the clauses the teachings turn on, although both teachings are
> unchanged on 3.15.2 — see §Trial on real domain work); M40-16 (the two gates'
> selftests write fixtures outside the repo and default to `/tmp`); M40-17 (the
> `c2_forge_rows` witness never reaches the quote-locate branch it is cited
> for); M40-18 (the candidate lesson carries no §Census, §Frontier step,
> §Assimilation or §Trial section, and the census-**after** fleet receipt is
> untracked).
>
> **Not delivered.** K40ReviewLedger produced no report file and no receipt
> directory; its remit (attack C1 without the migrations) is not covered by
> another seat and is not claimed as covered.
>
> Every verdict above is the L1's reading of committed receipts plus the seat
> reports named; the wave's seats are lane evidence, not outside agreement.

---

## Provenance

- Seat roster, roles and assignments: `.ufo/waves/round-40/build-spec.json`
  (read with `python3`/`json`), `.ufo/waves/round-40/build-dispatch.json`.
- Receipt inventory: `ls .ufo/waves/round-40/build/` and
  `ls .ufo/waves/round-40/build/<seat>/` (read-only).
- This seat's own measurements: `quote-counts.md`, `overstatement-audit.md`,
  `draft-trial.md` in this directory.
- Tool installs: **none**. Git: read-only (`git log`, `git show`, `git diff`,
  `git ls-tree`, `git cat-file`, `git archive`, `git status`); no commit, no
  push, no branch or worktree mutation anywhere.
- Scratch: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40ScribeLesson/`
  (read-only extractions of BASE and the candidate, plus two mutation probes),
  removed before this seat finished.
