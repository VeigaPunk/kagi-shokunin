# R62ScoutPreState — pre-state census at BASE 60b5b7b6

Seat `R62ScoutPreState` (scout, w1, kagi round 62 attempt 1). Receipt with every
command and its exact output: `.ufo/waves/round-62/build/R62ScoutPreState/prestate.md`.

Scope: read-only. No lane file was edited (other than this report and the receipt
named by this seat), no git/jj mutation was run in the lane, a sibling lane or any
index, and the lane's git/jj index was never touched. Scratch:
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ScoutPreState/`, deleted before
this seat yielded. No tool was installed or upgraded by this seat.

## What was measured

BASE extracted with `git archive 60b5b7b60b76629633110a5b4adac883193c8b2a` into the
scratch; every fixture is a copy of that tree with exactly one asserted-once
substitution.

**BASE checker digest:** `plans/round-61-c1-check.py` sha256
`d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812`, **1454 lines**.
`plans/round-61-c2.sh` 389 lines; `corpus/openbao-seal-trial.sh` 1123 lines.

**C1 — the five bypass fixtures each read `value=0`, rc 1** (checker invoked
`python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge`;
the checker bytes in every copy equal the BASE digest, so only the tree varies):

| fixture | substitution | `C1_ROUTED:` line | rc |
|---|---|---|---|
| B3 | `**A3 item 2 is withdrawn**` → `… is not withdrawn**` | `value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| B4 | `… three new record defects it did not route` → `… no three new record defects …` | `value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| B5 | `it was rewritten in place at` → `it was **not** rewritten in place at` | `value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| B6 | `the lane was progressing, not stale.` → `the paragraph's times are correct.` | `value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| B7 | `3/16 = 18.75 % … 4/16 = 25 %` → `3/16 = 25 % … 4/16 = 18.75 %` | `value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| unmodified copy | — | `value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |

The per-item `c1:` detail lines are **byte-identical across all six copies**
(measured by `diff`, not assumed). The unmodified copy with the challenge leg enabled
reads the same line with `guard=1` rc 0.

⇒ **`C1_BYPASS accepted = 5`** (POP 5), target 0. **BASE 5 re-derived.**

**C2 — both falsifier legs survive, the guard does not discriminate:**

* M-A (main aggregation block → constant `value=5`): `bash plans/round-61-c2.sh --selftest` ⇒ `C2_SELFTEST: PASS (cases=11)` rc 0.
* M-B (shim aggregation made unconditional): `bash plans/round-61-c2.sh --selftest` ⇒ `C2_SELFTEST: PASS (cases=11)` rc 0.
* G (tree whose trial is a 2-line stub that exits 0 and prints nothing): `bash plans/round-61-c2.sh --tree <copy>` ⇒ `C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=1 (… trial=fb99eae9…)` rc 1 — `guard=1` where the predicate requires `guard=0`.

⇒ **`C2_HARDENED killed = 0`** (POP 3), target 3. **BASE 0 re-derived.**

**BASE selftest case counts:** `python3 -I -B plans/round-61-c1-check.py --selftest` ⇒
`C1_CHECK_SELFTEST: PASS (52 cases)` rc 0; `bash plans/round-61-c2.sh --selftest` ⇒
`C2_SELFTEST: PASS (cases=11)` rc 0.

## Findings the executors should act on

1. **The plan's C2 leg wording names markers the BASE counter does not carry.**
   §C2 defines M-A/M-B over `# BEGIN-DECIDE`/`# END-DECIDE` and `# BEGIN-SHIMS`/
   `# END-SHIMS`; `grep -rn 'BEGIN-DECIDE|BEGIN-SHIMS'` over the whole BASE tree
   returns nothing. The markers are a property the hardened counter must introduce,
   so the frozen leg text cannot be applied literally at BASE. This seat used the
   corresponding BASE source blocks. **Reported, not amended** (the plan is frozen):
   the executor that introduces the markers must place them so the same two mutations
   are the ones the predicate names, and the round-62 counter's fixtures must pin the
   marker positions so the K2 "needle matches exactly once" property holds.
2. **Both guard thresholds sit above BASE's own case counts.** Guard leg (b) needs
   ≥ 57 C1 cases (BASE ships 52) and guard leg (a) needs ≥ 17 C2 cases (BASE ships
   11). The plan's K5 names one case per fixture class (five bypass + three
   paraphrase) on top of BASE's 52 → 60 ≥ 57 for C1; C2 needs ≥ 6 added cases.
   Without these, GUARD cannot read 1 on any tree and no candidate can satisfy the
   predicate.
3. **The M-A mutant is a constant-acceptor, not merely a selftest blind spot.**
   Measured: the M-A counter on the stub tree whose trial prints nothing reads
   `C2_SEAL_TRIAL: value=5 … guard=1` **rc 0**, while the unmutated counter on the
   same tree reads `value=0` rc 1. The `nosecret/stub_ok/value=5` re-zeroing line
   sits *downstream* of the mutated block and is satisfied (`stub_ok=1`,
   `nosecret=1`), so the constant survives it. A candidate that only moves the
   aggregation into a function without re-ordering the re-zeroing does not close the
   M-A leg.
4. **The M-B mutant fabricates the shim census.** Measured: on the stub tree it reads
   `shims=5 vectors=ok/5` while every measured shim vector is `NNNNN`. `V=ok` is
   derived from `shims_ok`, so an unconditional `shims_ok` also fabricates the
   "vectors ok" reading. A candidate must derive `vectors` from the measured
   vectors, not from the shim counter.
5. **The C1 counter's `--selftest` (52 cases) contains no bypass-class or
   paraphrase-class case.** Derived from the plan's K5 requirement versus the BASE
   count; the fixture classes are the round's own new cases.
6. **A plan amendment landed while this seat was running (not by this seat).**
   `plans/round-62.md` gained `## Amendment A1 — 2026-11-07, before any candidate
   reading (I6's denial clause)`, adding clause (d) to the hardened I6 condition,
   credited to `R62ExecC1Counter` and `R62ExecC1Grammar`. This seat's census is
   unaffected — every reading here used the BASE checker's bytes
   (`d525ee28…`, 1454 lines) from `git archive 60b5b7b6`, and the BASE checker does
   not read `plans/round-62.md` at all. This seat's own B6 measurement corroborates
   the amendment's premise: on the B6 fixture the BASE checker reads
   `i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9` and the tree
   reads `value=0` rc 1, i.e. the denial is accepted at BASE. Flagged for the L1's
   integration record; this seat made no amendment and takes no position on the
   amendment's authority.

## Bounds

* Everything above is measured from commands in this seat's scratch against the
  BASE tree; no number is quoted from the plan.
* The BASE real-trial reference run (`C2_SEAL_TRIAL: value=5 … guard=1` rc 0, trial
  sha256 `a3bc8825…`, 63 trial cases) used the pinned `/home/vgpnk/.local/bin/bao`
  (v2.7.2, sha256 `9c5f3628…`, matching the lane's own `PIN_BAO`); it is a read-only
  input, nothing was installed.
* The M-A/M-B full-run readings in §4b of the receipt are beyond the assigned step;
  they use the same BASE instrument and scratch and are offered as executor-facing
  evidence.
* No frozen predicate, target, POP, kill rule or item condition was amended. No
  claim is made here for either round; this seat only establishes the pre-state.

SEAT-STATUS: complete
