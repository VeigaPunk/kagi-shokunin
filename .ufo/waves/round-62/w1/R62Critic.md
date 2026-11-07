# R62Critic — the two predicates, falsified before the candidate reading

Seat `R62Critic`, kagi round 62 attempt 1. Read-only over the lane; every write is
under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62Critic/` and the receipts
under `.ufo/waves/round-62/build/R62Critic/`. No lane commit, no `git add/commit`,
no mutating `jj`, no host mutation. No tool installs were needed (python3, bash, git,
`bao` v2.7.2 were already present).

Read before working: `plans/round-62.md` (frozen, commit `8e5463c`),
`corpus/QUALITY.md` QM78–QM80, `corpus/lessons/round-61.md`,
`corpus/lessons/round-61-verifier-spotcheck.md` §7.

## Instruments and bytes measured

| object | revision / sha256 | note |
|---|---|---|
| measured tree | `60b5b7b60b76629633110a5b4adac883193c8b2a` (`git archive`) | the claim BASE |
| BASE checker | `plans/round-61-c1-check.py` `d525ee28…` | unhardened (round 61) |
| BASE C2 counter | `plans/round-61-c2.sh` `c7d9e272…` | unhardened (round 61) |
| round-62 C1 counter | `plans/round-62-c1.sh` (worktree, untracked) | sha changed during the wave (`c427a5a1`, `19ea1131`); the receipts name the bytes each run used |
| hardened checker | `plans/round-61-c1-check.py` `f2afd9b8…` (worktree) | selftest `PASS (75 cases)`; an earlier revision `884c338d` read `FAIL (51/52)` mid-edit |
| hardened C2 counter | `plans/round-61-c2.sh` `20614697…` (worktree) | selftest `PASS (cases=21)` |
| `bao` | `/home/vgpnk/.local/bin/bao` v2.7.2, sha256 `9c5f3628…` | pinned by the counter |

The BASE checker's selftest prints `C1_CHECK_SELFTEST: PASS (52 cases)`; the BASE
counter's prints `C2_SELFTEST: PASS (cases=11)`. Every command below was run; the
receipt named beside each attempt is the observed output.

## Attempts

### A1 — do-nothing control, C1 (frozen kill rule C1-K1)

```
git -C <lane> archive 60b5b7b6 | tar -x -C $S/base
# for B3..B7: cp -a base copy; replace the anchor exactly once;
(cd <copy> && python3 -I -B plans/round-61-c1-check.py \
   --root <copy> --repo <lane> --no-challenge)
```

Observed (`attempt1-base.txt`):

```
UNMODIFIED | C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
B3 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
B4 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
B5 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
B6 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
B7 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
ACCEPTED=5 POPULATION=5
```

Verdict: accepted = 5 at BASE, and the unmodified copy reads `value=0` (guard leg a).
The five anchors each occur exactly once at BASE (`plans/round-60.md` 1,
`corpus/lessons/round-60.md` 1/1/1, `LOG.md` 1). **K1-C1 holds.**

### A2 — do-nothing control, C2 (frozen kill rule C2-K1)

```
bash plans/round-61-c2.sh --tree $S/base          # the BASE tree has the round-61 trial
bash plans/round-61-c2.sh --tree $S/stubtree      # trial = 3-line stub, sha256 fb99eae9…
git show 60b5b7b6:plans/round-61-c2.sh | grep -c 'BEGIN-DECIDE'   # and the other three markers
```

Observed (`attempt1-c2-base.txt`, `attempt6-c2-stub.txt`):

```
C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1
  (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH … sh5=HHHHB
   trial=a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535 cases=63)   rc=0
C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=1
  (… trial=fb99eae951f1adc14d1a4a9a186c21930db2786b3208c94c7d9af382bd1048e5 cases=0)   rc=1
BEGIN-DECIDE: 0   END-DECIDE: 0   BEGIN-SHIMS: 0   END-SHIMS: 0
```

The reviewer's mutations on a BASE tree copy (constant `value=5`; `shims_ok=5`)
each keep `C2_SELFTEST: PASS (cases=11)` rc 0 (M-A/M-B survive). The G leg does not
fire: a valid-sha256 stub trial reads `guard=1`. **killed = 0 at BASE**, as declared —
but see D4: the frozen M-A/M-B needles do not exist at BASE.

### A3 — fixture vacuity (frozen fixture rule: exactly once, 0 or >1 fails closed)

```
bash plans/round-62-c1.sh --tree $S/vac-double   # B3 anchor appended a second time
bash plans/round-62-c1.sh --tree $S/vac-zero     # B3 anchor replaced by another sentence
```

Observed (`attempt3-vacuity.txt`):

```
vac-double | rc=2 verdict_lines=0
  c1-counter: SETUP fixture B3: fixture B3: anchor must occur exactly once in
  plans/round-60.md (0 or >1 occurrences fails closed)
vac-zero   | rc=2 verdict_lines=0
  c1-counter: SETUP fixture B3: … (0 or >1 occurrences fails closed)
```

A naive replace-all on the doubled tree leaves the checker reading `value=0`
(accepted), which is exactly what the count check prevents. **The counter fails
closed; the clause is load-bearing and implemented.**

### A4 — guard leg (c): a printer-stub checker must not reach a verdict line

```
# named stub: one constant C1_ROUTED line (the frozen shape)
bash plans/round-62-c1.sh --tree $S/stub-named
# crafted stub: the same constant line PLUS C1_CHECK_SELFTEST: PASS (cases=57)
bash plans/round-62-c1.sh --tree $S/stub-crafted
```

Observed (`attempt4-c1-counter.txt`):

```
named:   c1-counter: refuse: tree checker --selftest printed no C1_CHECK_SELFTEST:
         PASS line (rc=0) — no verdict
         rc=2 verdict_lines=0
crafted: c1-counter: selftest rc=0 pass=1 cases=57 (guard needs >= 57)
         c1-counter: unmodified value=0
         c1-counter: stub rc=2 verdict_absent=1
         c1-counter: paraphrase leg=1
         C1_BYPASS: accepted=5 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1)
         rc=1 verdict_lines=1
```

Re-run on the current counter bytes (`plans/round-62-c1.sh` sha `19ea1131…`,
`attempt4b-c1-counter-current.txt`):

```
base         | rc=1 verdict_lines=1 | C1_BYPASS: accepted=5 population=5 guard=0
                                      (real=1 selftest=0 stub=1 paraphrase=1)
stub-crafted | rc=1 verdict_lines=1 | C1_BYPASS: accepted=5 population=5 guard=1
                                      (real=1 selftest=1 stub=1 paraphrase=1)
stub-named   | rc=2 verdict_lines=0 | c1-counter: refuse: … no verdict
```

**The named stub is refused; the crafted stub reaches a verdict line with guard=1**
on both counter revisions. The refusal is a selftest-*presence* check (plus a
second, PASS-only stub shape), not a byte pin. See D5.

### A5 — guard leg (d): benign paraphrase must read resolved

```
# P3/P4/P5 on the BASE checker
(cd <copy> && python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge)
# the frozen grammar, implemented literally (grammar.py), on benign rewrites
python3 grammar.py <file> i3|i4|i5
```

Observed (`attempt5-paraphrase.txt`, `attempts-rest.txt`):

```
P3 | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
P4 | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
P5 | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
i3-reorder "Item 2 of A3 is withdrawn"                    :: resolved=0
i3-notmerely "A3 item 2 is not merely withdrawn …"        :: resolved=0
i4-nofewer "no fewer than three new record defects"       :: resolved=0
i4-digit "3 new record defects"                           :: resolved=0
i5-notappended "not appended but rewritten in place …"    :: resolved=0
i5-hyphen "rewritten in-place"                            :: resolved=0
i3-p3 / i4-p4 / i5-p5                                     :: resolved=1 each
```

The frozen paraphrase set passes; the grammar rejects six reasonable benign
rewrites. See D7 (a named ceiling, not a claim failure under the frozen set).

### A6 — the C2 guard: stub trial `guard=0`, real trial `value=5`

Observed (`attempt6-c2-hardened.txt`; hardened counter `plans/round-61-c2.sh`
sha `20614697…` on a BASE extraction):

```
unmutated selftest            rc=0  C2_SELFTEST: PASS (cases=21)
M-A (BEGIN-DECIDE → echo 5)   rc=1  findings=6  C2_SELFTEST: FAIL (cases=21 failed=6)
M-B (BEGIN-SHIMS → shims_ok=5) rc=1 findings=3  C2_SELFTEST: FAIL (cases=21 failed=3)
G stub-trial tree             rc=1  value=0 … guard=0 (… trial=fb99eae9… cases=0)
K4 real trial                 rc=0  value=5 … shims=5 vectors=ok/5 … guard=1
                                    (… trial=a3bc8825… cases=63)
```

The hardened counter closes the C2-4/C2-5 class: M-A and M-B are killed by the
selftest, the stub trial reads `guard=0`, and the real trial still reads `value=5`.
**The C2 target 0 → 3 is reachable on the hardened bytes.** The remaining C2 defect
is the BASE census (D4), not the target.

### A7 — the claim's arithmetic, re-derived

```
grep -cE '^\| B[3-7] \|' plans/round-62.md          ⇒ 5
grep -cE '^\| P[3-5] \|' plans/round-62.md          ⇒ 3
awk '/^\| name \| role \| work \|/,/^$/' plans/round-62.md | grep -c '^| R62'   ⇒ 14
roles: 2 scout, 4 executor, 2 scribe, 1 reviewer, 1 critic, 2 mutation-tester,
       1 connector, 1 sentinel
4/14*100                                             ⇒ 28.57142857142857
git show --stat 8e5463c                              ⇒ plans/round-62.md | 261 +
```

5 and 3 are the fixture and leg populations; 4/14 = 28.57 %; the predeclaration
commit carries the plan alone. The "3" is a target, not a BASE derivation: at BASE
only G is constructible (M-A/M-B needles are absent, D4).

### A8 — causal separability

```
# C1 on a tree stripped of the round-61/62 C2 files
rm plans/round-61-c2.sh corpus/openbao-seal-trial.sh ; run B3..B7
# C1 on a tree stripped of plans/round-60-c2.sh
rm plans/round-60-c2.sh ; run the unmodified checker
# C2 on a tree stripped of the C1 files
rm plans/round-61-c1-check.py plans/round-62-c1.sh ; run the BASE counter
```

Observed (`attempts-rest.txt`, `attempt2-c1-coupling.txt`):

```
NOC2-B3..B7 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0   (accepted=5, unchanged)
NO-round-60-c2 | C1_ROUTED: value=1 population=7 i1=1 i2=0 i3=1 … i6=1 i7=1 guard=0
NOC1-C2 | C2_SEAL_TRIAL: value=5 … guard=1 … trial=a3bc8825… cases=63   rc=0
```

C1 is independent of the round-61/62 C2 files but **coupled to
`plans/round-60-c2.sh`** through the inherited I2 leg A; C2 is independent of the
C1 files. See D6.

### A9 — independent candidate reading on the hardened checker (not the L1's canonical reading)

The hardened checker `plans/round-61-c1-check.py` sha `f2afd9b8…` (selftest
`C1_CHECK_SELFTEST: PASS (75 cases)`) on a BASE extraction with each fixture applied:

```
B3 | rc=1 | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0
B4 | rc=1 | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0
B5 | rc=1 | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0
B6 | rc=1 | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0
B7 | rc=1 | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0
P3 | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
P4 | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
P5 | rc=1 | C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
```

Each forgery is rejected with **exactly its designated item** unresolved, and the
three paraphrases still resolve. **The C1 target 5 → 0 is reachable on these bytes** —
but only because the instrument implements the line-scoped I4/I5 (D1/D2) and A1's
clause (d) (D3); the frozen text alone does not. This is an independent reading, not
the L1's canonical candidate reading on the committed revision.

## Defects

Severity: high = decides whether the claim can reach its target; medium = the claim
can pass but the guard/reading is weaker than stated; low = wording/ceiling.

| id | sev | clause | evidence | fix |
|---|---|---|---|---|
| D1 | high | C1 I4 ("`three` occurs with no negator in its 5-token window before it") names no line; a literal whole-file reading resolves on unrelated `three` | `corpus/lessons/round-60.md` has 4 `three` occurrences; after B4 two are unnegated (`:94` "carries all three T1 observables", `:109` "the three gate receipts"); `grammar.py i4` on the B4 tree ⇒ `resolved=1` (the forged occurrence negated, the others not). The delivered checker (`f2afd9b8`) scopes I4 to the last `supersedes the round-60 quality-trend sentence` line (`item4`: `candidates[-1]`), which rejects B4 (`grammar.py … i4 <regex>` ⇒ `resolved=0`) | state the line scope in the predicate/ceiling and the receipt; a literal implementation reads B4 accepted and the claim cannot reach 0 |
| D2 | high | C1 I5 ("`rewritten in place` occurs with no negator …") names no file/line | `git grep -n 'rewritten in place'` matches `.ufo/waves/round-22/falsify/AttackEntry13.md:36`, `.ufo/waves/round-23/falsify/CritNoHarm.md:160`, `CritPlanScope.md:299`, `ClaimR15X02.md:25`, … ; a tree-wide reading resolves on B5. LOG.md-only reading rejects B5 (`grammar.py i5 LOG.md` ⇒ `resolved=0`). The delivered checker scopes I5 to the last `supersedes the round-60 LOG wave line` line | same as D1 |
| D3 | high | C1 I6 cannot reject B6 as frozen; the worktree `## Amendment A1` adds clause (d) | B6 reads `value=0` on the BASE checker (A1); the B6 tail keeps the launch line, the stamps and the superseded stamp, so the frozen I6 passes it. A1's deny phrases occur 0 times on the real line 179 (`grep -ci` 0 each), so clause (d) does not break guard leg (a). A1 is uncommitted against `8e5463c` and amends a frozen item condition | commit A1 before the first work commit (QM29) and name both the frozen text and A1 in the candidate receipt; or route B6 as a ceiling and accept that the claim cannot reach 0 |
| D4 | high | C2 M-A/M-B are defined by `# BEGIN-DECIDE`/`# END-DECIDE` and `# BEGIN-SHIMS`/`# END-SHIMS` | those markers occur **0** times in `git show 60b5b7b6:plans/round-61-c2.sh`; per K2 ("0 or >1 fails closed") the BASE control is SETUP, not `killed=0`; the plan's census (`M-A copy ⇒ PASS (cases=11)`) is reproducible only with the reviewer's different mutation (constant `value=5`, `shims_ok=5`), which `plans/round-62-controls.sh` substitutes for K1-BASE-C2 while C2-F1/F2 use the markers; on the hardened counter the frozen M-A fails (`FAIL (cases=21 failed=6)`), so the census cannot be the hardened counter either — the label `M-A` names two different mutations | define M-A/M-B by a needle present at BASE (the aggregation block text) and use the same needle at BASE and candidate; or state the substitution explicitly |
| D5 | high | C1 guard leg (c) | named stub refused (rc 2, no verdict); crafted stub (constant `C1_ROUTED` line + `C1_CHECK_SELFTEST: PASS (cases=57)`) ⇒ `C1_BYPASS: accepted=5 population=5 guard=1`, rc 1, `verdict_lines=1` — on the counter bytes at 18:16 (`attempt4-c1-counter.txt`) and on the current bytes `19ea1131` (`attempt4b-c1-counter-current.txt`) | pin the checker's sha256 to the lane's bytes at the measured revision (QM58), or require the selftest to fail on a mutated copy (execute a challenge on the checker) |
| D6 | medium | causal separability | C1 on a tree without `plans/round-60-c2.sh` ⇒ `value=1 … i2=0`; C1 without the round-61/62 C2 files ⇒ accepted=5 unchanged; C2 without the C1 files ⇒ value=5 guard=1 | name the coupling in the predicate/ceiling, or make I2's selftest leg independent |
| D7 | medium | C1 guard leg (d) / K4 | the frozen grammar rejects "Item 2 of A3 is withdrawn", "not merely withdrawn", "no fewer than three", "3 new record defects", "not appended but rewritten in place", "rewritten in-place" (all `resolved=0`); P3/P4/P5 pass | extend the idiom list (`not merely`, `not just`, `no fewer than`) or test the negator only at the copula; name the token-form ceiling (digit/hyphen) |
| D8 | low | C1 guard (b) line shape | the predicate says `PASS (cases=N)`; the committed checker prints `PASS (52 cases)`; an earlier counter revision read `cases=1` from the `C1` identifier (`attempt4-c1-counter.txt`), the current one uses a `sed` extraction | state the exact line shape and keep the extraction anchored to the parenthesised number |
| D9 | low | C1 I6 `-03:00` | `git log --format='%ci'` emits `-0300`; the round-61 checker normalises (`_norm_ci`); a literal implementation reads I6 unresolved | name the normalisation in the predicate |
| D10 | low | C1 I7 "the wave results file" | the round-61 checker derives from `.ufo/waves/round-60/w1-results.json`; a literal implementation using the round-62 results file (14 seats) would not match `3/16`, `4/16` | name the file |
| D12 | low | C2 guard leg (c) ("a constant-verdict counter … is refused by the counter's own stub control") | the hardened counter's `--selftest` (21 cases) unit-tests `decide`/`shim_count` but has no case that runs a constant-verdict *copy* of itself; the controls battery's C2-F5 names `plans/round-62-c2.sh` as the mechanism, and that wrapper does not exist yet at this writing | name the wrapper/control that refuses the constant-verdict copy and add a selftest case that runs one |
| D11 | medium | identity / process | `plans/round-62.md` is modified against the frozen `8e5463c` (A1, uncommitted); the hardened checker implements A1's clause (d); its selftest read `FAIL (51/52 cases) failed=i7-wrong-fraction` at 18:2x and `PASS (75 cases)` at 18:3x (the instrument moved during the wave) | commit A1 before the first work commit; the candidate receipt must name the checker sha it measured and both the frozen text and A1 |

## Impacted axes

- **calibration** — D1, D2, D3, D8, D9, D10, D11 (the C1 predicate's scope/identity).
- **operability** — D4, D5, D6, D12 (the C2 counter's guard and the C1 guard's refusal).
- **No axis is harmed by a defect that is only a named ceiling**: D7 is a ceiling
  (the frozen paraphrase set passes), not a claim failure.

## Verdict

- **C1**: the BASE reading (accepted = 5) is reproduced exactly, and the independent
  candidate reading on the hardened checker (`f2afd9b8`, selftest `PASS (75 cases)`)
  rejects each of B3..B7 with exactly its designated item unresolved and accepts
  P3/P4/P5 — the target 5 → 0 is reachable on those bytes. The predicate is
  **unsound as frozen** on two counts: I6 cannot reject B6 (D3), and I4/I5 are
  under-specified such that a literal implementation accepts B4/B5 (D1/D2). The
  delivered checker resolves the scope by line anchoring and implements A1's clause
  (d); the candidate receipt must name that scope and A1, and the amendment must be
  committed before the first work commit. The guard leg (c) is defeated by a stub
  that prints a PASS line (D5) — the guard must pin bytes or execute a challenge.
- **C2**: the BASE reading (killed = 0; the stub trial reads `guard=1`; the real
  trial reads `value=5 … shims=5 vectors=ok/5`) is reproduced. The predicate's
  M-A/M-B legs are **not constructible at BASE** (D4), so the do-nothing control and
  the candidate leg do not use the same mutation; the controls battery substitutes
  the reviewer's mutations. The G leg is real and the hardening's `guard_obs` term
  is the right shape; the BASE census must be restated with the needle that exists.

SEAT-STATUS: complete
