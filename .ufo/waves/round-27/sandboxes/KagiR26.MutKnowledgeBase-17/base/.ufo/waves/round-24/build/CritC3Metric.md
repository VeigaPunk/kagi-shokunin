# C3 metric review — identity-bound count rows

## Finding

**Strongest objection:** the proposed `0/15` result can establish, at most, that the fifteen enumerated mutations are detected relative to the newly pinned after-state hashes. It does not yet establish a fair calibration of the count-only ledger population: the cohort boundary is inconsistent with the plan's own exclusions, and the current probe source does not prove that a reported kill was caused by the corresponding identity row while the old count claim remained green.

### Population fairness

- `plans/round-24.md:51-61` calls the 15 rows a population of “bare cardinality” expectations, then `:78-80` explicitly excludes nine selftest case-count rows while acknowledging they “share the count-only class.” The ledger confirms those nine are count-bearing rows: `R11-03`, `R11-05`, `R11-09`, `R12-02`, `R15-02`, `R16-02`, `R18-03`, `R21-03`, `R22-02` (`corpus/claim-ledger.tsv:17,19,23,27,34,40,50,53,56`).
- The boundary is not simply “selftests out”: selected `R22-04` is itself a selftest count (`cases=17 failed=0`, `corpus/claim-ledger.tsv:58`), and selected `R22-03` asserts a multi-field audit summary rather than a bare cardinality (`:57`). The nine omitted rows are therefore a different stratum, not a cleanly excluded category. One omission (`R11-03`) is `[substrate]`-tagged (`:17`), but the others are not tagged; the plan gives no row-by-row reason for excluding them.
- The current probe hard-codes exactly one author-chosen mutant per selected row (`.ufo/waves/round-24/tools/identity-swap.py:137-153`). A single fixed mutation can be a useful smoke test, but the aggregate is not a representative estimate of all count-only rows or mutation classes. In particular, excluding selftest case-name populations leaves the sensitivity of case-count assertions largely unmeasured.

**Correction to the claim:** either call this a *targeted 15-row cohort* and say nothing general about the remaining nine, or include/stratify the nine with an explicit host-safety rationale. Do not label `0/15` as coverage of the whole count-only class.

### Probe validity / concrete counterexample

The probe's stated method says “count-preserving” and promises an invalid-control guard (`identity-swap.py:10-22`), but the implementation does not assert the key causal conditions:

- `evaluate()` returns only parsed `FAIL`/`POLICY` IDs; it discards the verifier's process return code (`:180-187`).
- A mutant is counted `KILLED` on **any** failing row (`:213-218`), not specifically the R24 identity row for that old claim. Every R24 row is added to every subset (`:170-177`). For shared surfaces this makes per-row attribution especially important: `R16-04/05/06` and `R17-02/03` all count different memberships in `corpus/adjacency.tsv` (`corpus/claim-ledger.tsv:42-47`).
- The harness does not check that the mutated old row's original expected count still passes before calling the mutant killed. Thus a count-changing mutation, an unrelated R24-row failure, or an abnormal verifier exit can be misreported as evidence for identity binding. The hard-coded mutants appear designed to preserve counts, but that property is not asserted by the harness. The final summary is printed and the script returns 0 unconditionally (`identity-swap.py:223-225`), so an automated caller must also parse and enforce the expected `15/15` before and `0/15` after.

**Counterexample to the metric, not a claim about an observed run:** if an R11-10 mutation made its old numeric expectation fail, or if an unrelated R24 row failed, the current decision rule would still increment `killed`; no checked condition requires the matching R24 identity row to be the cause. No mutant run was performed in this review, so no runtime result or exit code is claimed.

Smallest test correction: for every case, assert (1) the original row's command still exits as expected and matches its original count after mutation, (2) the corresponding R24 identity row fails, (3) controls pass, and (4) no other failure is used to score that case. Retain the full failing-ID set, check verifier status, and make the harness exit nonzero when before/after acceptance criteria are missed.

### Digest semantics and legitimate edits

`plans/round-24.md:55-57` says the reader hashes “membership each row claims,” but the inspected tree did not contain `corpus/row-identity.sh`, so its selector projection, canonicalization, and pinned-output form could not be reviewed. A same-repository digest is a useful **drift detector**, not an independent oracle: an after-state hash records the selected members; it does not establish that those members are the correct interpretation of the old note. Recomputing a pin after an edit is also easy unless the migration is separately reviewed. This is a limitation, not by itself a reason to reject pinning: the established lesson is that a stamp/pointer is integrity, not currentness or truth (`corpus/lessons/round-12.md:107-108`; `corpus/lessons/round-13.md:100-102`).

There is also a real over-pinning tradeoff. **[INFERENCE]** If each selector hashes complete matching lines, changing a note/value on an otherwise same member will require a digest migration; if it hashes only stable keys, the key set may fail to represent a meaningful identity change. The plan does not yet specify that boundary. Before accepting `0/15`, record the per-selector identity projection (stable keys vs full rows), demonstrate one legitimate non-membership edit that should not churn a pin, and make any actual membership change an explicit migration with before/after member lists and rationale. Keep the digest literal in the ledger; do not derive its expected value dynamically from the same current state.

## Axis and scope

- **Primary axis: calibration.** The intended benefit is correcting “self-assessment matches repo state” for count claims. A passing mutation suite alone shows detector sensitivity, not that the assessment is relevant or true; round 13 already records pointer relevance as a calibration ceiling (`corpus/lessons/round-13.md:100-102`).
- **Secondary axis: operability.** `row-identity.sh` and the mutation runner are operational mechanisms, but adding a reader does not itself improve scheduling or how readily users operate the gates. The digest also has a freshness/integrity effect, but that is not the stated principal claim.

## Evidence that would settle the objection

1. At the frozen BASE and measured after commit, show for each selector the exact canonical member keys, count, digest, and a reviewed before/after member diff; explain each changed/renamed member. A second reviewer should validate the keys against the row note, not merely recompute the same digest.
2. Run the exact old row command on each mutant and retain its exit plus output (must still satisfy the old count). Then show that the **matching** R24 row is the failing row, with a clean no-mutant control. Include a deliberately changed count as a negative control that is **not** credited as an identity kill.
3. Either exercise the nine omitted selftest rows as a separate stratum, or preserve them explicitly as out-of-scope and narrow the conclusion to the fifteen listed claims. Explain why `R22-04` is included while analogous case-count rows are not.
4. Align the runner name before citing a command: the plan specifies `bash .ufo/waves/round-24/tools/identity-swap.sh <rev>` (`plans/round-24.md:58-61`), while the inspected build artifact documents `identity-swap.py LABEL REV [SRC FILE...]` (`.ufo/waves/round-24/tools/identity-swap.py:24-25`). This review did not invoke either command (exit status: **not run**); no before/after result is asserted.

## Smallest safe disposition

Keep C3 as a calibration claim, but narrow it to the enumerated cohort unless the nine omitted rows are tested. Gate the claimed `0/15` on count-preserving, target-row-attributed failures and clean controls. Define selector identity and require a reviewed migration record for changed members; do not claim the digest independently validates semantic correctness. No code or other lane file was changed.