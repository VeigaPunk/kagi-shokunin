# ReopenSource05 — S005 reopen, S017–S020 feature separation, revision accounting

Seat `KagiR22.ReopenSource05` (scout, leaf; no subagent dispatch). Axes:
**calibration (C1)** and **freshness (C2)**. Read 2026-10-20 against the frozen
integrated tree. Public documentation GETs and owned local fixture executions
only; no production edit, no lane jj/Git mutation, no account/vault/secret
operation, no launcher/package tool, no loopback/health/CDP probe, no
installation. Four dead W1 scribe seats remain **uncredited**; this is an
independent attack item, not a replacement.

## 1. Exact revision and frozen inputs

| item | observed |
|---|---|
| integrated HEAD | `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` |
| tree | `d12afd7a545e86f21eb9acac567d10de774df50f` |
| manifest | `.ufo/waves/round-22/integration-manifest.json` = `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` |
| historical BEFORE | `c2cab35bc92e57e39e5489bac3386db078345b3f` (not the attack input) |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` · 86 L · 19,721 B |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` · 192 L · 15,700 B |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` · 10 L · 1,804 B |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` · 69 L |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` · 58 L |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` |
| `corpus/sources-census.sh` | `03fb300a74157232978525c6bc4b028d7ed9159bccbb47d32333deb48ba76b3c` |

`git status --porcelain` at read time showed only wave scaffolding under
`.ufo/`; no manifest-listed production input is modified. Every digest above
equals the manifest entry.

## 2. S005 reopen — exact URL, teaching, anchor, immutability

URL: https://1password.com/product/credential-broker — public GET 2026-10-20.
The page has no displayed article version/date; its H1 is
“Machine and AI agent credential runtime access”. The row's anchor is present
as an H3:

| anchor | observed text (≤25 words) | location / date |
|---|---|---|
| §The platform identifies the job | “Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for.” | H3 under “Keep credentials out of pipelines”, https://1password.com/product/credential-broker, 2026-10-20 |

The row's teaching — workload identity checked against policy before approved
credential delivery — is supported verbatim. The row remains **tier C,
status `queued`, used-by `—`**; it is not cited by
`corpus/lessons/round-22.md` (whose source line and Gate cover S017–S020 and
whose OpenBao note covers S021) or by
`corpus/knowledge/feature-bound-credential-review.md` (S017–S021). So round-22
lesson usage of S005 is **none**: it stays a lead, correctly not promoted.

**Immutable-row check:** the S005 row is byte-identical between
`c2cab35bc92e57e39e5489bac3386db078345b3f` and HEAD: 819 bytes, SHA-256
`1ba27291504fc63beef8e6cdb7e3ade09cc315c6ff3bd9f0566511a55b9ce274`. More
broadly, all S001–S016 rows and the registry header are byte-identical; the
registry diff is S017–S021 added, zero rows removed, zero original rows
changed.

### Concrete supported claim (S005)

The S005 row is correct at its exact anchor: the quoted sentence is present
verbatim under “The platform identifies the job”, the page still displays no
version/date, and the row's explicit “lead, not mechanism authority” limit is
appropriate. No round-22 claim rests on it.

### Scope limit (S005, required)

S005 is product positioning, not feature-status or eligibility authority. Its
FAQ now says, under “Is 1Password Credential Broker generally available?”:
“currently in public preview for all Enterprise Password Manager customers,
starting with GitHub Actions, and custom OIDC configurations” (same URL,
2026-10-20). That product-level sentence **lumps custom OIDC under public
preview**, while S018's own H1 says public beta and S020's dated split says
beta. It also says “Enterprise Password Manager customers”, not “Business”.
The corpus's feature-specific-H1 rule resolves the conflict, and S005's
`queued`/unused state means no integrated claim is infected; but the row's
scope text says only “not configuration mechanics”, not “not per-feature
status”. If S005 is ever promoted, add that explicit prohibition and never
cite the FAQ sentence for status. No production edit was made.

## 3. S017–S020: feature-specific status and eligibility, separately

Each page was reopened independently on 2026-10-20; status, eligibility and
setup conditions are kept apart. Quotes are ≤25 words.

| row | status carried by its own page | eligibility/setup carried by its own page |
|---|---|---|
| S017 https://www.1password.dev/brokered-access/github-actions/ | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” + “Public Preview” badge | introduction “If an administrator has connected your GitHub organization to your 1Password Business account”; Step 1 “make sure you have the latest version of the 1Password desktop app”; Get help requires `id-token: write` |
| S018 https://www.1password.dev/brokered-access/custom-workflow/ | H1 “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” + “Beta” badge | introduction “connected an OIDC provider to your 1Password Business account”; Step 1 “latest beta release of the 1Password desktop app”; Step 3 note “Credential Broker is only supported in the 1Password JavaScript SDK at this time.” |
| S019 https://www.1password.dev/brokered-access | guide H1 “… (public preview)”; **guide-level label only** | “administrators can set up a supported integration in their 1Password Business account”; GitHub.com only; “GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren't currently supported.”; GitHub Free private-repository workflows excluded |
| S020 https://1password.com/blog/1password-credential-broker-public-preview, published 2026-07-28 | §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | introduction “available for all Enterprise Password Manager Business customers to start using right now” |

Independent result: **no uniform Broker status is supported**. S017 is
public preview, S018 is public beta, S019's guide title does not determine
S018's status, and S020's split is announcement-time (2026-07-28), not a live
status oracle. The rows' `teaches` sentences match the pages. The typed catalog
keeps the separation mechanical: S017 status evidence = S017-title +
S020-status-split; S018 status evidence = S018-title + S020-status-split;
S019 supplies Business/GitHub requirements and exclusions (plus product/path
bindings), not release status; S020 supplies
the dated split and the plan phrase.

No immutable-field mutation: S017–S020 are new A/mined rows; S001–S016 rows,
including S005/S006/S007 status/recheck/used-by fields, are unchanged. S019 and
S020 carry the supersession notes; S006/S007 are preserved.

## 4. C1 calibration — executed decisions, not authored row counts

Against the frozen tree (authorized local fixtures; no network):

| command | observed | exit |
|---|---|---|
| `python3 corpus/feature-claims.py --phase before` | 10/10 expected decisions matched: 2 `reject:false-claim` (E1 status conflation; same-page preview anchor), 8 `reject:bar-fail`; `false_admissions=0 misses=0`; each cell `matches=1` | 1 (intended) |
| `python3 corpus/feature-claims.py --phase after` | `CLEAN phase=after admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0 unjudgeable=0` | 0 |
| `python3 corpus/feature-claims.py --phase boundary` | 3 `cannot-evaluate` (unknown feature, unknown field, unknown source), `unjudgeable=3 scored=no` | 2 (intended) |
| `python3 corpus/feature-claims.py --selftest` | `PASS cases=10` | 0 |

The known E1/E3 overclaims are rejected; the four pinned bounded controls are
admitted with zero false admissions. This is a per-record decision result, not
an accuracy scalar and not outside agreement.

### Held-out `--input` controls (private `/tmp/kagi-r22-ReopenSource05` clone)

16 independent typed claims built from the unchanged catalog; no production
file written. Results:

- **Admitted (5):** exact custom-OIDC bounded; exact GitHub-Actions bounded;
  exact OpenBao TTL bounded; OpenBao `release_status=not_asserted`; custom
  status evidence reordered (set semantics confirmed).
- **Rejected (9 bar-fail + 2 false-claim):** custom OIDC claimed public
  preview → `FC-STATUS-MISMATCH`; GitHub exclusions dropped →
  `FC-ELIGIBILITY-QUALIFIER`; custom SDK scope reduced →
  `FC-RUNTIME-CONSTRAINT`; custom status announcement-only →
  `FC-EVIDENCE-ANCHOR`; custom plan value changed → `FC-ELIGIBILITY-QUALIFIER`;
  custom eligibility omitted → `FC-ELIGIBILITY-QUALIFIER`; custom fact replaced
  with OpenBao fact → `FC-FACT-UNSUPPORTED`; GitHub citing a Vault source →
  `FC-CROSS-PRODUCT`; custom plan cited S006 instead of S020 →
  `FC-EVIDENCE-MISSING`; GitHub business requirement cited S017 instead of
  S019 → `FC-EVIDENCE-MISSING`; custom `not_asserted` on an asserted-status
  feature → `FC-STATUS-MISMATCH` (classification nuance; still a reject).
- **Zero false admissions.**

### C1 scope limit (required)

Admission is **exact-pinned-citation-set** admission, not semantic
equivalence. Two equally authoritative bounded controls were rejected:

1. custom-OIDC plan cited `S006-eligible` (“available for all Enterprise
   Password Manager Business customers”) instead of `S020-epm-plan`; same bound
   value, same product, rejected `FC-EVIDENCE-MISSING`.
2. GitHub business requirement cited `S017-business` instead of
   `S019-business`; same bound value, same product, rejected
   `FC-EVIDENCE-MISSING`.

The code requires `reference_set == required_references`
(`corpus/feature-claims.py:733-738`), so only the pinned route admits. This is
a disclosed closed-record limit, not a false admission; it bounds “admits
correctly bounded controls” to the reviewed catalog. Proposed correction: keep
the exact-set guard (it is what prevents guide-only evidence from admitting)
and state in the review's limits that admission is catalog-relative. A second,
smaller nuance: an unasserted-status claim on an asserted feature is classified
`false-claim` rather than `bar-fail`, though both are rejects.

### Additional source-model limits

- **S017 setup constraints are not in the catalog.**
  `op_cb_github_actions.runtime_constraints` is empty, while the page's Step 1
  requires the latest desktop app and Get help requires `id-token: write`.
  A source-faithful claim adding either is rejected by exact set equality.
  This is a false-reject risk, not a false admission. Proposed correction:
  after reopening, add the two constraints to the Actions record with one
  admitting control and one omission negative, or record why they are
  deliberately outside the model.
- **Plan-label equivalence is unsourced.** The catalog uses
  `enterprise_password_manager_business` for both features, sourced from the
  product-level S020 sentence. The feature pages say “1Password Business
  account”, S005's FAQ says “Enterprise Password Manager customers”, and S020
  says “Enterprise Password Manager Business customers”. No opened page maps
  those labels to one entitlement; the inference is plausible but not
  feature-scope sourced. Proposed correction: cite a plan-mapping source, or
  split the product-level plan phrase from the feature-scope requirement.

No production correction was made; both are proposed for the owner.

## 5. C2 freshness — nine rewrite lines, six stale pins, exact migrations

### 5.1 “Nine previously dropped stamps” are nine rewrites, zero drops

Between `aea7a4301` and `e1544c194fddf1bb073b3946847b4526f326ad73`:

- `git diff --numstat` on `corpus/stamps.tsv` = **16 added / 9 deleted** lines.
- First-column member set: **56 → 63**, **0 removed**, **7 genuinely added**
  (`QUALITY.md`, `SOURCES.md`, `sources-census.sh`, three knowledge entries,
  `lessons/round-21.md`).
- The 9 deleted lines are exactly the 9 `changed_stamp_records` in
  `.ufo/waves/round-22/round21-migrations.json`; each old and new line is
  byte-identical to `git show` at its revision (checked field-for-field). Same
  9 paths, fresh pins; no member disappeared.
- Claim-ledger span: **10 added / 5 deleted**; 5 changed rows
  (`R12-02`, `R12-03`, `R13-01`, `R13-02`, `R14-01`), 4 new R21 rows plus one
  comment line; **0 removed ids**.
- Exact historic expectation changes preserved:
  `R12-02 29→36`, `R12-03 56→63`, `R13-01 20→23`,
  `R14-01 21/18→24/21`; `R13-02` note-only, expectation stays 35.
  `historical-migrations.json` separately preserves `R21-03 40→47` and
  `deleted_stamps: []`.

So the outside reviewer's nine deleted diff lines were real **rewrites**, not
nine lost members. No silent deletion or laundering found.

### 5.2 Six stale pins at the starting revision, reconciled

`before.json` and `before-runnable.json` both record six stale stamps at
`c2cab35bc92e57e39e5489bac3386db078345b3f`, exit 1:
`LOG.md`, `corpus/knowledge/config-layering.md`,
`corpus/knowledge/handler-on-disk-state.md`,
`corpus/knowledge/handler-trust-boundary.md`,
`corpus/knowledge/janitor-env-contract.md`, `corpus/lessons/round-18.md`.
I independently re-derived those six from `pin-migrations-integration.json`:
of its 38 `stamp_changes`, 6 are absent-at-base additions, 32 are changes,
and exactly the same six old stamps disagree with their recorded
`base_observed` tuple. The sixth stale pin beyond the outside verifier's five
(the extra `LOG.md` mismatch) is therefore on the record, not hidden.

### 5.3 Current state and migrated expectations

- `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`
  → `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`,
  exit 0. Six additions: `feature-claims.json`, `feature-claims.py`,
  `feature-bound-credential-review.md`, `round-21-verifier-spotcheck.md`,
  `round-22.md`, `revision-audit.py`; **0 dropped**.
- `python3 corpus/revision-audit.py --selftest` → `PASS (cases=11 failed=0)`.
- `pin-migrations-integration.json` records 63→69 members, 38 stamp changes
  (6 added + 32 changed), 0 removed; every `new_stamp` matches the current
  file's SHA-256, newline count and byte count; every changed `old_stamp`
  matches the base row; `claim_changes` = 12, each old/new row preserved.
- Executed current expectations (all match):
  `stamps.tsv` non-blank = **69**; `SCORECARD.md` `## Round ` headings = **25**;
  `grep '^R1' claim-ledger.tsv` = **35**; `claim-ledger.sh docs` =
  `entries=25 row_linked=22 by_hand=3`; `claim-ledger.sh --selftest` =
  `PASS (108 cases)`; `sources-census.sh` =
  `CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)`;
  `sources-census.sh --selftest` = `PASS (47 cases)`;
  `claim-ledger.tsv` row count = **43**; `op-ref-probe.sh --selftest` =
  `PASS (36 cases)`; feature before/after/boundary/selftest as §4;
  revision audit as above.
- `R21-01` (`op --dotenv-bytes`) was **not executed** (op/account-dependent,
  host-private surface); it is not claimed.

**C2 verdict: holds.** The nine deleted diff lines are accounted rewrites,
the six stale pins are exactly recorded and repaired, current membership has
zero stale/missing/dropped, and every migrated ledger expectation I executed
matches the frozen tree. Restamping proves pointer integrity only; it does not
prove vendor currentness, and no such inference is made.

## 6. Required deliverables

**Concrete supported claim:** S005's exact URL and §“The platform identifies
the job” anchor carry the quoted identity-check-before-delivery sentence
verbatim; the row is correctly tier C/queued and the S001–S016 immutable rows
are byte-identical to base.

**Scope limit:** S005 is not feature-status authority — its product FAQ lumps
custom OIDC into “public preview”, contradicting S018's public-beta H1 and
S020's dated split, and its plan wording omits “Business”. The feature-specific
H1 rule and S005's unused state contain the risk; promotion would require an
explicit “not per-feature status” clause.

Additional bounded limits: exact-pinned-citation admission rejects equally
authoritative alternate citations; S017's desktop-app and `id-token: write`
prerequisites are not modelled; the EPM/Business plan-label mapping is
unsourced; S005 and S020 raw HTML hashes are per-request non-deterministic
(historical point observations, as the lesson already says).

## 7. Limits and non-claims

- One source row (S005) reopened plus S017–S020 and the S020 announcement;
  public documentation only. No 1Password account, vault, integration,
  workflow, secret or entitlement was exercised.
- The gate's “admit” is catalog consistency, not vendor truth; `verbatim-pin`
  and `construction-rule` authority labels are provenance, not outside
  agreement.
- S017–S020 page digests were not re-derived here beyond the S005/S020
  non-determinism check; the peer reports cover S017/S018 raw-HTML digests.
- I did not run `op`-dependent rows, `claim-ledger.sh verify`, or any
  host-private gate. No depth move and no legacy-header count claim is made;
  census counts are consistency checks only.
- No installations occurred; no production file was edited. The only writes
  are this report and the private `/tmp/kagi-r22-ReopenSource05` fixtures.

## 8. Checks the parent should run after integration

- `python3 corpus/feature-claims.py --phase before` → 10 rejects, exit 1.
- `python3 corpus/feature-claims.py --phase after` → 4 admits, exit 0.
- `python3 corpus/feature-claims.py --phase boundary` → 3 unjudgeable, exit 2.
- `python3 corpus/feature-claims.py --selftest` → `PASS cases=10`.
- `python3 corpus/revision-audit.py --history c2cab35…` → `CLEAN (… added=6 …)`.
- `python3 corpus/revision-audit.py --selftest` → `PASS cases=11`.
- `bash corpus/sources-census.sh` → `CLEAN (rows=21 … entries_sourced=4 legacy=21)`.
- `bash corpus/sources-census.sh --selftest` → `PASS 47 cases`.
- `bash corpus/claim-ledger.sh --selftest` → `PASS 108 cases`.
- `bash corpus/claim-ledger.sh docs` → `entries=25 row_linked=22`.
- `bash corpus/op-ref-probe.sh --selftest` → `PASS 36 cases`.

Installations: none.

Trailer: `.ufo/waves/round-22/falsify/ReopenSource05.md`
