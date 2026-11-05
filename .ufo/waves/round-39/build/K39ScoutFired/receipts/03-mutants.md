# 03 — the three frozen C1 mutants, and what each gate sees

Each mutant is one sed on one SOURCES.md row of the candidate tree (as plans/round-39-c1.sh does):
  M1  S034  v2.2.0 -> v2.2.1      (sed '/^| S034 |/ s/v2\.2\.0/v2.2.1/g')
  M2  S035  v2.7.1 -> v2.7.2      (sed '/^| S035 |/ s/v2\.7\.1/v2.7.2/g')
  M3  S039  Python 3.15.1 -> 3.15.2
  M4  S036  Python 3.15.0 -> 3.15.2   (NOT a frozen mutant; my own control, see 08)

## The frozen mutants also rewrite the teaches cell
A cell-level diff of the mutated SOURCES.md row vs the original shows the sed changes TWO cells
per row, not one:
  M1  S034  col7 anchor 'Entry titled v2.2.0, tag link /releases/tag/v2.2.0 …' -> '…v2.2.1…'
             col8 teaches 'Newest stable Vault is v2.2.0; the same feed carries sdk/v0.26.0 and v…' -> '…v2.2.1…'
  M2  S035  col7 anchor and col8 teaches both v2.7.1 -> v2.7.2
  M3  S039  col7 anchor 'Python 3.15.1 item, …' -> 'Python 3.15.2 item, …'
             col8 teaches 'supersedes S036 — newest stable semantic version in this fetched feed is 3.15.1; …' -> '…3.15.2…'
So "the three frozen in-place anchor rewrites" are, in bytes, three two-cell row edits.
The pin gate reads only column 7, so the detection verdict is unaffected (DRIFT is reported),
but the mutant is not a pure anchor-cell edit.

## What each committed instrument sees (candidate tree, one mutant at a time)
  mutant | anchor-pins.sh        | round-37-c2.sh | release-clock.py            | census | sweep
  M1     | DRIFT S034 (rc 1)      | 0 (rc 0)       | DERIVATION S013,S022,S023,S024; FAILED observed=26 fired=11 | CLEAN | n=8
  M2     | DRIFT S035 (rc 1)      | 0 (rc 0)       | DERIVATION S014,S015,S016,S021,S025,S026; FAILED observed=24 fired=9 | CLEAN | n=8
  M3     | DRIFT S039 (rc 1)      | 0 (rc 0)       | CLEAN (on_release=30 … fired=15 derived=15) rc 0          | CLEAN | n=8
  M4*    | CLEAN (pins=3) rc 0    | 0 (rc 0)       | CLEAN rc 0                                                | CLEAN | n=8
  (*M4 = my control, S036 is not pinned — see 08, defect D1)

## Same three mutants applied to the BASE tree (pre-existing instruments only)
  BASE + M1 (S034)  -> release-clock.py: DERIVATION S013,S022,S023,S024; FAILED observed=26 fired=11 derived=11
  BASE + M2 (S035)  -> release-clock.py: DERIVATION S014,S015,S016,S021,S025,S026; FAILED observed=24 fired=9 derived=9
  BASE + M3 (S039)  -> release-clock.py: CLEAN (on_release=30 … fired=15 derived=15) rc 0
=> M1 and M2 are ALREADY detected at BASE by corpus/release-clock.py (as DERIVATION findings),
   because those rows' anchored_version is derived from the feed row's anchor cell
   (derived_anchor_bound). M3 is not detectable at BASE by any committed gate except the new
   anchor-pins gate. This is the concrete novelty of C1: it is the first gate that sees an
   in-place rewrite of S039's anchor cell.

## round-37-c2.sh on a 2.2.10 boundary (the round-37 M5 probe the plan routes to round 40)
  $ (in a tree with S089's anchor rewritten v2.2.1 -> v2.2.10) bash plans/round-37-c2.sh
      1        rc 0
  $ (unmutated candidate) bash plans/round-37-c2.sh
      0        rc 0
=> the round-37 counter DOES read the 2.2.10 boundary correctly (it does not mistake v2.2.10
   for v2.2.1), consistent with the plan's statement that the counter "already reads the
   boundary correctly on the fixture class I measured, so it is a control gap, not a detection
   gap". The surviving-mutant M5 concern is about the counter's own frozen control set, not
   about this behavior.
