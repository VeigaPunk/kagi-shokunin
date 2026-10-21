# FCensusCapturedate — C2 `inrow-capture-date`

Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Axes: operability (isolated fixture execution), freshness (classification/capture date equality), calibration (exact finding identity/count).
Result: **PASS within the stated bounds; mutant KILLED.** Severity: no defect observed by this probe; no admission judgment.

## Isolation and commands
`S=/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusCapturedate-9`
`H=/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusCapturedate-9-home` (created empty; HOME for every execution).
Below, `$S` and `$H` abbreviate the absolute paths actually supplied; command working directory was `$S` except clone setup.
Setup: `env -i PATH=/usr/bin:/bin HOME=$H /usr/bin/mkdir -p /fast/scratch/kagi-r24-recovery $H` (exit 0).
Clone: `env -i PATH=/usr/bin:/bin HOME=$H /usr/bin/git -c core.hooksPath=/dev/null clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin $S` (exit 0).
Checkout: `env -i PATH=/usr/bin:/bin HOME=$H /usr/bin/git -c core.hooksPath=/dev/null -C $S checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0` (exit 0; HEAD reported `c5ef9e9`).
Fixture: `$S/inrow-capture-date`, reproducing `base_fixture` (sources-census.sh:374–426), with the S001 raw-pin control from line 538; empty lessons directory included.
Only this four-row fixture/control was built; production files were not edited. No real-tree gate, full selftest, network, host/account operation, or installation was run.

## Mutant and expected detector
Mutation: fixture `corpus/inrow-pins.tsv`, S001 column 3 only: `2026-10-19` → `2026-10-20`.
The S001 capture date remained `2026-10-19`; its 64×`a` raw digest, pin, verdict `reproduces-raw`, and other fields stayed unchanged.
Expected: pristine/restored exit 0 and CLEAN; mutated exit 1, exactly `FINDING SC_INROW id=S001 capture-date`, and `findings=1 rows=4`.
Authority: frozen case table line 630 (`1|SC_INROW|1`), date predicate line 308. No SC_FETCH or SETUP finding is expected.
Falsifier: acceptance of the changed date, missing/wrong finding, wrong count, or failure of a clean control (the latter would make this probe inconclusive).
Same command for all three phases:
`env -i PATH=/usr/bin:/bin HOME=$H /usr/bin/bash probe-capture-date.sh`
The unchanged wrapper executes `/usr/bin/timeout 20s /usr/bin/bash corpus/sources-census.sh verify --root inrow-capture-date`, prints `DETECTOR_EXIT=$rc`, and exits `$rc`; tool deadline 30s.

## Exact captured output
Pristine — command exit **0**:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
DETECTOR_EXIT=0
```
Mutated — command exit **1**:
```text
FINDING SC_INROW id=S001 capture-date
SOURCES_CENSUS: FAILED (findings=1 rows=4)
DETECTOR_EXIT=1
```
Restored — command exit **0**:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
DETECTOR_EXIT=0
```

## Hash and restoration evidence
At each phase, exit-0 command: `env -i PATH=/usr/bin:/bin HOME=$H /usr/bin/sha256sum corpus/sources-census.sh inrow-capture-date/corpus/SOURCES.md inrow-capture-date/corpus/knowledge/e1.md inrow-capture-date/corpus/knowledge/legacy.md inrow-capture-date/corpus/source-fetches.tsv inrow-capture-date/corpus/inrow-pins.tsv`.
SHA-256 of fixture `inrow-pins.tsv`:
- Before: `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`
- Mutated: `4b2b1d45fdb5a8973a8d3d5ea171bb61a1d7b70903e0967adfcce491afe28dd3`
- Restored: `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`
Other SHA-256 outputs were identical at all three phases:
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh
aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212  inrow-capture-date/corpus/SOURCES.md
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  inrow-capture-date/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  inrow-capture-date/corpus/knowledge/legacy.md
e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b  inrow-capture-date/corpus/source-fetches.tsv
```
The changed hash proves mutation was not inert; only the classification file changed, then its exact bytes were restored before the third identical detector invocation.
Bounds: one S001 date-equality mutation, four fixture registry rows/captures, one in-row pin, three bounded executions; no unrelated setup failure observed. Whole-corpus recapture, normalizer behavior, C1 host safety, and C3 membership-bound counts remain untested here.
