# FCensusNormalizedcontrol — C2 inrow-normalized-control
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Axes: operability (isolated execution), freshness (classification recomputed from capture), calibration (one targeted finding).
Result: PASS for this bounded probe; evidence mutant KILLED. Severity: none observed within this fixture; no counterexample found here.
Bounds: one named positive control, one datum changed, three fixture-only census executions; 4 registry rows, 4 captures, 1 in-row classification.
Evidence read: plans/round-24.md and corpus/sources-census.sh; frozen fixture helpers at lines 374–428/532–540, expectation at 626.
Constructed only the existing base_fixture + m_inrow_norm_ok shape under the unique scratch clone; synthetic digests, no fetch/network activity.
Mutant: S001 source-fetches.tsv field 15 changed from 64 `1` digits to `9` followed by 63 `1` digits (one byte); raw digest, registry pin and classification untouched.
Expected detector: pristine/restored exit 0 CLEAN_INROW; mutant exit 1 with exactly `SC_INROW id=S001 verdict=reproduces-normalized capture-says=non-reproducing`.
Observed: exactly that transition; no SC_FETCH, SETUP or unrelated finding. Mutation fires as shown by changed capture hash and classification finding.
C1/C3 contracts, real captures, the normalizer itself and complete C2 claim remain untested/UNKNOWN; this is author-side evidence, not admission authority.

Command notation: S=/fast/scratch/kagi-r24-recovery/FCensusNormalizedcontrol; F=probe/inrow-normalized-control; execution cwd=$S.
Clone preparation (exit 0): `env -i PATH=/usr/bin:/bin HOME=$S-home mkdir -p $S-home`; `env -i PATH=/usr/bin:/bin HOME=$S-home git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin $S`; `env -i PATH=/usr/bin:/bin HOME=$S-home git -C $S checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0`.
Checkout stdout: `HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`.
Created empty $S/home and $F/corpus/lessons with env-isolated mkdir (exit 0); fixture files created using write, one-byte mutation/restoration using edit.
Hash command H (each phase): `env -i PATH=/usr/bin:/bin HOME=$S/home sha256sum corpus/sources-census.sh $F/corpus/SOURCES.md $F/corpus/source-fetches.tsv $F/corpus/inrow-pins.tsv $F/corpus/knowledge/e1.md $F/corpus/knowledge/legacy.md`.
Detector D (identical each phase): `env -i PATH=/usr/bin:/bin HOME=$S/home bash corpus/sources-census.sh verify --root probe/inrow-normalized-control`.
Each phase executed H && D; exact stdout follows. Stderr was empty for all three detector executions.

Pristine — exit 0:
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh
9dd4c67deabd8d17c2b04a0cfde78bfa39f5f8f5f44014f5a00344784cbc0d66  probe/inrow-normalized-control/corpus/SOURCES.md
e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b  probe/inrow-normalized-control/corpus/source-fetches.tsv
53ee07f4d7ce823ff327b904667b54012574f855b78b084ae9d4ab8bb6acfbf9  probe/inrow-normalized-control/corpus/inrow-pins.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  probe/inrow-normalized-control/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  probe/inrow-normalized-control/corpus/knowledge/legacy.md
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Mutated — exit 1:
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh
9dd4c67deabd8d17c2b04a0cfde78bfa39f5f8f5f44014f5a00344784cbc0d66  probe/inrow-normalized-control/corpus/SOURCES.md
29de71b9a4b11bd9de36f501d2eeed1100f985e1e4f7b9d037296ffad7584f45  probe/inrow-normalized-control/corpus/source-fetches.tsv
53ee07f4d7ce823ff327b904667b54012574f855b78b084ae9d4ab8bb6acfbf9  probe/inrow-normalized-control/corpus/inrow-pins.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  probe/inrow-normalized-control/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  probe/inrow-normalized-control/corpus/knowledge/legacy.md
FINDING SC_INROW id=S001 verdict=reproduces-normalized capture-says=non-reproducing
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored — exit 0:
```text
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh
9dd4c67deabd8d17c2b04a0cfde78bfa39f5f8f5f44014f5a00344784cbc0d66  probe/inrow-normalized-control/corpus/SOURCES.md
e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b  probe/inrow-normalized-control/corpus/source-fetches.tsv
53ee07f4d7ce823ff327b904667b54012574f855b78b084ae9d4ab8bb6acfbf9  probe/inrow-normalized-control/corpus/inrow-pins.tsv
bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38  probe/inrow-normalized-control/corpus/knowledge/e1.md
399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9  probe/inrow-normalized-control/corpus/knowledge/legacy.md
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Restoration evidence: all five fixture file hashes and unchanged census hash match pristine exactly; source-fetches.tsv returned to e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b.
Cleanup: `env -i PATH=/usr/bin:/bin HOME=$S/home rmdir $S-home` exited 0, no output (temporary clone HOME was empty).
Production edits: none; only this assigned report written on the lane. No complete selftest, real-tree verify, ledger cells, host rows, delegates or background jobs.
Tool installs/updates: none. Probe stopped after restoration.
