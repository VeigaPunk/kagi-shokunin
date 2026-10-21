#!/usr/bin/env python3
"""Independently measure release-clock bindings at a committed revision."""

from __future__ import annotations

import csv
import datetime as dt
import io
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

REQUIRED_CLOCK_FIELDS = {"id", "observed_at", "verdict"}
ISO_DATE = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}\Z")
ISO_DATETIME = re.compile(
    r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}"
    r"(?::[0-9]{2}(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\Z"
)
SEPARATOR_CELL = re.compile(r":?-{3,}:?\Z")


class SetupError(Exception):
    """The requested revision or its measurement inputs cannot be read."""


def git(root: Path, *args: str) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            ["git", "-C", str(root), *args],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            check=False,
        )
    except (OSError, UnicodeError) as exc:
        raise SetupError(f"cannot run git {args[0]}") from exc


def show_blob(root: Path, revision: str, path: str, *, optional: bool = False) -> str | None:
    result = git(root, "show", f"{revision}:{path}")
    if result.returncode == 0:
        return result.stdout
    if optional:
        exists = git(root, "cat-file", "-e", f"{revision}:{path}")
        if exists.returncode != 0:
            return None
    raise SetupError(f"cannot read {path} at requested revision")


def pipe_cells(line: str) -> list[str] | None:
    stripped = line.strip()
    if not (stripped.startswith("|") and stripped.endswith("|")):
        return None
    return [cell.strip() for cell in stripped[1:-1].split("|")]


def parse_registry(text: str) -> list[tuple[str, str]]:
    in_registry = False
    header: list[str] | None = None
    rows: list[tuple[str, str]] = []

    for line in text.splitlines():
        stripped = line.strip()
        if not in_registry:
            if stripped == "## Registry":
                in_registry = True
            continue
        if stripped.startswith("## "):
            break

        cells = pipe_cells(line)
        if cells is None:
            if header is not None and (stripped.startswith("|") or stripped.endswith("|")):
                raise SetupError("malformed pipe-table row in SOURCES.md registry")
            if header is not None and not stripped:
                break
            continue
        if cells and all(SEPARATOR_CELL.fullmatch(cell) for cell in cells):
            continue
        if header is None:
            if "id" in cells and "recheck" in cells:
                if cells.count("id") != 1 or cells.count("recheck") != 1:
                    raise SetupError("ambiguous SOURCES.md registry header")
                header = cells
            continue
        if len(cells) != len(header):
            raise SetupError("SOURCES.md registry row has the wrong number of cells")
        row_id = cells[header.index("id")]
        if not row_id:
            raise SetupError("SOURCES.md registry row has no id")
        rows.append((row_id, cells[header.index("recheck")]))

    if not in_registry or header is None:
        raise SetupError("SOURCES.md registry table is missing")
    return rows


def parse_bindings(text: str) -> list[dict[str, str]]:
    try:
        reader = csv.reader(io.StringIO(text, newline=""), delimiter="\t", strict=True)
        records = [row for row in reader if row]
    except csv.Error as exc:
        raise SetupError("release-clocks.tsv is malformed") from exc
    if not records:
        raise SetupError("release-clocks.tsv has no header")

    header = [cell.strip().lstrip("\ufeff") for cell in records[0]]
    if len(set(header)) != len(header) or not REQUIRED_CLOCK_FIELDS.issubset(header):
        raise SetupError("release-clocks.tsv header lacks unique required columns")
    if any(len(row) != len(header) for row in records[1:]):
        raise SetupError("release-clocks.tsv row has the wrong number of columns")
    positions = {name: header.index(name) for name in REQUIRED_CLOCK_FIELDS}
    return [
        {name: row[index] for name, index in positions.items()}
        for row in records[1:]
    ]


def is_iso_observed_at(value: str) -> bool:
    value = value.strip()
    try:
        if ISO_DATE.fullmatch(value):
            dt.date.fromisoformat(value)
            return True
        if ISO_DATETIME.fullmatch(value):
            dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
            return True
    except ValueError:
        return False
    return False


def measure(root: Path, revision: str) -> tuple[int, int, int, int, int, int]:
    sources = show_blob(root, revision, "corpus/SOURCES.md")
    assert sources is not None
    registry = parse_registry(sources)
    on_release = [row_id for row_id, recheck in registry if recheck == "on-release"]
    if len(set(on_release)) != len(on_release):
        raise SetupError("SOURCES.md has duplicate on-release row ids")

    clocks_text = show_blob(root, revision, "corpus/release-clocks.tsv", optional=True)
    bindings = parse_bindings(clocks_text) if clocks_text is not None else []
    binding_counts = Counter(binding["id"] for binding in bindings)
    on_release_ids = set(on_release)

    bound = sum(binding_counts[row_id] == 1 for row_id in on_release_ids)
    unbound = sum(binding_counts[row_id] == 0 for row_id in on_release_ids)
    orphan = sum(binding["id"] not in on_release_ids for binding in bindings)
    # Observation/firing counts belong only to unique population members.
    # Orphans and duplicate bindings are invalid inputs, never observations.
    eligible = [binding for binding in bindings
                if binding["id"] in on_release_ids and binding_counts[binding["id"]] == 1]
    observed = sum(is_iso_observed_at(binding["observed_at"]) for binding in eligible)
    fired = sum(binding["verdict"] in ("fired", "quote-missing") for binding in eligible)
    return len(on_release), bound, unbound, orphan, observed, fired


def main(argv: list[str]) -> int:
    if len(argv) != 1 or not argv[0] or any(char.isspace() for char in argv[0]):
        print("C3_MEASURE: SETUP (usage: c3-measure.py <rev>)", file=sys.stderr)
        return 2
    try:
        root = Path(__file__).resolve().parents[4]
        counts = measure(root, argv[0])
    except (IndexError, OSError, SetupError, UnicodeError) as exc:
        detail = str(exc) or "cannot resolve repository root"
        print(f"C3_MEASURE: SETUP ({detail})", file=sys.stderr)
        return 2
    on_release, bound, unbound, orphan, observed, fired = counts
    print(
        f"C3_MEASURE rev={argv[0]} on_release={on_release} bound={bound} "
        f"unbound={unbound} orphan={orphan} observed={observed} fired={fired}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
