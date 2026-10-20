# ReopenSource12 — S012 and Broker feature-row falsification

## Axes and verdict

- **Calibration (C1):** one defect survives. The S012 row and the active E3
  bullet state the `bound_audiences` exact-match rule without Vault's
  role-type qualifier; the reopened page applies it to `"jwt"` roles, while
  OIDC roles keep `bound_audiences` optional. The executable C1 set has no
  holdout for that boundary.
- **Freshness (C2):** no revision-accounting kill. The S012 row is
  byte-identical to the frozen base; its version locator is still consistent
  with the served switcher (`latest` = v2.x, newest non-latest = v1.21.x);
  the registered Fetch hash is not reproducible but the tree already refuses
  to call that drift. The stamps ledger is clean and the nine alleged
  deletions are zero member removals with exact old/new rows preserved.
- **S017–S020:** all four feature-specific teachings and anchors verified;
  S006/S007 rows are byte-identical to base. No false admission observed in
  the executed 10-before / 4-after / 3-boundary decision set.
- **Not a whole-tree KILL.** This seat confirms one required append-only
  qualifier correction and one C1 coverage gap. No W1 scribe credit is
  claimed; the four dead W1 seats remain uncredited.

## Read revision and observed hashes

The historical BEFORE base `c2cab35bc92e57e39e5489bac3386db078345b3f` is not
this attack input. The input is the tree frozen by
`.ufo/waves/round-22/integration-manifest.json`, observed at measured landing
`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`.

| Frozen input | Observed SHA-256 | Matches manifest |
|---|---|---|
| `.ufo/waves/round-22/integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` | — (the manifest itself) |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | yes (86 lines, 19,721 B) |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` | yes |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | yes |
| `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | `f633d004100b5d440685770f6be6635f460c28673a2e353b554a64afd42c8610` | yes |
| `corpus/knowledge/onepassword-machine-credentials.md` | `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` | yes |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` | yes |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | yes |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | yes |

Production inputs were not modified. This report is the only file written.
**Installs: none.**

## S012 — source record, anchor, teaching

URL: https://developer.hashicorp.com/vault/docs/auth/jwt, opened 2026-10-20.

| field | observation |
|---|---|
| HTTP | 200; version switcher aria-label “Currently viewing **v2.x (latest)**”; newest non-latest entry `v1.21.x` (switcher JSON `isLatest:false`) |
| page revision | JSON-LD `datePublished` = `dateModified` = `2026-04-15T00:14:24.000Z` |
| decompressed HTML sha256 | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` — independently reproduces the hash recorded in `.ufo/waves/round-22/build/Source12.md` |
| registered row hash | `ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45` — not reproduced; representation unknown; no content-change evidence because `dateModified` is unchanged and the tree already refuses to call it drift |
| anchors | §JWT verification (h3), §Configuration → §Bound claims (h3), §Claims as metadata (h3), §OIDC configuration troubleshooting — all present |

Located quotes (each ≤25 words, same URL/date):

| heading | quote | check |
|---|---|---|
| Page-introduction Note | “the associated `bound_audiences` for the "jwt" role must exactly match at least one of the `aud` claims declared for the JWT” | 21 words; verbatim rule |
| §Bound claims | “For roles of type "jwt":” … “the `bound_audiences` parameter is required when an `aud` claim is set” | role type named explicitly |
| §OIDC configuration troubleshooting | “`bound_audiences` is optional for OIDC roles and typically not required” | 11 words; the omitted qualifier |
| §Claims as metadata | “it must existing in the JWT or else the authentication will fail” | sic, verbatim |

Version gate independently checked: the v1.17.x page carries the introduction
Note and the §Bound claims list; the v1.16.x page carries neither
`Starting in Vault 1.17` nor `must exactly match at least one`. The row's
“audience note applies starting Vault 1.17” is therefore supported, not
merely restated. Anchor precision: the version gate exists **only** in the
page-introduction Note; §JWT verification restates the same rule without the
gate, and §Bound claims states it under “For roles of type "jwt"”.

**Immutable original row:** the S012 line SHA-256 is
`6bfac7df41faffb9c8e5150373685227e96e5235c03a656762550116f0057d2a` at both
`c2cab35` and HEAD. The whole-file diff base→HEAD is **43 insertions / 0
deletions**, so every S001–S016 row is byte-identical; the registry grows
16→21 rows. For S012, `status=mined`, `opened=2026-10-19`,
`recheck=on-release`, and
`used-by=corpus/knowledge/vault-openbao-token-lease-lifecycle.md` are unchanged.

## S012 — surviving calibration defect (role type)

The page separates the two paths. The exact-match requirement is stated
**only for roles of type `"jwt"`**; OIDC roles keep `bound_audiences`
optional. Two integrated statements omit that qualifier:

1. S012 `teaches`: “Vault requires an exact role audience match when a
   presented JWT has an audience claim” — scope field says “Vault JWT/OIDC”.
   The sentence is supported for `jwt` roles only.
2. E3 active body, line 28–29: “a JWT carrying `aud` needs a role
   `bound_audiences` that exactly matches one of its values” — no role-type
   qualifier, and the entry has no OIDC-optional counter-statement.
   `grep -n bound_audiences` over E3 returns only this line.

The build seat `.ufo/waves/round-22/build/Source12.md` found the same split
and proposed a superseding row under the then-free ID `S021`; the integrated
registry assigns `S021` to the OpenBao token row, no `S022` exists, and the
qualifier appears nowhere in integrated production prose. The correction was
therefore not landed, only left in advisory build evidence.

**Proposed correction (append-only):** add an E3 errata bullet: “The Vault
`bound_audiences` requirement is role-type-specific: from Vault 1.17, roles
of type `jwt` require it when the JWT carries `aud`, matching at least one
value; OIDC roles keep it optional (§OIDC configuration troubleshooting).”
Optionally add a superseding S022 registry row carrying the same qualifier.
S022 would change the census expectation from 21 to 22 rows; the immutable
S012 row and its fetch hash stay untouched. Add a C1 holdout: admit the
jwt-role control, reject “OIDC roles require `bound_audiences`” as a
false-claim; if executed, the after/before counts become 5/11 and the
manifest expectation must migrate with exact old/new evidence.

## S012 — round-22 lesson usage / freshness

The only round-22 use is the SOURCES.md “Inherited source-locator caveats”
paragraph and the matching lesson bullet, which say S012/S013's old
version/date descriptions “are not current release pins” and point to
`build/Source12.md`/`Source13.md`.

- For S012 that caveat is conservative but **not evidence of a wrong
  version claim**: today's switcher is `v2.x (latest)` plus `v1.21.x` as the
  newest non-latest version, exactly “latest page … newest pinned version
  v1.21.x”. The row's date phrase is a served date, not a displayed page date.
- The build seat's stronger charge that S012's stamp is “stale” because the
  served latest page is v2.x conflates `latest` with `newest pinned`; I do not
  reproduce it. No restamping or row correction is justified for S012.
- Adjacent, same caveat sentence: S013's row says “current Vault docs have no
  displayed version/date”. The served §Lease page does display
  “Currently viewing v2.x (latest)” and the same versions JSON. That specific
  version-half error is not named in the integrated tree. This seat did not
  re-audit the rest of S013.

## S017–S020 — feature-specific verification

All four pages were reopened independently on 2026-10-20; S017–S019 served
their Markdown alternates (no displayed version/date); S020 is an HTML post
with `article:published_time` `2026-07-28`.

| row | claim checked | page evidence | verdict |
|---|---|---|---|
| S017 | GitHub Actions public preview; admin connects org to Business | title “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)”; intro “If an administrator has connected your GitHub organization to your 1Password Business account” | supported |
| S018 | custom OIDC public beta; Business + OIDC provider; beta desktop app; JavaScript SDK only | title “(public beta)”; intro “connected an OIDC provider to your 1Password Business account”; Step 1 “latest beta release of the 1Password desktop app”; Step 3 note “only supported in the 1Password JavaScript SDK at this time” | supported |
| S019 | Business setup; GitHub.com only; GHES/GHEC data residency unsupported; Free org private-repo limit | intro “administrators can set up a supported integration in their 1Password Business account”; “Your GitHub organization must be hosted on GitHub.com.”; “GitHub Enterprise Server or … Enterprise Cloud with data residency aren't currently supported”; Free-org private-repository sentence | supported |
| S020 | EPM Business eligibility; dated announcement separates Actions preview from custom-OIDC beta | “available for all Enterprise Password Manager Business customers”; “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” (19 words); byline July 28, 2026 | supported |

Status and eligibility were checked separately at each feature page's own
title/introduction; the parent guide's “(public preview)” title was not used
to classify custom workflows. This matches the tree's stated rule.

**Immutable original rows:** S006 line SHA-256
`1b20aaca0bba9407501c7c9dfed9e616d2f61a8e45265c84e3d1a49581295ba5`,
S007 `f9905ea9fefcd60a3a4e212ca6634a9de9b5e9b02781dc0e4c8e420fe4c3f963`,
identical at base and HEAD.
S019/S020 are appended supersessions, not rewrites. The S007 mechanisms the
supersession claims to preserve are still present on the same page:
integration key (`the token value is your integration key`), all configured
claims must match, and workflow-duration access.

## C1 executed decisions (reproduced)

| command | observed |
|---|---|
| `python3 corpus/feature-claims.py --selftest` | `FEATURE_CLAIMS_SELFTEST: PASS cases=10`, exit 0 |
| `--phase before` | 10 decisions: 2 `reject:false-claim` (E1 status conflation, same-page preview swap) + 8 `reject:bar-fail`; exit 1 |
| `--phase after` | 4 `admit` bounded controls; `false_admissions=0`, `misses=0`; exit 0 |
| `--phase boundary` | 3 `cannot-evaluate`, `scored=no`; exit 2 |

No fabricated outside agreement: the after records are labelled
`verbatim-pin`, and the tool is a closed-record reviewer. The new holdout in
the S012 section is not covered by these decisions.

## C2 revision accounting (reproduced)

| check | observed |
|---|---|
| `python3 corpus/revision-audit.py --history 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` | `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=0 invalid=0)`, exit 0 |
| `python3 corpus/revision-audit.py --selftest` | `REVISION_AUDIT_SELFTEST: PASS (cases=11 failed=0)` |
| `corpus/SOURCES.md` stamp | hash/86/19721 match the live file |
| historical membership `aea7a4301` → `e1544c194…` | first-column sets: 56 → 63; **0 removed**, 7 added; 9 changed records preserved with exact old/new rows in `round21-migrations.json` |
| spot check | LOG.md old/new in that artifact exactly match `git show aea7a4301:corpus/stamps.tsv` and `git show e1544c194…:corpus/stamps.tsv`; current LOG.md is a later, separately stamped append |

The outside reviewer's “nine deleted lines” is not nine lost members. The
keep/restamp evidence is exact and append-preserving.

## Required answer

- **One concrete supported claim:** from Vault 1.17, a role of type `jwt`
  whose presented JWT carries `aud` requires `bound_audiences` matching at
  least one `aud` value; the rule is carried verbatim in the introduction
  Note and §JWT verification, and §Bound claims states it under “For roles of
  type "jwt"”. It is absent from the v1.16.x page.
- **One scope limit:** that requirement is not an OIDC-role rule;
  `bound_audiences` is “optional for OIDC roles and typically not required”.
  Neither the S012 `teaches` field nor the active E3 bullet carries this
  boundary, and the C1 fixture has no role-type holdout.

## Limits / remaining unknowns

- Vendor documentation only; no account, workflow, SDK, vault, or credential
  was contacted. Eligibility is documentary, not tested.
- The registered S012 Fetch hash cannot be reproduced; the 2026-10-19 bytes
  were not retained, so a representation/method difference cannot be fully
  excluded. The unchanged JSON-LD `dateModified` is not proof of no edit.
- The v1.16.x absence was observed through the rendered page, not a byte
  archive; a future redirect/change would reopen the gate question.
- S013 was spot-checked only for the version-selector half of the joint
  caveat; the rest of S013 was not re-audited here.
- Build evidence (`Source12.md`, `Source13.md`) is advisory and was used only
  to locate the candidate defect; every cited page fact above was re-observed
  independently.
- No install or host-state change was made.

## Checks the parent should run after integration

1. `git show c2cab35…:corpus/SOURCES.md | awk '/^\| S012 /' | sha256sum` and
   the same on the landed tree — both must remain `6bfac7df…`.
2. `python3 corpus/feature-claims.py --selftest` and the three phases; if the
   proposed role-type holdout is added, re-pin the expected before/after
   counts with exact old/new evidence.
3. `python3 corpus/revision-audit.py --history 8ada17a…` — expect CLEAN.
4. `python3 corpus/revision-audit.py --selftest` — expect 11 cases.
5. `bash corpus/sources-census.sh` — the live registry now has 23 rows over
   18 distinct URLs (S022/S023 appended); update the census expectation
   explicitly, never by laundering the count.

## Final-row check — late S022/S023 append (read 2026-10-20)

Delta from the frozen 21-row input: live `corpus/SOURCES.md` is
`9e0b155772ffcf2c22d60daccea43450ad6f4755a5c3266a7fea265fbdc36c6e`
(23 rows, 18 distinct URLs); new `corpus/lessons/round-22-source-errata.md`
is `20e9bb06096d1e5819feab755df9bee1b7244efcf21834e212d8fa0ef26097c2`.
`git show HEAD:corpus/SOURCES.md` is still
`3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7`, and
the SOURCES modification plus the lesson are uncommitted. The
integration-manifest hash therefore describes the 21-row input, not these
live bytes; this check names the live delta instead of inferring it from a
commit.

Base→live and HEAD→live diffs contain **0 deleted lines**. S006, S007 and
S012 line hashes are unchanged; S017–S020 line hashes match HEAD exactly.
No production edit was made by this seat; only this report was appended.

### S022 — AGREE

Both located quotes are verbatim on the page already opened for S012 and
re-checked here:

- Introduction Vault 1.17 note, 21 words: “the associated `bound_audiences`
  for the "jwt" role must exactly match at least one of the `aud` claims
  declared for the JWT.”
- OIDC configuration troubleshooting, 11 words: “`bound_audiences` is
  optional for OIDC roles and typically not required.”

The scope (“JWT roles from 1.17: audience match when aud is present;
separate OIDC-role optional setting”) and the teaching (“supersedes S012 —
… not a mandatory bound_audiences setting for OIDC roles”) are supported.
The lesson's disposition is the precise one: admit only for JWT roles when
the presented JWT carries `aud`; reject an OIDC-wide mandatory inference.

One wording note, not a disagreement: “exact bound-audience matching is the
JWT-role path” is safe only with its following “not a mandatory … for OIDC
roles” clause; “the mandatory exact-match requirement is the JWT-role path”
would avoid implying that an optionally configured OIDC `bound_audiences`
uses different matching semantics. The page does not state the latter
either way.

### S023 — AGREE

- KV note quote, 20 words, verbatim: “The Key Value Backend which stores
  arbitrary secrets does not issue leases although it will sometimes return
  a lease duration” (link markup removed; the page continues “; see the
  documentation for more information”).
- H1 “Lease, renew, and revoke” and the observed Edit-this-page route
  `content/vault/v2.x/content/docs/concepts/lease.mdx` are present.
- Locator-only supersession is the correct disposition: it preserves the
  valid Vault lease/KV mechanism, withdraws S013's categorical
  no-displayed-version wording, and does not turn a v2.x source route into
  deployment proof or a KV retention guarantee. This agrees with the
  adjacent finding already recorded above.

### Lesson — AGREE, with one C1 consequence

The lesson's two located quotes, the “S012's most-recent non-latest pinned
v1.21.x label is not contradicted merely by a v2.x latest route” statement,
and “S013's categorical no-displayed-version locator is withdrawn” all agree
with what this seat observed independently.

The statement “JWT login remains outside C1's closed profile, not a new
countable fixture” is a defensible scope boundary only if stated with its
consequence: the executable decisions remain **10 before / 4 after / 3
boundary**, and my earlier proposed 11/5 migration is withdrawn as
inapplicable because no fixture case was added. The role-type correction is
prose evidence; the C1 executable gate still does not measure it. If a
measured role-type decision is required, add a separate fixture/control with
exact before/after pins; otherwise the errata must not be counted as a C1
decision.

**Bounded verdict:** AGREE with S022 and S023 as written, with the S022
wording caveat above; AGREE with the lesson's quotes and qualifiers; the
C1 count remains 10/4/3 and is not inflated by these rows. No new seat
identity and no production edit.
