# K44ExecC3 — C3 register evidence (round-44, attempt 1)

Seat: K44ExecC3 (executor, godspeed). Predeclaration ae9e9eb. Independently
re-executed the raw material for the C3 register rows in sandbox
/fast/scratch/hyaku/kagi-r44/K44ExecC3 (removed before yield).

## Axes
Freshness (C3): register rows must reflect measured committed/re-derived
values, not memory.

## Results — all match frozen plan expectations; no disagreement
1. Committed at 5f3566c4cfe65a74da4d201d74d28b403929807b:
   c1-base.txt last line `4`, c2-base.txt `0`, c2-worktree-at-base.txt `3`
   (each 2 bytes: digit + LF; hexdump recorded). rc 0 all.
   -> matches plan matrix (4/0/3).
2. Re-derivation: fresh clone --shared at 5f3566c, snapshot 3, delete 3,
   `(cd clone && bash plans/round-42-controls.sh)` rc=0, stdout tail
   `C1 BASE N=5`, `C2 derivation D=1`, `C2 BASE N=1`. Produced
   c1-base last line `5`, c2-base `1` (expected 5 and 1).
   c2-worktree-at-base.txt NOT recreated. Restore snapshots, cmp identical
   rc 0 for all 3 (restore duty holds).
3. Sweep: `git grep 'c2-worktree-at-base' 5f3566c -- 'plans/*.sh' 'corpus/*.sh'`
   empty, rc=1 (expected). Full .sh inventory at 5f3566c: 204 files;
   38 outside .ufo/waves/** (17 corpus/, 21 plans/); sweep globs cover
   direct children of both declared dirs (36 runners + 1 fixture); the one
   nested corpus file (fixtures/cells-hermetic/corpus/fx-ok.sh) is a
   hermetic fixture, not a runner; all remaining 166 .sh are archived
   .ufo/waves/** fixtures/mutants/sandboxes.
   No missed runners within the frozen predicate's declared scope.
4. Superseding artifacts at claim BASE d54109d: both `git cat-file -e`
   rc=0 — round-43 c2-manifest-rederive-base.txt and round-41
   c2-base-19025d9.txt (content last line `1`, the re-derived value).
5. Cross-check vs round-43 disclosure: full agreement — c1 4->5,
   c2 0->1, c2-worktree absent/not-written. Zero findings of disagreement.

## Evidence files (under .ufo/waves/round-44/build/K44ExecC3/)
evidence.json (all five steps with commands/rc/last lines),
step1-committed-values.txt, step2-rederivation.txt,
snapshot-*.txt (3 committed bytes), produced-*.txt (2 re-derived),
round43-disclosure.txt, c2-base-19025d9.txt, all-sh-at-5f3566c.txt (204 lines).

Tools installed: none.

SEAT-STATUS: complete
