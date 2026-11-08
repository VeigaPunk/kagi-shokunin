# R64Critic — the two predicates falsified before the candidate reading

Seat `R64Critic`, kagi round 64 attempt 2. Read-only over the lane. Every write is under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64Critic/` (deleted before yield) and this
receipt directory. No lane commit, no `git add/commit/stash/push`, no mutating `jj`, no host
mutation, no tool installs (`python3`, `bash`, `git`, `sha256sum`, `timeout` already present).
Nothing inside a measured tree was written; every probe ran on a copy in scratch.

Read before working: `plans/round-64.md` (frozen, incl. Amendment A1), `plans/round-64-heldout.tsv`,
`.ufo/waves/round-64/base/census-a1.md`, `.ufo/waves/round-64/base/c1-fix-reference.md`,
`.ufo/waves/round-64/base/c2-e2e-head.txt`, `corpus/lessons/round-63-verifier-spotcheck.md` §2/§6,
`corpus/lessons/round-63.md`, `.ufo/waves/round-63/w1/R63Critic.md`, `plans/round-63-c1.sh`,
`plans/round-63-c2.sh`, `plans/round-63-controls.sh`, `plans/round-62-c1.sh`,
`plans/round-62-c2.sh`, `plans/round-62-controls.sh`, `plans/round-61-c1-check.py`,
`plans/round-64-c1.sh`, `plans/round-64-c2.sh`, `plans/round-64-controls.sh`,
`.ufo/waves/round-64/w1-spec.json`.

**Seal disclosure (required).** This seat read `plans/round-64-heldout.tsv` and used it to build
falsification probes. It was **not** read for the checker's benefit; no row of it is reproduced
here. The C1 checker seat's prohibition is untouched by this seat — but see **C1-1**, a leak that
*does* reach that seat through a permitted file.

## Instruments and bytes measured

| object | revision / hash | note |
|---|---|---|
| claim BASE | `09cbee831d57be7c4edfbe77bf238f46bf729047` | lane `git log` tip-1 |
| frozen plan | `dff0929` (`plans/round-64.md`, 16 530 B) | incl. A1 |
| sealed table | `plans/round-64-heldout.tsv` sha256 `b0f51e2a…93c2` | **re-derives** (my `sha256sum`); 20 data rows, 8 in H∪Q |
| BASE checker | `plans/round-61-c1-check.py` 2031 lines | `--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (cases=102)` rc 0 |
| `--fleet` on BASE checker | accepted (`--help` lists it) | round-63 M63-9 does **not** recur |
| round-63 C1 counter | `plans/round-63-c1.sh` 660 lines | verdict literal `population=10/6` at `:524` |
| round-63 C2 counter | `plans/round-63-c2.sh` 240 lines | `--selftest` ⇒ `C2R63_SELFTEST: PASS (cases=13)` rc 0 |
| round-63 battery | `plans/round-63-controls.sh` 590 lines | `--selftest` ⇒ `CONTROLS_SELFTEST: PASS (cases=25)` rc 0 in 1.2 s |
| round-64 C1 counter | `plans/round-64-c1.sh` 35 152 B, **untracked working-tree file** | `--selftest` run by this seat (see §D) |
| round-64 C2 counter | `plans/round-64-c2.sh` 18 795 B, **untracked** | `--selftest` ⇒ `C2R64_SELFTEST: PASS (cases=21)` rc 0 |
| round-64 battery | `plans/round-64-controls.sh` 31 632 B, **untracked** | `C1_BASE_HELDOUT=8`, `C2_BASE_TERMINATES=0` |
| bao pin | `~/.local/bin/bao` sha256 prefix `9c5f3628…` | equals `PIN_BAO` (`plans/round-57-c2.sh:31`) ⇒ C2 guard (c) is runnable |
| wave | `.ufo/waves/round-64/w1-spec.json` 16 items | roles as plan §Wave; attack 4/16 = 25 %, 5/16 = 31.25 % **matches** (round-63 B-2 closed) |

Note: at the time of this review the three round-64 instruments were **uncommitted working-tree
files**; the verdict below is about those bytes, and any L1 edit re-opens the affected finding.

Slim tree used for every C1 probe: `LOG.md`, `SKILL.md`, `plans/round-60.md`,
`plans/round-60-c2.sh`, `plans/round-61-c1-check.py`, `corpus/lessons/round-60.md`,
`.ufo/waves/round-60/w1-results.json` (536 KB). The unmodified slim copy reads
`C1_ROUTED: value=0 population=7 i1..i7=1 guard=0` rc 1 — the documented invariant re-derives.

## A. C1 census re-derived — all 20 rows measured

`python3 -I -B <copy>/plans/round-61-c1-check.py --root <copy> --repo <lane> --fleet <fleet> --no-challenge`,
one fixture per fresh copy, anchor-occurrence count asserted = 1.

| id | value | i-bits | census-a1 says | agree |
|---|---|---|---|---|
| unmodified | 0 | all 1 | 0, all 1 | yes |
| F1 | 1 | i7=0 | 1, i7=0 | yes |
| **F2 (H)** | 0 | all 1 | 0, all 1 | yes |
| F3 | 0 | all 1 | 0 (correct accept) | yes |
| F4 | 0 | all 1 | 0 (correct accept) | yes |
| F5 | 1 | i4=0 | 1, i4=0 | yes |
| **F6 (H)** | 0 | all 1 | 0, all 1 | yes |
| F7 | 0 | all 1 | 0 (carried ceiling) | yes |
| **F8 (H)** | 0 | all 1 | 0, all 1 | yes |
| F9 | 1 | i7=0 | 1, i7=0 | yes |
| **F10 (H)** | 0 | all 1 | 0, all 1 | yes |
| P1 | 0 | all 1 | 0 | yes |
| P2 | 0 | all 1 | 0 | yes |
| P3 | 0 | all 1 | 0 | yes |
| P4 | **0** | **all 1** | **1, i2=0 "slim-tree artifact"** | **NO — C1-9** |
| P5 | 0 | all 1 | 0 | yes |
| **P6 (Q)** | 1 | i7=0 | 1, i7=0 | yes |
| B3 | 1 | i7=0 | 1, i7=0 | yes |
| **B4 (H)** | 0 | all 1 | 0, all 1 | yes |
| **B5 (Q)** | 1 | i4=0 | 1, i4=0 | yes |
| **P7 (Q)** | 1 | i7=0 | 1 (mechanism level) | yes |

**`heldout=8` re-derives**: the five H rows read `value=0` and the three Q rows `value>=1` at BASE.
The population is non-vacuous and K1's `heldout=8` floor is sound. P4 is outside H∪Q, so its
disagreement does not touch the claim.

## B. C1 — can `heldout=0` be reached without the grammar?

### Attempt 1 — a checker that reads no file
Constant `value=0` ⇒ 5 H counted ⇒ `heldout=5`. Constant `value=1` ⇒ 3 Q counted ⇒ `heldout=3`.
**Fails**, and both are refused by the landed counter's constant-printer defence
(`plans/round-64-c1.sh`, `measure_heldout`'s `cmp -s "$pfx.gate.out" "$pfx.H-$id.out"` guard).

### Attempt 2 — a monotone token/length rule
Computed with the checker's own tokenizer (`[A-Za-z0-9_']+`) on the **whole replaced line**:

| id | base → fixture tokens | Δ |
|---|---|---|
| F2 (H) | 89 → 94 | +5 |
| F6 (H) | 75 → 88 | +13 |
| F8 (H) | 80 → 84 | +4 |
| F10 (H) | 89 → 95 | +6 |
| B4 (H) | 89 → 93 | +4 |
| P6 (Q) | 89 → 94 | +5 |
| B5 (Q) | 80 → 83 | +3 |
| P7 (Q) | 89 → 103 | +14 |

Exhaustive threshold search, three features × both directions × every threshold in ±1 of an
observed value:

| rule | best `heldout` |
|---|---|
| reject iff Δ > T / Δ < T | **2** / 2 |
| reject iff repl-len > T / < T | 2 / 2 |
| reject iff anc-len > T / < T | 3 / 3 |
| blanket reject / blanket accept | 3 / 5 |

**A pure length rule cannot reach 0** — the target is not vacuously reachable. But the margin is
one token (B4 Δ = 4 vs B5 Δ = 3; F2 Δ = 5 = P6 Δ = 5), so one length rule plus two benign
exceptions reaches 0 with no polarity reasoning (**C1-3**).

### Attempt 3 — a checker that errors on held-out input (the counting hole)
BASE checker + a prelude that exits 2 printing nothing on the five forgeries' inserted strings,
delegating `--selftest` to the real checker:

```
--selftest                    ⇒ C1_CHECK_SELFTEST: PASS (cases=102)
unmodified slim copy          ⇒ C1_ROUTED: value=0 population=7 i1..i7=1 guard=0  rc 1
F2/F6/F8/F10/B4 (H)           ⇒ <no C1_ROUTED line>   rc 2   (all five measured)
P6/B5/P7 (Q)                  ⇒ C1_ROUTED: value=1 …  rc 1   (unchanged from BASE)
F1 (control)                  ⇒ C1_ROUTED: value=1 …  rc 1   (unchanged from BASE)
```

Under the frozen predicate's **literal** counting rule (count only a printed `value=0` /
`value>=1`), a verdict-less run is neither, so the forgery half scores as correctly rejected:
measured `heldout=3` for this checker, and `heldout=0` if the same prelude also covers the three
benign strings. **The landed counter closes this**: `measure_heldout` fails closed
(`[[ -z "$RUN_VAL" ]] ⇒ AF_ERR ⇒ return 1`) and the verdict block calls `setup_die`, so a
verdict-less fixture yields SETUP, never a pass. The frozen text does not say so — see **C1-2**.

### Attempt 4 — the A4 vehicle, as specified vs. as informed
The landed counter builds the A4 vehicle from the round-63 residual/bypass tables
(`make_vehicle_tree`), so it has no entry for any H row ⇒ `heldout=5` ⇒ refused by guard (e).
A 23-entry variant (16 committed + 8 held-out) passes every leg including (e). Declared as a
ceiling — but **C1-1** hands the eight strings to the seat guard (e) is supposed to police.

### Attempt 5 — the do-nothing control
See §E. A byte-identical BASE checker reads `heldout=8`; adding seven dummy selftest cases
(`cases=109`) flips `guard` to 1 without changing `heldout`. Target missed — until the leak is
used.

## C. C2 — is `terminates=1 killed=5` reachable cheaply?

### The recursion, traced
`plans/round-63-c2.sh:198` → `plans/round-63-controls.sh <tree>` → `main()` calls
`probe_counters` **first** (`plans/round-63-controls.sh:585`), which runs `bash "$C2_INSTR" --tree` — and `C2_INSTR` is
`plans/round-63-c2.sh` — back to `:198`. The two stub controls (`ctrl_c1_f8` `:368`,
`ctrl_c2_f6` `:406`) are emitted **after** `probe_counters`, and `ctrl_prior` (`:323`) is last.

A wall-clock cap therefore harvests **nothing** — measured: a scratch copy of the battery whose
`emit()` also writes to stdout, run on the lane tree under `timeout 120`, printed its header lines
and **zero `CONTROL` lines** before the deadline (the L1's `rc=124` at 240/900/1500 s is the same
run). This is why the landed bound has to *select* controls instead of trimming the clock.

### The bound as landed
`plans/round-64-c2.sh:328` calls `battery_run "$TREE" "$WORK/battery.out" "$BOUND"` with **no
timeout argument**; `battery_run` (`:153`) then sets `R63_CONTROLS_FIXTURE_ONLY=1` when
`BOUND=1`. `plans/round-63-controls.sh:571-584` honours it by skipping `probe_counters` **and**
`ctrl_prior` and running the six fixture controls. So:

| tree | `BOUND=1` | `BOUND=0` |
|---|---|---|
| candidate (patched battery) | fixture-only battery ⇒ l3, l4 fire ⇒ run completes | full battery ⇒ re-enters ⇒ hangs |
| BASE `09cbee8` (unpatched battery) | flag ignored ⇒ `probe_counters` ⇒ re-enters ⇒ **hangs** | hangs |

`terminates=1` is therefore a property of the **measured tree's battery file**, not of the counter:
the counter carries no bound of its own (`battery_run` has no timeout at `:328`). Guard (b) of the
plan ("bound=0 must not terminate in 240 s") is satisfied trivially, and a candidate tree whose
battery ignores the flag hangs the counter with no self-protection. See **C2-2**.

### Reachability
- Deleting the battery leg ⇒ l3 = l4 = 0 ⇒ `killed=3` ⇒ target missed. K3 holds.
- A stub that prints the frozen target line and sleeps under `C2_RECURSION_BOUND=0` satisfies the
  predicate's literal text and guard (a)-(d) — **no guard leg refuses a stub** (**C2-5**).
- `killed` is the counter's own sum; the predicate's cross-check against "the round-63 counter's
  own selftest legs on the same tree" is unimplemented (**C2-3**).

## D. Findings

### C1-1 — high — the seal leaks to the exact seat forbidden from reading it, through a file its own prompt tells it to read

**Observation.** `.ufo/waves/round-64/w1-spec.json` → `R64ExecC1Grammar.prompt`:
> "**You must NOT read `plans/round-64-heldout.tsv`** … Build from the six shape classes … and the
> evidence file `.ufo/waves/round-64/base/census-a1.md` (**which names each class, not each fixture
> string**)."

Measured: the minimal inserted substring of each H∪Q row appears `in` the committed census
(6/8 verbatim) and the other two are described precisely:

| fixture | distinguishing string | in `census-a1.md` |
|---|---|---|
| F2 | `, which is not the case` | **verbatim** |
| F6 | duplicated `rewritten in place at …` mechanism, second occurrence | described |
| F8 | `, the record denies it` | **verbatim** |
| F10 | `and, seen elsewhere, 4/16 = 25 %` | **verbatim** |
| B4 | `a different seat than` | **verbatim** |
| P6 | `— not the other way round —` | **verbatim** |
| B5 | `not less than` | **verbatim** |
| P7 | full replacement incl. `(16 results counted, three present roles, one sentinel present, as the role mix records)` | **verbatim** (`census-a1.md:43-45`) |

`census-a1.md` is **tracked** (`git ls-files` ⇒ `.ufo/waves/round-64/base/census-a1.md`, committed
with the plan at `dff0929`).

**Consequence.** A seat that obeys its prompt reads the census, learns all eight strings, can
implement an 8-entry lookup, reaches `heldout=0` with `guard=1`, and **truthfully reports it never
read the sealed file**. The disclosure protocol is defeated because the content is reachable
through a second, permitted file. With C1-8, the claim's causal reading — "the grammar closes the
held-out set" — is false as specified.

**Fix (smallest safe, no predicate change).** Redact `census-a1.md` to class-level prose (drop
every quoted inserted string; keep id → class → required reading), re-commit, and point the C1 seat
at the redacted file. The L1 then greps the seat's checker for the redacted string set and records
`leak=0` in the C1 receipt; a nonzero count is a defect, not a pass. Until it lands the claim must
stay worded as process-bounded and the lesson must record the attempt-2 breach.

### C1-2 — medium — the frozen counting rule does not require fail-closed; the instrument's correctness rests on an unstated counter behaviour

**Observation.** Measured (§B/Attempt 3): a checker that prints nothing on the five H rows measures
`heldout=3` under the predicate's literal rule (`value=0` / `value>=1` only), and `heldout=0` if it
also swallows the three Q rows. The **landed** `plans/round-64-c1.sh` closes this —
`measure_heldout` sets `AF_ERR` and returns 1 on an empty `RUN_VAL`, and the verdict block turns
that into `setup_die` (no `C1_HELDOUT:` line) — but nothing in `plans/round-64.md` §C1 requires it,
and the plan's "reads SETUP, never a pass" clause is stated only about *tree-copy cost*.

**Consequence.** The claim's validity depends on a counter behaviour the frozen predicate leaves
optional. A re-implementation (or a seat editing the measure leg) can reach `heldout=3` for free and
`heldout=0` with the leaked strings, and no leg would notice.

**Fix.** State it in the C1 counter's registry row and its header (it is already true of the code):
a held-out fixture with no parsable `C1_ROUTED: value=` is SETUP. Add one `--selftest` case that a
verdict-less checker tree produces SETUP, so the property is pinned rather than incidental.

### C1-3 — medium — separability margin is one token; a length rule plus two exceptions reaches the target

**Observation.** §B/Attempt 2. Best monotone length rule: `heldout=2` (closes 5/5 forgeries,
misrejects P6 and P7). B4 (Δ=4) vs B5 (Δ=3) differ by one token; F2 (Δ=5) equals P6 (Δ=5).

**Consequence.** The plan's ceiling covers "a lookup table carrying a new entry for each held-out
fixture"; it does not cover "one length rule plus exceptions", which is cheaper and survives a
per-string leak audit. The landed counter also has no leg requiring the H rows to fail on
*distinct* items, although the instruments already produce distinct i-bits (`F2` all-1 →
`i7=0` under a fix, `F6` → `i5=0`, `F8` → `i4=0`, `B4` → `i7=0`) — nothing checks it.

**Fix.** Add the ceiling sentence to §C1's lesson text, and have the landed counter print
`per-fixture` i-bits (it already prints `id=valueN` in `HITS`; extend to the bit that failed) so a
reviewer can see the H rows fail on distinct items.

### C1-4 — medium — fixture ids are reused across two tables with different fixtures

**Observation.** `plans/round-64-heldout.tsv` uses `F1..F10`, `P1..P6`, `B3..B5`;
`plans/round-63-residual.tsv` / `plans/round-63-benign.tsv` use the **same ids for entirely
different fixtures** (round-63 `F2` = `**A3 item 2 is withdrawn — the record denies it**`; round-64
`F2` = the sentinel-percentage pair plus an appended denial; round-63 `F10` = a duplicate launch
stamp; round-64 `F10` = a duplicate fraction pair). The frozen predicate names ids only.

**Consequence.** Every unqualified per-fixture citation is ambiguous, and a seat grepping for `F2`
finds the round-63 fixture first; it can harden the wrong class and believe it closed round-64 `F2`.

**Fix.** Use the plan's own `H1..H5` / `Q1..Q3` labels in every derived artifact and report; keep
the frozen predicate's `F2,F6,F8,F10,B4` naming but always qualify the table it indexes.

### C1-5 — low — the plan text carries no seal step (the landed counter does; the battery does not)

**Observation.** `plans/round-64.md` fixes the sha but specifies no verification; the landed
`plans/round-64-c1.sh` verifies it (`SEAL_ACTUAL` vs `HELDOUT_SHA`, SETUP on mismatch) — good. The
round-64 battery only *comments* that it never reads the table (`plans/round-64-controls.sh:75`)
and its receipt carries no seal sha.

**Fix.** Have `plans/round-64-controls.sh` emit `INSTRUMENT plans/round-64-heldout.tsv <sha>` in its
receipt header so the seal is pinned by a second instrument.

### C1-6 — medium — C1 is coupled to a C2 script, and executes it twice per measurement

**Observation.** Stripping `plans/round-60-c2.sh` from the slim tree:

```
c1: i2 FAIL selftest[plans/round-60-c2.sh missing or symlinked] …
C1_ROUTED: value=1 population=7 i1=1 i2=0 … guard=0
```

i.e. guard (a) fails and the unmodified copy no longer reads `value=0`. The checker **executes**
that C2 counter's `--selftest` twice per invocation (`round-61-c1-check.py:702`, `:664`), which
dominates the ~25 s cost of every C1 measurement.

**Consequence.** Answering the assignment's separability question: **C1 does need a C2 file.** The
plan declares no such dependency.

**Fix.** Declare it in §Bounds ("I2 executes `plans/round-60-c2.sh --selftest`; a tree without it
cannot read `value=0`") and keep `i2` in the counter's provenance line (it is already in the
checker's detail output) so a stripped tree is visibly a dependency failure.

### C1-7 — low — the plan floor (`≥91`) and the counter floor (`≥109`) disagree; a 91–108-case checker satisfies the frozen plan and fails the instrument

**Observation.** §C1 guard (b) says `N >= 91`; `plans/round-64-c1.sh` sets `SELFTEST_FLOOR=109`
(BASE prints 102).

**Fix.** Say which governs. If the counter's floor is intended, record in the lesson that the guard
is stricter than the frozen text (a *narrowing*, which the wave may adopt, but must state).

### C1-8 — medium — guard (e) refuses the vehicle's needle, not its class

**Observation.** `make_vehicle_tree` builds the 15-entry table from the round-63 residual/bypass
tables; on the held-out set it reads `heldout=5` ⇒ refused. A 23-entry variant passes every leg.
§C1 names this ceiling, and the round-63 `chal` leg (emptied `NEGATORS` must fail the checker's own
selftest) is **not** in the round-64 guard.

**Fix.** Restore `chal` as guard (f) *(amendment — report, do not apply)*, or keep the claim worded
as process-bounded. Together with C1-1, the wheel-bounded wording is currently false.

### C1-9 — low — the census's P4 reading does not reproduce on the documented slim tree

**Observation.** On the slim tree (which includes `plans/round-60-c2.sh`) P4 reads `value=0`, all
i-bits 1; `census-a1.md:35` records `P4 | 1 | i2=0 — slim-tree artifact`. P4 is excluded from H∪Q,
so the population is unharmed, but the census's tree definition is unstated and its stated reason
does not hold for the tree the assignment documents and the landed counter builds (its `SLIM_FILES`
is the same seven paths).

**Fix.** Restate the census's tree definition and re-record P4; keep P4 out of H∪Q.

### C1-10 — high — guard (c)'s 600 s budget is below the round-63 counter's measured cost on the slim tree the counter builds

**Observation.** `leg_resid` runs `<slim>/plans/round-63-c1.sh --tree <slim>` under
`RESID_TIMEOUT=600` and reads `RESID=0` on a non-zero rc with no verdict line
(`plans/round-64-c1.sh`, `leg_resid`). `leg_vehicle` runs the **same** counter a second time under
the same budget.

Measured cost of one checker invocation on that exact slim tree, `--repo <lane> --fleet <fleet>
--no-challenge`: **26.08 s** (`/usr/bin/time`). Independent batch rate: 11 fixture rows in 300 s =
27.3 s/row. The round-63 counter's verdict run performs, on the same tree:
`measure_residual` 10 forgery + 6 benign = 16 invocations, `leg_real` 1, `leg_prior` 5,
`leg_para` 3 (the three stub legs cost one gate each, not sixteen — `stub_leg` →
`measure_residual` → `selftest_gate` refuses before the fixtures). That is **25–26 expensive
invocations**, i.e. **652–678 s derived** — above the 600 s cap with no margin, and the two batches
above were measured under fleet load, where 90 s/row was observed. One direct end-to-end run of
`plans/round-63-c1.sh --tree <the same slim tree>` was still running when my shell cap cut it at
**300 s with no verdict line** (i.e. >50 % of the 600 s budget consumed before completion, and the
platform's 300 s job cap prevented the full measurement).

**Consequence.** `RESID=0` by timeout on a perfectly hardened candidate ⇒ `guard=0` ⇒
`C1_HELDOUT: … guard=0` and exit 1 on the very run the round needs. The C1 claim's target is then
unreachable for a *cost* reason, and the plan explicitly says a cost-driven reading must be SETUP,
never a pass — so the counter would report guard=0 rather than admit a budget defect.

**Fix.** Raise `RESID_TIMEOUT` above the measured total with margin (≥1200 s at 26 s/invocation),
or have `leg_resid`/`leg_vehicle` measure only the round-63 **measure** leg (16 fixtures) instead of
the full counter including its own guard legs — a 17-invocation cost (~450 s). Either way: record
the measured seconds per invocation in the receipt so the budget is derived, not guessed.

### C2-1 — high — the landed guard (d) is not the frozen guard (d), and the frozen one is unsatisfiable

**Observation.** Plan §C2 guard (d): "the round-63 controls battery's existing controls still match
with 0 skips".
- The battery's `fixture-only` branch (`plans/round-63-controls.sh:571-584`) skips
  `probe_counters` **and** the `ctrl_prior` delegation. Since `C1_HAVE`/`C2_HAVE` are set only in
  `probe_counters` (`:459`, values at `:461`/`:469`), `ctrl_c1_nowork`/`ctrl_c2_nowork`/
  `ctrl_c1_real`/`ctrl_c2_real` (`:479`, `:496`, `:513`, `:528`) all `report_skip`, and **no
  `PRIOR-*` row is emitted at all**. So the only terminating battery run emits `SKIPS: 4` and zero
  PRIOR rows.
- The landed counter instead measures `g_d = bash "$TREE/plans/round-62-controls.sh" --selftest`
  and greps `CONTROLS_SELFTEST: PASS` — the **round-62** battery, fixture-driven ("no instruments,
  no bao"), i.e. a constant leg that says nothing about the candidate.

**Consequence.** Frozen guard (d) is either unimplementable inside the budget (0 skips is
impossible for any terminating run) or silently replaced by a weaker, differently-scoped leg. Either
way the frozen predicate cannot be met as written, and the landed counter does not report it.

**Fix.** Report the predicate defect to the L1; in the counter, implement guard (d) as "the
fixture-only battery run exits 0 (`mismatch=0`), with the 4 reading-dependent controls recorded as
`skip` and counted", and print `skips=N` in the C2 verdict's detail lines instead of claiming 0.

### C2-2 — high — the bound lives in the measured tree, not in the counter; `battery_run` has no timeout

**Observation.** `plans/round-64-c2.sh:328` → `battery_run "$TREE" "$WORK/battery.out" "$BOUND"`:
no timeout argument (the 4th parameter defaults to 0 = none). The only bound is the env var
`R63_CONTROLS_FIXTURE_ONLY=1`, which **the tree's** `plans/round-63-controls.sh` must honour. On a
BASE tree (unpatched battery) the flag is ignored, `probe_counters` re-enters `round-63-c2.sh`, and
the counter hangs with no self-protection — the run's stop is the external `timeout 1200`. This is
why K1 holds (a BASE tree reads no verdict line).

Two more consequences:
1. `terminates 0→1` measures "the measured tree carries round-63's patched battery" as much as
   "the counter bounds itself". The bound's **entire** effect is one `if` block in
   `plans/round-63-controls.sh` (`:571`); the `plans/round-63-c2.sh` pass-through the C2 seat was
   told to add (`:198`) is inert on this path (the round-64 counter calls the battery directly).
   Both files are round-63's measured artifacts and change with **no `supersedes` row, no registry
   re-pin** — `SKILL.md:878` pins `C2R63_SELFTEST: PASS (cases=13)` and `SKILL.md:879` pins
   `CONTROLS_SELFTEST: PASS (cases=25)` for those files, and the round-63 lesson cites their bytes.
2. The bound is *cooperative*: any future tree with an unpatched or third-party battery hangs the
   counter. A counter whose whole claim is termination should carry its own timeout.

**Fix.** (i) Give `battery_run` a timeout at `:328` (the plan's own 240 s refutation budget plus
margin) so a non-cooperating tree produces l3=l4=0 and a verdict line rather than an unbounded run;
(ii) record new sha256/`wc -l` for both patched round-63 files and an explicit `supersedes` note in
the lesson; (iii) re-read the two `SKILL.md` tallies at integration.

### C2-3 — medium — the predicate's leg-sum cross-check is unimplemented: `killed` is self-reported

**Observation.** §C2 says killed "equals the sum of the five round-63 legs as measured by the
round-63 counter's own selftest legs on the same tree". `plans/round-64-c2.sh` computes
`killed=$(killed_calc $l1 $l2 $l3 $l4 $l6)` from its own legs and never reads a round-63 selftest
composition; `plans/round-63-c2.sh --selftest` asserts field parsing, not a per-tree leg sum.

**Fix.** Either drop the clause (report to the L1) or implement it: run
`plans/round-63-c2.sh --selftest --tree "$TREE"` and compare its leg set with the counter's, and
print `crosscheck=ok|mismatch` in the detail lines.

### C2-4 — medium — l3/l4 are near-constant and, under the bound, are measured on a degraded battery

**Observation.** `ctrl_c1_f8`/`ctrl_c2_f6` build a stub counter printing `C1_STUB_LINE`/
`C2_STUB_LINE` (the target lines) and compare against hard-coded BASE constants
(`C1_BASE_ACCEPTED=10`, `C1_BASE_REJECTED=6`, `C2_BASE_KILLED=0`) ⇒ `mismatch` on **any** tree
carrying the battery, unconditionally. Under the bound they also run on a battery whose
`probe_counters` was skipped.

**Fix.** Name it as a ceiling (round 63 did) and state in the receipt that `killed=5` = 2
near-constant legs + 3 measured legs.

### C2-5 — medium — the C2 guard is self-reported; a stub satisfies it, and the refusals sit outside the predicate

**Observation.** The frozen guard and the landed guard do not line up:

| plan §C2 guard | landed implementation (`plans/round-64-c2.sh`) |
|---|---|
| (a) round-63 counter `--selftest` ⇒ `C2R63_SELFTEST: PASS` | `g_r63`, folded into `selftest_leg` ✔ |
| (b) `bound=0` must not terminate inside 240 s | **not a guard leg** — it is a battery control (`ctrl_c2_bound`, `plans/round-64-controls.sh:542`) |
| (c) the five legs still fire individually | implied by `killed=5`, never asserted as a guard |
| (d) the round-63 battery's controls match with 0 skips | **substituted** by `g_d = round-62-controls.sh --selftest` |
| — | `g_a` = round-62 C1 counter `--selftest` (not in the plan's list; carried from round 63) |

Guard (a) = two selftests; (b) = this counter's own `--selftest`; (c) = the `round-62-c2.sh` real
trial; (d) = the round-62 battery selftest (C2-1). So a stub that prints the frozen line and sleeps
under `C2_RECURSION_BOUND=0` satisfies every counter-side guard. The refusals that would catch it —
`C2-F7` (printer-stub) and `C2-NOWORK` — live in the battery, outside the predicate.

**Fix.** Require the receipt to cite `C2-F7=mismatch` and `C2-NOWORK=match` from the same tree's
battery run next to the verdict line (free, no predicate change), or move them into the guard (L1
amendment).

### C2-6 — low — `killed=5` keeps the five ids but l3/l4's measured artifact changed

**Observation.** Round-63 l3/l4 = the full battery's `C2-F6`/`C1-F8`; round-64 = the fixture-only
battery's. K3 voids a claim only for a *dropped* leg.

**Fix.** Record the scope change (full → fixture-only) in the lesson with the identical control ids.

### C2-7 — medium — guard (c) reaches a host binary and a tree file the plan does not declare

**Observation.** `g_c` runs `bash "$TREE/plans/round-62-c2.sh" --tree "$TREE"`, which sha-pin-gates
`$HOME/.local/bin/bao` against `plans/round-57-c2.sh:31` and runs the seal trial. Present and
matching here (prefix `9c5f3628…`), but a missing/mismatched bao or a tree without
`plans/round-57-c2.sh` makes `guard=0` for reasons unrelated to the bound.

**Fix.** Declare the dependency in §Bounds (round 63 named "the real leg needs `bao`"; round 64's
plan does not) and have the counter print `real_dep=bao|missing` beside the `real=` field.

## E. Do-nothing control verdict (explicit)

- **C1 — the byte-identical no-work control does NOT meet the target.** Measured: BASE checker on
  the unmodified slim tree reads `value=0`; on the five H rows `value=0`; on the three Q rows
  `value=1` ⇒ `heldout=8`, and `guard=0` (its selftest is 102 < the counter's 109 floor). Adding
  seven dummy selftest cases flips `guard` to 1 without changing `heldout=8` — still missed.
- **C1 — the cheapest control that DOES meet it is a no-grammar lookup, and the committed census
  supplies the entries.** With the eight strings from `census-a1.md` (C1-1), a checker that keeps
  BASE behaviour on the 16 committed fixtures and answers the eight held-out rows from an 8-entry
  table reads `heldout=0` with `guard=1` (real ✓, selftest ✓ at 109, resid ✓, stub ✓, vehicle ✓ —
  the vehicle is a different table and still reads `heldout=5`). Verified by construction against
  the landed counter's leg definitions and by the per-fixture census in §A; **the error/crash
  shortcut is refused** by the landed fail-closed measure leg (C1-2). So: the C1 target is
  reachable without the grammar *given the leak*; it is not reachable by a blank refusal.
- **C2 — a byte-identical no-work control does NOT meet the target** (no verdict line; the battery
  re-enters). **The cheapest control that does meet it is a stub**: a file that prints
  `C2_REFUSAL: killed=5 population=5 guard=1 (… terminates=1 bound=1)` and sleeps when
  `C2_RECURSION_BOUND=0` satisfies the predicate's literal text and the landed guard (a)-(d). Only
  the battery's out-of-predicate controls (`C2-F7`, `C2-NOWORK`) refuse it. **The C2 target is
  therefore reachable without bounding any recursion, and neither the plan nor the counter's guard
  says so.**

## F. Impacted axes

- **calibration (C1)**: C1-1 (seal leak — the claim's causal reading), C1-2, C1-3, C1-4, C1-6
  (undeclared C2 coupling), C1-8, C1-10 (guard budget vs. instrument cost). C1-5, C1-7, C1-9 are
  declaration/measurement defects.
- **operability (C2)**: C2-1 (frozen guard unimplementable and silently substituted), C2-2 (the
  bound is in the tree; no timeout in the counter; two round-63 instruments changed without
  provenance), C2-3, C2-4, C2-5, C2-7. C2-6 is a scope-record defect.
- Nothing here is only a ceiling: every finding above names a fix the L1 can take before the
  candidate reading. C1-1, C1-10, C2-1 and C2-2 should be dispositioned first — C1-1 and C2-1
  decide whether the two claims can be worded as they stand.

## G. Verified-closed (no finding)

- `--fleet` is accepted by the BASE checker at `09cbee8` ⇒ round-63 M63-9 does not recur.
- Wave shape: 16 items, roles as plan §Wave, attack 4/16 = 25 % / 5/16 = 31.25 % ⇒ B-2 closed.
- The seal sha re-derives and the landed C1 counter verifies it (C1-5's implementation half).
- The landed C1 counter fails closed on a verdict-less fixture (C1-2's implementation half).
- `plans/round-63-c2.sh --selftest` ⇒ `C2R63_SELFTEST: PASS (cases=13)` rc 0;
  `plans/round-63-controls.sh --selftest` ⇒ `CONTROLS_SELFTEST: PASS (cases=25)` rc 0 (1.8 s);
  `plans/round-64-c2.sh --selftest` ⇒ `C2R64_SELFTEST: PASS (cases=21)` rc 0.
- The l1/l2 needles each occur exactly once in the tree's `plans/round-62-c1.sh` (measured
  `count=1`), so the round-63 M63-7 cross-seat hazard does not fire: the C1 seat writes
  `round-64-c1.sh`, not `round-62-c1.sh`.
- `plans/round-64/base/c2-e2e-head.txt` is `rc=124` (7 bytes) — the BASE non-termination reading
  is as the plan states.

SEAT-STATUS: complete
