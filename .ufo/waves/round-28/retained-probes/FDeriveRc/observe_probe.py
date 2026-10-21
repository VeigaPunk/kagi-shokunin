"""Offline probe: does a DERIVATION mismatch still write a 'fired' verdict?

Usage: observe_probe.py <tree-root> <out-receipt.json>
No network: corpus/release-clock.py's request_body is replaced by a stub that
answers the Vault feed with a newer stable release (v2.3.0) and every other
feed with an empty feed body.
"""
import importlib.util
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
out_path = pathlib.Path(sys.argv[2]).resolve()

spec = importlib.util.spec_from_file_location("release_clock", root / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)


def fake_request_body(url, opener=None, resolver=None):
    if "hashicorp/vault" in url:
        return 200, b"<feed><entry><title>v2.3.0</title></entry></feed>", None
    return 200, b"<feed></feed>", None


rc.request_body = fake_request_body

sources = rc.parse_sources(root)
rows = rc.parse_bindings(root)
captures = rc.parse_captures(root)
if out_path.exists():
    out_path.unlink()
failures = rc.run_observe(root, sources, rows, str(out_path), captures)
print("observe_failures=%d" % failures)

document = json.loads(out_path.read_text(encoding="utf-8"))
for record in document["observations"]:
    if record["id"] in ("S013", "S022", "S023", "S024"):
        print("receipt %s verdict=%r parsed=%r" % (
            record["id"], record.get("verdict"), record.get("parsed_version")))

bundle = rc.load_receipt_bundle(out_path)
result = rc.evaluate(sources, rows, captures, bundle)
print("errors=%r" % (result["errors"],))
print("passed=%r" % (result["passed"],))
