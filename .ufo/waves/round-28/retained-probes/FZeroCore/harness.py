#!/usr/bin/env python3
"""FZeroCore independent harness (round-28 falsify).

Attacks ONLY the carrier: canonical version-token handling in
corpus/release-clock.py -- the `0.0.0` canonical control and the zero-padded
CORE (patch) component -- at pinned candidate 62a33b1 vs BASE 3553d49.

No network: the module's own request_body/opener is stubbed (the substitution
the script's own selftest uses). Writes only under this sandbox.
"""
import hashlib
import importlib.util
import io
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
CAND = SANDBOX / "cand" / "corpus" / "release-clock.py"
BASE = SANDBOX / "base" / "corpus" / "release-clock.py"

HEADER = ("id", "clock", "feed_source_id", "feed_url", "anchored_version",
          "observed_version", "observed_at", "verdict", "note")
FEED_URL = "https://example.test/releases.atom"
ATOM = (b'<feed xmlns="http://www.w3.org/2005/Atom">'
        b'<entry><title>%s</title></entry></feed>')


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def mini_corpus(tmp, anchor_cell, rows, feed_cell):
    corpus = tmp / "corpus"
    corpus.mkdir(parents=True, exist_ok=True)
    md = [
        "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
        "| S001 | Doc - https://example.test/doc | docs | A | test scope | %s | Quote: “x.” | mined | 2026-10-21 | on-release | - |" % anchor_cell,
        "| S002 | Feed - %s | code | A | test scope | %s | Feed teaching. | mined | 2026-10-21 | 90d | - |" % (FEED_URL, feed_cell),
    ]
    (corpus / "SOURCES.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    body = ["\t".join(HEADER)]
    body.extend("\t".join(row) for row in rows)
    (corpus / "release-clocks.tsv").write_text("\n".join(body) + "\n", encoding="utf-8")
    return corpus


def receipt_for(rows, path, mirror=True):
    records = []
    for row in rows:
        values = dict(zip(HEADER, row))
        if not mirror:
            break
        records.append({
            "id": values["id"], "clock": values["clock"], "url": values["feed_url"],
            "http_status": 200, "sha256": "0" * 64,
            "parsed_version": values["observed_version"], "located": None,
            "verdict": values["verdict"],
            "observed_at": values["observed_at"] + "T00:00:00Z",
        })
    path.write_text(json.dumps({"format": "release-clock-observations-v1",
                                 "observations": records}, indent=2, sort_keys=True),
                    encoding="utf-8")
    return path


def run_main(module_path, rows, anchor_cell, feed_cell, mirror=True):
    tmp = Path(tempfile.mkdtemp(prefix="fzerocore-"))
    try:
        mini_corpus(tmp, anchor_cell, rows, feed_cell)
        receipt = receipt_for(rows, tmp / "receipt.json", mirror)
        sha = hashlib.sha256(receipt.read_bytes()).hexdigest()
        cmd = [sys.executable, "-I", "-B", str(module_path), "--root", str(tmp),
               "--receipt", str(receipt), "--receipt-sha", sha]
        proc = subprocess.run(cmd, capture_output=True, text=True)
        out = proc.stdout.strip().splitlines()
        cats = [line.split(" ", 1)[0] for line in out
                if line and not line.startswith("RELEASE_CLOCK:")]
        summary = next((line for line in out if line.startswith("RELEASE_CLOCK:")), "")
        return {
            "rc": proc.returncode,
            "categories": sorted(set(cats)),
            "summary": summary,
            "traceback": "Traceback" in (proc.stdout + proc.stderr),
            "stderr_head": proc.stderr.strip().splitlines()[:3],
        }
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def feed_row(rid="S001", anchored="1.2.3", observed="1.2.3", verdict="not-fired",
             note="test", observed_at="2026-10-21"):
    return [rid, "feed", "S002", FEED_URL, anchored, observed, observed_at,
            verdict, note]


def probe_module(module):
    out = {}

    def parse(body):
        try:
            return ["ok", module.parse_latest_version(body)]
        except Exception as exc:  # noqa: BLE001
            return [exc.__class__.__name__, str(exc)[:120]]

    def observe(anchored, observed, body):
        values = {"id": "S001", "clock": "feed", "feed_url": FEED_URL,
                  "anchored_version": anchored, "observed_version": observed}
        source = {"url": "https://example.test/doc", "teaches": "test"}

        class Response:
            code = 200
            msg = "OK"
            headers = {}

            def getcode(self):
                return self.code

            def info(self):
                return self.headers

            def read(self, limit):
                return body[:limit]

            def __enter__(self):
                return self

            def __exit__(self, *exc):
                return False

        class Opener:
            def open(self, request, timeout=None):
                return Response()

        def resolver(host, port, type=None):
            return [(2, 1, 6, "", ("93.184.216.34", port))]

        try:
            receipt = module.observe_one(source, values, None, opener=Opener(),
                                         resolver=resolver)
        except Exception as exc:  # noqa: BLE001
            return [exc.__class__.__name__, str(exc)[:120]]
        return [receipt.get("verdict"), receipt.get("parsed_version"),
                (receipt.get("error") or "")[:90]]

    out["parse_feed_v0.0.0"] = parse(ATOM % b"v0.0.0")
    out["parse_feed_v0.0.01"] = parse(ATOM % b"v0.0.01")
    out["parse_feed_v3.15.01"] = parse(ATOM % b"v3.15.01")
    out["parse_feed_v3.15.1"] = parse(ATOM % b"v3.15.1")
    out["parse_feed_v3.15.1_and_v0.0.00"] = parse(
        ATOM.replace(b"<entry>", b"<entry>") % b"v3.15.1")
    out["parse_text_0.0.0"] = parse(b"Version: 0.0.0\nDate: 2026-10-14\n")
    out["parse_text_0.0.01"] = parse(b"Version: 0.0.01\nDate: 2026-10-14\n")
    out["numeric_0.0.0"] = str(module.numeric_version("0.0.0"))
    out["numeric_0.0.0_is_none"] = module.numeric_version("0.0.0") is None
    out["numeric_0.0.01"] = str(module.numeric_version("0.0.01"))
    out["numeric_0.0.01_is_none"] = module.numeric_version("0.0.01") is None
    out["numeric_3.15.01"] = str(module.numeric_version("3.15.01"))
    out["numeric_3.15.01_is_none"] = module.numeric_version("3.15.01") is None
    out["order_000_lt_001"] = module.numeric_version("0.0.0") < module.numeric_version("0.0.1")
    out["order_001_lt_010"] = module.numeric_version("0.0.1") < module.numeric_version("0.1.0")
    out["order_010_lt_100"] = module.numeric_version("0.1.0") < module.numeric_version("1.0.0")
    out["order_3.15.9_lt_3.15.10"] = (module.numeric_version("3.15.9")
                                      < module.numeric_version("3.15.10"))
    out["vin_0.0.0"] = module.version_is_named(
        "Entry titled v0.0.0, tag link /releases/tag/v0.0.0", "0.0.0")
    out["vin_0.0.0_in_10.0.0"] = module.version_is_named("title v10.0.0", "0.0.0")
    out["vin_0.0.01_in_0.0.01"] = module.version_is_named(
        "Entry titled v0.0.01, tag link /releases/tag/v0.0.01", "0.0.01")
    out["observe_canonical_0.0.0_feed"] = observe("1.2.3", "1.2.3", ATOM % b"v0.0.0")
    out["observe_zero_core_feed"] = observe("1.2.3", "1.2.3", ATOM % b"v1.2.03")
    out["observe_zero_core_row_anchor"] = observe("1.2.03", "1.2.03", ATOM % b"v1.2.3")
    out["observe_zero_core_row_obs"] = observe("1.2.3", "1.2.03", ATOM % b"v1.2.3")
    if hasattr(module, "non_canonical_version"):
        out["noncanon_0.0.0"] = module.non_canonical_version("0.0.0")
        out["noncanon_0.0.01"] = module.non_canonical_version("0.0.01")
        out["noncanon_3.15.01"] = module.non_canonical_version("3.15.01")
        out["noncanon_3.15.1"] = module.non_canonical_version("3.15.1")
        out["noncanon_0.00.0"] = module.non_canonical_version("0.00.0")
    return out


CASES = [
    ("ctrl_clean", "Version 1.2.3 documentation",
     [feed_row()],
     "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z"),
    ("zero_core_obs", "Version 1.2.3 documentation",
     [feed_row(observed="1.2.03", verdict="fired")],
     "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z"),
    ("zero_core_anchor", "Version 1.2.3 documentation",
     [feed_row(anchored="1.2.03", observed="1.2.03")],
     "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z"),
    ("zero_core_derived_anchor", "Version 1.2.3 documentation",
     [feed_row(anchored="1.2.03", observed="1.2.03",
               note="derived: newest stable release on the feed")],
     "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z"),
    ("zero_canonical_000", "Version 0.0.0 documentation",
     [feed_row(anchored="0.0.0", observed="0.0.0")],
     "Entry titled v0.0.0, tag link /releases/tag/v0.0.0, updated 2026-10-21T00:00:00Z"),
    ("zero_canonical_000_fired_lie", "Version 0.0.0 documentation",
     [feed_row(anchored="0.0.0", observed="0.0.0", verdict="fired")],
     "Entry titled v0.0.0, tag link /releases/tag/v0.0.0, updated 2026-10-21T00:00:00Z"),
    ("zero_core_obs_unmirrored_receipt", "Version 1.2.3 documentation",
     [feed_row(observed="1.2.03", verdict="fired")],
     "Entry titled v1.2.3, tag link /releases/tag/v1.2.3, updated 2026-10-21T00:00:00Z"),
]


def main():
    results = {}
    for label, path in (("cand", CAND), ("base", BASE)):
        module = load(path, "rc_" + label)
        results[label + "_module"] = probe_module(module)
        runs = {}
        for case_id, anchor_cell, rows, feed_cell in CASES:
            mirror = case_id != "zero_core_obs_unmirrored_receipt"
            runs[case_id] = run_main(path, rows, anchor_cell, feed_cell, mirror)
        results[label + "_runs"] = runs
    print(json.dumps(results, indent=1, sort_keys=True))


if __name__ == "__main__":
    main()
