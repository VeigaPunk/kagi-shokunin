# FClockS028 — C3 S028 independent check

Axes: calibration · operability · freshness. No tools installed.

- **Revision:** `82745e2c60e726b49499b8f309529935dc4eff2b`.
- **Sandbox:** `/fast/scratch/kagi-r25/KagiR25.FClockS028-4/lane`.
- **Clone argv:** `mkdir -p /fast/scratch/kagi-r25/KagiR25.FClockS028-4 && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/KagiR25.FClockS028-4/lane && git -C /fast/scratch/kagi-r25/KagiR25.FClockS028-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && git -C /fast/scratch/kagi-r25/KagiR25.FClockS028-4/lane rev-parse HEAD`; **exit 0**, stdout `82745e2c60e726b49499b8f309529935dc4eff2b`.
- **Observed:** 2026-10-21; `date -u '+UTC=%Y-%m-%dT%H:%M:%SZ'` → `UTC=2026-10-21T12:10:26Z` (exit 0).

## Frozen row vs live evidence

- `corpus/release-clocks.tsv:25`: S028 binds feed S036, anchor `3.15.0`, observed `3.15.0`, date `2026-10-21`, `not-fired`; note says anchor names Python 3.15.0 and newer 3.16.0a1 is prerelease.
- `corpus/SOURCES.md:34`: page is Python 3.15.0 docs; anchor `html.unescape(s)`; teaches named/numeric HTML5 references and the post-tag-removal behavior.
- `corpus/source-fetches.tsv:71`: stored page status 200, `decoded-http-body-volatile-v1`, 20,100 bytes, raw-body SHA `b45945567002f1ee33df533a08267a6f27832ad10374295039723b3f8c5d7f3b`, normalized SHA `7a19837f557036e1bb232b98c4331994903b8a799f91e15454c13ed5e9716ed1`; capture quote is the full “Convert all named and numeric character references … corresponding Unicode characters.” string, locator profile `rendered-text-v1`.

Reopened both URLs on 2026-10-21 using the source-fetch request profile (`source-fetches.tsv:14-15`, curl UA `kagi-shokunin-round23/1.0 (documentation verification)`):

```text
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FClockS028-4/home curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/KagiR25.FClockS028-4/work/declared-profile-S028.html -w 'HTTP_STATUS=%{http_code}\n' https://docs.python.org/3/library/html.html
stdout: HTTP_STATUS=200; exit 0

env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FClockS028-4/home curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/KagiR25.FClockS028-4/work/declared-profile-S036.rss -w 'HTTP_STATUS=%{http_code}\n' https://www.python.org/downloads/feed.rss
stdout: HTTP_STATUS=200; exit 0
```

- `sha256sum <page> <feed> && wc -c <page> <feed>` (exit 0): page `cd1a74e603c8cfbb1836ef251a2ea8fca77c4a42175c0c4a776314135d35b59d`, 20,100 bytes; feed `326a2dc4eb6f27937b88078cc317e0cee1df5fb527f5323229f407eb31127844`, 3,389 bytes.
- Feed body: `lastBuildDate` Tue 13 Oct 2026; newest CPython stable item is `Python 3.15.0` (`pubDate` Fri 09 Oct 2026 13:54:59 +0000). `Python 3.16.0a1` (13 Oct) is prerelease; `Python install manager 26.4` is not a CPython release; `3.15.0rc3` is also prerelease. **Independent latest-stable result: 3.15.0.** Current docs title says Python 3.15.0; footer says `Last updated on Oct 21, 2026 (07:27 UTC)`.
- `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FClockS028-4/home python3 -B corpus/rendered-text-v1.py digest /fast/scratch/kagi-r25/KagiR25.FClockS028-4/work/declared-profile-S028.html` (exit 0) stdout: `RENDERED_TEXT_V1: raw_sha256=cd1a74e603c8cfbb1836ef251a2ea8fca77c4a42175c0c4a776314135d35b59d bytes=20100 normalized_sha256=279f549c67a7f1d50ad7c08549d88096c5c4641a15fed37cb1ae35f962aea760 normalized_bytes=2395`.
- `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.FClockS028-4/home python3 -B corpus/rendered-text-v1.py locate /fast/scratch/kagi-r25/KagiR25.FClockS028-4/work/declared-profile-S028.html 'Convert all named and numeric character references (e.g. &gt; , &#62; , &#x3e; ) in the string s to the corresponding Unicode characters.'` (exit 0) stdout: `RENDERED_TEXT_V1_LOCATE: count=1`.

## Assessment

- **Freshness / frozen clock: PASS.** Current independent feed result, docs version, observation date, and verdict match S028's frozen TSV. This is a named `3.15.0` anchor, not a `derived:` anchor; the feed's newer 3.16.0a1 does not falsify it.
- **Quote: PASS for presence and core claim; PARTIAL if taken as the whole teaching.** The capture quote still occurs once under its declared `rendered-text-v1` locator. Current page lines 228-232 also state that HTML 5 rules cover valid and invalid references. The quote itself establishes conversion, not the normalizer's order; `corpus/rendered-text-v1.py:27-35` separately documents entity decoding after tag removal and escaped-tag survival. No semantic counterexample observed.
- **Hash drift is not semantic drift.** Current raw/normalized hashes differ from the frozen volatile-body pins, but byte count is still 20,100 and the quote survives. `source-fetches.tsv:17-23` explicitly classifies this representation as volatile and does not enforce cross-capture digest equality; hashes are point observations, not a semantic verdict.
- **Profile distinction:** `release-clock.py:126-149` reads source-fetch columns 13-14 (declared quote plus locate profile); `:617-628` applies `rendered-text-v1`. Its network request separately uses its own round-25 UA (`:32`, `:500`); I did not run `--observe` to test that observer end-to-end. The independent page/feed re-fetch above used the recorded curl request profile.
- **UNRUN:** `corpus/release-clock.py --observe` / receipt mutation, API calls, full `verify`/`cells`; none needed for this read-only public-source check. No API authentication or product/vault execution.

**Concrete falsifier:** none found for S028's current version/quote. Remaining limit: an end-to-end observer receipt was intentionally not generated; this report independently validates the source observations and locator only.
