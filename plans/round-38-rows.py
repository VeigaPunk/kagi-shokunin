#!/usr/bin/env python3
"""round-38-rows.py -- the sole generator of the round-38 candidate rows S092 and S093.

Reads the committed capture bodies under .ufo/waves/round-38/capture/ and prints:
  python3 plans/round-38-rows.py fetch     16-column corpus/source-fetches.tsv rows
  python3 plans/round-38-rows.py registry  11-column corpus/SOURCES.md rows
  python3 plans/round-38-rows.py manifest  corpus/quote-bodies.tsv rows (no header)
The controls runner and the candidate commit both use this output, so the fixtures and the
landed rows cannot diverge.
"""
import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CAPTURE = ".ufo/waves/round-38/capture/"
ROWS = [
    {
        "id": "S092",
        "url": "https://github.com/hashicorp/vault/releases/tag/v2.2.1",
        "body": CAPTURE + "S092-vault-tag.body",
        "quote": "<title>Release v2.2.1 \u00b7 hashicorp/vault \u00b7 GitHub</title>",
        "locator": "tag-page-title-byte-offset-21886",
        "registry": (
            "| S092 | Vault release tag page v2.2.1, GitHub -- https://github.com/hashicorp/vault/releases/tag/v2.2.1 "
            "| docs | A | Vault release identity for the tag v2.2.1 (corroborates the feed entry of S089) "
            "| Page title \"Release v2.2.1 \u00b7 hashicorp/vault \u00b7 GitHub\"; release datetime 2026-10-22T21:59:36Z in the page body; opened 2026-11-05 "
            "| corroborates S089 -- the release tag page names the same version and date as the feed entry, so the feed identity is not a single-surface claim. Quote: \u201c<title>Release v2.2.1 \u00b7 hashicorp/vault \u00b7 GitHub</title>\u201d (page title, byte offset 21886). "
            "| mined | 2026-11-05 | 90d | corpus/lessons/round-38.md |"
        ),
    },
    {
        "id": "S093",
        "url": "https://github.com/openbao/openbao/releases/tag/v2.7.2",
        "body": CAPTURE + "S093-openbao-tag.body",
        "quote": "<title>Release v2.7.2 \u00b7 openbao/openbao \u00b7 GitHub</title>",
        "locator": "tag-page-title-byte-offset-21886",
        "registry": (
            "| S093 | OpenBao release tag page v2.7.2, GitHub -- https://github.com/openbao/openbao/releases/tag/v2.7.2 "
            "| docs | A | OpenBao server release identity for the tag v2.7.2 (corroborates the feed entry of S090) "
            "| Page title \"Release v2.7.2 \u00b7 openbao/openbao \u00b7 GitHub\"; release datetime 2026-10-26T20:24:37Z in the page body; opened 2026-11-05 "
            "| corroborates S090 -- the release tag page names the same version and date as the feed entry. Quote: \u201c<title>Release v2.7.2 \u00b7 openbao/openbao \u00b7 GitHub</title>\u201d (page title, byte offset 21886). "
            "| mined | 2026-11-05 | 90d | corpus/lessons/round-38.md |"
        ),
    },
]


def body_facts(row):
    data = (ROOT / row["body"]).read_bytes()
    offset = data.find(row["quote"].encode("utf-8"))
    if offset < 0:
        raise SystemExit("quote absent from %s" % row["body"])
    return data, offset


def fetch_row(row):
    data, _ = body_facts(row)
    digest = hashlib.sha256(data).hexdigest()
    row_identity = hashlib.sha256(("%s\tmined\t%s\n" % (row["id"], row["url"])).encode("utf-8")).hexdigest()
    cols = [
        row["id"], "mined", row_identity, row["url"], row["url"], "200",
        "curl-fsSL-compressed-v1", "2026-11-05", "decoded-http-body-volatile-v1",
        digest, str(len(data)), "-", row["quote"], "raw-literal-v1", "-", row["locator"],
    ]
    return "\t".join(cols)


def manifest_row(row):
    _, offset = body_facts(row)
    return "\t".join([row["id"], row["body"], str(offset), row["quote"]])


def main(argv):
    if argv == ["fetch"]:
        print("\n".join(fetch_row(r) for r in ROWS))
    elif argv == ["registry"]:
        print("\n".join(r["registry"] for r in ROWS))
    elif argv == ["manifest"]:
        print("\n".join(manifest_row(r) for r in ROWS))
    else:
        print("usage: round-38-rows.py fetch|registry|manifest", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
