# K42ReviewC2 — pre-freeze attacks on claim C2 (round 42, attempt 1)

Scope: plans/round-42.md §C2 + amendment A1. Claim BASE e8265c0; predeclaration 98dd4de; A1 fdbb83d; frozen counter source 5142b52; pinned BASE 19025d9. All runs in scratch `/fast/scratch/hyaku/kagi-r42/K42ReviewC2` (deleted after this report); lane untouched (status verified, attack 4). No commits made anywhere; attack probes use tree copies, not candidate commits (harness substitutes `cp -a` of a prepared tree for the counter's clone step; every other line of `plans/round-42-c2.sh` unchanged).

## Attack 1 — the C2 defect at e8265c0 (receipt not re-derivable from the revision it names)

**Claim:** the committed receipt `.ufo/waves/round-41/controls/c2-base-19025d9.txt` reads 1, but the same runner run in a clean clone at the same commit reads 3.

**Command and output:**
- `git -C <lane> show e8265c0:.ufo/waves/round-41/controls/c2-base-19025d9.txt` → `1` (rc 0; last line `1`).
- Clone `--shared` at e8265c0 (`rev-parse --show-toplevel` = the clone), then `bash plans/round-41-controls.sh` → rc 0, 0s; last lines: `C2 BASE N=3`; controls nominal: `c1-blanket-refuse N=0`, `c1-blanket-accept N=0`, `c1-no-gate N=0`, `c2-decoy-superseded N=2`.
- Run receipt last line (`.ufo/waves/round-41/controls/c2-base-19025d9.txt`): `3`.

**Verdict: DEFECT** — committed 1 vs re-run 3 at the identical commit; the receipt is a function of ambient worktree state, not of the revision it names. Exactly the §C2 improvement statement. (Root cause visible in `plans/round-41-controls.sh`: `bash plans/round-41-c2.sh` with cwd = repo root, counter reads `corpus/*` and `.ufo/waves/*/capture/S095.body` from the worktree.)

## Attack 2 — can a candidate reach N=1 without fixing the runner?

Harness: `plans/round-42-c2.sh` copy with ONLY the clone/checkout step replaced by `cp -a "$FAKECAND" "$SCR/clone"`; D derivation, runner execution, `R=$(tail -1 receipt)`, `N = (D==1 && R==D)` unchanged. D measured 1 in every probe. Negative control first.

**(a) runner writes the constant 1:**
- Runner: `printf '1\n' > .ufo/waves/round-41/controls/c2-base-19025d9.txt`.
- Negative control (unmodified 98dd4de tree): `N=[0]` (old runner writes 3 ≠ D=1). Harness sound.
- Probe: `probe-a: N=[1]`. Counter returns 1.
- Plan names it: yes, explicitly — §C2 "Declared ceilings: ... a runner that writes the constant `1` passes ... the counter's own derivation is the control against it, and the candidate's runner is reviewed as code"; same sentence in the counter header ("Ceiling").
- **Verdict: NOT-DEFECT** (declared ceiling). Residual: the counter cannot by itself verify the fix; admission rests on runner code review per the plan.

**(b) runner copies the receipt via `git show 19025d9`:**
- Premise verified: `git ls-tree 19025d9 -- .ufo/waves/round-41/controls/c2-base-19025d9.txt` → empty (rc 0); the whole `.ufo/waves/round-41/controls/` dir is absent from 19025d9; in a clone, `git show 19025d9:<receipt>` → `fatal: path ... exists on disk, but not in '19025d9'`, rc 128. The receipt first enters the tree at 5142b52 (`git log --diff-filter=A`).
- Probe: `probe-b1: N=[0]` — runner's `git show` fails, receipt never written, R empty, counter prints 0.
- **Verdict: NOT-DEFECT** (attack fails closed, exactly as the assignment predicted).
- Adjacent variant measured for calibration (b2): `git show e8265c0:<receipt>` (committed `1`) → `probe-b2: N=[1]`. **NOT-DEFECT but inside the named ceiling** — indistinguishable from (a) to the counter (value-only check); worth one line in the lesson so review knows to look for receipt-copying, not just constant-writing.

**(c) runner runs the counter in the worktree, then rewrites the line to 1 by arithmetic:**
- Runner: executes the committed (unfixed) `plans/round-41-controls.orig.sh` (worktree reading 3 in the clean tree), then `echo $((x - 2)) > receipt`.
- Probe: `probe-c: N=[1]`. Counter returns 1.
- Plan names it: yes — same ceiling sentence (counter checks the receipt VALUE against D, "not the runner's source"). Note: kill rule (b) ("runner still reads the worktree for the BASE line") is therefore review-enforced only; the counter cannot detect it.
- **Verdict: NOT-DEFECT** (declared ceiling), with the review-dependence named.

## Attack 3 — the derivation D at 19025d9 (A1's frozen counter over the pinned archive)

**Claim:** D is derivable from `git archive 19025d9` alone (its own normalizer, registry, fetch rows) with the 5142b52-frozen counter, and reads 1.

**Command and output:** `git -C <lane> archive 19025d9 | tar -x -f - -C $E`; files present: `corpus/rendered-text-v1.py` (192 lines), `corpus/SOURCES.md` (256 lines), `corpus/source-fetches.tsv` (139 lines). `git show 5142b52:plans/round-41-c2.sh > $E/plans/round-41-c2.sh`; `(cd "$E" && bash plans/round-41-c2.sh)` → rc 0, stdout `[1]`, empty stderr. `$E/.git` does not exist (pure archive; the counter needs no git — it reads the corpus files and the capture body committed in the tree, and `--selftest` runs the archived normalizer).

**Verdict: NOT-DEFECT** — D = 1, reproducible from the pinned tree alone, no lane files, matches `.ufo/waves/round-42/controls/c2-derivation-D.txt` (1).

## Attack 4 — the counter's clone step never writes into the lane

**Command and output:** snapshot `git -C <lane> status --porcelain` (6 lines, all `??` untracked `.ufo/waves/round-42/build*` wave-state of the L1), then from a scratch cwd run `bash <lane>/plans/round-42-c2.sh` (REPO = the lane, candidate default HEAD fdbb83d): stdout `[0]`, rc 0, 1s. Post-run `status --porcelain` byte-identical (before == after). A second full diff against the first snapshot of the session: `lane-status-UNCHANGED-since-first-snapshot`. Counter-scratch variant: running a copy of the scripts from a non-repo dir refuses (`counter-refused: candidate`, rc 2) — fail-closed, nothing written.

**Verdict: NOT-DEFECT** — `git clone --shared` + `checkout --detach` of the candidate only read the lane; the inner runner executes in the counter's scratch clone and writes receipts there.

## Attack 5 — axis fit: is "the runner derives its receipt from the pinned revision" freshness, or only a fix?

**Verdict: freshness move, not merely a fix — with the detection living in the counter, and bounded by the value-only ceiling.**

Reasons:
1. The round-41 defect is not "wrong number"; it is that the receipt was a function of ambient worktree state, i.e., structurally stale-prone — the exact freshness failure the axis names ("the receipt is not re-derivable from the revision it names"). Making the receipt a deterministic function of the immutable pinned revision is the freshness property itself, and the §C2 predicate states it as an invariant (receipt == D, D re-derived every measurement from `git archive 19025d9` with the 5142b52 counter).
2. The drift-detection mechanism is the COUNTER, not the runner: every future run re-derives D and compares, so any regression of the committed receipt away from its named revision (or of the runner back to worktree reading) flips N to 0. That is standing drift detection of a pinned artifact, the shape of a freshness claim — a one-time fix would not re-check anything.
3. Bound: the detection is value-only. Source-faking runners — constant 1 (a), receipt copied from any commit ≥ 5142b52 (b2), arithmetic rewrite after a worktree read (c) — all pass N=1 and are invisible to the counter. The plan declares this ceiling and routes the residual to code review ("the candidate's runner is reviewed as code"), and A1 already closed the sharper variant (D itself forged via a candidate-edited round-41 counter). So: freshness move, honestly scoped; the axis gains a re-checkable invariant, and the residual (receipt provenance) is review-enforced, not measured.

## Residual risks

- The counter certifies the receipt VALUE only; provenance of the candidate's receipt is unmeasured by construction (declared ceiling). Review of the candidate runner is load-bearing for kill rule (b).
- Receipt-copying from any commit containing the receipt (5142b52 and later) is a distinct pattern from constant-writing; name it in the review checklist for the C2 runner.
- `find .ufo/waves -path '*/capture/S095.body'` in the frozen counter means D depends on capture bodies committed in the 19025d9 tree — verified present and matching today; immutable input, so no drift possible.

All probes ran in `/fast/scratch/hyaku/kagi-r42/K42ReviewC2` (removed after writing this file). Lane writes: none (deliverables only, this file set).
