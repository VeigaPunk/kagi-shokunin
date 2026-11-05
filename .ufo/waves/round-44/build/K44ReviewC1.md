# K44ReviewC1 — review of the round-44 C1 counter battery (calibration)

Reviewed object: `plans/round-44-c1.sh` (battery), `plans/round-43-c2.sh` (counter under
test), `corpus/controls-replay.sh` (gate), `plans/round-44-controls.sh` (runner), the
committed BASE receipts/fixtures under `.ufo/waves/round-44/controls/`, against the frozen
plan `plans/round-44.md` §C1 and the K43 survivor evidence
`.ufo/waves/round-43/build/K43MutCounters/mutants.md` — all at the predeclaration
**ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae**. All work in sandbox
`/fast/scratch/hyaku/kagi-r44/K44ReviewC1` (deleted at seat end); no lane-tree edits; no
subagents; fixture commits only inside disposable scratch clones with the seat-attributed
identity `K44ReviewC1 (fixture) <k44reviewc1@fixture.invalid>` (the assignment's
smoke-matrix reproduction step sanctions fixture commits; nothing pushed).

## Verdict

The battery is calibrated and fail-closed at ae9e9eb. All five frozen checks reproduce.
No predicate-threatening defect found. One LOW operational finding (F1) creates an L1
environment duty before the final measurement; three INFO findings. Every "at candidate"
value below is a **measurement on the ae9e9eb tree / ae9e9eb-based fixtures**, not a
prediction (the candidate does not exist yet); the only predictions are explicitly marked.

## Frozen checks — results

1. **Recipe fidelity: PASS.** The battery's embedded python (extracted verbatim, 779
   bytes) run on a byte-copy of `ae9e9eb:plans/round-43-c2.sh` produces mutants
   **byte-identical (sha256-equal) to independently hand-built equivalents** built from
   the frozen plan text with a line-anchored cut (`# N1: stale fixture`…`N1=$?`
   inclusive, then the final-condition replacement; same for N2). Post-conditions hold:
   `"$N1"` absent in mut-y1, `"$N2"` absent in mut-y2, the opposite block retained in
   each, `bash -n` clean, final conditions exactly `[ "$P1" = "0" ] && [ "$N2" = "1" ]`
   (y1) / `[ "$P1" = "0" ] && [ "$N1" = "1" ]` (y2). Marker census in the counter:
   finalcond OLD ×1, N1 marker ×1, N2 marker ×1, `N1=$?` ×1, `N2=$?` ×1 (the battery's
   asserts are sound and cannot double-fire). Counter bytes are identical
   dd6ccb92→ae9e9eb (`git diff` rc 0), so the recipes cut exactly the blocks K43
   hand-mutated. Receipts: `receipts/recipe-fidelity.txt`; artifacts under `artifacts/`.
2. **Interface fidelity: PASS** (one LOW finding, F1). The fixture gates are battery
   heredocs written to battery scratch (`$SCR/g-*`), **outside every clone**; the
   counter's default gate resolves inside its own nested clone
   (`<clone>/corpus/controls-replay.sh`) — the paths cannot collide, verified by direct
   gate probes (g-as refuses only the silent shape, g-asi only the stale shape,
   g-always always rc 1) and by the 12-cell counter×gate matrix run with `run_counter`'s
   exact invocation shape (explicit CAND; inline `CONTROLS_REPLAY_GATE` on override
   legs): real 1/0/0/0, y1 1/**1**/0/0, y2 1/0/**1**/0 (default/g-as/g-asi/g-always) —
   matching the K43 probes exactly. Fail-closed legs measured: stale self-copy → rc 2,
   empty stdout, stderr `battery-refused: self mismatch`; `R44_ONLY_FIXTURE=bogus` →
   rc 2; unknown candidate → rc 2; existence leg at d54109d → prints 0, rc 0
   (per predicate: a candidate without the battery file reads 0). `run_counter`'s INVALID
   path (non-zero rc, empty or multi-line or non-numeric stdout) can only drop N, never
   inflate it. The runner's `cap()` propagates `R44_SKIP_FIXTURES=1` into the battery
   (load-bearing for the final c1-skipfix receipt) — verified through the exact
   invocation shape.
3. **Blanket coverage: measured, kill points pinned per mutant class** (fixture commits
   ff74395d/a7084500/b41fa2bf/efa8ecb5/b572b419/5712f880, receipts
   `receipts/coverage-probes.txt`):
   - echo-constant 2 with no recipe markers → **rc 2** — kill rule (f), recipe assert.
   - output-constant 2 (markers kept) → **0** — P0: the real copy reads 2 under the
     candidate's own gate.
   - y3 shape (P1 test → `true`) → **rc 2** — the substitution destroys the frozen
     final-condition marker, so the recipe refuses the candidate (kill rule (f)).
   - N1 leg crippled (`true`), markers kept → **0** (P0); N1 leg run only when a gate
     override is present → **0** (P0 — there is no override-free invocation of the real
     copy except P0 itself).
   - **behavior-equivalent-on-probed-shapes mutant (dead extra check) → reads 2 — NOT
     killed.** This is exactly the plan's declared ceiling ("the battery proves
     discrimination of the two frozen recipes only"), now measured. Structural analysis
     (not separately committed): the paired-gate coupling also kills wrong-file fixture
     mutants — Y2_ASI=1 requires the retained N1 block to refuse under accept-silent, so
     any counter whose stale fixture keys on the wrong manifest file drops to N≤1.
   - Plan-prose note (F2): the ceiling sentence "an echo-constant counter at 2 is caught
     only by the no-work control at BASE" is imprecise — measured catch is at the
     candidate (rc 2 via recipe assert, or 0 via P0). Conservative direction; no
     predicate impact.
4. **Smoke matrix reproduced at ae9e9eb: 2 / 0 / 1** (plus only-silent 1):
   `c1-real` 2 (12426 ms), `R44_SKIP_FIXTURES=1` 0 (28768 ms), `R44_ONLY_FIXTURE=stale`
   1 (21543 ms), `R44_ONLY_FIXTURE=silent` 1 (18730 ms); c1-base re-measured at
   d54109d = 0. The fixture is a shared clone of the lane at ae9e9eb with the battery's
   own untracked counter copies (instruments are committed at ae9e9eb, so the smoke
   recipe's two-commit construction is not needed for the C1 trio). The committed
   smoke receipt's gate sha fab42e1d…40f equals `sha256(ae9e9eb:corpus/controls-replay.sh)`
   — the pre-freeze fixture and the predeclaration are the same instrument bytes; the
   C1 pin `git diff --quiet 65f66e17 HEAD -- corpus/controls-replay.sh
   plans/round-43-c2.sh` is rc 0. Receipt: `receipts/probe-matrix.txt`.
5. **Runtime envelope: no threat to the ~15 min budget.** Measured at ae9e9eb: battery
   real 12.4 s / skipfix 28.8 s / only-stale 21.5 s (skipfix is the slow shape — all
   legs exercise the heavy committed gate instead of the 1 ms fixture gates); one
   committed-gate run 4.0 s with clean restore duty; BASE receipts re-measured in
   4–11 ms each except the executed C3 legs (c3-pos 3.5 s, c3-wrongvals 5.4 s);
   c2-real executed-leg proxy 8.2 s (receipt naming ae9e9eb + committed gate sha reads
   1). Full `round-44-controls.sh final` suite: **79.8 s** at ae9e9eb (c2-real/c3-real
   short-circuit to 0 there); with the executed legs added at a real landing the
   projected total is ~93 s ≈ 1.6 min, ~9× headroom. Receipt:
   `receipts/base-remeasure-envelope.txt`.

BASE evidence re-measured (kill-rule (c) shape): all eight committed receipts reproduce
at the BASE — c1-base 0, c1-skipfix 0, c2-base 0, c2-forged-sha 0, c2-forged-rev 0,
c3-base 0, c3-pos 3, c3-wrongvals 1 — matching `measured-at.txt`
(2026-11-05T18:58:51Z) and `prefreeze-base.txt` (13/13 OK).

## Findings by severity

- **F1 — LOW (operational; L1 duty before finals).** The battery's P0 leg is not
  hermetic to the ambient environment: it invokes the counter copy with no inline
  `CONTROLS_REPLAY_GATE`, but does not unset the variable, so an exported
  `CONTROLS_REPLAY_GATE` in the L1's measurement shell leaks into P0 and the battery
  reads 0 on a valid candidate (measured: ambient g-as → 0, ambient g-asi → 0). The
  degradation is strictly toward 0 (any override gate that is not a properly
  discriminating gate fails P0's own legs), so it can never inflate N; the sanctioned
  runner passes no environment. The battery bytes are frozen (kill rule (d)), so the fix
  is procedural: the L1's final-measurement shell must `unset CONTROLS_REPLAY_GATE
  R44_SKIP_FIXTURES R44_ONLY_FIXTURE R44_RECEIPT R44_REGISTER_ROOT` (or use `env -i`
  equivalents) before `round-44-controls.sh final`. Recommend one line in the round
  report's operational notes.
- **F2 — INFO (plan prose).** The declared-ceiling sentence naming "an echo-constant
  counter at 2 … caught only by the no-work control at BASE" understates the battery:
  both echo-constant shapes are killed at the candidate (rc 2 by the recipe assert with
  no markers; 0 by P0 with markers kept). Conservative imprecision; the BASE-only catch
  claim is harmless because the candidate-side catch is stronger. Fold into the lesson's
  ceiling table if the L1 amends prose.
- **F3 — INFO (runner hygiene, no action in the sanctioned flow).** `final` mode writes
  receipt names that collide with tracked BASE receipt names (`c1-skipfix`); measured in
  a fixture the overwrite was byte-identical (BASE 0, final 0) so no dirt appeared, and
  the runner's header already restricts `final` mode to a clone of the candidate. If
  `final` mode were ever run in a lane worktree at a failing candidate it would dirty a
  committed file (visible in `git status`, recoverable); documented behavior, not a
  defect.
- **F4 — INFO (ceiling sharpening, named not closed).** The measured survivor class:
  counter mutants behaviorally equivalent on the three probed shapes (clean /
  counter-built stale / counter-built silent under override + default) reach N=2 (v6).
  Sub-case: a counter that treats a gate exit-2 refusal as "refused" in its comparisons
  is indistinguishable to the battery because the embedded gates never exit 2 on the
  probed shapes; against the pinned committed gate (refusal rc 1, bytes frozen) the
  behaviors coincide. Both are inside the plan's declared ceiling ("a third gate shape
  would need its own fixture").

## Prediction for the landing candidate (marked prediction)

If the landed tip keeps the pinned instrument/counter/gate bytes (kill rules (d)/(e))
and the counter does not change semantics, the final receipts should read c1-real 2,
c1-skipfix 0, c1-partial 1 (and the battery cannot exit 2 unless the candidate's counter
bytes lose a recipe marker — which would itself be a pin violation). F1 is the only
observed way a valid candidate could misread (to 0, never upward).

## Residual risk and verification gaps

- K43's actual mutant files are gone (scratch removed), so equivalence to the K43 y1/y2
  survivors is **semantic, not byte-level**: counter bytes identical dd6ccb92→ae9e9eb
  (rc 0), and every per-gate reading in mutants.md reproduced (y1: accept-stale 1,
  blankets 0; y2: accept-silent 1; pristine 0 under both paired gates).
- No candidate exists; every candidate-side number here is measured on ae9e9eb trees or
  ae9e9eb-based fixture commits. Pins verified only up to ae9e9eb — post-ae9e9eb drift
  is precisely what kill rules (d)/(e) police at landing.
- c3-real-at-landing cost is proxied by c3-pos/c3-wrongvals (same executed legs);
  c2-real-at-landing by the 8.2 s executed-leg proxy. Neither is directly measurable
  before the landing exists.
- Ambient-environment hermeticity beyond `CONTROLS_REPLAY_GATE` (e.g. `GIT_*` variables)
  was not probed; the sanctioned runner sets none.

## Receipts index (paths relative to `build/K44ReviewC1/`)

- `receipts/recipe-fidelity.txt` — check 1 transcript (verbatim), sha256 of mutants.
- `receipts/probe-matrix.txt` — checks 2+4 transcript (verbatim): gate probes, 12-cell
  matrix, smoke matrix 2/0/1/1, fail-closed legs, ambient-leak probes, cap propagation.
- `receipts/coverage-probes.txt` — check 3 transcript (verbatim): v1–v6 fixture revs and
  battery readings with kill-point interpretation.
- `receipts/base-remeasure-envelope.txt` — check 5 + BASE re-measurement transcript
  (verbatim): eight BASE receipts, c2/c3 proxies, gate run + restore duty, final-runner
  79.8 s.
- `artifacts/` — battery-produced mutants (`mut-y1`, `mut-y2`), hand-built equivalents
  (`hand-y1`, `hand-y2`), the counter byte-copy (`counter.orig`), the verbatim-extracted
  embedded recipe (`embedded.py`), the verbatim-extracted fixture gates (`g-as`,
  `g-asi`, `g-always`), `sha256sums.txt`.

Tooling record: **no tools installed or upgraded** (bash, git, python3, coreutils
sufficed); no pacman transactions, no host services touched.

SEAT-STATUS: complete
