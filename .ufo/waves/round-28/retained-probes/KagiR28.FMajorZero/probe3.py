#!/usr/bin/env python3
"""V7: a derived row whose ANCHOR carries a major-component leading zero."""
import os
import shutil
import sys
import tempfile
from pathlib import Path

import probe

c1 = probe.c1
ROW = "S008"


def main():
    trees = {"cand": Path(sys.argv[1]).resolve(), "base": Path(sys.argv[2]).resolve()}
    for label, tree in trees.items():
        temp = Path(tempfile.mkdtemp(prefix="kagi-r28-fmj3-%s-" % label))
        try:
            env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
                   "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
            result = probe.table_case(
                tree, temp, env, "v7", {ROW: {4: "03.13.3", 5: "03.13.3", 7: "not-fired"}})
            print("=" * 70)
            print("%s V7-derived-anchor-03.13.3 exit=%s verdict=%s traceback=%s" % (
                label, result["exit"], result.get("verdict"),
                result.get("traceback_in_output")))
            print(result["stdout"].rstrip())
            if result.get("stderr"):
                print("[stderr] " + result["stderr"].rstrip())
        finally:
            shutil.rmtree(temp, ignore_errors=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
