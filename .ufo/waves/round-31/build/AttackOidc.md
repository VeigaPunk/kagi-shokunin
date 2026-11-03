# AttackOidc — round-31 C2 attack on the staged OIDC entries (2026-11-03)

Seat: AttackOidc (reviewer, kagi-r31-build wave). Target: the staged text of
`oidc-federation-trust-policy.md` and `cdp-bridge-1password-oidc-workflow.md`
(`/home/vgpnk/Projects/shokuknow/merge/kagi/`, READ-ONLY) against
`corpus/QUALITY.md` QA1–QA10, the round-30 M30-8 negative-bound class, the
census shape, and the staged fetch-sha pins. Method: every cited page re-fetched
2026-11-03 with the declared profile (`curl -fsSL --compressed -A
'kagi-shokunin-round23/1.0 (documentation verification)'`, `--max-time 30`);
quotes located with the lane's own `corpus/rendered-text-v1.py locate`; census
behavior measured on scratch fixtures (`sources-census.sh verify --root`), never
on the lane tree. Receipts: `.ufo/waves/round-31/AttackOidc/`
(`fetch-digests.tsv`, `needles.txt`, `census-staged-as-is.txt`,
`census-adopted-shape.txt`, `bodies/p1–p11.body`).

## Verdicts (Gate-table ready)

| staged → adopted | decision and basis | URL, access date, located quote |
|---|---|---|
| S052 → S061 AWS IAM create-oidc | ADMIT, tier A docs, 180d | https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html ; 2026-11-03; sha16 `141dd4819db34dc2` (campaign `c69aea104f5fb072` does not reproduce — recorded); quote "The aud claim must match the Audience value" located once; `claims_supported` example carries `aud`, `iat`, `iss`; issuer-URL rules located ("must begin with https://", "query parameters are not" allowed, "should not contain a port number"); no page stamp (0 hits) |
| S053 → S062 AWS IAM OIDC condition keys | ADMIT, tier A docs, 180d | https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html ; 2026-11-03; sha16 `fb5b2e35ec37c18b` (campaign `c65b05feaf7e5140` drifts); §"Available keys for AWS OIDC federation" located; `token.actions.githubusercontent.com:aud` located; the load-bearing sentence located verbatim: "When a claim is not available in session, the OIDC condition context key can only be used in a role trust policy for the initial AssumeRoleWithWebIdentity authentication." |
| S054 → S063 AWS STS AssumeRoleWithWebIdentity | **REFUSE AS STAGED → ADMIT AFTER FLIP (F-A, load-bearing)** | https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html ; 2026-11-03; sha16 `a08888ce4d86adf2` (campaign `e5349f6cbfdbc717` drifts). The staged anchor "§Request Parameters, entry `Audience`" **does not exist on the current page**: request parameters are DurationSeconds, MinimumSessionTokenSize, ProviderId, RoleArn, RoleSessionName, WebIdentityToken; `Audience` occurs exactly twice in the whole page, both in the RESPONSE section (element description + XML example). The quoted sentence "The intended audience (also known as client ID) of the web identity token" is the response element's description. The page also says of ProviderId: "Do not specify this value for an OpenID Connect identity provider." |
| S055 → S064 GCP WIF best practices | ADMIT, tier A docs, 180d | https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation ; 2026-11-03; sha16 `b6a55ce1bb731b65` (campaign `ac85362d89649e66` drifts); bullets located: "Use attribute conditions when federating with GitHub or other multi-tenant identity providers", "Use the URL of the workload identity pool provider as audience", "Use a single provider per workload identity pool to avoid subject collisions"; the 23-word collision quote located verbatim; page stamp "Last updated 2026-10-29 UTC" **is present** (refutes the entry's blanket no-stamp bound, F-B) |
| S056 → S065 GCP WIF ja | ADMIT, tier A docs (ja terminology scope, self-bounded flip-to-C), 180d | https://docs.cloud.google.com/iam/docs/workload-identity-federation?hl=ja ; 2026-11-03; sha16 `bc0abaf9dcd4d7cc` (campaign `97c3149df09fbc90` drifts); §属性条件 located; "属性条件は、アサーション属性とターゲット属性をチェックする CEL 式です" located; `google.subject=assertion.sub` located; stamp "最終更新日 2026-03-04 UTC" present |
| S057 → S066 Alibaba RAM trusted-IdP | ADMIT, tier A docs, 180d | https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp ; 2026-11-03; sha16 `2232fe3cabac70a8` (campaign `48173805d3c27af4` drifts); 限制条件表 located with 是否必选 flags: `oidc:iss` 是 (StringEquals mandatory, value only the registered issuer URL), `oidc:aud` 是 (StringEquals mandatory), `oidc:sub` 否 (any String operator, "最多设置 10 个 OIDC 主体作为条件值") — every cell of the entry's Alibaba rows grounded; 更新时间 label renders with an empty value in static HTML |
| S064 → S067 OpenID Connect Core 1.0 | ADMIT, tier A spec, 730d — **anchor locator defect F-C** | https://openid.net/specs/openid-connect-core-1_0.html ; 2026-11-03; sha16 `4d016752a645e8a3` **reproduces the campaign pin exactly**; §3.1.3.6 located; aud entry located verbatim ("REQUIRED. Audience(s) that this ID Token is intended for. It MUST contain the OAuth 2.0 client_id of the Relying Party as an audience value.") — but at **lines 1056–1063** of the pinned bytes, not the staged anchor's "lines 923-933" (923–933 is the §1 terminology section; the pin reproduces, so the locator was wrong at staging, not drifted) |
| S065 → S068 RFC 9700 | ADMIT, tier A spec, 730d | https://www.rfc-editor.org/rfc/rfc9700.txt ; 2026-11-03; sha16 `9919d061d40a9788` **reproduces the campaign pin exactly**; §4.10.2 "Audience-Restricted Access Tokens" exists (line 1661); quote located verbatim: "If the access token fails the intended audience validation, the resource server refuses to serve the respective request." (the entry's quoted span is a contiguous substring) |
| S092 → S069 1password.dev brokered-access | ADMIT, tier A docs, 180d | https://www.1password.dev/brokered-access ; 2026-11-03; sha16 `6179e9c140851529` (campaign `11c2476e3733ceff` drifts); Custom Workflow (OIDC) tab has 5 top-level steps matching the staged anchor; "All configured claims must match to verify the workload’s identity" located ×2 (curly apostrophe — see F-J); "Make note of the expected audience value. …" located ×2; "The token value is your integration key, which is required to decrypt secrets in your team’s workflows" located; JWKS manual-entry step located; GitHub Actions tab present (the entry's "documents separately" holds); **`OP_INTEGRATION_KEY` appears only in the GitHub tab, not the Custom Workflow (OIDC) tab** (F-H) |
| S093 → S070 1password.dev custom-workflow | ADMIT, tier A docs, 180d — **anchor form defect F-P** | https://www.1password.dev/brokered-access/custom-workflow ; 2026-11-03; sha16 `a34902cc251b9d9c` (campaign `bd85d7332dda43d0` drifts); page title "…custom workflows at runtime **(public beta)**" located — the feature-level status the staged entry never states (F-G); runtime triple quote located ×1; "(Optional) Define any additional access conditions…" ×2; "any inherited conditions your administrator configured for the integration" ×2; the page's Step 2 heading is "Step 2. Connect your Environment to your workflow" (period) — the staged row anchor's colon form "Step 2: Connect…" locates 0 times; Step 3 colon form locates ×4; SDK code sample carries `OP_WORKLOAD_ID` and `OP_INTEGRATION_KEY` |
| S095 → S071 1password.com/jp credential-broker | ADMIT, tier A docs (ja terminology scope, self-bounded flip-to-C), 180d | https://1password.com/jp/product/credential-broker ; 2026-11-03; sha16 `5225ad39e4dabd0f` (campaign `654571f5f88fc6bc` drifts); staged lead-paragraph anchor located ×1; WIF FAQ located ×3 ("Credential Brokerは、認証情報を配信する前に、Workload Identity Federationを使用してワークロードのIDを検証します"); **the page carries no release status at all**: パブリックプレビュー 0, public preview 0, ベータ 0 — so the entry's "the product page describes Credential Broker as in public preview" has no cited carrier (F-G); page is UA-sensitive: without the profile UA the body hashes `036f6b9a2b93d51a` vs `5225ad39e4dabd0f` — raw pins on this page are fragile, the capture row should note the profile dependence |

**Per-entry verdicts:** both entries are **ADMIT-AFTER-FLIP** (no outright
REFUSE; every defect is flip-repairable with the in-round evidence above, which
is exactly the ≥1-admit / ≥1-reject-or-flip shape the per-entry gate needs).

- `oidc-federation-trust-policy.md` — **ADMIT-AFTER-FLIP**: F-A (STS row
  re-derivation; load-bearing), F-B (per-vendor no-stamp bound), F-C (S067 line
  locator), F-D ("four claims" mislabel), F-E (falsifier sentence), F-F
  (optional gloss tightening).
- `cdp-bridge-1password-oidc-workflow.md` — **ADMIT-AFTER-FLIP**: F-G
  (per-feature release status; load-bearing), F-K (ground re-grounding), F-L
  (entry attribution), F-H (OP_INTEGRATION_KEY citation), F-I (quote length),
  F-J (apostrophe form for capture quotes), F-M (bound the cross-page
  negative), F-N (falsifier sentence), F-O/F-P (minor).

## F-A — the AWS STS row asserts what its own re-opened source contradicts (M30-8 class, load-bearing)

The staged entry's four-dialects table row: "AWS STS | request parameter
`Audience` on `AssumeRoleWithWebIdentity` — 'The intended audience (also known
as client ID) of the web identity token' [S063] | caller asserts it; STS
re-checks it | caller asserts `ProviderId`". Measured on the 2026-11-03 page:

1. The request-parameter section documents exactly: DurationSeconds,
   MinimumSessionTokenSize, ProviderId, RoleArn, RoleSessionName,
   WebIdentityToken. **No `Audience` request parameter.** `Audience` occurs
   exactly twice in the whole page body — the response-element description and
   the `<Audience>` XML example in the sample response.
2. The staged quote is real text but it is the **response** element's
   description; the staged anchor "§Request Parameters, entry `Audience`" names
   a section entry that is not there.
3. The subject cell "caller asserts `ProviderId`" is contradicted twice over:
   the page says "Do not specify this value for an OpenID Connect identity
   provider", and ProviderId identifies the provider, not the workload — the
   subject arrives inside the presented ID token.
4. The staged S063 teaches ("audience binding is asserted by the requester and
   then re-checked by STS against the token") and the entry's "caller asserts
   it; STS re-checks it" are therefore unsupported; they also contradict the
   entry's own AWS IAM row, which correctly puts the audience check in the
   trust-policy condition (S061/S062).

Whether this was a staging-time mislabel or 11-day page drift is not
decidable from the lane (the campaign pin does not reproduce; no archive fetch
is in scope). Either way the in-round re-open is the evidence the admission
rests on, and it does not carry the claim — the exact M30-8 class ("landed
entries asserted what their own cited source contradicts"). **Flip:** re-derive
the STS row from the current page — scope becomes the response-side echo
(Audience element returns the token's audience) plus the explicit
no-ProviderId-for-OIDC rule, with audience enforcement attributed to the role
trust policy's `provider:aud` condition (S061/S062); subject cell becomes "the
subject arrives inside the presented ID token; the caller specifies no
ProviderId for an OIDC IdP". The entry's table row and the "Audience binding is
checked twice, at issuance and at use" synthesis must be re-worded so the
"requester asserts" half is withdrawn (the requester asserts nothing about
audience in the STS call; the token carries it and the trust policy checks it).

## F-G — the 1password entry's release-status bullet is the round-22-rejected reading (QA10, load-bearing)

Staged bullet: "It does not establish general availability: the product page
describes Credential Broker as in public preview, and this entry records the
setup mechanics only." Measured:

- The entry's own product-page row (S095→S071, jp) carries **no status
  anywhere** (パブリックプレビュー 0, public preview 0, ベータ 0) — the
  sentence has no cited carrier among the entry's three rows.
- The dev docs pages carry the **guide-level** "(public preview)" label
  (brokered-access: 21 hits) while the custom-workflow page's own title says
  "**(public beta)**" (14 hits) — the per-feature split the lane already
  adopted: S018 (custom workflows = public beta, opened round 22), S017
  (Actions = public preview), S020 (announcement distinguishes them), and S019
  whose teaches literally say "the guide-level preview label does not determine
  custom-workflow status".
- The lane litigated this exact reading twice: round-21 spot-check E1
  ("conflates GitHub Actions public preview with custom-OIDC beta") and
  round-22 spot-check ("Credential Broker status is uniformly preview" →
  reject, outside-agreed). QA10's weak-signal column names it verbatim:
  "calling both Broker workflows public preview".

**Flip:** state the per-feature status in the sentence that uses it — the
custom-OIDC workflow is public beta per the runtime page title (re-verified
2026-11-03) — cite the lane's status rows (S017/S018/S020, which the entry
currently never cites) or the located page-title quote, and drop the
product-level blanket label.

## Other named flips

- **F-B (oidc entry, bounds section):** "AWS, GCP and Alibaba all ship changes
  without a version stamp on the page" is refuted for GCP: the best-practices
  page carries "Last updated 2026-10-29 UTC" and the ja page "最終更新日
  2026-03-04 UTC" (both located on the 2026-11-03 fetches). AWS pages carry no
  stamp (0 hits, verified); Alibaba renders an empty 更新时间 value in static
  HTML. Flip: restrict the no-stamp claim to AWS and state the GCP/Alibaba
  stamp facts per page.
- **F-C (S067 anchor):** "claim list entry `aud` (REQUIRED) at page lines
  923-933" — the aud entry is at lines 1056–1063 of the pinned bytes (the pin
  reproduces, so this was wrong at staging). Flip: correct the locator (or use
  the stable §3.1.3.6 anchor alone).
- **F-D (oidc entry, §The rule):** "Four claims do that work" lists `iss`,
  `aud`, `sub` and "the resulting permission", which the entry itself says "is
  the output of the trust policy, not one of its inputs" — three claims and one
  output. Flip: re-word ("three claims and the permission they produce").
- **F-E / F-N (both entries, QA4):** neither entry names a falsifier. The
  lane's own admitted entries carry explicit falsifier paragraphs
  (`onepassword-machine-credentials.md`: "This entry is falsified if …").
  Flip: add one falsifier sentence each (oidc entry: a provider page dropping
  the aud/registration binding, or a trust policy accepting a mismatched-aud
  token; 1password entry: the broker verifying a workflow whose configured
  claims do not all match, or the pages dropping the conjunctive-match or
  triple statements).
- **F-H (1password entry, QA9):** "the integration key … stored by the team as
  `OP_INTEGRATION_KEY` [S069]" — the Custom Workflow (OIDC) tab says only
  "configure the key as a secret that can be retrieved at runtime. For
  example, … a CI/CD variable in a GitLab group"; `OP_INTEGRATION_KEY` appears
  in the **GitHub Actions** tab (a path the entry explicitly does not cover)
  and in the runtime page's SDK sample (`process.env.OP_INTEGRATION_KEY`,
  S093→S070). Flip: cite S070 for the env-var name, or qualify the path.
- **F-I (1password entry, capture-quote bar):** the S069 claims quote is a
  44-word three-sentence block ("Define the identity requirements … environment,
  etc.") — over the ≤25-word capture-quote bar. Flip: capture the locating
  fragment ("All configured claims must match to verify the workload’s
  identity", 10 words) and keep the rest as paraphrase.
- **F-J (1password entry, quote form):** the staged quotes use straight
  apostrophes ("workload's", "provider's"); the page uses ’ (U+2019). Under
  `rendered-text-v1 locate` the straight forms count 0; the curly forms count
  2. Flip: record capture quotes in the locating (curly) form — the oidc
  entry's quotes are unaffected (no apostrophes).
- **F-K (1password entry, ground line, QM11):** "ground: Round-2 ledger item 4
  — '1Password Credential Broker custom-OIDC workflow sub-page'" — the lane has
  no round-2 lesson (`corpus/lessons/` starts round-1, round-3, …), no R2-x
  claim-ledger rows (earliest R11-01), and no SCORECARD round-2 section; the
  string exists nowhere in the lane. "Round-2" is the merge package's internal
  round numbering (MERGE-REPORT.md "rows by round"), a foreign artifact. The
  lane's actual records: the SOURCES.md §Leads bullet (created by the round-21
  critic report) and the round-22 opening as S018. Flip: re-ground the line to
  those lane records (or cite the foreign ledger explicitly as such).
- **F-L (1password entry, QM11):** "Those entries already record that a
  workflow's identity is checked against policy before credentials are
  delivered" — true for `onepassword-machine-credentials.md` (§item 4: "a
  workload's configured trust policy determines which credentials it may
  retrieve during the authorized job"), **false** for `cdp-bridge-1password.md`
  (a Chrome native-messaging-host bridge entry; zero identity/policy/delivery
  content — grep for identity|policy|deliver returns nothing). Flip: attribute
  the claim to `onepassword-machine-credentials.md` only.
- **F-M (1password entry):** "a third factor that the cloud-provider dialects
  do not have" is an unsourced cross-page negative. I verified it: 0
  workload-ID-credential hits across all six provider pages (p4–p9). Flip: bind
  it ("none of the six cited provider pages names a separate workload-ID
  credential") so the negative carries its sweep.
- **F-O (minor):** "a single misconfigured claim makes every workflow fail
  closed" — scope to "every workflow requesting under that integration".
- **F-P (minor, S070 anchor):** the page's Step 2 heading is "Step 2. Connect
  your Environment to your workflow" (period); the staged row anchor's colon
  form locates 0 times. Flip: record the period form (or bare §"Step 2").
- **F-F (optional):** S061's teaches gloss "refused before any permission is
  evaluated" is the entry's inference, not page text (the page says only that
  the aud claim must match the Audience value); keep it marked as consequence
  or drop it.

## Negative-bound audit summary (M30-8 class — every absence sentence checked)

| # | absence sentence (entry) | verdict | evidence |
|---|---|---|---|
| 1 | issuer URL "https://, no query parameters, normally no port" (oidc, S061) | HOLDS | "The URL must begin with https://. Per the OIDC standard, path components are allowed but query parameters are not." + "The URL should not contain a port number." (p4) |
| 2 | "no version stamp on page" (S061 anchor, AWS) | HOLDS for AWS | 0 "Last updated"/stamp hits on p4/p5/p6 |
| 3 | "AWS, GCP and Alibaba all ship changes without a version stamp" (oidc bounds) | **REFUTED for GCP** | "Last updated 2026-10-29 UTC" (p7), "最終更新日 2026-03-04 UTC" (p8) → F-B |
| 4 | "GitHub-OIDC rows do not cover [the cloud-provider side]" (oidc ground) | HOLDS | S047/S050 scopes say "GitHub only"/"GitHub.com only"; QA7 sweep clean |
| 5 | "the lane already holds that ground (rows S047/S050)" (oidc bounds) | HOLDS | both rows exist, GitHub OIDC claim model |
| 6 | "does not cover the Vault-side audience check (S012/S022)" (oidc bounds) | HOLDS | both rows exist (S022 supersedes S012) |
| 7 | "cannot be used to scope permissions afterwards" (oidc, S062) | HOLDS | "When a claim is not available in session, the OIDC condition context key can only be used in a role trust policy for the initial AssumeRoleWithWebIdentity authentication." located verbatim (p5) |
| 8 | "AWS's condition-key set treats all three as ordinary claim keys" (oidc, S062) | HOLDS | iss/aud/sub listed as provider:claim keys (e.g. accounts.google.com:aud) |
| 9 | JWKS "entered manually if not detected automatically" (1password, S069) | HOLDS | "If your JWKS endpoint isn’t detected automatically, enter the URL manually, then select Continue." (p1) |
| 10 | "the product page describes Credential Broker as in public preview" (1password bounds) | **REFUTED as stated** | jp product page: no status (0/0/0 hits); guide-level label vs feature-level "(public beta)" → F-G |
| 11 | "does not cover the GitHub Actions integration path, which the same administrator page documents separately" (1password bounds) | HOLDS | GitHub Actions tab present (9 hits, panel-github-actions-0) |
| 12 | "nor the service-account path" (1password bounds) | HOLDS | page hero "without managing service account tokens" |
| 13 | "a third factor that the cloud-provider dialects do not have" (1password) | HOLDS, unbound | 0 workload-ID-credential hits on p4–p9 → F-M binding |
| 14 | "Those entries already record that a workflow's identity is checked against policy…" (1password) | **HALF-REFUTED** | true for onepassword-machine-credentials.md; false for cdp-bridge-1password.md → F-L |
| 15 | "makes every workflow fail closed" (1password) | over-scoped | conjunctive rule grounded; scope to the integration → F-O |

## Census shape (measured on scratch fixtures; lane tree untouched)

- **Staged as-is → 40 findings, exit 1** (`census-staged-as-is.txt`): SC_DUP ×6
  (S052–S057 collide with lane rows), SC_USEDBY_NOCITE ×9 (multi `source:`
  lines — only the first line's ids are seen), SC_FETCH ×17 (S052–S057
  url/row-identity mismatches from the id collision; S064/S065/S092/S093/S095
  missing-provenance), SC_ENTRY_CITE ×6 (the collision breaks six EXISTING
  rows' used-by contracts: feed-token-boundaries S052,
  secret-scanning-detection-vs-validation S053/S054,
  betterleaks-detection-vs-validation S055/S056,
  trufflehog-verification-lifecycle S057), SC_ENTRY_HEADER ×2. This is the
  M30-7 class again: the staged package cannot land as shipped.
- **Adopted shape → CLEAN, exit 0** (`census-adopted-shape.txt`):
  `SOURCES_CENSUS: CLEAN (rows=71 A=68 B=1 C=2 queued=1 mined=67 rejected=3
  entries_sourced=10 legacy=21 captures=71 inrow=16 inrow_only=0
  inrow_nonreproducing=12)` — exactly the plan's predicate shape (rows=71,
  entries_sourced=10, legacy=21, captures=71; S061–S071 = 11 rows).
- **Traps the L1 must not hit (each one bit the dry run):**
  1. Renumber in ONE pass: the new ids S064/S065 overlap the staged ids
     S064/S065 — sequential string replacement double-renames and silently
     drops citations (first dry-run attempt produced SC_USEDBY_NOCITE for
     S064/S065). Use a single-pass `re.sub(r'S\d{3}', map)`.
  2. The capture row-identity digest is sha256 of `id\tstatus\tURL\n` **with
     the trailing newline** (the census printf adds `\n`).
  3. The capture location column must be ≥8 chars (`SC_FETCH id=… location`);
     "4.10.2" and "Step 3" are too short.
  4. The merged `source:` line must carry ALL cited ids (8 for the oidc entry,
     3 for the 1password entry) — use the round-30 entry's one-line semicolon
     form; `verified-at: 2026-11-03 — … campaign dates 2026-10-23 are not
     evidence here` per the round-30 pattern.
  5. All 11 staged rows are NF=13 with no pipes in cells (checked) — clean.
- **used-by completeness** holds in the adopted shape (census-enforced).

## Fetch-pin drift (round-30 sentinel pattern: recorded, not hidden)

9 of 11 staged pins do not reproduce on 2026-11-03 with the declared profile;
the two static specs reproduce exactly (`fetch-digests.tsv` has all rows). The
only **claim-level** drift is the STS page (F-A — its request-parameter section
changed/never matched); the other seven drifted pages still locate every quote
the entries rely on (`needles.txt`), i.e. chrome/build-level drift. Both
declared recheck needles reproduce: 1password "All configured claims must match
to verify" → 1; AWS "The aud claim must match the Audience value" → 1. Per the
round-30 pattern the campaign pins stay in the anchor cells and the in-round
captures (2026-11-03) are the evidence the census checks.

## QA walk (per entry, both entries unless noted)

- **QA1** ✓ tier A per scope with anchors — three anchor defects to fix in-round
  (F-A S063, F-C S067, F-P S070).
- **QA2** ✓ oidc entry (no status-dependent claims). ✗ 1password entry's status
  bullet (F-G).
- **QA3** ✓ bounds sections present and mostly accurate; F-B and F-M tighten two
  bounds; F-O scopes one consequence.
- **QA4** ✗ neither entry names a falsifier (both carry `recheck:` lines whose
  needles reproduce) → F-E/F-N.
- **QA5** ✓ credential scan clean on both staged entries (lane CRED_RE: 0 hits;
  `OP_INTEGRATION_KEY`/`OP_WORKLOAD_ID` are variable names, not secret
  material).
- **QA6** ✓ counts carry commands; "at most 10 values" is carried by the S066
  table anchor; both recheck lines carry commands that reproduce today.
- **QA7** ✓ no sibling ground: 0 OIDC/workload-identity/federation mentions
  across all 21 sibling `PROVINCE.md` files; the only sibling-corpus hits are
  mori-shokunin evidence captures of the OWASP Logging Cheat Sheet (fleet
  observability lane, incidental nav text — not ground). Consistent with the
  plan's round-21/30 sweeps.
- **QA8** ✓ PASS (negative result, honestly reported): neither entry collapses
  token lifetime, lease, or federation trust into one claim; the integration
  key is described without lifetime claims; the oidc entry makes no lifetime
  claims at all.
- **QA9** ✗ F-H (OP_INTEGRATION_KEY path qualifier) and F-G (product-level label
  where the lane's adopted ground splits per feature). The S065/S071 ja rows'
  self-bounded "flip to C if the ja path lags" notes are good and travel.
- **QA10** ✗ F-G: the status bullet rests on no cited page (the cited jp product
  page carries no status), and the guide-level label is the exact reading
  round-22 rejected with outside agreement.

## Plan-text observations (not entry defects; for the lesson, plan is frozen)

- The plan's collision parenthetical overstates: only staged **S052–S057**
  collide with lane registry ids (lane = S001–S060; fixture-proven SC_DUP ×6;
  no SC_DUP for S064/S065/S092/S093/S095). The renumber map is per document
  either way and the predicate (S061–S071 = 11) is unaffected.
- The renumber overlap hazard (new S064/S065 vs staged S064/S065) is real and
  belongs in the lesson's migration record (trap 1 above).
- The staged 1password filename (`cdp-bridge-1password-oidc-workflow.md`)
  collides by prefix with the unrelated CDP-bridge entry; the plan freezes the
  path, so record the naming hazard in the lesson rather than renaming.

## Tooling record

No installs (none needed): python3 3.14.8 (`/usr/bin/python3`), curl,
sha256sum, plus the lane's own read-only instruments (`corpus/rendered-text-v1.py`,
`corpus/sources-census.sh verify --root` run against scratch fixture copies
only). No pacman transactions; no lane git/jj mutation; no `op` contact beyond
nothing (not even `--version` was needed).

## Scratch

`/fast/scratch/hyaku/kagi-r31/AttackOidc/` — deleted before yield; receipts
copied first to `.ufo/waves/round-31/AttackOidc/` (`fetch-digests.tsv`,
`needles.txt`, `census-staged-as-is.txt`, `census-adopted-shape.txt`,
`bodies/p1–p11.body`).
