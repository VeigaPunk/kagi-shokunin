# Source07 — S007 re-open: feature-specific status, eligibility, and pin reconciliation

Axes: **calibration** (C1) and **freshness** (C2). Read-only seat: S007 plus the two feature links
it names were opened; no account, workflow, SDK, or vault was exercised; no source-registry,
entry, lesson, or log edit was made.

Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD`, matches the
frozen base). The live worktree was **dirty from peer round-22 work** when read, and that is part
of the freshness evidence below:

| file | HEAD (`c2cab35`) sha256 | worktree sha256 | worktree mtime |
|---|---|---|---|
| `corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` | `e4afe6d080b97741942c9e8a75e3d6df4284e983b53f54d5e7e88b88b4cebe3f` | 2026-10-20 18:36:27 -0300 |
| `corpus/knowledge/onepassword-machine-credentials.md` | `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb` | `e885081e4d566af05080edde8e92de7692db4dc974b678b6020f2e30e68f96af` | 2026-10-20 18:34:10 -0300 |

The worktree additions are S017–S020 and an appended round-22 erratum. I read them as peer work
and checked them against the pages; I did not write them.

## 1. S007 re-open — exact evidence

Source: **https://www.1password.dev/brokered-access**, opened **2026-10-20** with `curl -sL`
(HTTP 200, `date: Tue, 20 Oct 2026 21:33:58 GMT`, `etag: W/"11vu9hu72scpp31"`, `age: 11415`,
**no `Last-Modified`**). The page displays no visible revision date; it does carry a
machine-readable `dateModified`, which the S007 row does not record.

| representation | bytes | sha256 |
|---|---|---|
| raw HTML (default curl UA) | 1,199,099 | `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f` |
| raw HTML (Chrome UA) | same | same |
| raw HTML (`--compressed`) | same | same |
| vendor text, `…/brokered-access.md` | 6,841 | `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3` |
| tags-stripped text (script/style removed, tags→space, unescaped, whitespace collapsed) | 6,034 chars | `972b353e548e679e1907b04b32a469f5e69369fce33cb802adb68a84f00e1f5a` |
| GitHub Actions sub-page raw HTML | 1,215,155 | `937f6828883599d23c736ae8df57daaa60fd30295c3a300b226caa4ceed10849` |
| GitHub Actions sub-page `.md` | 5,245 | `092fd0ba581cbb60eaf756e853d8659c15b76e17dd616c23aff8137ef42c6d0f` |
| Custom workflow sub-page raw HTML | 1,282,825 | `d0890c11edaa85d3ec68680d8d9bc867db502229fb3c815ee6b1b62ac62b76e5` |
| Custom workflow sub-page `.md` | 6,088 | `5da83bb665fc575b6c7d27c3b31ab2e1be4e2feded35fc119e1185467311016e` |

Vendor content clocks (JSON-LD `dateModified`) and deployment stamp observed in all three pages:

- guide **2026-08-17T22:36:47.823Z**; GitHub Actions **2026-08-04T15:42:17.097Z**; custom workflow
  **2026-08-17T22:36:47.822Z**; `buildId` **6ad68a298cdc29c1c7fdf7e9** on all three.

## 2. Scoped teaching, with located quotes (≤25 words each)

All quotes from the pages opened 2026-10-20; URL as named.

| # | location | quote | words |
|---|---|---|---|
| Q1 | guide, introduction — https://www.1password.dev/brokered-access | “Secrets are only accessible after a workload has been verified, and only remain accessible for the duration of the workflow.” | 20 |
| Q2 | guide, §Add an integration → GitHub Actions, step 2 | “The token value is your integration key, which is required to decrypt secrets in your team's workflows.” | 17 |
| Q3 | same step | “Set the secret name to OP_INTEGRATION_KEY and the value to your integration key.” | 13 |
| Q4 | guide, §Add an integration → Custom Workflow (OIDC), step 3 | “All configured claims must match to verify the workload's identity.” | 10 |
| Q5 | guide, subtitle under H1 | “Learn how to set up a supported integration in 1Password Business” | 11 |
| Q6 | guide, §Add an integration → GitHub Actions, requirements | “Your GitHub organization must be hosted on GitHub.com.” | 8 |
| Q7 | same requirements | “GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren't currently supported.” | 17 |
| Q8 | same requirements | “If you use GitHub Free for organizations, your team won't be able to use this integration for workflows in private repositories.” | 21 |
| Q9 | custom-workflow H1 — https://www.1password.dev/brokered-access/custom-workflow | “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | 14 |
| Q10 | GitHub Actions H1 — https://www.1password.dev/brokered-access/github-actions | “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | 14 |
| Q11 | custom-workflow, §Step 1 | “make sure you have the latest beta release of the 1Password desktop app” | 13 |
| Q12 | custom-workflow, §Step 3 note | “1Password Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | 14 |

### Status / eligibility / product / path qualifiers

- **Status is per path, not guide-wide.** The guide is titled and badged **public preview**; the
  sidebar reads “Credential Broker (public preview)”. The **GitHub Actions** page is titled and
  badged **public preview**. The **Custom Workflow (OIDC)** page is titled **(public beta)** and
  carries a **Beta** body badge. The guide's raw HTML contains exactly **one** “public beta”
  string — the embedded navigation title for the custom page — while its tags-stripped text
  contains **zero**. This is the exact reason the round-21 sweep produced a false negative.
- **Product / plan:** all three pages scope setup to a **1Password Business** account (“supported
  integration in 1Password Business”; an administrator connects the Business account).
- **Path — GitHub Actions:** GitHub.com organization only; GHES and GitHub Enterprise Cloud with
  data residency unsupported; GitHub Free organizations excluded for private-repository
  workflows. The integration key is stored as the GitHub organization secret `OP_INTEGRATION_KEY`.
- **Path — Custom Workflow (OIDC):** administrator connects an OIDC provider; Step 1 requires the
  **latest beta desktop app**; Step 3 states **JavaScript SDK only at this time** (the SDK example
  notes SDK 0.5.0-beta.1 accepts only unpadded integration keys).
- The guide documents only these two “supported integrations” on this page. It does **not**
  establish that both paths share a release status, that custom OIDC is public preview, that
  workflow-duration delivery expires a Service Account token, or that no CI-held key remains.

## 3. Calibration: entry claims vs S007 (frozen HEAD `c2cab35`)

| claim (frozen-base location) | verdict | evidence / correction |
|---|---|---|
| `corpus/knowledge/onepassword-machine-credentials.md:16` — “labels the workflow integration public preview” | **REJECT as uniform; ADMIT only scoped** | True for the guide and GitHub Actions; **false for Custom Workflow (OIDC)**, which is public beta (Q9, Q11). Replace with path-specific statuses. |
| `:16` — “requires every configured OIDC claim to match” | **ADMIT** | Q4, Custom Workflow (OIDC) step 3. Correct as written, and it is a custom-path setup step, not a guide-wide rule. |
| `:16` — “limits access to the workflow duration” | **ADMIT** | Q1, guide introduction. Correct as the guide's overview sentence. |
| `:16` — “For GitHub Actions … integration key as an organization CI secret” | **ADMIT** | Q2–Q3, GitHub Actions step 2; the secret is on the GitHub organization. |
| `:25` — “does not remove every CI-stored key … organization secret” | **ADMIT** | Q2–Q3; no page sentence removes that key. |
| `:34` (round-21 erratum) — Business-plan scoping | **ADMIT** | Q5; page also says “in their 1Password Business account”. |
| `:35` (round-21 erratum) — “public beta … Not reproduced … unverified” | **REJECT the negative and the conclusion** | Parent raw HTML has 1 “public beta”; the custom sub-page's own H1 and badge declare public beta (Q9); stripped-text count of 0 is a method artifact, not absence. The critic's report is confirmed, path-scoped. |
| `corpus/lessons/round-21.md:108` — “disagree (not reproduced)” | **REJECT** | Same evidence. Historic row should be superseded with an appended correction, not rewritten. |
| `LOG.md:1041` — “not reproduced (0 matches)” | **PARTLY REPRODUCIBLE, conclusion falsified** | The 0 count is reproducible only over the tags-stripped parent text; it does not support “not reproduced”. |
| `corpus/SOURCES.md:13` (S007 scope) — “Public-preview workflow identity verification …” | **REJECT as uniform status** | Scope is path-blind and its anchor omits the two feature pages. Coverage is superseded by S017/S018 (status) and S019 (eligibility); no new row is needed. |
| worktree S017/S018/S019 row assertions | **CONFIRMED** | Every statement I can derive from the pages checked: H1 statuses, Business prerequisite, GitHub.com/GHES/data-residency/Free restrictions, beta app, JS-SDK-only. |
| worktree S020 assertion (announcement feature split) | **NOT CHECKED** | The announcement was outside this seat's re-open scope; S020 needs its own check. |

The decisive calibration failure is not the count of rows but the **uniform status inference**:
a guide-level label applied to both documented workflows. The bounded control that survives is
“GitHub Actions public preview + custom OIDC public beta, both Business-scoped, with the named
GitHub and SDK/beta-app restrictions”.

## 4. Freshness: S007 pin reconciliation (exact historic evidence)

- Historic pin: `e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818`, introduced with
  the S007 row at **`c41af82`** (`git log -S`; unchanged at `e1544c1` and at frozen `c2cab35`).
  The row does not name the representation or command that produced it.
- Today, no fetched representation matches that pin. Tested: raw HTML (1,199,099 bytes),
  `--compressed`, two user agents, `sed`-tag-stripped (with and without space substitution),
  HTML-unescaped, whitespace-collapsed, newline-collapsed, and the vendor `.md` (6,841 bytes).
  Digests are in §1; none equal `e4aef238…`.
- The vendor content clock for this URL is **2026-08-17T22:36:47.823Z**, earlier than both the
  2026-10-19 opening and today's 2026-10-20 opening; the GitHub Actions page is older still
  (2026-08-04). So there is **no observed content change** across the two openings.
- No archived copy is available to authenticate the 2026-10-19 bytes: Wayback CDX for
  `1password.dev/brokered-access`, `from=2026-10-01&to=2026-10-21`, returned `[]`; the wildcard
  retry returned HTTP 429.
- **Disposition (QM14):** classify the stored pin as **unreproduced / representation undocumented**,
  **not** as content drift and **not** as a verified match. Preserve the old value verbatim in
  the migration record; do not delete it and do not silently restamp. [INFERENCE] A raw-HTML pin
  over this Mintlify/Next deployment is unstable against deployment chrome even when
  `dateModified` is unchanged; a vendor-text pin plus the content clock is the durable pair.
- **Pin debt on the correction:** all four new rows **S017–S020 carry no `Fetch sha256` at all**
  (`awk` over rows 23–26: 0/4), including **S019**, which explicitly supersedes S007. The
  superseding row therefore closes the qualifier gap but inherits the revision-stamp gap.
- **Citation wiring gap:** the round-22 erratum in the knowledge entry cites S017–S020, but the
  entry's `source:` line still lists only S001–S004, S006, S007, and S017–S020's `used-by` is
  `corpus/lessons/round-22.md` only. `SC_ENTRY_CITE` reads the entry's `source:` line, so the
  appended correction is not machine-covered by the registry gate. Either add S017–S019 to the
  entry's `source:` line and their `used-by`, or record an explicit machine-checked correction
  pointer; prose indirection alone leaves the correction outside the census.

### Proposed correction (for the integration owner; not applied here)

1. **Entry** — keep the appended round-22 erratum, and append one sentence to it:
   *“The round-21 ‘not reproduced’ result is superseded, not deleted: the parent page's raw HTML
   carries the custom page's ‘(public beta)’ navigation title once, and the custom page's own H1
   and Beta badge declare it; the earlier zero count came from a tags-stripped parent-only sweep.”*
2. **Historical records** — append the same one-line correction to `LOG.md:1041` and
   `corpus/lessons/round-21.md:108` (append; do not rewrite the historical verdict).
3. **S019 pin** — add, labeled:
   `Fetch sha256 (raw HTML, curl -sL, 2026-10-20, 1199099 bytes): 896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f;`
   `text (…/brokered-access.md, 6841 bytes): b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3;`
   `content clock dateModified 2026-08-17T22:36:47.823Z; buildId 6ad68a298cdc29c1c7fdf7e9.`
   Add the QM14 note: *“S007 pin e4aef238… (c41af82) not reproduced on 2026-10-20; retained as
   historic value; no observed content drift (content clock predates both openings).”*
4. **S017/S018 pins** — same labeled treatment: S017 `092fd0ba…` (`.md`, 5,245 bytes),
   `937f6828…` (raw HTML), clock 2026-08-04T15:42:17.097Z; S018 `5da83bb6…` (`.md`, 6,088 bytes),
   `d0890c11…` (raw HTML), clock 2026-08-17T22:36:47.822Z.
5. **S007 anchor** — the row says “no displayed version/date”; that is true of the rendered page,
   but add the machine-readable content clock and note that the guide-level label is not a
   per-workflow status. Do not edit the immutable columns in place.

No new superseding row is needed: S017/S018/S019 already exist in the worktree and carry the
right scope; the missing move is pinning them and correcting the historic negative.

## 5. Falsifier

This reading is falsified if a re-opened page changes the title/badge status of either path
(including the guide's own preview label), drops the 1Password Business prerequisite, changes the
GitHub.com / GHES / data-residency / GitHub Free restrictions, removes the beta-desktop-app or
JavaScript-SDK-only requirement, or alters the claim-match, workflow-duration, or integration-key
sentences. Separately, a documented command that reproduces `e4aef238…` from a 2026-10-19 fetch
would falsify the “unreproduced pin” classification (not the content-clock observation).

## 6. Limits

- Read-only; no registry/entry/lesson edit, no account, workflow, SDK, vault, or secret operation.
- Only S007 and its two feature links were opened; S006 and S020 (announcement) were **not**
  reopened, so the announcement-side sentences in the worktree erratum are not independently
  verified here.
- HTML was fetched without JavaScript; the `.md` endpoint is the vendor's own text rendering.
  `dateModified` is vendor-declared, not independently authenticated.
- Wayback had no capture in the queried window; the 2026-10-19 bytes were not recovered.
- Parent should run after integration: `bash corpus/sources-census.sh` and `--selftest`, plus the
  claim-ledger `cells`/`verify` path if the entry's `source:` line or stamped files change.

Report: `.ufo/waves/round-22/build/Source07.md`
