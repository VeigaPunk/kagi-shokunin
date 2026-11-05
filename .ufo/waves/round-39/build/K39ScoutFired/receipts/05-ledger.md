# 05 — claim-ledger verify and census: BASE vs candidate (regression inventory)

## claim-ledger verify (exit 2, POLICY), BASE overlay vs candidate
BASE (06144518) FAIL rows:
  FAIL R11-08 reason=exit-mismatch exit=1 want=0
  FAIL R22-03 reason=exit-mismatch exit=2 want=0
  FAIL R24-15 reason=exit-mismatch exit=2 want=0
  FAIL R25-02 reason=exit-mismatch exit=2 want=0
  POLICY R29-01, POLICY R29-02, POLICY R38-03
  CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)
Candidate (6742fde) FAIL rows:
  FAIL R11-08, R13-01, R21-02, R22-03, R24-06, R24-15, R25-02, R31-02, R33-02, R34-03, R36-01
  POLICY R29-01, POLICY R29-02, POLICY R38-03
  CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)
=> The candidate adds SEVEN newly-failing ledger rows at BASE-passing status:
   R13-01, R21-02, R24-06, R31-02, R33-02, R34-03, R36-01.
   R13-01/R24-06/SCORECARD-round-count and the four census rows are count-expectation rows the
   round-39 lesson declares as "not appended in round 39 … that rebinding is its own round-38-style
   migration" (a named gap, not a silent regression) — but R36-01 is a DIFFERENT class:
   it is the round-36 self-description counter row, and its failure is caused by the candidate's
   own SCORECARD edit, not by an unbound count.

## R36-01 in detail — the candidate's SCORECARD breaks a self-description counter row
  R36-01  bash plans/round-36-c1.sh   expectation ^0$
  BASE overlay : 0
  candidate    : 3
  The counter reads SD5 (red ids on the lane-status line that are absent from the calibration row
  of the LATEST '## Round' section) + the self-counts stale count. The lane-status line still
  declares 3 routed reds (R25-02, R29-01, R29-02). At BASE the latest section is
  '## Round 38 — post-move', whose calibration row names all three reds. The candidate's new
  '## Round 39 — post-move' calibration row (SCORECARD.md:1490) names NONE of them, so SD5 = 3.
  Measured SD5 detail at the candidate:
    MISMATCH SD5 SCORECARD.md:14 red id 'R25-02' is absent from the latest calibration row (SCORECARD.md:1490)
    MISMATCH SD5 SCORECARD.md:14 red id 'R29-01' is absent from the latest calibration row (SCORECARD.md:1490)
    MISMATCH SD5 SCORECARD.md:14 red id 'R29-02' is absent from the latest calibration row (SCORECARD.md:1490)
  Round-38's own lesson records this exact failure mode (M38-5) and round-38's calibration row
  named the reds precisely to keep the counter at 0. The round-39 candidate repeats the omission.

## self-description sweep, BASE overlay vs candidate
  BASE overlay : SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=0 SD8=0 SD9=0)
                 SD6 rows: corpus/lessons/round-30-verifier-spotcheck.md:41, round-32…:54, round-33…:90
  candidate    : SELF_DESCRIPTION: MISMATCH n=8 (… SD5=3 SD6=5 SD7=0 SD8=0 SD9=0)
                 SD6 rows: SCORECARD.md:1493 .ufo/waves/round-39/expectation-migrations.json (ufo)
                            SCORECARD.md:1494 .ufo/waves/round-39/build/ (ufo)
                            + the three BASE verifier rows
=> The plan (plans/round-39.md:21) states the BASE reading as
   "SELF_DESCRIPTION: MISMATCH n=3 (SD6=3), all three SD6 rows inside verifier-owned
    spot-check files (round-30, round-32, round-33); not lane-owned, not claimed" and
   "bash plans/round-36-c1.sh reads 0". Both are exactly what I measured at BASE — so the
   plan's BASE statements are TRUE. What the plan does not record is that the candidate
   moves both readings: SD6 3->5 (two NEW lane-owned unresolved citations, both pointing at
   paths that do not exist at the candidate) and round-36-c1 0->3.
   The two new SD6 rows are the candidate's own citations:
     SCORECARD.md:1493  .ufo/waves/round-39/expectation-migrations.json  (ufo)  — absent at the candidate
     SCORECARD.md:1494  .ufo/waves/round-39/build/                      (ufo)  — absent at the candidate
   (`git ls-tree -r 6742fde -- .ufo/waves/round-39` lists only .ufo/waves/round-39/capture/S094.body;
    the expectation-migrations.json and the build/ dir are absent at the candidate commit. The
    round-38 candidate did commit .ufo/waves/round-38/expectation-migrations.json, so the
    round-39 candidate drops a file its own SCORECARD cites.)
   Note: SD6 is explicitly excluded from the round-36 counter's population ("The non-owned SD6
   class is NOT part of this reading"), and the lane-status SD6 rows are verifier-owned, but
   these two NEW rows are lane-owned and are introduced by this round's candidate.

## census, BASE overlay vs candidate
  BASE overlay : SOURCES_CENSUS: CLEAN (rows=93 A=89 B=2 C=2 queued=1 mined=89 rejected=3 entries_sourced=14 legacy=21 captures=93 inrow=16 inrow_only=0 inrow_nonreproducing=12)  rc 0
  candidate    : SOURCES_CENSUS: CLEAN (rows=94 A=90 B=2 C=2 queued=1 mined=90 rejected=3 entries_sourced=14 legacy=21 captures=94 inrow=16 inrow_only=0 inrow_nonreproducing=12)  rc 0
=> The candidate is CLEAN at rows=94 (A 89->90, mined 89->90, captures 93->94) because S094 is
   tier-A own-work. The plan's frontier step says "expected rows=94 with S094 (own-work),
   entries_sourced unchanged" — the measured value matches, and entries_sourced stays 14.
   The plan's "Census before (START, this round)" receipts are named as
   /fast/scratch/hyaku/kagi-r39/l1/census/start-fleet.txt and start-lane.txt "copied to the wave
   dir": the scratch files exist and read as claimed (start-lane.txt reads rows=93 …; start-fleet.txt
   reads 'kagi W04 …' 19 W04 lines and ends 'kagi ok <lane>/corpus/SOURCES.md'), but
   .ufo/waves/round-39/census/ in the working tree is EMPTY and nothing under
   .ufo/waves/round-39/ is tracked at the candidate except capture/S094.body — so the "copied to
   the wave dir" half of that statement is not yet true at the candidate commit (round-38's
   candidate DID commit .ufo/waves/round-38/controls/start-census-*.txt).

## Plan's kill rule: "The lane's bash corpus/sources-census.sh not CLEAN at landing -> C1 unmet"
  satisfied: candidate census rc 0 and CLEAN.
