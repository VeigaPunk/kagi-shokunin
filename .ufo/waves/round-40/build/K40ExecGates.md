# K40ExecGates — build/attack seat report (round 40, 2026-11-05)

Assignment: re-run C3 and the two amended gates on the candidate tree
(cb3f642479a09644a03874909bb7e44b52697a8d), re-derive the M39-6 red witnesses
in scratch copies, and re-run the four C3 control modes at the predeclaration
(f687504767ce9ed56b848dfde83e03a1ec6cedd3). Leaf seat; read-only on the lane.

## Environment

- Lane /home/vgpnk/Projects/shokunin/kagi-shokunin, branch master, HEAD
  verified `cb3f642479a09644a03874909bb7e44b52697a8d` == candidate before any
  run. Working tree: 13 dirty paths, ALL under `.ufo/waves/round-40/` (wave
  dispatch/receipt artifacts) — no production file dirty, so the working-tree
  runs below read exactly the candidate bytes.
- Scratch: `/fast/scratch/hyaku/kagi-r40/K40ExecGates/` (HYAKU_SCRATCH pointed
  there for every gate/selftest/control run; deleted after receipts were
  written — see Teardown).
- plans/round-40.md read in full before execution.

## 1. C3 counter at the candidate — REPRODUCED

    bash plans/round-40-c3.sh

stdout `2`, stderr empty, exit 0. Frozen target 2 — exact match. Receipt:
`c3-counter.txt`.

## 2. Amended gate selftests at the candidate — REPRODUCED

    bash corpus/anchor-pins.sh --selftest
    → stdout `ANCHOR_PINS_SELFTEST: PASS (8 cases)`, exit 0

    bash corpus/claims-declared.sh --selftest
    → stdout `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`, exit 0

Both frozen expectations (PASS, 8 cases) — exact match.

## 3. Declared-axis gate over the lane — REPRODUCED

    cd <lane> && bash corpus/claims-declared.sh --root .
    → stdout `CLAIMS_DECLARED: CLEAN (claims=5)`, stderr empty, exit 0

Frozen expectation `CLAIMS_DECLARED: CLEAN (claims=5)` — exact match.

## 4. M39-6 red witnesses re-derived (constant-CLEAN mutants) — CAUGHT

Copied each gate to scratch, verified the target line unique
(`if [ "$bad" -gt 0 ]; then`, anchor-pins.sh:164 / claims-declared.sh:187),
replaced it with `if false; then`, ran the patched copy's own `--selftest`
(GATE_SRC = the patched copy, so all 8 cases exercise the mutant):

- patched anchor-pins: exit 1, `ANCHOR_PINS_SELFTEST: FAIL (passed=2/8)`,
  stderr: five drift-case failures (`rc=0`, gate output shows the DRIFT
  diagnosis followed by `ANCHOR_PINS: CLEAN (pins=3)` — diagnosis without
  verdict) plus `SELFTEST-FAIL constant-mutant real=0 mutant=0`.
- patched claims-declared: exit 1, `CLAIMS_DECLARED_SELFTEST: FAIL
  (passed=1/8)`, stderr: six drift-case failures plus
  `SELFTEST-FAIL constant-mutant real=0 mutant=0`.

Divergence caught by two mechanisms: (a) each selftest's case 8 explicitly
requires real=rc1 / mutant=rc0 and fails with `constant-mutant real=0
mutant=0`; (b) the verdict line collapses to `FAIL (passed=N/8)` exit 1,
which the C3 counter's parsable-verdict criterion (`*_SELFTEST: PASS
(8 cases)`, rc 0) rejects — so a constant-CLEAN gate fails both its own
selftest and C3. Unpatched controls pass 8/8 (section 2), so the failures
are attributable to the mutation alone. Receipt: `constant-mutants.md`.

## 5. Four C3 control modes at the predeclaration — REPRODUCED

Extraction: `git -C <lane> archive f687504… | tar -x -C $S` (exit 0; lane
untouched). Pre-check: 0 rows of the predec SKILL.md `## Gate registry` name
either script. Then, with `BASE=$S` and
`HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r40/K40ExecGates`:

| MODE                 | observed | frozen | verdict    |
|----------------------|----------|--------|------------|
| c3_nowork            | 0        | 0      | REPRODUCED |
| c3_selftest_anchor   | 8        | 8      | REPRODUCED |
| c3_selftest_claims   | 8        | 8      | REPRODUCED |
| c3_forge_missing_gate| 0        | 0      | REPRODUCED |

All modes exit 0. Receipt: `controls-at-predec.txt`.

## Verdict

Every frozen C3-family counter and gate expectation reproduced exactly at the
candidate; the M39-6 constant-counter class is confirmed caught at gate level
and counter level; no surviving defect observed within this seat's scope.
C1 (~5 min ledger run) and C2 are outside this seat's assignment and were not
run. No lane, fleet, sibling, or domain-source tree was mutated; no commits,
pushes, or fixture-repo mutations performed (none required: the only git
operations were read-only `rev-parse`/`status`/`archive`).

## Tool installs

None. No install need arose; pacman is paused host-wide per the 2026-10-20
guard and nothing in this assignment required a new tool.

## Receipts

- `c3-counter.txt` — C3 counter run at candidate.
- `selftests.txt` — both selftests + `claims-declared.sh --root .` at candidate.
- `constant-mutants.md` — M39-6 mutant derivation with verbatim observed output.
- `controls-at-predec.txt` — extraction + four control modes at f687504….

## Teardown

Scratch tree `/fast/scratch/hyaku/kagi-r40/K40ExecGates/` (const-mut copies,
predec extraction, selftest temp dirs) deleted after these receipts were
written; transient `/tmp/k40eg-*.err` capture files removed.
