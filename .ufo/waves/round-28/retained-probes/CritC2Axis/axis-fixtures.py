#!/usr/bin/env python3
"""CritC2Axis BASE fixtures: release-clock verdict plus a model of the plan's C2 predicate.

The model is NOT the integrated patch: it applies round-28.md:51-53 literally
(a `derived:` row's anchored version must be named by its feed_source_id row's
SOURCES.md anchor) with BASE's own version_is_named().
"""
import hashlib, importlib.util, json, shutil, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "base"
OUT = HERE / "runs"
RECEIPT = BASE / ".ufo/waves/round-26/observe-2.json"

spec = importlib.util.spec_from_file_location("rc", BASE / "corpus/release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

GROUPS = {
    "G1-sops": ({"S008", "S009", "S010", "S011"}, "3.13.2", "S033", "v3.13.3", "v3.13.2"),
    "G2-vault": ({"S013", "S022", "S023", "S024"}, "2.1.0", "S034", "v2.2.0", "v2.1.0"),
    "G3-openbao": ({"S014", "S015", "S016", "S021", "S025", "S026"}, "2.7.0", "S035", "v2.7.1", "v2.7.0"),
    "G4-curl": ({"S029"}, "8.22.0", "S037", "8.23.0", "8.22.0"),
}


def make(label, row_ids, version, source_edit=None):
    root = OUT / label
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE / "corpus", root / "corpus")
    tsv = root / "corpus/release-clocks.tsv"
    lines = tsv.read_text(encoding="utf-8").splitlines(keepends=True)
    new = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in row_ids:
            f[4] = version
            f[5] = version
            f[7] = "not-fired"
            line = "\t".join(f) + "\n"
        new.append(line)
    tsv.write_text("".join(new), encoding="utf-8")
    if source_edit:
        sid, old, newv = source_edit
        src = root / "corpus/SOURCES.md"
        out = []
        for line in src.read_text(encoding="utf-8").splitlines(keepends=True):
            if line.startswith("| %s |" % sid):
                assert old in line, (sid, old)
                line = line.replace(old, newv)
            out.append(line)
        src.write_text("".join(out), encoding="utf-8")
    doc = json.loads(RECEIPT.read_text(encoding="utf-8"))
    for rec in doc["observations"]:
        if rec["id"] in row_ids:
            rec["parsed_version"] = version
            rec["verdict"] = "not-fired"
    rpath = root / "receipt.json"
    rpath.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return root, rpath


def run(label, root, rpath):
    sha = hashlib.sha256(rpath.read_bytes()).hexdigest()
    p = subprocess.run(
        [sys.executable, "-I", "-B", str(BASE / "corpus/release-clock.py"), "--root", str(root),
         "--receipt", str(rpath), "--receipt-sha", sha],
        capture_output=True, text=True, env={"PATH": "/usr/bin", "LC_ALL": "C"})
    sources = rc.parse_sources(root)
    model = []
    for row in rc.parse_bindings(root):
        v = dict(zip(rc.HEADER, row["fields"]))
        if v.get("clock") == "feed" and v["note"].startswith("derived:"):
            feed = sources.get(v["feed_source_id"])
            if feed is None or not rc.version_is_named(feed["anchor"], v["anchored_version"]):
                model.append(row["id"])
    return {"label": label, "exit": p.returncode, "tail": p.stdout.strip().splitlines()[-1:],
            "findings": p.stdout.strip().splitlines()[:-1], "traceback": "Traceback" in p.stderr,
            "c2_model_mismatch": model}


results = []
root, rpath = make("control", set(), "")
results.append(run("control", root, rpath))
for label, (ids, ver, sid, old, newv) in GROUPS.items():
    root, rpath = make(label, ids, ver)
    results.append(run(label, root, rpath))
    root, rpath = make(label + "+src", ids, ver, (sid, old, newv))
    results.append(run(label + "+src", root, rpath))
root, rpath = make("O1-leading-zero-derived", {"S008"}, "3.13.03")
results.append(run("O1-leading-zero-derived", root, rpath))
json.dump(results, open(HERE / "axis-fixtures.json", "w"), indent=2)
for r in results:
    print(json.dumps(r))
