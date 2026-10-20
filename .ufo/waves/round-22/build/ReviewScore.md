# Round 22 — ReviewScore

## Scope and read revision

Axes: **calibration (C1)** and **freshness (C2)**. Frozen base read: `c2cab35bc92e57e39e5489bac3386db078345b3f`. The round-21 scorecard places both owned axes at 9 (`SCORECARD.md` §Round 21, lines 622–645); the round-22 plan calls them tied lowest-owned axes (`plans/round-22.md:5–8`). No depth move or legacy-header-count proxy is in scope.

At the observed in-progress worktree snapshot, the tracked diff was limited to `corpus/QUALITY.md`, `corpus/SOURCES.md`, and appended errata in `corpus/knowledge/onepassword-machine-credentials.md` and `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; `corpus/lessons/round-22.md` and the wave artifacts were untracked. `SCORECARD.md`, `corpus/stamps.tsv`, and `corpus/claim-ledger.tsv` had no working-tree changes. This is not a final round-22 implementation or scoring verdict.

## Findings by severity

### High — C1 has not yet demonstrated calibrated decisions

The decisive prior evidence is `corpus/lessons/round-21-verifier-spotcheck.md:11–17` (verifier commit `1e9e67ff3f8f9e7118f8a7026c0e79aab9ce42b2`): `REJECTED-HONEST-STOP`; both sampled admits E1 and E3 disagreed with the non-author reviewer (0/2), while the three sampled rejects agreed (3/3). The verifier explicitly held calibration at 9 because counts of authored mistakes/criteria were not a discernment check. `SCORECARD.md:642,669–672` preserves that result. The current round-22 edits add QA10/QM13 (`corpus/QUALITY.md:67–73`), new source rows S017–S020 (`corpus/SOURCES.md:23–26`), and E1/E3 errata; those are useful corrections, not outcome evidence. The new lesson itself says the source/citation checker is not a content verifier (`corpus/lessons/round-22.md:21–25`).

**Acceptance condition:** before any C1 credit, adjudicate a fixed, source-grounded decision set and report per-case expected outcome, observed decision, miss and false-admit counts. Include the two known bad admits (E1's omitted Business eligibility / conflated Broker feature statuses; E3's Vault/OpenBao and JWT-path conflations), plus bounded positive controls: Actions-only public preview with Business eligibility; custom-OIDC-only public beta with its stated Business/app/SDK limits; and product-separated Vault/OpenBao claims. Require a non-author adjudication for outside agreement. QA/QM row counts, citation resolution, or a passing typed-record selftest alone do not satisfy this.

**Falsifier C1 must withstand:** submit the broad claim that *both* Broker workflows are public preview and available without the Business prerequisite, supported only by the guide-level source. The expected result is reject: the current registry records feature-specific Actions status at S017, custom-workflow status at S018, and eligibility/setup limits at S019/S020; the round-22 E1 erratum records the same split (`onepassword-machine-credentials.md:37–68`). If a gate accepts that claim—or reports calibration from its row count while doing so—C1 fails. Conversely, it must retain an admit for each correctly bounded feature-specific control. I did not fetch the public pages, so these are the corpus-recorded expected outcomes, not an independent source verification.

### Medium — C2 must preserve the historic row migrations without calling replacements missing members

The earlier verifier record says five stamp mismatches remained at `e1544c194`; the round-21 lesson names them (`corpus/lessons/round-21.md:81–87`). At the frozen round-22 base, `.ufo/waves/round-22/before.json:2–11` records **six** stale rows: those five plus `LOG.md`; `.ufo/waves/round-22/frozen/before/expected.json:2–18` binds the frozen revision and original stale set. The new lesson correctly records six as the starting observation (`corpus/lessons/round-22.md:36–40`). Hash changes measure byte-pointer integrity only, not whether historical source facts are current.

There is an important terminology check for the “nine deleted stamps” claim. The outside report `…/.ufo/waves/kaika-w3/kagi-review.md:18–19,131` reports nine `stamps.tsv` lines deleted between `aea7a4301034aa9160ada69457a6427f77064169` and `e1544c194fddf1bb073b3946847b4526f326ad73`. I read that exact Git diff: the nine old tuples are replaced by tuples for the **same nine paths**, not nine absent path memberships. Examples include `corpus/claim-ledger.tsv` (old `c8369a…`, 49 lines/13,981 bytes; new `8a4019…`, 54/16,986), `corpus/op-ref-probe.sh` (old `509f08…`, 660/28,660; new `0f1945…`, 788/34,362), and `SCORECARD.md` (old `f3e61b…`, 446/66,069; new `29f9f0…`, 691/87,010). The full nine-path set is `corpus/claim-ledger.tsv`, `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`, `corpus/README.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, and `SKILL.md`. This does not disprove a different-interval membership loss; it does mean the cited interval proves nine superseded row values, not nine dropped paths. Preserve that distinction in the migration record and substantiate any additional missing-membership claim against its exact historic revision.

The same historical diff shows four expectation rewrites in `corpus/claim-ledger.tsv`: R12-02 `29`→`36` cases, R12-03 `56`→`63` stamp rows, R13-01 `20`→`23` scorecard headings, and R14-01 `21/18`→`24/21` entries/row-linked. The old and new rows are recoverable from the stated commit pair. For QM14 acceptance, record each old/new expectation, why the correction is justified, and the observed check; do not treat the new expectation as its own evidence.

**Acceptance condition:** compare complete historical/current path sets and full row tuples, not just counts. Preserve every superseded tuple and ledger expectation with old/new values and rationale; report truly missing members individually and restore them or justify each removal. Do not report CLEAN on unavailable history, malformed input, or a count-preserving path swap. Reconcile the six frozen-start stale rows and the newly modified files only after final edits. At this snapshot, `corpus/QUALITY.md`, `corpus/SOURCES.md`, and both appended knowledge entries had changed while `corpus/stamps.tsv` remained unchanged; its base pins therefore still describe the pre-edit versions. This is an open integration requirement, not evidence of a completed C2 move.

## No depth or header-count credit

`plans/round-22.md:8` explicitly forbids a depth claim and legacy-header proxy; `corpus/lessons/round-22.md:7–8` says no depth claim. The observed diff did not change `SCORECARD.md`. Do not infer either axis movement from new document rows, an authored header count, or round-21's separate depth result.

## Residual risk and verification gaps

- No round-22 C1/C2 decision or migration gate was exercised here; no build, test, lint, formatter, or host-private check was run. Parent should run the isolated adversarial fixtures for decision outcomes, complete membership comparison, malformed/missing history and count-preserving swaps after integration; then apply the documented safe-row/stamp verification rather than the host-bound ledger row.
- I did not independently reopen vendor pages or perform the round-22 non-author spot-check. Outside agreement remains pending.
- The mounted tool list has no `lsp` device (`read xd://lsp` returned “No such tool”); therefore `references`, `definition`, and `diagnostics` were unavailable. Grep was used only to locate passages; findings above rely on direct file reads and the exact historical Git diff, not grep as semantic proof.
- No tools were installed.

Report path: `.ufo/waves/round-22/build/ReviewScore.md`
