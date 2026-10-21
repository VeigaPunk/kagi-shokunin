# SourceS005 — S005 provenance audit (round 23, attempt 1)

Seat: reviewer, leaf (no dispatch), **read-only**. Axes: calibration, freshness,
operability. Assigned item: exactly one source row, S005. No judgment or
admission authority. Production root for every citation:
`/home/vgpnk/Projects/shokunin/kagi-shokunin`.

## 0. Exact observed revision

| item | observed 2026-10-21 |
|---|---|
| first registry read | `corpus/SOURCES.md` sha256 `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`, 118 lines, 22,843 bytes, 23 rows (mined 21, queued 1, rejected 1) |
| final registry read (03:51:56Z) | `corpus/SOURCES.md` sha256 `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29`, 121 lines, 24,995 bytes, 26 rows (mined 24, queued 1, rejected 1) |
| **S005 row** | line 11, 819 bytes incl. LF, sha256 `1ba27291504fc63beef8e6cdb7e3ade09cc315c6ff3bd9f0566511a55b9ce274`; identical in both reads and identical to the round-22 frozen-before copy (`c2cab35`) and to `ReopenSource05`'s recorded hash |
| plan base (declared) | `plans/round-23.md:3` = `d218603b74099ddca0bd8f869516fc41db0979bf`; I verified S005's row bytes, not the commit identity |
| concurrent artifacts (not audited; **flux**) | `corpus/source-fetches.tsv` 10 rows S017–S026, no S005 row; `corpus/sources-census.sh` SC_FETCH doc block at line 56. Both files were edited repeatedly during this audit (census observed `7142f484…` → `bf56b1a4…` → `ece39d32…` → `4e60d5e0…`; table `c77520f8…` → `e2f40132…` → `ccc9ae6e…`). Citations below use finding codes/field names; the quoted census line numbers are from the last snapshot I read and may shift again. |

S024–S026 and the provenance/census material changed **during** this audit.
Line numbers below are from the last registry snapshot (03:51:56Z) and the last
census/table snapshot I read; the S005 row itself did not move.

## 1. Public reopen — S005 (opened successfully)

URL https://1password.com/product/credential-broker, HTTP 200, no redirect
(final URL = canonical URL), opened twice with a browser UA and twice with the
provenance table's declared profile
`kagi-shokunin-round23/1.0 (documentation verification)`.

| checked | observation |
|---|---|
| H1 | “Machine and AI agent credential runtime access” — matches the row's source title |
| anchor | `<h3>` “The platform identifies the job”, under H2 “Keep credentials out of pipelines”; present in rendered DOM and in embedded CMS JSON (`redesignHeading`, tag `h3`) |
| quote (20 words) | “Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for.” — verbatim in decoded/normalized text |
| displayed version/date | none: no date-like token and no “last updated/modified” in normalized text; the row's wording is accurate |

**Verdict: the scoped teaching is SUPPORTED at the exact anchor.** The row's
paraphrase (“identity is checked against policy before approved credentials are
delivered”) is faithful. No semantic change was observed relative to the
round-22 reopen.

Encoding detail for any quote checker: the rendered `<p>` encodes the
apostrophe as `&#x27;`; the only plain-apostrophe occurrence in raw bytes is the
embedded CMS JSON body. A raw-byte substring check is therefore
representation-dependent; a decoded/normalized check is robust.

## 2. Status, tier, and supersession

- **tier C — supported.** The page is product positioning. It carries no
  configuration mechanics; `corpus/lessons/round-21.md:48` already rejected it as
  mechanism support and kept it as a tier-C lead. `queued` plus tier C is the
  honest calibration.
- **status `queued` — supported.** S005 is the sole `queued` row in both
  snapshots (`queued=1`). `used-by` is `—`. No `corpus/knowledge/*` entry or
  `source:` header cites S005: `grep -rn '^source:.*S005' corpus/` returns
  nothing. The only local mentions are round-21 lesson decision/row tables
  (`corpus/lessons/round-21.md:48,59`) and the verifier spot-check, which are
  records, not entry pointers. `SC_ENTRY_CITE` applies to entries citing
  non-mined rows; a queued row with `used-by —` is contract-conformant.
- **explicitly superseding row — none.** S019/S020 supersede S007/S006
  (`corpus/SOURCES.md:59`; the “Supersession scope (round 22)” paragraph at
  `:75` confines that scope to the guide's uniform-status reading) and
  S022/S023 supersede S012/S013 (rows at `:28-29`). No row claims to supersede
  S005, and the supersession paragraph does not mention it.
- **Live semantic contradiction (not supersession).** S005's FAQ, under “Is
  1Password Credential Broker generally available?” (undated page, opened
  2026-10-21, https://1password.com/product/credential-broker), says:
  “Not yet. Credential Broker is currently in public preview for all Enterprise
  Password Manager customers, starting with GitHub Actions, and custom OIDC
  configurations.” (23 words). That lumps custom OIDC into public preview.
  S018's feature-page title records “public beta” for custom workflows and S020's
  §New in this release records the dated split (both captured 2026-10-21 in
  `corpus/source-fetches.tsv`; I did not reopen those two pages). The plan label
  also differs: S005 says “Enterprise Password Manager customers”, S020 says
  “Enterprise Password Manager Business customers”.
  Because S005 is queued and unused, no active claim inherits this; the corpus's
  feature-page-H1 rule resolves it. **If L1 ever promotes S005, the row needs an
  explicit “not per-feature status or plan-eligibility authority” scope clause,
  and the FAQ sentence must not be cited for status.** This report is not
  admission.

## 3. Historical bytes versus current semantic support

The stored in-row digest `f7ba8254b1109111c42429eb896b9ba767a7320c20c5a9c5fc6f1d993bdffd2f`
matches none of today's measured representations (raw decoded body under either
profile, full rendered text, or main-region text). Its representation was never
recorded. **This is unresolved, not drift**: the quote and anchor are still
present, so the semantic claim survives even though the byte pin cannot be
reproduced.

Page-level evidence consistent with continuity: embedded Contentful metadata
shows the quote-bearing `contentCardGrid` entry at `publishedVersion 21`,
`updatedAt 2026-04-16T21:17:57Z`, and `heroCentered` at `publishedVersion 3`,
`updatedAt 2026-04-29T20:34:44Z`. These are CMS payload fields, not displayed
dates, not release notes, and not deployment proof; they simply predate the
row's 2026-10-19 open.

## 4. Transport / raw-HTML digest volatility (measured)

| capture | request profile | decoded body | body sha256 | rendered-text sha256 |
|---|---|---|---|---|
| #1 | browser UA | 196,082 B | `2583cb4c90e7708280bec430dade1bab2f4c5544ac3e6e0d94f4344e6bacb970` | `f439a0eb…` |
| #2 | browser UA | 196,082 B | `67fb4616460f0f6d64ebfed146c148e356e7f1fca9591e40f87de9b9e0b1e564` | `f439a0eb…` |
| #3 | declared profile | 196,082 B | `b98fb50f7d337911cf3e3449ce6d7e8678cad0565c50228d14a4f5ee8048c0e1` | `f439a0eb…` |
| #4 | declared profile | 196,082 B | `a1b8077fb4d5d40ad4683622da74a0fc2488b243a8a479d9400dc97eea450de6` | `f439a0eb…` |

- Every pair differs only inside one cluster, byte offsets 74307–74350
  (browser pair; 44 differing bytes) and 74308–74350 (profile pair; 22 bytes),
  inside `/cdn-cgi/l/email-protection#…` on the footer “Privacy support” link.
  This is Cloudflare per-response HTML rewriting, the class the registry already
  records for S020 (`corpus/SOURCES.md:104-107`).
- No `ETag` or `Last-Modified`; `cf-cache-status: DYNAMIC`; `cache-control:
  public, max-age=0, must-revalidate`. There is no transport validator to rely on.
- The decoded body is 196,082 B in all four captures; `curl -w %{size_download}`
  reports compressed transfer sizes (39,025/39,219), **not** the representation.
  Byte count is stable here; the body digest is not.
- Stable projection under the table's own `rendered-text-v1` (strip
  script/style, tags→space, `html.unescape`, collapse whitespace): 5,786 chars /
  5,818 UTF-8 bytes, sha256
  `f439a0eb0411a3d5191849b5b7f8d20d3fe4634656e7589d281378e0e8934c2a`, identical
  across all four captures and both profiles; quote and anchor present.

Conclusion: for S005 the raw body digest is a point attestation only, and the
normalized rendered-text digest is the reproducible identity. This holds across
the declared request profile too, so the provenance table's declared profile
does not change the normalized result.

## 5. Deployed-product proof

None. The page is marketing copy with vendor claims (two-key encryption with an
enclave-held key, Workload Identity Federation, full attribution logging,
public preview). It displays no version, release note, status page, or exercised
entitlement. Its own FAQ “documentation page” deep link
`https://1password.dev/environments/credential-broker` routes
301 → `https://www.1password.dev/environments/credential-broker` →
308 → `/brokered-access/github-actions` → 200, i.e. to the GitHub Actions
feature page, not a Broker overview. Tier C plus “This is a lead, not mechanism
authority” is the correct calibration; S005 cannot support a deployment claim.

## 6. C2 source-fetch provenance — exact expectations and contradictions

The live table already declares the right shape
(`corpus/source-fetches.tsv`, header lines 2–34): URL, final URL, HTTP status,
request profile, date, representation, body sha256/bytes, revision, a ≤25-word
quote, normalization, normalized sha256, and location. The census enforces it (the `SC_FETCH` block; the file was still being edited
during this audit, so I cite finding codes rather than fixed line numbers).
Measured expectations for this row:

1. **Representation.** S005 is `decoded-http-body-volatile-v1`: body bytes are
   response-coupled (four distinct digests, one 43–44-byte window), while
   `rendered-text-v1` is stable. If S005 is ever given a provenance row, use
   `bytes=196082`, body sha256 as captured, `normalization=rendered-text-v1`,
   `normalized_sha256=f439a0eb0411a3d5191849b5b7f8d20d3fe4634656e7589d281378e0e8934c2a`.
2. **Anchor.** `location` should be
   `Keep credentials out of pipelines > The platform identifies the job`.
   The observed check is only string length ≥8 (`SC_FETCH ... location`,
   previously line 279), so any eight-character string passes; require the
   heading text to occur in the normalized representation, and require the
   parent heading to disambiguate from site chrome.
3. **Quote.** ≤25 words (the row's is 20) and must be matched as a decoded
   substring of the normalized representation, not raw bytes. The observed check
   is word-count only (`SC_FETCH ... quote`, previously lines 271–272): a
   fabricated five-word quote with location “Introduction” passes. Concrete
   minimal failing fixture for L1 (static reading, **not executed**): one
   provenance row for S005 with quote `this sentence is absent from the page`
   and location `Introduction`; expected `SC_FETCH`, observed clean because
   neither quote nor location is content-checked. Offline repair needs either a
   capture-time substring assertion recorded with the row, or the normalized
   text committed (5.8 KB for S005); `normalized_sha256` alone cannot prove
   quote presence.
4. **Legacy in-row pin.** The census's `inrow-digest-malformed` branch accepts
   any 64-hex in-row `Fetch sha256:` and `continue`s, so
   `missing-provenance` never applies. S005 therefore passes on **presence**,
   although `f7ba8254…` is unreproducible. That is defensible for a queued row
   under the table's declared “every mined row” scope, but it is a promotion
   trap: if S005 becomes `mined`, the same path lets it bypass
   `source-fetches.tsv`. Recommendation: promotion queued→mined must require a
   provenance row, and legacy pins should be labelled `undocumented-point`
   rather than counted as verified provenance.

**One real contradiction for C2.** “In-row `Fetch sha256:` present” is being
treated as fetch provenance for S005, yet no current representation reproduces
that digest while the quote is still present. The check is presence assurance,
not provenance. The second, semantic contradiction is §2's FAQ-vs-feature-page
status split. Both are contained today only because S005 is queued and unused;
neither is admission material.

## 7. Limits and non-claims

- Read-only: no gate, ledger, census, handler, op, vault, host, or git command
  was executed. No production edit; this report is the only write.
- Only S005 was reopened. S017–S026 were not re-fetched; their quotes above come
  from committed registry/provenance rows. The only other public GET was the
  S005 page's own documentation deep link (redirect chain, §5).
- No 1Password account, vault, integration, workflow, entitlement, or secret was
  exercised. No deployment proof is claimed.
- The stored digest's representation is unrecoverable; no drift conclusion is
  drawn. Concurrent integration artifacts may move after 03:51:56Z.
- Prior-round overlap: `ReopenSource05` (round 22) already recorded the row hash
  and the FAQ conflict. This audit re-verifies them on 2026-10-21 and adds the
  measured per-request volatility, the stable normalized projection, the docs
  deep-link routing, and the C2 checker observations.
- Tool installs/updates: none.

Report: `.ufo/waves/round-23/parent-build/SourceS005.md`
