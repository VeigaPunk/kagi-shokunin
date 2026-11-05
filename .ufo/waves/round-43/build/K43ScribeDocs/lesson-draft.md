source: S094 (`https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`, re-opened 2026-11-05; the served body is byte-identical to the committed round-39 capture `.ufo/waves/round-39/capture/S094.body`); the frozen plan `plans/round-43.md`, the three frozen counters and the BASE receipts under `.ufo/waves/round-43/controls/` are the evidence for the rest

# Round 43 — C1 calibration instrument (six forgeries), C2 durable receipt-replay gate, C3 lane-scratch selftest discipline

Frozen plan: `plans/round-43.md`; predeclaration `a9180250955ad44530b565fa5b131b540c849199`; amendment A1 `dd6ccb92bf04a061e9f1e66913d15f097397b1b3` (both before any candidate measurement). Claim BASE: `5f3566c4cfe65a74da4d201d74d28b403929807b`. Candidate: <<FILL: candidate commit>>. Section order: Claims, Gate, Mistakes, Frontier, Routed, considerthese, Assimilation, Adjacency.

## Claims

- **C1 calibration — the C1 instrument refuses the three broken-instrument shapes the round-42 instrument accepted.** Target: N = 6 at the candidate.

  Frozen predicate (verbatim, `plans/round-43.md` §C1): *"the counter prints ONE unsigned integer N in 0..6 = the number of the six forgeries F1–F6 the gate `${EXPECT_JOURNAL:-corpus/expect-journal.sh}` refuses with its frozen token (rc 1 and the exact line `EXPECT_JOURNAL: REFUSE <token>`), counted only if the gate accepts the positive control P0 (rc 0); missing gate, refused P0 or P0 error ⇒ N = 0."*

  BASE readings at `5f3566c`, receipts under `.ufo/waves/round-43/controls/` (`measured-at.txt` = `5f3566c4cfe65a74da4d201d74d28b403929807b`), command `bash plans/round-43-controls.sh`:
  old instrument (`plans/round-42-c1.sh`) real gate **5** (`c1-old-real.txt`), +K1 **0** (`c1-old-K1.txt`), +K3 **0** (`c1-old-K3.txt`), +fakeC **5** (`c1-old-fakeC.txt`), m3+K1 **5** (`c1-old-m3-K1.txt`), m5+K3 **5** (`c1-old-m5-K3.txt`), blanket refuse/accept **0/0** (`c1-blanket-refuse.txt`, `c1-blanket-accept.txt`);
  new instrument (`plans/round-43-c1.sh`) real gate **6** (`c1-new-real.txt`), +K1 **0** (`c1-new-K1.txt`), +K3 **0** (`c1-new-K3.txt`), +fakeC **5** (`c1-new-fakeC.txt`), m3+K1 **6** (`c1-new-m3-K1.txt`), m5+K3 **6** (`c1-new-m5-K3.txt`), blanket refuse/accept **0/0**.
  The broken-instrument rejection count moves **0/3 → 3/3**: the old set passes every broken shape (survivor receipts 5/5/5); the new set refuses all three (K1/K3 hold at 0 with the mutants exposed at 6; fakeC 5 < 6). The real-gate reading moves 5 → 6.

  No-work control (verbatim, `plans/round-43.md` §C1): "the old-instrument receipts (5/5/5 survivors, real 5) and `c1-base` absence — the new counter does not exist at BASE (`bash plans/round-43-c1.sh` at `5f3566c` is a missing file), so no do-nothing state reaches N = 6 with the matrix. Committed receipts are the control." The absence is re-derived from the committed tree: `git -C <lane> show 5f3566c:plans/round-43-c1.sh` exits 128 (the file is absent at the claim BASE; it lands at the predeclaration commit).

  Candidate reading: <<FILL: C1 candidate reading>> (target 6), with the frozen matrix re-measured byte-frozen under `final/` at the candidate: <<FILL: C1 candidate matrix receipts>>. Kill-clause outcomes at the candidate: <<FILL: C1 kill-clause outcomes>>.

  Kill rule (verbatim, `plans/round-43.md` §C1): "C1 is not admitted if (a) N ≠ 6 at the candidate; (b) any of `c1-new-K1`, `c1-new-K3` ≠ 0, `c1-new-fakeC` ≠ 5, `c1-new-m3-K1` ≠ 6, `c1-new-m5-K3` ≠ 6; (c) any of `c1-old-real` ≠ 5, `c1-old-fakeC` ≠ 5, `c1-old-m3-K1` ≠ 5, `c1-old-m5-K3` ≠ 5 (the before-state moved); (d) `git diff --quiet 5f3566c HEAD -- corpus/expect-journal.sh` fails (the gate bytes were to stay untouched this round); (e) the landing check `bash corpus/expect-journal.sh --base-ledger <(git show 6cc8850:corpus/claim-ledger.tsv) --ledger corpus/claim-ledger.tsv --journals <dir with the round-40 and round-41 journals>` is not `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)` rc 0." Amendment A1 corrects clause (e) — the plan's combined two-journal form refuses — to the round-42 landing form, measured now at `5f3566c`: "Kill rule (e) is corrected to the round-42 landing form, measured now: `bash corpus/expect-journal.sh --base-ledger <(git show 5142b52:corpus/claim-ledger.tsv) --ledger corpus/claim-ledger.tsv --journals <dir holding a copy of .ufo/waves/round-41/expectation-migrations.json>` → `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`, rc 0, measured at `5f3566c` (the ledger is unchanged this round; the same command is kill rule C3 (d)). Nothing else in this plan changes."

  Declared ceilings (verbatim, `plans/round-43.md` §C1): "the counter measures token output, not gate logic — a gate keying all six answers plus P0 acceptance still passes (the answer-key class at population 6; fakeC proves the 5-key fails, a 6-key is named as surviving); the counter does not re-run commands and does not judge reason text; the mutant battery covers the guard and token drops only; F6 forges one row only."

- **C2 freshness — a committed gate durably enforces receipt re-derivability at the revision it names.** Target: N = 1 at the candidate.

  Frozen predicate (verbatim, `plans/round-43.md` §C2): *"the counter prints N ∈ {0,1}; N = 1 iff, in a shared clone of the candidate commit (argument, default HEAD), the committed gate (the clone's own `corpus/controls-replay.sh`, override `CONTROLS_REPLAY_GATE=<path>`) exits 0 on the clean clone (P1), exits 1 on a stale fixture (N1: a copy whose `round-42/controls/c2-derivation-D.txt` reads 2), and exits 1 on a silent fixture (N2: a copy whose `plans/round-42-controls.sh` is replaced by `exit 0`)."*

  BASE readings at `5f3566c`, receipts under `.ufo/waves/round-43/controls/`: base **0** (`c2-base.txt`), blanket always-0 **0** (`c2-blanket-0.txt`), blanket always-1 **0** (`c2-blanket-1.txt`). No-work control (verbatim, `plans/round-43.md` §C2): "at the claim BASE no gate exists, so `bash plans/round-43-c2.sh` reads **0** (`controls/c2-base.txt`, measured at `5f3566c`); blanket always-0 and always-1 gates read **0** (`c2-blanket-0.txt`, `c2-blanket-1.txt`), so neither a do-nothing gate nor a blanket gate reaches the target." The absence is re-derived from the committed tree: `git -C <lane> show 5f3566c:corpus/controls-replay.sh` exits 128 (no committed gate at the claim BASE).

  Candidate reading: <<FILL: C2 candidate reading>> (target 1), the direct replay receipt `final/c2-replay-direct.txt` and the byte-match of the clone's two controls dirs: <<FILL: C2 candidate receipts>>. Kill-clause outcomes at the candidate: <<FILL: C2 kill-clause outcomes>>.

  Kill rule (verbatim, `plans/round-43.md` §C2): "C2 is not admitted if (a) N ≠ 1 at the candidate; (b) the gate refuses the clean clone or accepts either fixture in a direct run (`final/c2-replay-direct.txt` not rc 0); (c) the clone's controls dirs do not byte-match their committed state after the direct replay (the restore duty); (d) either blanket receipt ≠ 0 re-measured at the candidate."

  Declared ceilings (verbatim, `plans/round-43.md` §C2): "a gate that special-cases the three invocation shapes passes the counter — the gate's default verification is reviewed as code; a runner hardcoding all eight manifest values passes the byte comparison — the runners are reviewed as code and D is pinned to `5142b52` by round-42 amendment A1; the counter checks the manifest set only, not files outside it."

- **C3 operability — the five gate selftests honour the lane scratch root, not `${TMPDIR:-/tmp}`.** Target: N = 5 at the candidate. The gate set is scanned under `C3_ROOT` so the controls runner can point the counter at fixture trees.

  Frozen predicate (verbatim, `plans/round-43.md` §C3): *"the counter prints N in 0..5 = the number of the five gates satisfying all three legs: (1) no `TMPDIR:-/tmp` in the gate bytes; (2) the selftest scratch default names `${HYAKU_SCRATCH:-/fast/scratch/hyaku}`; (3) executed: `HYAKU_SCRATCH=<scratch>/probe bash <gate> --selftest` exits 0 with the frozen last line — `ANCHOR_PINS_SELFTEST: PASS (8 cases)`, `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`, `PREFREEZE_SELFTEST: PASS (25 cases)`, `SELFTEST: PASS (10 cases)`, `SELFTEST: PASS (16 cases)` — all five measured passing at BASE (L1, this round, scratch probe)."*

  BASE readings at `5f3566c`, receipts under `.ufo/waves/round-43/controls/`: base **0** (`c3-base.txt`), one-gate-fixed fixture **1** (`c3-pos.txt`), all-greps-fixed-but-selftest-sabotaged fixture **4** (`c3-blanket.txt`). No-work control (verbatim, `plans/round-43.md` §C3): "at the claim BASE all five gates carry the `TMPDIR:-/tmp` default, so leg (1) fails for every gate: N = **0** (`controls/c3-base.txt`). Fixture controls: a tree with exactly one gate fixed reads **1** (`c3-pos.txt`); a tree with every grep leg fixed but surface-census's selftest PASS token sabotaged reads **4**, never 5 (`c3-blanket.txt`) — the executed leg is load-bearing." The BASE state is re-derived from the committed tree: the five gates carry `TMPDIR:-/tmp` at `5f3566c` (`corpus/anchor-pins.sh` 1 occurrence, `corpus/claims-declared.sh` 1, `corpus/prefreeze-control.sh` 2, `corpus/self-description-sweep.sh` 2, `corpus/surface-census.sh` 1 — `git show 5f3566c:<gate> | grep -c 'TMPDIR:-/tmp'`).

  Candidate reading: <<FILL: C3 candidate reading>> (target 5), with `c3-pos` and `c3-blanket` re-measured at the candidate and the touched ledger rows re-run individually: <<FILL: C3 candidate receipts>>. Kill-clause outcomes at the candidate: <<FILL: C3 kill-clause outcomes>>.

  Kill rule (verbatim, `plans/round-43.md` §C3): "C3 is not admitted if (a) N ≠ 5 at the candidate; (b) `c3-pos` ≠ 1 or `c3-blanket` ≠ 4 re-measured at the candidate; (c) any of the touched ledger rows re-run individually departs from its BASE verdict: R11-03 (`bash corpus/surface-census.sh --selftest` → `SELFTEST: PASS (16 cases)` rc 0), R33-01 and R34-02 (`PREFREEZE_SELFTEST: PASS (25 cases)` rc 0), R34-01 (`SELFTEST: PASS (10 cases)` rc 0); (d) the landing check of C1 kill rule (e) is not CLEAN (the ledger is unchanged; no journal is needed); (e) the landed diff touches anything beyond the seven frozen replaces."

  Declared ceilings (verbatim, `plans/round-43.md` §C3): "a comment-only or grep-only "fix" that drops the executed leg would read 5 — `c3-blanket` = 4 proves the executed leg discriminates; the counter does not verify where the selftests write beyond the probe run; case counts are frozen to today's measured values."

## Gate

- **S094 — re-opened this round.** URL `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`; access date **2026-11-05**; HTTP 200 with 0 redirects and the decoded body 11296 bytes, sha256 `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8` (scout receipt `.ufo/waves/round-43/build/K43ScoutS094/notes.md`; re-derived by this seat over the scout's committed capture `.ufo/waves/round-43/build/K43ScoutS094/CORPUS-live.md`: `sha256sum` = the same digest, `stat -c %s` = 11296, `cmp` against `.ufo/waves/round-39/capture/S094.body` exit 0 — no drift).
  Located quote, 8 whitespace tokens (≤ 25): *"Only `status`, `recheck` and `used-by` change in place"*; raw byte offset **6172**, occurrence count **1**, served-body line **116** (`grep -b -o -F` / `grep -c -F` over the same capture).
  Re-open verdict: <<FILL: S094 re-open verdict>>.
  Used-by old → new: <<FILL: S094 used-by old→new>> (the old value, measured now at `corpus/SOURCES.md` line 101, is `corpus/lessons/round-39.md`; the scout's proposed new value and the census's dangling-used-by constraint are in `.ufo/waves/round-43/build/K43ScoutS094/notes.md` §3 — the L1 lands the cell, this seat does not edit `corpus/SOURCES.md`).
  Rows added: none. Rows touched: S094 only, `used-by` only.
  Named limit (carried, not repaired): the row's `teaches` cell mixes the verbatim quote with a derived clause that does not occur in the served body (`grep -c -F 'an in-place anchor rewrite violates this rule'` → 0); `teaches` is not one of the three cells rule 2 lets change in place, so the fix is a new row, not an in-place repair (round-40 M40-1 class; round-42 critic F7). S094 governs `corpus/SOURCES.md`, not `corpus/claim-ledger.tsv`; C1's use of it on the ledger is by analogy.
  Census before the wave: `kagi ok`, exit 0, 98 rows (19 W04 duplicate-url warnings; warnings allowed). Registry row count before: 98 (`grep -c '^| S[0-9]' corpus/SOURCES.md` → 98).

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M42-4 | a report's diff-stat sentences disagree with the diff they describe: "+23/−3" and "+7/−1" against `git diff --numstat` "21 2" and "6 1" | fleet-root `.ufo/reports/round-42/kagi.md` item 6 (line 20) against `git -C <lane> diff --numstat e8265c0d90b01fcce0447d2f70615b0592ed145f d00a543 -- corpus/expect-journal.sh plans/round-41-controls.sh` → the two lines "21 2 corpus/expect-journal.sh" and "6 1 plans/round-41-controls.sh" (tab-separated), exit 0; routing: round-42 verifier spot-check §6 item 1 | `none` | QUALITY row QM46: every report diff-stat is re-derived by `git diff --numstat` before the report is filed. The round-42 numbers are non-verdict-bearing — the claim counters do not depend on line counts — so the fix is a criterion, not a rewrite of the round-42 report bytes |
| M42-5 | the round's build-results file carried no per-seat `status` field, so seat liveness was not explicit per seat | `.ufo/waves/round-42/build-results.json`: each entry in `results` carries `name`, `agent`, `note`, `output` and no `status` key; routing: round-42 verifier spot-check §6 item 3 | `none` | per-seat `SEAT-STATUS` in every wave prompt and a per-seat status in the round report, taken from `results.json` |
| <<FILL: M43-1 id>> | restore-on-refusal gap: a gate that byte-compares and only then restores leaves the clone's controls dirs dirty on a refusing run, while the frozen kill rule pins only the clean-clone direct run | `.ufo/waves/round-43/build/K43ReviewC2/attacks.md` (defect D1) — the stale fixture leaves ` M c1-base.txt`, ` M c2-base.txt`, ` D c2-worktree-at-base.txt` and the silent fixture leaves six deleted receipts | `K43ReviewC2` | <<FILL: M43-1 fix>> |
| <<FILL: M43-2 id>> | receipt-file naming breaks traceability: every frozen receipt is cited with a `.txt` suffix while the committed predeclaration files are extensionless | `.ufo/waves/round-43/build/K43ReviewC2/attacks.md` (defect D2) — plan §Controls and `plans/round-43-c2.sh` header cite `c2-base.txt`, the committed file is `controls/c2-base` | `K43ReviewC2` | <<FILL: M43-2 fix>> |
| <<FILL: M43-3 id>> | any further mistake the round-43 attack seats name after this draft | `.ufo/waves/round-43/build/` (reviewer, critic and mutation-tester seats) | <<FILL: M43-3 captured-by>> | <<FILL: M43-3 fix>> |

## Frontier

- **Calibration ground advanced.** The C1 instrument now has a forgery population of six and rejects the three broken-instrument shapes the round-42 instrument accepted: the broken-shape rejection count moves 0/3 → 3/3 at the BASE tree, and the real-gate reading moves 5 → 6. What moved is the instrument's discrimination, not the gate: the gate bytes stay untouched this round (kill clause (d)).
- **Freshness ground advanced.** The one-shot round-42 C2 counter becomes a committed gate (`corpus/controls-replay.sh`) that durably enforces receipt re-derivability, so the property survives the close of this round instead of living only in a frozen counter.
- **Operability ground advanced.** Five gate selftests move from the `${TMPDIR:-/tmp}` default to the lane scratch root `${HYAKU_SCRATCH:-/fast/scratch/hyaku}`, by the seven frozen replaces only.
- No frontier-to-core move; no `corpus/knowledge/` entry; no registry row added.
- Rows touched: S094 only — `used-by` old → new: <<FILL: S094 used-by old→new>>.
- Mistakes mined: M42-4, M42-5, plus the round-43 rows the attack seats name (<<FILL: M43 mistake ids>>).
- Sourced claim: C1 rests on S094 (re-opened this round, Gate above).

## Routed

Named in `plans/round-43.md` §Routed and not claimed this round:

1. `expect-journal.sh` `*.json` discovery failing closed (exit 2) on a wave directory — a frozen-interface
   change needing its own predicate; no slot (three claims frozen).
2. C3 counter defects M40-9 / M40-10 / M40-17 (round-40 instruments are closed-round evidence;
   rewriting them is a re-freeze, not a patch).
3. The owed appended erratum to the round-40 report (round-41 routed item 3) — the erratum lands in
   this round's lesson naming the amended-in-place report, not by editing the round-40 report bytes
   (the L1 write scope covers `.ufo/reports/round-43/kagi.md` only).
4. Considerthese `2026-10-26.md` proposals 1 and 3 (unchanged reason: proposal 1 is operator policy
   under HOLD; proposal 3 needs its own predicate; no slot).
5. L0 open (operator-owned): `.ufo/l0-questions.md` line 368 — the retirement form for the
   unconditional `DELETED` rule; routed around, not assumed.
6. A 6-key answer-key gate passes the new C1 counter (named ceiling above) — a shape-level control
   is a later round's predicate amendment.
7. The old counter's mutants (`mut-m3-old`, `mut-m5-old`) are receipts, not committed instruments;
   a durable counter-mutation battery is later work if the fleet wants it.

## considerthese

The latest file is `considerthese/2026-10-26.md`. Proposal 1 ("a repair-only release path under a HOLD") and proposal 3 ("mark known-defective instrument output") remain unimplemented. **Not taken this round — reason:** no separable claim slot (the three claims are frozen); proposal 1 is operator policy under HOLD and proposal 3 needs its own predicate.

## Assimilation

None this round. No merge or kagi knowledge entry fits the three frozen instrument claims; the round's sourced action is the S094 re-open, which re-verifies ground the lane already holds.

## Adjacency

<<FILL: adjacency scan>>
