# FCensusUnclassified — bounded C2 mutation probe
Axes: operability (isolated fixture), freshness (unclassified pin refusal), calibration (one precise finding).
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Sandbox: `/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9` (all command cwd after checkout).
Bootstrap HOME: `/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9-home` (created empty).
Detector HOME: sandbox `/.probe-home` (created empty); all executions used `env -i PATH=/usr/bin:/bin HOME=...`.
Bounds: only the four-row selftest fixture; no real-tree verify, full selftest, host rows, network, or ledger execution.
Production files were read-only; the only lane write is this report. No installs, delegates, or background jobs.

## Construction and command evidence
Bootstrap commands, each exit 0 (clone/checkout used bootstrap HOME above):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9-home mkdir -p /fast/scratch/kagi-r24-recovery/FCensusUnclassified-9-home
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9-home git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FCensusUnclassified-9
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9-home git -C /fast/scratch/kagi-r24-recovery/FCensusUnclassified-9 checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9-home mkdir -p /fast/scratch/kagi-r24-recovery/FCensusUnclassified-9/.probe-home
```
Checkout reported `HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`.
`probe-setup.sh` copies frozen `base_fixture` and `rep` declarations (sources-census.sh:374–428), calling only `base_fixture probe`.
Setup command, exit 0, no stdout/stderr:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9/.probe-home bash probe-setup.sh probe
```
Mutant: change only `probe/corpus/SOURCES.md:7`, replacing S001's `teaches one` with `teaches one. Fetch sha256: ` followed by the backtick-enclosed 64-character `a` digest. Leave classification absent and all captures unchanged; this independently reproduces `m_inrow_unclassified` (:537).
Expected detector: frozen case table :624 requires exit 1, `SC_INROW`, exactly one finding; :321 supplies detail `id=S001 classification-missing`.
Same command in all three phases, each with a 15-second deadline:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9/.probe-home bash corpus/sources-census.sh verify --root probe
```

## Actual detector stdout (complete)
Pristine: exit 0; no stderr:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=0 inrow_only=0 inrow_nonreproducing=0)
```
Mutated: exit 1; no stderr:
```text
FINDING SC_INROW id=S001 classification-missing
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored: exit 0; no stderr:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=0 inrow_only=0 inrow_nonreproducing=0)
```

## Mutation firing and exact restoration
Hash command, run in every phase, exit 0:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusUnclassified-9/.probe-home sha256sum probe/corpus/SOURCES.md probe/corpus/source-fetches.tsv probe/corpus/knowledge/e1.md probe/corpus/knowledge/legacy.md corpus/sources-census.sh
```
SOURCES.md pristine/restored: `1350bc7d2ef7fdadd2c3bb522734c0800b801320f5dce06319762933cee2ccc1`.
SOURCES.md mutated: `aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212`.
Other hashes identical in all three phases:
- source-fetches.tsv: `e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b`
- knowledge/e1.md: `bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38`
- knowledge/legacy.md: `399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9`
- census detector: `8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a`
The single fixture edit was undone exactly; restored hash and CLEAN stdout equal pristine. No setup failure or unrelated finding occurred; SC_FETCH findings=0.
Verdict: **KILLED / bounded detector PASS**. Severity: no defect observed in this assigned case; no C2 counterexample found.
Falsifier: the same unclassified S001 pin returning CLEAN, a different/missing SC_INROW detail, or unrelated setup failure would defeat this result.
C1 ledger operability and C3 membership-bound counts were not exercised; broader claim status remains unknown here. This is author-side evidence, not admission authority.
