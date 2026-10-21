# ClockS026 — round 26 C1 freshness re-verification (S026 / clock S035)

Seat: `KagiR26.ClockS026` (scout, leaf). Lane-authored advice, not non-author closure.
Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE; worktree shows only untracked `.ufo/waves/round-26/` and `plans/round-26.md`).
Access: 2026-10-21T13:36:39Z (UTC). No production, registry, Git or jj writes.

## Result (bounded)

**Unchanged; the clock has not fired.** The S026 page's decoded body is byte-identical to the recorded capture, the declared quote is located exactly once under the recorded section, and the S035 feed is byte-identical to the round-25 retained receipt. The newest stable OpenBao server release is still v2.7.1. No superseding row is warranted for S026.

This verifies one 22-word quote under §Token hierarchies and orphan tokens on 2026-10-21. It is not whole-page coverage and not continuous monitoring.

## Rows under test (BASE)

- `corpus/SOURCES.md:32` S026. URL https://openbao.org/docs/concepts/tokens/. Anchor: "§Token hierarchies and orphan tokens and §Token Time-To-Live; Version 2.7.x, opened 2026-10-21". Clock: on-release.
- `corpus/release-clocks.tsv:23`: `S026 feed S035 https://github.com/openbao/openbao/releases.atom 2.7.1 2.7.1 2026-10-21 not-fired`.
- `corpus/source-fetches.tsv:53` S026 capture: sha256 `5229521866ce21fa…385f82c`, 47384 bytes, normalized `ed949658b434fa76…c0d2e3`, location "Token hierarchies and orphan tokens".
- Round-25 receipt `.ufo/waves/round-25/observe-1.json` (sha256 `b74c8ee3…349f92`, equal to `DEFAULT_RECEIPT_SHA256`). Its S026 entry is feed, http 200, observed_at 2026-10-21T11:31:53Z, parsed_version 2.7.1, feed sha256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`, verdict not-fired. I read it and did not modify it.

## Commands and observed output

Run from `.ufo/waves/round-26/build/` with the declared profile `curl-fsSL-compressed-v1`:

```
UA='kagi-shokunin-round23/1.0 (documentation verification)'
curl -fsSL --compressed -A "$UA" -D ClockS026.tokens.headers.txt -o ClockS026.tokens.html \
  -w 'tokens %{http_code} %{url_effective} %{size_download}\n' https://openbao.org/docs/concepts/tokens/
curl -fsSL --compressed -A "$UA" -D ClockS026.releases.headers.txt -o ClockS026.releases.atom \
  -w 'feed %{http_code} %{url_effective} %{size_download}\n' https://github.com/openbao/openbao/releases.atom
sha256sum ClockS026.tokens.html ClockS026.releases.atom; wc -c ...
```

Observed output:

- `tokens 200 https://openbao.org/docs/concepts/tokens/ 12527` (12527 is the gzip wire size).
- `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c ClockS026.tokens.html` with 47384 bytes. This equals the recorded raw digest and byte count.
- `feed 200 https://github.com/openbao/openbao/releases.atom 506783`.
- `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f ClockS026.releases.atom` with 506783 bytes. This equals the round-25 receipt's feed sha256.

Normalizer, run from the repo root:

- `python3 corpus/rendered-text-v1.py digest …/ClockS026.tokens.html` printed `RENDERED_TEXT_V1: raw_sha256=5229521866ce…f82c bytes=47384 normalized_sha256=ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3 normalized_bytes=14608`. The normalized digest equals the recorded one.
- `python3 corpus/rendered-text-v1.py locate …/ClockS026.tokens.html 'When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.'` printed `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0).

Response headers:

- tokens: `HTTP/2 200`, `content-type: text/html; charset=utf-8`, `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`, `etag: W/"6ad71d3a-b918"`, `cache-control: max-age=600`, `content-encoding: gzip`, `date: Wed, 21 Oct 2026 13:36:39 GMT`, `age: 12`, `x-cache: HIT`.
- feed: `HTTP/2 200`, `content-type: application/atom+xml; charset=utf-8`, `etag: W/"1f0bb338e341cfe8eb797a20bb663285"`, `cache-control: max-age=0, private, must-revalidate`, `date: Wed, 21 Oct 2026 13:36:28 GMT`.

Feed parse (Python `xml.etree`, Atom namespace):

- Feed `<updated>` is 2026-10-01T13:32:54Z. The feed has 10 entries.
- The first and maximum stable `vX.Y.Z` entry is `v2.7.1`, updated 2026-10-01T18:32:18Z, at `/releases/tag/v2.7.1`.
- The next entries are `v2.6.4`, then `api/v2.7.1: …` (a module release, excluded by S035), `v2.7.0`, `v2.6.3`, `sdk/…`, and `v2.7.0-beta20260909` (beta, excluded).

Tools: curl 8.23.0 (system), Python 3.14.8 (system). Nothing was installed or updated.

## Source teaching and whether it holds

- Located quote (22 words, verbatim, §Token hierarchies and orphan tokens): "When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well."
- Docs version: the page's version selector renders "Version 2.7.x" as the current label. The selector also lists "Development", "Version 2.6.x" and "Version 2.5.x". This is consistent with the clock anchor at the 2.7.x series and stable v2.7.1.
- **The teaching still holds**, with no drift in the recorded raw or normalized representation.
- The second anchor, §Token Time-To-Live, carries S021's quote ("After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked."). It also locates with count=1. It is S021's teaching, so I do not claim it as S026 coverage.

## Limits: docs-only versus feed

- The S035 feed proves only the server release identity. It says nothing about the docs teaching.
- The docs page has `last-modified 2026-10-20 07:50:18 GMT`, a weak ETag, and was a CDN cache HIT. Its bytes equal the round-23/24 capture, so no docs-only change happened between those captures and today. A docs rebuild with identical bytes is not evidence about semantics outside the quoted sentence.
- The feed is a 10-entry window. A stable release that scrolled out of the window would not be visible. Today's first entry is v2.7.1, so this does not affect the verdict.
- One oddity: the feed-level `<updated>` (13:32:54Z) is earlier than the v2.7.1 entry's `<updated>` (18:32:18Z). This is GitHub feed metadata and does not affect the verdict.

## Actionable counterexamples (calibration, not drift)

1. **Orphan-revocation exception, on the same page.** The page says: "the auth/token/revoke-orphan endpoint, which revokes the given token but rather than revoke the rest of the tree, it instead sets the tokens' immediate children to be orphans." S026's teaching cell is unqualified: "revocation of a parent token also revokes its child tokens and their leases". It holds for normal revocation, but not for `revoke-orphan`. Orphan tokens have no parent by construction ("These tokens have no parent -- they are the root of their own token tree."). Advice for L1: if a future superseding row is ever cut, scope the teaching to normal revocation. That is not a freshness trigger this round.
2. Nothing on this page bears on Python. The Python 3.15.1 normalizer check belongs to S027/S028 (seats ClockS027/ClockS028), so I inspected nothing there.

## Inspected scope

- Two public URLs, each fetched once: https://openbao.org/docs/concepts/tokens/ and https://github.com/openbao/openbao/releases.atom.
- Read-only files at BASE: the S026/S035 rows in `corpus/SOURCES.md` and `corpus/release-clocks.tsv`, the S026 row in `corpus/source-fetches.tsv`, `corpus/rendered-text-v1.py` (run only in `digest`/`locate` mode on my own artifact), and `.ufo/waves/round-25/observe-1.json`.
- Not run: `release-clock.py`, census, gates, tests and lint. These are L1-only after integration, and none are claimed passing.

## Supporting artifacts (this seat only)

- `.ufo/waves/round-26/build/ClockS026.tokens.html` (sha256 `5229521866ce…f82c`, 47384 B)
- `.ufo/waves/round-26/build/ClockS026.tokens.headers.txt`
- `.ufo/waves/round-26/build/ClockS026.releases.atom` (sha256 `1f0bb338e341…bc6f`, 506783 B)
- `.ufo/waves/round-26/build/ClockS026.releases.headers.txt`

Proposed disposition for the new receipt: S026 is `unchanged / not-fired`, observed 2.7.1 against anchored 2.7.1. The feed and page digests are identical to the retained evidence. I propose no registry change.
