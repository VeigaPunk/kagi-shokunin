#!/usr/bin/env python3
"""CritFrozenCommands probe: run BASE (and draft mutants) on F1-F4/G1-G4 readings, offline."""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

SB = Path(__file__).resolve().parent
BASE = SB / "base"
WORK = SB / "work"
PY_URL = "https://www.python.org/downloads/feed.rss"
FEED_COPY = BASE / ".ufo/waves/round-26/captures/S039.body"
BIG = "1" * 4301
GROUPS = {
    "G1": (["S008", "S009", "S010", "S011"], "3.13.2"),
    "G2": (["S013", "S022", "S023", "S024"], "2.1.0"),
    "G3": (["S014", "S015", "S016", "S021", "S025", "S026"], "2.7.0"),
    "G4": (["S029"], "8.22.0"),
}

WRAPPER = r'''
import importlib.util, sys, urllib.error
clock, root, out, body_path, pinned = sys.argv[1:6]
spec = importlib.util.spec_from_file_location("rc", clock)
rc = importlib.util.module_from_spec(spec); spec.loader.exec_module(rc)
body = open(body_path, "rb").read()
def fake(url, opener=None, resolver=None):
    if url == "%s":
        return 200, body, None
    raise urllib.error.URLError("offline harness")
rc.request_body = fake
if pinned != "-":
    rc.utc_timestamp = lambda: pinned
sys.exit(rc.main(["--root", root, "--observe", out]))
''' % PY_URL


def tree(name, clock_src):
    root = WORK / name
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py", "release-clocks.tsv"):
        shutil.copy2(BASE / "corpus" / rel, root / "corpus" / rel)
    shutil.copy2(clock_src, root / "corpus/release-clock.py")
    return root


def edit_table(root, edits):
    path = root / "corpus/release-clocks.tsv"
    lines = path.read_text().splitlines(keepends=True)
    for i, line in enumerate(lines):
        f = line.rstrip("\n").split("\t")
        if f[0] in edits:
            for col, val in edits[f[0]].items():
                f[col] = val
            lines[i] = "\t".join(f) + "\n"
    path.write_text("".join(lines))


def mirror_receipt(root, edits):
    receipt = json.loads((BASE / ".ufo/waves/round-26/observe-2.json").read_text())
    for rec in receipt["observations"]:
        if rec["id"] in edits:
            e = edits[rec["id"]]
            if 5 in e:
                rec["parsed_version"] = e[5]
            if 7 in e:
                rec["verdict"] = e[7]
    p = root / "receipt.json"
    p.write_text(json.dumps(receipt, indent=2) + "\n")
    return p, hashlib.sha256(p.read_bytes()).hexdigest()


def summarize(proc, receipt_file=None):
    out = proc.stdout
    findings = [l for l in out.splitlines() if re.match(r"^[A-Z][A-Z -]+ S[0-9]{3}$", l)]
    last = [l for l in out.splitlines() if l.startswith("RELEASE_CLOCK:")][-1:] or [""]
    res = {"exit": proc.returncode, "last": last[0][:140],
           "tb_stdout": "Traceback" in out, "tb_stderr": "Traceback" in proc.stderr,
           "findings": findings}
    if receipt_file and Path(receipt_file).exists():
        recs = json.loads(Path(receipt_file).read_text())["observations"]
        res["py_receipts"] = {r["id"]: (r.get("verdict"), (r.get("parsed_version") or "")[:12],
                                        (r.get("error") or "")[:60])
                              for r in recs if r.get("url") == PY_URL}
    return res


def run_table(clock_src, name, edits, mirror=True):
    root = tree(name, clock_src)
    edit_table(root, edits)
    argv = [sys.executable, "-I", "-B", str(root / "corpus/release-clock.py"), "--root", str(root)]
    if mirror:
        p, sha = mirror_receipt(root, edits)
        argv += ["--receipt", str(p), "--receipt-sha", sha]
    else:
        argv += ["--receipt", str(BASE / ".ufo/waves/round-26/observe-2.json"),
                 "--receipt-sha", "13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169"]
    return summarize(subprocess.run(argv, capture_output=True, text=True, timeout=300))


def run_observe(clock_src, name, title, mode="replace", pinned="-"):
    root = tree(name, clock_src)
    body = FEED_COPY.read_bytes()
    old = b"<title>Python 3.15.1</title>"
    assert body.count(old) == 1
    new = ("<title>%s</title>" % title).encode()
    if mode == "replace":
        body = body.replace(old, new)
    elif mode == "add-first":
        body = body.replace(b"<item>", b"<item>" + new + b"</item><item>", 1)
    elif mode == "add-last":
        idx = body.rindex(b"</item>") + len(b"</item>")
        body = body[:idx] + b"<item>" + new + b"</item>" + body[idx:]
    bp = root / "feed.body"
    bp.write_bytes(body)
    wp = root / "wrap.py"
    wp.write_text(WRAPPER)
    out = root / "observe.json"
    argv = [sys.executable, "-I", "-B", str(wp), str(root / "corpus/release-clock.py"),
            str(root), str(out), str(bp), pinned]
    return summarize(subprocess.run(argv, capture_output=True, text=True, timeout=300), out)


def main():
    variant = sys.argv[1]
    clock = SB / ("base/corpus/release-clock.py" if variant == "base" else variant + ".py")
    WORK.mkdir(exist_ok=True)
    r = {}
    r["F1_mirror"] = run_table(clock, variant + "-F1m", {"S040": {5: "3.15.01", 7: "fired"}})
    r["F1_tableonly"] = run_table(clock, variant + "-F1t", {"S040": {5: "3.15.01", 7: "fired"}}, False)
    r["F2_mirror"] = run_table(clock, variant + "-F2m", {"S040": {5: "3.15." + BIG, 7: "fired"}})
    r["F3_replace"] = run_observe(clock, variant + "-F3", "Python 3.15.01")
    r["F3_replace_nextday"] = run_observe(clock, variant + "-F3d", "Python 3.15.01", pinned="2026-10-22T00:00:01Z")
    r["F3_add_first"] = run_observe(clock, variant + "-F3af", "Python 3.15.01", "add-first")
    r["F3_add_last"] = run_observe(clock, variant + "-F3al", "Python 3.15.01", "add-last")
    r["F3_control_unedited"] = run_observe(clock, variant + "-F3c", "Python 3.15.1")
    r["F4_replace"] = run_observe(clock, variant + "-F4", "Python 3.15." + BIG)
    r["F4_leading0_big"] = run_observe(clock, variant + "-F4z", "Python 3.15.0" + "1" * 4300)
    for g, (ids, low) in GROUPS.items():
        edits = {i: {4: low, 5: low, 7: "not-fired"} for i in ids}
        r[g + "_mirror"] = run_table(clock, "%s-%sm" % (variant, g), edits)
        r[g + "_tableonly"] = run_table(clock, "%s-%st" % (variant, g), edits, False)
    raise_edits = {i: {4: "3.13.4", 5: "3.13.4", 7: "not-fired"} for i in GROUPS["G1"][0]}
    r["G1_raise_mirror"] = run_table(clock, variant + "-G1raise", raise_edits)
    ctl = subprocess.run([sys.executable, "-I", "-B", "corpus/release-clock.py"], cwd=BASE,
                         capture_output=True, text=True, timeout=300) if variant == "base" else None
    if ctl:
        r["control_default"] = summarize(ctl)
    Path(SB / ("probe-%s.json" % variant)).write_text(json.dumps(r, indent=1) + "\n")
    for k, v in r.items():
        print(k, json.dumps(v)[:400])


if __name__ == "__main__":
    main()
