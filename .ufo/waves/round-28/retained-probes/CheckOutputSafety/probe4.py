#!/usr/bin/env python3
"""Probe 4: crash sweep over DERIVED row shapes (round-28 candidate 62a33b1).

Every mutation of a derived row must end in a typed finding on stdout
("<CATEGORY> <ROWID>") with NO Traceback on stdout/stderr, and no oversized /
untrusted token echoed.  Any uncaught exception inside main() would print a
Traceback (main() catches only SetupError) -- that is what this sweep hunts.

Mutations cover: anchored/observed version shapes, verdicts, feed_source_id
targets (present / absent / rendered-quote row), note prefix, observed_at,
and a registry anchor cell that carries a huge token.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
TREE = SANDBOX / "cand"
OVERSIZE = "1" * 4301

VERSIONS = [
    "3.13.3", "3.13.03", "3.13." + OVERSIZE, "3.13.1.1", "v3.13.3", "3.13.x",
    "-", "", "3.13.3 ", " 3.13.3", "3.13.3-rc1", "3.13.3+build", "0.0.0",
    "00.13.3", "3.13.3.0", "9"*40 + ".1.1", "3.13.٣", "3.13.3\t",
]


def env_for(tmp):
    return {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(tmp),
            "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}


def stage(tmp, name, table_text, sources_text):
    root = tmp / name
    (root / "corpus").mkdir(parents=True)
    for rel in ("source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    (root / "corpus" / "SOURCES.md").write_text(sources_text, encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(table_text, encoding="utf-8")
    return root


def base_table():
    return (TREE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8")


def with_row(fields):
    lines = base_table().splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f and f[0] == "S008":
            out.append("\t".join(fields) + "\n")
        else:
            out.append(line)
    return "".join(out)


def sources_with_anchor(sid, new_anchor):
    lines = (TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        cells = line.split("|")
        if line.strip().startswith("|") and len(cells) > 6 and cells[1].strip() == sid:
            cells[6] = " " + new_anchor + " "
            out.append("|".join(cells))
        else:
            out.append(line)
    return "".join(out)


def mirror_receipt(root, row_id, parsed, verdict):
    doc = json.loads((TREE / ".ufo" / "waves" / "round-26" / "observe-2.json")
                     .read_text(encoding="utf-8"))
    for rec in doc["observations"]:
        if rec.get("id") == row_id:
            rec["parsed_version"], rec["verdict"] = parsed, verdict
    p = root / "receipt.json"
    p.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
    return p, hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    tmp = Path(tempfile.mkdtemp(prefix="r28-probe4-", dir=str(SANDBOX)))
    env = env_for(tmp)
    findings = []
    crashes = []
    n = 0
    try:
        src = sources_with_anchor("S033", "Entry titled v3.13.3, tag link /releases/tag/v3.13.3, "
                                   + OVERSIZE + " updated 2026-07-23T05:29:11Z")
        cases = []
        for v in VERSIONS:
            for feed in ("S033", "S999", "S017", "-"):
                cases.append(("anchor=%r feed=%s" % (v[:24], feed),
                              ["S008", "feed", feed,
                               "https://github.com/getsops/sops/releases.atom",
                               v, v, "2026-10-21", "not-fired",
                               "derived: anchor names the main snapshot"]))
        cases.append(("registry-anchor-huge",
                      ["S008", "feed", "S033",
                       "https://github.com/getsops/sops/releases.atom",
                       "3.13.3", "3.13.3", "2026-10-21", "not-fired",
                       "derived: anchor names the main snapshot"]))
        for label, fields in cases:
            n += 1
            huge_src = "registry-anchor-huge" in label
            root = stage(tmp, "case-%03d" % n, with_row(fields),
                         src if huge_src else (TREE / "corpus" / "SOURCES.md").read_text(encoding="utf-8"))
            rp, sha = mirror_receipt(root, "S008", fields[4], fields[7])
            p = subprocess.run(
                ["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                 "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                cwd=str(TREE), env=env, text=True, capture_output=True, timeout=120)
            out = p.stdout + p.stderr
            rec = {"label": label, "exit": p.returncode,
                   "traceback": "Traceback" in out,
                   "stdout": p.stdout.splitlines()[:4],
                   "stderr": p.stderr.splitlines()[:6],
                   "echoed_oversize": OVERSIZE in out}
            findings.append(rec)
            if rec["traceback"] or rec["echoed_oversize"] or p.returncode not in (0, 1):
                crashes.append(rec)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    (SANDBOX / "probe4-result.json").write_text(
        json.dumps({"cases": findings, "anomalies": crashes}, indent=2) + "\n",
        encoding="utf-8")
    print("cases=%d anomalies=%d" % (len(findings), len(crashes)))
    cats = {}
    for f in findings:
        key = tuple(sorted(l.split()[0] for l in f["stdout"]
                           if l and not l.startswith("RELEASE_CLOCK")))
        cats.setdefault(key, []).append(f["label"])
    for k, v in sorted(cats.items()):
        print("  %-60s n=%d e.g. %s" % (str(k), len(v), v[0]))
    for c in crashes:
        print("ANOMALY %s" % json.dumps(c)[:600])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
