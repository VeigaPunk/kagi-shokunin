# ClockS020 — C3 release clock for S020

Seat KagiR25.ClockS020-2 · BASE 4587c61a348e4528717404a68912c373f3ef4d03 (rev-parse verified, exit 0) · observed 2026-10-21 (UTC 10:36–10:41) · sandbox /fast/scratch/kagi-r25/ClockS020-2 (`lane/` = BASE clone, `fetch/` = captures)

## Verdict
- Clock identity: (b) unversioned live docs → `rendered-quote`. The page names no product version. Its only identity is `article:published_time` = `article:modified_time` = `2026-07-28T00:00:00.000Z`, matching the row's "published 2026-07-28" anchor.
- Fired: no (`not-fired`). Both row sentences locate once in the fresh fetch, and the rendered-text-v1 digest equals the registered capture (`20b4fd86…`).
- Teaches (EPM Business eligibility; announcement-time Actions-preview vs custom-OIDC-beta split): HOLDS as an announcement-time reading. It is not a live-status claim, and the live feature labels observed today agree with it.

## Proposed release-clocks.tsv line
```
S020	rendered-quote	https://1password.com/blog/1password-credential-broker-public-preview	-	-	2026-10-21	not-fired
```
Column convention follows the sibling ClockS007 proposal (ClockS007.md:85-88): `feed_url` = observed page URL (the quote's fetch target); `-` for versions.
`--observe` receipt content: quote count=1 (split sentence) and count=1 (EPM sentence); raw sha256 `e3ea0396…`; normalized sha256 `20b4fd86…` (9530 B).

## Why not a `feed` clock
- The anchor names no version, so the `feed` rule ("plus the version the anchor names") cannot be filled.
- The vendor blog feed (`/blog/index.xml`, declared by the page's `<link rel="alternate">`) indexes every post, not versions. A "moved" test would fire on unrelated posts; the newest item (2026-10-20) is unrelated.
- Supersession was checked directly (feed scan below). The live split belongs to S017/S018, which are unversioned and need their own clocks.

## Fetch evidence
`curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)'`, exit 0 for every GET; final URL unchanged.

| capture | HTTP | decoded B | raw sha256 | normalized sha256 |
|---|---|---|---|---|
| registered 2026-10-21 (source-fetches.tsv:47) | 200 | 190261 | 53dfeac5… | 20b4fd86… |
| GET1 (Date 10:37:06Z) | 200 | 190261 | e3ea0396… | 20b4fd86… |
| GET2 | 200 | 190261 | ca5e5057… | 20b4fd86… |
| GET3 | 200 | 190261 | 2301a37c… | 20b4fd86… |

- Raw variance is the footer link `/cdn-cgi/l/email-protection#<hex>` ("Privacy support"): one token per GET, none shared across the three. Normalized text is byte-identical (9530 B). Row identity recomputed = `c1ce1e05…` (matches column 3).
- `python3 lane/corpus/rendered-text-v1.py locate fetch/s020.body '<quote>'`, exit 0 each:
  - "Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows." → count=1 (§New in this release: Custom OIDC workflows)
  - "available for all Enterprise Password Manager Business customers to start using right now" → count=1 (unheaded lead)
- `--selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0. Lane copy sha256 = BASE copy (`7d6bfe81…`).
- Article text: byline "July 28, 2026"; no update or edited note; no date after 2026-07-28 (related-post dates and footer year are the only other dates).

## Feed and feature-page context
- `https://1password.com/blog/index.xml`: HTTP 200, 961074 B decoded, sha256 `e0ccf907…`, 100 items, lastBuildDate Wed, 21 Oct 2026 10:38:17 GMT. 41 items are dated 2026-07-28 or later. Among the 36 dated after it, 5 mention Credential Broker, and only the 2026-07-30 post carries status wording ("read about the Credential Broker public preview"). Same-day posts add none beyond the announcement. No feed item from 2026-07-28 to 2026-10-20 announces a status change for either feature.
- S017 `…/brokered-access/github-actions/`: title and H1 "(public preview)"; normalized sha256 `2a39cb16…`.
- S018 `…/brokered-access/custom-workflow/`: title and H1 "(public beta)"; normalized sha256 `d493bd81…`; body: "latest beta release of the 1Password desktop app". Both pages' product nav reads "Credential Broker (public preview)".

## Calibration notes (rows are append-only; nothing edited)
1. The anchor label "Introduction" is not a page heading (0 matches). The EPM sentence sits in the unheaded lead before "How 1Password Credential Broker works". A correction would be a superseding row.
2. The teaches has two claims, but the registered quote covers only the split. The EPM eligibility sentence can drift without firing the clock (critic point, build/CritC3.md:7). Both locate today. Recommend `--observe` check both quote IDs (`S020-epm-plan`, `S020-status-split` in feature-claims.json).
3. The fetch-TSV header names the round-23 UA; this run used the round-25 UA as the contract requires. The normalized digest matched exactly, so no UA effect was observed.
4. S006 shares this URL and normalized digest and is also on-release. Both of its quotes locate (`unlike a service account token…` count=1; `is in public preview` count=1). Its owner needs the line `S006<TAB>rendered-quote<TAB>https://1password.com/blog/1password-credential-broker-public-preview<TAB>-<TAB>-<TAB>2026-10-21<TAB>not-fired`. Not my row; not written.

## Optional SOURCES candidate (feed; not needed by the S020 clock)
`1Password Blog RSS feed — https://1password.com/blog/index.xml | docs | A | Vendor blog index (titles, dates); supersession check for Credential Broker announcements, not a version feed | Channel lastBuildDate Wed, 21 Oct 2026 10:38:17 GMT; item "1Password Credential Broker is now in public preview", pubDate Tue, 28 Jul 2026, first description paragraph | No feed item from 2026-07-28 to 2026-10-20 changes the S020 split (100 newest items) | Quote (24 words): "Today, we're moving Credential Broker from closed beta to public preview, available for all Enterprise Password Manager Business customers to start using right now." | mined | 2026-10-21 | recheck: L1 picks a non-on-release value | —`
Setting `recheck: on-release` without a `release-clocks.tsv` binding would add an unbound row (on_release 28 → 29).

## Not run / boundaries
- `release-clock.py`, `--observe`, `c3-measure.py`: absent at BASE or outside this seat; UNRUN. `claim-ledger.sh verify`/`cells` not run (forbidden on the lane tree).
- No lane file changed. No installs (pacman paused; none needed). No credential, vault, CDP, or op action. Fetched content treated as data only.
- Commands: git clone + checkout (exit 0); curl ×6 (exit 0); rendered-text-v1 digest/locate/--selftest (exit 0); feed and HTML parsing in the Python kernel with stdlib only.
