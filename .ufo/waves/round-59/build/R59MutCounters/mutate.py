#!/usr/bin/env python3
"""Apply one declared textual mutation to a fixture tree, with assertions.

usage: mutate.py TREE SPEC.json
SPEC: {"id": "...", "edits": [{"file": "...", "old": "<exact>", "new": "<exact>", "count": 1}]}
Prints the pre/post sha256 of every edited file and fails if an anchor is absent or
the number of replacements differs from `count` (default 1). No write is made when
any edit fails its assertion (all-or-nothing: it validates every anchor first).
"""
import hashlib
import json
import os
import sys


def sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def main() -> int:
    tree, specp = sys.argv[1], sys.argv[2]
    spec = json.load(open(specp, encoding="utf-8"))
    plan = []
    for e in spec["edits"]:
        p = os.path.join(tree, e["file"])
        if os.path.islink(p):
            print(f"FAIL symlinked target {e['file']}")
            return 2
        try:
            data = open(p, "rb").read()
        except OSError as exc:
            print(f"FAIL unreadable {e['file']}: {exc}")
            return 2
        text = data.decode("utf-8")
        cnt = text.count(e["old"])
        want = e.get("count", 1)
        if cnt != want:
            print(f"FAIL anchor count {cnt} != {want} in {e['file']} :: {e['old']!r}")
            return 2
        plan.append((e, p, text))
    for e, p, text in plan:
        before = sha(open(p, "rb").read())
        new = text.replace(e["old"], e["new"], e.get("count", 1))
        with open(p, "w", encoding="utf-8") as f:
            f.write(new)
        after = sha(open(p, "rb").read())
        print(f"EDIT {spec['id']} {e['file']} sha256 {before} -> {after}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
