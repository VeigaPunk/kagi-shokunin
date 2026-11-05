source: S094 (`https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`, re-opened 2026-11-05, byte-identical to the committed round-39 capture `.ufo/waves/round-39/capture/S094.body`); the frozen counters, the frozen plan and the receipts under `.ufo/waves/round-42/` are the evidence for the rest

# Round 42 — journal-gate deletion refusal (C1, calibration), pinned-revision controls receipt (C2, freshness)

Frozen plan: `plans/round-42.md`, predeclaration `98dd4de`; amendments A1 `fdbb83d` (the C2 counter's
derivation source is `5142b52`) and A2 `ca0c6a9` (the C2 counter deletes the clone's receipt before the
runner runs). Candidate: `d00a543`. Claim BASE: `e8265c0d90b01fcce0447d2f70615b0592ed145f` (the
round-41 integrator spot-check, the lane tip at round start). C1 positive control P0
`6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`; C1 base ledger `6cc8850dfc5757927699e5a53a876f47c8df21aa`.
Section order follows `corpus/lessons/round-41.md` (Claims before Gate).

## Claims

- **C1 calibration — `bash plans/round-42-c1.sh` 4 → 5.** BASE **4** at `e8265c0`: the round-41 gate
  refuses F1–F4 with their frozen tokens and accepts F5 (base row `R17-02` deleted, no journal entry), so
  N = 4 (`.ufo/waves/round-42/controls/c1-base.txt`). The blanket-refuse and blanket-accept controls read
  **0** and **0** (`c1-control-refuse-all.txt`, `c1-control-accept-all.txt`), so neither a do-nothing
  gate nor a blanket gate reaches the target. **Candidate reading: 5** (`.ufo/waves/round-42/final/c1-final.txt`,
  measured at `d00a543`); blanket controls at the candidate 0 and 0 (`final/c1-blanket-refuse.txt`,
  `final/c1-blanket-accept.txt`). Target met.

  Frozen predicate (verbatim, `plans/round-42.md` §C1): *"prints ONE unsigned integer N = the number of
  the five forgeries F1–F5 that `corpus/expect-journal.sh` refuses with its frozen token (rc 1 and the
  exact line `EXPECT_JOURNAL: REFUSE <token>`), counted only if the gate accepts the positive control P0
  (rc 0); if the gate is missing, P0 is refused, or P0 errors, N = 0."*

  F1–F4 are the round-41 forgeries, unchanged. F5 is new: the P0 ledger with `R17-02` deleted and the P0
  journal unchanged; token `DELETED R17-02`. `R17-02` is a row of the base ledger `6cc8850`, of P0 and of
  `e8265c0`, and it appears in no round-40 or round-41 migration journal (measured by the reviewer seat,
  `.ufo/waves/round-42/build/K42ReviewC1/attacks.md` attack 2). The candidate rule: every base-ledger id
  absent from the candidate ledger is refused with `DELETED <ID>`, unconditionally; the existing classes,
  the ledger format and the migration schema are unchanged; `MISSING_ROW` is kept.

  Kill rule (verbatim, `plans/round-42.md` §C1): *"C1 is not admitted if (a) the candidate gate refuses P0
  or any of the six round-41 migrations at the round-41 landing check (...), expected `EXPECT_JOURNAL:
  CLEAN (changed=6 journaled=6)`; (b) N < 5 at the candidate; or (c) the gate's own selftest does not pass
  with the F5 case added."* Measured at `d00a543`: (a) `final/landing-r41.txt` → `EXPECT_JOURNAL: CLEAN
  (changed=6 journaled=6)`, rc 0, and P0 accepted (N = 5 requires it); (b) N = 5; (c) `final/gate-selftest.txt`
  → `EXPECT_JOURNAL_SELFTEST: PASS (cases=8)`, rc 0. No kill clause fires.

  Wording erratum (critic F4, F5, F6; the plan body is not rewritten): the plan's "Improves" sentence says
  the round-41 gate refuses an unjournaled change *and* the deletion case "passes CLEAN" without bounding
  the population. What is measured is one deletion (F5) and the rule for every base id by construction.
  The claim is therefore stated as: *the gate refuses the frozen F5 deletion and, by rule, every base id
  absent from the candidate.* The ceiling sentence "a deleted row ... is refused by `MISSING_ROW`" applies
  only to a deleted row whose id still has a journal entry. Kill clause (c) is testable as written: run
  `--selftest` and read the case count (done above).

  Declared ceilings, carried from the plan (not claimed as closed):
  - the gate does not re-run commands and does not judge reason text;
  - the rule refuses a legitimate future retirement until a retirement form exists (an operator-visible
    cost, not a silent loosening);
  - F5 forges one row only.

  Ceilings added by this round's attack seats (named here, not closed):
  - **Answer-key gate (reviewer attack 3, `.ufo/waves/round-42/build/K42ReviewC1/attacks.md`).** A gate
    that reads the journal and hardcodes the five per-id answers reaches N = 5 with both blanket controls
    at 0 (its fake gate `fakeC`: 5). The counter measures the token output of the gate it is given, not
    the gate's logic. The gate's logic is measured only by its own selftest (8 cases, F1–F5 among them)
    and by the candidate's code review; the blanket controls do not discriminate an answer key.
  - **Value-only counter mutants (mutation battery, `.ufo/waves/round-42/build/K42MutCounters/mutants.md`).**
    Two counter-level mutants survive every frozen control: `c1-M3` (the P0 guard deleted, so a gate that
    refuses P0 with a valid token is not forced to N = 0; a token-refusing gate reads 1 against the
    pristine 0) and `c1-M5` (the per-token check dropped, so a rc-1 refusal with a wrong token counts). The
    frozen blanket-refuse fixture refuses token-lessly and is filtered by the per-token grep, so no frozen
    control has the shape that would kill `c1-M3` or `c1-M5`. Named ceiling; a new control is a future
    round's frozen-predicate amendment, not this round's.

- **C2 freshness — `bash plans/round-42-c2.sh` 0 → 1.** BASE **0** at `e8265c0`: the committed runner
  `plans/round-41-controls.sh` runs the C2 counter in the *worktree*, and the worktree reads **3** while the
  committed receipt `.ufo/waves/round-41/controls/c2-base-19025d9.txt` reads **1**
  (`.ufo/waves/round-42/controls/c2-worktree-at-base.txt`, `c2-base.txt` = 0). The frozen derivation
  D reads **1** (`c2-derivation-D.txt`, the round-41 counter from `5142b52` over a `git archive 19025d9`).
  **Candidate reading: 1** (`.ufo/waves/round-42/final/c2-final.txt`, measured at `d00a543` by running the
  committed runner in a clone of the candidate). Target met.

  Frozen predicate (verbatim, `plans/round-42.md` §C2, with A1's source pin): *"prints ONE unsigned integer
  N in {0,1}. N = 1 iff, in a clean clone of the candidate commit (...), running that clone's
  `plans/round-41-controls.sh` writes `.ufo/waves/round-41/controls/c2-base-19025d9.txt` whose last line
  equals D, where D is the frozen C2 counter (...) run in a `git archive` of the claim BASE `19025d9`, AND D
  equals 1. Otherwise N = 0."* A1 pins the frozen counter's source to `git show 5142b52:...`; A2 deletes
  the clone's receipt before the runner runs and requires the runner's exit status to be 0.

  Kill rule (verbatim): *"(a) the candidate receipt is not `1` in a clean clone of the candidate; (b) the
  runner still reads the worktree for the BASE line; or (c) the committed receipt in the candidate tree
  differs from the runner's output at the candidate."* Measured at `d00a543`: (a) N = 1 means the candidate
  receipt is 1 in a clean clone; (b) the patched runner's BASE line runs `git archive 19025d9` and
  `git show 5142b52:...` (the diff in `.ufo/waves/round-42/build/K42ExecRunner/patch.diff`); the sabotage
  copy that runs the worktree reads 3 (`build/K42ExecRunner/mutant-run.txt`); (c) the committed receipt
  `c2-base-19025d9.txt` is `1` and the patched runner writes `1` (`build/K42ExecRunner/fixed-run.txt`). No
  kill clause fires.

  Ceilings (declared, and the two found pre-freeze):
  - **Value-only (plan §C2, declared).** The counter checks the receipt value against D, not the runner's
    source: a runner that writes the constant `1` passes (`c2-M1` above is a counter mutant that the BASE
    control kills; the runner-side constant-1 survives by construction). Reviewer attack 2 added: a runner
    that copies a receipt from any later commit `≥ 5142b52` containing `1` also passes (`git show
    e8265c0:<receipt>` → `N=1`). Named ceiling; the candidate runner is reviewed as code.
  - **Do-nothing hole, found by the critic and closed by A2.** Before A2 a runner that writes nothing read
    `N = 1` from the committed receipt (critic F1; `.ufo/waves/round-42/build/K42CriticClaims/receipt-stale-receipt-attack.txt`),
    contradicting the plan's "not reachable by do-nothing". A2 deletes the receipt first. Measured after A2:
    a do-nothing runner in a fixture clone reads 0 (`fixture noop` run, recorded in the report), and the
    committed runner at `ca0c6a9` reads 0.
  - **Counter copied from the lane (critic F2, reviewer attack 3 — pre-A1 state).** Closed by A1: the
    derivation D reads `git show 5142b52:plans/round-41-c2.sh`, so a one-line edit to the lane's
    `plans/round-41-c2.sh` cannot move D. The critic's F2 was measured at `98dd4de`, before A1, which is why
    it reads as a live defect in its report; at `fdbb83d` and later it does not.
  - **Frozen-bytes check (critic F3).** Closed by check, not amendment: the counters and controls are
    byte-identical from `ca0c6a9` (the A2 commit) to the candidate `d00a543` (`git diff --quiet ca0c6a9 HEAD
    -- plans/round-42-c1.sh plans/round-42-c2.sh plans/round-42-controls.sh plans/round-41-c2.sh
    plans/round-42.md` → exit 0, recorded in the report). `plans/round-41-c2.sh` is unchanged since
    `5142b52`.

- **Base context (measured at the claim BASE `e8265c0`, not re-derived as a claim).** SOURCES census `kagi ok`,
  98 rows (A 94, B 2, C 2, queued 1, mined 93, rejected 4), W04 warnings 19; ledger 86 ids, no id removed
  across `6cc8850`, `6f1588c` and `e8265c0`; verify BASE red set FAIL `R11-08`, `R22-03`, `R24-15`,
  `R25-02`, `R36-03`, POLICY `R29-01`, `R29-02`, `R38-03` (`.ufo/waves/round-42/` evidence from the L1
  run; none of these rows belongs to C1 or C2).

## Gate

- **S094 — re-opened this round.** `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`,
  tier A (own-work; the registry's append-only rule). Access: re-fetched **2026-11-05** with
  `curl -fsSL --compressed`; HTTP **200**, no redirect; decoded body **11296** bytes, sha256
  `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8` — equal to the committed fetch row's
  sha and byte count, and `cmp` against `.ufo/waves/round-39/capture/S094.body` exits 0 (no drift; scout
  receipt `.ufo/waves/round-42/build/K42ScoutS094/notes.md`). Located quote, 8 whitespace tokens (≤ 25):
  *"Only `status`, `recheck` and `used-by` change in place"*, raw offset **6172**, count **1**. The rule
  line is item 2 of the registry's rules, line 116 of the served body.
  Re-open verdict: **admit as the sourced basis** of C1's append-only principle. Registry row unchanged.
  Named limit (critic F7): S094 governs `corpus/SOURCES.md`, not `corpus/claim-ledger.tsv`. C1 applies the
  principle to the ledger by analogy, and the ledger's own migration discipline (QM14) is the rule the
  journal enforces. The row's `teaches` cell carries a derived clause ("an in-place anchor rewrite violates
  this rule") that does not occur in the served body (`grep -c -F` → 0); that clause is the round-40 M40-1
  defect class and is not repaired here, because the row is append-only.
- **Rows added:** none. **Rows touched old → new:** none (the census still reads `kagi ok`, 98 rows).
- **Admit / reject on this round's candidate material:** no new knowledge entry or registry row is admitted
  this round, so there is no admit/reject pair to report for the discernment spot-check; the S094 re-open is
  a verdict on an existing row, and the gate's own selftests (8 cases) are the instrument-level discrimination.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M41-4 | controls runner wrote a worktree reading into a committed BASE receipt; the receipt is not re-derivable from the revision it names | `.ufo/waves/round-42/controls/c2-worktree-at-base.txt` (worktree **3**), `c2-base.txt` (**0**), committed receipt `.ufo/waves/round-41/controls/c2-base-19025d9.txt` (**1**): three values for one named receipt. Routing: round-41 lesson §Routed item 6; critic defect 1 | `none` | C2: the runner's C2 BASE line comes from a `git archive 19025d9` extraction with the frozen counter from `5142b52`. The fix is shown able to fail: the unfixed runner reads 0 against the frozen no-work control, and the sabotage copy that reads the worktree reads 3 (`build/K42ExecRunner/mutant-run.txt`) |
| M41-5 | a frozen plan sentence overstates what the old gate accepts: "accepts F1–F4 by construction" is false for F4 | `plans/round-41.md` §C1 against `corpus/claim-ledger.sh` (the policy allowlist, `ALLOWED_RE`, and the first-token refusal `first-token:echo`): F4's construction rebinds R24-06's command to an `echo`, which the old gate's allowlist refuses before the command runs. Routing: round-41 lesson §Routed item 5; round-41 spot-check §6 item 7 | `none` | erratum in this lesson; the round-41 frozen plan is not rewritten. Round-42 does not repeat the sentence |
| M41-6 | journal gate blind spot: a base row removed from the candidate, with no journal entry, is in neither population of the frozen classes and passes `CLEAN` | round-41 lesson §Routed item 4; round-41 spot-check §6 item 4; reviewer attack A6 (`.ufo/waves/round-41/build/K41ReviewJournal/attacks.md`) | `none` | C1: the `DELETED <ID>` class, unconditional; F5 is the fifth counter forgery. Shown able to fail: the round-41 gate at the claim BASE reads F5 accepted, so BASE 4 < target 5 |
| M42-1 | a do-nothing runner read 1 from the committed receipt, so the C2 counter's no-work control was not 0 as the plan states | `.ufo/waves/round-42/build/K42CriticClaims/receipt-stale-receipt-attack.txt` (critic F1; the stale committed receipt `1` is the same file that M41-4 names); found by the critic before any candidate was measured | `none` (the plan's "not reachable by do-nothing" premise was asserted, not measured for a do-nothing runner) | A2 (`ca0c6a9`): delete the receipt before the runner runs and require exit 0. Shown able to fail: the fixture do-nothing runner reads 0 after A2 (recorded in the report), where the pre-A2 counter read 1 |
| M42-2 | the C2 counter copied the frozen counter from the candidate clone, so a candidate edit to the frozen counter could move D | my own draft of `plans/round-42-c2.sh` (caught in my re-read before any candidate existed; the critic's F2 reproduced it at `98dd4de`) | `none` | A1 (`fdbb83d`): D reads `git show 5142b52:...`; the frozen-bytes check (no counter change from `ca0c6a9` to `d00a543`) is recorded in the report |
| M42-3 | an answer-key gate reaches the C1 target with both blanket controls at 0; the declared ceilings did not name it | reviewer attack 3, `.ufo/waves/round-42/build/K42ReviewC1/attacks.md`, fake gate `fakeC` → N = 5 | `none` | named as a ceiling above (not a counter change: the predicate and the target are frozen); a control with the answer-key shape is a future round's amendment |

## Frontier

- **Calibration ground advanced.** The journal gate now refuses the one change class round 41's frozen
  classes could not see: an unjournaled deletion of a base row. The round-41 gate reads 4 on the frozen
  counter; the candidate reads 5. Two counter-level mutants and one answer-key gate survive the frozen
  controls; they are named ceilings above.
- **Freshness ground advanced.** The controls runner's C2 BASE receipt is now re-derivable from the revision
  it names: the committed runner at the candidate reads 1, the claim-BASE runner read 3 against a committed
  1. The derivation is pinned to the frozen counter at `5142b52`.
- No frontier-to-core move; no `corpus/knowledge/` entry; no registry row added or changed.
- Mistakes mined: M41-4, M41-5, M41-6, M42-1, M42-2, M42-3. Captured-by is `none` for all six. The fixes for
  M41-4, M41-6 and M42-1 are shown able to fail by their committed readings; M41-5 is an erratum; M42-2 is
  caught in the draft; M42-3 is named as a ceiling.
- Sourced claim: C1 rests on S094 (re-opened this round, Gate above).
- Assimilation: none this round.

## Routed

Named in `plans/round-42.md` §Routed and not claimed:

1. Mutation-runner anchors against the delivered gate (round-41 battery `killed=0 survived=4`).
2. `expect-journal.sh` `*.json` discovery fails closed (exit 2) on a wave directory: a frozen-interface change,
   round 43.
3. C3 counter defects M40-9 / M40-10 / M40-17 (stub selftests, constant counters, the HTML-comment heading case).
4. Gate-selftest scratch defaults `${TMPDIR:-/tmp}` in `corpus/anchor-pins.sh`, `corpus/claims-declared.sh`,
   `corpus/prefreeze-control.sh`, `corpus/self-description-sweep.sh`, `corpus/surface-census.sh`.
5. The round-40 report's owed appended erratum (round-41 routed item 6).
6. Considerthese `2026-10-26.md` proposals 1 and 3 (see below).
7. Counter-level discrimination: a control with the token-refusing shape (kills `c1-M3`, `c1-M5`) and an
   answer-key control (kills the `fakeC` gate), each a frozen-predicate amendment for a later round.
8. C2 value-only ceiling (constant-1 runner; receipt copied from a later commit): a receipt-provenance check is
   a later round's predicate.

## considerthese

The latest file is `considerthese/2026-10-26.md`. Proposal 3 ("mark known-defective instrument output" —
a `KNOWN_DEFECT: D1` qualifier on a `CLEAN` verdict) and proposal 1 ("a repair-only release path under a
HOLD") remain unimplemented. Measured at `e8265c0`: `grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → 0,
and the lane holds no HOLD-release mechanism. **Not taken this round — reason:** no separable claim slot;
both need a new predicate, and proposal 1 is operator policy.

## Assimilation

None this round. The round claims no new registry row and no knowledge entry; the sourced action is the
re-open of S094, which re-verifies ground the lane already holds.
