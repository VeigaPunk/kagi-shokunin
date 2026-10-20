# ReopenSource07 — S007 reopen and S017–S020 feature qualifiers

Seat: `KagiR22.ReopenSource07` (leaf, read-only). Axes: **calibration, freshness**.
Assigned: reopen S007's exact URL; verify teaching and located anchor against the immutable original
row and round-22 lesson usage; examine S017–S020 feature-specific status/eligibility separately;
check original rows for immutable-field mutation. No production writes, no account/vault/host
private gates, no launcher/package-manager/loopback use. The four dead W1 scribe seats are not
credited here; this is an independent attack.

## Exact read revision and frozen inputs

| item | observed value |
|---|---|
| HEAD / measured landing under attack | `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` |
| Frozen manifest | `.ufo/waves/round-22/integration-manifest.json` |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` · 19,721 B · 86 L (matches manifest) |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` · 15,700 B · 192 L (matches manifest) |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` · 47,434 B · 995 L (matches manifest) |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` · matches manifest |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` · 43 L (matches manifest) |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` · matches manifest |
| Worktree vs HEAD | `git hash-object` = `git rev-parse HEAD:<path>` for SOURCES.md, feature-claims.json, round-22.md and feature-bound-credential-review.md; `git status --porcelain` empty for these paths |

The historical BEFORE is `c2cab35bc92e57e39e5489bac3386db078345b3f`; it is not the falsification input.
Only public documentation GETs, read-only git/hash reads, local JSON reads and the repository's own
local fixture gates were executed. No installs were needed or made.

## S007 — independent reopen (PASS)

Opened `https://www.1password.dev/brokered-access` 2026-10-20 (raw HTML, tags stripped for reading).

| check | observation |
|---|---|
| HTTP | 200, effective URL unchanged, 1,199,099 bytes |
| current digest | `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f` (stable 3/3 across default, `curl/8.13.0`, and a browser UA) |
| stored S007 Fetch hash | `e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818` (2026-10-19) — **not reproduced**; the current digest above matches S019's recorded 2026-10-20 digest |
| title | “Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)” |
| machine date | JSON-LD `dateModified` 2026-08-17T22:36:47.823Z; no displayed version/date (row wording is accurate) |

**Anchor and teaching verification.** All three row quotes are present at the named locations:

1. Introduction: “only remain accessible for the duration of the workflow” — the sentence continues
   “Every request for access is recorded in your audit log.”
2. §Custom Workflow (OIDC), inside “Add an integration”: “All configured claims must match” — full
   sentence “All configured claims must match to verify the workload’s identity.”
3. §GitHub Actions, integration-key step: “the token value is your integration key” — followed by the
   `OP_INTEGRATION_KEY` organization-secret instruction.

The registry teaching (“all configured OIDC claims to match … workflow-duration access … GitHub
organization secret for the integration key”) is directly supported. One path-specificity nuance: the
GitHub organization secret is the GitHub Actions storage method; the Custom Workflow branch instead
says to configure the same integration key as a secret retrievable at runtime (for example a GitLab
CI/CD variable). The anchor names both sections, so this is not an overclaim, but a reader must not
generalize “GitHub organization secret” to every Broker path.

**Concrete supported claim.** The three mechanisms the round-22 lesson preserves are verified on the
live guide: configured claims must all match; delivered secrets remain accessible for the workflow's
duration; and the integration key is a separate secret the workflow must receive. The lesson's
preserved-scope statement — integration-key, configured-claim and workflow-duration mechanisms remain
supported — is accurate.

**Scope limit.** The guide title's “(public preview)” is a guide-level label, not a per-feature status
for Custom Workflow (OIDC). The guide's Custom Workflow branch states setup steps but no status; the
separate custom-workflow page's H1 is the feature-status anchor. S007 must not be used as a status
oracle for both paths. That is the exact reading S019 is appended to carry.

**Immutable original row.** `git diff --numstat c2cab35..HEAD -- corpus/SOURCES.md` is **43 insertions,
0 deletions**. A line-set diff of the 21 registry rows against the frozen base shows only the added
S017–S021 rows; no S001–S016 row differs. S007's bytes including the trailing LF hash to
`f9905ea9fefcd60a3a4e212ca6634a9de9b5e9b02781dc0e4c8e420fe4c3f963` in both revisions (S006:
`1b20aaca0bba9407501c7c9dfed9e616d2f61a8e45265c84e3d1a49581295ba5`). The round-22 lesson's claim
“original S001–S016 fields did not change” is true. S019 is a new registry row for the same URL with a
narrower scope; the old row is preserved, not rewritten.

**Round-22 lesson usage.** `corpus/lessons/round-22.md:23` says S019/S020 supersede S007/S006’s
incomplete qualifier coverage while preserving the original rows; `:97` says no existing
status/recheck/used-by field changed; `:106-108` treats old Fetch hashes as historical point
observations, not current drift pins. All three statements match the tree. The S007 digest is an
unreproduced 2026-10-19 point observation; the tree does not promote it to current, and S019 records
the present byte state. Cause of the byte difference (representation versus same-day page revision) is
not determinable, but the machine `dateModified` (2026-08-17) predates both opens, so a content change
between the two fetches is [INFERENCE] unlikely; this is not called drift.

## S017–S020 — feature-specific status and eligibility, opened separately

Each URL was fetched independently on 2026-10-20; status was read at the page's own H1/title, never
from shared navigation. Quoted fragments are ≤25 words.

| row | own-page status anchor | independently verified eligibility/constraint evidence | digest |
|---|---|---|---|
| S017 `…/github-actions/` | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | Intro: “If an administrator has connected your GitHub organization to your 1Password Business account”; runtime quote “access secrets from your 1Password Environments in your organization’s GitHub Actions workflows at runtime” | 1,215,155 B; `937f6828…` matches stored; 200 |
| S018 `…/custom-workflow/` | H1 “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | Intro: “If an administrator has connected an OIDC provider to your 1Password Business account”; Step 1: “latest beta release of the 1Password desktop app”; Step 3: “Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | 1,282,825 B; `d0890c11…` matches stored; 200 |
| S019 `…/brokered-access` | Guide H1 “Set up … (public preview)” — **not used as a feature status** | Intro: “administrators can set up a supported integration in their 1Password Business account”; “Your GitHub organization must be hosted on GitHub.com.”; GHES and GHEC-with-data-residency “aren’t currently supported”; GitHub Free organizations cannot use it “for workflows in private repositories” | 1,199,099 B; `896c780b…` matches stored; 200 |
| S020 blog | “1Password Credential Broker is now in public preview” (published 2026-07-28) | Intro: “available for all Enterprise Password Manager Business customers to start using right now”; §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | 190,261 B; stored `55bf23fe…` **not reproduced** (F2); 200 |

**Separation holds.** S017 states Actions public preview. S018 states custom OIDC public beta and its
own beta-app/SDK limits. S019 supplies Business setup and GitHub deployment restrictions; its
guide-level “(public preview)” title is not used as either feature's status. S020 supplies the dated
feature split and product-level EPM Business eligibility. The same-page hazard is real in both
directions: the GitHub Actions HTML contains one “public beta” string (a related-topic link to the
custom page), and the custom-workflow HTML contains eleven “public preview” strings in shared chrome.
Whole-page substring scanning would misclassify; the typed catalog's
`release_status_anchor: page-title-H1` pin and the lesson's H1 rule are the correct reading.

**Scope limit (primary).** The custom-workflow page says “1Password Business account”, not
“Enterprise Password Manager Business”. The admitted plan value
`enterprise_password_manager_business` is bound to S020's product-level announcement sentence, not to
S018. The gate's required plan evidence is S020 for both features, and the claim scope is
`source_bounded`, so this is a bounded announcement-level inference — not a per-feature verbatim
statement. Do not strengthen it to “S018 states EPM Business.” If the parent's C1 criterion requires
per-feature plan evidence rather than product-level announcement scope, the `eligibility.plans` field
in the Broker controls is a candidate over-admission (sharper for custom OIDC, whose page states only
a Business account); if `source_bounded` product-level eligibility is accepted, it stands. The
distinction should be adjudicated explicitly, not left implicit in the field.

## C1 — executed feature-decision evidence (decisions match; one source candidate)

Local fixtures only; no network from the gate, no account/deployment.

```
python3 corpus/feature-claims.py --root . --selftest
  FEATURE_CLAIMS_SELFTEST: PASS cases=10                      exit 0

python3 corpus/feature-claims.py --root . --phase before
  10 DECISION lines, all expected
  false_claims=2 bar_failures=8 false_admissions=0 misses=0  exit 1 (expected replay failure)

python3 corpus/feature-claims.py --root . --phase after
  admitted=4 false_admissions=0 misses=0                     exit 0

python3 corpus/feature-claims.py --root . --phase boundary
  unjudgeable=3 (FC-UNKNOWN-FEATURE / FC-UNKNOWN-FIELD /
  FC-UNKNOWN-SOURCE), scored=no                              exit 2
```

The before cells include the outside-verifier E1 status-conflation and E3 cross-product records; both
reject. The four after controls admit: GitHub bounded, custom beta bounded, Vault lease and OpenBao
TTL. The manifest expectations `feature_before_rejections=10`, `feature_after_admits=4`,
`feature_selftest_cases=10`, `boundary_unjudgeable=3` are met.

**Fresh holdouts (six, under `/tmp/kagi-r22-ReopenSource07/gatehood`).** A byte-identical copy of the
pinned artifact was placed in a private root; each claim was derived from `AFTER-CUSTOM-BETA-BOUNDED`.

| mutation | observed decision | finding |
|---|---|---|
| status `public_preview` | reject:false-claim | FC-STATUS-MISMATCH |
| add plan `teams` | reject:bar-fail | FC-ELIGIBILITY-QUALIFIER |
| add requirement `github_com_org` | reject:bar-fail | FC-ELIGIBILITY-QUALIFIER |
| requirements evidence `[S019,S019-business]` | reject:bar-fail | FC-EVIDENCE-MISSING |
| status evidence `[S017,S017-title]` for custom feature | reject:bar-fail | FC-EVIDENCE-ANCHOR |
| product `openbao` | reject:false-claim | FC-PRODUCT-MISMATCH |

No false admission was found. **Limit:** the gate is closed-world. Every non-evidence field must equal
the catalog's feature values, and each evidence field must equal the feature's pinned required-reference
set exactly (`corpus/feature-claims.py:624-740`). It is a typed-record reviewer, not a prose
adjudicator; my holdouts are catalog-derived, and a source that is wrong in the same way as the catalog
would still pass. The decisions are correct; they do not establish vendor truth.

**Same-page control nuance (low).** `BEFORE-SAME-PAGE-PREVIEW` claims `public_preview` while citing
`S018-title` (public beta) and `S020-status-split`; its observed finding is `FC-STATUS-MISMATCH`, the
same barrier as the selftest's `input-same-page-status` case. The H1-only status rule is enforced as a
feature-catalog invariant (`release_status_anchor` plus a required `page-title-H1` quote), not by an
evidence-anchor test on the claim. Shared-navigation text has no quote ID, so it cannot be cited at
all. The decision is correct, but the defect label “same-page-status-anchor” overstates what the
executed record proves.

## C2 — freshness checks actually run (bounded PASS)

```
bash corpus/sources-census.sh
  SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19
  rejected=1 entries_sourced=4 legacy=21)                     exit 0

python3 corpus/revision-audit.py --selftest
  REVISION_AUDIT_SELFTEST: PASS (cases=11 failed=0)           exit 0

python3 corpus/revision-audit.py --root . --history 8ada17a…
  REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0
  added=0 invalid=0)                                          exit 0
```

- `corpus/stamps.tsv:60` records `corpus/SOURCES.md 3ba44518… 86 19721`; the file matches exactly.
- Nine-line span `aea7a4301 → e1544c194fddf1bb073b3946847b4526f326ad73`: `corpus/stamps.tsv`
  56→63 rows, first-column **removed=0**, added=7; `corpus/claim-ledger.tsv` 49→54, **removed=0**,
  added=5. The nine “deleted” diff lines are replacements: all nine `old`/`new` stamp records in
  `.ufo/waves/round-22/round21-migrations.json` byte-match the two declared git revisions (9/9), all
  nine paths persist in both revisions' `stamps.tsv`, and the same artifact's five rewritten claim
  rows byte-match (5/5). `removed_members` is `[]`, consistent with the measured set difference.
- The census expectation migration is documented, not silent:
  `.ufo/waves/round-22/pin-migrations-integration.json:434-436` carries R21-02
  `rows=16 … entries_sourced=3` → `rows=21 … entries_sourced=4`, matching the current clean census.
- Limit: the audit's `--history` dropped check against HEAD is a self-comparison; the historical
  dropped-member check is the set difference above. The BEFORE red state (six stale records) was not
  rerun in this seat; it remains the recorded `before.json` / `before-runnable.json` evidence.

## Findings

### F1 — S007's catalog bindings overreach the guide title (low, calibration; currently inert)

`corpus/feature-claims.json:49-53` binds `S007-guide-title` to
`op_cb_github_actions.feature`, `op_cb_custom_oidc.feature` and
`op_cb_custom_oidc.path = brokered-access/custom-workflow`. The title names neither feature nor a docs
path; it is the setup-guide title. The same shape appears in S019/S020 (`:157,159,162,185-186`).
Current decisions are unaffected: the required feature/path references are the S017/S018 title quotes
(`:232-239,259-265`), and the only records citing `S007-guide-title` are `release_status` records
(`:350,452`), where S007 has no `release_status` binding. Both reject earlier — on status value or
required-reference-set mismatch — so the overbroad bindings are inert. Removing them or re-anchoring
them to the feature titles would close a latent path where a future evidence-requirement edit could
admit a guide-title citation for a feature/path. The catalog is pinned; any edit requires the normal
re-pin and report.

### F2 — S020's recorded digest is not reproducible (medium, freshness)

Stored `55bf23fe…`; five independent GETs today produced five distinct hashes, for example
`09d983e9…`, `08cc4100…`, `2b09a02c…`, `f2c32dcc…`, all 190,261 bytes. The diff between two fetched
copies was confined to a rotating Cloudflare `/cdn-cgi/l/email-protection#…` token; both semantic
quotes are present in each fetch. The digest is a point observation, not a drift pin. Proposed: label
it as such in the typed artifact, or adopt the content-scoped pin/method recorded in the build
evidence; do not treat a changed raw hash as semantic drift. No gate decision depends on it (the gate
never fetches source URLs).

### F3 — missing same-URL `prior_registry_sha256` on S019 and S020 (medium, freshness/accounting)

S021 carries `prior_registry_sha256: c083fdca…` (S016's digest) and S013 carries `ae321512…`. S019
(`:141`) and S020 (`:170`) have no prior pin, although the prose says they supersede S007/S006 and the
old rows/digests remain in `SOURCES.md` and the typed catalog. Nothing is deleted; the machine-readable
old→new link is asymmetric. Proposed: add the prior pins or record the intentional exception in the
lesson. Do not rewrite S006/S007.

### F4 — locator understates available build metadata (low)

The guide and custom pages carry JSON-LD `dateModified` 2026-08-17; the Actions page 2026-08-04.
“No displayed version/date” is accurate, but recording the machine build stamp as a non-semantic bound
would make later fetches comparable without claiming vendor truth. It also supports the [INFERENCE]
that the S007 digest change is representation, not content. Optional.

## Verdict

- **S007: PASS.** Exact URL, title, all three quotes and both section anchors reproduce; the teaching
  is supported with a documented path-specific nuance; the original row is byte-identical; the
  round-22 supersession is correctly limited and the old row is preserved. Its 2026-10-19 Fetch hash is
  an unreproduced point observation, not a currentness claim.
- **S017–S020: PASS on feature-specific status/eligibility.** Four separate pages support four separate
  readings; the typed catalog encodes the split, the Business prerequisites, the GitHub deployment
  exclusions and the beta app/SDK constraints. The E1 status-conflation is verified rejectable on live
  source facts here; the E3 cross-product barrier is exercised by the gate, but its OpenBao/Vault
  source facts are outside this seat's reopen. The candidate over-admission is the product-level
  (S020) plan attribution shared by both Broker controls, sharper for custom OIDC and flagged above
  for explicit adjudication.
- **C1: PASS on executed decisions, with one source-attribution candidate.** 10/10 before rejections,
  4/4 after admits, 3 unjudgeable boundaries, and six fresh holdouts rejected with the expected
  barriers; no false admission was observed in the exercised records. The mechanism is a closed-world
  typed checker, and the S020 plan attribution for the Broker controls (sharper for custom OIDC)
  remains a candidate over-admission for parent adjudication rather than an executed failure. The
  same-page label overstates one exercised rule.
- **C2: bounded PASS.** Current stamp, census and revision audit are clean; the nine replaced stamp
  lines and five rewritten expectations are preserved with byte-exact old/new evidence in the declared
  revisions; no membership deletion. F2 (unstable S020 digest) and F3 (missing prior pins) are
  accounting gaps, not deletions; F1 is a latent calibration binding. No decision depends on any of
  them.
- No score move is claimed; the axes remain candidate 9 pending the parent's full-wave adjudication.

## Limits

- Public documentation GETs only; no account, workflow, SDK, vault, deployment or authenticated
  endpoint. No loopback/CDP/health probe, no launcher, no package manager, no install.
- HTML was read without JavaScript execution; tags were stripped for reading. Digests are raw-response
  observations and representation-dependent; `dateModified` is vendor-declared, not authenticated.
- The feature gate is a closed-record reviewer with inert source URLs; executing it proves control
  behavior, not vendor currentness.
- The build wave's advisory reports were not used as the under-attack input; the frozen manifest and
  HEAD were.
- The historical BEFORE `c2cab35…` was used only for the immutable-row comparison, not as a runnable
  falsification input.

## Parent checks to run after integration

1. `python3 corpus/feature-claims.py --root . --selftest` then `--phase before|after|boundary`.
2. `bash corpus/sources-census.sh` (expect `rows=21 … entries_sourced=4`).
3. `python3 corpus/revision-audit.py --selftest` and
   `python3 corpus/revision-audit.py --root . --history <landing-oid>`.
4. If F2 is corrected, re-pin `PINNED_SOURCES_SHA256`/`PINNED_REVIEW_SHA256` deliberately and re-run
   the feature gate; do not restamp only to make the run green.

---
Report path relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`:
`.ufo/waves/round-22/falsify/ReopenSource07.md`. Exact read revision:
`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`. No production file was written.
