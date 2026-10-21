# ClockS018 — round 26 C1 freshness, S018 (lane-authored advice, not closure)

Seat: KagiR26.ClockS018 (scout). Observed BASE: `git rev-parse HEAD` =
`1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE). Production untouched.

## Verdict

**S018 is unchanged: the response bytes are the same and every anchored teaching still holds.** Python 3.15.1 drift does
not touch S018: it is a 1Password docs row with a `rendered-quote` clock, no feed. No registry change
indicated. Two calibration notes below (N1, N2) are scoped wording issues, not drift.

## Targets inspected

- `corpus/SOURCES.md:24` (S018): public beta, Business OIDC connection, beta desktop app, JavaScript SDK only.
- `corpus/release-clocks.tsv:15`: `S018 rendered-quote - - - - 2026-10-21 quote-located unversioned guide; the beta SDK version is not named by the anchor`
- `corpus/source-fetches.tsv:45`: raw sha256 `a0617582…b450`, 1283173 bytes, rendered-text-v1 sha256 `d493bd81…e0fc`, final URL without trailing slash, 200.
- `corpus/feature-claims.json:127-131`: five quote ids (S018-title/intro/beta-app/js-sdk/runtime).

## Re-fetch (this round)

URL: https://www.1password.dev/brokered-access/custom-workflow/ — accessed 2026-10-21T13:36:37Z.

```
curl -fsSL --compressed -D ClockS018.headers.txt -o ClockS018.body.html -w 'http=%{http_code} final=%{url_effective} size=%{size_download}\n' <URL>
http=200 final=https://www.1password.dev/brokered-access/custom-workflow size=167892
sha256 a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450   bytes 1283173
```

Headers: `HTTP/2 308` → `HTTP/2 200`; `content-type: text/html; charset=utf-8`; `etag: W/"qlxr8hi2xirhxx"`;
`age: 46336`; `x-vercel-cache: MISS`; `cache-control: no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0`;
`date: Wed, 21 Oct 2026 13:36:37 GMT`. No `last-modified` header. The embedded JSON has `"dateModified":"2026-08-17T22:36:47.822Z"` (2 occurrences).

`python3 corpus/rendered-text-v1.py digest ClockS018.body.html` (Python 3.14.8):
`RENDERED_TEXT_V1: raw_sha256=a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450 bytes=1283173 normalized_sha256=d493bd815016219da8da33e18fb673aed3414155c6634a9139c7083ba7bae0fc normalized_bytes=6423`

The raw and normalized digests both equal `source-fetches.tsv:45` byte for byte. The capture is classified
`decoded-http-body-volatile-v1`, but it reproduced exactly this round. That is one observation, not a stability pin.

## Anchored quotes (`rendered-text-v1.py locate`, each exit 0)

| quote id | anchor | located text (≤25 words) | count |
|---|---|---|---|
| S018-title | `<h1 id="page-title">` / `<title>` | "Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)" | 3 |
| S018-intro | introduction | "If an administrator has connected an OIDC provider to your 1Password Business account" | 1 |
| S018-runtime | introduction | "you can use 1Password to access secrets from your 1Password Environments in your custom workflows at runtime" | 1 |
| S018-beta-app | Step 1: Set up an Environment | "latest beta release of the 1Password desktop app" | 1 |
| S018-js-sdk | Step 3 note | "Credential Broker is only supported in the 1Password JavaScript SDK at this time." | 1 |

The raw-HTML `grep -F` counts were 0 for intro and js-sdk, because inline link and code markup splits them. They are
located only under the declared normalizer, so do not cite them as raw-byte matches.

## Calibration notes / counterexamples

- **N1: the clock note is scoped to the anchor, and the page does name an SDK version.** The usage-example code comment
  reads "// SDK 0.5.0-beta.1 only accepts unpadded integration keys." It also uses `require ( "@1password/sdk" )` (normalized
  text). The clock note "the beta SDK version is not named by the anchor" is literally true for the Step 3 note.
  A reader must not take it to mean "the page names no version". The comment is example code, not a support statement,
  so it does not justify a feed clock (no npm/GitHub feed was fetched, which is out of lane). Advice: if the note is ever
  revised, scope it as "the anchor names none; the example comment says 0.5.0-beta.1".
- **N2: the "Beta" badge does not appear in rendered-text-v1 text.** `round-22-verifier-spotcheck.md:103` cites a "Beta"
  callout. In the raw body it is the MDX component `BetaBadge` → `op-status-badge` `Beta`, which only exists inside
  `<script>`. The normalizer strips that, so the normalized text contains 0 occurrences of `Beta`. The registered status
  teaching rests on the H1 "(public beta)", which is located, so no row is affected. Do not cite the badge as quote-located
  evidence. The historical receipt is unchanged.
- The page's nav section label reads "Credential Broker (public preview)" while the H1 says "(public beta)". This is the
  known per-feature status split already handled by S019/S020. It is not new drift.

## Bounds

Scope: one GET of the registered URL; headers, raw and normalized digests; the five feature-claims quotes; status, version
and date greps over the normalized text and raw body. Not done: browser rendering, other 1Password pages, any SDK release
feed, and whole-page semantic coverage beyond the five anchors. No build, lint or tests were run. The `digest`/`locate`
calls were evidence probes on the captured file. No tools were installed.

Supporting artifacts (this directory): `ClockS018.headers.txt`, `ClockS018.body.html`, `ClockS018.normalized.txt`
(sha256 `d493bd815016219da8da33e18fb673aed3414155c6634a9139c7083ba7bae0fc`).
