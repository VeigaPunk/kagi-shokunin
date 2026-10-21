#!/usr/bin/env python3
"""FDeriveTwo offline --observe probe for the round-28 C2 carrier.

Same isolated exported candidate tree; the only edit is the located anchor cell
of feed registry row S033. The network is replaced by a static body per feed
URL, so no packet leaves the host. Question: does the candidate write a fired
verdict for the unbound derived rows, and what does the clock report?
"""
import importlib.util
import io
import json
import re
import shutil
import sys
from contextlib import redirect_stdout
from pathlib import Path

SB = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/FDeriveTwo")
CAND = SB / "cand"
S033_ORIG = ("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, "
             "updated 2026-07-23T05:29:11Z; feed fetched 2026-10-21")
TWO_VERSIONS = ("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, "
                "updated 2026-07-23T05:29:11Z; previous stable release "
                "v3.12.9; feed fetched 2026-10-21")

FEED_BODIES = {
    "https://github.com/getsops/sops/releases.atom":
        b'<feed><entry><title>v3.13.3</title><link href="/releases/tag/v3.13.3"/></entry></feed>',
    "https://github.com/hashicorp/vault/releases.atom":
        b'<feed><entry><title>v2.2.0</title><link href="/releases/tag/v2.2.0"/></entry></feed>',
    "https://github.com/openbao/openbao/releases.atom":
        b'<feed><entry><title>v2.7.1</title><link href="/releases/tag/v2.7.1"/></entry></feed>',
    "https://www.python.org/downloads/feed.rss":
        b'<rss><channel><item><title>Python 3.15.1</title></item></channel></rss>',
    "https://curl.se/info": b"Version: 8.23.0\n",
}
DERIVED_ROWS = ["S008", "S009", "S010", "S011"]


def edit_anchor_cell(tree, old_cell, new_cell):
    path = tree / "corpus" / "SOURCES.md"
    text = path.read_text(encoding="utf-8")
    line_old = next(l for l in text.splitlines() if l.startswith("| S033 |"))
    cells = line_old.split(" | ")
    idx = next(i for i, c in enumerate(cells) if c.strip() == old_cell)
    cells[idx] = new_cell
    path.write_text(text.replace(line_old, " | ".join(cells)), encoding="utf-8")


def load_module(tree):
    spec = importlib.util.spec_from_file_location(
        "rc_%s" % tree.name, tree / "corpus" / "release-clock.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(tree, cell, tag):
    work = SB / ("obs-%s" % tag)
    if work.exists():
        shutil.rmtree(work)
    shutil.copytree(CAND, work)
    edit_anchor_cell(work, S033_ORIG, cell)
    module = load_module(work)
    captures = module.parse_captures(work)

    def fake_request(url, opener=None, resolver=None):
        if url in FEED_BODIES:
            return 200, FEED_BODIES[url], None
        quote = captures.get(url, ("", ""))[0]
        return 200, ("<html><p>%s</p></html>" % quote).encode("utf-8"), None

    module.request_body = fake_request
    out_json = work / "observe.json"
    buf = io.StringIO()
    with redirect_stdout(buf):
        code = module.main(["--root", str(work), "--observe", str(out_json)])
    stdout = buf.getvalue()
    bundle = json.loads(out_json.read_text(encoding="utf-8"))
    records = {rec["id"]: rec for rec in bundle.get("observations", [])
               if isinstance(rec, dict) and isinstance(rec.get("id"), str)}
    rows = {rid: records.get(rid, {}) for rid in DERIVED_ROWS}
    findings = [l for l in stdout.splitlines()
                if l.strip() and not l.startswith("RELEASE_CLOCK")]
    final = [l for l in stdout.splitlines() if l.startswith("RELEASE_CLOCK:")]
    return {
        "tag": tag, "exit": code, "stdout": stdout,
        "finding_lines": findings, "final_lines": final,
        "derived_receipts": {k: {kk: v.get(kk) for kk in
                                 ("id", "parsed_version", "verdict", "error")}
                             for k, v in rows.items()},
        "observe_line": next((l for l in stdout.splitlines()
                              if l.startswith("RELEASE_CLOCK_OBSERVE")), ""),
    }


def main():
    out = [run(CAND, S033_ORIG, "control"), run(CAND, TWO_VERSIONS, "two_versions")]
    for res in out:
        print(json.dumps(res, indent=1))
        print("-" * 70)
    (SB / "observe-results.json").write_text(json.dumps(out, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
