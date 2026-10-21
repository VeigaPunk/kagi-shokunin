# ClockS017 — round 26 C1 freshness re-verification for S017

Seat `KagiR26.ClockS017` · lane `kagi-shokunin` · observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`, exit 0; equals the frozen BASE; tree has only the untracked `.ufo/waves/round-26/` and `plans/round-26.md`) · observed 2026-10-21T13:36:42Z–13:37:41Z · installs: none · subagents: none · production edits: none.
Axes: freshness (re-open the source this round, against the declared clock) and calibration (claim only what the bytes show).

## Verdict

S017's clock stays **quote-located / not-fired**. Both parts of the row's teaching **still hold** on the page served today. The page bytes are **byte-identical** to the recorded capture and to the round-25 observation, so nothing has drifted. This is a **same-day Cloudflare copy**, not proven origin state (see the freshness limit below). S017 is not a Python row, so the S027/S028 Python 3.15.1 work does not apply to it.

## Target rows (BASE)

- `corpus/SOURCES.md:23` — S017, `https://www.1password.dev/brokered-access/github-actions/`, docs/A, anchor "Page title and introduction, unversioned live docs opened 2026-10-20". Teaches: "GitHub Actions is public preview; an administrator first connects the organization to a 1Password Business account." recheck `on-release`.
- `corpus/release-clocks.tsv:14` — `S017 rendered-quote - - - - 2026-10-21 quote-located` with the note "unversioned guide; JSON-LD dateModified is metadata, not a release identity".
- `corpus/source-fetches.tsv:44` — declared capture: raw sha256 `62953bb4…478d`, 1215460 bytes, normalized (`rendered-text-v1`) sha256 `2a39cb16…81c7`. Quote "Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)", locator "page title/H1".

## Fetch evidence (public primary URL only)

1. `curl -fsSL --compressed -D …/s017.headers -o …/s017.html -w '…' https://www.1password.dev/brokered-access/github-actions/` → exit 0. Response: `HTTP/2 308` (location `/brokered-access/github-actions`), then `HTTP/2 200`, redirects=1. `content-type: text/html; charset=utf-8`, `content-encoding: br`, `etag: W/"3f11lj35pfq1q0"`, `x-served-version: dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`, `cf-cache-status: HIT`, `age: 46341`, `date: Wed, 21 Oct 2026 13:36:42 GMT`, `x-vercel-cache: MISS`. `size_download=164494` is the compressed transfer size.
2. Cache-busting attempt: the same URL plus `?r26=ClockS017-20261021`, with `Cache-Control: no-cache` and `Pragma: no-cache` → exit 0, 308 then 200. Still `cf-cache-status: HIT`, `age: 46399` at 13:37:41 GMT, same etag and deployment id, and identical digests.
3. `python3 corpus/rendered-text-v1.py digest …/s017.html` → `raw_sha256=62953bb47db1af593c522b06c4f12c6a89853dd0a8fb718118189349213f478d bytes=1215460 normalized_sha256=2a39cb1691b24f492dd4ad5a126538df35f865c15cd5f46a35e405a5282781c7 normalized_bytes=5577`. This equals `source-fetches.tsv:44` and the round-25 receipt `.ufo/waves/round-25/observe-1.json` (S017 sha256 `62953bb4…`, `located: true`, 2026-10-21T11:31:52Z).
4. Normalizer identity: `sha256(corpus/rendered-text-v1.py)` = `7d6bfe81…c7bf`, the same as the round-25 report's value.
5. Page metadata: JSON-LD `"dateModified":"2026-08-04T15:42:17.097Z"` (2 occurrences). `<title>` = H1 + " - 1Password Developer". This is metadata only, unchanged since round 25.

Artifacts are in `.ufo/waves/round-26/sandboxes/ClockS017/`: `s017.html`, `s017.headers`, `s017-bust.html`, `s017-bust.headers`, `s017.normalized.txt` (sha256 `2a39cb16…81c7`).

## Located quotes (`rendered-text-v1 locate`; exit 0 = located, 1 = missing)

| Quote (each ≤25 words) | Anchor | count |
|---|---|---|
| "Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)" | title, nav, body H1 | 3 |
| "If an administrator has connected your GitHub organization to your 1Password Business account" | introduction | 1 |
| `feature-claims.json:108` S017-runtime, as stored with an ASCII `'` | introduction | **0** |
| the same text with U+2019 "organization’s" | introduction | 1 |
| Controls: H1 with "(generally available)"; H1 with "(public beta)"; "to your 1Password Enterprise account" | — | 0 / 0 / 0 |

The controls miss, so the locator would fire if the status or plan changed.

## Teaching status

- **"GitHub Actions is public preview": holds.** The page's own H1 reads "(public preview)". The only version-like phrase is the generic "latest version of the 1Password desktop app" (count 1). It names no Broker release identity.
- **"an administrator first connects the organization to a 1Password Business account": holds as a precondition.** The located introduction is conditional ("If an administrator has connected…, you can use…"). The word "first" is an ordering reading [INFERENCE]; round 25 recorded the same point.
- **Change type:** none. There is no docs-only edit (identical raw bytes) and no feed movement (S017 has no feed; `feed_source_id` is `-`). The `rendered-quote` clock limits apply: it detects only removal or rewording of the one H1 quote.

## Counterexamples and gaps (still open; none rewrite historical receipts)

1. **The clock covers only half the teaching (known since round 25, still open).** `release-clock.py:735-750` locates only the single `source-fetches.tsv` quote, which is the H1. The Business-account prerequisite has no locator. A page that kept the H1 but changed "Business" to "Enterprise" would still read `quote-located`. I did not construct a mutated page; the control above shows only that the Enterprise wording is absent today. The fix route already recorded is a second locator for multi-claim unversioned rows (`corpus/README.md:192`, round-25 lesson "FClockS017/S020"). L1 owns any schema change.
2. **The S017-runtime quote does not locate under `rendered-text-v1` (known since round 23, still open).** `feature-claims.json:108` stores an ASCII apostrophe, but the page serves U+2019. This was first recorded in `.ufo/waves/round-23/parent-build/SourceS017.md:144-156` (fix options: declare the `.md` representation, add a folding step, or re-quote via a QM14 migration). Today's capture confirms it: count 0 for ASCII, 1 for U+2019. Impact is latent, because `feature-claims.py:359-361` checks only type and ≤25 words and never locates the quote. Risk: any future gate that locates catalog quotes will fail S017's required `fact` evidence.
3. **Freshness is limited by the CDN.** Both responses were Cloudflare HITs. Their `date − age` gives about 2026-10-21T00:44:21Z, the same stored object that round 25 saw (00:44:22Z). Query-string and no-cache headers did not bypass it. The observation is therefore same-day CDN state, not origin-current state.

## Proposed (advice only, L1 integrates)

- Receipt line for the new round-26 receipt: `S017 rendered-quote` · located=true · http 200 · sha256 `62953bb47db1af593c522b06c4f12c6a89853dd0a8fb718118189349213f478d` · verdict `quote-located` · observed 2026-10-21T13:36:42Z.
- No superseding registry row is needed: no immutable fact changed.

## Not run

- `corpus/release-clock.py --observe` and any gate (census, claim-ledger, verify, selftests): not run. They are L1-only after integration.
- No feed fetch, because none is bound to S017. No sitemap or changelog fetch, because this round was scoped to the exact source URL. No vault, account or CDP contact.
