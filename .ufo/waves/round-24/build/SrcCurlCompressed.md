# curl `--compressed` source assessment

## Observed

- Opened `https://curl.se/docs/manpage.html` with the declared request profile. Exact fetch:
  `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://curl.se/docs/manpage.html`
  (body returned to stdout). An explicit status run with the same profile plus
  `-o /dev/null -w 'http=%{http_code}\n'` returned `http=200`, `curl_exit=0`.
- Verbatim quote (17 words): “(HTTP) Request a compressed response using one of the algorithms curl supports, and automatically decompress the content.”
- Location: **Options → All options → `--compressed`**, anchor
  [`#--compressed`](https://curl.se/docs/manpage.html#--compressed). The adjacent note says
  saved response headers are not modified although the content has already been decompressed.
- Revision: the page's **Version** section says it describes curl **8.23.1**; no publication
  or page-revision date is displayed. The page identifies the online man page as its latest
  incarnation. Opened: 2026-10-21.
- Code check: `corpus/rendered-text-v1.py:10-13` declares its input as decoded HTTP body bytes
  and strict UTF-8 decoding; `:69-70` implements only that UTF-8 decode followed by text
  normalization and UTF-8 encoding. It does not fetch HTTP or decompress content.
  `corpus/source-fetches.tsv:12-16` declares the matching curl `--compressed` profile and
  `decoded-http-body-v1` representation; `:27-30` separates the rendered-text normalization.
- The SOURCES contract permits `docs` and defines tier A as primary/authoritative for the
  scoped claim; scope is claim-specific and the anchor must include a version/date
  (`/home/vgpnk/Projects/shokunin/CORPUS.md:91-100`).

## Recommendation

**ADMIT**, narrowly, as grounding for the input-representation premise behind
`decoded-http-body-v1`: curl documents that `--compressed` requests an HTTP compressed
response and automatically decompresses its content before delivery. This does not mean
curl UTF-8-decodes the body; that distinct operation is explicit in
`rendered-text-v1.py:10-13,69-70`. Nor does the curl page ground the normalizer's HTML,
entity, whitespace, or trimming rules; the code declares those separately at `:14-37,61-66`.

- **Kind:** `docs`.
- **Tier:** `A`, only for curl's documented HTTP `--compressed` content-decompression behavior.
- **Scope:** HTTP response content decompression into curl-delivered body bytes when
  `--compressed` is enabled and the encoding is supported (not response-header rewriting,
  UTF-8 decoding, or the rest of rendered-text-v1).
- **Anchor/revision:** `curl man page`, **Options → All options → `--compressed`**,
  `#--compressed`; version 8.23.1, opened 2026-10-21. No page date is displayed.
- **Flip condition:** reject it as support for this input premise if the capture profile no
  longer uses curl `--compressed`, the input is wire-encoded bytes, or a different client
  is used without equivalent authoritative evidence. The manual also says unsupported
  encodings produce an error, so this source does not establish successful decoding for
  every possible HTTP encoding or certify any individual capture.

## Evidence limits

No `lsp` device/server is mounted (`read xd://lsp` returned “No such tool”); literal search
was used only to locate call/profile references, and the cited code and contract sections
were read directly. No tools were installed or updated; no tests or host-private gates ran.