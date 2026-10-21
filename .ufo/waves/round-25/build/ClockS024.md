# ClockS024 — C3 per-row clock for S024 (KV v2 API, max_versions)

Seat KagiR25.ClockS024-2 (leaf, no subagents). Base 4587c61a348e4528717404a68912c373f3ef4d03. Fetches 2026-10-21 (from ~10:37Z). Lane files read-only; no gate run; no cookies sent (curl without -b/-c); no credentials. Sandbox: /fast/scratch/kagi-r25/ClockS024 (bodies, JSON, patches). Tools: system curl, git ls-remote, python3. No installs (pacman paused; none needed).
UNRUN: corpus/release-clock.py (not in lane yet); claim-ledger/sources-census gates (lane-tree gates out of bounds).

## Verdict
- Clock: rendered-quote. Verdict: not-fired. Quote LOCATED in fresh fetch (count=3).
- S024 teaches: still holds on the fresh page.
- Release identity does not govern this page; the docs source does (reasons below).

## Why rendered-quote, not a Vault release feed
1. S024 anchor names no version (SOURCES.md:30: "served live docs opened 2026-10-21"). The plan's feed rule needs an anchored version; there is none.
2. The page labels itself "v2.x (latest)" in its version selector (normalized text). That is a docs line, not a release. A feed anchored at v2.x would fire only on a v3 major and would miss KV docs changes inside 2.x.
3. The page text follows docs commits on a moving branch. Its Edit link is hashicorp/web-unified-docs/blob/main/content/vault/v2.x/content/api-docs/secret/kv/kv-v2.mdx. Its two most recent source commits, e99b4f6e (author 2026-07-21) and a2f19108 (2026-07-13), fall between Vault releases v2.0.3 (2026-06-17) and v2.0.4 (2026-08-04). The GitHub release list shows no release in that window.
4. Feed as context only: latest Vault v2.2.0, published 2026-10-15T16:17:18Z, is before this row's opened date (2026-10-21). A feed verdict over the row's window would also be not-fired.

## Proposed release-clocks.tsv line
TSV: S024<TAB>rendered-quote<TAB>-<TAB>-<TAB>-<TAB>2026-10-21<TAB>not-fired
Columns: id=S024 clock=rendered-quote feed_url=- anchored_version=- observed_version=- observed_at=2026-10-21 verdict=not-fired.
feed_url `-`: no feed bound; the row's own registered URL is the fetch target. anchored_version `-`: anchor names none. observed_version `-`: this clock observes text, not a release.

## Rendered-quote evidence (2026-10-21)
Quote (S024 row): “max_versions (int: 0) – The number of versions to keep per key.”
- `python3 corpus/rendered-text-v1.py locate s024-body.html '<quote>'` → `RENDERED_TEXT_V1_LOCATE: count=3`, exit 0.
- `python3 corpus/rendered-text-v1.py digest s024-body.html` → `raw_sha256=9842a375f0c30115c5b34d1a1c47c6a59a924f58fa2d5221cd74680a28f18b8e bytes=586181 normalized_sha256=7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715 normalized_bytes=24395`, exit 0.
- Normalized digest equals the row's pinned value (source-fetches.tsv:51, col 15). Visible text is unchanged since the row's capture.
- `rendered-text-v1.py --selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0.
- Source cross-check: MDX at main = e99b4f6e (sha256 911ad99c…, 200). Whitespace-normalized, the sentence “The number of versions to keep per key.” occurs 3 times; MDX backtick markup means the full rendered quote is not a literal match.

## Fetch evidence
- `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2` → http=200, final URL unchanged, curl_exit=0. Wire 43111 B (br); decoded 586181 B.
- Headers: date 2026-10-21 05:08:47 GMT, cached copy with age 19708 s at fetch. x-matched-path /vault/api-docs/secret/kv/kv-v2. Deployment dpl_A3yEDEPW9sYZQ9TkKGeyyKhu4mmP.
- Pinned raw digest aaf52ac25695b1bb8ac6cba4f5e67abe27a35700619c9fa88b7bb292571c1008 (586146 B). The raw difference is chrome only, as declared (volatile representation); normalized digests match. Not re-pinned: the provenance row stays; this is the observation receipt.

## Teaches check (fresh rendered text)
- "Once a key has more than the configured allowed versions, the oldest version will be permanently deleted." (count=3) → caps retained versions per key.
- "If set, specifies the length of time before a version is deleted." (delete_version_after, count=1) and "Set the delete_version_after value … for all new versions written to this key." (count=2) → deletion timing is a separate parameter.
- Row scope "document configuration only, not a deployment or KV-retention guarantee" remains correct.
- Optional, planner's choice: the page also says "When 0 is used or the value is unset, Vault will keep 10 versions." (count=1). The row omits that default.
- Verdict: teaches HOLDS.

## Feed evidence (opened; candidates below)
- api.github.com/repos/hashicorp/vault/releases/latest → 200, sha256 8deb527d…, tag v2.2.0, published_at 2026-10-15T16:17:18Z, target_commitish 2891bfd23893ebd302307050edaf03d871ea8351, x-ratelimit-remaining 17.
- api.github.com/repos/hashicorp/vault/releases?per_page=8 → 200, sha256 a44bd515…, remaining 10. Latest 8: v2.2.0 (10-15), v2.2.0-rc1 (10-08), v2.1.2 (10-07), v2.1.1 (09-16), v2.1.0 (09-01), v2.0.4 (08-04), v2.0.3 (06-17), v2.0.2 (06-05).
- api.github.com commits for the KV file → 403, remaining 0, reset 2026-10-21T11:25:01Z. Unauthenticated 60/h quota consumed by other callers on this IP [INFERENCE: peer report from ClockS016-2, plus our counter readings 17→10→0].
- github.com/hashicorp/vault/releases/latest → 302, location …/releases/tag/v2.2.0 (no quota).
- github.com/hashicorp/vault/releases/tag/v2.2.0 → 200, sha256 77d186a9…, `datetime="2026-10-15T16:17:18Z"`.
- `git ls-remote --tags https://github.com/hashicorp/vault.git refs/tags/v2.2.0` → 2891bfd23893ebd302307050edaf03d871ea8351 (matches API target).
- releases.hashicorp.com/vault/index.json → 200, 2691686 B, sha256 85a2c038…; contains `"version":"2.2.0"`; no timestamps.
- `git ls-remote https://github.com/hashicorp/web-unified-docs.git refs/heads/main` → 28d67d3308eb58e3c64976d52f612f847bb62985.
- github.com/hashicorp/web-unified-docs/commits/main/…/kv-v2.mdx → 200, sha256 75a64e13…. Patches: e99b4f6e (author Tue 21 Jul 2026), a2f19108 (Mon 13 Jul 2026).

## SOURCES-row-ready candidates (opened feeds; planner assigns id; not re-pinned)
Shape checked offline: 13 pipe fields, 11 cells, kind/tier/status in enums (sources-census.sh:191). used-by lesson file does not exist yet, so SC_USEDBY_MISSING fires until it lands.
A. | S0NN | Vault release feed — https://github.com/hashicorp/vault/releases/latest | code | A | Vault OSS latest-release pointer (tag, publish date, target commit) for feed-bound on-release clocks; release identity, not docs text | §Release v2.2.0 tag page (redirect target); published 2026-10-15; commit 2891bfd23893ebd302307050edaf03d871ea8351 | Latest official Vault OSS release is v2.2.0, published 2026-10-15; later tags are feed events, not content verdicts. Quote: “datetime="2026-10-15T16:17:18Z"” (tag page v2.2.0, relative-time element). | mined | 2026-10-21 | on-release | corpus/lessons/round-25.md |
B. | S0NN | Vault artifact index — https://releases.hashicorp.com/vault/index.json | dataset | A | Official HashiCorp Vault artifact index; corroborates latest OSS version; no publish timestamp | §versions["2.2.0"] object; fetched 2026-10-21 | Official index lists Vault OSS 2.2.0 as built. Quote: “"version":"2.2.0"” (versions["2.2.0"] object). | mined | 2026-10-21 | on-release | corpus/lessons/round-25.md |
Moving-ref revision for a fetch row on A: 2891bfd23893ebd302307050edaf03d871ea8351. S024 itself needs neither row.

## Operability findings
1. api.github.com cannot serve C3 observations while sibling seats share the IP quota. Use the github.com redirect, the tag page datetime, and git ls-remote (verified above).
2. source-fetches.tsv:14-15 documents the request profile UA as round-23. sources-census.sh:266 checks the profile name only, so a round-25 UA passes. Documentation drift, not a gate failure.
3. Freshness of this page is its source commit history, not any release. The release feed cannot see docs-only commits (two of them fell in the no-release window above).

## Side observations (flagged, not acted on)
- S012 anchors "newest pinned version v1.21.x" (SOURCES.md:18). Feed latest v2.2.0 is past that, so a feed clock on S012 would fire. Sibling ClockS012-2 independently confirmed: fired.
- Optional anchor amendment for future binding: name the route "v2.x (latest)" and the source branch on S024.

## Acceptance map
- Clock line: above (rendered-quote, not-fired, observed_at 2026-10-21).
- Feed candidates with quotes: A and B above.
- Fetch evidence: above (URLs, HTTP status, sha256, byte counts, commands).
- Teaches verdict: HOLDS.
