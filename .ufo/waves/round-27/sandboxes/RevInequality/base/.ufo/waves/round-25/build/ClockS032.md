# ClockS032 — C3 release clock for S032

Seat KagiR25.ClockS032-2 · BASE 4587c61a348e4528717404a68912c373f3ef4d03 · observed 2026-10-21 (~10:37Z) · sandbox /fast/scratch/kagi-r25/ClockS032-2 (BASE clone, fetched bodies only; lane tree not written)

## Verdict
- Governing clock: **rendered-quote** (branch b). No feed governs S032.
- Clock result: **quote-located** (not fired).
- S032 teaches (capital-T integration-key sentence in both setup paths): **holds**.

## Governing identity
- Row anchor is "unversioned public guide" (corpus/SOURCES.md:38); recheck on-release.
- Visible text has no version and no date. `beta`/`preview` tokens sit only in title, nav, H1 (normalized offsets 99–1280) and one blog link (5518); none inside the setup instructions.
- Machine date only: JSON-LD `dateModified` (2 quoted hits) and RSC `pageMetadata.lastModified` (1 hit), all `2026-08-17T22:36:47.823Z`. Not a release identity. Raw body has no `"version"` or `datePublished` key.
- Feed branch rejected: the anchor names no version, so anchored_version would be `-` and "fired iff observed != anchored" would fire on any feed. The only release index found is multi-product (below).

## Proposed release-clocks.tsv line (9-column XReleaseClock schema, .ufo/waves/round-25/build-spec.json:25; tab-separated)
```
S032	rendered-quote	-	-	-	-	2026-10-21	quote-located	unversioned guide, no displayed version/date; machine lastModified 2026-08-17T22:36:47.823Z; locate count=2 (GitHub Actions and Custom Workflow OIDC panels), lowercase 0; raw sha256 67f690e2 (= 2026-10-21 capture); normalized f3861c17
```
Assignment field order: id S032 · clock rendered-quote · feed_url `-` (no feed; fetch target is the registry URL https://www.1password.dev/brokered-access) · anchored_version `-` · observed_version `-` · observed_at 2026-10-21 · verdict quote-located.

## Feed SOURCES candidate
- None bound to S032. No SOURCES row proposed.
- Opened and rejected: https://releases.1password.com/developers/ — HTTP 200, text/html, 47130 B, sha256 11fd01e43b68e53ffeaa616725c54595854614d497305770b49ffd4bc3639f0a, normalized 770cfec29e77cf5795dd78a9559d1840896ab3ed3c1c51e3183b7df1487df0e8 (2594 B). Entries: CLI 2.41.0 (Oct 12 2026), CLI beta 2.42.0-beta.01 (Oct 8), JavaScript SDK 0.5.0 (Jul 31), Go SDK 0.4.1 (Jul 29). Mixed products; no entry names the S032 guide, so the guide's wording does not follow these versions [INFERENCE].
- Reference line only, not for SOURCES.md: 1Password Releases, developer tools index — https://releases.1password.com/developers/ | docs | A | JavaScript SDK 0.5.0 Credential Broker workload identity (public preview, GitHub Actions) | entry "Updated to 0.5.0 on July 31 2026"; opened 2026-10-21 | “Version 0.5.0 introduces support for workload identity authentication through 1Password Credential Broker, currently available in public preview for GitHub Actions.” (JavaScript SDK entry; locate count=1, exit 0; 20 words)
- Seen, not feed candidates: https://blog.1password.com/index.xml (general blog feed); https://1password.com/developer-newsletter.

## Fetch evidence
All sandbox runs: `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`; curl 8.23.0.
1. `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o fetch/S032.body -w 'http=%{http_code} effective=%{url_effective} redirects=%{num_redirects} ctype=%{content_type} transfer=%{size_download}' https://www.1password.dev/brokered-access` → exit 0; `http=200 effective=https://www.1password.dev/brokered-access redirects=0 ctype=text/html; charset=utf-8 transfer=166493`. Decoded file 1199447 B.
2. `sha256sum fetch/S032.body` → 67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312 = source-fetches.tsv S032 raw digest and byte count.
3. `python3 corpus/rendered-text-v1.py --selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0.
4. `rendered-text-v1.py digest fetch/S032.body` → `normalized_sha256=f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9 normalized_bytes=6049`, exit 0 = source-fetches.tsv normalized digest.
5. `rendered-text-v1.py locate fetch/S032.body "The token value is your integration key"` → count=2, exit 0. Lowercase "the token value is your integration key" → count=0, exit 1.
6. Panel mapping (normalized char offsets): occurrence 3419 is in the GitHub Actions panel (after "Enter a name for the integration and the name of the GitHub organization…" at 3292, before "Enter a name for the integration, then enter your OIDC provider's issuer URL" at 3727). Occurrence 4327 is in the Custom Workflow (OIDC) panel (before "Delete an integration" at 4815).
7. Lane history (read-only grep): this URL's raw digest has taken three values: e4aef238… (S007, 2026-10-19, not reproduced; .ufo/waves/round-23/parent-build/SourceS007.md:136-150), 896c780b… (S019 pin, 2026-10-20; corpus/feature-claims.json:149), 67f690e2… (today). The lane records normalized f3861c17… for this URL (.ufo/waves/round-23/falsify/CritNormalizer.md:158-159), equal to today's. No 2026-10-20 body is retained, so that day's normalized digest cannot be recomputed here.
- Observation receipt (--observe shape): url https://www.1password.dev/brokered-access · http 200 · sha256 67f690e2… · bytes 1199447 · normalized f3861c17… · located 2 · utc 2026-10-21T10:37:07Z.

## S032 teaches verdict: holds
- Capital-T sentence present in both setup panels (count 2); lowercase form absent (count 0), so the S007 correction still stands.
- Guide-level H1 label "(public preview)" is unchanged. S032 asserts no status; the existing S019 reading (corpus/SOURCES.md:25: the guide-level preview label does not determine custom-workflow status) is not contradicted.

## For L1 (calibration, operability, freshness)
1. Calibration gap: the spec verdict requires count ≥ 1. S032 teaches "both integration setup paths", so a one-panel loss (2→1) still reads quote-located. Recommend the observer emit the count and S032's note carry expect=2, or narrow the "both" wording. Not implemented here.
2. Freshness gap: on-release never fires for an unversioned guide. The clock runs only when --observe is invoked, so observed_at=2026-10-21 ages. Recommend a re-observe cadence, or treating a changed machine lastModified as a forced re-locate trigger.
3. Operability: feed_url is `-` for rendered-quote, so --observe must read the URL from the SOURCES registry row, not the TSV.
4. Shared URL: S019 (corpus/SOURCES.md:25) registers the same URL with its own quote; one fetch can serve both rows. This fetch did not test S019's quote.
5. Do not treat raw-digest equality as drift: the raw digest changed three times in three days while dateModified did not.

## Tooling and UNRUN
- Installed or updated: nothing. Used existing git (sandbox clone and checkout only), curl 8.23.0, sha256sum, python3 stdlib, one web_search (not evidence; fetched bytes are the evidence).
- UNRUN: `release-clock.py --observe` (not in BASE; XReleaseClock builds it); `c3-measure.py`; all lane gates. No lane file written; release-clocks.tsv unchanged (L1 integrates).
