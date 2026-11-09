# R69MutTester — mutation probe of the C1/C2 counters (attack artifact)

SEAT-STATUS: complete

Lane: kagi. Seat: R69MutTester (mutation-tester; the validator refuses
`labrat` as a swarm role, so this probe rides the mutation-tester seat).
Claim BASE `264917aa8fc9e71b6595d0d5166c4b615120fb8b`. Frozen plan
`plans/round-69.md` §C1/§C2 read first; the 13 routed defects in
`corpus/lessons/round-68-verifier-spotcheck.md` §7 likewise. No production
edits: every mutant below is a scratch copy under
`/fast/scratch/hyaku/kagi-r69/R69MutTester/`, preserved at
`.ufo/waves/round-69/w1/R69MutTester/` (detector `legcheck.py`, mutant
predicate bytes `predicate-m5.sh`/`predicate-const.sh`/`predicate-empty.sh`).

Context the L1 needs before the table: when this probe ran, the live lane
carried only the predicate repair (R69ExecPredicate, selftest 59→62), the
record-surface repairs (R69ExecRecord), the ledger repoint (R69ExecLedger),
and `plans/round-69-c2.sh` (selftest 19 cases). `plans/round-69-c1.sh`
(R69ExecCounterC1) had NOT landed (no file at `plans/round-69-c1.sh`, no
seat scratch), so the C1 mutants were evaluated with an independent
detector (`legcheck.py`) derived verbatim from §C1's leg wording, while the
C2 mutants ran the real `plans/round-69-c2.sh`. The pristine readings
below capture the live lane at that moment, not the final candidate.

## Baseline (pristine live lane vs BASE extraction)

- `bash plans/round-68-c1.sh --selftest` on the candidate: 
  `C1_VERIFIED_SELFTEST: PASS (62 cases)` rc 0; on the BASE extraction:
  `C1_VERIFIED_SELFTEST: PASS (59 cases)` rc 0.
- `bash plans/round-69-c2.sh --tree . --base-tree <BASE>` on the live lane:
  `LEG subfloor tree=cand a=1 b=0 c=1 subfloor=0`,
  `LEG ledger tree=cand a=0 b=0 c=1 d=1 ledger=0`,
  `C2_TEETH: subfloor=0 ledger=0 guard=0` rc 0.
  Root cause of `b=0`: the seat spec froze `N_cand = N_base + 1`, but the
  predicate seat shipped three new cases (62 vs 59, delta +3); the
  counter's exact `== base+1` test fails a correct repair. This is a
  finding, not a mutant: the frozen predicate and the shipped instrument
  now disagree. R69ExecPredicate's own notes name the same divergence.
  The ledger `a=0` is a second live-lane breakage: the scratch reduced
  ledger prints `CLAIM_LEDGER: FAIL (claims=1 failed=1 deferred=0
  stamped=168 stale=5 …)` where `CLAIM_LEDGER: CLEAN (claims=1…` is
  required. Neither breakage is in the plan's kill rules to re-litigate;
  both are measured here because they decide what a mutant run can show.

## Mutants

### M1 — partial L1 repair (fabricated aggregate kept, `unprovable` + receipt added)

- Mutant: scratch copy of the live lane with the L1 honest-stop row
  keeping the aggregate `C2_RECORD: mismatches=0 population=3 guard=1`
  alongside the `unprovable` token and the receipt path
  `.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt`.
- Command: `python3 legcheck.py <m1-tree> <base-tree> L1` (independent
  detector: the §C1 L1 wording requires the ROUND-68 CALIBRATION ROW to
  name `unprovable` AND the receipt AND carry NO `mismatches=0` string).
- Observed: `L1 sec=None=False unprovable=True receipt=True
  fab_present=True`, verdict `L1 verdict=MISMATCH`.
- Verdict: **KILLED** by the leg wording. A keyword scan over the whole
  file would see both tokens; the section-scoped rule correctly refuses.
  The plan's own guard (d) decoy control (same idea, honest-stop text in
  the round-67 row) relies on exactly this scoping — the probe confirms
  the scoping carries the load.

### M2 — wrong-receipt supersession in the lesson-68 correction

- Mutant: correction block appended to `corpus/lessons/round-68.md`
  naming `.ufo/waves/round-68/w1/R68ExecCounterC2/c2-run.txt` (exists,
  carries `C2_RECORD: mismatches=3 population=3 guard=0`, RC 1/124,
  pre-fix bytes) instead of
  `.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt` (the honest-stop
  receipt).
- Command: `python3 legcheck.py <m2-tree> <base-tree> L3`.
- Observed: `L3 orig_present=True corr=True names_sentence=True
  names_receipt=False`, verdict `L3 verdict=MISMATCH`.
- Verdict: **KILLED** by the leg wording: the correction does not name
  the plan-required honest-stop receipt. Note for the L1: `c2-run.txt`
  is a true-looking receipt that exists — a counter that only checked
  "names a receipt that exists" would false-pass here. The plan's L3
  wording ("names … the honest-stop receipt") is what kills this
  mutant; that string must not be loosened to "any existing receipt".

### M3 — shape-only QUALITY repair (four rows >QM96, `round-68` cited, no falsifier)

- Mutant: four rows `QM97`–`QM100` appended to `corpus/QUALITY.md`,
  each citing `corpus/lessons/round-68.md` in the lesson column, each
  stating a one-line shape claim with NO falsifier text (no "the
  observation that would make it wrong", no failing-condition sentence).
- Command: `python3 legcheck.py <m3-tree> <base-tree> L11`, plus manual
  inspection of the four rows.
- Observed: `L11 high=['QM100','QM97','QM98','QM99']
  cited68=['QM100','QM97','QM98','QM99'] count_cited=4`,
  `L11 verdict=PASS`; the four rows as printed carry falsifier-free
  criteria ("A supersession names the old bytes…", "A frozen floor is a
  predicate comparison.", …).
- Verdict: **SURVIVED** by the frozen leg wording — and this is the
  report's central finding. L11 as frozen ("at least four criteria with
  id > QM96 whose source column names `corpus/lessons/round-68.md`")
  checks id + source column only; it never reads the criterion or
  falsifier text, so a four-row shape-only repair satisfies it. The bar
  itself (QUALITY.md §QM criteria, QA4: "Each entry names a falsifier")
  forbids this, but the counter has no leg that reads falsifier text.
  The plan anticipated the analogous hole elsewhere (M69-2: "a
  predicate whose frozen floors exist only in the plan is not a floor;
  captured-by: QM98") but frozen no falsifier-text check for L11. The
  L1 should expect a shape-only QUALITY landing to read green on L11;
  closing it requires a leg (or a QM18-style identity check over
  criterion text) the plan did not freeze. No seat is asked to change
  the contract; the finding is recorded for the falsification ledger.

### M4 — two-row scratch ledger under the C2 `ledger` leg

- Mutant: a candidate tree whose `corpus/claim-ledger.tsv` reduced file
  keeps TWO rows (`R68-02` plus `R99-99`, whose expect
  `^NEVER_PRODUCED_LINE_XYZ$` can never pass), built from the live
  repointed `R68-02` row.
- Detector: real `bash plans/round-69-c2.sh --tree <m4-tree>
  --base-tree <BASE>` (the counter's own ledger leg, including its
  reducer `reduce_ledger()` which returns `None` unless exactly one
  `R68-02` row exists, and its `reducer-refuses-duplicate-row`
  selftest case).
- Observed: `LEG ledger tree=cand a=0 b=0 c=0 d=0 ledger=0`,
  `C2_TEETH: subfloor=0 ledger=0 guard=0` rc 0;
  `a verify-reduced rc=1 last='CLAIM_LEDGER: FAIL (claims=1 failed=1
  deferred=0 stamped=168 stale=4 …)'`. A second construction (raw
  two-row ledger with comments) took the same path: `rows=2 (need
  exactly 1)` / reducer refusal.
- Verdict: **KILLED on both constructions.** The reducer refuses any
  row count ≠ 1 before execution, and the duplicate-row selftest case
  makes the refusal part of the instrument's own selftest. `ledger`
  does not read 1 on a two-row ledger. (The pristine live lane also
  reads `ledger=0` through the stale-stamp path above, so M4's kill
  is measured against the already-red baseline; the refusal itself is
  what the probe exercised.)

### M5 — comment-only floors plus an early `return True` for the sub-floor input

- Mutant: `plans/round-68-c1.sh` `predicate_ok` gains
  `# verified >= 37, col15 >= 32` as comment text and
  `if verified == 36 and col15 == 31: return True` before the
  unchanged body (bytes preserved at `R69MutTester/predicate-m5.sh`).
- Commands:
  - `bash plans/round-68-c1.sh --selftest` on the mutant instrument:
    `C1_VERIFIED_SELFTEST: FAIL (62 cases, 2 failed)
    names=predicate-subfloor,predicate-floor-col15` rc 0 (printed
    verdict is FAIL, exit plumbing prints it — the counter's
    `selftest()` returns 1 on failure but the wrapper's printed line
    is what the consumer reads; the observed line FAILs explicitly).
  - `bash plans/round-69-c2.sh --tree <m5-tree> --base-tree <BASE>`:
    `LEG subfloor tree=cand a=0 b=0 c=1 subfloor=0` with
    `a (36, 31, 6, 1, 0) want=False got=True MISS`, verdict
    `C2_TEETH: subfloor=0 ledger=0 guard=0` rc 0; the mutant's own
    selftest read `tree_cases=None(rc=1)` (`b` also fails on the
    count).
- Verdict: **KILLED twice over** — by the instrument's own selftest
  cases `predicate-subfloor`/`predicate-floor-col15` AND by the real
  C2 counter's leg (a + b). The early `return True` for exactly the
  sub-floor probe point cannot hide behind a comment: the comment does
  not compare, the branch does not refuse, and both detectors execute
  the function rather than reading its text. This is the D8 repair
  working as designed.

### Counter-instrument self-mutants

- **Constant verdict** (`verdict_line` replaced by
  `return "C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1"`):
  command `bash plans/round-68-c1.sh --selftest` on the mutated
  instrument gives
  `C1_VERIFIED_SELFTEST: FAIL (62 cases, 2 failed)
  names=verdict-line,verdict-line-zero` rc 0. **KILLED** by the
  counter's own selftest (the `verdict-line` cases assert the
  composition); a constant-verdict counter cannot pass its own
  selftest. This answers the plan's guard (f) requirement that the
  selftest include "a constant-verdict mutant" and confirms the
  shipped selftest discharges it.
- **Emptied leg** (`measure()` short-circuited to print
  `C1_VERIFIED: SETUP empty-leg` and `return 2`): command
  `bash plans/round-68-c1.sh --tree <tree>` gives
  `C1_VERIFIED: SETUP empty-leg` rc 2. **KILLED** in the required way:
  reads `SETUP`, never a numeric pass — exit 2, no `C1_VERIFIED:`
  verdict line. (Its `--selftest` still prints `PASS (62 cases)` since
  the selftest does not route through `measure()`; recorded as the
  boundary of the detector: the empty-leg mutant is caught by the
  production path, not by the selftest.)

## Verdicts for the L1 (falsification ledger)

- M1 killed by section scoping; M2 killed by named-receipt wording;
  M4 killed by the exactly-one-row reducer; M5 killed by execution
  (selftest + C2 leg); constant-verdict killed by the counter's own
  selftest; empty-leg killed by the SETUP production path.
- **M3 (shape-only QUALITY rows) SURVIVED** the frozen L11 wording.
  Finding for the ledger: L11 green does not establish the bar's
  falsifier requirement; a falsifier-text leg would be a new freeze,
  not a repair of this round's counter.
- Two baseline divergences measured (not mutants, not re-litigation):
  (i) shipped predicate selftest is 62 vs BASE 59 (+3) while C2
  `subfloor` (b) demands exactly `N_base + 1` — live lane reads
  `subfloor=0` on a correct repair; (ii) the scratch reduced ledger
  reads `CLAIM_LEDGER: FAIL (claims=1 failed=1 … stale=5)` where
  `CLAIM_LEDGER: CLEAN (claims=1…` is required — live lane reads
  `ledger=0` independently of any mutant. The C1 counter (no
  `plans/round-69-c1.sh` at probe time) may resolve either; the
  falsification rows above remain valid against the leg wording and the
  landed C2 counter.

## Restoration evidence

No production file was modified by this seat: `git status --porcelain`
before and after shows only the sibling seats' in-flight changes
(`plans/round-68-c1.sh`, record surfaces, ledger) with no new
modification attributable to this probe; all mutants are scratch copies
(sha256 of the three predicate mutants on file under
`.ufo/waves/round-69/w1/R69MutTester/`), and the BASE extraction is
untouched. No tool installed; no pacman transaction; scratch deleted
except the report-dir copies above.
