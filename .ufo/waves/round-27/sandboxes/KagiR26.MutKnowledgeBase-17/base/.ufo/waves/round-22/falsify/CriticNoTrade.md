# Round 22 falsification — pin migration vs. semantic freshness, C1 prose-inference probe

Axes: **calibration**, **freshness**. Lane: leaf member; no subagent dispatch.
Read revision: integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (master tip at read time); frozen inputs verified against `.ufo/waves/round-22/integration-manifest.json` sha256/line/byte triples. No production edits, no host gates, no installs.

## Verdict

**Holds-with-limit.** C2's bookkeeping conclusions survive a fresh attack; the audit, memberships, and every journaled migration reproduce exactly. C1's gate holds no broader prose claim and I found no admission hole in the evaluator. One concrete defect stands: a false provenance record inside the C2 migration journal itself (F1 below), plus two smaller catalog-hygiene observations (F2, F3).

## F1 — Defect: `base_observed: null` for a file that existed at the frozen base

`kagi-shokunin/.ufo/waves/round-22/pin-migrations-integration.json` records
`corpus/lessons/round-21-verifier-spotcheck.md` with `old_stamp: null` and
`base_observed: null` — the same shape used for the five genuinely new files
(feature-claims.py/.json, revision-audit.py, feature-bound-credential-review.md,
round-22.md).

Exercised contradiction:

- `git merge-base --is-ancestor 1e9e67f c2cab35…` → **true**: integrator commit
  `1e9e67f` (the round-21 verifier spot-check) is inside the frozen base.
- `git show c2cab35…:corpus/lessons/round-21-verifier-spotcheck.md` → 2468 bytes,
  17 lines, sha256 `6e4fa622ae953f343c294e3ce401303b6b6fa377e8800f9164047b08711f1ffb`
  — byte-identical to the current file and to the sha cited by the two
  `outside-verifier` authority records in `corpus/feature-claims.json`.
- `git show c2cab35…:corpus/stamps.tsv` → 63 members; the file is absent.

So the file is not an "ADDED member" in the sense the other five are: it existed at
base, authored by the integrator (QM5 lag — an artifact committed without its stamp),
and round-22 retro-pinned it. The migration record's `null` pair erases that
provenance. A reader diffing this journal cannot distinguish "file absent at base"
from "file present but unpinned at base" — and cannot see that the artifact the
C1 `outside-verifier` authority labels point at was itself an unpinned integrator
write. This is the laundering-adjacent shape QM14 exists to prevent, even though the
omission is almost certainly sloppy bookkeeping rather than intent.

**Smallest safe correction (not applied — frozen wave):** in
`pin-migrations-integration.json`, set `base_observed` to
`{"sha256":"6e4fa622…","lines":17,"bytes":2468}` and change the entry's disposition
to note "pre-existing unpinned artifact (integrator commit 1e9e67f); stamp added in
round 22". Optionally add a `new_member_kind: "retro-pinned"` field to separate it
from the five authored-this-round files. The lessons text should name the
retro-pin in one sentence next to the six additions list (§Revision accounting).

## F2 — Minor: catalog over-bindings are schema-permitted but semantically loose

`_validate_feature_catalog` (feature-claims.py:468) checks
`expected_values ⊆ observed_values` one-way. Verified instances where a source
binding carries a value the quote text does not literally support:

- `S019` quote `S019-business` ("a supported integration in their 1Password
  Business account") is bound to `op_cb_custom_oidc`/`eligibility.requirements`
  with **both** `business_account_connected` and `oidc_provider_connected`. The
  OIDC-provider value is not in that quote's words.
- `S020-status-split` binds `public_beta` for `op_cb_custom_oidc` from the quote
  "…we're slowly rolling out a new capability in beta: custom OIDC workflows." —
  defensible ("in beta" is present, "public beta" is not), disclosed below.

No admission hole: an admissible claim must equal the feature's exact typed values,
and extra bound values never reach a decision. But the pinned catalog can silently
accumulate unsupported binding values under the subset rule. Correction: enforce
`expected == observed` per (feature, field, quote) at catalog-validate time, or add
a literal-substring audit binding `value` → quote text vocabulary. Low impact; the
author asserts the catalog anyway (declared limit).

## F3 — Minor: boilerplate dispositions

All 38 `stamp_changes` entries share one identical disposition sentence
("Reviewed current round-22 artifact; historical source facts remain historical…").
Per-member motivating reasons exist in `corpus/lessons/round-22.md` §Revision
accounting for the nine round-21 replacements, but the six stale-at-base members and
the 20+ coincident restamps carry no member-specific note in the journal itself.
QM14 is satisfied in substance (old/new values exact and verified — see below),
but the record will read as formulaic to an outside reviewer.

## What was re-exercised and holds

Freshness (C2), all re-derived from git objects, not from the build reports:

- **Six (not five) stale at base, reproduced independently.** For each of the 63
  base stamp rows I hashed `git show c2cab35…:<path>`: exactly LOG.md plus the five
  named files (config-layering, handler-on-disk-state, handler-trust-boundary,
  janitor-env-contract, round-18.md) mismatch — `stale=6`, `missing=0`, `dropped=0`,
  matching `before.json` and `before-runnable.json`. Every stale file's last base
  commit is a documented correction (f4a8dd9 errata, bad9088 erratum, e1544c1/c2cab35
  LOG appends) — the drift cause is explainable, not concealed.
- **"Nine dropped stamps" = nine replacements, zero removals.** Set difference of
  `aea7a4301` vs `e1544c19` first columns: removed = ∅, added = 7 (round-21 set),
  changed = 9 members; unified-diff deletion lines = 9. `round21-migrations.json`
  old/new values match the two revisions byte-for-byte.
- **Current integrated tree is CLEAN and pin-honest.**
  `python3 corpus/revision-audit.py --history c2cab35…` on the working tree →
  `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0 —
  reproduces `integration-pin-check.json` and manifest `expected.revision_audit`.
  All 69 current stamps.tsv pins re-verified against live bytes (sha256/lines/bytes,
  zero mismatches); membership = 63 base + 6 additions; removed = ∅.
- **Every claim-ledger migration is journaled and accurate.** Diffing the TSV at
  `c2cab35` vs working tree: 8 changed rows (R11-09, R12-03, R13-01, R14-01,
  R18-02, R18-03, R21-02, R21-04), 4 added (R22-01…04), 0 removed. All 12 appear in
  `pin-migrations-integration.json claim_changes` with old/new strings byte-identical
  to the actual rows. No unjournaled expectation rewrite.
- **LOG.md history preserved.** The journal's `old_stamp` keeps the stale round-21
  pin (`60a8fd36…/1043/74864`) while `base_observed` records the actual base bytes
  (`51e76cf1…/1050/75404`) — exactly the honest shape the C2 claim needs.
- **No semantic-freshness overclaim found.** SCORECARD (9→9 both axes), R22-03's
  note ("No source-currentness or host/vault inference"), lessons ("Restamping
  proves pointer integrity only"), and feature-bound-credential-review.md
  ("a revision stamp proves local-byte identity, not that historical host files or
  deployed behavior are current") all keep the pointer/currentness boundary explicit.

Calibration (C1), re-exercised by reading evaluator + artifact:

- Mechanism is closed-vocabulary typed adjudication: claim `fact` must be a member
  of the feature's `facts` list (FC-FACT-UNSUPPORTED), values must equal catalog
  values exactly, evidence reference sets must equal `evidence_requirements` exactly
  (under- and over-citation both rejected), source product must equal feature
  product (FC-CROSS-PRODUCT), preview/beta status is bound to a `page-title-H1`
  anchored quote (FC-STATUS-ANCHOR-PIN at catalog load). The "same-page status"
  counterexample (BEFORE-SAME-PAGE-PREVIEW) is rejected at `FC-STATUS-MISMATCH`
  before evidence is even consulted.
- `repaired-checks.json` before-phase parses to 10/10 correct rejections
  (2 `reject:false-claim`, 8 `reject:bar-fail`, 0 false admissions/misses/
  unjudgeable); after-phase admits the 4 controls; boundary returns exit 2 for the
  3 unjudgeable records — all matching manifest `expected`.
- Outside-verifier record sha256s point at the real spotcheck file (verified).
  `verbatim-pin` AFTER records anchor to the new active-review file's table rows.
- Prose-inference limit holds: `review.limits` declares typed-record-only scope;
  the knowledge file and QM13 repeat "not arbitrary prose or vendor truth." No
  document I inspected upgrades the 4-control admit into an accuracy scalar or
  outside agreement. No C1 claim rests on stamp state (`pin-only-ablation` isolation
  is honest: it restamped only the isolated clone).
- Residual limit worth naming: `prior_registry_sha256` on S013/S021 encodes the
  older captured digests (`ae321512…` = SOURCES.md S013 fetch hash; `c083fdca…` =
  S016's fetch hash for the same OpenBao tokens URL under the old row id). The
  re-observed 2026-10-20 digests differ (`de5f8836…`, `52295218…`), meaning the
  pinned catalog binds claims to **new captures** while registry rows still carry
  the **old** fetch hashes. Disclosed by lessons ("Fetch hashes are unrepeatable
  point observations"), but the quote-level semantics in the artifact are only as
  current as the author's 2026-10-20 capture; a different document version could
  support the same pins. This is an honesty limit, not a defect — the artifact
  never claims content equality across observations.

## Limits of this review

- Did not fetch or reopen any public page; source quotes are trusted as pinned
  capture text, so binding-value literal consistency (F2's S019 over-binding) is
  judged only against the quote text stored in the artifact.
- Did not rerun `claim-ledger.sh` selftest, `sources-census.sh`, or the cells/
  checklist gates (sibling seats cover those); my audit run was the one explicitly
  relevant read-only command plus `git show` byte comparisons.
- Did not inspect `corpus/claim-ledger.sh` stamp-write implementation for
  silent-prune paths; membership fact was established by TSV set diff instead.
- `.ufo/waves/round-22/falsify/` sibling reports and `safe-row-plan.json` were
  written during my pass; I did not cross-dedupe beyond noting SentinelClaimInput's
  FIFO finding, which is orthogonal to F1–F3.

## Reported blocker: none. Installs: none.
