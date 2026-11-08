# Round 64 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 64, attempt 1. Claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047` (round-63 verifier spot-check tip,
`round-63 verifier spot-check (integrator, hyaku): non-author admit/reject`, 2026-11-07).

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; capabilities entered rounds
57–63, so no stagnation waiver is claimed. Both claims are declared here before any
candidate work; this file is committed alone as the predeclaration, then the
instruments, then the pre-freeze control battery, then the candidate.

Motivating evidence for the round:

- `corpus/lessons/round-63-verifier-spotcheck.md` §2/§6 routes two record defects
  (D-63-1 the lookup-table guard vacuum M63-6; D-63-2 the C2 nested-battery recursion
  M63-LEN) and carries one carried debt (D-63-3, all landed, nothing open). They are
  resolved as work items (receipt `plans/round-64-routed.sh`), not as a third claim.
- The round-63 spot-check §2 holds the C2 `killed=5` number as a **leg composition**,
  not a single counter verdict (receipt `.ufo/waves/round-63/final/c2-refusal.txt` is
  7 bytes `rc=124`). The C1 ceiling is named the same way: leg (f) falsifies the A4
  *vehicle*, not the grammar class. Both ceilings are this round's claims.
- The round-63 SCORECARD `## Round 63 — planned` items 1–3 are the round's frontier:
  (1) a held-out fixture not in the committed TSVs in the C1 guard; (2) a recursion
  bound so one `bash plans/round-63-c2.sh --tree .` terminates inside its own budgets;
  (3) a freshness re-verification of the S143 BioC endpoint and the S138/S144 flips.

## C1 — calibration: a held-out fixture defeats the lookup-table checker

Target axis: calibration (the mismatch between the lane's self-assessment — here the
C1 instrument's claim that it implements a polarity grammar — and observed behaviour:
a fixture-lookup checker reaches `accepted=0 rejected=0` on the committed tables).

**Frozen predicate (this sentence is the plan's, the counter's code and the receipt's label):**

```
C1_HELDOUT: heldout = the number of the round-64 held-out fixtures (H1..H5, ids
F2,F6,F8,F10,B4 in plans/round-64-heldout.tsv, Amendment A1) on which the measured
tree's checker (plans/round-61-c1-check.py, invoked
`python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --fleet <fleet-root> --no-challenge`)
prints `C1_ROUTED: value=0` (accepts the forgery) or on which any of the three
benign held-out fixtures (Q1..Q3, ids P6,B5,P7, Amendment A1) prints `value>=1`
(rejects the benign rewrite). POP = 8 (5 forgery + 3 benign); target heldout=0
(BASE 8, legs (a)-(e) below). GUARD = 1 iff, on the same measured tree: (a) the
unmodified copy prints `value=0` (the seven round-61 corrections still resolve); (b) the
checker's `--selftest` exits 0 printing
`C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 91; (c) the round-63 counter's
verdict still reads `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1`
on the candidate (no regression on the committed tables); (d) a printer-stub
checker is refused — no `C1_HELDOUT:` verdict line and a non-zero exit; (e) the
A4 lookup-table vehicle (a checker carrying a literal
`NEGATORS = frozenset(())` dead line plus a 15-string fixture lookup and a
constant `PASS (cases=91)`) is refused on the held-out set — it must NOT reach
`heldout=0` on the candidate.
```

The held-out fixtures are **sealed at the predeclaration**: they live in a single
file `plans/round-64-heldout.tsv` (sha256
`b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`, Amendment A1,
20 rows over the round-60 correction lines in `corpus/lessons/round-60.md` and
`LOG.md`, plus id `P7`) that the C1 counter seals before any candidate work and
never updates. They are **held out from the checker**: the checker and its
selftest are built without reading them, and the wave's checker seat is told
so in its prompt (which names the sealed file and forbids reading it; a seat
that reads it must disclose that in its report, which the L1 records as a
defect, not a pass).

Every number the counter compares is derived at run time from the measured tree or,
where a fixture names a revision, from the lane repository; no constant carries a fact
the measured tree asserts.

The 20 rows split by prefix (Amendment A1): H1..H5 (ids F2,F6,F8,F10,B4) are
forgeries the round-63 checker accepts at BASE (each must read `value>=1` on the
hardened checker); Q1..Q3 (ids P6,B5,P7) are benign rewrites it rejects at BASE
(each must read `value=0` on the hardened checker); the remaining rows are
controls (each must still read `value>=1`, and each is already rejected at BASE or
is not counted): F1,F5,F9 (already rejected at BASE — swapped pairs / direct
negation), F3,F4 (already accepted correctly at BASE — hedge / idiom), F7
(accepted at BASE, carried as a known ceiling), P1,P2,P3,P4,P5 (accepted at BASE),
B3 (already rejected at BASE). The anchors are the round-60 correction lines the
round-63 checker reads. The amendment's census evidence is in
`.ufo/waves/round-64/base/census-a1.md`; the superseded full-file sha
`7ed354918ca6c635…` is retained there for audit, never cited as the seal.

Commands:

```
bash plans/round-64-c1.sh [revision]          # BASE when omitted; --tree DIR also accepted
bash plans/round-64-c1.sh --selftest [revision|--tree DIR]   # the counter's own selftest
python3 -I -B plans/round-61-c1-check.py --root <tree> --repo <lane> --fleet <fleet-root> --no-challenge
```

Output line: `C1_HELDOUT: heldout=A population=8 guard=G (real=… selftest=… resid=… stub=… vehicle=…)`.
Exit 0 iff guard=1 and heldout=0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a tree byte-identical to BASE must read `heldout=8 population=8`; any lower
  reading means a held-out fixture is vacuous and voids the claim.
- K2: each forgery must be able to read accepted on the BASE checker and rejected on
  the hardened checker; each benign rewrite must be able to read rejected on the BASE
  checker and accepted on the hardened one.
- K3: a printer-stub checker must be refused (guard leg d).
- K4: the round-63 `C1_RESIDUAL` verdict must still read `accepted=0 rejected=0`
  on the candidate (guard leg c); a hardening that regresses a committed fixture
  fails the guard, not the claim.
- K5: the A4 lookup-table vehicle must NOT read `heldout=0` on the candidate (guard
  leg e); the checker's `--selftest` must carry one case per held-out shape class
  that names the class without quoting the fixture, and must fail on a mutated copy
  (the negator set emptied).

**Population census at BASE (measured, not assumed, Amendment A1):** on an
extracted `09cbee8` tree the five held-out forgery copies (ids F2,F6,F8,F10,B4)
each read `C1_ROUTED: value=0 population=7 …` rc 1, and the three benign copies
(ids P6,B5,P7) each read `value>=1` rc 1 — heldout 8. The unmodified copy reads
`value=0` rc 1. The A4 vehicle reads `heldout=0` on the committed tables
(accepted=0 rejected=0) — that is the defect this claim closes. The pre-amendment
file's census (`heldout=8` over F1..F10/P1..P6) was disproven by the L1's own
re-measurement (F1,F5,F9 already rejected at BASE; F3,F4 already accepted
correctly as hedge/idiom; F7 accepted with no polarity hook) and is superseded
by this text; the per-fixture readings are in
`.ufo/waves/round-64/base/census-a1.md`. The committed counter re-derives the
amended census.

**Named ceilings:** eight fixtures are eight fixtures, not a grammar proof; a
lookup table carrying a *new* entry for each held-out fixture would also reach
`heldout=0` — the counter cannot tell a fresh lookup from the grammar (the seal
discloses this; the checker's challenge leg (f) from round 63 is the only guard that
sees the vehicle's needle, and it is unchanged here). A structural read cannot prove
the corrected sentence true (QM79/QM81). The negator/denial/idiom lists stay closed
floors.

## C2 — operability: the C2 counter terminates end-to-end (single verdict line)

Target axis: operability (a runnable artifact that produces the stated outcome — here,
one counter invocation that prints its verdict line inside its own budgets).

**Frozen predicate:**

```
C2_TERMINATES: terminated = 1 iff a single invocation
`bash plans/round-64-c2.sh --tree <candidate>` from a clean scratch root prints
exactly one `C2_REFUSAL: killed=K population=5 guard=G (…) ` line and exits with the
counter's own exit code inside `timeout 1200`, AND that invocation's `killed` equals
the sum of the five round-63 legs as measured by the round-63 counter's own selftest
legs on the same tree. Target terminated=1 with killed=5 population=5 guard=1
(BASE terminated=0: the round-63 counter read `rc=124` at 900s and 1500s and the
committed receipt is 7 bytes).
GUARD = 1 iff, on the same measured tree: (a) the round-63 C2 counter's `--selftest`
exits 0 printing `C2R63_SELFTEST: PASS`; (b) a tree with the recursion bound removed
(`C2_RECURSION_BOUND=0`) does NOT terminate inside `timeout 240` (the bound is real,
not decorative); (c) the five legs still fire individually (L1/L2 print a named
finding, L3/L4 read mismatch, L6 reads `C1_CHECK_SELFTEST: FAIL`); (d) the round-63
controls battery's existing controls still match with 0 skips.
```

The recursion bound is an explicit environment flag `C2_RECURSION_BOUND` (default 1):
at 1 the counter's controls-battery leg delegates to the battery's
fixture/confinement controls only and never re-enters a counter; at 0 it delegates to
the full battery (which re-enters both counters). The bound is committed, named in
the counter's header and registry row; the run-64 controls battery carries a control
that reads `mismatch` when the bound is set to 0 and the tree is measured with a
240 s timeout (the refutation leg).

Commands:

```
bash plans/round-64-c2.sh [--tree DIR | revision]
C2_RECURSION_BOUND=0 bash plans/round-64-c2.sh --tree DIR      # must not terminate in 240 s
bash plans/round-64-controls.sh [candidate tree DIR]
```

Output line: `C2_REFUSAL: killed=K population=5 guard=G (l1=… l2=… l3=… l4=… l6=… selftest=… real=… terminates=… bound=…)`.
Exit 0 iff guard=1 and killed=5 and terminates=1; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a tree byte-identical to BASE must read `terminates=0` (the bound is absent, so
  the run does not produce its verdict line); a tree that terminates at BASE is
  vacuous and voids the claim.
- K2: with `C2_RECURSION_BOUND=0` the candidate must NOT terminate inside 240 s
  (guard leg b); a bound that cannot fail is decorative.
- K3: each of the five legs must still fire individually on the candidate (guard
  leg c); a leg dropped by the bound voids the claim.
- K4: the real trial must still read `value=5 shims=5 vectors=ok/5` (the round-63
  counter's guard leg c, now inside this counter's guard b via (a)).
- K5: the battery's existing controls must still match with 0 skips (guard leg d).

**Population census at BASE (measured, not assumed):** at BASE the round-63 counter
reads `rc=124` (no verdict line) at 900 s and 1500 s — committed receipt
`.ufo/waves/round-63/final/c2-refusal.txt` (7 bytes) — and the L1 re-measures it at
BASE with `timeout 240 bash plans/round-63-c2.sh --tree .` rc=124. Measured at
`.ufo/waves/round-64/base/c2-e2e-head.txt`.

**Named ceilings:** `terminates=1` is a termination claim, not a correctness claim about
the number 5 (the five legs are round-63's, unchanged; a leg that fires for the wrong
reason still counts — the guard legs (a)/(d) and the leg-by-leg firing are the only
witnesses). The bound is an environment flag, not a proof: `C2_RECURSION_BOUND=0`
re-enters by construction, and a caller who sets it to 0 gets the old behaviour.

## Frontier step

Candidate sources to open this round (at least three opened, at least one admitted,
at least one rejected, each with a ≤25-word located quote and an access date):

1. The `equivalent mutant` second attestation behind the C2 kill contract — the
   mutation-testing survey behind S137/S139/S140 (a second peer-reviewed statement,
   e.g. the Mutation Testing book chapter or the PIT/Stryker docs' own definition
   pages) grounding the knowledge entry this round adds.
2. The BioC/ConText deposit behind S135/S143 re-opened on the *current* endpoint
   (freshness item 3 of the round-63 plan): the pseudo-trigger/termination-term
   classes re-verified against the served deposit; if the XML shape changed, the
   superseding row is a new row (`supersedes S143 —`) per CORPUS.md rule 2.
3. One weak lead (a vendor blog or a wiki page about mutation testing) as the reject.
4. OpenBao's own mutation-test or equivalent-mutant statement if one exists (the
   `equivalent mutant` ground in the lane's own domain).

The C1 claim's evidence cites the admitted row (the held-out shape classes); the
knowledge entry and the lesson's Gate carry the `S###` ids.

## Routed defects (round-63 spot-check §6) — work items, not a claim

- **D-63-1** the lookup-table guard vacuum (the A4 vehicle reaches the verdict on the
  committed tables): C1's guard leg (e) re-runs the vehicle against the new held-out
  set; leg `d1` of `plans/round-64-routed.sh` requires it.
- **D-63-2** the C2 nested-battery recursion: the run-64 counter's recursion bound is
  the landing; leg `d2` requires the single end-to-end line.
- **D-63-3** carried (all landed, nothing open): leg `d3` records the disposition.

## considerthese

No still-unimplemented proposal is mined this round: the latest file
(`considerthese/2026-10-26.md`) proposal 3 was mined in round 63 (landed as QM83/QM84;
M63-5). Recording it as a sentence in the report, not amending anything.

## Wave

`kagi-r64-w1`, 16 seats v1 (band 8–16; `.ufo/waves/round-64/w1-dispatch.json`; reports
`.ufo/waves/round-64/w1/`): 2 scout, 5 executor, 2 scribe, 1 reviewer, 1 critic,
2 mutation-tester, 1 connector, 1 sentinel, 1 revenger. Attack share 4/16 = 25 %
on the addendum's literal list (reviewer, critic, mutation-tester ×2; no labrat seat
exists), 5/16 = 31.25 % counting the sentinel. The L1 holds the canonical planner
seat and is the sole integration owner and committer.

## Amendment A1 — 2026-11-08, before the wave (L1 re-measurement of the held-out
population)

The pre-amendment census ("F1..F10 accepted, P1..P6 rejected, B3..B5 controls")
was wrong for 10 of 19 rows (L1 slim-tree re-measurement at extracted
`09cbee8`, `.ufo/waves/round-64/base/census-a1.md`): F1/F5/F9 and B3 are
already rejected at BASE (swapped percentages, direct negation, swapped
fraction); F3/F4 are accepted correctly at BASE (hedge, idiom); P1/P2/P3/P5
are accepted at BASE already; P4 is an unmeasured slim-tree artifact and is
excluded from H/Q; B4 is accepted at BASE (negated subject) so it cannot be a
control. The amended table keeps the 19 rows byte-identical, removes the
unfinished `?` marker, adds P7 (parenthetical between subject and pair; counted
BASE-rejected at mechanism level and re-derived by the commit-time counter
run), and reseals at
`b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`; the
superseded sha `7ed354918ca6c635…` is retained in `census-a1.md` for audit.

The guard (a)-(e), target (`heldout=0`), POP (8) and output line are unchanged.
Only the enumeration (H1..H5 = F2,F6,F8,F10,B4; Q1..Q3 = P6,B5,P7) is restated
in the predicate sentence itself; each H fixture must read accepted at BASE
and rejected on the hardened checker, each Q fixture the reverse. Six fixes
are the reachable set (falsifiable against the amended census): F2 denial
after pair (I7 pair assertion), F6 duplicated mechanism (I5 single-occurrence
rule), F8 quoted denial (I4 `NO_NEW` assertion), F10 unbound duplicate pair
(I7 every-pair-bound rule), B4 negated subject (subject-negatedness guard),
P6/P7 binding window (parenthetical / em-dash masking) and B5 idiom class
(`not less than`). F7 carries no polarity hook and is a named ceiling, not a
fix target.

## Bounds

- The two counters are the verdicts; this plan's BASE census is the L1's own measurement
  (`.ufo/waves/round-64/base/`, committed) and is re-derived by the committed counters.
- The held-out table is sealed at predeclaration; a seat that reads it must disclose it.
- A counter whose fixtures tree-copy cost exceeds its budget reads SETUP, never a pass.
