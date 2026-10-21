# ClaimR18X03: R18-03 semantic audit (round 23 parent-build, advisory)

Seat ClaimR18X03 (scout, leaf). This audit was read-only. I did not execute the ledger command, the selftest, `verify`, `cells`, any sibling gate, or any host probe. I installed and updated no tools. I have no judgment or admission authority.

## 0. Paths and observed revision

| Short name | Absolute path |
|---|---|
| ledger | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv` |
| script | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh` |
| stamps | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/stamps.tsv` |
| deferral entry | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/substrate-deferral.md` |
| ledger entry | `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/claim-ledger.md` |
| scorecard | `/home/vgpnk/Projects/shokunin/kagi-shokunin/SCORECARD.md` |
| receipt | `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-22/final-verification.json` |
| inputs | `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-22/final-verification-inputs.json` |
| epoch files | `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-22/{pin-migrations-integration,pin-migrations-falsifier-repairs,safe-row-plan}.json`, `…/round-22/frozen/before/corpus/claim-ledger.tsv` |

- **Frozen population.** Lane HEAD is `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20T21:11:59-03:00).
  - The script at HEAD has sha256 `cf56f9ea75d512f60c3be80b8afe34d331eb0f007b8fa6aef2d3d9f188cb6c2c`, 1428 lines, 88425 B, git mode 100755. This equals `4be5da3`, stamps:4 and the inputs record.
  - The ledger at HEAD has sha256 `e6806968436375870067d0e587fb1e8ea27e5d3304b8bb563e3f484c1dce8305`. This equals stamps:5 and the inputs record.
- **In-flight worktree (L1, not frozen).** I observed it at 2026-10-21T00:54 and 00:59 -03:00.
  - The script is now `c20c2d04…`. The diff is +3/−3: the python allowlist adds `closure-dispositions.py`. The selftest block is byte-identical to HEAD.
  - The ledger is now `6fa0c24f…`. The R18-03 line is byte-identical. R23-01 and R23-02 are added.

## 1. The row

ledger:50 reads `R18-03 | bash corpus/claim-ledger.sh --selftest | ^SELFTEST: PASS \(121 cases\)$ | 0 | 300`. Its note says: "same isolated selftest as R11-09: expected 108->121 after fresh malformed-heading/positional-mode falsifiers. All expectation epochs retained; no host-private gate execution in selftest." The row has no `[substrate]` tag.

## 2. Verdicts

| Question | Verdict |
|---|---|
| Last-line ERE `(121 cases)` | **Supported**, causally and not just by count (§3) |
| Exit 0 | **Supported** |
| Timeout 300 | **Supported**: observed 2.289 s; the slowest case is bounded at about 1 s |
| Untagged, so never deferred | **Supported**, and it must stay untagged |
| Note's "no host-private gate execution" | **Supported** by a static trace (§4) |
| Deferral mechanism proved hermetically | **Incomplete**: the untagged×absent clause has no forced case (§5, primary risk) |
| SKIP-SELF preserves the obligation | **No**: only the pointer survives. Only direct or safe-row execution discharges the row (§6) |
| Hermetic synthetic mode (C3) preserves it | **Only if** C3 runs R18-03 or binds a sha-bound receipt. R23-01 does neither by design (§7) |
| C1 | R18-03 is not one of R23-02's 15 obligations. The chain and epochs to keep are in §8 |

## 3. The expectation: causal evidence

- **Static count.**
  - The selftest block contains 118 `tcase` calls and 3 `tcase_last` calls (script:1291-1424). All are top-level; none sits in a loop or a conditional.
  - Each call increments `cases` exactly once (:1261, :1278).
  - :1426 prints `SELFTEST: PASS (%d cases)` and exits 0 only when `failures==0`. :1427 prints FAIL and exits 1.
  - A setup break aborts under `set -euo pipefail`, so it fails closed.
- **Receipt.** receipt `safe_rows[22]` shows exit 0, `last`=`SELFTEST: PASS (121 cases)`, empty stderr, 2.289 s. I parsed its stdout:
  - 122 lines: 121 `ok-case` and 0 `FAIL-case`. Ordinals run contiguously 1..121.
  - **The case names match the 121 names in the HEAD script, in the same order. Every per-case exit equals the script's `want_rc`.**
  - `safe_rows[3]` is R11-09 in a separate run (2.316 s). Its stdout is byte-identical.
- **Delta against `8ada17a` (108 cases).** 13 names were added and 0 removed:
  - 2 positional cases: `mode-unknown-revision` and `verify-extra-positional` (:1292-1293).
  - 11 heading cases, `cells-round-tab-refused` … `cells-pre-movement-refused`.
  - This matches R11-09's 8+2+3 breakdown and R18-03's note.
- **Binding.**
  - The inputs record pins script sha `cf56f9ea…` and `expected_selftest_cases.ledger=121`. The receipt and the script landed in the same commit, `4be5da3`.
  - Only two committed revisions of the script followed round 21: `8ada17a` (108 names) and `4be5da3` (121 names).
  - **Limit:** the receipt stores no cwd, no environment and no digest of the executed bytes. The byte binding is declared; the name and exit match is the causal link.
- **Timeout.** The slowest case, `claim-timeout` (:1296), runs `sleep 30` (:1042) under a 1 s claim timeout (:1156) via `timeout -k 5` (:427). The whole run took 2.3 s against a 300 s limit.

## 4. `[substrate]` deferral: what the selftest proves

- R18-03 is untagged, so `verify_claims` never defers it (:416). That is correct, because the selftest is host-free:
  - It runs in a `mktemp -d` scratch directory (:1031), and every inner call passes `--root "$R"`.
  - It clears the nesting marker (:1037).
  - The only `[substrate]` fixture is `claims-defer.tsv` (:1205), used only under an explicit `KAGI_SUBSTRATE` (:1422-1424).
  - Nothing unforced reaches `substrate_present` (:140-146), which is the script's only `$HOME` read.
  - Python and denied-verb rows are refused before they execute. The allowed python rows run scratch stubs.
- The three named cases prove two things:
  - A tagged row on an absent substrate is deferred and counted `deferred=1` (:1422, :1424).
  - A tagged row on a present substrate runs (:1423).
- That matches deferral entry:33 ("both arms on any host"). The ordinals "95–97" at deferral entry:85 and scorecard:322 are historical. They are now cases 119–121 (erratum :110-113).

## 5. Primary risk: false-clean of the deferral contract (specific to R18-03)

**Clauses with no forced proof:**
- deferral entry:38-39: "Absent substrate + no tag ⇒ normal run … deferral cannot launder a real regression".
- Falsifier at :91: "a non-tagged row reporting DEFER".
- Bound 5 at :77 relies on "the selftest pins both arms".

**Observation (static; not executed).** No case runs an **untagged** row under forced `KAGI_SUBSTRATE=absent`. Ordinary cases exercise the clause only by accident, through host detection; for example `claims-pass` expects `deferred=0` (:1291).

**Mutant M.** M drops the tag predicate at :416. A one-character variant also counts: un-quoting `'[substrate]'` turns it into a bracket expression that matches any note containing s/u/b/t/r/a/e.
- **Substrate present, or `KAGI_SUBSTRATE=present` inherited:** all 121 cases still pass. R18-03 and R11-09 stay green.
- **Substrate absent:**
  - `verify` defers every row, including R18-03, so the selftest never runs there. It prints `CLAIM_LEDGER: CLEAN (claims=43 deferred=43 …)`.
  - No row pins the deferred count. The verify summary cannot be pinned (:229-238), and R13-03 matches `row_deferred=[0-9]+`.
- **Precedent:** at round 18 an in-flight tag form over-matched and deferred untagged count and selftest rows (deferral entry:65-69).

**Minimal synthetic failing fixture.** This is a proposal for L1. I have not run it.
```
printf 'c1\tgrep -c EXPECTED corpus/absent.txt\t^1$\t1\t5\tprose says substrate and substrate-deferral, no bracket tag\n' >"$R/claims-untagged-absent.tsv"
tcase defer-untagged-absent-runs 1 'FAIL c1 reason=exit-mismatch' env KAGI_SUBSTRATE=absent "$0" verify --root "$R" --claims "$R/claims-untagged-absent.tsv" --stamps "$R/stamps.tsv"
```
Expected outcomes, from reading the code:
- **Current code:** `FAIL c1 reason=exit-mismatch exit=2 want=1`, exit 1, so the case passes.
- **Under M, the un-quoted glob, or a word-boundary tag regex:**
  - The gate prints `DEFER c1 reason=substrate-absent` and `CLAIM_LEDGER: CLEAN (claims=1 deferred=1 …)` and exits 0.
  - The case fails, so the selftest prints `SELFTEST: FAIL` on every host.
- **Consequence for the pins:** the count moves from 121 to 122. R11-09 and R18-03 must migrate together, each with an old/new `claim_changes` epoch.
- **Do not fold this assertion into an existing case.** That would change what the selftest proves while the count-only pin stays at 121.

## 6. SKIP-SELF

- `cells_evidence` skips any cited row whose command contains `claim-ledger.sh` (:816-819). R18-03 is therefore always `SKIP-SELF`. `cells` never re-runs it; it shows up only in `self_skipped`.
- Only one scored cell cites R18-03: scorecard:324 (Round 18 post-move, operability), which cites `R11-03` and `R18-03`.
- R11-03 is `[substrate]`, so it is deferred when the substrate is absent.
  - `C_N` increments before the DEFER branch (:415-418) and becomes `rows_run` (:828).
  - So on an absent host this cell rests on **zero executed rows**. It still counts as `row_pointed`, and `rows_run` includes the deferred row.
- Two statements in ledger entry do not hold for this cell:
  - :183-185, "a cell cannot rest on a failing row".
  - :200-202, "the line itself shows how many scores rest on a re-run command".
- R13-03 itself carries `[substrate]` in its note, and round-22 final verification skipped it. There is no record of `cells` re-verifying this cell at HEAD.
- **Not duplicated here:** ClaimR11X08 (Finding 2) and ClaimR14X01 (§3) already report the general class, where CLEAN absorbs a skipped cited row.
- **Specific to R18-03:** its SKIP-SELF is not needed to keep the audit bounded. The selftest clears depth (:1037) and is scratch-rooted. Its only self fixture, `R3-01` (:1131), points at a scratch root that has no `corpus/claim-ledger.sh` [INFERENCE]. An exemption for the exact argv would therefore stay bounded. That is a design choice for L1, not a defect claim.

## 7. Hermetic synthetic mode / C3: what to keep for R18-03

1. **Keep R18-03 untagged and run it directly**, through the safe-row harness or a top-level run. If it were tagged, the only proof of the DEFER branch would itself be deferred, on exactly the hosts that need it.
2. **C3 depends on R18-03 for two branches.** R18-03 and R11-09 are the only executed proofs of the SKIP-SELF branch (`cells-self-row-skip`, :1374) and the DEFER branch (:1422-1424). In-flight R23-01 pins `row_deferred=0 self_skipped=0` over `corpus/fixtures/cells-hermetic/` (2 local rows), so it deliberately exercises neither.
3. **C3 must not report any `claim-ledger.sh` row as discharged by `cells`.** That covers R18-03 and also R23-01: the worktree scorecard cell at :841 cites only R23-01, which leaves it in the same position as R18-03's cell.
4. **Watch `KAGI_SUBSTRATE`.** Running R18-03 under a global `KAGI_SUBSTRATE` does not change its verdict. However, `=present` hides mutant M (§5) until the falsifier lands, so prefer leaving it unset or setting `=absent`.
5. **Freshness after landing.**
   - The worktree script (`c20c2d04…`) differs from the receipt-bound bytes (`cf56f9ea…`), so the round-22 receipt does not discharge R18-03 for the landing bytes.
   - From a static reading, the outcome should not change: the selftest block is identical and no case uses `closure-dispositions.py` [INFERENCE].
   - Re-run after landing. stamps:4 will read STALE until it is re-stamped.

## 8. C1 closure-disposition: what to keep for R18-03

- **Follow the pointer chain, not the number:**
  1. ledger:50
  2. argv
  3. script sha (stamps:4)
  4. the 121 named cases
  5. receipt `safe_rows[22]` (names and exits matched)
  6. inputs record

  The consumer cell is scorecard:324. The narrative mention is `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-22-verifier-spotcheck.md:70`.
- **Epochs.** All three are retained:

| Count | Status | Where recorded |
|---|---|---|
| 97 | historical | `frozen/before/…/claim-ledger.tsv:50`; `pin-migrations-integration.json` `claim_changes[5].old` |
| 108 | superseded | `…integration.json` `claim_changes[5].new`; `…falsifier-repairs.json` `claim_changes[2].old`; `safe-row-plan.json` `safe_rows[22]`, whose status is "plan, not an exercised pass" |
| 121 | current for HEAD | `…falsifier-repairs.json` `claim_changes[2].new`; receipt |

- **Mentions to classify as historical, not active evidence:**
  - scorecard:322 ("cases 95–97").
  - scorecard:764 ("PASS (108 cases)", the H1 candidate). :805-806 ("ledger121") supersedes it.
  - deferral entry:85 (old ordinals; see erratum :110-113).
  - Round-22 build and falsify reports that quote 97 or 108.
- **In-flight R23-02.** `corpus/closure-dispositions.json` (sha `52ae37de…`) lists 15 obligations: SPOT-01..05, ADJ, and D1..D9.
  - None of them is R18-03. The spot-check's one R18-03 mention (:70) sits outside the parsed sections.
  - There is nothing to dispose of. The requirement is to never accept "121" as assurance without the name/sha binding plus the receipt.

## 9. Secondary observations (not the primary risk)

- **SELFTEST falls through from the environment (latent false-fail).**
  - `SELFTEST` is missing from the other mode globals' initialization (:103-113). Only the `selftest)` arm sets it (:1025), and :1030 reads it.
  - The CLEAN arms of `stamp`, `verify`, `docs`, `cells` and `citations` (:966-1023) do not exit.
  - With `SELFTEST=1` exported, any CLEAN run appends a full selftest. Inside that selftest, every CLEAN inner `"$0"` call recurses. R18-03 would then run into its 300 s timeout and record `FAIL … reason=timeout` [INFERENCE].
  - **Fix:** add `SELFTEST=0` next to `MODE="verify"` (:110).
  - **Regression case for after the fix:** `tcase selftest-env-ignored 0 'CITATION_GATE: CLEAN' timeout 10 env SELFTEST=1 "$0" citations --root "$R" --docs "$R/corpus/docs/clean.md"`. Before the fix it would fail, with exit 124 from the bounded depth-first recursion.
- **Depends on the exec bit.** Inner cases exec `"$0"` directly (for example :1291). A checkout that drops mode 100755 turns all 121 cases into FAIL-case; this fails closed. The row's cwd/argv form is fine.

## 10. Limits

- **Nothing executed.** I derived every mutant and fixture outcome by reading the HEAD bytes.
- **Substrate state not probed**, per the contract. The last committed measurement says it is absent (the R18-01 expectation; deferral entry:3-11, round 18).
- **Unknown round-22 environment.** The receipt records no cwd or environment, so the `KAGI_SUBSTRATE` value during round-22 execution is unknown. It does not affect R18-03's verdict.
- **The worktree was moving** between my two observations, so worktree citations carry sha256.
- **Other owners' rows.** R11-09 (same command), R11-03 and R13-03 belong to other owners; I used only the facts R18-03 needs. I needed no public sources.
- **Write disclosure.** Besides this report, I wrote one transient copy of the committed HEAD script to `/tmp` for line lookup and deleted it immediately. I touched no production path.
