#!/usr/bin/env python3
"""FBound18 probe 2: typed category for a non-canonical token carried by a
RETAINED receipt (not produced by this run's --observe).

Table row stays canonical (observed 3.15.1 / not-fired); only the retained
receipt record's parsed_version is a non-canonical token.
"""
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROW = "S040"
tree = Path(sys.argv[1]).resolve()
temp = Path(tempfile.mkdtemp(prefix="fb18b-"))
root = temp / "fx"
(root / "corpus").mkdir(parents=True)
for rel in ["SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py",
            "release-clocks.tsv"]:
    shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)

receipt = json.loads((tree / ".ufo" / "waves" / "round-26" /
                      "observe-2.json").read_text(encoding="utf-8"))
for record in receipt["observations"]:
    if record.get("id") == ROW:
        record["parsed_version"] = "3.15.01"   # non-canonical (leading zero)
        record["verdict"] = "not-fired"        # matches the table row
path = root / "receipt.json"
path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
sha = hashlib.sha256(path.read_bytes()).hexdigest()
proc = subprocess.run(
    ["python3", "-I", "-B", str(tree / "corpus" / "release-clock.py"),
     "--root", str(root), "--receipt", str(path), "--receipt-sha", sha],
    cwd=str(tree), text=True, capture_output=True, timeout=120)
print("exit:", proc.returncode)
print(proc.stdout.strip())
print("stderr:", proc.stderr.strip()[:300])
shutil.rmtree(temp, ignore_errors=True)
