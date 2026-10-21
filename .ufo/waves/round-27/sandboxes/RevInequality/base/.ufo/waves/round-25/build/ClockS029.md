# ClockS029 — S029 release clock (round-25 C3)

Seat KagiR25.ClockS029-2 · observed 2026-10-21 · lane HEAD 4587c61a348e4528717404a68912c373f3ef4d03 = BASE (`git rev-parse HEAD`, read-only) · lane files read-only, none edited · scratch /fast/scratch/kagi-r25/ClockS029/{fetch,tarball} · installs: none (curl, python3, tar, sha256sum, git used as found).

## 1. Decision and verdict
- Identity: (a) versioned product docs with an official release feed. Feed: https://curl.se/info (curl project site, tier A). The man page names it: "You can always learn which the latest curl version is by running curl https://curl.se/info" (s029.html:573-574).
- Feed content: Version 8.23.0, Date 2026-10-14, Next release 2026-12-09 (info2.txt:1-9).
- Row anchor version: 8.23.1 ("This man page describes curl 8.23.1.", s029.html:572). The feed has not moved past 8.23.1, so the literal verdict is **not-fired**.
- Anchor defect: 8.23.1 is the master development label, not a release. master `include/curl/curlver.h:35` = `"8.23.1-DEV"`, `:71` = `"[unreleased]"`. Release 8.23.0 tarball: `curlver.h:35` = `"8.23.0"`, `:71` = `"2026-10-14"`; its generated man text says "This man page describes curl 8.23.0" (src/tool_hugehelp.c:190, template docs/cmdline-opts/_VERSION.md:5). No 8.23.1 release appears in any official source (§4). [INFERENCE: the curl.se manpage is built from master; its origin Last-Modified (2026-10-19) postdates the 8.23.0 release.]
- Teaches: still holds (§5). Clock (b) rendered-quote is not governing; run as a supplement, the quote locates (count=1) on the fresh page.

## 2. Proposed release-clocks.tsv line (tab-separated; extraction `^Version: (\S+)$` and `^Date: (\S+)$`)
```
S029	feed	https://curl.se/info	8.23.0	8.23.0	2026-10-21	not-fired
```
- Recommended anchor 8.23.0, the release whose docs contain the claim sentence (§5). Anchored at 8.23.1, an official 8.23.1 release would equal the anchor and never fire under "moved past"; anchored at 8.23.0, any newer official release fires. This departs from the planner's "row's anchor version" rule: planner decision.
- Rule-literal alternative: `S029	feed	https://curl.se/info	8.23.1	8.23.0	2026-10-21	not-fired` (flag anchor-ahead-of-feed).
- Feed SOURCES row: S033 (provisional; L1 renumbers if another clock seat claims it). Next expected firing: 2026-12-09 (feed-declared schedule, not a guarantee).

## 3. Feed SOURCES candidate (S033, row-ready)
```
| S033 | curl version feed — https://curl.se/info | docs | A | Latest official curl release version and publish date; the feed the S029 man page names for its latest version; binds clock S029 | Plain-text body, Version and Date fields (lines 1–2); body volatile (Packages and Up-to-date counters), opened 2026-10-21 | Latest official curl release is 8.23.0, published 2026-10-14; next release listed as 2026-12-09. Quote: “Version: 8.23.0 Date: 2026-10-14” (body lines 1–2). | mined | 2026-10-21 | on-release | corpus/lessons/round-25.md |
```
Fetch row (16 columns; row identity = sha256 of `S033\tmined\thttps://curl.se/info\n`, verified `8620b94e…a835e43`):
```
S033	mined	8620b94ebab96accb7027ae38596dcf73034b139855fd783bc3e2f044a835e43	https://curl.se/info	https://curl.se/info	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	cfa106be99126075e28cd6dbc675aa1cebf7f81b02e0a39e31efd946e765e1e8	352	-	Version: 8.23.0 Date: 2026-10-14	rendered-text-v1	90b57e66f985cc70ed8d4f6f9e706df5378b0c2e08a8cef3454b88a5d6eb9fd6	Version and Date fields, body lines 1-2
```
- Quote check: `rendered-text-v1.py locate info2.txt "Version: 8.23.0 Date: 2026-10-14"` → count=1.
- used-by must match `corpus/(knowledge|lessons)/<name>.md` (sources-census.sh:215); `corpus/release-clocks.tsv` is not legal there.

## 4. Fetch and release-identity evidence (UA kagi-shokunin-round25/1.0 (documentation verification); `-fsSL --compressed` unless noted)
- S029 https://curl.se/docs/manpage.html: HTTP 200, no redirect, edge age 57. Decoded body 465399 B, sha256 9d2b36d00af7240f77480e911ce28346113419dd3eb5ebca1d8cc50284cfe5ca = registry col 10 (identical). Normalized (rendered-text-v1) sha256 fb3a4889…18c27 = col 15 (identical, 264660 B). Wire (no --compressed, Accept-Encoding set): content-encoding br, 80924 B, sha256 0550842e…8be56 (not a registry column). Origin Last-Modified Mon, 19 Oct 2026 06:25:03 GMT (s029.headers:4).
- Registry col 3 `be4509c1…6948a9` is the row-identity hash, not a body digest: `printf 'S029\tmined\thttps://curl.se/docs/manpage.html\n' | sha256sum` → identical.
- https://curl.se/info: HTTP 200, 352 B, identity encoding, sha256 cfa106be99126075e28cd6dbc675aa1cebf7f81b02e0a39e31efd946e765e1e8; Last-Modified Wed, 21 Oct 2026 10:10:59 GMT (info2.headers:3), so the body is volatile.
- https://curl.se/download/curl-8.23.0.tar.gz: HTTP 200, 4465093 B, sha256 e3de77cfa6367083c776a26647fc9f633b538c06c3baa73d931a252ac8f72b49 = the `sha256:` field of curl.se/info (match).
- Corroboration: curl.se/download.html "Version: curl 8.23.0" / "Release date: 2026-10-14" (locate count=1); curl.se/changes.html top heading "Fixed in 8.23.0 - October 14 2026" (changes.html:177), no 8.23.1 heading; api.github.com/repos/curl/curl/releases/latest → tag curl-8_23_0, name 8.23.0, published_at 2026-10-14T06:05:46Z, draft false, prerelease false; releases?per_page=3 → 8.23.0, 8.22.0 (2026-09-02), 8.21.0 (2026-06-24).
- Negative/UNRUN: curl.se/ch/8.23.1.html → 404; curl.se/changelog/ (the brief's example) → 404; curl.se/rss.xml → 404; api.github.com/…/tags?per_page=5 → 403 (x-ratelimit-remaining 0 of 60; reset epoch 1792581901 ≈ 11:25 UTC), UNRUN; configure.ac:29 `AC_INIT([curl], [-], …)` stores no version: inconclusive.

## 5. Teaches verdict: STILL HOLDS
- Row quote "(HTTP) Request a compressed response using one of the algorithms curl supports, and automatically decompress the content." → count=1 in the fresh body (s029.html:706) and count=1 in the official 8.23.0 docs (docs/cmdline-opts/compressed.md:18-19, wrapped lines).
- Digest domain: decoded 465399 B against 80924 B on the wire (br). The digests are over decoded bytes, as taught. All three recorded digests (cols 3, 10, 15) reproduce today.
- Calibration gaps, not teaches-breaking: (i) the anchor "curl 8.23.1 man page" needs a release qualifier (official 8.23.0; 8.23.1 is the master label); (ii) the row omits "This is a request, not an order; the server may or may not deliver data compressed." (s029.html:708; compressed.md:26-27). Optional superseding row (planner): restate the anchor and add the qualifier.

## 6. Operability notes for L1
- The GitHub anonymous API quota is exhausted by this wave (403, remaining 0): a GitHub-backed clock fails `--observe`. curl.se/info returned 200 on every call; use GitHub as corroboration only.
- curl.se/changelog/ is not a feed (404); the changelog is curl.se/changes.html.
- Tarball members are gz bytes, so rendered-text-v1 cannot locate in them: release-doc checks are report evidence, not citable rows.
- SC_FETCH needs a fetch row for each mined row; the S033 proposal includes one.

## 7. Command log (exit codes)
- `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o …/s029.html https://curl.se/docs/manpage.html` → 0.
- `curl … https://curl.se/changelog/` → 22 (404); `curl … https://curl.se/rss.xml` → 22 (404); `curl … api.github.com/…/tags?per_page=5` → 22 (403).
- `python3 corpus/rendered-text-v1.py digest s029.html` → 0 (raw 9d2b…, normalized fb3a…); `locate s029.html "(HTTP) Request a compressed response … the content."` → 0, count=1.
- `locate info2.txt "Version: 8.23.0 Date: 2026-10-14"` → 0, count=1. First attempt raced the fetch (`SETUP unreadable: FileNotFoundError`, exit 2); re-run after the fetch completed.
- `tar -xzf curl-8.23.0.tar.gz` → 0; grep over docs/ and include/curl/curlver.h as cited above.

## 8. Limits
- UNRUN: GitHub tags endpoint (403). No gate `verify`/`cells`, no lane edits, no installs, no subagents.
- The S033 row, fetch row and release-clocks.tsv line are proposals; the planner owns SOURCES.md, source-fetches.tsv and release-clocks.tsv.
