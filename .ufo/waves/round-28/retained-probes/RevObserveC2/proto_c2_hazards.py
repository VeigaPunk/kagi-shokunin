#!/usr/bin/env python3
"""Second C2 experiment set: three sharper hazards for the derived-anchor rule.

E  token set taken from the feed row's WHOLE row (anchor+teaches+scope) instead
   of the anchor cell only -> a forged anchor that IS named in the teaches cell
   (S034 teaches names sdk/v0.26.0) is accepted.
F  the "feed row" resolved as the NEWEST registry row for the same feed URL
   instead of the row named by feed_source_id -> a legitimately fired derived
   row is flagged once a new feed registry row exists (the S036->S039 rearm
   shape).
R  the feed registry row's located-anchor cell rewritten IN PLACE -> the old
   (legitimately fired) derived rows are flagged.
"""
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
BASE = SANDBOX / "base"
WORK = SANDBOX / "work2"

HELPERS = '''
def _version_tokens(text):
    out = set()
    for match in re.finditer(r"(?<![0-9A-Za-z.])v?([0-9]+\\.[0-9]+\\.[0-9]+)(?![0-9A-Za-z.])",
                             text or ""):
        token = match.group(1)
        if not re.search(r"(^|\\.)0[0-9]", token):
            out.add(token)
    return out


def feed_anchor_versions(feed_source, sources, feed_url):
    """Variants of 'the version named by the feed row's located anchor'."""
    return _version_tokens(feed_source["anchor"])


def feed_whole_row_versions(feed_source):
    return _version_tokens(" | ".join([feed_source["anchor"], feed_source["teaches"]]))


def feed_newest_row_versions(feed_source, sources):
    """The newest registry row for the same feed URL (by opened date then id)."""
    same = [s for s in sources.values() if s["url"] == feed_source["url"]]
    if not same:
        return set()
    same.sort(key=lambda s: (s["opened"], s["id"]))
    return _version_tokens(same[-1]["anchor"])
'''

PATCH_E = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = feed_whole_row_versions(feed_source)
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

PATCH_F = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = feed_newest_row_versions(feed_source, sources)
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

PATCH_R = '''
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if is_derived and feed_source is not None:
                av = feed_anchor_versions(feed_source, sources, feed_url)
                if av and norm_version(values["anchored_version"]) not in av:
                    errors.add(("DERIVED-ANCHOR", source_id))
                    row_valid = False
'''

VARIANTS = {"E": PATCH_E, "F": PATCH_F, "R": PATCH_R}


def build_variant(name):
    root = WORK / ("v" + name)
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE, root)
    path = root / "corpus/release-clock.py"
    code = path.read_text(encoding="utf-8")
    helper_anchor = "def evaluate(sources, rows, captures=None, receipt_bundle=None):\n"
    code = code.replace(helper_anchor, HELPERS.lstrip("\n") + "\n\n" + helper_anchor, 1)
    anchor_line = '            is_derived = values["note"].startswith("derived:")\n'
    code = code.replace(anchor_line, VARIANTS[name], 1)
    path.write_text(code, encoding="utf-8")
    return root


def build_fixture(variant_root, tag, table_edits, receipt_edits, sources_edits=None):
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
        if fields[0] in table_edits:
            anchored, observed, verdict = table_edits[fields[0]]
            fields[4], fields[5], fields[7] = anchored, observed, verdict
            line = "\t".join(fields) + "\n"
        out.append(line)
    (root / "corpus/release-clocks.tsv").write_text("".join(out), encoding="utf-8")
    if sources_edits:
        text = (root / "corpus/SOURCES.md").read_text(encoding="utf-8")
        for old, new in sources_edits:
            assert old in text, old
            text = text.replace(old, new, 1)
        (root / "corpus/SOURCES.md").write_text(text, encoding="utf-8")
    receipt = json.loads((variant_root / ".ufo/waves/round-26/observe-2.json")
                         .read_text(encoding="utf-8"))
    for record in receipt["observations"]:
        if record["id"] in receipt_edits:
            record["parsed_version"], record["verdict"] = receipt_edits[record["id"]]
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()
    return root, receipt_path, sha


def run(root, receipt_path, sha):
    return subprocess.run(
        ["python3", "-I", "-B", str(root / "corpus/release-clock.py"),
         "--root", str(root), "--receipt", str(receipt_path), "--receipt-sha", sha],
        capture_output=True, text=True, timeout=120)


def report(label, proc):
    lines = [l for l in proc.stdout.splitlines() if l.strip()]
    findings = [l for l in lines if not l.startswith("RELEASE_CLOCK:")]
    print("  %-22s exit=%d findings=%s" % (label, proc.returncode, findings or "[]"))
    if proc.stderr.strip():
        print("      stderr: %s" % proc.stderr.strip()[:300])


def main():
    if WORK.exists():
        shutil.rmtree(WORK)
    WORK.mkdir(parents=True)
    fired = {"S008": "3.14.0", "S009": "3.14.0", "S010": "3.14.0", "S011": "3.14.0"}
    fired_table = {rid: ("3.13.3", v, "fired") for rid, v in fired.items()}
    fired_receipt = {rid: (v, "fired") for rid, v in fired.items()}

    # E: forged anchor 0.26.0 -- named in S034's TEACHES cell ("sdk/v0.26.0")
    e_forge = {"S013": ("0.26.0", "0.26.0", "not-fired")}
    e_receipt = {"S013": ("0.26.0", "not-fired")}
    # E2: forged anchor 8.23.1 -- named in S037's TEACHES cell (curl's dev label);
    #     numerically NEWER than the feed floor 8.23.0, so REGRESSED cannot see it
    e2_forge = {"S029": ("8.23.1", "8.23.1", "not-fired")}
    e2_receipt = {"S029": ("8.23.1", "not-fired")}

    # F: a new SOPS feed registry row (the S036->S039 rearm shape) while the
    #    derived rows still name S033 and legitimately fire
    new_row = ("| S044 | SOPS releases, GitHub release Atom feed (round-28) — "
               "https://github.com/getsops/sops/releases.atom | code | A | SOPS "
               "release identity at the round-28 fetch | Entry titled v3.14.0, tag "
               "link /releases/tag/v3.14.0, updated 2026-10-25T00:00:00Z; feed "
               "fetched 2026-10-25 | supersedes S033 — newest stable SOPS is "
               "v3.14.0. Quote: “<title>v3.14.0</title>”. | mined | 2026-10-25 | "
               "90d | — |")  # 11 fields: id|source|kind|tier|scope|anchor|teaches|status|opened|recheck|used-by

    for name in VARIANTS:
        root = build_variant(name)
        print("== variant %s ==" % name)
        proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py"],
                              cwd=root, capture_output=True, text=True, timeout=120)
        report("control", proc)
        if name == "E":
            fx, rp, sha = build_fixture(root, "forge", e_forge, e_receipt)
            report("forged 0.26.0 anchor", run(fx, rp, sha))
            fx, rp, sha = build_fixture(root, "forge2", e2_forge, e2_receipt)
            report("forged 8.23.1 anchor", run(fx, rp, sha))
        if name in ("F", "R"):
            fx, rp, sha = build_fixture(root, "FIRED", fired_table, fired_receipt)
            report("fired, no new feed row", run(fx, rp, sha))
        if name == "F":
            fx, rp, sha = build_fixture(root, "FIRED+newrow", fired_table,
                                        fired_receipt,
                                        sources_edits=[("\n\n## Paths", "\n" + new_row + "\n\n## Paths")])
            report("fired + new feed row", run(fx, rp, sha))
        if name == "R":
            fx, rp, sha = build_fixture(root, "FIRED+rewrite", fired_table,
                                        fired_receipt,
                                        sources_edits=[("Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z",
                                                        "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-10-25T00:00:00Z")])
            report("fired + anchor rewritten", run(fx, rp, sha))
        print()


if __name__ == "__main__":
    main()
