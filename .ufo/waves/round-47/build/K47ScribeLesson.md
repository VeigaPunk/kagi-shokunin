# K47ScribeLesson — report (kagi round 47, attempt 1)

Seat scope: draft text only — `corpus/lessons/round-47.md` body, the SCORECARD erratum, the `## Mistakes`
rows, and the `considerthese` section. No lane file was edited; no gate was run (none is named for this
item); no claim value was measured by this seat.

## Behaviour

Read and measured, in order:

1. `corpus/lessons/round-46.md` (section shape and the `## Mistakes` table header), `corpus/lessons/
   round-46-verifier-spotcheck.md` (§5 routed defects 1–2 at `:104`, `:105`), `SCORECARD.md:1689-1700`,
   `plans/round-47.md`, `CORPUS.md:64-184` (§SOURCES.md; the `## Mistakes` row
   contract at `:171-176`; the "a fix is shown able to fail" rule at `:177-184`), `LEARNING.md` in full
   (Discernment at `:42-46`).
2. Verified the SCORECARD miscount against committed bytes at three revs (BASE r46 `f5977284`, candidate
   `0bd8888`/landing `f4a33d3d`, BASE r47 `252ef1ca`) — the required command and its output are quoted in
   `case-count-check.txt` and in the erratum draft.
3. Audited every lane gate that reads `SCORECARD.md` for a count cross-check: `self-description-sweep.sh`
   SD1–SD9 (`:8-31`), `claims-declared.sh` (`:181`, `:223`), `claim-ledger.sh` `cell` (`:80-88`). Result:
   **none** compares a numeric self-description with the gate's own assertion — so M47-1's `captured-by`
   is `none`, and the proposed replacement check was demonstrated red then green.
4. Inventoried `considerthese/` (8 dated files, newest `2026-10-26.md`) and measured the state of each of
   its four proposals at BASE, including executing `corpus/release-clock.py`'s own `STABLE_TITLE_RE` to
   test the stale fail-open premise.

## Drafts produced (all under `.ufo/waves/round-47/build/K47ScribeLesson/`)

| file | content |
|---|---|
| `erratum-scorecard.md` | appended `## Errata` section for `SCORECARD.md`: E47-1 corrects the round-46 operability row's `(8 → 11 cases)` → `(8 → 12 cases)` and "cases 9–11" → "cases 9–12"; quoted command outputs at three revs; a suggested companion `LOG.md` line; a table of the checks it rests on. Score untouched (`9 → 9`), line 1695 never rewritten. |
| `mistakes.md` | three `## Mistakes` rows in the lane's shape — M47-1 `number-drift` (captured-by **none**, audited; fix = SD10, demonstrated rc 1 → rc 0), M47-2 `attribution` (captured-by `LEARNING.md:42-46`), M47-3 `stale-premise` (captured-by none; the 2026-10-26 fail-open text vs executed regex). |
| `considerthese.md` | file inventory + newest file + one line per proposal 1–4 (state, evidence path:line, whether it fits C1/C2) + the proposed lesson section text. |
| `lesson-round-47-skeleton.md` | the `corpus/lessons/round-47.md` skeleton in round-46's section order; every unmeasured value is a `<L1: …>` placeholder, not a plausible number. |
| `proposal-sd10-demo.py` | the proposed SD10 implementation used for the red/green demonstration (reads bytes only; runs no gate). |
| `case-count-check.txt` | receipt: the required `git show … | grep -n 'cases" -eq'` command and outputs at `f4a33d3d` (122, `-eq 12`), `f5977284` (102, `-eq 8`), `252ef1ca` (122, `-eq 12`), the case-12 block, and the round-46 receipt lines. |
| `regex-test.txt` | receipt: `corpus/release-clock.py:789` at BASE, the `c303c92` predecessor, and the executed `STABLE_TITLE_RE` results for the four title variants. |
| `sd10-real-tree.txt` | receipt: `SD10: MISMATCH n=1` at `SCORECARD.md:1695`, rc 1. |
| `sd10-with-erratum.txt` | receipt: `SD10: CLEAN n=0`, rc 0, on a scratch copy with one appended `supersedes SCORECARD.md:1695` line. |

## Findings

- **The miscount is exactly the spot-check's reading, and the corrected numbers hold at BASE r47 too:**
  `f4a33d3d:corpus/claims-declared.sh:122` → `-eq 12`; `f5977284:…:102` → `-eq 8`; `252ef1ca:…:122` →
  `-eq 12`. `11` is neither endpoint. Case 12 (`same-claim-second-axis`, `f4a33d3d` lines 118–121) is
  K46RP-02's case, so the row's own citation omitted the case that answers its reviewer; case
  descriptions for 9/10/11 (lines 105–117) are correct and are left alone.
- **`captured-by: none` for M47-1 is a measured verdict, not a guess.** The three gates that read
  SCORECARD check section/tag presence, pointer presence, red-id presence and range tokens. None parses a
  `(A → B cases)` tuple.
- **The fix is demonstrable both ways.** SD10 fires on the real tree (`MISMATCH SD10 SCORECARD.md:1695
  says (… → 11 cases) but corpus/claims-declared.sh asserts $cases -eq 12`) and goes clean once an erratum
  naming that line is appended. The iteration that matters: without a `supersedes` clause, an append-only
  file keeps the check permanently red — the exemption is part of the fix. A byte-keyed variant would
  instead match its own inserted text, the M46-2 class, so the demo keys on parsed numbers.
- **M47-2 is real but self-inflicted nomenclature, not a wrong measurement.** `round-46.md:12` and `:23`
  use "non-author" for a lane-dispatched seat; `LEARNING.md:43-46` makes that impossible by definition.
  The 29/29 agreement itself is unaffected.
- **The 2026-10-26 considerthese fail-open premise is stale at BASE.** `corpus/release-clock.py:789` now
  carries a negative lookahead instead of the old `$` anchor, and the module's own regex returns
  `3.15.1` for `Python 3.15.1.` and `3.15.01` for `Python 3.15.01.` — the "period-suffixed title is
  invisible" symptom does not reproduce, consistent with `corpus/lessons/round-33.md:17` ("#3's defect is
  closed"). The `KNOWN_DEFECT` qualifier is still absent (`grep -c` → 0), so proposal 3 is
  "unimplemented, defect closed" — two facts that prior lessons (`round-41.md:231`, `round-44.md:63`)
  merged into one.
- **Proposal 3 is the only considerthese item that touches a claimed surface** (C2's GATE leg reads
  `RELEASE_CLOCK: CLEAN`). Accommodating it would amend a frozen predicate, so it is named and not taken.

## Gates

None run. This item names no gate, and the lane's full claim-ledger verify and self-counts are excluded
by the seat spec. The two scripts I did run are my own draft check
(`build/K47ScribeLesson/proposal-sd10-demo.py`, rc 1 on the real tree / rc 0 on the corrected copy) and a
read-only module load of `corpus/release-clock.py` (`regex-test.txt`, rc 0); neither mutates the lane.

## Touched surfaces

- Written: `.ufo/waves/round-47/build/K47ScribeLesson/` (9 files) and
  `.ufo/waves/round-47/build/K47ScribeLesson.md` (this report). Nothing else.
- Read-only: `corpus/lessons/round-46*.md`, `SCORECARD.md`, `LOG.md`, `plans/round-47.md`,
  `considerthese/*`, `corpus/claims-declared.sh`, `corpus/self-description-sweep.sh`,
  `corpus/claim-ledger.sh`, `corpus/release-clock.py`, `corpus/lessons/round-33.md|41|44`,
  `.ufo/waves/round-46/{final,controls}/`, `.ufo/waves/round-47/controls/`, `CORPUS.md`, `LEARNING.md`.
- Git: read-only only (`show`, `log`, `diff --stat`, `rev-parse`). No `add`/`commit`/`checkout`/mutation,
  in the lane or the fleet. Scratch `$HYAKU_SCRATCH/kagi-r47/K47ScribeLesson` created and removed via
  `trap … EXIT`; the only copy kept is the scratch tree's read of `release-clock.py` for the regex test
  (its output is committed; nothing of value stayed behind).
- No tool installed, no upgrade, no host mutation; `pacman` untouched.

## Out of scope / not done by this seat

- No claim value (C1 `value`, C2 `value`, gate lines, capture digests, rechecks, frontier line) is
  measured or asserted here; the lesson skeleton leaves them as `<L1: …>`.
- The SD10 check is a **draft**; it is not wired into `corpus/self-description-sweep.sh` (that file is
  outside this seat's write scope) and no selftest case was added for it. What was shown is exactly two
  behaviours: the real-tree red and the superseded-line green; an empty tree, a tree with no tuple, and a
  row naming a missing script were not exercised.
- `[not verified]` recorded in M47-3: whether a zero-padded `3.15.01` capture can move a clock verdict
  (the comparison path was not inspected).
- Round-46's committed lesson and report were not edited; E47-2 is the correction vehicle.

SEAT-STATUS: complete
