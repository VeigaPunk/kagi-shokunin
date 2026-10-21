#!/usr/bin/env python3
"""Isolated verification of the two decisive counterexamples (no cross-fixture
contamination), plus the live-vs-registry distinction.

CE1  a derived row forged to curl's UNRELEASED dev label 8.23.1
     (S037's own teaches cell says: "S029's anchor names 8.23.1, which is
     curl's unreleased development label, so its clock anchors on the
     released 8.23.0").  8.23.1 > 8.23.0, so REGRESSED cannot see it.
     A whole-registry-row scan (E) accepts it; an anchor-cell scan (A) refuses.
CE2  a legitimately FIRED derived row (SOPS feed advanced to 3.14.0, anchor
     unchanged at 3.13.3).  The observation-binding variant (B) refuses it.
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
BASE = SANDBOX / "base"
WORK = SANDBOX / "work7"

HELPER = '''
def _ver_tokens(text):
    out = set()
    for m in re.finditer(r"(?<![0-9A-Za-z.])v?([0-9]+\\.[0-9]+\\.[0-9]+)(?![0-9A-Za-z.])",
                         text or ""):
        t = m.group(1)
        if not re.search(r"(^|\\.)0[0-9]", t):
            out.add(t)
    return out
'''

BODY = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                %s
'''

VARIANTS = {
    "A_anchorcell": BODY % '''av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False''',
    "B_observation": BODY % '''av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["observed_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False''',
    "E_wholerow": BODY % '''av = _ver_tokens(feed_source["anchor"] + " | " + feed_source["teaches"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False''',
}


def build(name):
    root = WORK / ("v" + name)
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE, root)
    path = root / "corpus/release-clock.py"
    code = path.read_text(encoding="utf-8")
    code = code.replace("def evaluate(sources, rows, captures=None, receipt_bundle=None):\n",
                        HELPER.lstrip("\n") + "\n\ndef evaluate(sources, rows, captures=None, receipt_bundle=None):\n", 1)
    code = code.replace('            is_derived = values["note"].startswith("derived:")\n',
                        VARIANTS[name], 1)
    path.write_text(code, encoding="utf-8")
    return root


def fixture(vroot, tag, table_edits, receipt_edits):
    root = WORK / ("fx-%s-%s" % (vroot.name, tag))
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
                "release-clock.py"):
        shutil.copy2(vroot / "corpus" / rel, root / "corpus" / rel)
    lines = (vroot / "corpus/release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f[0] in table_edits:
            a, o, v = table_edits[f[0]]
            f[4], f[5], f[7] = a, o, v
            line = "\t".join(f) + "\n"
        out.append(line)
    (root / "corpus/release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    receipt = json.loads((vroot / ".ufo/waves/round-26/observe-2.json").read_text())
    for rec in receipt["observations"]:
        if rec["id"] in receipt_edits:
            rec["parsed_version"], rec["verdict"] = receipt_edits[rec["id"]]
    rp = root / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    return root, rp, sha


def outcome(proc):
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    last = lines[-1] if lines else ""
    return proc.returncode, last, findings


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    for name in VARIANTS:
        root = build(name)
        print("=== %s ===" % name)
        # CE1: isolated -- only S029 is touched, receipt mirrored for S029 only
        fx, rp, sha = fixture(root, "CE1",
                              {"S029": ("8.23.1", "8.23.1", "not-fired")},
                              {"S029": ("8.23.1", "not-fired")})
        rc, last, fnd = outcome(subprocess.run(
            ["python3", "-I", "-B", str(fx / "corpus/release-clock.py"), "--root", str(fx),
             "--receipt", str(rp), "--receipt-sha", sha], capture_output=True, text=True, timeout=120))
        print("  CE1 forged 8.23.1: exit=%d clean=%s findings=%s" % (
            rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))
        # CE2: isolated -- control tree with only the four SOPS rows re-verified
        fx2, rp2, sha2 = fixture(root, "CE2",
                                 {r: ("3.13.3", "3.14.0", "fired")
                                  for r in ("S008", "S009", "S010", "S011")},
                                 {r: ("3.14.0", "fired")
                                  for r in ("S008", "S009", "S010", "S011")})
        rc, last, fnd = outcome(subprocess.run(
            ["python3", "-I", "-B", str(fx2 / "corpus/release-clock.py"), "--root", str(fx2),
             "--receipt", str(rp2), "--receipt-sha", sha2], capture_output=True, text=True, timeout=120))
        print("  CE2 fired derived rows: exit=%d clean=%s findings=%s" % (
            rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))
        print()


if __name__ == "__main__":
    main()
