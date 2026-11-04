#!/usr/bin/env python3
r"""rendered-text-v1 normalizer — kagi round 33 NIST capture rows.

Reproduces the `normalization` column of .ufo/waves/round-33/build/nist-captures.tsv.

Algorithm (v1), applied to the raw body bytes as saved by curl:

  1. If the body starts with the PDF magic `%PDF`, the text is
     `pdftotext -layout -enc UTF-8 <body> -` taken from stdout, UTF-8 decoded.
     Otherwise the body is decoded as UTF-8 with errors="replace".
  2. HTML path only: every `<script ...>...</script>` and `<style ...>...</style>`
     block is removed together with its contents; every remaining `<...>` tag is
     replaced by one U+0020; HTML character references are resolved with
     html.unescape.
  3. Every run of Unicode whitespace (`\s+`) is collapsed to a single U+0020 and
     the ends are stripped.
  4. The result is encoded UTF-8; `normalized_sha256` is the sha256 of those bytes.

The normaliser is content-addressed by the label `rendered-text-v1`; any change to
this file is a new label. Raw bodies are kept under build/src-open/<ID>.<ext>.
"""
import hashlib
import html
import re
import subprocess
import sys


def normalize(path: str) -> str:
    with open(path, "rb") as fh:
        raw = fh.read()
    if raw[:4] == b"%PDF":
        out = subprocess.run(
            ["pdftotext", "-layout", "-enc", "UTF-8", path, "-"],
            check=True, capture_output=True,
        )
        text = out.stdout.decode("utf-8", errors="replace")
    else:
        text = raw.decode("utf-8", errors="replace")
        text = re.sub(r"<script\b[^>]*>.*?</script\s*>", " ", text,
                      flags=re.IGNORECASE | re.DOTALL)
        text = re.sub(r"<style\b[^>]*>.*?</style\s*>", " ", text,
                      flags=re.IGNORECASE | re.DOTALL)
        text = re.sub(r"<[^>]*>", " ", text)
        text = html.unescape(text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--text":
        print(normalize(sys.argv[2]))
        raise SystemExit(0)
    for path in sys.argv[1:]:
        text = normalize(path)
        print(path, len(text), hashlib.sha256(text.encode("utf-8")).hexdigest())
