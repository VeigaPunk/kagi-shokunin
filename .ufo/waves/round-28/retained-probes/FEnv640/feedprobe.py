#!/usr/bin/env python3
"""Offline probe of the release-clock feed path for oversize version tokens.

Usage: feedprobe.py <tree> <digits> <mode>
modes: newest | older | rowanchor | canonical
No network: a static opener and a fake resolver are injected, exactly as the
candidate's own selftest does.
"""
import importlib.util
import socket
import sys

tree, digits, mode = sys.argv[1], int(sys.argv[2]), sys.argv[3]
spec = importlib.util.spec_from_file_location("rc", tree + "/corpus/release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)


class StaticResponse:
    code = 200
    msg = "OK"
    headers = {}

    def __init__(self, body):
        self.body = body

    def getcode(self):
        return self.code

    def info(self):
        return self.headers

    def read(self, limit):
        return self.body[:limit]

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        return False


class StaticOpener:
    def __init__(self, body):
        self.response = StaticResponse(body)
        self.requests = []

    def open(self, request, timeout):
        self.requests.append(request)
        return self.response


def fake_resolver(host, port, type=socket.SOCK_STREAM):
    return [(socket.AF_INET, type, socket.IPPROTO_TCP, "", ("93.184.216.34", port))]


token = "3.15." + "1" * digits
atom = b'<?xml version="1.0" encoding="UTF-8"?>\n<feed xmlns="http://www.w3.org/2005/Atom">\n'


def entry(title):
    return ('<entry><title>%s</title>'
            '<link href="https://www.python.org/downloads/release/x/"/></entry>\n' % title).encode()


if mode == "newest":
    body = atom + entry("Python " + token) + b"</feed>\n"
    anchor, observed = "3.15.1", "3.15.1"
elif mode == "older":
    body = atom + entry("Python 3.15.1") + entry("Python 3.14." + "1" * digits) + b"</feed>\n"
    anchor, observed = "3.15.1", "3.15.1"
elif mode == "rowanchor":
    body = atom + entry("Python 3.15.1") + b"</feed>\n"
    anchor, observed = token, token
else:
    body = atom + entry("Python 3.15.1") + b"</feed>\n"
    anchor, observed = "3.15.1", "3.15.1"

source = {"url": "https://docs.python.org/3/", "teaches": "t"}
values = {
    "id": "S001", "clock": "feed",
    "feed_url": "https://www.python.org/downloads/feed.rss",
    "anchored_version": anchor, "observed_version": observed,
}
receipt = rc.observe_one(source, values, None,
                         opener=StaticOpener(body), resolver=fake_resolver)
print("mode=%s digits=%d" % (mode, digits))
print("  observe verdict=%r parsed_version=%r error=%r" % (
    receipt.get("verdict"), receipt.get("parsed_version"), receipt.get("error")))
try:
    print("  parse_latest_version=%r" % rc.parse_latest_version(body))
except Exception as exc:
    print("  parse_latest_version raised %s: %s" % (type(exc).__name__, exc))
print("  non_canonical_version(row anchor)=%r non_canonical_version(observed)=%r" % (
    rc.non_canonical_version(anchor) if hasattr(rc, "non_canonical_version") else "n/a",
    rc.non_canonical_version(observed) if hasattr(rc, "non_canonical_version") else "n/a"))
