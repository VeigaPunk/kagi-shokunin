# ClockS005 — round 26 C1 freshness re-verification of S005

Seat KagiR26.ClockS005 (leaf; no dispatch). Lane kagi-shokunin. Observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`). `git diff --quiet BASE -- corpus/SOURCES.md corpus/release-clocks.tsv corpus/source-fetches.tsv corpus/rendered-text-v1.py corpus/release-clock.py` exited 0, so the production inputs equal BASE. Access 2026-10-21 (13:36:39Z and 13:37:12Z). Installs: none (system curl and python3). Production files were not written.

## Bounded result
- **Clock row** `corpus/release-clocks.tsv:2` (`S005 rendered-quote - - - - 2026-10-21 quote-located`): **holds**. The declared capture quote still locates exactly once under rendered-text-v1. The verdict stays `quote-located` and the clock does not fire.
- **Teaching** `corpus/SOURCES.md:11` (a workload's identity is checked against policy, then approved credentials are delivered; tier C lead, not mechanism authority): **unchanged**. The quote still sits verbatim directly under the heading "The platform identifies the job".
- **Scope:** this covers one quote plus its heading only, not the whole page. S005 is not a Python row, so the Python 3.15.1 versus 3.15.0 comparison (S027/S028) does not apply here. S005 has no feed and no displayed version or date. Its only clock is the rendered quote, which is a docs-only clock: it can detect that the quote was removed or reworded, but it cannot detect a product release.

## Source re-opened
URL `https://1password.com/product/credential-broker`. The final URL was the same (no redirect).

| capture | command | HTTP | decoded bytes | raw sha256 | rendered-text-v1 sha256 |
|---|---|---|---|---|---|
| retained `corpus/source-fetches.tsv:58` | curl-fsSL-compressed-v1 | 200 | 196082 | `0be7a540048c…` | `f439a0eb0411…4c2a` |
| retained round-25 receipt `.ufo/waves/round-25/observe-1.json` (S005, 11:31:48Z) | release-clock.py urllib | 200 | — | `d39b9ef64afc…` | — |
| this round, #1 `ClockS005.body.html` | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'` | 200 | 196082 | `919637d72fce…166e` | `f439a0eb0411a3d5191849b5b7f8d20d3fe4634656e7589d281378e0e8934c2a` |
| this round, #2 `ClockS005.body2.html` | same | 200 | 196082 | `b5843b0b9cc3…2cd9` | `f439a0eb0411…4c2a` |
| this round, instrument probe | `release-clock.py` `observe_one` (S005 only, receipt not written) | 200 | — | `b04b685b5994…1020` | located=true |

- HTTP metadata for #1: `HTTP/2 200`, `date: Wed, 21 Oct 2026 13:36:39 GMT`, `content-type: text/html; charset=utf-8`, `content-encoding: gzip`, `x-vercel-cache: HIT`, `age: 1237`, `cf-cache-status: DYNAMIC`. Wire sizes were 39040 and 39068 bytes.
- Raw bytes vary between responses. Captures #1 and #2 differ in 44 bytes (`cmp -l | wc -l`), which matches the round-25 report's 44-byte Cloudflare email-protection footer difference. Normalized text (5818 bytes) is byte-identical to the retained capture's normalized digest. This is a same-representation reproduction, not a drift pin (`source-fetches.tsv` defines `decoded-http-body-volatile-v1`).

## Located quote and anchor
`python3 corpus/rendered-text-v1.py locate ClockS005.body.html '<quote>'` returned `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0. The heading `The platform identifies the job` also returned count=1, exit 0. `--selftest` returned `PASS (cases=22)`. The normalizer's sha256 is `7d6bfe81…c7bf`, the same as round 25.

Quote (22 words): "Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for."

Normalized context: "…The platform identifies the job Credential Broker checks the workload's identity… approved for. Limited potential blast radius…".

## Counterexamples and limits for the planner (advice, not closure)
1. **The release state is outside this clock.** The FAQ still reads "Is 1Password Credential Broker generally available? Not yet. Credential Broker is currently in public preview…". A GA announcement would change that sentence and would not move the S005 clock. The quote does not depend on preview or GA status, so the teaching is unaffected. Any registry claim about preview or GA needs its own clock (round-25 finding, still true).
2. **Receipt `sha256` for this row is the volatile raw-body hash.** The round-25 receipt has `d39b9ef6…` and today's probe has `b04b685b…`. `receipt_matches` (`corpus/release-clock.py:378-407`) only checks the shape of `sha256` (64 hex), so this raw-hash churn cannot cause a false fire. Do not read a raw-sha change as drift for S005.
3. **The in-row pin is still non-reproducing.** `SOURCES.md:11` "Fetch sha256 `f7ba8254…2fd`" matches neither the raw nor the normalized digest of any capture (`corpus/inrow-pins.tsv:11`). This is a historical value and should be kept as-is, not rewritten.
4. **The row identity still matches.** `printf 'S005\tqueued\t<url>\n' | sha256sum` gives `3ea11288…7b45`, equal to `source-fetches.tsv:58` column 3.
5. **The historical receipt is preserved.** `sha256sum .ufo/waves/round-25/observe-1.json` gives `b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92`, equal to `DEFAULT_RECEIPT_SHA256` (`corpus/release-clock.py:28`). I did not modify it. A round-26 receipt would need a new path. For S005 it would record `located: true`, `verdict: quote-located`, observed 2026-10-21, consistent with the TSV row as it stands.

## Not run
- `release-clock.py --observe` (all 28 clocks), `--check`/census and the claim ledger. These are L1 production verification. I called only `observe_one` in-process for S005, with nothing written.
- No feed probe: S005 is not bound to a feed. Round 25 already screened the releases index and SDK RSS, and they are out of this row's scope.

## Artifacts (this seat only)
- `.ufo/waves/round-26/build/ClockS005.body.html`
- `.ufo/waves/round-26/build/ClockS005.body2.html`
- `.ufo/waves/round-26/build/ClockS005.headers.txt`
- `.ufo/waves/round-26/build/ClockS005.md`
