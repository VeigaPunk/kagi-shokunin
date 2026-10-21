#!/usr/bin/env python3
"""Independent probe for round-28 C1, major-component leading zero.

Reuses the FROZEN instrument's fixture builders (.ufo/waves/round-28/tools/
c1-measure.py) unmodified; only the bad token differs (03.15.1 instead of
3.15.01). No network: the table path fetches nothing, the observe path is
served by the instrument's local stub.
"""
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

LANE = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
TOOL = LANE / ".ufo/waves/round-28/tools/c1-measure.py"

spec = importlib.util.spec_from_file_location("c1measure", TOOL)
c1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c1)

TOKEN = "03.15.1"
ROW = "S040"


def env_for(temp):
    return {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
            "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}


def table_edit(tree, edits):
    """edits: row_id -> dict(field_index -> value) over the header order."""
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    kept = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in edits:
            for idx, val in edits[fields[0]].items():
                fields[idx] = val
            kept.append("\t".join(fields) + "\n")
        else:
            kept.append(line)
    return "".join(kept)


def table_case(tree, temp, env, name, edits):
    """Table fixture with a mirrored receipt (frozen tool's receipt mirroring)."""
    table_text = table_edit(tree, edits)
    root = c1.stage_fixture(tree, temp, name, table_text)
    receipt_edits = {}
    for row_id, changes in edits.items():
        receipt_edits[row_id] = (changes.get(5, c1.row_fields(table_text, row_id)[5]),
                                 changes.get(7, c1.row_fields(table_text, row_id)[7]))
    path, sha, mirrored = c1.mirrored_receipt(
        tree, c1.default_receipt_rel(tree), receipt_edits, root)
    result = c1.run(
        ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
         "--root", str(root), "--receipt", str(path), "--receipt-sha", sha],
        cwd=tree, env=env)
    written = sorted(p.name for p in root.iterdir() if p.is_file())
    result = c1.classify(result, ROW, "")
    result["root_files_after_run"] = written
    result["mirrored_rows"] = mirrored
    return result


def observe_case(tree, temp, env, name, titles):
    runner = temp / ("observe-runner-%s.py" % name)
    runner.write_text(c1.RUNNER, encoding="utf-8")
    _, result = c1.observe_fixture(tree, temp, env, runner, name, TOKEN, titles)
    return result


def report(label, result):
    print("=" * 78)
    print(label, "exit=%s verdict=%s traceback=%s" % (
        result["exit"], result.get("verdict"), result.get("traceback_in_output")))
    print("-- stdout --")
    print(result["stdout"])
    if result.get("stderr"):
        print("-- stderr --")
        print(result["stderr"])
    if "receipt" in result and result["receipt"] is not None:
        print("-- receipt records --")
        print(json.dumps(result["receipt"], indent=2))
    print("-- typed finding lines --")
    print(json.dumps(result.get("typed_finding_lines"), indent=2))


def main():
    trees = {"cand": Path(sys.argv[1]).resolve(), "base": Path(sys.argv[2]).resolve()}
    out = {}
    for label, tree in trees.items():
        temp = Path(tempfile.mkdtemp(prefix="kagi-r28-fmj-%s-" % label))
        try:
            env = env_for(temp)
            # 1. table observation carries the major-zero token, verdict fired
            r1 = table_case(tree, temp, env, "table-observed",
                            {ROW: {5: TOKEN, 7: "fired"}})
            report("%s table-observation %s (verdict fired)" % (label, TOKEN), r1)
            # 2. table anchor carries the major-zero token (observed mirrors)
            r2 = table_case(tree, temp, env, "table-anchored",
                            {ROW: {4: TOKEN, 5: TOKEN, 7: "not-fired"}})
            report("%s table-anchor %s" % (label, TOKEN), r2)
            # 3. observe path: local feed whose newest entry is the major-zero token
            r3 = observe_case(tree, temp, env, "observe-majorzero",
                              ["Python " + TOKEN, "Python 3.15.0"])
            report("%s observe feed newest %s" % (label, TOKEN), r3)
            out[label] = {"table_observed": r1, "table_anchored": r2,
                          "observe": r3}
        finally:
            shutil.rmtree(temp, ignore_errors=True)
    Path(__file__).with_name("probe-result.json").write_text(
        json.dumps(out, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
