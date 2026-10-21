# ClockS028 — C3 per-row release clock for SOURCES row S028

Rev: BASE 4587c61a348e4528717404a68912c373f3ef4d03 (frozen; no lane mutation — fetch/observe
only, so no sandbox clone was load-bearing). Observations: 2026-10-21. No tools installed.
Work dir: /fast/scratch/kagi-r25/ClockS028.

## Row under test

- corpus/SOURCES.md:34 (S028): html — HyperText Markup Language support —
  https://docs.python.org/3/library/html.html | docs | A | rendered-text-v1 entity step;
  anchor `html.unescape(s)` (#html.unescape), "Python 3.15.0 documentation"; recheck=on-release.
- corpus/source-fetches.tsv:71: decoded b45945567002f1ee33df533a08267a6f27832ad10374295039723b3f8c5d7f3b
  (20100 bytes), normalized 7a19837f557036e1bb232b98c4331994903b8a799f91e15454c13ed5e9716ed1.

## Fresh re-open (declared profile)

```
curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' \
  -o fresh-S028.html https://docs.python.org/3/library/html.html
# HTTP_STATUS:200, exit=0; sha256=cd1a74e603c8cfbb1836ef251a2ea8fca77c4a42175c0c4a776314135d35b59d (20100 bytes)
python3 corpus/rendered-text-v1.py --selftest          # PASS (cases=22), exit 0
python3 corpus/rendered-text-v1.py digest fresh-S028.html
# normalized_sha256=279f549c67a7f1d50ad7c08549d88096c5c4641a15fed37cb1ae35f962aea760 normalized_bytes=2395
python3 corpus/rendered-text-v1.py locate fresh-S028.html \
  'Convert all named and numeric character references (e.g. &gt; , &#62; , &#x3e; ) in the string s to the corresponding Unicode characters.'
# RENDERED_TEXT_V1_LOCATE: count=1, exit 0
```

Drift, honestly recorded: decoded cd1a74e6… ≠ recorded b4594556…; normalized 279f549c… ≠
recorded 7a19837f…; identical decoded byte count (20100). Cause consistent with an intraday
docs rebuild: fresh footer reads "Last updated on Oct 21, 2026 (07:27 UTC)" (grep, 1 hit) —
rebuilt after the round-24 capture earlier today. This is what `decoded-http-body-volatile-v1`
means: digest = point observation, never a drift signal; the content check is the quote,
which still locates (count=1). Raw context confirms the rendered literal: source
`<span class="pre">&amp;gt;</span>` renders as `&gt;`, exactly as the recorded quote has it.

## Release identity — route (a): versioned docs, official vendor feed

Page self-declares its version: `<title>… Python 3.15.0 documentation</title>`; `3.15.0` 4x;
switcher links `docs.python.org/3.15/`.

Feed opened (official vendor latest-release landing):
- https://www.python.org/downloads/ → HTTP 200, exit 0. Hero h1 "Download the latest source
  release" + button "Download Python 3.15.0" → /downloads/release/python-3150/.
- https://www.python.org/downloads/release/python-3150/ → HTTP 200, exit 0;
  title "Python Release Python 3.15.0 | Python.org"; line "Release date: Oct. 9, 2026".
- Anchored 3.15.0 == observed latest 3.15.0 → **verdict: not-fired**.

Also attempted https://api.github.com/repos/python/cpython/releases/latest → HTTP 403,
exit 22: "API rate limit exceeded for 179.218.13.209" (unauthenticated shared IP; credentials
forbidden by lane rules). ATTEMPTED-BLOCKED; the python.org feed carries the verdict alone.
UNRUN: none.

## Proposed release-clocks.tsv line

```
S028	feed	https://www.python.org/downloads/	3.15.0	3.15.0	2026-10-21	not-fired
```

## SOURCES-row-ready feed candidate

`| S0xx | python.org downloads — Python release feed — https://www.python.org/downloads/ | release-feed | A | CPython latest-release identity governing docs.python.org/3/ rows (S027–S029 anchors) | hero h1 "Download the latest source release"; button "Download Python 3.15.0" → /downloads/release/python-3150/ ("Release date: Oct. 9, 2026"); opened 2026-10-21 | The /3/ docs URL serves the current stable docs; when this feed moves past the anchored version, the row's rendered-quote clock must be re-verified. Quote: "Download the latest source release" (hero h1, verbatim). | proposed | 2026-10-21 | on-release | corpus/release-clocks.tsv |`

(Quote: 6 words, verbatim, location hero h1; both feed pages opened this round, declared
curl profile.)

## Verdict on S028's teaches

HOLDS. (1) Feed not fired: anchored 3.15.0 == vendor latest 3.15.0 (released 2026-10-09).
(2) Belt-and-braces: the row's quote still locates in the fresh 3.15.0 body (count=1, exit 0) —
the entity-step teaching (named+numeric refs, HTML5 rules, after tag removal) is unchanged on
the served release. (3) The row's anchor "page last updated 2026-10-21" stays true of the fresh
body (footer 07:27 UTC today). The intraday normalized-digest drift (7a19837f… → 279f549c…)
is recorded as volatile-representation behavior, not semantic drift, per the S020 precedent
already in SOURCES.md.

## Files (sandbox only)

/fast/scratch/kagi-r25/ClockS028/: fresh-S028.html, py-downloads.html, py-3150.html,
gh-headers.txt, cpython-latest.json (403 body).
