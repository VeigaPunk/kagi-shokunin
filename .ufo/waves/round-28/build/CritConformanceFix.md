# CritConformanceFix — attack on the round-28 mined-mistake fix (round-conformance check)

Seat: KagiR28.CritConformanceFix-7 (critic, advice only). Target: the check XConformance is assigned to write
(`build-spec.json` "XConformance": (1) plan first-commit purity, (2) census-start present and committed no later
than the plan, (3) frozen counting-command lines identical at first commit and tip; FAIL round 27, PASS round 28).
No XConformance draft existed, so I wrote a literal reading of the spec (`spec_check.py`) and a hardened draft
(`hard_check.py`) in `sandboxes/CritConformanceFix/`, and ran both on the real lane (read-only git) and on 21
synthetic histories built from the real `bdf90f5` plan and census. Citations are at BASE `3553d49`, except
`plans/round-28.md` (absent at BASE), which is cited at `b9a42c0`; its lines 1–91 equal `bdf90f5`.

## Findings (most severe first)

1. **Check (3) cannot detect round 27's third defect, and it never fires on real history.** Round 27's counting
   commands are prose (`plans/round-27.md:20`, `:32-33`), so there are zero indented command lines. The C2 widening
   was *appended* under `## Plan corrections` (`plans/round-27.md:48`, `:50` "C2 scope widened before landing")
   in `3fb7727`, after the candidate code landed in `144babc`; the frozen prefix stayed untouched. The spec check
   on round 27 reports only the first-commit impurity and the missing census, with `frozen_cmd_lines=0` (exit 1).
   Check (3) also passes vacuously on rounds 24–27. The acceptance "FAILS on round 27" is met by check (1) alone
   (1873 extra paths), so it would still be met if checks (2) and (3) were no-ops. That is premature saturation.
2. **The plan's own correction rule permits the round-27 shape.** `plans/round-28.md:88` says corrections are
   "appended below this line". A late, appended widening (CE12) passes the spec. Only a timing rule can mark it:
   any plan-touching commit after the first must touch only the plan, and no work commit may precede it.
   Round 28's correction declares exactly that timing ("before any measurement tool or patch exists", `:93`),
   and `b9a42c0` (plan-only, child of `bdf90f5`) satisfies it.
3. **A census-start file is not evidence of a start census.** Round 28's census-start body is byte-identical to
   the round-26 and round-27 *end* census stdout (checked: `stdout==body` is True for both). The only
   discriminator is a self-written timestamp (`2026-10-21T13:38:30-03:00`). That timestamp falls inside the
   window from the BASE commit (13:29:03) to the plan commit (13:44:04), but it can be forged. The end census
   records `source_registry_sha256` (`.ufo/waves/round-26/census-end.json:12`); the start census does not. A census
   run on a dirty uncommitted tree (CE17) passes the spec **and** my hardened draft. This is the honest residual.
4. **Check (1) path-filter holes.** "No path outside `plans/`" accepts: a candidate patch under `plans/` (CE08);
   a rename of code into `plans/` (CE07; `git show` defaults to rename detection and lists only
   `R100 corpus/helper.py plans/helper.py`); work committed *before* the pure plan commit (CE02), or with the BASE
   line moved onto the work commit (CE03); delete/re-add laundering, where the earliest add is the pure one (CE14);
   and a merge carrying code (CE09). In CE09, `git show --name-only` lists only plan and census, but
   `diff-tree --no-renames HEAD^1 HEAD` shows `M corpus/release-clock.py`. The spec exits 1 there only because
   `git log --diff-filter=A` skips merge diffs ("plan-missing"): the right exit for the wrong reason.
5. **Check (2) holes:** "exists" accepts an empty census (CE05), `exit=1` (CE06), and a census rewritten after work
   (CE04; round 27 already appended a census-start correction, `corpus/lessons/round-27.md:262`).
6. **Check (3) holes beyond finding 1:** frozen fixture or predicate text edited with command lines unchanged
   (CE10, F1 `3.15.01`→`3.15.1`); a widening that is made, measured against, then reverted (CE11); an uncommitted
   worktree edit (CE15); a measurement tool body rewritten with its command line unchanged (CE16), although
   `plans/round-28.md:27` says "written this round, then never changed". `tools/c2-measure.py` already exists
   *untracked*, so a git-only check is blind to edits before its first commit.
7. **"Plan committed alone but empty":** the literal 0-byte variant (CE21: empty plan, then the full plan plus
   code) *is* caught by the spec (`frozen-lines-changed first=0 tip=2`). A stub plan (only a BASE line and the
   corrections heading) whose claims are appended later as corrections alongside code (CE01) passes it.

## Counterexamples (synthetic, same round-28 layout; `case-summary.tsv`)

| case | spec | hardened (typed) |
|---|---|---|
| CE01 stub frozen part, claims appended with code | 0 PASS | PLAN-NO-CLAIMS, PLAN-AMENDED-WITH-WORK |
| CE02 code committed before the plan | 0 | PLAN-NOT-ON-BASE |
| CE03 same, BASE line moved to the work commit | 0 | BASE-NOT-ADMITTED (needs MANIFEST) |
| CE04 census rewritten later | 0 | CENSUS-START-REWRITTEN |
| CE05 empty census / CE06 census exit=1 | 0 / 0 | CENSUS-START-NO-TIMESTAMP,-EXIT / -EXIT |
| CE07 rename into plans/ / CE08 patch in plans/ | 0 / 0 | PLAN-FIRST-IMPURE |
| CE09 merge carries code | 1 (wrong reason) | PLAN-FIRST-MERGE |
| CE10 frozen fixture text edited | 0 | FROZEN-REWRITTEN |
| CE11 widen, measure, revert | 0 | FROZEN-REWRITTEN, PLAN-AMENDED-AFTER-WORK |
| CE12 late appended widening (round-27 shape) | 0 | PLAN-AMENDED-AFTER-WORK |
| CE13 corrections heading moved up | 1 | FROZEN-REWRITTEN |
| CE14 delete/re-add laundering | 0 | PLAN-READDED, FROZEN-REWRITTEN, PLAN-AMENDED-WITH-WORK |
| CE15 dirty worktree plan | 0 | PLAN-WORKTREE-DIRTY |
| CE16 measurement tool rewritten | 0 | TOOL-REWRITTEN |
| CE17 census run on dirty uncommitted tree | 0 | **0 PASS (residual)** |
| CE18 census hash ≠ BASE `corpus/SOURCES.md` | 0 | CENSUS-START-NOT-BASE-REGISTRY |
| CE19 census committed after the plan | 1 | CENSUS-START-NOT-WITH-PLAN, -OUT-OF-WINDOW, PLAN-FIRST-IMPURE |
| CE20 plan on a side line, code merged | 0 | WORK-OFF-PLAN (+ PLAN-READDED, label noise from `-m`) |
| CE21 0-byte plan, then full plan with code | 1 | PLAN-NO-BASE, PLAN-NO-CLAIMS, PLAN-AMENDED-WITH-WORK |
| GOOD (plan+census, plan-only fix, tool, work) | 0 | 0 PASS |

Real lane (`real-lane*.txt`): spec FAILs rounds 24–27 (always on check 1; check 3 never fires), PASSes 28.
Hardened FAILs 24–27 with 4–6 typed defects each (round 27: PLAN-FIRST-IMPURE, CLAIM-NO-COUNTING-COMMAND ×2,
PLAN-AMENDED-WITH-WORK `3fb7727`, CENSUS-START-NOT-WITH-PLAN, -MISSING) and PASSes 28 at `b9a42c0` against
MANIFEST `rounds[425].commit=kagi-shokunin@3553d49`.

## Smallest safe correction (specify for XConformance; L1 integrates)

Read-only git, always `--no-renames`; path sets from `diff-tree -r --name-status P^1 P` (never `git show
--name-only`); adds found with `log -m`. P = the plan's first add. Typed FAIL names in parentheses.
- **Plan add:** exactly one add of `plans/round-N.md`, no delete (PLAN-READDED); P has one parent
  (PLAN-FIRST-MERGE); P's exact path set is `{A plan, A census-start}` (PLAN-FIRST-IMPURE).
- **BASE:** `P^ ==` the plan's `Frozen BASE:` hash (PLAN-NOT-ON-BASE) `==` the MANIFEST commit of the lane's
  admitted round N−1 (BASE-NOT-ADMITTED); the BASE tree has no round-N paths.
- **Structure and append-only:** each frozen `## C<k>` has an indented counting command (PLAN-NO-CLAIMS,
  CLAIM-NO-COUNTING-COMMAND). Every later plan blob, *and* the worktree file, starts byte-for-byte with P's plan
  (FROZEN-REWRITTEN, PLAN-WORKTREE-DIRTY): whole-prefix identity, not just command lines.
- **Corrections before work:** a later plan-touching commit touches only the plan, and no non-plan commit
  precedes it (PLAN-AMENDED-WITH-WORK / -AFTER-WORK). Every commit in `P..tip` is on `--ancestry-path`
  (WORK-OFF-PLAN). Measurement tools named in frozen commands have ≤1 touching commit (TOOL-REWRITTEN).
- **Census-start:** touched only by P (NOT-WITH-PLAN / REWRITTEN); first line an ISO timestamp within
  [BASE, P] committer dates; last line `exit=0` (`exit=2` only if BASE lacks `corpus/SOURCES.md`); contains the
  `<lane>\tok\t…corpus/SOURCES.md` line and only `<lane>\t` lines. From round 29 the writer must also emit
  `source_registry_sha256=` equal to the SHA-256 of `BASE:corpus/SOURCES.md` (UNBOUND / NOT-BASE-REGISTRY).
- **Able-to-fail per typed check, not per round:** each type needs its own failing fixture (finding 1).

Tradeoffs for the judge, not fixable defects: (a) the corrections-before-work rule is stricter than
`plans/round-28.md:88`. Once any tool or patch commit lands, every further round-28 plan correction FAILs, so
post-work clarifications must go to the lesson; without the rule, round 27's widening is mechanically invisible.
(b) Timestamps are author-controlled; ancestry and the MANIFEST binding are the strong parts. CE17 stays
undetectable until the registry hash is recorded, and still passes when `SOURCES.md` was untouched (harmless:
then the census equals a true start census).

## Commands (cwd = sandbox; all read-only on the lane)

- `git -C <lane> log/show/diff-tree/rev-list …`: all exit 0; `git show 3553d49:plans/round-28.md`: exit 128.
- `spec_check.py <lane> N` / `hard_check.py <lane> N kagi HEAD <fleet>/MANIFEST.json` (`python3 -I -B`) for
  N=24..28: exit 1,1,1,1,0 for both (hardened re-run for 27/28 after the final edit: 1, 0).
- `build_cases.py plan0.md census0.txt`: exit 1 first (CE09 merge ordering), then exit 0 (22 repos);
  `bash run_cases.sh`: exit 0. sha256 hard_check.py `82edd4a6…7387a6`, spec_check.py `19d5d1ae…dd3e16`.

## Not checked

- XConformance's actual code (none existed); `spec_check.py` is one reading (with `log -m` it would PASS CE09).
- Rounds before 24 (round 22/23 plan-first commits listed, not run). Fleet `scripts/sources-census.sh` was not
  executed; MANIFEST was read, not validated. Whether round-28 tools get committed before the patch is unenforced
  except via TOOL-REWRITTEN after their first commit.
- No tool installs or updates; no lane gates or selftests run; no writes outside this report and my sandbox.
