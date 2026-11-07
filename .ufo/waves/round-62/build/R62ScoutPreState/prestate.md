# R62ScoutPreState — independent pre-state census at BASE

Seat: `R62ScoutPreState` (scout). Round 62, attempt 1, lane `kagi-shokunin`.
Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`.
Frozen plan `plans/round-62.md` (predeclaration commit `8e5463c7937dccdd97fd5a812b8091f83b708aa7`).

Scope: read-only census. No lane file was edited; no git/jj mutation was run in the
lane, a sibling lane, or any index. Every number below is derived from a command run
in this seat's scratch, not quoted from the plan.

Scratch root: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ScoutPreState/`
(`/fast/scratch/hyaku/kagi-r62/R62ScoutPreState`). Removed before this seat yielded.

Tooling: none installed, upgraded or removed by this seat. The only pre-existing
binary used is the pinned OpenBao `/home/vgpnk/.local/bin/bao` (v2.7.2, sha256
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`), read from the
lane's own `plans/round-57-c2.sh` `PIN_BAO` line and matching it exactly; it is a
read-only input to the trial the counter drives, no install occurred.

---

## 1. BASE extraction and instrument digest

```
$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 60b5b7b60b76629633110a5b4adac883193c8b2a | tar -x -C /fast/scratch/hyaku/kagi-r62/R62ScoutPreState/base
EXTRACT_OK
```

Tree contents at BASE: `AGENTS.md LOG.md PROVINCE.md README.md SCORECARD.md SHONEN.md
SKILL.md considerthese corpus plans`. `plans/round-62-c1.sh` and
`plans/round-62-c2.sh` are **absent** at BASE (`ls` ⇒ `No such file or directory`);
`plans/` carries only `round-61-c1-check.py`, `round-61-c1.sh`, `round-61-c2.sh`,
`round-61-controls.sh`, `round-61.md`. The round-62 counters are the instruments the
round must land.

```
$ sha256sum base/plans/round-61-c1-check.py
d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812  base/plans/round-61-c1-check.py

$ wc -l base/plans/round-61-c1-check.py base/plans/round-61-c2.sh base/corpus/openbao-seal-trial.sh
  1454 base/plans/round-61-c1-check.py
   389 base/plans/round-61-c2.sh
  1123 base/corpus/openbao-seal-trial.sh
  2966 total
```

**BASE checker: sha256 `d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812`, 1454 lines.**
(The checker bytes equal the pin named in `corpus/lessons/round-61.md` §Corrections,
which records the 17:11/17:12 checker as `d525ee28…`.)

Base tree identity: `diff -r base clean` ⇒ empty (the "clean" copy is byte-identical
to BASE).

---

## 2. C1 — the five bypass fixtures, each built from the plan §C1 table

Each fixture is a full copy of the BASE tree with exactly one anchor→replacement
substitution. The anchor count is asserted to be exactly 1 before the substitution and
the replacement count exactly 1 after (0 or >1 fails closed). Fixture script:
`apply.py` in the seat scratch; output:

```
OK b3: plans/round-60.md anchor=1 replacement=1
OK b4: corpus/lessons/round-60.md anchor=1 replacement=1
OK b5: LOG.md anchor=1 replacement=1
OK b6: corpus/lessons/round-60.md anchor=1 replacement=1
OK b7: corpus/lessons/round-60.md anchor=1 replacement=1
APPLY_RC=0
```

Anchor occurrence counts measured at BASE before substitution:

```
B3 plans/round-60.md: 1
B4 corpus/lessons/round-60.md: 1
B5 LOG.md: 1
B6 corpus/lessons/round-60.md: 1
B7 corpus/lessons/round-60.md: 1
```

Exactly one file differs per fixture (`diff -rq base <fixture>`):

```
b3: base/plans/round-60.md differs
b4: base/corpus/lessons/round-60.md differs
b5: base/LOG.md differs
b6: base/corpus/lessons/round-60.md differs
b7: base/corpus/lessons/round-60.md differs
clean: (no differences)
```

The checker in every fixture copy is byte-identical to the BASE checker
(`sha256sum` = `d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812` in
all six copies), so the only variable is the fixture tree.

### Command

```
cd <fixture> && python3 -I -B plans/round-61-c1-check.py \
  --root <fixture> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
```

### Outputs (the `C1_ROUTED:` line and the rc)

**B3** (`**A3 item 2 is withdrawn**` → `**A3 item 2 is not withdrawn**`):

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
rc=1
```

**B4** (`the round introduced three new record defects it did not route` → `the round
introduced no three new record defects it did not route`):

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
rc=1
```

**B5** (`it was rewritten in place at` → `it was not rewritten in place at`):

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
rc=1
```

**B6** (`the lane was progressing, not stale.` → `the paragraph's times are correct.`):

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
rc=1
```

**B7** (`so the literal reading is 3/16 = 18.75 %, … 4/16 = 25 %` → `so the literal
reading is 3/16 = 25 %, … 4/16 = 18.75 %`):

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
rc=1
```

**Unmodified copy** (`clean`, byte-identical to BASE):

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
rc=1
```

(The same copy with the challenge leg enabled, i.e. without `--no-challenge`, reads
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1` rc 0 —
the challenge leg resolves; the `--no-challenge` reading is the diagnostic form the
plan's population census names.)

The per-item detail lines are **byte-identical across all six copies** (`diff` of the
`c1:` lines of b3 against b4, b5, b6, b7 and clean ⇒ IDENTICAL for each), e.g. B3's:

```
c1: i1 HOLD derived results=16 output=3824 supersedes-lines-after=1 last-line=states-derived-count-and-names-mutants.md
c1: i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[selftest-cell='`bash plans/round-60-c2.sh --selftest` ⇒' none-own=absent] mutation[mutated rc=1 finding=yes]
c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-withdrawn lesson-line=second-instance
c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-states-three
c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place
c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9
c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=states-both-fractions-and-both-percentages
```

**Derived: `C1_BYPASS accepted = 5`** (all five fixtures read `value=0`, i.e. the
checker accepts the negation / swapped pairing) over POP = 5. Target 0 ⇒ **BASE 5**,
independently re-derived.

### Paraphrase fixtures (plan §C1 guard leg d, K4) — measured for completeness

Built the same way (`apply.py`-style, anchor count asserted 1):

```
OK p3: plans/round-60.md anchor=1 replacement=1
OK p4: corpus/lessons/round-60.md anchor=1 replacement=1
OK p5: LOG.md anchor=1 replacement=1
```

```
p3 rc=1  C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
p4 rc=1  C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
p5 rc=1  C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
```

All three benign rewrites read `value=0` at BASE, so guard leg (d) is satisfiable at
BASE by the current checker: benign rewording is not currently a false positive.

---

## 3. C2 — the two falsifier legs M-A and M-B

The BASE counter (`plans/round-61-c2.sh`, 389 lines) carries **no** `# BEGIN-DECIDE` /
`# END-DECIDE` / `# BEGIN-SHIMS` / `# END-SHIMS` markers
(`grep -rn 'BEGIN-DECIDE|BEGIN-SHIMS' base` ⇒ none found). The plan §C2 describes the
legs in terms of those markers, so the BASE-level mutation is the corresponding
source block, exactly as this seat's assignment specifies.

### M-A — main aggregation block replaced by a constant

Needle (count asserted = 1), in `base/plans/round-61-c2.sh`:

```
pass=0
[ "$real_ok" = 1 ] && pass=5
value=0
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] \
  && [ "$selftest_ok" = 1 ] && [ "$ops_ok" = 1 ] && [ "$t2_ok" = 1 ] && value=5
```

replaced by `value=5`. `diff -u base mA`:

```
@@ -320,9 +320,7 @@
 done
 pass=0
 [ "$real_ok" = 1 ] && pass=5
-value=0
-[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] \
-  && [ "$selftest_ok" = 1 ] && [ "$ops_ok" = 1 ] && [ "$t2_ok" = 1 ] && value=5
+value=5
 stub_ok=0
```

### M-B — shim aggregation made unconditional

Needle (count asserted = 1):

```
    && broken41 "${OUT[sh$n]}" && shims_ok=$((shims_ok+1))
```

replaced by:

```
    ; shims_ok=$((shims_ok+1))
```

`diff -u base mB`:

```
@@ -316,7 +316,7 @@
 shims_ok=0
 for n in 1 2 3 4 5; do
   [ "$(vec "${OUT[sh$n]}")" = "${EXPECT[sh$n]}" ] && [ "${RC[sh$n]}" = 1 ] \
-    && broken41 "${OUT[sh$n]}" && shims_ok=$((shims_ok+1))
+    ; shims_ok=$((shims_ok+1))
 done
```

### Command and results

```
$ cd <copy> && bash plans/round-61-c2.sh --selftest
```

**BASE (unmutated):**

```
C2_SELFTEST: PASS (cases=11)
rc=0
```

**M-A copy:**

```
C2_SELFTEST: PASS (cases=11)
rc=0
```

**M-B copy:**

```
C2_SELFTEST: PASS (cases=11)
rc=0
```

**Derived: M-A and M-B both survive at BASE** — the counter's own `--selftest` never
executes the aggregation it is meant to guard. The leg count that fires on either
mutation at BASE is **0**.

---

## 4. C2 — the guard challenge (leg G)

Tree `gc` = full BASE copy with `corpus/openbao-seal-trial.sh` replaced by a 2-line stub
that exits 0 and prints nothing:

```
$ wc -l gc/corpus/openbao-seal-trial.sh
2 gc/corpus/openbao-seal-trial.sh
$ cat -A gc/corpus/openbao-seal-trial.sh
#!/usr/bin/env bash$
exit 0$
```

```
$ cd gc && bash plans/round-61-c2.sh --tree gc
C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=1 (real=0 real2=0 none=0 ops=0 t2w=0 stubctl=1 secret=1 sh1=NNNNN sh2=NNNNN sh3=NNNNN sh4=NNNNN sh5=NNNNN trial=fb99eae951f1adc14d1a4a9a186c21930db2786b3208c94c7d9af382bd1048e5 cases=0)
rc=1
```

**Derived: leg G does not fire at BASE** — the counter reads `guard=1` on a tree whose
trial prints nothing, i.e. the guard does not discriminate. The plan requires `guard=0`
on this shape.

### Counter on the unmodified BASE tree (real trial, pinned bao) — reference

```
$ cd base && bash plans/round-61-c2.sh --tree base
C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB trial=a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535 cases=63)
rc=0
```

So the BASE counter is green on the real trial (`value=5 … guard=1`) and green on the
stub tree (`value=0 … guard=1`): `guard=1` is a near-constant at BASE, exactly the
round-61 reviewer's C2-4 finding. The stub control does reach
(`stubctl=1`, value 0 on the vacuous stub), so it is the *guard* leg, not the whole
counter, that is vacuous.

**Derived C2 kill count at BASE**

```
M-A: --selftest exits 0, no FINDING           -> leg does not fire
M-B: --selftest exits 0, no FINDING           -> leg does not fire
G  : guard=1 where the predicate requires 0    -> leg does not fire
```

**`C2_HARDENED killed = 0`** over POP = 3. Target 3 ⇒ **BASE 0**, independently
re-derived.

### 4b. The same two mutants run as a full counter (beyond the assigned step, same scratch)

Both mutants were also run as the full counter, once against the unmodified BASE tree
and once against the guard-challenge stub tree `gc`. This is the same BASE instrument,
same scratch, same pinned bao; it is extra derived evidence for the two findings
below.

M-A counter on the unmodified BASE tree (real trial):

```
C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB trial=a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535 cases=63)
rc=0
```

M-A counter on the guard-challenge stub tree `gc` (trial prints nothing):

```
C2_SEAL_TRIAL: value=5 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=1 (real=0 real2=0 none=0 ops=0 t2w=0 stubctl=1 secret=1 sh1=NNNNN sh2=NNNNN sh3=NNNNN sh4=NNNNN sh5=NNNNN trial=fb99eae951f1adc14d1a4a9a186c21930db2786b3208c94c7d9af382bd1048e5 cases=0)
rc=0
```

M-B counter on the guard-challenge stub tree `gc`:

```
C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=5 vectors=ok/5 selftest=0 guard=1 (real=0 real2=0 none=0 ops=0 t2w=0 stubctl=1 secret=1 sh1=NNNNN sh2=NNNNN sh3=NNNNN sh4=NNNNN sh5=NNNNN trial=fb99eae951f1adc14d1a4a9a186c21930db2786b3208c94c7d9af382bd1048e5 cases=0)
rc=1
```

Two derived consequences, both from the executions above:

1. **The M-A mutant is a constant-acceptor.** On the stub tree — whose trial prints
   nothing at all — the mutated counter reads `value=5` and **exits 0**, while the
   unmutated counter on the same tree reads `value=0` and exits 1. The
   `nosecret/stub_ok/value=5` line that re-zeroes the value is *downstream* of the
   mutated block and is satisfied because `stub_ok=1` and `nosecret=1`; the mutated
   block's constant `value=5` survives it. So the M-A class is not merely invisible
   to `--selftest` (C2-5): at BASE it also converts the counter into one that accepts
   a vacuous trial outright. Any candidate hardening must make the aggregation
   unreachable-by-constant *and* keep the value re-zeroing downstream of it, or the
   M-A leg is not actually closed.
2. **The M-B mutant fabricates the shim census.** On the stub tree it reads
   `shims=5 vectors=ok/5` although every measured shim vector is `NNNNN` (no verdict
   observed at all). The `V=ok` flag is derived from `shims_ok`, so an unconditional
   `shims_ok` also fabricates the "vectors ok" reading. A candidate must derive
   `vectors` from the measured vectors, not from the counter of the shims.

---

## 5. BASE selftest case counts

```
$ cd base && python3 -I -B plans/round-61-c1-check.py --selftest
C1_CHECK_SELFTEST: PASS (52 cases)
rc=0

$ cd base && bash plans/round-61-c2.sh --selftest
C2_SELFTEST: PASS (cases=11)
rc=0
```

**BASE selftest counts: C1 checker 52 cases; C2 counter 11 cases.**

Against the plan's guard thresholds: the C1 guard leg (b) requires `N >= 57` and the
C2 guard leg (a) requires `N >= 17`. At BASE the counts are **52** and **11** — below
both thresholds. A candidate that only hardens the grammar/aggregation without
adding cases cannot satisfy the guard legs: the C1 checker must reach ≥ 57 cases
(the plan's K5 names one case per fixture class — five bypass + three paraphrase — on
top of BASE's 52) and the C2 counter must reach ≥ 17 cases.

---

## 6. Summary of the derived pre-state

| quantity | derived at BASE | plan target | source |
|---|---|---|---|
| `C1_BYPASS accepted` | **5** (POP 5) | 0 | §2, five fixture readings `value=0` rc 1 |
| unmodified copy | `value=0 … guard=0` rc 1 (`guard=1` rc 0 with the challenge leg) | — | §2 |
| paraphrase P3/P4/P5 | all `value=0` rc 1 | — | §2 |
| C1 checker selftest | `PASS (52 cases)` rc 0 | ≥ 57 for guard leg (b) | §5 |
| `C2_HARDENED killed` | **0** (POP 3) | 3 | §3, §4 |
| M-A / M-B | `--selftest` `PASS (cases=11)` rc 0 (both survive) | must fire | §3 |
| G | `guard=1` rc 1 (does not fire) | `guard=0` | §4 |
| C2 counter selftest | `PASS (cases=11)` rc 0 | ≥ 17 for guard leg (a) | §5 |
| C2 counter, real BASE tree | `value=5 … guard=1` rc 0 | — | §4 |

Both claims' BASE readings are confirmed by this seat's own execution: **C1 accepted
5**, **C2 killed 0**, **guard 1**.

## 7. Defects / observations reported (no frozen predicate was amended)

1. **The plan's C2 leg wording names markers the BASE counter does not carry.**
   §C2 describes M-A/M-B as replacing "the block between its `# BEGIN-DECIDE` and
   `# END-DECIDE` markers" and "between its `# BEGIN-SHIMS` and `# END-SHIMS` markers".
   `grep -rn 'BEGIN-DECIDE|BEGIN-SHIMS'` over the whole BASE tree returns nothing; the
   BASE counter has no such markers. The markers are a property the *hardened* counter
   must introduce, so the plan's leg text cannot be applied literally at BASE. This
   seat used the corresponding BASE source blocks (the `value=0` + `[ "$pass" = 5 ] …
   value=5` aggregation, and the `&& broken41 … && shims_ok=$((shims_ok+1))` shim
   line). **This is a wording defect in the frozen plan, reported not amended**: the
   executor that introduces the markers must place them so the same two mutations are
   the ones the predicate names, or the round-62 counter's own fixtures must pin the
   marker positions. The plan's K2 ("the needle must match exactly once") is the
   mechanism that makes this safe; the BASE mutation above is the honest BASE-level
   reading and it survives.
2. **Both guard thresholds are above BASE's own case counts** (§5). The plan's C1
   guard leg (b) needs ≥ 57 C1 cases and the C2 guard leg (a) needs ≥ 17 C2 cases;
   BASE ships 52 and 11. This is not a defect but a landing requirement the
   executors must meet for GUARD to be able to read 1 at all.
3. **The C2 counter's `--selftest` does not reach the aggregation** — confirmed by
   execution, not by reading: mutating the aggregation to a constant (M-A) leaves
   `--selftest` at `PASS (cases=11)` rc 0. The 11 selftest cases exercise the
   parsing helpers (`verdict`, `vec`, `holds5`, `EXPECT`, the secret scan) and the
   tree-argument handling, never the `pass`/`shims_ok`/`value` aggregation.

No frozen predicate, target, POP, kill rule or item condition was changed by this
seat. No lane file was written by this seat other than the two paths it names
(this receipt and its wave report).

### 7b. Observation on a plan amendment made by another seat (not by this one)

While this seat was running, the lane working tree gained `plans/round-62.md`
`## Amendment A1 — 2026-11-07, before any candidate reading (I6's denial clause)`,
adding clause (d) to the plan §C1 hardened I6 condition ("the correction line does
not assert that the superseded paragraph is correct" — the line carries none of
`times are correct`, `times are right`, `is correct`, `are correct`). The amendment
credits `R62ExecC1Counter` and `R62ExecC1Grammar` for the derivation and states that
"the predicate, target 0, POP 5, the five fixtures B3–B7 and the kill rules" are
unchanged.

Two facts, both measured here, recorded for the L1:

* **This seat's census is unaffected by that amendment.** Every reading in this
  receipt was taken with the BASE checker's bytes
  (`plans/round-61-c1-check.py` sha256 `d525ee28…`, 1454 lines), extracted by
  `git archive 60b5b7b6`; the BASE checker does not read `plans/round-62.md` at all
  (`grep -n 'round-62' base/plans/round-61-c1-check.py` ⇒ no match). The amendment
  changes the *candidate's* hardened condition, not the BASE instrument, so
  `accepted=5` at BASE stands either way.
* **This seat's B6 measurement independently corroborates the amendment's premise.**
  The amendment asserts that B6 (the tail-only substitution
  `the paragraph's times are correct.`) keeps every token the frozen I6 clause tests.
  The measurement in §2 shows exactly that: on the B6 fixture the BASE checker reads
  `i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9` and the whole
  tree reads `value=0 … guard=0` rc 1 — the denial is accepted at BASE. That is the
  defect the amendment addresses.

This seat made no amendment and takes no position on the amendment's authority; it
is the L1's to adjudicate. Recorded here because the plan is frozen and an
amendment to an item condition is a fact the L1's own integration record should
carry explicitly.

SEAT-STATUS: complete
