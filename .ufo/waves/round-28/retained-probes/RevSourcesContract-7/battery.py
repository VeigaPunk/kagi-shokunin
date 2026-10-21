#!/usr/bin/env python3
"""Round-28 reviewer battery: what a new SOURCES.md row / used-by change trips.

Read-only against BASE; all mutations happen in copies under this sandbox.
"""
import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path

BASE = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/RevSourcesContract-7/base")
WORK = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/RevSourcesContract-7/work")
FLEET = "/home/vgpnk/Projects/shokunin/scripts/sources-census.sh"

S042_SCOPE = ("Precedence of strict MAJOR.MINOR.PATCH version cores: numeric, "
              "left-to-right comparison; prerelease/build suffixes excluded from the core")

NEW_ROW_SEMVER = (
    "| S044 | Semantic Versioning 2.0.0 — https://semver.org/spec/v2.0.0.html | spec | A | "
    "{scope} | §1 MAJOR.MINOR.PATCH, spec item 1 (leading zeroes) | "
    "{teaches} | mined | 2026-10-21 | 180d | {usedby} |"
)

NEW_ROW_PY = (
    "| S045 | set_int_max_str_digits — https://docs.python.org/3/library/sys.html | docs | A | "
    "CPython integer-string conversion limit for decimal int() conversion | "
    "sys.set_int_max_str_digits() (int_max_str_digits), default 4300 | "
    "CPython refuses int(str) conversions longer than the limit; the clock must type an "
    "oversize version component instead of raising. Quote: “the limit is 4300 digits” | "
    "mined | 2026-10-21 | 90d | corpus/lessons/round-28.md |"
)

LESSON = """source: S042, S043, S044, S045
verified-at: 2026-10-21
recheck: 180d

# Round 28 lesson (battery fixture)

Mentions S042 S043 S044 S045.
"""


def row_identity(row_id, status, url):
    return hashlib.sha256(("%s\t%s\t%s\n" % (row_id, status, url)).encode()).hexdigest()


def insert_after_registry(text, row):
    lines = text.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if line.startswith("| S043 "):
            lines.insert(index + 1, row + "\n")
            break
    else:
        raise SystemExit("S043 row not found")
    return "".join(lines)


def case_good(tree):
    # A compliant new row: new URL, 90d recheck, a capture row, a citing lesson.
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    src.write_text(insert_after_registry(text, NEW_ROW_PY), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")
    url = "https://docs.python.org/3/library/sys.html"
    digest = "a" * 64
    row = "\t".join([
        "S045", "mined", row_identity("S045", "mined", url), url, url, "200",
        "curl-fsSL-compressed-v1", "2026-10-21", "decoded-http-body-volatile-v1",
        digest, "1000", "-",
        "the limit is 4300 digits", "rendered-text-v1", "b" * 64,
        "sys.set_int_max_str_digits",
    ])
    with (tree / "corpus" / "source-fetches.tsv").open("a", encoding="utf-8") as handle:
        handle.write(row + "\n")


def case_e04(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_SEMVER.format(scope=S042_SCOPE, teaches="Normal version cores carry no leading zeroes.",
                                usedby="corpus/lessons/round-28.md")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_w04(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_SEMVER.format(scope="Canonical form of a normal version core: no leading zeroes",
                                teaches="supersedes S042 — a normal version number MUST NOT contain leading zeroes.",
                                usedby="corpus/lessons/round-28.md")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_e11(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_SEMVER.format(scope="Canonical form of a normal version core: no leading zeroes",
                                teaches="supersedes S042 — a normal version number MUST NOT contain leading zeroes.",
                                usedby="corpus/lessons/round-29.md")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")


def case_e12(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_SEMVER.format(scope="Canonical form of a normal version core: no leading zeroes",
                                teaches="supersedes S042 — a normal version number MUST NOT contain leading zeroes.",
                                usedby="corpus/lessons/round-28.md")
    with src.open("a", encoding="utf-8") as handle:
        handle.write("\n" + row + "\n")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_e01(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_SEMVER.format(scope="Canonical form of a normal version core: no leading zeroes",
                                teaches="supersedes S042 — no leading zeroes | with a pipe",
                                usedby="corpus/lessons/round-28.md")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_sc_fetch(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_sc_inrow(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY.replace(
        "mined | 2026-10-21 | 90d |",
        "mined | 2026-10-21 | 90d |").replace(
        "canonical token form", "canonical token form")
    row = NEW_ROW_PY[:-2] + " Fetch sha256: %s | corpus/lessons/round-28.md |" % ("c" * 64)
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_clock_onrelease(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY.replace("| 90d |", "| on-release |")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_clock_s1000(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY.replace("S045", "S1000").replace("| 90d |", "| on-release |")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_e08(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY.replace("| 2026-10-21 |", "| 2026-10-22 |")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_e10(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY.replace("| docs | A |", "| community | A |")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_w01(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY.replace("| docs | A |", "| community | C |")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


def case_e09(tree):
    src = tree / "corpus" / "SOURCES.md"
    text = src.read_text(encoding="utf-8")
    row = NEW_ROW_PY.replace("| 90d |", "| 18-10-21 |")
    src.write_text(insert_after_registry(text, row), encoding="utf-8")
    (tree / "corpus" / "lessons" / "round-28.md").write_text(LESSON, encoding="utf-8")


CASES = [
    ("00-base", None),
    ("01-good-new-row", case_good),
    ("02-e04-same-url-same-scope", case_e04),
    ("03-w04-same-url-new-scope", case_w04),
    ("04-e11-missing-usedby", case_e11),
    ("05-e12-row-outside-registry", case_e12),
    ("06-e01-pipe-in-cell", case_e01),
    ("07-sc_fetch-no-capture-row", case_sc_fetch),
    ("08-sc_inrow-pin-not-historical", case_sc_inrow),
    ("09-clock-new-on-release-row", case_clock_onrelease),
    ("10-clock-id-S1000", case_clock_s1000),
    ("11-e08-future-opened", case_e08),
    ("12-e10-community-at-A", case_e10),
    ("13-w01-tierC-mined-usedby", case_w01),
    ("14-e09-bad-recheck", case_e09),
]


def run(cmd, cwd=None):
    proc = subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)
    return proc.returncode, proc.stdout, proc.stderr


def main():
    WORK.mkdir(parents=True, exist_ok=True)
    for name, mutate in CASES:
        tree = WORK / name
        if tree.exists():
            shutil.rmtree(tree)
        shutil.copytree(BASE, tree, symlinks=True)
        if mutate:
            mutate(tree)
        fleet_rc, fleet_out, _ = run(
            "bash %s validate --file %s --today 2026-10-21" % (FLEET, tree / "corpus" / "SOURCES.md"))
        lane_rc, lane_out, _ = run(
            "bash %s --root %s" % (tree / "corpus" / "sources-census.sh", tree))
        clock_rc, clock_out, _ = run(
            "python3 -I -B %s --root %s" % (tree / "corpus" / "release-clock.py", tree))
        fleet_codes = [line.split("\t")[1] for line in fleet_out.splitlines()
                       if "\t" in line and line.split("\t")[1].startswith(("E", "W"))]
        lane_findings = [line.split(" ", 2)[1] for line in lane_out.splitlines()
                         if line.startswith("FINDING ")]
        print("== %s" % name)
        print("   fleet rc=%d codes=%s" % (fleet_rc, ",".join(fleet_codes) or "-"))
        print("   lane  rc=%d findings=%s" % (lane_rc, ",".join(lane_findings) or "-"))
        print("   clock rc=%d %s" % (clock_rc, clock_out.strip().replace("\n", " | ")))
        if name in ("01-good-new-row", "02-e04-same-url-same-scope", "03-w04-same-url-new-scope",
                    "05-e12-row-outside-registry", "07-sc_fetch-no-capture-row",
                    "08-sc_inrow-pin-not-historical", "10-clock-id-S1000"):
            for line in fleet_out.splitlines():
                if "\t" in line and line.split("\t")[1].startswith(("E", "W")):
                    print("   fleet> %s" % line)
            for line in lane_out.splitlines():
                if line.startswith("FINDING "):
                    print("   lane>  %s" % line)
    return 0


if __name__ == "__main__":
    sys.exit(main())
