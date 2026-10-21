# FSibling — sibling resolver mutation probe

- Seat: KagiR25.FSibling-4. Revision: `82745e2c60e726b49499b8f309529935dc4eff2b`.
- Axes: calibration (exact checked-citation count), operability (sibling hit/miss); freshness UNRUN.
- Result: PASS scoped probe; mutant KILLED. No frozen-candidate counterexample found in this pair; no admission judgment.
- Production code was read-only. Only this report was written in the production lane; all experiments used the unique sandbox below.

## Setup and exact argv

CWD for all detector/hash commands: `/fast/scratch/kagi-r25/FSibling`.
Setup command (exit 0; stdout empty):
```sh
mkdir -p /fast/scratch/kagi-r25/FSibling/home && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FSibling/lane && git -C /fast/scratch/kagi-r25/FSibling/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b
```
Revision command (exit 0; stdout exactly the revision above):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FSibling/home PYTHONDONTWRITEBYTECODE=1 git -C /fast/scratch/kagi-r25/FSibling/lane rev-parse HEAD
```
Fixture files created via file-write tool, all under the sandbox:
- `fleet/MANIFEST.json`: `{}\n` (explicit synthetic fleet marker).
- `fleet/kake-shokunin/x.md`: `# Synthetic sibling target\n`.
- `fleet/lane/corpus/positive.md`: one backticked `kake-shokunin/x.md` plus newline.
- `fleet/lane/corpus/negative.md`: one backticked `kake-shokunin/missing.md` plus newline; that target was not created.

Same bounded detector pair, run on pristine, mutated and restored bytes:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FSibling/home PYTHONDONTWRITEBYTECODE=1 timeout 10s bash lane/corpus/claim-ledger.sh citations --root fleet/lane --docs fleet/lane/corpus/positive.md
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FSibling/home PYTHONDONTWRITEBYTECODE=1 timeout 10s bash lane/corpus/claim-ledger.sh citations --root fleet/lane --docs fleet/lane/corpus/negative.md
```
Expected: positive exit 0 with CLEAN and `cites=1`; negative exit 1 with the specific sibling UNRESOLVED and BROKEN. Pair PASS/FAIL is the comparison of observed outputs, not an executed wrapper's exit code.

## Mutant and actual output

One-line defect at `corpus/claim-ledger.sh:676`, under the `*-shokunin/*` branch at line 675: replace BOTH `$ROOT/../$t` occurrences with `$ROOT/$t`. This misroutes a sibling citation into the lane. No other behavior was mutated.

Exact stdout labels:
```text
P = CITATION_GATE: CLEAN (cites=1 docs=1 unresolved=0 ephemeral=0 labeled=0)
N = UNRESOLVED corpus/negative.md:1 kake-shokunin/missing.md (sibling)
M = UNRESOLVED corpus/positive.md:1 kake-shokunin/x.md (sibling)
B = CITATION_GATE: BROKEN (cites=1 docs=1 unresolved=1 ephemeral=0 labeled=0)
```
| Bytes | Positive stdout / exit | Negative stdout / exit | Pair |
|---|---|---|---|
| pristine | P / 0 | N then B / 1 | PASS |
| mutated | M then B / 1 | N then B / 1 | FAIL — KILLED |
| restored | P / 0 | N then B / 1 | PASS |
All six commands completed within their bound; no stderr was emitted by the detector. The mutant was red, not silently clean; the existing sibling file became the concrete falsifier of the positive contract.

## Restoration evidence and limits

Hash argv, run at each of the three stages (each exit 0):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FSibling/home PYTHONDONTWRITEBYTECODE=1 sha256sum lane/corpus/claim-ledger.sh
```
- Before: `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41`.
- Mutated: `d474954203ed478f5769d86e433f8069d3e9d3a2586df6e2580569d2aa8baad5`.
- Restored: `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41` — exact original file bytes restored by reversing line 676.
- Relevant frozen pointers: `corpus/claim-ledger.sh:647` sibling classification; `:675-676` target resolution; `:688-692` fleet detection; `:803-815` classification/resolution; `:1265-1276` BROKEN/CLEAN verdicts.
- Limits: only one resolver defect and one synthetic sibling hit/miss pair exercised. This is not evidence that the committed selftest kills the mutant: whole `--selftest` UNRUN (unnecessary), `verify`/`cells` UNRUN. Recognition-removal mutation, lone layout, other citation classes, C1 self-counts and C3 clocks UNRUN.
- No network, credentials, account/handler/vault operations, host changes, package installs or tool updates. No production repair or Git-index mutation.
