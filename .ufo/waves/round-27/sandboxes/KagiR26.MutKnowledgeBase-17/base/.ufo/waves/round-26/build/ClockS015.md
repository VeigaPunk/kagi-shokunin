# ClockS015 — round 26 C1 freshness re-verification (S015, OpenBao Kubernetes JWT provider)

Seat: `KagiR26.ClockS015` (scout, leaf). Lane-authored advice, not non-author closure.
Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE). Production untouched.

## Verdict (bounded)

**S015 is unchanged: no drift.** The one teaching quote is still on the page, the docs version label is still "Version 2.7.x", and the S035 feed clock's newest stable release is still v2.7.1. The raw page bytes and the feed bytes both match their declared captures **byte-for-byte**. S015 is not a Python row; the S027/S028 3.15.1 work does not apply here.

## Targets inspected

- `corpus/SOURCES.md:21`, row S015. Anchor: "§Kubernetes, TokenReview note; OpenBao 2.7.x". Quote: “The JWT auth engine does not use Kubernetes' `TokenReview` API during authentication”. In-row `Fetch sha256: a0a2b227…5fd4`.
- `corpus/release-clocks.tsv:12`: `S015 feed S035 https://github.com/openbao/openbao/releases.atom 2.7.1 2.7.1 2026-10-21 not-fired`.
- `corpus/source-fetches.tsv`, rows S015 and S035 (the declared captures).
- `.ufo/waves/round-25/observe-1.json` (sha256 `b74c8ee3…9f92`, which equals `DEFAULT_RECEIPT_SHA256`). Its S015 record: `parsed_version 2.7.1`, `sha256 1f0bb338…bc6f`, `observed_at 2026-10-21T11:31:51Z`, `verdict not-fired`. I read it only; it is not modified.

## Source re-open: the page

Command (2026-10-21T13:36:37Z UTC):
`curl -sSL --compressed -D page.headers -o page.html -w 'http=%{http_code} url=%{url_effective} size=%{size_download}\n' https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/`

| field | observed | declared (source-fetches.tsv S015) |
|---|---|---|
| HTTP / final URL | 200, same URL (no redirect) | 200, same URL |
| raw sha256 | `4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f` | `4e3fdb7d2628…edbf2f`: **match** |
| decoded bytes | 55824 (10227 on the wire, compressed) | 55824: **match** |
| rendered-text-v1 normalized sha256 | `2732189767e6663d9994b7d7f5d20cab6c4d5b28ede6f73c5f2cfb4707a2aab8` (8724 bytes) | `2732189767e6…a2aab8`: **match** |
| headers | `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`, `etag: W/"6ad71d3a-da10"`, `date: Wed, 21 Oct 2026 13:36:37 GMT` | not declared |

Probe: `python3 corpus/rendered-text-v1.py digest <page.html>` printed the line above (exit 0). Then `python3 corpus/rendered-text-v1.py locate <page.html> "The JWT auth engine does not use Kubernetes' TokenReview API during authentication"` printed `RENDERED_TEXT_V1_LOCATE: count=1` (exit 0).

Located quote (21 words, rendered text, §Kubernetes "info Note:"): “The JWT auth engine does not use Kubernetes' TokenReview API during authentication, and instead uses public key cryptography to verify the contents of JWTs.”

The note's next two sentences still support the row's inference that revocation is not immediate:
- "tokens that have been revoked by Kubernetes will still be considered valid by OpenBao until their expiry time"
- the advised fix is to use short TTLs or Kubernetes auth, "which does use the TokenReview API"

Docs version: the breadcrumb reads "Version: Version 2.7.x". The version switcher lists `Development`, `Version 2.7.x`, `Version 2.6.x` and `Version 2.5.x`. There is no 2.8.x entry. The page served at the unversioned URL is 2.7.x, which matches the anchor.

## Clock re-open: the feed (S035)

Command (2026-10-21T13:36:28Z UTC): `curl -sSL --compressed -D feed.headers -o feed.atom … https://github.com/openbao/openbao/releases.atom`

- Result: HTTP 200, 506783 bytes, sha256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`, `etag: W/"1f0bb338e341cfe8eb797a20bb663285"`.
- This matches the S035 capture byte-for-byte (`1f0bb338…bc6f`, 506783) and matches the round-25 S015 receipt digest.
- Committed parser run offline on the captured bytes (I imported `corpus/release-clock.py` and called `parse_latest_version(feed.atom)`): result `2.7.1`. Anchored version is 2.7.1, so the verdict is **not-fired**, the same as round 25.
- The feed holds 10 entries. Newest first:
  - `v2.7.1` (2026-10-01T18:32:18Z)
  - `v2.6.4`
  - `api/v2.7.1`
  - `v2.7.0`
  - `v2.6.3`
  - `sdk/v2.7.1`
  - `sdk/v2.6.3`
  - `v2.7.0-beta20260909`
  - `sdk/v2.7.0`
  - `api/v2.7.0`
- There is no v2.7.2 or v2.8.x tag, and no pre-release newer than v2.7.1.

## What these checks do not establish

- **Historical in-row pin.** The in-row `a0a2b227…` pin still does not equal the raw capture (`4e3fdb7d…`) or the normalized capture (`27321897…`). This matches `corpus/inrow-pins.tsv:21`, which already classifies it as `non-reproducing`. It is historical debt from round 23/24, not new drift, and it should not be rewritten.
- **Coverage.** The only teaching re-verified is the one TokenReview note sentence plus the two sentences after it. This is not whole-page coverage: the issuer-discovery and JWKS configuration sections were not checked as teachings. The same goes for the knowledge file `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` beyond its S015 citation.
- **Docs drift vs feed drift.** The page's `last-modified` (2026-10-20 07:50 GMT) is newer than the row's mined date (2026-10-19), yet the raw bytes equal the declared 2026-10-21 capture. That suggests a site redeploy with no content change since that capture `[INFERENCE]`. Docs-only edits that ship without a release would not fire this feed clock. Only the re-open digest above catches those, and it is a one-time snapshot, not monitoring.
- **Feed window.** GitHub's Atom feed shows only the 10 newest entries. A burst of more than 10 `sdk/` or `api/` module tags could push a stable tag out of the window. The parser takes the max stable version over what remains, so this cannot cause a false fire, but it could lag. Not currently the case: v2.7.1 is entry 1.
- **Not run.** No build, lint, test, selftest, `release-clock.py --observe` or census was run; those are L1's to run after integration. Only the two public URLs above were fetched.

## Suggested disposition for L1

S015 does not need a superseding registry row this round. In the new receipt, record S015 as `feed`, observed version 2.7.1, verdict not-fired, digest `1f0bb338…bc6f`, plus a page re-open note: raw `4e3fdb7d…` and normalized `27321897…` both match, `locate count=1`, label "Version 2.7.x". Leave the round-25 receipt and the `a0a2b227` in-row pin as they are.

## Artifacts (uniquely named, under this wave)

`.ufo/waves/round-26/build/ClockS015-evidence/`:
- `page.html`: `4e3fdb7d…edbf2f`
- `page.headers`: `f0cfff52781f3c8119cf7f72f0494307a216aa637bb64b8de8e19ebae75c5d04`
- `feed.atom`: `1f0bb338…bc6f`
- `feed.headers`: `ec3b3d7a16c7403e6a62d10d78a42ae919618cb98323dca3493c1480f28130f8`

Tool installs: none.
