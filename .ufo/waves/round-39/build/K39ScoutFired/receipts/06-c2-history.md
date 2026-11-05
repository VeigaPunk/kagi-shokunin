# 06 — C2 gate: what it actually covers, and the round-38 relabel

## The gate reads the manifest, the plan heading and ONE tagged SCORECARD row
corpus/claims-declared.sh (candidate, 70 lines):
  manifest  "$root/corpus/claims-declared.tsv"   (round, claim, axis)
  plan      grep -qF -- "## $claim — $axis:" "$root/plans/round-$round.md"
  scorecard the LAST '## Round <round> — post-move' section, rows containing "[$claim]",
            first cell must equal $axis; exactly one such row required
  exits 0 CLEAN / 1 MISMATCH / 2 SETUP
The manifest at the candidate has exactly two rows (39 C1 freshness, 39 C2 calibration) ->
CLAIMS_DECLARED: CLEAN (claims=2).

## The gate's scope over the round-38 history is exactly what the plan's ceiling says
Adding a round-38 manifest row to a copy of the candidate tree (38 C2 calibration):
  MISMATCH 38 C2 tagged-rows-0
  CLAIMS_DECLARED: MISMATCH (claims=3 mismatch=1)   rc 1
Reason: round-38's SCORECARD post-move rows carry NO '[C2]' tag (I verified: `git show
06144518:SCORECARD.md | grep '\[C2\]'` -> no hits; the round-38 rows use bare 'C2 ...' text).
So the gate, run over history, reports the MISSING TAG, not the axis relabel.

## The relabel itself IS detectable once the row is tagged
Same tree, but I tagged the round-38 operability row '[C2]' (a cell the lane never wrote):
  MISMATCH 38 C2 scorecard-axis-operability-not-calibration
  CLAIMS_DECLARED: MISMATCH (claims=3 mismatch=1)   rc 1
=> The gate's axis comparison is correct and would have caught CD-1 (C2 declared calibration,
   reported under operability) on a TAGGED row. Round 38's rows are untagged, which is why
   the gate cannot see them — the plan's ceiling states this ("it cannot detect an untagged
   relabel of a row that was never tagged"). Confirmed, not falsified.

## The gate cannot see an axis relabel that is not tagged, in the CURRENT round either
The counter's X3 mutant ("the tag removed from a claim row") is the only X-mutant that tests
the untagged case, and it is detected (rows != 1 -> MISMATCH tagged-rows-0). But an untagged
row that is merely RELABELLED (axis cell changed, tag still absent, count still != 1) is
reported under the same tagged-rows-0 reason. The reason string does not distinguish
"tag missing" from "axis changed" when both hold.
