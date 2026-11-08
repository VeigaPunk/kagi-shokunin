# R67Critic — C2 attack (kagi round 67, w1)

Seat: critic (leaf). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
BASE `076701a11a58e3eb58d996b4c76c5e18071fb179`; frozen plan `aa8807e…`.
Read: `plans/round-67.md` §C2, `corpus/lessons/round-66-verifier-spotcheck.md`
§1–§6, `corpus/lessons/round-66.md`, `corpus/QUALITY.md` QM89–QM94,
`.ufo/waves/round-67/w1-spec.json`, and the landed `plans/round-67-c2.sh`
(untracked at review time, 37663 B, mtime 07:59). Every leg was re-derived from
committed bytes; the landed counter was run on BASE, on the candidate tree, and
on a falsified copy. Receipts: `w1/R67Critic/*.txt`.

## Verdict in one line

All seven legs are real mismatches at BASE and the do-nothing control holds
(measured: `mismatches=7`), but **L6 is content-blind: a candidate tree whose
`c3-base.txt` states a finding count the round-66 gate never produced still
reads `C2_FIDELITY: mismatches=0 population=7 guard=1`, exit 0.** The population
also omits two closure-named surfaces that the lane cannot write.

## Counterexample (landed code, not a hypothetical)

Landed L6 (`plans/round-67-c2.sh:328-359`) checks: receipt exists, non-empty,
header lines contain the base sha, the words "provenance" and "reconstruct", and
one line matching `^SOURCES_CENSUS: (FAILED|CLEAN)`. It never reads `findings=`,
the four `FINDING` ids, the `C3_CENSUS:` line, and never re-derives.

```
$ cp <candidate tree> <stubtree>
$ sed -i 's/^SOURCES_CENSUS: FAILED (findings=4 rows=155)$/SOURCES_CENSUS: CLEAN (findings=0)/' \
    <stubtree>/.ufo/waves/round-66/final/c3-base.txt
$ bash plans/round-67-c2.sh --tree <stubtree> --scratch <scratch>
LEG L6 verdict=ok receipt=present header_lines=8 base=d549ee6eb877 \
    gate='SOURCES_CENSUS: CLEAN (findings=0)'
C2_FIDELITY: mismatches=0 population=7 guard=1        # exit 0
```

The lie is impossible on the named revision: the round-66 counter re-runs today
on a `d549ee6` extraction and prints
`C3_CENSUS: findings=4 rows=155 guard=1` (exit 1), and the lane gate prints
`SOURCES_CENSUS: FAILED (findings=4 rows=155)` (`w1/R67Critic/l6-rerun.txt` §3).
The landed `--selftest` (22 cases) plants two L6 fixtures — `header-sha-drift`
and `gate-line-absent` — both absence/shape mutants, so a **content lie is not
planted and survives guard (b)**. This is the frozen guard (c) unmet ("each
re-derives from committed bytes (a gate output, a file's contents or a referenced
path)"): the leg re-derives from a header, not from the gate output the receipt
is cited for.

Today's committed-tree artifact is one step short even without the lie: the
in-flight `c3-base.txt` (sha256 `8365a4e7…`) carries only
`SOURCES_CENSUS: FAILED (findings=4 rows=155)` — **no `C3_CENSUS:` line** — while
the round-66 report and SCORECARD cite the path as the C3 BASE receipt.

Transcripts: `landed-counter-runs.txt` (BASE / candidate / stub),
`l6-rerun.txt` (the live re-derivation, hermeticity caveat).

## Per-leg re-derivation at BASE

All seven are **real mismatches** on committed bytes; none is a preference, none
reads `ok` as a do-nothing control. Transcript: `base-seven-defects.txt`.

| leg | BASE defect (re-derived) | only repair? | landed check closes the trap? |
|---|---|---|---|
| L1 | `SCORECARD.md:2339` cell `gate=A claims=3 rows=R attack_seats=K guard=G` + "reads `pass`"; cited `c2-candidate.txt` reads `gate=0 claims=0 rows=0 attack_seats=0 guard=0`, `SETUP findings=1` | yes — cell restated from the receipt it cites | yes: parses the cited path, whitelists it to `round-66/final/*c2*.txt`, compares the cell's first verdict token to the receipt's line and requires the gate-out sentence in the cell. (The correction marker "corrected in round 67" is present but not required — see corrections.) |
| L2 | `SKILL.md:893` pins `cases=14`; `plans/round-66-c1.sh --selftest` ⇒ `cases=45 failed=0` | yes — pin the measured tally | yes: one row must contain `plans/round-66-c1.sh` and the exact string `cases=45 failed=0`, and the instrument is run from `$TREE` (closes the AppRole-row trap where `cases=45` already exists at BASE; closes M66-9 scope by running `$TREE/plans/round-66-c1.sh`). |
| L3 | `corpus/README.md` has 0 `carrier` rows; entry file present | yes — add the row | mostly: requires the entry file and a row containing the basename with ≥3 cells, but does not verify the basename sits in the row's `Entry` column. Same landing adds a second row (`knowledge/source-capture-binding.md`) whose file is absent until the L1 lands it — the leg only checks the carrier entry, so a dangling second row is unread. |
| L4 | ledger has 9 rows, 0 `R66Sentinel`; gate rule `attack-seat-unread` | yes — add the row | mostly: requires exactly one row, ≥5 TAB columns, claim id present in the ledger, class `neutral`, detail ≥40 chars, and `R66Sentinel.md` on disk. Does not require the wording to name V-1/V-2 (a 40-char detail passes any claim). |
| L5 | `claims.json` has 0 `C2_PREFILE`/`C3_CENSUS`, 2 stale ids | yes — ids/targets from the A2/A3 restatements | yes: derives the *last* `C<n>_TOKEN` per claim from the plan (the restated one) and forbids the superseded tokens in `claims.json`; closes the trap that the amended plan retains the withdrawn text (`C2_CLAIMS` ×4, `exact=1` ×6, `C3_SELFREF` ×3). |
| L6 | path in no commit (`git ls-tree` ⇒ 0; `git log --all -- path` ⇒ 0 commits) | only a committed file reaches ok — content not forced | **no — see counterexample.** |
| L7 | `corpus/lessons/round-66.md` has one `used-by` mention (line 28), 0 `S113`, no old→new table | yes — append the mapping to the defective file | yes: parses the corrigendum table, derives the pairs from `git show d549ee6:corpus/SOURCES.md` vs the round-67 BASE (`076701a`), and compares each old/new token list; refuses a wrong old value. Fallback only when the tree is not a git repo. |

Candidate reading after the in-flight repairs (lane working tree):
`C2_FIDELITY: mismatches=0 population=7 guard=1` rc 0 — leg details in
`landed-counter-runs.txt` §2. This is the state the L1 intends to commit; the
reading is attributable to the repairs, not to the counter being lenient
(BASE reads 7).

## Predicate as a whole

### (a) Reachable by doing nothing?
No — measured. `--tree <BASE extraction>` ⇒
`C2_FIDELITY: mismatches=7 population=7 guard=1` rc 1 (`landed-counter-runs.txt`
§1). Caveat: `--tree <BASE>` must be a materialized extraction; the lane working
tree carries all seven repairs, so a run without `--tree` tests the candidate.
The counter's guard (a) itself compares `base_defects=7`, so this control is
machine-checked, not just read.

### (b) Population closed?
**No.** The closure routed nine items; C2 covers §6.1, §6.2, §6.3, §6.6, §6.7
(split across seven legs). **§6.4 (report `LOG.md` bullet pointers, uncited
commits, "across the four commits") and §6.5 (post-integration controls-battery
receipt) have no leg**, and both are live:

```
grep -c '8bd920d\|d89e01d' .ufo/reports/round-66/kagi.md   ⇒ 0
round-66 LOG entry top-level bullets                        ⇒ 10  (pointers reach 16)
CONTROLS: match=8 mismatch=2 / match=8 mismatch=1           (no mismatch=0 receipt)
```

They are not repairable from this lane: the round-66 report is a fleet-root file
(`ls kagi-shokunin/.ufo/reports/` ⇒ `round-20` only; no `round-66/`). So the
predicate can read 0 while two closure-named record surfaces still misstate
their state, and the C2 title ("the lane's record surfaces match the state they
describe") is wider than `population=7`. Receipt: `population-gap.txt`.

Related, not closure-named: the lane's own self-count pins are stale at BASE —
`SELF_COUNTS: POLICY … stale=6`, naming `SKILL.md:46` ×2, `PROVINCE.md:73` ×2,
`corpus/README.md:64-65` ×2 (`self-counts.txt`). The in-flight repair updates
them to 99/163/44/47, but **the round's own landing adds one knowledge entry and
its stamp, which moves the docs/stamps counts again** — pins set before that
landing will be stale at integration. Not a leg gap (the closure did not route
them); it is calibration debt to name, and the L1's integration gate will show it.

### (c) Coupling to C1?
No semantic dependency: no leg reads `corpus/sources-census.sh`,
`corpus/source-fetches.tsv` or `corpus/knowledge/source-capture-binding.md`.
Couplings are write/scratch only (`coupling.txt`): SKILL.md (L2 + C1 pins, two
writers unnamed by the plan), `corpus/README.md` (L3 + Scribe's two rows, one for
a file not yet on disk), and `plans/round-66-c1.sh`'s fixed scratch root
`${HYAKU_SCRATCH}/kagi-r66/C1Counter` — the counter invokes it without
`--scratch` (`plans/round-67-c2.sh:196` runs `bash <inst> --selftest`), so two
concurrent C2 runs share it. L6's counter re-run is not hermetic w.r.t. guard
(d): a scratch fleet root prints `fleet no-line`, `guard=0`; only the real fleet
yields `guard=1` (`l6-rerun.txt` §5).

### (d) Guard (b)/(c) enforcement
Guard (b) plants two fixtures per leg (22 cases) and guard (a) proves all seven
are discriminative at BASE. The surviving class is the **content lie**: no
fixture plants a plausible-but-false value in a surface the leg only checks for
shape. L6 is the demonstrated instance; the same class could hide in L3's row
column placement and L4's "naming what it confirms". No seat mutation-tests the
C2 counter: `R67MutGate` attacks the census gate (M1–M5), `R67Revenger` the
census bypasses — unlike C1's `caught=6/6`, C2 has no adversarial mutation seat.

Smaller in-flight defects in the repairs themselves:
- The round-66 corrigendum says "The seven `used-by` cells **changed**"; the diff
  shows **six changed cells + one row added** (S164's cell first appeared). The
  pairs are right (`used-by-pairs.txt`); the sentence is number-drift inside the
  artifact that repairs number-drift.
- S152's pair is `—` → `—, corpus/knowledge/claim-instrument-carrier-binding.md`
  (round-66 landing): the cell now holds a non-path placeholder plus a path. The
  corrigendum records it faithfully; no C2 leg covers the malformed cell. Name
  it as unabsorbed; do **not** add it to C2 (a new repair changes the target).
- The corrigendum exists in `corpus/lessons/round-66.md` (L1) while
  R67ScribeLesson's prompt puts the same table in `corpus/lessons/round-67.md`.
  One authority: the round-66 file; the round-67 file may only point at it.

## Impacted axes

- **calibration** (primary): C2 is the axis move; the L6 content lie lets the
  predicate read 0 on a false record, and the two-leg population gap leaves
  closure-named surfaces unrepaired. The self-count re-staleness is the round's
  own landing hazard.
- **freshness** (secondary): C1's evidence chain is untouched; L6 is the C3
  record, so the defect does not move freshness but poisons calibration.
- **operability**: not implicated.

## Smallest safe corrections

1. **L6 (no predicate/counter-interface/kill/target change).** In `leg6`, after
   the header checks: require a `C3_CENSUS:` line; require the four `FINDING`
   ids; re-run `$TREE/plans/round-66-c3.sh` on a `d549ee6` extraction (or run
   `$TREE/corpus/sources-census.sh` on it) and require the receipt's
   `findings=`/`rows=` to equal the fresh output; keep the header requirements.
   Add two selftest fixtures: a false `findings=` and a removed `FINDING` line —
   both must read `defect`. This is the frozen guard (c), already required.
2. **Population scope — file as an amendment before candidate readings**
   (A1-style; changes no predicate, counter, kill rule or target):
   > Population scope: the seven legs are the round-66 closure's lane-writable
   > record surfaces (§6.1, §6.2, §6.3, §6.6, §6.7). §6.4 and §6.5 live in
   > `.ufo/reports/round-66/kagi.md`, a fleet-root file outside this lane's
   > write scope (`kagi-shokunin/.ufo/reports/round-66` does not exist); they
   > are named as routed to the operator and are not claimed by
   > `C2_FIDELITY`. The lane's six stale self-count pins are likewise outside
   > this population and are named as debt.
3. **L3/L4 tightening (same leg, no new leg).** L3: resolve the row's `Entry`
   column to the entry path (not just any cell); L4: require the detail to name
   V-1 and V-2. Both read `defect` at BASE unchanged (no row / no sentinel row),
   so the target is untouched.
4. **Mutation owner for C2 (wave scope, no new seat).** Extend `R67MutGate` (or
   the critic's post-landing read) with M-C2-1…7: replace each leg's derivation
   with a constant `ok`, and inject the content lies (L6 false `findings=`, L5
   right ids/wrong target, L7 six right pairs + one wrong old). Only C1 has a
   mutation seat today.
5. **L1 integration:** one commit per shared file (SKILL.md: apply both cells;
   corpus/README.md: land the round-67 row **with** the entry file); pass
   `--scratch` when the counter invokes `plans/round-66-c1.sh`; re-run
   `python3 corpus/self-counts.py` **after** the new entry and stamp land and set
   the pins to the final live numbers; require L1's correction marker in the
   SCORECARD cell.
6. **L7 wording:** "seven `used-by` cells changed" → "six cells changed and one
   appeared with the added S164 row".

Dead ends / not performed: I did not execute sibling gates; I did not edit any
lane record; the candidate reading was taken on the working tree mid-flight, so
the committing L1 must re-run it after the final edits. No claim is made beyond
the runs in `w1/R67Critic/`.
