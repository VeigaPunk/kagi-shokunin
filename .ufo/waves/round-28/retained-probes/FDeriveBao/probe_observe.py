#!/usr/bin/env python3
"""Offline observe-path probe for the G3 carrier (OpenBao S035, six rows).

Patches the candidate's request_body with a fake OpenBao Atom body whose newest
stable entry is v2.7.1 (the version the registry row S035 locates), then runs
the candidate's own run_observe/observe_one over the G3 fixture (six derived
anchors lowered to 2.6.0) and over the unmodified tree.

Question: does the candidate write a *fired* verdict for rows whose derived
anchor contradicts their own feed registry row (S035 -> 2.7.1)?
"""
import importlib.util
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
CAND = HERE / "cand"
G3 = HERE / "g3"
ROWS = ["S014", "S015", "S016", "S021", "S025", "S026"]
FEED_ROW = {"S035"}

FAKE_ATOM = b"""<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Release notes from openbao</title>
  <entry>
    <title>v2.7.1</title>
    <link href="https://github.com/openbao/openbao/releases/tag/v2.7.1"/>
    <updated>2026-10-01T18:32:18Z</updated>
  </entry>
  <entry>
    <title>api/v2.7.1</title>
    <link href="https://github.com/openbao/openbao/releases/tag/api/v2.7.1"/>
    <updated>2026-10-02T00:00:00Z</updated>
  </entry>
</feed>
"""


def load_module(path: Path):
    spec = importlib.util.spec_from_file_location("release_clock_candidate", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def probe(module, root: Path, label: str):
    module.request_body = lambda url, opener=None, resolver=None: (200, FAKE_ATOM, None)
    sources = module.parse_sources(root)
    rows = module.parse_bindings(root)
    keep = set(ROWS) | FEED_ROW
    sub_sources = {k: v for k, v in sources.items() if k in keep}
    sub_rows = [r for r in rows if r["id"] in keep]
    out = root / ("observe-%s.json" % label)
    if out.exists():
        out.unlink()
    failures = module.run_observe(root, sub_sources, sub_rows, out, {})
    doc = json.loads(out.read_text(encoding="utf-8"))
    verdicts = {r["id"]: (r.get("verdict"), r.get("parsed_version"), r.get("error"))
                for r in doc["observations"]}
    bundle = module.load_receipt_bundle(out)
    result = module.evaluate(sub_sources, sub_rows, {}, bundle)
    print("=== %s" % label)
    print("observe failures=%d" % failures)
    for rid in ROWS:
        print("  receipt %s verdict=%r parsed=%r error=%r" % (rid, *verdicts.get(rid, (None, None, None))))
    print("  evaluate errors=%s" % result["errors"])
    print("  evaluate counts: on_release=%d bound=%d observed=%d fired=%d derived=%d"
          % (result["on_release"], result["bound"], result["observed"],
             result["fired"], result["derived"]))
    print()
    return verdicts, result


def main():
    module = load_module(CAND / "corpus" / "release-clock.py")
    probe(module, CAND, "control-unmodified")
    probe(module, G3, "g3-lowered")
    return 0


if __name__ == "__main__":
    sys.exit(main())
