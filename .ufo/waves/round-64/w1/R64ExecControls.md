# R64ExecControls — round-64 pre-freeze control battery

Seat: R64ExecControls (executor). Judged on: operability.
Claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`; frozen plan
`plans/round-64.md` (commit `dff0929`, incl. Amendment A1).
`SEAT-STATUS: complete`

## Files

| file | state | sha256 |
|---|---|---|
| `plans/round-64-controls.sh` | **new**, 770 lines, executable | `e37d497dc6bf56e02b26d8fec8ed24cf66d252968287302b74267ef158d8a678` |
| `plans/round-63-controls.sh` | **not touched by this seat**; working-tree bytes carry the C2 seat's `R63_CONTROLS_FIXTURE_ONLY` branch (BASE sha `cb8134ad…`, current `f0aa2307…`) | — |
| `.ufo/waves/round-64/build/R64ExecControls/` | receipts | `controls.md`, `base-run.out/.txt`, `fixture-accept.*`, `fixture-run.*`, `stub-run.*`, `c1-repro.*`, `counters.sha256` |

Full receipt with every command and output:
`.ufo/waves/round-64/build/R64ExecControls/controls.md`.

## Behaviour landed

`bash plans/round-64-controls.sh [TREE]` / `--selftest`; per-control lines
`CONTROL <id> expect=… observed=… verdict=match|mismatch|skip`; last summary
`CONTROLS: match=N mismatch=M`; exit 0 iff mismatch=0, 1 on mismatch, 2 SETUP.

Controls (all frozen expectations are literals derived from plan §C1/§C2, never
from the measured tree):

- `C1-F9` — printer-stub copy of `plans/round-64-c1.sh` (byte copy + dispatch
  after the shebang printing the constant candidate-success
  `C1_HELDOUT: heldout=0 population=8 guard=1 …`, exit 0) measured against the
  BASE literal `heldout=8` → `mismatch` (the stub is refused).
- `C2-F7` — constant-verdict copy of `plans/round-64-c2.sh` (constant
  `C2_REFUSAL: killed=5 population=5 guard=1 … terminates=1 bound=1`) measured
  against the BASE literal `terminates=0` → `mismatch`.
- `C2-BOUND` — **the recursion-bound refutation leg**: the real counter under
  `C2_RECURSION_BOUND=0 timeout 240`. No verdict line ⇒ `match` (the bound is
  load-bearing); any `C2_REFUSAL:` line under bound=0 ⇒ `mismatch` (the bound
  is decorative). This is what makes the bound non-decorative.
- `C1-NOWORK` / `C2-NOWORK` — the unmutated counters (each run once, parsed into
  `U1_*`/`U2_*`, shared with the REAL controls): `heldout=8 population=8`, and
  `terminates=0` **either** as a line (`killed=0 population=5 terminates=0`)
  **or** as the frozen BASE non-termination (`rc=124`, no line — §C2 census,
  7-byte receipt).
- `C1-REAL` / `C2-REAL` — unmutated counters must print a verdict line with
  `guard=1`.
- `PRIOR-<id>` — the round-63 battery's own controls re-run on a private
  snapshot and re-emitted with verdicts preserved. Delegation mode is read from
  the prior battery's bytes: `R63_CONTROLS_FIXTURE_ONLY=1`
  `<battery> <snap>` when the C2 seat's branch is present (no counter
  re-entered), otherwise `--selftest` only (the pre-landing full battery hangs
  on the round-63 recursion defect) with a `PRIOR-SELFTEST` row when no CONTROL
  rows come back.

Instrument resolution is the round-63 pre-freeze semantics: the measured tree's
own counter when present, else the lane's (`R64_CONTROLS_REPO` overrides the
lane root; needed only when the script is run as a copy outside
`<lane>/plans`). No lane instrument is required by `--selftest`, and no `bao`
is invoked anywhere.

## Evidence (measured)

1. `bash -n plans/round-64-controls.sh` rc 0.
2. `bash plans/round-64-controls.sh --selftest` ⇒
   `CONTROLS_SELFTEST: PASS (cases=36)` rc 0. Six end-to-end fixture trees
   under scratch (BASE-census, candidate-target, empty, hang-under-bound,
   sleeping-under-bound, decorative-bound), each asserted for its expected
   verdicts; a failing case prints `FINDING R64C-CTL-ST-<case>` and exits 1.
3. Acceptance pattern in one tree (`fixaccept`: BASE-census fixture counters,
   C2 terminates under bound=0): `C1-F9`, `C2-F7`, `C2-BOUND` all
   `verdict=mismatch`; `C1-NOWORK`, `C2-NOWORK` both `match`;
   `CONTROLS: match=5 mismatch=3`, rc 1.
4. Printer-stub tree (`fixstub`): `C1-F9`/`C2-F7`/`C2-BOUND` mismatch, both
   NOWORK mismatch, both REAL match, `match=3 mismatch=5`.
5. BASE tree (slim extraction of `09cbee8`: `plans`, `LOG.md`, `SKILL.md`,
   `corpus/lessons/round-60.md`, `.ufo/waves/round-60/w1-results.json`), lane
   counters sha `e03a4d69…` (C1) and `e2d8171f…` (C2), 1992 s:
   C1-F9 mismatch, C2-F7 mismatch, **C2-BOUND match** (`no-verdict-line;rc=124`
   at 240 s), **C1-NOWORK match** (`heldout=8 population=8`), **C2-NOWORK
   match** (`no-verdict-line;rc=124`), C1-REAL mismatch (`guard=0`), C2-REAL
   mismatch (no line), PRIOR-SELFTEST match ⇒ `CONTROLS: match=4 mismatch=4`
   rc 1. The four mismatches are the expected BASE-side readings (two stub
   refusals + two positive controls that a pre-candidate counter cannot
   honestly pass at BASE).

## Coordination

`plans/round-63-controls.sh` carries the `R63_CONTROLS_FIXTURE_ONLY` branch
landed by seat `R64ExecC2Counter` (its prompt item 1). That seat confirmed by
message 2026-11-08 that it owns the branch; this seat did not write the file.
The battery detects the branch from the prior battery's bytes, so it works with
or without the landing.

## Risks and observations

- **Instrument flakiness observed, not hidden:** one BASE run at 06:33 UTC read
  `C1-NOWORK … rc=2` (SETUP, no verdict line) while the C1 seat was still
  writing `plans/round-64-c1.sh`; the same bytes measured directly immediately
  after read `C1_HELDOUT: heldout=8 population=8 guard=0 …` rc 1 (626 s), and
  the next battery run read `heldout=8`. The battery reported the SETUP as a
  `mismatch` with the rc and absent line; no row was softened. The L1 should
  expect transient SETUP while sibling seats rewrite the counters.
- `C2-BOUND` costs one 240 s timeout per real run; the C2 probe costs up to
  1300 s when the counter cannot terminate (the BASE reading). Measured BASE
  battery wall time: 1992 s.
- `ctrl_prior` copies the measured tree (`cp -a`) and runs the prior battery on
  the snapshot; bounded by `timeout 600`.
- The prior delegation mode is chosen by grepping the prior battery's bytes for
  the branch name — a mode switch, not a safety gate.
- The battery never reads `plans/round-64-heldout.tsv`; it inherits the seal
  discipline from the C1 counter it measures. This seat did not read it.

## Named ceilings (plan's, unchanged)

- A stub printing exactly the independently expected BASE line is
  indistinguishable by output alone; the control refuses a stub whose constant
  line names the target reading.
- `C2-BOUND` proves the bound changes termination behaviour, not that the five
  legs fire for the right reasons.
