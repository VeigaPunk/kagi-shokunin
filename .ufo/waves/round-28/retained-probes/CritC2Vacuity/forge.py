#!/usr/bin/env python3
"""CritC2Vacuity: forgeries against the round-28 C2 derived-anchor binding.

Runs only inside this sandbox against the BASE tree extracted beside it.
Every fixture is a copy of BASE corpus/ with named edits; each is evaluated by
BASE's own release-clock.py (subprocess, exit + last line) and then by overlay
rules (in-process, BASE's evaluate() plus the extra rule's findings):

  NAMED  derived anchored must be named by the feed row's anchor cell
         (version_is_named, the idiom BASE already uses at line 566)
  EXACT  the feed row's anchor cell must name exactly one version, = anchored
  COH    rows sharing a feed_url must record one observation (parsed_version, sha256)
  BODY   every feed receipt's sha256 must resolve to a retained body whose
         parse_latest_version() equals parsed_version, and a derived anchor must
         equal parse_latest_version() of the feed row's capture body (source-fetches.tsv col 10)
  SERVES a derived row's id must be listed in its feed row's scope cell
"""
import hashlib
import importlib.util
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "base"
WORK = HERE / "fixtures"
spec = importlib.util.spec_from_file_location("clock", BASE / "corpus/release-clock.py")
clock = importlib.util.module_from_spec(spec)
spec.loader.exec_module(clock)

BODIES = {}
for path in (BASE / ".ufo/waves").glob("round-2[5-7]/**/*"):
    if path.is_file() and "sandboxes/KagiR" not in str(path) and path.stat().st_size <= clock.MAX_BODY_BYTES:
        BODIES.setdefault(hashlib.sha256(path.read_bytes()).hexdigest(), path)

SOPS = ["S008", "S009", "S010", "S011"]
VAULT = ["S013", "S022", "S023", "S024"]
BAO = ["S014", "S015", "S016", "S021", "S025", "S026"]
CURL = ["S029"]


def lower(ids, version):
    return {i: {"anchored_version": version, "observed_version": version, "verdict": "not-fired"} for i in ids}


def anchor_sub(sid, old, new):
    return [(sid, "anchor", old, new)]


FIX = {
    "control": ({}, []),
    "G1-sops": (lower(SOPS, "3.13.2"), []),
    "G2-vault": (lower(VAULT, "2.1.0"), []),
    "G3-openbao": (lower(BAO, "2.7.0"), []),
    "G4-curl": (lower(CURL, "8.22.0"), []),
    "B1-sops+SOURCES": (lower(SOPS, "3.13.2"), anchor_sub("S033", "3.13.3", "3.13.2")),
    "B2-vault+SOURCES": (lower(VAULT, "2.1.0"), anchor_sub("S034", "2.2.0", "2.1.0")),
    "B3-openbao+SOURCES": (lower(BAO, "2.7.0"), anchor_sub("S035", "2.7.1", "2.7.0")),
    "B4-curl+SOURCES": (lower(CURL, "8.22.0"), anchor_sub("S037", "8.23.0", "8.22.0")),
    "M2-vault+anchor-append": (lower(VAULT, "2.1.0"),
                               [("S034", "anchor_append", None, "; prior stable v2.1.0")]),
    "R1-vault-repointed-to-curl": ({i: {"feed_source_id": "S037", "feed_url": "https://curl.se/info",
                                        "anchored_version": "8.23.0", "observed_version": "8.23.0",
                                        "verdict": "not-fired", "_body_from": "S029"} for i in VAULT}, []),
    "R2-python-stale-sibling": ({i: {"feed_source_id": "S036", "anchored_version": "3.15.0",
                                     "observed_version": "3.15.0", "verdict": "not-fired",
                                     "note": "derived: newest stable CPython when opened"} for i in ("S040", "S041")}, []),
    "A1-sops-appended-feed-row": ({i: dict(lower([i], "3.13.2")[i], feed_source_id="S044") for i in SOPS},
                                  [("S044", "clone_of", "S033", ("3.13.3", "3.13.2"))]),
}


def build(name, row_edits, src_edits):
    root = WORK / name
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(BASE / "corpus", root / "corpus")
    tsv = root / "corpus/release-clocks.tsv"
    lines = tsv.read_text().splitlines(keepends=True)
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] in row_edits:
            for key, value in row_edits[fields[0]].items():
                if not key.startswith("_"):
                    fields[clock.HEADER.index(key)] = value
            lines[index] = "\t".join(fields) + "\n"
    tsv.write_text("".join(lines))
    src = root / "corpus/SOURCES.md"
    text = src.read_text().splitlines(keepends=True)
    for sid, op, old, new in src_edits:
        for index, line in enumerate(text):
            if op == "clone_of" and line.startswith("| %s |" % old):
                cells = line.split(" | ")
                cells[0] = "| " + sid
                cells[5] = cells[5].replace(*new)
                cells[6] = cells[6].replace(*new)
                text.insert(index + 1, " | ".join(cells))
                break
            if line.startswith("| %s |" % sid):
                cells = line.split(" | ")
                if op == "anchor":
                    cells[5] = cells[5].replace(old, new)
                else:
                    cells[5] = cells[5] + new
                text[index] = " | ".join(cells)
    src.write_text("".join(text))
    receipt = json.loads((BASE / ".ufo/waves/round-26/observe-2.json").read_text())
    by_id = {r["id"]: r for r in receipt["observations"]}
    for record in receipt["observations"]:
        edit = row_edits.get(record["id"])
        if edit:
            record["parsed_version"] = edit["observed_version"]
            record["verdict"] = edit["verdict"]
            if "feed_url" in edit:
                record["url"] = edit["feed_url"]
            if "_body_from" in edit:
                record["sha256"] = by_id[edit["_body_from"]]["sha256"]
    rpath = root / "receipt.json"
    rpath.write_text(json.dumps(receipt, indent=2) + "\n")
    return root, rpath, hashlib.sha256(rpath.read_bytes()).hexdigest()


def versions_in(text):
    return {clock.norm_version(m.group(1)) for m in clock.VERSION_RE.finditer(text)}


def scope_ids(scope):
    ids = set()
    for a, b in re.findall(r"S([0-9]{3})(?:-S([0-9]{3}))?", scope):
        ids.update("S%03d" % n for n in range(int(a), int(b or a) + 1))
    return ids


def extra(rule, root, sources, rows, receipts):
    found = set()
    captures_body = {}
    for line in (root / "corpus/source-fetches.tsv").read_text().splitlines():
        f = line.split("\t")
        if len(f) == 16 and not line.startswith("#"):
            captures_body[f[0]] = f[9]
    scope_cells = {}
    for line in (root / "corpus/SOURCES.md").read_text().splitlines():
        cells = [c.strip() for c in line.strip()[1:].split("|")]
        if cells and clock.SOURCE_ID_RE.fullmatch(cells[0]):
            scope_cells[cells[0]] = cells[4]
    by_feed = {}
    for row in rows:
        v = dict(zip(clock.HEADER, row["fields"]))
        if v["clock"] != "feed":
            continue
        rec = receipts["records"].get(v["id"], {})
        by_feed.setdefault(v["feed_url"], set()).add((rec.get("parsed_version"), rec.get("sha256")))
        derived = v["note"].startswith("derived:")
        feed = sources.get(v["feed_source_id"])
        if rule == "BODY":
            body = BODIES.get(rec.get("sha256"))
            if body is None or clock.parse_latest_version(body.read_bytes()) != clock.norm_version(rec.get("parsed_version", "")):
                found.add(("BODY-MISMATCH", v["id"]))
        if not derived or feed is None:
            continue
        if rule == "NAMED" and not clock.version_is_named(feed["anchor"], v["anchored_version"]):
            found.add(("DERIVATION", v["id"]))
        if rule == "EXACT" and versions_in(feed["anchor"]) != {clock.norm_version(v["anchored_version"])}:
            found.add(("DERIVATION", v["id"]))
        if rule == "BODY":
            body = BODIES.get(captures_body.get(v["feed_source_id"]))
            if body is None or clock.parse_latest_version(body.read_bytes()) != clock.norm_version(v["anchored_version"]):
                found.add(("DERIVATION", v["id"]))
        if rule == "SERVES" and v["id"] not in scope_ids(scope_cells.get(v["feed_source_id"], "")):
            found.add(("NOT-SERVED", v["id"]))
    if rule == "COH":
        for row in rows:
            v = dict(zip(clock.HEADER, row["fields"]))
            if v["clock"] == "feed" and len(by_feed[v["feed_url"]]) > 1:
                found.add(("FEED-INCOHERENT", v["id"]))
    return found


def main():
    WORK.mkdir(exist_ok=True)
    out = {"bodies_indexed": len(BODIES)}
    for name, (row_edits, src_edits) in FIX.items():
        root, rpath, sha = build(name, row_edits, src_edits)
        proc = subprocess.run(["python3", "-I", "-B", str(BASE / "corpus/release-clock.py"), "--root", str(root),
                               "--receipt", str(rpath), "--receipt-sha", sha], capture_output=True, text=True)
        lines = [l for l in proc.stdout.splitlines() if l.strip()]
        sources = clock.parse_sources(root)
        rows = clock.parse_bindings(root)
        receipts = clock.load_receipt_bundle(rpath, sha)
        base = clock.evaluate(sources, rows, clock.parse_captures(root), receipts)
        res = {"base_exit": proc.returncode, "base_last": lines[-1] if lines else "",
               "base_findings": lines[:-1], "traceback": "Traceback" in proc.stderr}
        for rule in ("NAMED", "EXACT", "COH", "BODY", "SERVES"):
            errs = sorted(set(base["errors"]) | extra(rule, root, sources, rows, receipts))
            res[rule] = "CLEAN" if not errs and base["passed"] else "FAILED " + " ".join("%s:%s" % e for e in errs)
        cen = subprocess.run(["bash", str(BASE / "corpus/sources-census.sh"), "verify", "--root", str(root)],
                             capture_output=True, text=True)
        res["census"] = "%d %s" % (cen.returncode, ([l for l in cen.stdout.splitlines() if l.strip()] or [""])[-1])
        res["census_findings"] = [l for l in cen.stdout.splitlines() if l.startswith("FINDING")][:6]
        out[name] = res
        print("%-28s base=%d %-10s NAMED=%-8s EXACT=%-8s COH=%-8s BODY=%-8s SERVES=%-8s census=%s" % (
            name, proc.returncode, "CLEAN" if "CLEAN" in res["base_last"] else "FAILED",
            res["NAMED"].split()[0], res["EXACT"].split()[0], res["COH"].split()[0],
            res["BODY"].split()[0], res["SERVES"].split()[0], res["census"][:60]))
    (HERE / "forge-results.json").write_text(json.dumps(out, indent=2) + "\n")


if __name__ == "__main__":
    sys.exit(main())
