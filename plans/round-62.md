# Round 62 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 62, attempt 1. Claim BASE
`60b5b7b60b76629633110a5b4adac883193c8b2a` (round-61 verifier spot-check tip,
`round-61 verifier spot-check (integrator, hyaku): non-author admit/reject`, 2026-11-07).

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; capabilities entered rounds
57, 58, 59, 60 and 61, so no stagnation waiver is claimed. Both claims are declared
here before any candidate work; this file is committed alone as the predeclaration,
then the instruments, then the pre-freeze control battery, then the candidate.

Motivating evidence for the round:

- `corpus/lessons/round-61-verifier-spotcheck.md` §7.7 and `SCORECARD.md` §Planned
  (round-61 close) name this round's two candidates: **QM79** (the C1 item grammar
  accepts a negation or a swapped pairing) and **C2-4/C2-5** (the C2 counter's
  `guard` is a near-constant and its `--selftest` never executes the aggregation).
- Measured at BASE by the reviewer (`plans/round-61-c1-check.py` bytes, 67905 B):
  five attack trees — `not withdrawn`, `no three`, `not rewritten in place`,
  "the paragraph's times are correct", and `3/16 = 25 %` / `4/16 = 18.75 %` — each
  keeps every token the frozen item names and each reads `value=0` (accepted).
  Re-measured by the L1 at BASE: `B3..B7` all read
  `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0`, rc 1 (accepted).
- Measured at BASE by the L1: `plans/round-61-c2.sh` with its main aggregation
  replaced by a constant `value=5` reads `C2_SELFTEST: PASS (cases=11)` rc 0, and
  with its shim aggregation made unconditional reads the same — the two reviewer
  mutations survive. A tree whose trial is a valid-sha256 stub that prints nothing
  reads `C2_SEAL_TRIAL: value=0 … guard=1` — the guard does not discriminate.
- The round-61 spot-check §7 routes five record defects (D1–D5); this round resolves
  them as work items (receipt `plans/round-62-routed.sh`), not as a third claim: a
  second calibration claim would be the same claim (AXES.md §"two claims on one
  axis count as one claim"), and the plan's calibration candidate is QM79.

## C1 — calibration: the C1 checker's negation / swapped-pairing bypass class is closed

Target axis: calibration (mismatch count between the lane's own statements and the
observed repository state — here, between a forged correction and the checker that
grades it).

**Frozen predicate (this sentence is the plan's, the counter's code and the receipt's label):**

```
C1_BYPASS: accepted = the number of the five committed bypass fixtures (B3..B7, one per
round-61 checker item I3..I7) on which the measured tree's checker
(plans/round-61-c1-check.py, invoked `python3 -I -B … --root <copy> --repo <lane>
--no-challenge`) prints `C1_ROUTED: value=0` — i.e. accepts the negation or
swapped-pairing forgery — when GUARD = 1, else FAIL. POP = 5; target 0 (BASE 5).
GUARD = 1 iff, on the same measured tree: (a) the unmodified copy prints `value=0`
(the seven round-61 corrections still resolve — no false positive); (b) the checker's
`--selftest` exits 0 printing `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 57;
(c) a printer-stub checker (a file printing a constant `C1_ROUTED: value=0 …` line)
is refused — the counter's measure leg on a stub tree prints no `C1_BYPASS:` verdict
and exits non-zero; and (d) the three committed paraphrase fixtures (P3, P4, P5)
each still print `value=0` (benign rewording is not a defect).
```

Every number the counter compares is derived at run time from the measured tree or,
where a fixture names a revision, from the lane repository; no constant carries a fact
the measured tree asserts. The five fixtures are the reviewer's five bypass trees,
frozen here as anchor→replacement pairs (each must occur exactly once in the measured
tree; 0 or >1 occurrences fails closed):

| id | file | anchor | replacement (the forgery) |
|---|---|---|---|
| B3 | `plans/round-60.md` | `**A3 item 2 is withdrawn**` | `**A3 item 2 is not withdrawn**` |
| B4 | `corpus/lessons/round-60.md` | `the round introduced three new record defects it did not route` | `the round introduced no three new record defects it did not route` |
| B5 | `LOG.md` | `it was rewritten in place at` | `it was not rewritten in place at` |
| B6 | `corpus/lessons/round-60.md` | `the lane was progressing, not stale.` | `the paragraph's times are correct.` |
| B7 | `corpus/lessons/round-60.md` | `so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %` | `so the literal reading is 3/16 = 25 %, and counting the sentinel as an attack seat gives 4/16 = 18.75 %` |

The three paraphrase fixtures (guard leg d; benign rewrites that keep the assertion):

| id | file | anchor | replacement (benign) |
|---|---|---|---|
| P3 | `plans/round-60.md` | `**A3 item 2 is withdrawn**` | `**A3 item 2 is hereby withdrawn**` |
| P4 | `corpus/lessons/round-60.md` | `the round introduced three new record defects it did not route` | `this round did introduce three new record defects it did not route` |
| P5 | `LOG.md` | `it was rewritten in place at` | `it was rewritten in place, at` |

**The hardened grammar (the instrument this claim lands), item by item.** Each rule
tests the token in the asserting position; the negator set is closed and named here.

| item | hardened condition |
|---|---|
| I3 | at least one occurrence of `withdrawn` whose 12-token window before it contains `A3 item 2` and whose 5-token window before it (truncated at the nearest `.`, `;` or `:`) contains no negator |
| I4 | `three` occurs with no negator in its 5-token window before it (truncated at `.`/`;`/`:`) |
| I5 | `rewritten in place` occurs with no negator in its 5-token window before it (same truncation) |
| I6 | the correction line carries the driver launch line, at least three `-03:00` stamps in the derived committer set, **and** at least one `HH:MM:SS` time that is neither the launch line's time nor a derived committer time (the superseded paragraph's stamp must be quoted — QM78) |
| I7 | the derived fraction and its derived percentage are paired in one expression: `3/16 = 18.75 %` and `4/16 = 25 %` (whitespace-tolerant, numbers derived from the wave results file) |

Negator set (case-insensitive, word-boundary): `not`, `no`, `never`, `neither`, `nor`,
`without`, `none`, `n't`. The bigram `not only` immediately before the match is an
idiom, not a negator. The window is a floor, not a parser (named ceiling).

Commands:

```
bash plans/round-62-c1.sh [revision]          # BASE when omitted; --tree DIR also accepted
python3 -I -B plans/round-61-c1-check.py --root <tree> --repo <lane> --no-challenge
```

Output line: `C1_BYPASS: accepted=A population=5 guard=G (real=… selftest=… stub=… paraphrase=…)`.
Exit 0 iff guard=1 and accepted=0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a tree byte-identical to BASE must read `accepted=5 population=5`; any lower
  reading means a fixture is vacuous and voids the claim (BASE census, `--no-challenge`).
- K2: each of the five fixtures must be able to read accepted on the BASE checker and
  rejected on the hardened checker; the controls battery's `C1-F1..C1-F5` re-run each
  fixture on the candidate tree and must read exactly 1.
- K3: a printer-stub checker must be refused (guard leg c); a stub that self-attests
  `value=0` is the round-61 reviewer's C1-1 defect and must not reach a verdict line.
- K4: the three paraphrase fixtures must read 0 accepted (guard leg d); a hardening
  that rejects benign rewording fails the guard, not the claim.
- K5: the checker's `--selftest` must contain one case per fixture class (five bypass
  cases and three paraphrase cases) and must fail on a mutated copy (a verdict mapping
  inverted or an item's polarity test removed).

**Population census at BASE (measured, not assumed):** the five fixture copies of
`60b5b7b6` each read `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0`, rc 1;
the unmodified copy reads `value=0 … guard=0`. Accepted = 5.

**Named ceilings:** the five fixtures are the reviewer's five; a sixth negation or
pairing class is a new routed defect, not a claim failure. A structural read cannot
prove the corrected sentence true — it proves the sentence asserts the correction
(QM79 narrows, never closes, this). The negator set and the 5-token window are a
floor: a forger who writes a false assertion with no negator and all the tokens
still passes. The paraphrase set is three rewrites, not a grammar.

## C2 — operability: the C2 counter's guard and self-invocation can fail

Target axis: operability (a runnable artifact that produces the stated outcome — here,
a gate whose self-invocation mode witnesses its own verdict and whose guard
distinguishes "evaluated and failed" from "could not evaluate").

**Frozen predicate:**

```
C2_HARDENED: killed = the number of the three falsifier legs that fire over POP = 3 —
M-A (the measured tree's C2 counter, plans/round-61-c2.sh, with the block between its
`# BEGIN-DECIDE` and `# END-DECIDE` markers replaced by `  echo 5`, makes `--selftest`
exit non-zero printing a named `FINDING`),
M-B (the same counter with the block between its `# BEGIN-SHIMS` and `# END-SHIMS`
markers replaced by `  shims_ok=5`, makes `--selftest` exit non-zero printing a named
`FINDING`),
G (a tree whose trial file is a valid-sha256 stub that prints no expected observable
reads `guard=0` on the unmutated counter) — when GUARD = 1, else FAIL.
Target 3 (BASE 0).
GUARD = 1 iff, on the same measured tree: (a) the unmutated counter's `--selftest`
exits 0 printing `C2_SELFTEST: PASS (cases=N)` with N >= 17; (b) the counter on the
real trial reads `value=5 … shims=5 vectors=ok/5` (the hardening preserves the real
verdict); (c) a constant-verdict counter (a copy whose `--selftest` prints PASS without
executing the aggregation) is refused by the counter's own stub control.
```

The hardened counter exposes two testable units, delimited by the markers above:
`decide` (the value aggregation: pass, shims, none, selftest, ops, t2w → 0|5) and the
shim aggregation (five shim vectors → 0..5). `--selftest` calls both with positive and
negative vectors, so a mutant that replaces either block with a constant fails a case.
The `guard` leg requires every leg's expected observable (the trial's
`SEAL_SELFTEST: PASS (cases=N)` line, the ops argv shapes, the T2 markers), not just a
captured rc.

Commands:

```
bash plans/round-62-c2.sh [revision]          # BASE when omitted; --tree DIR also accepted
bash plans/round-61-c2.sh --tree <tree>       # the measured counter
bash plans/round-61-c2.sh --selftest          # the self-invocation mode
```

Output line: `C2_HARDENED: killed=K population=3 guard=G (ma=… mb=… g=… selftest=… real=…)`.
Exit 0 iff guard=1 and killed=3; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a tree byte-identical to BASE must read `killed=0 population=3` (M-A and M-B
  survive, G reads guard=1); any higher reading means a leg is vacuous.
- K2: M-A and M-B must each be able to survive (BASE) and be killed (candidate); the
  needle must match exactly once (0 or >1 fails closed).
- K3: the guard challenge G must read `guard=1` at BASE and `guard=0` on the candidate;
  a guard that reads 0 on the real trial fails leg (b), not the claim.
- K4: the real trial must still read `value=5 shims=5 vectors=ok/5` after the
  hardening (positive control; the hardening may not weaken the gate).
- K5: the counter's `--selftest` must fail on a copy whose `decide` or shim aggregation
  is replaced by a constant (that is M-A/M-B), and must pass on the unmutated tree.

**Population census at BASE (measured, not assumed):** M-A copy ⇒
`C2_SELFTEST: PASS (cases=11)` rc 0; M-B copy ⇒ `C2_SELFTEST: PASS (cases=11)` rc 0;
the stub-trial tree ⇒ `C2_SEAL_TRIAL: value=0 … guard=1` rc 1. Killed = 0.

**Named ceilings:** two mutation classes, not a complete mutation set; the guard
challenge is one stub shape; the real-trial leg needs `bao` on PATH (SETUP otherwise);
the counter still trusts the trial's printed observables (fabrication class, the
round-61 K2 ceiling, unchanged).

## Wave plan — ONE v1 wave, 14 seats

Band 8–16 under `scripts/hyaku/ufo-wave-policy.json` (`waveMinLanes=8`,
`waveMaxLanes=16`; hard ceiling 256). Roles: 2 scout, 4 executor, 2 scribe,
1 reviewer, 1 critic, 2 mutation-tester, 1 connector, 1 sentinel. **Attack seats on
the addendum's literal list {reviewer, critic, mutation-tester, labrat}: 4 of 14 =
28.57 %** (labrat is a frozen-topology probe role, not a swarm lane — the validator's
proposal-role set excludes it; the two mutation-tester seats are distinct work, one per
claim). Connector seats: 1 (≤ 2). The L1 holds the canonical planner seat
(the validator rejects `planner`; a bounded planning data-walk rides the pre-state
scout item). Residual call: none planned; if the wave leaves a gap, ≤ 4 reviewer/critic
seats in one ordinary `task` call, counted in the round total.

Seat list (name → role → work):

| name | role | work |
|---|---|---|
| R62ScoutSources | scout | open the mutation-testing and negation-detection sources live; captures, located ≤25-word quotes, reject verdicts |
| R62ScoutPreState | scout | independent pre-state census: build B3..B7 and the two mutants in scratch, re-derive accepted=5 / killed=0 / guard=1 |
| R62ExecC1Grammar | executor | harden `plans/round-61-c1-check.py` (the five rules above) + selftest cases |
| R62ExecC1Counter | executor | `plans/round-62-c1.sh`, `plans/round-62-bypass.tsv`, `plans/round-62-paraphrase.tsv`, stub refusal |
| R62ExecC2Counter | executor | harden `plans/round-61-c2.sh` (markers, `decide`, shim aggregation, guard observables, selftest) + `plans/round-62-c2.sh` |
| R62ExecControls | executor | `plans/round-62-controls.sh`: pre-freeze battery, receipts |
| R62ScribeEntry | scribe | `corpus/knowledge/claim-instrument-falsifiability.md` draft |
| R62ScribeRecords | scribe | routed defects D1/D2/D5 record edits; QUALITY QM81/QM82 drafts; lesson draft |
| R62Reviewer | reviewer | attack both claims: new negations/pairings, receipt checks, mutant hunts |
| R62Critic | critic | falsify the predicates: no-work control, stub controls, causal separability |
| R62MutC1 | mutation-tester | mutation battery over the hardened C1 grammar and counter |
| R62MutC2 | mutation-tester | mutation battery over the hardened C2 counter |
| R62Connector | connector | sibling-overlap sweep + `considerthese/` mining (≤ 1 proposal) |
| R62Sentinel | sentinel | security/scratch discipline: no credential material, no host mutation, scratch cleanup |

## Frontier step (§2b)

- `corpus/SOURCES.md` census at round start: `kagi ok`, rc 0, 127 rows (receipt
  `.ufo/waves/round-62/census-start.txt`). At round end the same command must read rc 0.
- New rows this round: the mutation-testing source (the kill/survive definition the C2
  claim rests on) and, if it opens and quotes, a negation-detection source for the
  polarity rule; a rejected candidate stays as a row with reason and flip. Each new
  row's Gate entry records URL, access date and a ≤25-word located quote.
- One mistake mined into `corpus/lessons/round-62.md` §Mistakes with class · evidence ·
  captured-by · fix.
- At least one sourced claim: the entry `claim-instrument-falsifiability.md` cites the
  admitted rows and is the evidence C2's kill contract lands.

## Routed-defect work items (not claims; receipt `plans/round-62-routed.sh`)

| id | spot-check §7 | resolution |
|---|---|---|
| D1 | SCORECARD controls count 17 vs 18 | appended correction naming the receipt and the derived count |
| D2 | no SKILL.md registry rows for the round-61 gates | registry rows for `plans/round-61-c1-check.py`, `plans/round-61-c2.sh`, `corpus/openbao-seal-trial.sh` |
| D3 | literal attack share 3/16 at round 61 | this round's wave carries 4/14 = 28.57 % literal; plan and report state both readings |
| D4 | no committed candidate-revision receipt | `.ufo/waves/round-62/final/candidate.txt` names the candidate revision and carries both verdict lines |
| D5 | ancillary gate verdicts have no receipt | one committed receipt per gate line under `.ufo/waves/round-62/final/`, cited from `LOG.md` |

## Named ceilings for the round

- **calibration** — pointer relevance remains unverifiable; the hardened grammar narrows
  the bypass class, it does not prove a corrected sentence true (QM79).
- **operability** — nothing schedules the gates; the C2 counter's real leg needs `bao`;
  the two mutation classes are not a complete mutation set.
- **depth / coverage** — no new domain surface this round: the work is instrument
  falsifiability, counted under calibration and operability; the coverage map gains the
  entry row, not a new path surface.
- **adjacency** — the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not
  absorbed; the connector sweep reports, never absorbs.
