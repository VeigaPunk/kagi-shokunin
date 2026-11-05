Draft for the L1 to integrate into `SCORECARD.md`. Two headings, in the order the lane's rounds 36–41 use
(§Round N — pre-move, then §Round N — post-move). Every value the L1 must measure at the candidate is a
`FILL` token (double angle brackets around `FILL: name`); QM7 forbids a placeholder in a committed
file, so the L1 replaces each one before commit.

## Round 42 — pre-move (repo HEAD 98dd4de, round-41 close)

Claim BASE `e8265c0d90b01fcce0447d2f70615b0592ed145f`; predeclaration `98dd4de` (frozen plan
`plans/round-42.md`, counters `plans/round-42-c1.sh` and `plans/round-42-c2.sh`, controls runner
`plans/round-42-controls.sh`, measured BASE receipts under `.ufo/waves/round-42/controls/`); predeclaration
amendment A1 `fdbb83d` (the frozen C2 counter is taken from `5142b52`, before any candidate commit).
Round-40 landed state (the positive control P0 of C1): `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`;
C1 base ledger `6cc8850dfc5757927699e5a53a876f47c8df21aa`. Every axis stood at 9 at the round-41 close;
this table is the reference line the two claims are measured against.

- **C1 calibration — BASE 4.** `bash plans/round-42-c1.sh` reads 4 at the claim BASE: the round-41 gate
  refuses F1–F4 and accepts F5, an unjournaled deletion of `R17-02` (`.ufo/waves/round-42/controls/c1-base.txt`
  → `4`). Controls `c1-control-refuse-all.txt` and `c1-control-accept-all.txt` read 0 and 0. Target 5.
- **C2 freshness — BASE 0.** `bash plans/round-42-c2.sh` reads 0 at the claim BASE
  (`.ufo/waves/round-42/controls/c2-base.txt` → `0`): the committed runner writes a worktree reading (3,
  `.ufo/waves/round-42/controls/c2-worktree-at-base.txt`) where the frozen derivation D reads 1
  (`.ufo/waves/round-42/controls/c2-derivation-D.txt`). Target 1.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract and the feed-token agreement invariant. Row `R29-01`. | round 29 |
| coverage | 9 | 98 registry rows at BASE (A 94, B 2, C 2, queued 1, mined 93, rejected 4); census CLEAN, fleet `kagi ok` (row `R21-02`). This round re-opens S094 and adds no row. | round 41 |
| operability | 9 | Gate mode-sets with verdicts and selftests green; the committed gate is `corpus/expect-journal.sh`, but the controls runner's C2 BASE line is a worktree reading (receipt 1, worktree 3 — `.ufo/waves/round-42/controls/c2-worktree-at-base.txt`). | round 41 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-42-c2.sh` reads 0; the committed receipt `.ufo/waves/round-41/controls/c2-base-19025d9.txt` reads 1 while the same runner at the same commit reads 3. | round 41 |
| calibration | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-42-c1.sh` reads 4 — the journal gate refuses a loosened expect but a deleted ledger row is in neither population of its frozen classes and passes `CLEAN` (round-41 spot-check, routed item 4). | round 41 |
| adjacency | 9 | Unchanged: ownership partition gate green (row `R17-02`); the ledger carries 86 ids at the base ledger, at P0 and at the claim BASE, with no id removed across them. | round 35 |

## Round 42 — post-move (claims C1 calibration, C2 freshness)

Measured commands and receipts: `.ufo/waves/round-42/`. The frozen predicates, counters, kill rules and
targets are `plans/round-42.md` (predeclaration `98dd4de`, amendment A1 `fdbb83d`) and were not amended
after data. Axis scores stay 9 → 9: a claim move adds no new score; the rows record what moved, as in
rounds 36–41. The "Before → after" column carries the counter reading: the before value is the measured
BASE reading (receipt pointer in the evidence column), the after value is the candidate reading, which
the L1 measures and replaces (a `FILL` token).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 4 → <<FILL: c1 candidate reading>> (axis score 9 → 9) | [C1] `bash plans/round-42-c1.sh` at the candidate: the journal gate refuses all five forgeries F1–F5 with their frozen tokens (`UNJOURNALED R13-01`, `OLD_MISMATCH R21-02`, `NOT_LITERAL R13-01`, `COMMAND_MISMATCH R24-06`, `DELETED R17-02`) and accepts the positive control P0 (`EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`). The new class is unconditional: every base-ledger id absent from the candidate ledger is refused with `DELETED <ID>`; the existing classes, the four-column ledger format and the migration schema are unchanged and `MISSING_ROW` is kept. Blanket-refuse and blanket-accept controls read 0. Ceilings (declared, not closed): the gate does not re-run commands and does not judge reason text; a deleted row with a surviving journal entry is still refused by `MISSING_ROW`; the rule refuses a legitimate future retirement until a retirement form exists; F5 forges one row only. The round-41 lesson's M41-5 erratum stands (the old gate's policy allowlist refuses F4's `echo` construction — `first-token:echo` — so it never "accepts F1–F4 by construction"). | `plans/round-42-c1.sh`; `corpus/expect-journal.sh`; `.ufo/waves/round-42/controls/c1-base.txt` (4), `c1-control-refuse-all.txt` (0), `c1-control-accept-all.txt` (0); `.ufo/waves/round-41/expectation-migrations.json`; `corpus/lessons/round-42.md` §Mistakes M41-4, M41-5, M41-6 |
| freshness | 0 → <<FILL: c2 candidate reading>> (axis score 9 → 9) | [C2] `bash plans/round-42-c2.sh` at the candidate: the controls runner's C2 BASE line is produced by running the frozen C2 counter in a `git archive 19025d9` extraction, with the counter copied in from the lane, never in the lane worktree, so `.ufo/waves/round-41/controls/c2-base-19025d9.txt` is re-derivable from the revision it names (BASE: committed receipt 1, worktree reading 3). Amendment A1 pins the derivation D to `git show 5142b52:plans/round-41-c2.sh`, so a candidate edit to `plans/round-41-c2.sh` cannot move D or N. The runner's other lines and its C1 controls are unchanged. Ceiling (named, not closed): the counter checks the receipt value against D, not the runner's source — a runner writing the constant 1 passes; the claim does not re-derive the round-41 C1 BASE. S094 re-opened 2026-11-05 (HTTP 200, decoded 11296 bytes, sha256 `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`, byte-identical to `.ufo/waves/round-39/capture/S094.body`; quote "Only `status`, `recheck` and `used-by` change in place" at raw offset 6172, count 1); registry rows added: none; rows touched: none. | `plans/round-42-c2.sh`; `plans/round-41-controls.sh`; `.ufo/waves/round-42/controls/c2-base.txt` (0), `c2-derivation-D.txt` (1), `c2-worktree-at-base.txt` (3); `.ufo/waves/round-41/controls/c2-base-19025d9.txt` (1); `corpus/SOURCES.md` row S094; `.ufo/waves/round-42/build/K42ScribeLesson/gate-receipt.txt`; `corpus/lessons/round-42.md` §Mistakes M41-4, M41-7 |

FILL keys for the L1: `c1 candidate reading` = the value `bash plans/round-42-c1.sh` prints at the
candidate (target 5); `c2 candidate reading` = the value `bash plans/round-42-c2.sh` prints at the
candidate (target 1). Both must be replaced before commit — QM7 fails a stamp on a placeholder token in
a tracked file. If a claim fails its kill rule, its row records the measured reading and the failed
kill clause, not the target.
