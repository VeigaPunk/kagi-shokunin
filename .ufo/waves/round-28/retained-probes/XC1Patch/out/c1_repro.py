#!/usr/bin/env python3
"""XC1 executor reproduction of the round-28 C1 fixture definitions (F1-F4, control).

The frozen tool .ufo/waves/round-28/tools/c1-measure.py was absent from the lane
when this ran (that directory was empty), so this file reproduces the plan's
fixture definitions in the sandbox. It never writes into the lane.

TYPED follows the predicate relayed by the round-28 XC1Measure seat: a stdout line
`<CATEGORY> <id>` naming a fixture id (S040, or the python.org rows for --observe)
whose CATEGORY is outside the BASE-era set {ORPHAN, UNBOUND, INCONSISTENT, BADFEED,
REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED}. The BASE-era set is also reported as
`base_era_lines` so the reader can see what a BASE-era category would have counted.

Usage: python3 -I -B c1_repro.py TREE LABEL OUT.json
"""
import contextlib
import importlib.util
import io
import json
import re
import shutil
import subprocess
import sys
import tempfile
import traceback
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent.parent
TREE = Path(sys.argv[1]).resolve()
LABEL = sys.argv[2]
OUT = Path(sys.argv[3])
PY_URL = "https://www.python.org/downloads/feed.rss"
PY_IDS = {"S027", "S028", "S040", "S041"}
BASE_ERA = {"ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
            "RECEIPT-MISMATCH", "NOT OBSERVED"}
STRICT = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
FIXTURES_DIR = SANDBOX / "out" / "fixtures"
FIXTURES_DIR.mkdir(parents=True, exist_ok=True)


def copy_fixture(name):
    root = Path(tempfile.mkdtemp(prefix=LABEL + "-" + name + "-", dir=FIXTURES_DIR))
    (root / "corpus").mkdir()
    for item in (TREE / "corpus").iterdir():
        if item.is_file():
            shutil.copy2(item, root / "corpus" / item.name)
    receipt_dir = root / ".ufo" / "waves" / "round-26"
    receipt_dir.mkdir(parents=True)
    shutil.copy2(TREE / ".ufo" / "waves" / "round-26" / "observe-2.json",
                 receipt_dir / "observe-2.json")
    return root


def edit_row(root, row_id, observed, verdict):
    path = root / "corpus" / "release-clocks.tsv"
    lines = path.read_text(encoding="utf-8").split("\n")
    for index, line in enumerate(lines):
        fields = line.split("\t")
        if fields[0] == row_id and len(fields) == 9:
            fields[5] = observed
            fields[7] = verdict
            lines[index] = "\t".join(fields)
    path.write_text("\n".join(lines), encoding="utf-8")


def default_run(root):
    proc = subprocess.run([sys.executable, "-I", "-B", "corpus/release-clock.py"], cwd=root,
                          capture_output=True, text=True, timeout=300)
    return proc.returncode, proc.stdout + proc.stderr


def load_module(root):
    spec = importlib.util.spec_from_file_location("rc_fixture", root / "corpus" / "release-clock.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def observe_run(root, python_body):
    module = load_module(root)
    sources = module.parse_sources(root)
    rows = module.parse_bindings(root)
    captures = module.parse_captures(root)
    newest = {}
    for row in rows:
        values = dict(zip(module.HEADER, row["fields"]))
        if values["clock"] != "feed":
            continue
        for key in ("anchored_version", "observed_version"):
            version = values[key]
            if STRICT.fullmatch(version):
                key_tuple = tuple(int(part) for part in version.split("."))
                url = values["feed_url"]
                if url not in newest or key_tuple > newest[url][0]:
                    newest[url] = (key_tuple, version)

    def quote_body(url):
        quotes = [captures[sid][0] for sid, source in sources.items()
                  if source["url"] == url and sid in captures]
        return "".join("<p>%s</p>" % quote for quote in quotes).encode("utf-8") or None

    def stub(url, opener=None, resolver=None):
        if url == PY_URL:
            return 200, python_body, None
        if url == "https://curl.se/info" and url in newest:
            return 200, ("Version: %s\nDate: 2026-10-14\n" % newest[url][1]).encode(), None
        if url in newest:
            body = ('<feed xmlns="http://www.w3.org/2005/Atom"><entry><title>v%s</title>'
                    '</entry></feed>' % newest[url][1]).encode()
            return 200, body, None
        body = quote_body(url)
        if body:
            return 200, body, None
        return None, None, "fixture stub: unknown URL"

    module.request_body = stub
    out_path = root / "observe-receipt.json"
    buffer = io.StringIO()
    try:
        with contextlib.redirect_stdout(buffer):
            code = module.main(["--root", str(root), "--observe", str(out_path)])
    except BaseException:
        code = "EXCEPTION"
        buffer.write(traceback.format_exc())
    records = {}
    if out_path.exists():
        records = module.load_receipt_bundle(out_path)["records"]
    fired_written = sorted(
        sid for sid, record in records.items()
        if record.get("url") == PY_URL and record.get("verdict") == "fired")
    return {"exit": code, "text": buffer.getvalue(), "fired_python_receipts": fired_written,
            "python_receipts": {sid: {k: records[sid].get(k) for k in
                                      ("parsed_version", "verdict", "error")}
                                for sid in sorted(PY_IDS) if sid in records}}


def finding_lines(text):
    lines = []
    for line in text.splitlines():
        if not line.strip() or line.startswith("RELEASE_CLOCK"):
            continue
        category, _, row_id = line.rpartition(" ")
        if row_id.startswith("S") and row_id[1:].isdigit():
            lines.append((category, row_id))
    return lines


def classify(exit_code, text, mentioned, fired_written):
    findings = finding_lines(text)
    typed = [(c, r) for c, r in findings if r in mentioned and c not in BASE_ERA]
    base_era = [(c, r) for c, r in findings if r in mentioned and c in BASE_ERA]
    if "Traceback" in text or exit_code == "EXCEPTION":
        return "MISHANDLED (traceback)", typed, base_era
    if (exit_code == 0 and "RELEASE_CLOCK: CLEAN" in text) or fired_written:
        return "MISHANDLED", typed, base_era
    if exit_code == 1 and typed:
        return "TYPED", typed, base_era
    return "OTHER", typed, base_era


def record(results, name, exit_code, text, mentioned, fired_written=False):
    klass, typed, base_era = classify(exit_code, text, mentioned, fired_written)
    results[name] = {"exit": exit_code, "class": klass, "typed_lines": typed,
                     "base_era_lines": base_era, "fired_python_receipts": fired_written}
    return klass


def main():
    results = {}
    root = copy_fixture("control-default")
    code, text = default_run(root)
    results["control_default"] = {"exit": code, "class": "control",
                                  "output": text.strip().splitlines()[-1:]}

    root = copy_fixture("F1")
    edit_row(root, "S040", "3.15.01", "fired")
    code, text = default_run(root)
    record(results, "F1_table_lie_leading_zero", code, text, {"S040"})
    results["F1_table_lie_leading_zero"]["output"] = text.strip().splitlines()

    root = copy_fixture("F2")
    edit_row(root, "S040", "3.15." + "1" * 4301, "fired")
    code, text = default_run(root)
    record(results, "F2_table_oversize", code, text, {"S040"})
    results["F2_table_oversize"]["output"] = [
        line[:160] for line in text.strip().splitlines()]

    root = copy_fixture("F3")
    body = (b"<rss><channel><item><title>Python 3.15.01</title></item>"
            b"<item><title>Python 3.15.0</title></item></channel></rss>")
    observed = observe_run(root, body)
    record(results, "F3_observe_leading_zero", observed["exit"], observed["text"], PY_IDS,
           bool(observed["fired_python_receipts"]))
    results["F3_observe_leading_zero"].update(
        {k: observed[k] for k in ("text", "python_receipts")})

    root = copy_fixture("F4")
    body = (b"<rss><channel><item><title>Python 3.15." + b"1" * 4301 +
            b"</title></item><item><title>Python 3.15.0</title></item></channel></rss>")
    observed = observe_run(root, body)
    record(results, "F4_observe_oversize", observed["exit"], observed["text"], PY_IDS,
           bool(observed["fired_python_receipts"]))
    results["F4_observe_oversize"].update(
        {k: observed[k] for k in ("text", "python_receipts")})

    root = copy_fixture("control-observe")
    body = (b"<rss><channel><item><title>Python 3.15.1</title></item>"
            b"<item><title>Python 3.15.0</title></item></channel></rss>")
    observed = observe_run(root, body)
    results["control_observe_canonical"] = {
        "exit": observed["exit"], "class": "control", "text": observed["text"],
        "fired_python_receipts": observed["fired_python_receipts"]}

    summary = {"label": LABEL, "tree": str(TREE), "results": results}
    OUT.write_text(json.dumps(summary, indent=2, ensure_ascii=False, sort_keys=True) + "\n",
                   encoding="utf-8")
    for name, value in results.items():
        print("%-30s exit=%s class=%s" % (name, value["exit"], value["class"]))


if __name__ == "__main__":
    main()
