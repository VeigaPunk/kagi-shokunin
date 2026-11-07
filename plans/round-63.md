# Round 63 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 63, attempt 1. Claim BASE
`0c07aab8df64b673a54a5113aebd7f34b622adbc` (round-62 verifier spot-check tip,
`round-62 verifier spot-check (integrator, hyaku): non-author admit/reject`, 2026-11-07).

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; capabilities entered rounds
57–62, so no stagnation waiver is claimed. Both claims are declared here before any
candidate work; this file is committed alone as the predeclaration, then the
instruments, then the pre-freeze control battery, then the candidate.

Motivating evidence for the round:

- `corpus/lessons/round-62-verifier-spotcheck.md` §2 and §6 route three record defects
  (D-A report counts that do not re-derive; D-B four gate verdict lines with no
  committed receipt; D-C an undercounted case enumeration). They are resolved as work
  items (receipt `plans/round-63-routed.sh`), not as a third claim.
- The round-62 reviewer's own table (`.ufo/waves/round-62/w1/R62Reviewer.md` §1) leaves
  ten forgery trees **accepted** by the round-62 hardened checker: N2 (`hardly`), N3
  (denial after the token), N4/N14/N9 (negation beyond the 5-token window), N6 (`three`
  quoted then denied), N7 (negator truncated at a colon), N11 (subjects swapped, each
  fraction correctly paired) and N12/N12b (a fabricated stamp). Reviewer findings D-3,
  D-4 and D-5 are open; the critic's D7 names six **benign** rewrites the same grammar
  wrongly **rejects**. Re-measured by the L1 at BASE (2026-11-07, `.ufo/waves/round-63/
  base/`): all ten forgeries read `C1_ROUTED: value=0` (accepted) and all six benign
  rewrites read `value>=1` (rejected).
- The round-62 mutation-testers leave six instrument defects alive at BASE: MutC1
  CM2a (the C1 counter's stub composition forced to 1 passes `--selftest`), CM2b
  (`stub_leg` forced to read 1 passes `--selftest`), GM5 (the checker's I6
  superseded-stamp conjunct has no isolating selftest case); MutC2 S3 (a zero-match
  M-A needle reads as a surviving mutant, not SETUP); reviewer D-6 (no leg refuses a
  printer-stub claim counter) and critic D12 (no case runs a constant-verdict copy of
  the C2 counter). Re-measured by the L1 at BASE: CM2a and CM2b each read
  `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0; the GM5 mutant checker reads
  `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0; the two stub counters print the target
  verdict line rc 0 and `grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh` ⇒ 0.

## C1 — calibration: the C1 checker's residual polarity classes close on both sides

Target axis: calibration (the mismatch count between the lane's own record statements
and the checker that grades them — here, a checker that accepts a forged correction and
rejects a benign one).

**Frozen predicate (this sentence is the plan's, the counter's code and the receipt's label):**

```
C1_RESIDUAL: accepted = the number of the ten committed forgery fixtures (F1..F10) on
which the measured tree's checker (plans/round-61-c1-check.py, invoked
`python3 -I -B … --root <copy> --repo <lane> --fleet <fleet-root> --no-challenge`)
prints `C1_ROUTED: value=0` — i.e. accepts the forgery; rejected = the number of the
six committed benign fixtures (P1..P6) on which it prints `value>=1` — i.e. rejects a
sentence that keeps the assertion. POP = 10 / 6; target accepted=0 AND rejected=0
(BASE 10 / 6). GUARD = 1 iff, on the same measured tree: (a) the unmodified copy prints
`value=0` (the seven round-61 corrections still resolve); (b) the checker's `--selftest`
exits 0 printing `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 91; (c) the five round-62
bypass fixtures (B3..B7) each still print `value>=1`; (d) the three round-62 paraphrase
fixtures (P3..P5) each still print `value=0`; (e) a printer-stub checker (a file printing
a constant `C1_ROUTED: value=0 …` line) is refused — no `C1_RESIDUAL:` verdict line and
a non-zero exit.
```

Every number the counter compares is derived at run time from the measured tree or,
where a fixture names a revision, from the lane repository; no constant carries a fact
the measured tree asserts.

The ten forgery fixtures (each anchor must occur exactly once in the measured tree; 0 or
>1 occurrences fails closed):

| id | reviewer id | file | anchor → replacement (the forgery) |
|---|---|---|---|
| F1 | N2 | `plans/round-60.md` | `**A3 item 2 is withdrawn**` → `**A3 item 2 is hardly withdrawn**` |
| F2 | N3 | `plans/round-60.md` | `**A3 item 2 is withdrawn**` → `**A3 item 2 is withdrawn — the record denies it**` |
| F3 | N4 | `plans/round-60.md` | `**A3 item 2 is withdrawn**` → `**A3 item 2 is not, as the earlier draft asserted, withdrawn**` |
| F4 | N6 | `corpus/lessons/round-60.md` | `the round introduced three new record defects it did not route` → `the round introduced "three new record defects it did not route", a claim the record refutes` |
| F5 | N7 | `corpus/lessons/round-60.md` | same anchor → `the round did not introduce: three new record defects it did not route` |
| F6 | N14 | `corpus/lessons/round-60.md` | same anchor → `the round did not introduce, as the earlier claim had it, three new record defects it did not route` |
| F7 | N9 | `LOG.md` | `it was rewritten in place at` → `it was not, contrary to the earlier record's claim, rewritten in place at` |
| F8 | N11 | `corpus/lessons/round-60.md` | `so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %` → `so the literal reading is 4/16 = 25 %, and counting the sentinel as an attack seat gives 3/16 = 18.75 %` |
| F9 | N12 | `corpus/lessons/round-60.md` | `launch 15:09:28 −03` → `launch 16:59:59 −03` |
| F10 | N12b | `corpus/lessons/round-60.md` | `launch 15:09:28 −03` → `launch 15:09:28 −03 (also seen at 16:59:59 −03)` |

The six benign fixtures (each must read `value=0` after the hardening):

| id | critic id | file | anchor → replacement (benign) |
|---|---|---|---|
| P1 | D7 | `plans/round-60.md` | `**A3 item 2 is withdrawn**` → `**Item 2 of A3 is withdrawn**` |
| P2 | D7 | `plans/round-60.md` | `**A3 item 2 is withdrawn**` → `**A3 item 2 is not merely withdrawn**` |
| P3 | D7 | `corpus/lessons/round-60.md` | `the round introduced three new record defects it did not route` → `the round introduced no fewer than three new record defects it did not route` |
| P4 | D7 | `corpus/lessons/round-60.md` | same anchor → `the round introduced 3 new record defects it did not route` |
| P5 | D7 | `LOG.md` | `it was rewritten in place at` → `it was not appended but rewritten in place at` |
| P6 | D7 | `LOG.md` | same anchor → `it was rewritten in-place at` |

**The hardened grammar (the instrument this claim lands), item by item.**

| item | hardened condition |
|---|---|
| polarity (I3/I4/I5) | a token is asserted iff (i) no negator sits between the nearest `.` or `;` before it and the token (window capped at 24 tokens), (ii) no denial predicate sits between the token and the nearest `.` or `;` after it (capped at 24 tokens), (iii) no idiom immediately precedes it, and (iv) no negator before it is followed by `but` before the token (contrastive). Double-quoted spans that END before the token are masked first (a quotation of the superseded text is not the correction's own assertion; round 62 applied the same mask to I7). |
| I3 | an occurrence of `withdrawn` whose 12-token window before it contains `A3 item 2` **or** `item 2 of A3`, and whose polarity test passes |
| I4 | `three` **or** the digit `3` (word-boundary) with a passing polarity test |
| I5 | `rewritten in place` **or** `rewritten in-place` with a passing polarity test |
| I6 | the correction line carries the driver launch line, at least three `-03:00` stamps in the derived committer set, **and** a quoted superseded span whose `HH:MM:SS` set equals exactly the superseded record's stamp, derived from the fleet report `.ufo/reports/round-60/kagi.md` §Stale-lane line (`launch HH:MM:SS`); a missing or unreadable fleet report is SETUP (fail closed) |
| I7 | the derived fraction and its derived percentage are paired **and bound to their subject**: `3/16 = 18.75 %` follows the `literal reading` subject within 8 tokens, and `4/16 = 25 %` follows the `sentinel` subject within 8 tokens |

Negator set (case-insensitive, word-boundary): `not`, `no`, `never`, `neither`, `nor`,
`without`, `none`, `n't`, `hardly`, `barely`, `scarcely`, `rarely`, `seldom`,
`no longer`.

Denial predicates (post-token, case-insensitive): `denies`, `denied`, `deny`, `refutes`,
`refuted`, `refute`, `is false`, `are false`, `not true`, `untrue`, `not the case`,
`no such`.

Idioms (immediately before the token, not a negator): `not only`, `not merely`,
`not just`, `no fewer than`, `no less than`.

Commands:

```
bash plans/round-63-c1.sh [revision]          # BASE when omitted; --tree DIR also accepted
python3 -I -B plans/round-61-c1-check.py --root <tree> --repo <lane> --fleet <fleet-root> --no-challenge
```

Output line: `C1_RESIDUAL: accepted=A rejected=R population=10/6 guard=G (real=… selftest=… prior=… para=… stub=…)`.
Exit 0 iff guard=1 and accepted=0 and rejected=0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a tree byte-identical to BASE must read `accepted=10 rejected=6 population=10/6`;
  any lower reading means a fixture is vacuous and voids the claim.
- K2: each forgery must be able to read accepted on the BASE checker and rejected on
  the hardened checker; each benign rewrite must be able to read rejected on the BASE
  checker and accepted on the hardened one.
- K3: a printer-stub checker must be refused (guard leg e).
- K4: the five round-62 bypass fixtures must still read rejected and the three
  round-62 paraphrases must still read resolved (guard legs c/d); a hardening that
  rejects a paraphrase fails the guard, not the claim.
- K5: the checker's `--selftest` must carry one case per new fixture class and must
  fail on a mutated copy (the negator set emptied, or an item's polarity test removed).

**Population census at BASE (measured, not assumed):** on an extracted `0c07aab8` tree
the ten forgery copies each read `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0`
rc 1, and the six benign copies each read `C1_ROUTED: value=1 …` (i3=0 for P1/P2, i4=0
for P3/P4, i5=0 for P5/P6) rc 1 — accepted 10, rejected 6. The unmodified copy reads
`value=0` rc 1.

**Named ceilings:** the ten fixtures are the reviewer's ten; a further negation or
pairing class is a new routed defect, not a claim failure. A structural read cannot
prove the corrected sentence true — it proves the sentence asserts the correction
(QM79/QM81 narrow, never close, this). The negator set, the denial set and the 24-token
sentence window are closed lists and a floor: a forger who writes a false assertion with
none of them still passes. The six benign rewrites are six rewrites, not a grammar. I6's
derivation reads one fleet path; a moved report is SETUP, never a silent pass.

## C2 — operability: the claim counters and the measured counter refuse the named surviving mutants

Target axis: operability (a runnable artifact that produces the stated outcome — here,
a gate whose self-invocation mode witnesses its own verdict and whose failure to find
its needle is distinguishable from a surviving mutant).

**Frozen predicate:**

```
C2_REFUSAL: killed = the number of the six falsifier legs that fire over POP = 6:
  L1 (CM2a): the measured tree's C1 claim counter (plans/round-62-c1.sh) with its stub
     composition (`stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1`) replaced
     by `stub=1` makes `--selftest` exit non-zero printing a named `FINDING`;
  L2 (CM2b): the same counter with `stub_leg` forced to read `SL_OK=1` unconditionally
     (a line `SL_OK=1` appended before its closing brace) makes `--selftest` exit
     non-zero printing a named `FINDING`;
  L3 (D12): a constant-verdict copy of the C2 claim counter (prints the target verdict
     line, exits 0) run on the claim BASE tree makes the controls battery read
     `mismatch` for its control;
  L4 (D-6): a printer-stub copy of the C1 claim counter (prints the target verdict line,
     exits 0) run on the claim BASE tree makes the controls battery read `mismatch`;
  L5 (S3): a tree whose `plans/round-61-c2.sh` carries neither the M-A marker block nor
     the BASE aggregation text makes the C2 claim counter print `SETUP needle-ma` with
     exit 2 (not `killed=2 …` with exit 1);
  L6 (GM5): the measured checker with the I6 superseded-stamp conjunct dropped
     (`ok = len(qualifying) >= 3 and not denied`) makes its own `--selftest` exit
     non-zero printing `C1_CHECK_SELFTEST: FAIL`
  — when GUARD = 1, else FAIL. Target 6 (BASE 0).
GUARD = 1 iff, on the same measured tree: (a) the unmutated C1 counter's `--selftest`
exits 0 printing `C1_COUNTER_SELFTEST: PASS`; (b) the unmutated C2 counter's
`--selftest` exits 0 printing `C2R63_SELFTEST: PASS`; (c) the C2 counter on the real
trial reads `value=5 … shims=5 vectors=ok/5` (the hardening preserves the real verdict);
(d) the controls battery's existing controls still match with 0 skips.
```

Commands:

```
bash plans/round-63-c2.sh [revision]          # BASE when omitted; --tree DIR also accepted
bash plans/round-62-controls.sh <tree>        # the battery the L3/L4 controls join
bash plans/round-63-controls.sh [candidate tree DIR]
```

Output line: `C2_REFUSAL: killed=K population=6 guard=G (l1=… l2=… l3=… l4=… l5=… l6=… selftest=… real=…)`.
Exit 0 iff guard=1 and killed=6; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a tree byte-identical to BASE must read `killed=0 population=6`; a leg that
  already fires at BASE is vacuous and voids the claim.
- K2: each leg must be able to survive at BASE and be killed on the candidate; the
  needle for each mutation must match exactly once (0 or >1 fails closed as SETUP).
- K3: L5's SETUP must be a SETUP (exit 2), not a `killed=2` reading; a zero-match
  needle that still counts as a surviving mutant fails the leg.
- K4: the real trial must still read `value=5 shims=5 vectors=ok/5` (guard leg c).
- K5: the battery's existing controls must still match with 0 skips (guard leg d).

**Population census at BASE (measured, not assumed):** on an extracted `0c07aab8` tree
CM2a and CM2b each read `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0; the GM5 mutant
checker reads `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0; the D12 and D-6 stub counters
print their target verdict lines rc 0 and the battery carries no such control
(`grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh` ⇒ 0); the S3 tree's counter run
reads `killed=2 … guard=0` rc 1 (recorded in the pre-freeze receipt).

**Named ceilings:** six legs, not a complete mutation set; a stub that prints exactly
the independently expected line is indistinguishable by output alone (the battery
compares the full verdict line and the counter's own leg fields, nothing more); the
real leg needs `bao`; nothing schedules the gates.

## Frontier step

Candidate sources to open this round (at least three opened, at least one admitted, at
least one rejected, each with a ≤25-word located quote and an access date):

1. Harkema et al., *ConText: An algorithm for determining negation, experiencer, and
   temporal status from clinical reports* (J Biomed Inform 2009) — the pseudo-negation
   and termination-term classes that ground the idiom/contrastive exception list.
2. Chapman et al., *A simple algorithm for identifying negated findings and diseases in
   discharge summaries* (J Biomed Inform 2001) — the NegEx window rule the sentence
   scope narrows (S130/S131 already hold the PMC deposits; a new row is written only if
   a page opened this round grounds a new lesson).
3. Jia & Harman, *An Analysis and Survey of the Development of Mutation Testing*
   (IEEE TSE 2011) — the equivalent-mutant problem behind "a surviving mutant must be
   killed or shown equivalent".
4. One weak lead (a vendor blog or a wiki page) as the reject.

The C1 claim's evidence cites the admitted row (the idiom/contrastive exception list);
the knowledge entry and the lesson's Gate carry the `S###` ids.

## Routed defects (round-62 spot-check §6) — work items, not a claim

- **D-A** report counts that do not re-derive: the round-63 report cites only counts its
  own commands print; `plans/round-63-routed.sh` leg `da` re-derives the two round-62
  counts from committed bytes and records the corrected values in the lesson.
- **D-B** gate verdict lines without a committed receipt: one receipt per gate line under
  `.ufo/waves/round-63/final/`, cited from `LOG.md`; leg `db` requires each receipt and
  its citation.
- **D-C** undercounted case enumeration: the lesson cites the seat receipt or the full
  list; leg `dc` requires the enumeration to match the instrument's own case count.

## considerthese

One still-unimplemented proposal is mined this round (read-only; never edited):
`considerthese/2026-10-26.md` proposal 3, "Mark known-defective instrument output" — a
gate that knows a defect class in its own instrument appends a `KNOWN_DEFECT: <id>`
qualifier to a `CLEAN` verdict instead of printing a bare CLEAN. It lands as the
`C1_RESIDUAL`/`C2_REFUSAL` verdict lines carrying their named ceilings in the same line
(`ceiling=` field) and as the QUALITY criterion this round adds, citing this lesson.

## Wave

`kagi-r63-w1`, 16 seats v1 (band 8–16; `.ufo/waves/round-63/w1-dispatch.json`; reports
`.ufo/waves/round-63/w1/`): 2 scout, 6 executor, 2 scribe, 1 reviewer, 1 critic,
2 mutation-tester, 1 connector, 1 sentinel. Attack share 4/16 = 25 % on the addendum's
literal list (reviewer, critic, mutation-tester ×2; no labrat seat exists), 5/16 = 31.25 %
counting the sentinel. The L1 holds the canonical planner seat and is the sole
integration owner and committer.

## Bounds

- The two counters are the verdicts; this plan's BASE census is the L1's own measurement
  (`/fast/scratch/hyaku/kagi-r63/L1-base/`, not citable evidence) and is re-derived by
  the committed counters.
- The fixture tables are frozen here; a seat that finds a fixture vacuous reports it,
  never edits it.
- The I6 derivation reads the fleet report; a lane that cannot read it reads SETUP.

## Amendment A1 — 2026-11-07, before the wave dispatch (wave shape only)

The §Wave line names 16 seats; the validated wave (`kagi-r63-w1`,
`.ufo/waves/round-63/w1-dispatch.json`) carries **15 seats**: 2 scout, 5 executor,
2 scribe, 1 reviewer, 1 critic, 2 mutation-tester, 1 connector, 1 sentinel. The checker
work (all five items I3–I7 and the selftest cases) is one file with one owner
(`R63ExecC1Grammar`), so the sixth executor seat the earlier line implied is not
dispatched. Attack share 4/15 = 26.67 % on the addendum's literal list (reviewer,
critic, mutation-tester ×2; no labrat seat exists), 5/15 = 33.33 % counting the
sentinel. No predicate, target, POP, kill rule, fixture or item condition changes.

## Amendment A2 — 2026-11-07, before any candidate reading (C2 population correction, measured)

L5 (MutC2 S3, the zero-match M-A needle) is **vacuous at BASE**: measured on an extracted
`0c07aab8` tree whose `plans/round-61-c2.sh` carries neither the literal `# BEGIN-DECIDE`
marker nor the BASE aggregation text, `bash plans/round-62-c2.sh --tree <tree>` prints
`C2_HARDENED: SETUP needle-ma` with exit 2 — `plans/round-62-c2.sh:279` already carries
`[ "$ma_applied" = 1 ] || setup needle-ma`, so the mutation-tester's S3 was closed by
round 62's Amendment A2 (its report predates that guard). A leg that already fires at BASE
is vacuous under kill rule K1 and cannot count.

**C2 population is therefore 5, target killed=5**: L1 (CM2a), L2 (CM2b), L3 (D12),
L4 (D-6), L6 (GM5). The counter prints
`C2_REFUSAL: killed=K population=5 guard=G (l1=… l2=… l3=… l4=… l6=… selftest=… real=…)`;
the leg ids keep their plan names. No other predicate, target, kill rule or fixture changes.

## Amendment A3 — 2026-11-07, before the candidate reading (attack-seat findings, C1 guard and C2 leg mechanics)

`R63Critic` (C1-1/C1-5/C1-2/C1-3/C1-4, C2-1/C2-3/C2-6/C2-7/C2-8) and `R63ScoutPreState`
(the `--fleet` probe) measured these before any candidate reading. Each item strengthens an
instrument or restates an already-implemented condition; none narrows a target.

1. **C1 guard leg (f) — the checker challenge (closes C1-1/C1-5).** A copy of the measured
   tree's `plans/round-61-c1-check.py` with its negator set emptied (`NEGATORS = frozenset(())`)
   must fail its own `--selftest` with a named `C1_CHECK_SELFTEST: FAIL` line and a non-zero
   exit. A fixture-lookup checker that prints a constant PASS line has no negator set to
   empty; the needle matches 0 times and the leg reads 0 (SETUP is not a pass). GUARD gains
   leg (f); the verdict line gains `chal=…`.
2. **C1-2 — the checker invocation.** The counter passes `--fleet <dir>` only when the
   measured tree's checker lists it in `--help`; the BASE checker does not, so the BASE
   no-work control is measured with the BASE checker's own supported interface (its I6 then
   reads the round-62 qualifying-time form and F9/F10 are accepted, which is the BASE
   reading the claim needs).
3. **C1-3 — I6 keeps the round-62 A1 denial clause** (`I6_DENY_PHRASES`: `times are
   correct`, `times are right`, `is correct`, `are correct`). B6 is rejected by that clause;
   the plan's I6 text above named only the launch line, the derived stamps and the quoted
   superseded span. Guard leg (c) already requires B3..B7 rejected, so the clause is part of
   the frozen guard, not a new condition.
4. **C1-4 — I4/I5 keep the round-62 line scope:** the LAST line matching the item's
   supersedes phrase (the whole-file reading is not the item's condition; round-62 A2).
5. **C2 population is 5** (A2 stands): L1, L2, L3, L4, L6. The seat prompt's "population 6"
   and the milestone's "killed 0->6" are stale wording, corrected here and in the report.
6. **C2 leg mechanics (C2-3/C2-6/C2-7).** L1's needle is derived from the candidate tree's
   own `plans/round-62-c1.sh`: the exact line `stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]]
   && stub=1` when present, else the `stub_calc` body's `[[` line; L2's needle is the
   `stub_leg` body's closing `}` (a line `SL_OK=1` appended before it). L6's needle is the
   BASE line `ok = len(qualifying) >= 3 and bool(superseded) and not denied`. A leg fires on
   a non-zero exit **and** a line matching `^FINDING` or `failed=` (the C1 counter's selftest
   prints `failed=`), not on a source-pin grep.
7. **C2-8 — scratch root.** Both round-63 counters write under
   `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/<seat>/`, never a round-62 path.
8. **B-3 — declared couplings.** C1's I2 reads `plans/round-60-c2.sh` (a pre-existing item's
   evidence this round does not change); C2's L1/L2 read the C1 counter's file. Verification
   stays separable: C1's claim needs no C2 leg, and C2's legs run on the BASE checker
   (`C1_CHECK_SELFTEST: PASS (cases=75)`), so neither claim verifies through the other's
   hardening.
9. **Named ceilings (recorded, not smoothed):** C2-4/C2-5 — L3/L4's BASE reading is "the
   control is absent", and the control compares the stub's verdict line to the independently
   expected BASE line, not the counter's refusal logic (a stub printing the expected line is
   indistinguishable by output); C1-6 — only the double-quoted span is the superseded stamp
   (the whole-line set also carries the complete time and four backticked stamps); C1-7 —
   C1's I2 depends on `plans/round-60-c2.sh`; B-2 — the dispatch carries 15 seats (A1).
