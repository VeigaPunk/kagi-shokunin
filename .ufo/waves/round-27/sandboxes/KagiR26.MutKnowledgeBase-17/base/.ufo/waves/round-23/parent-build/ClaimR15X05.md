# ClaimR15X05 — semantic audit of claim row R15-05 (round 23 parent-build, advisory, read-only)

Observed revision: kagi-shokunin `HEAD d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-21).
Working tree at audit time: untracked `.ufo/waves/round-23/`, `plans/round-23.md`,
`corpus/closure-dispositions.py` (no `corpus/closure-dispositions.json`, no `corpus/fixtures/`);
`SKILL.md` modified at L643 only (mtime 2026-10-21 00:54, `OP_REF_SELFTEST: PASS (29→36 cases)`),
outside the checklist section. No gate or row command executed. No public sources used. Tool installs: none.

## Row

`corpus/claim-ledger.tsv:37`: `bash corpus/checklist-run.sh --ratio` · expect
`^CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6$` · exit `0` · timeout `30` ·
note carries no `[substrate]` tag. Byte-identical to the round-22 freeze
(`.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:37`; freeze→current diff touches rows at
lines 23, 28–29, 32, 49–50, 52, 54+ only).

| Obligation part | Status | Basis |
|---|---|---|
| expect / last line | supported | §1 static re-derivation reproduces the pinned line exactly |
| exit 0 | supported | zero declaration defects re-derived over HEAD bytes (§1) |
| timeout 30 | supported | 0.184 s (r22 receipt), ~0.2 s (r15 LOG); ≈150× margin |
| note: 9/16, floor 8, 7 by-hand, E1/E5/H7 delegated, 6 direct introduced in r15 | supported, causally | §1 git first-add dates |
| note: replaced prose "was wrong at every revision it appeared in" | refuted as an unconditional statement (depends on criterion) | §6 |

## 1. Causal path (static reading, not executed)

- `--ratio` sets `MODE=verify RATIO_ONLY=1` (`corpus/checklist-run.sh:82`). `verify()` runs these steps in order: item
  extraction from `SKILL.md` `## Credential-hygiene checklist` (:100–117); `load_rows` POLICY shape and deny
  list (:120–171, deny ERE :75); duplicate ids; UNDECLARED/EXTRA; lead bijection both ways; DUPLICATE-REASON;
  the floor (:246). It then prints the ratio line and returns before any row executes (:250–254).
  Inputs are `SKILL.md` (via `ROOT`, :66–68), `corpus/checklist.tsv` (:67) and `mktemp`; nothing else.
  There is no `$HOME`, no handler and no network.
- Re-derivation: I reimplemented the declaration checks in Python over the HEAD bytes; this is not a gate
  run. Result: items=16, rows=16 with 8 columns, no lead/item/reason/deny/shape defects, and the derived line is
  `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`.
  floor = (16+2−1)/2 = 8 (:73, :174), and 9·2 ≥ 16.
- `delegated=3` is a lexical prefix test, `^bash[[:space:]]+corpus/` (:244). It matches E1
  (`surface-census.sh` + `drift-pins.sh`), E5 (`op-ref-probe.sh`) and H7 (`transcript-scan.sh`).
  **Causality check:** every delegate predates the round-15 commit `587fda0`: drift-pins `5f55ba8`
  (r6), transcript-scan `148ae5c` (r8), surface-census `03477c0` (r10), op-ref-probe `4b8c018` (r13).
  `corpus/checklist.tsv` and `corpus/checklist-run.sh` each have exactly one commit (`587fda0`), so "6
  assertions this round introduced" (E4, E8, H1, H3, H4, H8) holds.
- The last line does not change when the declaration is defective. In ratio mode, defect lines print *before* the
  ratio line (:246 → :251), so a defect that preserves the counts (DUPLICATE-LEAD/ITEM, DUPLICATE-REASON)
  leaves the pinned last line intact and exits 1. The exit code carries that check, and the ledger
  compares the exit code before the last line (`corpus/claim-ledger.sh:432–443`).
  `corpus/knowledge/checklist-execution.md:50` lists the ratio line's exit as "—", which understates
  this. A consumer that grades R15-05 on `last` alone would report it clean when it is not.

## 2. Historical vs current evidence

- **Historical, r15** (`587fda0`), from `LOG.md:540–545`: "`--ratio` ⇒ the same ratio line in 0.2 s with no row
  executed".
- **Historical, r22**, from `.ufo/waves/round-22/final-verification.json:236–247`: exit 0, the exact line,
  `passed: true`, 0.184 s. The safe-row plan is `.ufo/waves/round-22/safe-row-plan.json:103–109`. The receipt
  records `.h1 = 8ada17a5`, while the routed defect D6 says the measured bytes are `4be5da3`. That difference does
  not matter for this row: `checklist-run.sh` and `checklist.tsv` are identical at
  `c2cab35`/`254d632`/`8ada17a`/`4be5da3`/HEAD, and the checklist-section hash (`24e60673…`) is identical at all
  of them and in the working tree.
- **Current, HEAD bytes:** the §1 re-derivation; `checklist-run.sh` and `checklist.tsv` match their stamps
  exactly (`corpus/stamps.tsv:2–3`). HEAD `SKILL.md` matches `stamps.tsv:70`. The working-tree `SKILL.md`
  does not (`dc5d9867…` vs `00d6202f…`) because of the L643 edit. That edit lines up with R12-02's `36 cases`
  pin and looks like in-flight integration. It does not affect this row's inputs; its effect on the stamp
  belongs to the R12-03/R22-03 owners.

## 3. `[substrate]` deferral, SKIP-SELF and hermetic mode

- `[substrate]`: deferral is triggered by a tag in the note (`claim-ledger.sh:416–418`). R15-05 is untagged and
  never deferred, which is correct because `--ratio` touches no substrate. Its twin R15-01 (full run) is tagged
  and was skipped in r22 (`final-verification.json` `skipped_rows`). R15-05 is therefore the **only executed
  operability evidence** on this host. It preserves its own obligation (declaration ratio), but it cannot stand
  in for R15-01's execution obligation; the erratum at `checklist-execution.md:193–203` already says deferred
  live rows stay unverified.
- SKIP-SELF is keyed on `*claim-ledger.sh*` in the command (`claim-ledger.sh:816`), so it never applies to
  R15-05. `checklist-run.sh` refuses `claim-ledger\.sh` in a row check (:75), and `--ratio` executes no row,
  so there is no recursion route.
- Hermetic vs synthetic: `--ratio` is independent of the host but reads the production declaration. The
  synthetic proof is R15-02's selftest (`checklist-run.sh:426–491`: ratio clean, ratio floor-breach exit 1, and
  "runs no row"). **However, no selftest fixture contains a delegated row.** All fixture checks are
  `printf`/`sleep`/`exit`/`true`, and `bash corpus/claim-ledger.sh verify` is refused by POLICY before it is
  counted (:380). The `delegated`/`direct` classifier is therefore exercised only by R15-05 against
  production data.

## 4. What C3 (`cells` hermetic) must keep for this row

1. R15-05 stays a direct safe row executed at the repo root, independent of R23-01. The round-23 pre-move
   operability cell is anchored on it (`SCORECARD.md:830`). R15-05 is also cited at
   `SCORECARD.md:215, 228, 292, 313, 621, 706, 735`.
2. `cells` runs cited rows with `cd "$ROOT"` (`claim-ledger.sh:426`). If a fixture-root `cells` run cites
   `R15-05`, it will run the fixture's own `corpus/checklist-run.sh`. If that file is absent, the result is exit
   127 and a FAIL. If it is a copy, the run verifies the copy, not production. Fixture rows should therefore
   use fixture-only ids, so that a fixture `CELL_AUDIT: CLEAN` cannot be read as evidence for R15-05.
3. Keep SKIP-SELF keyed on the ledger script name (:816) and deferral keyed on the note tag (:416). R15-05 must
   stay untagged; R18-02's `^11$` pin would expose a new tag.
4. `rows_run` includes deferred rows: `C_N` increments at :415, before the DEFER test at :416–418, and is
   copied at :828. For the operability cells citing `R15-01`, `R15-05` (:228, :292, :313, :621), only R15-05
   actually executes on this host. A C3 receipt should not present `rows_run` as the number of executed rows.

## 5. What C1 (closure-dispositions) must keep for this row

- `parse_obligations` is scoped by section (`corpus/closure-dispositions.py:76–101`). R15-05 appears in the
  spot-check only in `## Per-axis verdicts` ("operability | unchanged | R15-05 ratio unchanged",
  `corpus/lessons/round-22-verifier-spotcheck.md:96`, section :82). The parser correctly creates **no**
  obligation from it, because no routed defect (:163–184, D1–D9) names R15-05. Keep that scoping.
- That axis basis is still claim-count-style assurance, and the checker never resolves it. If C1 ever follows
  row pointers, a pointer to R15-05 must bind the row's exit + last-line receipt. POINTER-ID (:117–120) only
  tests that the id token is present.

## 6. Consumer-visible false-clean (one): `delegated` never resolves the delegate

- **What the docs claim:** `checklist-run.sh:29–30` says "`delegated` = rows whose check is `bash corpus/<gate>.sh`, i.e.
  the item already had a gate". The R15-05 note says "3 delegate to an existing gate (E1, E5, H7)", and
  `checklist-execution.md:103` calls the split "the only mechanical signal that a row is not simply
  re-asserting an existing gate's exit".
- **What the code does:** it counts by prefix only (:244), never checks that the path exists, and `--ratio` executes nothing.
- **Host coupling:** no executed safe row runs `corpus/surface-census.sh` (E1's first delegate).
  R11-01/02/03 and R15-01 were all skipped in r22. `scope-gate.sh` names it only in comments and messages
  (:81, :121, :639). Its only coverage is the byte pin at `stamps.tsv:63`, which R22-03 would flag if the file
  were deleted.
- **How the false-clean happens:** a `checklist.tsv` edit points E1 (or a new delegated row) at a
  non-existent path and lands with a journaled `stamps.tsv:3` re-pin. Every executed safe row then stays green:
  R15-05 still prints `delegated=3` with exit 0, R15-03 `--list` executes nothing, R15-04 only counts ids, and
  R15-01 is deferred. The operability cells keep their evidence while E1 delegates to nothing.
- **Minimal synthetic falsifier for L1 (proposal; NOT executed):** use the selftest harness — `items6` SKILL,
  `rest_rows` C2–C6 (:346–365) — with this C1 row:
  `C1⇥runnable⇥alpha⇥bash corpus/no-such-gate.sh⇥0⇥^A1: OK$⇥-⇥alpha delegates to an existing gate`,
  run with `--tsv T --skill S --ratio`. `ROOT` stays the real repo root (:66), so the path must not exist in
  the repo.
  - Current outcome [INFERENCE: static reading of :120–171, :244, :246, :250–254]: last line
    `CHECKLIST_RATIO: runnable=4/6 floor=3 by_hand=2 delegated=1 direct=3`, exit 0.
  - Wanted: `DELEGATE-MISSING C1 (corpus/no-such-gate.sh)` before the ratio line, exit 1.
- **Fix sketch:** in the :241–245 loop, for each `bash[[:space:]]+(corpus/[A-Za-z0-9._-]+\.sh)` token (E1
  has two), add `[[ -f "$ROOT/$tok" ]] || defect …`. All four production delegates exist
  (`stamps.tsv:7, 55, 63, 65`), so R15-05's line and exit do not change.
  - Coupling: the added case(s) move R15-02's `PASS (34 cases)` pin and the 34-case text in
    `checklist-execution.md` (R15-02's owner).
  - Bound: existence at run time does not prove that the item "already had a gate" before the round. That part
    can only be checked in git history, which I checked here for the current four.

## 7. Secondary calibration: the note's historical clause

The note says the prose "12 checklist items are still operator judgement" was "wrong at every revision it
appeared in".

- **Wording:** that exact wording is not found verbatim. `03477c0:SCORECARD.md:28,40` reads "12 of the
  checklist items are still operator judgement" and "Two runnable verdict gates (drift, transcript) + 12
  checklist items that are still operator judgement". `301b9ec`/`4b8c018` L62/L84 read "12 checklist items
  still operator judgement".
- **The count at r9–r11:** the list had 14 items. Three of them name a live gate: item 1
  (drift-pins, plus surface-census from r10), item 2 (`--pin`) and item 13 (transcript-scan).
  - "Wrong" (≤11 judgement items) holds only if item 2 counts as gate-checked.
  - R15's own E2 row classes that item `by-hand` (manual-change; `checklist.tsv` E2; `checklist-execution.md:80`).
  - Under the row's own rule the r9–r11 state is 2 runnable + 12 by-hand, which is exactly the old figure.
- **What is affected:** this is historical prose only; expect, exit and timeout are untouched.
- **Fix:** an appended erratum that states the criterion, not a rewrite.
- **Not a repeat of round 22:** Entry04 D2 audited only the attribution and the 14-item count
  (`.ufo/waves/round-22/build/Entry04.md:98–111`), not this criterion.

## Limits

- No `claim-ledger.sh`, `checklist-run.sh` or sibling gate was run. The Python re-derivation approximates bash
  ERE; this is safe here because the leads are literal or use only `.`.
- Git use was read-only: `rev-parse`/`log`/`show`/`diff` and `git show HEAD:… | diff`. Disclosure: two early
  `git status --porcelain` calls may have refreshed the `.git/index` stat cache (no content change).
- The working tree was changing during the audit. Evidence is bound to HEAD `d218603` plus the working-tree
  reads stated above.
- No contradiction rose to the "serious" bar for messaging KagiR23: no verdict, exit or pin is falsified at HEAD.
