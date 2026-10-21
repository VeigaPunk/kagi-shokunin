# ClockS018 — S018 per-row release clock (round-25 C3)

Seat KagiR25.ClockS018-2 · revision 4587c61a348e4528717404a68912c373f3ef4d03 (lane HEAD = BASE; `git log -1 -- corpus/SOURCES.md` and `-- corpus/source-fetches.tsv` = 277a0d4) · observed 2026-10-21 10:36–10:43 UTC · sandbox /fast/scratch/kagi-r25/ClockS018-2 · lane not written.

## Verdict
- Governing clock: **rendered-quote (b)**. SOURCES.md:24 anchors S018 as "unversioned live docs opened 2026-10-20" and names no version, so no feed clock can bind "the version the anchor names". The page carries no product version. Its only page-level date is JSON-LD `dateModified` 2026-08-17T22:36:47.822Z (a page-modification stamp, recorded, not used). The response header `x-served-version: dpl_8AUWT8…` is hosting deploy infrastructure, rejected.
- Clock result: title quote located in the fresh normalized text, `count=3`, exit 0 → **not-fired**. Nothing changed: decoded sha256 and normalized sha256 equal source-fetches.tsv:45.
- S018 teaches still holds: **yes**. Each of the four components is located in the fresh page and in the origin markdown export (table below).

## Proposed release-clocks.tsv line (TAB-separated; columns id, clock, feed_url, anchored_version, observed_version, observed_at, verdict)
S018	rendered-quote	https://www.1password.dev/brokered-access/custom-workflow/	-	-	2026-10-21	not-fired
Quote to locate: source-fetches.tsv:45 column 13 "Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)" (locator: page title/H1). feed_url is the registered URL (source-fetches.tsv:45 column 4). No version exists on this page, so anchored and observed version are `-`.

## S018 teaches vs fresh page
| teaches component | fresh HTML, `rendered-text-v1.py locate` (exit 0) | origin markdown export (llms-full.txt) |
|---|---|---|
| public beta | title quote, count=3 (normalized offsets 0, 588, 1263) | H1 "… (public beta)" |
| OIDC provider connected in Business | "connected an OIDC provider to your 1Password Business account", count=1 (intro) | same sentence, link markup |
| beta desktop app | "latest beta release of the 1Password desktop app", count=1 (Step 1) | same, Step 1 |
| only JavaScript SDK | "1Password Credential Broker is only supported in the 1Password JavaScript SDK at this time.", count=1 (Step 3) | `<Note>` in Step 3, same sentence with link markup |

## Fetch evidence (commands and exit codes)
1. `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' https://www.1password.dev/brokered-access/custom-workflow/` → exit 0; 308 then HTTP 200; effective `https://www.1password.dev/brokered-access/custom-workflow`; wire 167892 B; decoded 1283173 B; decoded sha256 a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450 = source-fetches.tsv:45 column 10 (identical). Run under `env -i`.
2. `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest final.html` → exit 0; `raw_sha256=a06175… bytes=1283173 normalized_sha256=d493bd815016219da8da33e18fb673aed3414155c6634a9139c7083ba7bae0fc normalized_bytes=6423` = TSV column 15 (identical). Run under `env -i`.
3. `… locate final.html "<title quote>"` → exit 0, `count=3`. Negative control (title + " - nonexistent control phrase") → exit 1, `count=0`. `--selftest` → `PASS (cases=22)`, exit 0. Run under `env -i`.
4. `cmp` lane corpus/rendered-text-v1.py vs sandbox copy → exit 0 (identical). Run under `env -i`.
5. Round-23 UA declared at source-fetches.tsv:14-15 → exit 0, decoded sha256 identical; `vary: User-Agent` is sent but the body is not UA-dependent here. Default environment.
6. CDN: HTML response `cf-cache-status: HIT`, `age: 35540` at 10:36:41Z (object stored ≈00:44Z). Cache-busted `?r25clock=` returned the same object (`age: 35584`). The HTML alone therefore does NOT prove origin freshness. Default environment.
7. `https://www.1password.dev/llms-full.txt` → exit 0, 2266728 B, sha256 d2c482f2125f0ead6f32b417be092f7d8ce1ea854ddf7f4b800241a216ef5bfd, `last-modified` 10:39:21Z; S018 markdown at offset 65517 carries the same claims. `https://www.1password.dev/llms.txt` → exit 0, 13438 B, sha256 745211d776963432cb9a75275b6b6ae0ae190d0db99bee8e0ad888f401954136, `cf-cache-status: EXPIRED` (origin revalidated 10:38:11Z), no custom-workflow entry. Default environment.
8. `https://api.github.com/repos/1Password/onepassword-sdk-js/releases/latest` → curl exit 22, HTTP 403 (API unusable from this host; Atom feed used instead). Default environment.

## Feeds opened (cross-check only; none binds S018)
- releases.1password.com/developers/ (200, 11443 B, sha256 11fd01e43b68e53ffeaa616725c54595854614d497305770b49ffd4bc3639f0a): JavaScript SDK card "Updated to 0.5.0 on July 31 2026"; no custom-workflow or OIDC text.
- github.com/1Password/onepassword-sdk-js/releases.atom (200, 26186 B, sha256 315dc118cf9e4ebff304789d0086d9c7654abb11df86f37f10c3b0cb2240553b): newest entry "Release 0.5.0" updated 2026-07-31T16:56:29Z; prior 0.4.1 2026-07-30T15:44:11Z; 0.5.0-beta.1 2026-06-16T21:19:02Z.
- github.com/1Password/onepassword-sdk-go/releases.atom (200, 25784 B, sha256 b573278a9241b3ab5e79fa8c5604a9d26129cb60b9728cbce3a6a9388cd3b267) and …-python/releases.atom (200, 21230 B, sha256 ea7dbec3ad11c569d44b95c6d5fb6de692d67e25323c44a20e0e1d009be580cc): newest "Release 0.4.1" 2026-07-30T13:36:33Z and 2026-07-30T13:55:31Z; zero Credential Broker, workload-identity or OIDC matches in their 10 newest entries. The "only JavaScript SDK" sub-claim is not contradicted.
- 1password.com/blog/index.xml (200, 321590 B, sha256 5cb7f6950f9e8945fa926107b66bbd2a46dd57c67ed2a3485138632ca0f85be4, 100 items): Credential Broker items are only 2026-07-28 (public preview) and 2026-06-15 (introducing); none newer.

## SOURCES-row-ready candidates (IDs for planner; next free S033; access date 2026-10-21; tier A = official vendor/maintainer feed)
- S0xx | 1Password Releases — Developers — https://releases.1password.com/developers/ | feed | A | 1Password developer-tool release cards (JavaScript, Go, Python SDK) | §Developer tools, JavaScript SDK card "Updated to 0.5.0 on July 31 2026" | Quote: "Version 0.5.0 introduces support for workload identity authentication through 1Password Credential Broker, currently available in public preview for GitHub Actions." (JavaScript SDK card; locate count=1) | mined | 2026-10-21 | on-release | —
- S0xx | 1Password JavaScript SDK releases — https://github.com/1Password/onepassword-sdk-js/releases.atom | feed (Atom) | A | JavaScript SDK tagged releases (vendor-owned repo) | entry "Release 0.5.0" (tag v0.5.0), updated 2026-07-31T16:56:29Z | Quote: "Currently available for GitHub Actions only." (Release 0.5.0, NEW list; locate count=1) | mined | 2026-10-21 | on-release | —
- S0xx | 1Password blog feed — https://1password.com/blog/index.xml | feed (RSS) | A | vendor blog announcements | item pubDate "Tue, 28 Jul 2026" | Quote: "1Password Credential Broker is now in public preview" (item title; locate count=1) | mined | 2026-10-21 | on-release | —
- S0xx | 1Password Go SDK releases — https://github.com/1Password/onepassword-sdk-go/releases.atom | feed (Atom) | A | Go SDK tagged releases (vendor-owned repo) | entry "Release 0.4.1", 2026-07-30T13:36:33Z (newest of 10) | Quote: "The SDK can now read variables from a 1Password Environment." (Release 0.4.1, NEW list; locate count=2) | mined | 2026-10-21 | on-release | —
- S0xx | 1Password Python SDK releases — https://github.com/1Password/onepassword-sdk-python/releases.atom | feed (Atom) | A | Python SDK tagged releases (vendor-owned repo) | entry "Release 0.4.1", 2026-07-30T13:55:31Z (newest of 10) | Quote: same sentence as the Go row (Release 0.4.1, NEW list; locate count=2) | mined | 2026-10-21 | on-release | —

## Tensions and calibration notes (none fires S018)
1. Stale in-page version: the S018 Step 3 example comment reads "SDK 0.5.0-beta.1 only accepts unpadded integration keys." The newest JavaScript SDK is 0.5.0 (2026-07-31). The 0.5.0 notes do not mention key padding, so whether that comment still holds is UNVERIFIED. It sits outside S018's anchor and is not bound.
2. Scope tension: SDK 0.5.0 notes say workload identity is "Currently available for GitHub Actions only." The S018 page (dateModified 2026-08-17) runs the same SDK path in a GitLab CI example under the custom-workflow beta. S018 makes no GitHub-only claim, so nothing fires; the planner may want the S017/S018 scope wording reviewed.
3. Label split is consistent: sidebar "Credential Broker (public preview)" versus title "(public beta)" on the same page, as S017, S019 and S020 record.
4. A web_search summary dated the JavaScript SDK 0.5.0 "July 29, 2026"; primary feeds say 2026-07-31. Search summaries were not used as evidence.
5. SOURCES.md:24 says "opened 2026-10-20"; source-fetches.tsv:45 captures 2026-10-21. Not a fire; noted.

## Calibration gap for planner (no edits made)
"Only JavaScript SDK supported" has an observable release identity (the SDK feeds above), but S018's anchor names no SDK version, so the C3 rule cannot bind it to a feed. Options: (i) keep rendered-quote; this verdict stands and I recommend it for round 25. (ii) Amend S018's anchor to name "JavaScript SDK 0.5.0 (2026-07-31)" and bind a feed clock in a later round. I did not write SOURCES.md, source-fetches.tsv or release-clocks.tsv; L1 owns integration.

## Not run / limits
- `corpus/release-clock.py` and `corpus/release-clocks.tsv` do not exist in the lane yet (`ls | grep` → 0 matches). C3 counting (`release-clock.py --root`, `c3-measure.py`) is UNRUN by me.
- HTML origin freshness is unproven (fetch row 6). llms-full.txt is the origin-side cross-check.
- No installs or updates. Tools: system curl, python3 stdlib (lane rendered-text-v1.py run as-is), one web_search. Fetch rows 1–4 and the feed-quote locates ran under `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`; rows 5–8 and the feed parses ran in the default environment. All writes stayed in the sandbox.
- Pointers: SOURCES.md:24 (S018 row); source-fetches.tsv:45 (S018 fetch row) and :14-15 (declared UA); rendered-text-v1.py:65-75 (normalize) and :110-121 (locate); sources-census.sh:277-283 (quote ≤25 words, normalization checks); plans/round-25.md:56-71 (C3 spec).
