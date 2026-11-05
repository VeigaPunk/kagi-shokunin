#!/usr/bin/env python3
"""quote-locate.py -- round 38 C1 instrument: located-quote gate over committed capture bodies.

Frozen predicate (the same sentence appears in plans/round-38.md and the counter):
  QUOTE_LOCATE located=N -- N is the number of rows of corpus/quote-bodies.tsv whose
  declared quote is found byte-for-byte in the committed capture body at its declared
  offset, where: the body sha256 and byte count equal the capture row's
  (corpus/source-fetches.tsv columns 10 and 11), the declared quote equals the capture
  row's quote (column 13), and the quote occurs verbatim in that id's registry row in
  corpus/SOURCES.md.

Manifest: corpus/quote-bodies.tsv, header `id<TAB>body_path<TAB>offset<TAB>quote`.
body_path is repo-relative; absolute paths and `..` components are refused.

Exit 0 `QUOTE_LOCATE: CLEAN located=N rows=N`; exit 1 `QUOTE_LOCATE: FAIL located=K rows=N`
with one `NOT-LOCATED <id> <reason>` line per failing row; exit 2 `QUOTE_LOCATE: SETUP <reason>`.

Named ceilings: this checks the committed bytes only; it does not re-fetch a live page and
does not judge whether the quote supports the row's teaching. Rows outside the manifest are
not checked by this gate.
"""
import hashlib
import os
import sys
from pathlib import Path

MANIFEST = "corpus/quote-bodies.tsv"
FETCHES = "corpus/source-fetches.tsv"
REGISTRY = "corpus/SOURCES.md"
MANIFEST_HEADER = ["id", "body_path", "offset", "quote"]


def setup(reason):
    print("QUOTE_LOCATE: SETUP %s" % reason)
    return 2


def load_fetches(root):
    fetch = {}
    with open(root / FETCHES, encoding="utf-8") as handle:
        for line in handle:
            if line.startswith("#") or not line.strip():
                continue
            cols = line.rstrip("\n").split("\t")
            if len(cols) == 16:
                fetch[cols[0]] = cols
    return fetch


def registry_line(registry_text, sid):
    prefix = "| %s |" % sid
    for line in registry_text.splitlines():
        if line.startswith(prefix):
            return line
    return None


def main(argv):
    root = Path(argv[argv.index("--root") + 1]).resolve() if "--root" in argv else Path(__file__).resolve().parent.parent
    manifest = root / MANIFEST
    if not manifest.is_file():
        return setup("no-manifest")
    try:
        fetch = load_fetches(root)
        registry_text = (root / REGISTRY).read_text(encoding="utf-8")
        with open(manifest, encoding="utf-8", newline="") as handle:
            header_line = handle.readline().rstrip("\n")
            if header_line.split("\t") != MANIFEST_HEADER:
                return setup("bad-manifest-header")
            rows = []
            for line in handle:
                if not line.strip() or line.startswith("#"):
                    continue
                cols = line.rstrip("\n").split("\t")
                if len(cols) != 4:
                    return setup("malformed-manifest-row")
                rows.append(cols)
    except (OSError, UnicodeDecodeError) as exc:
        return setup("unreadable %s" % exc.__class__.__name__)

    located = 0
    findings = []
    for sid, body_path, offset, quote in rows:
        reason = None
        capture = fetch.get(sid)
        if capture is None:
            reason = "no-capture-row"
        elif os.path.isabs(body_path) or ".." in Path(body_path).parts:
            reason = "unsafe-body-path"
        elif not (root / body_path).is_file():
            reason = "body-missing"
        elif not offset.isdigit():
            reason = "bad-offset"
        elif quote != capture[12]:
            reason = "quote-not-capture-quote"
        else:
            data = (root / body_path).read_bytes()
            needle = quote.encode("utf-8")
            line = registry_line(registry_text, sid)
            if hashlib.sha256(data).hexdigest() != capture[9]:
                reason = "body-sha256-mismatch"
            elif len(data) != int(capture[10]):
                reason = "body-bytes-mismatch"
            elif line is None or quote not in line:
                reason = "quote-not-in-registry-row"
            elif data[int(offset):int(offset) + len(needle)] != needle:
                reason = "quote-not-at-offset"
        if reason is None:
            located += 1
        else:
            findings.append("NOT-LOCATED %s %s" % (sid, reason))

    for finding in findings:
        print(finding)
    if findings:
        print("QUOTE_LOCATE: FAIL located=%d rows=%d" % (located, len(rows)))
        return 1
    print("QUOTE_LOCATE: CLEAN located=%d rows=%d" % (located, len(rows)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
