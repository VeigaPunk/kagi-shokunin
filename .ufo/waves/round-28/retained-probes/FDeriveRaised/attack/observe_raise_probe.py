#!/usr/bin/env python3
"""FDeriveRaised observe-path probe (offline, no network).

A derived row's anchored_version is RAISED above the version named by its
feed_source_id registry row's located anchor in corpus/SOURCES.md, with a
matching canonical observation.  The feed body is stubbed offline.

Asserts: the --observe path writes no "fired" verdict for the raised row, the
run exits 1, the finding is the typed DERIVATION category (not a generic
receipt mismatch, not a traceback), and the written receipt carries a typed
verdict.
"""
import importlib.util
import io
import json
from pathlib import Path
import sys
import tempfile

WORK = Path(__file__).resolve().parent
CLONE = WORK / "clone-candidate"
HEADER = ["id", "clock", "feed_source_id", "feed_url", "anchored_version",
          "observed_version", "observed_at", "verdict", "note"]


def load_module(path):
    spec = importlib.util.spec_from_file_location("release_clock_probe", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def build_root(root, anchored, observed):
    corpus = root / "corpus"
    corpus.mkdir(parents=True, exist_ok=True)
    rows = [
        "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
        # S001: the on-release clock row (the derived row).
        "| S001 | Doc — https://example.test/doc | docs | A | scope | §Doc, no version, opened 2026-10-19 | Doc. | mined | 2026-10-19 | on-release | https://example.test/doc |",
        # S002: the feed registry row; its located anchor names v1.2.9.
        "| S002 | Feed — https://example.test/releases.atom | code | A | scope | Entry titled v1.2.9 | Feed. | mined | 2026-10-21 | 90d | — |",
    ]
    (corpus / "SOURCES.md").write_text("\n".join(rows) + "\n", encoding="utf-8")
    table = [HEADER,
             ["S001", "feed", "S002", "https://example.test/releases.atom",
              anchored, observed, "2026-10-21", "not-fired",
              "derived: newest stable release on the feed when the row was opened"]]
    (corpus / "release-clocks.tsv").write_text(
        "".join("\t".join(r) + "\n" for r in table), encoding="utf-8")
    (corpus / "source-fetches.tsv").write_text("", encoding="utf-8")


def probe(label, anchored, observed, feed_title):
    module = load_module(CLONE / "corpus" / "release-clock.py")
    with tempfile.TemporaryDirectory(prefix="raise-observe-") as temp:
        root = Path(temp)
        build_root(root, anchored, observed)
        body = ('<feed xmlns="http://www.w3.org/2005/Atom">'
                "<entry><title>%s</title></entry></feed>" % feed_title).encode("utf-8")
        module.request_body = lambda url, **kwargs: (200, body, None)
        module.utc_timestamp = lambda: "2026-10-21T00:00:00Z"
        out = root / "receipt.json"
        stdout = io.StringIO()
        with contextlib_redirect(stdout):
            exit_code = module.main(["--root", str(root), "--observe", str(out)])
        text = stdout.getvalue()
        receipt = json.loads(out.read_text(encoding="utf-8"))
        record = receipt["observations"][0]
        findings = [l for l in text.splitlines()
                    if l.strip() and not l.startswith("RELEASE_CLOCK:")]
        return {
            "label": label, "anchored": anchored, "observed": observed,
            "feed_title": feed_title, "exit": exit_code, "stdout": text,
            "findings": findings, "receipt_verdict": record.get("verdict"),
            "receipt_parsed_version": record.get("parsed_version"),
            "receipt_error": record.get("error"),
            "traceback": "Traceback" in text,
            "fired_written": record.get("verdict") == "fired",
        }


class contextlib_redirect:
    def __init__(self, target):
        self.target = target

    def __enter__(self):
        import contextlib
        self.ctx = contextlib.redirect_stdout(self.target)
        return self.ctx.__enter__()

    def __exit__(self, *args):
        return self.ctx.__exit__(*args)


def main():
    results = []
    # O1: the feed's true newest stable is v1.2.9 (the registry's located
    # anchor); the row claims a raised 1.3.0 with a matching observation.
    results.append(probe("O1-raised-vs-true-feed", "1.3.0", "1.3.0", "v1.2.9"))
    # O2: the feed has advanced to v1.3.0 but the registry row still names
    # v1.2.9; the row's raised 1.3.0 no longer matches its registry anchor.
    results.append(probe("O2-raised-vs-stale-registry", "1.3.0", "1.3.0", "v1.3.0"))
    # Control: the row's anchor equals the registry's located anchor.
    results.append(probe("O3-control-bound", "1.2.9", "1.2.9", "v1.2.9"))
    (WORK / "observe-raise-results.json").write_text(
        json.dumps(results, indent=2) + "\n", encoding="utf-8")
    ok = True
    for r in results:
        print("%-28s exit=%s receipt_verdict=%s parsed=%s fired_written=%s "
              "traceback=%s findings=%s"
              % (r["label"], r["exit"], r["receipt_verdict"],
                 r["receipt_parsed_version"], r["fired_written"],
                 r["traceback"], r["findings"]))
    for r in results[:2]:
        if (r["exit"] != 1 or r["fired_written"] or r["traceback"]
                or "DERIVATION S001" not in r["stdout"]
                or "RELEASE_CLOCK: FAILED" not in r["stdout"]):
            ok = False
    print("OBSERVE_PROBE %s" % ("PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
