# ClockS014 — round 26 C1 freshness re-verification (lane advice, not closure)

Seat: KagiR26.ClockS014 (scout, leaf). Observed BASE: `git rev-parse HEAD` =
`1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE). Production files read only.
No installs, no host-private reads, no git/jj mutations. Python S027/S028 are not this seat's rows.

## Verdict (bounded)

S014's clock **has not fired**, and its source teaching **still holds** on the 2026-10-21 13:36Z
re-fetch. Both raw captures are byte-identical to the round's recorded captures, so this round saw
**no docs drift and no release drift**. The S014 row's own quote (uppercase) still does **not**
locate under rendered-text-v1. That is the known round-23 defect, already superseded by S025, and
not new drift. The non-reproducing in-row pin `e94723241fbc…` also stays as it was. Do not rewrite
historical receipts or rows on account of S014.

## Targets as observed at BASE

- `corpus/SOURCES.md:20` S014: URL https://openbao.org/docs/auth/jwt/, anchor "§JWT/OIDC auth method and
  §JWT verification; OpenBao 2.7.x", quote "The JWT auth method can be used to authenticate with OpenBao
  using OIDC", status mined, recheck on-release. S025 (`SOURCES.md:31`) supersedes S014's locator.
- `corpus/release-clocks.tsv:11` S014: `feed S035 https://github.com/openbao/openbao/releases.atom
  anchored=2.7.1 observed=2.7.1 2026-10-21 not-fired` (derived anchor).
- `corpus/source-fetches.tsv:67` S014: raw `449ef132…1785d9`, 63046 bytes; rendered-text-v1 normalized
  `ca496ad8…52a403`. Row `:78` S035 feed raw `1f0bb338…98bc6f`, 506783 bytes.
- `corpus/inrow-pins.tsv:20` S014: pin `e9472324…cb0b1` recorded as `non-reproducing`.

## Commands and observed outputs

Working dir `.ufo/waves/round-26/build/ClockS014-evidence/` (the supporting artifacts are
`page.html`, `page.headers`, `feed.atom`, `feed.headers`).

```
date -u                      -> 2026-10-21T13:36:32Z
curl -fsSL --compressed -D page.headers -o page.html https://openbao.org/docs/auth/jwt/
  -> http=200 final=https://openbao.org/docs/auth/jwt/ wire=13325 B (gzip), decoded 63046 B
curl -fsSL --compressed -D feed.headers -o feed.atom https://github.com/openbao/openbao/releases.atom
  -> http=200 final=same URL, 506783 B
sha256sum page.html feed.atom
  449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9  page.html
  1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f  feed.atom
curl 8.23.0; python3 3.14.8 (host, unchanged)
```

HTTP metadata:
- Page: `server: GitHub.com`, `etag: W/"6ad71d3a-f646"`, `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`,
  `content-encoding: gzip`, `content-length: 13325`, `date: Wed, 21 Oct 2026 13:36:32 GMT`.
- Feed: `etag: W/"1f0bb338e341cfe8eb797a20bb663285"` (prefix of body sha256),
  `content-type: application/atom+xml`, `date: Wed, 21 Oct 2026 13:36:28 GMT`.
- Header files sha256: page.headers `4235212458f0…c19a`, feed.headers `499e44becb3b…7c78`.

Normalizer (`corpus/rendered-text-v1.py`, digest/locate only; read-only):

```
digest page.html -> raw_sha256=449ef132…1785d9 bytes=63046 normalized_sha256=ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403 normalized_bytes=15942
locate "The JWT auth method can be used to authenticate with OpenBao using OIDC"            -> count=0
locate "The jwt auth method can be used to authenticate with OpenBao using OIDC"            -> count=1
locate "The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT" -> count=1
locate "JWT signatures will be verified against public keys from the issuer."             -> count=1
locate "only one method may be configured for a single backend"                            -> count=1
locate "Version: Version 2.7.x"                                                             -> count=1
locate "Development Version 2.7.x Version 2.6.x Version 2.5.x"                              -> count=1
locate "Bound claims" -> 3 ; "Claims as metadata" -> 2 ; "JWT verification" -> 3
```

Feed clock (`corpus/release-clock.py` `parse_latest_version` only, imported; no network or writes):

```
parse_latest_version(feed.atom) -> 2.7.1      (anchored 2.7.1 -> not-fired)
feed entries=10; stable titles in order: v2.7.1 (updated 2026-10-01T18:32:18Z), v2.6.4, v2.7.0, v2.6.3;
non-stable: v2.7.0-beta20260909, api/v2.7.1, sdk/v2.7.1, sdk/v2.6.3, sdk/v2.7.0, api/v2.7.0
```

## Source teaching: still holds (scoped to two located sentences)

- H1 "JWT/OIDC auth method": "The jwt auth method can be used to authenticate with OpenBao using OIDC
  or by providing a JWT" (rendered text, count=1). This covers both the OIDC path and the direct-JWT path.
- §JWT verification: "JWT signatures will be verified against public keys from the issuer." (count=1). This
  covers configured signature verification.
- Version label: "Version: Version 2.7.x". The version menu lists Development, 2.7.x, 2.6.x and 2.5.x,
  with no 2.8.x docs series. The served docs series therefore still matches S014's "OpenBao 2.7.x" anchor.

Scope note: claim handling (§Bound claims, §Claims as metadata) is only confirmed as **present
headings**. Their content was not re-read this round. These located sentences do not cover the whole page.

## Docs-only vs feed limitations (calibration)

1. **The feed clock cannot detect docs-only drift.** S035 tracks server release tags. The docs page is
   GitHub Pages content (`last-modified` 2026-10-20) and can change with no release. This round the docs
   are unchanged anyway, because the raw body is identical to the recorded `449ef132…` capture. That
   holds for the capture instant only. It is not continuous monitoring.
2. **The anchor is derived.** The row names a series ("2.7.x"), not a release. The anchor 2.7.1 is the
   newest stable release from when the row was opened. A 2.7.2 patch would fire the clock even though the
   series label is unchanged. A 2.8.0 release would fire it and probably also move the docs default
   series, so a re-open would then be required.
3. **Feed window and ordering.** The feed holds only 10 entries and interleaves 2.6.x backports
   (v2.6.4 updated after v2.7.0). A first-entry reader happens to get the right answer today, but only
   by order. The committed parser takes the max stable X.Y.Z and is safe here. The two `v2.8` substrings
   in the feed are deprecation notes ("will be removed in v2.8.0") inside release bodies, not releases.
   The anchored parser ignores them.
4. **Feed semantics.** The feed only provides release identity. It does not verify the JWT teaching; the
   page re-open above does that.

## Actionable counterexamples / residuals

- **C-S014-a (known, not new):** the S014 in-row quote with uppercase "JWT" locates **0** times. Only
  the lowercase rendered form locates (1). Disposition: already superseded by S025 (round 23). Keep
  S014 `mined` and cited as historical evidence. No new superseding row is needed for S014 in round 26.
- **C-S014-b (known, not new):** the in-row pin `e94723241fbc…` is still unreproduced. Today's raw
  digest is `449ef132…` and the normalized digest is `ca496ad8…`, matching `inrow-pins.tsv:20` exactly.
- **No drift finding.** Raw page, normalized page and raw feed all equal the recorded digests
  (source-fetches.tsv:67/:52/:78). Suggested receipt disposition for S014: `not-fired; teaching
  re-verified (unchanged bytes); docs-only drift undetectable by the feed clock`.

## Not run

No build, lint, test, formatter, `release-clock.py --selftest`/observe or `rendered-text-v1.py
--selftest`. None of these are claimed as passing. No registry or production writes.
