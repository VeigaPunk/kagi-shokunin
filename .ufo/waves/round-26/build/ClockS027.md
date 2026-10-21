# ClockS027 — round 26 freshness re-verification of S027 (Python `re` `\s`)

Seat `KagiR26.ClockS027`, lane-authored advice (not non-author closure).
Observed BASE: `git rev-parse HEAD` = `1bf3eec48d3761580ffd375c88143232485ae814` (equals frozen BASE; worktree shows only untracked `.ufo/waves/round-26/` and `plans/round-26.md`).
Access: 2026-10-21, fetches at 13:36:43Z (`fetched_at.txt`). Tools: system curl 8.23.0, /usr/bin/python3 3.14.8. Installs/updates: none. Production files edited: none.
Artifacts (this seat only): `.ufo/waves/round-26/build/ClockS027-artifacts/`.

## Result

- **Clock:** the S036 feed (`https://www.python.org/downloads/feed.rss`) now lists stable **Python 3.15.1**, published Wed, 21 Oct 2026 09:59:50 +0000. S027's anchor names 3.15.0, so the binding at `corpus/release-clocks.tsv:24` (`3.15.0 → 3.15.0 not-fired`, observed 2026-10-21) is **stale**. Under the declared newest-stable rule this round's observation is **fired**: anchored 3.15.0, observed 3.15.1.
- **Teaching:** it **still holds, unchanged**, on the 3.15.1 documentation. The served page is now titled "re — Regular expression operations — Python 3.15.1 documentation". The S027 capture quote locates exactly once.
- **Drift disposition:** this is a documentation-version relabel, not a change in teaching. The only differences in the served HTML are the version label, an asset cache key, and the footer build time (see the diff below). No `re` text changed.
- **Historical receipt:** preserved. Round 25's "S027 at 3.15.0, not-fired" was true when it was observed (feed top was 3.16.0a1, and /3/ served 3.15.0 at 07:27 UTC). It must not be rewritten. The new state needs a new, superseding row.

## Source teaching (located quote, ≤25 words)

URL: https://docs.python.org/3/library/re.html, which returned HTTP 200 with no redirect. `https://docs.python.org/3.15/library/re.html` serves byte-identical content.
Anchor: the `\s` entry in the special-sequences list.
> "For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() )."

The surrounding normalized text is unchanged on 3.15.1: "This includes [ \t\n\r\f\v] , and also many other characters, for example the non-breaking spaces mandated by typography rules … Matches [ \t\n\r\f\v] if the ASCII flag is used." This still supports the row's three clauses: Unicode whitespace, no-break spaces, and ASCII only when the ASCII flag is set.

## HTTP and digest metadata

| object | HTTP | Last-Modified / ETag | decoded sha256 | bytes |
|---|---|---|---|---|
| /3/library/re.html | 200 | Wed, 21 Oct 2026 13:04:29 GMT / `"6ad8b85d-3d7a3"`; age 1417; content-length 36006 (gzip) | `0724d8159158bdc1c92a212a2345ab1dc599343b8a35b0fa5682384af30c8aa5` | 251811 |
| /3.15/library/re.html | 200 | same body | `0724d815…` (identical) | 251811 |
| downloads/feed.rss | 200 | Wed, 21 Oct 2026 13:08:09 GMT; lastBuildDate 13:08:09 +0000 | `11c86a3481551067676403f66bc23b3d7dd1f5de14f32bbacafed239d13ca66b` | 3357 |
| /3/ index | 200 | `<title>3.15.1 Documentation</title>`; "Python 3.15 (stable)", "Python 3.16 (in development)" | `b5f922eb0a58bd6d7d10d6d5143f51c04f1386175999ba538b185aea8399e2d6` | — |
| /3/whatsnew/changelog.html | 200 | 13:04:29 GMT / `"6ad8b85d-708112"` | `133d59ad7d99ecabf7f918502fcb697066c6f9ecd64d82458330776e9e88f815` | 7373074 |

Commands:
- `curl -fsSL --compressed -D <n>.headers -o <n>.body -w '… http=%{http_code} final=%{url_effective} size=%{size_download}' <URL>`
- `python3 corpus/rendered-text-v1.py digest <artifacts>/re3.body` printed `raw_sha256=0724d815… bytes=251811 normalized_sha256=bbeb9d7c317cab01806f4238c293fecc424af4c95e91ad9a288f2d0d93d6f544 normalized_bytes=69062`. The same result was produced for `re315.body`.
- `python3 corpus/rendered-text-v1.py locate <artifacts>/re3.body 'For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() ).'` printed `count=1` and exited 0. The same result was produced for `re315.body`.

## 3.15.1 compared with 3.15.0

- **Full-body diff.** The round-25 ClockS027 3.15.0 capture (`/fast/scratch/kagi-r25/ClockS027-2/re.html`, sha256 `453e9e17…`, 07:27 UTC build) was diffed against today's body. Exactly six lines differ:
  - line 20: the `<title>` changes `3.15.0` to `3.15.1`;
  - line 27: `documentation_options.js?v=0fe728b1` changes to `?v=6b28f8f5`, inside a script tag that the normalizer strips;
  - line 34: the search label changes `3.15.0` to `3.15.1`;
  - lines 201 and 2314: both breadcrumbs change `3.15.0 Documentation` to `3.15.1 Documentation`;
  - line 2360: the footer changes `(07:27 UTC)` to `(13:02 UTC)`.

  No content line differs.
- **Pin reconstruction.** Today's body was taken, with `3.15.1` reverted to `3.15.0` (four occurrences) and `v=6b28f8f5` reverted to `v=0fe728b1`:
  - With footer `07:27`, it reproduces raw `453e9e17…` and normalized `bcee6611…`, which are round 25's values.
  - With footer `05:52`, it reproduces raw `d85d77e3…` and normalized `37cd15c2…`, which are the registered pins at `source-fetches.tsv:70`.

  Both matches are exact. The earlier test with the footer only (1440 candidate times, cache key unreverted) gave no hits, which is how the cache-key change was found.
- **Normalized-text diff (rendered-text-v1).** The only edits are the three `3.15.0`→`3.15.1` tokens and the footer time.
- **Bound on this evidence.** It shows the served `re.html` HTML is identical apart from chrome. It is not proof of the `re` implementation's behaviour, and it says nothing about other documentation pages.

## Implementation-side check (3.15.1 changelog, `#python-3-15-1-final`, 243 list items scanned)

- `gh-156444` is the only `re` behaviour change: "Fix matching of a negated character set in a bytes pattern compiled with both re.IGNORECASE and re.LOCALE". The normalizer's `WS_RE = re.compile(r"\s+")` is a str pattern with no flags, so this fix is out of scope for it. Dismissed counterexample candidate.
- `gh-156658`: "xml.dom and xml.etree.ElementTree no longer treat characters which are not white space in XML (such as U+00A0) as white space". This is a near-miss: it changes XML whitespace, not `re` `\s` or `str.isspace()`. rendered-text-v1 does not use the XML modules. Dismissed. It should not be read as U+00A0 dropping out of `\s`.
- There are no entries for `str.isspace`, a Unicode database version bump, or `unicodedata` in the 3.15.1 section. The only Unicode-normalization entry is `gh-159739`, a memory-leak fix.
- The host interpreter is still Python 3.14.8. No installed-Python upgrade is claimed or needed.

## Actionable counterexamples (calibration)

1. **The newest feed item is not the newest stable release on the clock's branch.** The feed's first item is now "Python 3.14.9" (13:08:09 +0000), above 3.15.1. S036's teaching cell ("newest stable X.Y.Z item") would select 3.14.9 under an entry-order reading.
   - I read `corpus/release-clock.py:649,685-699`: `STABLE_TITLE_RE` accepts "Python 3.14.9", "Python 3.15.1" and so on, rejects "Python 3.16.0a1" and "Python install manager 26.4", and returns the max X.Y.Z, which is 3.15.1. [INFERENCE: from reading the code; `release-clock.py` was not run by this seat.]
   - The S036 wording should say "maximum version", not "newest item". S036's own claim "Newest stable CPython is 3.15.0" is now stale too (that is a separate seat).
2. **A stale binding can still look fresh.** `release-clocks.tsv:24` carries `observed_at 2026-10-21`, and the 3.15.1 release happened the same day, at 09:59:50Z. A same-day date therefore does not establish freshness. A new receipt needs a UTC timestamp, not just a date.
3. **Changing digests are not drift evidence.** S027's raw and normalized digests changed again because of rebuilds (round-25 lesson lines 132–134). Today's change also includes a cache key, which a footer-only substitution model misses.

## Advice to L1 (append-only; do not edit historical rows)

- **New superseding clock row:** `S027 feed S036 https://www.python.org/downloads/feed.rss 3.15.0 3.15.1 <UTC receipt time> fired`, with the note "3.15.1 docs: `\s` quote locates; `re.html` differs from 3.15.0 only in chrome". Optionally re-anchor S027 to 3.15.1 through a new superseding SOURCES row rather than editing row 33.
- **Optional new capture row (S027, 13:02 UTC build):**
  - raw `0724d8159158bdc1c92a212a2345ab1dc599343b8a35b0fa5682384af30c8aa5`, 251811 bytes;
  - normalized `bbeb9d7c317cab01806f4238c293fecc424af4c95e91ad9a288f2d0d93d6f544`, 69062 bytes;
  - quote count 1.

  This value is volatile and will change on the next docs rebuild.

## Scope inspected and not run

- **Inspected:** S027's SOURCES row (`corpus/SOURCES.md:33`), its clock row (`release-clocks.tsv:24`), its capture row (`source-fetches.tsv:70`), the `\s` entry, the full `re.html` diff against the 3.15.0 build, and the 3.15.1 changelog section.
- **Not inspected:** S028 (`html.unescape`), which belongs to the ClockS028 seat; other documentation pages; the CPython source tags.
- **Not run:** `release-clock.py`, `sources-census.sh`, `rendered-text-v1.py --selftest`, and any gate or verify step. These are for L1 after integration.
