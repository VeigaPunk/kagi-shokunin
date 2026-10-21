# FSelfMiss — bounded self-reference mutation probe
Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (clone HEAD observed; exit 0).
Axes: calibration (bounded evidence), operability (C2 exercised), freshness (UNRUN).
Verdict: PASS — the missing-self-reference defect was KILLED in direct and brace-set encodings; no C2 counterexample observed in this probe.
Scope: only isolated scratch input changed; no production repair, integration, or round-admission judgment.

## Setup and exact detector argv
`S=/fast/scratch/kagi-r25/KagiR25.FSelfMiss-4` abbreviates absolute paths below.
Setup command (exit 0; stdout empty):
```sh
mkdir -p "$S/home" && env -i PATH=/usr/bin:/bin HOME="$S/home" git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin "$S/lane" && env -i PATH=/usr/bin:/bin HOME="$S/home" git -C "$S/lane" checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b
```
Every subsequent command used cwd `$S/lane` (an arbitrary clone name, not `kagi-shokunin`).
`env -i PATH=/usr/bin:/bin HOME="$S/home" git rev-parse HEAD` exited 0 with the revision above.
`env -i PATH=/usr/bin:/bin HOME="$S/home" test ! -e corpus/nope.md` exited 0, stdout empty.
The SAME bounded detector ran at all four stages:
```sh
env -i PATH=/usr/bin:/bin HOME="$S/home" bash corpus/claim-ledger.sh citations --docs corpus/FSelfMiss-probe.md
```
Clean synthetic input `corpus/FSelfMiss-probe.md:1-2` (written only in scratch):
```text
Positive `kagi-shokunin/corpus/README.md` and reference `kagi-shokunin/corpus/README.md`
Positive `kagi-shokunin/corpus/README.md` and set `kagi-shokunin/corpus/{README,README}.md`
```
Mutant: a self-owned absent file, first changing only line 1's final `README.md` to `nope.md`; then restoring line 1 and changing only line 2's set to `{README,nope}.md`.
Expected detector: clean input exit 0; either missing-self encoding `UNRESOLVED … (self)`, BROKEN exit 1, never FLEET-ABSENT/INCOMPLETE exit 3.

## Actual stdout and exits
All four stages printed this layout line (verbatim):
```text
CITATION_LAYOUT: lone-clone fleet_absent=0 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
```
Pristine input — PASS, exit 0; layout line followed by:
```text
CITATION_GATE: CLEAN (cites=4 docs=1 unresolved=0 ephemeral=0 labeled=0)
```
Direct mutant — PASS/KILLED, exit 1; before layout line:
```text
UNRESOLVED corpus/FSelfMiss-probe.md:1 kagi-shokunin/corpus/nope.md (self)
```
Brace mutant — PASS/KILLED, exit 1; before layout line:
```text
UNRESOLVED corpus/FSelfMiss-probe.md:2 kagi-shokunin/corpus/{README,nope}.md (self)
```
Each mutant's layout line was followed by:
```text
CITATION_GATE: BROKEN (cites=4 docs=1 unresolved=1 ephemeral=0 labeled=0)
```
Restored exact input — PASS, exit 0; stdout identical to pristine. Thus existing README self-citations resolve under clone name `lane`, including the all-existing brace set; the same-line positive citation does not hide the missing brace alternative.

## Hashes and restoration evidence
Hash argv: `env -i PATH=/usr/bin:/bin HOME="$S/home" sha256sum corpus/FSelfMiss-probe.md corpus/claim-ledger.sh corpus/README.md` before/after (both exit 0); intermediate argv used only `corpus/FSelfMiss-probe.md` (both exit 0).
- Probe pristine/restored: `792ad8f8a81320243b5e2153df2725f868bacbe7565add386200768d332b9794`.
- Probe direct mutant: `81907b32f83a810c9d6c18d3fd00bece2eb07406b0b8f351baa7c0ca94f2410f`.
- Probe brace mutant: `f1b4354df008543a55da2fc3d85c01a8fa82645d3f5e3834c1727185da526931`.
- Detector before/after: `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41`.
- Referenced README before/after: `0ddc590a688886a96bce2ab98d75df87a797d4e2e65ce3b226ef968d58f50366`.
Source pointers: `corpus/claim-ledger.sh:646,668-674` self resolution; `:711-721` self not fleet-only; `:805-814` every brace alternative; `:823-831,1265-1268` unresolved/BROKEN exit 1.
Concrete falsifier sought: either absent self encoding accepted CLEAN/0 or downgraded to FLEET-ABSENT/3. Neither occurred; this is not an exhaustive tokenizer/layout proof.
Limits: C1 numeric calibration and C3 live freshness UNRUN; full verify/cells/selftest UNRUN; no network, host/account/vault operations, or tool installs/updates. Only this report was written in production; scratch fixture restored, candidate source unchanged.
