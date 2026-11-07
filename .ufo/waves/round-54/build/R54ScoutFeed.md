# R54ScoutFeed — independent live re-opening of the C1 sources (S112, S072, the two rejected addresses)

Seat: `R54ScoutFeed` (scout, leaf member — no subagent dispatch).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317` → CANDIDATE `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14` (read at
HEAD `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`).
Scratch: `/fast/scratch/hyaku/kagi-r54/R54ScoutFeed/` (bodies, headers, scripts).
Raw receipts (fetch metadata, cmp exits, parser outcomes, endpoint probe table, word-count table):
`.ufo/waves/round-54/build/R54ScoutFeed-receipts.txt` (this seat's own file, 9.8 kB).
Nothing was installed; no
tool was updated (nothing needed one — `curl`, `python3`, `sha256sum`, `cmp` from the host were sufficient).
All network reads were plain GETs of public pages/archives with a plain UA; no login, no form post, no write
to any remote; no `op` invocation of any kind; no token/secret/key value read or printed.

Request profile used (as specified): `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`.

---

## 1. S112 feed — live re-open

`https://releases.1password.com/developers/cli/index.xml`

| field | live (2026-11-07, this seat) | committed capture / registry |
|---|---|---|
| HTTP status | `200` | `200` (`corpus/source-fetches.tsv` S112 row) |
| content-type | `text/xml` | `text/xml` |
| decoded byte count | `45175` B | `45175` B |
| sha256 (decoded body) | `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2` | `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2` |
| final URL | `https://releases.1password.com/developers/cli/index.xml` | same |

Commands (exit codes as returned):

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o s112.body -w 'HTTP_STATUS=%{http_code} …' -D s112.headers \
  https://releases.1password.com/developers/cli/index.xml      # exit 0
wc -c s112.body                                                # 45175 s112.body
sha256sum s112.body                                            # 2dce505a…65405e2  s112.body
cmp s112.body …/capture/S112.body                              # exit 0 → byte-identical
```

`cmp` exit 0 ⇒ my live body is **byte-identical** to the committed capture
`.ufo/waves/round-54/capture/S112.body` and to the digest the registry row and the clock receipt carry.
Response headers (public, non-secret): `server: AmazonS3`, `last-modified: Thu, 05 Nov 2026 20:36:59 GMT`,
`etag: W/"454c2805510fcda7fd9af75c79b7156e"`, `content-encoding: gzip`, `cache-control: max-age=60`,
`x-cache: RefreshHit from cloudfront`, `date: Sat, 07 Nov 2026 06:17:35 GMT`.

### Feed contents

- **27 items** (`<item>` elements) — matches the lesson's "27 release items".
- Every title is exactly `1Password CLI X.Y.Z` (0 titles deviating): the first is `1Password CLI 2.22.0`
  (pubDate `Tue, 24 Oct 2023 00:00:00 +0000`), the last is `1Password CLI 2.42.0`.
- **Newest stable observed: `1Password CLI 2.42.0`** (max version tuple (2,42,0) over all items; the item
  order in the feed is ascending, so the newest is also the last). Version ladder tail:
  2.38.1, 2.39.0, 2.40.0, 2.41.0, 2.41.1, **2.42.0**.
- The feed contains **no beta items** (betas live on a separate feed, §5 below) and no pre-release tokens.

### Quote location (byte search, `raw-literal-v1`)

- Literal `<title>1Password CLI 2.42.0</title>` — **count = 1**, **byte offset = 37215** in the live body
  (regex `finditer` over the decoded bytes; the committed `corpus/quote-bodies.tsv` S112 row records the same
  offset `37215`). The committed `corpus/source-fetches.tsv` row records the same quote and `count` implicitly
  via `raw-literal-v1`.

### The 2.42.0 item, read from the capture bytes

```
<item><title>1Password CLI 2.42.0</title>
<link>https://releases.1password.com/developers/cli/2.42.0/</link>
<pubDate>Wed, 04 Nov 2026 00:00:00 +0000</pubDate>
<guid>https://releases.1password.com/developers/cli/2.42.0/</guid>…
```

### Anchor-cell comparison, character by character (round-53 closure D1)

S112 anchor cell (`corpus/SOURCES.md:119`, cell 6):
`Item titled 1Password CLI 2.42.0, link /developers/cli/2.42.0/, item pubDate Wed, 04 Nov 2026 00:00:00 +0000; feed fetched 2026-11-07`

| field | anchor cell | capture bytes | equal? |
|---|---|---|---|
| title | `1Password CLI 2.42.0` | `1Password CLI 2.42.0` | **exact match** |
| pubDate | `Wed, 04 Nov 2026 00:00:00 +0000` | `Wed, 04 Nov 2026 00:00:00 +0000` | **exact match** (byte-for-byte, comma and offset included — this is the D1 defect that was fixed) |
| link | `/developers/cli/2.42.0/` | `https://releases.1password.com/developers/cli/2.42.0/` | **not byte-equal**: the cell carries the path suffix, the capture carries the absolute URL; the cell string *is* an exact suffix of the capture string |
| fetched | `2026-11-07` | feed fetched 2026-11-07 (registry + fetch row) | match |

**Verdict on the anchor cell: AGREE.** The D1 defect (the paraphrased `pubDate Wed 04 Nov 2026`) is gone — the
timestamp now equals the capture byte for byte. The only divergence is the link form (path vs absolute URL),
which is the lane's existing convention rather than a paraphrase: the S111 anchor cell likewise writes
`tag link /releases/tag/v1.3.2` where the Atom `href` is the absolute
`https://github.com/FiloSottile/age/releases/tag/v1.3.2` (8 of 112 anchor cells contain a `link ` field).
No D1-class defect remains.

### Cross-check of the same facts in the other landed artifacts

- `corpus/release-clocks.tsv` S072 row: `S072⇥feed⇥S112⇥https://releases.1password.com/developers/cli/index.xml⇥2.41.1⇥2.42.0⇥2026-11-07⇥fired⇥<note>` — 9 TAB fields, anchored `2.41.1`, observed `2.42.0`, verdict `fired`.
- `.ufo/waves/round-54/final/observe-r54.json`: exactly one `S072` observation —
  `{"clock": "feed", "http_status": 200, "id": "S072", "located": null, "observed_at": "2026-11-07T05:54:19Z", "parsed_version": "2.42.0", "sha256": "2dce505a…65405e2", "url": "https://releases.1password.com/developers/cli/index.xml", "verdict": "fired"}`
  — its `sha256` equals the committed capture digest (the counter's K1-F14 link). 32 observations total,
  **0 errors**; verdict breakdown `fired=14`, `quote-located=11`, `not-fired=7`; the fired set is
  S012–S016, S021–S028 and S072 (13 pre-existing + S072), matching the plan's "13 earlier fired rows + S072".
- `corpus/SOURCES.md:119` is the **only** registry row whose URL is the S112 feed (a registry-wide scan for
  `releases.1password.com/developers/cli/index.xml` returns one row); kind `docs`, tier `A`, status `mined`,
  recheck `90d` (i.e. S112 is not itself on-release — correct, S072 is the on-release row).

---

## 2. S072 page — live re-open

`https://app-updates.agilebits.com/product_history/CLI2`

| field | live (this seat) | committed rejection receipt |
|---|---|---|
| HTTP status | `200` | `200` |
| content-type | `text/html;charset=utf-8` | `text/html;charset=utf-8` |
| decoded byte count | `528203` B | `528203` B |
| sha256 | `bb179199193f3dfd7cd773dd35a0dab1e5c0edbe671c3be7ceb3cda901c0e7a5` | same |
| final URL | `https://app-updates.agilebits.com/product_history/CLI2` | same |

`cmp cli2.body …/capture/rejections/app-updates_agilebits_com_product_history_CLI2.body` → exit 0, byte-identical
to the committed rejection receipt.

- **The 2.41.1 heading S072 quotes is still present.** The heading for `<article id="v2410101">` is
  `2.41.1 (build #2410101) – released 2026-10-21` (after HTML entity unescaping `&nbsp;` → space); the
  S072 anchor cell's quoted heading is character-for-character identical to it, including the en dash.
  The article id `v2410101` is present in the live page.
- **2.42.0 does appear on the page**: `<article id="v2420001">`, heading
  `2.42.0 (build #2420001) – released 2026-11-03`. So the release-notes page does carry the newer release; it
  is simply not machine-readable (see §3).
- Beta headings are also present (`2.44.0-beta.01` build #2440001 released 2026-11-03; `2.43.0-beta.02`;
  `2.42.0-beta.01`; …) — the page mixes stable and beta sections, another reason it is a poor clock source.
- Counts reproduced from the live body match the committed receipt exactly: `2.42.0` appears **68** times,
  `2.41.1` **34** times (receipt states `count("2.42.0")=68`).

**Date observation (not a defect):** the page says 2.42.0 was *released 2026-11-03*, while the S112 feed's
`pubDate` for the same item is `Wed, 04 Nov 2026 00:00:00 +0000`. The S112 anchor cell quotes the **feed's**
pubDate, and quotes it byte-exactly, so D1 is satisfied; the one-day difference between the page's release
date and the feed's publication date is expected (feed published next day) and is not something the cell
claims otherwise.

---

## 3. The two rejected addresses, re-checked with the gate's own parser

Both rejections are re-fetched live by this seat, and both live bodies are byte-identical to the committed
rejection receipts.

| address | live status / type / bytes | sha256 (live == receipt) | receipt file |
|---|---|---|---|
| `https://app-updates.agilebits.com/product_history/CLI2` | 200 / `text/html;charset=utf-8` / 528203 | `bb179199…e0e7a5` | `…/capture/rejections/app-updates_agilebits_com_product_history_CLI2.{meta,body}` |
| `https://releases.1password.com/developers/cli/` (HTML index) | 200 / `text/html` / 96166 | `0cfbd208…1e49acf` | `…/capture/rejections/releases_1password_com_developers_cli_.{meta,body}` |

Both bodies contain exactly one `<!DOCTYPE` and **no** `<!ENTITY` declaration.

`parse_latest_version` imported from `corpus/release-clock.py` (candidate tree) run on **my** fetched bodies:

| body | `prefix=None` | `prefix='1Password CLI'` |
|---|---|---|
| `s112.body` (S112 feed) | REFUSED — `ValueError: feed has no stable X.Y.Z release entry` | **`'2.42.0'`** |
| `cli2.body` (CLI2 page) | REFUSED — `ValueError: XML DTD and entity declarations are not allowed` | REFUSED — `ValueError: XML DTD and entity declarations are not allowed` |
| `clihtml.body` (HTML index) | REFUSED — `ValueError: XML DTD and entity declarations are not allowed` | REFUSED — `ValueError: XML DTD and entity declarations are not allowed` |

This reproduces the committed rejection receipts exactly (`parse(prefix=None) refused: XML DTD and entity
declarations are not allowed` / `parse(prefix='1Password CLI') refused: …` on both).

**Verdict on rejection #1 (CLI2 page): AGREE.** The page is HTML with a DOCTYPE; the gate's parser refuses it
by rule before any title logic runs (the DTD/entity guard at `corpus/release-clock.py:836-837`). The lesson's
reasoning holds: a rendered-quote clock on it would only watch whether the `2.41.1` heading stays present,
which it does — so such a clock could never fire on the 2.42.0 release that S072's on-release recheck must
watch. The page legitimately stays S072's *identity* source (it is where the `2.41.1` / build `#2410101`
identity and its article id live), and it is not its clock.

**Verdict on rejection #2 (HTML index of the same site): AGREE.** Same parser refusal, same reason
(`<!DOCTYPE` present). Confirmed independently: the HTML index itself advertises the RSS form —
`Subscribe to the <a href=/developers/cli/index.xml>RSS feed</a> for 1Password CLI release notes.` — so the
machine-readable form of that index *is* S112. The HTML index also carries `2.42.0` five times
(`count("2.42.0")=5` in the receipt), matching my live count exactly.

**Gate decisions, summarized:**

| Gate decision | verdict | reason (live evidence) |
|---|---|---|
| **S112 admit** (new feed row, primary op CLI release source) | **AGREE** | 200/`text/xml`, 45175 B, sha256 `2dce505a…` == committed capture == registry row == receipt digest; 27 items, all titles exactly `1Password CLI X.Y.Z`; newest stable **2.42.0**; quote `<title>1Password CLI 2.42.0</title>` count 1 offset 37215; the gate's own parser reads `2.42.0` under the declared prefix and refuses the same body without it. |
| **Reject #1 — `app-updates.agilebits.com/product_history/CLI2` as the clock's feed** | **AGREE** | HTML + DOCTYPE ⇒ parser refuses by rule with *and* without the prefix; a rendered-quote clock could not fire on 2.42.0; the page remains S072's identity source (2.41.1 heading + article id `v2410101` present and character-exact). |
| **Reject #2 — `releases.1password.com/developers/cli/` (HTML index) as the clock's feed** | **AGREE** | HTML + DOCTYPE ⇒ parser refuses by rule; the index itself links the RSS feed as its machine-readable form, i.e. S112. |

---

## 4. Word counts for every quote in the lesson's `## Gate` (E49-1)

Rule as stated in `corpus/lessons/round-54.md:19`: *every word count in this `## Gate` is
`printf '%s' "<quote>" | wc -w`, run on each quote before writing it.*

The lesson states **exactly one** count: the S112 title quote is "(3 words: `printf '%s' '<title>1Password CLI 2.42.0</title>' | wc -w` prints 3)".

| quote | `printf '%s' "<quote>" \| wc -w` | stated in lesson | agree? |
|---|---|---|---|
| `<title>1Password CLI 2.42.0</title>` | **3** | **3** | **AGREE** |
| `Wed, 04 Nov 2026 00:00:00 +0000` | 6 | (none stated) | — |
| `https://releases.1password.com/developers/cli/2.42.0/` | 1 | (none stated) | — |
| `pubDate Wed 04 Nov 2026` (the retracted D1 paraphrase, quoted for contrast) | 5 | (none stated) | — |
| `1Password CLI X.Y.Z` | 3 | (none stated) | — |
| `2.42.0` | 1 | (none stated) | — |
| `feed has no stable X.Y.Z release entry` | 7 | (none stated) | — |
| `XML DTD and entity declarations are not allowed` | 8 | (none stated) | — |
| `2.41.1` | 1 | (none stated) | — |
| `https://releases.1password.com/developers/cli/index.xml` | 1 | (none stated) | — |
| `curl-fsSL-compressed-v1` | 1 | (none stated) | — |
| `180d` / `on-release` | 1 / 1 | (none stated) | — |
| `printf '%s' "<quote>" | wc -w` (the rule's own command) | 6 | (none stated) | — |

**Verdict: AGREE.** The one stated count (3) is exactly what the stated command prints; no count in the
`## Gate` disagrees with `wc -w`. (For reference, the historical failures this rule exists for are
M49-3/M53-6 in earlier lessons — not repeated here.)

---

## 5. Is S112 the right primary source? — survey of other official machine-readable op CLI release endpoints

Probed live (plain GET, same UA), status/type/decoded-size:

| URL | result |
|---|---|
| `https://releases.1password.com/developers/cli/index.xml` | **200 `text/xml`, 45175 B decoded** — the S112 feed |
| `https://releases.1password.com/developers/cli-beta/index.xml` | 200 `text/xml`, 5542 B — beta-only feed (titles `1Password CLI Beta 2.44.0-beta.01`, `… 2.43.0-beta.02`, …) |
| `https://releases.1password.com/developers/index.xml` | 200 `text/xml`, 13739 B — "Developers" feed: CLI **and** CLI Beta items mixed |
| `https://releases.1password.com/index.xml` | 200 `text/xml`, 3136276 B decoded — the whole-site releases feed (1824 items; 44 CLI-titled items incl. betas) |
| `https://releases.1password.com/sitemap.xml` | 200 `text/xml`, 10821 B — sitemap, not a release feed |
| `https://releases.1password.com/developers/cli/atom.xml` / `index.json` / `releases.json` / `rss.xml` / `feed.xml` / `index.rss` | 404 (HTML) |
| `https://releases.1password.com/api/developers/cli/releases.json` | 404 (HTML) |
| `https://app-updates.agilebits.com/product_history/CLI2.json` / `.xml` / `.rss` / `.atom` / `product_history.json` / `feed/CLI2.xml` / `product_history/CLI2/feed` | 404 (HTML) |
| `https://app-updates.agilebits.com/product_history/CLI2?format=json` | 200 but still `text/html;charset=utf-8`, same 74323-byte compressed body — the query string does not switch representation |
| `https://app-updates.agilebits.com/api/v1/updates` | 404 |
| `https://releases.1password.com/developers/cli/feed` | 301 (redirect; `-L` resolves to the HTML index, not a feed) |
| `https://cache.agilebits.com/dist/1P/op2/pkg/` | 404 (no directory listing) — binaries are per-version paths only |

**No JSON or Atom endpoint for the op CLI release identity exists on either vendor host** — the RSS feeds are
the only machine-readable forms, and there is no `op`-versioned JSON API (the CLI itself prints its version,
but that is a local binary, not a source page).

**Verdict: S112 IS the right primary source — AGREE.** It is (a) the endpoint the vendor's own HTML index
advertises as the RSS feed for CLI release notes, (b) scoped to the CLI only (no betas, no other products), so
its newest stable item is unambiguous, (c) the smallest of the four live feeds that carry CLI identities
(45175 B vs 13739 B for the Developers feed vs 3.1 MB site-wide vs a separate beta feed), and (d) stable-only,
so no beta heading can ever be mistaken for the newest stable. The alternatives were also parsed to show why
they are inferior, not merely worse:

- `developers/index.xml` and the site-wide `index.xml` both parse to `2.42.0` under the declared prefix, but
  they mix `1Password CLI Beta 2.44.0-beta.01`-style items and other products; the anchored prefix rule
  correctly refuses those beta titles (`^1Password CLI v?(\d+\.\d+\.\d+)$` — verified: `1Password CLI Beta
  2.44.0-beta.01` → no match, `1Password CLI 2.42.0` → match), so they would work today but are strictly
  noisier and larger. The dedicated CLI feed removes the question entirely.
- `developers/cli-beta/index.xml` parses to **REFUSED** under the declared prefix (all its titles carry the
  `Beta` word) — correctly, since a clock must watch the newest *stable* item.

### Prefix-rule spot-check (the mechanism S112 depends on)

`prefixed_title_re("1Password CLI")` = `^1Password\ CLI\ v?([0-9]+\.[0-9]+\.[0-9]+)$`:

| title | matches? |
|---|---|
| `1Password CLI 2.42.0` | **yes** |
| `1Password CLI v2.42.0` | yes (the `[v]` form the rule allows) |
| `1Password CLI 2.42.0 extra` | no (anchored at both ends) |
| `x1Password CLI 2.42.0` | no |
| `1Password CLI 2.42.0.1` | no |
| `1Password CLI 2.42` | no |
| `1Password CLI 2.42.0-beta.01` | no |
| `1Password CLI Beta 2.44.0-beta.01` | no |
| `Python install manager 26.4.1` | no (the CPython feed stays refused — the plan's stated invariant) |

---

## 6. Supporting runs (read-only) for context

- `python3 corpus/release-clock.py --selftest` on the candidate tree extracted from
  `git archive ede4373afa…`: last line `RELEASE_CLOCK_SELFTEST: PASS (121 cases)`, exit 0 — the plan's
  stated 116 → 121 holds.
- `python3 corpus/quote-locate.py` (lane root): last line `QUOTE_LOCATE: CLEAN located=10 rows=10`.
- `bash plans/round-54-c1.sh ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`:
  `C1_OP_CLOCK: value=2 watched=1 measured=1 guard=1 (bad=watched:OK measured:OK; gate-line=RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17))`, exit 0.
  (Context only — the counter's own verdict is the integrator's to read; the point here is that the frozen
  reading of the candidate tree is reproducible at the tip I fetched from.)
- Public header check on the official op 2.42.0 archive named by the plan,
  `https://cache.agilebits.com/dist/1P/op2/pkg/v2.42.0/op_linux_amd64_v2.42.0.zip`:
  `HTTP/2 200`, `content-type: application/zip`, `content-length: 16233648`,
  `last-modified: Wed, 04 Nov 2026 20:49:39 GMT`, `etag: "c56f1c53673443078ee4f6cbcfba5393-2"`. The archive
  exists and is publicly downloadable; I did not download or execute it (that measurement is another seat's
  scope, and the plan's receipt is what the counter reads).

---

## 7. Findings summary

| # | finding | confidence |
|---|---|---|
| F1 | S112 feed re-fetched live: 200 / `text/xml` / 45175 B / sha256 `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2` — **byte-identical** to the committed capture, the registry fetch row, the quote-bodies row and the S072 receipt digest. | observed (high) |
| F2 | Newest stable op CLI release observed: **2.42.0** (27 items, all titles exactly `1Password CLI X.Y.Z`; no betas in this feed). | observed (high) |
| F3 | Quote `<title>1Password CLI 2.42.0</title>` — count **1**, byte offset **37215**; matches `corpus/quote-bodies.tsv` S112 row offset 37215. | observed (high) |
| F4 | Anchor cell: title and pubDate **byte-exact** vs the capture (D1 fixed); link is written as the path suffix `/developers/cli/2.42.0/` (capture holds the absolute URL) — same convention as S111's `tag link /releases/tag/v1.3.2`, not a paraphrase defect. | observed (high) |
| F5 | S072 page live: 2.41.1 heading present and character-exact (`2.41.1 (build #2410101) – released 2026-10-21`, article id `v2410101`); 2.42.0 also present (`build #2420001`, released 2026-11-03). | observed (high) |
| F6 | Both rejected addresses: live bodies byte-identical to their receipts; `parse_latest_version` refuses both with and without the prefix, with the DTD/entity rule — the rejection reasons are reproducible, not asserted. | observed (high) |
| F7 | The single stated word count in the lesson's `## Gate` (3 for the title quote) equals `wc -w`; no count disagrees. | observed (high) |
| F8 | S112 is the correct primary machine-readable source: the vendor's own HTML index advertises it as the RSS feed; it is CLI-scoped and stable-only; no JSON/Atom op-CLI release endpoint exists on either vendor host (`?format=json` on CLI2 still returns HTML). Two larger feeds also carry the CLI items and parse to 2.42.0, and the separate beta feed is correctly refused by the prefix rule. | observed (high) |
| F9 | Page-vs-feed date nuance: CLI2 says 2.42.0 released 2026-11-03; the feed's `pubDate` is `Wed, 04 Nov 2026 00:00:00 +0000`. The anchor cell quotes the feed's pubDate exactly, so no D1-class defect; the nuance is a feed-publication-date vs release-date difference. | observed (high) |

**Gate verdicts: S112 admit — AGREE. Rejection #1 (CLI2 page) — AGREE. Rejection #2 (HTML index) — AGREE.**

## Appendix A — every item title in the S112 feed (live body, 27 items, in feed order)

| # | title | pubDate | link |
|---|---|---|---|
| 1 | `1Password CLI 2.22.0` | Tue, 24 Oct 2023 00:00:00 +0000 | https://releases.1password.com/developers/cli/2.22.0/ |
| 2 | `1Password CLI 2.23.0` | Thu, 16 Nov 2023 00:00:00 +0000 | …/2.23.0/ |
| 3 | `1Password CLI 2.24.0` | Thu, 14 Dec 2023 00:00:00 +0000 | …/2.24.0/ |
| 4 | `1Password CLI 2.25.0` | Mon, 26 Feb 2024 00:00:00 +0000 | …/2.25.0/ |
| 5 | `1Password CLI 2.25.1` | Tue, 12 Mar 2024 00:00:00 +0000 | …/2.25.1/ |
| 6 | `1Password CLI 2.26.0` | Tue, 19 Mar 2024 00:00:00 +0000 | …/2.26.0/ |
| 7 | `1Password CLI 2.26.1` | Fri, 22 Mar 2024 00:00:00 +0000 | …/2.26.1/ |
| 8 | `1Password CLI 2.27.0` | Wed, 17 Apr 2024 00:00:00 +0000 | …/2.27.0/ |
| 9 | `1Password CLI 2.28.0` | Wed, 01 May 2024 00:00:00 +0000 | …/2.28.0/ |
| 10 | `1Password CLI 2.29.0` | Tue, 21 May 2024 00:00:00 +0000 | …/2.29.0/ |
| 11 | `1Password CLI 2.30.0` | Wed, 31 Jul 2024 00:00:00 +0000 | …/2.30.0/ |
| 12 | `1Password CLI 2.30.3` | Thu, 07 Nov 2024 00:00:00 +0000 | …/2.30.3/ |
| 13 | `1Password CLI 2.31.0` | Wed, 07 May 2025 00:00:00 +0000 | …/2.31.0/ |
| 14 | `1Password CLI 2.31.1` | Wed, 28 May 2025 00:00:00 +0000 | …/2.31.1/ |
| 15 | `1Password CLI 2.32.0` | Tue, 19 Aug 2025 00:00:00 +0000 | …/2.32.0/ |
| 16 | `1Password CLI 2.32.1` | Thu, 05 Feb 2026 00:00:00 +0000 | …/2.32.1/ |
| 17 | `1Password CLI 2.33.0` | Mon, 16 Mar 2026 00:00:00 +0000 | …/2.33.0/ |
| 18 | `1Password CLI 2.33.1` | Tue, 24 Mar 2026 00:00:00 +0000 | …/2.33.1/ |
| 19 | `1Password CLI 2.34.0` | Thu, 16 Apr 2026 00:00:00 +0000 | …/2.34.0/ |
| 20 | `1Password CLI 2.34.1` | Tue, 09 Jun 2026 00:00:00 +0000 | …/2.34.1/ |
| 21 | `1Password CLI 2.35.0` | Mon, 13 Jul 2026 00:00:00 +0000 | …/2.35.0/ |
| 22 | `1Password CLI 2.38.1` | Thu, 30 Jul 2026 00:00:00 +0000 | …/2.38.1/ |
| 23 | `1Password CLI 2.39.0` | Fri, 14 Aug 2026 00:00:00 +0000 | …/2.39.0/ |
| 24 | `1Password CLI 2.40.0` | Thu, 01 Oct 2026 00:00:00 +0000 | …/2.40.0/ |
| 25 | `1Password CLI 2.41.0` | Mon, 12 Oct 2026 00:00:00 +0000 | …/2.41.0/ |
| 26 | `1Password CLI 2.41.1` | Wed, 21 Oct 2026 00:00:00 +0000 | …/2.41.1/ |
| 27 | **`1Password CLI 2.42.0`** | **Wed, 04 Nov 2026 00:00:00 +0000** | **…/2.42.0/** |

Every title matches `1Password CLI [v]X.Y.Z` exactly; no beta/pre-release items in this feed.

Unresolved / out of my scope: the op 2.42.0 dotenv byte measurement itself (another seat, receipt
`.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt`) — I confirmed only that the official archive is
publicly reachable with the expected size/date; I did not download, verify the signature, or run it, and I ran
no `op` subcommand at all. Also out of scope: the counter's kill-rule evaluation and the ledger migrations
(another seat's reads).
