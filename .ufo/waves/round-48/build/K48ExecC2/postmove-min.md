## Round 48 — post-move (claims C1 operability, C2 calibration)

Candidate: the round-48 candidate commit (recorded in the report; this section is written before the candidate's hash is known and names the content it measures). Claim BASE `76da518fcc3029e738648bd6fd4ba5571df01c1c`; predeclaration `164f0ea5ed8b76a671f9b076158d1d8022881813` + amendment A1 `52991e5da64cbacaa724b28b407cf5765fd21b41` (frozen plan `plans/round-48.md`, counter `plans/round-48-c1.sh`, pre-freeze controls `plans/round-48-controls.sh`). Measured receipts: `.ufo/waves/round-48/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-48-c1.sh <candidate>` (BASE 0, target 5): the lane executes the SOPS/age access-and-rotation mechanics its entry `corpus/knowledge/sops-age-key-rotation.md` documents; the trial `corpus/sops-age-trial.sh` runs T1..T5 against the real `sops` 3.13.3 / `age-keygen` 1.3.2 and each test flips to BROKEN under its designated falsifier shim. | `plans/round-48-c1.sh`; `.ufo/waves/round-48/` |
| calibration | 9 → 9 | [C2] `bash plans/round-48-c2.sh <candidate>` 3 → 0 (target 0): the `## Capabilities` table's stated evidence readings agree with the commands' executed output at the measured revision for the ten frozen keys K01..K10; the current-readings line is inserted in that section. | `plans/round-48-c2.sh`; `.ufo/waves/round-48/build/K48ExecC2/readings-line.txt` |
| coverage | 9 → 9 | No claim. | `plans/round-48.md` |
| depth | 9 → 9 | No claim. | `plans/round-48.md` |
| freshness | 9 → 9 | No claim. | `plans/round-48.md` |
| adjacency | 9 → 9 | No claim. Connector: no sibling registry row teaches SOPS/age; no sibling trial tooling. | `.ufo/waves/round-48/build/` |
