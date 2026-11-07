source: S128 — https://pitest.org/ (front page, the kill/survive sentence; capture sha256 `b0c7e0505c51c95b596060ef27babbce08e72d5aaf4557eb002c2637d2bf10cc`, 12023 B, opened 2026-11-07; `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-62/capture/S128.body 'If your tests fail then the mutation is killed'` ⇒ `count=1`); S129 — https://stryker-mutator.io/docs/ (What is mutation testing?; the killed/survived sentences; capture sha256 `185130082d9961cb4cb0d9527f2281e58b2e2126ee2372551193b0decd6c9e8e`, 30253 B, opened 2026-11-07; locate `count=1` for each quoted sentence); S130 — Harkema et al., "ConText: an algorithm for determining negation, experiencer, and temporal status from clinical reports", J Biomed Inform 2009, PMC2757457 (the round's re-pin moves the registry row to the token-free efetch XML form; capture `.ufo/waves/round-62/capture/S130.body`, sha256 `cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b`, 189603 B, opened 2026-11-07; §3.1.4 ConText and NegEx; locate `count=1`); S131 — Mehrabi et al., "DEEPEN: a negation detection system for clinical text incorporating dependency relation into NegEx", J Biomed Inform 2015, PMC5863758 (same re-pin; capture `.ufo/waves/round-62/capture/S131.body`, sha256 `80ec43266cc9bf39e6cf05fc45cb2c3ccf58ce9802d023cd820dbe999998cc38`, 101800 B, opened 2026-11-07; Abstract; locate `count=1`); `plans/round-62.md` §C1 and §C2 (the frozen predicates, the fixture tables and the closed negator set); the measured instruments `plans/round-61-c1-check.py` (sha256 `d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812` at BASE) and `plans/round-61-c2.sh` (sha256 `c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6` at BASE), with the round's counters `plans/round-62-c1.sh` and `plans/round-62-c2.sh`
verified-at: 2026-11-07 — BASE `60b5b7b60b76629633110a5b4adac883193c8b2a` extracted with `git archive`; the five bypass and three paraphrase trees built from the plan's anchor→replacement pairs (every anchor occurs exactly once, else the builder fails closed); every BASE reading below re-measured by the command printed beside it, receipts under `.ufo/waves/round-62/build/R62ScribeEntry/`; the candidate readings are working-tree observations at the instrument digests named beside them, and the committed candidate receipt `.ufo/waves/round-62/final/candidate.txt` is the L1's to land
recheck: 180d — re-extract the claim BASE, rebuild the eight fixture trees from `plans/round-62-bypass.tsv` and `plans/round-62-paraphrase.tsv`, re-run `bash plans/round-62-c1.sh` (expect `accepted=5` at BASE) and the three C2 legs (expect `killed=0` at BASE), then run both counters on the then-current candidate; re-open S128/S129 (kill/survive) and S130/S131 (trigger scope) if either rule is re-quoted
Reverify: R62-01, R62-02

# Instrument falsifiability: a gate's self-invocation must execute its own aggregation, and a structural item must test its token in the asserting position

Scope: the two round-62 claims of the kagi lane, measured on `kagi-shokunin` at BASE
`60b5b7b` — C1, the C1 checker's negation / swapped-pairing bypass class (accepted 5 → 0
over five fixtures), and C2, the C2 counter's guard and self-invocation (killed 0 → 3 over
three falsifier legs). The entry is written in two voices and keeps them apart: the
kill/survive *definition* is the two sourced pages' sentences, each with a located quote,
while every instrument reading below is a line a lane command printed on a named tree. The
entry is about the instruments, not about OpenBao: it makes no claim about a vault, a
server or a secret, and the round's own domain evidence stays in
`corpus/knowledge/openbao-seal-key-custody.md`.

## The bypass class

A structural item that tests only **token presence** accepts a sentence that keeps every
token and denies the assertion. The round-61 checker (`plans/round-61-c1-check.py`, 1454
lines, 67905 B by `wc -lc`, sha256 `d525ee28…` by `sha256sum`) read five forged trees as
satisfied. Each tree is the
BASE tree with one anchor replaced by one forgery; the anchor must occur exactly once (0 or
more than one fails closed), and the reading is the checker's own line:

```
python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge
```

| id | file | forgery (the whole replacement) | reading on the BASE checker |
|---|---|---|---|
| B3 | `plans/round-60.md` | `**A3 item 2 is not withdrawn**` | `C1_ROUTED: value=0 population=7 i3=1` |
| B4 | `corpus/lessons/round-60.md` | `the round introduced no three new record defects it did not route` | `value=0 … i4=1` |
| B5 | `LOG.md` | `it was not rewritten in place at` | `value=0 … i5=1` |
| B6 | `corpus/lessons/round-60.md` | `the paragraph's times are correct.` | `value=0 … i6=1` |
| B7 | `corpus/lessons/round-60.md` | `3/16 = 25 %` and `4/16 = 18.75 %` (the pairing swapped) | `value=0 … i7=1` |

The unmodified copy reads the same line (`value=0 population=7 i1=1 … i7=1 guard=0`, rc 1),
so the population is not vacuous: the five trees are not accepted because the checker is
broken everywhere, but because each item's token test cannot see the denial. Receipt
`.ufo/waves/round-62/build/R62ScribeEntry/c1-base-census.txt` (9 lines: the unmodified copy,
B3–B7, P3–P5); the per-fixture command is the one above with `<copy>` set to the fixture
tree.

The stronger reading is that the items are **unmoved**, not merely satisfied: with
`--verbose`, the seven item detail lines (i1–i7) are byte-identical on all nine trees (the
unmodified copy, B3–B7 and P3–P5) — `c1: i3 HOLD a7-at-line=331 …` through
`c1: i7 HOLD derived 3/16=18.75 4/16=25 …` (receipt
`.ufo/waves/round-62/build/R62ScribeEntry/verbose-items.txt`, 72 lines: 9 tree blocks × 7
item lines).
A forger who negates the assertion changes nothing the item reads; that is the signature of
a token-presence test, and it is why the hardening must move a reading, not add a token.

The class has three shapes, not one:

- **Negation** (B3, B4, B5) — a negator inserted immediately before the token the item
  names: `not withdrawn`, `no three`, `not rewritten in place`. The token occurs; the
  sentence asserts its opposite.
- **Vacuous restatement** (B6) — the stale-lane sentence is replaced by a sentence that
  asserts the paragraph's times are correct. The item's three conjuncts (the driver launch
  line, at least three `-03:00` stamps in the derived committer set, one `HH:MM:SS` time
  that is neither the launch line's time nor a derived committer time) stay satisfiable from
  the surrounding correction, so the tree reads satisfied while the paragraph no longer
  admits the defect.
- **Swapped pairing** (B7) — both fractions and both percentages remain, and the item's
  tokens all occur, but the arithmetic is inverted: `3/16 = 25 %` and `4/16 = 18.75 %`.

The class is measured, not inferred: the five trees are the round-61 reviewer's five
(`corpus/lessons/round-61.md` §Corrections, ceiling from §C1), frozen as anchor→replacement
pairs in `plans/round-62.md` §C1 and committed as `plans/round-62-bypass.tsv`. The frozen
plan's Amendment A1 (2026-11-07, written before any candidate reading) adds the matching
clause to I6's hardened condition: the correction line carries none of `times are correct`,
`times are right`, `is correct`, `are correct` (case-insensitive), because B6's tail is
exactly that denial. A1 strengthens the item and leaves the predicate, the target, the
population and the five fixtures unchanged.

## The polarity rule

The hardened I3–I5 test the token in the **asserting position**: the token must occur with
no negator in its 5-token window *before* it, and the window is truncated at the nearest
`.` , `;` or `:` — so a negator in a previous clause does not taint the token, and a negator
in the same clause does.

The negator set is closed and named in the frozen plan (case-insensitive, word-boundary):
`not`, `no`, `never`, `neither`, `nor`, `without`, `none`, `n't`.

Two refinements are part of the rule, not of the implementation:

- **The `not only` idiom.** The bigram `not only` immediately before the match is a focus
  particle, not a negation: `A3 item 2 is not only withdrawn` asserts withdrawal. A window
  matcher that treats every `not` as a negator rejects the idiom and fails the paraphrase
  guard, not the claim.
- **I3's subject window.** I3 requires at least one occurrence of `withdrawn` whose
  12-token window *before* it contains `A3 item 2` **and** whose 5-token window before it
  contains no negator. The 12-token window binds the token to its subject, so a `withdrawn`
  elsewhere in the file cannot satisfy the item; the 5-token window is the polarity test on
  the bound occurrence.

The rule's shape is not the lane's invention. S130 (Harkema et al., J Biomed Inform 2009)
states the NegEx trigger-scope rule: "In the NegEx algorithm the scope of a trigger term is
a priori restricted to a window of six tokens" (located `count=1`). The lane's rule is the
same shape — a negator token with a bounded window — read in the opposite direction: the
window is the tokens *before* the asserted token, because the item asks whether that token
is negated, not whether a trigger's scope contains a finding. S131 (Mehrabi et al., J Biomed
Inform 2015) states the failure mode a window cannot fix: "NegEx fails to correctly capture
the negation status of concepts in complex sentences." (located `count=1`). A found trigger
is not the same as a negated assertion, which is why the entry calls the window a floor.

The window is a **floor, not a parser** — the plan's named ceiling. A forger who writes a
false assertion with no negator and all the tokens still passes. The rule raises the cost of
the cheapest forgery; it does not decide truth.

## The pairing rule

A fraction and its percentage must be **derived from the same pair and adjacent in one
expression**. For I7 the expression is `3/16 = 18.75 %` and `4/16 = 25 %`
(whitespace-tolerant), and the numbers are derived at run time from the wave results file
the correction cites, not from the correction's own text: the file holds 16 results
(`python3 -c 'import json; print(len(json.load(open(".ufo/waves/round-60/w1-results.json"))["results"]))'`
⇒ 16), three literal attack seats (reviewer, critic, mutation-tester) and four counting the
sentinel. Two tokens in the same file are not a pairing; the pairing is one expression.
That is why B7 fails the hardened item while it passed the token-presence item: `3/16` and
`25 %` both occur, but not in the derived pairing.

The rule's teeth are the derivation: the checker's verbose line prints the derived pairs it
compares against (`c1: i7 HOLD derived 3/16=18.75 4/16=25`), so a tree whose wave results
file changed would move the derived pair and the correction would have to move with it.

## The mutation-kill contract

A gate's `--selftest` must **execute its own aggregation**. Two testable units are delimited
by markers in the counter: `decide` (the value aggregation: pass, shims, none, selftest,
ops, t2w → 0 or 5) between `# BEGIN-DECIDE` and `# END-DECIDE`, and the shim aggregation
(five shim vectors → 0..5) between `# BEGIN-SHIMS` and `# END-SHIMS`. The contract has
three clauses, each with a mutant that must fail:

1. **A constant-aggregation mutant must fail.** M-A replaces the `decide` block with
   `echo 5`; `--selftest` must exit non-zero printing a named `FINDING`.
2. **An unconditional-aggregation mutant must fail.** M-B replaces the shim block with
   `shims_ok=5`; `--selftest` must exit non-zero printing a named `FINDING`.
3. **A guard must have a challenge leg that reads 0 on a valid-but-incomplete tree.** A
   tree whose trial file is a valid sha256 (any file is) but prints no expected observable
   must read `guard=0`, not `guard=1`. The guard's job is to separate "evaluated and
   failed" (`value=0`, `guard=1`) from "could not evaluate" (`value=0`, `guard=0`); a guard
   that reads 1 on a stub makes the two indistinguishable to every reader.

The guard also requires every leg's **expected observable** — the trial's
`SEAL_SELFTEST: PASS (cases=N)` line, the ops argv shapes, the T2 markers — not just a
captured exit code. A captured rc proves a process ran; it does not prove the process
measured anything.

The contract is the lane's application of the sourced definition. S128 (PIT) states the
rule in one sentence: "If your tests fail then the mutation is killed" (located `count=1`).
S129 (Stryker) states both halves: "If at least one of your tests fail, we say the mutant is
killed" and "If no test fails, it survived" (each located `count=1`). A mutant that a
gate's own selftest cannot kill is a **surviving mutant** — an aggregation the gate does not
test. The round-61 counter's `--selftest` ran 11 cases (`bash plans/round-61-c2.sh
--selftest` ⇒ `C2_SELFTEST: PASS (cases=11)`) and none of them executed the value or shim
aggregation, so both mutants survived; that is the defect this contract names.

## Measured

Every number is a line a command printed. Receipts are under
`.ufo/waves/round-62/build/R62ScribeEntry/` (this seat) and, for the candidate,
`.ufo/waves/round-62/final/` (the L1).

**C1 — before (BASE `60b5b7b`).** The five bypass trees each read accepted; accepted = 5 of
population 5.

```
for t in B3 B4 B5 B6 B7; do
  python3 -I -B plans/round-61-c1-check.py --root <fixture-$t> --repo <lane> --no-challenge
done
```

⇒ each prints `C1_ROUTED: value=0 population=7 … i3..i7=1 guard=0`, rc 1 (receipt
`c1-base-census.txt`, 9 lines: the unmodified copy, B3–B7, P3–P5). The frozen counter's own
BASE control is the same reading: `bash plans/round-62-c1.sh` ⇒ `C1_BYPASS: accepted=5
population=5 guard=0 (real=1 selftest=0 stub=1 paraphrase=1)` rc 1 (receipt
`c1-counter-base.txt`). The `selftest=0` is over-determined at BASE: the checker's own line
is `C1_CHECK_SELFTEST: PASS (52 cases)` (receipt `c1-selftest-base.txt`), so 52 < 57 fails
the guard's case floor. The first counter revision also printed `cases=1` because it took
the first digit run of that line, which is the `1` in `C1_CHECK_SELFTEST`; the owner fixed
the parse mid-wave (counter sha256 `19ea1131…`) and the corrected BASE control reads
`cases=52` (receipt `c1-counter-base-fixed.txt`). The candidate reading must show `cases`
≥ 57 and `selftest=1`.

**C1 — after (candidate).** Frozen target `accepted=0 population=5 guard=1`, produced by
`bash plans/round-62-c1.sh <candidate>` and landed as
`.ufo/waves/round-62/final/candidate.txt` by the L1. The guard's four legs are the reading:
the unmodified copy still `value=0` (no false positive), the checker's `--selftest` prints
`C1_CHECK_SELFTEST: PASS (cases=N)` with N ≥ 57, a printer-stub checker reaches no
`C1_BYPASS:` line, and the three paraphrase trees each still read `value=0`.

On the working tree at the time of writing, the same nine-tree loop was run on two checker
revisions — `60bffd05…` at the start of the first run and `f2afd9b8…` (which reads
`C1_CHECK_SELFTEST: PASS (75 cases)`) — with identical readings: the unmodified copy
`value=0`; B3 `value=1 … i3=0`; B4 `value=1 … i4=0`; B5 `value=1 … i5=0`; B6
`value=1 … i6=0`; B7 `value=1 … i7=0`; P3–P5 `value=0` (receipts `c1-hardened-census.txt`
and `c1-hardened-census-2.txt`). Each forgery is rejected by exactly the item it targets
and no other item moves — accepted = 0 of 5. The counter-level reading on the same tree
(counter sha256 `138625b7…`) is `C1_BYPASS: accepted=0 population=5 guard=1 (real=1
selftest=1 stub=1 paraphrase=1)` rc 0 (receipt `c1-verdict-worktree.txt`) — the frozen
target line. The committed candidate receipt `.ufo/waves/round-62/final/candidate.txt` is
the L1's to land.

**C2 — before (BASE `60b5b7b`).** killed = 0 of population 3.

```
bash plans/round-61-c2.sh --selftest            # on the base, M-A and M-B copies
bash plans/round-61-c2.sh --tree <stub-trial-tree>
bash plans/round-61-c2.sh --tree <base>
```

⇒ base, M-A and M-B each print `C2_SELFTEST: PASS (cases=11)` rc 0, so both mutants
survive; the stub-trial tree prints `C2_SEAL_TRIAL: value=0 … guard=1` rc 1, so the guard
does not discriminate (receipt `c2-base-census.txt`, 4 lines). The real trial is the
positive control: `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1
guard=1 (… sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB … cases=63)` rc 0 (receipt
`c2-real-base.txt`). At BASE the two mutants were built by text: M-A replaces the block from
`pass=0` through the `value=5` assignment with `value=5`; M-B replaces the block from
`shims_ok=0` through the shim loop's `done` with `shims_ok=5` — the reviewer's two mutation
classes, which the plan's candidate form restates as the marker-delimited blocks (the two
diffs are receipted as `mutA.diff` and `mutB.diff`, 15 lines each).

**C2 — after (candidate).** Frozen target `killed=3 population=3 guard=1`, produced by
`bash plans/round-62-c2.sh <candidate>`: M-A and M-B each make `--selftest` exit non-zero
printing a named `FINDING`, and the stub-trial tree reads `guard=0`. The hardening may not
weaken the gate: the real trial must still read `value=5 … shims=5 vectors=ok/5`.

On the working tree at the time of writing (counter sha256 `20614697…`, before the
candidate commit), the three legs read: the unmutated counter `C2_SELFTEST: PASS
(cases=21)` rc 0; M-A (the `# BEGIN-DECIDE` block replaced by `echo 5`) `C2_SELFTEST: FAIL
(cases=21 failed=6)` rc 1 with FINDINGs `decide-pass`, `decide-shims`, `decide-none`,
`decide-selftest`, `decide-ops`, `decide-t2w`; M-B (the `# BEGIN-SHIMS` block replaced by
`shims_ok=5`) `C2_SELFTEST: FAIL (cases=21 failed=3)` rc 1 with FINDINGs `shims-ok`,
`shims-bad`, `shims-summary`; the stub-trial tree `C2_SEAL_TRIAL: value=0 … guard=0` rc 1
(receipt `c2-hardened-census.txt`). killed = 3 of 3 — the frozen target. The real-trial
positive control read `C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5
selftest=1 guard=1 … cases=63` rc 0 (receipt `c2-real-hardened.txt`), the same line the
BASE counter printed — the hardening did not weaken the gate. The round-62 counter on the
same tree reads `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1
real=1)` rc 0 (receipt `c2-verdict-worktree-2.txt`) — the frozen target line. An earlier
run of the same counter read `guard=0` because the real-trial leg failed under host
contention (`real=0 real2=0 ops=0`, one shim reading `HBHEH`, receipt
`c2-verdict-worktree.txt`); the trial run directly on the same tree immediately after read
`OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` rc 0 (receipt
`trial-direct-1.txt`), so that failure is host load, not a counter defect. The committed
candidate receipt `.ufo/waves/round-62/final/candidate.txt` is the L1's to land.

## Bounds

1. **The five fixtures are the reviewer's five.** A sixth negation or pairing class is a new
   routed defect, not a failure of this contract. The grammar narrows the class; it does not
   enumerate forgeries.
2. **A structural read proves assertion, not truth.** The hardened item proves the sentence
   *asserts* the correction; it cannot prove the corrected sentence true. QM79 narrows this
   gap and never closes it.
3. **The negator window is a floor.** A false assertion with no negator and all the tokens
   still passes; the closed set and the 5-token window are the declared floor, not a parser.
   The published rule bounds a trigger's scope to six *following* tokens (S130); the lane's
   five-token look-behind is its own choice, and the source grounds the shape, not the
   length or the direction.
4. **Two mutation classes are not a complete mutation set.** M-A and M-B replace a whole
   aggregation with a constant; a mutant that preserves the aggregation's shape and corrupts
   one comparison (an operator or a boundary) is outside the frozen set and may survive.
5. **The real leg needs `bao` on PATH, and a quiet host.** Without the binary the counter
   reads SETUP, not a verdict; under host contention a real run can fail (one round-62 run
   read `real=0` with `ops=0` and one shim reading `HBHEH`, while the trial run directly on
   the same tree immediately after read `HOLDS holds=5`). The real-trial reading is a host
   capability, not a property of the tree.
6. **The paraphrase set is three rewrites, not a grammar.** A benign rewording outside P3–P5
   may be rejected; that fails the guard (a false positive), not the benign text.
7. **The guard challenge is one stub shape.** A valid-sha256 trial that prints nothing is
   the frozen challenge; a stub that prints a plausible but wrong observable is the
   fabrication class, unchanged from the round-61 K2 ceiling.
8. **The counter still trusts the trial's printed observables.** No independent oracle
   exists for the trial's own claims; the round-61 M61-8 ceiling stands.
9. **The C1 stub refusal is a printer-stub refusal.** A checker that prints a constant
   verdict line is refused; a stub that prints a plausible full item vector is not covered
   by that leg alone.

## Falsifiers

1. A tree byte-identical to BASE reads `accepted` < 5 on `bash plans/round-62-c1.sh` ⇒ a
   fixture is vacuous and the claim is void (the plan's K1).
2. Any of B3–B7 reads rejected (`value` ≠ 0) on the BASE checker ⇒ the fixture does not
   test the item it is assigned to.
3. Any of B3–B7 reads accepted on the hardened checker ⇒ the bypass class is not closed.
4. Any of P3–P5 reads rejected on the hardened checker ⇒ the hardening rejects benign
   rewording and the guard leg fails, not the claim.
5. A printer-stub checker reaches a `C1_BYPASS:` verdict line ⇒ the stub refusal is broken.
6. The hardened checker's `--selftest` passes on a copy with a verdict mapping inverted or
   an item's polarity test removed ⇒ the selftest does not execute the grammar.
7. M-A or M-B passes `--selftest` on the candidate ⇒ the selftest does not execute the
   aggregation.
8. The stub-trial tree reads `guard=1` on the candidate ⇒ the guard still cannot tell
   "could not evaluate" from "evaluated and failed".
9. The real trial reads anything but `value=5 … shims=5 vectors=ok/5` on the candidate ⇒ the
   hardening weakened the gate.
10. `bash plans/round-62-c1.sh` at BASE reads `accepted` ≠ 5 ⇒ the counter's BASE control is
    broken.
11. The unmodified copy reads `value` ≠ 0 on the hardened checker ⇒ a false positive, and
    the claim's guard leg (a) fails.
12. A paraphrase tree that reads the same line as its bypass sibling ⇒ the fixture pair is
    not discriminating and the guard is vacuous.
