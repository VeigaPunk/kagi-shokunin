# FCensusCapturemissing — bounded mutation probe

Axes: operability, freshness, calibration; direct target: C2 freshness.
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (observed checkout/HEAD).
Original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (context only; not executed).
Sandbox S: `/fast/scratch/kagi-r24-recovery/FCensusCapturemissing-9`.
HOME H: `$S/empty-home`; fixture F: `$S/probe-inrow-capture-missing`.
All executed binaries received `env -i PATH=/usr/bin:/bin HOME=<sandbox HOME>`.
No installs, network, host-reading gates, delegates, background jobs, or production edits.

## Construction and detector
Clone command (HOME was the empty S directory before clone):
`env -i PATH=/usr/bin:/bin HOME="$S" /usr/bin/git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin "$S"`
Checkout command (cwd S, HOME H):
`env -i PATH=/usr/bin:/bin HOME="$H" /usr/bin/git -c advice.detachedHead=false checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0`
Observed clone/checkout exit 0; `git rev-parse HEAD` printed the frozen revision above.
Fixture independently written from `base_fixture` (lines 374–426), plus the S001 raw-pin/control shape (lines 533–538).
Bounds: four registry rows; one sourced entry; one legacy entry; one historical pin/classification; captures 4 → 3 → 4.
Only mutation: cut the complete S001 provenance datum (first TSV row) from F/corpus/source-fetches.tsv.
S001's registry pin and matching `2026-10-19 reproduces-raw` classification remained unchanged.
Expected detector: exit 1, exactly `FINDING SC_INROW id=S001 capture-missing`, findings=1; no setup failure or unrelated finding.
Same command for all three states (cwd S; timeout 30 seconds per invocation):
`env -i PATH=/usr/bin:/bin HOME="$H" /usr/bin/bash corpus/sources-census.sh verify --root "$F"`

## Actual output
Pristine control — exit 0:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
Mutated fixture — exit 1:
```text
FINDING SC_INROW id=S001 capture-missing
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```
Restored fixture — exit 0:
```text
SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1 entries_sourced=1 legacy=1 captures=4 inrow=1 inrow_only=0 inrow_nonreproducing=0)
```
No additional detector output was observed. Mutation inspection showed only S002, S003, S004 capture rows.

## Hashes and exact restoration
Hash command, cwd F, before/mutated/restored:
`env -i PATH=/usr/bin:/bin HOME="$H" /usr/bin/sha256sum corpus/SOURCES.md corpus/source-fetches.tsv corpus/inrow-pins.tsv corpus/knowledge/e1.md corpus/knowledge/legacy.md`
source-fetches.tsv before: `e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b`
source-fetches.tsv mutated: `2fd176bf4d63735412a2bd90ec115e3da7678a94b6391544d6f6e6cb9510c2c9`
source-fetches.tsv restored: `e2022d4a4842a7e8cc94856fb01a09a04be841db7b7753909d5df039984c218b`
The original row was restored from the edit tool's captured register; all other fixture hashes stayed identical in all three states:
- SOURCES.md: `aa968e6765d3cc195215f5b8a3ef057ef9bceefd8a1e0779e14942381c6f8212`
- inrow-pins.tsv: `56a8dcab6f4a0843f7fd6a43634c4263e2cc7220682a8a4421c4332809b8e24d`
- knowledge/e1.md: `bc06900e855084d94f90b37721f3a9c5abb71c1c1ab6c0222571171ff8c88c38`
- knowledge/legacy.md: `399d703d8c64b2819a0a5e7cd72deafd2c7a437bdbfbca94cd761cc7dc9f44c9`
Sandbox census script before/after (`sha256sum corpus/sources-census.sh`, cwd S, same isolated environment):
`8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a`

Verdict: **KILLED** — the independently removed capture triggered the exact assigned finding; pristine/restored controls passed.
Severity: no defect observed within this probe; no admission or whole-claim judgment.
Falsifier sought: CLEAN/exit 0 after removing S001 capture, a missing/wrong finding, or failure caused only by setup/unrelated checks. None occurred.
Unknown outside bounds: real-tree provenance, live recapture/normalizer behavior, C1 host safety, C3 membership counts, and other census cases.
Report: `.ufo/waves/round-24/falsify/FCensusCapturemissing.md`
