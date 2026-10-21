# FCensusRawcontrol — bounded C2 mutation probe

Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (checkout observed); original BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` was not executed.
Axes: operability (isolated execution), freshness (capture/classification agreement), calibration (one datum, one exact finding).
Sandbox: `/fast/scratch/kagi-r24-recovery/FCensusRawcontrol-9`; HOME is its newly created empty `.probe-home`.
Fixture: ONLY `case-inrow-raw-control`, matching frozen `base_fixture` plus `m_inrow_raw_ok` (sources-census.sh:374–428,538,625): four registry/capture rows, one sourced entry, one legacy entry, one S001 pin/classification.
Mutant: change only the first hex character of S001's capture raw digest (source-fetches.tsv field 10), `a` → `e`; retain the other 63 characters, in-row pin, normalized digest, date and `reproduces-raw` classification unchanged.
Expected detector: pristine/restored exit 0 with exact CLEAN_INROW; mutated exit 1 with exactly `SC_INROW id=S001 verdict=reproduces-raw capture-says=non-reproducing` (frozen recomputation:309–312).

## Commands and construction
All command executions used `env -i PATH=/usr/bin:/bin HOME=...`; these parameterized commands show the exact executable/arguments. Clone/checkout/mkdir/hash commands exited 0.
```sh
S=/fast/scratch/kagi-r24-recovery/FCensusRawcontrol-9
E="env -i PATH=/usr/bin:/bin HOME=$S/.probe-home"
$E git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin "$S"
$E git -C "$S" checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0
$E mkdir "$S/.probe-home"
# Remaining commands used cwd=$S; mkdir produced no output.
$E mkdir -p case-inrow-raw-control/corpus/lessons
# Detector below executed exactly once at each of pristine, mutated, restored (15s timeout each):
$E bash corpus/sources-census.sh verify --root case-inrow-raw-control
# Hash command below executed at each of the same three states (10s timeout each):
F=case-inrow-raw-control/corpus
$E sha256sum corpus/sources-census.sh "$F/SOURCES.md" "$F/source-fetches.tsv" "$F/inrow-pins.tsv" "$F/knowledge/e1.md" "$F/knowledge/legacy.md"
```
Five fixture files were created with `write`; row-identity hashes came from SHA-256 of the fixture's literal `id<TAB>status<TAB>URL<LF>` tuples. The one-byte mutation and inverse restoration used `edit`, not production writes.

## Actual detector output (verbatim)
Pristine — exit 0:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Mutated — exit 1:
```text
FINDING SC_INROW id=S001 verdict=reproduces-raw capture-says=non-reproducing
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored — exit 0:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```

## Hashes and exact restoration
SHA-256 of fixture `corpus/source-fetches.tsv`:
```text
pristine e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b
mutated  bbe5c23edfd069ff637aca6a126c13f66576cccd2b6c13fc97e71b1a86cf3b91
restored e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b
```
Other SHA-256 values were identical in pristine, mutated and restored states (fixture paths relative to case-inrow-raw-control; detector relative to sandbox):
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  detector corpus/sources-census.sh
 aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212  corpus/SOURCES.md
56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d  corpus/inrow-pins.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  corpus/knowledge/legacy.md
```

Verdict: **KILLED**; expected exits and exact SC_INROW finding observed; no SC_FETCH, SETUP or unrelated finding. Baseline was clean, the mutated file hash changed, and restored hashes/output exactly matched pristine.
Severity: no defect found by this assigned probe; this is not admission of the overall claims.
Observed bounds: three fixture-only census invocations; no entire selftest, real-tree gate, host rows, body normalization, network recapture, C1/C3 verification or other case. Synthetic metadata only; no conclusion about actual remote content.
No production/shared source, index, host configuration or sibling sandbox edits. Only this report was written in the lane. No tools installed or upgraded.
