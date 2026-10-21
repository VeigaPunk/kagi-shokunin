# FCensusNothistorical — bounded C2 mutation probe
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Axes: operability (isolated fixture invocation), freshness (historical-pin boundary), calibration (exact findings, not exit alone).
Result: KILLED; no counterexample to this named fixture at the frozen revision. Severity: no production defect observed.

## Isolation and commands
`L=/home/vgpnk/Projects/shokunin/kagi-shokunin`
`S=/fast/scratch/kagi-r24-recovery/KagiR24-2.FCensusNothistorical-9`
Below, `E` expands to `env -i PATH=/usr/bin:/bin HOME=$S/.empty-home`; detector/hash commands used cwd `$S`.
`E git clone --no-hardlinks "$L" "$S"` → exit 0, clone completed.
`E mkdir -p "$S/.empty-home"`; `E git -C "$S" checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0` → exits 0.
Constructed only `fixture-inrow-not-historical`, matching `base_fixture()` (lines 374–426) plus `m_inrow_not_historical()` (550–552).
Bounds: five registry rows; four fixture captures; one sourced entry, one legacy entry; S017 has 64×`a` pin and a non-reproducing classification, but no capture.
Fixture capture identities were SHA-256 of the existing fixture's literal `id\tstatus\tURL\n` inputs; no network/body recapture.
No full selftest, real-tree verify, host gate, other runtime, install, or sibling edit. Only this report was written in the lane.

## One-datum mutant and expected detector
Scratch `corpus/sources-census.sh:295`: `HIST_RE='^S0(0[1-9]|1[0-6])$'` → `HIST_RE='^S0(0[1-9]|1[0-7])$'`.
This plausible off-by-one admits S017 to the historical exemption; no fixture or other source datum changed during the probe.
`detect-inrow-not-historical.sh` runs `bash corpus/sources-census.sh verify --root fixture-inrow-not-historical` once, capturing combined output.
It returns 0 only for gate exit 1 AND the exact pristine four-line gate output below; otherwise 1.
`E bash detect-inrow-not-historical.sh pristine` → detector exit 0; exact stdout:
```text
PHASE pristine
GATE_EXIT 1
FINDING SC_INROW id=S017 capture-missing
FINDING SC_INROW id=S017 inrow-pin-not-historical
FINDING SC_FETCH id=S017 missing-provenance
SOURCES_CENSUS: FAILED (findings=3 rows=5)
DETECTOR PASS
```
`E bash detect-inrow-not-historical.sh mutated` → detector exit 1; exact stdout:
```text
PHASE mutated
GATE_EXIT 1
FINDING SC_INROW id=S017 capture-missing
SOURCES_CENSUS: FAILED (findings=1 rows=5)
DETECTOR FAIL
```
Restored the single datum immediately, then `E bash detect-inrow-not-historical.sh restored` → detector exit 0; exact stdout:
```text
PHASE restored
GATE_EXIT 1
FINDING SC_INROW id=S017 capture-missing
FINDING SC_INROW id=S017 inrow-pin-not-historical
FINDING SC_FETCH id=S017 missing-provenance
SOURCES_CENSUS: FAILED (findings=3 rows=5)
DETECTOR PASS
```
The baseline is an expected negative fixture, not a failed detector. No SETUP finding or unrelated error occurred.
Mutation fired: historical exemption removed both the specific boundary finding and missing-provenance finding; capture-missing remained.
An exit-only check cannot distinguish these observed runs. Exact findings/count killed this mutant; this is not admission authority.

## Restoration evidence and limits
`E sha256sum corpus/sources-census.sh` (all hash commands exit 0):
Before: `8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a`
Mutant: `266a02f50fb0d985c7e9c8715b36e6d151dd91149f19e39dd3f19894e39ad0c2`
Restored: `8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a` — exact original bytes.
Fixture/detector fingerprint before and after: `b940555b6c83094d54e74b0cc49b03074d037b329d3a4129df606f961dff3639`.
Fingerprint command: `E sha256sum fixture-inrow-not-historical/corpus/{SOURCES.md,source-fetches.tsv,inrow-pins.tsv,knowledge/e1.md,knowledge/legacy.md} detect-inrow-not-historical.sh | E sha256sum`.
Falsifier: widened S017 exemption retaining the exact three findings would survive this detector; observed output instead changed to one finding.
C1 host-policy behavior, other C2 cases/normalization/captures, and C3 membership populations remain untested by this seat.
Tools installed/updated: none.
