# R69ExecCounterC2 — notes (C2_TEETH counter, plans/round-69-c2.sh)

Sole writer: `plans/round-69-c2.sh`. Receipts here are copies of stdout from that counter
(or of single manual commands whose exact command is named in each file). Scratch lived under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r69/R69ExecCounterC2/` and is removed before yield.

## Verdicts at the measured bytes (this session)

- `selftest.txt`: `C2_TEETH_SELFTEST: PASS (20 cases)`, rc 0.
- `run-base.txt` (tree = BASE extraction `git archive 264917aa…`): last line
  `C2_TEETH: subfloor=0 ledger=0 guard=0`, rc 1. Expected `subfloor=0 ledger=0`: met.
  The guard-b control holds (BASE reads 0/0). guard-d = 1 (20 cases ≥ 10); guard-c = 1 (comment-only copy of BASE reads subfloor=0).
- `run-candidate.txt` (tree = lane working tree at measurement time): last line
  `C2_TEETH: subfloor=0 ledger=0 guard=0`, rc 1. Not the target `subfloor=1 ledger=1 guard=1`.
  The tree was mid-edit by sibling seats (see below), so this is a reading, not a final candidate.

## Leg-level readings (candidate, from run-candidate.txt)

- subfloor a = 1: the candidate `predicate_ok` now refuses (36,31,6,1,0) and accepts the frozen
  floor tuples and refuses the three negatives (all six `ok`).
- subfloor b = 0: candidate C1 selftest = 62 cases, BASE = 59. Frozen rule needs `N_cand = N_base + 1` = 60.
  The +3 is `predicate-subfloor`, `predicate-floor-edge`, `predicate-floor-col15`, all added in
  `plans/round-68-c1.sh` (`git diff 264917aa -- plans/round-68-c1.sh`, read-only).
- subfloor c = 1: BASE predicate accepts (36,31,6,1,0) (blindness witness holds).
- ledger a = 0, b = 0: see `single-row-verify.txt` and `true-command-verify.txt`.
- ledger c = 1 on the candidate (`EXPECT_JOURNAL: CLEAN (changed=3 journaled=3)`), 0 on BASE (no
  round-69 journals directory in the BASE extraction, `expect-journal rc=2`).
- ledger d = 1 on both: R24-14 pins `count=101` on BASE and `count=103` on the candidate, and
  `row-identity.sh ledger-ids` matches the pinned expectation in both (parsed from the row).

## Structural findings (measured, frozen spec cannot read ledger=1 as written)

1. **ledger (a) is unreachable.** `claim-ledger.sh verify` exits 1 whenever `unresolved_ids > 0`
   (source: `corpus/claim-ledger.sh` ~line 1251, `IDX_MISSING > 0`), independent of rows. A
   single-row ledger leaves every other R-id cited in the corpus unresolved (1660 on BASE).
   `single-row-verify.txt` control: a passing row (`failed=0 stale=0 missing=0`) still exits 1 with
   `unresolved_ids=1660`.
2. **ledger (b) cannot produce `FAIL R68-02`.** The frozen replacement command `true` is refused
   by the gate's own allowlist (`ALLOWED_RE='^(bash|grep|sha256sum|wc|test|python3)$'`): exit 2,
   `POLICY R68-02 reason=first-token:true`. A frozen-but-allowlisted no-op (e.g. `test 1 = 0`) would
   reach the FAIL path, but the spec says `true`, so it is NOT substituted here.
3. **The reduced ledger is itself stamped.** `corpus/stamps.tsv` pins `corpus/claim-ledger.tsv`,
   so reducing it reads STALE on its own pin. The scratch copy re-pins its stamp row to the bytes it
   runs (`repin_ledger_stamp`). This is a scratch-only mechanic the spec did not name; it is disclosed.
4. **The R68-02 command nests the ledger.** BASE `bash plans/round-68-c2.sh` exits 2 under the
   reduced verify (`FAIL R68-02 reason=exit-mismatch exit=2`) because the nested verify is refused.
   Guard against counter self-recursion: env `R69_C2_NESTED=1` is set only for the scratch verify.

## Judgment calls (recorded so the L1 can overrule)

- **guard (c) reading.** "A comment-only copy ... above the unchanged predicate body" is built from
  the BASE predicate body. On the candidate's fixed body, the same comment would read subfloor=1 and
  guard (c) could never be 1. The header of `plans/round-69-c2.sh` states this.
- **subfloor b wording.** Plan prose says N is "strictly greater" than N_base; the parenthetical
  says `N_cand = N_base + 1`. The counter implements the parenthetical (as the assignment states).
  Under the prose reading b would be 1 on the candidate. The L1 must rule.
- **BASE default.** With no `--base-tree`, the counter extracts BASE with `git archive` from its own
  lane repo (asserted as the git toplevel). The receipts pass `--base-tree` explicitly.
- **Verbose verify lines** are capped (40) and limited to STALE/MISSING/NOT-A-FILE/FAIL/POLICY/
  CLAIM_LEDGER; `MISSING-ID` (1660 lines) is excluded from the log.

## Ceilings the counter does NOT cover (measured, not claimed)

- The frozen tuples do not witness the col15 floor: `verified >= 37` alone (no col15 clause)
  passes all six frozen tuples, and accepts `(37,31,6,1,0)`. Measured in this session (python exec of
  the stripped predicate, output "True/True"). The col15 floor is witnessed only by the C1 selftest case
  `predicate-floor-col15` (added by the executor seat), not by the C2 subfloor leg.
- The full 100-row ledger is never run (by design, per assignment).
- Candidate receipts reflect the working tree at measurement time; the R68-02 row was pointing at
  `plans/round-69-c1.sh` (not yet present, `exit=127`) and several stamped files were mid-edit (STALE),
  so the candidate ledger reading is a mid-flight reading.

## Tools

No tools installed or upgraded. Only `python3`, `bash`, `git`, `tar`, `sha256sum` (already present).
