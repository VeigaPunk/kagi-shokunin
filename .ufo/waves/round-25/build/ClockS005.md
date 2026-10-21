# ClockS005 — C3 release clock for SOURCES S005

Lane kagi-shokunin · BASE 4587c61a348e4528717404a68912c373f3ef4d03 · access 2026-10-21 · seat KagiR25.ClockS005-2 (leaf).
Sandbox /fast/scratch/kagi-r25/ClockS005 (lone clone at BASE; fetched bodies and normalized text kept there).
Installs: none (system curl, python3 3.14.8, git).

## Verdict
- Governing identity: **none versioned, so clock `rendered-quote`.** The page shows no version or date, and the anchor "§The platform identifies the job" names no version, so the `feed` binding cannot apply.
- Clock result: **not-fired.** The quote and the anchor each locate exactly once in 3 of 3 fresh captures, and the rendered-text-v1 digest equals the logged one.
- S005 teaches: **still holds** on 2026-10-21. Tier C (marketing lead, not mechanism authority) stays correct.

## Proposed release-clocks.tsv line
Columns: `id clock feed_url anchored_version observed_version observed_at verdict` (tab-separated):

	S005	rendered-quote	https://1password.com/product/credential-broker	-	-	2026-10-21	not-fired

Receipt for `--observe` (what the verdict rests on): HTTP 200; decoded 196082 bytes; normalized_sha256 `f439a0eb0411a3d5191849b5b7f8d20d3fe4634656e7589d281378e0e8934c2a`; quote_count=1; anchor_count=1.

## Fetch evidence (`https://1password.com/product/credential-broker`, final URL unchanged)
`curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)'`, exit 0, HTTP 200. Server Date on fresh #1: Wed, 21 Oct 2026 10:36:15 GMT.

| capture | HTTP | decoded bytes | raw sha256 (prefix) | rendered-text-v1 sha256 (prefix) |
|---|---|---|---|---|
| source-fetches.tsv:58 (logged) | 200 | 196082 | 0be7a540048c | f439a0eb0411 |
| RecapS005, round 24 (`.ufo/waves/round-24/build/RecapS005.md:5-6`) | 200 | 196082 | f1319513a95f | f439a0eb0411 |
| fresh #1 (this run) | 200 | 196082 | 76980790415 | f439a0eb0411 |
| fresh #2 | 200 | 196082 | b401638e44a9 | f439a0eb0411 |
| fresh #3 | 200 | 196082 | 458c6eaf903e | f439a0eb0411 |

- Raw bytes are volatile. Fresh #1 and #2 differ in exactly 44 bytes (`cmp -l`), all inside the footer link "Privacy support" (`/cdn-cgi/l/email-protection#<hex>`, Cloudflare). Normalized text is identical across all five captures.
- Wire sizes vary (gzip 39090–39121 bytes). The clock must use the decoded body with rendered-text-v1, never wire bytes or raw sha.
- The in-row pin at `corpus/SOURCES.md:11` ("Fetch sha256" `f7ba8254…2fd`) matches no captured representation (`corpus/inrow-pins.tsv:11`, non-reproducing). The bytes that produced it are not retained.

## Clock checks
Sandbox copy of `corpus/rendered-text-v1.py` (sha256 7d6bfe81…, identical at BASE and in the working tree). `--selftest`: PASS (cases=22), exit 0.
- Quote "Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for." → `locate` count=1, exit 0, in fresh #1, #2, #3. The apostrophe is straight ASCII (curly count 0).
- Anchor "The platform identifies the job" → count=1, exit 0, in fresh #1, #2, #3.

## Why not a feed clock
- Normalized page text has no "version", "release", "updated", or dated product stamp. Only "© 2026" appears.
- Feeds opened:
  1. `https://releases.1password.com/` (HTML, 200, 48426 decoded bytes, sha256 0f06cb1f…ab80). Newest entry: "Updated to 8.12.42 on October 20 2026", an unrelated app. Zero Credential Broker mentions.
  2. `https://releases.1password.com/developers/sdk-javascript/index.xml` (RSS, 200, text/xml, 1884 bytes, sha256 4a6da2ba…87fe, identical on 2 fetches). Latest item "1Password JavaScript SDK 0.5.0", pubDate Fri, 31 Jul 2026. It is the SDK's versioned feed, not this product page's, and S005 names no version, so it does not bind S005.
- The page's FAQ says "Not yet. Credential Broker is currently in public preview…". That is a release-state sentence that GA would change. It is outside S005's quote, so this clock does not move on it.

## SOURCES candidate (feed opened, not bound to S005)
Highest existing id is S032, so the planner assigns S033. Row-ready:

`| S033 | 1Password JavaScript SDK release feed — https://releases.1password.com/developers/sdk-javascript/index.xml | docs | A | 1Password JavaScript SDK release history; Credential Broker workload-identity support | RSS channel; latest item "1Password JavaScript SDK 0.5.0", pubDate Fri, 31 Jul 2026 (link …/developers/sdk-javascript/0.5.0/); opened 2026-10-21 | Quote: "The SDK can now authenticate using workload identity through 1Password Credential Broker." (RSS item 0.5.0 description; 12 words) | queued | 2026-10-21 | on-release | — |`

- Tier A: official 1Password vendor feed. Kind `docs` is in the census enum.
- Representation: `decoded-http-body-v1` (raw sha stable across 2 fetches). The quote locates count=1 under rendered-text-v1 (normalized sha256 a2406a50…123f) and once by raw substring.
- Status stays `queued` until a clock binds it. The planner sets `mined` and `used-by` when it does.

## Teaches verdict (S005)
Holds on 2026-10-21. The quote is verbatim and visible under the anchored heading in every fresh capture. The claim (identity checked against policy, then exact credentials delivered) does not depend on preview or GA status, so no release event falsifies it.

## Findings for the planner (not edited)
1. S005's in-row pin `f7ba8254…` is unreproducible and undeclared. Round-23 D7 puts new bindings in `corpus/source-fetches.tsv`, not in-row. Replace or label the pin on the next integration.
2. `source-fetches.tsv` column 3 equals sha256 of `id\tstatus\turl\n` (`corpus/sources-census.sh:262`). It covers status and URL only. Changing S005's status (queued → mined) triggers `row-identity-digest-mismatch` until column 3 is regenerated in the same integration.
3. S006 and S007 carry "public preview" release-state claims. S005's clock cannot cover them. They need a release-feed clock; the SDK RSS above is one candidate, assigned by the planner.

## Commands and exit codes
- S005 curl ×3: exit 0, HTTP 200. Releases index curl: exit 0. SDK HTML curl: exit 0. SDK RSS curl ×2: exit 0.
- `rendered-text-v1.py --selftest`: PASS (cases=22), exit 0. `digest` ×3: exit 0. `locate` quote ×3 and anchor ×3: exit 0, count=1.
- sha256 of `S005\tqueued\thttps://1password.com/product/credential-broker\n` = 3ea11288bfdab82f… = fetch-row column 3 (match).
- Lane vs BASE: `corpus/SOURCES.md` line 11 identical (sha fe63d47d…).
- UNRUN: `corpus/release-clock.py` and `corpus/release-clocks.tsv` do not exist in the working tree (0 matches), so no checker ran. `sources-census.sh` was not run on the lane tree (contract: no gate runs on the real tree).
