# CritConformance — falsify `round-conformance.py` at candidate 62a33b1

Seat `KagiR28.CritConformance` (critic, advice only). Target is the committed tool
`62a33b1:.ufo/waves/round-28/tools/round-conformance.py`, sha256 `2c97be60…b1992b`, run from a
scratch clone checked out at `62a33b1bd15217ed729df2ca40c8a30aba3076c0`. Lane checkout not executed.

## Verdict

- **Bounded contract: PASS.** The known negative round 27, the synthetic changed-command case and the
  synthetic census-after-plan case all exit 1 at the candidate; round 28 exits 0.
- **QM29 as worded: FAIL.** `corpus/QUALITY.md:136` covers "frozen text … never change" and
  lists "a frozen scope widened by an appended correction after measurement" as a counterexample.
  The check that M28-1 names (`corpus/lessons/round-28.md:87`) passes that shape, including
  on round 27's real history. The lesson's limit ("vacuous on prose commands") understates the gap:
  prose widening also passes when C3 is non-vacuous (`lines=2`, S3 below).

## Findings (exact candidate path:line)

1. **C3 never sees semantic widening.** `round-conformance.py:83-93` compares only fenced lines
   and lines indented by 4 or more spaces. `:73-80` drops everything from the first `## Plan corrections`.
   `:200` compares only the first commit with HEAD. As a result, edits to the frozen fixtures or
   predicates (`plans/round-28.md:31-44,61-68`), an appended widening, and a change-then-restore all
   read `C3 OK`. On round 27 itself C3 is `OK lines=0 (vacuous)`, even though its C2 widening was
   appended in `3fb7727`, a commit that touches 65 paths including round-27 build reports
   (`plans/round-27.md:48-55`). So the FAIL on round 27 rests on C1 and C2 only.
2. **QM29 overclaims the check.** `corpus/QUALITY.md:136` ("frozen text and counting commands never
   change"; "correction appended only before the first work commit") has no implementing line. The
   tool has no whole-frozen-text comparison and no correction-timing rule.
3. **The frozen tool body is outside the check.** `plans/round-28.md:27` says "then never changed".
   C3 freezes only the command line, so rewriting `tools/c1-measure.py` passes (S6). All four
   tools first land in the candidate commit `62a33b1`, so git history holds no earlier tool state
   for any check to compare against.
4. **"Before any work" is enforced only for the plan's own first commit.** `:147-148` filters the
   paths of that commit, but `:179-185` does not check the scope of the census commit. Code can land in
   the census commit before the plan and still PASS (S7). A stub plan that holds only the command lines,
   followed by the full plan plus code, also PASSes (S8). The census content is never checked (S9).
5. **(new) History simplification hides a plan-with-code commit.** `:131` runs
   `git log -- <plan>` without `--full-history`. A side-branch commit that adds the plan together with
   `corpus/release-clock.py` code, merged next to an identical plan-only mainline commit, is
   dropped from the log. It is reachable from HEAD (`merge-base --is-ancestor` rc=0), and
   `--full-history` lists it, yet the tool reports `C1 OK … VERDICT PASS` (S10).
6. **No regression on round 28.** The frozen prefix (everything before `## Plan corrections`) has the
   same sha256, `56e49d6b…afe14`, at `bdf90f5`, `b9a42c0`, `2dfb534` and `62a33b1`. Both correction
   commits touch only `plans/round-28.md` and precede `62a33b1`, so round 28 meets QM29 by inspection. The
   gap is in the checker, not in round 28's history. M28-1 cites round 28 PASS at lane tip `b9a42c0`
   (XConformance); I reproduced PASS at the candidate.

## Commands (all in scratch clone `/fast/scratch/hyaku/kagi-r28/KagiR28.CritConformance/lane`)

| case | command / construction | result | exit |
|---|---|---|---|
| R28 | `python3 -I -B rc.py lane 28` @62a33b1 | C1 OK touched=2, C2 OK same-commit, C3 OK lines=2, PASS | 0 |
| R27 | `python3 -I -B rc.py lane 27` @62a33b1 | C1 FAIL-SCOPE outside=1873, C2 FAIL-MISSING, C3 OK vacuous, FAIL | 1 |
| S1 | `plans/round-28.md:29` + ` --lenient`, committed | C3 FAIL-CHANGED index=0 | 1 |
| S2 | round-99 plan commit, then census commit | C2 FAIL-ORDER census-committed-after-plan | 1 |
| S3 | frozen prose `:33` 4301→9999, `:38` predicate, `:52` "located"→"any" | PASS lines=2 | 0 |
| S4 | `## Plan corrections` inserted at `:60` (after last command) | PASS | 0 |
| S5 | `:29` changed in one commit, restored in the next | PASS | 0 |
| S6 | `tools/c1-measure.py` body edited, plan untouched | PASS | 0 |
| S7 | census + `corpus/release-clock.py` edit, then plan-only commit | PASS | 0 |
| S8 | plan = command lines only + census; then full plan + code | PASS | 0 |
| S9 | census-start rewritten after the plan | PASS | 0 |
| S10 | side branch plan+code merged beside an identical plan-only commit | PASS (side commit hidden) | 0 |

The harness is `.ufo/waves/round-28/sandboxes/KagiR28.CritConformance/synth.sh`; its full output is `synth.out`
in the same directory. Python 3.14 (system).

## Smallest safe correction (frozen commands, fixtures and predicates untouched)

- **Wording (required):** narrow QM29 (`QUALITY.md:136`) and M28-1 (`lessons/round-28.md:87`) to what
  the tool checks. That means C1 is the path scope of the plan's first commit, C2 is census first-commit
  ancestry, and C3 is endpoint equality of fenced and indented lines. State plainly that it does not detect
  semantic widening, appended or prose widening, tool-body edits, code before the plan, or census content.
- **Optional hardening:** these keep round 28 PASS and round 27 FAIL by the inspection in finding 6.
  - C3' compares the whole frozen prefix bytes at every plan-touching commit, not just the endpoints.
  - C4 makes every later plan-touching commit touch only `plans/`, and requires no non-plan commit since BASE
    before it. Round 27's `3fb7727` would fail this.
  - C1 and C2 log with `--full-history` and reject any plan-touching or census commit with non-plan paths.
  - None of this fixes the forgeable census (CritConformanceFix finding 3).

## Not checked

- `c1-measure.py` / `c2-measure.py` behaviour; release-clock C1/C2 semantics; rounds 22–26 history.
- Rename-into-`plans/`, empty-census and delete/re-add cases (CritConformanceFix CE07, CE05, CE14), not re-run here.
- Commit-date skew ordering in `git log` with merges (inference only: the default order is date-based).
- I couldn't find the godspeed skill file on this host, so I didn't read it. No tools were installed.
