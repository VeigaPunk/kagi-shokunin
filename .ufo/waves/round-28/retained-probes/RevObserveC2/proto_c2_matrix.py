#!/usr/bin/env python3
"""Which C2 rule variants satisfy the plan's FROZEN predicate?

Frozen predicate (plans/round-28.md C2):
  ACCEPTED when exit 0 and "RELEASE_CLOCK: CLEAN"
  EXACT    when exit 1 and the typed derivation findings name exactly that
           group's row ids
  control default CLEAN30 exit 0 at both

Variants (all bind a derived row's anchor to a token set, differing in WHICH
token set and WHICH field):
  A  anchor cell of the row's OWN feed_source_id registry row   (correct)
  B  the row's OBSERVED version, same token set                  (wrong: fires)
  C  anchor cell of the row's OWN registry row (not the feed's)  (wrong: S029)
  D  every feed row, not just derived ones                       (wrong: S012)
  E  whole registry row (anchor + teaches)                        (weak: 8.23.1)
  F  newest registry row for the same feed URL                    (wrong: fires)

For each: the 4 frozen groups (EXACT?), the control (CLEAN?), and two
counterexamples the frozen predicate does NOT cover:
  FIRED  a legitimately fired derived row (feed advanced to 3.14.0)
  CURL   a derived anchor forged to 8.23.1 (curl's UNRELEASED dev label)
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
BASE = SANDBOX / "base"
WORK = SANDBOX / "work5"

HELPER = '''
def _ver_tokens(text, whole_row=False):
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
    "A": (BODY % '''av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False'''),
    "B": (BODY % '''av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["observed_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False'''),
    "C": (BODY % '''av = _ver_tokens(sources[source_id]["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False'''),
    "D": (BODY % '''av = _ver_tokens(feed_source["anchor"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False''').replace(
        "            if is_derived and feed_source is not None:",
        "            if feed_source is not None:"),
    "E": (BODY % '''av = _ver_tokens(feed_source["anchor"] + " | " + feed_source["teaches"])
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False'''),
    "F": (BODY % '''same = [s for s in sources.values() if s["url"] == feed_source["url"]]
                same.sort(key=lambda s: (s["opened"], s["id"]))
                av = _ver_tokens(same[-1]["anchor"]) if same else set()
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False'''),
}

GROUPS = {
    "G1": (["S008", "S009", "S010", "S011"], "3.13.2"),
    "G2": (["S013", "S022", "S023", "S024"], "2.1.9"),
    "G3": (["S014", "S015", "S016", "S021", "S025", "S026"], "2.7.0"),
    "G4": (["S029"], "8.22.0"),
}

SOPS_ATOM = b"""<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry><title>v3.14.0</title>
  <link href="https://github.com/getsops/sops/releases/tag/v3.14.0"/>
  <updated>2026-10-25T00:00:00Z</updated></entry>
  <entry><title>v3.13.3</title>
  <link href="https://github.com/getsops/sops/releases/tag/v3.13.3"/>
  <updated>2026-07-23T05:29:11Z</updated></entry>
</feed>
"""


def build(name):
    root = WORK / ("v" + name)
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE, root)
    path = root / "corpus/release-clock.py"
    code = path.read_text(encoding="utf-8")
    code = code.replace("def evaluate(sources, rows, captures=None, receipt_bundle=None):\n",
                        HELPER.lstrip("\n") + "\n\ndef evaluate(sources, rows, captures=None, receipt_bundle=None):\n", 1)
    anchor_line = '            is_derived = values["note"].startswith("derived:")\n'
    code = code.replace(anchor_line, VARIANTS[name], 1)
    path.write_text(code, encoding="utf-8")
    return root


def fixture(vroot, tag, table_edits, receipt_edits, sources_edits=None):
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
    if sources_edits:
        text = (root / "corpus/SOURCES.md").read_text(encoding="utf-8")
        for old, new in sources_edits:
            assert old in text, old
            text = text.replace(old, new, 1)
        (root / "corpus/SOURCES.md").write_text(text, encoding="utf-8")
    receipt = json.loads((vroot / ".ufo/waves/round-26/observe-2.json").read_text())
    for rec in receipt["observations"]:
        if rec["id"] in receipt_edits:
            rec["parsed_version"], rec["verdict"] = receipt_edits[rec["id"]]
    rp = root / "receipt.json"
    rp.write_text(json.dumps(receipt, indent=2) + "\n")
    sha = hashlib.sha256(rp.read_bytes()).hexdigest()
    return root, rp, sha


def run(root, rp, sha):
    return subprocess.run(
        ["python3", "-I", "-B", str(root / "corpus/release-clock.py"), "--root", str(root),
         "--receipt", str(rp), "--receipt-sha", sha],
        capture_output=True, text=True, timeout=120)


def outcome(proc):
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    last = lines[-1] if lines else ""
    ids = sorted({m for l in findings for m in re.findall(r"S[0-9]{3}", l)})
    return proc.returncode, last, findings, ids


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    for name in VARIANTS:
        root = build(name)
        print("=== variant %s ===" % name)
        # control
        proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py"],
                              cwd=root, capture_output=True, text=True, timeout=120)
        rc, last, fnd, ids = outcome(proc)
        print("  control      exit=%d clean=%s findings=%s" % (rc, last.startswith("RELEASE_CLOCK: CLEAN"), fnd or "[]"))
        # frozen groups
        for gname, (rows, lower) in GROUPS.items():
            te = {r: (lower, lower, "not-fired") for r in rows}
            re_ = {r: (lower, "not-fired") for r in rows}
            fx, rp, sha = fixture(root, gname, te, re_)
            rc, last, fnd, ids = outcome(run(fx, rp, sha))
            exact = (rc == 1 and ids == sorted(rows) and all(
                f.split()[0] not in ("ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED",
                                     "REGRESSED", "NOT", "RECEIPT-MISMATCH")
                for f in fnd))
            print("  %-12s exit=%d EXACT=%s ids=%s" % (gname, rc, exact, ids))
        # counterexample 1: FIRED derived row (real --observe path)
        import importlib.util
        spec = importlib.util.spec_from_file_location("rc_" + name, root / "corpus/release-clock.py")
        rcmod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(rcmod)
        sources = rcmod.parse_sources(root)
        trows = rcmod.parse_bindings(root)
        captures = rcmod.parse_captures(root)
        real_req, real_utc = rcmod.request_body, rcmod.utc_timestamp
        rcmod.request_body = lambda url, opener=None, resolver=None: (
            (200, SOPS_ATOM, None) if "getsops" in url
            else real_req(url, opener=opener, resolver=resolver))
        rcmod.utc_timestamp = lambda: "2026-10-21T13:43:21Z"
        outp = root / "observe.json"
        if outp.exists():
            outp.unlink()
        try:
            rcmod.run_observe(root, sources, trows, outp, captures)
        finally:
            rcmod.request_body, rcmod.utc_timestamp = real_req, real_utc
        bundle = rcmod.load_receipt_bundle(outp)
        # re-verify the table to match the receipt (anchor unchanged, observation moved)
        te = {r: ("3.13.3", "3.14.0", "fired") for r in ("S008", "S009", "S010", "S011")}
        tsv = root / "corpus/release-clocks.tsv"
        lines = tsv.read_text(encoding="utf-8").splitlines(keepends=True)
        out = []
        for line in lines:
            f = line.rstrip("\n").split("\t")
            if f[0] in te:
                a, o, v = te[f[0]]
                f[4], f[5], f[7] = a, o, v
                line = "\t".join(f) + "\n"
            out.append(line)
        tsv.write_text("".join(out), encoding="utf-8")
        result = rcmod.evaluate(rcmod.parse_sources(root), rcmod.parse_bindings(root),
                                rcmod.parse_captures(root), bundle)
        der = [e for e in result["errors"] if e[0] == "DERIVED-ANCHOR"]
        print("  FIRED (legit) DERIVED-ANCHOR findings=%s  passed=%s" % (der, result["passed"]))
        # counterexample 2: CURL -- derived anchor forged to curl's unreleased 8.23.1
        te2 = {"S029": ("8.23.1", "8.23.1", "not-fired")}
        re2 = {"S029": ("8.23.1", "not-fired")}
        fx, rp, sha = fixture(root, "CURL", te2, re2)
        rc, last, fnd, ids = outcome(run(fx, rp, sha))
        print("  CURL forge   exit=%d findings=%s" % (rc, fnd or "[]"))
        print()


if __name__ == "__main__":
    main()
