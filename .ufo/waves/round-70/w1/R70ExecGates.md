Author: R70ExecGates (executor)

# R70ExecGates — harm check: BASE 7bd34832 vs candidate 0d225553

Lane gates run on `git archive` extractions of both revisions in my scratch
(/fast/scratch/hyaku/kagi-r70/R70ExecGates/{base,cand}), each gate run from
inside its tree with stdout / stderr / rc captured separately. No gate mode
that writes into the lane was run. Per-gate results are in `harm.tsv` beside
this report (same directory).

## Results

| gate | BASE | candidate | new failures |
|---|---|---|---|
| `bash corpus/sources-census.sh` | rc 0, `SOURCES_CENSUS: CLEAN (rows=160)` | rc 0, `SOURCES_CENSUS: CLEAN (rows=163)` | none — the +3 rows are the round's own S170/S171/S172 |
| `bash corpus/scope-gate.sh` (default verify) | rc 1, `ADJACENCY_SCOPE: DEFECT (unresolved=1 contested=1 stale_basis=2 breadth_drift=5 …)` | rc 1, byte-identical verdict line | none — pre-existing DEFECT, unchanged |
| `bash corpus/claim-ledger.sh verify` | rc 2, `CLAIM_LEDGER: POLICY (claims=102 policy=5 stamped=173)`, 21 FAIL rows | rc 2, same POLICY verdict, 21 FAIL rows | 3 ids change shape, 2 STALE lines appear (below) |
| `bash corpus/claim-ledger.sh docs` | rc 0, `DOC_AUDIT: CLEAN (entries=49 row_linked=46 … unpinned=0)` | rc 1, `DOC_AUDIT: BROKEN (entries=50 row_linked=47 … unpinned=1)` | **UNPINNED `corpus/knowledge/openbao-pki-certificate-lifecycle.md`** (knowledge entry is not a row in the stamps file) — the new entry landed without its stamp |
| `bash corpus/self-description-sweep.sh` (default mode) | rc 1, `SELF_DESCRIPTION: MISMATCH n=28` (SD6=23) | rc 1, `SELF_DESCRIPTION: MISMATCH n=29` (SD6=24) | **+1 MISMATCH**: `SD6 corpus/knowledge/openbao-pki-certificate-lifecycle.md:11 corpus/lessons/round-70.md (local)` — the landed entry's own `corpus/lessons/round-70.md` §Gate citation is unresolved by the SD6 checker |
| fleet wrapper `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (live lane, post-candidate) | — | `kagi ok …/corpus/SOURCES.md`, 25 W04 duplicate-url warnings including `S170` | none (the duplicate-url warning class is pre-existing; S170 is this round's own row) |

## The three changed ledger ids (the real harm)

`verify` reads POLICY at both revisions (rc 2 — expected per the seat spec), so
the comparison is by failing id list. Sorted-line diff of the two runs shows
only the following changes:

1. **R14-01** (`bash corpus/claim-ledger.sh docs`, expecting `DOC_AUDIT: CLEAN
   (entries=49 … unpinned=0)`): BASE `FAIL … verdict-not-final exit=0`, cand
   `FAIL … exit-mismatch exit=1 want=0`. Direct re-run: BASE docs rc 0 CLEAN
   (49/46/0); cand docs rc 1 BROKEN (50/47/**unpinned=1**), the unpinned entry
   being exactly the round-70 knowledge entry. **This is a genuine regression
   caused by the candidate**: QM61 requires a landing that adds a knowledge
   entry to land on `DOC_AUDIT: CLEAN` with the entry's stamp row in the same
   commit.

2. **R36-01** (`bash plans/round-36-c1.sh`, expecting `^0$`, tmo=300): BASE
   `FAIL … verdict-not-final exit=0`, cand `FAIL … timeout exit=124 tmo=300`.
   Direct re-run of the counter on the candidate tree prints `8` with rc 0 —
   the row still fails (8 ≠ `^0$`) but the failure *shape* changed from
   exit-0-with-wrong-verdict to a 300 s timeout. The candidate moves this
   count (the counter tallies SD5 red-id omissions + stale self-counts); a
   counter that times out inside `verify` is a worse failure mode than a
   quick verdict mismatch.

3. **R36-03** (`bash plans/round-36-c3.sh`, the release-clock gate, expecting
   `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 …)`): the row is **absent**
   from the BASE failure list and `FAIL … exit-mismatch exit=1 want=0` at
   cand. Direct re-run: BASE rc 0 `CLEAN (on_release=32 bound=32 unbound=0 …)`;
   cand rc 1 `FAILED (on_release=34 bound=32 unbound=2 observed=32 …)` with
   `UNBOUND S170` / `UNBOUND S171`. **Genuine regression**: the round added two
   `on-release` registry rows (S170, S171) without bounding their release
   clocks, tripping QM63 ("a landing that adds a registry row runs the
   release-clock gate … an `on-release` row needs a bound release clock in
   the same commit"). Note the S170 row's own `recheck: on-release` line in
   the knowledge entry makes the unbound clock a self-inflicted contradiction.

4. **STALE lines** (cand only, BASE has none):
   `STALE corpus/source-fetches.tsv sha=d5af7ba9e9d7->5d0516e9e2ab lines=203->206`
   and `STALE corpus/SOURCES.md sha=9ca0ffaa3ad0->34d37d9085ed lines=322->325`.
   These are the round's own appended fetch rows — expected to appear whenever
   the fetch registry grows, and consistent with QM14's old→new journal
   discipline being satisfied by the candidate commit itself; recorded here as
   a new-in-cand line class, not a gate failure (they change no verdict).

The 19 other failing ids are identical at both revisions (R11-08, R12-03,
R13-01, R21-02, R22-03, R24-05, R24-06, R24-15, R25-02, R31-02, R33-02,
R34-03, R58-01, R62-01, R62-03, R62-06, R64-01, R68-01 and the 5 POLICY ids
R29-01/R29-02/R38-03/R57-01/R62-04 — count 21 on each side after the three
shape-changes above).

## What is NOT harm

- `scope-gate.sh` DEFECT and the sweep's other 28 MISMATCH lines are
  pre-existing and byte-identical across the two trees.
- Census grows 160 → 163 rows and stays CLEAN; the captured counts are the
  round's admission, not drift.
- The fleet wrapper validates the live lane with no new warning class.

## Evidence notes

- Timing hazards observed while measuring: the two trees' `verify` runs take
  690–800 s (R36-01's 300 s row timeout is inside that); the sweep takes
  ~216 s. Partial outputs from killed/interrupted runs are not evidence —
  every number above is from a run that printed its verdict line and rc.
- Per QM36, the R36-01 and R36-03 reruns are direct executions on the
  candidate tree, quoted with their own rc/output; the BASE comparisons are
  the same commands on the BASE tree.
- No process I started is left running; the scratch dir still holds both
  trees and the captured outputs for the integrating seat to re-read.

## Risks / blockers

- None blocking. The three regressions above are all repairable inside the
  candidate's own scope (a stamps row, a bound release clock or a `NNd`
  cadence, and whichever counter input R36-01 counts that the round moved),
  but as landed, the candidate breaks gates that were green at BASE.

Checks for the main agent: re-run `bash corpus/claim-ledger.sh docs` and
`bash plans/round-36-c3.sh` on the live lane, and `bash corpus/claim-ledger.sh
verify | grep -E 'R14-01|R36-01|R36-03'` after any repair commit.

FINDING GX-1 falsifies-number claim-ledger docs goes CLEAN(49,unpinned=0) at BASE to BROKEN(50,unpinned=1) at candidate: the new knowledge entry has no stamps row (R14-01 shape-changes verdict-not-final to exit-mismatch)
FINDING GX-2 falsifies-number claim-ledger R36-03: release-clock gate CLEAN at BASE, FAILED at candidate with UNBOUND S170/S171 — the round's two new on-release rows carry no bound clock
FINDING GX-3 falsifies-number claim-ledger R36-01: counter reading moves 0-era verdict-not-final to a timeout inside verify (direct rerun prints 8, expect ^0$), a new failure shape on a BASE-red row
FINDING GX-4 neutral self-description sweep gains one mismatch: SD6 flags the landed entry's own corpus/lessons/round-70.md citation as unresolved (n=28 to n=29)
FINDING GX-5 neutral sources-census stays CLEAN on both trees (160 to 163 rows) and scope-gate DEFECT output is byte-identical, no new failures there
SEAT-STATUS: complete harm check executed on both trees, harm.tsv filed
