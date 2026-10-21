# FCensusOrphanclassification — bounded C2 mutation probe

- Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (observed checkout and `git rev-parse HEAD`).
- Original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`; not executed.
- Axes: operability (isolated execution), freshness (classification-to-pin binding), calibration (exact finding/count).
- Verdict: **KILLED; scoped PASS**. Severity: no defect demonstrated by this probe; C1/C3 and broader C2 remain untested.
- Sandbox `S=/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusOrphanclassification-9`; lane `L=/home/vgpnk/Projects/shokunin/kagi-shokunin`.
- Bounds: one named fixture/control, three census invocations, 10-second timeout each; no full selftest, real-tree verification, network or host-row execution.

## Construction and falsifier

Used the four registry/capture rows and two entries from `corpus/sources-census.sh:374-426`, with the S001 reproduces-raw control from lines 533-538.
Control: S001 has a 64×`a` in-row pin, matching raw capture digest and one matching classification dated 2026-10-19.
Single-datum mutation: remove only `. Fetch sha256: <backtick>64×a<backtick>` from S001's teaches cell, retaining the classification and all captures.
This produces the named `m_inrow_orphan` condition (line 554; expected case at line 634).
Expected detector: exit 1, exactly `FINDING SC_INROW id=S001 not-an-inrow-row`, and findings=1; a clean exit or unrelated/setup failure would not kill this mutant.

## Commands and actual output

Preparation (all commands exit 0; environment restricted throughout):
```sh
env -i PATH=/usr/bin:/bin HOME="$S" /bin/mkdir -p "$S"
env -i PATH=/usr/bin:/bin HOME="$S" git clone --no-hardlinks "$L" "$S"
env -i PATH=/usr/bin:/bin HOME="$S" /bin/mkdir "$S/.probe-home"
env -i PATH=/usr/bin:/bin HOME="$S/.probe-home" git -C "$S" checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0
```
Fixture files were written under `$S/fixture` using the existing fixture content; only its S001 row was edited and restored.
Same detector command for pristine, mutated and restored bytes, cwd=`$S`:
```sh
env -i PATH=/usr/bin:/bin HOME="$S/.probe-home" timeout 10s bash corpus/sources-census.sh verify --root fixture
```
Pristine: exit 0; stderr empty; exact stdout:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Mutated: exit 1; stderr empty; exact stdout:
```text
FINDING SC_INROW id=S001 not-an-inrow-row
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored: exit 0; stderr empty; exact stdout:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Exact exit/stdout/stderr comparisons: `pristine_exact=true`, `orphan_exact=true`, `restored_exact=true`; `VERDICT=KILLED`.

## Restoration evidence

Each phase ran, cwd=`$S` (exit 0):
```sh
env -i PATH=/usr/bin:/bin HOME="$S/.probe-home" sha256sum corpus/sources-census.sh fixture/corpus/SOURCES.md fixture/corpus/source-fetches.tsv fixture/corpus/inrow-pins.tsv fixture/corpus/knowledge/e1.md fixture/corpus/knowledge/legacy.md
```
`fixture/corpus/SOURCES.md` SHA-256:
- Pristine: `aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212`
- Mutated: `1350bc7d2ef7fdadd2c3bb522734c0800b801320f5dce06319762933cee2ccc1`
- Restored: `aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212`
All other measured files were identical across all three phases:
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh
e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b  fixture/corpus/source-fetches.tsv
56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d  fixture/corpus/inrow-pins.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  fixture/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  fixture/corpus/knowledge/legacy.md
```
Mutation fired (changed source hash); restoration is byte-exact (original hash and detector output recovered). No unrelated findings or setup failures occurred. No production edits or installs; only this assigned report was written in the lane.
