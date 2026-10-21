# ClaimR22X01 — R22-01 semantic audit (connector, round-23 parent build)

Advisory only. This report does not judge or admit anything.
Axes: calibration, freshness, operability.

## 0. Revisions observed and how I worked

- **Frozen population:** `d218603b74099ddca0bd8f869516fc41db0979bf` was HEAD when I started.
  - The row is `corpus/claim-ledger.tsv:55`. The sha256 of that line is `7688f1e5cd51e2a0…`.
- **HEAD moved during the audit.** L1 committed `e1884c6ecb7ccd717965b0d748bc193137118dbf` at 2026-10-21T01:04:19-03:00 ("round-23: closure dispositions, declared source provenance, hermetic cells").
  - The R22-01 line is byte-identical at d218603, at e1884c6 and in the working tree.
  - Unless marked otherwise, the line numbers below are e1884c6 line numbers.
  - After the commit the worktree still changed: the falsify-wave reports under `.ufo/waves/round-23/falsify/` kept moving.
- **Subject bytes.** I hashed the blobs:
  - `corpus/feature-claims.py` is `d53b39fe…` and `corpus/feature-claims.json` is `a66acbfb…`.
  - Both are identical at 4be5da3, 254d632, d218603, e1884c6 and in the working tree.
  - They match `.ufo/waves/round-22/final-verification-inputs.json` and stamps rows 9/10 at d218603 (rows 19/20 at e1884c6).
  - At the receipt's `.h1`, 8ada17a5, the bytes differ: the `.py` is `9f6a7e35…` and the `.json` is `a506cea7…`.
- **What I ran and did not run.**
  - I did not run the row or any gate, selftest, handler, op/vault or host command.
  - I never imported or executed any `corpus/*.py`. I used python3 only as a stdlib JSON reader on committed files.
  - My only write is this report.
- **Git disclosure.** I ran one plain `git status --porcelain` at the start, which can refresh the index stat cache. After that I made only object reads with `GIT_OPTIONAL_LOCKS=0` (`show`, `cat-file`, `log`, `rev-parse`, `status`). I made no commits.
- **Tools:** none installed or updated; none needed.
- **Public sources:** I fetched none and quote none.

## 1. Answers

| question | status | basis |
|---|---|---|
| Expected verdict, last line, exit 0 and timeout 60 justified | **supported** | §2. The CLEAN print is `feature-claims.py:842-847`. The historical run took 0.028 s (`final-verification.json:450-465`). |
| Measured quantity vs. authored count | **count of authored controls** | `admitted=4` is fixed by `EXPECTED_RECORDS` (`:82-85`) plus the pins. `false_admissions=0 misses=0 unjudgeable=0` is a literal (`:845`). |
| `[substrate]` deferral | **correctly absent** | The note is untagged. Verify defers only tagged rows (`claim-ledger.sh:416-419`). The gate reads no `$HOME`, environment or network. |
| SKIP-SELF | **not applicable** | It fires only for commands containing `claim-ledger.sh` (`claim-ledger.sh:816-819`). |
| Hermetic/synthetic modes preserve the obligation | **no, and they do not claim to** | The selftest stub (`claim-ledger.sh:1166`) proves policy only. C3's fixture cites no production row (`lessons/round-23.md:190`). The obligation lives only in R22-01's direct safe-row run. |
| Historical receipt transfers to current bytes | **supported, through the inputs digests only** | The `.h1` (`final-verification.json:2`) names *different* evaluator and catalog bytes. For R22-01, D6 is material. |
| Consumer-visible false-clean/false-fail risk | **supported (§5)** | The only admitted Vault control is locked to superseded id S013. The active S023 gives `FC-UNKNOWN-SOURCE`. |

## 2. Causal content of the CLEAN line (supported)

**Call chain**

- `main` (`feature-claims.py:1024-1047`) computes root as `Path(__file__).resolve().parent.parent` (`:216`).
- It reads only `corpus/feature-claims.json` (`:24`), below that root, with `O_NOFOLLOW` (`:250-290`).
- `_artifact` (`:742-753`) checks all six section digests against the code pins (`:61-66`).
- It also validates every control, whatever the phase. That covers the record set, the transition minimal-delta paths (`FC-TRANSITION-DELTA`) and the boundary set (`:512-591`).
- Then `_run_phase('after')` runs (`:780-847`).

**Exit map**

- CLEAN → 0 (`:842-847`).
- FAILED → 1 (`:835-841`).
- CANNOT_EVALUATE → 2 (`:829-834`, `:1044-1046`).

**Field by field**

- **`admitted=4`** is computed, but in a CLEAN line it always equals the number of `after` records.
  - That number is fixed by `EXPECTED_RECORDS` (`:82-85`), `FC-RECORD-EXPECTATION`/`FC-RECORD-SET` (`:526`, `:531`) and `PINNED_RECORDS_SHA256` (`:64`).
  - A fifth `after` record gives exit 2, not `admitted=5`.
- **`false_claims=0 bar_failures=0`** are computed, but are necessarily 0 whenever CLEAN prints.
- **`false_admissions=0 misses=0 unjudgeable=0`** is a constant string (`:845`). Each value is entailed:
  - unjudgeable returns 2 first (`:829`);
  - a miss sets `failed`, which gives FAILED (`:835`);
  - a false admission cannot happen in phase `after`, because every after record must expect `admit` (`:82-85`, `:526`).
  - So R22-01 can never observe a false admission.
- **Last line and exit under the ledger.**
  - The ledger runs `cd "$ROOT"`, then `timeout -k 5 60 bash -o pipefail -c … 2>&1` (`claim-ledger.sh:426-427`).
  - It takes the last non-empty line (`:436`) and does a bash ERE match (`:441`).
  - The expect pattern is literal text between `^` and `$`, so harness and bash ERE semantics agree.
  - The round-22 harness used the identical argv and ERE, with stderr `""` (`final-verification.json:450-465`).
- **Timeout.** It ran in 0.028 s against a 60 s limit.

**What can flip R22-01**

- Evaluator code on the admit or validation paths.
- Any content change in the six JSON sections.
- The interpreter or its environment.
- What cannot flip it: SOURCES.md status or supersession, `source-fetches.tsv`, knowledge entries, or vendor pages. `feature-claims.py` never references `SOURCES.md` or `source-fetches` (0 matches).
- So the row is a regression check on a frozen artifact, with **zero freshness sensitivity**.

**Discrimination**

- [INFERENCE, code-derived] A mutant where `_evaluate_claim` always returns admit prints R22-01's exact line, exit 0.
- Refusal power lives only in R22-02's selftest: the input reject cases (`:916-922`) and the before/boundary invocations (`:926-927`).
- The live citations are correct only as a pair:
  - `SCORECARD.md:737` ("R22-01/R22-02 must demonstrate false-admit refusal and bounded-control acceptance");
  - `SCORECARD.md:686` and `:850` ("refusing known-bad admits | … R22-01/R22-02").
- R22-01's share is bounded-control acceptance plus whole-artifact integrity.

**Related design note**

- `--phase before` returns 1 whether or not its ten records were classified correctly (`:835`).
- If a before-phase row is ever added, it must pin the full FAILED line, including `false_admissions=0 misses=0`, not only exit 1.

## 3. Deferral, SKIP-SELF and hermetic modes

- **`[substrate]`.**
  - The note is untagged, and the 11 tags counted by R18-02 exclude R22-01.
  - That is correct: the gate uses only the stdlib and reads one root-confined file.
  - Since the row is never DEFERred, deferral cannot hide a red result.
- **SKIP-SELF.** Not triggered.
  - Production `cells` would re-run R22-01, because the Round-22 post-move calibration cell cites it (`SCORECARD.md:737`).
  - But production `cells` is R13-03. R13-03 is `[substrate]`-tagged and skipped in authorized runs (`final-verification.json` `skipped_rows`).
- **Synthetic modes.**
  - The ledger selftest writes a `print("EXPECTED")` stand-in for `corpus/feature-claims.py` (`claim-ledger.sh:1166`). That tests the python allowlist, never R22-01.
  - C3's R23-01 fixture cites no production row and no python row. Its files are `corpus/fixtures/cells-hermetic/`: `claims.tsv` with R90-01 (`fx-ok.sh`) and R90-02 (grep), plus `stamps.tsv`, `SCORECARD.md` and `corpus/{fx-ok.sh,adjacency.tsv}`.
- **Unresolved gap (not a defect today).** In the authorized regime, no command resolves the `R22-01` token at `SCORECARD.md:737`:
  - idref runs only inside `verify`/`cells`, and neither is run;
  - R11-08 `citations` checks paths, not ids;
  - R14-01 `docs` checks `Reverify:` lines only, and `feature-bound-credential-review.md` declares `Reverify: R21-02`, not R22-01.
  - So renumbering would be caught only by count rows (R21-04), never by identity.

## 4. What C3 and C1 must retain for this row

**C3 (cells)**

- Never read R23-01's `CELL_AUDIT: CLEAN` as cell→row coverage of R22-01 or of `SCORECARD.md:737`. The lesson already says this (`round-23.md:190`), and R13-03's skip stays explicit.
- If a future fixture cites a python3 row, execution is re-rooted:
  - `cd "$ROOT"` (`claim-ledger.sh:426`);
  - `--root` leaves CLAIMS/STAMPS at the script dir (`:105`, `:203`, `:240`).
- A fixture-local `corpus/feature-claims.py` would then run instead of production, and the `:1166` stub idiom passes both policy and the row.
- So either forbid python rows in fixtures, or stamp and cite the copies at the production digests (stamps rows 19/20). Then a stub raises STALE-POINTER.

**C1 (closure dispositions)**

- R22-01 is not one of the 15 obligations (D1–D9, SPOT-01..05, ADJ). Do not enrol it; that would break R23-02's `obligations=15`.
- **D6 is the only obligation that touches R22-01's evidence, and it is prospective.**
  - The `fixed` pointer is `corpus/lessons/round-23.md#Routed defect dispositions`.
  - That section says the round-23 verdict file will carry `measured_commit` (`round-23.md:102-104`). The file was absent at e1884c6.
  - The resolver itself (file + anchor + token) is already criticized by ClaimR11X05, ClaimR12X02 and ClaimR13X01. I do not repeat that.
- **R22-01-specific retention:**
  - The new verdict entry must carry `measured_commit`, argv equal to the row tokens, the row ERE verbatim, and input digests equal to stamps rows 19/20.
  - The round-22 receipt must stay annotated: "`.h1` names other bytes for this row; binding is via `final-verification-inputs.json`".

## 5. Connector finding: the only Vault admission is locked to a superseded id

**Evidence**

- **R22-01 depends on S013.**
  - `AFTER-VAULT-LEASE` (`feature-claims.json:748-783`) is one of the four controls R22-01 requires to be admitted.
  - Its only evidence id is S013 (`:772-780`).
  - The catalog feature requires *exactly* S013 (`:303-329`), and the exact-set rule is `feature-claims.py:732-738`.
  - Its verbatim-pin reference anchors at "Registry S013…" (`:755-756`). verbatim-pin references are checked for shape only (`:507-508`).
- **The registry supersedes S013.**
  - `SOURCES.md:29` reads: S023 "supersedes S013 — retain the valid Vault lease/KV mechanism, withdraw the categorical no-displayed-version locator".
  - S023 and the final catalog bytes landed in the same commit, 4be5da3.
  - The catalog never mentions S023 (0 matches).
- **C2's rule places the active value under S023.**
  - Lesson D7 (`round-23.md:106-116`): superseding rows carry the active declared digests; old rows keep their historical values.
  - `source-fetches.tsv:43` binds `de5f8836…` (261,632 B, fetched 2026-10-21, `decoded-http-body-volatile-v1`) to **S023**.
  - The catalog files that same value under **S013** (`feature-claims.json:83`, `digest_observed_at` 2026-10-20, `prior_registry_sha256` `ae3215…`).
- **The gate admits S013 and refuses S023.** [INFERENCE, code-derived, not executed]
  - A caller `--input` record is advertised (`SKILL.md:696`; row note: "caller --input records use the same evaluator").
  - If it cites the active S023, `source_index.get` returns None, giving `cannot-evaluate FC-UNKNOWN-SOURCE` (`feature-claims.py:710-712`).
  - The output is `FEATURE_CLAIMS: CANNOT_EVALUATE finding=FC-UNKNOWN-SOURCE`, exit 2 (`:848-858`). That is the same path as the fabricated S999 boundary (`:177`).
  - The same claim citing S013 gives ADMIT, exit 0, which is exactly what R22-01 certifies.
- **No committed gate links the two stores.** At e1884c6, `sources-census.sh` has 0 `supersed` matches and 0 `feature-claims` matches. `feature-claims.py` has 0 references to the registry or the fetch file.
- **The debt record misses these consumers.** M23-2 (`round-23.md:143`) gives S012's catalog consumers (`:63-77`, `:915-932`, a boundary/unjudgeable use) as its evidence. It names no S013 consumer.
- **Full map of superseded-id consumers in the gate.** I derived it from the committed JSON and SOURCES edges (S006→S020, S007→S019, S012→S022, S013→S023, S014→S025, S016→S026).
  - Admit path: `AFTER-VAULT-LEASE` (S013), and the `vault_dynamic_secret_leases` requirement (S013).
  - Reject-only, i.e. historical bad evidence (appropriate):
    - `BEFORE-E1-STATUS` `:332-` (S007);
    - `BEFORE-CUSTOM-UNDERCITED` `:431-` (S006, S007);
    - `BEFORE-E3-VAULT-ONLY` `:393-430` (S013);
    - `BEFORE-VAULT-GA-UNPINNED` `:606-640` (S013);
    - `BEFORE-VAULT-OPENBAO-SOURCE` `:641-675` (S013).
  - Boundary: `OUT-OF-SCOPE-VAULT-JWT` (S012).
- **No semantic false-clean today.**
  - S023 retains the mechanism.
  - The bound quote (`feature-claims.json:89`) equals `source-fetches.tsv:43`'s quote verbatim.
- **Not repeated here:** the digest-disagreement and same-URL findings (SourceS013 F1/F4), and the quote re-attestation, title-case and S023-consumer findings (SourceS023 F3/F4/F6). This finding is the gate-side consequence of those.

**Consumer-visible effects**

- **False fail.** A caller who follows the registry's active row gets exit 2 for a correct, in-profile Vault lease claim.
- **Latent false clean.**
  - Suppose a later row supersedes S013/S023 and *withdraws* the mechanism, or S013 becomes `rejected`.
  - R22-01 would stay CLEAN.
  - It would keep printing `DECISION id=AFTER-VAULT-LEASE authority=verbatim-pin … actual=admit`.
- **Misdirected debt.** The routed "machine-readable supersession edges" debt is in SCORECARD "Remaining named debt" and M23-2. Starting from M23-2's named consumers, it would miss the one executable admission this affects.

**Axes affected:** freshness and calibration, both improvable; operability neutral.

## 6. Proposed move (one, bounded; no code, JSON or verdict-line change)

Make the superseded-id dependency explicit where consumers look, and probe it in the falsify wave.

1. **Append to `corpus/lessons/round-23.md` an M23-2 consumer completion.**
   - List the S013 gate consumers:
     - `feature-claims.json:79-97` (catalog);
     - `:303-329` (feature requirement: any admissible Vault-lease claim must cite S013);
     - `:748-783` (`AFTER-VAULT-LEASE`, the only admit-path consumer, certified by R22-01);
     - the reject-only S013, S006 and S007 records listed in §5.
   - Label them "historical id; mechanism retained by S023".
2. **Make the R22-01 note precise, with a QM14 journal entry** (expect, exit and timeout unchanged). The note should say:
   - `AFTER-VAULT-LEASE` binds S013, superseded by S023 for the locator only;
   - `--input` citing S023 is CANNOT_EVALUATE `FC-UNKNOWN-SOURCE` by closed-catalog design;
   - `false_admissions/misses/unjudgeable` are entailed literals in phase `after`, and refusal evidence is R22-02.
3. **Seed the falsify wave with Fixture A** as a probe, and record its current outcome. It is not a passing case.

Future round, not round 23: catalog S023 beside S013 with an explicit retention edge, plus an `--input` selftest case. That migration is reviewed and changes:

- `PINNED_SOURCES/FEATURES/RECORDS`;
- stamps rows 19/20;
- the R22-01/R22-02 epochs (R22-02's case count).

## 7. Minimal synthetic failing fixtures for L1 (proposals; not executed)

**Fixture A — supersession inversion through `--input`**

- Build a scratch input file, e.g. `corpus/inputs/vault-lease-active.json` in the selftest-style root.
  - Start from the claim object of `AFTER-VAULT-LEASE` (`feature-claims.json:758-782`).
  - Change every `S013` source id to `S023`.
  - Change the quote ids to `S023-title` and `S023-dynamic`.
- Run `python3 corpus/feature-claims.py --input <that path>`.
- Expected today: last line `FEATURE_CLAIMS: CANNOT_EVALUATE finding=FC-UNKNOWN-SOURCE`, exit 2.
- Paired control: the unmodified claim gives `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED`, exit 0.
- Assertion it encodes, which fails today: a claim that cites the registry's active superseding row for an in-profile feature is judgeable (exit 0 or 1).

**Fixture B — cross-store supersession check, for the routed supersession debt**

- Build a scratch `SOURCES.md` with two rows:
  - `S001 … mined`;
  - `S002 … supersedes S001 — withdraw the reading … mined`.
- Build a scratch catalog whose only `after` record cites S001.
- Expected once fixed: the check fails with something like `SUPERSEDED-ADMIT-EVIDENCE S001 by S002 record=<after-id>`.
- Control: S002 says "retain …" and the catalog records the retention edge. That must pass.
- Today no gate reads both files, so R21-02 and R22-01 both stay CLEAN. Showing that is the fixture's purpose.

## 8. Risks of the move

- `corpus/lessons/round-23.md` is stamped, so appending to it needs a restamp with a journal entry.
- The R12-03 count (79) and R22-03's `added=16` do not change.
- Do not record this as a C1 obligation. It is not a D or SPOT item, and adding it would break `obligations=15`.
- If L1 instead edits the catalog this round, R22-01/R22-02 and the stamps migrate at once. That would contradict the frozen plan's no-new-claim scope.

## 9. Verification L1 should run (none run here)

- `python3 corpus/feature-claims.py --phase after` (R22-01) and `--selftest` (R22-02). Both lines should be unchanged.
- Fixture A, both cases.
- `bash corpus/claim-ledger.sh --selftest` (R11-09/R18-03) after the note edit.
- The R21-04 count should be unchanged at 45.
- If the lesson append lands, restamp and check R12-03/R22-03.

## 10. Incidental (outside my row; for L1/R13-01's owner)

- The committed R13-01 note at e1884c6 contains the sentence "Includes the preserved blocked round-20 attempt … fail closed." twice.
- It is cosmetic, with no verdict effect.

## 11. Limits

- Every gate outcome above is derived from code reading [INFERENCE]. Nothing was executed.
- The only executed evidence is round 22's historical receipt.
- The worktree and HEAD moved during the audit. Citations use e1884c6. Peer reports that cite in-flight line numbers may differ by ±1.
- No public page was opened by this seat. Statements about digests and quotes come from committed files.
