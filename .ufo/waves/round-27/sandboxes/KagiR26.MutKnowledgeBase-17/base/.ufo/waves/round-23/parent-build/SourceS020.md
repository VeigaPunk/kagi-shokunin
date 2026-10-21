# SourceS020 — provenance audit of SOURCES row S020 (round 23 parent build)

Seat `SourceS020`, reviewer, leaf (no dispatch), read-only. Axes: calibration, freshness,
operability. This report is advisory only. It has no admission, judgment or re-curation
authority. S006 is touched only as S020's supersession target.
No gate, ledger row, census, selftest, handler, `op`, vault or host command was executed.
No account, workflow, SDK or deployment probe was made.

## Exact read revision

- `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf`. Base blob `corpus/SOURCES.md` =
  `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`.
- S020 is `corpus/SOURCES.md:26`. sha256 of the row line plus LF =
  `f1c9b657a166a0aa6c719d15b410c877795ab976b2b525e67f431367d5640dab`. It is byte-identical in the
  working tree at read time. The working-tree `SOURCES.md` (`06dde644…`) only appends S024–S026.
- S020's consumers are unchanged against base (`git diff --quiet d218603`):
  `corpus/feature-claims.json`, `corpus/knowledge/feature-bound-credential-review.md`,
  `corpus/lessons/round-22.md` and `corpus/knowledge/onepassword-machine-credentials.md`.
- **L1 implementation was in progress during this audit.** The files below are uncommitted and
  changed while I read them. They are outside the frozen population, so every finding marked
  *[WT]* is a snapshot at the stated digest, not a verdict on landed code:
  - `corpus/source-fetches.tsv` `e2f40132…`
  - `corpus/sources-census.sh` `bf56b1a4…` (diff against base `7bcdb81`)
  - `corpus/lessons/round-23.md` `e8821701…`
  - `corpus/closure-dispositions.json` `52ae37de…`

## Opens (all succeeded; none skipped)

| what | how | result |
|---|---|---|
| S020 URL `https://1password.com/blog/1password-credential-broker-public-preview` | read tool (reader markdown) | OK. H1, byline "July 28, 2026", all H2s present |
| same URL, raw | 7 independent GETs, 2026-10-21 ~00:43–00:55 −03:00, curl 8.23.0. Variants: Chrome-like UA without encoding (×3); curl default without encoding (×1); `--compressed` (×1); `-fsSL --compressed` with the round-23 UA string (×2). The flags were typed by hand, not executed from the TSV. | all `HTTP/2 200`, no redirect (`url_effective` = row URL), `text/html; charset=utf-8`, `cf-cache-status: DYNAMIC`, `vary: accept-encoding` |
| `https://www.1password.community/announcements-52/1password-credential-broker-is-now-in-public-preview-25158` | read tool | OK. Vendor community post, 2026-07-29 (lead only) |
| `1password.com/blog/categories/developers` and `/unified-access` | curl, first listing page | OK, 13 post slugs each |
| web search ×2 (Broker GA/custom OIDC; "Credential Broker" October 2026) | web_search | OK |

## Row recheck at base (S020, `corpus/SOURCES.md:26`)

Public quote, the only verbatim S020 sentence in this report (19 words). Location:
§New in this release: Custom OIDC workflows, published 2026-07-28, reopened 2026-10-21:
“Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.”

| cell | observed 2026-10-21 | verdict |
|---|---|---|
| source/URL | URL is byte-equal to the canonical `/blog/1password-credential-broker-public-preview`. H1 = the page title. Served without redirect. | supported |
| kind `docs` | Vendor blog announcement. The contract enum (`sources-census.sh:161`) has no blog/announcement kind; `docs` is the nearest value. The scope cell's "announcement-time" wording carries the qualifier. | acceptable, minor |
| tier `A` | First-party vendor statement of its own announcement-time status and eligibility, so A for that scope (QA1). It is **not** tier A for current per-feature status; S017 and S018 own that. | supported as scoped |
| scope | Both halves present: the eligibility sentence in the lede, and the split in §New in this release. | supported |
| anchor | The H2 "New in this release: Custom OIDC workflows" exists verbatim. "Introduction" is an unheaded lede: the nearest preceding DOM heading is the taxonomy H2 "Related Categories". This hazard is already in `SourceS006.md:212-221`; I reproduced it, and it is not re-litigated here. Published date: `article:published_time`, `modified_time`, `og:updated_time` and CMS `date` are all `2026-07-28T00:00:00.000Z`. | supported (precision note) |
| teaches | The split is verbatim, above. The EPM Business sentence is present once in the rendered text (13 words; text identical to `feature-claims.json:181`). A second EPM sentence sits in §Try 1Password Credential Broker today. | supported |
| status `mined`, used-by | `round-22.md:1` and `feature-bound-credential-review.md:1` both carry S020 on their `source:` line, and both paths exist. | supported |
| opened 2026-10-20, recheck on-release | Consistent with round-22 records. The page has no update clock (`modified` = `published`), so "on-release" means reopening the feature pages, not this post. | consistent |

## Historical bytes vs current support vs transport volatility vs deployed proof

- **Historical bytes.** These are point observations of undocumented or volatile
  representations. None of them can be refetched, and none is a drift pin:
  - S006 in-row `39a869df…` (2026-10-19)
  - `feature-claims.json:176` `55bf23fe…` (2026-10-20, with `prior_registry_sha256 39a869df…` at `:177`)
  - *[WT]* the lesson's `56ade2d0…` and `cbd70b29…`
  - *[WT]* the TSV's `53dfeac5…`

  None equals any of my 7 bodies. This matches `SOURCES.md:101-104` and `feature-claims.json`
  `review.limits[8]`.
- **Transport volatility (reproduced).**
  - The decoded body is 190,261 B in all 7 GETs, under three UA/encoding variants. That equals
    the size ReopenSource20 and SourceS006 recorded.
  - The 7 raw sha256 values are all distinct. Each body differs from the first in exactly 44 bytes,
    at 0-based offsets 68,525–68,568, inside `/cdn-cgi/l/email-protection#<hex>`.
  - gzip wire size also varies (38,999, 39,022 and 39,132 B). Never record wire bytes.
  - Masking the token gives a stable digest, but the digest depends on the mask literal. Literal
    `MASKED` gives `60ccf221539bc565aeae5ac397818e97e728db6c468e841fd12373b735480f43` (190,223 B, 7/7).
    Literal `TOKEN` reproduces SourceS006's `4f9aa03f…` [INFERENCE: matched by digest; that report
    does not name the literal].
  - `buildId` is `build-TfctsWXpff2fKS`.
- **Current semantic support.** Both S020 assertions are present today at their anchors.
  - The split quote occurs once in the rendered text, directly after its H2 text and before the
    next H2.
  - SourceS006's article-text pin (H1 to before "Continue Reading", strip, unescape, collapse,
    trim) reproduces **7/7** here: `bbfbd7ce87eeffd15938dd1074911c9e6db120729a105c6be141f372bb4c6c36`,
    7,547 chars. This is an independent cross-seat reproduction.
- **Deployed-product proof.** None. The page is a 2026-07-28 vendor assertion. Its custom-OIDC
  sentence says the beta is "slowly rolling out", so the page does not establish per-account
  availability of custom OIDC for any EPM Business customer.

## Supersession and freshness search

- The edge S020 → S006 is explicit but prose-only (`SOURCES.md:26`, `:56-59`, `:73-77`). It is
  partial: S006's recorded integration-key quote is still present verbatim under §How 1Password
  Credential Broker works, and S006's §Try status quote is still present. S006 is incomplete, not
  refuted (consistent with SourceS006).
- No row supersedes S020, at base or in the working tree (grep for `supersedes S020`: none).
- Bounded public search found no newer vendor post that supersedes the announcement. Neither
  category first page lists another Credential Broker slug; the newest listed posts are dated
  2026-10-06 and 2026-10-19.
- The vendor community post (2026-07-29, https://www.1password.community/announcements-52/1password-credential-broker-is-now-in-public-preview-25158)
  corroborates the split at feature level. Under "What’s in the public preview" it has a subsection
  titled “Generic OIDC (beta)”, yet its lede says “now in public preview, with support for GitHub
  Actions and Generic OIDC”. That is the same product-level versus feature-level trap.
  - It is a lead only: `community` cannot be tier A (`SC_INFLATION`).
  - Its docs link `www.1password.dev/environments/credential-broker` was **not opened**. It is a
    lead for the S019 owner.

## C2 source-fetch provenance: exact expectations for S020

| field | expectation |
|---|---|
| url / final_url / status | `https://1password.com/blog/1password-credential-broker-public-preview` for both; `200`; byte-equal to the row. *[WT]* TSV row matches. |
| representation | Decoded entity body (Content-Encoding removed), **volatile**. *[WT]* `decoded-http-body-volatile-v1` is correct. |
| bytes | 190,261 (stable on 2026-10-20 and 2026-10-21). *[WT]* TSV matches. |
| raw sha256 | Per-response point attestation. Never compare it across captures, nor to `39a869df`, `55bf23fe`, `56ade2d0`, `cbd70b29` or `53dfeac5`. Never require equality with `feature-claims.json:176`, because that value sits under `PINNED_SOURCES_SHA256` (`feature-claims.py:62`). |
| normalized | `rendered-text-v1` **with trim** = `20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f` (9,530 B, 7/7). It covers page plus site chrome, not article identity (F5). The article-coupled alternative is `bbfbd7ce…` (above). |
| normalization choice | `rendered-text-v1` is required. Under `raw-literal-v1` the split quote's only raw hit is inside the `<script id="__NEXT_DATA__">` JSON, because the rendered `<p>` encodes the apostrophe as `&#x27;`. A raw match would therefore "locate" it in a non-rendered payload. |
| quote(s) | Split quote: 19 words, one rendered occurrence. EPM sentence: 13 words, one rendered occurrence in the lede (F3). Both are within the ≤25-word bound. |
| location | Exact H2 text `New in this release: Custom OIDC workflows` (*[WT]* TSV has the prefix `New in this release`, F9). The lede is "introduction" as defined in SourceS006 item 3. |
| identity binding | *[WT]* `row_identity_sha256` = `c1ce1e05d3cca13412de51bb3f662a6f9ef631f0452f43753a3ad915394b4cc5`, which I verified as sha256 of `S020\tmined\t<url>\n`. Limit: this binds provenance to (id, status, URL) and **not** to `teaches` or `anchor`. A later edit to S020's teaches cell will not invalidate the quote binding. |

## The one real contradiction (C2, operability/freshness) — F1

The declared `rendered-text-v1` does not reproduce the recorded S020 normalized digest. The
definition appears in three *[WT]* places with the same wording:
`source-fetches.tsv` header, `sources-census.sh` header (around `:72-74`) and `round-23.md:40-41`.
It reads: “strip script/style, tags -> single space, html.unescape, collapse whitespace”.

Implemented literally (case-insensitive `<(script|style)\b…</\1>` removal, `<[^>]+>` → space,
`html.unescape`, `\s+` → one space), the S020 bodies give
`f747d2afec6a4e58007fae95c9e90091928d86cc7f0bfa23d45062a77d5b7e56` (9,532 B) on all 7 GETs.
The recorded `20b4fd86…` (9,530 B) reproduces only after an **undeclared trim** of leading and
trailing whitespace. Case sensitivity, separate script/style passes and ASCII-only versus Unicode
`\s` made no difference on this page; trim is the only free choice observed.

Consequence: an independent verifier who follows the declaration will get a mismatch. That
mismatch is exactly what the corpus forbids reading as drift. No committed code computes
normalized digests (the census only shape-checks them), so today the "stable declared identity"
cannot be reproduced from its declaration.

Fix: declare "…collapse whitespace, then trim; sha256 over UTF-8". Better, commit a reference
normalizer whose selftest pins FX-1 below. Sent to `agent://KagiR23`.

## Findings by severity

**Medium**
- **F1**, above.
- **F2 [WT] Supersession is computed but never used.** In `sources-census.sh` (`bf56b1a4`), the
  `SUPERSEDED[]` map is declared at `:229` and filled at `:242`, and appears nowhere else. SC_FETCH
  therefore treats superseded or historical rows exactly like active ones. That falls short of the
  C2 contract: "distinguish historical/rejected/superseded assertions from active public evidence".
  The parse `^supersedes S[0-9]` also flags whole rows, but S020 → S006 is scope-partial. S006's
  integration-key quote is still live, so blanket-marking S006 historical would retire active
  evidence.
  Fix: use a scoped relation (for example `supersedes S006 (status/eligibility)`), or remove the map
  and state that SC_FETCH does not model supersession. Sent to `agent://KagiR23`.

**Low–Medium**
- **F3 [WT] Only half of S020's teaching has C2 provenance.** S020 teaches two assertions. The TSV
  binds only the split quote. The EPM-eligibility half, which feeds `eligibility.plans` for both
  features (`feature-claims.json:193-194`), keeps only the non-reproducible 2026-10-20 capture.
  The `duplicate-provenance` rule (`sources-census.sh:296`) forbids a second same-capture row for
  S020. Either key provenance on (id, location) for rows sharing one capture's raw and normalized
  digests, or state the coverage bound in the lesson.
- **F4 [WT] SPOT-03 misclassifies S020.** `closure-dispositions.json` SPOT-03 says S020–S023 "stay
  immutable historical records". That contradicts the spot-check, which recorded admit and agree
  (`round-22-verifier-spotcheck.md:105`), and the registry's active review: "The active review uses
  S017–S021's explicit feature/product anchors". S020 is unchanged **active** evidence; S006 is the
  historical row. Its pointer is file-granular (`corpus/SOURCES.md`), so the C1 checker cannot see
  row drift; the row-line pin is `f1c9b657…`. Sent to `agent://KagiR23`.

**Low**
- **F5 [WT] The normalized digest is chrome-coupled.** Of its 9,530 B, 2,120 B are site chrome:
  promo banner, "Continue Reading" teasers and footer. The TSV header's "the normalized digest is the
  stable declared identity" holds only for the observation window. A banner change will alter it
  with no article change. The article-coupled pin `bbfbd7ce…` is the better content identity; the
  quote-under-heading check stays the content check.
- **F6 (base) Path bindings to S020 have no support on the page.** `feature-claims.json:189-190`
  binds `path` values to `S020-status-split`. The S020 page has **0** occurrences of
  `custom-workflow`; its only `brokered-access` link is the github-actions link in §Try. The binding
  is non-load-bearing, since `evidence_requirements.path` uses S017-title and S018-title. Still, it
  is a quote binding the source does not carry (QA1 / M12 class).
  Fix: drop both path bindings from S020.
- **F7 [WT] The recorded capture is not traceable in the lesson.** `round-23.md:48` cites S020 GETs
  `56ade2d0…` and `cbd70b29…`, but the TSV records `53dfeac5…`, a third capture the lesson does not
  mention. Name it there.
- **F8 [WT] Census header contradicts the code, and selftests lack volatile cases.**
  - The census header (around `:64-66`) says two rows for one URL "must agree on the raw digest"
    unconditionally. The code exempts volatile rows (`:284`), and the TSV header says the same.
  - The case list (`:563-574`) has no volatile admit control and no normalized-disagreement case
    (FX-2, FX-3).
- **F9 [WT] TSV location is truncated.** The location `New in this release` should be the exact H2
  `New in this release: Custom OIDC workflows`.

**Carried, still present at base (not redone)**
- ReopenSource20 obs 1: the row's teaches cell says "supersedes S006" without scope. It is bounded
  only by registry prose at `SOURCES.md:73-77`.
- ReopenSource20 obs 2: `S020-epm-plan` is bound to `op_cb_custom_oidc` `eligibility.plans`
  (`feature-claims.json:194`; also required by `evidence_requirements`). The page's own custom-OIDC
  sentence qualifies that feature as a slow beta rollout.
- ReopenSource20 obs 3, extended: `used-by` is not an exhaustive index.
  - E1's body cites S020 (`onepassword-machine-credentials.md:43,58,63`) but its `source:` header
    does not.
  - *[WT]* `round-23.md:1` lists S020, but S020's `used-by` does not list that lesson. The census
    does not scan lessons as entries.
- ReopenSource06 F2 (missing `prior_registry_sha256`) is **resolved** for S020 at `4be5da3`
  (`feature-claims.json:177`).

## Proposed synthetic minimal failing fixtures for L1 (specified, not run against any gate)

**FX-1, normalizer trim (kills F1's mutant).**

Build `a.html` with this bytewise recipe:

```
printf '\n<html><head><title>Fixture | Vendor</title><script id="__NEXT_DATA__" type="application/json">{"q":"we'"'"'re rolling"}</script><style>.x{color:red}</style></head>\n<body><h2>Related Categories</h2><ul><li>News</li></ul>\n<p>Available for all Example Business customers today.</p>\n<h2>New in this release: Feature B</h2>\n<p>Feature A is in preview; we&#x27;re slowly rolling out Feature B in beta.</p>\n<a href="/cdn-cgi/l/email-protection#00112233">Support</a>\n</body></html>\n'
```

`b.html` is the same file with the token `00112233` replaced by `44556677`.

My reference implementation of the declared steps gives:

| | `a.html` | `b.html` |
|---|---|---|
| raw sha256 (471 B) | `b66b8523…88b7f` | `d45c8848…6671e` (differs) |
| normalized + trim (200 B) | `d075ff8a3b3372f5b5659b444827e0219785015d716bc0496def60f1c279b562` | same |
| normalized, no trim (202 B) | `afb056d01e4ebea029628aac8bd6e54bbf22ea3ed26c9b2b80f3470dde0bb43a` | same |

The quote `Feature A is in preview; we're slowly rolling out Feature B in beta.` occurs once in the
normalized text and 0 times raw-literally.

Expected results:
- A normalizer selftest pinned to `d075ff8a…` **fails** for the no-trim mutant.
- `a.html` and `b.html` agree on the normalized digest and differ on the raw digest. This is the
  volatile control.
- A `raw-literal-v1` locate of the quote fails.

L1 must recompute these values with its own normalizer before pinning.

**FX-2, volatile admit control (census).** Two TSV rows with distinct ids and the same URL, both
`decoded-http-body-volatile-v1`, with different raw sha256 and identical normalized sha256.
Expected `SOURCES_CENSUS: CLEAN`, exit 0. It kills the mutant that drops the `:284` guard.

**FX-3, volatile normalized disagreement (census).** Same as FX-2, but the normalized digests
differ. Expected `FINDING SC_FETCH id=<second> same-url-normalized-disagreement url=…`, exit 1.

**FX-4, S020-shape multi-assertion (decision fixture).** Two rows for one id from one capture, with
identical raw and normalized digests but different quote and location. Today the expected result is
`FINDING SC_FETCH id=… duplicate-provenance`, exit 1. That result **is the F3 gap**: it should stay
red only if L1 documents that S020's EPM half is uncovered.

SourceS006's FC2-A to FC2-D (anchor, transport, superseding row unpinned, content change) are not
duplicated here.

## Messages sent

Two short notes went to `agent://KagiR23`: F1 together with F2, then F4.

## Limits / non-actions

- **Not executed:** `sources-census.sh`, its selftest, `feature-claims.py`, `closure-dispositions.py`
  and every ledger row. Every digest above was computed by my own Python 3.14.8 over bytes I fetched
  myself.
- **Snapshot status:** the *[WT]* findings describe uncommitted files that changed while I was
  reading them.
- **Unrecoverable:** the representation behind `55bf23fe…` and `39a869df…`.
- **Not reopened or audited:** S006, S007 and S017–S019 pages, except S006's quotes on this shared
  URL.
- **Not exercised:** no account, no entitlement, and no live availability check.
- **Writes:** besides this report, scratch fetches and fixtures went to `/tmp/kagi-r23-S020/`
  (7 HTML bodies, 1 gzip body, 5 header files, 2 category pages, 2 fixture files). They are deleted
  at the end of this seat. No production, registry, stamp, ledger or lane state was modified.
- **Tools:** none installed or updated. I used system `curl 8.23.0` and `python3 3.14.8`.

## Report trailer

Relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`: report written at
`.ufo/waves/round-23/parent-build/SourceS020.md`.

- Read revision: `d218603b74099ddca0bd8f869516fc41db0979bf`.
- S020 row-line sha256: `f1c9b657…640dab`.
- Page accessed: 2026-10-21.
