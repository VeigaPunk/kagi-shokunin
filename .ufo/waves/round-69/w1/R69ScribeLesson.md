# R69ScribeLesson — round-69 lesson seat report (kagi, attempt 2, mid-wave)

SEAT-STATUS: partial — the two lesson files are written; the registry, QUALITY,
knowledge-entry and README rows are not in the tree at this reading and are
recorded as `not landed` below. Readings marked `measured at integration` are the L1's.

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, claim BASE `264917aa`,
predeclaration `adb69726`. Axis judged: calibration.

## Files written

- `corpus/lessons/round-68.md` — append-only. One block `## Correction (round 69)` appended after the last line (the file's 226 existing lines are unchanged; `diff` against the pre-edit copy shows 9 added lines, 0 removed). Quotes the superseded `C2_RECORD` mismatches 3 → 0 sentence, states `unprovable`, and quotes `.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt:6` (`# (no C2_RECORD line; the process was killed at the budget)`). Gate: `citations --docs corpus/lessons/round-68.md` ⇒ `CITATION_GATE: CLEAN (cites=26 docs=1 unresolved=0 ephemeral=0 labeled=0)` rc 0.
- `corpus/lessons/round-69.md` — new; sections Claims, Gate, In-place registry changes, Mistakes (M69-1..4 as routed, M69-5..8 new), Frontier & census, L1 erratum. Gate: `citations --docs corpus/lessons/round-69.md` ⇒ `CITATION_GATE: CLEAN (cites=40 docs=1 unresolved=0 ephemeral=0 labeled=2)` rc 0 (two dead-path tokens labelled on their own line with `no longer present`).

## Receipts (`.ufo/waves/round-69/w1/R69ScribeLesson/`)

- `gate-quotes.txt` — URL, status, bytes, raw sha256 (own fetch = committed capture), `rendered-text-v1` locate counts for each chosen quote (S168 10 words count=1; S169 24 words count=1).
- `expansion-count.txt` — BASE 48 vs measured 48 ⇒ `new_knowledge_entries=0`.
- `erratum-check.txt` — `git log --all` for the dead path ⇒ 0 commits; corrected pointer exists; `sed -n 19p` reads `C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0`.
- `base-13-legs.txt` — the thirteen BASE defect legs, each with the line read.
- `c2-mid-wave-readings.txt` — C2 counter run on BASE and candidate, with commands and verdict lines.
- `base-c1-selftest-rerun.txt`, `citations-lane-full.txt` — copies of the re-runs cited in the lesson.

## Measured readings (commands and output)

- Round-start census (`.ufo/waves/round-69/base/census-round-start.txt`): `kagi ok`, EXIT=0. Mid-wave re-run: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒ `kagi	ok	…/corpus/SOURCES.md`, `EXIT=0`.
- BASE `predicate_ok` (extracted and executed from `264917aa:plans/round-68-c1.sh`): `(36,31,6,1,0)`→True, `(37,32,6,1,0)`→True, `(38,33,6,1,0)`→True, `(38,33,5,1,0)`→False, `(38,33,6,0,0)`→False, `(38,33,6,1,1)`→False. The floors are not compared (D8 confirmed).
- BASE `R68-02` expect `^C2_RECORD: mismatches=0 population=3 guard=1$`; `c2-lane-run.txt:6` has no such line (D9 confirmed).
- `git log --all -- .ufo/waves/round-68/final/c1-base.txt` ⇒ 0 commits (D6 confirmed).
- `C1_VERIFIED_SELFTEST` on the committed `plans/round-68-c1.sh` (blob `a907fc2a`, same blob at `264917aa`, `ef90e98`, `0bddda6`, `8342062`): `PASS (59 cases)`; `selftest.txt:13` reads `PASS (56 cases)` — receipt does not reproduce (M69-5).
- `C2_TEETH` on BASE: `subfloor=0 ledger=0 guard=0`. On the candidate scratch copy: `subfloor=0 ledger=0 guard=0`; candidate selftest `PASS (62 cases)`; leg (b) `tree_cases=62 base_cases=59 need tree=base+1` ⇒ 0. With `predicate-floor-edge` and `predicate-floor-col15` removed from the scratch copy (`predicate-subfloor` kept): `tree_cases=60`, `subfloor=1` (receipt `c2-mid-wave-readings.txt`, final block; the counter's `C2_TEETH` line there still reads `ledger=0 guard=0`).
- Ledger leg on the candidate: (a) `verify-reduced: FAIL R68-02 reason=exit-mismatch exit=127` (counter absent); (b) `true` ⇒ `POLICY R68-02 reason=first-token:true`, rc 2; (c) `EXPECT_JOURNAL: CLEAN (changed=3 journaled=3)`; (d) `ROW_IDENTITY: ledger-ids count=103 sha256=4d15db51…` (R24-14 pin matches).
- Whole-docs `citations` on the lane tip: `CITATION_GATE: BROKEN (cites=5375 docs=175 unresolved=32 ephemeral=1 labeled=24)`; on BASE extraction: `BROKEN (cites=5369 docs=175 unresolved=19 ephemeral=1 labeled=41)`; full output `.ufo/waves/round-69/w1/R69ScribeLesson/citations-lane-full.txt`.

## Gate rows

S168 admit (RFC 9162 §2.1.4, located quote count=1, 10 words); S169 reject (Wikipedia Merkle tree, located quote count=1, 24 words; zero `append-only`, `consistency proof`, `MUST` in the rendered text). Full rows in the lesson `## Gate`.

## Not landed at this reading (recorded, not claimed)

- `corpus/SOURCES.md` and `corpus/source-fetches.tsv`: no S168/S169 rows (`git status` empty). The captures at `.ufo/waves/round-69/capture/` are present and match my own fetch.
- `corpus/QUALITY.md`: last criterion still QM96; no QM97–QM100.
- `corpus/knowledge/`: 48 files; no new entry. `corpus/README.md`: no Frontier bullet.
- `plans/round-69-c1.sh`: absent. `plans/round-69-c2.sh` present (R69ExecCounterC2).
- The lesson's `In-place registry changes` says `Completed at integration`.

## Findings routed to L1 (not edited by this seat)

1. C2 leg (b): candidate `plans/round-68-c1.sh` has three new cases where §C2 requires +1 (M69-7). R69ExecPredicate and R69ExecCounterC2 both measured the same numbers and hold the decision for L1.
2. C2 ledger leg (b): the `true` negative is refused by the gate as `POLICY reason=first-token:true` (rc 2), so the frozen `FAIL R68-02` witness cannot be produced by that shape (M69-6). Predicate-satisfiability decision for L1.
3. The round-68 selftest receipt `R68ExecCounterC1/selftest.txt:13` does not reproduce from its committed blob (56 receipt vs 59 run) (M69-5). Correction under the append-only rule is L1's.
4. The round-68 spot-check lesson carries unlabelled dead citations (`c1-base.txt` at lines 58, 346) and two absolute host paths (202, 290) (M69-8). Out of this seat's write scope.
5. Lane-tip citations gate reads unresolved=32 vs 19 at BASE; not attributed here.

## Ceilings

- The `mismatches=13` BASE reading of the C1 counter is not measured (counter absent); the 13 defects are measured by hand (`base-13-legs.txt`).
- The S169 quote is located on the committed capture by the lane normalizer; it is not located in raw bytes (line-wrapped in the page's rendering is not claimed).
- The expansion number is a mid-wave derivation; the L1 re-derives it.

## Tooling

No installs, upgrades or pacman transactions. Tools used: `bash`, `python3`, `curl` (already on the host), `git` (read-only: `log`, `show`, `archive`, `ls-tree`, `status`, `diff`, `rev-parse`). No commits, no branch or index changes, no fleet-root writes.

## Scratch

Scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r69/R69ScribeLesson/` (BASE and candidate copies, fixtures, C2 scratch) is removed at exit after the receipts above were copied.
