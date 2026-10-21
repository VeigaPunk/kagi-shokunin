#!/usr/bin/env python3
"""Probe-only fixture runner (CritSeparability sandbox): F1/F2/F3/F4, G1..G4, control.

usage: fixtures.py <tree> [--forge-receipt]
Not the frozen c1/c2-measure tools; an approximation of their fixture sets.
"""
import hashlib
import importlib.util
import io
import json
import contextlib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
FORGE = "--forge-receipt" in sys.argv[2:]
RECEIPT = Path(".ufo/waves/round-26/observe-2.json")
GROUPS = {
    "G1": ("S033", ["S008", "S009", "S010", "S011"], "3.13.2"),
    "G2": ("S034", ["S013", "S022", "S023", "S024"], "2.1.0"),
    "G3": ("S035", ["S014", "S015", "S016", "S021", "S025", "S026"], "2.7.0"),
    "G4": ("S037", ["S029"], "8.22.0"),
}


def stage(edits):
    temp = Path(tempfile.mkdtemp(prefix="critsep-"))
    shutil.copytree(TREE / "corpus", temp / "corpus")
    (temp / RECEIPT.parent).mkdir(parents=True)
    shutil.copy(TREE / RECEIPT, temp / RECEIPT)
    tsv = temp / "corpus" / "release-clocks.tsv"
    lines = tsv.read_text(encoding="utf-8").splitlines()
    header = lines[0].split("\t")
    out = [lines[0]]
    for line in lines[1:]:
        fields = line.split("\t")
        if fields[0] in edits:
            for key, value in edits[fields[0]].items():
                fields[header.index(key)] = value
        out.append("\t".join(fields))
    tsv.write_text("\n".join(out) + "\n", encoding="utf-8")
    args = []
    if FORGE and edits:
        doc = json.loads((temp / RECEIPT).read_text(encoding="utf-8"))
        for record in doc["observations"]:
            if record["id"] in edits:
                e = edits[record["id"]]
                if "observed_version" in e:
                    record["parsed_version"] = e["observed_version"]
                if "verdict" in e:
                    record["verdict"] = e["verdict"]
        forged = temp / "forged.json"
        raw = json.dumps(doc).encode()
        forged.write_bytes(raw)
        args = ["--receipt", str(forged), "--receipt-sha", hashlib.sha256(raw).hexdigest()]
    return temp, args


def run(label, edits):
    temp, args = stage(edits)
    proc = subprocess.run(
        [sys.executable, "-I", "-B", str(temp / "corpus" / "release-clock.py"),
         "--root", str(temp)] + args,
        capture_output=True, text=True)
    text = proc.stdout + proc.stderr
    tb = "Traceback" in text
    lines = [l for l in text.splitlines() if not l.startswith("RELEASE_CLOCK:")]
    summary = [l for l in text.splitlines() if l.startswith("RELEASE_CLOCK:")]
    print("%s exit=%d traceback=%s findings=%s %s" % (
        label, proc.returncode, tb, sorted(lines)[:12] if not tb else text.strip().splitlines()[-1][:160],
        summary[0] if summary else ""))
    shutil.rmtree(temp)


def observe(label, title):
    spec = importlib.util.spec_from_file_location("rc", TREE / "corpus" / "release-clock.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    body = ("<rss><channel><item><title>Python 3.14.9</title></item>"
            "<item><title>%s</title></item><item><title>Python 3.15.0</title></item>"
            "</channel></rss>" % title).encode()
    mod.request_body = lambda url, opener=None, resolver=None: (200, body, None)
    values = {"id": "S040", "clock": "feed", "feed_url": "https://www.python.org/downloads/feed.rss",
              "anchored_version": "3.15.1", "observed_version": "3.15.1"}
    err = io.StringIO()
    try:
        with contextlib.redirect_stderr(err):
            r = mod.observe_one({"id": "S040", "url": None}, values, None, floor="3.15.1")
        print("%s receipt verdict=%s parsed=%s error=%s" % (
            label, r.get("verdict"), (r.get("parsed_version") or "")[:12], r.get("error", "")[:90]))
    except Exception as exc:  # noqa: BLE001 - probe reports untyped escapes
        print("%s TRACEBACK %s: %s" % (label, exc.__class__.__name__, str(exc)[:90]))


run("control", {})
run("F1", {"S040": {"observed_version": "3.15.01", "verdict": "fired"}})
run("F2", {"S040": {"observed_version": "3.15." + "1" * 4301, "verdict": "fired"}})
for name, (_, ids, low) in GROUPS.items():
    run(name, {i: {"anchored_version": low, "observed_version": low, "verdict": "not-fired"} for i in ids})
# coupling probes (not frozen fixtures)
run("X1 derived leading-zero anchor+obs S008",
    {"S008": {"anchored_version": "3.13.03", "observed_version": "3.13.03"}})
run("X2 derived leading-zero anchor only S008 (obs 3.13.3, fired)",
    {"S008": {"anchored_version": "3.13.03", "verdict": "fired"}})
run("X3 derived oversize anchor S029",
    {"S029": {"anchored_version": "8.23." + "0" * 4301, "verdict": "fired"}})
run("X4 G1 lowered to non-canonical 3.13.02",
    {i: {"anchored_version": "3.13.02", "observed_version": "3.13.02", "verdict": "not-fired"}
     for i in GROUPS["G1"][1]})
run("X5 derived v-prefix anchor S008 v3.13.3",
    {"S008": {"anchored_version": "v3.13.3"}})
observe("F3", "Python 3.15.01")
observe("F4", "Python 3.15." + "1" * 4301)
