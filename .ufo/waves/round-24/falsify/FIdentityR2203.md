# R22-03 identity-swap review

## Verdict

- **Finding severity: none / no actionable defect.** C3 calibration is supported for the assigned R22-03 swap at frozen lane revision `c5ef9e92201b6c36396301f12b23740565bf86a0`. Axes in scope: calibration; freshness and operability not evaluated.
- **Pass:** pristine R22-03 count and R24-15 membership digest agree; the one count-preserving membership swap is killed by R24-15 identity alone. **Fail/survivor:** none. **Invalid control/mutant:** none.

## Scoped verification

- Scratch clone: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/KagiR24-2.FIdentityR2203-9/repo`, then checkout frozen revision `c5ef9e92201b6c36396301f12b23740565bf86a0`; `rev-parse HEAD` returned that exact OID. Execution used `env -i PATH=/usr/bin:/bin` and empty scratch `HOME`; temp files were confined under the sandbox. No host rows, full harness, or install ran.
- Scoped runner (exit 0) reused `m_added_swap` from the cloned `identity-swap.py` and evaluated only `R12-03`, `R22-03`, `R24-15`, first pristine, then the single mutant.
- Pristine command `bash corpus/row-identity.sh revision-added` (exit 0): `ROW_IDENTITY: revision-added count=20 sha256=574d0da4c1b995923dfb9f95694cef96e159a078b7e0d2d6c076a60ee66c429e` — matches R24-15's frozen expected count/digest. Pristine `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` (exit 0): `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=20 invalid=0)`; 20 `ADDED` paths. Scoped ledger control: `CONTROL_FAILING -` for all three rows.
- Mutant changed only tracked `corpus/stamps.tsv`: removed added member `corpus/lessons/round-22-source-errata.md`, added `plans/round-23.md`. It preserved the ADDED population at 20. Mutant audit (exit 0): `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=20 invalid=0)`. Selector (exit 0): `ROW_IDENTITY: revision-added count=20 sha256=f31e3c0e4a1cac349fb3cec77a5b9e3598b9b97602dfd1dca93139019714812e`.
- Mutant scoped ledger result: `MUTANT_FAILING R24-15`; `R12-03` and population row `R22-03` pass (`MUTANT_POPULATION_ROW_PASSES yes`). Thus the old cardinalities remain valid (stamps row count and 20 additions), while the digest projection catches changed membership—not byte/stamp drift or R22-03's unrelated count predicate.
- Falsifier: this pass would fail if the pristine digest differed from R24-15, control failed, mutant changed the 20-member count / made R22-03 fail, or R24-15 passed the changed membership. None occurred.

## Residual risk and verification gaps

- The committed `build/IdentR2203.md` describes the earlier BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (16 additions, pre-R24 identity row); `identity-before-v2.txt` is likewise BASE evidence, while `identity-after.txt` reports `6c23a56dea0f`, not the frozen `c5ef...`. Those receipts alone do not establish the frozen result; the scoped run above does.
- One assigned mutation only; no claim is made about other mutation classes. No LSP device was available in this session, so LSP status/references/definition/diagnostics were not run; no grep output was used as semantic proof.
