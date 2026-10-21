# ClockS023 — S023 freshness re-verification (round 26, C1)

Seat KagiR26.ClockS023 (leaf; no dispatch). Access 2026-10-21T13:36:44Z (UTC).
Observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`, read-only; equals frozen BASE; worktree shows only untracked `.ufo/waves/round-26/` and `plans/round-26.md`).
Writes: this report plus `.ufo/waves/round-26/build/ClockS023-artifacts/` (lease.html, lease.headers, lease.normalized.txt, vault-releases.atom, vault-releases.headers). Installs/updates: none. Production files untouched.

## Verdict
- **Clock not-fired; S023's teaching still holds; no drift.** S023 is a Vault row. The Python 3.15.1 drift (S027/S028) does not apply to it.
- Declared clock is `feed` via S034 `https://github.com/hashicorp/vault/releases.atom` (release-clocks.tsv:20, anchored 2.2.0, observed 2.2.0, not-fired). Today the newest stable tag is still **v2.2.0**, and today's feed bytes are byte-identical to the round-25 receipt's S023 record.
- No superseding row is warranted. The round-25 receipt is unchanged and was not rewritten.

## 1. Clock (feed) re-opened
- Command: `curl -fsSL --compressed -D …/vault-releases.headers -o …/vault-releases.atom -w 'url=%{url_effective} code=%{http_code} size=%{size_download}\n' https://github.com/hashicorp/vault/releases.atom`
  - Output: `url=https://github.com/hashicorp/vault/releases.atom code=200 size=303995`. Headers include `date: Wed, 21 Oct 2026 13:36:37 GMT` and `etag: W/"e41bc5793403136a07c68d7d107fe3e9"`.
  - sha256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`. This equals the S034 fetch row (source-fetches.tsv:77) and the round-25 receipt's S023 record.
- Round-25 receipt `.ufo/waves/round-25/observe-1.json`, sha256 `b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92`, equals `DEFAULT_RECEIPT_SHA256` (release-clock.py:28). Its S023 record reads:
  - `{"clock":"feed","http_status":200,"id":"S023","located":null,"observed_at":"2026-10-21T11:31:53Z","parsed_version":"2.2.0","sha256":"e41bc579…","url":"…/releases.atom","verdict":"not-fired"}`
  - Today's bytes are the same, so the historical observation is reproduced exactly.
- Atom parse (stdlib ElementTree, first 10 entries): `v2.2.0 2026-10-15T18:50:14Z`, `v2.2.0-rc1`, `v2.1.2`, `sdk/v0.26.0`, `v2.1.1`, `v2.1.0`, …
  - The newest stable `^v\d+\.\d+\.\d+$` tag is v2.2.0. No stable entry is newer than the anchor.
  - The feed-level `<updated>` is `2026-10-14T19:24:08Z`, earlier than the newest entry's `<updated>`. That field is not a usable feed-freshness signal; read the entries.
- UNRUN: `corpus/release-clock.py` (production verification is L1-only). My version reading is a manual parse, not the instrument.

## 2. Source page re-opened (corroboration, not the governing clock)
- Command: `curl -fsSL --compressed -D …/lease.headers -o …/lease.html -w … https://developer.hashicorp.com/vault/docs/concepts/lease`
  - Output: `code=200 size=40413` (compressed transfer), no redirect. Headers: `date: Wed, 21 Oct 2026 11:02:50 GMT`, `age: 9234`, `x-vercel-cache: HIT`, `etag: W/"8sgi8uynwf5lvi"`. This was a CDN copy cached about 2.6 h earlier.
- `python3 corpus/rendered-text-v1.py digest …/lease.html` → `raw_sha256=492ffb3c2ae8e65daa89aabae99e93b80b3081d46b3e2cdee2a61bffe0efafde bytes=261632 normalized_sha256=0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76 normalized_bytes=7354`
  - Normalized digest: **equal** to source-fetches.tsv:50 (`0e62e056…`).
  - Raw digest: differs from both the row's `de5f8836…` and round-25's `ac99140f…`, at the same 261632 bytes. This is the third distinct raw value. Under the declared `decoded-http-body-volatile-v1`, raw bytes are a point attestation, not a drift input.
- JSON-LD: `"datePublished":"2026-04-15T00:14:52.000Z"` and `"dateModified":"2026-04-15T00:14:52.000Z"`, the same as round 25. No newer page edit is declared.

## 3. Teaching — located quotes (rendered-text-v1 `locate`)
| Anchor (SOURCES.md:29) | Quote (≤25 words) | count |
|---|---|---|
| H1 Lease, renew, and revoke | “Lease, renew, and revoke” | 2 |
| Dynamic-secret and service-token lease | “With every dynamic secret and service type authentication token, Vault creates a lease” | 1 |
| Dynamic-secret lease requirement (source-fetches.tsv:50 quote) | “All dynamic secrets in Vault are required to have a lease.” | 1 |
| KV note | “The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration” | 1 |
| Served version route | “v2.x (latest)” | 2 |
| Edit this page link | raw `content/vault/v2.x/content/docs/concepts/lease.mdx` | 1 (grep -c on raw HTML) |

The version switcher still lists `v2.x (latest) v1.21.x … v1.16.x`. The row's scope holds as written: the lease mechanism, the KV no-lease note, and a locator that names only the served route. Its stated limits also still apply: a v2.x route is not deployment proof, and a lease-duration note is not a KV retention guarantee. This report checks only these six anchors, not the whole page.

## 4. Counterexamples and caveats (actionable)
1. **Phrase-literal check trap.** The literal string `service token` occurs 0 times in the rendered text. The page says “service type authentication token”. A mechanical locator keyed on the SOURCES scope wording "service-token" would wrongly report quote loss. Use the located quote in §3.
2. **Raw-HTML grep trap.** The KV sentence has 0 literal matches in the raw HTML (`grep -c`) but 1 after rendered-text-v1 normalization, because of intervening markup. Only the declared normalizer should be used for quote location.
3. **Feed blind spot.** A docs-only edit to the lease page under v2.x would not fire this feed clock; only a new stable Vault tag would. Today the rendered-text digest and dateModified both show no such edit. That is a single point observation, not monitoring.
4. **CDN staleness.** The page body was a cache HIT with `age: 9234`, so "opened today" means the CDN copy as of 11:02:50 GMT, not origin.
5. **Raw digest churn.** The source-fetches.tsv:50 raw digest has not been reproducible on two consecutive days, with three distinct values. Only the normalized digest is a stable identity for this row.

## 5. Scope and handoff
- Inspected: SOURCES.md:29, release-clocks.tsv:20, source-fetches.tsv:50 and :77, release-clock.py:28 and :450, `.ufo/waves/round-25/observe-1.json` (S023 record), and `.ufo/waves/round-25/build/ClockS023.md`. Public URLs fetched: the two above only.
- Python S027/S028 3.15.1 comparison: not applicable to this row; owned by the Python seats.
- Proposed new-receipt S023 record for L1: id S023, clock feed, url `https://github.com/hashicorp/vault/releases.atom`, parsed_version 2.2.0, sha256 `e41bc579…70ba`, verdict not-fired, observed 2026-10-21T13:36:37Z (feed `date` header).
- L1 checks to run after integration: `python3 corpus/release-clock.py --root .`, then the new-receipt observe/check path.
