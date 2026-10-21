#!/usr/bin/env python3
"""Round-27 C1 counting instrument: knowledge-entry numbers against their source.

c1-measure.py DOCS_REV TABLE_REV LABEL OUT.json [--mutate ID]

Scratch clone at DOCS_REV; corpus/self-counts.tsv is overlaid from TABLE_REV
(git show), so the SAME binding population is measured against BASE docs and
after docs. Runs the clone's own `python3 -I -B corpus/self-counts.py` with a
whitelisted environment and records exit, summary, STALE/UNLOCATED/AMBIGUOUS
ids and how many bindings point into corpus/knowledge/. --mutate ID bumps the
first digit of the captured number on that binding's located doc line by one
(the red control: the binder must report exactly that id STALE).
"""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

LANE = Path(__file__).resolve().parents[4]


def main():
    args = sys.argv[1:]
    mutate = None
    if "--mutate" in args:
        index = args.index("--mutate")
        mutate = args[index + 1]
        del args[index:index + 2]
    if len(args) != 4 or not all(re.fullmatch(r"[0-9a-f]{40}", a) for a in args[:2]):
        raise SystemExit("usage: c1-measure.py DOCS_REV TABLE_REV LABEL OUT.json [--mutate ID]")
    docs_rev, table_rev, label, out = args
    with tempfile.TemporaryDirectory(prefix="kagi-r27-c1-", dir="/fast/scratch") as temp:
        temp = Path(temp)
        env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
               "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
        # sibling layout is irrelevant: self-counts reads only lane files and runs non-host rows
        clone = temp / "kagi-shokunin"
        subprocess.run(["git", "clone", "--quiet", "--no-checkout", str(LANE), str(clone)], check=True, env=env)
        subprocess.run(["git", "-C", str(clone), "checkout", "--quiet", "--detach", docs_rev], check=True, env=env)
        table = subprocess.check_output(["git", "-C", str(clone), "show", table_rev + ":corpus/self-counts.tsv"], env=env)
        (clone / "corpus/self-counts.tsv").write_bytes(table)
        rows = [line.split("\t") for line in table.decode().splitlines() if line and not line.startswith("#")]
        knowledge = [r[0] for r in rows if r[1].startswith("corpus/knowledge/")]
        mutation = None
        if mutate:
            row = next(r for r in rows if r[0] == mutate)
            doc = clone / row[1]
            lines = doc.read_text().splitlines(keepends=True)
            hits = [i for i, line in enumerate(lines) if re.search(row[2], line)]
            if len(hits) != 1:
                raise SystemExit("mutation locator not unique: %r" % hits)
            match = re.search(row[2], lines[hits[0]])
            start = match.start(1)
            digit = lines[hits[0]][start]
            bumped = str((int(digit) + 1) % 10)
            lines[hits[0]] = lines[hits[0]][:start] + bumped + lines[hits[0]][start + 1:]
            doc.write_text("".join(lines))
            mutation = {"id": mutate, "doc": row[1], "line": hits[0] + 1, "from": digit, "to": bumped}
        proc = subprocess.run(["python3", "-I", "-B", "corpus/self-counts.py"], cwd=clone, env=env,
                              text=True, capture_output=True, timeout=1500)
    findings = re.findall(r"^(STALE|UNLOCATED|AMBIGUOUS|POLICY|SETUP) (\S+)", proc.stdout, re.M)
    last = [line for line in proc.stdout.splitlines() if line.strip()][-1:] or [""]
    result = {"format": "kagi-round27-c1-measure-v1", "docs_revision": docs_rev, "table_revision": table_rev,
              "label": label, "bindings": len(rows), "knowledge_bindings": len(knowledge),
              "mutation": mutation, "exit": proc.returncode, "last_line": last[0],
              "findings": findings, "stale_knowledge": sorted(i for k, i in findings if k == "STALE" and i in knowledge),
              "stdout": proc.stdout, "stderr": proc.stderr}
    Path(out).write_text(json.dumps(result, indent=2) + "\n")
    print("C1_MEASURE %s: exit=%d bindings=%d knowledge=%d stale_knowledge=%d findings=%d | %s" % (
        label, proc.returncode, len(rows), len(knowledge), len(result["stale_knowledge"]), len(findings), last[0]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
