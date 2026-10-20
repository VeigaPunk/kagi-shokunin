# ReopenSource04 — S004 exact reopen, S017–S020 separate status/eligibility, revision accounting

Seat `KagiR22.ReopenSource04` (scout, leaf; no subagent dispatch). Axes:
**calibration (C1)** and **freshness (C2)**. Read 2026-10-20 against the frozen
integrated tree. Public documentation GETs and owned local fixture executions
only; no production edit, no host-private gate, no launcher/package tool, no
loopback/health/CDP probe, no account/vault/credential operation, no
installation. The four dead W1 scribe seats remain **uncredited**; this is an
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
| `corpus/lessons/round-21-verifier-spotcheck.md` | `6e4fa622ae953f343c294e3ce401303b6b6fa377e8800f9164047b08711f1ffb` |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` · 43 L · 4,440 B |
| `corpus/knowledge/onepassword-machine-credentials.md` | `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` |
| `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | `f633d004100b5d440685770f6be6635f460c28673a2e353b554a64afd42c8610` |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` · 69 L |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` · 58 L |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` · 10 L · 1,804 B |

Every manifest-listed input above matches its recorded SHA-256. The plan's
C1/C2 claims are the decision frame, not evidence; the lesson is read as the
round-22 narrative and migration pointer. `git status
--porcelain` at read time showed only `.ufo/` wave scaffolding moved; no
manifest-listed production input is modified. An advisory build artifact,
`.ufo/waves/round-22/build/BuildQualifierGate.md`, moved during this wave; it
is not a frozen input and no claim below depends on its current bytes.

## 2. S004 — exact URL, teaching, anchor, immutability

URL: https://www.1password.dev/service-accounts/security — public GET
2026-10-20, both the alternate markdown and the raw HTML. The page H1 is
“1Password Service Account security”; it displays no version or date. The two
cited sections exist as `## Access control` and
`### Token rotation and revocation`.

| anchor | observed text (≤25 words) | location |
|---|---|---|
| §Access control | “you choose the vaults it can access and its level of access.” | H2 under the page introduction |
| §Token rotation and revocation | “You can rotate or revoke service account tokens.” | H3 under “Service accounts and token generation” |

Both quoted strings are present verbatim in the raw HTML and in the rendered
page. The row's teaching — Service Account vault permissions and token
rotation/revocation are separately documented controls — is supported by the
separate sections and by the §Security model bullets (“can only read items
from vaults it has READ access to”; “Disabling service accounts for a vault
removes access”). The page's extra bullets (“You can't add vault access to a
generated service account after creation”, token of a deleted service account
cannot authenticate) do not contradict the row.

**Immutable-row check.** The S004 row is byte-identical between
`c2cab35bc92e57e39e5489bac3386db078345b3f` and HEAD (line 10 is
unchanged). The whole registry diff is **43 insertions,
0 deletions** (`git diff --numstat c2cab35…HEAD -- corpus/SOURCES.md`), so no
S001–S016 line changed, not even whitespace. S006 and S007 are likewise
byte-identical, and the 16→21 row increase is exactly the S017–S021 addition.
S004's `used-by` remains only `corpus/knowledge/onepassword-machine-credentials.md`;
`corpus/lessons/round-22.md` does not cite S004 (its `source:` line is
S017–S020 and its OpenBao note is S021). The round-22 append to the
onepassword entry is **45 insertions, 0 deletions** and leaves item 2's S004
sentence intact.

### Concrete supported claim (S004)

The two quoted controls are still exactly present at the exact URL: vault
selection/access level on creation is documented in §Access control, and
token rotation/revocation is documented separately in §Token rotation and
revocation. The row's “separate controls” teaching survives the reopen.

### Scope limit (S004, required)

The page states that rotation/revocation exists but **does not document the
procedure, token lifetime, immediate effect, or session termination**; it
links to `/service-accounts/manage-service-accounts#rotate-token` and
`#revoke-token`. It therefore cannot support any claim that the Service
Account token expires with a child process, that rotation ends live CLI
sessions, or that token lifetime equals process lifetime. The row does not
make those claims; its scope should be read as “controls exist and are
separate”, not “lifecycle mechanics”.

### Freshness limit (S004)

The row's 2026-10-19 `Fetch sha256` `19bcf13eacd212b54db578ed7b1fdaa7341756ab73a6bd4f61d4b0012c7d2d60`
does not match either current stable representation: raw HTML
`7e6f04088407b7ae388a4a27c33b6575c3819586aeac746910a96176f8924923`
(two identical GETs) or the `.md` alternate
`24b22be063adedda0731fed48ce7dc835ed0c79d856f09c5daa110d1b0e5ab5d`.
The acquisition representation is unrecorded and the row is explicitly a
2026-10-19 point observation, so this is **not** evidence of semantic drift;
the cited sections and quotes are unchanged. Do not restamp this hash as if it
were current, and do not infer page change from the mismatch. The proposed
correction is a note, not a production edit.

## 3. S017–S020 — feature-specific status and eligibility, separately

Each page was reopened independently on 2026-10-20. Status, eligibility and
setup conditions are kept apart; quotes are ≤25 words and name the anchor.

| row | status carried by its own page | eligibility/setup carried by its own page |
|---|---|---|
| S017 https://www.1password.dev/brokered-access/github-actions/ | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” plus a “Public Preview” badge | introduction “connected your GitHub organization to your 1Password Business account”; Step 1 “latest version of the 1Password desktop app”; Get help requires `id-token: write` |
| S018 https://www.1password.dev/brokered-access/custom-workflow/ | H1 “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” plus a “Beta” badge | introduction “connected an OIDC provider to your 1Password Business account”; Step 1 “latest beta release of the 1Password desktop app”; Step 3 note “only supported in the 1Password JavaScript SDK at this time” |
| S019 https://www.1password.dev/brokered-access | guide H1 “… (public preview)”; **guide-level label only**; its §Custom Workflow (OIDC) section carries no status | “a supported integration in their 1Password Business account”; §GitHub Actions requirements: “must be hosted on GitHub.com”; GitHub Enterprise Server / Enterprise Cloud with data residency “aren't currently supported”; GitHub Free organizations cannot use the integration for private-repository workflows |
| S020 https://1password.com/blog/1password-credential-broker-public-preview, published 2026-07-28 | §New in this release “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | introduction “available for all Enterprise Password Manager Business customers to start using right now”; §Try today repeats EPM Business |

Independent result: **no uniform Broker status is supported**. S017 is public
preview, S018 is public beta, S019's guide title does not determine S018's
status, and S020's split is announcement-time (2026-07-28), not a live status
oracle. S020's page title (“1Password Credential Broker is now in public
preview”) is product-level; only its §New in this release section carries the
feature split, so the title must not be used for the custom feature either.

The pages' own setup conditions differ in a feature-specific way:
S017 asks for the latest desktop app, while S018 asks for the latest **beta**
release and restricts support to the JavaScript SDK “at this time”; S019 adds
the GitHub.com and Free/private-repository conditions. The S018 page's shared
“Related topics” chrome contains “(public preview)” strings for the other
pages, confirming that a whole-page substring scan would misclassify the
custom feature; the H1 anchor is the correct status source.

### Calibration decision result

Executed against the frozen tree (authorized local fixtures; no network):

| command | observed | exit |
|---|---|---|
| `python3 corpus/feature-claims.py --phase before` | 10/10 expected decisions: 2 `reject:false-claim` + 8 `reject:bar-fail`; `false_admissions=0 misses=0`; E1 status conflation → `FC-STATUS-MISMATCH`, E1 eligibility omission → `FC-ELIGIBILITY-QUALIFIER`, E3 vault-only → `FC-CROSS-PRODUCT` | 1 (intended) |
| `python3 corpus/feature-claims.py --phase after` | `CLEAN phase=after admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0 unjudgeable=0` | 0 |
| `python3 corpus/feature-claims.py --phase boundary` | 3 `cannot-evaluate` (unknown feature, unknown field, unknown source), `unjudgeable=3 scored=no` | 2 (intended) |
| `python3 corpus/feature-claims.py --selftest` | `PASS cases=10` | 0 |

This is per-record decision evidence, not an accuracy scalar and not outside
agreement. The assigned source rows are consistent with those decisions.

### Concrete supported claim (S017–S020)

The feature split is supported at the named anchors: GitHub Actions is public
preview (S017 H1), custom OIDC workflows are public beta (S018 H1), and the
announcement's own section separates the two (S020 §New in this release). The
guide's uniform “public preview” label is correctly not used for the custom
feature.

### Scope limit (S017–S020, required)

S020's EPM Business sentence is **release-level**: it describes the public
preview release, while its custom-OIDC section says “slowly rolling out … in
beta”. The custom feature page says only “1Password Business account”, and no
opened page states a feature-level EPM-Business entitlement for custom OIDC.
The typed catalog nevertheless uses `S020-epm-plan` for **both** features'
`eligibility.plans`. That plan link is a plausible synthesis, not a verbatim
feature-scope plan statement; it should be labelled inferred, or replaced by a
feature-specific plan quote if one exists. The bounded admit is not flipped:
S018 independently requires a 1Password Business account, and S020 presents
custom OIDC as part of the same EPM Business release. A second limit: S018's
“at this time” is time-bound and supports no permanent SDK-exclusion claim.

### Finding F1 (calibration, latent; no current decision impact)

`corpus/feature-claims.json` binds the S019 quote “a supported integration in
their 1Password Business account” to
`op_cb_custom_oidc.eligibility.requirements = oidc_provider_connected`, and
also to the custom feature/path fields. That quote names neither OIDC nor the
custom-workflow path; “OIDC provider” appears in S018's introduction and the
guide's §Custom Workflow (OIDC) Step 1 (“enter your OIDC provider's issuer
URL”). The gate's exact-set rule (`reference_set == required_references`,
`corpus/feature-claims.py:733-738`) means no admitted claim can use
`S019-business` for the custom requirement: the required set is exactly
`{S018-intro}`, so the binding is inert today and no false admission occurs.
It remains a quote-level cross-attribution hazard if requirements change or
another consumer reads `bindings` as proof. Proposed correction: remove the
extra custom feature/path/OIDC bindings from S019, or re-anchor them to the
guide's §Custom Workflow (OIDC) Step 1 quote; the S017/S018 titles already
satisfy feature/path. This independently corroborates peer findings
(ReopenSource01/11/18, CriticNoTrade); no novelty is claimed.

### Finding F2 (freshness, informational; no decision impact)

The S020 full-page digest in `corpus/feature-claims.json` and
`BuildQualifierGate.md` is
`55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda`.
It is **not reproducible**: four immediate plain GETs of the exact URL
returned four distinct raw-HTML hashes —
`3af184026463af44a0b47b62637a646e8f9ef44553f4f2608015c2281bc2b495`,
`796096c5b7c9fe93b88bc147695b6c907699532fb62f44e9756c5808f1ab5a0e`,
`99d287ddbd6f893b88f2ebd2dcd25cfde9e81d01958d8d226d226d8a9446e909`,
and `1c5254db84bab9a0b44c8c5594ddb29bc842ecf60c5dd561554d647cd6642aa4`
— none equal the recorded value. The page is per-request non-deterministic
(duplicated hydration JSON and varying bytes); the two cited sentences are
still present and the quoted text is unchanged. S017, S018 and S019 raw-HTML
digests do reproduce exactly and match the catalog
(`937f6828…`, `d0890c11…`, `896c780b…`). Therefore S020's value is a point
observation of a dynamic representation, **not** a drift pin: do not restamp
it to today's hash, and do not read the mismatch as vendor drift or as a reason
to delete the source. Proposed correction: record the acquisition
representation and a dynamic/point-observation marker for S020 (or a
content-scoped pin with its extraction method), and extend the lesson's
“earlier undocumented Fetch hashes” sentence to cover this new pin. Peer
reports (ReopenSource01/05/18) flag the same nondeterminism independently.

## 4. Revision accounting — local pointer integrity

### 4.1 Current membership and stale pins

- `corpus/stamps.tsv`: **69/69 rows** match SHA-256, newline count and byte
  count exactly against the current files. Zero stale, zero missing.
- At `c2cab35…`, the base row set has **63** members and exactly **six** stale
  records, independently re-derived and matching `before.json`:
  `LOG.md`, `corpus/knowledge/config-layering.md`,
  `corpus/knowledge/handler-on-disk-state.md`,
  `corpus/knowledge/handler-trust-boundary.md`,
  `corpus/knowledge/janitor-env-contract.md`, `corpus/lessons/round-18.md`.
- `python3 corpus/revision-audit.py --history c2cab35…`:
  `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`,
  exit 0; the six additions are the feature-claims pair, the active review
  entry, the round-21 verifier spot-check, round-22 lesson and revision-audit
  tool. `--selftest` passes 11 cases.

### 4.2 Nine deleted lines are rewrites, not nine lost members

Between `aea7a4301` and `e1544c194fddf1bb073b3946847b4526f326ad73`:

- `corpus/stamps.tsv`: `16 added / 9 deleted`; first-column member set
  **56 → 63**, **0 removed**, 7 genuinely added. The 9 deleted lines are
  exactly the 9 `changed_stamp_records` in `round21-migrations.json`; each old
  and new line is byte-identical to `git show` at its revision (18/18 lines
  checked).
- `corpus/claim-ledger.tsv`: `10 added / 5 deleted`; **0 removed ids**. The 5
  rewritten rows are preserved old/new exactly (5/5); four change an
  expectation — `R12-02 29→36`, `R12-03 56→63`, `R13-01 20→23`,
  `R14-01 21/18→24/21` — and `R13-02` changes only its note while retaining
  expectation 35. `historical-migrations.json` separately preserves
  `R21-03 40→47` with exact old/new lines.
- `pin-migrations-integration.json` records 63→69 members, 0 removed, and 12
  round-22 claim changes; every old line equals the `c2cab35…` row and every
  new line equals the current row (12/12 exact). `historical-correction-pins.json`
  (13 changed stamp records, 26 old/new lines) is 26/26 exact and its
  `removed_members`/`new_members` are `[]`.

**Nuance, not laundering:** four of the nine *old* stamp rows are themselves
stale against the `aea7a4301` bytes (LOG.md, SCORECARD.md, corpus/README.md,
corpus/op-ref-probe.sh; e.g. the old LOG row says 762 lines/56,847 B while
`git show aea7a4301:LOG.md` is 963 lines/68,885 B). The migration artifact
faithfully preserves those recorded old lines, and every new pin matches its
revision's bytes. This is the drift being repaired, not a restorable
expectation; do not “restore” the old values.

### 4.3 Executed current expectations

| check | observed |
|---|---|
| `grep -c '[^[:space:]]' corpus/stamps.tsv` | 69 |
| `grep -c '^## Round ' SCORECARD.md` | 25 |
| `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | 43 |
| `grep -cE '^\| S[0-9]{3} ' corpus/SOURCES.md` | 21 |
| `bash corpus/claim-ledger.sh docs` | `DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)` |
| `bash corpus/claim-ledger.sh --selftest` | `SELFTEST: PASS (108 cases)` |
| `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)` |
| `bash corpus/sources-census.sh --selftest` | `SOURCES_CENSUS_SELFTEST: PASS (47 cases)` |

**C2 verdict:** local pointer accounting holds — zero stale/missing/dropped,
the six pre-existing stale pins are exactly recorded and repaired, the nine
deleted diff lines are accounted rewrites with zero removed members, and every
migrated expectation I executed matches the frozen tree. Byte identity proves
pointer integrity only; it does not prove vendor currentness, and no such
inference is made.

## 5. Decision count and remaining unknowns

Assigned source rows reopened: S004, S017, S018, S019, S020. Observed
decisions: **5/5 retained as correctly bounded; 0 require rejection**. The
executable feature gate independently produced 10/10 before-rejects (0 false
admissions), 4/4 after-admits and 3 boundary unjudgeables. This is a bounded
control check, not an accuracy scalar.

Remaining unknowns:

- Whether “Enterprise Password Manager Business” (S020) and “1Password
  Business account” (S017/S018/S019) name exactly one entitlement; no opened
  page states the mapping.
- The exact representation/UA/date behind S004's 2026-10-19 hash and S020's
  2026-10-20 hash; neither is reproducible as a stable URL pin today.
- Whether S017–S019 digests remain stable across other clients/CDN edges; only
  one HTTP client and no content negotiation were exercised.
- Whether a future catalog change will make the inert S019 extra bindings
  load-bearing; today the exact-set rule blocks them.

## 6. Limits and non-claims

- One source row (S004) reopened plus S017–S020 and the S020 announcement;
  public documentation only. No 1Password account, vault, integration,
  workflow, secret or entitlement was exercised.
- An `admit` is catalog consistency, not vendor truth; `verbatim-pin` and
  `construction-rule` labels are provenance, not outside agreement.
- No depth move and no legacy-header count claim is made; counts above are
  revision/consistency checks only.
- No installation occurred. No production file was edited; this report is the
  only persistent write (scratch command output under `/tmp` only).
- The advisory build artifact `BuildQualifierGate.md` moved during the wave;
  no claim here depends on its current bytes.

## 7. Checks the parent should run after integration

- `python3 corpus/feature-claims.py --phase before` → 10 rejects, exit 1.
- `python3 corpus/feature-claims.py --phase after` → 4 admits, exit 0.
- `python3 corpus/feature-claims.py --phase boundary` → 3 unjudgeable, exit 2.
- `python3 corpus/feature-claims.py --selftest` → `PASS cases=10`.
- `python3 corpus/revision-audit.py --history c2cab35…` → `CLEAN (… added=6 …)`.
- `python3 corpus/revision-audit.py --selftest` → `PASS cases=11`.
- `bash corpus/sources-census.sh` → 21 rows, `entries_sourced=4`.
- `bash corpus/sources-census.sh --selftest` → `PASS 47 cases`.
- `bash corpus/claim-ledger.sh --selftest` → `PASS 108 cases`.
- `bash corpus/claim-ledger.sh docs` → `entries=25 row_linked=22`.
- If S020 is treated as a drift pin anywhere, repeat a plain GET twice and
  compare; expect non-identical bytes and do not restamp.

Installations: none.

Trailer: `.ufo/waves/round-22/falsify/ReopenSource04.md`
