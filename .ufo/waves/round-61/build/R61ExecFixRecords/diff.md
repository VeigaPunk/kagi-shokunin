# R61ExecFixRecords — diff receipt (round 61)

`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff -- LOG.md corpus/lessons/round-60.md plans/round-60.md`
at the time of writing (all hunks are pure appends; `--numstat` = 1/0, 15/0, 14/0 —
0 deletions in every file).

```diff
diff --git i/LOG.md w/LOG.md
index ab0ef0e..d45e707 100644
--- i/LOG.md
+++ w/LOG.md
@@ -1979,3 +1979,4 @@ Frozen BASE `655e620`; plan `4767b04` (alone, QM29); plan corrections 1/2 `2d46e
 - Corpus: `corpus/SOURCES.md` 122 → 124 rows (S123, S124; tier A, `mined`, `180d`); `corpus/source-fetches.tsv` +2; entry `corpus/knowledge/openbao-approle-secret-id-custody.md` (41 entries, row-linked, pinned); coverage map +2 rows; `corpus/QUALITY.md` gains QM76 (a `kind: gate` row carries a runnable self-invocation mode) and QM77 (an amendment cites a receipt carrying every observable it restates).
 - No axis is re-scored: all six stay 9 → 9 (L1 reading, for the operator's ruling). No stagnation waiver, retirement or split.
 - Wave `kagi-r60-w1`, 16 seats v1 (`.ufo/waves/round-60/w1-dispatch.json`; reports `.ufo/waves/round-60/w1/`): 2 scout, 6 executor, 2 scribe, 1 reviewer, 1 critic, 1 mutation-tester, 1 sentinel, 1 connector, 1 revenger; dead seats 0 (16 of 16 seats settled with a non-empty final output; the mutation-tester settled late and delivered `MUTANTS: total=16 killed=9 survived=7`).
+- Correction (round-61 C1 I5, spot-check D5): supersedes the round-60 LOG wave line above — it was rewritten in place at `818d2a82` (`git diff --numstat 14a6c07d 818d2a82 -- LOG.md` ⇒ insertions=1 deletions=1: the superseded `dead seats 1` sentence replaced by `dead seats 0`) instead of an appended correction, contrary to the append-only convention this log applies elsewhere; the superseded text is recoverable at `14a6c07d`, and this line is the correction of record.
diff --git i/corpus/lessons/round-60.md w/corpus/lessons/round-60.md
index 7ab71a5..05f432c 100644
--- i/corpus/lessons/round-60.md
+++ w/corpus/lessons/round-60.md
@@ -163,3 +163,18 @@ own. Contested scope reported, not absorbed: the trial's `strace`/argv evidence
 round-scoped (R33), and the carried `ADJACENCY_SCOPE: DEFECT`
 (`breadth_drift=5 breadth_unverified=1`, `stale_basis=0`) is unchanged and named in
 `.ufo/waves/round-60/final/scope-candidate.txt`, not absorbed.
+
+## Correction (round 61)
+
+Appended in round 61 (claim C1 `C1_ROUTED` items I1/I3/I4/I6/I7, routing the round-60
+verifier spot-check §7 defects D1, D3, D4, D6, D7). The superseded statements above
+stand unrewritten; under the lane's last-occurrence-wins convention these lines are
+the corrections of record. Every number below was re-derived in round 61 from the
+named tree objects; the derivations are receipted at
+`.ufo/waves/round-61/build/R61ExecFixRecords/rederive.md`.
+
+- Correction (I1, spot-check D1): supersedes R37 and the §Bounds line "the wave's 16th seat (mutation-tester) produced nothing" — measured on this tree over `.ufo/waves/round-60/w1-results.json`, results=16 output=3824 (16 result records; the `R60MutCounters` record's final output is 3824 bytes, both derived from that file), and the seat delivered `.ufo/waves/round-60/build/R60MutCounters/mutants.md` (with its `raw/` directory) plus the report `.ufo/waves/round-60/w1/R60MutCounters.md`: the mutation-tester seat produced artifacts and a report.
+- Correction (I3, spot-check D3): the plan §A3 item 2 asserts a form-encoded-body behaviour its cited receipt `.ufo/waves/round-60/final/l1-probe.txt` does not carry (that receipt holds no form/content-type leg), and mistake M60-2 mined only §A3 item 4 — §A3 item 2 is the second instance of the same mistake class (an amendment grounded on a receipt that did not carry its observables); the plan withdraws it in Amendment A7.
+- Correction (I4, spot-check D4): supersedes the round-60 quality-trend sentence "The round introduced no new record defect that it did not itself route (R32–R43)" in the round-60 report's §Trend verdicts — the round introduced three new record defects it did not route: D1 (R37's false no-artifacts claim), D2 (`SKILL.md:855` registering `plans/round-60-c2.sh` as `kind: gate` with selftest `none of its own`) and D3 (§A3 item 2's receipt-free form-encoded claim).
+- Correction (I6, spot-check D6): supersedes the round-60 stale-lane paragraph ("launch 15:09:28 −03" with commit times matching neither author nor committer stamps) — the driver line is `2026-11-07T15:03:17-03:00 launch kagi round=60` (complete `2026-11-07T16:34:37-03:00`), and the lane's committer stamps inside that window — `2026-11-07T15:06:58-03:00`, `2026-11-07T15:14:19-03:00`, `2026-11-07T15:18:26-03:00`, `2026-11-07T15:47:01-03:00` — each occur in `git log --format='%ci' a677c78e..818d2a82`: the lane was progressing, not stale.
+- Correction (I7, spot-check D7): supersedes the round-60 attack-share arithmetic "4/16 = 25 % on the addendum's literal list" — derived from the role mix of `.ufo/waves/round-60/w1-results.json` (16 results, `agent` fields): the addendum's literal attack list {reviewer, critic, mutation-tester, labrat} has three present roles (reviewer, critic, mutation-tester; no labrat seat exists) so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %; the round states both readings, as R36 already did.
diff --git i/plans/round-60.md w/plans/round-60.md
index ccfb235..b72a1dd 100644
--- i/plans/round-60.md
+++ w/plans/round-60.md
@@ -327,3 +327,17 @@ produced receipt. A5 item 3's rule is unchanged in substance (the gate's own ver
 line, with at least one numeric `key=value` field); the prefix for that one receipt is
 `ADJACENCY_SCOPE:`, and the checker's `_FINAL_PREFIXES["scope"]` plus its fixtures are
 corrected to it. The other two prefixes (`RELEASE_CLOCK:`, `DOC_AUDIT:`) are unchanged.
+
+## Amendment A7 — 2026-11-07, after the round-60 closure (withdraws A3 item 2; round-61 C1 item I3)
+
+Spot-check D3 (round-60 verifier spot-check §7): §A3 item 2 asserts the
+form-encoded-body behaviour ("role creation returns 204 with defaults and every login
+reads 400 `invalid role or secret ID`"), but its cited receipt
+`.ufo/waves/round-60/final/l1-probe.txt` carries no form/content-type leg — the probe
+never sent a form-encoded request, so the receipt cannot carry the observable the
+amendment restated. Lesson mistake M60-2 mined only §A3 item 4; item 2 is the second
+instance of that class. **A3 item 2 is withdrawn**: the trial's every-request contract
+keeps the first sentence of item 2 (`Content-Type: application/json` on every
+request), and the unmeasured form-encoded refusal shape is a named gap, not a frozen
+observable (the entry's D10 already discloses it). A3 items 1, 3 and 5 stand; item 4
+was withdrawn by A4. No predicate, target, POP, item or kill rule changes.
```
