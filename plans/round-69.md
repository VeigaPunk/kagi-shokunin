# Round 69 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 69, attempt 1. Claim BASE
`264917aa8fc9e71b6595d0d5166c4b615120fb8b` (round-68 verifier spot-check tip).
This file is the predeclaration: committed alone before any candidate work.
The candidate moves; this file does not.

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; a capability entered
round 67 and round 68 entered none (1 of 3), so the stagnation nudge does not
fire and the lowest-axis obligation binds. All six cells are equal, so the tie
is broken by measurement: round 68's non-author spot-check
(`corpus/lessons/round-68-verifier-spotcheck.md`) rejected the round
(`rejected-harmed`: C1 verified, C2 `unprovable`, calibration and discernment
harmed) and routed **thirteen numbered defects** (§7 items 1–13). This round
repairs those record surfaces and the two falsified instruments, each with a
counter a reader can re-run. No retirement, no split.

Motivating evidence, measured at BASE this round (receipts under
`.ufo/waves/round-69/base/`):

- `SCORECARD.md:2425` prints `C2_RECORD: mismatches=0 population=3 guard=1 …
  rc 0` for C2 while `.ufo/waves/round-68/final/c2-candidate.txt` is 0 bytes
  and `w1/R68ScribeLesson/c2-lane-run.txt:6` says the process was killed at
  the budget (D1).
- `SCORECARD.md:2426` says "QM97–QM99 enter the bar"; `corpus/QUALITY.md` ends
  at QM96 and `git diff d3b2a4e..264917aa -- corpus/QUALITY.md` is empty (D2,
  D11).
- `corpus/lessons/round-68.md:18` states "`C2_RECORD` mismatches 3 → 0" (D3);
  `LOG.md:2221` prints `C1_VERIFIED_SELFTEST: PASS (59 cases)` where
  `w1/R68ExecCounterC1/selftest.txt:13` reads 56 (D4);
  `.ufo/waves/round-68/base/base-derivation.md:33` quotes `caught=0/6` where
  `w1/R68ExecCounterC1/base-run.txt:21` reads `caught=6/6` (D5).
- `.ufo/reports/round-68/kagi.md:106` cites
  `.ufo/waves/round-68/final/c1-base.txt`, which exists in no commit (D6).
- `.ufo/waves/round-68/claims.json` still carries the pre-A1 target
  `verified=37 col15=32` (D7).
- `plans/round-68-c1.sh:753` `predicate_ok` returns
  `guard == 1 and caught == 6 and defects == 0`: the frozen floors
  `verified >= 37` and `col15 >= 32` are not compared, and the selftest has no
  sub-floor case (D8).
- `corpus/claim-ledger.tsv` row `R68-02` pins the C2 aggregate line the
  counter never produced on the landed bytes, and the counter treats its own
  invocation as the row's execution (D9).
- `SCORECARD.md:2424` prints `caught=0/6` for BASE alone; the spot-check's
  frozen-anchor battery reads 2/6 (`w1/R68Sentinel/receipts/base-legs.txt:19`)
  (D10).
- Round 68 filed without `w1-results.json` (D12), and its expansion verdict
  claimed `improved` for a widening of an existing entry (D13).

## C1 — calibration: the round-68 record surfaces match observed state

Target axis: calibration (`AXES.md`: "SHONEN.md/SCORECARD entries match
observed repo state"). The claim counts mismatches between the lane's
self-assessment and observed repo state, one leg per routed defect.

**Frozen predicate (this sentence is the plan's, the counter's code and the
receipt's label):**

```
C1_RECORD: mismatches=0 population=13 guard=1
```

`bash plans/round-69-c1.sh --tree <candidate> [--base-tree <BASE extraction>]`
computes, each leg derived from the measured tree's bytes (never listed):

| leg | routed defect | measured at BASE (mismatch) | repair the leg requires |
|---|---|---|---|
| L1 | D1 | `SCORECARD.md` §`## Round 68 — post-move` calibration row prints the fabricated aggregate `C2_RECORD: mismatches=0` as an achieved reading | the row carries the honest stop: it names `unprovable` and the receipt `.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt`, that path exists in the tree, and the row carries no `mismatches=0` string |
| L2 | D2 | the same section's depth row says "QM97–QM99 enter the bar" while none exist | the row names every criterion id that `corpus/QUALITY.md` carries with `corpus/lessons/round-68.md` in its source column (the set is derived from QUALITY, never listed) and carries no "enter the bar" claim |
| L3 | D3 | `corpus/lessons/round-68.md:18` states the C2 target as achieved | the original sentence is still present **and** an appended block headed `Correction (round 69)` names the superseded `C2_RECORD` sentence and the honest-stop receipt (append-only: the old bytes are never rewritten) |
| L4 | D4 | `LOG.md` prints `C1_VERIFIED_SELFTEST: PASS (59 cases)`; the receipt's own count is 56 | the original line is still present **and** an appended `Correction (round 69)` names the count the receipt `.ufo/waves/round-68/w1/R68ExecCounterC1/selftest.txt` prints (the count is parsed from the receipt, never named by the counter) and that receipt exists |
| L5 | D5 | `base-derivation.md` quotes `caught=0/6`; the receipt reads `caught=6/6` | an appended correction names the value parsed from `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt` and that receipt exists |
| L6 | D6 | the round-68 report cites `final/c1-base.txt`, absent from the tree and from every commit | `corpus/lessons/round-69.md` names the dead citation `.ufo/waves/round-68/final/c1-base.txt` and the corrected pointer `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt`, and the corrected path exists |
| L7 | D7 | `claims.json` carries only the pre-A1 `37/32` target | the file parses, the original `target` strings are unchanged, and a `superseded_by` object names `Amendment A1` and the final reading `38`/`33` |
| L8 | D8 | `predicate_ok` ignores both frozen floors | extracting the function and executing it: `(36,31,6,1,0)` is refused, `(37,32,6,1,0)` and `(38,33,6,1,0)` are accepted, and `(38,33,5,1,0)`, `(38,33,6,0,0)`, `(38,33,6,1,1)` are refused; the selftest table carries a case named `predicate-subfloor` |
| L9 | D9 | `R68-02` pins a line the tree never printed | exactly one `R68-02` row exists, its expect is fully literal anchored, its command exits 0 and its last line matches the expect when executed with the row's own timeout, and a migration journal entry carries `old_expect` = `^C2_RECORD: mismatches=0 population=3 guard=1$` |
| L10 | D10 | `SCORECARD.md:2424` prints `0/6` alone | the round-68 freshness row carries both BASE readings (`0/6` and `2/6`) and names `.ufo/waves/round-68/w1/R68Sentinel/receipts/base-legs.txt`, which exists |
| L11 | D11 | the bar ends at QM96 while the record claims new criteria | `corpus/QUALITY.md` carries at least four criteria with id > QM96 whose source column names `corpus/lessons/round-68.md` (the ids are derived, never listed) |
| L12 | D12 | round 68 filed with no settlement file and achievement-shaped spec metadata | `.ufo/waves/round-69/w1-results.json` parses, every seat entry has a terminal status, and `.ufo/waves/round-69/w1-spec.json` carries no `C1_RECORD:`/`C2_TEETH:` target string and no `mismatches=0` |
| L13 | D13 | round 68 called a widening of an existing entry `expansion — improved` | `corpus/lessons/round-69.md` carries a line `expansion` whose `new knowledge entries=<n>` equals the number of files under `corpus/knowledge/` in the measured tree minus the same count in `--base-tree` (both derived, never listed) |

**Kill rules.** The target is missed if `mismatches > 0` or `guard = 0`.
`guard = 1` iff:

- (a) `plans/round-68.md` carries `## Amendment A2 — post-closure repairs
  (round 69)` naming, in its body, each changed surface with old → new:
  `SCORECARD.md`, `corpus/lessons/round-68.md`, `LOG.md`,
  `base-derivation.md`, `claims.json`, `predicate_ok`, `R68-02`,
  `QUALITY.md`;
- (b) the unmodified candidate tree prints `C1_RECORD: mismatches=0
  population=13 guard=1`;
- (c) **no-work control** — on the extracted BASE tree the counter prints
  `mismatches=13` and every leg prints its mismatch detail (a leg that reads
  pass at BASE is a defect of the counter, not a bonus);
- (d) **decoy control** — a copy with the L1 honest-stop text moved into the
  round-67 calibration row (round-68 row left fabricated) still reads L1 = 1
  (file/section scoping, not a keyword search);
- (e) **misplacement control** — a copy with the L3 correction appended to the
  end of `LOG.md` instead of the lesson still reads L3 = 1;
- (f) `--selftest` prints `C1_RECORD_SELFTEST: PASS (N cases)` with
  `N >= 12`, including a constant-verdict mutant and a sub-population case.

A `SETUP` line (missing surface, empty tree) is never a pass. No count is
hard-coded: the populations, the receipt values and the criterion ids are all
derived from the measured bytes.

Landing surface: `SCORECARD.md` (round-68 section rows L1/L2/L10),
`corpus/lessons/round-68.md` (L3), `LOG.md` (L4),
`.ufo/waves/round-68/base/base-derivation.md` (L5),
`corpus/lessons/round-69.md` (L6, L13), `.ufo/waves/round-68/claims.json`
(L7), `plans/round-68-c1.sh` (L8), `corpus/claim-ledger.tsv` + a round-69
journal (L9), `corpus/QUALITY.md` (L11), the round-69 wave files (L12).

Ceilings (named, not saturated): the counter reads committed bytes, so it
cannot vouch for a receipt's *authorship* — only that the receipt exists and
carries the value the record quotes; `L12`/`L13` are end-of-round surfaces and
are the only legs whose pass depends on the round's own artifacts; the
`caught=2/6` frozen-anchor reading is a receipt, not a re-run (re-running the
BASE gate on a NEW anchor is not the same measurement).

## C2 — operability: the two falsified instruments refuse their negatives

Target axis: operability (`AXES.md`: "Runnable artifacts: checklists that are
executable, commands that exist, scripts that run"). Round 68's closure
falsified two instruments (D8, D9); this claim makes each refuse its own
negative on the production path.

**Frozen predicate:**

```
C2_TEETH: subfloor=<0|1> ledger=<0|1> guard=<0|1>
```

`bash plans/round-69-c2.sh --tree <candidate> [--base-tree <BASE extraction>]`
computes two legs:

- `subfloor` = 1 iff (a) the candidate `plans/round-68-c1.sh`'s extracted
  `predicate_ok` refuses `(36,31,6,1,0)` and accepts `(37,32,6,1,0)` and
  `(38,33,6,1,0)`; (b) its `--selftest` prints
  `C1_VERIFIED_SELFTEST: PASS (N cases)` with `N` strictly greater than the
  same run on the BASE tree's copy (`N_cand = N_base + 1`, derived by running
  both); (c) the BASE copy's predicate **accepts** `(36,31,6,1,0)` — the
  blindness witness.
- `ledger` = 1 iff (a) a scratch copy of the candidate tree whose
  `corpus/claim-ledger.tsv` holds only the `R68-02` row (plus comments) runs
  `bash corpus/claim-ledger.sh verify` through the gate's own path and exits 0
  with `CLAIM_LEDGER: CLEAN (claims=1` on the last line; (b) the same scratch
  with `R68-02`'s command replaced by `true` exits 1 with a `FAIL R68-02`
  line (the row is executed, not text-matched); (c) `bash
  corpus/expect-journal.sh` reads `EXPECT_JOURNAL: CLEAN` against the BASE
  ledger with the round-69 journals; (d) `bash corpus/row-identity.sh
  ledger-ids` matches the identity the ledger's own `R24-14` row pins (the
  membership migration is real).

**Kill rules.** Missed if `subfloor = 0`, `ledger = 0` or `guard = 0`.
`guard = 1` iff:

- (a) the unmodified candidate prints `C2_TEETH: subfloor=1 ledger=1 guard=1`;
- (b) the BASE extraction prints `subfloor=0` and `ledger=0` (the no-work
  control: BASE cannot reach either leg);
- (c) **comment-only control** — a copy that adds `# verified >= 37, col15 >=
  32` above the unchanged predicate body still reads `subfloor=0`;
- (d) `--selftest` prints `C2_TEETH_SELFTEST: PASS (N cases)` with `N >= 10`,
  including the scratch-ledger builder, the `true`-command negative and the
  constant-verdict mutant.

Landing surface: `plans/round-68-c1.sh` (predicate floor + sub-floor case),
`corpus/claim-ledger.tsv` (`R68-02` repointed through a journaled migration,
`R69-01`/`R69-02` minted), `.ufo/waves/round-69/journals/`.

Ceilings: `ledger` runs one row through the gate, not the whole 100-row
ledger (the full run costs > 5 min and is receipted separately, not claimed);
the `R68-02` repoint carries a journaled supersession, which is a narrowing of
what the row protects and is stated in the lesson.

## Frontier step (contract v1)

Two sources opened this round by the scout seat, one admit and one reject:

- **S168 (admit candidate)** — RFC 9162 (Certificate Transparency v2) §2.1 /
  §2.1.1, the append-only property of a Merkle log: a log's later state must
  be an append-only extension of its earlier state, and the proof of that
  property is a consistency proof between the two tree heads. Grounds C1's
  supersession rule and the new knowledge entry
  `corpus/knowledge/record-supersession.md` (the entry is the round's
  expansion product, not a claim).
- **S169 (reject candidate)** — the Wikipedia "Merkle tree" article, opened
  for the same rule: a tertiary summary with no normative mechanism or
  consistency-proof obligation; reject with the flip (cite the RFC it
  summarizes).

Both rows carry the URL, access date and a ≤25-word located quote in the
lesson's `## Gate`; every `status`/`recheck`/`used-by` change is logged
old → new in the round-69 lesson. The census at round start reads
`kagi ok` exit 0; a lane gate reading is required at round end.

## Mistakes to mine

- **M69-1** — a repair that writes a corrected sentence but leaves the
  fabricated one as the only citable line teaches a reader the wrong fact;
  captured-by: the append-only + `Correction (round 69)` rule this round
  freezes.
- **M69-2** — a predicate whose frozen floors exist only in the plan (D8) is
  not a floor; captured-by: QM98.
- **M69-3** — a ledger row whose expectation the tree never printed is a
  guaranteed miss dressed as a claim; captured-by: QM99.
- **M69-4** — `expansion` credited for widening an existing entry; captured-by:
  QM100 and L13's derived count.
Plus any new misfires the wave measures; each with class · evidence pointer ·
captured-by · fix.

## Wave

One v1 wave, `kagi-r69-w1`, 15 seats under `ufo-wave-policy.json` (run-15 band
8–16, ≥25% attack share, ≤2 connector seats): 5 executor (C1 counter; C2
counter; record surfaces; ledger/journal; predicate floor), 3 scribe (lesson;
QUALITY/knowledge/README; registry/fetch rows), 1 scout (source opening), 1
connector (sibling overlap), 1 reviewer, 1 critic, 1 mutation-tester, 1
sentinel, 1 revenger — attack 5/15 = 33.3%. The planner seat is the L1's.
One writer per file; no seat commits; all scratch under
`$HYAKU_SCRATCH/kagi-r69/<seat>/`.

## Honest stop (attempt 3)

Appended at integration by the attempt-3 L1 (`KagiR69a3`). Nothing above this
heading is amended: predicates, populations, kill rules and targets stand as
frozen at `adb6972`. Both claims are filed as **missed** on their frozen
counters; no target is narrowed after data (§9). This section is the narrowing
pointer the pre-file falsification ledger cites for every `falsifies-wording`
row: the deliverable is the honest stop, not a re-worded claim.

- **C1** — landed tree: `C1_RECORD: mismatches=1 population=13 guard=0` (rc 1);
  BASE extraction: `mismatches=13`, every leg printing its mismatch. Eleven
  record-surface legs (L1–L11) and L13 pass; L12 fails because the wave
  settlement lost every seat output when the orchestrator was killed (the
  driver's `kagi-r69-w1-results.json` holds `output: null` × 16; the plan's
  `w1-results.json` does not exist). The L1 does not synthesise the driver's
  artifact. Kill rule `mismatches > 0` fires → **missed**. Attack findings that
  falsify the wording of individual legs (R69Reviewer F-1…F-7, R69Critic
  F-C1-1/-3/-4/-5/-6, R69MutTester M3: L11 counts ids without falsifier text) are
  recorded, not repaired by re-wording: they are routed to the next round's
  counter.
- **C2** — landed tree: `C2_TEETH: subfloor=0 ledger=0 guard=0` (rc 1); BASE
  reads `subfloor=0 ledger=0`. subfloor (b) is unmet (59 → 62 cases, not +1);
  ledger (a)/(b) are unsatisfiable on the production gate as frozen (the `true`
  negative is refused by the policy allowlist with rc 2; a one-row ledger is
  not CLEAN on the unscoped docs set). **Missed.** The repair the claim was
  about — `predicate_ok` comparing both frozen floors — landed and is measured
  by C1 leg L8; `R69-02` was not minted.
- Ledger: `R69-01` pins only the measured L1–L11 subset
  (`C1_RECORD_LEGS: legs=1,…,11 ok=11`), never the missed full target.
