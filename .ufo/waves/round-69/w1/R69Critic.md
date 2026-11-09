# R69Critic — falsification of C1_RECORD and C2_TEETH wording

Lane: kagi-shokunin. BASE 264917aa8fc9e71b6595d0d5166c4b615120fb8b. Frozen predeclaration plans/round-69.md and .ufo/waves/round-69/claims.json verified byte-identical to adb6972 (sha256 2473c7ac… and d785d202…). No production edits. No commits. Scratch removed; receipts copied to `.ufo/waves/round-69/w1/R69Critic/`.

## Scope limit (stated first)

`plans/round-69-c1.sh` and `plans/round-69-c2.sh` do not exist in the tree yet. The 13 C1 legs and the C2 legs are therefore reasoned from the frozen wording and falsified only where the existing instruments (`corpus/claim-ledger.sh`, `plans/round-68-c1.sh`, `corpus/expect-journal.sh`) already let me run the attack. Items marked **[unrun]** are derived from wording only and are not measured.

## Findings

Each finding: verdict, one-line reason, the narrowing it requires, and the observed evidence.

### C2 — `ledger` leg

**F-C2-1 — falsifies-wording: the `true`-command negative cannot produce a `FAIL R68-02` line.**
- Plan §C2 ledger (b) says: with `R68-02`'s command replaced by `true`, the gate "exits 1 with a `FAIL R68-02` line".
- Observed: the policy layer refuses `true` before execution. `policy_check` allows only `bash|grep|sha256sum|wc|test|python3` as first token (`corpus/claim-ledger.sh:272,285`).
- Output: `POLICY R68-02 reason=first-token:true`, `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)`, exit **2**. Receipt `.ufo/waves/round-69/w1/R69Critic/ledger1-true.out`.
- So the leg as worded can only pass on a refusal, not on the row's expectation being checked. The "row is executed, not text-matched" claim is not what this negative exercises.
- Narrowing required: the negative must use a policy-allowed failing command (e.g. `bash <scratch>/fail.sh` that exits 2 or prints a non-matching last line) and assert `FAIL R68-02 reason=exit-mismatch` or `…=expect-mismatch`, plus rc 1.

**F-C2-2 — falsifies-wording: the single-row scratch is not CLEAN in the form leg (a) names.**
- Plan (a) requires `corpus/claim-ledger.sh verify` to exit 0 with `CLAIM_LEDGER: CLEAN (claims=1` on the last line, on a scratch whose ledger holds only `R68-02`.
- Observed, unscoped (default docs set): `STALE corpus/claim-ledger.tsv sha=c5cd548f… lines=119->19`, then `FAIL R68-02 reason=exit-mismatch exit=2 want=0` (the BASE `bash plans/round-68-c2.sh` exits 2 in scratch), then 1,833 `MISSING-ID`/`LABELED-ID` lines, then `CLAIM_LEDGER: FAIL (… stale=1 … unresolved_ids=1660 …)`, rc 1. Receipts `ledger1-verify.out`, `ncount2.out`.
- Re-stamping the reduced ledger (`stamp --prune corpus/claim-ledger.tsv corpus/planted.sh`) clears STALE, but the verdict stays FAIL on the unscoped docs set (`unresolved_ids=1660`).
- With `--docs corpus/lessons/round-68.md` the verdict becomes `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=2 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)` rc 0 (`printfrow-docs.out`). That run used a `--docs` scope and a re-minted stamp the plan does not name.
- So "reducing the ledger to one row" changes the gate's semantics: it requires a restamp (a new revision pin for the scratch) and a docs-scope flag, and the `orphans=1` field reports the row as uncited. The plan's leg (a) text does not say any of this.
- Narrowing required: name the exact invocation (`--docs` set, stamp regeneration) and state that the reduced ledger's CLEAN is a scratch-only pin, not a property of the full ledger.

**F-C2-3 — falsifies-wording (or -number): the `R68-02` command repoint to a planted print passes L9 as worded.**
- Plan C1 L9 requires only: exactly one `R68-02` row, expect fully literal anchored, command exits 0 and last line matches expect, and a journal `old_expect`. It does not require the command to invoke the counter.
- Measured: the scratch row `R68-02 bash corpus/planted.sh` where `planted.sh` is `printf 'C2_RECORD: mismatches=0 population=3 guard=1\n'`, restamped and scoped with `--docs`, reads `CLAIM_LEDGER: CLEAN (claims=1 … failed=0 …)` rc 0 (`printfrow-docs.out`). The row executed and matched; the instrument behind it is a constant.
- This is the QM59/QM83-class do-nothing acceptance at the row level. Narrowing required: L9 must pin the command's first-token path to the registered counter (`bash plans/round-69-c2.sh`), plus a bytes check that the counter is not a printf (e.g. the row's expect must be unreachable by any file other than the counter's output, or the counter's selftest must be its guard).
- Caveat: the CLEAN above is only under `--docs`; unscoped the same row reads FAIL on unrelated MISSING-ID lines, so this is a row-level acceptance, not a whole-gate one.

**F-C2-4 — falsifies-number: `N_cand = N_base + 1` is not what the executor's landed bytes produce.**
- Plan C2 subfloor (b) requires the candidate selftest count to be `N_base + 1`, "derived by running both".
- Measured on the current working tree vs BASE:
  - BASE `bash plans/round-68-c1.sh --selftest` → `C1_VERIFIED_SELFTEST: PASS (59 cases)` rc 0 (`selftest-base.out`).
  - Working tree → `C1_VERIFIED_SELFTEST: PASS (62 cases)` rc 0 (`selftest-wt.out`).
  - Delta is **+3**, not +1. The three added names are `predicate-subfloor`, `predicate-floor-edge`, `predicate-floor-col15` (`diff` of `case("…"` lines).
- So subfloor (b) as worded reads 0 on the executor's current repair even though the sub-floor behaviour is correct. Either the leg is unsatisfiable as the executor implemented it, or the executor must delete two cases to hit +1.
- Composition attack [unrun, arithmetic only]: deleting two existing cases and adding three keeps `N_cand − N_base = 1` while removing coverage. The count is a header number, not a coverage measure; the leg cannot see which cases changed.
- Narrowing required: count the named cases (`predicate-subfloor` present AND its body calls `predicate_ok(36,31,6,1,0)`), and compare the set of BASE case names to the candidate set (superset), not the integer.

### C1 — wording (reasoned from the frozen text, mostly **[unrun]**)

**F-C1-1 — falsifies-wording: L8 requires a case *named* `predicate-subfloor`, not one that exercises the sub-floor vector.**
- Plan L8: "the selftest table carries a case named `predicate-subfloor`". The defect sentence (spotcheck §7 item 8) says the selftest "has no sub-floor case", i.e. one that runs the floor.
- Measured on the working tree: the name is present and the case is `case("predicate-subfloor", not predicate_ok(36, 31, 6, 1, 0))` (line in `plans/round-68-c1.sh`), so this specific instance is exercised. A tree with the literal string `predicate-subfloor` in a comment or a `case("predicate-subfloor", True)` passes the name test. [unrun for the mutant]
- Narrowing required: the leg must execute the extracted `predicate_ok` on the six vectors (the leg's own guard (c)/(d) is the place) and must not accept a name-only table entry.

**F-C1-2 — falsifies-wording: L9's execution clause does not bind the command to the counter (see F-C2-3).**
- Counted once here for C1 L9 because the leg lives in the C1 population.

**F-C1-3 — falsifies-wording: L10 requires both BASE readings as tokens, not as the row's headline reading.**
- Plan L10: the row "carries both BASE readings (`0/6` and `2/6`)". Token presence is satisfied by `caught=0/6 (2/6 under the frozen anchor)` or by a row whose headline stays `0/6` with `2/6` appended. The defect (spotcheck §7 item 10) asks for the repin of the readings, not a second token. [unrun; wording]
- Narrowing required: the row's headline (the first `caught=` reading) must be the receipt pair, and the 0/6 must be labelled as the counter-anchor reading.

**F-C1-4 — falsifies-wording: L11 counts ids, not criterion content.**
- Plan L11: "at least four criteria with id > QM96 whose source column names `corpus/lessons/round-68.md`". A row `QM97 | TBD | TBD | corpus/lessons/round-68.md` satisfies L2 and L11. The defect (§7 item 11) asks for criteria "each citing its lesson, per LEARNING.md §3", with weak-signal and teeth. [unrun; wording]
- Narrowing required: each new row carries a non-empty criterion, weak-signal and a red witness pointer, and the leg counts only rows with all four cells filled.

**F-C1-5 — falsifies-wording: L13 counts new files, not admitted entries on uncovered ground.**
- Plan L13: `new knowledge entries = files under corpus/knowledge/ (tree) − (base)`. The defect (§7 item 13) is that a widening of an existing entry is not expansion. A new file that duplicates an existing entry's ground still reads n=1. [unrun; wording]
- Narrowing required: the entry must carry a coverage-map row in `corpus/README.md` and a registry row with the new-ground reason (LEARNING.md observable), not a bare file count.

**F-C1-6 — falsifies-wording (minor): L12 "every seat entry has a terminal status" is vacuous for missing seats.**
- A `w1-results.json` that lists only settled seats, all with `failed`/`cancelled` terminal statuses, passes. The bijection between `swarm-registry.json` members and results entries is not required. (QM54-class.) [unrun; wording]
- Narrowing required: results entries must equal the registry member set (bijection), and each must carry a status in the QM47 vocabulary (`SEAT-STATUS: complete|partial …`).

**F-C1-7 — falsifies-wording (minor, cosmetic but a real mismatch): `claims.json` target strings do not match the frozen predicate's printed form.**
- `claims.json` (frozen at adb6972): `"target": "mismatches=0 population=13 GUARD=1 …"` and `"subfloor=1 ledger=1 GUARD=1 …"`. The frozen predicates are `guard=1` (lower case). The counters will print lowercase `guard=`. A reader who greps the printed line for the `claims.json` target gets no match.
- Measured: `grep -n 'GUARD' .ufo/waves/round-69/claims.json` returns the two uppercase targets. Narrowing: none needed for the counter (it prints the plan's form); the claims.json string is a wording defect in a frozen file and is reported, not amended (plan says never amend).

**F-C1-8 — no falsification found (recorded so the report is complete).**
- The spec and dispatch carry no literal verdict strings: `grep -c 'C1_RECORD:' .ufo/waves/round-69/w1-spec.json` → 0, `grep -c 'C2_TEETH:'` → 0, `mismatches=0`, `verified=37`, `36->`, `3->0` → 0. Placeholder notation `<colon>` is used. (The subset line `C1_RECORD_LEGS: legs=1,3 ok=2` appears only as a counter output spec, not a verdict.)
- `plans/round-68-c1.sh` diff vs BASE is the L8 change only (a dated `Amendment (round 69)` header, plus the `and verified >= 37 and col15 >= 32` term). The floors are the frozen ones.
- L7 (`claims.json` superseded_by naming A1 and 38/33, original `target` strings unchanged) matches the spotcheck item 7 repair as worded; no narrowing found.
- L2 at BASE: the derived set (QUALITY rows citing `round-68.md`) is empty, so the "names every id" clause is vacuous at BASE; the BASE failure comes from the "enter the bar" clause. This is a pass for the no-work control, not a hole.

## Summary table

| # | claim/leg | verdict | one-line reason | measured? |
|---|---|---|---|---|
| F-C2-1 | C2 ledger (b) | falsifies-wording | `true` is refused by policy (rc 2, POLICY), not a FAIL from the row | yes |
| F-C2-2 | C2 ledger (a) | falsifies-wording | reduced ledger is STALE/FAIL unscoped; CLEAN only with `--docs` and a restamp | yes |
| F-C2-3 | C1 L9 / C2 ledger | falsifies-wording | command not bound to the counter; printf row passes | yes (under --docs) |
| F-C2-4 | C2 subfloor (b) | falsifies-number | N_cand − N_base = +3 (62 vs 59) on the landed repair; plan says +1 | yes |
| F-C1-1 | C1 L8 | falsifies-wording | name-only case satisfies "carries a case named" | partly |
| F-C1-3 | C1 L10 | falsifies-wording | token presence, not headline reading | no |
| F-C1-4 | C1 L11 | falsifies-wording | id count, no criterion content | no |
| F-C1-5 | C1 L13 | falsifies-wording | file count, not admitted entry on new ground | no |
| F-C1-6 | C1 L12 | falsifies-wording | no seat bijection; partial results can read terminal | no |
| F-C1-7 | claims.json | falsifies-wording (cosmetic) | `GUARD=1` vs `guard=1` in frozen targets | yes (grep) |

## Commands and receipts

- `bash plans/round-68-c1.sh --selftest` (BASE extraction) → `C1_VERIFIED_SELFTEST: PASS (59 cases)` — `.ufo/waves/round-69/w1/R69Critic/selftest-base.out`
- `bash plans/round-68-c1.sh --selftest` (working tree) → `C1_VERIFIED_SELFTEST: PASS (62 cases)` — `.ufo/waves/round-69/w1/R69Critic/selftest-wt.out`
- `bash corpus/claim-ledger.sh verify --root <scratch 1-row>` → `STALE …`, `FAIL R68-02 reason=exit-mismatch exit=2 want=0`, `CLAIM_LEDGER: FAIL (… stale=1 …)` rc 1 — `…/ledger1-verify.out`, `…/ncount2.out`
- same scratch, `R68-02` command `true` → `POLICY R68-02 reason=first-token:true`, `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=168)` rc 2 — `…/ledger1-true.out`
- restamped scratch, `bash corpus/planted.sh` printing the anchored expect, `--docs corpus/lessons/round-68.md` → `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=2 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)` rc 0 — `…/printfrow-docs.out`

## Tool notes

No tools installed or upgraded. No pacman transaction. No host sysctl or process touched. Scratch dir removed by trap; the receipt copies are the only retained evidence.

## Verdicts for the L1

- C1 wording: no falsification of the count (`mismatches=0 population=13`) by a do-nothing tree was measured, because the counter does not exist yet. Wording defects F-C1-1, -3, -4, -5, -6 are narrowings to be fixed before freeze of the counter, or before the counter's selftest is accepted.
- C2 wording: F-C2-1 and F-C2-4 are the two that make the instrument's own guard unsatisfiable or mis-stated as written; F-C2-2 and F-C2-3 show the ledger leg is a restamp-and-scope exercise, not the production gate.
