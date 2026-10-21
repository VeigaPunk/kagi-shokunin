#!/usr/bin/env python3
"""Fuzz bad version tokens through the observe/parse paths (no network).

For each token shape: the token is used as a derived row anchor and as the
newest feed entry.  Assert: no exception escapes (no traceback), and a
noncanonical token never yields a fired verdict or an untyped refusal.
"""
import importlib.util
import json
import sys
from pathlib import Path

ATOM = ("<?xml version='1.0' encoding='UTF-8'?>\n"
        "<feed xmlns='http://www.w3.org/2005/Atom'>"
        "<entry><title>v{ver}</title>"
        "<link href='https://example.test/releases/tag/v{ver}'/>"
        "<updated>2026-10-21T00:00:00Z</updated></entry></feed>")

TOKENS = [
    "3.13.3",
    "3.13.03",
    "3.13.003",
    "03.13.3",
    "3.013.3",
    "3.13.3.1",
    "3.13",
    "3.13.1-rc1",
    "v3.13.03",
    "3.13." + "1" * 19,
    "3.13." + "1" * 4301,
    "3.13." + "9" * 4301,
]


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run(tree, label):
    mod = load(str(Path(tree) / "corpus" / "release-clock.py"), "fz_" + label)
    out = []
    for token in TOKENS:
        rec = {"token": token, "len": len(token)}

        # 1) feed parse with the token as the newest entry
        body = ATOM.format(ver=token).encode()
        try:
            parsed = mod.parse_latest_version(body)
            rec["feed_parse"] = "parsed=%r" % (parsed,)
        except ValueError as exc:
            rec["feed_parse"] = "ValueError: %s" % exc
        except Exception as exc:  # noqa: BLE001
            rec["feed_parse"] = "UNEXPECTED %s: %s" % (exc.__class__.__name__, exc)

        # 2) observe over a row whose derived anchor is the token
        mod.request_body = lambda url, opener=None, resolver=None: (200, ATOM.format(ver="3.13.3").encode(), None)
        values = {"id": "S001", "clock": "feed",
                  "feed_url": "https://feed.example.test/releases.atom",
                  "anchored_version": token, "observed_version": "3.13.3"}
        source = {"id": "S001", "url": "https://example.test/doc", "teaches": "test"}
        try:
            obs = mod.observe_one(source, values, None)
            rec["observe_verdict"] = obs.get("verdict")
            rec["observe_error"] = obs.get("error")
            rec["observe_parsed"] = obs.get("parsed_version")
        except Exception as exc:  # noqa: BLE001
            rec["observe_verdict"] = "UNEXPECTED %s: %s" % (exc.__class__.__name__, exc)
            rec["observe_error"] = None
            rec["observe_parsed"] = None
        out.append(rec)
    return out


if __name__ == "__main__":
    for tree, label in ((sys.argv[1], sys.argv[2]),):
        for rec in run(tree, label):
            print("%-9s %-8s feed=%-70s obs_verdict=%-12s obs_err=%s" % (
                label, "len=%d" % rec["len"], rec["feed_parse"][:70],
                rec["observe_verdict"], rec["observe_error"]))
        print(json.dumps(run(tree, label))[:0])
