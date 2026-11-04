# ExecReplay — scoped findings (round 35, C1 calibration replay)

Seat ExecReplay-2. Full evidence: .ufo/waves/round-35/build/ExecReplay/report.md + receipts/.
All runs read-only against lane repo (no clone, no git/jj mutation, no production edits). Scratch removed.

1. **Before state reproduced exactly.** Frozen instrument (measure.py e73cd1ff, unchanged since controls
   commit 63ba87af) driven against the BASE gate (corpus/prefreeze-control.sh at 063c4074, sha ca338da7):
   `MEASUREMENT_RESULT mismatches=5 invalid_false_clean=5 positive_matches=2 cases=9` exit 1. All nine cases'
   rc/stdout/stderr byte-identical to the frozen predeclaration receipt controls/before.json; totals 5/5/2 on
   both sides. The five false-CLEAN witnesses (setup-number, failed-number, diagnostic-number, stderr-number,
   clean-forgery) each certified `OK … measured=0` + CLEAN exit 0 at BASE; empty-output and wrong-count refused;
   valid-zero and grep-empty accepted. Independent direct replay with a seat-owned driver matches the
   instrument byte-for-byte on all nine cases (receipts/direct/, 27 files).

2. **BASE selftest green at BASE bytes.** `PREFREEZE_SELFTEST: PASS (12 cases)` exit 0, empty stderr.

3. **C1 predicate observed on installed candidate.** Mid-wave, the lane working tree gained the candidate
   producer (sha 2a0986d4e0bce5e2383ef60afe68b84036960045e7177870333b5de5424edeea, mtime 2026-11-04 15:30:48
   -0300; was ca338da7 at seat start). The same unmodified frozen instrument run against those working-tree
   bytes printed the exact C1 predicate `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0
   positive_matches=2 cases=9` exit 0, all nine match=true: five false-CLEAN → five NORESULT/SETUP-2 refusals,
   positive and refusal controls retained. This is an independent observation, not L1's official counter
   (final/after.json remains L1's).

4. **Nine-case contract coherence holds.** Every frozen expected rc/finding derives independently from the
   plan's production contract (single nonempty integer stdout line, no stderr, rc0; or rc1 with zero; else
   fail-closed NORESULT + SETUP exit2): setup/failed/diagnostic/stderr-number and clean-forgery → NORESULT rc2;
   valid-zero and grep-empty → OK rc0; empty-output → NORESULT rc2; wrong-count → MISMATCH rc1. No expected
   verdict contradicts the contract; the plan's named residual unsoundness (dishonest bare-integer rc0
   producer) is correctly outside the claim.

5. **Exact BASE populations measured via git show/archive.** Registry (SOURCES.md `## Registry` rows) 88;
   sourced (knowledge entries with `source:` header) 14; legacy (entries lacking it) 21 (prefreeze-controls.md
   NOT in the legacy bucket at BASE); captures (source-fetches.tsv data rows) 88; entries 35; context:
   claim-ledger 79, stamps 111, self-counts 62, docs gate on BASE extraction row_linked=32 by_hand=3 CLEAN.
   All five wave-population values equal the sibling populations-independent.json artifact (read as data).

6. **Hygiene.** No tool installs (base system python3/bash/git only; pacman paused per dispatch). Non-owned
   surfaces untouched (R25-02 FAIL / R29-01/R29-02 POLICY routing, SD6 bytes, sibling files). One driver bug
   (TSV expect column) was corrected and its artifacts replaced before reporting — noted in report §C.
