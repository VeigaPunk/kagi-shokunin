# SourceS018 — S018 provenance audit (round 23, attempt 1)

Seat: `SourceS018` (reviewer, leaf, read-only). Axes: **calibration**, **freshness**,
**operability**. Scope: row S018 only, plus the used-by pointers that consume it and the
one vendor page that conflicts with its status label. No other source row was audited.
No behavioral gate was run (contract), no account/vault/SDK/workflow was exercised,
no installs, no production write beyond this file.

- Observed revision: git `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf`, the
  `plans/round-23.md:3` base. Working tree `corpus/SOURCES.md` is byte-identical to
  `git show HEAD:corpus/SOURCES.md` (sha256 `a5e1c13e…cc30`, 118 lines, 22,843 B;
  matches `corpus/stamps.tsv:61`).
- Row identity: `corpus/SOURCES.md:24`, line sha256
  `d90338be21feff283ce72f1715670a880e97c8ba134a2680334d7ca6f7ce0390`, 569 B
  **including the trailing LF**. The same line hash holds at `8ada17a`, `4be5da3`,
  `254d632` and `HEAD`; the row text did not move into round 23.
- Method: the exact registered URL was opened with the `read` web reader and with
  `curl` (public GET only, 2026-10-21 03:43–03:47 UTC); anchors were located in both
  the markdown alternate and raw HTML; local pointers were followed; the vendor
  product page was opened only to test the status label. No gate, no ledger, no
  claim row was executed or audited.

## 1. Reopen record (2026-10-21)

| field | observed |
|---|---|
| URL as registered (`SOURCES.md:24`) | `https://www.1password.dev/brokered-access/custom-workflow/` |
| Redirect | `HTTP/2 308` → `/brokered-access/custom-workflow` (no trailing slash) |
| No-redirect body | 15 B `Redirecting...`, `content-type: text/plain`, sha256 `7c040f86…d76c2` |
| Final 200 | `text/html; charset=utf-8`; `cf-cache-status: HIT`; `age: 10749`; weak `etag: W/"qlxr8hi2xirhxx"`; **no `Last-Modified` on HTML**; `date: Wed, 21 Oct 2026 03:43:30 GMT` |
| Raw HTML (`Accept: text/html`, `Accept-Encoding: identity`, `-L`) | 1,283,173 B; sha256 `a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450` |
| Same-day repeat | 03:43:30 and 03:43:41 GETs byte-identical (`cmp` equal) |
| Client variants | default curl, `--compressed`, browser UA+Accept, `Accept: text/html` → all the same `a0617582…`, 1,283,173 B |
| Content negotiation | `Accept: text/markdown` on the **same URL** returns the Markdown alternate: 6,088 B, sha256 `5da83bb665fc575b6c7d27c3b31ab2e1be4e2feded35fc119e1185467311016e`; two GETs identical |
| Gzip wire bytes | 257,923 B, sha256 `c93abb93…e51936d`; gunzip → `a0617582…`, 1,283,173 B (wire ≠ entity) |
| Embedded metadata | `meta generator=Mintlify`; JSON-LD `dateModified: 2026-08-17T22:36:47.822Z`; no displayed version or date |
| Markdown alternate headers | `date` is per-response; one response carried `last-modified: Wed, 21 Oct 2026 03:43:20 GMT` (request time), later responses carried none — not a content date |

Anchor text located (normalized: tags stripped, whitespace collapsed):

| anchor in the row | observed public text (≤25 words) | location |
|---|---|---|
| Page title / status | “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | `<h1 id="page-title">`; `<title>` is the same plus ` - 1Password Developer`; a “Beta” badge follows the description |
| introduction | “If an administrator has connected an OIDC provider to your 1Password Business account” | introduction paragraph, after the “Copy page” control |
| Step 1 | “make sure you have the latest beta release of the 1Password desktop app” | “Step 1: Set up an Environment” |
| Step 3 note | “1Password Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | `[!NOTE]` under “Step 3: Use your Environment in your workflow” |

## 2. Scoped fields rechecked

| field / assertion (`SOURCES.md:24`) | observation | verdict |
|---|---|---|
| `teaches`: public beta | H1, `<title>`, JSON-LD `name` all say `(public beta)`; visible “Beta” badge | **supported** |
| `teaches`: connected OIDC provider in Business | introduction conditions use on an administrator having connected an OIDC provider to the 1Password **Business** account | **supported** (a conditional prerequisite, not a plan-mapping proof) |
| `teaches`: beta desktop app | Step 1 says “latest beta release of the 1Password desktop app” | **supported** as a setup prerequisite |
| `teaches`: only JavaScript SDK | Step 3 note says only the JavaScript SDK is supported “at this time” | **supported** |
| `anchor`: “Page title, introduction, Step 1, Step 3 note; unversioned live docs opened 2026-10-20” | all four locations exist; no displayed version/date. Machine-readable `dateModified` does exist (2026-08-17) | **supported**; precision notes L1/L2 below |
| `status: mined` | `used-by` files exist and each carries `S018` on its `source:` line (`corpus/lessons/round-22.md:1,18`; `corpus/knowledge/feature-bound-credential-review.md:1,17`) | **supported** |
| `tier: A` | vendor primary feature documentation, single feature scope; QA1 (`corpus/QUALITY.md:20`) asks tier A “for that scope” | **consistent**; not a truth claim (see the vendor conflict) |
| `opened 2026-10-20` | recorded by round-22 seats (`ReopenSource18.md:30`, `build/Source07.md:35`); not independently provable from the page | **supported historically** |
| explicit supersession | only S019→S007, S020→S006, S022→S012, S023→S013 carry `supersedes` (`SOURCES.md:25,26,28,29`); none names S018. S019 supersedes the *guide's uniform-status reading*, which is why S018 exists; it does not supersede S018 | **no superseding row** |
| `used-by` completeness | two listed consumers cite it; a third real consumer cites `[S018]` in body text but is unregistered | **M2** |

Deployed-product proof: **none**. The page is documentation; no account, OIDC
provider, workflow, desktop app or SDK was exercised. The page's own JS example is
not runtime evidence, and its only version marker is a comment (“SDK 0.5.0-beta.1
only accepts unpadded integration keys.”) — not a supported-version matrix.

## 3. Historical bytes vs current semantic support

| byte domain | size | sha256 | when |
|---|---|---|---|
| raw HTML, recorded pin | 1,282,825 B | `d0890c11edaa85d3ec68680d8d9bc867db502229fb3c815ee6b1b62ac62b76e5` | 2026-10-20 (`corpus/feature-claims.json:123`; `build/Source07.md:35`; reproduced by `ReopenSource18.md:30` and four other round-22 seats) |
| raw HTML, this reopen | 1,283,173 B | `a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450` | 2026-10-21 03:43Z |
| Markdown alternate | 6,088 B | `5da83bb665fc575b6c7d27c3b31ab2e1be4e2feded35fc119e1185467311016e` | 2026-10-21 03:43Z |
| redirect stub (no `-L`) | 15 B | `7c040f86…d76c2` | 2026-10-21 03:44Z |
| gzip wire | 257,923 B | `c93abb93…e51936d` | 2026-10-21 03:44Z |

The recorded raw-HTML pin **does not reproduce**: the page grew by 348 B between the
round-22 acquisition and this reopen. Two same-day GETs are byte-identical and four
client/encoding variants agree, so this is not request-to-request jitter on this
host. The page's JSON-LD `dateModified` is still `2026-08-17T22:36:47.822Z`, the same
clock recorded in `build/Source07.md:150`, and every cited anchor is present
unchanged — so current **semantic support holds** while byte identity does not.
Whether the +348 B is a docs deployment, a different CDN generation, or a difference
in the round-22 client is **unresolved**: no stored prior byte copy exists in the
repo (searched `.ufo` for a 1,282,825 B file; none), so the delta cannot be
localized. [INFERENCE] Given the unchanged `dateModified`, the delta is more likely
generated/navigational bytes than an editorial status change; that inference is not
a finding.

This is exactly why `plans/round-23.md:26-28`'s “point attestations … never
content-drift pins” wording is right — and why the round-22 value must not be
copied into `source-fetches.tsv` as the expected S018 digest.

## 4. Findings by severity

**M1 (medium, freshness/provenance).** The S018 digest is a one-day-old point
observation, not a reproducible pin. `corpus/feature-claims.json:123` records
`d0890c11…`; today's identical raw-HTML GET yields `a0617582…` (1,283,173 B). The
round-22 seats' “reproduces exactly” statement (`ReopenSource18.md:30`) was true for
their fetch and false for this one. No recorded representation/client/final-URL
accompanies the value, so a checker cannot tell a representation mismatch from a
byte change. *Fix:* fetch fresh for the C2 row; keep `d0890c11…` only under an
explicit `historical` marker with its 2026-10-20 date; record `final_url`,
`content_type`, `Accept`, `Accept-Encoding`, UA, HTTP status and byte count beside
every digest. Do not gate on digest equality against the r22 value.

**M2 (medium, pointer integrity).** A real consumer of S018 is invisible to the
registry. `corpus/knowledge/onepassword-machine-credentials.md:42,52,55` cites
`[S018]` in its round-22 erratum, but `S018.used-by` lists only
`corpus/lessons/round-22.md` and the review file, and that entry's `source:` line
(line 2) cites S001–S004/S006/S007 without S018. The census checks only the
`source:` field: `sources-census.sh:199-201` requires each used-by file's
`src_field` to contain the id, and `:229` requires each source-line id's row to list
that entry. Body citations are checked by neither. Consequence: C1/C2 pointer
enumeration undercounts S018's consumers, and a status change would not flag this
entry. *Fix (L1 curation, two-sided):* add the entry to `S018.used-by` **and** add
S018 to that entry's `source:` line in the same change; adding one side alone trips
`SC_USEDBY_NOCITE` or `SC_ENTRY_CITE`. The same pattern appears likely for
S017/S019/S020/S021; not audited here.

**M3 (medium, C2 schema coverage).** A single “located ≤25-word quote” cannot attest
S018's `teaches`, which conjoins four page facts (status, eligibility, app channel,
SDK). One quote covers at most one conjunct; a gate that admits on one quote would
leave the other three unverified — the C2 analogue of claim-count assurance. *Fix:*
allow multiple quote rows per source (`quote_id`, `anchor`, `quote`,
`quote_sha256`, normalization) and have `SC_FETCH` require the row's named anchors
to be covered, or document explicitly that one quote is a floor, not coverage.

**M4 (medium, C2 offline check honesty).** “Location present” is not verifiable by an
offline `SC_FETCH` unless the record carries a normalized excerpt or its hash;
otherwise the check degenerates to “non-empty anchor field” and is shape assurance,
not provenance. This matters for S018 because two quotes are **not byte-literal in
raw HTML**: `grep -cF` of the introduction and Step 3 note in `page.html` returns 0
(inline links split the sentence); both appear only after tag-stripping/whitespace
normalization (“…JavaScript SDK at this time.”). *Fix:* store a deterministic
normalization rule plus `quote_sha256` over the normalized quote; the gate can
recompute from the stored excerpt, and a periodic (non-gate) re-fetch checks the
live page.

**L1 (low, anchor precision).** The row says “Page title”; `<title>` is H1 plus
` - 1Password Developer`. Name `h1#page-title` in the C2 anchor so a prefix quote
cannot be matched against a longer `<title>`. Consider recording JSON-LD
`dateModified` as machine metadata; keep “unversioned” meaning *no displayed*
version, not *no metadata*.

**L2 (low, operability).** `recheck: on-release` has no document-change trigger. The
page's bytes moved overnight with no visible release and no `dateModified` change, so
a release-only clock cannot detect a status/eligibility edit. *Fix:* widen to
“Credential Broker release **or** feature-page H1/Step text or `dateModified`
change”, and state the C2 re-fetch cadence.

## 5. Planned C2 provenance — exact expectations for S018

The `plans/round-23.md:20-28` record must carry, per source:

1. **Identity:** `S018`; registered URL exactly as `SOURCES.md:24`
   (`…/custom-workflow/`); row-line sha256 with its domain stated
   (`d90338be…0390`, 569 B **including** LF).
2. **Representation:** an explicit token (`raw-html-identity` or
   `markdown-alternate`) plus the request that produced it — `Accept`,
   `Accept-Encoding`, UA, redirects followed. This is mandatory here: the same URL
   returns HTML (1,283,173 B) or Markdown (6,088 B) depending on `Accept`, and a
   no-redirect GET returns 15 B.
3. **URL fields:** `url` (registered) **and** `final_url` (post-308, no trailing
   slash). “URL equality” against the registered string alone is ambiguous about
   which bytes the digest covers.
4. **Hash:** 64-hex sha256 over the decoded entity body of the declared
   representation; `byte_count` of those bytes; `http_status`; never hash gzip wire
   bytes or a redirect stub.
5. **Anchor + quote:** anchor id (`h1#page-title`, Step 1 heading, Step 3 note),
   quote ≤25 words, normalization stated, `quote_sha256` over the normalized quote.
   Quote matching must be normalized-substring on word boundaries; the raw HTML is
   not byte-literal.
6. **Date + non-claims:** UTC fetch timestamp; “point attestation of the fetched
   representation, not a drift pin, not deployed-product proof”.
7. **Offline gate checks that are honest:** row id exists and is `mined`; registered
   URL exact; `final_url` path equals the registered path with the trailing slash
   normalized; representation in the enum; digest shape; positive byte count;
   quote word count ≤25; anchor non-empty; `quote_sha256` shape; no duplicate
   `quote_id`; **no live fetch and no equality check against any historical
   digest**.

**One real contradiction (hash expectation).** The round-22 pin `d0890c11…`
(1,282,825 B) is presented as reproduced by five seats; the identical request on
2026-10-21 returns `a0617582…` (1,283,173 B) with the same `dateModified` and the
same anchors. The C2 record must therefore treat the historical digest as a
different byte domain/date, not as the expected value.

**One real contradiction (public text).** The feature page H1 says
“(public beta)” (opened 2026-10-21, `https://www.1password.dev/brokered-access/custom-workflow/`),
while the vendor product FAQ says “Credential Broker is currently in public preview
for all Enterprise Password Manager customers, starting with GitHub Actions, and
custom OIDC configurations.” (`Credential Broker FAQs`,
`https://1password.com/product/credential-broker`, undated, opened 2026-10-21; 21
words). The S018 page's own OG-image URL also carries the division label
`Credential Broker (public preview)`. The corpus rule (`SOURCES.md:99-101`) resolves
the *corpus* reading by the feature page's H1; it does not reconcile the vendor's
labels. C2 must bind status only to the H1 anchor and should include a fixture
where “public preview” appears in navigation/metadata but not in the H1.

## 6. Residual risk and verification gaps

- No gate, census, `feature-claims.py`, or ledger run (contract); tier/status/used-by
  compliance is read statically from the row and `sources-census.sh` logic, not
  observed as a passing run.
- The +348 B delta cannot be attributed: no stored 2026-10-20 byte copy exists, and
  only one host/CDN edge (`gru1`) and one network path were exercised. An archive
  (Wayback/Software Heritage) check was not made.
- Markdown-alternate stability is proven only within this session (2/2), not across
  days; its `Last-Modified` is request-time and unusable as a content date.
- No deployed-product proof: no account, OIDC provider, workflow, desktop app, SDK or
  vault was touched. The page's JS example and its `0.5.0-beta.1` comment are not a
  support matrix.
- One discarded fetch attempt raced a parallel temp-dir setup and wrote a partial
  body with `curl` exit 1; it is not used as evidence and is not a page property. It
  does illustrate the need to record HTTP status, exit status and byte count together.
- Untracked round-23 artifacts (`plans/round-23.md`, `corpus/closure-dispositions.*`,
  `corpus/__pycache__/`) exist in the tree; none was audited or modified.
- Tool installs/updates: none.

**Verdict:** row S018 is **supported** at every scoped field on 2026-10-21: public
beta, Business account with a connected OIDC provider, latest beta desktop app, and
JavaScript SDK only. No superseding row exists; `mined`/tier A are consistent. The
defects are pointer coverage (M2) and provenance mechanics (M1, M3, M4), not the
row's semantic claim. This report is advisory evidence, not a curation or admission
decision.

**Report: `.ufo/waves/round-23/parent-build/SourceS018.md`**
