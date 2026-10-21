# ClockS013 — round 26 C1 freshness re-verification (scout, lane-authored advice)

Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE).
Working tree at observation: only `?? .ufo/waves/round-26/` and `?? plans/round-26.md` untracked.
Production files read only; no registry/production writes; no tool installs.

## Result (bounded)

S013's declared clock did **not fire**, and the five teaching sentences bound to S013 still locate
exactly once each in a fresh capture. The rendered-text-v1 normalized digest reproduces the
recorded capture byte-for-byte. One calibration counterexample, already superseded in the
registry, survives in the clock note (see Counterexamples). The Python 3.15.1 / S027/S028 part of
the assignment does not apply to this row: S013 is the Vault lease page, so no Python
documentation was opened.

## Rows inspected

- `corpus/SOURCES.md:19` S013: Vault lease page, anchor "§Lease, renew, and revoke; current Vault docs have no displayed version/date, opened 2026-10-19", recheck `on-release`.
- `corpus/SOURCES.md:29` S023: supersedes S013's "categorical no-displayed-version locator"; retains the lease/KV mechanism.
- `corpus/release-clocks.tsv:10`: `S013 feed S034 https://github.com/hashicorp/vault/releases.atom 2.2.0 2.2.0 2026-10-21 not-fired derived: anchor says no displayed version; newest stable Vault when the row was opened 2026-10-19 (v2.2.0, 2026-10-15)`.
- `corpus/source-fetches.tsv:66`: recorded raw `ac99140f11ac…` 261632 B, normalized `0e62e05612ea…`, profile `curl-fsSL-compressed-v1`.
- `corpus/inrow-pins.tsv:19`: S013 in-row pin `ae321512d37a…` is `non-reproducing`.

## Clock: S034 feed (accessed 2026-10-21T13:36:37Z)

Command: `curl -sSL --compressed -D feed.headers -o feed.atom https://github.com/hashicorp/vault/releases.atom`
- HTTP 200, final URL unchanged, `content-type: application/atom+xml; charset=utf-8`, `etag: W/"e41bc5793403136a07c68d7d107fe3e9"`.
- Body sha256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`. This is **identical** to the S013 feed sha in `.ufo/waves/round-25/observe-1.json` (observed 2026-10-21T11:31:50Z) and in `.ufo/waves/round-26/observe-1.json` (observed 2026-10-21T13:36:33Z).
- Repo parser, run offline on that file: `corpus/release-clock.py` `parse_latest_version(feed.atom)` → `2.2.0`.
- Independent Atom parse: 10 entries, 8 stable `vX.Y.Z` titles. The newest is `v2.2.0` (updated 2026-10-15T18:50:14Z, link `/releases/tag/v2.2.0`), then v2.1.2 and v2.1.1. The non-stable entries are `v2.2.0-rc1` and `sdk/v0.26.0`, which the parser correctly excludes.
- Verdict: anchored 2.2.0 = observed 2.2.0, so **not-fired**. The verdict is unchanged from the round25 receipt.

## Source: S013 page (accessed 2026-10-21T13:36:36Z)

Command: `curl -sSL --compressed -D lease.headers -o lease.html https://developer.hashicorp.com/vault/docs/concepts/lease`. This omits the `-f` of `curl-fsSL-compressed-v1`, which makes no difference on a 200.
- HTTP 200, final URL unchanged, `content-type: text/html; charset=utf-8`, `etag: W/"8sgi8uynwf5lvi"`, `x-vercel-cache: HIT`, `age: 9225`, `date: Wed, 21 Oct 2026 11:02:50 GMT`. The served copy is a CDN cache entry from about 11:02Z, so it is not an origin render at 13:36Z.
- Wire bytes were 40413 (compressed). `python3 corpus/rendered-text-v1.py digest lease.html` → `raw_sha256=492ffb3c2ae8e65daa89aabae99e93b80b3081d46b3e2cdee2a61bffe0efafde bytes=261632 normalized_sha256=0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76 normalized_bytes=7354`.
  - The raw sha differs from both the recorded `ac99140f…` and the in-row pin `ae321512…`. The decoded size of 261632 B is the same as recorded, which fits the declared `decoded-http-body-volatile-v1` behaviour (for example, the Next.js `buildId` is `build-TfctsWXpff2fKS`).
  - The **normalized sha `0e62e056…` equals the recorded value exactly**, so the regex-normalized visible text is unchanged since the recorded capture.
- `rendered-text-v1.py locate` counts in the fresh capture:

| quote (≤25 words) | count |
|---|---|
| "All dynamic secrets in Vault are required to have a lease." (S013 row and feature-claims `S013-dynamic`) | 1 |
| "Lease, renew, and revoke" (H1 `id="lease-renew-and-revoke"`; the second hit is the "On this page" table of contents) | 2 |
| "every dynamic secret and service type authentication token" | 1 |
| "invalidates that secret immediately" | 1 |
| "all leases that were created using that token" | 1 |
| "completely advisory" | 1 |
| "The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration" | 1 |
| "v2.x (latest)" | 2 |

- The Edit link is `https://github.com/hashicorp/web-unified-docs/blob/main/content/vault/v2.x/content/docs/concepts/lease.mdx`, which matches S023's anchor. The embedded version list has `{"name":"latest","label":"v2.x (latest)","isLatest":true,"releaseStage":"stable"}`, then v1.21.x and older.

**Teaching still holds (bounded):** the page still says Vault requires leases on dynamic secrets and service tokens, revoking a token revokes its leases, renewal increments are advisory, and the KV backend does not issue leases. This covers exactly the sentences listed above, as matched by a regex normalizer. It is not whole-page or browser-rendered coverage, and it does not support a KV retention or expiry guarantee (`knowledge/vault-openbao-token-lease-lifecycle.md:110` already bounds this).

## Counterexamples and calibration (actionable, advisory)

1. **The clock note's derivation cites a withdrawn locator.** `release-clocks.tsv:10` justifies `anchored_version=2.2.0` with "anchor says no displayed version". The fresh capture shows a version-switcher label `v2.x (latest)` (count 2 in normalized text, inside `<span>` on the switcher button). Because the normalized digest equals the recorded one, that label was also present in the recorded capture.
   - S023 (`SOURCES.md:29`, `lessons/round-22-source-errata.md:26`) already withdraws this locator, so this is not new drift.
   - The note is literally true as a quotation of S013's anchor column, but it reads as a live fact.
   - Suggested L1 wording (no production edit made): `derived: S013 locator withdrawn by S023 (page displays v2.x (latest)); newest stable Vault when the row was opened 2026-10-19 (v2.2.0, 2026-10-15)`. Compare S024's note, which already says "served v2.x (latest) route".
2. **Feed and docs granularity.** The feed resolves a patch release (2.2.0), but the page declares only a series (`v2.x`). A not-fired feed therefore does not prove the docs are unchanged, and a docs-only edit inside v2.x would not fire the clock. The equal normalized digest is today's only docs-side unchanged evidence, and it is a point attestation from a CDN cache HIT (age 9225 s), not monitoring.
3. **Pin status.** The in-row pin `ae321512…` is still non-reproducing against fresh raw bytes (`492ffb3c…`), which matches `inrow-pins.tsv:19`. It should stay a historical attestation, never a drift signal.

## Scope not inspected

- Python S027/S028 and 3.15.1 documentation: out of scope for this row.
- No other S013 page sections were opened beyond the located sentences (for example, §Lease IDs and §Prefix-based revocation).
- No browser rendering.
- No build, lint or tests run.

Supporting artifacts: `.ufo/waves/round-26/build/ClockS013-evidence/` (`lease.html`, `lease.headers`, `feed.atom`, `feed.headers`).
