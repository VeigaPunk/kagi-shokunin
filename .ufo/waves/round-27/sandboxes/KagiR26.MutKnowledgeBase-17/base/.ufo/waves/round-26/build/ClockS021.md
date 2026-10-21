# ClockS021 — round 26 C1 freshness scout (lane advice, not closure)

Seat: KagiR26.ClockS021. Observed BASE: `git rev-parse HEAD` in kagi-shokunin = `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE). Worktree had only untracked `.ufo/waves/round-26/` and `plans/round-26.md`. No production, registry, Git, or jj writes.

## Verdict (bounded)

S021's registered teaching still holds on the live page. The S035 feed clock has **not fired**. The decoded HTTP body is byte-identical to the registered capture. No counterexample was found.

## Inspected scope

- Registry rows read: `corpus/SOURCES.md:27` (S021), `corpus/release-clocks.tsv:18` (S021), `corpus/source-fetches.tsv:48` (S021), and `corpus/feature-claims.json` quotes S021-title, -version, -service-scope, -ttl, and -nonroot-ttl.
- Fetched only two public URLs: the S021 source page and the S035 feed. Nothing else was fetched.
- **Python S027/S028:** not in this lane's target, so not inspected. This report makes no claim about the Python 3.15.1 or 3.15.0 normalizer.

## Source re-open — https://openbao.org/docs/concepts/tokens/ (accessed 2026-10-21T13:36Z)

Command: `curl -fsSL --compressed -D tok.hdr -o tok.html -w '%{http_code} %{url_effective} %{size_download}\n' https://openbao.org/docs/concepts/tokens/`

| Field | Observed value |
|---|---|
| HTTP status | 200 |
| Final URL | `https://openbao.org/docs/concepts/tokens/` (no redirect) |
| Transfer size | 12527 bytes compressed |
| Decoded body size | 47384 bytes |
| Decoded body SHA-256 | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` |
| `last-modified` | Tue, 20 Oct 2026 07:50:18 GMT |
| `etag` | `W/"6ad71d3a-b918"` |
| `date` | Wed, 21 Oct 2026 13:36:27 GMT |
| `x-cache` | HIT |
| `age` | 0 |

The decoded body SHA-256 and size equal the values in `source-fetches.tsv:48` (`5229521866…f82c`, 47384 bytes). The page is unchanged since the registered 2026-10-21 capture.

The `last-modified` header (2026-10-20) is a docs-site build stamp. It is not evidence of a teaching change.

### Quote location

Method: strip `<script>`/`<style>` and tags, `html.unescape`, then collapse whitespace. This approximates the registry's rendered-text-v1 normalizer but is not that exact normalizer, so I did not recompute the rendered digest `ed949658…`.

Every quote was located verbatim and each is 25 words or fewer:

- **S021-ttl**, at §Token Time-To-Live, periodic tokens, and explicit max TTLs: "After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked."
  - A raw-HTML `grep -F` for this sentence returned 0 matches. Markup splits it in the raw HTML; it matches only after tag-stripping.
- **S021-nonroot-ttl**: "Every non-root token has a time-to-live (TTL) associated with it". Raw-HTML match count: 1.
- **S021-service-scope**: "The features in the following sections all apply to service tokens, and their applicability to batch tokens is discussed later." Located in rendered text.
- **S021-title**: `<h1>Tokens</h1>`.
- **S021-version**: the rendered text "Concepts Tokens Version: Version 2.7.x On this page". The version dropdown also lists 2.7.x, Development, and 2.6.x.
- **Section headings:** "Token Time-To-Live, periodic tokens, and explicit max TTLs" and "Token type comparison" each appear 4 times in the raw HTML.

### Teaching status

Unchanged: in OpenBao 2.7.x's service-token context, non-root tokens carry a TTL, and when it expires the token and its associated leases are revoked.

The scope limits in SOURCES.md still hold:

- no Vault-token claim;
- no KV-retention claim;
- batch-token behavior stays separate.

## Clock — S035 feed https://github.com/openbao/openbao/releases.atom (accessed 2026-10-21T13:36Z)

| Field | Observed value |
|---|---|
| HTTP status | 200 |
| Body size | 506783 bytes |
| SHA-256 | `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f` |
| `etag` | `W/"1f0bb338e341cfe8eb797a20bb663285"` |
| Feed-level `<updated>` | 2026-10-01T13:32:54Z |
| Entries in feed | 10 |

Entries parsed with ElementTree, newest first:

| Updated | Release |
|---|---|
| 2026-10-01T18:32:18Z | **v2.7.1** (newest stable server tag) |
| 2026-10-01T13:59:14Z | v2.6.4 |
| 2026-10-01T13:24:26Z | api/v2.7.1 (module, excluded) |
| 2026-09-23T17:39:54Z | v2.7.0 |
| 2026-09-23T17:06:02Z | v2.6.3 |
| 2026-09-23T16:27:33Z | sdk/v2.7.1 (module, excluded) |
| 2026-09-23T16:18:59Z | sdk/v2.6.3 (module, excluded) |
| 2026-09-09T12:58:28Z | v2.7.0-beta20260909 (beta, excluded) |

- There is no v2.7.2, v2.8.x, or newer beta tag.
- Observed version 2.7.1 equals the anchored 2.7.1, so the verdict is `not-fired`. This matches `release-clocks.tsv:18`.

## Limitations (not passing checks)

- **Docs-only versioning:** the page identifies only the series "Version 2.7.x", not a patch version. A teaching edit inside 2.7.x without a new server tag would not fire this clock. Only the body-hash comparison above detects such an edit, and it is volatile across site rebuilds.
- **Feed window:** the feed holds only 10 entries. That is enough to establish the newest stable tag, but it is not a complete release history.
- **Normalizer:** the rendered-text-v1 digest was not reproduced, because the exact normalizer was not run.
- **Installs:** none.

## Actionable counterexamples

None found. The registered S021 row and the clock row need no superseding row this round. The round-25 receipt and lone-clone INCOMPLETE/48 are untouched.

Scratch files (`/tmp/clockS021/{tok.html,tok.hdr,feed.atom,feed.hdr}`) are outside the fleet and were not registered.
