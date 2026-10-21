# ClockS032 — round 26 C1 freshness re-open of S032

Seat KagiR26.ClockS032 · observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`; worktree shows only untracked `.ufo/waves/round-26/` and `plans/round-26.md`) · observed 2026-10-21T13:36:49Z · sandbox `.ufo/waves/round-26/sandboxes/ClockS032/` (fetched body, headers, byte-identical copy of `corpus/rendered-text-v1.py`). Lane-authored advice, not non-author closure.

## Verdict (bounded)
- Governing clock (`corpus/release-clocks.tsv:29`): **rendered-quote**, no feed. Re-run result: **quote-located**, not fired.
- S032 teaching (`corpus/SOURCES.md:38`): the case-sensitive quote “The token value is your integration key” appears in both integration setup paths. **Holds this round, and the bytes are unchanged.** The raw digest equals the registered capture (`corpus/source-fetches.tsv:75`).
- The Python 3.15.1 drift instruction applies only to S027/S028. S032 is a 1Password guide with no Python dependency, so there is no 3.15.0 → 3.15.1 comparison for this row.
- No superseding row is needed. The registry facts for S032 (raw digest, normalized digest, quote, locator) all reproduce exactly.

## Source anchors
- URL: https://www.1password.dev/brokered-access, accessed 2026-10-21T13:36:49Z.
- Located quote (7 words, case-sensitive): “The token value is your integration key”.
  - Normalized offset 3419 is in the **GitHub Actions** panel. It comes after “Enter a name for the integration and the name of the GitHub organization…” (offset 3292) and before the OIDC panel opener (3727).
  - Normalized offset 4327 is in the **Custom Workflow (OIDC)** panel. It comes after “Enter a name for the integration, then enter your OIDC provider…” (3727) and before “Delete an integration” (4815).
- Lowercase form “the token value is your integration key”: count 0, exit 1. The S007 → S032 correction still stands.

## Commands and observed outputs
Fetches ran with `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home` and curl 8.23.0 (OpenSSL/3.6.5). Python ran with `PYTHONDONTWRITEBYTECODE=1`.
1. `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -D S032.headers.txt -o S032.body -w '…' https://www.1password.dev/brokered-access` → exit 0. Output: `http=200 effective=https://www.1password.dev/brokered-access redirects=0 ctype=text/html; charset=utf-8 transfer=166493`.
2. `sha256sum S032.body` → `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312`. `stat -c %s` → 1199447. Both equal `source-fetches.tsv:75`.
3. Response headers: `date: Wed, 21 Oct 2026 13:36:49 GMT`, `etag: W/"z6d2q9klrgppcp"`, `age: 46370`, `x-vercel-cache: MISS`, `cache-control: no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0`. There is no `last-modified` header.
4. `sha256sum` of the sandbox copy and of `corpus/rendered-text-v1.py` → both `7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf`.
5. `python3 rendered-text-v1.py --selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0.
6. `python3 rendered-text-v1.py digest S032.body` → `normalized_sha256=f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9 normalized_bytes=6049`, exit 0. This equals the registered normalized digest.
7. `locate S032.body "The token value is your integration key"` → `count=2`, exit 0. The lowercase variant → `count=0`, exit 1.
8. Machine dates in the body: `"dateModified":"2026-08-17T22:36:47.823Z"` appears 2 times and RSC `lastModified` 1 time. Neither changed since round 25, and neither is a release identity.
9. Corroboration (read only): `.ufo/waves/round-26/observe-1.json` (sha256 `9a1cefec…5b1e`) records S032 at `2026-10-21T13:36:38Z` as http 200, the same sha256 `67f690e2…`, `located: true`, verdict `quote-located`.

## Distinguishing unchanged teaching from clock limitations
- **Unchanged teaching (observed):** the raw bytes, normalized digest, quote count (2) and panel placement are all identical to the round-25 receipt (`.ufo/waves/round-25/build/ClockS032.md`). That receipt is preserved and not rewritten here.
- **Docs-only limitation:** the guide shows no version or date. The term “public preview” appears at normalized offsets 92–1280 (title, navigation, H1) and 5511 (a blog link), but never inside the setup instructions. S032 makes no status claim, and S019's guide-level preview reading is untouched. This fetch did not test S019's own quote.
- **Feed limitation:** S032 has no feed. Its `on-release` recheck can only fire through a manual or `--observe` re-locate, so freshness means re-observing it each round, as done here.

## Actionable counterexamples and gaps (for L1)
1. **Calibration gap, still open in BASE.** `corpus/release-clock.py:747` sets `located = bool(wanted) and wanted in normalized_page`, which is a boolean with no count. S032 teaches “both integration setup paths”. If the quote disappeared from one panel (2 → 1), the clock would still report `quote-located` while the row's “both” claim became false.
   - Counterexample construction (not run): delete one of the two sentences from a copy of `S032.body`. `rendered-text-v1.py locate` would then report count=1 with exit 0, and `release-clock.py` would report verdict `quote-located`.
   - Remedy options: record an expected count of 2 in S032's note and have the observer compare counts, or narrow the row's “both” wording.
2. **Stale-cache signal is not a drift signal.** The response was `x-vercel-cache: MISS` with `age: 46370` (about 12.9 hours) while the body was byte-identical. The raw digest has changed three times across rounds 23–25 with no change to `dateModified`. Raw-digest equality or inequality alone should not be treated as teaching drift.

## Tooling and UNRUN
- Installed or updated: nothing. I used the existing curl 8.23.0, sha256sum, python3 stdlib, and a sandbox copy of `corpus/rendered-text-v1.py`.
- No production or registry file was written. `release-clocks.tsv`, `SOURCES.md` and `source-fetches.tsv` are unchanged. No git or jj mutation.
- UNRUN: `release-clock.py --observe` (L1's `observe-1.json` was read, not re-run), `release-clock.py --selftest`, `sources-census.sh`, `claim-ledger.sh`, and every lane gate. No passing status is claimed for any of them.
