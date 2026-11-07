# R55ExecHarm — harm check: full ledger verify BASE vs candidate + citation set

Seat: R55ExecHarm (kagi round 55, attempt 1). Scope: harm check only (no edits to lane files; no subagents).
Revisions (from `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse`):
- BASE: ebe095857a734caf5efdd7bd776feb22b4e23972
- CANDIDATE: 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f
Clones: `git clone -q --shared` into $HYAKU_SCRATCH default /fast/scratch/hyaku/kagi-r55/R55ExecHarm/{base,cand}; checkout asserted; `rev-parse --show-toplevel` = clone dir for both.

## Verdict: HARM = NONE
No row changed verdict between BASE and candidate. The candidate adds no FAIL/POLICY/STALE, no MISSING-ID, no HOST-SKIP change, and no new UNRESOLVED citation (M54-6 satisfied). The only differences are the REV header and the citation-doc counts (cites 3928 -> 3957, docs 136 -> 137, from the new lesson/entries).

## Receipts (all in .ufo/waves/round-55/build/R55ExecHarm.d/)
| Check | Rev | Exit | Final line |
|---|---|---|---|
| verify | BASE ebe095857a734caf5efdd7bd776feb22b4e23972 | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)` |
| verify | CAND 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)` |
| citations | BASE | 1 | `CITATION_GATE: BROKEN (cites=3928 docs=136 unresolved=6 ephemeral=0 labeled=40)` |
| citations | CAND | 1 | `CITATION_GATE: BROKEN (cites=3957 docs=137 unresolved=6 ephemeral=0 labeled=40)` |
| expect-journal (CAND, base tsv -> cand tsv, journal = round-55 expectation-migrations.json only) | CAND | 0 | `EXPECT_JOURNAL: CLEAN (changed=8 journaled=8)` |
| self-counts | CAND | 2 | `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` |
| self-counts | BASE | 2 | identical POLICY lines (diff exit 0) |

Diff receipts: verify-ids-diff-…txt, citations-diff-…txt, self-counts-compare-…txt, clones-…txt.

## Id-set diff (verify)
- FAIL/POLICY/STALE set, BASE == CAND (diff exit 0):
  - FAIL R11-08 (exit-mismatch exit=1 want=0)
  - FAIL R25-02 (exit-mismatch exit=2 want=0)
  - FAIL R36-01 (timeout exit=124 tmo=300)
  - POLICY R29-01, R29-02 (first-token:python), POLICY R38-03 (python-script)
  - STALE: none
- MISSING-ID count: 57 BOTH (diff exit 0)
- HOST-SKIP id set: identical (diff exit 0)
- Full 106-line verify receipts differ only on the REV header line.

## Citation set (UNRESOLVED), BASE == CAND (diff exit 0)
- corpus/lessons/round-30-verifier-spotcheck.md:41 -> corpus/README.md:64/65/67 (local)
- corpus/lessons/round-32-verifier-spotcheck.md:54 -> corpus/README.md:64/65/67 (local)
- corpus/lessons/round-33-verifier-spotcheck.md:90 -> knowledge/corpus/knowledge/ (shorthand)
- corpus/lessons/round-51-verifier-spotcheck.md:72 -> corpus/plans/.ufo (local)
- corpus/lessons/round-54-verifier-spotcheck.md:55 -> corpus/json.py (local)
- corpus/lessons/round-54-verifier-spotcheck.md:55 -> corpus/hashlib.py (local)
- Layout: CITATION_LAYOUT lone-clone fleet_absent=187 (both). Fleet-only citations were NOT checked in either clone.

## R11-08 (named in assignment)
Row command = `bash corpus/claim-ledger.sh citations`, expect `^CITATION_GATE: CLEAN (… unresolved=0 …)` exit 0. It FAILS on BOTH BASE and CAND with exit-mismatch (exit=1, want=0), because the clone has unresolved=6 (above). This is pre-existing (identical on BASE), not introduced by round 55. Caveat: the lone-clone layout means fleet-only citations are unchecked; a fleet-checkout run could differ and was not measured by this seat.

## Interpretation caveats (what this does NOT prove)
- Verify and citations were run on clean clones (lone-clone layout); the R11-08 FAIL and the six UNRESOLVED are the same on both revs, so they are not a round-55 harm, but they are not resolved here.
- Each full verify took ~11 min (BASE 656s, CAND 679s); an R36-01 per-row timeout (tmo=300) is a BASE and CAND result alike.
- The live leg named in the milestone was not run by this seat (assignment scope = harm check only).

## Tools / installs
None installed; no PATH or ~/.local/bin changes. Used repo scripts only, with explicit HOME untouched.

SEAT-STATUS: complete
