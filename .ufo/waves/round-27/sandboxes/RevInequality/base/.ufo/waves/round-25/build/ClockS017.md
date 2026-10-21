# ClockS017 — C3 release clock for S017

Seat KagiR25.ClockS017-2 · lane `kagi-shokunin` · revision 4587c61a348e4528717404a68912c373f3ef4d03 (`git rev-parse HEAD`, exit 0; equals frozen BASE) · observed 2026-10-21 · installs: none · subagents/background jobs: none · lane edits: none.
Axes: calibration = recorded digests reproduce exactly; operability = one offline `locate` per locator; freshness = same-day CDN copy (§6).

**Verdict.** Governing clock = `rendered-quote`: no versioned release identity governs this page. Row quote **located** (count 3, exit 0) → **not-fired**. S017 teaches **still holds** on today's copy, with one wording gap (§5) and a CDN-age caveat (§6).

## 1. Governing identity
- `corpus/SOURCES.md:23` anchor: "Page title and introduction, unversioned live docs opened 2026-10-20". It names no version.
- The fresh normalized page (5549 chars) shows no page version. Its only "version" token is the generic "latest version of the 1Password desktop app" (`fetch/s017.normalized.txt` @1886).
- Machine-readable revision identity: `dateModified` = `lastModified` = `2026-08-04T15:42:17.097Z` (raw HTML JSON-LD and pageMetadata). Sitemap `<lastmod>` for `/brokered-access/github-actions` is identical (`fetch/sitemap.xml:300-301`). Recorded as metadata only. It moves on any edit, so it should trigger re-verification, not a fire.
- Feeds checked, none governs S017: the sitemap has no Credential Broker changelog (only `events-api/changelog`, an unrelated product, `sitemap.xml:1300-1301`); the page links only the general blog RSS `blog.1password.com/index.xml`; the JS SDK release feed (§3) tracks SDK versions. S017 names no version, so a "moved past anchored version" test has no anchor, and the feed clock is undefined.

## 2. Fetch evidence
`curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' https://www.1password.dev/brokered-access/github-actions/` (exit 0)
- HTTP 308 → 200 (redirects=1); effective `https://www.1password.dev/brokered-access/github-actions`; `text/html; charset=utf-8`.
- Decoded body sha256 `62953bb47db1af593c522b06c4f12c6a89853dd0a8fb718118189349213f478d`, 1215460 bytes. Equals `corpus/source-fetches.tsv:44` (sha256 and bytes columns).
- Two more requests (`Cache-Control: no-cache`; `?r25=ClockS017-2026-10-21`) gave the same sha256 and bytes.
- Normalized (`rendered-text-v1`): sha256 `2a39cb1691b24f492dd4ad5a126538df35f865c15cd5f46a35e405a5282781c7`, 5577 bytes = the row's `normalized_sha256` (`source-fetches.tsv:44`). The normalized text is byte-identical to the 2026-10-21 capture.
- Tool identity: `sha256(corpus/rendered-text-v1.py)` = `7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf`, identical in the sandbox BASE clone and the lane worktree.
- `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home python3 corpus/rendered-text-v1.py --selftest` → exit 0, `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`.
- `… digest <body>` → exit 0, `raw_sha256=62953bb4…478d bytes=1215460 normalized_sha256=2a39cb16…81c7 normalized_bytes=5577`.

## 3. Locate results (`… locate FILE QUOTE`: exit 0 = located, 1 = missing)
- exit 0, count 3: row quote "Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)" (`source-fetches.tsv:44`, quote column). Hits: document start @0 (title), navigation block @589, body H1 @1278.
- exit 0, count 1: teaches clause 2 "If an administrator has connected your GitHub organization to your 1Password Business account" (intro, @1522).
- exit 1, count 0 (controls; the clock can fire): H1 with "(generally available)"; H1 with "(public beta)"; "…to your 1Password Enterprise account".
- "Public Preview" (capitalised): exit 1, count 0. The raw HTML has 4 copies that do not survive normalization. Bind the visible lowercase "(public preview)".

Feed opened (candidate only, not bound to S017): `https://releases.1password.com/developers/sdk-javascript/`. HTTP 200, sha256 `d42ffbfeafea1f4e97d64093805b40bad73d9c86d8ded399948323331471aabc`, 39015 bytes. "Updated to 0.5.0 on July 31 2026"; RSS subscription link; latest entry 0.5.0 (July 31 2026), prior 0.4.1 (July 29 2026).
SOURCES-row-ready candidate (planner assigns id; feed rows are S033+):
`S0NN | 1Password JavaScript SDK release notes — https://releases.1password.com/developers/sdk-javascript/ | docs | A | JavaScript SDK release entries; Credential Broker workload identity, GitHub Actions only (SDK scope) | "What's new" entry July 31 2026, 1Password JavaScript SDK 0.5.0 (intro: "Updated to 0.5.0 on July 31 2026") | Quote: "Version 0.5.0 introduces support for workload identity authentication through 1Password Credential Broker, currently available in public preview for GitHub Actions." (intro paragraph; locate count 1) | mined | 2026-10-21 | on-release | — (unbound candidate)`
Not a clock for S017. The "moved past anchor" test needs an anchored version, and S017 has none. An unrelated SDK patch would fire it, while a status change on the Actions page would not necessarily show there.

Corroboration only (S005 URL, tier C): `https://1password.com/product/credential-broker`. HTTP 200, sha256 `4689be6fa32305e0a35df5d6d093f6ea5b5ee1f9ab5e1877b2dc1ce11d5d9840`, 196082 bytes. FAQ: "Is 1Password Credential Broker generally available? Not yet." followed by "Credential Broker is currently in public preview for all Enterprise Password Manager customers, starting with GitHub Actions, and custom OIDC configurations." (locate exit 0, count 1.)

## 4. Proposed `corpus/release-clocks.tsv` line (columns per `plans/round-25.md:56-71`; L1 owns the schema; tab-separated)
```
S017	rendered-quote	https://www.1password.dev/brokered-access/github-actions/	unversioned	unversioned;dateModified=2026-08-04T15:42:17.097Z	2026-10-21	not-fired
```
- Locators: both must locate, and any miss → `fired`. (1) Row quote (count 3). (2) Teaches clause 2 (count 1). The H1 alone misses the Business-prerequisite clause; a sibling critic makes the same point (`.ufo/waves/round-25/build/CritC3.md:7`). Locator 2 needs a schema slot (a `quote2` column or an `S017b` line).
- Mapping: located = not-fired; missing = fired → re-verify and record, never silently re-pin.

## 5. Does S017's teaches still hold?
- "GitHub Actions is public preview": **holds**. Title and body H1 read "(public preview)"; the product FAQ and the JS SDK entry (July 31 2026) agree. The sidebar label "Credential Broker (public preview)" (@1001) is shared navigation. `corpus/SOURCES.md:98` says to use the page's own H1, which is what the clock binds.
- "an administrator first connects the organization to a 1Password Business account": **holds as a prerequisite**. The page says "If an administrator has connected your GitHub organization to your 1Password Business account, you can use 1Password…" (@1522). "first" is an ordering reading [INFERENCE]; the page states a precondition. Optional L1 tightening: "requires that an administrator has connected…".
- Release change: none. No version, no GA statement, and digests identical to the row.

## 6. Freshness and limits
- All three responses carried `cf-cache-status: HIT` with `age` 35602 / 35674 / 35674 s. Date minus age = 00:44:22Z for each, so the body is a Cloudflare-cached copy stored 2026-10-21 00:44:22Z. Per-request `cf-ray` and `x-vercel-id` differ, and `x-vercel-cache: MISS`. Headers cannot prove the origin path, so treat this as a same-day CDN copy, not origin state at 10:37Z.
- `x-served-version: dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP` is a deployment id. A redeploy would change it without a status change, so it is recorded and not used as a clock.
- Lead for L1 (not evaluated here): S018 names the JavaScript SDK as its only supported SDK; the SDK feed is a plausible anchor for that clause, not for S017.

## 7. UNRUN / not done
- `corpus/release-clock.py`, `corpus/release-clocks.tsv`, `.ufo/waves/round-25/tools/c3-measure.py`, and `--observe`: absent in the lane and the sandbox → UNRUN.
- Lane `verify` / `cells`: not run (forbidden on the lane tree).
- web_search summaries (GA target "late 2026"; CLI 2.41.0 `--environment` GA): leads only, not fetched, not relied on.
- No edits to `SOURCES.md`, `source-fetches.tsv`, or any lane file. Writes: this report, plus sandbox files under `/fast/scratch/kagi-r25/ClockS017-2/fetch/`.
