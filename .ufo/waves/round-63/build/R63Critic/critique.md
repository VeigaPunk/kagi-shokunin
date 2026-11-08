# R63Critic — the two predicates falsified before the candidate reading

Seat `R63Critic`, kagi round 63 attempt 1. Read-only over the lane; every write is under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63Critic/` and this receipt directory.
No lane commit, no `git add/commit/stash/push`, no mutating `jj`, no host mutation. No
tool installs were needed (`python3`, `bash`, `git`, `bao` v2.7.2 already present).

Read before working: `plans/round-63.md` (frozen at `12c9e428`, 277 lines; the working
copy at lane HEAD `966c469` carries A1+A2, 303 lines), `.ufo/waves/round-62/w1/R62Critic.md`,
`corpus/lessons/round-62-verifier-spotcheck.md` §2/§6, `corpus/lessons/round-62.md`, the
L1 BASE census `.ufo/waves/round-63/base/census.md`, and the dispatch
`.ufo/waves/round-63/w1-dispatch.json` (15 seats, `counts.spawn=15`).

## Instruments and bytes measured

| object | revision / sha256 | note |
|---|---|---|
| measured tree | `0c07aab8df64b673a54a5113aebd7f34b622adbc` (`git archive`) | the claim BASE |
| BASE checker | `plans/round-61-c1-check.py` `f2afd9b8f538…` | 1710 lines; `--selftest` ⇒ `PASS (cases=75)` |
| BASE C1 counter | `plans/round-62-c1.sh` `efe676ebb0d0…` | 451 lines; selftest `PASS (8/8 checks)` |
| BASE C2 counter | `plans/round-62-c2.sh` `b26d42207ff5…` | 331 lines; `needle-ma` at `:279` |
| BASE battery | `plans/round-62-controls.sh` `93587e6d15d5…` | 904 lines; `grep -c 'C1-F8\|C2-F6'` ⇒ 0 |
| frozen plan | `12c9e4284d6de52ba61fcc656165cd24e8b74480` | 277 lines; **A1/A2 are not in it** (`grep -c 'Amendment A2'` ⇒ 0) |
| working plan | lane HEAD `966c469` | 303 lines; A1 (15 seats), A2 (C2 population 5) |
| dispatch | `.ufo/waves/round-63/w1-dispatch.json` | `counts.spawn=15`; milestone says `killed 0->6` |
| fleet report | `.ufo/reports/round-60/kagi.md` | §Stale-lane line 194: `launch 15:09:28 -03` (ASCII hyphen) |

## Attempts (every command below was run; the receipt is the observed output)

### A1 — C1 BASE census, independently re-derived (16 fixtures)

For each fixture: `cp -a` the BASE tree, assert the plan's anchor occurs exactly once,
apply the byte-exact replacement, run

```
python3 -I -B plans/round-61-c1-check.py --root <copy> \
  --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
```

Observed (`fixtures-base.json`, 402 s):

```
F1..F10 | count=1 | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
P1,P2   | count=1 | rc=1 | C1_ROUTED: value=1 … i3=0 … guard=0
P3,P4   | count=1 | rc=1 | C1_ROUTED: value=1 … i4=0 … guard=0
P5,P6   | count=1 | rc=1 | C1_ROUTED: value=1 … i5=0 … guard=0
unmodified | —    | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
```

accepted = 10, rejected = 6; every anchor occurs exactly once; F9/F10's anchor uses
U+2212 (`\xe2\x88\x92`) and the lesson carries exactly one occurrence (the ASCII-hyphen
variant count is 0). **The BASE population is non-vacuous and the L1 census re-derives.**

### A2 — the frozen C1 command line is not executable on the BASE checker

```
python3 -I -B plans/round-61-c1-check.py --root <base> --repo <lane> \
  --fleet /home/vgpnk/Projects/shokunin --no-challenge
⇒ round-61-c1-check.py: error: unrecognized arguments: --fleet …   rc=2
```

The checker's argparse (`:1678-1692`) has `--root --repo --no-challenge --json
--verbose --selftest --work`; no `--fleet`. The L1's own census command block omits
`--fleet` (`.ufo/waves/round-63/base/census.md`), so the census was measured with a
different command than the frozen predicate prints. The candidate checker is told to add
`--fleet` (grammar seat prompt), so the flag is candidate-only; the BASE leg cannot use it.

### A3 — C2 legs at BASE: the two CM2 mutants survive, the GM5 mutant survives

```
# CM2a: the stub composition line replaced by `stub=1`
bash plans/round-62-c1.sh --selftest --tree <cm2a> ⇒ C1_COUNTER_SELFTEST: PASS (8/8 checks) rc=0
# CM2b: `SL_OK=1` appended before stub_leg's closing brace
bash plans/round-62-c1.sh --selftest --tree <cm2b> ⇒ C1_COUNTER_SELFTEST: PASS (8/8 checks) rc=0
# GM5: `ok = len(qualifying) >= 3 and bool(superseded) and not denied`
#      → `ok = len(qualifying) >= 3 and not denied` (needle count 1, line 756)
python3 -I -B plans/round-61-c1-check.py --selftest ⇒ C1_CHECK_SELFTEST: PASS (cases=75) rc=0
```

The L1 census's L1/L2/L6 rows re-derive. `plans/round-62-c2.sh:279` carries
`[ "$ma_applied" = 1 ] || setup needle-ma`; an S3 tree (markers removed, aggregation text
altered) reads `C2_HARDENED: SETUP needle-ma` rc 2. **L5 fires at BASE; A2's vacuity
finding is correct.**

### A4 — C1 guard (e) / the lookup-table counterexample (the decisive measurement)

A checker that implements no grammar: a 15-string lookup table (the ten F replacements
plus the five B replacements), `--selftest` prints a constant
`C1_CHECK_SELFTEST: PASS (cases=91)`, the unmodified tree prints `value=0`, any table hit
prints `value=1`. Measured over all 24 committed fixtures (16 round-63 + 5 bypass + 3
paraphrase):

```
F1..F10 → value=1 (10/10 rejected)      P1..P6 → value=0 (6/6 resolved)
B3..B7  → value=1 (5/5 rejected)        P3..P5 → value=0 (3/3 resolved)
unmodified → value=0
```

Every frozen C1 guard leg is satisfied: (a) unmodified `value=0`; (b) `PASS (cases=91)`
with N ≥ 91; (c) B3..B7 `value>=1`; (d) P3..P5 `value=0`; (e) the counter's printer-stub
test replaces the tree's checker with its own constant `value=0` stub, which this checker
is not — the selftest gate sees a PASS line and the stub leg passes. **The C1 target
`accepted=0 AND rejected=0` is reachable with zero grammar hardening.**

The round-62 counter catches the same checker only through its `chal` leg:

```
bash plans/round-62-c1.sh --tree <lookup-table tree>
⇒ C1_BYPASS: accepted=0 population=5 guard=0 (real=1 selftest=1 stub=1 paraphrase=1 chal=0) rc=1
```

The round-63 plan's guard legs (a)–(e) contain no `chal` leg; K5's "must fail on a
mutated copy" is a kill rule for the mutation-testers, not a counter leg.

### A5 — B6 and the plan's I6 text

```
# B6 (the paragraph's times are correct.) on the BASE checker
C1_ROUTED: value=1 … i6=0 … guard=0
c1: i6 FAIL … denial=are correct|times are correct
```

B6 is rejected only by the BASE checker's `I6_DENY_PHRASES` (`times are correct`,
`times are right`, `is correct`, `are correct` — round-62 Amendment A1 clause (d)). The
round-63 plan's I6 item text (launch line + ≥3 derived committer stamps + quoted
superseded span = fleet stamp) has no denial clause; implemented literally it accepts B6
and guard leg (c) fails. The grammar seat's prompt adds "Keep … the denial-phrase
exclusion", so the seat may rescue it, but the frozen predicate does not carry it.

### A6 — the plan's I4/I5 texts name no line scope

The BASE checker scopes I4 to the last `supersedes the round-60 quality-trend sentence`
line (`:667-670`) and I5 to the last `supersedes the round-60 LOG wave line` (`:694-697`).
The plan's I4/I5 item texts say only "an occurrence of `three` …" / "an occurrence of
`rewritten in place` …". `grep -rIl 'rewritten in place'` matches **71 files** in the
tree (`.ufo/waves/round-22…`, sandboxes, lessons); a whole-file I5 resolves on an
unrelated occurrence and F7 is accepted. Round-62 critic D1/D2 (high) recur unchanged.

### A7 — the I6 quoted-span scope

The unmodified correction line's whole-line `HH:MM:SS` set is
`superseded-stamp=15:09:28,16:34:37` (the BASE checker's own i6 detail); `16:34:37` is
the "complete" stamp outside the double-quoted span, and the line also carries four
backticked committer stamps. The plan says "a quoted superseded span"; a whole-line or
backtick-inclusive reading requires `{15:09:28, 16:34:37, …} == {15:09:28}` and fails
guard (a) on the unmodified tree. Only the double-quoted span (`"launch 15:09:28 −03"`)
has the singleton set.

### A8 — causal separability

```
# C1 on a tree stripped of plans/round-60-c2.sh
C1_ROUTED: value=1 … i2=0 … guard=0
# C1 on a tree stripped of plans/round-61-c2.sh, plans/round-62-c2.sh,
#   corpus/openbao-seal-trial.sh
C1_ROUTED: value=0 … i1..i7=1 guard=0
```

C1 is independent of the round-61/62 C2 files but **coupled to `plans/round-60-c2.sh`**
through the inherited I2 leg A (round-62 critic D6). C2's L1/L2 name
`plans/round-62-c1.sh` — the C1 counter — so C2 is coupled to a C1 file. Neither
coupling is declared in the plan.

### A9 — C2 leg L1/L2 cross-seat interface

The C1 counter seat is told to "extract the stub composition into a `stub_calc` function"
— the exact line the C2 L1 needle names (`  stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]]
&& stub=1`, `:324`). The C2 L1/L2 legs require the mutant selftest to print "a named
`FINDING`"; the BASE counter's selftest prints `C1_COUNTER_SELFTEST: FAIL (N/8 checks)
failed=<names>` and no `FINDING` line, while the C2 counter's `finding_named` requires
`^FINDING R61-C2-ST-`. The C1 seat's prompt says "a named `FINDING`/failed-case line" —
not the `R61-C2-ST-` prefix. If the C1 seat emits `failed=`, the C2 legs do not fire.

### A10 — C2 L3/L4 instrument

The plan's L3/L4 legs run "the controls battery"; the C2 seat's prompt names
`bash plans/round-63-controls.sh <tree>`, which does not exist at BASE. The L1 census
substitutes `grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh` ⇒ 0 and the stub
counters' own rc 0. The BASE reading is "the control is absent", not "the stub survives a
control". The round-62 battery records an absent control as `verdict=skip` (its own
header), so a 5-leg counter that runs the round-62 battery at BASE would read a skip, not
a leg field.

### A11 — the plan's population/identity conflict

- Frozen plan `12c9e428`: `C2_REFUSAL … POP = 6 … Target 6 (BASE 0)`, six legs L1–L6.
- Lane HEAD `81bd56c` (A2, after the predeclaration): `population is therefore 5, target
  killed=5`, L5 dropped, output line without `l5`.
- Dispatch `w1-dispatch.json` (committed `4fe6c0d`, before A2): the C2 seat's prompt says
  `population=6`, runs L1–L6, and its acceptance is `killed=0 population=6 guard=0`; the
  registry milestone (all 15 seats) says `C2 C2_REFUSAL killed 0->6`.
- The assignment for this seat says `killed 0 -> 6`.
- The L1 census says "killed = 0 over the five non-vacuous legs".

A 6-leg counter whose L5 leg requires `SETUP needle-ma` reads `l5=1` at BASE and therefore
`killed>=1` at BASE, contradicting the seat's own acceptance `killed=0 population=6`.
A 5-leg counter contradicts the seat's prompt and the milestone. The two authorities
cannot both be satisfied.

### A12 — wave shape

`w1-dispatch.json` `counts.spawn=15` (A1); the assignment says 16 and the plan §Wave says
16. Attack share is 4/15 = 26.67 % (5/15 = 33.33 % counting the sentinel), not 4/16 = 25 %.

### A13 — the controls battery's real-trial leg is load-sensitive

First run (fleet load 19–33, a concurrent fixture job):

```
CONTROLS: match=12 mismatch=2   rc=1
CONTROL C2-F4 expect=value=5;shims=5;vectors=ok/5 observed=value=0;shims=0;vectors=0/5 verdict=mismatch
DETAIL C2-F4 … sh1=BHHHH sh2=HBHEH sh3=HHBEH sh4=HHHEH sh5=HHHHB … cases=63
CONTROL C2-F5 expect=guard=0;cleanguard=1 observed=guard=0;cleanguard=0 verdict=mismatch
```

The shim vectors carry `E` (the trial's T3 seal / T4 generate-root legs errored; the
trial's `verdict` maps an errored leg to `ERROR`). Re-run alone, same tree:

```
CONTROLS: match=14 mismatch=0   rc=0
DETAIL C2-F4 real-trial rc=0 line=C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5
  vectors=ok/5 selftest=1 guard=1 (… sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH
  sh5=HHHHB … cases=63)
CONTROL C2-F5 … verdict=match
```

The battery reads the load-induced `E` vector as `real-verdict-weakened` (a counter
defect), not as a trial error. The plan's C2 guard (c) (`value=5 … shims=5 vectors=ok/5`)
and guard (d) ("the controls battery's existing controls still match with 0 skips")
depend on this trial; the plan's ceiling names only "the real leg needs `bao`", not the
load sensitivity.

## Findings

Severity: high = decides whether the claim can reach its target or whether the measured
reading is the predicate's; medium = the claim can pass but the guard/reading is weaker
than stated; low = wording/ceiling.

| id | sev | clause | observation (measured) | fix |
|---|---|---|---|---|
| C1-1 | high | C1 target + guard (a)–(e) | A 15-string lookup-table checker with a constant `PASS (cases=91)` selftest reads F1..F10 `value=1`, P1..P6 `value=0`, B3..B7 `value=1`, P3..P5 `value=0`, unmodified `value=0` — every frozen guard leg passes and `accepted=0 rejected=0` is reached with no grammar. The round-62 counter refuses the same tree only via its `chal` leg (`chal=0 guard=0`); the round-63 guard has no `chal`. | Add the round-62 `chal` leg (mutated-copy challenge: emptied negator set must make the checker's selftest FAIL) to the C1 guard and make K5 a counter leg; or pin the checker on a held-out fixture not in the committed TSVs. |
| C1-2 | high | C1 command line | `--fleet` is an unrecognized argument on the BASE checker (`rc=2`, usage error); the L1 census silently omits it. The frozen command cannot produce the BASE census. | State the BASE invocation without `--fleet` (candidate default) or make the counter probe the flag; the census must use the frozen command or the plan must mark `--fleet` candidate-only. |
| C1-3 | high | C1 I6 item text | B6 (`the paragraph's times are correct.`) reads `value=1` on the BASE checker only because of `I6_DENY_PHRASES` (`denial=are correct\|times are correct`, A1); the plan's I6 text has no denial clause and accepts B6 → guard (c) fails. | Name the denial-phrase exclusion in the frozen I6 item (the four phrases), or route B6 as a ceiling and drop it from guard (c). |
| C1-4 | high | C1 I4/I5 item texts | The BASE checker scopes I4 to the last quality-trend line and I5 to the last LOG wave line; the plan's texts name no line/file. `rewritten in place` occurs in 71 tree files; a whole-file I5 resolves F7, and the other `three` occurrences resolve F4/F5/F6. | Name the line scope in the item texts (round-62 D1/D2 recur). |
| C1-5 | medium | C1 guard (b) / K5 | The floor is a count: the lookup table prints `PASS (cases=91)` and passes; the counter checks only the count, not that any case exercises a fixture class. K5's mutated-copy test is not a guard leg. | Require the selftest to fail on a mutated copy inside the counter's guard (the `chal` leg), not only in a kill rule. |
| C1-6 | medium | C1 I6 quoted-span scope | The unmodified line's whole-line set is `{15:09:28, 16:34:37}` plus four backticked committer stamps; a whole-line or backtick-inclusive reading fails guard (a). Only the double-quoted span is the singleton `{15:09:28}`. | Name the double-quoted span and the exact extraction regex in the I6 item. |
| C1-7 | medium | C1 separability | Stripping `plans/round-60-c2.sh` makes the unmodified tree `value=1` (`i2=0`); guard (a) then fails and every fixture reading shifts. C1 is coupled to a C2 instrument (round-60's counter). | Declare the coupling in the plan's ceilings, or make I2's selftest leg independent of the round-60 C2 counter. |
| C2-1 | high | C2 population / target | A2 (5, no L5) contradicts the C2 seat's dispatch prompt (6, L1–L6, acceptance `killed=0 population=6`) and the milestone (`killed 0->6`). L5 fires at BASE (`SETUP needle-ma` rc 2), so a 6-leg counter reads `killed>=1` at BASE and fails its own acceptance. | Restate the seat prompt and the milestone to A2's 5-leg shape (or revert A2 and route L5); the report must name the population it answers. |
| C2-2 | high | C2 L5 premise | The seat prompt says "the M-A leg at :277-288 has no `setup needle-ma`"; `plans/round-62-c2.sh:279` already carries it at BASE (S3 tree ⇒ `SETUP needle-ma` rc 2). | Correct the prompt; the seat must not add a duplicate guard. |
| C2-3 | high | C2 L1/L2 cross-file ownership | L1/L2 mutate `plans/round-62-c1.sh`, owned by the C1 counter seat, which is told to refactor the exact L1 needle line into `stub_calc`; a byte-changing refactor makes the L1 mutation match 0 times → SETUP → the C2 target unreachable. The L1/L2 legs also require a `FINDING` line; the C1 counter's selftest prints `failed=`, and the C2 `finding_named` requires `^FINDING R61-C2-ST-`. | Freeze the post-refactor needle (or forbid changing the line) and name the required `FINDING` prefix in the C1 seat's prompt; the C2 seat must not depend on a file it does not own. |
| C2-4 | medium | C2 L3/L4 BASE reading | The legs name `plans/round-63-controls.sh`, absent at BASE; the census substitutes the round-62 battery's `grep` (0 controls) and the stub counters' rc 0. The BASE reading is "instrument absent", not "the stub survives a control". | State the BASE reading as "instrument absent" and add a negative control (the new control must match on the clean tree) so a tautological control cannot satisfy the leg. |
| C2-5 | medium | C2 L3/L4 mechanism | The control compares the stub counter's output to the hardcoded BASE line (`accepted=10 rejected=6` / `killed=0`); the stub prints the target line → mismatch by construction. The control does not exercise the counter's refusal logic; the plan's ceiling admits a stub that prints the expected line passes. | Name the control's expected observation as "the tree's counter is the stub" (a no-work control) rather than "the counter refuses"; add a clean-tree match leg. |
| C2-6 | medium | C2 L6 needle | The plan prints the replacement (`ok = len(qualifying) >= 3 and not denied`) as if it were the needle; the BASE line is `ok = len(qualifying) >= 3 and bool(superseded) and not denied` (`:756`). A literal needle of the parenthetical matches 0 times → SETUP. | State the needle and the replacement separately (the seat prompt does; the plan does not). |
| C2-7 | medium | C2 L1/L2/L6 test quality | The legs accept a source-pin selftest (grep the counter's own bytes for the literal line/conjunct) as readily as a behavioral test; K5 only requires the selftest to fail on a mutated copy, which a source-pin does. | Require the selftest case to exercise the mutated behavior (the C1 seat's `stub_c1=0` case is the behavioral form). |
| C2-8 | low | scratch discipline | `plans/round-62-c1.sh` hardcodes `SCRATCH_ROOT=…/kagi-r62/R62ExecC1Counter`; a round-63 copy writes under the round-62 scratch (observed in every run), not `kagi-r63/<seat>`. | Parameterize the scratch root for the round-63 counter. |
| B-1 | high | judged milestone vs frozen plan | The assignment and the dispatch milestone say C2 `killed 0->6`; the plan's A2 says 5 and the L1 census says "five non-vacuous legs". A report answering 5 fails the milestone; a report answering 6 fails the plan. | The L1 must state the population the report answers; restate the milestone to A2's 5 (or revert A2). |
| B-2 | medium | wave shape | The dispatch carries 15 seats (`counts.spawn=15`, A1); the assignment and the plan §Wave say 16. Attack share is 4/15 = 26.67 % (5/15 = 33.33 %), not 4/16 = 25 %. | The report must cite the dispatch's 15 and A1. |
| B-3 | medium | separability | C1's guard (a) depends on `plans/round-60-c2.sh` (I2); C2's L1/L2 depend on `plans/round-62-c1.sh` (the C1 counter). Neither coupling is declared. | Declare both couplings in the plan's ceilings (round-62 D6 recurs). |
| C2-9 | medium | C2 guard (c)/(d) / battery flakiness | Two runs of `plans/round-62-controls.sh <extracted-BASE>` on the same tree: first (fleet load 19–33) `match=12 mismatch=2` with C2-F4 `vectors=0/5` and shim vectors carrying `E` (T3/T4 legs errored); second `match=14 mismatch=0` rc 0. The battery reads a load-induced trial error as `real-verdict-weakened`, not as a trial error; guard (c)/(d) are load-sensitive. | Make the trial's shim legs retry on an `ERROR` vector (or the counter treat `E` as SETUP/retry, not a guard failure); the battery's C2-F4 should distinguish "trial errored" from "counter weakened". |

## Ceilings the plan smooths

- **C1**: the plan's named ceilings cover the negator/denial/idiom lists and the ten
  fixtures, but not (i) the guard's inability to distinguish a fixture-lookup checker
  (C1-1), (ii) the `--fleet` command mismatch (C1-2), (iii) the I6 denial-phrase omission
  (C1-3), (iv) the I4/I5 line scope (C1-4), (v) the count-only selftest floor (C1-5),
  (vi) the quoted-span scope (C1-6), (vii) the I2 coupling (C1-7).
- **C2**: the plan's ceiling "a stub that prints exactly the independently expected line
  is indistinguishable by output alone" is honest, but it is not the only smoothing:
  the population/target identity (C2-1), the false L5 premise (C2-2), the cross-file
  needle ownership (C2-3), the absent-instrument BASE reading (C2-4), the tautological
  control (C2-5), the needle/replacement conflation (C2-6), and the source-pin test
  (C2-7) are all undeclared.
- **Both**: the two claims are not separable (B-3); the milestone and the plan disagree
  (B-1); the wave is 15 seats, not 16 (B-2).

## Do-nothing control verdict

**The byte-identical no-work control does not reach either target.** A tree at
`0c07aab8` reads C1 `accepted=10 rejected=6` (guard=0) and C2 `killed=0` over the five
non-vacuous legs — both targets fail, as declared.

**The cheapest no-hardening C1 control does reach the target.** A 15-string lookup-table
checker with a constant `PASS (cases=91)` selftest and no grammar reads
`accepted=0 rejected=0` with all five guard legs satisfied (A4). The C1 predicate is
therefore not causally tied to the grammar hardening it claims: a checker that reads no
fixture semantics passes. The round-62 `chal` leg is the only measured mechanism that
refuses this control, and the round-63 guard dropped it.

**The cheapest C2 control is a source-pin, not a behavioral test.** L1/L2/L6 accept a
selftest case that greps the counter's own bytes for the literal line/conjunct; L3/L4
accept a control that compares a stub's output to the hardcoded BASE line. Neither
exercises the mutated behavior. The target is reachable without hardening the aggregation
or the checker's I6 logic; only the shape of the selftest changes.

## Impacted axes

- **calibration** — C1-1..C1-7, C2-1..C2-3, C2-6, C2-7, B-1, B-3.
- **operability** — C2-1..C2-8, C1-1, C1-2, B-1, B-3.
- **No axis is harmed by a finding that is only a named ceiling**; C1-5, C1-6, C2-4,
  C2-5, C2-8 are ceilings/weaknesses, not claim failures on their own.

SEAT-STATUS: complete
