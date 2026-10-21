# FEol — PASS: newline-regression mutant KILLED

Axes: calibration (checked-token count and missing-path verdict), operability (bounded lone-clone citations), freshness (exact frozen revision; release clocks UNRUN).
Revision: `82745e2c60e726b49499b8f309529935dc4eff2b`; seat `KagiR25.FEol-4`.
Sandbox/CWD: `/fast/scratch/kagi-r25/KagiR25.FEol-4/lane`; HOME: `/fast/scratch/kagi-r25/KagiR25.FEol-4/home`.
Read `corpus/lessons/round-25.md:17-79` first; correction R25-C4, not the withdrawn fleet-row-skip design, governs this probe.

## Setup and mutation
Executed setup (exit 0):
```sh
mkdir -p /fast/scratch/kagi-r25/KagiR25.FEol-4/home && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FEol-4/home git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/KagiR25.FEol-4/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FEol-4/home git -C /fast/scratch/kagi-r25/KagiR25.FEol-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FEol-4/home git -C /fast/scratch/kagi-r25/KagiR25.FEol-4/lane rev-parse HEAD
```
Stdout: `82745e2c60e726b49499b8f309529935dc4eff2b`.
`mkdir -p corpus/FEol-fixtures` succeeded in the sandbox. Four fixture files were written there; JSON-escaped exact content:
```text
eol-broken.md   = "`corpus/FEol-absent.md`\n"
eol-existing.md = "`corpus/claim-ledger.sh`\n"
space-broken.md = "`corpus/FEol-absent.md` \n"
tab-broken.md   = "`corpus/FEol-absent.md`\t\n"
```
Only behavior-bearing mutation: sandbox `corpus/claim-ledger.sh:839`, `printf '%s\n' "$content"` → `printf '%s' "$content"`; restored with the inverse single-line edit.
Pointers: tokenizer `corpus/claim-ledger.sh:797-842`; existing regression fixture/assertion `:1770,:1783`; verdict dispatch `:1259-1276`.

## Same bounded detector: pristine → mutant → restored
Exact argv template (each `<fixture>` is the literal filename in the table; all four invocations ran in each stage, concurrently within the stage):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FEol-4/home timeout 10s bash corpus/claim-ledger.sh citations --root . --docs corpus/FEol-fixtures/<fixture>
```
Expected detector: missing path must exit 1, print UNRESOLVED and count one citation; existing path must exit 0 and count one citation. No timeouts or stderr were observed.
Exact stdout dictionary, preserving line order (L is the shared layout line):
```text
L = CITATION_LAYOUT: lone-clone fleet_absent=0 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
B(f) = UNRESOLVED corpus/FEol-fixtures/f:1 corpus/FEol-absent.md (local)
       [L]
       CITATION_GATE: BROKEN (cites=1 docs=1 unresolved=1 ephemeral=0 labeled=0)
C1 = [L]
     CITATION_GATE: CLEAN (cites=1 docs=1 unresolved=0 ephemeral=0 labeled=0)
C0 = [L]
     CITATION_GATE: CLEAN (cites=0 docs=1 unresolved=0 ephemeral=0 labeled=0)
```
Here `f` in B(f) expands to the literal fixture filename below; brackets denote dictionary expansion, not emitted bytes.
| Fixture | Pristine exit/stdout | Mutant exit/stdout | Restored exit/stdout | Detector result |
|---|---|---|---|---|
| eol-broken.md | 1 / B(eol-broken.md) | 0 / C0 | 1 / B(eol-broken.md) | PASS → FAIL → PASS; KILLED |
| eol-existing.md | 0 / C1 | 0 / C0 | 0 / C1 | PASS → FAIL(count) → PASS |
| space-broken.md | 1 / B(space-broken.md) | 1 / B(space-broken.md) | 1 / B(space-broken.md) | PASS all; alone does not kill |
| tab-broken.md | 1 / B(tab-broken.md) | 1 / B(tab-broken.md) | 1 / B(tab-broken.md) | PASS all; alone does not kill |

## Restoration evidence and limits
At all three stages the command below exited 0 (same CWD/environment); exact SHA-256 stdout hash for `corpus/claim-ledger.sh`:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FEol-4/home sha256sum corpus/claim-ledger.sh
```
- Before: `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41`.
- Mutated: `995a35ba15b347f8339b6002eeec19503a849b864cbd6f771139ccebecf65923`.
- Restored: `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41` (exact before/after match: PASS).
Concrete falsifier: one missing, backticked EOL citation becomes CLEAN/cites=0 when the added newline is removed. The baseline and restored detector both reject it; trailing space/tab supply delimiters and conceal this defect, while exit-only existing-path checks also miss it.
No counterexample to the frozen candidate was found in these four cases. UNRUN: full verify/cells, integrated selftest, self-counts/C1, release clocks/C3, other citation classes/layouts, and files without a final LF. No host/account/vault/network operations or installs; production source/index untouched. Only this report was written in the production checkout.
