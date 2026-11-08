# Seat Report — R64ScoutPreState (kagi round 64 attempt 2)

- **Seat**: `R64ScoutPreState` (scout, leaf member — no subagent dispatch)
- **Lane**: `kagi-shokunin` (secrets & vault ops)
- **Claim BASE**: `09cbee831d57be7c4edfbe77bf238f46bf729047`
- **FROZEN Predeclaration**: `plans/round-64.md` @ `dff0929c0e084822b0fe32e0d164534c768f97fe` (incl. Amendment A1)
- **Receipt**: `.ufo/waves/round-64/build/R64ScoutPreState/prestate.md` (every command and its exact output)
- **Status**: `SEAT-STATUS: complete`

Read-only seat: no lane file edited, no mutating git/jj command run anywhere. All measurement in
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ScoutPreState/`, deleted at yield.

---

## 1. What this seat measured

An independent pre-state census of the two round-64 claims at BASE, from scratch copies:

- **C1 (calibration)** — the BASE checker's readings on the eight held-out fixtures, re-derived by
  applying each fixture to a **fresh slim copy** (anchor uniqueness asserted first), plus the
  checker's own `--selftest` case count and the A4 lookup-table vehicle built and measured per the
  frozen guard (e) text.
- **C2 (operability)** — the frozen round-63 counter's end-to-end invocation under a 240 s budget,
  on the BASE tree and on the lane-tip tree, plus the committed round-63 receipt's byte count, plus a
  source trace of the recursion edge.

Every number in this report is derived by a command in the receipt; none is quoted from the plan.

---

## 2. C1 pre-state — `heldout = 8`, `population = 8` (re-derived)

BASE instrument: `plans/round-61-c1-check.py`, sha256
`eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6`, **2031 lines**, 98257 bytes.

Slim tree (the seven named input files, 556 K) — unmodified copy:

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0    rc 1
```

Identical line on the full 209 MB BASE tree ⇒ the slim tree is a faithful surrogate.

The five held-out **forgeries** (H = F2, F6, F8, F10, B4) — each applied to a fresh slim copy,
each anchor asserted to occur exactly once:

| id | file | anchor count | reading | rc |
|---|---|---|---|---|
| F2 | `corpus/lessons/round-60.md` | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| F6 | `LOG.md` | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| F8 | `corpus/lessons/round-60.md` | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| F10 | `corpus/lessons/round-60.md` | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| B4 | `corpus/lessons/round-60.md` | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |

The three held-out **benign rewrites** (Q = P6, B5, P7) — same method:

| id | file | anchor count | reading | rc |
|---|---|---|---|---|
| P6 | `corpus/lessons/round-60.md` | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0` | 1 |
| B5 | `corpus/lessons/round-60.md` | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` | 1 |
| P7 | `corpus/lessons/round-60.md` | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0` | 1 |

**Re-derived BASE `heldout` = 5 (forgeries accepted) + 3 (benign rejected) = 8, `population` = 8,
POP = 8** — the frozen target's "before" value, reproduced by measurement. Every one of the 20
sealed rows has an anchor that occurs **exactly once** at BASE (no vacuous fixture).

Item-bit attribution of the three Q failures: P6 → **i7** (binding window), B5 → **i4** (idiom
class), P7 → **i7** (binding window / parenthetical). All five H failures are "all seven items
hold", i.e. the forgery is entirely invisible to the BASE grammar.

Reading independence: the same lines are produced with `--repo` = the (dirty) live lane and with
`--repo` = a pristine `09cbee8` clone, so no reading depends on the lane's in-flight edits.

### 2.1 Checker selftest and the A4 vehicle

- `--selftest` at BASE: `C1_CHECK_SELFTEST: PASS (cases=102)`, rc 0.
- The emptied-negator copy of the BASE checker: `C1_CHECK_SELFTEST: FAIL (cases=102 failed=14 …)`,
  rc 1 — K5's "must fail on a mutated copy" already holds at BASE.
- The BASE checker's 102 cases carry **no** case naming any round-64 held-out shape class ⇒ K5's
  "one case per held-out shape class" is genuinely open at BASE.
- **A4 vehicle, built per the frozen guard (e) text** (literal `NEGATORS = frozenset(())` dead line,
  15-string fixture lookup = the ten round-63 residual `F` replacements + the five round-62 bypass
  `B` replacements, constant `PASS (cases=91)`):
  - unmodified copy → `value=0`; committed round-63 tables → accepted 0 / rejected 0 (it *is* a
    vehicle); held-out set → **heldout = 5 ≠ 0 ⇒ refused**; guard (e) has a live target.
  - negative vector (the same vehicle with the five held-out `H` replacements added, 20 strings) →
    **heldout = 0** ⇒ the guard leg **can** fail; the frozen plan's named ceiling ("a lookup table
    carrying a new entry for each held-out fixture would also reach `heldout=0`") is confirmed by
    measurement.
  - the emptied-negator mutation does **not** kill the vehicle (it still prints
    `PASS (cases=91)`, rc 0, no `FAIL` line) — which is why guard (e) must be the held-out-set leg.

---

## 3. C2 pre-state — the round-63 counter does not terminate

```
$ timeout 240 bash plans/round-63-c2.sh --tree <BASE tree>       # rc 124, stdout 0 B, stderr 0 B
$ timeout 240 bash plans/round-63-c2.sh --tree <lane-tip tree>    # rc 124, stdout 0 B
```

**No `C2_REFUSAL:` verdict line is produced at all** — the counter is killed by the timeout
(241.2 s / 242.3 s wall). The round-63 counter is byte-identical at BASE and at the lane tip
(`6842eb759e4605d4ee4ba49c1994aa777c6d33e330652d3d2463515df97b5d0e`).

Committed round-63 receipt: **7 bytes**, content `rc=124\n`.

Source trace of the cycle (no conclusion beyond the trace):

- `plans/round-63-c2.sh:198` — the counter runs the battery `bash "$TREE/plans/round-63-controls.sh" "$TREE"`.
- `plans/round-63-controls.sh:460` — the battery runs `timeout 2400 bash "$C2_INSTR" --tree "$CAND"`,
  i.e. the counter again.
- `grep -c C2_RECURSION_BOUND plans/round-63-c2.sh` ⇒ **0** — the BASE counter has no recursion
  bound, so each level re-enters the pair.
- The counter's own `--selftest` is healthy: `C2R63_SELFTEST: PASS (cases=13)`, rc 0.

Supplementary control (recorded so it is not misread as a counter defect): the round-63 **C1**
counter's `--selftest` reads `C1_RESIDUAL_SELFTEST: FAIL (26/28 checks)` when run from a
`git archive` extraction — because `run_checker` passes `--repo "$LANE"` and `LANE` is derived from
the counter's own location (`plans/round-63-c1.sh:67`), so in an extraction `--repo` names a
directory with no `.git`. The same counter against a git-backed BASE clone reads
`C1_RESIDUAL_SELFTEST: PASS (28/28 checks)`, rc 0. Not a defect of the counter at BASE.

---

## 4. Defects reported (nothing amended by this seat)

- **D-R64-1 — the sealed TSV is not a BASE artifact.** The wave prompt's step 1 asks for its size and
  digest "at `09cbee8…`"; at BASE it does not exist (`git ls-tree` / `git cat-file` confirm). It
  enters with the frozen plan at `dff0929`, a *descendant* of BASE. Measured at `dff0929` and at the
  lane tip (identical bytes): sha256
  `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`, **3584 bytes**, 21 lines
  (1 header + 20 rows) — matching the declared seal. No frozen item is affected; the citation should
  name `dff0929`/lane-tip, not BASE.
- **D-R64-2 — `census-a1.md`'s P4 row does not reproduce.** It records P4 as `value=1` / `i2=0` and
  calls it a "slim-tree artifact". Measured here: P4 reads `value=0` / `i2=1` **five times out of
  five** — three runs on the slim tree, one on the full 209 MB BASE tree, and one with `--repo`
  pointing at a pristine `09cbee8` clone — with the i2 detail line
  `selftest[rc=0 cases=36 PASS-line] … mutation[mutated rc=1 finding=yes]`. P4 is a control outside
  H/Q, so the frozen population and the `heldout=0` target are unaffected; but the census row and
  the "slim-tree artifact" reasoning are not reproducible with the slim tree the wave context names.
  Load probe: the i2 leg's `plans/round-60-c2.sh --selftest` sub-run has a frozen **90 s** timeout
  (`plans/round-61-c1-check.py:178,655-671`) and its wall time measured 8.7 s idle → 13.9 s under 8
  busy loops → 36.1 s under 64 busy loops on 32 cores, so a transient timeout-induced `i2=0` is a
  plausible mechanism — but it was **not reproduced** here (under 64 busy loops the leg still read
  `i2=1` and the tree still read `value=0`), so this seat asserts only the reproducible fact.
- **D-R64-3 — "Six fixes" vs seven enumerated shape classes.** Plan §C1 Amendment A1 says "Six
  fixes" then enumerates seven mechanisms (F2, F6, F8, F10, B4, P6/P7, B5); the wave context says
  "six shape classes"; the dispatch's C1-seat prompt is headed "The six reachable fixes" while
  numbering **seven** items and setting the floor at `N >= 109` = 102 + **7**. The enumeration and
  the arithmetic agree on seven; the word "six" does not. K5 requires one case per held-out shape
  class, so a hardening seat that takes "six" literally lands at `cases=108` and misses the counter's
  `N >= 109`. Frozen predicate/target/POP/kill rules/fixtures/item conditions are untouched by this
  observation — it is a count in the plan's prose and in the seat prompt, reported for the L1 to
  reconcile.
- **D-R64-4 — `census-a1.md` mixes two revisions in one sentence.** It reads "Checker … (2031
  lines, sha `f2afd9b8…` at 0c07aab8)"; measured, at `0c07aab8` the checker is `f2afd9b8…` / **1710
  lines**, and at `09cbee8` it is `eb08094c…` / **2031 lines**. Citation defect only; the correct
  round-64 BASE digest is `eb08094c…`.

### Disclosure — this seat read the sealed file

`plans/round-64-heldout.tsv` **was read** by this seat, because the seat's own steps 3/4 require
applying the eight held-out fixtures to derive their readings. It was not read for the checker's
benefit: this seat wrote no checker code, suggested none, and passed nothing to the C1 checker
hardening seat (`R64ExecC1Grammar`, which must not read it). The sealed fixture *strings* are kept
out of the receipt (only anchor-uniqueness counts and derived readings are recorded). The
prohibition binds the C1 checker hardening seat, not this seat.

---

## 5. Scope boundaries observed

- Did not touch `plans/round-61-c1-check.py` or any sibling seat's file.
- Did not run the wave's in-flight candidate counters (`plans/round-64-c1.sh`,
  `plans/round-64-c2.sh`, `plans/round-64-controls.sh`, `plans/round-64-routed.sh`); the C2
  measurement uses the frozen round-63 counter named by this seat's step 6.
- Did not commit, push, stash, or mutate any git/jj state outside this seat's own scratch clone.
- Did not write citable evidence under `/tmp`.
- No tool was installed or upgraded (nothing to record against the operator's tooling directive).

Scratch deleted at yield.

SEAT-STATUS: complete
