# Gate — round 36 source re-verification (seat ScribeGate)

Scope: the four registry rows the round-36 plan names as this round's cited
sources — `S034`, `S035`, `S040`, `S041` in `corpus/SOURCES.md`. Each row's URL
was opened directly (no inherited quote counts), the body fetched with
`curl -sS --max-time 60 -A 'kagi-shokunin-round36/1.0'` (public pages only, no
auth, no credentials), and the quote searched for in the fetched bytes.

Access date for every block below: **2026-11-04** (fetch and quote search were
run on this date; the wall clock in the fetch log is not recorded per block,
the date is).

Digest convention: `sha256` is the sha256 of the **fetched body bytes** as
written to disk by curl (no re-encoding, no normalisation). Normalised
(rendered-text-v1) digests are given separately where the quote is a rendered
text quote.

Normaliser used for the rendered-text quote searches: the lane's own committed
`corpus/rendered-text-v1.py` (unchanged; `locate` / `digest` subcommands).

---

## S034 — Vault releases, GitHub release Atom feed

- **URL:** https://github.com/hashicorp/vault/releases.atom
- **Access date:** 2026-11-04
- **Registry recheck cell (as read, HEAD `09f27e2`):** `90d`; status `mined`;
  opened `2026-10-21`; used-by `corpus/lessons/round-25.md`
  (the working tree already carries `opened 2026-11-04` for this row from
  another seat's in-flight registry edit — not mine; I edited nothing.)
- **Quote establishing the release identity the row's clock observed (Vault 2.2.1):**
  > `<title>v2.2.1</title>`
  
  Located at the **first stable entry** of the fetched feed: raw byte offset
  **726**, body line **12** (`<entry>` 0 of 10). Same entry's
  `<updated>2026-10-23T17:34:44Z</updated>` is on body line **10**.
- **Release date stated by the feed:** the entry states
  `<updated>2026-10-23T17:34:44Z</updated>`; the feed carries **no
  `<published>` element** (grep count 0), so this is the only date the feed
  states for the entry.
- **sha256 of fetched body:**
  `3cbfdd86d1b4530999d9ab7ed15f395f2757ce0f8a2ae835798878bbe1957fce`
  (297221 bytes, HTTP 200)
- **Is the quote present at that anchor? — YES.**
  `<title>v2.2.1</title>` occurs exactly once (grep -F count = 1) and is the
  first stable `X.Y.Z` entry title in the feed.
- **The registry's currently recorded quote for this row**
  (`<title>v2.2.0</title>`, locator "first stable entry"): the **literal
  string is still present** in the fetched body (count = 1, byte offset 4199),
  but its **locator no longer holds** — `v2.2.0` is now the *second* stable
  entry (updated `2026-10-15T18:50:14Z`, unchanged), so "first stable entry"
  now resolves to `v2.2.1`. The anchor cell's timestamp for `v2.2.0`
  (`2026-10-15T18:50:14Z`) is still exactly what the feed states.
- **Scope guards still needed, and still visible in the feed:** the same feed
  carries `sdk/v0.26.0` (count 1) and `v2.2.0-rc1` (count 1); the row's
  "excludes `sdk/` module tags and `-rc` prereleases" scope is still live.
- **Cross-check against the committed receipt:** the lane's own extractor
  (`corpus/release-clock.py` → `parse_latest_version`) run against these
  fetched bytes returns **2.2.1**, matching the receipt row for the S034 feed
  (`observe-live.json`, `S012`/`S013`/`S022`/`S023`/`S024`,
  `parsed_version 2.2.1`, `verdict fired`). The body sha256 above is
  byte-identical to the sha256 the receipt records for that URL
  (`3cbfdd86d1b45309…`).

---

## S035 — OpenBao releases, GitHub release Atom feed

- **URL:** https://github.com/openbao/openbao/releases.atom
- **Access date:** 2026-11-04
- **Registry recheck cell (as read, HEAD `09f27e2`):** `90d`; status `mined`;
  opened `2026-10-21`; used-by `corpus/lessons/round-25.md`
  (the working tree already carries `opened 2026-11-04` for this row from
  another seat's in-flight registry edit — not mine; I edited nothing.)
- **Quote establishing the release identity the row's clock observed (OpenBao 2.7.2):**
  > `<title>v2.7.2</title>`
  
  Located at the **first stable entry** of the fetched feed: raw byte offset
  **729**, body line **12** (`<entry>` 0 of 10). Same entry's
  `<updated>2026-10-26T20:24:37Z</updated>` is on body line **10**.
- **Release date stated by the feed:** the entry states
  `<updated>2026-10-26T20:24:37Z</updated>`; the feed carries **no
  `<published>` element** (grep count 0).
- **sha256 of fetched body:**
  `a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e`
  (543805 bytes, HTTP 200)
- **Is the quote present at that anchor? — YES.**
  `<title>v2.7.2</title>` occurs exactly once (grep -F count = 1) and is the
  first stable `X.Y.Z` entry title in the feed.
- **The registry's currently recorded quote for this row**
  (`<title>v2.7.1</title>`, locator "first stable entry"): the **literal
  string is still present** in the fetched body (count = 1, byte offset 39061),
  but its **locator no longer holds** — `v2.7.1` is now the **third** stable
  entry (updated `2026-10-01T18:32:18Z`, unchanged); entry 1 is `v2.6.5`
  (updated `2026-10-26T20:23:12Z`), so entry order is not the newest stable
  release and "first stable entry" now resolves to `v2.7.2`.
- **Scope guards still needed, and still visible in the feed:** the same feed
  carries `api/v2.7.1: Add changelog entry for v2.7.1 CVE fixes` (count 1),
  `sdk/v2.7.1: Bump kms/transit (#4064) (#4072)` and
  `v2.7.0-beta20260909`; the row's "excludes api/ and sdk/ module releases
  and beta tags" scope is still live.
- **Cross-check against the committed receipt:** the lane's own extractor
  (`corpus/release-clock.py` → `parse_latest_version`) run against these
  fetched bytes returns **2.7.2**, matching the receipt rows for the S035 feed
  (`observe-live.json`, `S014`/`S015`/`S016`/`S021`/`S025`/`S026`,
  `parsed_version 2.7.2`, `verdict fired`). The body sha256 above is
  byte-identical to the sha256 the receipt records for that URL
  (`a54d1a5314ca7016…`).

---

## S040 — re whitespace teaching, round-26 documentation

- **URL:** https://docs.python.org/3/library/re.html
- **Access date:** 2026-11-04
- **Registry recheck cell (as read, HEAD `09f27e2`):** `on-release`; status
  `mined`; opened `2026-10-21`; used-by `corpus/lessons/round-26.md`
  (the working tree already carries `opened 2026-11-04` for this row from
  another seat's in-flight registry edit — not mine; I edited nothing.)
- **Quote establishing the release identity the row's clock observed (Python 3.15.2):**
  > `Python 3.15.2 documentation`
  
  Located in the page `<title>` (body line 20, raw bytes):
  `<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>`.
  Under the committed normaliser (`rendered-text-v1 locate`) the string
  `Python 3.15.2 documentation` occurs **count = 1**, at the very head of the
  rendered text.
- **Release date stated by the feed:** the docs page states **no release date**
  for 3.15.2. It states only a page-maintenance stamp,
  `Last updated on Nov 04, 2026 (23:57 UTC)` — that is a page-update marker,
  not a release date. The **clock feed named for this row**
  (`release-clocks.tsv` row `S040`, `feed_source_id S039`) is
  https://www.python.org/downloads/feed.rss; fetched on 2026-11-04 it carries
  the item `<title>Python 3.15.2</title>` with
  `pubDate Sun, 25 Oct 2026 04:15:38 +0000` and
  `link https://www.python.org/downloads/release/python-3152/`.
  Feed-body sha256:
  `9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e`
  (3354 bytes, HTTP 200) — byte-identical to the sha256 the receipt records
  for that URL.
- **sha256 of fetched body (the row's own URL):**
  `064fbcb69853dc814b27732f09c640cd205e8a821e9a695d540a7945bf8f8b89`
  (257722 bytes, HTTP 200);
  rendered-text-v1 normalised sha256
  `79e22ea7bea40789f664242baecf1073d9691b55a2cd700f6f40a353446a8a8d`
  (69356 normalised bytes).
- **Is the quote present at that anchor? — YES for the release identity; the
  row's recorded *anchor title* is ABSENT.**
  - `Python 3.15.2 documentation` → present (count = 1).
  - `Python 3.15.1 documentation` → **absent** (`locate` count = 0, exit 1).
    The page no longer carries the 3.15.1 title the anchor cell names; it now
    serves the 3.15.2 title. Per the assignment, this is stated as `absent`
    with what the page now serves — the page serves
    `re — Regular expression operations — Python 3.15.2 documentation`.
  - The row's **teaching quote** is unchanged and still located:
    `Matches Unicode whitespace characters (as defined by str.isspace() ).`
    → `rendered-text-v1 locate` count = **1** (exit 0).
- **Cross-check against the committed receipt:** the receipt row for `S040`
  (`observe-live.json`) names the **feed** https://www.python.org/downloads/feed.rss,
  `parsed_version 3.15.2`, `verdict fired`, `observed_at 2026-11-04T23:42:58Z`,
  `sha256 9ba8856e586659ab…` — reproduced byte-identically by this seat's
  independent fetch of the same URL.

---

## S041 — html.unescape teaching, round-26 documentation

- **URL:** https://docs.python.org/3/library/html.html
- **Access date:** 2026-11-04
- **Registry recheck cell (as read, HEAD `09f27e2`):** `on-release`; status
  `mined`; opened `2026-10-21`; used-by `corpus/lessons/round-26.md`
  (the working tree already carries `opened 2026-11-04` for this row from
  another seat's in-flight registry edit — not mine; I edited nothing.)
- **Quote establishing the release identity the row's clock observed (Python 3.15.2):**
  > `Python 3.15.2 documentation`
  
  Located in the page `<title>` (body line 20, raw bytes):
  `<title>html — HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>`.
  Under the committed normaliser (`rendered-text-v1 locate`) the string
  `Python 3.15.2 documentation` occurs **count = 1**, at the very head of the
  rendered text.
- **Release date stated by the feed:** the docs page states **no release date**
  for 3.15.2; it states only `Last updated on Nov 04, 2026 (23:57 UTC)` (a
  page-update marker, not a release date). The **clock feed named for this row**
  (`release-clocks.tsv` row `S041`, `feed_source_id S039`) is
  https://www.python.org/downloads/feed.rss; the same fetch as above carries
  the item `<title>Python 3.15.2</title>`, `pubDate Sun, 25 Oct 2026
  04:15:38 +0000`, `link https://www.python.org/downloads/release/python-3152/`.
- **sha256 of fetched body (the row's own URL):**
  `1a4f2e2a1f8c1db5949dd85303444654364cc06c3180b2376cf6b307f450bcd8`
  (20100 bytes, HTTP 200);
  rendered-text-v1 normalised sha256
  `b5ae69774891f4070ee2db9503b6ec1509d0b75171f5a0757f103e35cf4b806b`
  (2395 normalised bytes).
- **Is the quote present at that anchor? — YES for the release identity; the
  row's recorded *anchor title* is ABSENT.**
  - `Python 3.15.2 documentation` → present (count = 1).
  - `Python 3.15.1 documentation` → **absent** (`locate` count = 0, exit 1).
    The page now serves
    `html — HyperText Markup Language support — Python 3.15.2 documentation`.
  - The row's **teaching quote** is unchanged and still located:
    `This function uses the rules defined by the HTML 5 standard for both valid
    and invalid character references` → `rendered-text-v1 locate` count = **1**
    (exit 0). Note for a reader checking by hand: in the **raw** HTML the
    sentence is wrapped across a newline ("…HTML 5 standard\nfor both valid…"),
    so a raw single-line substring search returns 0; under the lane's declared
    normaliser (tags → one space, entities → Unicode, whitespace collapsed) it
    is located. Quote the rendered form, not the raw form.
- **Cross-check against the committed receipt:** the receipt row for `S041`
  (`observe-live.json`) names the feed https://www.python.org/downloads/feed.rss,
  `parsed_version 3.15.2`, `verdict fired`, `observed_at 2026-11-04T23:42:58Z`,
  `sha256 9ba8856e586659ab…` — reproduced byte-identically by this seat's
  independent fetch of the same URL.

---

## Absence summary (verbatim, no paraphrase)

| id | recorded quote | present at that anchor? | what the page now serves |
|---|---|---|---|
| S034 | `<title>v2.2.0</title>` (first stable entry) | string present, locator stale | first stable entry is now `<title>v2.2.1</title>`; `v2.2.0` is the second entry |
| S035 | `<title>v2.7.1</title>` (first stable entry) | string present, locator stale | first stable entry is now `<title>v2.7.2</title>`; entry 1 is `v2.6.5`, `v2.7.1` is the third |
| S040 | anchor title `Python 3.15.1 documentation` | **absent** | `re — Regular expression operations — Python 3.15.2 documentation` |
| S041 | anchor title `Python 3.15.1 documentation` | **absent** | `html — HyperText Markup Language support — Python 3.15.2 documentation` |

The four teaching/release quotes that carry the rows' substantive claims
(`<title>v2.2.1</title>`, `<title>v2.7.2</title>`, the `str.isspace()`
sentence, the HTML 5 sentence) are all **located** in the fetched bytes.
