# ReopenSource01 — S001 reopen and feature-bound S017–S020 attack

Seat: `KagiR22.ReopenSource01` (leaf, read-only). Axes: **calibration, freshness**.
Assigned item: reopen S001's exact URL; verify teaching/anchor against the immutable original row and
round-22 lesson usage; examine S017–S020 feature-specific status/eligibility separately; check original
rows for immutable-field mutation. No production writes, no account/vault/live host gates.

## Exact read revision and frozen inputs

| item | observed value |
|---|---|
| HEAD / landing under attack | `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` |
| Frozen manifest | `.ufo/waves/round-22/integration-manifest.json` |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` · 19,721 B · 86 L (matches manifest) |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` · 15,700 B · 192 L (matches manifest) |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` · 47,434 B · 995 L (matches manifest) |
| Frozen BEFORE `corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332`; equals `git show c2cab35:corpus/SOURCES.md` and `frozen/before/expected.json` |
| Working tree vs HEAD | `git hash-object corpus/SOURCES.md` = `76751ab535fbc00dc159a372303e877ff0ee255a` = `git rev-parse HEAD:corpus/SOURCES.md` (no uncommitted source change) |

Only public documentation GETs, read-only git/hash reads and local JSON reads were used. No package
manager, launcher, loopback/CDP probe, account or vault access. No installs.

## S001 — independent reopen (PASS, with a stated limit)

Opened `https://www.1password.dev/cli/secrets-scripts` 2026-10-20 (markdown alternate and raw HTML).

- Page H1: **Load secrets into scripts**. Located section heading, verbatim:
  **Use `op run` to pass environment variables from a 1Password Environment**.
- Exact quoted fragment in that section (7 words, present in both the vendor `.md` rendering and the
  raw HTML): **“provisioned for the duration of the process.”**
- The surrounding vendor sentence (paraphrased, not quoted) says the CLI runs the application or script
  in a subprocess with the Environment variables provided for that process's duration.

**Concrete supported claim.** Environment variables from a 1Password Environment, delivered by
`op run`, are provisioned into the child process for the duration of that process. The registry
teaching “Process-lifetime delivery” and its scope “1Password CLI process-lifetime Environment-variable
delivery” are directly supported at the named anchor.

**Scope limit.** The sentence bounds the *delivered subprocess environment*, not the lifetime, expiry,
deletion or non-readability of the underlying secret, Service Account token or 1Password item. It is
also specific to the 1Password Environment method (item 1 on the page), not a general statement about
the `op run` secret-reference method. The row does not claim token lifetime, and
`corpus/knowledge/onepassword-machine-credentials.md` (`:10`, `:24`) states the same bound explicitly,
including that neither page shows the Service Account token becoming short-lived. This is the correct
calibration; the round-21 rejected inference (“`op run` makes the machine credential short-lived”)
does not survive in the current tree.

**Immutable original row.** Frozen BEFORE and integrated rows are byte-identical:
`S001` line 7 in both, row sha256
`052aa61b03d95d4723c63abdb3f82b0e3e20af72cdd7f72b6950483d2cb06a80`. All sixteen original rows match
by line hash: S001 `052aa61b…`, S002 `41b63088…`, S003 `6ca8f899…`, S004 `405a8b03…`, S005 `1ba27291…`,
S006 `1b20aaca…`, S007 `f9905ea9…`, S008 `771e4306…`, S009 `b97d9d75…`, S010 `e3feaa5d…`,
S011 `565fcf51…`, S012 `6bfac7df…`, S013 `b9e83471…`, S014 `48a401de…`, S015 `9a75576e…`, S016 `066d4a7e…`.
`git diff c2cab35..HEAD -- corpus/SOURCES.md` is **43 insertions, 0 deletions**; no `+`/`-` line matches
an `S001`–`S016` row. The five new rows are S017–S021 at lines 23–27; the file has 21 source rows.

**Round-22 lesson usage.** `corpus/lessons/round-22.md:97` says original S001–S016 fields did not change;
that is verified byte-for-byte. S001 is not re-cited as a round-22 Gate source or restamped, and the
lesson's blanket statement (`:106-107`) treats old Fetch hashes as historical point observations, not
reproducible drift pins. No silent replacement of S001's digest was found.

**Freshness observation (limit, not a drift finding).** The stored S001 Fetch hash
`9f9d7283c2659d23c9ede72d96a31690533678b28437b2b22f73b2b73370c439` was not reproduced: today's raw
HTML is `24d1aecd2b5713e2decfae9151107421a261c4c998bfb0b74f8ada29856e7a84` (stable 2/2) and the
vendor `.md` alternate is `43b9a0c7…`. The page carries machine `dateModified` 2026-10-19T21:23:28Z and
no displayed date, consistent with the row's “no displayed version/date”. Cause (representation vs
same-day page revision) is not determinable from the stored evidence. I do not call this drift, and the
tree does not promote the old hash to current. The operative semantic evidence (heading and quote)
still reproduces exactly.

## S017–S020 — feature-specific status and eligibility opened separately

Each URL was opened independently on 2026-10-20. Status was read at the feature page's own H1/badge,
never from shared navigation. Quoted fragments are ≤25 words.

| row | live H1 (status anchor) | eligibility/constraint evidence | typed digest |
|---|---|---|---|
| S017 | **Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)**; badge “Public Preview” | Introduction: “If an administrator has connected your GitHub organization to your 1Password Business account” | `937f6828…` raw HTML, stable 2/2, matches stored `937f6828…` |
| S018 | **Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)**; badge “Beta” | Intro: “If an administrator has connected an OIDC provider to your 1Password Business account”; Step 1: “latest beta release of the 1Password desktop app”; Step 3 note: “Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | `d0890c11…` raw HTML, stable 2/2, matches stored `d0890c11…` |
| S019 | **Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)**; badge “Public Preview” | “administrators can set up a supported integration in their 1Password Business account”; “Your GitHub organization must be hosted on GitHub.com.”; “GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren't currently supported.”; “If you use GitHub Free for organizations, your team won't be able to use this integration for workflows in private repositories.” | `896c780b…` raw HTML, stable 2/2, matches stored `896c780b…` |
| S020 | **1Password Credential Broker is now in public preview** (published 2026-07-28) | Intro: “available for all Enterprise Password Manager Business customers to start using right now”; §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | stored `55bf23fe…` **not reproduced** (see F2) |

**Feature-specific separation holds.** Actions is public preview; custom OIDC is public beta. The values
are not inferred from the parent guide or from a shared page label. The same-page hazard is real in both
directions: S018's “Related topics” chrome contains the parent link “… (public preview)”, and S017's
chrome contains “… (public beta)”. Whole-page substring scanning would misclassify; anchoring on each
H1/badge (as the lesson's CriticAdmission note says) is required and is what the typed features use
(`release_status_anchor: page-title-H1`).

**Calibration check against the typed decisions (static, no gate run).** In
`corpus/feature-claims.json`: `op_cb_github_actions` = `public_preview`, plans
`enterprise_password_manager_business`, requirements `business_account_connected` + `github_com_org`,
exclusions Enterprise Server / Enterprise Cloud with data residency / GitHub Free private repos;
`op_cb_custom_oidc` = `public_beta`, Business + OIDC-provider requirements, runtime constraints
`beta_desktop_app` + `javascript_sdk_only`. Every required quote exists on the live page and every bound
value is supported. The two AFTER controls (`AFTER-GITHUB-BOUNDED`, `AFTER-CUSTOM-BETA-BOUNDED`) are
statically consistent: required-reference sets equal the cited quotes, and no parent-guide title is used
as custom-OIDC status evidence. The known E1/E3 overclaims are represented as before-records whose
release/eligibility values contradict these features, so they remain rejectable on the source facts
(no new outside agreement is claimed). I did not execute the gate; other seats own that.

## Findings

### F1 — S019/S020 lack the same-URL `prior_registry_sha256` chain that S021/S013 carry (medium, freshness)

- S019 (`https://www.1password.dev/brokered-access`) has `sha256: 896c780b…`, `digest_observed_at:
  2026-10-20`, **no `prior_registry_sha256`**. S007 has the same URL, `sha256: e4aef238…`,
  `digest_observed_at: 2026-10-19`.
- S020 (`https://1password.com/blog/1password-credential-broker-public-preview`) has
  `sha256: 55bf23fe…`, `digest_observed_at: 2026-10-20`, **no `prior_registry_sha256`**. S006 has the
  same URL, `sha256: 39a869df…`, `digest_observed_at: 2026-10-19`.
- By contrast, S021 carries `prior_registry_sha256: c083fdca…` (S016's same-URL digest) and S013 carries
  `prior_registry_sha256: ae321512…`.
- The old values are **not deleted**: S006/S007 rows are preserved in `SOURCES.md`, and both old pins
  appear in the advisory build reports (`build/BuildQualifierGate.md`, `build/Source06.md`,
  `build/Source07.md`). But the typed catalog's old→new migration linkage is asymmetric, so the
  “supersedes S006/S007” claim is carried in prose while the machine-readable prior pin is absent for
  exactly the two superseding rows.

**Proposed correction:** add to S019 `prior_registry_sha256: e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818`
and to S020 `prior_registry_sha256: 39a869df8807696009d98bd6d0a86bc27524af65f94f235d37e6dd5a6e514c1f`,
with a note that both are 2026-10-19 point observations; or record the intentional exception in the
lesson. Do not rewrite S006/S007.

### F2 — S020's typed digest is an unreproducible raw-HTML observation; the stable content pin exists only in an advisory build report (medium, freshness)

- Two consecutive `curl -fsSL` GETs of the S020 URL are both 190,261 bytes but differ in **44 bytes**,
  all inside a Cloudflare `/cdn-cgi/l/email-protection#…` token (offsets ~68,525). Raw-HTML hashes
  observed: `0cacf645…`, `dd342618…`, `d93c4302…`, `fed4284c…`; none is the stored `55bf23fe…`. The
  digest therefore cannot function as a byte-stable drift pin, even on the same day.
- A documented content-scoped method reproduces exactly: slice from the first `<h1` to the byte before
  the first following “Continue Reading”, strip `<script>`/`<style>` and tags, HTML-unescape, collapse
  whitespace, trim, hash UTF-8. Two independent fetches both yield
  **`bbfbd7ce87eeffd15938dd1074911c9e6db120729a105c6be141f372bb4c6c36`** (7,547 chars), matching the
  5/5 stability recorded in `build/Source06.md:138-142`.
- `corpus/feature-claims.json` uses the unstable `55bf23fe…` with no representation/method field; the
  stable pin and method exist only in the advisory build report. The integrated `SOURCES.md` S020 row
  deliberately carries no Fetch hash, so the typed artifact is the only production place the unstable
  digest appears. `feature-claims.py` format-checks source digests but never fetches them, so no gate
  decision depends on this. The lesson's “historical point observations, not presently reproducible
  drift pins” sentence is written about *earlier* hashes and does not cover this new S020 pin.

**Proposed correction:** adopt the content-scoped pin (`bbfbd7ce…`) with its extraction method in the
typed artifact if the schema can carry it, or explicitly label `55bf23fe…` a point observation and add
the content pin + method to the active review/lesson. Do not call the raw hash a content-drift detector.

### F3 — S019's catalog contains cross-attribution bindings (low, calibration; no current decision impact)

`S019-business` (“a supported integration in their 1Password Business account”) is bound to
`op_cb_custom_oidc.feature`, `op_cb_custom_oidc.path`, `op_cb_custom_oidc.eligibility.requirements =
business_account_connected` and — the sharpest case — `op_cb_custom_oidc.eligibility.requirements =
oidc_provider_connected`, although “OIDC provider” appears only in S018-intro; `S019-github-com`
(“Your GitHub organization must be hosted on GitHub.com.”) is bound to
`op_cb_github_actions.feature` and `.path`. Neither quote names the feature or path. The gate's
`reference_set != required_references` equality means these bindings cannot satisfy the feature/path or
status fields for an admitted claim (those require S017/S018 titles), so the current decisions are not
corrupted. They remain a latent cross-product attribution hazard if evidence requirements change or
another consumer reads the bindings as quote-level proof.

**Proposed correction:** remove the feature/path bindings from S019 (the titles already satisfy those
fields) or re-anchor them to the S017/S018 title quotes. Same hygiene should be reviewed for the
preserved S007 bindings of the same shape.

### F4 — “1Password Business account” vs “Enterprise Password Manager Business” crosswalk is editorial (low, calibration)

The three docs pages say only “1Password Business account”; S020 says “Enterprise Password Manager
Business customers”. The typed plan value `enterprise_password_manager_business` is bound only to S020;
no opened page states the two names are one SKU. The requirement `business_account_connected` is bound
separately to S019, so no admission rests on the crosswalk, but the plan label is an interpretation, not
a verbatim identity.

**Proposed correction:** record the crosswalk as an explicit source limit (or cite a vendor page that
equates the names) rather than letting the enum imply an established identity.

## Verdict

- **S001: PASS.** Exact URL/anchor/quote reproduce; teaching is correctly process-scoped; the bounded
  reading is preserved in the knowledge entry; the immutable row is byte-identical; the round-22 lesson's
  “S001–S016 fields did not change” is true. The stored Fetch hash is an unreproduced point observation,
  explicitly not treated as current by the tree; that is a disclosure limit, not laundering.
- **S017–S020: PASS on feature-specific status/eligibility.** Each live page supports its own status and
  its own prerequisites; the typed features encode the split and the restrictions separately; the
  known E1/E3 conflations remain rejectable on these source facts. No uniform-status label survives.
- **Freshness within this slice: PARTIAL PASS.** F1 (missing same-URL prior pins for the two superseding
  rows) and F2 (unstable S020 raw digest where a stable content pin exists) are real accounting gaps, but
  neither deletes historic evidence nor changes a decision. F3/F4 are latent calibration limits.
- No immutable-field mutation in S001–S016. No production edit, no lane-state change, no host gate.

## Limits

- No gate executed (feature-claims selftest/runs, sources census, claim-ledger); those belong to the
  parent/other seats. Static record inspection only.
- No account, workflow, SDK, vault, credential or authenticated endpoint touched. No loopback/CDP/
  health probe. Public documentation GETs only.
- HTML was read without JavaScript; the vendor `.md` alternate was also read. `dateModified` is
  vendor-declared, not independently authenticated.
- S001's stored hash cannot be reproduced in principle without the 2026-10-19 representation/UA/headers;
  the tree already disclaims this class. The S020 content pin was reproduced 2/2 today with the stated
  method; the raw pin was not.
- The nine dropped stamps and claim-ledger expectation migrations are outside this seat; no C2 overall
  verdict is claimed.
- Four W1 scribe seats remain uncredited; this report is this seat's independent evidence and does not
  credit them.

## Checks the parent should run after integration

- `python3 corpus/feature-claims.py --selftest` and the C1 before/after/boundary invocation owned by the
  test seats; confirm the four AFTER controls still admit and the ten before-records reject.
- `bash corpus/sources-census.sh --selftest` if any S019/S020 prior-pin or digest text changes; then
  `bash corpus/sources-census.sh` for row/used-by resolution.
- Re-run the S020 content method once at integration; expect
  `bbfbd7ce87eeffd15938dd1074911c9e6db120729a105c6be141f372bb4c6c36` (7,547 chars) and record the access
  date. Do not compare raw HTML bytes.
- If F1 is applied, re-run the feature-claims schema validation to confirm the optional
  `prior_registry_sha256` values are 64 lowercase hex.

Report: `.ufo/waves/round-22/falsify/ReopenSource01.md`
