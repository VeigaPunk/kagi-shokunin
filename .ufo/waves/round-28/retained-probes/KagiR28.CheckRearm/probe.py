"""CheckRearm probe harness — offline probes of the derived rearm path at the
pinned candidate 62a33b1.  Builds tree variants from the exported candidate and
runs corpus/release-clock.py (verify path) with an explicit receipt copy.

No network.  No lane-checkout mutation.  Synthetic versions are used only to
exercise the machinery; no release is claimed.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCRATCH = Path(os.environ.get("PROBE_SCRATCH",
                           "/fast/scratch/hyaku/kagi-r28/KagiR28.CheckRearm"))
CAND = Path(os.environ.get("PROBE_TREE", str(SCRATCH / "cand"))).resolve()
HEADER = ["id", "clock", "feed_source_id", "feed_url", "anchored_version",
          "observed_version", "observed_at", "verdict", "note"]
DEFAULT_RECEIPT = CAND / ".ufo" / "waves" / "round-26" / "observe-2.json"


def read_tsv(root):
    lines = (root / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines()
    return [l.split("\t") for l in lines]


def write_tsv(root, rows):
    out = [root / "corpus" / "release-clocks.tsv"]
    out[0].write_text("\n".join("\t".join(f) for f in rows) + "\n", encoding="utf-8")


def set_row(root, row_id, **kw):
    rows = read_tsv(root)
    for fields in rows[1:]:
        if fields[0] == row_id:
            for key, value in kw.items():
                fields[HEADER.index(key)] = value
            break
    else:
        raise SystemExit("no row %s" % row_id)
    write_tsv(root, rows)


def add_row(root, row_id, clock, feed_source_id, feed_url, anchored, observed,
            observed_at, verdict, note):
    rows = read_tsv(root)
    rows.append([row_id, clock, feed_source_id, feed_url, anchored, observed,
                 observed_at, verdict, note])
    write_tsv(root, rows)


def set_source_anchor(root, source_id, anchor):
    path = root / "corpus" / "SOURCES.md"
    lines = path.read_text(encoding="utf-8").splitlines()
    for index, line in enumerate(lines):
        if line.startswith("| %s |" % source_id):
            cells = [c.strip() for c in line.strip()[1:].split("|")]
            if cells and not cells[-1]:
                cells.pop()
            cells[5] = anchor
            lines[index] = "| " + " | ".join(cells) + " |"
            break
    else:
        raise SystemExit("no source %s" % source_id)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def add_source(root, row):
    path = root / "corpus" / "SOURCES.md"
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    last = max(i for i, l in enumerate(lines) if l.startswith("| S0"))
    lines.insert(last + 1, "| " + " | ".join(row) + " |")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def make_receipt(root, name, updates):
    """Copy the retained default receipt, apply per-id field updates."""
    document = json.loads(DEFAULT_RECEIPT.read_text(encoding="utf-8"))
    by_id = {record["id"]: record for record in document["observations"]}
    for record_id, fields in updates.items():
        record = dict(by_id.get(record_id, {}))
        record.update(fields)
        by_id[record_id] = record
    document["observations"] = [by_id[k] for k in sorted(by_id)]
    path = root / (name + ".json")
    path.write_text(json.dumps(document, sort_keys=True, indent=1), encoding="utf-8")
    return path, hashlib.sha256(path.read_bytes()).hexdigest()


def run(name, tree, receipt):
    digest = hashlib.sha256(receipt.read_bytes()).hexdigest()
    proc = subprocess.run(
        [sys.executable, "-I", "-B", "corpus/release-clock.py", "--root", str(tree),
         "--receipt", str(receipt), "--receipt-sha", digest],
        cwd=str(CAND), capture_output=True, text=True)
    print("== %s" % name)
    print(proc.stdout.strip())
    if proc.stderr.strip():
        print("STDERR: %s" % proc.stderr.strip())
    print("EXIT=%d" % proc.returncode)
    print()
    return proc.returncode, proc.stdout


def fresh(name):
    tree = SCRATCH / ("p-" + name)
    if tree.exists():
        shutil.rmtree(tree)
    shutil.copytree(CAND, tree)
    return tree


def main():
    # P1 — derived rearm successor on the python.org group: the rearmed rows
    # S040/S041 are declared derived and stay bound to the successor feed row
    # S039; the old fired rows S027/S028 are retained.
    tree = fresh("p1")
    set_row(tree, "S040", note="derived: rearmed successor to S027, which remains fired at its original 3.15.0 anchor")
    set_row(tree, "S041", note="derived: rearmed successor to S028, which remains fired at its original 3.15.0 anchor")
    receipt, _ = make_receipt(tree, "receipt", {})
    run("P1 derived rearm successor (python.org), old fired rows retained", tree, receipt)

    # P2 — same, but the successor feed row's anchor cell also records the
    # retained historical version (the lane's own style in S039's teaches cell).
    tree = fresh("p2")
    set_row(tree, "S040", note="derived: rearmed successor to S027")
    set_row(tree, "S041", note="derived: rearmed successor to S028")
    set_source_anchor(tree, "S039",
                      "Python 3.15.1 item, pubDate Wed, 21 Oct 2026 09:59:50 +0000; "
                      "historical 3.15.0 item retained; fetched 2026-10-21")
    receipt, _ = make_receipt(tree, "receipt", {})
    run("P2 successor feed row anchor cell names two versions", tree, receipt)

    # P3 — round-26 successor shape applied to a derived group: a new feed
    # registry row naming the new release plus a successor clock row; the
    # predecessor derived rows are retained untouched.
    tree = fresh("p3")
    add_source(tree, [
        "S050", "SOPS upstream README, synthetic successor — https://raw.githubusercontent.com/getsops/sops/main/README.rst",
        "code", "C", "synthetic probe successor of S008", "no displayed version",
        "synthetic probe row", "mined", "2026-11-02", "on-release", "—"])
    add_source(tree, [
        "S051", "SOPS releases, synthetic successor feed row — https://github.com/getsops/sops/releases.atom",
        "code", "A", "SOPS release identity for the rearmed clock of S050",
        "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-11-02T00:00:00Z; feed fetched 2026-11-02",
        "synthetic probe row", "mined", "2026-11-02", "90d", "—"])
    add_row(tree, "S050", "feed", "S051", "https://github.com/getsops/sops/releases.atom",
            "3.14.0", "3.14.0", "2026-11-02", "not-fired",
            "derived: synthetic successor of S008")
    receipt, _ = make_receipt(tree, "receipt", {
        "S050": {"id": "S050", "clock": "feed", "url": "https://github.com/getsops/sops/releases.atom",
                 "verdict": "not-fired", "observed_at": "2026-11-02T00:00:00Z",
                 "parsed_version": "3.14.0", "located": None, "http_status": 200,
                 "sha256": "0" * 64}})
    run("P3 successor shape on a derived group (predecessors retained)", tree, receipt)

    # P4 — atomic in-place rearm of the derived group: every predecessor row
    # moves to the new version and repoints to the new feed row.
    tree = fresh("p4")
    add_source(tree, [
        "S051", "SOPS releases, synthetic successor feed row — https://github.com/getsops/sops/releases.atom",
        "code", "A", "SOPS release identity for the rearmed clocks of S008-S011",
        "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-11-02T00:00:00Z; feed fetched 2026-11-02",
        "synthetic probe row", "mined", "2026-11-02", "90d", "—"])
    for row_id in ("S008", "S009", "S010", "S011"):
        set_row(tree, row_id, feed_source_id="S051", anchored_version="3.14.0",
                observed_version="3.14.0", observed_at="2026-11-02", verdict="not-fired")
    receipt, _ = make_receipt(tree, "receipt", {
        row_id: {"id": row_id, "clock": "feed", "url": "https://github.com/getsops/sops/releases.atom",
                 "verdict": "not-fired", "observed_at": "2026-11-02T00:00:00Z",
                 "parsed_version": "3.14.0", "located": None, "http_status": 200,
                 "sha256": "0" * 64}
        for row_id in ("S008", "S009", "S010", "S011")})
    run("P4 atomic in-place rearm of the derived group", tree, receipt)

    # P5 — no rearm at all: the feed advanced (observed 3.14.0) but the derived
    # anchor stays at the old 3.13.3; the pinned registry row still names
    # 3.13.3, so the C2 binding is satisfied.
    tree = fresh("p5")
    for row_id in ("S008", "S009", "S010", "S011"):
        set_row(tree, row_id, observed_version="3.14.0", observed_at="2026-11-02",
                verdict="fired")
    receipt, _ = make_receipt(tree, "receipt", {
        row_id: {"id": row_id, "clock": "feed", "url": "https://github.com/getsops/sops/releases.atom",
                 "verdict": "fired", "observed_at": "2026-11-02T00:00:00Z",
                 "parsed_version": "3.14.0", "located": None, "http_status": 200,
                 "sha256": "0" * 64}
        for row_id in ("S008", "S009", "S010", "S011")})
    run("P5 derived anchor stale (feed advanced, no rearm)", tree, receipt)

    # P6 — same as P5 but the derived rows keep their old anchored_version and
    # are fired; the successor feed row raises the feed floor.
    tree = fresh("p6")
    add_source(tree, [
        "S051", "SOPS releases, synthetic successor feed row — https://github.com/getsops/sops/releases.atom",
        "code", "A", "SOPS release identity for the rearmed clocks of S008-S011",
        "Entry titled v3.14.0, tag link /releases/tag/v3.14.0, updated 2026-11-02T00:00:00Z; feed fetched 2026-11-02",
        "synthetic probe row", "mined", "2026-11-02", "90d", "—"])
    for row_id in ("S008", "S009", "S010", "S011"):
        set_row(tree, row_id, observed_version="3.14.0", observed_at="2026-11-02",
                verdict="fired")
    receipt, _ = make_receipt(tree, "receipt", {
        row_id: {"id": row_id, "clock": "feed", "url": "https://github.com/getsops/sops/releases.atom",
                 "verdict": "fired", "observed_at": "2026-11-02T00:00:00Z",
                 "parsed_version": "3.14.0", "located": None, "http_status": 200,
                 "sha256": "0" * 64}
        for row_id in ("S008", "S009", "S010", "S011")})
    run("P6 stale derived anchor + successor feed row present (floor 3.13.3)", tree, receipt)

    # P7 — python.org rearm with a successor feed row and a successor clock
    # row; the retained old fired rows (S027/S028) and the first rearmed
    # successors (S040/S041) are re-observed at the new newest release.
    tree = fresh("p7")
    add_source(tree, [
        "S052", "re whitespace teaching, synthetic successor — https://docs.python.org/3/library/re.html",
        "docs", "A", "synthetic probe successor of S040",
        "title Python 3.15.2 documentation, fetched 2026-11-02",
        "synthetic probe row", "mined", "2026-11-02", "on-release", "—"])
    add_source(tree, [
        "S053", "Python release feed, synthetic successor feed row — https://www.python.org/downloads/feed.rss",
        "docs", "A", "CPython stable release identity for the rearmed clock of S052",
        "Python 3.15.2 item, pubDate Sun, 02 Nov 2026 00:00:00 +0000; fetched 2026-11-02",
        "synthetic probe row", "mined", "2026-11-02", "90d", "—"])
    add_row(tree, "S052", "feed", "S053", "https://www.python.org/downloads/feed.rss",
            "3.15.2", "3.15.2", "2026-11-02", "not-fired",
            "rearmed successor to S040, which remains fired at its original 3.15.0 anchor")
    for row_id in ("S027", "S028", "S040", "S041"):
        set_row(tree, row_id, observed_version="3.15.2", observed_at="2026-11-02",
                verdict="fired")
    receipt, _ = make_receipt(tree, "receipt", {
        "S052": {"id": "S052", "clock": "feed", "url": "https://www.python.org/downloads/feed.rss",
                 "verdict": "not-fired", "observed_at": "2026-11-02T00:00:00Z",
                 "parsed_version": "3.15.2", "located": None, "http_status": 200,
                 "sha256": "0" * 64},
        **{row_id: {"id": row_id, "clock": "feed", "url": "https://www.python.org/downloads/feed.rss",
                    "verdict": "fired", "observed_at": "2026-11-02T00:00:00Z",
                    "parsed_version": "3.15.2", "located": None, "http_status": 200,
                    "sha256": "0" * 64} for row_id in ("S027", "S028", "S040", "S041")}})
    run("P7 python.org rearm, retained old fired rows re-observed", tree, receipt)

    # P8 — same successor, but the retained rows keep their old receipts.
    tree = fresh("p8")
    add_source(tree, [
        "S052", "re whitespace teaching, synthetic successor — https://docs.python.org/3/library/re.html",
        "docs", "A", "synthetic probe successor of S040",
        "title Python 3.15.2 documentation, fetched 2026-11-02",
        "synthetic probe row", "mined", "2026-11-02", "on-release", "—"])
    add_source(tree, [
        "S053", "Python release feed, synthetic successor feed row — https://www.python.org/downloads/feed.rss",
        "docs", "A", "CPython stable release identity for the rearmed clock of S052",
        "Python 3.15.2 item, pubDate Sun, 02 Nov 2026 00:00:00 +0000; fetched 2026-11-02",
        "synthetic probe row", "mined", "2026-11-02", "90d", "—"])
    add_row(tree, "S052", "feed", "S053", "https://www.python.org/downloads/feed.rss",
            "3.15.2", "3.15.2", "2026-11-02", "not-fired",
            "rearmed successor to S040, which remains fired at its original 3.15.0 anchor")
    receipt, _ = make_receipt(tree, "receipt", {
        "S052": {"id": "S052", "clock": "feed", "url": "https://www.python.org/downloads/feed.rss",
                 "verdict": "not-fired", "observed_at": "2026-11-02T00:00:00Z",
                 "parsed_version": "3.15.2", "located": None, "http_status": 200,
                 "sha256": "0" * 64}})
    run("P8 python.org rearm, retained rows keep their old receipts", tree, receipt)

    # P9 — a derived row whose feed_source_id points at a non-feed registry row:
    # does the candidate add a second, unrelated typed finding to the row?
    tree = fresh("p9")
    set_row(tree, "S029", feed_source_id="S030")
    receipt, _ = make_receipt(tree, "receipt", {})
    run("P9 derived row repointed at a non-feed registry row", tree, receipt)


if __name__ == "__main__":
    main()
