# HTML comment `>` source finding

## Observed

- Opened `https://html.spec.whatwg.org/multipage/syntax.html#comments` with the native static-web reader (browser-equivalent) on 2026-10-21. The located section is **13.1.6 Comments**, section anchor `#syntax-comments`: `https://html.spec.whatwg.org/multipage/syntax.html#syntax-comments`.
- Exact quote (19 words): “The text is allowed to end with the string "`<!`", as in `<!--My favorite operators are > and   <!-->`.” The section's comment-data restrictions do not prohibit `>`; the quoted valid-comment example includes one. **Yes: HTML comment text may legally contain `>`.**
- No page revision/date was displayed in the page text returned by the reader; a targeted search of that page text for update, modification, revision, copyright, year, or date markers returned no matches. 2026-10-21 is the observed access date, not a claimed source revision.
- Current `corpus/rendered-text-v1.py:23-27` declares no separate comment rule and says `>` in a comment ends its tag match. `:62, :68-70` show `TAG_RE = re.compile(r"<[^>]+>")` and its substitution. `:126-127` records `comment-plain` and `comment-gt`, with the latter expecting `a y -->b` for `a<!-- x > y -->b`.

## SOURCES recommendation

- **ADMIT** for the narrow HTML-syntax premise used by `rendered-text-v1`: the WHATWG HTML Standard is a primary normative specification and its comment section explicitly exemplifies `>` in comment data.
- Recommended registry fields: `kind=spec`; `tier=A` **for this scope**; `scope=HTML comment syntax: comment data may contain U+003E GREATER-THAN SIGN`; `anchor=§13.1.6 Comments (#syntax-comments)`; `opened=2026-10-21`; page revision/date not displayed. This follows `corpus/SOURCES.md:1,5` (registry/schema), the `spec` kind and A/B/C tier enums in `corpus/sources-census.sh:191`, its statement that tier C is lead-only at `:52-53`, and QA1's tier-A-for-scope rule in `corpus/QUALITY.md:20`.
- **Limit:** the specification grounds HTML legality, not Python regex mechanics. The code, not this source, grounds v1's `[^>]` stop-at-first-`>` rule. For the current input, that regex behavior implies a match for `<!-- x >` and leftover `y -->`; this inference agrees with the declared fixture at `rendered-text-v1.py:127`. Do not cite this source alone as proof of an HTML parser's behavior or of the Python normalizer's output.
- **Flip condition:** withdraw/reject this support if a re-opened normative comment grammar disallows `>` in comment data or the example no longer supports that reading. If the claim is expanded from syntax legality to parser behavior or v1 output, require implementation-specific evidence in addition; this source alone does not establish that expanded claim.

## Bounds and checks

- LSP was unavailable: `read xd://lsp` returned “No such tool” and the mounted-tool inventory contained no LSP device. I read the relevant source lines directly; no LSP definition/reference result is claimed.
- No shell command, normalizer selftest, build, or other check was run; therefore no command exit code or test pass is claimed. The cited selftest expected value is source text, not an executed result. No tools were installed or updated.
