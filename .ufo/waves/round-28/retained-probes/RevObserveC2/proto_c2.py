#!/usr/bin/env python3
"""Prototype C2 rule variants against BASE, in a sandbox only.

Variants:
  A  correct   : derived row's ANCHORED version must be named by its
                  feed_source_id registry row's ANCHOR cell; observation free.
  B  wrong#1   : bind the OBSERVED version (conflicts with a fired derived row)
  C  wrong#2   : bind the source row's OWN anchor cell (not the feed row's)
  D  wrong#3   : bind EVERY feed row, not just derived rows

Fixtures:
  G1..G4  plan's lowering fixtures
  FIRED   legitimately fired derived rows (SOPS feed advances to 3.14.0)
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
BASE = SANDBOX / "base"
WORK = SANDBOX / "work"

ANCHOR_CHECK = '''
def feed_anchor_versions(anchor_cell):
    """Distinct canonical X.Y.Z tokens named by a feed registry row's anchor cell."""
    out = set()
    for match in re.finditer(r"(?<![0-9A-Za-z.])v?([0-9]+\\.[0-9]+\\.[0-9]+)(?![0-9A-Za-z.])",
                             anchor_cell or ""):
        token = match.group(1)
        if not re.search(r"(^|\\.)0[0-9]", token):
            out.add(token)
    return out


def derived_anchor_bound(feed_source, values, sources):
    """True when the derived row's anchor is named by its feed row's anchor cell."""
    if not values["note"].startswith("derived:"):
        return True
    if feed_source is None:
        return True
    av = feed_anchor_versions(feed_source["anchor"])
    if not av:
        return True
    return norm_version(values["anchored_version"]) in av
'''

PATCH_A = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                if not derived_anchor_bound(feed_source, values, sources):
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

PATCH_B = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = feed_anchor_versions(feed_source["anchor"])
                if av and norm_version(values["observed_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

PATCH_C = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived:
                av = feed_anchor_versions(sources[source_id]["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

PATCH_D = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if feed_source is not None:
                av = feed_anchor_versions(feed_source["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

VARIANTS = {"A": PATCH_A, "B": PATCH_B, "C": PATCH_C, "D": PATCH_D}

GROUPS = {
    "G1": {"feed": "S033", "rows": ["S008", "S009", "S010", "S011"], "lower": "3.13.2"},
    "G2": {"feed": "S034", "rows": ["S013", "S022", "S023", "S024"], "lower": "2.1.9"},
    "G3": {"feed": "S035", "rows": ["S014", "S015", "S016", "S021", "S025", "S026"],
           "lower": "2.7.0"},
    "G4": {"feed": "S037", "rows": ["S029"], "lower": "8.22.0"},
}

# SOPS feed advances 3.13.3 -> 3.14.0: every derived row on S033 legitimately fires.
FIRED = {"S008": "3.14.0", "S009": "3.14.0", "S010": "3.14.0", "S011": "3.14.0"}


def build_variant(name, workdir):
    root = workdir / ("v" + name)
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE, root)
    path = root / "corpus/release-clock.py"
    code = path.read_text(encoding="utf-8")
    anchor_line = '            is_derived = values["note"].startswith("derived:")\n'
    assert anchor_line in code, "anchor line not found"
    helper_anchor = "def evaluate(sources, rows, captures=None, receipt_bundle=None):\n"
    assert helper_anchor in code, "evaluate() not found"
    code = code.replace(helper_anchor, ANCHOR_CHECK.lstrip("\n") + "\n\n" + helper_anchor, 1)
    code = code.replace(anchor_line, VARIANTS[name], 1)
    path.write_text(code, encoding="utf-8")
    return root


def build_fixture(variant_root, tag, edits, receipt_edits):
    """edits: {row_id: (anchored, observed, verdict)}; receipt_edits mirrors parsed/verdict."""
    root = variant_root.parent / ("fx-%s-%s" % (variant_root.name, tag))
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clock.py"):
        shutil.copy2(variant_root / "corpus" / rel, root / "corpus" / rel)
    lines = (variant_root / "corpus/release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields[0] in edits:
            anchored, observed, verdict = edits[fields[0]]
            fields[4], fields[5], fields[7] = anchored, observed, verdict
            line = "\t".join(fields) + "\n"
        out.append(line)
    (root / "corpus/release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    receipt_rel = ".ufo/waves/round-26/observe-2.json"
    receipt = json.loads((variant_root / receipt_rel).read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record["id"] in receipt_edits:
            record["parsed_version"], record["verdict"] = receipt_edits[record["id"]]
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()
    return root, receipt_path, sha


def run(root, receipt_path, sha):
    argv = ["python3", "-I", "-B", str(root / "corpus/release-clock.py"),
            "--root", str(root), "--receipt", str(receipt_path), "--receipt-sha", sha]
    proc = subprocess.run(argv, capture_output=True, text=True, timeout=120)
    return proc


def report(label, proc):
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    last = lines[-1] if lines else ""
    print("  %-10s exit=%d  findings=%s" % (label, proc.returncode, findings or "[]"))
    print("             last=%s" % last)
    if proc.stderr.strip():
        print("             stderr=%s" % proc.stderr.strip()[:200])


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    for name in VARIANTS:
        root = build_variant(name, WORK)
        print("== variant %s ==" % name)
        # control: unmodified tree, default command
        proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py"],
                              cwd=root, capture_output=True, text=True, timeout=120)
        report("control", proc)
        for gname, group in GROUPS.items():
            edits = {rid: (group["lower"], group["lower"], "not-fired")
                     for rid in group["rows"]}
            redits = {rid: (group["lower"], "not-fired") for rid in group["rows"]}
            fx, rpath, sha = build_fixture(root, gname, edits, redits)
            report(gname, run(fx, rpath, sha))
        # FIRED: SOPS feed advances; derived rows legitimately fire
        edits = {rid: (None, v, "fired") for rid, v in FIRED.items()}
        edits = {rid: ("3.13.3", v, "fired") for rid, v in FIRED.items()}
        redits = {rid: (v, "fired") for rid, v in FIRED.items()}
        fx, rpath, sha = build_fixture(root, "FIRED", edits, redits)
        report("FIRED", run(fx, rpath, sha))
        print()


if __name__ == "__main__":
    main()
