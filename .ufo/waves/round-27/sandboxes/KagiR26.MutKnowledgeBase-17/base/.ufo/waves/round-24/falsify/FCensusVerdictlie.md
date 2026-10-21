# FCensusVerdictlie — round-24 recovery

Axes: operability (isolated execution), freshness (C2 classification), calibration (one-datum detector specificity).
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (observed `git rev-parse HEAD`, exit 0).
Original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`; not executed for this probe.
Verdict: **KILLED / bounded PASS**. Severity: informational; no counterexample in this assigned case.
Author-side verification only; not an independent admission decision.

## Scope and construction
Read `plans/round-24.md` and assigned `corpus/sources-census.sh`; fixture definitions at 374–428, named case at 541/628, detector at 309–312.
Sandbox: `/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusVerdictlie-9` (S below).
Bootstrap command (exit 0):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusVerdictlie-9 bash --noprofile --norc -c 'set -eu; mkdir -p "$HOME"; git -c core.hooksPath=/dev/null clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin "$HOME"; mkdir "$HOME/.empty-home"; env -i PATH=/usr/bin:/bin HOME="$HOME/.empty-home" git -C "$HOME" -c core.hooksPath=/dev/null checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0'
```
Clone output: `Cloning into '/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusVerdictlie-9'...`, `done.`, `HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`.
Constructed only `.probe-fixture`: existing four-row fixture, two knowledge entries, four capture rows, plus S001's honest raw pin/classification. No full selftest.
Builder: copied existing fixture shape into scratch `.probe-build-fixture.sh`, with S001 pin `a` × 64 and classification `reproduces-raw`.
Builder command from S: `env -i PATH=/usr/bin:/bin HOME=$S/.empty-home bash .probe-build-fixture.sh $S/.probe-fixture`; exit 0, no output.
Mutant: changed only S001 field 4 in fixture `corpus/inrow-pins.tsv`, `reproduces-raw` → `non-reproducing`, using a hashline edit; same id/pin/date/note and capture bytes.
This independently instantiates `inrow-verdict-lie`; S001 capture raw sha256 equals the pin, normalized sha256 is `1` × 64.
Expected detector: baseline/restored exit 0 CLEAN; mutant exit 1 with exactly `SC_INROW id=S001 verdict=non-reproducing capture-says=reproduces-raw` and one finding.

## Identical bounded detector, three executions
Cwd S; environment exactly `PATH=/usr/bin:/bin`, `HOME=$S/.empty-home` (empty).
Actual argv each time: `/usr/bin/timeout 10s /usr/bin/bash corpus/sources-census.sh verify --root /fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusVerdictlie-9/.probe-fixture`.
Launched via `subprocess.run` with that explicit environment, captured stdout/stderr, outer timeout 15 seconds.
Pristine: exit 0; stdout exactly:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Mutated: exit 1; stdout exactly:
```text
FINDING SC_INROW id=S001 verdict=non-reproducing capture-says=reproduces-raw
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored: exit 0; stdout exactly:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
All three stderr values were empty; output lines ended in newline. No SETUP, SC_FETCH, timeout, or unrelated finding occurred.

## Byte-change and restoration evidence
Command at each phase, cwd S, same sanitized environment: `sha256sum corpus/sources-census.sh .probe-fixture/corpus/SOURCES.md .probe-fixture/corpus/source-fetches.tsv .probe-fixture/corpus/inrow-pins.tsv .probe-fixture/corpus/knowledge/e1.md .probe-fixture/corpus/knowledge/legacy.md`; exits 0.
Fixture `inrow-pins.tsv` pristine/restored SHA-256: `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`.
Fixture `inrow-pins.tsv` mutated SHA-256: `78c45a365d74f607b7f78dbcfa52f4c52e9327744691dddf689ad2c2812cf459`.
Other hashes were identical in pristine, mutated, and restored phases:
- `corpus/sources-census.sh`: `8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a`
- Fixture `corpus/SOURCES.md`: `aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212`
- Fixture `corpus/source-fetches.tsv`: `e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b`
- Fixture `corpus/knowledge/e1.md`: `bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38`
- Fixture `corpus/knowledge/legacy.md`: `399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9`
Restored exact classification bytes before the third detector run; the mutation fired and changed only the intended datum.
Falsifier sought: a lying `non-reproducing` classification accepted as CLEAN, or rejection without the specific verdict finding. Neither occurred.
Bounds: four synthetic rows, one raw-reproducing historical pin, one false verdict, three detector runs. Other C2 cases, real captures, normalizer correctness, C1 and C3 remain untested by this seat.
No production edits beyond this assigned report; no real-tree gate, network, host rows, services, packages, credentials, delegates, or background jobs. No tool installs/updates.
