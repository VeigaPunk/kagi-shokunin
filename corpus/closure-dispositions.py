#!/usr/bin/env python3
"""Turn a non-author closure's decisions into a machine-checked obligation set.

WHY. Round 22's outside spot-check routed nine defects (D1-D9), re-opened the
discernment sample, and recorded an adjudication. Those are the lane's debts and
its outside signal; before this gate they existed only as prose, so "we handled
the review" was a self-certification. This gate parses the closure document,
requires exactly one typed disposition per obligation, and resolves the
pointer a `fixed` disposition names. It never decides whether a fix is good --
it decides whether the lane recorded one and whether the record still resolves.

WHAT IT READS. The source is a markdown closure record with these H2 sections:
`## Routed defects` (one `- D<N> ...` bullet per defect), `## Discernment
spot-check` (a `| item | decision | ... |` table whose decision cell is
`admit` or `reject`), and `## Adjudication` (a line starting
`**ADMITTED.**`/`**REJECTED...**`). Obligations become `D<N>`, `SPOT-<NN>` in
table order, and `ADJ`. The document's sha256 is pinned by the dispositions
file: a silent edit to the closure invalidates the obligations until the pin is
reviewed.

DISPOSITIONS. `corpus/closure-dispositions.json` carries `schema`, `source`,
`source_sha256`, and `dispositions` rows `{id, class, disposition, pointer,
note}`. `disposition` is one of `fixed` (pointer required; the pointed file must
name the obligation id and, with `#anchor`, carry a heading containing the
anchor), `reported`, `rejected`, `no-action`, `operator-owned` (pointer optional
but must resolve when present; note >= 24 chars for every kind). Unknown,
missing and duplicate ids are defects; a malformed record exits 2.

USAGE.
  python3 corpus/closure-dispositions.py [--root DIR] [--source PATH]
                                          [--dispositions PATH] [--selftest]

VERDICT (last line):
  CLOSURE_DISPOSITIONS: CLEAN (obligations=N fixed=.. reported=..
      operator_owned=.. no_action=.. rejected=.. pointers=..)          exit 0
  CLOSURE_DISPOSITIONS: FAILED (obligations=N dispositions=M missing=..
      unknown=.. unresolved=..)                                       exit 1
  CLOSURE_DISPOSITIONS: SETUP (<reason>)                              exit 2
  --selftest: CLOSURE_DISPOSITIONS_SELFTEST: PASS (N cases)           exit 0

Bounds: the gate checks record shape, obligation coverage and pointer
resolution. It does not judge whether a disposition's prose is honest, rerun
the fix, or reach the network; the parent's non-author closure still owns
admission. A `fixed` pointer proves a reviewed record exists at that path, not
that its content is correct.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
import tempfile
from pathlib import Path

SCHEMA = "kagi-closure-dispositions-v1"
DEFAULT_SOURCE = "corpus/lessons/round-22-verifier-spotcheck.md"
DEFAULT_DISPOSITIONS = "corpus/closure-dispositions.json"
KINDS = {"fixed", "reported", "rejected", "no-action", "operator-owned"}
MIN_NOTE = 24
HEAD_RE = re.compile(r"^##\s+(.+?)\s*$")
ROUTED_RE = re.compile(r"^- D(\d+)\b")
SEP_RE = re.compile(r"^\|[\s:|-]+\|$")


def setup(message: str) -> "NoReturn":
    print(f"CLOSURE_DISPOSITIONS: SETUP ({message})")
    raise SystemExit(2)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_obligations(text: str) -> dict[str, str]:
    """id -> class, in document order (dicts keep insertion order)."""
    obligations: dict[str, str] = {}
    section = None
    spot = 0
    for raw in text.splitlines():
        line = raw.strip()
        heading = HEAD_RE.match(line)
        if heading:
            section = heading.group(1)
            continue
        if section and section.startswith("Routed defects"):
            match = ROUTED_RE.match(line)
            if match:
                obligations[f"D{match.group(1)}"] = "routed-defect"
        elif section and section.startswith("Discernment spot-check"):
            if not line.startswith("|") or SEP_RE.match(line):
                continue
            cells = [cell.strip() for cell in line.strip("|").split("|")]
            if len(cells) >= 2 and cells[1] in ("admit", "reject"):
                spot += 1
                obligations[f"SPOT-{spot:02d}"] = "spot-decision"
        elif section and section.startswith("Adjudication"):
            if line.startswith("**ADMITTED.**") or line.startswith("**REJECTED"):
                obligations["ADJ"] = "adjudication"
    return obligations


def resolve_pointer(root: Path, pointer: str, oid: str, kind: str) -> list[tuple[str, str]]:
    """Return failure tuples for one pointer; [] means it resolves."""
    rel, _, anchor = pointer.partition("#")
    if not rel or rel.startswith("/") or ".." in Path(rel).parts:
        return [("POINTER-ESCAPE", f"{oid} {pointer}")]
    target = root / rel
    if not target.is_file():
        return [("POINTER-MISSING", f"{oid} {rel}")]
    try:
        resolved = target.resolve()
        if root.resolve() not in resolved.parents and resolved != root.resolve():
            return [("POINTER-ESCAPE", f"{oid} {pointer}")]
        text = resolved.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        return [("POINTER-MISSING", f"{oid} {rel} ({exc.__class__.__name__})")]
    if anchor and not any(
        line.startswith("#") and anchor in line for line in text.splitlines()
    ):
        return [("POINTER-ANCHOR", f"{oid} {pointer}")]
    if kind == "fixed":
        token = re.compile(r"(^|[^A-Za-z0-9_])" + re.escape(oid) + r"([^0-9]|$)")
        if not token.search(text):
            return [("POINTER-ID", f"{oid} {rel}")]
    return []


def load_dispositions(path: Path) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        setup(f"dispositions unreadable: {exc}")
    if not isinstance(data, dict):
        setup("dispositions root is not an object")
    if data.get("schema") != SCHEMA:
        setup(f"schema mismatch: {data.get('schema')!r}")
    rows = data.get("dispositions")
    if not isinstance(rows, list) or not rows:
        setup("dispositions list is empty")
    return data


def verify(root: Path, source_rel: str, dispositions_rel: str) -> int:
    source = root / source_rel
    if not source.is_file():
        setup(f"source not found: {source_rel}")
    data = load_dispositions(root / dispositions_rel)
    declared_source = data.get("source")
    if declared_source != source_rel:
        setup(f"source field {declared_source!r} != requested {source_rel!r}")
    actual = digest(source)
    if data.get("source_sha256") != actual:
        setup(f"source digest mismatch: {data.get('source_sha256')} -> {actual}")

    try:
        source_text = source.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        setup(f"source unreadable: {exc}")
    obligations = parse_obligations(source_text)
    if not obligations:
        setup(f"no obligations parsed from {source_rel}")

    failures: list[tuple[str, str]] = []
    seen: dict[str, str] = {}
    counts = {kind: 0 for kind in KINDS}
    pointers = 0
    for row in data["dispositions"]:
        if not isinstance(row, dict):
            setup("disposition row is not an object")
        oid = row.get("id")
        if not isinstance(oid, str) or not oid:
            setup("disposition row has no id")
        if oid in seen:
            setup(f"duplicate disposition id {oid}")
        seen[oid] = oid
        kind = row.get("disposition")
        if kind not in KINDS:
            setup(f"invalid disposition {kind!r} for {oid}")
        klass = row.get("class")
        if oid in obligations and klass != obligations[oid]:
            setup(f"class mismatch for {oid}: {klass!r} != {obligations[oid]!r}")
        note = row.get("note")
        if not isinstance(note, str) or len(note.strip()) < MIN_NOTE:
            failures.append(("NOTE-SHORT", f"{oid} note < {MIN_NOTE} chars"))
        pointer = row.get("pointer")
        if pointer is None or pointer == "":
            if kind == "fixed":
                failures.append(("POINTER-MISSING", f"{oid} fixed without pointer"))
            counts[kind] += 1
            continue
        if not isinstance(pointer, str):
            failures.append(("POINTER-MALFORMED", f"{oid} pointer is not a string"))
            counts[kind] += 1
            continue
        resolved = resolve_pointer(root, pointer, oid, kind)
        if resolved:
            failures.extend(resolved)
        else:
            pointers += 1
        counts[kind] += 1

    missing = [oid for oid in obligations if oid not in seen]
    unknown = [oid for oid in seen if oid not in obligations]
    for oid in missing:
        print(f"DISPOSITION MISSING {oid}")
    for oid in unknown:
        print(f"DISPOSITION UNKNOWN {oid}")
    for code, detail in failures:
        print(f"DISPOSITION {code} {detail}")

    if missing or unknown or failures:
        print(
            "CLOSURE_DISPOSITIONS: FAILED "
            f"(obligations={len(obligations)} dispositions={len(seen)} "
            f"missing={len(missing)} unknown={len(unknown)} unresolved={len(failures)})"
        )
        return 1
    print(
        "CLOSURE_DISPOSITIONS: CLEAN "
        f"(obligations={len(obligations)} fixed={counts['fixed']} "
        f"reported={counts['reported']} operator_owned={counts['operator-owned']} "
        f"no_action={counts['no-action']} rejected={counts['rejected']} pointers={pointers})"
    )
    return 0


# --- selftest ----------------------------------------------------------------
FIXTURE_SOURCE = """# closure fixture

## Routed defects

- D1 first routed defect
- D2 second routed defect

## Discernment spot-check

| item | decision | re-opened source | verdict | reason |
|---|---|---|---|---|
| source one | admit | page one | agree | located quote present |
| source two | reject | page two | agree | located quote absent |

## Adjudication

**ADMITTED.** Fixture adjudication.
"""

FIXTURE_NOTES = """# fixture notes

## Routed

D1 is handled here. D2 is handled here too.
"""


def base_rows() -> list[dict]:
    return [
        {"id": "D1", "class": "routed-defect", "disposition": "fixed",
         "pointer": "notes.md#Routed", "note": "fixture pointer resolves and names D1"},
        {"id": "D2", "class": "routed-defect", "disposition": "reported",
         "pointer": "notes.md", "note": "fixture reported with a sufficiently long note"},
        {"id": "SPOT-01", "class": "spot-decision", "disposition": "no-action",
         "note": "outside agreed, no lane action required"},
        {"id": "SPOT-02", "class": "spot-decision", "disposition": "rejected",
         "pointer": "notes.md", "note": "fixture rejects the outside reading with reasons"},
        {"id": "ADJ", "class": "adjudication", "disposition": "reported",
         "pointer": "notes.md", "note": "fixture adjudication recorded for the lane"},
    ]


def selftest() -> int:
    cases: list[tuple[str, str, int, str]] = []  # name, mutation, expected exit, needle
    with tempfile.TemporaryDirectory(prefix="closure-dispositions-selftest-") as tmp:
        root = Path(tmp)
        source_rel = "spot.md"
        dispo_rel = "dispositions.json"
        (root / source_rel).write_text(FIXTURE_SOURCE, encoding="utf-8")
        (root / "notes.md").write_text(FIXTURE_NOTES, encoding="utf-8")
        (root / "other.md").write_text("# other\n\nnothing here.\n", encoding="utf-8")
        (root.parent / "outside.md").write_text("# outside\n\nD1 outside root.\n", encoding="utf-8")
        (root / "link.md").symlink_to(root.parent / "outside.md")
        source_digest = digest(root / source_rel)

        def write(rows: list[dict], **overrides) -> None:
            data = {"schema": SCHEMA, "source": source_rel,
                    "source_sha256": source_digest, "dispositions": rows}
            data.update(overrides)
            (root / dispo_rel).write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")

        def run() -> tuple[int, str, str]:
            import subprocess
            proc = subprocess.run(
                [sys.executable, str(Path(__file__).resolve()), "--root", str(root),
                 "--source", source_rel, "--dispositions", dispo_rel],
                capture_output=True, text=True,
            )
            last = [line for line in proc.stdout.splitlines() if line.strip()]
            return proc.returncode, (last[-1] if last else ""), proc.stdout

        mutations: list[tuple[str, callable]] = []
        mutations.append(("clean", lambda r: None))
        mutations.append(("missing", lambda r: r.pop(1)))
        mutations.append(("duplicate", lambda r: r.append(dict(r[0]))))
        mutations.append(("unknown", lambda r: r.append(
            {"id": "X9", "class": "routed-defect", "disposition": "no-action",
             "note": "unknown obligation recorded anyway"})))
        mutations.append(("pointer-missing", lambda r: r[0].update(pointer="absent.md#Routed")))
        mutations.append(("pointer-id", lambda r: r[0].update(pointer="other.md")))
        mutations.append(("pointer-anchor", lambda r: r[0].update(pointer="notes.md#Nope")))
        mutations.append(("bad-kind", lambda r: r[1].update(disposition="ignored")))
        mutations.append(("note-short", lambda r: r[1].update(note="short")))
        mutations.append(("pointer-escape", lambda r: r[0].update(pointer="../notes.md#Routed")))
        mutations.append(("pointer-symlink", lambda r: r[0].update(pointer="link.md")))
        mutations.append(("class-mismatch", lambda r: r[1].update(**{"class": "spot-decision"})))
        expect = {
            "clean": (0, "CLOSURE_DISPOSITIONS: CLEAN (obligations=5 fixed=1 "
                           "reported=2 operator_owned=0 no_action=1 rejected=1 pointers=4)"),
            "missing": (1, "DISPOSITION MISSING D2"),
            "duplicate": (2, "duplicate disposition id D1"),
            "unknown": (1, "DISPOSITION UNKNOWN X9"),
            "pointer-missing": (1, "DISPOSITION POINTER-MISSING D1"),
            "pointer-id": (1, "DISPOSITION POINTER-ID D1"),
            "pointer-anchor": (1, "DISPOSITION POINTER-ANCHOR D1"),
            "bad-kind": (2, "invalid disposition"),
            "note-short": (1, "DISPOSITION NOTE-SHORT D2"),
            "pointer-escape": (1, "DISPOSITION POINTER-ESCAPE D1"),
            "pointer-symlink": (1, "DISPOSITION POINTER-ESCAPE D1"),
            "class-mismatch": (2, "class mismatch"),
        }
        failed = 0
        total = 0
        for name, mutate in mutations:
            rows = base_rows()
            mutate(rows)
            write(rows)
            total += 1
            rc, last, full = run()
            want_rc, needle = expect[name]
            ok = rc == want_rc and needle in full
            print(f"case {name}: {'ok' if ok else 'FAIL'} (exit {rc}, {last})")
            if not ok:
                failed += 1
        # source drift: an obligation added to the closure while the disposition
        # set stays frozen must fail as missing, proving the gate reads the source
        drifted = FIXTURE_SOURCE.replace(
            "- D2 second routed defect", "- D2 second routed defect\n- D3 third routed defect"
        )
        (root / source_rel).write_text(drifted, encoding="utf-8")
        write(base_rows(), source_sha256=digest(root / source_rel))
        total += 1
        rc, last, full = run()
        ok = rc == 1 and "DISPOSITION MISSING D3" in full
        print(f"case source-drift: {'ok' if ok else 'FAIL'} (exit {rc}, {last})")
        if not ok:
            failed += 1
        # digest mismatch: pinned closure digest no longer matches the document
        (root / source_rel).write_text(FIXTURE_SOURCE, encoding="utf-8")
        write(base_rows(), source_sha256="0" * 64)
        total += 1
        rc, last, full = run()
        ok = rc == 2 and "source digest mismatch" in full
        print(f"case digest-mismatch: {'ok' if ok else 'FAIL'} (exit {rc}, {last})")
        if not ok:
            failed += 1
        if failed == 0:
            print(f"CLOSURE_DISPOSITIONS_SELFTEST: PASS ({total} cases)")
            return 0
        print(f"CLOSURE_DISPOSITIONS_SELFTEST: FAIL ({total} cases, {failed} failed)")
        return 1


def parse_args(argv: list[str]) -> tuple[Path, str, str, bool, bool]:
    root = Path(".")
    source = DEFAULT_SOURCE
    dispositions = DEFAULT_DISPOSITIONS
    selftest_flag = False
    help_flag = False
    i = 0
    while i < len(argv):
        token = argv[i]
        if token == "--root":
            i += 1
            if i >= len(argv):
                setup("--root needs a directory")
            root = Path(argv[i])
        elif token == "--source":
            i += 1
            if i >= len(argv):
                setup("--source needs a path")
            source = argv[i]
        elif token == "--dispositions":
            i += 1
            if i >= len(argv):
                setup("--dispositions needs a path")
            dispositions = argv[i]
        elif token == "--selftest":
            selftest_flag = True
        elif token in ("-h", "--help"):
            help_flag = True
        else:
            setup(f"unknown argument: {token}")
        i += 1
    return root, source, dispositions, selftest_flag, help_flag


def main(argv: list[str] | None = None) -> int:
    root, source, dispositions, selftest_flag, help_flag = parse_args(
        list(sys.argv[1:] if argv is None else argv)
    )
    if help_flag:
        print(__doc__.strip())
        return 0
    if selftest_flag:
        return selftest()
    return verify(root, source, dispositions)


if __name__ == "__main__":
    sys.exit(main())
