# ReopenSource17 — S017 Credential Broker GitHub Actions runtime

Seat `KagiR22.ReopenSource17` (scout, leaf). Axes: **calibration (C1)** and
**freshness (C2)**. Assigned source row: `corpus/SOURCES.md` S017.
Read 2026-10-20 against the frozen integrated tree; public documentation GETs
and integrated-tree fixture executions only. This is an independent attack
item, **not** a replacement for any dead W1 seat; no W1 credit is claimed and
the four missing W1 scribes remain uncredited.

## 1. Frozen input identity and exact read revision

| item | observed value |
|---|---|
| Historical BEFORE base | `c2cab35bc92e57e39e5489bac3386db078345b3f` (not the attack input) |
| HEAD read | `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, tree `d12afd7a545e86f21eb9acac567d10de774df50f` |
| Landing subject | `round-22: feature-bound review capability and audited revision repairs` |
| `.ufo/waves/round-22/integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` · 86 lines · 19721 bytes |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` · 995 lines · 47434 bytes |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` · 1040 lines · 45532 bytes |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` · 192 lines · 15700 bytes |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` · 43 lines · 4440 bytes |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` · 10 lines · 1804 bytes |

Every code/docs/data input read here matches the manifest digest above.
`git status --porcelain` at read time showed only wave scaffolding
(`.ufo/waves/round-22/falsify*`, `safe-row-plan.json`); no production input was
modified. No lane revision was inferred from detached HEAD. No installation
was performed (nothing was missing), and no loopback/health/CDP probe,
launcher, package transaction, account or vault operation occurred.

## 2. S017 reopen — exact URL, teaching, located anchor

URL reopened twice on 2026-10-20: raw HTML at
`https://www.1password.dev/brokered-access/github-actions/` and the docs-site
alternate at `.../github-actions.md` (public GET only).

| representation | SHA-256 | bytes | vs. catalog `937f6828…0849` |
|---|---|---|---|
| raw HTML `curl -sSL` | `937f6828883599d23c736ae8df57daaa60fd30295c3a300b226caa4ceed10849` | 1,215,155 | **exact match** |
| alternate markdown | `092fd0ba581cbb60eaf756e853d8659c15b76e17dd616c23aff8137ef42c6d0f` | 5,245 | different representation (expected) |

Anchors claimed by the row are **“Page title and introduction”**. Both are
present in the HTML and the markdown alternate:

| anchor | exact text (≤25 words) | location / URL / date |
|---|---|---|
| page title H1 | “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | H1, https://www.1password.dev/brokered-access/github-actions/, 2026-10-20 |
| badge | “Public Preview” | top badge, same page, 2026-10-20 |
| introduction | “If an administrator has connected your GitHub organization to your 1Password Business account” | introduction, same page, 2026-10-20 |
| Step 1 | “make sure you have the latest version of the 1Password desktop app” | Step 1, same page, 2026-10-20 |
| Get help | “make sure you have `id-token: write` set in the `permissions`” | Get help, same page, 2026-10-20 |

**Row teaching verdict: supported as written.** “GitHub Actions is public
preview” is carried by the feature's own H1 and badge, not by the setup guide.
“an administrator first connects the organization to a 1Password Business
account” is carried by the introduction's conditional sentence. The catalog's
three S017 quotes (`S017-title`, `S017-business`, `S017-runtime`) are verbatim
substrings of the live page and are anchored correctly.

**Concrete supported claim (required):** S017's own page title and badge
independently establish *GitHub Actions* as **public preview**, and its
introduction makes a connected 1Password Business account a precondition.

**Scope limit (required):** S017 alone does **not** establish the plan tier
(`Enterprise Password Manager Business`), the GitHub.com-only hosting rule, the
GitHub Enterprise Server / Enterprise Cloud data-residency exclusions, the
GitHub Free private-repository limitation, the desktop-app channel, or any
announcement date. Those are S019/S020 facts; reading them into S017 would
repeat the E1 overclaim. The row and the typed record correctly do not do so.

## 3. Feature-specific status/eligibility separation (S017–S020)

Each page reopened separately on 2026-10-20; status, eligibility and plan
evidence are kept apart.

| row | status anchor it actually carries | eligibility it alone supports | what it must not be used for |
|---|---|---|---|
| S017 `/brokered-access/github-actions/` | own H1 + badge: public preview | Business-account-to-GitHub-organization connection (intro) | plan tier, GitHub.com-only, exclusions, SDK/app channel |
| S018 `/brokered-access/custom-workflow/` | own H1 + badge “Beta”: public beta | OIDC provider connected to a 1Password Business account (intro); latest **beta** desktop app (Step 1); **JavaScript SDK only** (Step 3 note) | Actions status; every-SDK support |
| S019 `/brokered-access` | guide title says public preview — **guide-level only** | integration set up in 1Password Business (intro/Add an integration); GitHub.com hosting; GHES and GHEC data residency unsupported; GitHub Free private-repo limitation | custom-OIDC status; per-feature release status |
| S020 blog `https://1password.com/blog/1password-credential-broker-public-preview` | published 2026-07-28; Actions public preview vs custom-OIDC beta split | Enterprise Password Manager Business customers | uniform Broker status; OpenBao/Vault facts |

Quotes used above (each ≤25 words):

| quote | heading / URL / date |
|---|---|
| “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | H1, https://www.1password.dev/brokered-access/custom-workflow/, 2026-10-20 |
| “only supported in the 1Password JavaScript SDK at this time” | Step 3 note, same URL, 2026-10-20 |
| “latest beta release of the 1Password desktop app” | Step 1, same URL, 2026-10-20 |
| “Your GitHub organization must be hosted on GitHub.com.” | GitHub Actions requirements, https://www.1password.dev/brokered-access, 2026-10-20 |
| “GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren't currently supported” | same section, same URL, 2026-10-20 |
| “your team won't be able to use this integration for workflows in private repositories” | same section, same URL, 2026-10-20 |
| “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | §New in this release, https://1password.com/blog/1password-credential-broker-public-preview, 2026-10-20 |
| “available for all Enterprise Password Manager Business customers” | introduction, same blog, 2026-10-20 |

Typed-record mapping confirms the separation is mechanical, not prose-only:
`op_cb_github_actions.release_status` evidence = S017-title + S020-status-split;
`eligibility.plans` = S020-epm-plan; `eligibility.requirements` =
S019-business + S019-github-com; `documented_exclusions` = S019-enterprise-host
+ S019-free-private. Status therefore cannot be satisfied from the guide, and
eligibility cannot be satisfied from the feature page.

## 4. Round-22 lesson usage and immutable-row accounting

- `corpus/lessons/round-22.md` §Gate line for S017 quotes the H1 exactly
  (“Use 1Password Credential Broker to access secrets in GitHub Actions at
  runtime (public preview)”), names the URL and the 2026-10-20 reopen, and
  bounds its admission scope to “Actions feature status only; Business-account
  prerequisite from introduction”. Verified against the live page.
- `used-by` links are live and reciprocal: S017 lists
  `corpus/lessons/round-22.md, corpus/knowledge/feature-bound-credential-review.md`;
  both files' `source:` fields contain S017.
- Executed read-only census:
  `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)`, exit 0.
  This is identical to ledger row R21-02's expectation
  (`corpus/claim-ledger.tsv:52`) and to the manifest `expected` block. The
  census verifies the citation chain only; it does **not** fetch URLs or verify
  content.
- Immutable original rows: comparing the 16 registry rows in
  `.ufo/waves/round-22/frozen/before/corpus/SOURCES.md` against the current 21
  rows gives **0 shared rows changed, 0 removed, 5 added** (S017–S021). S006
  and S007 remain present while S019/S020 carry the supersession statements, as
  the lesson states. No immutable-field mutation was observed.
- S017 is a new row, so there is no earlier S017 original to compare; the
  relevant immutability test is the S001–S016 set above.

## 5. Executed calibration observations (integrated tree)

Read-only executions, no production mutation:

| command | observed result |
|---|---|
| `python3 corpus/feature-claims.py --selftest` | `FEATURE_CLAIMS_SELFTEST: PASS cases=10`, exit 0 |
| `python3 corpus/feature-claims.py --phase before` | 10 rejects — 2 `reject:false-claim`, 8 `reject:bar-fail`; `false_admissions=0 misses=0`; exit 1 |
| `python3 corpus/feature-claims.py` (after) | `admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0`; exit 0 |
| `python3 corpus/feature-claims.py --phase boundary` | 3 `cannot-evaluate` (`UNKNOWN-FIELD`, `UNKNOWN-SOURCE`, `OUT-OF-SCOPE-VAULT-JWT`); exit 2 |
| eight `.ufo/waves/round-22/falsify/inputs/*.json` via `--input` | 7 reject + 1 admit, all reason codes as named (below) |

Held-out inputs (independent of the authored control list, hashes recorded):

| fixture | SHA-256 | decision |
|---|---|---|
| `ga-status-no-title-anchor.json` | `de55ed33…deb6` | reject:bar-fail `FC-EVIDENCE-ANCHOR` — correct status/eligibility, but status evidence omits S017-title |
| `ga-status-beta-swap.json` | `c50b4bfd…520e` | reject:false-claim `FC-STATUS-MISMATCH` |
| `ga-no-business.json` | `e2a0ae18…5dc4` | reject:bar-fail `FC-ELIGIBILITY-QUALIFIER` |
| `ga-valid-reordered.json` | `262e9021…9fd5` | **admit** `FC-ADMITTED` |
| `custom-preview-claim.json` | `49603609…cf0d` | reject:false-claim `FC-STATUS-MISMATCH` |
| `openbao-claim-vault-product.json` | `83e10d93…f6d7` | reject:false-claim `FC-PRODUCT-MISMATCH` |
| `openbao-generalized.json` | `532c7442…b14d` | reject:bar-fail `FC-RUNTIME-CONSTRAINT` |
| `vault-claim-openbao-src.json` | `bc7636b2…bf6a` | reject:bar-fail `FC-CROSS-PRODUCT` |

Static rules observed in `feature-claims.py` that back the separation:
`FC-STATUS-ANCHOR-PIN` requires `release_status_anchor == "page-title-H1"` for
`public_preview`/`public_beta`; `release_status` evidence must equal the
required reference set (guide S007 cannot substitute); eligibility fields are
compared by exact set equality; product mismatch is rejected before binding.
Measured C1 result: the two E1 defects and both E3 cross-product defects are
rejected, the four bounded controls are admitted, and the ten held-out/negative
records do not produce a false admission or a miss.

Gate limits (not defects against its own contract): the `outside-verifier`
reference SHA-256 is only checked to be 64 hex characters, not against the
file's bytes, so authority metadata is pinned by the records manifest digest
rather than re-verified content; the gate never fetches URLs; and “admit” means
the typed record matches this reviewed catalog, not vendor truth. These are
stated in the artifact's own `review.limits`.

## 6. Freshness observations

Digests re-tested against the live public pages on 2026-10-20:

| source | catalog SHA-256 reproduces from raw HTML? | observation |
|---|---|---|
| S017 | **yes**, `937f6828…0849`, 1,215,155 bytes | docs page byte-stable across fetches |
| S018 | **yes**, `d0890c11…76e5` | docs page byte-stable |
| S019 | **yes**, `896c780b…4a9f` | docs page byte-stable |
| S021 | **yes**, `52295218…f82c` | OpenBao page byte-stable |
| S020 | **no**, catalog `55bf23fe…3eda` | blog HTML is per-request non-deterministic |

S020 proof: three consecutive `curl -sSL` fetches of the same blog URL returned
three different SHA-256 values (`bc16c1bd…f599`, `047de9db…c60f`,
`e260f402…ce1e7`); the page embeds a per-request CSP nonce and an
`unleash-session-id` cookie. The article region between the H1 and “Continue
Reading” also differed between two fetches, while the H1 and the quoted
status-split sentence were present in every fetch. `[INFERENCE]` The stored
digest is therefore a point observation of an unstated extraction, not a
reproducible byte pin for this source; it may match whichever representation the
author captured.

Adjacent corroboration of mixed bases (outside S017, reported as observation,
not as my row's defect): the S013 SOURCES row digest (`ae321512…bf5`, 2026-10-19)
differs from the catalog digest (`de5f8836…3802`, 2026-10-20), and the live raw
HTML now matches the catalog exactly. Likewise S007 (row and catalog
`e4aef238…f818`, 2026-10-19) and S019 (`896c780b…4a9f`, 2026-10-20) are the same
URL with different digests; live raw HTML matches only S019. The records do not
state a representation basis, so a page change cannot be distinguished from a
representation change. The lessons' statement that earlier `Fetch sha256`
values are “not presently reproducible drift pins” is correct for unstated
representations, but it is **not** universal: S017/S018/S019/S021 raw HTML is
reproducible today.

Freshness verdict for S017: the row's reopen date is current, its anchors are
live, its catalog digest reproduces byte-exactly, its citation chain passes the
census, and no immutable original row changed. No stale pin or silent deletion
attaches to this row. I did not audit the stamp-membership/migration set (other
seats own C2 accounting) and claim no decision there.

## 7. Findings and proposed corrections

Positive results:

- **P1 (C1, S017):** the Actions status is anchored to the feature's own H1 and
  immediately rejected when that anchor is omitted (`ga-status-no-title-anchor`
  → `FC-EVIDENCE-ANCHOR`); swapping in `public_beta` is a false-claim reject.
  This is the concrete correction of E1's status conflation.
- **P2 (C1, eligibility):** omitting the plan set (`ga-no-business`) and
  omitting the documented exclusions (authored `BEFORE-GITHUB-EXCLUSIONS`) are
  both rejected, so the ranked-E1 eligibility omission is no longer admissible.
- **P3 (C2, S017):** live H1/badge/introduction, exact catalog digest, census
  CLEAN, S001–S016 unchanged, S017–S021 added without removal.

Gaps, each with a proposed correction:

- **F1 — calibration coverage (minor, false-reject risk).**
  `op_cb_github_actions.runtime_constraints` is an empty list, although the
  S017 page documents two source-backed deployment constraints: the latest
  desktop app (Step 1) and `id-token: write` (Get help). Custom OIDC models its
  analogous beta-app and SDK constraints. Because `runtime_constraints` is
  compared by exact set equality, a source-faithful bounded claim that adds
  either constraint is rejected with `FC-RUNTIME-CONSTRAINT`. This does not
  create a false admission, but it means the mechanism cannot admit a correctly
  bounded control covering those documented prerequisites.
  *Proposal:* after reopening, add `desktop_app_current` and
  `id_token_write_permission` (names for review) to the Actions record, plus one
  admitting control and one omitted-constraint negative. Alternative: record in
  the review why those prerequisites are deliberately outside the model. Either
  choice is a deliberate expectation migration, not a silent edit.
- **F2 — freshness (S020, adjacent to S017's status evidence).**
  The S020 catalog digest cannot be reproduced from the live page because the
  blog HTML varies per request; the AFTER-GITHUB-BOUNDED control's
  `release_status` evidence includes `S020-status-split`, so this pin's
  presentation overstates reproducibility.
  *Proposal:* add a `digest_basis`/`digest_stable` field (e.g. `raw-html`,
  `tags-stripped`, `markdown-alternate`) and, for the blog, pin a canonical
  article-text hash (H1 + article body) or mark the digest non-pinnable. Keep
  the dated prose quote as the semantic anchor.
- **F3 — freshness (catalog-wide, minor).**
  Digest bases are unlabeled, and the same URL carries different digests across
  S007/S019 and row/catalog S013 without a recorded representation or change
  reason.
  *Proposal:* name the representation for every stored digest and do not treat
  a catalog `sha256` as currentness proof; restate the lesson's
  unrepeatability caveat as representation-specific.
- **F4 — catalog hygiene (minor).** S017's `S017-business` binding is not cited
  by any feature's required evidence (eligibility requirements require S019
  refs). There is no loophole: the gate rejects a claim that cites only S017 for
  eligibility because the reference set must match exactly. The binding is
  documentation, not authority; either leave it explicitly as such or remove it
  to keep the binding set minimal.
- **F5 — measurement coverage (minor).** No held-out fixture exercises a
  GitHub Actions status claim that cites only the guide (S007) or only the
  announcement while keeping the correct status; the analogous custom-OIDC case
  is covered by `BEFORE-CUSTOM-UNDERCITED`. The rule rejects it by
  reference-set equality, but that exact decision is not executed for Actions.
  *Proposal:* add one `ga-status-guide-only.json` fixture and record its
  `FC-EVIDENCE-ANCHOR` outcome.

No correction is proposed to the S017 row's teaching, status, recheck or
`used-by` fields, and none to any immutable original row.

## 8. Limits and non-claims

- One source row reopened; public documentation only. No 1Password account,
  vault, integration, workflow or secret was exercised, so no deployed-behavior
  or entitlement claim is made.
- S006/S007 semantics were not re-adjudicated here; S019 and S020 (same URL as
  S006) were read for the separation table. The S006/S007 rows were only checked
  for immutability.
- The gate's admission is catalog consistency, not vendor truth; label
  authority (`outside-verifier`, `construction-rule`, `verbatim-pin`) is
  provenance, not outside agreement. My executions are integrated-tree fixture
  observations, not an outside verifier's verdict.
- I did not audit revision-stamp membership, the nine previously dropped diff
  lines, or ledger expectation migrations; this report claims no C2 decision
  beyond S017's digest/anchor/citation-chain freshness.
- `[INFERENCE]` items are marked inline; everything else is a direct
  observation with the hash, byte count, command output, quote or status shown.

## 9. Checks the parent should run after integration

- `python3 corpus/feature-claims.py --selftest` → expect `PASS cases=10`, exit 0.
- `python3 corpus/feature-claims.py` → expect `admitted=4 … false_admissions=0`, exit 0.
- `python3 corpus/feature-claims.py --phase before` → expect 10 rejects (2 false-claim, 8 bar-fail), exit 1.
- `python3 corpus/feature-claims.py --phase boundary` → expect 3 unjudgeable, exit 2.
- Repeat the eight `--input .ufo/waves/round-22/falsify/inputs/*.json` cases → expect 7 rejects + 1 admit as tabulated.
- `bash corpus/sources-census.sh` → expect `CLEAN (rows=21 … entries_sourced=4 legacy=21)`, exit 0.
- Owner-run revision audit for the stamp set (not run by this seat).

Installations: none.
