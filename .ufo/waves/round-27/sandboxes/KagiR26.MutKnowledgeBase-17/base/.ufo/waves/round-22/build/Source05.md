# Source05 — S005 re-open and entry-claim calibration

Seat: `KagiR22.Source05` (scout, read-only). Assigned source: **S005 only**.
Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Observed worktree: **2026-10-20T21:34–21:41Z**. Sibling seats were writing the same tree
concurrently (S017–S021, `feature-bound-credential-review.md`, E1's round-22 erratum);
the digests in §9 pin the exact bytes this report read.
No source-registry edit, no production-file edit, no install or update was made.

## 1. Fetch and anchor resolution

- URL: `https://1password.com/product/credential-broker`
- Fetch method: `curl -sSL`, Chrome UA, public page only; no account, vault, workflow or SDK touched.
- 2026-10-20 fetch A (21:34Z): HTTP 200, **196,082 bytes**,
  sha256 `6170ccddff028eab32c1d18f874f4598f8d793e88fa7782c06bde435f492b547`; effective URL unchanged.
- 2026-10-20 fetch B (21:40Z): HTTP 200, **196,082 bytes**,
  sha256 `96d201957e7ba3fa0e08d9b6cf30d87d953014b7885fe8d6545d50b96a1dd4e8`;
  `cmp -l` reports **44 differing byte positions** at identical length; a character-level diff
  finds five changed blocks, all short hex-like tokens (for example `3c4c4e55`→`ddadafb`), not
  prose. The anchor and status sentences occur exactly once and are identical in both fetches.
- Stored row digest (opened 2026-10-19): `f7ba8254b1109111c42429eb896b9ba767a7320c20c5a9c5fc6f1d993bdffd2f`.
  The S005 registry line is byte-identical to the frozen-base copy (`diff` of line 11).
  Fields read: kind `docs`, tier `C`, status `queued`, `opened 2026-10-19`, `recheck on-release`,
  `used-by —`.
- **Observed:** the byte pin no longer matches. **Inference:** the mismatch is page-build noise,
  not a proven copy change — two same-day fetches already differ at identical length while the
  anchor/status occurrence counts are identical, and no 2026-10-19 bytes are archived. No restamp,
  no superseding row, no deletion; the row's teaching does not depend on the digest.
- Displayed revision: none. The page shows no version/date; only a `© 2026 1Password` footer.
  The row's "current product page has no displayed version/date" still holds.
- Anchor `§The platform identifies the job`: present; quoted sentence present exactly once.

## 2. Located quotes (each ≤25 words)

Access date for every URL below is **2026-10-20**.

| id | location | quote | words |
|---|---|---|---|
| S005 | §The platform identifies the job | “Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for.” | 20 |
| S005 | FAQ, “Is 1Password Credential Broker generally available?” | “Not yet. Credential Broker is currently in public preview for all Enterprise Password Manager customers, starting with GitHub Actions, and custom OIDC configurations.” | 23 |
| S005 | FAQ, “How does 1Password Credential Broker keep secrets secure?” | “Decrypting a credential requires both keys.” | 6 |
| S005 | §how it works, “Start with GitHub Actions” | “Any workflow running on GitHub Actions can prove its identity to 1Password and receive the exact credentials it's approved for” | 20 |
| S005 | §how it works, “Go further with custom OIDC connections” | “Any system that issues an OIDC token can authenticate directly to 1Password and retrieve only the credentials it's approved for.” | 20 |
| S005 | discover, secure, audit | “Credential Broker is part of the Unified Access platform” | 9 |
| S017 | page title, `https://www.1password.dev/brokered-access/github-actions/` | “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | 14 |
| S018 | page title, `https://www.1password.dev/brokered-access/custom-workflow/` | “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | 14 |
| S018 | introduction / Step 1 | “connected an OIDC provider to your 1Password Business account” / “latest beta release of the 1Password desktop app” | 12 / 8 |
| S018 | Step 3 note | “1Password Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | 14 |
| S019 | introduction, `https://www.1password.dev/brokered-access` | “administrators can set up a supported integration in their 1Password Business account” | 12 |
| S019 | GitHub Actions requirements | “GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren't currently supported” | 17 |
| S019 | GitHub Actions requirements | “If you use GitHub Free for organizations, your team won't be able to use this integration for workflows in private repositories.” | 21 |
| S020 | §New in this release: Custom OIDC workflows, `https://1password.com/blog/1password-credential-broker-public-preview` (published 2026-07-28) | “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | 19 |
| S020 | introduction / §Try 1Password Credential Broker today | “available for all Enterprise Password Manager Business customers” | 8 |
| S007 | introduction, `https://www.1password.dev/brokered-access` | “only remain accessible for the duration of the workflow” | 9 |

S005's own documentation link (`1password.dev/environments/credential-broker`) resolves to
`https://www.1password.dev/brokered-access/github-actions` — the **GitHub Actions** feature page,
not the overview. That is consistent with the product page's "starting with GitHub Actions"
phrasing, but it does not make the product page's custom-OIDC status claim correct.

S005 is the only assigned source. S017/S018 are the feature-specific documentation pages reached
from the S005 page and the setup guide; S006/S007/S019/S020 are used only as the existing
tier-A/B links for adjudicating E1's claims, not as new S005 evidence.

## 3. Scoped teaching vs associated entry claims

S005's scoped teaching — "a workload's identity is checked against policy before approved
credentials are delivered… a lead, not mechanism authority" — remains **true** at the page's
product-positioning level. The current page, however, also carries status, eligibility and path
wording that the row's anchor does not record and that conflicts with the tier-A feature pages.

Associated entry: `corpus/knowledge/onepassword-machine-credentials.md` (E1), item 4 plus both
errata; the corrected active reading is also now in
`corpus/knowledge/feature-bound-credential-review.md` (Broker rows 1–3, citing S017–S020).

| entry claim (location) | current source evidence | verdict |
|---|---|---|
| E1 item 4, sentence 1: trust policy determines credentials retrievable during the authorized job, no standing vault access [S006] | S005 says the same at positioning level; S006 (tier A) already carries it | **Consistent; S005 not needed.** Do not add S005 as support. |
| E1 item 4, sentence 2: “the setup guide also labels the workflow integration public preview” [S007] | Parent guide/nav says `(public preview)`, but the custom-workflow feature page title says `(public beta)` [S018]; S020 separates Actions preview from custom beta | **Reject the unqualified singular.** It is true for Actions only; the round-22 erratum's feature split is the operative reading. |
| E1 item 4, sentence 2: every configured OIDC claim must match; workflow-duration access [S007] | S005 has no claim-matching or duration text; S007 carries both | **No S005 support.** S005 cannot stand in for S007 mechanics (QA1). |
| E1 item 4, sentence 3: integration key stored as an org CI secret; encryption key; valid OIDC identity needed “to decrypt” [S006, S007] | S007: integration key “required to decrypt”; stored as `OP_INTEGRATION_KEY`. S006: leaked integration key alone is a dead end because a valid OIDC token is also needed. S005: two keys, integration key plus enclave key, “Decrypting a credential requires both keys.” | **Citation merge, not an S005 rescue.** Split it: S007 for the integration key's decryption role; S006 for the OIDC token access condition; S005 only as tier-C positioning. |
| E1 round-21 erratum: “The per-workflow release status of the custom-OIDC path is therefore **unverified**” | S018 title says `(public beta)`; S020 says “capability in beta: custom OIDC workflows” | **Falsified.** The erratum's negative claim was swept on the parent guide only; the feature page and the announcement's beta section carry the answer. This is a QA6 wrong-page negative sweep and a QA10 unopened feature link. The round-22 erratum correctly supersedes it. |
| E1 round-22 erratum: Actions public preview; custom OIDC public beta; EPM Business; GitHub.com/deployment restrictions; beta desktop app; JavaScript SDK only | Independently reproduced on S017, S018, S019, S020 | **Correct bounded control.** Admit as the current reading; the historical item 4 stays as written under the append-only convention. |
| `feature-bound-credential-review.md` Broker rows (S017–S020) | Matches the feature pages; it does not cite S005 | **Correct.** S005 is an outlier against it, not a source for it. |

**Qualifier set captured from S005 (for the registry row's unreported surface):**

- **Product:** 1Password Credential Broker, positioned inside the Unified Access platform.
- **Status:** public preview, explicitly not GA (“Not yet”); no displayed version/date.
- **Eligibility (product page):** “all Enterprise Password Manager customers” — omits the
  `Business` qualifier used by S019/S020 and by S018's setup prerequisite.
- **Path (product page):** “starting with GitHub Actions, and custom OIDC configurations” —
  flattens Actions public preview and custom OIDC public beta into one preview label.
- **Path (feature pages):** GitHub.com only; GitHub Enterprise Server and GitHub Enterprise Cloud
  with data residency unsupported; GitHub Free organizations cannot use private-repository
  workflows; custom OIDC needs the beta desktop app and only the JavaScript SDK.
- **Mechanism:** product positioning only; the two-key sentence is not a configuration procedure
  and does not establish claim matching, workflow duration, key storage or SDK support.

## 4. Calibration decisions (C1)

The unit below is the decision, not the number of rows authored. Each expected outcome is
source-grounded; the known E1 overclaim is rejected and a bounded control is retained.

| # | proposition tested | expected | S005 basis / cross-check | verdict |
|---|---|---|---|---|
| C1-1 | S005, §The platform identifies the job, supports the product-level statement that identity is policy-checked before delivery | ADMIT, tier-C positioning only | anchor quote (20 words) | **ADMIT (bounded)** |
| C1-2 | S005 supports OIDC claim matching or workflow-duration mechanics | REJECT | no such text; S007 only | **REJECT** |
| C1-3 | S005 supports “both Broker paths are public preview” | REJECT | S005 status quote vs S018 `(public beta)`, S020 beta | **REJECT** |
| C1-4 | S005 supports eligibility for all Enterprise Password Manager customers | REJECT as entry support | S019/S020 say EPM **Business**; S018 says Business account | **REJECT** |
| C1-5 | S005 supports “any workflow running on GitHub Actions” without deployment limits | REJECT | S019: GitHub.com only, no GHES/GHEC data residency, GitHub Free private repos unsupported | **REJECT** |
| C1-6 | S005's two-key sentence is mechanism authority | REJECT as authority | tier C; S006/S007 already carry custody; no procedure | **REJECT as authority; retain as lead** |
| C1-7 | S005 should be promoted to `mined` and cited by E1 | REJECT | no unique support; duplicates S006/S007/S017–S020; tier C cannot stand alone (QA1) | **REJECT** |
| C1-8 | S005 should be deleted or demoted from its queued lead status | REJECT | anchor resolves; positioning teaching true | **REJECT; keep `queued`** |
| C1-9 | A superseding S005 row is needed for the current page state | REJECT | no claim depends on the digest; status/eligibility now on S017–S020; a new row perturbs the census for no authority | **REJECT; no new row** |
| C1-10 | E1's round-21 “custom-OIDC status unverified” stands | REJECT | S018 title `(public beta)`; S020 beta sentence | **REJECT; falsified** |
| C1-11 | E1's round-22 feature split, Business eligibility, deployment and SDK limits | ADMIT | S017–S020 reproduced | **ADMIT (bounded control)** |
| C1-12 | E1 item 4's “setup guide labels the workflow integration public preview” can stand unqualified | REJECT | S018 public beta; S005 flattens both | **REJECT; erratum supersedes** |
| C1-13 | E1's “valid OIDC identity … needed to decrypt [S006, S007]” is correctly cited | REJECT citation merge | S006 = OIDC token access condition; S007 = integration key required to decrypt; S005 = two keys | **REJECT; split citations** |

E3 (Vault/OpenBao) is outside S005's evidence; this report makes **no** E3 claim. No row-count
or criteria-count score is offered — C1 is decided by the propositions above.

## 5. Falsifier

**S005 lead.** Falsified if the anchor section or quoted sentence disappears, the product is
renamed/withdrawn, the page changes to GA, the eligible plan changes, or the feature-path list
changes. This falsifies the **lead**, not an entry: no entry cites S005.

**E1's corrected reading.** Falsified if either feature page changes status (`public preview` /
`public beta`), the setup guide stops requiring a 1Password Business account, the GitHub.com /
GHES / GHEC-data-residency / GitHub Free restrictions change, or the custom workflow stops
requiring the beta desktop app or widens beyond the JavaScript SDK. Recheck trigger:
`on-release`, opening S017 and S018 **separately**, then S019's eligibility/requirements.

**S005 as an eligibility widening.** Falsified by any tier-A/B page stating availability to all
Enterprise Password Manager customers (not Business). As of 2026-10-20, S018/S019/S020 still say
Business, so S005's broader wording is the outlier, not evidence of an expansion.

## 6. Freshness and pin reconciliation

### S005 itself

- Old digest `f7ba8254…` (2026-10-19) → observed `6170ccdd…` and `96d20195…` (2026-10-20,
  same length, 44 differing byte positions). Two fetches already differ from each other, so the
  digest is a **snapshot**, not a content-stability pin.
- No restamp is possible under this seat's contract, and none is needed: S005 is `queued`,
  `used-by: —`, and the census gate never re-fetches. The honest disposition is to record the
  old/new digests and keep the row queued.
- No superseding row: the row's immutable fields (scope, anchor, teaching, status) remain true;
  the new status/eligibility qualifiers are carried at tier A by S017–S020; a duplicate tier-C
  row would add no authority and would perturb the registry census.
- `recheck: on-release` remains the right trigger. The custom-OIDC wording on S005 suggests a
  possible status change, but S018 still says public beta, so no release event is established;
  the conflict is recorded, not resolved by preferring the newer page.

### Adjacent state observed in the same tree (parent-owned; not this seat's correction)

These were live during the read and may change at integration. Exact values at 21:40Z:

| artifact | recorded | observed | consequence |
|---|---|---|---|
| `corpus/SOURCES.md` stamp row | `db134917…`, 43 lines, 14,261 bytes | `ebf88646…`, 66 lines, 18,222 bytes | stale stamp; regenerate with old/new preserved |
| E1 stamp row | `7635be81…`, 35 lines, 6,240 bytes | `e885081e…`, 68 lines, 8,328 bytes | stale stamp; owned by Entry15/parent, not this seat |
| `R21-02` census pin | `rows=16 A=14 B=0 C=2 queued=1 mined=14 rejected=1 entries_sourced=3 legacy=21` | currently `FAILED (findings=1 rows=21)`; after the S021 fix the expected clean line is `rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21` | re-pin required; current row fails |
| `R14-01` docs pin | `entries=24 row_linked=21 … unpinned=0` | `BROKEN (entries=25 row_linked=22 … unpinned=1)` | new `feature-bound-credential-review.md` has no stamps row; after stamping, the expected pin is `entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0` |
| `R12-03` stamps count | `63` | 63 now; 65 if stamp rows are added for `lessons/round-22.md` and `feature-bound-credential-review.md` | re-pin required if membership grows |
| census finding | — | `FINDING SC_USEDBY_NOCITE id=S021 path=corpus/lessons/round-22.md` | S021's used-by lists `round-22.md`, but that lesson's `source:` line does not carry S021; add the id or remove the used-by path |

The two new files (`corpus/lessons/round-22.md`, `corpus/knowledge/feature-bound-credential-review.md`)
have no stamps rows. `feature-bound-credential-review.md` also has no `# ` title before its
`source:` line; no current gate checks that, so it is a style/QA6 observation only.

## 7. Proposed correction (no registry edit)

1. **Do not edit S005.** Keep it `queued`, `used-by: —`. Do not promote it, cite it in E1, or add
   a superseding row. The product page is the exact QA9/QA10 failure mode (a tier-C page
   flattening two feature statuses and dropping the Business plan), and it must remain a lead.
2. **Optional E1 append-only note** (if the parent wants the outlier recorded where a reader will
   meet it; exact text):
   > **Product-page outlier (S005, appended 2026-10-20).** The Broker product page as opened
   > 2026-10-20 says the preview is “for all Enterprise Password Manager customers, starting with
   > GitHub Actions, and custom OIDC configurations” (S005, FAQ; queued registry lead, not
   > admitted support). That tier-C page conflicts with the feature pages: Actions is public
   > preview [S017], custom workflows are public beta [S018], and setup requires a 1Password
   > Business account [S019]. It does not widen this entry's status or eligibility reading.
3. **E1 header/expectation migration** (parent decision; preserve old values in the round
   migration record, do not silently rewrite):
   - old `verified-at: 2026-10-19 (reopened the six cited public documentation pages …)`
   - new `verified-at: 2026-10-20 (reopened S017–S020; S005 rechecked as a queued lead)`
   - old `recheck: … on-release for S006–S007 — … check Broker preview status, claim requirements, workflow duration, and integration-key custody.`
   - new `recheck: … on-release for S006–S007 and S017–S020 — open the GitHub Actions and custom-workflow feature pages separately; check per-feature status, Business eligibility, GitHub deployment restrictions, beta app and SDK support, claim matching, workflow duration and integration-key custody.`
4. **If S017–S020 are added to E1's `source:` line**, the citation handshake requires their
   `used-by` to list E1 as well; otherwise the census emits `SC_ENTRY_CITE … used-by-omits-entry`.
   Conversely, listing E1 in `used-by` without the entry's `source:` id emits
   `SC_USEDBY_NOCITE`. Change both sides together, or leave the erratum lesson-cited as it is.
5. **Fix the observed S021 handshake before integration** (`SC_USEDBY_NOCITE` above), and stamp
   the two new files with the old/new row-count migration recorded.

## 8. Limits and remaining unknowns

- Public pages only; no account, vault, workflow, SDK, deployment or live product behaviour was
  exercised. The page's marketing statements are not verified against runtime.
- No archived 2026-10-19 S005 bytes exist in the corpus and no archive query was made; the
  **date** of the current “all EPM customers / custom OIDC in preview” wording is unknown. It is
  not claimed to be new.
- The two fetches are same-day samples only; no longitudinal stability is claimed. The 44-byte
  difference at identical length is observed; the five changed blocks are short hex-like tokens
  with no prose change, so build noise is the supported inference, not a proof of the cause.
- The worktree was being written by siblings during the read. §9's digests define the read state;
  later integration may change counts and rows. No jj/Git index or lane state was touched.
- `feature-bound-credential-review.md` and `lessons/round-22.md` appeared during the read; their
  ownership is not this seat's. Their observed pin defects are reported for routing, not fixed.
- E1's round-21 erratum is a historical record; this report does not rewrite it. The round-22
  erratum is the operative correction.

## 9. Read state (exact)

- Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
- Observed at `2026-10-20T21:40:05Z`:
  - `corpus/SOURCES.md` `ebf8864654b7cf1669ffb8944d7682cdefbea3234bca3adbbcb32157488f4de2`, 66 lines / 18,222 bytes (S005 line byte-identical to base).
  - `corpus/knowledge/onepassword-machine-credentials.md` `e885081e4d566af05080edde8e92de7692db4dc974b678b6020f2e30e68f96af`, 68 lines / 8,328 bytes.
  - `corpus/knowledge/feature-bound-credential-review.md` `213b246eec59d8285f181e649895abe2bdf2c714b50c895d4e7c2e2b34bf49e5`, 43 lines / 4,319 bytes.
  - `corpus/lessons/round-22.md` `f080f33a1eaa06bcf37c995ee224fc13c6730f8026ea0788faa2c306f56156eb`, 80 lines / 8,506 bytes.
  - `corpus/stamps.tsv` `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b`, 63 rows.
  - `corpus/claim-ledger.tsv` `8a4019cfc1eec916f30a8958fbc3ca2d30e59632e0f1d5d843cea6d1c24faa97`.
- No installs or updates were performed.

## 10. Checks parent should run after integration

- `bash corpus/sources-census.sh` — expect `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)` after the S021 handshake fix.
- `bash corpus/claim-ledger.sh docs` — expect `DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0 ... )` after `feature-bound-credential-review.md` is stamped.
- `grep -c '[^[:space:]]' corpus/stamps.tsv` — expect `65` if stamp rows are added for `lessons/round-22.md` and `feature-bound-credential-review.md`; re-pin `R12-03` with the old/new membership.
- `bash corpus/sources-census.sh --selftest` — expect `SOURCES_CENSUS_SELFTEST: PASS (47 cases)`; data rows do not change it.
- `bash corpus/claim-ledger.sh verify` is host-bound (`R18-01` reads host-private surfaces); use QM12's per-row substitute rather than claiming it was run here.

Report: `.ufo/waves/round-22/build/Source05.md`
