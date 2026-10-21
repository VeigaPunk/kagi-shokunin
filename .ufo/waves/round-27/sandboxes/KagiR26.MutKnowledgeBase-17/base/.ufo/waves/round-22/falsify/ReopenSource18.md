# ReopenSource18 — S018 reopen, S017–S020 feature split, revision accounting

Seat: `KagiR22.ReopenSource18` (leaf; no subagent dispatch). Axes: **calibration**, **freshness**.
Read revision: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (git HEAD at read time; integration landing named by the wave). Historical BEFORE cited by the plan: `c2cab35bc92e57e39e5489bac3386db078345b3f`; it was not used as the falsification input.
Read-only seat: no production edit, no private clone, no lane jj/Git mutation, no account/vault endpoint, no installation. Four dead W1 scribe seats remain uncredited; this evidence is independent and does not replace them.

Axes named for this seat: (1) calibration — does the integrated S018 row and its typed use reject the E1/E3 overclaims and admit only bounded, feature-specific qualifiers? (2) freshness — do the S018 pin, census expectation and migration record agree with the bytes and membership actually read?

## Frozen inputs actually read

Every claimed code/doc input below is listed in `.ufo/waves/round-22/integration-manifest.json`; I recomputed SHA-256 over the bytes I read and matched the manifest exactly (bytes/lines also matched):

| path | SHA-256 (manifest = observed) |
|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` (19,721 B / 86 L) |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` (47,434 B / 995 L) |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` (45,532 B / 1,040 L) |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` (4,440 B / 43 L) |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` (15,700 B / 192 L) |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` (7,213 B / 69 L) |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` (17,770 B / 58 L) |
| `corpus/QUALITY.md` | `dc2f5fe27935c3e238c0992cb14a4285bbee5edd902e2174b963561bcc84c09d` (12,926 B / 79 L) |

`corpus/lessons/round-21-verifier-spotcheck.md` recomputes to `6e4fa622…b08711f1ffb`, the hash embedded in `corpus/feature-claims.json`'s outside-verifier references. No input bytes changed during this read-only wave (HEAD and manifest hashes held at first and last read).

## S018 reopen — exact URL and all four anchors

URL: https://www.1password.dev/brokered-access/custom-workflow/ — opened 2026-10-20 (docs alternate-markdown for text; raw HTML for digest).

Digest: recorded `d0890c11edaa85d3ec68680d8d9bc867db502229fb3c815ee6b1b62ac62b76e5`; my raw-HTML GET is `d0890c11…62b76e5`, 1,282,825 B. **The recorded acquisition digest reproduces exactly**, so this page has no byte drift under the same representation.

| anchor | observed text (quote ≤25 words) | heading / location |
|---|---|---|
| H1/status | “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | page title `<h1 id="page-title">` |
| introduction | “connected an OIDC provider to your 1Password Business account” | introduction, after Beta badge |
| Step 1 | “latest beta release of the 1Password desktop app” | “Step 1: Set up an Environment” |
| Step 3 | “only supported in the 1Password JavaScript SDK at this time” | “Step 3” NOTE |

All four match the S018 registry row (`corpus/SOURCES.md:24`: anchor “Page title, introduction, Step 1, Step 3 note”) and the lesson Gate row (`corpus/lessons/round-22.md` §Gate), including its admission scope (“status independently of the setup guide; Step 1 beta desktop app and Step 3 JavaScript SDK note also opened”). The row's `teaches` sentence — public beta; Business + connected OIDC provider; beta desktop app; JavaScript SDK only — is supported by the quoted text. The only nuance: Step 1 is a setup instruction (“make sure you have…”), and the desktop app is also used for the Connect step, so the typed field name `runtime_constraints` is slightly broader than “runtime”; the factual requirement itself is page-supported.

**Same-page status trap is real and the anchor policy is correct.** The raw S018 HTML contains 11 case-insensitive `public preview` strings (navigation group “Credential Broker (public preview)”, sidebar/schema JSON, related links, one CSS comment) against 21 `public beta` strings. Whole-page substring scanning would label the feature preview; the catalog anchors `release_status` at `page-title-H1`, which is beta. This independently confirms the disposition recorded in the lesson (§Additional bounded findings, CriticAdmission).

## S017–S020 examined separately (status vs eligibility)

| row | own feature page status | own eligibility/setup qualifier | independent result |
|---|---|---|---|
| S017 https://www.1password.dev/brokered-access/github-actions/ | H1 “GitHub Actions at runtime (public preview)” + “Public Preview” badge | “connected your GitHub organization to your 1Password Business account”; latest (not beta) desktop app | public preview; Business-connection prerequisite ✓ |
| S018 https://www.1password.dev/brokered-access/custom-workflow/ | H1 `(public beta)` + “Beta” badge | Business account with connected OIDC provider; latest beta desktop app; JavaScript SDK only | public beta, distinct from guide label ✓ |
| S019 https://www.1password.dev/brokered-access | H1 “Set up … in their workflows (public preview)” | “a supported integration in their 1Password Business account”; GitHub.com only; Enterprise Server and Enterprise Cloud with data residency unsupported; GitHub Free private repositories excluded | guide-level preview label; Business setup + GitHub deployment restrictions ✓ |
| S020 https://1password.com/blog/1password-credential-broker-public-preview (published 2026-07-28) | article title “now in public preview” | “available for all Enterprise Password Manager Business customers”; §“New in this release: Custom OIDC workflows”: “we're slowly rolling out a new capability in beta: custom OIDC workflows” | dated feature split: Actions preview vs custom-OIDC beta; EPM Business availability ✓ |

The lesson's central calibration claim is therefore reproduced from primary pages: the S019 guide title says *public preview*, while the S018 feature H1 says *public beta*; the dated S020 announcement states the split explicitly. No uniform Broker status is supported, and the S018 row does not launder the guide title.

One additional public page sharpens the scope: the product page https://1password.com/product/credential-broker (undated, S005) says Credential Broker is “currently in public preview for all Enterprise Password Manager customers”, naming “custom OIDC configurations” under that preview. This is a product-level label on another property, not the feature page. The corpus's rule (feature page H1 wins; an announcement/guide is not a universal status oracle) resolves it, and S005 is tier C; but the live vendor-property conflict is not analysed in the round-22 lesson, so it is a residual scope limit rather than a contradiction of the admitted feature row. It must not be read as independent confirmation of either status.

## Original rows and lesson usage

- `git diff c2cab35…..HEAD -- corpus/SOURCES.md` = **43 insertions, 0 deletions**. The registry change is a pure append; no original line was rewritten. A line-level diff of `S001`–`S016` between `.ufo/waves/round-22/frozen/before/corpus/SOURCES.md` and `corpus/SOURCES.md` is empty.
- S006 and S007 remain byte-identical, including their public-preview status/recheck fields; the round-22 supersede notes live in S019/S020's `teaches` cells and the SOURCES.md supersession paragraph, exactly as claimed.
- The round-21 “unopened lead” for the custom-OIDC sub-page is still present verbatim, with an appended disposition paragraph stating it is now S018; nothing was erased.
- S017–S020 `used-by` = `corpus/lessons/round-22.md, corpus/knowledge/feature-bound-credential-review.md`; both files exist and both name the rows (lesson §Gate; review provenance line S017–S021). S018's status/recheck were not mutated after drafting in the integrated tree.
- No immutable-field mutation found. No registry row count is offered as a calibration result; the counts below are only pointer/consistency checks.

## C1 calibration — executed decisions (not authored row counts)

Commands executed against the frozen tree (authorized local fixtures; no network):

| command | observed | exit |
|---|---|---|
| `python3 corpus/feature-claims.py --phase before` | 10/10 expected decisions matched: 2 `reject:false-claim` (E1 status conflation, same-page preview), 8 `reject:bar-fail`; `false_admissions=0 misses=0`; each of the 10 cells `matches=1` | 1 (intended red) |
| `python3 corpus/feature-claims.py --phase after` | `admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0 unjudgeable=0` | 0 |
| `python3 corpus/feature-claims.py --phase boundary` | 3 records `cannot-evaluate` (unknown feature, unknown field, unknown source), `unjudgeable=3`, `scored=no` | 2 (intended) |
| `python3 corpus/feature-claims.py --selftest` | `FEATURE_CLAIMS_SELFTEST: PASS cases=10` | 0 |

So the mechanism rejects the two known E1 overclaims (status conflation; same-page preview anchor) and the E3 cross-product overclaim, and admits the four bounded controls with zero false admissions. `BEFORE-CUSTOM-UNDERCITED` and the two CUSTOM scope omissions also fail on their intended bars. The status decision is made by catalog comparison at `corpus/feature-claims.py:649-653`, and evidence sets are exact (`required_references` equality at `:733-738`). The 10-before/4-after/3-boundary cases are authored fixtures; the measured result is the per-record decision match, not the count.

## C2 freshness — pin, census and migration accounting

| check | observed | verdict |
|---|---|---|
| `python3 corpus/revision-audit.py --history c2cab35…` | `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0; six ADDED paths: feature-claims.json/.py, feature-bound review, round-21 spotcheck, round-22 lesson, revision-audit.py | matches manifest `revision_audit` |
| `python3 corpus/revision-audit.py --selftest` | `PASS (cases=11 failed=0)`, exit 0 | matches manifest |
| `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21)`, exit 0 | current row, R21-02 expectation |
| `corpus/stamps.tsv` row `corpus/SOURCES.md` | `3ba44518…` / 86 / 19,721 = current file byte-for-byte | pin current |
| frozen before stamp | `db134917…` / 43 / 14,261; `base_observed` identical | old state preserved |
| frozen before run | 6 STALE (config-layering, handler-on-disk-state, handler-trust-boundary, janitor-env-contract, round-18, LOG), `stale=6`, exit 1 | reproduces lesson's six |
| round-21 span (`aea7a4301`→`e1544c1`) | `removed_members: []`; 9 changed stamp records for the same 9 paths, old and new lines preserved | “nine replacements, zero lost members” verified |
| round-22 span (`c2cab35`→HEAD) | 32 changed + 6 added stamp records; `pin-migrations-integration.json` has 38 `stamp_changes` (old_stamp, base_observed, new_stamp, disposition); set difference: 0 uncovered | no silent deletion/laundering |
| claim expectation migrations | R12-03 63→69 (69 actual rows), R21-02 rows 16→21, R13-01 23→25, R14-01 24→25, R11-09/R18-03 97→108, R21-04 39→43, plus R22-01..04; old and new rows preserved | documented |

The S018 freshness chain is complete: the row's page digest reproduces; SOURCES.md's stamp equals the current bytes; the stamp migration preserves old/base/new tuples; the census expectation moved 16→21 and the executable census returns 21. Hash identity proves pointer integrity only — it does not re-verify the vendor facts, and I do not claim it does.

## Findings and proposed corrections

**F1 — concrete supported claim (calibration).** S018's registry row is correct at every anchor: the feature page's own H1 says *public beta*, the introduction requires a Business account with a connected OIDC provider, Step 1 names the *latest beta* desktop app, and Step 3 restricts support to the JavaScript SDK; the recorded acquisition digest still reproduces. The row does not inherit the guide's *public preview* label, and the same-page navigation contains 11 competing “public preview” strings that the title-anchor rule correctly ignores.

**F2 — scope limit (required).** The admitted `AFTER-CUSTOM-BETA-BOUNDED` control asserts `eligibility.plans = enterprise_password_manager_business` with only the product-level S020 sentence (“available for all Enterprise Password Manager Business customers”). The feature page itself says “1Password Business account”; no opened page maps “Enterprise Password Manager Business” to “1Password Business”, and 1Password's public pricing page (opened 2026-10-20) lists “Business” and “Enterprise” as distinct tiers and does not use the label “EPM Business”. The inference is plausible but **unsourced at feature scope**; it is a calibration limit, not a demonstrated false admission. Proposed (no edit made): either cite a plan-mapping source, or split the product-level announcement plan from the feature-level requirement (`business_account_connected`) so the control does not silently merge two plan labels. This is also the honest limit of the C1 gate: it compares claims to a pinned catalog (`feature-claims.py:649-653`), not to vendor truth.

**F3 — low, inert catalog anchor mismatch.** `corpus/feature-claims.json:162` binds `op_cb_custom_oidc / eligibility.requirements / oidc_provider_connected` to quote `S019-business`, whose text is only “a supported integration in their 1Password Business account”. The sentence that supports OIDC-provider connection is the guide's §Custom Workflow (OIDC) Step 1 (“enter your OIDC provider's issuer URL”), which the S019 registry row's anchor field does not name. The binding cannot change a decision today: the custom-OIDC `eligibility.requirements` required set is exactly `{S018-intro}` (`feature-claims.json:238`), and `feature-claims.py:733-738` requires exact set equality, so citing S019-business is rejected as `FC-EVIDENCE-MISSING`. Proposed: move the binding to a new §Custom Workflow quote and add that section to the row's anchor, or drop the binding (S018-intro already supports the value). Analogous structural bindings on S019 quotes are anchor tokens and are likewise unused by admitted controls.

**F4 — freshness (informational, no drift claim).** S017, S018 and S019 raw-HTML digests all reproduce exactly; S020's recorded digest `55bf23fe…` does not, and two back-to-back GETs of the blog returned different HTML (`280ed20a…` then `bdf49c41…`; both 190,261 B). The cited S020 text is still present, so this is page non-determinism, not semantic drift, and the corpus already refuses to treat a changed Fetch hash as drift. However, the lesson's blanket phrasing (“earlier undocumented Fetch hashes … not presently reproducible”) is overbroad: three of the four rows are in fact reproducible byte pins. Proposed: record the acquisition representation (raw HTML via GET, no content negotiation) alongside each digest, and distinguish reproducible docs-page pins from dynamic marketing-page point observations. No re-stamp or deletion is implied.

**F5 — minor field label.** The custom-OIDC “beta desktop app” requirement is registered under `runtime_constraints`; the page states it as Step 1 setup (“make sure you have…”), and the desktop app is also used to Connect the Environment. The factual reading is right; only the field name overstates it as runtime-only. Low priority; do not change the decision.

## Verdict

S018 and its S017–S020 calibration context **survive fresh falsification**: no false admission among the four controls, no mutation of S001–S016, no dropped stamp member, no silent expectation rewrite, and the S018 pin/census/migration chain is consistent. Two bounded corrections are proposed (F2 plan-label scope; F3 quote anchor), and one documentation refinement (F4 representation-aware digests). No outside agreement or overall accuracy scalar is claimed; no depth move and no legacy-header count claim is made.

## Remaining unknowns

- Whether “Enterprise Password Manager Business” (S020) and “1Password Business account” (S017/S018/S019) name the same entitlement; no opened page states the mapping.
- Which vendor label is operator-current for custom OIDC: the feature page (beta), the dated announcement (beta), or the undated product FAQ (product-wide public preview, including custom OIDC). The corpus's feature-page rule resolves this by policy, not by vendor reconciliation.
- The exact representation/UA/date behind S020's recorded digest; today the page is not reproducible even between adjacent GETs.
- Whether S017–S019 digests remain stable across other clients/CDN edges; only one HTTP client and no content negotiation were exercised here.

Report: .ufo/waves/round-22/falsify/ReopenSource18.md
