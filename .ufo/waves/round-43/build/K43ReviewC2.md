# K43ReviewC2 — scoped findings (round 43, §C2 freshness attacks)

Scope: attacks on claim C2's BASE premise, exclusions, named ceilings, restore duty, and predicate wording,
executed before any candidate measurement, in a sandbox clone at dd6ccb92bf04a061e9f1e66913d15f097397b1b3
(= lane master tip). No lane edits. Full evidence: `build/K43ReviewC2/attacks.md`, gates + counter receipt in
`build/K43ReviewC2/receipts/`.

## Verdicts per assigned item

1. **BASE premise — HOLDS.** Plain re-run and full-delete re-run of `plans/round-42-controls.sh` +
   `plans/round-41-controls.sh` (rc 0 / rc 0 both times) re-derive the 8 manifest receipts **byte-identically**
   (8/8 `cmp` MATCH in both modes; snapshots from `git show dd6ccb92:<path>`). Zero deviations recorded.
2. **Exclusions — REAL.** `c1-base.txt` committed 4 → re-derives 5; `c2-base.txt` committed 0 → re-derives 1;
   `c2-worktree-at-base.txt` is written by no committed runner (absent after full delete). Including either
   excluded receipt would make P1 impossible; the 8-file manifest is the maximal honest set.
3. **Shape-keying ceiling — CONFIRMED.** A scratch gate that replays nothing (probes r42-runner bytes vs
   `HEAD`, and D==1) made `CONTROLS_REPLAY_GATE=<it> bash plans/round-43-c2.sh` print **1**, rc 0. Blanket-0 and
   blanket-1 override gates both read **0** (counter refuses blankets, accepts shape-keying) — the ceiling is
   exactly as named in §C2; the candidate gate's default verification stays reviewed-as-code.
4. **Restore duty — DEFECT FOUND (fresh; survives frozen checks).** A gate following the plan's step order
   (byte-compare, then restore) restores correctly on the clean clone (rc 0, porcelain empty) but leaves a
   REFUSED fixture dirty: stale fixture → ` M c1-base.txt`, ` M c2-base.txt`, ` D c2-worktree-at-base.txt`;
   silent fixture → six ` D` receipts. Kill rule (c) pins only the clean-clone direct run, so no frozen check
   breaks — but the executor's `corpus/controls-replay.sh` must restore on ALL exit paths (EXIT trap or restore
   before every `exit 1`) for kill rule (c)'s duty to be honestly met on refusing runs.
5. **Predicate wording.** (a) All 20 round-43 receipt names in the plan/header carry `.txt`, but the committed
   predeclaration files are extensionless (`c2-base`, …; only `measured-at.txt` has one) — cosmetic traceability
   break, values match the frozen table. (b) §C2 prose "re-derive at the BASE HEAD" is ambiguous (BASE 5f3566c vs
   dd6ccb92); the header's "revision they live at" is operative — the report should name dd6ccb92. (c) rc
   exactness (0/1/1) is enforced literally and fails closed; consistent. (d) "default HEAD" is repo-relative;
   the L1 must pin the candidate and the receipt should record it.

## Surviving defects named

- D1 (operability, pre-measurement): restore-on-refusal gap in the candidate gate's required step order — fix in
  `corpus/controls-replay.sh` implementation, not in frozen text (no frozen check violated).
- D2 (cosmetic, traceability): extensionless round-43 receipt files vs `.txt` citations in plan §Controls and the
  counter header.

## Not run (honest gaps)

Candidate measurement (no `corpus/controls-replay.sh` exists at dd6ccb92); C1/C3 counters; full claim-ledger
verify (out of seat bounds); re-derivation at 5f3566c. Tooling: nothing installed or upgraded.
Scratch `/fast/scratch/hyaku/kagi-r43/K43ReviewC2` deleted before yield.
