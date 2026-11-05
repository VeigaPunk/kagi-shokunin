# ScribeGate — round 36 (kagi) source re-verification

Seat: ScribeGate. Lane: kagi-shokunin. Access date for every fetch and quote
search: **2026-11-04**. Scoped findings only; no lane or registry edit.

## Verdict

All four cited sources were opened directly and all four release-identity
quotes are **located** in the fetched bytes. Two of the four rows carry
anchor cells that the served pages no longer satisfy (staleness in the
registry, not in the sources). No seat-vs-seat conflict observed.

## Numbers

| id | URL | http | bytes | sha256 of fetched body | quote | present at anchor? |
|---|---|---|---|---|---|---|
| S034 | https://github.com/hashicorp/vault/releases.atom | 200 | 297221 | `3cbfdd86d1b4530999d9ab7ed15f395f2757ce0f8a2ae835798878bbe1957fce` | `<title>v2.2.1</title>` | **yes** |
| S035 | https://github.com/openbao/openbao/releases.atom | 200 | 543805 | `a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e` | `<title>v2.7.2</title>` | **yes** |
| S040 | https://docs.python.org/3/library/re.html | 200 | 257722 | `064fbcb69853dc814b27732f09c640cd205e8a821e9a695d540a7945bf8f8b89` | `Python 3.15.2 documentation` | **yes** (recorded title `Python 3.15.1 documentation` → **absent**) |
| S041 | https://docs.python.org/3/library/html.html | 200 | 20100 | `1a4f2e2a1f8c1db5949dd85303444654364cc06c3180b2376cf6b307f450bcd8` | `Python 3.15.2 documentation` | **yes** (recorded title `Python 3.15.1 documentation` → **absent**) |
| S039 (clock feed of S040/S041) | https://www.python.org/downloads/feed.rss | 200 | 3354 | `9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e` | `<title>Python 3.15.2</title>` | **yes** |

Release dates stated by the feeds: Vault `v2.2.1` → `<updated>2026-10-23T17:34:44Z</updated>`;
OpenBao `v2.7.2` → `<updated>2026-10-26T20:24:37Z</updated>` (neither Atom feed
carries a `<published>` element); CPython `3.15.2` →
`pubDate Sun, 25 Oct 2026 04:15:38 +0000`. The two docs pages state only
`Last updated on Nov 04, 2026 (23:57 UTC)` — a page stamp, not a release date.

## Findings routed to the L1 (not edited by me)

1. **S034/S035 anchor locators are stale.** Their recorded title strings are
   still literally present, but "first stable entry" now resolves to
   `v2.2.1` / `v2.7.2`; `v2.2.0` is second, `v2.7.1` third (entry 1 of the
   OpenBao feed is `v2.6.5`). Their `recheck` cells are `90d`.
2. **S040/S041 recorded anchor titles are absent** from the served pages
   (`locate` count 0 each); the pages now serve the 3.15.2 titles.
3. **Teaching quotes unchanged and located** (both `rendered-text-v1 locate`
   count 1). Caveat: the S041 sentence wraps a newline in raw HTML — located
   only under the declared normaliser.
4. **Independent fetch reproduces the committed receipt byte-for-byte** on all
   three feeds; receipt file sha256 recomputes to the declared
   `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`.
5. **The lane's extractor agrees**: `release-clock.py::parse_latest_version` on
   my bodies → `2.2.1`, `2.7.2`, `3.15.2`.
6. Feed scope guards still live: `sdk/v0.26.0`, `v2.2.0-rc1`, `api/v2.7.1…`,
   `sdk/v2.7.1…`, `v2.7.0-beta20260909`, `Python 3.16.0a1`, `Python install
   manager 26.4`.

## Out of scope

No lane production file, no registry cell, no `.ufo/state`, no
`MANIFEST.json`, no fleet-root file touched. Git read-only
(`status`/`log`/`show`/`diff`, all with explicit `git -C <abs>`); no commit,
push, checkout, switch, reset, stash or clean. No subagent dispatch. No tool
installed or upgraded (nothing needed beyond `curl`, `sha256sum`, `python3`
and the lane's own committed scripts).

## Artifacts

- `.ufo/waves/round-36/build/ScribeGate/gate.md`
- `.ufo/waves/round-36/build/ScribeGate/fetch-sha256.tsv`
- `.ufo/waves/round-36/build/ScribeGate/report.md`
- `.ufo/waves/round-36/build/ScribeGate/evidence/{locate-evidence.txt,quote-excerpts.txt,feed-entries.txt,python-feed.rss}`

Scratch `/fast/scratch/hyaku/kagi-r36/ScribeGate/` was removed after the
receipts were copied into the build directory.
