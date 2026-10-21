# FLocalMiss — PASS; assigned mutant KILLED

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (frozen candidate).
Axes: calibration, operability, freshness; this probe directly exercises C2 operability/classification, not C1/C3.
Sandbox/cwd: `/fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/lane`; HOME: `/fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/home`.
Read `corpus/lessons/round-25.md:17-79` Plan corrections before experiments; no production repair.
Setup command (exit 0; stdout exactly the revision above):
```sh
mkdir -p /fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/home && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/home git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/home git -C /fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/home git -C /fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/lane rev-parse HEAD
```
Same hash argv and bounded detector argv, in the cwd above, for every phase:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/home sha256sum README.md corpus/claim-ledger.sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FLocalMiss-4/home timeout 15s bash corpus/claim-ledger.sh citations --docs README.md
```
Expected detector: pristine/restored CLEAN exit 0; local EOL miss UNRESOLVED/BROKEN exit 1; mixed line BROKEN exit 1 despite fleet absence. Fleet-only control INCOMPLETE exit 3.
Mutation point: append to existing `README.md:14` (no dead-citation marker on that line); no detector changes.
Local suffix: `` `corpus/nope.md` ``. Mixed suffix: `` `kake-shokunin/nope.md` `corpus/nope.md` `` (local remains EOL). Fleet-only control suffix: `` `kake-shokunin/nope.md` ``.
Actual detector stdout follows in full; all detector stderr empty. Every hash command exited 0.

## Pristine — PASS; exit 0
```text
CITATION_LAYOUT: lone-clone fleet_absent=0 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: CLEAN (cites=3 docs=1 unresolved=0 ephemeral=0 labeled=0)
```
## Local EOL mutation — PASS; exit 1; KILLED
```text
UNRESOLVED README.md:14 corpus/nope.md (local)
CITATION_LAYOUT: lone-clone fleet_absent=0 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: BROKEN (cites=4 docs=1 unresolved=1 ephemeral=0 labeled=0)
```
## Same-line fleet + local EOL — PASS; exit 1; KILLED
```text
FLEET-ABSENT README.md:14 kake-shokunin/nope.md (sibling)
UNRESOLVED README.md:14 corpus/nope.md (local)
CITATION_LAYOUT: lone-clone fleet_absent=1 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: BROKEN (cites=5 docs=1 unresolved=1 ephemeral=0 labeled=0)
```
## Fleet-only control — PASS; exit 3
```text
FLEET-ABSENT README.md:14 kake-shokunin/nope.md (sibling)
CITATION_LAYOUT: lone-clone fleet_absent=1 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: INCOMPLETE (cites=4 docs=1 unresolved=0 ephemeral=0 labeled=0 fleet_absent=1)
```
## Restored pristine — PASS; exit 0
```text
CITATION_LAYOUT: lone-clone fleet_absent=0 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: CLEAN (cites=3 docs=1 unresolved=0 ephemeral=0 labeled=0)
```
## Hashes / restoration evidence
SHA-256 of `README.md` from the same hash command at each phase:
- Pristine: `add2a5169e472b33d147610963a6ea052d6a4f6aa8b398e75000fd5942f68733`
- Local EOL: `d57d61d3214294243be692516a93770da9975fd1ca307c263a2d96b9cfb930f9`
- Mixed: `9db55c540cd684f014d1d92b10497039a2098a75f82e348d579c5147f0248d4e`
- Fleet-only: `4aaa376aad05f185fe3edecf53e052a984e1d2c883298767e979c58599f5619b`
- Restored: `add2a5169e472b33d147610963a6ea052d6a4f6aa8b398e75000fd5942f68733` — exact original bytes restored.
`corpus/claim-ledger.sh` stayed `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41` in all five phases.
Pointers: `corpus/claim-ledger.sh:641-648` class ownership; `:823-831` per-token classification; `:836-841` EOL tokenizer; `:1265-1273` BROKEN precedes INCOMPLETE.
Concrete attempted falsifier: a lane-owned EOL miss gets dropped or laundered into fleet absence, or a same-line sibling miss downgrades BROKEN. Neither occurred; no counterexample found for these inputs.
Limits / UNRUN: other docs/classes/layouts, EOF without newline, default-doc census, full verify/cells, C1 calibration and C3 clock checks. No general invariant or round-acceptance judgment.
Tools installed/updated: none. No network, credentials, account/vault/handler/CDP operations, subagents, background jobs, or other runtime. Production writes: this report only.
