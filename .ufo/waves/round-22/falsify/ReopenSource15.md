# ReopenSource15 — S015 reopen; S017–S020 feature status/eligibility attack

- wave: `kagi-r22-falsify`, seat `ReopenSource15` (scout, read-only, no delegation)
- axes: **calibration**, **freshness**
- read revision: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (HEAD of the working tree)
- frozen input contract: `.ufo/waves/round-22/integration-manifest.json`
- date: 2026-10-20. Public documentation GETs only; no account/vault endpoint, no
  host-private gate, no fixture execution, no production edit.

## Observed tree (lane edits frozen)

| path | sha256 | lines / bytes | manifest |
|---|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` | 86 / 19721 | matches |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | 192 / 15700 | matches |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | — | matches |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 rows | matches |
| frozen `frozen/before/corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` | 43 / 14261 | equals base `c2cab35` blob |

`git status` shows only falsify-wave artifacts (`falsify/`, `falsify-start.json`,
`falsify-dispatch.json`, modified `falsify-spec.json`, `safe-row-plan.json`);
no production input is dirty. The c2cab35 tree is historical BEFORE only.

## S015 — reopen

Row under attack (byte-identical everywhere, see below):

> S015 | Kubernetes JWT provider — https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/ | docs | A | OpenBao Kubernetes JWT signature verification versus TokenReview revocation behavior | §Kubernetes, TokenReview note; OpenBao 2.7.x | OpenBao JWT verification does not consult Kubernetes TokenReview, so Kubernetes revocation is not immediate through this path. Quote: “The JWT auth engine does not use Kubernetes' `TokenReview` API during authentication” (§Kubernetes note). Fetch sha256: `a0a2b227…` | mined | 2026-10-19 | on-release | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`

Reopened 2026-10-20, exact URL, native HTML:

- Page declares `meta-docsearch:version: 2.7.x` and displays “Version: Version 2.7.x”
  — the row's `OpenBao 2.7.x` locator is current, not a version inference.
- The note sits under the H2 “Kubernetes”, before the first H3
  (“Using service account issuer discovery”): the anchor `§Kubernetes note` is
  located correctly.
- Exact text present: “The JWT auth engine does **not** use Kubernetes'
  `TokenReview` API during authentication” (§Kubernetes,
  https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/, Version 2.7.x,
  reopened 2026-10-20; 12 words).
- The consequence sentence is also present: “tokens that have been revoked by
  Kubernetes will still be considered valid by OpenBao until their expiry time”
  (same heading/URL/date; 18 words).

**Verdict:** the teaching is supported as written; the anchor is correct. The
row's “not immediate through this path” wording is exactly the page's bound.

### Freshness of the S015 pin

| item | value |
|---|---|
| recorded | `a0a2b227a7a91b7af0033a9fc665d319776d2d03aa09341620f9abee2f195fd4` |
| today's raw HTML | `4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f`, 55824 bytes |
| served header | `last-modified: Tue, 20 Oct 2026 07:50:18 GMT` (build timestamp) |

Representations tested against the recorded value, none matching: raw bytes;
`curl --compressed` (identical); tag-stripped + whitespace-squeezed
`851107d4…`; tag-stripped preserving newlines `2204a8c1…`; script/style-stripped
`00f5441b…`. The `.md` alternates (`…/kubernetes.md`, `…/kubernetes/index.md`)
return 404. The page is a Docusaurus 3.10.2 build whose `Last-Modified` is the
deploy time, so its byte stream is build-dependent.

**Conclusion:** the recorded Fetch hash is a historical point observation with an
undocumented representation, not a reproducible content pin. A raw-hash mismatch
must not be recorded as semantic drift, and today's bytes must not be blessed as
the new expected value. Freshness here is adjudicated by the visible quote +
version label, both intact — not by hash equality. No ledger row, stamp or
member is involved, so nothing is deleted or restamped.

### Immutability and round-22 lesson usage

- S015 row line sha256 `9a75576e…` is identical in `c2cab35:corpus/SOURCES.md`,
  the frozen-before copy, and the integrated file; combined S006/S007/S015 line
  hash `3db1eefa…` is likewise identical base→integrated.
- All 16 original rows S001–S016 are byte-identical between `c2cab35` and
  `8ada17a`; the only added ids are S017–S021. No original status, `opened`,
  `recheck`, `used-by` or teach field was mutated — S019/S020 carry the
  supersession in their own rows while S006/S007 remain untouched (lesson
  §Supersession scope).
- Round-22 lesson usage of S015: **none** — S015 is absent from the lesson's
  `source:` line and its `## Gate` table. Its only live consumer is
  `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; that entry's
  round-22 erratum bounds the inherited “an operator must revoke it” inference
  (“tokens can also expire”). The inference is labelled `[INFERENCE]` in the
  body, and the erratum is the authoritative bound. No contradiction with the
  source page: S015 says validity persists “until their expiry time”.

## S017–S020 — feature-specific status and eligibility, examined separately

Each page was reopened at its exact URL on 2026-10-20; the catalog (`feature-claims.json`)
pins and the located quotes were checked separately, never by shared navigation.

| row | title / own status anchor | eligibility and runtime qualifiers | catalog digest check | quotes |
|---|---|---|---|---|
| S017 | “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” (title/H1) | administrator must have connected the GitHub organization to a 1Password Business account (introduction) | `937f6828883599d23c736ae8df57daaa60fd30295c3a300b226caa4ceed10849` reproduced twice, 1,215,155 bytes | 3/3 present |
| S018 | “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” (title/H1) | OIDC provider connected to the Business account (introduction); latest **beta** desktop app (Step 1); only JavaScript SDK (Step 3 note) | `d0890c11edaa85d3ec68680d8d9bc867db502229fb3c815ee6b1b62ac62b76e5` reproduced twice, 1,282,825 bytes | 5/5 present |
| S019 | guide title “(public preview)”, but the guide's own related links distinguish the sub-pages (Actions preview, custom beta) | Business-account integration setup; GitHub.com org only; GitHub Enterprise Server and GitHub Enterprise Cloud with data residency unsupported; GitHub Free orgs cannot use private-repository workflows | `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f` reproduced twice, 1,199,099 bytes | 4/4 present |
| S020 | announcement: whole Broker moves to public preview; §New in this release separates custom OIDC as beta | “available for all Enterprise Password Manager Business customers” (introduction); `article:published_time` 2026-07-28 | `55bf23fe…` **not reproduced** — see below | 2/2 present |

Representative located quotes (all ≤25 words):

- S019 introduction: “administrators can set up a supported integration in their
  1Password Business account” (12 words).
- S019 §GitHub Actions requirements: “GitHub organizations hosted on GitHub
  Enterprise Server or GitHub Enterprise Cloud with data residency aren't
  currently supported.” (17 words).
- S019 §GitHub Actions requirements: “If you use GitHub Free for organizations,
  your team won't be able to use this integration for workflows in private
  repositories.” (21 words).
- S020 §New in this release: Custom OIDC workflows: “Alongside GitHub Actions
  support in public preview, we're slowly rolling out a new capability in beta:
  custom OIDC workflows.” (19 words).

**Verdict:** feature status is correctly separated (Actions = public preview;
custom OIDC = public beta; the guide-level label is not used as a per-feature
status). Eligibility is correctly separated from status (Business plan, GitHub
hosting/plan, beta app, SDK). The S017–S019 raw digest pins are reproducible and
stable across repeated requests — a real freshness improvement over the old
undocumented hashes.

### Finding — S020 catalog digest is structurally irreproducible

Three identical GETs of the S020 URL returned three different raw sha256 values,
all 190,261 bytes: `2deea865…`, `9a80b61f…`, `68e86e24…` (earlier with a browser
UA `ec2b7ed4…`, without UA `f30bcae3…`). The only varying span is one Cloudflare
email-obfuscation link, `/cdn-cgi/l/email-protection#<hex>`; normalizing that span
yields the same digest `8a85318b615200fa9343093438058f46b7166f32281947b57242c8198a636620`
for every fetch. The recorded `55bf23fe…` matches neither the raw nor the
normalized form today.

So: content is stable and the located quotes are intact, but a raw-byte digest
of this page can never be a reproducible pin. The catalog's own limits already
say “A digest identifies captured bytes but is not semantic verification,” and
the gate never fetches URLs; the risk is an audit false positive, not a runtime
break. The same URL is also S006's, so the same representation caveat applies
there.

## Calibration check — decisions, not authored rows

Independently adjudicated against the reopened pages (my author-lane check, not
an outside-verifier score and not a count of criteria rows):

| # | decision subject | verdict | basis |
|---|---|---|---|
| 1 | Broker is uniformly “public preview” | reject (false) | S018 title public beta; S020 feature split |
| 2 | GitHub Actions usable without a Business account | reject | S017 introduction; S019 introduction |
| 3 | GHES or GHEC-with-data-residency supported | reject | S019 requirements |
| 4 | Custom OIDC usable without the beta desktop app | reject | S018 Step 1 |
| 5 | Custom OIDC supported beyond the JavaScript SDK | reject | S018 Step 3 note |
| 6 | Actions path: public preview + Business + GitHub.com org + Free-plan private-repo exclusion | admit | S017, S019, S020 |
| 7 | Custom OIDC: public beta + Business + OIDC provider + beta app + JS SDK | admit | S018, S020 |
| 8 | GitHub setup stores the integration key as org secret `OP_INTEGRATION_KEY` | admit | S019 setup steps |
| 9 | OpenBao JWT auth over Kubernetes service-account tokens does not consult TokenReview; revocation is not immediate there | admit | S015 note |
| 10 | S015 generalises to other IdPs/Vault, or means tokens never end | reject | S015 says “until their expiry time”; the page points to Kubernetes auth “which *does* use the `TokenReview` API” |

5 rejects / 5 admits. These match the active review's dispositions; they do not
create outside agreement, and the E1/E3 overclaim classes are rejected on the
feature/product-specific pages rather than by row totals.

## C2 revision accounting — independent checks (git, not the JSONs)

1. **Nine “dropped” stamps are nine replaced records, zero removed members.**
   `git show aea7a4301:corpus/stamps.tsv` = 56 first-column members;
   `…e1544c19…:corpus/stamps.tsv` = 63. Set difference removes nothing; the nine
   replaced paths are exactly `LOG.md`, `PROVINCE.md`, `SCORECARD.md`,
   `SHONEN.md`, `SKILL.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`,
   `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`; 9 old
   lines replaced, 7 new paths added. This independently confirms the lesson's
   “zero removed stamp members, not nine”.
2. **Four expectation migrations match historic bytes.** R12-02 29→36 cases;
   R12-03 56→63 stamp rows; R13-01 20→23 round headings; R14-01
   `entries=21 row_linked=18` → `entries=24 row_linked=21`; R13-02 stayed 35
   with a note-only change. All read from the two revisions, not from
   `round21-migrations.json`.
3. **Integration stamp set.** `c2cab35` 63 → `8ada17a` 69 members; added exactly
   six (`corpus/feature-claims.json`, `corpus/feature-claims.py`,
   `corpus/knowledge/feature-bound-credential-review.md`,
   `corpus/lessons/round-21-verifier-spotcheck.md`, `corpus/lessons/round-22.md`,
   `corpus/revision-audit.py`); zero removed. Matches manifest `added: 6`,
   `dropped: 0`.
4. **SOURCES.md stamp migration is documented with old and new evidence.**
   `corpus/stamps.tsv` row `db134917… 43 14261` → `3ba44518… 86 19721`; the new
   triple matches the on-disk bytes and the manifest. `pin-migrations-integration.json`
   records `old_stamp`, `base_observed` (same triple), `new_stamp` and a
   disposition. No silent overwrite.
5. S015's own row sits inside that file but its bytes did not change; only the
   file-level stamp moved for the added rows and appended sections.

## Required outputs

- **Concrete supported claim:** OpenBao's JWT auth method, using Kubernetes as an
  OIDC provider, authenticates by public-key JWT verification and does not call
  Kubernetes `TokenReview`, so a Kubernetes-revoked service-account token remains
  acceptable to OpenBao until its expiry (S015, §Kubernetes, Version 2.7.x,
  reopened 2026-10-20).
- **Scope limit:** that note governs only the JWT/OIDC auth method's Kubernetes
  provider. The same page contrasts the separate Kubernetes auth method, which
  *does* use TokenReview, and says nothing about other IdPs, Vault tokens or KV
  value retention; the registry's recorded Fetch hash is not reproducible
  (OpenBao rebuilds the page), so the row's freshness rests on the visible
  quote/version, not on hash equality.

## Proposed corrections (for the integration owner; none applied here)

1. Record S020's catalog digest as representation-unstable: either pin a
   normalized representation (normalize `/cdn-cgi/l/email-protection#[0-9a-f]+`
   and collapse whitespace; today `8a85318b…`) or annotate
   “not reproducible — per-response obfuscation token”. Do not treat a raw-byte
   mismatch as semantic drift. The same class applies to S006 (same URL).
2. For S015 and the other original rows, keep the recorded Fetch hash explicitly
   historical; if a pin is ever restated, use a normalized section-text digest,
   never today's raw build bytes.
3. Optional clarity: S019/S020's `teaches` say “supersedes S007/S006” without
   repeating the lesson's narrower preserved-mechanism scope; the lesson
   paragraph is authoritative. No row edit is required for correctness.

## Limits

- Author-lane check only; not the outside verdict, no agreement scalar, no score.
- Public docs only; no live account/vault/CDP/loopback probe and no host gate was
  run. No fixture execution was assigned to this seat.
- I did not run `corpus/sources-census.sh`, `corpus/feature-claims.py` or
  `corpus/revision-audit.py`; parent should run, after integration:
  `bash corpus/sources-census.sh --selftest`, the feature-claims selftest and
  `python3 corpus/revision-audit.py --selftest`, plus the round-end census
  (`source_rows=21`, no used-by path outside the corpus).
- Four dead W1 scribe seats remain uncredited; nothing here replaces them.
- No tool installs were needed; none were performed.
