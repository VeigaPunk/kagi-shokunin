# 02 — the two instruments on the candidate tree (kill rules)

  $ cd $S/ext && bash corpus/anchor-pins.sh --root .
      ANCHOR_PINS: CLEAN (pins=3)          rc 0
  $ cd $S/ext && bash corpus/claims-declared.sh --root .
      CLAIMS_DECLARED: CLEAN (claims=2)     rc 0
=> C1 kill rule 1 and C2 kill rule 1 both satisfied at the candidate.

## Pins are computed from the BASE anchor cells (plan: "computed from the claim BASE registry")
sha256 of the whitespace-trimmed column-6 cell of each BASE row vs corpus/anchor-pins.tsv:
  S034  base cell 'Entry titled v2.2.0, tag link /releases/tag/v2.2.0, updated 2026-10-15T18:50:14Z; feed fetched 2026-10-21'
        sha256 5e10a867bd3954bd1d771d4f1efc96197edd8dceee66f43933095db96d443811  == pin  MATCH
  S035  base cell 'Entry titled v2.7.1, tag link /releases/tag/v2.7.1, updated 2026-10-01T18:32:18Z; feed fetched 2026-10-21'
        sha256 0ddd47c09377c066d75f6912e643246e742853c9746d73953e7482551683d33a  == pin  MATCH
  S039  base cell 'Python 3.15.1 item, pubDate Wed, 21 Oct 2026 09:59:50 +0000; fetched 2026-10-21'
        sha256 772e58b25951bca52d8e5ac195906a8b7411be224bb8f02634cf71167fef4230  == pin  MATCH
=> the three pins are exactly the BASE anchor-cell digests; the pin file is not a re-derivation
   of the candidate tree (the candidate's S034/S035/S039 anchor cells are byte-identical to BASE:
   the only corpus/SOURCES.md change BASE->candidate is the added S094 row).

## Column index used by the gate vs the plan's wording
corpus/anchor-pins.sh extracts the anchor with awk field $7 of the '|'-split row
(the row starts with '|', so $1 is empty, $2=id, $7=anchor). Verified independently: a
rewrite of column 7 alone (anchor) is detected; a rewrite of column 8 alone (teaches) is NOT.
  anchor-cell-only rewrite (col 7)  -> DRIFT S034 / ANCHOR_PINS: DRIFT (pins=3 drift=1)  rc 1
  teaches-cell-only rewrite (col 8)  -> ANCHOR_PINS: CLEAN (pins=3)                        rc 0
=> the gate binds the anchor cell (column 7), as the plan's "column 6" wording means
   (1-indexed after the leading '|': id=1, source=2, kind=3, tier=4, scope=5, anchor=6).
