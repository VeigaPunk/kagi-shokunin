# 07 — plan / lesson provenance audit (incorrect provenance or history)

Each item below was checked against the committed bytes, not against the plan's own wording.

## P1 — the plan's round-38 close description is wrong about WHAT the closure said
  plans/round-39.md:9-13 "Round 38 closed as `verifier-spotcheck` … C1 verified (located-quote
  0 -> 5), C2 not verified as declared because its axis was calibration in the plan and
  operability in the SCORECARD (CD-1, CD-2)."
  VERIFIED: corpus/lessons/round-38-verifier-spotcheck.md:26-27 states CD-1 (declared axis
  calibration, relabelled operability after the counter read 3) and CD-2 (lane self-verdict
  "verified as operability"), and :49 "C1 verdict: verified. Measured 0 -> 5".
  => The plan's account of the round-38 closure is ACCURATE.

## P2 — "Not a fresh-start round: round 36, 37 and 38 closed `ok`; no rejected closure in the
##      last three." — CONTRADICTED by the fleet manifest
  plans/round-39.md:19 "Not a fresh-start round: round 36, 37 and 38 closed `ok`; no rejected
  closure in the last three." (repeated at corpus/lessons/round-39.md:8 "Rounds 36, 37 and 38
  closed `ok` (`MANIFEST.json` rounds 1321, 1328 and the round-36 entry)")
  MEASURED (/home/vgpnk/Projects/shokunin/MANIFEST.json, rounds[] array):
     index 1298  round 36  kagi  verdict = rejected-honest-stop  admitted = False
     index 1321  round 37  kagi  verdict = admitted
     index 1328  round 38  kagi  verdict = rejected-honest-stop  admitted = False
  => Two of the three named closures (36 and 38) were REJECTED, not "ok". The manifest's own
     `lanes: {kagi: ok}` field is the lane-side status and is what the lane's prose appears to
     have read as the closure verdict. The conclusion ("not a fresh-start round") still holds on
     the manifest's own numbers only because the rule counts three CONSECUTIVE rejected closures
     and 37 was admitted between them; but the sentence as written ("no rejected closure in the
     last three") is false against the fleet record. This is a provenance error in the frozen
     plan and in the candidate lesson that repeats it.

## P3 — the plan's release-clock paragraph attributes the fired-clock families correctly
  plans/round-39.md:23-25 "The 15 fired clocks sit on Vault (S034 family,
  S012/S013/S022–S024), OpenBao (S035 family, S014–S016/S021/S025/S026) and Python
  (S036/S039 family, S027/S028/S040/S041)."
  MEASURED from corpus/release-clocks.tsv: exactly those ids, and the feed families are
  S034 (5), S035 (6), S036 (2), S039 (2) = 15.
  => ACCURATE (and the round-38 lesson's "10 DERIVATION findings" also reproduces exactly).

## P4 — the plan's claim that the SD6 class is "not lane-owned" is true at BASE but the
##      candidate adds two lane-owned SD6 rows (see 05-ledger.md)
  plans/round-39.md:21 "all three SD6 rows inside verifier-owned spot-check files
  (round-30, round-32, round-33); not lane-owned, not claimed."
  VERIFIED for BASE (exactly those three rows). At the candidate the sweep's SD6 = 5 and two of
  them are this round's own SCORECARD citations to files absent at the candidate.
  => The BASE statement is accurate; the candidate changes the population without recording it.

## P5 — the plan's Frontier census receipts: "copied to the wave dir" is not true at the candidate
  plans/round-39.md (Frontier step) names /fast/scratch/hyaku/kagi-r39/l1/census/start-fleet.txt
  and start-lane.txt and says "(copied to the wave dir)". The scratch files exist and read as
  claimed, but .ufo/waves/round-39/census/ is empty in the working tree and
  `git ls-tree -r 6742fde -- .ufo/waves/round-39` lists only capture/S094.body.
  Round-38's candidate DID commit .ufo/waves/round-38/controls/start-census-*.txt.
  => The receipt copy is outstanding at the candidate (the plan's own words imply it is done).

## P6 — the plan's census-after expectation vs the ledger rows it names
  plans/round-39.md:37 "Census after: recorded at the landing revision; expected rows=94 with
  S094 (own-work), entries_sourced unchanged."
  MEASURED: census at the candidate reads rows=94 A=90 mined=90 captures=94, entries_sourced=14 —
  matches. But the four census ledger rows (R21-02, R31-02, R33-02, R34-03) still expect
  rows=93/captures=93 and now FAIL (see 05). The lesson names the counter-rows gap
  ("Ledger rows for the round-39 counters … are not appended in round 39") but not these four
  census rows, which the SCORECARD's own coverage row claims as "(migrated,
  `.ufo/waves/round-39/expectation-migrations.json`)" — a file that does not exist at the candidate.
  => SCORECARD.md:1496 cites a migration file that is not committed, and the rows it names are
     failing, not migrated.

## P7 — the candidate lesson's "Fresh-start check" repeats the same history error
  corpus/lessons/round-39.md:8 "Rounds 36, 37 and 38 closed `ok` (`MANIFEST.json` rounds 1321,
  1328 and the round-36 entry); the last-three window holds no rejected closure."
  MEASURED: rounds[1328].verdict = "rejected-honest-stop" (round 38) and rounds[1298].verdict =
  "rejected-honest-stop" (round 36).
  => FALSE as written, in both the frozen plan and the candidate lesson.

## P8 — the plan's routing of R38-D2
  plans/round-39.md (Routed, not claimed) lists R38-D3, D4, D5, D6/D5, R37-V4, R38-EG-1 — but
  NOT R38-D2 ("report wording … Remove 'frozen predicates … not amended after data' or name
  the C2 axis relabel as an amendment (CD-1); replace the lane's self-verdict on C2 with the
  claim-as-declared reading (CD-2)"), which the round-38 closure lists as item 2
  (corpus/lessons/round-38-verifier-spotcheck.md:97).
  The candidate LESSON does table R38-D2 (corpus/lessons/round-39.md, sweep table row
  "R38-D2 (report wording "not amended after data"; self-verdict on C2) | Report for this round
  names no self-verdict on any claim beyond the measured counters, and states the relabel of
  round 38 as an unrecorded mismatch").
  => The frozen plan's routed list omits D2; the lesson covers it. Plan/lesson asymmetry, not a
     false statement in the lesson.

## P9 — the plan's claim about the round-37 counter and in-place anchor rewrites
  plans/round-39.md:26-29 "Registry anchor cells of the superseded feed rows S034, S035 and S039
  are the only anchors the round-37 counter (`plans/round-37-c2.sh`) cannot see changing in
  place: that counter only asks whether *some* current row exists (S089–S091), so a rewritten
  superseded anchor reads unchanged".
  MEASURED: round-37-c2.sh reads 0 before AND after each of the three mutants (M1/M2/M3) — the
  blindness claim holds for S034/S035/S039.
  BUT the word "only" is wrong: S036 is ALSO a superseded feed anchor cell (S039's anchor cell
  says "supersedes S036"), and rewriting S036's anchor cell (Python 3.15.0 -> 3.15.2) also reads
  0 on round-37-c2.sh, is invisible to anchor-pins.sh (not pinned), and leaves release-clock.py
  CLEAN. See defect D1 in the report.
  => The mechanism is right; the enumeration is incomplete.
