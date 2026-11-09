# R69ExecCounterC2 — C2_TEETH counter report (kagi round 69, attempt 2)

Seat: executor, sole writer of `plans/round-69-c2.sh`. Judged on operability.
Receipts: `.ufo/waves/round-69/w1/R69ExecCounterC2/` (selftest.txt, run-base.txt,
run-candidate.txt, single-row-verify.txt, true-command-verify.txt, notes.md).

## Result

The counter is built to §C2 and runs end to end. It does not read the target at the measured bytes:

- BASE control (`run-base.txt`): `C2_TEETH: subfloor=0 ledger=0 guard=0`, rc 1. The no-work control holds.
- Candidate (`run-candidate.txt`, mid-edit tree): `C2_TEETH: subfloor=0 ledger=0 guard=0`, rc 1.
  Target was `subfloor=1 ledger=1 guard=1`.
- Selftest: `C2_TEETH_SELFTEST: PASS (20 cases)`, rc 0.

Two of the frozen legs cannot read 1 as written. Both are blockers for the L1, not something this
seat can fix without amending the frozen plan.

## Blockers (frozen spec, measured)

1. **ledger (a) is unreachable with a single-row ledger.** `claim-ledger.sh verify` exits 1 on
   any `unresolved_ids > 0` (`corpus/claim-ledger.sh`, the `IDX_MISSING` test before the CLEAN line).
   A single-row ledger leaves 1660 cited R-ids unresolved on BASE. Control receipt
   `single-row-verify.txt`: a row that passes (`failed=0 stale=0 missing=0`) still exits 1 with
   `unresolved_ids=1660`. Leg (a) cannot print `CLAIM_LEDGER: CLEAN` under this design.
2. **ledger (b) cannot print `FAIL R68-02`.** The frozen replacement command `true` is refused by the
   allowlist (`ALLOWED_RE='^(bash|grep|sha256sum|wc|test|python3)$'`): `POLICY R68-02 reason=first-token:true`,
   exit 2 (`true-command-verify.txt`). Only an allowlisted failing no-op (e.g. `test 1 = 0`) reaches the
   FAIL path. Not substituted: the spec says `true`.

Ruling needed from the L1: amend §C2's ledger leg (a) and (b) in a journaled plan amendment, or
accept ledger=0 as the round's honest reading.

## Other judgment calls (see notes.md)

- **subfloor (b) wording.** Plan prose says "strictly greater"; the parenthetical says
  `N_cand = N_base + 1`. The counter implements the parenthetical. The candidate C1 selftest reads 62
  against BASE 59 (+3: `predicate-subfloor`, `predicate-floor-edge`, `predicate-floor-col15`, from
  `git diff 264917aa -- plans/round-68-c1.sh`). Under the prose reading b would be 1. L1 ruling needed.
- **guard (c)** is built from the BASE predicate body. On the candidate's fixed body, a comment-only copy
  would read subfloor=1 and guard (c) could never be 1.
- **Stamped reduced ledger.** `corpus/stamps.tsv` pins `claim-ledger.tsv`, so the reduced scratch reads
  STALE on its own pin. The scratch stamp row is re-pinned to the bytes it runs. Scratch only, disclosed.

## Attack-style findings (for claim-falsification.tsv; each with exact command and output)

- `bash plans/round-69-c2.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin --base-tree <BASE> --scratch <S> --verbose`
  → `LEG subfloor tree=cand a=1 b=0 c=1 subfloor=0`; `LEG ledger tree=cand a=0 b=0 c=1 d=1 ledger=0`.
- `grep -c ... ` control on reduced ledger → `CLAIM_LEDGER: FAIL (claims=1 failed=0 deferred=0 stamped=168 stale=0 missing=0 unresolved_ids=1660 labeled_ids=173 host_skipped=0)` rc=1.
- `true` row → `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` rc=2.
- Frozen tuples do not witness col15: a predicate with only `verified >= 37` passes all six frozen
  tuples (python exec, output `True`), and accepts `(37,31,6,1,0)` (output `True`). The col15 floor is
  witnessed only by the C1 selftest, not by the C2 subfloor leg.
- The candidate R68-02 row points at `plans/round-69-c1.sh`, which does not exist yet
  (`FAIL R68-02 reason=exit-mismatch exit=127`, candidate verify). Mid-flight, not final.

## Procedure

- Selftest and both measurement runs: `bash plans/round-69-c2.sh --selftest|--tree ... --verbose`,
  all reproducible from the receipts' headers.
- No commits, no mutating git or jj in the lane. Scratch under `${HYAKU_SCRATCH}/kagi-r69/R69ExecCounterC2/`,
  removed before yield.
- Tools: none installed or upgraded.

## Checks the main agent should run after integration

- `bash plans/round-69-c2.sh --selftest` (expect `C2_TEETH_SELFTEST: PASS (20 cases)`).
- `bash plans/round-69-c2.sh --tree <lane> --base-tree <BASE extraction>` once the R68-02 row and the
  C1 selftest count are settled; the verdict is whatever the counter prints.
