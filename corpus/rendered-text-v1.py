#!/usr/bin/env python3
"""rendered-text-v1 -- the one committed declaration of the quote/page normalizer.

Round 24 (routed D6): round 23 declared this normalization three different ways
(source-fetches.tsv said Python \\s, sources-census.sh and the lesson said only
"collapse whitespace", and the comment rule was undeclared).  This file is now
the single declaration; corpus/source-fetches.tsv, corpus/sources-census.sh and
the round lessons cite it instead of restating it.

Definition (applied in exactly this order to the decoded HTTP body bytes):

  1. decode      strict UTF-8; undecodable bytes are a setup error (exit 2),
                 never replaced or ignored.
  2. script/style
                 remove every match of (?is)<(script|style)\\b[^>]*>.*?</\\1\\s*>
                 -- case-insensitive, spanning lines, the opening tag must
                 close with '>' before the body, shortest body, the closing
                 tag must name the same element -- replacing it with one SPACE.
                 This is the round-23 generator's exact opener pattern
                 (.ufo/waves/round-23/falsify/CritNormalizer.md:76); round-24
                 wave-1 CritC2Metric showed a looser opener disagrees on a
                 malformed opener (selftest case script-malformed-opener).
  3. tags        replace every match of <[^>]+> with one SPACE.  There is NO
                 separate comment rule: an HTML comment is removed only because
                 it matches this tag pattern, so a '>' inside a comment ends the
                 match and the rest of the comment survives as text (selftest
                 case comment-gt).
  4. entities    html.unescape (Python stdlib, HTML5 named and numeric
                 references) AFTER tag removal, so an escaped '&lt;b&gt;' becomes
                 literal '<b>' text and is NOT removed (selftest case
                 escaped-tag-survives).
  5. whitespace  collapse every run of Unicode whitespace -- Python re '\\s' on a
                 str pattern, i.e. the characters str.isspace() accepts, which
                 includes U+00A0 NO-BREAK SPACE and U+3000 -- to one U+0020.
                 ASCII-only whitespace is NOT v1: it fails to reproduce 3 of the
                 10 round-23 normalized digests (S022, S023, S024; round-24
                 lesson Gate, rejected source row for the WHATWG ASCII class).
  6. trim        strip leading/trailing whitespace (the same Unicode class).
  7. encode      UTF-8; the normalized digest is sha256 of these bytes.

Sources (opened round 24, see corpus/SOURCES.md): Python `re` \\s for str
patterns and Python `html.unescape`.

Usage:
  python3 corpus/rendered-text-v1.py digest FILE
      RENDERED_TEXT_V1: raw_sha256=<64hex> bytes=<n> normalized_sha256=<64hex> normalized_bytes=<n>
  python3 corpus/rendered-text-v1.py locate FILE QUOTE
      RENDERED_TEXT_V1_LOCATE: count=<n>   (exit 0 if n>=1, 1 if n==0)
      QUOTE is normalized by steps 5-6 only (it is text, not markup).
  python3 corpus/rendered-text-v1.py --selftest
      RENDERED_TEXT_V1_SELFTEST: PASS (cases=<n>)

Exit: 0 ok, 1 not-found / selftest failure, 2 setup (usage, unreadable,
undecodable).  Reads only the named file; no network, no writes.
"""
import hashlib
import html
import re
import sys

SCRIPT_STYLE_RE = re.compile(r"(?is)<(script|style)\b[^>]*>.*?</\1\s*>")
TAG_RE = re.compile(r"<[^>]+>")
WS_RE = re.compile(r"\s+")


def normalize_text(text):
    s = SCRIPT_STYLE_RE.sub(" ", text)
    s = TAG_RE.sub(" ", s)
    s = html.unescape(s)
    s = WS_RE.sub(" ", s)
    return s.strip()


def normalize_bytes(data):
    return normalize_text(data.decode("utf-8", errors="strict")).encode("utf-8")


def collapse_quote(q):
    return WS_RE.sub(" ", q).strip()


def setup(msg):
    print("RENDERED_TEXT_V1: SETUP (%s)" % msg)
    sys.exit(2)


def read_file(path):
    try:
        with open(path, "rb") as fh:
            return fh.read()
    except OSError as exc:
        setup("unreadable: %s" % exc.__class__.__name__)


def cmd_digest(path):
    data = read_file(path)
    try:
        norm = normalize_bytes(data)
    except UnicodeDecodeError:
        setup("not strict UTF-8")
    print("RENDERED_TEXT_V1: raw_sha256=%s bytes=%d normalized_sha256=%s normalized_bytes=%d"
          % (hashlib.sha256(data).hexdigest(), len(data), hashlib.sha256(norm).hexdigest(), len(norm)))
    return 0


def cmd_locate(path, quote):
    data = read_file(path)
    try:
        text = normalize_bytes(data).decode("utf-8")
    except UnicodeDecodeError:
        setup("not strict UTF-8")
    q = collapse_quote(quote)
    if not q:
        setup("empty quote")
    n = text.count(q)
    print("RENDERED_TEXT_V1_LOCATE: count=%d" % n)
    return 0 if n >= 1 else 1


# (name, input bytes, expected normalized text) -- each case fixes one rule.
CASES = [
    ("tags-to-space", b"<p>a</p><p>b</p>", "a b"),
    ("script-removed", b"x<script>var y='<p>z</p>';</script>w", "x w"),
    ("style-removed-case-multiline", b"x<STYLE type=t>\np{}\n</style >w", "x w"),
    ("script-close-must-match", b"a<script>1</style>2</script>b", "a b"),
    ("comment-plain", b"a<!-- hidden -->b", "a b"),
    ("comment-gt", b"a<!-- x > y -->b", "a y -->b"),
    ("escaped-tag-survives", b"a &lt;b&gt; c", "a <b> c"),
    ("numeric-entity", b"&#62;&#x3e;&gt;", ">>>"),
    ("nbsp-entity-collapses", b"a&nbsp;&nbsp;b", "a b"),
    ("nbsp-raw-collapses", "a\u00a0b".encode("utf-8"), "a b"),
    ("ideographic-space-collapses", "a\u3000b".encode("utf-8"), "a b"),
    ("ascii-runs-collapse", b"a \t\r\n\x0b\x0c b", "a b"),
    ("trim-both-ends", b"  <i> a </i>  ", "a"),
    ("zero-width-space-kept", "a\u200bb".encode("utf-8"), "a\u200bb"),
    # round-24 wave-1 mutation lane (MutNormalizer): three survivors killed
    ("empty-angle-kept", b"a<>b", "a<>b"),
    ("script-shortest-match", b"a<script>1</script>M<script>2</script>b", "a M b"),
    ("script-word-boundary", b"a<scripture>keep</script>b", "a keep b"),
    # round-24 wave-1 CritC2Metric: the round-23 opener needs '>' before the body
    ("script-malformed-opener", b"L<script broken</script>secret</script>R", "L R"),
]


def cmd_selftest():
    failed = 0
    for name, data, want in CASES:
        got = normalize_bytes(data).decode("utf-8")
        if got == want:
            print("case %s: ok" % name)
        else:
            failed += 1
            print("case %s: FAIL got=%r want=%r" % (name, got, want))
    n = len(CASES) + 2
    # strict decode: invalid UTF-8 must be refused, never replaced
    try:
        normalize_bytes(b"a\xffb")
        failed += 1
        print("case strict-utf8: FAIL (decoded)")
    except UnicodeDecodeError:
        print("case strict-utf8: ok")
    # the quote side collapses whitespace only; markup in a quote is text
    if collapse_quote(" a\u00a0 <b>\n") == "a <b>":
        print("case quote-collapse-only: ok")
    else:
        failed += 1
        print("case quote-collapse-only: FAIL")
    if failed:
        print("RENDERED_TEXT_V1_SELFTEST: FAIL (cases=%d failed=%d)" % (n, failed))
        return 1
    print("RENDERED_TEXT_V1_SELFTEST: PASS (cases=%d)" % n)
    return 0


def main(argv):
    if argv == ["--selftest"]:
        return cmd_selftest()
    if len(argv) == 2 and argv[0] == "digest":
        return cmd_digest(argv[1])
    if len(argv) == 3 and argv[0] == "locate":
        return cmd_locate(argv[1], argv[2])
    setup("usage: digest FILE | locate FILE QUOTE | --selftest")


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
