# SourceS006 — provenance audit of SOURCES row S006 (round 23)

Seat: `SourceS006`, scout, leaf (no dispatch), read-only. Axes: calibration,
freshness, operability. No production edit, no gate/ledger/handler execution,
no account/workflow/SDK/vault probe. This report is advisory only; it carries no
admission or re-curation authority.

All quote lines below are from
`https://1password.com/blog/1password-credential-broker-public-preview`,
published 2026-07-28 (`article:published_time`), reopened by this seat
2026-10-21; the heading named in each row is where the text was found.

## Exact read revision

- `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf`; `git status --porcelain`
  showed only untracked `.ufo/waves/round-23/`.
- `corpus/SOURCES.md` sha256 `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`,
  118 lines, 22,843 B (matches `corpus/stamps.tsv:61`). Registry = **23 rows**
  (A=21, C=2; mined=21, queued=1, rejected=1) — independently counted, and equal
  to the `R21-02` expected counts at `corpus/claim-ledger.tsv:52`.
- `corpus/claim-ledger.tsv` = **43** command rows, so the frozen 66-item
  population (43 + 23) holds at this revision.
- S006 = `corpus/SOURCES.md:12`, 877 B (863 chars, UTF-8). Full-line sha256
  `c417c1511c3abdfa6be26bc198d443e475ddaba2404c552766b4ab2a22562eaa`, which
  reproduces the `immutable_original_full_line_sha256.S006` value in
  `.ufo/waves/round-22/registry-census-details.json`. This is a **reproducible
  row pin**; the page-level hashes below are not.
- `corpus/knowledge/onepassword-machine-credentials.md` (E1) sha256
  `8380b35927e96b89fc0da7832516ecaff2a8e097660b47c599f560344709cf48`
  (matches `stamps.tsv:26`); `corpus/knowledge/feature-bound-credential-review.md`
  (FBCR) `53a24710…2b42d8` (matches `stamps.tsv:20`);
  `corpus/feature-claims.json` `a66acbfb…38449b`, whose `features` canonical
  digest equals `PINNED_FEATURES_SHA256` (`corpus/feature-claims.py:63`,
  `154997ff…b5555`).

## Reopen: observed transport and digests

Method: `curl 8.23.0 -sS -L --max-time 60 -A 'Mozilla/5.0 … audit-readonly/1.0'`,
HTML only, no JavaScript, no cookies, no auth. `HTTP/2 200`, `content-type:
text/html; charset=utf-8`, `cf-cache-status: DYNAMIC`, `x-vercel-cache: HIT`,
**no `ETag`, no `Last-Modified`**. `article:published_time` and
`article:modified_time` are both `2026-07-28T00:00:00.000Z`; byline “July 28, 2026”;
single `<h1>`, ten `<h2>`.

Measured, 2026-10-21:

| measurement | result |
|---|---|
| raw-HTML GETs (two batches) | 10 responses, **10 distinct sha256** |
| response size | 190,261 B on all five measured responses |
| byte delta between responses | 44 bytes at offsets 68,525–68,568, inside a `/cdn-cgi/l/email-protection#<hex>` token |
| raw HTML normalized only for that token | `4f9aa03f1e9fff3aa4aed4ff7d56b10f0896b62d5b617f9c970fd8d27da92246`, 5/5 identical |
| article-text pin (method below) | `bbfbd7ce87eeffd15938dd1074911c9e6db120729a105c6be141f372bb4c6c36`, 7,547 chars, **7/7 identical** |

Article-text extractor used: slice from the first `<h1` through the byte before
the first `Continue Reading`; strip `<script>`/`<style>`; replace tags with a
space; HTML-unescape; collapse `\s+` to one space; trim; hash UTF-8. No
JavaScript was executed. This reproduces, independently, the content pin
proposed in `.ufo/waves/round-22/build/Source06.md` — the first reproduction of
that value by another seat.

## Row S006 recheck (scope / anchor / teaches / status / tier)

Observed row: `docs`, tier `A`, scope “Credential Broker public-preview status
and integration-key versus standing Service Account access distinction”, anchors
`§How 1Password Credential Broker works` and `§Try 1Password Credential Broker
today`, opened 2026-10-19, recheck `on-release`, status `mined`, used-by E1.
Both H2 texts exist verbatim in the opened page.

| row element | public observation (same URL/date; heading named) | verdict |
|---|---|---|
| status quote | “unlike a service account token that carries standing access, the organization-wide integration key is an encryption key” — §How 1Password Credential Broker works, one occurrence | **supported** |
| second quote | “is in public preview” — §Try 1Password Credential Broker today, one occurrence, inside “1Password Credential Broker is in public preview, and available now for all 1Password EPM Business customers.” | **supported** |
| publication date | meta both dates 2026-07-28; byline “July 28, 2026” | **supported** |
| tier A, kind docs | primary vendor announcement for its own announcement-time status; not a community row; no inflation | **supported as scoped** |
| status `mined` | historical curation record; not re-curated here; rejected S008 and queued S005 untouched | **unchanged, correct disposition** |
| scope limits | row does not claim eligibility or “no standing vault access”; the page does carry both (lede; §How) | **no overreach in this row** |

Adjacent wording facts relevant to consumers of this source:
`decrypt` occurs **0** times (case-insensitive). The page says of a leaked
integration key: “They'd also need a valid OIDC token from GitHub, tied to a
specific repo, branch, and workflow, that expires when the job ends.” (§How;
ASCII apostrophe, 23 words). Therefore E1’s active item-4 clause “says a valid
OIDC identity is also needed to decrypt [S006, S007]”
(`corpus/knowledge/onepassword-machine-credentials.md:16`) is an inference, not
an S006 sentence; E1’s appended erratum says so at `:88`, but the active body
sentence still carries the inline attribution. The row itself is not defective;
the consumer sentence is mis-attributed until read with the erratum. Also note
the exact-string consequence: “would also need a valid OIDC token” is **not** a
substring of the page; “They'd also need…” is.

## Historical bytes vs current semantic support vs deployed proof

- **Historical bytes.** `39a869df…e514c1f` (row `:12`, observed 2026-10-19) and
  `55bf23fe…fe3eda` (`corpus/feature-claims.json:176`, S020, observed 2026-10-20)
  are unreproducible: neither equals any of today’s 10 raw responses, and no
  single response is reproducible even against another response from the same
  minute. This matches the registry’s own bound at `corpus/SOURCES.md:80-81`
  (“Original Fetch hashes remain historical point observations with undocumented
  representation”) and is **not** evidence of content drift.
- **Current semantic support.** All row quotes, both anchors, the H1 and the
  publication date are present on 2026-10-21; the article-text pin reproduces
  7/7. So the row’s teaching is currently supported even though its recorded
  fetch digest cannot be re-fetched.
- **Supersession.** S020 (`corpus/SOURCES.md:26`) explicitly says “supersedes
  S006 — EPM Business eligibility applies; the announcement explicitly
  distinguishes Actions public preview from custom-OIDC beta rollout.” The page
  carries that split: “Alongside GitHub Actions support in public preview, we're
  slowly rolling out a new capability in beta: custom OIDC workflows.” (§New in
  this release: Custom OIDC workflows). S020 does not rewrite S006’s cells, and
  S006’s quotes remain accurate — consistent with `corpus/SOURCES.md:58-59` and
  `:77-78`. But S020’s **row** carries no quote and no digest; both exist only in
  `feature-claims.json:173-200` (including `prior_registry_sha256: 39a869df…`).
  The superseding artifact is therefore weaker than the row it supersedes.
- **Deployed-product proof.** None. This is a 2026-07-28 vendor announcement;
  it establishes the vendor’s announcement-time assertion, not live
  availability, entitlement, or runtime behavior. No account, workflow, SDK or
  vault was exercised. The page has no update clock (`modified_time` =
  `published_time`), so freshness cannot be read from it.

## used-by pointer follow (this row only)

`S006.used-by` = `corpus/knowledge/onepassword-machine-credentials.md`.
E1’s header `source:` line (`:2`) cites S006 with the row’s two anchors, and its
`recheck:` (`:4`) names “on-release for S006–S007” — reciprocity holds
(`SC_USEDBY_NOCITE`-style check). E1 item 4 (`:16`), the round-21 erratum
(`:34`), and the round-22 erratum (`:37`) consume it; `corpus/README.md:76`
indexes E1 as “S001–S007”.

Gap in the pointer chain, scoped to S006: E1’s header cites only
S001–S004, S006, S007, while its body erratum cites S017–S020 (`:41-63`). The
active corrected reading lives in FBCR (`corpus/README.md:124`), whose `source:`
line cites S020 but **not** S006. A checker that follows only the header
`source:` fields (all `sources-census.sh` does) terminates at E1 and cannot see
that S006’s current admitted reading is S020 → FBCR. `R21-02` CLEAN therefore
proves reciprocity and counts, not current-reading disposition. There is no
machine-readable supersession edge: S006 stays `mined`, and the only
“supersedes S006” token is prose inside S020’s `teaches` cell.

## C2 source-fetch provenance — exact expectations

Proposed record per source capture (one record per source row capture, plus one
per catalog/JSON capture):

1. **Representation (required; no digest without it).** Enum + accessor:
   `raw-html` (`curl -sSL`, UA recorded, no cookies/auth; record status,
   `content-type`, byte length, `cf-cache-status`, `ETag`/`Last-Modified` if any);
   `article-text` (raw body → extractor below); `vendor-md` (only where the
   vendor serves a markdown alternate, with that URL named). “Fetch sha256”
   without a representation is a defect, not a pin.
2. **Normalization (named, minimal).** `cf-email-protection`:
   `/cdn-cgi/l/email-protection#[0-9a-fA-F]+` → fixed literal, applied to
   `raw-html` only. Any other normalization must be named in the record; an
   unlisted normalization makes the digest unverifiable.
3. **Anchor (resolved, not asserted).** `page-title-H1` = exact `<h1>` text;
   `section:<exact H2/H3 text>` resolved only inside article scope
   (`<h1>` → before the `Continue Reading` sentinel); `introduction` = the
   article lede after the byline and before the first article H2. Quote text
   must be an **exact substring** of the resolved anchor span. No Unicode,
   case, or punctuation folding unless declared on both sides.
4. **Hash.** sha256 over exactly the representation + normalization + anchor
   extractor output, with extractor identity/version; `observed_at` UTC
   ISO-8601; `volatility` ∈ {`stable`, `normalized-stable`,
   `per-response-variable`}.
5. **Registry linkage.** `prior_registry_sha256` on every re-registration of a
   URL (present for S019/S020, absent for the S006 row itself, which predates
   the convention); row-level immutable pin = sha256 of the full row line
   (already implemented by the round-22 census map and reproduced above).
6. **Checker semantics.** Digest equality is admissible only when
   representation + normalization + extractor match; otherwise the result is
   `UNVERIFIED-REPRESENTATION`, never `DRIFT`. Raw digests tagged
   `per-response-variable` are excluded from drift verdicts. Quote containment
   and a declared content pin are the content checks; no digest establishes
   deployed behavior. Supersession must resolve through a structured edge to a
   terminal active row that itself carries a pinned quote.

### One real contradiction

`corpus/SOURCES.md:12` presents `39a869df…` as a `Fetch sha256` for the blog
URL, and `corpus/feature-claims.json:176` presents `55bf23fe…` for the same URL;
neither is reproducible. Measured today: 10/10 raw GETs distinct, constant
190,261 B, the only delta being a per-response Cloudflare
`/cdn-cgi/l/email-protection#<hex>` token. A checker that treats the registered
value as a re-fetchable pin must report false drift for **both** registered
digests although the article text, anchors and date are unchanged and
supported. The fix is the representation/volatility labeling above (label both
values historical raw observations; pin `bbfbd7ce…` as the article-text value),
not a restamp.

### Concrete synthetic minimal failing fixtures for L1 (proposed, not run)

- **FC2-A (anchor).** Fixture row whose quote “available for all Enterprise
  Password Manager Business customers” is anchored
  `§Try 1Password Credential Broker today` while the text occurs only in the
  lede. This is the real pre-fix `S006-eligible` state (today
  `feature-claims.json:32` correctly says `introduction`). Expected:
  `FINDING SOURCE_QUOTE_ANCHOR` and exit 1.
- **FC2-B (transport).** Two captures identical after the named
  `cf-email-protection` normalization but differing before it. Expected:
  `UNVERIFIED-REPRESENTATION`, drift `unknown`, exit 0 with a warning; never
  `DRIFT`.
- **FC2-C (supersession).** Row A `mined`, row B saying “supersedes A” with no
  quote and no digest (the current S020 row shape). Expected:
  `FINDING SUPERSEDING_ROW_UNPINNED`, exit 1 (warning acceptable only if L1
  documents why).
- **FC2-D (content change).** Article-text pin differs after extraction.
  Expected: `DRIFT`, exit 1.

Minimum L1 set for this row: **A and B**; C is required if S020 is claimed as a
supersession pointer.

### Anchor-attribution hazard also worth encoding

On the fetched page the lede sentence sits after the nav heading
“Related Categories”: H1 at 16,166 B, byline at 19,740 B, “Related Categories”
at 22,392 B, lede at 25,698 B, first content H2 “How 1Password Credential Broker
works” at 26,021 B, `Continue Reading` at 38,433 B. A checker that resolves
“nearest preceding H2” would attribute the eligibility sentence to a nav
heading, not the introduction. The expectation in item 3 above (“article scope”
and an explicit `introduction` definition) is what prevents that false
attribution.

## Limits / non-actions

- Only S006’s URL was opened. S007, S017–S019 were **not** reopened; S020 was
  checked only as local row/JSON text for the supersession edge.
- Raw digest counts are point observations at 2026-10-21 with the UA above; the
  2026-10-19 capture environment is unrecorded and was not reconstructed.
- No gate, ledger command, handler, `op`, vault or host probe was executed; no
  files were edited; no installs or package transactions were made (curl 8.23.0
  was already present and is the only tool used).
- This report does not re-curate S006, S020, S005 or S008, and is not evidence
  for admission.

## Report trailer

Relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`: report written at
`.ufo/waves/round-23/parent-build/SourceS006.md`. Read revision
`d218603b74099ddca0bd8f869516fc41db0979bf`; S006 row line sha
`c417c151…62eaa`; page accessed 2026-10-21. No production file, registry row,
stamp, ledger, or lane state was modified.
