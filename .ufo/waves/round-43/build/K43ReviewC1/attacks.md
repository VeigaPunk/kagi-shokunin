# K43ReviewC1 — pre-measurement attacks on claim C1 (round 43)

Sandbox: `S=/fast/scratch/hyaku/kagi-r43/K43ReviewC1`, clone `git clone --shared
/home/vgpnk/Projects/shokunin/kagi-shokunin $S/work` at `dd6ccb92bf04a061e9f1e66913d15f097397b1b3`
(A1), `git -C $S/work rev-parse --show-toplevel` = `$S/work` (verified before any write). The lane
was never edited; all git calls against the lane are read-only (`git -C … show/diff/log/ls-tree/cat-file`).
All counter runs exited rc=0 and printed one unsigned integer; receipts under `receipts/` beside this
file; drivers and the four fixture gates under `scripts/` (the gates are byte-replicas of
`plans/round-43-controls.sh` `mk_keyed` + its two python p0-branch patches). Committed controls
(`.ufo/waves/round-43/controls/`, `measured-at.txt` = `5f3566c…`) were read and match the frozen
matrix; my C1 re-derivation below is at `dd6ccb9` and matches every C1 row.

## Attack 1 — six-key answer-key gate vs the new counter (prediction: 6)

**Claim.** plans/round-43.md §C1 declares "a gate keying all six answers plus P0 acceptance still
passes (the answer-key class at population 6)" as a surviving ceiling. Build that exact shape and
run `EXPECT_JOURNAL=<it> bash plans/round-43-c1.sh` in a sandbox clone at dd6ccb9; the prediction is
N = 6.

**Command.** `scripts/drive.sh` builds `my6.sh` (basename-keyed: `p0-ledger.tsv` → `EXPECT_JOURNAL:
CLEAN (changed=0 journaled=0)` rc 0; `f1-ledger.tsv`→`REFUSE UNJOURNALED R13-01` … `f6-ledger.tsv`→
`REFUSE DELETED R11-03` rc 1; default accept), then:
`env EXPECT_JOURNAL=$S/my6.sh bash $S/work/plans/round-43-c1.sh`
Honest-matrix re-derivation on the same clone (freshness check vs committed controls):
`EXPECT_JOURNAL=<real|K1|K3|fakeC> bash $S/work/plans/round-43-c1.sh` where real =
`$S/work/corpus/expect-journal.sh`.

**Output** (rc=0, value=): base-real **6**, base-K1 **0**, base-K3 **0**, base-fakeC **5**,
base-my6 **6**; blankets base-refuseall **0**, base-acceptall **0** (receipts
`c1-base-*.txt`). Identical to committed `c1-new-real/K1/K3/fakeC` = 6/0/0/5 and blankets 0/0
measured at 5f3566c.

**Verdict: NOT-DEFECT (prediction confirmed).** The 6-key answer-key gate reads the target 6 —
the named ceiling survives exactly as the plan predicts; fakeC (5 keys) is rejected at 5 < 6 on the
same run set. This is the declared, routed ceiling (Routed 6), not a defect of the claim.

## Attack 2 — is F6's id choice (R11-03) special in a way that weakens the claim?

**Claim.** F6 = P0 ledger with row `R11-03` deleted, journal unchanged. Precondition check: R11-03
present in base 6cc8850 and P0 6f1588c, absent from the round-40 journal, and the round-41 journal
does not mention it. R11-03's ledger command is `bash corpus/surface-census.sh --selftest` — does an
id pinned by a ledger expectation row make F6 special?

**Commands.**
`git -C <lane> show 6cc8850…:corpus/claim-ledger.tsv | grep -c '^R11-03'` (and 6f1588c, HEAD);
`git -C <lane> show 6f1588c…:.ufo/waves/round-40/expectation-migrations.json | grep -c R11-03` (and
HEAD's `.ufo/waves/round-41/expectation-migrations.json`); migration-id listing via python json;
eligible-id census (`scripts/evidence.sh`).

**Output.** Row counts 1 / 1 / 1 (base, P0, HEAD); row at both revs: `R11-03 → bash corpus/
surface-census.sh --selftest → ^SELFTEST: PASS \(16 cases\)` (command and expect identical at base
and HEAD). Literal `R11-03` occurrences: round-40 journal **0**, round-41 journal **0**. Migration
ids of both journals = [R13-01, R21-02, R24-06, R31-02, R33-02, R34-03] — R11-03 in neither. Ids
satisfying F6's exact preconditions (in base ∧ in P0 ∧ unjournaled in both journals ∧ not an
F1–F5 id): **79**, R11-03 among them.

**Verdict: NOT-DEFECT — the choice is arbitrary, not special.** The gate's `DELETED <ID>` class is
unconditional over base ids and never reads the command or expect cells
(`corpus/expect-journal.sh` python: `for rid in base_order: if rid not in cand_rows:
refuses.add(("DELETED", rid))`); the counter never executes commands; the fixture journals directory
holds only the round-40 journal. R11-03's expectation row matters only to C3 kill rule (c), which
re-runs `bash corpus/surface-census.sh --selftest` against the LANE tree — disjoint from the F6
scratch fixture. Any of the 79 eligible ids yields an equivalent forgery; F6's discriminating power
against basename-keyed answer gates comes from the new fixture basename (`f6-ledger.tsv`) plus a
token id distinct from F5's `R17-02`.

## Attack 3 — counter mutations outside the frozen battery (m3/m5)

**Claim.** The frozen battery covers guard-drop (m3) and token-drop (m5) only; find ≥2 OTHER trivial
counter mutations, measure each against the real gate and K1/K3/fakeC (+ my6, blankets, frozen-mutant
composites), and classify survivors as ceilings.

**Commands.** `scripts/drive.sh`, `drive2.sh`, `drive3.sh` apply single replacements to byte-copies
`$S/work/plans/mut-*.sh` and run each with `EXPECT_JOURNAL=<gate> bash <mutant>`. All rc=0.

**Output** (value=; honest counter row shown for reference):

| mutant (one-byte-class change) | real | K1 | K3 | fakeC | my6 | refuse-all | accept-all | m3+K1 | m5+K3 |
|---|---|---|---|---|---|---|---|---|---|
| honest (base) | 6 | 0 | 0 | 5 | 6 | 0 | 0 | — | — |
| x1 `echo "$n"`→`echo 6` | 6 | 0 | 0 | **6** | 6 | 0 | **6** | 6 | 6 |
| x2 `n=$((n+1))`→`:` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | — | — |
| x3 guard `!= "0"`→`= "0"` | **0** | **6** | 0 | 0 | 0 | — | — | — | — |
| x5 `grep -qxF`→`grep -q` | 6 | 0 | 0 | 5 | 6 | 0 | 0 | 6 | 6 |
| x9 missing-gate `echo 0`→`echo 6` | 6 | 0 | 0 | 5 | 6 | — | — | — | — |
| honest, gate MISSING | — | — | — | — | — | — | — | — | — → **0**; x9 → **6** |

Bold = drift from the honest/frozen reading. x1 composites (`c1-x1m3-K1`=6, `c1-x1m5-K3`=6) and x5
composites (`c1-x5m3-K1`=6, `c1-x5m5-K3`=6) hold their frozen values.

**Verdict: NOT-DEFECT — two survivors, both named ceilings, not defects.**
- **x5 (token-match loosened to substring)** is byte-blind to the ENTIRE frozen matrix including
  blankets and the m3/m5 composite receipts: kill rules (a)–(e) all still read their frozen values.
  Ceiling: the exact-line token match (`-qxF`) is unpinned by any control — the counter would count
  a refusal line merely *containing* the token. Widens the declared ceiling "the mutant battery
  covers the guard and token drops only".
- **x9 (missing-gate branch fail-open)** leaves the whole matrix unchanged because the matrix always
  supplies a gate; with no gate it prints the target 6 where the honest counter fail-closes to 0
  (`c1-base-missinggate`=0, `c1-x9-nogate6-missing`=6). Ceiling: the frozen predicate's
  "gate missing ⇒ N = 0" clause is never exercised by a control.
- The assignment's own example, x1 (`echo 6`), is **killed**: kill rule (b) requires
  `c1-new-fakeC = 5`, and x1+fakeC reads 6 ≠ 5 (the blanket-accept matrix receipt also drifts 0→6).
  x2 (dropped increment) is killed by (a) (0 ≠ 6 everywhere); x3 (inverted guard polarity) is killed
  by (a) (real 0) and (b) (K1 = 6 ≠ 0).

## Attack 4 — before-state immutability

**Claim.** Ledger ids at 6cc8850, 6f1588c and HEAD are identical (86 ids, none removed), and
`plans/round-42-c1.sh` is byte-unchanged since 5142b52.

**Commands / Output.**
- `git -C <lane> show <rev>:corpus/claim-ledger.tsv | cut -f1 | grep -v '^#' | grep -v '^$' | sort`
  per rev → **86 / 86 / 86** ids; `diff` of the sorted sets: empty both ways
  (`receipts/ids-diff-6cc-6f1.txt`, `ids-diff-6cc-HEAD.txt` empty).
- `git -C <lane> diff --quiet 5142b52 HEAD -- plans/round-42-c1.sh; echo $?` → **rc=1** — but
  5142b52 is the round-41 predeclaration and the file does not exist there
  (`git log --oneline 5142b52..HEAD -- plans/round-42-c1.sh` → only `98dd4de` "round-42:
  predeclaration", +140 = creation). From its true anchor: `diff --quiet 98dd4de HEAD` → **rc=0**,
  0 touching commits, blob sha `068a0b2773b2774d7ecbeeeaab4c3eabd0f7ae99` identical at 98dd4de and
  HEAD; `diff --quiet 98dd4de 5f3566c` rc=0 and `diff --quiet 5f3566c HEAD` rc=0.
- Supporting: `diff --quiet 5f3566c HEAD -- corpus/expect-journal.sh` rc=0 (C1 kill clause (d)
  holds); `git cat-file -e 5f3566c:plans/round-43-c1.sh` rc=128 (counter absent at BASE — no-work
  control holds).

**Verdict: NOT-DEFECT, one measurement note.** The immutability property holds on every rev that
contains the file: the round-42 instrument bytes never moved since their predeclaration commit. The
assignment's `5142b52` predates the file's existence, so the literal command returns rc=1 for ANY
state (absent-path diff, not a content change) — a rev mis-specification in the assignment, not lane
drift. The correct byte-freeze anchors are 98dd4de (creation) and 5f3566c (round-42 tip); both clean.

## Attack 5 — axis fit: is "C1 refuses three broken-instrument shapes" calibration?

**Claim.** C1 is filed under the calibration axis. Fit test: is the moved quantity a property of the
instrument's own discrimination, or of something else (lane state, time/revision, host operations)?

**Evidence.** (i) The measured object is the gate+counter pair against synthetic fixtures built in
scratch from committed bytes (P0, F1–F6); the lane ledger is bit-identical across the round (Attack
4: 86 ids, no removals, gate bytes frozen rc=0) — no lane property moves. (ii) The moved readings are
negative-control rows: K1/K3/blankets hold 0, m3/m5 exposed at 6, fakeC rejected 5 < 6 — 0/3 → 3/3
broken-shape rejection is a sensitivity/specificity statement about the instrument itself. (iii) The
real-gate move 5 → 6 is the instrument's forgery-population coverage point (the population
definition grew by F6), not a change in the measured system. (iv) The neighbor axes are disjoint:
freshness = committed receipts re-derive at the revisions they name (C2's shape); operability =
where instruments write (C3's scratch discipline). Neither describes a refusal-class matrix.

**Verdict: NOT-DEFECT — calibration fit confirmed.** The claim improves the instrument's
discrimination of its own no-work/broken classes, which is the calibration axis by this fleet's
frozen definitions; the population growth is the calibration probe, not a freshness event.

## Residual risk and verification gaps

- The 6-key ceiling (Attack 1) stands: admission cannot distinguish the honest gate from a
  basename-keyed 6-key gate — declared ceiling, routed item 6, open by design.
- x5 and x9 (Attack 3) are concrete trivial mutants that pass every frozen kill rule; a future
  battery could add a token-mode probe and a missing-gate probe to close them.
- Blanket receipts are frozen-matrix rows but absent from kill-rule letters (a)–(e); x1 was caught
  via fakeC ≠ 5, so no practical admission gap was exercised this round.
- I did not re-run `plans/round-43-controls.sh` end-to-end (host-heavy; not named by my items);
  committed controls were verified by value and my independent C1 re-derivation at dd6ccb9 matches
  every C1 row measured at 5f3566c. C2/C3 receipts were not re-measured (outside seat scope).
