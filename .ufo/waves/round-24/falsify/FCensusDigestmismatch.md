# FCensusDigestmismatch — bounded C2 mutation probe

Axes: operability / freshness / calibration. Author-side evidence, not admission authority.
Frozen revision observed by `git rev-parse HEAD`: `c5ef9e92201b6c36396301f12b23740565bf86a0` (exit 0).
Original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`; BASE was not executed.
Sandbox/CWD: `/fast/scratch/kagi-r24-recovery/FCensusDigestmismatch-9`.
Evidence read: `plans/round-24.md`; `corpus/sources-census.sh` (fixture 374–425, guard 306, case 629).

## Isolation and construction
Executed (exit 0; clone completed and checkout reported `HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusDigestmismatch-9/empty-home /bin/bash --noprofile --norc -c 'git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FCensusDigestmismatch-9 && mkdir -p /fast/scratch/kagi-r24-recovery/FCensusDigestmismatch-9/empty-home && git -C /fast/scratch/kagi-r24-recovery/FCensusDigestmismatch-9 checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0'
```
Created only `fixture/corpus/{SOURCES.md,source-fetches.tsv,inrow-pins.tsv,knowledge/e1.md,knowledge/legacy.md}` plus the existing-shape empty lessons directory.
Used the existing four-row base fixture and raw-reproduction control: S001 registry pin and capture raw digest = 64 `a`; normalized digest = 64 `1`; classification date `2026-10-19`, verdict `reproduces-raw`, note `selftest`.
Capture identity digests were independently computed with `printf 'ID\tSTATUS\tURL\n' | sha256sum` for each of the four literal fixture rows, under the isolated environment.
Mutant: change ONLY classification field 2's first byte from `a` to `7` (remaining 63 bytes `a`). Registry pin, capture evidence, date, verdict and every other file stayed unchanged. This is the named digest-mismatch condition with a one-byte transcription defect.

## Same bounded detector, three byte states
Exact command below was executed once per state, from the sandbox CWD:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusDigestmismatch-9/empty-home /usr/bin/timeout 15s /bin/bash corpus/sources-census.sh verify --root fixture
```
Expected: pristine/restored exit 0 and identical CLEAN line; mutant exit 1, exactly `FINDING SC_INROW id=S001 inrow-digest-mismatch`, findings=1. CLEAN mutant, wrong finding, or setup failure would falsify/invalidate this probe.
Pristine: exit 0; stderr empty; exact stdout:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Mutated: exit 1; stderr empty; exact stdout:
```text
FINDING SC_INROW id=S001 inrow-digest-mismatch
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored: exit 0; stderr empty; exact stdout:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```

## Hash and restoration evidence
At each state, executed (exit 0):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FCensusDigestmismatch-9/empty-home /usr/bin/sha256sum fixture/corpus/SOURCES.md fixture/corpus/source-fetches.tsv fixture/corpus/inrow-pins.tsv fixture/corpus/knowledge/e1.md fixture/corpus/knowledge/legacy.md corpus/sources-census.sh
```
SHA-256 of `fixture/corpus/inrow-pins.tsv`:
- Before:   `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`
- Mutated:  `d81c3e470b860c182e8f3db978315a42f6c18eb362595a02e860fa700362c421`
- Restored: `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`
Other file hashes, identical before/mutated/restored (paths relative to sandbox):
```text
aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212  fixture/corpus/SOURCES.md
e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b  fixture/corpus/source-fetches.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  fixture/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  fixture/corpus/knowledge/legacy.md
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh
```
Verdict: **KILLED / PASS for this input mutant**. Changed hash proves the mutation fired; the precise SC_INROW finding, clean controls and exact restored hashes exclude an unrelated setup failure. Severity: no defect demonstrated within this bound.
Observed bounds: three fixture-only census runs, four synthetic registry rows, four captures, one classified historical pin; no full selftest, real-tree gate, network, account, vault, CDP, host-row override, delegation or background job. Wider recapture/normalization claims and C1/C3 are untested here. Production code untouched; the only lane write is this report. No tools installed or updated.
