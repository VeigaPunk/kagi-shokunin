# R68Critic — C2 calibration + plan-to-landed fidelity (attack)

Seat: critic (attack 1 of the frozen attack list). Lane `kagi-shokunin`,
branch `master`, claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`,
frozen predeclaration `23a8e0290d8d3a6f1de16eafce40fd1a189ef636`
(`plans/round-68.md` + `claims.json`). Read-only: no lane file was edited,
no git mutation, no commit. Every construction ran under scratch
`/fast/scratch/hyaku/kagi-r68/R68Critic` (deleted after receipts were
copied to the report directory). At report time the candidate counters do
not exist yet (`plans/round-68-c1.sh` / `plans/round-68-c2.sh` absent) and
the ledger/cells/gate edits have not landed — the findings below are
measured against the frozen plan + BASE bytes + the seat spec, and the
smallest safe corrections are written so they can be checked against the
landed bytes when the executors finish.

Impacted axes: **calibration** (direct — C2's instrument integrity), and
secondarily **freshness** (C1 is the other surface of the same record
set). Judgeable verdicts: C2 as frozen is falsifiable in all three legs
via counter construction, not just honest misuse; the plan's own
`guard = 1 (a)–(c)` does not close the forgeries. Freeze discipline holds
(no post-reading change).

## 1. Attack each C2 leg (constructed, paste-verified)

### (a) L1 — stub-gate forge: `mismatches=0` from a printer, not the selftest

**Counterexample.** A `corpus/sources-census.sh` that never executes a
case and prints only:

```
SOURCES_CENSUS_SELFTEST: PASS (89 cases)
```

is indistinguishable from the real gate by every instrument C2 is said to
use:

1. `claim-ledger.sh verify`'s claim rule is *exit code + ERE against the
   last non-empty output line* (`corpus/claim-ledger.sh` §claim). The
   stub prints exactly the anchored line at the right place with rc 0,
   so row `R21-03` passes.
2. The seat-spec phrasing for L1 — "the count the gate prints under
   `--selftest` on the measured tree (parse both numbers; compare live,
   never a literal)" — is satisfied: the counter *does* run the gate
   and *does* parse the live number. The printer is the live number.
   It is not closed by that wording alone; only a BASE-pinned execution
   (the QM58 instrument class) closes it.
3. The plan's C2 guard (a)–(c) does not invoke a BASE-pinned gate or a
   stub-gate selftest: (a) `SOURCES_CENSUS: CLEAN` is printed verbatim
   by the same stub; (b) `CLAIM_LEDGER: CLEAN` follows from the row
   command printing the pinned line; (c) the negative controls are
   *ledger-flags-an-unminted-id* and *cells-flags-a-scored-section* —
   neither touches the census gate.

**Paste (constructed in scratch; real gate's final line shown for
comparison):**

```
$ stub_printer.sh          # prints exactly one line
SOURCES_CENSUS_SELFTEST: PASS (89 cases)
$ diff <(stub_printer.sh) <(bash corpus/sources-census.sh --selftest | tail -n1)
L1-STUB_MATCHES_FINAL_LINE: YES (ledger final-line rule cannot distinguish stub)
```

**Impacted axes:** calibration — C2 loses its only live instrument on
L1. **Not** a fixable defect of the frozen predicate, but of the frozen
counter spec and the frozen guard: as written, L1 admits a lying gate.

**Smallest safe correction (to be asserted against the landed
`plans/round-68-c2.sh` when it exists):** L1's live comparison must
execute BASE-pinned census bytes (`git archive <BASE>:corpus/sources-census.sh`
or a pinned sha) *or* the candidate gate must carry at least one
boundary case in which the case-count is wrong and the verdict is FAIL
(QM89) **plus** a stub-gate replay case inside the counter's own
selftest (QM58). The journal rule stays: `expect-journal.sh` must read
CLEAN for the `R21-03` `88→89` migration, but the journal alone cannot
vouch for the gate — the journal binds the *ledger*'s text, not the
*gate*'s behaviour.

### (b) L2 — row-text forge: `mismatches=0` while the C1 derivation is broken

**Counterexample.** A `plans/round-68-c1.sh` that contains only:

```sh
echo "C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1"
```

and ledger rows

```
R68-01  bash plans/round-68-c1.sh  ^C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1$
R68-02  bash plans/round-68-c2.sh  ^C2_RECORD: mismatches=0 population=3 guard=1$
```

with a C2 counter that counts **only** "these rows exist and name the
frozen predicates" is satisfied by row text alone:

- ledger `verify` — the row command prints exactly the pinned line,
  rc 0 → `CLAIM_LEDGER: CLEAN` (the ledger's final-line rule);
- `claims-declared.sh` — reads `CLAIMS_DECLARED: CLEAN`, which checks
  the *axis* of each `68<TAB>Cn<TAB>axis` row, never that the counter
  computes anything;
- the C2 counter's guard (b) — same `CLAIM_LEDGER: CLEAN` — follows.

Construction in scratch (rogue tree with the two planted rows, a stub
`round-68-c1.sh` and a row-text-only `round-68-c2.sh`) prints
`C2_RECORD: mismatches=0 population=3 guard=1` rc 0. The C1 claim's
population (`verified`, `col15`, `caught` — all *derived* numbers in the
frozen predicate) is never computed.

This is the QM89 class (a verdict field that cannot read differently),
but the round-68 C2 spec as issued for `R68ExecCounterC2` says "each
leg needs a positive and a negative vector" and "each bound to its
counter's frozen predicate" — predicate presence *is* a positive
vector under that wording. The plan's own §C2 L2 row says "each bound
to its counter's frozen predicate", which the forger meets textually.

**Impacted axes:** calibration (the rows are the record). **Smallest
safe correction:** L2 must execute both counters and require their
*leg-level* verdicts — `caught=6/6` with per-leg reason match, and the
identity of the derived population (`verified`/`col15` equal to an
independent row-by-row count) — not merely that the rows' expect lines
name `C1_VERIFIED:`/`C2_RECORD:`. Concretely: the C2 counter runs
`bash plans/round-68-c1.sh --tree <candidate> --base-tree <BASE>` and
fails L2 unless its output *and* its six leg fixtures agree with the
gate's own `FINDING` lines. The landed C1 counter cannot be judged
from row text.

### (c) L3 — cells tolerance: both directions constructed

BASE parser behaviour (measured) — the historical heading genuinely
breaks it:

```
claim-ledger: unrecognised round heading in SCORECARD.md: '## Round 63 — planned'
  (expected '## Round <N> — pre-move|post-move')          # exit 2, via die()
```

A `scored`-section-missing-an-axis fixture and an *unscored-heading-hides-a-
score-table* fixture both die the same way. So a fix is required; the
question is which shape.

**Naive fix (variant A — exact-regex skip):** add

```
PLANNED_RE='^## Round [0-9]+ — planned$'
```

and treat a matching heading like `BLOCKED_ATTEMPT_RE` (skip section,
skip the whole section's table). Patched in scratch against the real
script copy, run on two fixtures:

```
# unscored-hide:  '## Round 99 — planned' + table, one pointerless axis row
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 ...)
# rename-hide: SAME fixture, heading relabeled '## Round 63 — planned'
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 ...)
```

The rename-hide direction is the defect: any scored section renamed to
**exactly** `## Round N — planned` hides its score table — `in_set=0`
short-circuits the cell loop (`[[ $in_set -eq 1 && $content == '|'* ]] ||
continue`) and `section_check` never runs, so a pointerless or
missing-axis table reads CLEAN. The other direction *does* stay loud:
`## Round N — planned (claims C1 freshness)` does **not** match the exact
regex and still dies — so a fix that keys on "does the heading text
signal a score table" instead of exact equality also closes this.

**Impacted axes:** calibration — the cells gate is C2's L3 repair
surface. **Smallest safe correction the landed parser must satisfy:**

1. exact-heading skip **only**, and
2. the skip aborts (die, not skip) if a `|` table line appears before
   the next `##` heading — i.e. a scored table under an unscored heading
   is a loud failure, never a skipped section; and
3. a scored section (`SEC_RE` match) still dies if any axis is missing
   (existing `section_check`), covered by the counter's own negative
   vector.

Check the landed `claim-ledger.sh` against (1)–(3) before C2 passes;
variant A alone is insufficient.

## 2. Overclaim audit of the record surfaces the round changes

Standard: every sentence asserting a number names the command that
produced it (QA6/QM21/QM34 class). Pre-candidate state (the executors'
edits are still landing; this is the audit of what is frozen today, plus
the numbers the round *will* add).

| # | sentence | names command? | naive-reader risk |
|---|---|---|---|
| P-1 | plan §Motivating evidence: "Lane gate selftest is 89 cases, but row R21-03 expects 88" | yes — `bash corpus/sources-census.sh --selftest` reproduces 89; the ledger row shows 88 | none; both sides inspectable |
| P-2 | plan §C2 L1 table: "expects … 88 while the gate prints 89 (`SOURCES_CENSUS_SELFTEST: PASS (89 cases)`)" | yes — quotes the gate's final line | none |
| P-3 | plan §C2 Landing surface: "(`CLAIMS_DECLARED: CLEAN (claims=63)` at candidate)" | names the command, but the *value* is only true after landing the round-68 rows; the live run at freeze reads `claims=61` (no 68 rows yet). Quoted verbatim *before* the landing, the sentence asserts a candidate value that no command has produced | **yes — the worst candidate overclaim.** The sentence is true at candidate (61 + 2 rows = 63) but only after R68-01/R68-02 and the `claims-declared.tsv` 68 rows land. Any report quoting `claims=63` without re-reading `claims-declared.sh` after landing is asserting a number by copy. |
| P-4 | entry `source-capture-binding.md`: "36 capture-path rows at BASE, every one bound by sha256 and size, six mutation classes caught … The BASE gate reads `CLEAN` on all six (receipt `.ufo/waves/round-67/base/blind-gate.txt`)" | cites a *receipt*, not a measuring command | moderate — the receipt exists (verified by the R67 Revenger §2), but the sentence's evidence form is "a file says", not "run X". |
| P-5 | entry: "120 rows name a section … 17 of them contain `/`" | **no command** | high — pure counts with no reproducer. |
| P-6 | entry: "the token `a` occurs 580 times in the audit-device body" | **no command** | high — same shape. |
| P-7 | entry: "its §1.2 sentence reads `count=0` raw and `count=1` rendered" | names the normalizer's verbs but no invocation | medium — a reader cannot re-run from the sentence alone. |
| P-8 | entry §Reproduction: `bash corpus/sources-census.sh  # SOURCES_CAPTURES: CLEAN (path_rows=36 …)` — the counts sit in comments, not in stdout | commands are named, but the reproducer's expected line is a comment | medium — a copier can mistake the comment for a measured verdict. The widened population also changes these counts (36→37 prose/path split), so the block is stale the moment the recut lands unless the scribe re-measures it. |

No round-68 number has yet entered `SCORECARD.md` / `LOG.md` (both
grep-clean for round-68; only `SCORECARD.md` §sayings from earlier rounds
remain), so the only live overclaim exposure is P-3 plus the
entry's inherited P-5/P-6/P-7. The scribe's round-68 entry update must
re-measure the counts in P-5–P-8's family *with commands beside them* or
they fail QA6.

## 3. Freeze discipline

- `git log --oneline d3b2a4e8..master` (as the assignment directs):
  ```
  23a8e02 round-68: frozen predeclaration (plan C1 freshness / C2 calibration, claims.json)
  7e78630 round-68: wave spec, dispatch, ready handoff, claims.json, BASE receipts (...), scorecard pre-move
  ```
  Only two commits after BASE: the predeclaration and the wave
  handoff. `git diff 23a8e02..master -- plans/round-68.md
  .ufo/waves/round-68/claims.json` is **empty** for the frozen tracks.
  No predicate, population, kill rule or target changed after the first
  candidate reading — there *is* no candidate reading yet, and the
  frozen text has not moved. No post-reading change to name.
- BASE receipts were committed with the handoff
  (`.ufo/waves/round-68/base/`): census-start (CLEAN 36/36/36/121),
  selftest (89), fleet-wrapper (`kagi ok`), c1-base counter (caught
  0/6), base-derivation (verified 36 / col15 31) and three blindness
  witnesses (trailing-space, CRLF, col15-swap — each `CLEAN` on the BASE
  gate). All are QM96-clean: each names its tree, mutation and reading.
- One cosmetic drift to note, not a freeze breach: `claims.json` targets
  spell `GUARD=1` while the plan predicates spell `guard=1`. The axis
  mapping (`C1→freshness`, `C2→calibration`) matches; the case
  difference does not change any predicate. Flagged here so a strict
  string-match judge does not count it as a mismatch.
- `claims-declared.tsv` currently ends at round 67; `CLAIMS_DECLARED:
  CLEAN (claims=61)` is live. The plan's `claims=63` at candidate is
  exactly +2 rows (the two round-68 rows) — consistent *if* the declared
  rows land in the same commit as this plan's claims. That is the P-3
  condition above.

## 4. Causal separability of C1 and C2

**Verdict: separable in the frozen predicates, coupled in the frozen
guard — no full counterexample.**

- **Each is verifiable without the other.** C1's population is pure
  row-by-row census work over `corpus/source-fetches.tsv` (per-row
  derivation, per-leg mutation, blindness witness) — it never reads the
  ledger. C2's legs are ledger/journal/`claims-declared`/`cells`
  checks — none reads the census's capture-verification numbers. The
  BASE measurements are independent: at BASE, `verified=36` (C1, no
  guard) is measurable at the same moment `mismatches=3` (C2) is
  measurable — and the three BASE blindness witnesses read `CLEAN` on
  the census while the ledger still mis-pins 88. The ledgers' machines
  are disjoint; the kills are independently satisfiable.
- **The coupling is in C2's guard, not in the predicates.** C2 guard (a)
  requires `SOURCES_CENSUS: CLEAN` "the registry this round re-cuts is
  not broken" — `SOURCES_CENSUS` is C1's gate verdict. So C2 guard=1
  *does* depend on C1's gate being coherent, and a round-68 gate that
  fails C1's `SOURCES_CAPTURES: CLEAN` (e.g. a botched recut) zeroes C2
  guard too, even when all three ledger legs are clean. The plan
  acknowledges this by naming it as a guard, not a leg; it does not
  make C2 unverifiable without C1 (the legs are runnable), only
  C2-*guard* coupled. That is a deliberate, visible tradeoff — not a
  hidden causal collapse. **Counterexample considered and rejected:** a
  tree where C1's gate FAILS yet C2's ledger legs are clean prints
  `mismatches=0` but `guard=0` — the guard kills it, which is the
  intended coupling, not a falsification of either claim.
- Distinct axes are also distinct *instances*: C1's `freshness`
  predicate's blindness witnesses (whitespace/CR/col15) are exactly the
  classes the revenger measured CLEAN at round 67; C2's `mismatches`
  (88-pin, missing rows, SETUP heading) are exactly the three BASE
  ledger defects. No number of one claim is a function of the other.

## 5. Smallest safe corrections (for the integrator, checked pre-yield)

1. **L1:** require `plans/round-68-c2.sh` to execute BASE-pinned census
   bytes for the live count, plus a stub-gate selftest pair (real gate
   prints 89 / stub printing 89 does *not* reach `mismatches=0`).
2. **L2:** require the counter to *execute* `round-68-c1.sh` (and the C2
   rows' counters) and match leg-level derivation, not predicate text.
3. **L3:** require exact-heading skip **with** a table-after abort (any
   `|` row before the next `##` kills the skip); a scored section
   missing an axis must still die via `section_check`.
4. **P-3:** re-read `claims-declared.sh` *after* the declared rows land
   and quote its actual `claims=` value in the round report; do not
   copy the plan's `claims=63`.
5. **P-5/P-6/P-7:** the scribe adds a command beside each number or
   states "counted by hand, not a command" — the honest caption.
6. **`GUARD` vs `guard`:** normalize case in one of the two frozen
   tracks with a journal entry rather than letting two spellings stand
   in the record.

Receipts (copied in): `stub_printer.sh`, `rogue-c2/` (row-text forge),
`fx-cells/` (L3 fixtures), `verdicts.txt`, `overclaim-audit.txt`.

SEAT-STATUS: complete
