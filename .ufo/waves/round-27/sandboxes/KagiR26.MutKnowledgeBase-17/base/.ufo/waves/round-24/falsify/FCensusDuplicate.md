# FCensusDuplicate — bounded C2 mutation probe
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Axes: operability (isolated fixture execution), freshness (unique pin classification), calibration (exact finding and unchanged counts).
Verdict: **KILLED / bounded PASS**. Severity: no defect observed for this case; no admission judgment or general C2/C3 pass.

## Scope and commands
Sandbox `S=/fast/scratch/kagi-r24-recovery/FCensusDuplicate-9`; command cwd was `$S` after checkout.
Execution prefix `E=env -i PATH=/usr/bin:/bin HOME=$S/.home` (notation, not a shell variable used by the detector).
Clone command: `E /usr/bin/git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin $S`.
Then `E /usr/bin/mkdir -p $S/.home`; `E /usr/bin/git -C $S checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0`.
Clone/checkout exited 0; checkout stdout: `HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`.
Constructor command: `E /usr/bin/bash build-fixture.sh $S/fixture`; exit 0, no output.
The scratch constructor mirrors `base_fixture()` (sources-census.sh:374–428), adding only the existing S001 raw-control pin/classification (538).
Fixture bounds: four example.invalid registry rows, four capture attestations, one sourced entry, one legacy entry, one S001 raw pin; no network/body recapture.
Exactly one datum changed: classification multiplicity 1 → 2, by appending an identical five-field TSV row to `fixture/corpus/inrow-pins.tsv`.
Row fields: `S001`, 64 lowercase `a` characters, `2026-10-19`, `reproduces-raw`, `selftest`, separated by tabs, newline terminated.
No detector/source edit; neither the production gate nor the entire selftest was run.
Evidence anchors: duplicate guard line 304; named fixture `m_inrow_dup` line 544; expected row line 631 (`exit=1`, `SC_INROW`, one finding).

## Same bounded detector, three byte states
Command each time: `E /usr/bin/bash corpus/sources-census.sh verify --root $S/fixture`.
Expected: pristine/restored exit 0 and exact CLEAN line; duplicate exit 1 and exactly `SC_INROW id=S001 duplicate-classification`.
Pristine: exit 0; exact stdout:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Mutated: exit 1; exact stdout:
```text
FINDING SC_INROW id=S001 duplicate-classification
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored: exit 0; exact stdout:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
No detector stderr was observed in any run. No SETUP verdict or unrelated finding occurred.
Mutation demonstrably fired: appended row visible in edit result, digest changed, and the specific duplicate finding appeared.

## Restoration and byte evidence
Hash command in every state: `E /usr/bin/sha256sum corpus/sources-census.sh fixture/corpus/SOURCES.md fixture/corpus/source-fetches.tsv fixture/corpus/inrow-pins.tsv fixture/corpus/knowledge/e1.md fixture/corpus/knowledge/legacy.md` (all exit 0).
`fixture/corpus/inrow-pins.tsv` SHA-256:
- Pristine: `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`
- Mutated: `f21927f5b3cca41642df386b4da90feed96b201a79c3e9ada780224eea661ac6`
- Restored: `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`
Restoration deleted only appended line 2 with the edit tool; restored bytes match pristine exactly.
Other SHA-256 values were identical in pristine, mutated and restored states:
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh
aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212  fixture/corpus/SOURCES.md
e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b  fixture/corpus/source-fetches.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  fixture/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  fixture/corpus/knowledge/legacy.md
```
Falsifier sought: a duplicate five-field S001 classification accepted as CLEAN, a wrong/unstable finding, or contamination of restoration. None occurred in this one probe.
Observed limit: tests classification-record duplication only, not live freshness, body/digest truth, other census cases, C1 host policy or C3 population identity.
Production files remained read-only; the only lane write is this report. No installs, services, credentials, host gates, delegates or background jobs.
