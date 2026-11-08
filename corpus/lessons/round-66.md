# Round 66 — kagi (secrets & vault ops)

Lane: kagi. Round 66, attempt 1. Claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`
(round-65 verifier spot-check tip). Frozen predeclaration `plans/round-66.md`
(landed `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`, Amendments A1–A3 appended
before any candidate reading). Wave `kagi-r66-w1`, 14 seats.
source: `corpus/SOURCES.md` S164 (the carrier row this round's C1 claim reads the capture path from, opened live 2026-11-08).

Claims (as amended):

- **C1 freshness** — the S148 carrier binds by path equality + digest on a
  registry row that names the capture path; `C1_CARRIER` drift 0 → 1.
- **C2 operability** — the pre-file falsification ledger reads PASS with the
  wave's attack seats reconciled and `claims-declared` reads CLEAN with the
  round's rows; `C2_PREFILE` gate 0 → 1.
- **C3 calibration** — the lane's own `corpus/sources-census.sh` gate goes
  `FAILED (findings=4)` → `CLEAN (findings=0)`; the round states which census
  it means, closing the round-65 self-description defect.

## Gate (rows written this round)

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S164 | https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode | 2026-11-08 | "In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)" (§3.1.2, locate count=1, 17 words) | admit, tier A | supersedes S148: the row now names its carrier capture, and the live re-open on this date returned the pin's bytes exactly (HTTP 200, 264946 B, sha256 `3b8d4e15…cba40`) |
| S165 | https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode | 2026-11-08 | the served 200 body differs from the pin by one byte — the `<date>` stamp `20261108`→`20261108` (no change measured this window) | reject (no row written) | a second row for one URL would be a duplicate-URL row with no new lesson; the re-open's measurement rides S164 instead |

Rows: `corpus/SOURCES.md` 155 → 156 (S164 admitted, tier A, `mined`, `180d`).
No existing row's `status`/`recheck` changed; S148's and S156's `used-by`
gained `corpus/knowledge/claim-instrument-class-matrix.md`.

## Claims and readings

C1, C2 and C3 read their before/after in the report's **Before → after
measurements** section. The counters are `plans/round-66-c1.sh`,
`plans/round-66-c2.sh` and `plans/round-66-c3.sh`; the controls battery is
`plans/round-66-controls.sh`.

## Mistakes

### M66-1 — a predicate term with no implementation surface, frozen

- **class**: `vacuous`
- **evidence**: `plans/round-66.md` §C1 as first frozen asked for a
  "header-ID digest" that resolves a wrong-id file to the candidate body;
  `grep -rn "header-ID|header_id" plans/ corpus/` matched only that plan line.
  The lane's two real mechanisms are a path-keyed read plus a pin comparison
  (`corpus/volatile-shape.py`) and a row-identity digest over registry columns
  (`corpus/sources-census.sh` SC_FETCH); neither derives an id from bytes.
- **captured-by**: `R66Reviewer` F1 and `R66Critic` F1, in the wave, before any
  candidate reading. No `QUALITY.md` criterion required a predicate's central
  term to name an existing mechanism; QM87 requires a *guard* direction to be
  satisfiable, not a predicate term to be implemented. New criterion QM89.
- **fix**: Amendment A1 restates the predicate in the mechanism that exists
  (path equality + digest match), and the counter measures it.

### M66-2 — a kill rule that defines the candidate's own action as the failing control

- **class**: `vacuous`
- **evidence**: §C1's K2 said "a path-only edit … reads `drift=0`", while the
  candidate repair is a path string landing on a registry row — the control
  and the candidate were the same act. `R66Critic` F1 (`R66Reviewer` F2) measured
  that the counter would have to read the repair as its own failure.
- **captured-by**: `R66Critic` F1 / `R66Reviewer` F2 before any reading; no
  criterion covered kill-rule self-contradiction. New criterion QM90.
- **fix**: Amendment A1's guard leg (d) makes the falsifier a *wrong-path* file
  (`.ufo/waves/round-64/capture/S148.body`, sha `fabc74c5…`), which the counter
  refuses with `digest-mismatch:` — a control a correct candidate does not
  share an act with.

### M66-3 — a target a do-nothing control already reaches (recurrence of M65-1)

- **class**: `vacuous`
- **evidence**: §C2 as first frozen compared `claims.json` with the plan's
  headings; the round's `claims.json` was written by the L1 before the freeze,
  so `C2_CLAIMS: exact=1` read on the untouched tree at zero work
  (`c2-claims: exact=1 … guard=0`). The seat's own counter reproduced it.
- **captured-by**: `R66Critic` F6; the lane rule it violates is
  `plans/round-65.md` §9 ("a target must be one a do-nothing control cannot
  reach") — the rule existed and the L1 did not apply it to its own artifact.
- **fix**: Amendment A2 re-froze C2 onto the pre-file ledger gate's PASS,
  which cannot read before the wave settled and the ledger exists.

### M66-4 — a hard-coded sample presented as a census

- **class**: `number-drift`
- **evidence**: §C3 froze `checks=3` over a citation population the reviewer
  measured at 21+ rows (`R66Reviewer` F7), and `rows=155` would break as soon as
  C1 added a row.
- **captured-by**: `R66Reviewer` F7/F10 (QM6 class: a count carries its
  command); the plan wrote the literal instead of the command's output.
- **fix**: Amendment A3 re-froze C3 onto the lane gate's own `findings=` line
  and forbids a hard-coded `rows=`.

### M66-5 — the round's census claim named the wrong gate

- **class**: `attribution`
- **evidence**: the round-65 report's Sources & frontier section cites
  `scripts/sources-census.sh validate --root … kagi` ⇒ `kagi ok rc=0` — the
  fleet wrapper — while the lane's own `corpus/sources-census.sh` read
  `SOURCES_CENSUS: FAILED (findings=4 rows=155)` at the same tip (measured
  this round). Two different gates, one word.
- **captured-by**: `R66Reviewer` F3; QM6/QM13 (a count/verdict carries its
  command) — the sentence carried a command, but the wrong one for the claim
  it supported.
- **fix**: Amendment A3 guard (d) requires both readings and names each; the
  report's Sources & frontier section prints both.

### M66-6 — the dispatch handoff had the wrong top-level shape

- **class**: `landing`
- **evidence**: `w1-dispatch.json` was written as `{context, tasks}`; the
  driver reads `d['taskCall']['tasks']` and raised
  `KeyError('taskCall')` every 30 s for ~26 minutes, spawning zero seats
  (orchestrator repaired the file at 06:13 and the wave then spawned).
- **captured-by**: none in the lane (the validator's `run` output has the
  `taskCall` wrapper; the L1 extracted only the inner object). New criterion
  QM91.
- **fix**: the repaired file is committed as the wave evidence and the
  contract is recorded in `SKILL.md`'s gate registry row for the wave path.

### M66-7 — the counter's own verdict line held a literal

- **class**: `vacuous`
- **evidence**: the L1's first `plans/round-66-c1.sh` printed
  `match=1` as a string constant, so `match` could never read 0 and the frozen
  verdict shape was a constant printer. Measured by `R66MutC1`'s battery
  (`killed=24/32` on those bytes, with the constant-printer class among the
  survivors) and confirmed by the seat's patch.
- **captured-by**: `R66MutC1`; QM82 names the class for gate selftests, not for
  a counter's verdict printer. New criterion QM89 extends it.
- **fix**: the landed bytes (sha256 `221a2cd7…`) compute
  `match = 1 iff paths_n == 3 and refused_n == 3` through `verdict_ok()`, whose
  boundary cases (`hex=2`, `hex=4`, `paths=2`, `drift=0`, `guard=0`,
  `match=0`) each fail; selftest 29 cases.

### M66-8 — mutation legs ran on a tree where the claim already failed

- **class**: `survivor`
- **evidence**: at BASE the counter still ran its three mutation legs (the
  volatile anchor supplied a path), so the do-nothing tree printed
  `paths=3 hex=3 match=1` with `drift=0` — the target shape on no work.
- **captured-by**: `R66ExecC1Carrier` (defect 2); the L1's own BASE receipt
  (`C1_CARRIER: drift=0 paths=3 hex=3 match=1 guard=0`) is the witness.
- **fix**: legs run only when `drift == 1`; the landed BASE reading is
  `drift=0 paths=0 hex=0 match=0`, and the receipt is committed.

### M66-9 — a guard leg measured the lane, not the candidate

- **class**: `scope`
- **evidence**: guard (c) read `$SELF_DIR/../corpus/volatile-shape.py`, so
  `--tree <candidate>` still measured the script's own lane — A1 says "on the
  candidate".
- **captured-by**: `R66ExecC1Carrier` (defect 3); no criterion named which tree
  a guard leg reads. New criterion QM90 covers it.
- **fix**: the leg reads `TREE/corpus/volatile-shape.py` with a lane fallback
  that passes the candidate carrier explicitly.

### Corrigendum — A1's wrong-body id list

Amendment A1 names the three wrong-id bodies "(S143/S156/S157)". `S143.body` is
the carrier itself on the repaired tree, so a copy of it measures nothing. The
landed counter (`plans/round-66-c1.sh`, sha256 `bd3310b5…`) mutates
`S148/S156/S157` — the three round-64 bodies whose bytes are not the pin — and
asserts the property (three distinct bodies, each hashing differently from the
pin) rather than an id list. A1's structure, anchors, target, guard letters and
kill rules are unchanged.

### Corrigendum — A1's command line and guard (a)

A1's command line shows only `--tree`. Guard (a) requires
`--base-tree <d549ee6 extraction>`; without it the counter reads `guard=0` by
design. The round-end receipt passes it:
`.ufo/waves/round-66/final/c1-candidate.txt`.

## Routed dispositions

| id | what | state |
|---|---|---|
| D-65-2 | capture filename ≠ registry id for S148 | bound this round: C1's carrier row names the path, and the borrowed-identity class is measured (12 files carry another id's pin — routed to round 67 as a checked class, not silently adopted) |
| D-65-3 | `CITATION_GATE` / `CLAIM_LEDGER` not re-run in round 65 | carried; this round's gate budget went to the lane census repair and the three counters |
| D-65-5 | round-65 `claims.json` carried pre-amendment wording | fixed for round 66 by Amendment A2's scope; the round-65 file is history |

## Gate result

One admit (S164) and one refusal (the duplicate-URL second row) at the
frontier step. The non-author spot-check is the closure's duty.
