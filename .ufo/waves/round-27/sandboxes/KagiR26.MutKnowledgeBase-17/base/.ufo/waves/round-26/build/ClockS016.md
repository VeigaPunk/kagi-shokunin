# ClockS016 — round 26 C1 freshness, S016 (OpenBao tokens)

Seat KagiR26.ClockS016 · observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`) · observed 2026-10-21T13:36:34Z (UTC).
Production files read only. Writes: this report and `.ufo/waves/round-26/build/ClockS016-evidence/` (fetched bytes and headers). Installs: none. No credentials, vault, CDP or account contact. Gate/census/selftests: **not run** (L1-only).

## Bounded result

- **Clock S016 = not-fired (unchanged).** The newest stable OpenBao server release in the S035 feed is still **v2.7.1**. That equals both `anchored_version` and `observed_version` (2.7.1) in `corpus/release-clocks.tsv:13`.
- **Teaching = still holds, for the one declared quote only.** The S016 quote is located exactly once on today's page, under §Token hierarchies and orphan tokens. The page still labels itself **Version 2.7.x**.
- **No drift in either representation.** The raw page digest and the `rendered-text-v1` normalized digest both equal the recorded round-24 capture (`corpus/source-fetches.tsv:69`). The feed digest equals both the round-25 and round-26 receipt entries.
- **Python 3.15.1 drift does not reach this row.** S016 is OpenBao-only and its clock is the OpenBao feed (S035). The Python S027/S028 question is outside this seat's target.
- **No counterexample found.** No superseding row is warranted by S016's clock or quote.

## Sources re-opened (only these two public URLs)

| what | URL | HTTP | final URL | decoded bytes | sha256 (decoded body) |
|---|---|---|---|---|---|
| S016 page | https://openbao.org/docs/concepts/tokens/ | 200 | same | 47384 | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` |
| S016 page, declared UA | same, `-A 'kagi-shokunin-round23/1.0 (documentation verification)'` | 200 | same | 47384 | `5229521866ce…f82c` (identical) |
| S035 feed (clock) | https://github.com/openbao/openbao/releases.atom | 200 | same | 506783 | `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f` |

The page's HTTP metadata is `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`, `etag: W/"6ad71d3a-b918"`, `server: GitHub.com` and `date: Wed, 21 Oct 2026 13:36:34 GMT`. The feed's metadata is `etag: W/"1f0bb338e341cfe8eb797a20bb663285"` and `date: Wed, 21 Oct 2026 13:36:28 GMT`. The page bytes are identical even though `last-modified` is later than the row's 2026-10-19 mined date. A redeploy on 10-20 therefore left this body unchanged from the 10-21 round-24 capture. Nothing is claimed about the page content before that capture.

Commands (run in the evidence directory):

```
curl -fsSL --compressed -D tokens.headers -o tokens.html -w 'status=%{http_code} final=%{url_effective} size=%{size_download}\n' https://openbao.org/docs/concepts/tokens/
curl -fsSL --compressed -D feed.headers -o releases.atom -w '...' https://github.com/openbao/openbao/releases.atom
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o tokens.ua.html https://openbao.org/docs/concepts/tokens/
sha256sum tokens.html releases.atom tokens.ua.html
python3 corpus/rendered-text-v1.py digest tokens.html
python3 corpus/rendered-text-v1.py locate tokens.html 'When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.'
python3 -c '<import corpus/release-clock.py; parse_latest_version(open("releases.atom","rb").read())>'
```

Observed outputs:

- `RENDERED_TEXT_V1: raw_sha256=5229521866ce…f82c bytes=47384 normalized_sha256=ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3 normalized_bytes=14608`
- `RENDERED_TEXT_V1_LOCATE: count=1` (rc=0)
- `parse_latest_version = 2.7.1`

## Teaching (S016) — still holds, narrowly

- Located quote (21 words): “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.”
- Anchor: the h2 **Token hierarchies and orphan tokens**. The page headings in order are Tokens, Token formats, Token types, The token store, Root tokens, **Token hierarchies and orphan tokens**, Token accessors, **Token Time-To-Live, periodic tokens, and explicit max TTLs**, The general case, Explicit max TTLs, Periodic tokens, CIDR-Bound tokens, Token types in detail, Service tokens, Batch tokens, Token type comparison, and Service vs. batch token lease handling.
- Version label: the page HTML contains `Version 2.7.x` (2×), `version-2.7.x`, `Version: Version 2.7.x` and `version content=2.7.x` (2×). The version selector also lists 2.6.x and 2.5.x. The row's anchor `OpenBao 2.7.x` therefore still matches.
- Scope limit: the row's teaching cell also names TTL, renewal and policy behavior (§Token Time-To-Live …). This seat verified only that the section heading exists. TTL and renewal statements were **not** re-verified quote-by-quote. The clean result covers the revocation quote alone and must not be extended to whole-page coverage.

## Clock (S035 feed) — not-fired

Newest feed entries (Atom order; feed `<updated>` 2026-10-01T13:32:54Z):

| title | updated | counts as stable? |
|---|---|---|
| v2.7.1 | 2026-10-01T18:32:18Z | yes, newest |
| v2.6.4 | 2026-10-01T13:59:14Z | yes, older series |
| api/v2.7.1 | 2026-10-01T13:24:26Z | no (module tag) |
| v2.7.0 | 2026-09-23T17:39:54Z | yes |
| sdk/v2.7.1, sdk/v2.6.3 | 2026-09-23 | no (module tags) |
| v2.7.0-beta20260909 | 2026-09-09 | no (prerelease) |

The clock's own `parse_latest_version` takes the maximum X.Y.Z over the stable title and tag-link patterns and returns 2.7.1. That equals `anchored_version` 2.7.1, so `not-fired` is the correct verdict under `release-clock.py` lines 524–527.

## Receipt identity (historical receipt preserved)

| receipt | file sha256 | S016 entry |
|---|---|---|
| `.ufo/waves/round-25/observe-1.json` (tracked) | `b74c8ee30aae…9f92` | observed_at 2026-10-21T11:31:51Z, parsed 2.7.1, feed sha256 `1f0bb338…bc6f`, not-fired |
| `.ufo/waves/round-26/observe-1.json` (untracked, new) | `9a1cefec10c2…1b55` | observed_at 2026-10-21T13:36:34Z, parsed 2.7.1, feed sha256 `1f0bb338…bc6f`, not-fired |

`git diff --quiet 1bf3eec… -- .ufo/waves/round-25/observe-1.json corpus/SOURCES.md corpus/release-clocks.tsv` reported no difference. `git show 1bf3eec:.ufo/waves/round-25/observe-1.json | sha256sum` equals the working file (`b74c8ee3…`), so the round-25 receipt is intact. The S016 identity is the same in the old and new receipts apart from `observed_at`. This row adds **0** drift dispositions.

## Limitations and remaining unknowns

- `decoded-http-body-volatile-v1`: digest equality today is a point attestation, not a drift pin. A future chrome change could alter the raw digest without changing the teaching.
- A feed clock observes the release identity only. A docs-only edit inside the 2.7.x series would not fire it. Today's identical page digests show that no such edit has happened since the round-24 capture, but nothing more.
- Legacy in-row pin `c083fdca…` stays non-reproducing (`corpus/inrow-pins.tsv:22`). It is historical and was not rewritten. S026 remains the superseding locator for the same page and quote.
- TTL, renewal and policy sub-teachings were not re-verified (see above).
