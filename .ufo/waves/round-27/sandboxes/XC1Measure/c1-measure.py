#!/usr/bin/env python3
"""Round-27 C1 counting instrument: knowledge-entry numbers against their sources.

Usage:
  c1-measure.py DOCS_REV TABLE_REV LABEL [--mutate ID] [--json PATH]

DOCS_REV is the commit whose docs are measured. It is cloned into scratch, so it
must be reachable from a lane branch, remote or tag (what a clone copies).
TABLE_REV is the commit whose corpus/self-counts.tsv is overlaid; it is read
straight from the lane object store. Only committed revisions are measured.

  1. make a scratch directory under /fast/scratch and clone the lane into it at
     DOCS_REV (git clone --no-hardlinks --no-checkout, then a detached checkout);
  2. overlay corpus/self-counts.tsv with the exact bytes of TABLE_REV;
  3. count the bindings, and the bindings that target corpus/knowledge/, from
     the overlaid table itself rather than from the gate's summary line;
  4. run `python3 -B corpus/self-counts.py` in the clone with an environment
     whitelisted to PATH, HOME (the scratch directory) and LC_ALL=C;
  5. report the gate exit, its claim count, every STALE, UNLOCATED, AMBIGUOUS,
     POLICY and SETUP id, and whether each binding got exactly one verdict line.

--mutate ID is the red control. It measures the clone, bumps the first digit of
the captured number on that binding's located doc line (+1, or -1 for a 9 so the
replacement stays one digit), and measures again. PASS needs ID to be OK before,
STALE after, the gate to exit 1, and ID to be the only newly flagged id. If ID
was not OK before the mutation the verdict is INCONCLUSIVE; every other outcome
is FAIL. A locator with a backreference (\\1) usually makes the mutated line
UNLOCATED rather than STALE, which is reported as FAIL with that reason.

Exit codes: normal mode returns the gate's exit code (0 CLEAN, 1 STALE,
2 POLICY/SETUP). Mutate mode returns 0 on PASS and 1 otherwise. Instrument
errors return 3. Writes go only to the scratch directory and the --json file.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SCRATCH_ROOT = Path("/fast/scratch")
TABLE = "corpus/self-counts.tsv"
GATE = ["python3", "-B", "corpus/self-counts.py"]
KNOWLEDGE = "corpus/knowledge/"
GIT_TIMEOUT_S = 600
GATE_TIMEOUT_S = 3600
EXIT_INSTRUMENT = 3
VERDICT = re.compile(r"^(OK|STALE|UNLOCATED|AMBIGUOUS|POLICY|SETUP) (\S+)")
LABEL = re.compile(r"[A-Za-z0-9._-]+")


class InstrumentError(Exception):
    pass


class Parser(argparse.ArgumentParser):
    def error(self, message):
        print(f"C1_MEASURE_ERROR: {message}", file=sys.stderr)
        raise SystemExit(EXIT_INSTRUMENT)


def run(argv, env, what):
    try:
        done = subprocess.run(argv, env=env, stdin=subprocess.DEVNULL, capture_output=True,
                              timeout=GIT_TIMEOUT_S, check=False)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise InstrumentError(f"{what}: {type(exc).__name__}") from None
    if done.returncode != 0:
        tail = done.stderr.decode("utf-8", "replace").strip().splitlines()[-1:]
        raise InstrumentError(f"{what}: exit {done.returncode} {' '.join(tail)}".rstrip())
    return done.stdout


def lane_root() -> Path:
    for candidate in Path(__file__).resolve().parents:
        if (candidate / "corpus" / "self-counts.py").is_file() and (candidate / ".git").exists():
            return candidate
    raise InstrumentError("no lane above this file (corpus/self-counts.py beside .git)")


def resolve(lane: Path, env, rev: str, what: str) -> str:
    if not rev or rev.startswith("-") or any(ch.isspace() for ch in rev):
        raise InstrumentError(f"{what}: not a revision name: {rev!r}")
    out = run(["git", "-C", str(lane), "rev-parse", "--verify", "--quiet", f"{rev}^{{commit}}"],
              env, f"resolve {what}")
    return out.decode("ascii").strip()


def bindings(text: str) -> list[list[str]]:
    """Data rows under the gate's rule: nonblank, first non-space character not '#'."""
    return [line.split("\t") for line in text.splitlines()
            if line.strip() and not line.lstrip().startswith("#")]


def measure(clone: Path, env, rows, knowledge_ids: set) -> dict:
    try:
        done = subprocess.run(GATE, cwd=clone, env=env, stdin=subprocess.DEVNULL,
                              capture_output=True, timeout=GATE_TIMEOUT_S, check=False)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise InstrumentError(f"gate run: {type(exc).__name__}") from None
    stdout = done.stdout.decode("utf-8", "replace")
    lines = stdout.splitlines()
    verdicts = []
    for line in lines:
        match = VERDICT.match(line)
        if match:
            verdicts.append((match.group(1), match.group(2)))
    summary = next((line for line in reversed(lines) if line.startswith("SELF_COUNTS: ")), "")
    claims = re.search(r"claims=([0-9]+)", summary)

    def ids(*kinds):
        return sorted({ident for kind, ident in verdicts if kind in kinds})

    stale = ids("STALE")
    return {
        "exit": done.returncode,
        "summary": summary,
        "claims": int(claims.group(1)) if claims else None,
        "verdicts": verdicts,
        "stale": stale,
        "unlocated": ids("UNLOCATED"),
        "ambiguous": ids("AMBIGUOUS"),
        "errors": ids("POLICY", "SETUP"),
        "flagged": ids("STALE", "UNLOCATED", "AMBIGUOUS", "POLICY", "SETUP"),
        "knowledge_located": sum(1 for kind, ident in verdicts
                                 if kind in ("OK", "STALE") and ident in knowledge_ids),
        "knowledge_stale": [ident for ident in stale if ident in knowledge_ids],
        "accounted": sorted(ident for _kind, ident in verdicts) == sorted(row[0] for row in rows),
        "stdout": stdout,
        "stderr": done.stderr.decode("utf-8", "replace"),
    }


def status_of(result: dict, ident: str):
    found = [kind for kind, name in result["verdicts"] if name == ident]
    return found[0] if len(found) == 1 else None


def mutate(clone: Path, rows, ident: str) -> dict:
    found = [row for row in rows if row[0] == ident]
    if len(found) != 1 or len(found[0]) != 6:
        raise InstrumentError(f"--mutate {ident}: need exactly one six-column binding row")
    _id, doc, locator_text, _source, _extract, _note = found[0]
    relative = Path(doc)
    if not doc or relative.is_absolute() or ".." in relative.parts:
        raise InstrumentError(f"--mutate {ident}: unsafe doc path {doc!r}")
    path = (clone / relative).resolve()
    if not path.is_relative_to(clone.resolve()) or not path.is_file():
        raise InstrumentError(f"--mutate {ident}: {doc} is not a file inside the clone")
    try:
        raw = path.read_bytes().decode("utf-8")
        locator = re.compile(locator_text)
    except (UnicodeDecodeError, re.error) as exc:
        raise InstrumentError(f"--mutate {ident}: {type(exc).__name__}") from None
    if locator.groups != 1:
        raise InstrumentError(f"--mutate {ident}: locator needs exactly one capture group")
    plain = raw.splitlines()
    hits = [index for index, line in enumerate(plain) if locator.search(line)]
    if len(hits) != 1:
        raise InstrumentError(f"--mutate {ident}: locator matches lines "
                              f"{[index + 1 for index in hits]}; exactly one is required")
    index = hits[0]
    start, end = locator.search(plain[index]).span(1)
    if end <= start or plain[index][start] not in "0123456789":
        raise InstrumentError(f"--mutate {ident}: captured number does not start with a digit")
    old = int(plain[index][start])
    new = old + 1 if old < 9 else old - 1
    keep = raw.splitlines(keepends=True)
    keep[index] = keep[index][:start] + str(new) + keep[index][start + 1:]
    path.write_bytes("".join(keep).encode("utf-8"))
    return {"id": ident, "doc": doc, "line": index + 1, "from": old, "to": new}


def judge(ident: str, before: dict, after: dict):
    was = status_of(before, ident)
    if was != "OK" or before["exit"] == 2:
        return "INCONCLUSIVE", f"binding was {was or 'absent'} before the mutation, exit {before['exit']}"
    now = status_of(after, ident)
    newly = sorted(set(after["flagged"]) - set(before["flagged"]))
    if now != "STALE":
        return "FAIL", f"mutated binding is {now or 'absent'}, not STALE"
    if after["exit"] != 1:
        return "FAIL", f"gate exit {after['exit']} after the mutation, expected 1"
    if newly != [ident]:
        return "FAIL", f"newly flagged {newly}, expected only {ident}"
    return "PASS", "the binder reports exactly the mutated id STALE"


def fmt(items) -> str:
    return ",".join(items) if items else "-"


def run_measure(args) -> int:
    if not SCRATCH_ROOT.is_dir():
        raise InstrumentError(f"{SCRATCH_ROOT} is not a directory")
    lane = lane_root()
    scratch = Path(tempfile.mkdtemp(prefix="kagi-r27-c1-", dir=SCRATCH_ROOT))
    try:
        env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(scratch), "LC_ALL": "C"}
        docs_sha = resolve(lane, env, args.docs_rev, "docs-rev")
        table_sha = resolve(lane, env, args.table_rev, "table-rev")
        table = run(["git", "-C", str(lane), "show", f"{table_sha}:{TABLE}"], env, "show table-rev")
        try:
            rows = bindings(table.decode("utf-8"))
        except UnicodeDecodeError:
            raise InstrumentError("table-rev binding table is not UTF-8") from None
        if not rows:
            raise InstrumentError("table-rev binding table has no data rows")
        if args.mutate is not None and sum(1 for row in rows if row[0] == args.mutate) != 1:
            raise InstrumentError(f"--mutate {args.mutate}: no unique binding with that id")
        clone = scratch / "lane"
        run(["git", "clone", "--quiet", "--no-checkout", "--no-hardlinks", str(lane), str(clone)],
            env, "clone lane")
        run(["git", "-C", str(clone), "checkout", "--quiet", "--detach", docs_sha], env,
            "checkout docs-rev")
        (clone / TABLE).write_bytes(table)
        knowledge_ids = {row[0] for row in rows if len(row) > 1 and row[1].startswith(KNOWLEDGE)}
        knowledge_bindings = sum(1 for row in rows if len(row) > 1 and row[1].startswith(KNOWLEDGE))
        payload = {"format": "kagi-round27-c1-measure-v2", "label": args.label,
                   "docs_revision": docs_sha, "table_revision": table_sha,
                   "bindings": len(rows), "knowledge_bindings": knowledge_bindings}
        if args.mutate is None:
            result = measure(clone, env, rows, knowledge_ids)
            payload["measure"] = result
            claims = "none" if result["claims"] is None else str(result["claims"])
            lines = [
                f"C1_MEASURE {args.label}: gate_exit={result['exit']} claims={claims} "
                f"bindings={len(rows)} knowledge_bindings={knowledge_bindings} "
                f"knowledge_located={result['knowledge_located']} "
                f"accounted={'yes' if result['accounted'] else 'NO'} stale={fmt(result['stale'])} "
                f"knowledge_stale={fmt(result['knowledge_stale'])} "
                f"unlocated={fmt(result['unlocated'])} ambiguous={fmt(result['ambiguous'])} "
                f"errors={fmt(result['errors'])} docs={docs_sha[:12]} table={table_sha[:12]}",
                f"GATE_SUMMARY {result['summary'] or '(none)'}",
            ]
            code = result["exit"]
        else:
            before = measure(clone, env, rows, knowledge_ids)
            change = mutate(clone, rows, args.mutate)
            after = measure(clone, env, rows, knowledge_ids)
            verdict, reason = judge(args.mutate, before, after)
            newly = sorted(set(after["flagged"]) - set(before["flagged"]))
            payload.update(mutation=change, before=before, after=after, verdict=verdict, reason=reason)
            lines = [
                f"C1_MUTATE {args.label}: id={args.mutate} at {change['doc']}:{change['line']} "
                f"digit {change['from']}->{change['to']} "
                f"before={status_of(before, args.mutate) or 'absent'} exit={before['exit']} "
                f"after={status_of(after, args.mutate) or 'absent'} exit={after['exit']} "
                f"newly_flagged={fmt(newly)} verdict={verdict} reason={reason} "
                f"docs={docs_sha[:12]} table={table_sha[:12]}",
            ]
            code = 0 if verdict == "PASS" else 1
    finally:
        shutil.rmtree(scratch, ignore_errors=True)
    if args.json:
        Path(args.json).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    for line in lines:
        print(line)
    return code


def main(argv=None) -> int:
    parser = Parser(description="C1 counting instrument: measure a binding table against a docs revision.")
    parser.add_argument("docs_rev", help="commit whose docs are measured (cloned into scratch)")
    parser.add_argument("table_rev", help="commit whose corpus/self-counts.tsv is overlaid")
    parser.add_argument("label", help="short name echoed in the report line, [A-Za-z0-9._-]+")
    parser.add_argument("--mutate", metavar="ID", default=None,
                        help="red control: bump one binding's first digit and expect exactly that id STALE")
    parser.add_argument("--json", metavar="PATH", default=None, help="also write the full result as JSON")
    args = parser.parse_args(argv)
    if not LABEL.fullmatch(args.label):
        parser.error(f"label {args.label!r} must match [A-Za-z0-9._-]+")
    try:
        return run_measure(args)
    except (InstrumentError, OSError) as exc:
        print(f"C1_MEASURE_ERROR: {exc}", file=sys.stderr)
        return EXIT_INSTRUMENT


if __name__ == "__main__":
    raise SystemExit(main())
