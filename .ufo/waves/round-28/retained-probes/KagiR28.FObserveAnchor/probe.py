#!/usr/bin/env python3
"""Falsification probe: --observe over a derived row whose anchor is noncanonical.

Reproduces the CLI sequence of corpus/release-clock.py main() with the HTTP layer
replaced by an in-process static body map (no network, no vault/account contact).
"""
import argparse
import importlib.util
import json
import re
import sys
from pathlib import Path

ATOM = ("<?xml version='1.0' encoding='UTF-8'?>\n"
        "<feed xmlns='http://www.w3.org/2005/Atom'>"
        "<entry><title>v{ver}</title>"
        "<link href='https://example.test/releases/tag/v{ver}'/>"
        "<updated>2026-10-21T00:00:00Z</updated></entry></feed>")


def canonical_ok(value):
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", value or ""):
        return False
    return all(p == "0" or (p[0] != "0" and len(p) <= 18) for p in value.split("."))


def load_module(path):
    spec = importlib.util.spec_from_file_location("rc_probe", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, help="work tree root (contains corpus/)")
    ap.add_argument("--out", required=True, help="output dir for receipts")
    ap.add_argument("--label", required=True)
    ap.add_argument("--edit", default="", help="row_id=new_anchored_version")
    ap.add_argument("--edit-observed", default="", help="row_id=new_observed_version")
    ap.add_argument("--feed-override", default="", help="url=version")
    ap.add_argument("--target", default="", help="row id to report on")
    args = ap.parse_args()

    root = Path(args.tree).resolve()
    for spec, index in ((args.edit, 4), (args.edit_observed, 5)):
        if not spec:
            continue
        row_id, new_value = spec.split("=", 1)
        tsv = root / "corpus" / "release-clocks.tsv"
        out_lines = []
        for line in tsv.read_text(encoding="utf-8").splitlines():
            fields = line.split("\t")
            if fields and fields[0] == row_id:
                fields[index] = new_value
                line = "\t".join(fields)
            out_lines.append(line)
        tsv.write_text("\n".join(out_lines) + "\n", encoding="utf-8")
    mod = load_module(str(root / "corpus" / "release-clock.py"))
    sources = mod.parse_sources(root)
    rows = mod.parse_bindings(root)
    captures = mod.parse_captures(root)

    # per-feed newest canonical anchored version, plus explicit overrides
    feed_ver = {}
    for row in rows:
        v = dict(zip(mod.HEADER, row["fields"]))
        if v["clock"] != "feed":
            continue
        a = v["anchored_version"]
        if canonical_ok(a):
            cur = feed_ver.get(v["feed_url"])
            if cur is None or tuple(int(p) for p in a.split(".")) > tuple(int(p) for p in cur.split(".")):
                feed_ver[v["feed_url"]] = a
    if args.feed_override:
        url, ver = args.feed_override.split("=", 1)
        feed_ver[url] = ver

    bodies = {}
    for url, ver in feed_ver.items():
        if url.rstrip("/").endswith("/info"):
            bodies[url] = ("Version: %s\nDate: 2026-10-14\n" % ver).encode()
        else:
            bodies[url] = ATOM.format(ver=ver).encode()
    # rendered-quote rows: serve the declared capture quote(s) so those rows locate
    quote_bodies = {}
    for row in rows:
        v = dict(zip(mod.HEADER, row["fields"]))
        if v["clock"] != "rendered-quote":
            continue
        src = sources.get(v["id"])
        quote = (captures.get(v["id"]) or ("", ""))[0]
        if src is not None and quote:
            quote_bodies.setdefault(src["url"], []).append(quote)
    for url, quotes in quote_bodies.items():
        bodies[url] = ("\n".join(quotes)).encode("utf-8", "replace")

    def fake_request_body(url, opener=None, resolver=None):
        body = bodies.get(url)
        if body is None:
            return 404, None, "stub has no body for %s" % url
        return 200, body, None

    mod.request_body = fake_request_body

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    receipt_path = out_dir / ("%s.json" % args.label)

    stdout = []
    try:
        observation_failures = mod.run_observe(root, sources, rows, receipt_path, captures)
        receipts = mod.load_receipt_bundle(receipt_path)
        result = mod.evaluate(sources, rows, captures, receipts)
        mod.print_result(result)
        exit_code = 0 if result["passed"] and observation_failures == 0 else 1
        traceback = False
        error = None
    except Exception as exc:  # noqa: BLE001 - probe must capture any traceback
        import traceback
        error = traceback.format_exc()
        traceback = True
        exit_code = 1
        observation_failures = None
        result = None
        receipts = None

    report = {
        "label": args.label,
        "tree": str(root),
        "exit_code": exit_code,
        "observation_failures": observation_failures,
        "traceback": traceback,
        "exception": error,
        "errors": [list(e) for e in result["errors"]] if result else None,
        "counts": {k: result[k] for k in ("on_release", "bound", "unbound", "observed", "fired", "derived")} if result else None,
    }
    if receipts is not None:
        records = receipts.get("records", {})
        if args.target:
            report["target_record"] = records.get(args.target)
        fired = [rid for rid, rec in records.items()
                 if rec.get("verdict") in ("fired", "quote-missing")]
        report["receipt_ids_with_fired_verdict"] = sorted(fired)
        report["receipt_ids_with_error"] = sorted(
            rid for rid, rec in records.items() if rec.get("error"))
    print("PROBE_JSON " + json.dumps(report, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
