# ReopenSource14 — S014 and S017–S020 source adjudication

Seat: `KagiR22.ReopenSource14` (scout, leaf; no subagents). Axes: **calibration** and **freshness**. Assignment: reopen S014's exact URL, verify teaching/located anchor, compare the immutable original row and round-22 lesson usage; for S017–S020 examine feature-specific status/eligibility separately and check that original rows were not mutated. Public documentation only; no account, vault, host-private gate, launcher, or package transaction was used. No production edit is proposed as applied; the only write is this report.

## Read revision and frozen-input identities

Read at `HEAD = 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, 2026-10-20. The working tree differs from HEAD only in `.ufo/waves/round-22/falsify*` artifacts; every production input named below matches `integration-manifest.json`.

| file | sha256 | bytes | lines | manifest |
|---|---|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 19721 | 86 | match |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 15700 | 192 | match |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` | 1804 | 10 | match |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 7213 | 69 | match |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 17770 | 58 | match |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | 47434 | 995 | match |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | 45532 | 1040 | match |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | 4440 | 43 | match |
| `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | `f633d004100b5d440685770f6be6635f460c28673a2e353b554a64afd42c8610` | 11319 | 158 | match |
| `corpus/knowledge/onepassword-machine-credentials.md` | `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` | 9048 | 80 | match |
| `corpus/knowledge/op-ref-consumption.md` | `4b89d3b91f41039c12a3fca349b3154a4d8a8d0cd08b2c182b0b4cf6b6a75e9c` | 25991 | 384 | match |

## S014 — reopened and adjudicated

- URL reopened: `https://openbao.org/docs/auth/jwt/` (2026-10-20). The page carries `Version: Version 2.7.x`, title `JWT/OIDC auth method | OpenBao`.
- Located anchors: H1 `JWT/OIDC auth method`; H3 `JWT verification`; also `Bound claims` and `Claims as metadata`.
- Quote check: page text is “The `jwt` auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT.” The registry quote at `SOURCES.md:20` is “The JWT auth method can be used to authenticate with OpenBao using OIDC”: same sentence and location, but the token is uppercased and the backticks are removed. `SOURCES.md:82-83` already discloses this as normalized text, not a case-literal excerpt.
- Teaching check: the page supports OIDC and direct-JWT authentication; JWT signatures verify against issuer public keys by one of static keys, JWKS, or OIDC Discovery, one method per backend; `bound_claims` and `claim_mappings` are documented. The row's “configured signature verification and claim handling” is supported.
- Immutable original row: base `c2cab35` row sha256 `48a401dee0016f733b1b5f16aad7efbdcef67784228bb450e9b6033473808dcf`; current row the same. No field of S001–S016 changed (see mutation check below).
- Round-22 usage: `corpus/lessons/round-22.md` does **not** cite S014. The round-22 use is in `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (source header and the appended “Further product/path precision”), which states that JSON-pointer `claim_mappings` are required while non-pointer mappings are optional. That matches the reopened page's `Claims as metadata` section. No Vault-to-OpenBao or KV-retention inference rides on S014 there.
- Verdict: **PASS with one low-severity citation-normalization caveat** (F2 below).

## S017–S020 — feature-specific status and eligibility, separately

| row | URL reopened 2026-10-20 | observed feature-specific status | observed eligibility/limits | row check |
|---|---|---|---|---|
| S017 | `https://www.1password.dev/brokered-access/github-actions/` | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | introduction: “connected your GitHub organization to your 1Password Business account” | status and Business prerequisite correctly separated; no uniform Broker claim |
| S018 | `https://www.1password.dev/brokered-access/custom-workflow/` | H1 “…custom workflows at runtime (public beta)” | intro: OIDC provider connected to a 1Password Business account; Step 1: “latest beta release of the 1Password desktop app”; Step 3 note: “Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | public beta, not preview; eligibility and SDK/app limits match, except the row drops “at this time” (F1) |
| S019 | `https://www.1password.dev/brokered-access` | guide H1 still says “(public preview)”; this is the guide label | intro: “administrators can set up a supported integration in their 1Password Business account”; §Add an integration/GitHub Actions: “Your GitHub organization must be hosted on GitHub.com.”; GHES and GHEC-with-data-residency “aren't currently supported”; GitHub Free orgs cannot use the integration for private-repository workflows | bounded: guide label does not decide custom-workflow status; Business setup and deployment/private-repo qualifiers are separately sourced |
| S020 | `https://1password.com/blog/1password-credential-broker-public-preview` | published July 28, 2026; §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | intro: “available for all Enterprise Password Manager Business customers to start using right now” | announcement-time split is supported; it is not a live status oracle |

- S017 and S018 each carry their own title/H1 status; S019's guide-level preview label is not used as either feature's status anchor. S020's split quote is an announcement-time statement. This is the intended calibration separation, and it matches the active review table in `corpus/knowledge/feature-bound-credential-review.md`.
- Original rows were not mutated. `git diff c2cab35bc92e57e39e5489bac3386db078345b3f..HEAD -- corpus/SOURCES.md` reports **43 insertions, 0 deletions**. S006 (`1b20aaca0bba9407501c7c9dfed9e616d2f61a8e45265c84e3d1a49581295ba5`), S007 (`f9905ea9fefcd60a3a4e212ca6634a9de9b5e9b02781dc0e4c8e420fe4c3f963`) and S014 (`48a401dee0016f733b1b5f16aad7efbdcef67784228bb450e9b6033473808dcf`) are byte-identical to the base rows. S017–S020 are new rows; their `used-by` extension after drafting is disclosed at `corpus/lessons/round-22.md:93-98`, and their status/recheck did not change.
- Round-22 lesson Gate quotes (lines 17–21) are present on the reopened pages: S017/S018 titles, S019 introduction, S020 §New in this release. The `used-by` handshake is clean under the source census (below).

## C1 executable decisions (calibration, not row count)

| command | observed result | exit |
|---|---|---|
| `python3 corpus/feature-claims.py --phase before` | 10 records rejected: 2 `reject:false-claim` (E1 status conflation, same-page preview swap) and 8 `reject:bar-fail` (including E1 eligibility, E3 Vault-only OpenBao source, custom under-citation, beta-app/SDK omissions, GitHub exclusions, reverse cross-product); `FEATURE_CLAIMS: FAILED ...` | 1 |
| `python3 corpus/feature-claims.py --phase after` | 4 bounded controls admitted; `FEATURE_CLAIMS: CLEAN phase=after admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0 unjudgeable=0` | 0 |
| `python3 corpus/feature-claims.py --phase boundary` | 3 records return `cannot-evaluate` (`FC-UNKNOWN-FEATURE`, `FC-UNKNOWN-FIELD`, `FC-UNKNOWN-SOURCE`); `scored=no` | 2 |

The known E1/E3 overclaims are rejected on source/feature/product grounds, not merely by prose. The four after controls are `verbatim-pin`/authored bounded controls, not outside-verifier agreement; no accuracy scalar is inferred from them. The control fields match the reopened pages: GitHub Actions (public preview, EPM Business plan, Business-account and GitHub.com requirements, GHES/GHEC-data-residency and GitHub-Free-private-repo exclusions); custom OIDC (public beta, OIDC-provider + Business requirement, beta desktop app, JavaScript SDK); Vault lease and OpenBao service-token TTL (S021 quotes “After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked.”, under `Token Time-To-Live`, with the `Token types` service-token scope).

## C2 revision accounting

| item | observed |
|---|---|
| `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)`, exit 0 |
| `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` | `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0 |
| SOURCES.md stamp migration | old `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` / 43 / 14261 → new `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` / 86 / 19721; recorded in `.ufo/waves/round-22/pin-migrations-integration.json` with `removed_members: []` and `base_observed` matching the frozen before row |
| R21-02 expectation migration | old `rows=16 A=14 ... entries_sourced=3` → new `rows=21 A=19 ... entries_sourced=4`, preserved old/new in `pin-migrations-integration.json`; `claim-ledger.tsv:52` points to the round-22 journal and keeps the historic 16-row value available |
| nine-line stamp span `aea7a4301`→`e1544c194` | 56→63 records; **0 removed members**; 9 changed same-path pins: `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`, `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh` — exactly the lesson's replacement table |
| six before-stale records | all six named in `.ufo/waves/round-22/before.json` (`config-layering`, `handler-on-disk-state`, `handler-trust-boundary`, `janitor-env-contract`, `round-18`, `LOG`) are present in `pin-migrations-integration.json` `stamp_changes` with old/new triples; current audit stale=0 |

No silent deletion or restamping-to-green was observed for this slice. A byte hash re-pins pointer integrity only; the historical-source errata and the dated announcement remain historical, not re-verified currentness.

## Findings and proposed corrections (not applied)

- **F1 (low, calibration):** S018's row summary says “only JavaScript SDK supported”; the page says “only supported in the 1Password JavaScript SDK **at this time**.” The active review table already says “currently”, but the registry row drops the temporal qualifier. Proposed correction: add “currently … at this time” to the row's teaching (or scope), leaving quoted text untouched.
- **F2 (low, calibration):** S014's quote is case-normalized (`JWT` vs the page's backticked `jwt`). It is disclosed at `SOURCES.md:82-83`, so this is not hidden, but a quotation-marked excerpt is not literal. Proposed correction: use a literal sentence from the same section (for example, the page's `jwt` sentence as rendered) or annotate the row inline as normalized; do not rewrite the historical row otherwise.
- **F3 (low, consistency):** S019's and S020's `teaches` cells say “supersedes S007/S006”, while `SOURCES.md:69-74` scopes the replacement to only the uniform-status/eligibility reading (S019) and adds the feature split to S006 (S020). Proposed correction: qualify the two cells to “supersedes only … reading” / “adds … to S006” so a row-only reader cannot infer full replacement of the still-supported mechanisms.
- **F4 (informational, freshness):** `corpus/feature-claims.json` carries S017–S021 captured-byte sha256 pins with `digest_observed_at: 2026-10-20`, but the corresponding `SOURCES.md` rows carry no digest pointer. S020 (same URL as S006) also has no `prior_registry_sha256`, unlike S013/S021. The two S020/S006 digests are visible and dated, so this is not laundering; it is a provenance asymmetry. Proposed correction: add a one-line digest pointer to the review artifact (or a `prior_registry_sha256` for S020) without replacing historical hashes.
- **F5 (informational, calibration):** S020's “Enterprise Password Manager Business customers” and S017/S018/S019's “1Password Business account” are recorded as separate plan/requirement qualifiers; no reopened page states they are the same commercial tier. Keep them separate in prose rather than treating the enum binding as proof of tier identity.

None of these findings overturns the S017–S020 status/eligibility decisions or the E1/E3 rejections. F1 is the only one that touches an asserted feature claim; F2–F5 are annotation/provenance precision.

## One concrete supported claim and one scope limit

**Supported claim:** S018's own H1 says “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)”, its introduction makes a connected OIDC provider in a 1Password Business account the path, Step 1 requires the “latest beta release of the 1Password desktop app”, and Step 3 says Broker “is only supported in the 1Password JavaScript SDK at this time.” The round-22 row's public-beta status and its OIDC/Business/beta-app/JavaScript-SDK qualifiers are therefore source-supported; the E1 before-record that cites the setup-guide title for `public_preview` is correctly rejected with `FC-STATUS-MISMATCH`.

**Scope limit:** S020 is a July 28, 2026 announcement. Its “Enterprise Password Manager Business” eligibility and its Actions-preview/custom-OIDC-beta split are announcement-time facts, not a live status oracle; no reopened page establishes current availability, and the registry keeps “Enterprise Password Manager Business” and “1Password Business account” as separate qualifiers rather than proving one commercial tier. Likewise S014 establishes OpenBao 2.7.x JWT/OIDC mechanism, not Vault token behavior, KV retention, or deployed host behavior.

## Limits and residual verification

- Only public documentation GETs and owned local fixture executions were used. No account/vault operation, no host loopback/health/CDP probe, no launcher/package tool, no installation, no host gate.
- Page bytes are live and unversioned for S017–S019; S014/S021 show docs version 2.7.x but no page date. Captured-byte digests in `feature-claims.json` identify a capture, not semantic truth.
- I ran the feature-claim phases, the source census, and the revision audit. I did not run `corpus/claim-ledger.sh verify/docs/cells`, `scope-gate`, or the full selftest suite; those remain parent checks after integration.
- The four dead W1 scribe seats remain uncredited; this report uses no dead-seat output and makes no replacement claim.

Parent checks after integration: `git diff c2cab35..HEAD -- corpus/SOURCES.md` (only insertions), `bash corpus/sources-census.sh`, `python3 corpus/feature-claims.py --phase before|after|boundary`, `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`, and a second independent reopen of the five URLs if desired.
