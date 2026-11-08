# R63Critic — attack report (C1 calibration, C2 operability)

Seat `R63Critic`, kagi round 63 attempt 1. Read-only over the lane; full evidence and every
command output in `.ufo/waves/round-63/build/R63Critic/critique.md` and `receipts.md`.
No lane commit; no mutating git/jj; no host mutation; no tool installs.

## What re-derives

- **C1 BASE census**: all 16 anchors occur exactly once; F1..F10 read
  `C1_ROUTED: value=0` (accepted), P1..P6 read `value=1` (rejected) with `i3=0` for
  P1/P2, `i4=0` for P3/P4, `i5=0` for P5/P6; the unmodified copy reads `value=0`.
  **accepted = 10, rejected = 6** — the declared population is non-vacuous.
- **C2 BASE legs**: CM2a and CM2b each read `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0;
  the GM5 mutant reads `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0; the S3 tree reads
  `C2_HARDENED: SETUP needle-ma` rc 2 (`plans/round-62-c2.sh:279` already carries the
  guard) — **L5 is vacuous at BASE, as A2 says**; the real trial reads
  `killed=3 population=3 guard=1 (… real=1)` rc 0.

## Findings (high)

1. **C1-1 — the target is reachable with no grammar.** A 15-string lookup-table checker
   (the ten F replacements + five B replacements) with a constant
   `C1_CHECK_SELFTEST: PASS (cases=91)` selftest reads F1..F10 `value=1`, P1..P6 `value=0`,
   B3..B7 `value=1`, P3..P5 `value=0`, unmodified `value=0` — every frozen guard leg
   (a)–(e) passes and `accepted=0 rejected=0` is met. The round-62 counter refuses the same
   tree only through its `chal` leg (`C1_BYPASS: … guard=0 (… chal=0)`); the round-63
   guard has no `chal`, and K5's mutated-copy test is not a counter leg.
2. **C1-2 — the frozen C1 command line is not executable on the BASE checker.** `--fleet`
   is an unrecognized argument (`rc=2`, usage error); the L1 census silently omits it, so
   the census was measured with a different command than the predicate prints.
3. **C1-3 — the plan's I6 text cannot reject B6.** B6 (`the paragraph's times are
   correct.`) is rejected only by the BASE checker's `I6_DENY_PHRASES` (round-62 A1); the
   plan's I6 item (launch line + ≥3 derived stamps + quoted superseded span) has no denial
   clause, so a literal implementation accepts B6 and guard leg (c) fails.
4. **C1-4 — the plan's I4/I5 texts name no line/file scope.** The BASE checker scopes I4
   to the last quality-trend line and I5 to the last LOG wave line; `rewritten in place`
   occurs in 71 tree files, so a whole-file I5 resolves F7 (and the other `three`
   occurrences resolve F4/F5/F6). Round-62 critic D1/D2 recur.
5. **C2-1 — population/target identity conflict.** A2 (population 5, no L5) contradicts
   the C2 seat's dispatch prompt (population 6, L1–L6, acceptance `killed=0 population=6`)
   and the milestone (`killed 0->6`). L5 fires at BASE, so a 6-leg counter reads
   `killed>=1` at BASE and fails its own acceptance; a 5-leg counter contradicts the
   prompt and the milestone.
6. **C2-2 — the L5 premise in the seat prompt is false.** The prompt says the M-A leg has
   no `setup needle-ma`; `plans/round-62-c2.sh:279` already carries it at BASE.
7. **C2-3 — L1/L2 depend on a file the C2 seat does not own.** L1/L2 mutate
   `plans/round-62-c1.sh`, which the C1 counter seat is told to refactor (extract the
   exact L1 needle line into `stub_calc`); a byte-changing refactor makes the L1 mutation
   match 0 times → SETUP → the C2 target unreachable. The legs also require a `FINDING`
   line; the C1 counter's selftest prints `failed=`, and the C2 `finding_named` requires
   `^FINDING R61-C2-ST-`.

## Findings (medium/low)

- **C1-5** guard (b) is a count: a constant `PASS (cases=91)` passes; K5's mutated-copy
  test is not in the guard.
- **C1-6** I6's "quoted superseded span" is ambiguous: the unmodified line's whole-line
  set is `{15:09:28, 16:34:37}` plus four backticked stamps; only the double-quoted span
  is the singleton `{15:09:28}`.
- **C1-7** C1 is coupled to `plans/round-60-c2.sh` (I2): stripping it makes the unmodified
  tree `value=1` (`i2=0`).
- **C2-4** L3/L4's BASE reading is "the control is absent" (the round-63 battery does not
  exist at BASE), not "the stub survives a control".
- **C2-5** the L3/L4 control compares the stub's output to the hardcoded BASE line; it
  does not exercise the counter's refusal logic.
- **C2-6** the plan prints L6's replacement as if it were the needle; the BASE line is
  `ok = len(qualifying) >= 3 and bool(superseded) and not denied` (`:756`).
- **C2-7** L1/L2/L6 accept a source-pin selftest (grep own bytes) as readily as a
  behavioral test.
- **C2-8** the C1 counter hardcodes `kagi-r62/R62ExecC1Counter` scratch; round-63 runs
  write under the round-62 scratch.
- **C2-9** the controls battery's real-trial leg is load-sensitive: two runs of
  `plans/round-62-controls.sh <extracted-BASE>` on the same tree read `match=12
  mismatch=2` (fleet load 19–33; shim vectors carried `E` — the trial's T3/T4 legs
  errored) and `match=14 mismatch=0` (clean re-run). The battery reads a load-induced
  trial error as `real-verdict-weakened`; the plan's C2 guard (c)/(d) are
  load-sensitive and the ceiling names only "the real leg needs `bao`".
- **B-2** the dispatch carries 15 seats (A1); the assignment and plan §Wave say 16; the
  attack share is 4/15 = 26.67 % (5/15 = 33.33 %), not 4/16 = 25 %.
- **B-3** the two claims are not separable: C1 → `plans/round-60-c2.sh` (I2);
  C2 L1/L2 → `plans/round-62-c1.sh` (the C1 counter). Neither coupling is declared.

## Do-nothing control verdict

The byte-identical no-work control does **not** reach either target (C1 `accepted=10
rejected=6`, C2 `killed=0`). But the cheapest no-hardening C1 control — a fixture-lookup
checker with a constant PASS selftest — **does** reach `accepted=0 rejected=0` with
`guard=1`; the C1 predicate is not causally tied to the grammar it claims. The cheapest
C2 control is a source-pin selftest plus a stub-vs-BASE-line control, not a behavioral
hardening.

## Impacted axes

calibration (C1-1..C1-7, C2-1..C2-3, C2-6, C2-7, B-3); operability
(C2-1..C2-8, C1-1, C1-2, B-3). No axis is harmed by a finding that is only a named
ceiling (C1-5, C1-6, C2-4, C2-5, C2-8).

SEAT-STATUS: complete
