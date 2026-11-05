# K42ReviewC2 — report (round 42, C2 pre-freeze attacks)

Attacks on §C2 executed before any candidate exists; full evidence in `.ufo/waves/round-42/build/K42ReviewC2/attacks.md`.

## Verdict list

1. **DEFECT confirmed at e8265c0** — committed C2 BASE receipt reads `1`; the same runner in a clean clone at e8265c0 writes `3` (round-41 controls runner rc 0, all other controls nominal). Receipt not re-derivable from the revision it names; §C2 improvement statement verified.
2. **Constant-1 runner → counter N=1** — passes, explicitly a declared ceiling of the plan and counter header; counter's derivation D=1 is the control, runner reviewed as code. NOT-DEFECT.
3. **`git show 19025d9` receipt copy → N=0** — path absent from the 19025d9 tree (ls-tree empty; `git show` fatal rc 128; receipt first committed at 5142b52); fails closed. NOT-DEFECT. Adjacent variant `git show e8265c0` → N=1: inside the same named ceiling; add "receipt copied from a later commit" to the runner review checklist.
4. **Worktree-run + arithmetic rewrite to 1 → N=1** — passes under the same named ceiling; kill rule (b) (runner still reads the worktree) is enforceable only by review, not by the counter. NOT-DEFECT.
5. **Derivation D verified** — `git archive 19025d9` contains `corpus/rendered-text-v1.py` (192 ln), `corpus/SOURCES.md` (256 ln), `corpus/source-fetches.tsv` (139 ln); the 5142b52-frozen counter run in the extraction (cwd = extraction, no `.git`, no lane files) prints `1`, rc 0. Matches `c2-derivation-D.txt`. NOT-DEFECT.
6. **Clone-step lane safety verified** — dry run of `plans/round-42-c2.sh` with REPO = lane (HEAD fdbb83d): stdout `0`, rc 0; `git status --porcelain` byte-identical before/after (6 untracked L1 wave-state lines, unchanged across the session). Scripts copied outside a repo refuse rc 2. NOT-DEFECT.

## Axis-fit verdict (item 5)

"Runner derives its receipt from the pinned revision" is a **freshness move**, not only a fix: the predicate freezes a standing drift check (D re-derived from `git archive 19025d9` with the 5142b52 counter on every measurement; receipt must equal it), so any future drift between a committed receipt and the revision it names — the round-41 failure mode — flips N to 0. The runner-side derivation is the enabling fix; the detection lives in the frozen counter. Bound: detection is value-only, so receipt provenance (constant/copy/rewrite) remains review-enforced per the declared ceiling; A1 already closed the D-forgery variant.

## Residuals for the lesson/review

- Value-only ceiling: counter cannot distinguish fix from forgery; review is load-bearing for kill rule (b).
- Receipt-copying (`git show` of any commit ≥ 5142b52) is a distinct cheat pattern from constant-writing; both pass N=1.
- D depends on capture bodies committed in the 19025d9 tree — present and matching today; immutable input, no drift possible.

## Honesty

Every check above was run; commands, exit codes and last output lines are in attacks.md. Nothing in this report reinterprets the frozen plan; no lane files were edited, no commits created anywhere (attack probes used scratch tree copies via a single-substitution harness).
