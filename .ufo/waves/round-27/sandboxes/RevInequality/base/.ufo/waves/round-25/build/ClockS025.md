# ClockS025 — C3 release clock, S025 (OpenBao JWT/OIDC)

Seat KagiR25.ClockS025-2 (scout, leaf). Lane kagi-shokunin, BASE 4587c61a348e4528717404a68912c373f3ef4d03 (`git rev-parse HEAD`; untracked: .ufo/waves/round-25/, plans/round-25.md). Observed 2026-10-21 10:36–10:40 UTC. Sandbox /fast/scratch/kagi-r25/ClockS025. Installs: none. Lane files: read-only.

## 1. Governing identity: (a) feed
- Page is a versioned docs build: `docusaurus_version` 2.7.x, badge "Version: Version 2.7.x", version menu 2.7.x (current) / 2.6.x / 2.5.x, source link `…/blob/release/2.7.x/…` (page body). Maintainer repo linked from the page: github.com/openbao/openbao.
- Governing identity: OpenBao server v-tags on that repo; the anchor's "Version 2.7.x" is the 2.7.N line.
- Rendered-quote clock not chosen; checked anyway (§2): located.

## 2. Fetch evidence — S025 page (SOURCES.md:31, source-fetches.tsv:52)
- `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o s025-body.bin -w '%{http_code} %{url_effective}' https://openbao.org/docs/auth/jwt/` → exit 0; `200 https://openbao.org/docs/auth/jwt/` (no redirect); Date 2026-10-21 10:36:55 GMT; Last-Modified 2026-10-20 07:50:18 GMT; wire 13325 B.
- decoded sha256 `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9`, 63046 B = source-fetches.tsv:52 (match).
- Declared-profile UA (round-23 string, source-fetches.tsv:14-15): identical sha and bytes.
- `python3 corpus/rendered-text-v1.py digest` → normalized_sha256 `ca496ad8…a403`, normalized_bytes 15942 (= row), exit 0.
- `… locate <body> "The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT"` → count=1, exit 0.
- `… --selftest` under `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home` → PASS (cases=22), exit 0.

## 3. Feed evidence — release identity
- Feed https://github.com/openbao/openbao/releases.atom: HTTP 200, url_effective unchanged, decoded sha256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`, 506783 B; both hashed copies identical under the two UAs (3 fetches, all 200).
- Tags from `<link href=…/releases/tag/TAG>` in the 10 entries: product stable v2.7.1 (Atom updated 2026-10-01T18:32:18Z), v2.6.4, v2.7.0, v2.6.3. Excluded: sub-modules api/v2.7.1, api/v2.7.0, sdk/v2.7.1, sdk/v2.7.0, sdk/v2.6.3; prerelease v2.7.0-beta20260909.
- REST corroboration (10:36Z): `/releases/latest` → 200, tag v2.7.1, published_at 2026-10-01T14:03:19Z (Atom has no publish time), prerelease false. `/releases?per_page=12` → 200, top v2.7.1, no 2.8 stable or prerelease.
- Verdict: observed v2.7.1 was published 2026-10-01, before the row opened 2026-10-21, so the anchor already covers it: **not-fired**.

## 4. Operability findings (for L1)
- O1 REST quota exhausted host-wide: `/releases/tags/api%2Fv2.7.1` → HTTP 403 "API rate limit exceeded" (shared egress); x-ratelimit-reset 1792581901 = 2026-10-21T11:25:01Z. A REST-only clock cannot observe now; the Atom feed returned 200 every time.
- O2 Titles ≠ tags: entry title "api/v2.7.1: Add changelog entry for v2.7.1 CVE fixes" is a published release (tag page HTTP 200). The clock must parse the tag from the link href, never the title.
- O3 `releases/latest` is sorted by commit date, not publish date (docs.github.com/en/rest/releases/releases, HTTP 200: "sorted by the created_at attribute"), so it can return a sub-module tag. Not used.
- O4 corpus/sources-census.sh:191 kind enum excludes `feed`; proposed kind `code`.
- O5 rendered-text-v1 leaves escaped `<code>` as literal text (rendered-text-v1.py:65-75; entities decoded after tag removal), so the Atom quote "Prevent disclosure of tls_acme_eab_mac_key" → count=0. The feed row uses raw-literal-v1 with the byte-located `<title>v2.7.1</title>` (count=1).

## 5. Proposed release-clocks.tsv (header + line; tab-separated)
```
id	clock	feed_url	anchored_version	observed_version	observed_at	verdict
S025	feed	https://github.com/openbao/openbao/releases.atom	2.7.x	v2.7.1	2026-10-21	not-fired
```
Rule for release-clock.py: tag = percent-decoded segment after `/releases/tag/` in each entry's link; product = fullmatch `v(\d+)\.(\d+)\.(\d+)`; observed = max semver. Fired iff max > recorded observed_version; `2.7.x` classifies a fired event (same-series patch vs new series 2.8+). Unreachable or unparsable feed → UNRUN, never not-fired. A fired row is re-verified and receipted, not silently re-pinned. Bind check: feed_url must equal a registered SOURCES URL with a fetch row.

## 6. SOURCES candidate (S033 placeholder; L1 assigns the final id)
```
| S033 | OpenBao release-notes Atom feed — https://github.com/openbao/openbao/releases.atom | code | A | OpenBao server v-tag releases for the 2.7.x docs series named by S025; api/ and sdk/ sub-module tags and prerelease tags excluded | Atom entry 1 link tag v2.7.1 and updated 2026-10-01T18:32:18Z; feed titled "Release notes from openbao"; opened 2026-10-21 | Newest stable OpenBao server release in this feed is v2.7.1 (updated 2026-10-01); no newer stable tag or 2.8 series as of 2026-10-21. Quote: “<title>v2.7.1</title>” (entry 1, raw bytes). | mined | 2026-10-21 | on-release | corpus/release-clocks.tsv |
```
Fetch row (16 tab-separated columns; row_identity_sha256 = sha256 of `S033<TAB>mined<TAB>URL<LF>`):
```
S033	mined	1c37ce81943e97019a7dfde1b337017147f8507c5b6ca845b27f8767f7ac10ad	https://github.com/openbao/openbao/releases.atom	https://github.com/openbao/openbao/releases.atom	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f	506783	-	<title>v2.7.1</title>	raw-literal-v1	-	Atom feed entry 1 (link tag v2.7.1; updated 2026-10-01T18:32:18Z)
```
Checks: the census enum awk (sources-census.sh:191 program) on a sandbox copy of the two rows (/fast/scratch/kagi-r25/ClockS025/proposed-rows.md): S033 → no output; control S034 with kind `feed` → `kind S034 feed`, exit 0. Both rows NF=13. Fetch row: 16 columns (awk -F'\t'). Recompute the identity hash if the id changes.

## 7. Teaches verdict: S025 HOLDS, not fired
- Quote located (count=1); normalized sha reproduces.
- Anchor sections present (rendered headings): H1 "JWT/OIDC auth method", H2 "JWT authentication", H3 "JWT verification", H3 "Bound claims", H3 "Claims as metadata", H2 "Configuration".
- "optionality lives in §Claims as metadata": section says "Claim mappings which do not begin with a / are optional." Holds.
- "renders the method name as code": raw `<code>jwt</code>` ×2. Holds.
- v2.7.1 release body names no `auth/jwt` change; its JWT-matching lines are auth/approle, auth/cert, auth/kubernetes. (The kubernetes renewal fix GHSA-gf3j-hm38-jhh5 concerns the Kubernetes auth method; a note for the S015 clock owner, not S025.)
- Lesson recheck text (corpus/lessons/round-23.md:3: "when a release or docs version route changes"): route still 2.7.x; no 2.8.x in the menu.
- Source fetch row S025 (source-fetches.tsv:52) needs no restamp.

## 8. UNRUN / limits
- Complete REST listing (per_page=100) and the REST tag lookup: UNRUN (403 until 11:25:01Z). The verdict rests on the 10-entry Atom window and the 12-entry REST list; a newer tag would sort to the top of the updated-desc Atom window, but a complete listing is UNRUN.
- Not written (lane read-only): corpus/release-clocks.tsv, release-clock.py, SOURCES/source-fetches rows. Proposed text is above.
- `sources-census.sh validate` on the lane tree: not run (contract). Only the enum awk above, on sandbox rows.
- Pointers: SOURCES.md:31; source-fetches.tsv:14-15, :52; rendered-text-v1.py:65-75; sources-census.sh:191; lessons/round-23.md:3, :28; build-assignments.json:40.
