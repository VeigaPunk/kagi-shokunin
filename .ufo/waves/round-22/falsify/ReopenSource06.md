# ReopenSource06 — independent reopen of S006 and S017–S020

Seat `KagiR22.ReopenSource06` (leaf; no dispatch). Axes: **calibration (C1)** and
**freshness (C2)**. Attack target: S006; independent feature-specific check of
S017–S020; immutable-row check of the original registry. No production edit, no
account/vault endpoint, no launcher/package manager, no host loopback/health/CDP
probe. Installs/updates: **none**. The four dead W1 scribe seats are uncredited; no
finding below relies on them.

## Exact read revision and observed hashes

Measured tree: HEAD `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (round-22 landing).
Freeze authority: `.ufo/waves/round-22/integration-manifest.json`, observed SHA-256
`31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.

| Input read | Observed SHA-256 | Freeze comparison |
|---|---|---|
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` · 86 lines · 19,721 B | matches manifest |
| `corpus/feature-claims.json` (new in round 22) | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` · 995 lines | matches manifest |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | matches manifest |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` · 192 lines · 15,700 B | matches `stamps.tsv:47` |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` · 43 lines · 4,440 B | matches `stamps.tsv:20` |
| `corpus/knowledge/onepassword-machine-credentials.md` | `95d5b58d44f46d9867e0f4378cc09030865f859a29c6cbf7e2ca027addbfbd80` · 80 lines · 9,048 B | matches `stamps.tsv:26` |

`git status` during the read showed one pre-existing dirty tracked file,
`.ufo/waves/round-22/falsify-spec.json`; it is not this seat's write and is not an
input under attack. All manifest-listed inputs above matched byte-for-byte.

## S006 — reopened and verified

URL `https://1password.com/blog/1password-credential-broker-public-preview`, opened
2026-10-20 (HTTP 200). All quotes ≤25 words; heading and date named.

| Quote | Named location | Verdict |
|---|---|---|
| “unlike a service account token that carries standing access, the organization-wide integration key is an encryption key” | §How 1Password Credential Broker works | exact, in section |
| “is in public preview” | §Try 1Password Credential Broker today | exact, in section |
| “available for all Enterprise Password Manager Business customers” | introduction/lede, **not** §Try | exact; location is before the first content H2 |

Publication: meta `article:published_time`/`article:modified_time` `2026-07-28`, byline
“July 28, 2026”. **Teaching verdict: supported.** The row teaches product-level public
preview plus the integration-key-versus-standing-Service-Account-token distinction, and
both are present. The page additionally carries EPM Business eligibility, which the
S006 row does not claim (S020 adds it).

## Immutable original rows — no mutation

`git show c2cab35…:corpus/SOURCES.md` versus the frozen tree, first-column keyed:

- base rows **16**, current rows **21**;
- removed: **none**;
- added: exactly `S017`, `S018`, `S019`, `S020`, `S021`;
- changed rows: **none** (all S001–S016 byte-identical).

S006 and S007 were separately compared byte-for-byte against the base and are
identical, including `source`, `kind`, `tier`, `scope`, `anchor`, `teaches`, `status`,
`opened`, `recheck`, and `used-by`. The lesson claim “original S001–S016 fields did not
change” is therefore verified at row granularity, not merely asserted. Supersession did
not rewrite the originals.

## S017–S020 — feature-specific status and eligibility, independently

| Row | Opened claim | Independent page observation (2026-10-20) | Verdict |
|---|---|---|---|
| S017 | GitHub Actions public preview; Business connection prerequisite | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)”; intro “If an administrator has connected your GitHub organization to your 1Password Business account” | supported |
| S018 | Custom OIDC public beta; Business + OIDC provider; beta desktop app; JavaScript SDK only | H1 “(public beta)”; intro “If an administrator has connected an OIDC provider to your 1Password Business account”; Step 1 “latest beta release of the 1Password desktop app”; Step 3 note “only supported in the 1Password JavaScript SDK at this time” | supported |
| S019 | Business setup; GitHub.com deployment restrictions; no uniform status | intro “a supported integration in their 1Password Business account”; §Add an integration → GitHub Actions: “Your GitHub organization must be hosted on GitHub.com.”; GHES and GHEC-with-data-residency unsupported; “If you use GitHub Free for organizations, your team won't be able to use this integration for workflows in private repositories.” | supported |
| S020 | EPM Business eligibility; announcement-time Actions preview vs custom-OIDC beta | intro “available for all Enterprise Password Manager Business customers to start using right now”; §New in this release: Custom OIDC workflows: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | supported |

Calibration control is real on the page itself: the setup guide’s H1 says
“(public preview)”, while its own Related topics list labels the custom-workflow page
“(public beta)”. A guide-title or shared-chrome substring therefore cannot settle
custom-workflow status; the feature page’s own title must. This is exactly the
distinction the tree’s `BEFORE-SAME-PAGE-PREVIEW` record encodes, and I confirmed the
underlying page state, not the record’s expected exit.

## Findings

### F1 — calibration defect: `S006-eligible` quote anchor is mislocated (confidence: high)

`corpus/feature-claims.json` S006 quote at line 27:

```
{"id": "S006-eligible", "anchor": "§Try 1Password Credential Broker today",
 "text": "available for all Enterprise Password Manager Business customers"}
```

The exact string occurs **once** on the page, in the introduction/lede before the first
content H2 (“How 1Password Credential Broker works”). The §Try section contains a
different sentence: “available now for all 1Password EPM Business customers”. So the
quote is true and on the same source, but its named located anchor does not contain the
text. The knowledge erratum does not repeat this mislocation; it correctly says “S006
(introduction and §Try 1Password Credential Broker today)”.

Blast radius is currently zero for admit/reject decisions: enumerating every
`evidence` pair in all 14 typed records shows `S006-eligible` is referenced by no
record; only `S006-preview` is used, in `BEFORE-CUSTOM-UNDERCITED` (where §Try is its
correct location). The defect is nonetheless in the evidence layer the C1 mechanism
claims: `feature-claims.py:481-484` checks `release_status_anchor == page-title-H1` and
that the anchor exists among the release-status quotes, but no rule verifies that any
quote's text occurs under its named anchor; quote `anchor` strings are only
type-checked (`feature-claims.py:354-359`), so a wrong location passes validation.

**Proposed correction:** set the anchor to `introduction` (matching the erratum), or
split into two quotes: the lede eligibility sentence and the §Try sentence “available
now for all 1Password EPM Business customers”. Do not alter the S006 registry row.
**Remaining unknown:** whether the label was meant as a page-section locator or as a
descriptive provenance tag; the schema does not document the distinction.

### F2 — freshness/accounting gap: same-URL re-registrations carry inconsistent prior digests (confidence: high observation, medium intent)

Four catalog entries have a same-URL predecessor. Two record the predecessor digest
explicitly; the two that re-register S006/S007 do not:

| New entry | URL previously registered by | Prior SOURCES digest | `prior_registry_sha256` present |
|---|---|---|---|
| S013 | S013 (same id, refreshed pin) | `ae321512…` | yes → `ae321512…` |
| S021 | S016 | `c083fdca…` (S016) | yes → `c083fdca…` |
| S019 | S007 | `e4aef238…` (S007) | **no** |
| S020 | S006 | `39a869df…` (S006) | **no** |

So the catalog holds two digests for the blog URL (S006 `39a869df…`, observed
2026-10-19; S020 `55bf23fe…`, observed 2026-10-20) and two for the setup guide
(S007 `e4aef238…`; S019 `896c780b…`) with no explicit migration link, while S021 shows
the intended old→new convention. The historic values are not lost (original rows are
immutable and carry them), so this is a missing migration edge, not deletion or
laundering. `historical-correction-pins.json` does not contain any of these six digests.

Byte-reproducibility, measured directly:

- S017/S018/S019 catalog digests are **raw-HTML GETs and reproduce exactly** today:
  `937f68…` (1,215,155 B), `d0890c…` (1,282,825 B), `896c78…` (1,199,099 B).
  The vendor `.md` alternates are different representations
  (`092fd0…`/5,245 B, `5da83b…`/6,088 B, `b4de0e…`/6,841 B); the catalog does not
  name which representation it pins.
- The blog URL is **structurally non-reproducible at byte level**: four 2026-10-20 GETs
  produced four digests. The two same-size responses differed in exactly 44 bytes at
  offsets 68526–68569, inside a `/cdn-cgi/l/email-protection#…` token (same link
  context, different ciphertext), i.e. per-response randomized page chrome. Article
  text and the content clock (`2026-07-28`) did not change. Therefore neither
  `39a869df…` nor `55bf23fe…`
  can be a drift signal, and my refetch differences are **not** semantic drift.

**Proposed correction:** add `prior_registry_sha256` to S019/S020 mirroring S013/S021,
or document in the catalog that volatile-page re-registrations intentionally omit it;
record the representation (`raw HTML GET`) for S017–S019 and the randomized-token
caveat for S020. Do not restamp S006/S007 and do not bless a new blog digest.

### O1 — scope limit, not a defect: S019’s private-repository wording is conditional

The page excludes private-repository workflows **only** for GitHub Free organizations;
GitHub.com hosting is the flat deployment requirement. The S019 row compresses both as
“GitHub.com/private-repository requirements”, which is defensible but omits the plan
condition. The active review states the conditional correctly (“Free organizations
cannot use this integration for private-repository workflows”), so no admission error is
present; consumers of the row alone should not read the exclusion as universal.

### O2 — accounting context: the 16→21 delta is identifiers, not five distinct pages

S019 re-registers the S007 URL and S020 re-registers the S006 URL. The census delta is a
row/identifier count and must not be presented as five newly discovered pages or as a
calibration scalar. The lessons Gate describes the five as source identifiers, which is
consistent; this note only bounds its meaning.

### O3 — supersession is prose-only; historical rows stay `mined`

S006/S007 keep `status = mined` and `used-by = corpus/knowledge/onepassword-machine-credentials.md`;
the supersession edge exists only in S019/S020 `teaches` text and the SOURCES supersession
paragraph. The old entry’s item 4 is unchanged and carries appended round-22 errata;
`corpus/README.md:76` still indexes the old entry, while `:124` separately indexes the
corrected review. This is the documented append-only design, not a false current claim,
but there is no machine-readable `superseded_by` relation for a checker to follow.

## Named result (required pair)

- **Concrete supported claim:** S018 — custom OIDC workflows are public beta, require a
  connected OIDC provider in a 1Password Business account and the latest beta desktop
  app, and are currently supported only in the JavaScript SDK. Verified at the H1, the
  introduction, Step 1, and the Step 3 note on 2026-10-20.
- **Scope limit:** these pages establish point-in-time status/eligibility text only.
  They do not establish live availability, adoption, runtime/SDK behavior beyond the
  quoted note, or any product-wide status from a guide title. S019’s private-repository
  exclusion is plan-conditional (GitHub Free), not universal.

## What this seat did not do / parent checks

No gate, build, lint, formatter, installer, launcher, or host probe was run; the
expected decisions in `feature-claims.json` were read, not executed. After integration
the parent should run: `python3 corpus/feature-claims.py --selftest` (10 cases) plus one
bounded `--input` control; `python3 corpus/sources-census.sh` and its selftest (21 rows,
4 sourced entries); and the frozen-base revision audit (`before-runnable.json`, six
stale, zero dropped) if C2 verdicts depend on it. If F1 is corrected, add a
quote-anchor containment check so each quote’s text is findable under its named anchor;
no such check exists today.

Limits: no vendor-truth claim beyond the quoted text; no account, workflow, SDK, vault,
or deployment was exercised; digest observations are point observations and, for the
blog URL, cannot adjudicate content semantics.

Report: .ufo/waves/round-22/falsify/ReopenSource06.md
