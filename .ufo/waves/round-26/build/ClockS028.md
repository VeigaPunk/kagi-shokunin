# ClockS028 — round 26 C1 freshness: S028 (`html.unescape`) against Python 3.15.1

Observed BASE: `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`). The worktree shows only the
untracked `.ufo/waves/round-26/` and `plans/round-26.md`. Production files were read only. Observations were
taken 2026-10-21T13:36:36Z and 13:38:00Z (UTC). No tools were installed; I used the host's `curl` and its
Python 3.14.8 to run the committed normalizer. Evidence lives in
`.ufo/waves/round-26/build/ClockS028-evidence/`.

## Bounded result

- **S028's clock FIRED.** The feed's highest stable version is 3.15.1, but the row is anchored at 3.15.0.
- **The S028 teaching still HOLDS on the 3.15.1 docs.** The declared quote is located once (count=1) in the
  served Python 3.15.1 page.
- **The documentation text did not change.** In the rendered-text-v1 text of this page, 3.15.0 and 3.15.1
  differ only in version labels and the footer timestamp.
- **This is docs-level evidence only.** It does not show that the 3.15.1 stdlib *implementation* of
  `html.unescape` behaves the same. That gap is listed under "Unresolved" below.

## Rows under test (BASE, read only)

- `corpus/SOURCES.md:34` (S028): `https://docs.python.org/3/library/html.html`. Anchor: "`html.unescape(s)`
  (#html.unescape); Python 3.15.0 documentation, page last updated 2026-10-21"; recheck `on-release`.
- `corpus/release-clocks.tsv:25`: `S028 feed S036 https://www.python.org/downloads/feed.rss 3.15.0 3.15.0
  2026-10-21 not-fired` (this round-25 binding is historical).
- `corpus/source-fetches.tsv:71`: decoded body `b4594556…f3b` (20100 bytes), normalized `7a19837f…6ed1`,
  quote locate profile `rendered-text-v1`.

## Clock: S036 feed (re-opened this round)

Command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D feed-profile.headers -o feed-profile.rss https://www.python.org/downloads/feed.rss`

- Result: HTTP 200, exit 0, 3357 bytes, sha256 `11c86a3481551067676403f66bc23b3d7dd1f5de14f32bbacafed239d13ca66b`.
  Headers: `last-modified: Wed, 21 Oct 2026 13:08:09 GMT`, `age: 133`. A default-user-agent fetch at
  13:36:36Z returned the same digest.
- Item order in the feed (title, pubDate):
  - `Python 3.14.9`, Wed, 21 Oct 2026 13:08:09 +0000
  - `Python 3.15.1`, Wed, 21 Oct 2026 09:59:50 +0000, link `/downloads/release/python-3151/`
  - `Python 3.16.0a1`, Tue, 13 Oct 2026
  - `Python install manager 26.4`
  - `Python 3.15.0`, Fri, 09 Oct 2026 13:54:59 +0000
- `corpus/release-clock.py:654-699` (`parse_latest_version`) takes the **max X.Y.Z** over titles matching
  `STABLE_TITLE_RE` and does not trust feed order. The prerelease 3.16.0a1 and the install-manager item are
  rejected, so the parsed version is **3.15.1**, not the date-newest 3.14.9.
- Cross-check: `.ufo/waves/round-26/observe-1.json:258-266` (L1's observation at 13:36:36Z) records S028
  with `parsed_version "3.15.1"`, `verdict "fired"`, and the same sha256 `11c86a34…a66b`. My fetch matches it
  byte for byte.

## Source: S028 page (re-opened this round)

Command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D html-profile.headers -o html-profile.body https://docs.python.org/3/library/html.html`

- Result: HTTP 200, final URL unchanged, 20100 bytes decoded, sha256
  `8a54138162e47f1bb285f07404309df8556f004ff371140bbbb38d9be70a7122`.
- Headers: `last-modified: Wed, 21 Oct 2026 13:04:30 GMT`, `etag: "6ad8b85e-4e84"`, `x-cache: HIT, HIT`.
- `https://docs.python.org/3.15/library/html.html` returned the identical digest, so `/3/` currently serves
  3.15.
- The page declares itself as `<title>… Python 3.15.1 documentation</title>`, with the breadcrumb
  "3.15.1 Documentation" and the footer "Last updated on Oct 21, 2026 (13:02 UTC)."
- `python3 corpus/rendered-text-v1.py digest html-profile.body` returned normalized sha256
  `ef8996ed93adc1b8f88a14d8c7580712f7c2060ad9e592160c92e84cf2cdb17c` (2395 bytes). This differs from the
  recorded `7a19837f…`, as expected for `decoded-http-body-volatile-v1`. It is not by itself a drift signal.
- `python3 corpus/rendered-text-v1.py locate html-profile.body '<declared quote>'` returned
  `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0.

**Located quote** (anchor `#html.unescape`, html-profile.body lines 226-232, 23 words, identical to the
declared capture quote):

> "Convert all named and numeric character references (e.g. &gt; , &#62; , &#x3e; ) in the string s to the
> corresponding Unicode characters."

The same definition continues with "uses the rules defined by the HTML 5 standard for both valid and
invalid character references" (count=1). That sentence supports the row's "under HTML 5 rules" wording.
The row's "after tag removal" clause is kagi's own ordering declaration in `corpus/rendered-text-v1.py`
steps 3-4. It is not Python's teaching, and this page cannot confirm or refute it.

## 3.15.0 vs 3.15.1 comparison (same page, versioned archive)

Command: `curl -sSL --compressed -o html3150rel.body https://docs.python.org/release/3.15.0/library/html.html`

- Result: HTTP 200, 19540 bytes, sha256 `ed0ca0ad…eb14`, `last-modified: Fri, 09 Oct 2026 11:46:16 GMT`.
  The page reads "Python 3.15.0 documentation" with the footer "Last updated on Oct 09, 2026 (11:45 UTC)".
- Normalizing it gives sha256 `d3e59063…c372` at 2395 bytes, the same byte count as 3.15.1. The quote
  `locate` returns count=1.
- A `difflib` comparison of the two normalized texts (saved as `html-3.15.0.norm.txt` and
  `html-3.15.1.norm.txt`) finds only these changes:
  - "Python 3.15.0 documentation" → "Python 3.15.1 documentation" (the title)
  - "Python » 3.15.0 Documentation" → "3.15.1" (both breadcrumbs)
  - the footer "Oct 09, 2026 (11:45 UTC)" → "Oct 21, 2026 (13:02 UTC)"
- The raw HTML diff adds only chrome: social-preview `og:*` and `twitter:card` metadata, an analytics
  script, `switchers.js`, and a new `documentation_options.js` cache key.
- Result: **zero normalized-text change** to the `html.unescape` definition, or to any other teaching text
  on the page.
- Limitation: the archived 3.15.0 build (19540 bytes) is a different deployment from the round-24 `/3/`
  capture (20100 bytes). The comparison is between rendered texts, not against the original capture bytes,
  which the repository does not retain.

## Disposition (lane advice for L1)

1. **The clock fired; the teaching is unchanged.** This follows the S012 precedent at `release-clocks.tsv:9`.
   A new observation would read:
   `S028	feed	S036	https://www.python.org/downloads/feed.rss	3.15.0	3.15.1	2026-10-21	fired	anchor names Python 3.15.0; Python 3.15.1 (2026-10-21) is past it, so the clock FIRED; the html.unescape quote re-located on the 3.15.1 docs`
   - This line passes the anchor check: `version_is_named` finds "3.15.0" in the S028 anchor
     (`release-clock.py:518`).
   - Whether it supersedes `:25` or lands in a new round-26 binding is L1's call. Round 25's row and its
     receipt are not rewritten.
2. **Counterexample: the anchor is stale.** S028's anchor says "Python 3.15.0 documentation", but `/3/` now
   serves 3.15.1. Two options:
   - Keep the anchor at 3.15.0 and record the fired verdict, as S012 did.
   - Add a superseding row whose anchor names "Python 3.15.1 documentation", bound `not-fired` at
     3.15.0→3.15.1. A `3.15.1` anchored_version against the *current* anchor text fails `anchor_ok` unless
     the note starts `derived:`.
3. **No superseding registry row is needed for the teaching.** The quote, the `#html.unescape` anchor id,
   and the HTML 5-rules sentence are unchanged.
4. **Counterexample: the S036 wording.** `SOURCES.md:42` describes the clock as the "newest stable X.Y.Z
   item", and its teaching says "Newest stable CPython is 3.15.0".
   - Read by feed order, the newest stable *item* is now 3.14.9, a maintenance release of an older branch.
   - The code (max version) is correct, but the prose invites the wrong reading, and its 3.15.0 claim is now
     false.
   - S036 is `90d`, not `on-release`, so it does not fire. Its wording and teaching still need a superseding
     row or an explicit disposition if L1 records S036 facts this round.

## Unresolved / not run

- I did not check implementation behavior. The host has Python 3.14.8, no 3.15.1 interpreter was run, and
  the plan forbids claiming a Python upgrade. Docs-level unchanged text is not proof that 3.15.1 changes no
  `html.unescape` edge cases.
- I did not open the 3.15.1 changelog or `Lib/html/__init__.py` diff, because the fetch scope was limited to
  the S028 source and its clock.
- I did not run the `release-clock.py` gate, the selftest, or the census. Production verification is
  L1-only.
- The comparison covers this one page only. It says nothing about S027 or other docs pages.

## Evidence files (`.ufo/waves/round-26/build/ClockS028-evidence/`)

- 3.15.1 page: `html-profile.body` and `.headers` (declared profile), plus `html.body` and `.headers`
  (default user agent, same digest).
- `html3150.body` (the `/3.15/` route, same digest).
- 3.15.0 archive: `html3150rel.body` and `.headers`.
- Feed: `feed-profile.rss` and `.headers`, plus `feed.rss` and `.headers`.
- `html-3.15.0.norm.txt` and `html-3.15.1.norm.txt`.
