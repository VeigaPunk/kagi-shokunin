# R58ScribeLesson — lesson draft (non-Gate sections)

Seat: scribe. Axis: calibration. Lane: kagi round 58 attempt 1, wave `kagi-r58-w1`.
BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`; predeclaration commit `0085a5f`.

## Delivered

- `.ufo/waves/round-58/build/R58ScribeLesson/draft.md` — the lesson's non-Gate sections, ready
  for the L1 to merge into `corpus/lessons/round-58.md` (header + `source:` naming S118/S119 and
  `corpus/lessons/round-57-verifier-spotcheck.md`; `## Claims`; `## Routed dispositions` (12 rows,
  D1–D12); `## Mistakes` (6 rows); `## Sources & frontier` skeleton). 19292 B.
- `.ufo/waves/round-58/build/R58ScribeLesson/base-read.txt` — the command/output receipt behind
  every BASE number in the draft (149 lines; `$ command` + output + `[rc=N]` per step).

No corpus file was written; `corpus/lessons/round-58.md`, `SCORECARD.md`, `LOG.md`, `MANIFEST.json`
untouched. No git/jj mutation. Nothing written under `/tmp`. Scratch
`/fast/scratch/hyaku/kagi-r58/R58ScribeLesson/` (BASE extraction, r57-tip extraction, census and
scope-gate captures) deleted before this report.

## Measurement method

- Lane-local files: clean `git archive 1b13f5d` extraction (stable under concurrent sibling edits).
- Fleet-rooted gates (`corpus/scope-gate.sh` resolves `lane:<lane>` against the fleet root): measured
  in the lane worktree. Inside the extraction the same bytes read `stale_basis=3` because two
  `lane:kake` / `lane:kotoba` bases resolve into the scratch parent — recorded as mistake row 6.
- Committed-BASE vs worktree is labelled per row: sibling seats edited `corpus/lessons/round-57.md`
  and `SCORECARD.md` while this seat read; uncommitted changes are called out, never counted.

## Findings

1. **C1 population census cross-read: 8/8 unheld at BASE**, consistent with the plan's declared
   `value=8 population=8`. Each of I1–I8 was read with a pasted command (draft §Claims table; raw
   output in `base-read.txt`). The counters themselves do not exist at draft time, so this is a hand
   read, not a counter run.
2. **I2 stays OPEN at BASE — the receipt is split across two files.** Measured: `controls-prefreeze-epochC-final.txt`
   pins all five correctly (`76e836ee`, `6fcbdec7`, `140a8f2b`, `ee96476a`, `19d75337`) and carries
   **no** `CONTROLS:` line; `controls-prefreeze-epochC.txt` carries `CONTROLS: match=13 mismatch=0`
   and pins `b130bb83` (stale). No single receipt carries both, so neither alone says "measured, on
   these bytes". Closure condition (L1's fix): one receipt with all five pins **and** its own
   `CONTROLS:` line. Amendment **A1** (worktree) restates the count to `N≥13` and the uncommitted
   `-final` receipt now reads `match=15` — a candidate, not a closure. Recorded as the lesson's
   reusable mistake row `receipt-split-across-two-files`.
3. **The lane's own registry census is red at BASE and at the r57 tip, and no C1 item covers it**:
   `bash corpus/sources-census.sh` ⇒ `FAILED (findings=4 rows=117)` rc 1 at both `ee1a745` and
   `1b13f5d` — `SC_FETCH` S115/S116/S117 `missing-provenance` (`corpus/source-fetches.tsv` holds no
   row for them; `grep -c 'S115\|S116\|S117'` ⇒ 0) and `SC_USEDBY_NOCITE id=S117`. r57's
   `final/gates.txt` recorded the **fleet** validator (`kagi ok`, `rows=116`) instead. Drafted as
   routed defect D13 for round 59; not folded into any frozen predicate. **Landing condition recorded
   in the D13 row**: if this round lands any `corpus/SOURCES.md` row or `corpus/knowledge/` entry, the
   same commit must add that row's `corpus/source-fetches.tsv` provenance line and its `used-by`
   target — otherwise D13 grows and the next round inherits two reds.
4. **Plan↔artifact wave drift**: `plans/round-58.md` §Shape declares 14 seats including 1 labrat;
   `w1-dispatch.json` `counts.total=13` with roles 2 scout / 4 executor / 2 scribe / 1 reviewer /
   1 critic / 1 mutation-tester / 1 sentinel / 1 connector, no labrat. Attack 4/13 = 30.8 % (floor
   ≥25 % holds), one connector, one batched v1 wave. Recorded in the draft's shape line; §Shape is
   prose, not a predicate, and the plan is not amended.
5. **Prompt committed under the wrong identity**: fleet `.ufo/prompts/kagi-round-58.md` committed by
   `kagi-shokunin <kagi@shokunin.local>` at `22157d84`, 939 insertions, one file — r57 D10 repeating.
   The path is inside a lane's writable set and the content is the dispatched prompt, so the file is
   legitimate; the defect is the identity. The pushed commit is not rewritten; the fix is that the
   prompt file is committed by the orchestrator identity.
6. **Receipt exits are not trustworthy as filed**: `.ufo/waves/round-58/controls/scope-gate-base.txt`
   ends `rc=0` for a run whose own last verdict line is `ADJACENCY_SCOPE: DEFECT`; a direct
   `bash corpus/scope-gate.sh` exits 1 (`corpus/scope-gate.sh:660`). The census receipt
   `.ufo/waves/round-58/controls/census-start.txt` is consistent (fleet validator, warnings, rc 0).
7. **Checklist substrate gap has no lane registration**: `bash corpus/checklist-run.sh` ⇒
   `CHECKLIST_RUN: BROKEN (items=16 runnable=9 by_hand=7 failed=7)` rc 1, first failure
   `FileNotFoundError … /home/vgpnk/.config/opencode/agents/janitor.md`; `grep -rn 'CHECKLIST_RUN: BROKEN' --include='*.md' .`
   finds only r18/r57 narrative. Registered in the draft's D11 row as still open.

## Not verified

- No C1/C2 counter, trial, controls battery or receipt exists at draft time
  (`plans/round-58-c1-check.py`, `plans/round-58-c1.sh`, `plans/round-58-c2.sh`,
  `plans/round-58-controls.sh`, `corpus/openbao-policy-trial.sh` all absent), so `value=` lines for
  this round are unfilled and marked "L1 to fill".
- `/home/vgpnk/Projects/shokunin/.ufo/reports/round-58/kagi.md` is absent; D2's correction sentence
  has no carrier yet (its text is in the draft's D2 row).
- Census "after" numbers (rows, tiers, rows-touched old→new) are L1-filled placeholders by design.
- No trial was run, no OpenBao server started, no secret read.

## Tooling

No installs or upgrades. No network fetch by this seat (S118/S119 quotes are the plan's, not this
seat's admission).
