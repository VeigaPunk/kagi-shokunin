# K42ExecRunner — round 42, C2 freshness: controls runner BASE receipt re-derived from the pinned revision

Claim BASE e8265c0 · predeclaration 98dd4de · amendment A1 fdbb83d. Sandbox worktree: clone of the lane checked out at 98dd4de (verified `git rev-parse --show-toplevel` = sandbox root and `HEAD` = 98dd4de before every write); patch applied uncommitted in the sandbox; nothing written to the lane except this deliverable directory.

## Defect

`plans/round-41-controls.sh` produced `.ufo/waves/round-41/controls/c2-base-19025d9.txt` by running `bash plans/round-41-c2.sh` in the lane worktree. At BASE the committed receipt reads 1 while the same counter in the worktree reads 3 (`.ufo/waves/round-42/controls/c2-worktree-at-base.txt`): the receipt was not re-derivable from the revision it names. Plans/round-42.md §C2 + amendment A1.

## Fix (patch.diff, +5/−1, one block)

The C2 BASE line of `plans/round-41-controls.sh` is now produced by:
1. `git archive 19025d97e5013bac2f45d6b9e61bfbafc84c3c8d | tar -x` into a scratch subdir of the runner's own `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/controls.$$` root;
2. writing the frozen counter `git show 5142b52:plans/round-41-c2.sh` (A1 source) over that extraction's `plans/round-41-c2.sh`;
3. running it with cwd = the extraction;
4. redirecting its output into `$OUT/c2-base-19025d9.txt`.

The runner never reads the lane/candidate worktree or the candidate's counter for the BASE line. Kept byte-identical: the `cd "$(dirname "$0")/.."` pattern, the scratch-root pattern, all three C1 control lines, the c2-decoy-superseded line, and the frozen `C2 BASE N=` echo label. Fail-closed: `mkdir`/`git archive`/`git show` failures exit 2, leaving a non-integer receipt the gate reads as ≠D → N=0. Hashes are full 40-char, matching `plans/round-42-c2.sh`.

## Retained evidence (all receipts in this directory)

| Receipt | Command (cwd) | Exit code | Last line |
|---|---|---|---|
| fixed-run.txt | `bash plans/round-41-controls.sh` (sandbox worktree, patch in place, worktree counter reads 3) | 0 | `1` |
| mutant-run.txt | `bash plans/round-41-controls-mutant.sh` (sabotage copy: BASE block reverted to worktree behaviour) | 0 | `3` |
| derivation.txt | extraction + `git show 5142b52:plans/round-41-c2.sh` + `bash plans/round-41-c2.sh` in extraction | 0 / 0 / 0 | `D = 1` |
| fixed-receipt-c2-base-19025d9.txt | runner receipt itself | — | `1` |

Fixed-run full stdout: `CONTROL c1-blanket-refuse N=0`, `CONTROL c1-blanket-accept N=0`, `CONTROL c1-no-gate N=0`, `CONTROL c2-decoy-superseded N=2`, `C2 BASE N=1` — C1 controls and decoy unchanged by the patch. The mutant proves the counter sees the defect: identical worktree, only the BASE line's source changed, reading flips 1 → 3.

Gate's sha256 of patched.sh: `9a910953b850ef0a32dfaa0a791991d6550ea70be25ed91490d02599b036a370` (also in patched.sh.sha256).

## Not run (owned by the L1)

- `plans/round-42-c2.sh` (the committed counter): it clones the candidate COMMIT and runs the candidate's committed runner there — runnable only after the L1 lands the patch. Expected there: N=1 (receipt 1 = D 1).
- The lane's full claim-ledger verify / self-counts (host-heavy, out of seat scope).

## Risks / named ceilings

- Constant-1 ceiling stands (plan §C2): the counter checks the receipt value against D, not the runner's source; control is D's independent derivation + code review.
- `git archive`/`git show` need the pinned objects in whatever repository the runner executes in; the gate's shared clone of the lane has them. A shallow clone without them fails closed (exit 2 → N=0), it does not silently read the worktree.
- The runner header comment still documents the round-41 decoy expectation only; the new block carries its own comment naming the pinned-revision derivation (minimal diff, per frozen "other lines unchanged").

No tools installed; no host/pacman/service changes; scratch `/fast/scratch/hyaku/kagi-r42/K42ExecRunner` removed before yield. No blockers.
