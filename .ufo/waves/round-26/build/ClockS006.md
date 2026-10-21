# ClockS006 — round 26 C1 freshness re-verification (lane-authored advice)

Seat: `KagiR26.ClockS006`. Observed BASE: `1bf3eec48d3761580ffd375c88143232485ae814`
(`git rev-parse HEAD`; working tree untracked only `.ufo/waves/round-26/`, `plans/round-26.md`).
Scope: S006 only. Not S027/S028 (Python) — S006 is a 1Password blog announcement with no
Python dependency; the Python3.15.1 instruction does not apply to this row.

## Bounded result

**No finding: S006's clock binding and registered teaching still hold as of 2026-10-21T13:36:41Z.**
The declared rendered-quote clock re-locates (count=1 each for both registered quotes), and the
rendered-text-v1 normalized digest reproduces the recorded capture byte-for-byte
(`20b4fd86dada…804f`). Raw-body drift is explained by per-response Cloudflare email-obfuscation
bytes inside an `href` attribute. That drift is outside the normalized text and is already declared by the
row's `decoded-http-body-volatile-v1` representation.

## Rows under test (read at BASE, not modified)

- `corpus/release-clocks.tsv:3` — `S006 rendered-quote - - - - 2026-10-21 quote-located`
  "dated vendor announcement (published 2026-07-28); no release feed governs it".
- `corpus/SOURCES.md:12` — teaching: public-preview status, plus integration-key versus standing Service
  Account access; anchors §How 1Password Credential Broker works and §Try 1Password Credential Broker today.
- `corpus/source-fetches.tsv:59` — capture raw `fe37e1f3ef44…`, 190261 bytes, normalized
  `20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f`, quote under rendered-text-v1.
- `corpus/inrow-pins.tsv:12` — in-row pin `39a869df8807…` already classified `non-reproducing`
  (historical; not re-litigated here).

## Commands and observed outputs

```
curl -fsSL --compressed -D ClockS006.headers.txt -o ClockS006.body.html \
  -w 'http_code=%{http_code} url_effective=%{url_effective} size_download=%{size_download} content_type=%{content_type}\n' \
  https://1password.com/blog/1password-credential-broker-public-preview
→ http_code=200 url_effective=<same URL, no redirect> size_download=39041 content_type=text/html; charset=utf-8
curl 8.23.0 (libcurl/8.23.0, brotli/1.2.0, zlib/1.3.2)
headers: date: Wed, 21 Oct 2026 13:36:41 GMT; content-encoding: gzip; cache-control: public, max-age=0,
         must-revalidate; cf-cache-status: DYNAMIC; age: 62; server: cloudflare; no ETag/Last-Modified observed
sha256sum ClockS006.body.html → c7be838b751a5ebcd7196f3010a09207f33c2d52e924a60ee07c24fb3ddac575 (190261 bytes)

python3 corpus/rendered-text-v1.py digest .ufo/waves/round-26/build/ClockS006.body.html
→ RENDERED_TEXT_V1: raw_sha256=c7be838b…c575 bytes=190261 normalized_sha256=20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f normalized_bytes=9530
```

`python3 corpus/rendered-text-v1.py locate <body> "<quote>"` results:

| quote | count |
|---|---|
| unlike a service account token that carries standing access, the organization-wide integration key is an encryption key | 1 |
| is in public preview | 1 |
| 1Password Credential Broker is now in public preview (title, `feature-claims.json` S006-title) | 2 (title + H1) |
| available for all Enterprise Password Manager Business customers (S006-eligible) | 1 |
| How 1Password Credential Broker works / Try 1Password Credential Broker today (anchors) | 1 / 1 |
| July 28, 2026 | 3 (byline + two related-post dates) |
| General Availability / generally available (status-change probe) | 0 / 0 |

Raw drift probe: `cmp -l` against sibling seat ClockS020's independent fetch of the same URL
(`sandboxes/ClockS020/body-1.html`, sha256 `e9ccc403…`) differs in 44 bytes, all at offsets 68526–68569. That region
is `href="/cdn-cgi/l/email-protection#dfafadb6…"`, Cloudflare's per-response email obfuscation key, which sits inside a tag
and is removed by rendered-text-v1 step 3. This is [INFERENCE] the same mechanism behind the recorded
`fe37e1f3…` ≠ current `c7be838b…` raw mismatch. I did not inspect the original capture bytes because they are not retained in the tree.

## Located quotes (≤25 words, normalized text, URL accessed 2026-10-21)

- §How 1Password Credential Broker works: “unlike a service account token that carries standing access,
  the organization-wide integration key is an encryption key” — unchanged.
- §Try 1Password Credential Broker today: “1Password Credential Broker is in public preview, and available
  now for all 1Password EPM Business customers.” — unchanged.
- Byline: “by Jeff Malnick July 28, 2026 - 6 min” — publication date unchanged.

## Teaching disposition

- **Unchanged teaching.** Both registered quotes and the publication date re-locate, and the full normalized page is
  digest-identical to the round's capture. This means no wording on the rendered page changed since capture, not merely the
  quoted sentences. No "generally available" wording appears.
- **Clock limitation (docs-only, no feed).** `rendered-quote` attests to this announcement's text, not to the product's
  current status. A dated blog post stays the same even if 1Password later moves Credential Broker to GA or changes eligibility.
  The current-status authority is the setup guide (S007/S019), which I did not open: it is out of this seat's URL scope.
  Do not read this result as "Credential Broker is still in public preview today".
- **Coverage bound (no broadening).** The quote check proves only the two registered quotes (plus the title, eligibility and anchor
  strings above). The normalized-digest match is a whole-page text identity for rendered-text-v1 only. It is not a semantic review
  of every claim on the page.
- **Known, already-registered nuance.** The page also says “we're slowly rolling out a new capability in beta: custom OIDC
  workflows” (§New in this release). This is the Actions-preview versus custom-OIDC-beta split that S020 already
  supersedes for S006 (`SOURCES.md:26`). It is not a new counterexample.

## Actionable counterexamples

None for S006. Optional, for L1: if a receipt wants to cite raw-hash drift, record the cause as
Cloudflare email-protection bytes inside a tag attribute (offsets 68526–68569 in this fetch). That keeps it distinct from teaching drift.

## Historical receipts

I did not open, edit or rewrite anything from round 25 or earlier, `inrow-pins.tsv`, or the registry/TSV rows. The round-25
receipt and the lone-clone INCOMPLETE/48 status are untouched by this seat.

## Artifacts written (only these)

- `.ufo/waves/round-26/build/ClockS006.md` (this report)
- `.ufo/waves/round-26/build/ClockS006.body.html` (decoded body, sha256 `c7be838b…c575`)
- `.ufo/waves/round-26/build/ClockS006.headers.txt` (response headers)
- `.ufo/waves/round-26/build/ClockS006.normalized.txt` (rendered-text-v1 output, sha256 `20b4fd86dada…804f`)

Not run: build, lint, tests, formatters, `sources-census.sh`, `release-clock.py`. Installs: none.
