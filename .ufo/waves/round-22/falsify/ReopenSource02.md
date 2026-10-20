# ReopenSource02 — S002 reopen, S017–S020 feature status/eligibility, revision accounting

Axes: **C1 calibration** and **C2 freshness**. Leaf seat: read-only production; this report is the only write. No subagents, no installs, no account/vault/CLI/SDK execution, no host loopback probes; public documentation GETs only.

## Read revision and measured freeze

- Integration landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (`git rev-parse HEAD` at read time). The cited `c2cab35…` is the historical BEFORE, not this input.
- `integration-manifest.json` sha256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`; its input pins match the tree bytes I read:

| file | sha256 | lines | bytes |
|---|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 86 | 19721 |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 192 | 15700 |
| `corpus/knowledge/onepassword-machine-credentials.md` | `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` | 80 | 9048 |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | 43 | 4440 |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | 995 | 47434 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | 7213 |

All six match the manifest. `corpus/SOURCES.md` carries 21 rows (`S001`–`S021`).

## S002 — independent reopen

**URL:** `https://www.1password.dev/connect` (no query, no fragment). Title observed: `1Password Connect`.

**Representations opened 2026-10-20 ~22:16Z:** the page's advertised markdown alternate `https://www.1password.dev/connect.md` — 3,792 bytes, sha256 `ee60a0dfb3d41e15d52e8229b7b7a00a8b9dabfed181c0a5acb6057f1c60fe48`; and the HTML `/connect` — 1,186,550 bytes, sha256 `9e00e86dafcf8058332a74dfff983bd242c5d62b62109ffb6d495fd35c5b1cea` (served `date: Tue, 20 Oct 2026 22:16:45 GMT`). These are falsify-time observations, not new registry pins. The HTML digest independently coincides with the advisory W1 build report; that seat remains uncredited and is not the basis of any verdict here.

**Located anchor and teaching.** The row's quote is verbatim in the document, 20 words:

> “The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API.”

Locus: the `connect-diagram.png` image **alt text** (the diagram caption), not body prose. The page introduction separately supports the REST half: “access your 1Password items and vaults in your company's apps and cloud infrastructure using a private REST API.” The row's anchor (“Page introduction, Connect-server diagram caption”) is therefore accurate, with the precision that the token-bearing sentence lives in the caption/alt text only.

**Concrete supported claim:** S002's teaching — Connect application access uses the server's private REST API and access tokens — is supported by that caption plus the introduction; `S002`'s row is not overclaimed.

**Immutable-row check (freshness):** the S002 line is byte-identical between base `c2cab35…` and the integrated tree; line sha256 `41b6308840538d24f9b876d79744a7ec5d9259ec66320a1044632d73e12d9a78` in both. `diff` of all `S001`–`S016` rows base-vs-integrated is empty. No original status, opened date, recheck, scope, anchor, tier, or used-by field was mutated. `S002` is not cited in `corpus/lessons/round-22.md` (0 matches); its round-22 usage is only the appended erratum in its `used-by` entry, which cites `S017`–`S020`, not `S002`.

**Concrete scope limit / residual calibration defect:** S002 alone carries only the app→REST/token boundary. The page contains one “access tokens” phrase (the caption), one “credentials” and no “separate”, no setup step, no deployment-credential instruction, no per-application-token recommendation, no release status and no plan eligibility (`Business`/`Enterprise`/`beta`/`preview` = 0 matches). Yet `corpus/knowledge/onepassword-machine-credentials.md` item 3 still places `[S002, S003]` after the compound sentence “Connect setup creates deployment credentials for the server and a separate access token for applications or services…; the setup guide recommends a separate token for each application or service.” The round-22 “Additional source-attribution bounds” labels only the *custody-boundaries* conclusion `[INFERENCE]`; it does not split the bracket. The sentence is not false (the pair jointly supports it), but the S002 half cannot support the setup/deployment-credential or per-application clauses. Proposed append, not applied: split the bracket so the app→REST/token clause is `[S002]`, and setup/deployment credentials plus one-token-per-application are `[S003]`; keep the custody conclusion `[INFERENCE]`.

## S017–S020 — feature-specific status and eligibility, examined separately

Each page was reopened independently. Status is taken from the feature page's own title/H1 and badge, never shared navigation or CSS.

| row | page opened | observed status/label | observed eligibility/limits | verdict |
|---|---|---|---|---|
| S017 | `https://www.1password.dev/brokered-access/github-actions/` | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)”; badge Public Preview | “If an administrator has connected your GitHub organization to your 1Password Business account…” | **admit** status + Business prerequisite; row wording supported |
| S018 | `https://www.1password.dev/brokered-access/custom-workflow/` | H1 “…custom workflows at runtime (public beta)”; badge Beta | intro requires an OIDC provider connected to the Business account; Step 1 says use “the latest beta release of the 1Password desktop app”; Step 3 note: only the 1Password JavaScript SDK is supported | **admit** public beta + separate eligibility; row wording supported |
| S019 | `https://www.1password.dev/brokered-access` | guide H1 “…(public preview)”; related-topic link to the custom page says “(public beta)” | intro: “administrators can set up a supported integration in their 1Password Business account”; GitHub requirements: GitHub.com only; Enterprise Server and Enterprise Cloud with data residency unsupported; GitHub Free orgs cannot use it for private-repository workflows | **admit** eligibility/restrictions only; guide label does not settle custom-workflow status |
| S020 | `https://1password.com/blog/1password-credential-broker-public-preview` | published 2026-07-28; §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | introduction: “available for all Enterprise Password Manager Business customers” | **admit** dated feature split + EPM Business eligibility; not a live status oracle |

The four rows keep status and eligibility as separate facts. In particular, the same guide page that says “public preview” in its own title links to the custom-workflow page titled “public beta”; the integrated reading anchors on each feature title, so the round-21 conflation is not reintroduced.

The integrated feature catalog encodes the same decisions: 10 `before` rejects and 4 `after` admits. `BEFORE-E1-STATUS` (custom OIDC given `public_preview` from the S007 guide title) is `reject:false-claim`, exactly the overclaim the S018 title refutes. `BEFORE-E1-ELIGIBILITY` is `reject:bar-fail`, matching the S017/S019 Business prerequisite. The two Broker admits carry the observed qualifiers verbatim in substance: `AFTER-GITHUB-BOUNDED` = public_preview + enterprise_password_manager_business + business_account_connected/github_com_org, excluding GitHub Enterprise Server, Enterprise Cloud data residency and GitHub Free private repositories; `AFTER-CUSTOM-BETA-BOUNDED` = public_beta + enterprise_password_manager_business + business_account_connected/oidc_provider_connected, with beta_desktop_app and javascript_sdk_only runtime constraints. I did not execute the feature gate (left to its assigned seats). E3/S021 was not reopened by this seat.

## C2 — freshness and revision accounting

1. **In-scope stamps reconcile byte-for-byte.** The four stamp rows for `SOURCES.md`, `lessons/round-22.md`, `onepassword-machine-credentials.md` and `feature-bound-credential-review.md` equal the live sha256/line/byte values above. No stale in-scope pointer.

2. **The “nine deleted diff lines” claim reproduces exactly, with zero lost members.** Between `aea7a4301` and `e1544c194…`, `corpus/stamps.tsv` goes 56→63 rows: first-column set difference is **0 removed, 7 added**; line diff is **9 removed, 16 added** — nine old pin lines replaced for the same paths plus seven new paths. The nine replaced paths are exactly the lesson's table: `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`, `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`. This is replacement, not nine lost stamp members.

3. **Before measurement matches.** `before.json` records `stale_count: 6`; the six paths are `corpus/knowledge/config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`, `janitor-env-contract.md`, `corpus/lessons/round-18.md`, `LOG.md` — exactly the lesson's “four historical-source errata entries, round-18 lesson and LOG.”

4. **Integration expectation migrations are preserved with old/new evidence.** `pin-migrations-integration.json` has `base: c2cab35…`, members 63→69, **0 removed**, 6 new members (`feature-claims.json`, `feature-claims.py`, `feature-bound-credential-review.md`, `round-21-verifier-spotcheck.md`, `round-22.md`, `revision-audit.py`), and 12 `claim_changes` carrying exact old and new row text. The expectation moves reproduce: R12-03 63→69, R13-01 23→25, R14-01 24/21→25/22, R11-09 97→108, R21-03 40→47. The R12-03 note itemizes the six added members (two Python tools, feature-claim JSON, corrected review entry, round-22 lesson, outside-verifier evidence). `historical-migrations.json` (`c41af82…`→`e1544c194…`) records only R21-03 40→47 and zero deleted stamps; it is not offered as the full-span record, so the two records are complementary rather than substituted.

5. **S002's historical pin is retained, not laundered.** The row keeps `68017d4c…` as the 2026-10-19 point observation. Today's HTML and markdown digests differ/are recorded separately; because the original representation is unrecorded, I do not call the old pin stale-by-content, nor do I bless the new digest as an expected replacement. The round-22 SOURCES erratum's rule — original Fetch hashes are historical observations, not currentness proofs — is followed.

6. **Freshness limit of the new rows.** S017–S020 carry `opened 2026-10-20` and precise anchors but no Fetch digest. Their freshness is therefore date/anchor-based, not byte-reproducible from the registry alone. The falsify-time digests I observed (markdown alternates unless noted) are: `github-actions.md` `092fd0ba581cbb60eaf756e853d8659c15b76e17dd616c23aff8137ef42c6d0f` (5,245 B); `custom-workflow.md` `5da83bb665fc575b6c7d27c3b31ab2e1be4e2feded35fc119e1185467311016e` (6,088 B); `brokered-access.md` `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3` (6,841 B); S020 HTML `d9b7f1fa07f204e3a5d55fdfc7e1d8e6fc7984d898e0ed724e90af8341bf8683` (190,261 B). These are observations, not registry pins.

## Verdict

- **Supported claim:** S002's registered teaching and anchor are accurate — the Connect diagram caption states apps communicate via access tokens and a REST API, and the introduction states the private REST API. The immutable S002 row and all original `S001`–`S016` rows are untouched at the measured landing.
- **Scope limit:** the token sentence exists only as diagram alt text, and S002 contains no setup/deployment-credential, per-application-token, rotation, status or plan-eligibility text; the machine-credentials entry's `[S002, S003]` bracket therefore over-attributes its first clause to S002.
- **Proposed correction:** append one bracket-splitting sentence to that entry (text above); no registry supersession, no S002 field change, no production edit made here.
- **C1 decisions observed:** S017 admit (status + Business), S018 admit (public beta + OIDC/Business + beta app + JS SDK), S019 eligibility/restrictions admit while rejecting the guide-level uniform-preview reading, S020 dated split + EPM Business admit; the known E1 status/eligibility overclaims are rejected by the integrated catalog and by the reopened feature titles. No false admit found in my scoped sample. Not an outside agreement or an accuracy scalar.
- **C2 result:** nine-line replacement accounting reproduces with zero removed members; six-before set matches; integration 63→69 with 0 removed and 12 exact old/new claim changes; in-scope stamps match bytes. No silent deletion or restamp-as-freshness found in scope.

## Remaining unknowns and limits

- S002's 2026-10-19 bytes are unrecoverable; the original pin's representation is unknown, so “stale” is not asserted. The page is build-coupled and its `lastModified`-style metadata is a build stamp, not an editorial date.
- This seat did not reopen S003, S021, `/connect/get-started`, SDK pages, or the feature gate implementation; those belong to other seats. No account, workflow, SDK, vault, CLI or API call was exercised.
- W1 build reports (including `build/Source02.md`) are advisory in-flight reads; the dead W1 seat is not credited. No installs or upgrades were performed.

## Checks the parent should run after integration

1. `bash corpus/sources-census.sh` — confirm exit 0/CLEAN with 21 rows and the S017–S021 used-by handshake.
2. Feature gate selftest (10 cases) plus the typed records: 10 `before` rejects, 4 `after` admits, 3 boundary/unjudgeable — confirm the S017–S020 qualifier records above still admit.
3. `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` — expect `stale 0, dropped 0, added 6` at the frozen input.
4. If the S002 bracket append is adopted, verify only the new sentence was added and the S002 row remains byte-identical.

Report: `.ufo/waves/round-22/falsify/ReopenSource02.md`
