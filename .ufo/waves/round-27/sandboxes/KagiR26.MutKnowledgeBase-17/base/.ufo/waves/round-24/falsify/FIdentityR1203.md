# FIdentityR1203 — R12-03 / C3

Revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (fresh `--no-hardlinks` sandbox clone, detached checkout verified). Axes: calibration tested; operability and freshness not assessed.

## Finding

No actionable defect in the assigned R12-03 identity check. The single assigned mutant **KILLED by R24-05 membership identity**, not by stamp staleness. It is valid under `identity-swap.py`'s selected-row control rule; the whole subset verifier itself is not green (caveat below).

- `corpus/claim-ledger.tsv:28` notes 63 + 7 + 9 + 4 = 83 pins. `:68` pins R24-05 at count 83 and SHA-256 `136fde8b3656149c61f721eff42e1c0f973576a97d28eab2de079e962103b584` (79 at round-23 close + four named round-24 pins). These populations agree. On pristine c5ef: `grep -c '[^[:space:]]' corpus/stamps.tsv` → `83`, exit 0; `bash corpus/row-identity.sh stamps` → the expected count/digest, exit 0. Independent `LC_ALL=C awk -F '\t' '!/^#/ && length($0)>0 {print $1}' corpus/stamps.tsv | LC_ALL=C sort | sha256sum` reproduced the same digest. `corpus/stamps.tsv` is not self-pinned.
- Ran only `m_stamps_swap` from `.ufo/waves/round-24/tools/identity-swap.py:95-106` in a second c5ef clone. It replaced `corpus/lessons/round-10.md` with previously unpinned tracked `plans/round-21.md`; actual membership changed by exactly that remove/add, 83 → 83. The mutant's stamp metadata is computed from the candidate bytes by the shipped function.
- Mutant `grep -c '[^[:space:]]' corpus/stamps.tsv` → `83`, exit 0. `bash corpus/row-identity.sh stamps` → `ROW_IDENTITY: stamps count=83 sha256=2720ea6e92d90722159b87fda0c39637fd9c35ff4186fa1fa63f68b5e0911a1f`, exit 0. Thus R12-03's count still passes; R24-05 rejects the changed path set (`FAIL R24-05 reason=verdict-not-final exit=0`). Verify summary retained `stale=0 missing=0`, so this is not a stale-stamp catch. R24-15 also fails (`exit-mismatch exit=2`); this is secondary and not the direct digest evidence.
- Control command (cwd pristine clone): `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FIdentityR1203-9/home LANG=C.UTF-8 timeout -k 5 120 bash corpus/claim-ledger.sh verify --claims /fast/scratch/kagi-r24-recovery/FIdentityR1203-9/claims-r1203-harness.tsv --stamps corpus/stamps.tsv` → exit 1; final stdout: `CLAIM_LEDGER: FAIL (claims=17 failed=0 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=485 labeled_ids=53 host_skipped=0)`.
- The same command in the mutant clone → exit 1; stdout includes `FAIL R24-05 reason=verdict-not-final exit=0`, `FAIL R24-15 reason=exit-mismatch exit=2`, and final `CLAIM_LEDGER: FAIL (claims=17 failed=2 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=485 labeled_ids=53 host_skipped=0)`. Both outputs had document-ID diagnostics from the deliberately reduced subset; no host rows were selected.
- The selected-row control has zero `FAIL`/`POLICY` rows as the tool defines validity, but exit 1 means it is not a whole-verifier green run. The classifier ignores that overall status and judges only selected-row failures; treat this evidence strictly at selected-row scope.

## Residual risk and verification gaps

- Historical evidence is not at the frozen revision: `identity-before-v2.txt` is BASE `4f94b52a…`; `identity-after.txt` is `6c23a56d…`; `build/IdentR1203.md` documents the old BASE count 79. The fresh c5ef run above is the evidence for this report.
- `read xd://lsp` returned “No such tool”; no LSP status/references/definition/diagnostics were available. Literal search was only used to locate rows; runtime outputs and the inspected implementation support the conclusions. No tools installed or updated; no host rows or full harness run.
