# Round 42 — frozen plan (kagi, attempt 1)

Claim BASE: `e8265c0d90b01fcce0447d2f70615b0592ed145f` (lane `master` at round start; the round-41 integrator spot-check is its tip commit). Predeclaration (this plan, its counters, the controls runner and the BASE receipts under `.ufo/waves/round-42/controls/`) is committed alone before any candidate work. Frozen predicates, counters, refusal tokens, targets and kill rules below are not amended after data. A correction to this plan is appended only before the first candidate commit, and is named in the lesson.

Axes: C1 → **calibration**; C2 → **freshness**. Every axis stood at 9 at the round-41 close; the claims are measured against the BASE readings below, and no axis score is re-scored (the rows record what moved, as in rounds 36–41).

Shape: ONE v1 build wave of 9 seats (executor 2, scout 1, scribe 1, connector 1, reviewer 2, critic 1, mutation-tester 1); attack seats = reviewer 2 + critic 1 + mutation-tester 1 = 4/9 (44 %, floor 25 %); connector 1 (≤2). The planner seat is the L1 (the validator rejects the role); the L1 holds the §3 planner duty and records it in the report.

Frontier step (§2b): census before `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, rows=98 (`SOURCES_CENSUS`: rows 98, A 94, B 2, C 2, queued 1, mined 93, rejected 4). Round-start evidence: `.ufo/waves/round-42/controls/`. Mistake mined: M41-4 (below). Sourced claim: C1 rests on the append-only rule of `corpus/SOURCES.md` (registry row S094, CORPUS.md, re-opened this round; see the lesson's Gate).

## C1 — calibration: an unjournaled ledger-row deletion is refused

**Improves:** the journal gate `corpus/expect-journal.sh` (round 41) refuses every changed expectation without a migration record, but a *deleted* row is in neither population of its frozen classes: a base row removed from the candidate ledger with no journal entry passes `CLEAN` (round-41 spot-check, routed item 4; reviewer attack A6).

**Frozen predicate** (the same sentence appears in `plans/round-42-c1.sh`'s header and in the receipt label): `plans/round-42-c1.sh` prints ONE unsigned integer N = the number of the five forgeries F1–F5 that `corpus/expect-journal.sh` refuses with its frozen token (rc 1 and the exact line `EXPECT_JOURNAL: REFUSE <token>`), counted only if the gate accepts the positive control P0 (rc 0); if the gate is missing, P0 is refused, or P0 errors, N = 0.

- F1–F4: the round-41 forgeries, unchanged (R13-01 unjournaled loosening → `UNJOURNALED R13-01`; R21-02 forged old_expect → `OLD_MISMATCH R21-02`; R13-01 non-literal with forged new_expect → `NOT_LITERAL R13-01`; R24-06 command rebound → `COMMAND_MISMATCH R24-06`).
- F5 (new): the P0 ledger with row `R17-02` deleted; the P0 journal unchanged. `R17-02` is in the base ledger (6cc8850) and in no migration journal. Token: `DELETED R17-02`.
- P0: round-40 landed ledger `6f1588c` with its round-40 journal (accepted by the round-41 gate: `CLEAN (changed=6 journaled=6)`).

**Target:** N = 5 at the candidate.

**Candidate rule the gate must implement** (executor's work): for every base-ledger id absent from the candidate ledger, refuse with `DELETED <ID>`, unconditionally (there is no journal form for a deletion in this round; a future retirement form is a new contract version, never a loosened migration). The existing classes, the four-column ledger format and the migration schema stay unchanged. `MISSING_ROW` (journaled id absent from the candidate) is kept.

**No-work control:** the round-41 gate at the claim BASE (which accepts F5) reads **4** (`.ufo/waves/round-42/controls/c1-base.txt`). A blanket-refuse gate reads **0** (P0 refused), a blanket-accept gate reads **0** (`c1-control-accept-all.txt`, `c1-control-refuse-all.txt`). A do-nothing candidate therefore cannot reach the target.

**Kill rule:** C1 is not admitted if (a) the candidate gate refuses P0 or any of the six round-41 migrations at the round-41 landing check (`--base-ledger` = the 5142b52 ledger, `--ledger` = the candidate's `corpus/claim-ledger.tsv`, journal = the round-41 journal, expected `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`); (b) N < 5 at the candidate; or (c) the gate's own selftest does not pass with the F5 case added.

**Declared ceilings (not claimed as closed):** the gate does not re-run commands and does not judge reason text; a deleted row with a journal entry whose id survives is refused by `MISSING_ROW` (unchanged); the rule refuses a *legitimate* future retirement until a retirement form exists (an operator-visible cost, not a silent loosening); the F5 counter forges one row only.

## C2 — freshness: the committed controls runner re-derives the C2 BASE receipt from the pinned revision

**Improves:** `plans/round-41-controls.sh` writes `.ufo/waves/round-41/controls/c2-base-19025d9.txt` by running the C2 counter in the lane *worktree*. At the claim BASE the committed receipt reads **1** (`.ufo/waves/round-41/controls/c2-base-19025d9.txt`), the same runner run at the same commit reads **3** (`.ufo/waves/round-42/controls/c2-worktree-at-base.txt`): the receipt is not re-derivable from the revision it names. Round-41 spot-check item 6 and critic defect 1 routed this.

**Frozen predicate** (the same sentence appears in `plans/round-42-c2.sh`'s header and in the receipt label): `plans/round-42-c2.sh` prints ONE unsigned integer N in {0,1}. N = 1 iff, in a clean clone of the candidate commit (the argument, default HEAD), running that clone's `plans/round-41-controls.sh` writes `.ufo/waves/round-41/controls/c2-base-19025d9.txt` whose last line equals D, where D is the frozen C2 counter (`plans/round-41-c2.sh`, copied from the candidate) run in a `git archive` of the claim BASE `19025d9` (its own normalizer, registry and fetch rows), AND D equals 1. Otherwise N = 0.

**Target:** N = 1 at the candidate.

**Candidate rule the runner must implement** (executor's work): the runner's C2 BASE line is produced by running the C2 counter in a `git archive 19025d9` extraction, with the counter copied in from the lane, never in the lane worktree. The runner's other lines and its C1 controls stay unchanged.

**No-work control:** the committed runner at the claim BASE reads **0** (its receipt is 3, D is 1): `.ufo/waves/round-42/controls/c2-base.txt`. The derivation D reads **1** (`.ufo/waves/round-42/controls/c2-derivation-D.txt`).

**Kill rule:** C2 is not admitted if (a) the candidate receipt is not `1` in a clean clone of the candidate; (b) the runner still reads the worktree for the BASE line; or (c) the committed receipt in the candidate tree differs from the runner's output at the candidate.

**Declared ceilings:** the counter checks the receipt value against D, not the runner's source — a runner that writes the constant `1` passes (named ceiling; the counter's own derivation is the control against it, and the candidate's runner is reviewed as code). The claim does not re-derive the round-41 C1 BASE; it is the round-41 C2 receipt only.

## Routed (named, not claimed this round)

- Mutation runner anchors match 4 of 11 round-41 C1 mutants on the real gate (`.ufo/waves/round-41/mutants-landing.txt`) — the round-42 mutation seat re-runs the mutants on the candidate gate; survivors are routed unless they are the F5 rule itself.
- `expect-journal.sh` `*.json` discovery fails closed (exit 2) on a wave directory (routed item 2) — frozen-interface change, round-43.
- C3 counter defects M40-9 / M40-10 / M40-17 (stub selftests, constant counters, HTML-comment heading case) — round-43.
- Gate-selftest scratch defaults `${TMPDIR:-/tmp}` at `corpus/anchor-pins.sh:37`, `corpus/claims-declared.sh:37`, `corpus/prefreeze-control.sh:94,274`, `corpus/self-description-sweep.sh:226`, `corpus/surface-census.sh:275` (round-41 routed item 2; a QUALITY-class defect of `/tmp` scratch, `plans/round-40` uses `HYAKU_SCRATCH`) — round-43; this round edits only `corpus/expect-journal.sh` and `plans/round-41-controls.sh`.
- Round-40 report amended in place (round-41 routed item 6) — an appended erratum is owed; not claimed.
- Plan §C1 of round 41 says the gate "accepts F1–F4 by construction"; F4's echo construction is refused by the old gate's policy allowlist (`first-token:echo`) — recorded as an erratum in the round-42 lesson, not by rewriting round-41's frozen plan.
- Considerthese `2026-10-26.md` proposals 1 and 3 remain unimplemented (proposal 3: `KNOWN_DEFECT` qualifier; proposal 1: repair-only release path under HOLD). No separable claim slot this round: both need a new predicate, and proposal 1 is operator policy.

## Controls and receipts

All committed with this plan under `.ufo/waves/round-42/controls/`: `c1-base.txt` (4), `c1-control-refuse-all.txt` (0), `c1-control-accept-all.txt` (0), `c2-base.txt` (0), `c2-derivation-D.txt` (1), `c2-worktree-at-base.txt` (3, the direct worktree reading). Commands: `bash plans/round-42-controls.sh` (writes the receipts) and `bash plans/round-42-c1.sh`, `bash plans/round-42-c2.sh` (the counters).
