# Python `re` source candidate — rendered-text-v1

## Recommendation
**ADMIT** Python’s official `re` documentation as grounding for the normalizer’s Unicode `\s` whitespace choice. It directly defines `\s` for Unicode `str` patterns through `str.isspace()` and distinguishes the ASCII flag’s smaller class. This source is authoritative for that narrow Python behavior, not for unrelated normalization steps.
**Confidence:** High for the default `str`/Unicode behavior. The `re` page establishes the rule; the official `str.isspace` example and source fixtures corroborate the named code points. Remaining limitation: the `re` paragraph does not enumerate both code points itself (spelled out below).

## Opened source and citation
- URL: https://docs.python.org/3/library/re.html
- Location: **Regular expression syntax** → special sequences, `\s` entry; anchor `#regular-expression-syntax`. The flag overview is at `#re.ASCII`.
- Displayed revision: Python **3.15.0** documentation; footer says **Last updated on Oct 21, 2026 (05:52 UTC)**.
- ≤25-word verbatim quote (two excerpts; ellipsis marks omitted intervening text): “Matches Unicode whitespace characters (as defined by `str.isspace()`). … Matches `[ \t\n\r\f\v]` if the `ASCII` flag is used.” (16 words, excluding the omission mark.)
- Interpretation: **Yes** under Unicode `str` semantics, both U+00A0 NO-BREAK SPACE and U+3000 IDEOGRAPHIC SPACE are included. The `re` entry describes the Unicode class as `str.isspace()` and calls out non-breaking spaces; Python’s `str.isspace` documentation explicitly demonstrates `\u3000`. Under `re.ASCII`, neither code point is included: only `[ \t\n\r\f\v]` matches.
- Supplemental official definition: https://docs.python.org/3/library/stdtypes.html#str.isspace (Python 3.15.0 docs), example `‘\u3000’.isspace() # IDEOGRAPHIC SPACE`.

## Code check
Observed in `kagi-shokunin/corpus/rendered-text-v1.py`:
- Lines 27–33 declare Unicode whitespace as Python `re` `\s` on `str`, specifically name U+00A0 and U+3000, and reject ASCII-only whitespace for v1.
- Lines 56–58 compile `WS_RE = re.compile(r"\s+")` with no ASCII flag; lines 61–70 apply it after HTML unescaping to strictly UTF-8-decoded `str` text. Line 74 uses the same regex for quote whitespace.
- Lines 125–127 declare expected normalization cases for `&nbsp;`, raw U+00A0, and U+3000. These are source fixtures; this scout did not run the self-test.

The docs page itself does not spell out both code points in the `\s` paragraph: U+00A0 is covered by its non-breaking-space description and the source fixture, while the built-in-types docs explicitly show U+3000 passing `str.isspace()`. The codepoint conclusion therefore combines the documented `\s` → `str.isspace()` rule, the official `str.isspace` example, and the normalizer’s explicit fixtures.

## SOURCES contract recommendation
- **kind:** `docs`
- **tier:** `A`, scoped to the Python `re` `\s` behavior for Unicode `str` patterns versus `re.ASCII` (official docs are authoritative within scope).
- **scope:** Python’s `\s` whitespace membership for Unicode `str` regexes versus the ASCII flag, as it grounds `rendered-text-v1` whitespace collapse.

This follows `CORPUS.md:91–100` (kind, scoped tier, precise scope, exact anchor/revision) and `:112–115` (open source in-round and record a ≤25-word located quote). The quote above is within the limit; the source was opened 2026-10-21.

**Flip condition:** change to **REJECT** if the implementation switches to bytes or enables `re.ASCII`/`re.A`, or if the supported Python documentation changes the Unicode `\s`/`str.isspace()` relationship or excludes either code point. Recheck the pinned interpreter/documentation version when that support target changes.

## Access and limits
- `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' 'https://docs.python.org/3/library/re.html' -o /tmp/kagi-r24-python-re.html` → exit **0**, 251811 bytes.
- Same profile for `https://docs.python.org/3/library/stdtypes.html#str.isspace` to `/tmp/kagi-r24-python-isspace.html` → exit **0**, 814482 bytes.
- LSP is unavailable in this session (`read xd://lsp` returned “No such tool”); code locations above come from literal source search/read, not semantic LSP proof. No project test or self-test was run; no tools were installed.