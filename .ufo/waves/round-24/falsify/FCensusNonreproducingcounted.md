# FCensusNonreproducingcounted — bounded recovery probe

Result: PASS for this probe; evidence mutant KILLED. Severity: none observed. No C2 counterexample found within these bounds.
Axes: operability (isolated fixture execution), freshness (recomputed classification), calibration (exact fixture counters; C3 not exercised).
Frozen revision observed by `git -C repo rev-parse HEAD`: `c5ef9e92201b6c36396301f12b23740565bf86a0`.
Original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (not executed).
Read scope: `plans/round-24.md` and assigned `corpus/sources-census.sh` only; frozen census lines 374–428, 532–562 define the fixture/control; lines 309–313 recompute its verdict/count.

## Isolation and commands
`S=/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusNonreproducingcounted-9`; `L=/home/vgpnk/Projects/shokunin/kagi-shokunin`.
All execution used `env -i PATH=/usr/bin:/bin HOME="$S/.home"`; HOME was an empty sandbox directory. Commands below use those path abbreviations.
- `mkdir -p "$S/.home"` — exit 0.
- `git clone --no-hardlinks "$L" "$S/repo"` — exit 0.
- `git -C "$S/repo" checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0` — exit 0; `HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`.
- Created only the named four-row fixture and empty lessons directory under `$S/fixture`, matching `base_fixture` plus `m_inrow_nonrep_ok`; no selftest dispatch or real-tree census.
- Detector, identical all three times, cwd `$S`: `env -i PATH=/usr/bin:/bin HOME="$S/.home" bash repo/corpus/sources-census.sh verify --root fixture` (30-second bound per invocation).
- Hash command, identical all three times, cwd `$S`: `env -i PATH=/usr/bin:/bin HOME="$S/.home" sha256sum repo/corpus/sources-census.sh fixture/corpus/SOURCES.md fixture/corpus/source-fetches.tsv fixture/corpus/inrow-pins.tsv fixture/corpus/knowledge/e1.md fixture/corpus/knowledge/legacy.md` — exit 0 each time.

## Mutant and expected detector
Pristine S001: historical pin = `7` × 64, capture raw = `a` × 64, normalized = `1` × 64, classification = `non-reproducing` on 2026-10-19. Expected exit 0 and exact CLEAN counter `inrow_nonreproducing=1`.
One independently changed datum: S001 capture TSV field 15, normalized digest, `1` × 64 → `7` × 64. Raw digest, historical pin, classification, dates and every other fixture datum stayed unchanged.
Falsifier: census accepts the stale non-reproducing classification after normalized evidence matches its historical pin. Expected rejection: exit 1, exactly `SC_INROW id=S001 verdict=non-reproducing capture-says=reproduces-normalized`; no SC_FETCH/setup finding.

## Actual census output (verbatim)
Pristine — exit 0:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=1)
```
Mutated — exit 1:
```text
FINDING SC_INROW id=S001 verdict=non-reproducing capture-says=reproduces-normalized
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored — exit 0:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=1)
```
The expected normalized-evidence branch fired. Pristine/restored controls passed; the sole mutant finding was the intended SC_INROW, not an unrelated setup/provenance failure.

## SHA-256 and restoration evidence
`fixture/corpus/source-fetches.tsv`:
- Before: `e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b`
- Mutated: `665126d581349a7f42cef18eb83d1548415bfd5f63092f67c5360a87f23ce5d6`
- Restored: `e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b`
Other hashes were identical before, mutated and restored:
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  repo/corpus/sources-census.sh
d17fdd3c0b6c9b49ffa6a8644a0c20c8ad9ba67978f31e418348040a31bf0736  fixture/corpus/SOURCES.md
ee5328d93bb80e17a3662dd1dab4e6a9197467dbef69b1cec109460605e24f07  fixture/corpus/inrow-pins.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  fixture/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  fixture/corpus/knowledge/legacy.md
```
Exact mutated-file bytes restored; census source never changed. Bounds: one named positive control, one field flip, three census runs over four synthetic rows/one in-row pin/four captures. No live fetch, normalizer execution, host gate, full selftest, sibling edit or production edit. Actual remote-body freshness and broader C1/C3 invariants remain unassessed. No tool installs/updates.
