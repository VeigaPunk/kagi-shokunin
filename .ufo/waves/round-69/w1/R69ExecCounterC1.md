# R69ExecCounterC1 — C1_RECORD counter

SEAT-STATUS: complete

## Files changed (sole writer)

- `plans/round-69-c1.sh` — new, 1297 lines, sha256
  `8a2745da89d4d234c6b6489313148ed1e342c13dccbe1c4799864902bd4e0b39`.
  CLI: `bash plans/round-69-c1.sh --tree DIR [--base-tree DIR] [--scratch DIR]
  [--legs L1,L3] [--verbose]` and `--selftest`. Default `--tree .`.
  bash + python3 stdlib only, `set -u`, no network, no `claim-ledger.sh
  verify`, no `plans/round-68-c1.sh --selftest`, no hardcoded `/tmp`.
  Output: one `LEG L<k> <pass|fail> <detail>` per leg in order, guard lines
  `GUARD a=… f=…`, last stdout line exactly
  `C1_RECORD: mismatches=<n> population=13 guard=<0|1>`; exit 0 iff n==0 and
  guard==1, exit 1 otherwise, exit 2 on SETUP (reason on stderr, no numeric
  verdict). Subset mode prints `C1_RECORD_LEGS: legs=… ok=<k>` as last line,
  exit 0 iff every requested leg passes.
- Receipts under `.ufo/waves/round-69/w1/R69ExecCounterC1/`:
  `selftest.txt` (`C1_RECORD_SELFTEST: PASS (29 cases)`), `run-base.txt`
  (BASE extraction, `mismatches=13`), `run-candidate.txt` (mid-wave
  `mismatches=3`), `legs-verbose.txt`, `notes.md` (guard evidence).
- This report: `.ufo/waves/round-69/w1/R69ExecCounterC1.md`.

No other lane file was written. Two accidental fleet-root writes during the
build (`/home/vgpnk/Projects/shokunin/plans/round-69-c1.sh` and
`.ufo/waves/…/notes.md`) were moved into the lane and the fleet directories
removed (verified: `git -C /home/vgpnk/Projects/shokunin status` shows no
unexpected new files from this seat).

## Mid-wave readings (measured, verbatim verdicts)

- BASE (`git archive 264917aa…` extraction): all 13 legs fail →
  `C1_RECORD: mismatches=13 population=13 guard=0`, exit 1.
  Guards: (a) 0 (no A2), (c) 1 (13/13 at BASE), (d) 1, (e) 1, (f) 1.
- Candidate (live worktree, `mismatches=3` at receipt time):
  legs L1–L10 pass (10), L11/L12/L13 fail → `mismatches=3`, exit 1.
  Guards: (a) 1, (c) 1, (d) 1, (e) 1, (f) 1; (b) 0 (mismatches ≠ 0).
  Full candidate wall time ≈ 2 s (well under the ~120 s ledger budget).
  Determinism: two runs on the same bytes read the identical verdict line.
- Subset probe (the `R68-02` row's command):
  `bash plans/round-69-c1.sh --tree . --legs L1,L3` →
  `C1_RECORD_LEGS: legs=1,3 ok=2`, exit 0.
- `--selftest`: `C1_RECORD_SELFTEST: PASS (29 cases)` (N = 29 ≥ 12), exit 0.
  Covers the constant-verdict mutant, a sub-population case, the L2
  empty-set pair, the L5 both-values pair, the L9 cost bound with a `touch`
  marker, and the L4 never-re-run proof.

## Per-leg findings (candidate, with plan sentences)

| leg | mid-wave | plan sentence it implements (plans/round-69.md §C1) | measured detail |
|---|---|---|---|
| L1 | pass | “the row carries the honest stop: it names `unprovable` and the receipt `.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt`, that path exists in the tree, and the row carries no `mismatches=0` string” | `unprovable=1 receipt-named=1 exists=1 no-mismatches-0=1`; section-scoped to `## Round 68 — post-move` + `\| calibration` row |
| L2 | pass | “the row names every criterion id that `corpus/QUALITY.md` carries with `corpus/lessons/round-68.md` in its source column (the set is derived from QUALITY, never listed) and carries no ‘enter the bar’ claim” | derived set empty; row states the empty set explicitly (`states-empty-set=1`) — the reviewer A7 vacuity fix, so an empty set is not a free pass |
| L3 | pass | “the original sentence is still present and an appended block headed `Correction (round 69)` names the superseded `C2_RECORD` sentence and the honest-stop receipt (append-only: the old bytes are never rewritten)” | original `mismatches 3 → 0` kept; `## Correction (round 69)` after it names the superseded sentence and `c2-lane-run.txt` (exists) |
| L4 | pass | “the original line is still present and an appended `Correction (round 69)` names the count the receipt `.ufo/waves/round-68/w1/R68ExecCounterC1/selftest.txt` prints (the count is parsed from the receipt, never named by the counter) and that receipt exists” | parsed 56 from the committed receipt bytes only (never a live re-run — M69-5); LOG correction names “56 cases” + the path |
| L5 | pass | “an appended correction names the value parsed from `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt` and that receipt exists” — read with §7 item 5, which names the compared receipt `.ufo/waves/round-68/base/c1-base-round67-counter.txt` | names both: round-67 `caught=6/6` (`C1_READTHROUGH:`, from the §7 receipt) and round-68 `caught=0/6` (`C1_VERIFIED:`, from `base-run.txt`); the two BASE readings stay distinct instead of being collapsed into one |
| L6 | pass | “`corpus/lessons/round-69.md` names the dead citation `.ufo/waves/round-68/final/c1-base.txt` and the corrected pointer `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt`, and the corrected path exists” | both strings present; corrected path exists |
| L7 | pass | “the file parses, the original `target` strings are unchanged, and a `superseded_by` object names `Amendment A1` and the final reading `38`/`33`” | parses; both `target` strings unchanged; `superseded_by` names `Amendment A1` and “38/33” |
| L8 | pass | “extracting the function and executing it: `(36,31,6,1,0)` is refused, `(37,32,6,1,0)` and `(38,33,6,1,0)` are accepted, and `(38,33,5,1,0)`, `(38,33,6,0,0)`, `(38,33,6,1,1)` are refused; the selftest table carries a case named `predicate-subfloor`” | all six tuples hold on the extracted `predicate_ok` (source extracted, `exec` only); `predicate-subfloor` present in `plans/round-68-c1.sh` |
| L9 | pass | “exactly one `R68-02` row exists, its expect is fully literal anchored, its command exits 0 and its last line matches the expect when executed with the row’s own timeout, and a migration journal entry carries `old_expect` = `^C2_RECORD: mismatches=0 population=3 guard=1$`” | 1 row; literal anchored; journal old_expect present; executed `bash plans/round-69-c1.sh --tree . --legs L1,L3` (timeout 600) → rc 0, last line `C1_RECORD_LEGS: legs=1,3 ok=2`. Non-executing conjuncts evaluated first, so at BASE the 3600 s command is never run |
| L10 | pass | “the round-68 freshness row carries both BASE readings (`0/6` and `2/6`) and names `.ufo/waves/round-68/w1/R68Sentinel/receipts/base-legs.txt`, which exists” | `0/6` + `2/6` present; receipt named (as `:28`, the actual `BASE caught = 2/6` line — see discrepancy) and exists |
| L11 | fail | “`corpus/QUALITY.md` carries at least four criteria with id > QM96 whose source column names `corpus/lessons/round-68.md` (the ids are derived, never listed)” | derived 0: the bar still ends at QM96, no QM>96 row names the lesson yet (sibling R69ScribeQuality has not landed) |
| L12 | fail | “`.ufo/waves/round-69/w1-results.json` parses, every seat entry has a terminal status, and `.ufo/waves/round-69/w1-spec.json` carries no `C1_RECORD:`/`C2_TEETH:` target string and no `mismatches=0`” | `w1-results.json` absent (wave unsettled); spec quarantine passes literally (placeholders only — see discrepancy). Honest mid-wave failure |
| L13 | fail | “`corpus/lessons/round-69.md` carries a line `expansion` whose `new knowledge entries=<n>` equals the number of files under `corpus/knowledge/` in the measured tree minus the same count in `--base-tree` (both derived, never listed)” | stated 0 vs want 1: `corpus/knowledge/` is 49 files on the tree (the landed `record-supersession.md`) vs 48 at BASE; the lesson’s expansion line still reads 0 (stale — sibling R69ScribeLesson wrote it before the entry landed; the L1 re-derives at integration) |

## Guard evidence (summary; detail in `notes.md`)

- (a) A2 surface map: candidate 1 (all 8 surfaces named old → new in the
  `## Amendment A2` body); BASE 0 (heading absent).
- (b) Candidate prints its own zero line: 0 mid-wave (mismatches ≠ 0).
- (c) BASE no-work control: 1 — `mismatches=13` with every leg’s mismatch
  detail printed, in a few seconds (the 3600 s row command never executed).
- (d) Decoy (L1): 1 — relocated honest-stop text in the round-67 row still
  fails L1 on the copy (subset mode).
- (e) Misplacement (L3): 1 — relocated correction in `LOG.md` still fails L3
  on the copy (subset mode).
- (f) Selftest: 1 — 29 cases, constant-verdict mutant and sub-population
  included; fixture-only, never a full lane copy.

## Discrepancies and what the counter does about them (not verdicts)

1. **L5 receipt attribution (reviewer F-1).** The frozen table names the
   round-68 receipt `…/w1/R68ExecCounterC1/base-run.txt` (whose `caught` is
   0/6); §7 item 5 names the round-67 receipt `…/base/c1-base-round67-counter.txt`
   (whose `caught` is 6/6) as the misquoted surface. The counter requires the
   correction to name **both** parsed values with their paths, so neither
   counter's BASE reading is rewritten into the other's. If the L1 wants only
   one, this leg needs an amendment; the dual requirement is the stricter,
   honest reading.
2. **L4 count (reviewer F-2, lesson M69-5).** The committed selftest receipt
   reads 56; the live selftest on the same blob prints 59. The counter parses
   the **committed receipt bytes** (R69ExecRecord's correction, 56) and never
   re-runs the selftest, exactly as the frozen sentence says (“parsed from
   the receipt”). The drift is recorded by the lesson seat as M69-5 and routed
   to the L1; this counter does not adjudicate it.
3. **L10 citation line.** The plan, spot-check and R69ExecRecord all cite
   `base-legs.txt:19`; line 19 is an M5 SURVIVED line and the `BASE caught =
   2/6` line is :28 (verified by `nl -ba` on the committed receipt). The
   counter checks the receipt path + both values, not the line number, and the
   landed freshness row cites :28. Off-by-9 citation, not a leg defect.
4. **L12 wording.** The quarantine conjunct passes literally today (both
   wave files use placeholder notation, so no literal `C1_RECORD:` /
   `C2_TEETH:` / `mismatches=0` occurs), contrary to reviewer F-6's premise;
   the leg fails on the genuinely absent settlement file. “Terminal status”
   is operationalized as a non-empty final `output` per entry — the
   dispatcher writes `output: null` only when a seat's output was not
   retained (kernel restart), which is not settled. No `status` field exists
   on the entries to read.
5. **L13 staleness is not a counter defect.** The measured want moved 0 → 1
   when `record-supersession.md` landed after the expansion line was written.
   The leg fails honestly until the lesson corrects the line at integration.

## Risks / blockers

- L11/L12/L13 are sibling-settlement surfaces; the counter will read
  `mismatches=0` only when the QUALITY bar, the settlement file and the
  corrected expansion line land. Nothing in this seat can make them pass
  early without falsifying the record.
- No git/jj mutation was performed (read-only `git archive`/`git show`/
  `git status`/`git diff` only). No tool was installed or upgraded. Scratch
  under `/fast/scratch/hyaku/kagi-r69/R69ExecCounterC1/` was removed before
  yield; receipts are under `.ufo/waves/round-69/w1/R69ExecCounterC1/`.

Checks for the L1: re-run the three receipts plus
`bash plans/round-69-c1.sh --tree . --legs L1,L3` (the `R68-02` row) and the
full candidate run after R69ScribeQuality lands (L11) and the wave settles
(L12); the counter's BASE reading (`mismatches=13`, guards c–f = 1) is already
stable and does not depend on those landings.
