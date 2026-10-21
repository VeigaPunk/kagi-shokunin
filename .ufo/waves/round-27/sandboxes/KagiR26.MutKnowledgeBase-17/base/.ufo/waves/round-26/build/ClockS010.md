# ClockS010 — round 26 C1 freshness, S010 (SOPS key groups)

Seat: KagiR26.ClockS010 (leaf scout). Lane-authored advice, not non-author closure.
Observed BASE: `git rev-parse HEAD` in kagi-shokunin = `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE). Working tree: only untracked `.ufo/waves/round-26/` and `plans/round-26.md`.
Production files read only; no registry/production writes; no installs; no build/lint/tests run.

## Result (bounded)

S010's teaching **still holds** on the page as published today. The page is byte-identical to the pinned capture. The declared clock is the SOPS release feed (S033), and it shows **not-fired**: the newest stable release is still v3.13.3. Python S027/S028 instructions do not apply to this row. S010 is not a Python row, and nothing here bears on Python 3.15.1.

## Rows under review (BASE)

- `corpus/SOURCES.md:16` — S010, https://getsops.io/docs/usage/identities/key-groups/, anchor “§Key groups; last modified 2026-05-15, docs commit `9b7b84e…`”, pin `fed6b2e1…192e`.
- `corpus/release-clocks.tsv:7` — `S010 feed S033 https://github.com/getsops/sops/releases.atom 3.13.3 3.13.3 2026-10-21 not-fired derived: …`.

## Source re-open (access 2026-10-21T13:36:35Z UTC)

Command (from `/tmp/clocks010`, outside the repo):

```
curl -fsSL --compressed -D page.hdr -o page.html -w 'http=%{http_code} size=%{size_download} url=%{url_effective}\n' https://getsops.io/docs/usage/identities/key-groups/
sha256sum page.html
```

Observed:
- `http=200`, final URL unchanged (no redirect), decoded body 36366 bytes (8344 bytes on the wire, compressed).
- sha256 `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`, which equals the pins in the SOURCES.md row, `corpus/inrow-pins.tsv:16` and `corpus/source-fetches.tsv:63` (all 36366 bytes).
- Headers: `etag: "7d057e9afbb0ada43c13fdd8ebb42071-ssl-df"`, `age: 230983`, `date: Wed, 21 Oct 2026 13:36:35 GMT`, `content-type: text/html; charset=UTF-8`.
- Footer (rendered): “Last modified May 15, 2026: Add page descriptions. (9b7b84e)”. Link `commit/9b7b84e297bdabc9c78e571c1e6db43dcd69454a`, which equals the anchor.

Quote locations (`grep -boF` on the decoded body; rendered text = tags stripped, entities unescaped, whitespace collapsed):

| teaching (where it is used) | quote, ≤25 words | raw count / byte offset | rendered count |
|---|---|---|---|
| registry `teaches` (SOURCES.md:16) | “keys from multiple groups are required to decrypt a file.” | 1 / 22830 | 1 |
| threshold default (knowledge:46, lesson round-21:64) | “By default, the threshold is set to the number of key groups” | 1 / 23490 | 1 |
| no-group behaviour (knowledge:43) | “if any of the master keys is available, the file can be decrypted” | 0 (whitespace or markup inside the span `[INFERENCE]`) | 1 |

Override claim (knowledge:47, “overridable per invocation or per creation rule”): both forms are still in §Key groups. The page says to “optionally provide the --shamir-secret-sharing-threshold command line flag if we want to override the default threshold” and shows `shamir_threshold: 2` under `creation_rules`. `shamir_threshold` appears 3 times in the raw body.

This scope covers §Key groups only (the page's sole section). It is not a claim about other SOPS pages (S009 and S011 belong to their own seats).

## Declared clock re-open (feed S033)

```
curl -fsSL --compressed -D feed.hdr -o feed.atom -w '...' https://github.com/getsops/sops/releases.atom
grep -oE '<title>v[0-9]+\.[0-9]+\.[0-9]+</title>' feed.atom | sed … | sort -V | tail -3
```

Observed:
- `http=200`, 253037 bytes, sha256 `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`, `etag: W/"47a224ad71435b7f5cae863bc96c0146"`, feed `<updated>2026-07-23T04:56:54Z`.
- First entry `v3.13.3`, updated 2026-07-23T05:29:11Z. There is no entry above it, prerelease or otherwise. Highest stable by semver over all titles is `3.13.3`, then `3.13.2` and `3.13.1`.
- Verdict: anchored 3.13.3 = observed 3.13.3, so the clock is **not-fired**. This matches the BASE row; there is no drift.
- Under the round-25 alternative derivation (docs-date anchor v3.13.0, 2026-05-08T18:11:59Z), the clock would still read fired, because 3.13.3 > 3.13.0. That alternative stays recorded in round-25 R25-C8, and today's page fetch shows the teaching unchanged under it too. The page's 2026-05-15 footer falls between v3.13.0 (05-08) and v3.13.1 (05-16).

## Limitations and counterexamples (actionable, none falsify S010)

1. **The feed only tracks releases, not docs edits.** The feed clock (S033) fires only on a SOPS release. A docs commit to this page with no release would leave the clock at not-fired. The strongest freshness signal for this row is the page itself: byte-identical pin plus unchanged footer commit `9b7b84e`. Releasing v3.13.4 would fire the clock even if the page did not change.
2. **Today's fetch came from the CDN cache.** `age: 230983` (about 2.7 days) means the edge served a cached copy, not a fresh origin render. A docs deploy within the last ~2.7 days might not be visible yet `[INFERENCE]`. The footer commit and body hash give no sign of one.
3. **Raw byte matching misses the knowledge:43 quote.** “if any of the master keys is available, the file can be decrypted” locates in rendered text only. A raw-only locator would wrongly report it missing. This seat did not check whether the round-26 instruments use raw or rendered matching for S010's knowledge quotes.
4. **Reader trap, already recorded.** Knowledge line 49 still says “independent custodians”. The round-21 erratum at the end of the same file supersedes it with “independent key groups”. This is not a freshness drift, and the historical text must not be rewritten.

## Proposed receipt facts for L1 (advice only)

`S010 feed S033 https://github.com/getsops/sops/releases.atom 3.13.3 3.13.3 2026-10-21 not-fired`. The page re-open shows `reproduces-raw` against pin `fed6b2e14524`, and the footer commit `9b7b84e` is unchanged. No superseding registry row is warranted for S010.

## Tooling

No installs or updates. Used: curl, sha256sum, grep, sed, sort, python3 (stdlib `re`/`html`, rendering only).
