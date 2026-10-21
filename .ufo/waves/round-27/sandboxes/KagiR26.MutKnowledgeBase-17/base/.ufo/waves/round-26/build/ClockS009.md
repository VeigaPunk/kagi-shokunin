# ClockS009 — round 26 C1 freshness, row S009 (lane-authored advice, not closure)

Seat: KagiR26.ClockS009 (leaf scout). Observed BASE: `git rev-parse HEAD` =
`1bf3eec48d3761580ffd375c88143232485ae814` (commit date 2026-10-21T10:16:34-03:00),
matches the frozen BASE. Production files were only read. Writes: this report,
plus the raw captures in `.ufo/waves/round-26/sandboxes/ClockS009/`
(`page.html`, `page.hdr`, `feed.atom`, `feed.hdr`). No installs.

## Result (bounded)

**S009 has no drift.** Its teaching still holds and its clock has not fired.
The page body is byte-identical to the pinned capture. Python 3.15.1 does
not apply to this row: S009 is a SOPS docs row clocked on the SOPS feed (S033),
not on S036. The round-25 receipt stays valid for S009 and needs no rewrite.

## Inputs read (production, read-only)

- `corpus/SOURCES.md:15`. S009 is "Age on SOPS", https://getsops.io/docs/usage/identities/age/,
  §Encrypting using age, last modified 2026-05-15, docs commit `9b7b84e…`, quote
  "It is also possible to use `updatekeys`, when adding or removing age recipients.",
  fetch sha256 `a840727e…0b76`, recheck `on-release`.
- `corpus/release-clocks.tsv:6`. `S009 feed S033 https://github.com/getsops/sops/releases.atom 3.13.3 3.13.3 2026-10-21 not-fired derived: …`
- `corpus/inrow-pins.tsv:15` (`reproduces-raw`) and `corpus/source-fetches.tsv:62`
  (raw `a840727e…`, normalized `189d5ba9…`, 29301 bytes, observed 2026-10-21).
- `corpus/lessons/round-25.md:76-79` records an alternative derivation: anchoring on
  the docs date (v3.13.0) reads FIRED, and ClockS010's run found the teaching unchanged.

## Source re-open: S009 docs page

The command (run from the sandbox):
`curl -fsSL --compressed -D page.hdr -o page.html https://getsops.io/docs/usage/identities/age/` returned rc=0.

- Access time: 2026-10-21T13:36:32Z. Response: `HTTP/2 200`, `date: Wed, 21 Oct 2026 13:36:31 GMT`,
  `etag: "1095229ea5f2c31a0d4a6c751b1c1cb0-ssl-df"`, `age: 235043` (CDN cache, about 2.7 days),
  `content-length: 8475` (compressed).
- Decoded body: 29301 bytes, sha256 `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76`.
  This is the **same** digest as the SOURCES.md pin, the inrow-pins entry and the source-fetches entry.
- `python3 corpus/rendered-text-v1.py digest page.html` printed
  `raw_sha256=a840727e…0b76 bytes=29301 normalized_sha256=189d5ba9145e71f4a41dae10a42b9176fa660c58f3df5cb2774a145d11728d95 normalized_bytes=3570`.
  The normalized digest matches source-fetches.tsv:62.
- Quote location (anchor `<h2 id=encrypting-using-age>`, the only h2 on the page):
  - `rendered-text-v1.py locate page.html 'It is also possible to use updatekeys , when adding or removing age recipients.'`
    printed `count=1`. That is 13 words. The registry's backticked form only locates after rendering, which is the known round-25 R25-C7 behaviour and not a new finding.
  - The knowledge-file companion quote `'Each identity will be tried in sequence until one is able to decrypt the data.'`
    also printed `count=1`.
- Footer, in rendered text: "Last modified May 15, 2026: Add page descriptions. (9b7b84e)". It is unchanged from the anchor.
- Also present and unchanged, checked only as substrings (not whole-page coverage):
  - the lookup overrides `SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY` and `SOPS_AGE_KEY_CMD`;
  - "Note that only ssh-rsa and ssh-ed25519 are supported."

Teaching verdict: the scoped teaching still holds. It covers recipient configuration, the identity lookup order, and `updatekeys` for adding or removing recipients. The only coverage claimed is the located quotes plus a byte-identical body.

## Clock re-open: S033 SOPS release feed

The command:
`curl -fsSL --compressed -D feed.hdr -o feed.atom https://github.com/getsops/sops/releases.atom` returned rc=0.

- Response: `HTTP/2 200`, `date: Wed, 21 Oct 2026 13:36:32 GMT`, `etag: W/"47a224ad71435b7f5cae863bc96c0146"`.
  The body is 253037 bytes, sha256 `47a224ad71435b7f5cae863bc96c0146…72ff6` (full value: `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`).
- The feed has 10 entries, all plain stable `vX.Y.Z` (no `-rc` and no module prefixes):
  - 2026-07-23 v3.13.3 (newest)
  - 2026-06-30 v3.13.2
  - 2026-05-16 v3.13.1
  - 2026-05-08 v3.13.0
  - older entries down to v3.10.1
- `grep -c '<title>v3.13.3</title>' feed.atom` printed `1`. It is the first entry title, updated 2026-07-23T05:29:11Z.
  `rendered-text-v1.py locate` on the feed printed `count=0` because the normalizer strips tags. Use a raw match for feed titles.
- Newest stable is **3.13.3**, equal to `anchored_version` 3.13.3, so the verdict is **not-fired**. This matches release-clocks.tsv:6.

## Limits and counterexamples

1. **The clock does not watch the docs.** The page carries no SOPS version, and the clock is the release feed. A docs edit without a release (a new footer commit) would not fire the clock. Today the body digest and footer `9b7b84e` are unchanged, so no docs-only drift was missed. The footer remains the only in-page change signal, and the knowledge file's recheck already names it.
2. **The derived anchor is still a choice.** If the anchor were the docs date (v3.13.0), the observed v3.13.3 would read FIRED. Nothing new since round 25 (no release after 2026-07-23) changes either reading. The round-25 lesson's note about this stays accurate.
3. **The CDN copy may lag the docs repo.** The page came from a cache (`age: 235043`). I did not fetch the getsops/docs repository: only the S009 URL and its declared feed were authorized. Any newer upstream docs commit not yet served is unobserved [INFERENCE: unlikely to matter given the footer date of 2026-05-15].
4. **Python S027/S028 and 3.15.1 are out of scope for this row.** That comparison belongs to the seats for S027 and S028. S009 has no Python dependency.

## Not run

No build, lint, tests, `release-clock.py --observe` or receipt generation. Those are for L1 after integration. The only probes were the two public fetches above and the read-only `rendered-text-v1.py digest`/`locate` on my own sandbox capture.

## Suggestion for L1

When the round-26 receipt records the current clocks, record S009 as `observed 3.13.3, not-fired, 2026-10-21`. Leave the SOURCES.md S009 row, inrow-pins.tsv:15 and source-fetches.tsv:62 unchanged, since every immutable fact reproduces. No superseding row is needed.
