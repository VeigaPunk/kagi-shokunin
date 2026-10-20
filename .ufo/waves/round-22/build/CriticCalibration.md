# CriticCalibration — round 22 C1 attack

Seat: KagiR22.CriticCalibration (critic, read-only). Axes: calibration, freshness.
Exact read revision: frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`
plus working-tree material observed mid-flight (uncommitted: `corpus/QUALITY.md`
QA10/QM13/QM14, `corpus/lessons/round-22.md`, `corpus/SOURCES.md` S017–S020,
E1/E3 round-22 errata, `.ufo/waves/round-22/frozen/before/expected.json`). The
spec, dispatch and registry were read from `.ufo/waves/round-22/`.
`/tmp/kagi-r22-BuildQualifierGate` was inspected: clone exists, no
`feature-claims.py`/`.json` yet, so this attack lands on the *design* before the
gate lands — the moment criticism is cheapest.

## The attack: why "correct decisions" is still row counting

1. **Author-labelled ground truth is self-agreement.** `feature-claims.json`'s
   `expected` fields are authored by the same lane that writes the gate. A gate
   that matches authored labels proves author–gate agreement, not adjudication
   against source. This is the identical defect QM13 (QUALITY.md:72, working
   tree) was written to kill — the round-21 verdict held C2 at 9 because the
   evidence was "counts of rows the lane wrote" — transported from *rows* to
   *decisions*. Changing the unit of the count does not change who wrote the
   labels.
2. **The denominator is mintable.** "Minimum eight meaningful bad and four good
   controls" bounds the floor, not the composition. A reject-leaning gate scores
   higher on an author-chosen 8:2 bad:good fixture than on a balanced one; a
   trivial gate that pattern-matches "eligibility missing" rejects every E1
   class case by construction (the defect it was built to catch) — perfect
   accuracy on its own training set.
3. **Fail-closed is a free reject machine.** The spec: "unknown
   feature/field/source fail closed." Every claim outside the three scoped
   features returns reject. If the metric cannot distinguish a reasoned
   out-of-scope abstention from an adjudication, "correct reject" counts can be
   minted without bound — and, worse, a gate whose scope-check is too *narrow*
   fails closed on claims it should adjudicate and the metric still pays it.
4. **Reject means two different things.** The gate adjudicates *admission under
   QA1/QA2/QA9/QA10*, not proposition truth. A true-but-under-cited claim and a
   false claim both decide "reject" with no category separation. Collapsing both
   into one "correct decisions" number is the row-count defect with a better
   name: count of cells in one column.

## The concrete counterexample (primary)

**Case CB-1 — under-cited truth.** Claim: `product=1Password, feature=Credential
Broker custom workflows, status=public beta, eligibility=Business plan`,
cited only `S006` (announcement) and `S007` (setup guide). The proposition is
true — S018's feature page carries the beta status and Business prerequisite —
but neither cited source is the feature-specific page QA10 requires (guide-level
label, unopened feature link). Correct decision per the amended bar:
**reject-by-bar** (insufficient binding), which is a *different semantic* from
rejecting the overclaim "both workflows are public preview" (false proposition).

Expected failure, two directions, both silent:
- (a) If the author writes the label by intuition ("the claim is true" →
  `expected=admit`), the correctly-built gate *rejects* and the metric flags a
  false failure — an implementer "fixes" the gate to admit under-cited claims,
  regressing QA10 while raising the score.
- (b) If the author labels `reject` and the gate *admits* (it never learned the
  source-binding check — e.g. it only diffs status fields against pinned facts),
  the metric counts a **correct decision for a gate that never performs
  source-binding adjudication**. Calibration score claims discernment the
  mechanism does not have. This is exactly the E1 class the round exists to
  detect: round-21's E1 passed its own bar at landing for the same reason —
  the check measured the claim's *shape*, not its evidence chain.

**Secondary counterexample — denominator minting.** Fixture row:
`feature=Vault Kubernetes auth` (or any claim whose `feature` value is not one
of the three scoped features). Grounded in S015 (TokenReview behavior is real
corpus evidence). Gate returns reject (fail closed, never reaches adjudication).
Minted ×20 and the 8:4 fixture becomes 8:24 → a gate with zero scoped
adjudication ability scores "8 bad rejected + 24 more correct rejects = 32/36".
QM13 asks for "misses and false admissions"; a single accuracy scalar hides both.

## Independent holdout design (using only the frozen corpus)

Labels must carry provenance, not authorship. Three provenance classes, all
constructible today:

1. **`authority=outside-verifier`** — the round-21 non-author adjudication
   (`corpus/lessons/round-21-verifier-spotcheck.md` §Adjudication: E1 reject,
   E3 reject — both committed in the frozen base) plus the verifier's
   3/3-agreed rejects (S008, "Broker removes every secret", "a Vault KV read
   carries a lease"). `.ufo/waves/round-22/frozen/before/expected.json` already
   pins `"outside_admission": {"E1":"reject","E3":"reject"}` — these labels are
   *not lane-authored*, which is precisely what distinguishes them. Add the
   three agreed rejects so the outside-labelled set is 5, not 2.
2. **`authority=construction-rule`** — mutations of pinned source facts where
   the label is a function of the mutation, not a judgement:
   - swap `feature` value → expect reject (status-conflation class);
   - swap `product` binding (`product=OpenBao` + `sources=[S013]` Vault page) →
     expect reject (cross-product class);
   - delete `eligibility` binding → expect reject (eligibility-omission class);
   - cite `S005` (tier C) alone for a mechanism claim → expect reject (QA1
     class — already a corpus-grounded rule, not a new author opinion);
   - **unmutated well-formed claim on a feature with no pinned binding**
     (`feature=Vault JWT login` citing S012 `bound_audiences`) → expected
     outcome is `cannot-evaluate` (exit 2 / `unjudgeable`), *scored separately*,
     never counted in either the admit or reject column.
   All four reject labels follow from the mutation rule; an implementer cannot
   argue the label was tuned to the gate.
3. **`authority=verbatim-pin`** — positive controls taken verbatim from text
   already committed or appended with source pins: E1 round-22 erratum
   (Actions public preview + S017, Business eligibility + S019; custom OIDC
   public beta + S018), E3 round-22 erratum (OpenBao 2.7.x TTL + S016; KV
   carries no lease + S013 Vault-scoped). These are admit cases whose
   *content* was not written for the fixture — re-adjudicating corpus text is a
   regression test, not an authored control.
4. **Boundary class** — CB-1 above plus the dual ("both workflows public
   preview" citing S007+S019: false proposition) kept in a `reason` column
   (`reject:false-claim` vs `reject:bar-fail` vs `reject:unjudgeable`) so a
   reject is never counted without its class.

Scoring that cannot degrade to a count: report per `(decision × defect-class)`
cells with misses (bad admitted) and false rejections (good rejected) as
separate named numbers — QM13's literal demand; `unjudgeable` reported, never
folded into either column; the case inventory frozen at integration (sha256 of
`feature-claims.json` in the ledger); post-freeze additions start a new epoch,
never silently update the score. Any new or mutated case requires blind
re-adjudication by a non-author verifier before its decision counts toward the
axis — the lane's own spot-check section already states L2 seats are the author
lane (`corpus/lessons/round-22.md:25`), so this adds no new machinery, only a
hard gate on when the number may move.

## Impacted axes

- **calibration (primary):** the C1 number is only as independent as its
  labels. As designed, `feature-claims.json` authored labels + author-picked
  composition + collapsed reject semantics reproduce the M22-2 defect at
  decision granularity.
- **freshness (secondary):** expected.json/`historical-migrations.json` are the
  freshness ledger fixtures; if the same authored-label pattern is used for the
  stamp-expectation migrations (author writes "expected" migration and counts
  it correct), C2 inherits the identical flaw. QM14's "old/new values,
  motivating correction" wording is the right shape — require the old values to
  come from `git show <rev>`/`comm` output, not retyped rows.

## Smallest safe correction

Three bounded changes to the C1 design, no new machinery:

1. **Add `label_authority` to every `feature-claims.json` row**
   (`outside-verifier` | `construction-rule` | `verbatim-pin` | `author`).
   Axis-move credit only for non-`author` labels; `author`-labelled cases are
   selftest scaffolding, reported as such, never counted.
2. **Split the reject column**: `expected` carries `reject:false-claim`,
   `reject:bar-fail`, `unjudgeable`. CB-1 (under-cited truth, `reject:bar-fail`)
   and one `unjudgeable` scoped-out claim (Vault `bound_audiences`, S012) are
   mandatory fixture rows; unjudgeable is excluded from the accuracy
   denominator and reported.
3. **Freeze the case set at integration** (sha256 recorded in
   `claim-ledger.tsv` note); score reported per cell, not one scalar; the
   outside-verifier labels in `expected.json` count only if the gate never
   consulted them at implementation time (they are already written into a wave
   fixture — keep them out of `feature-claims.json` and score them separately,
   else the "outside" label becomes another authored row).

Rejected alternative (do not adopt): deleting `expected` labels and letting
the gate self-report accuracy, or expanding the authored fixture until the
ratio looks stable. Both trade the defect for a bigger count.

## Checks for the parent after integration

- `python3 corpus/feature-claims.py --selftest` → exit 0; then run it against
  the fixture and require the printed decision table (not only the exit code)
  to show CB-1-class rows in `reject:bar-fail`, not `reject`.
- `git diff c2cab35 -- corpus/feature-claims.json | sha256sum` → record the
  fixture digest in the ledger note; later edits must bump a recorded epoch.
- `bash corpus/claim-ledger.sh cells` (after FixCellParser lands) → exit 0,
  `CELL_AUDIT: CLEAN`, and the round-20 attempt heading preserved.
- `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN`, row count now 20
  (S017–S020 landed) — `R21-02`'s `rows=16` expectation must be migrated via
  QM14-style old/new record, not edited in place silently.

## Limits

- No tool was installed; pacman untouched (host-wide pause honored). No live
  vault/account/host-private gate run; all findings from committed corpus,
  git history, and wave fixtures only.
- The feature-claims gate had not landed at read time (`/tmp/kagi-r22-
  BuildQualifierGate` has no `feature-claims.*`); the attack targets the spec
  contract (build-spec.json:214) and the in-flight lesson/QUALITY drafts. If the
  landed gate already carries reason-typed rejects or provenance-labelled
  expectations, this attack degrades to a naming requirement — still apply
  fix 1–3.
- I did not re-open S017–S020 myself; their quotes are taken from the
  uncommitted working tree, which may differ from what integrates.
- `historical-migrations.json` shows `"deleted_stamps": []` for c41af82→e1544c1
  — correct: that diff rewrote 13 pin values, deleted no members. The "nine
  dropped stamps" are the pre-c41af82 round-21 member additions plus the
  round-18 pair (verified: 7 added at c41af82, 2 at fecee87, 2 at bc1af88 —
  member-drop analysis under LC_ALL=C). C2 ownership belongs to sibling seats;
  flagged here only where the same authored-label pattern would launder C2
  expectations.

Counterexample: CB-1 under-cited truth — a true claim correctly rejected by the
amended bar, where the proposed metric either marks the correct gate wrong
(labels truth, not admission) or marks a non-adjudicating gate right. Expected
failure: "correct decisions" counted on author-labelled, author-composed cases
reproduces M22-2 at finer granularity. Required fix: provenance-typed labels,
class-split rejects with a separated `unjudgeable` column, and a digest-frozen
case inventory — the three items in §Smallest safe correction.
