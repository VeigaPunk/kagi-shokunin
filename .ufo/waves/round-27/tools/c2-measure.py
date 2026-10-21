#!/usr/bin/env python3
"""Round-27 C2 counting instrument: does a numeric downgrade get accepted?

c2-measure.py REV LABEL OUT.json

In a scratch clone at REV, builds five fixtures from the clone's own active
binding table and default receipt (fixtures change ONLY the named rows;
`unfire` and `nonnumeric` were added after CritC2Rollback/CritC2NonNumeric):
  lie       S040 observed 3.15.0 < anchor 3.15.1, verdict fired (table + receipt)
  rollback  the whole Python feed regresses to 3.15.0 with the BASE inequality
            semantics a fresh --observe would record: S027/S028 (anchor 3.15.0)
            not-fired = silently un-fired; S040/S041 (anchor 3.15.1) fired
  control   unchanged copies (must stay CLEAN)
"""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

LANE = Path(__file__).resolve().parents[4]
FIXTURES = {
    "lie": {"S040": ("3.15.0", "fired")},
    "rollback": {"S027": ("3.15.0", "not-fired"), "S028": ("3.15.0", "not-fired"),
                 "S040": ("3.15.0", "fired"), "S041": ("3.15.0", "fired")},
    "unfire": {"S027": ("3.15.0", "not-fired"), "S028": ("3.15.0", "not-fired")},
    "nonnumeric": {"S012": ("1.20.0", "fired")},
    "control": {},
}
DOWNGRADES = ("lie", "rollback", "unfire", "nonnumeric")
# independent literals, never imported from the gate: the exact REGRESSED set
# each downgrade fixture must produce once the round-27 rule is in force
EXPECTED_REGRESSED = {"lie": ["S040"], "rollback": ["S027", "S028", "S040", "S041"],
                      "unfire": ["S027", "S028"], "nonnumeric": ["S012"]}


def measure_clone(clone, temp, env):
    """Run every fixture against the clone's own release-clock.py, table and default receipt."""
    results = {}
    code = (clone / "corpus/release-clock.py").read_text()
    default = re.search(r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")', code).group(1)
    receipt_rel = "/".join(part.strip('" ') for part in default.split("/"))
    for name, edits in FIXTURES.items():
        root = temp / ("fixture-" + name)
        (root / "corpus").mkdir(parents=True)
        for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
            shutil.copy2(clone / "corpus" / rel, root / "corpus" / rel)
        lines = (clone / "corpus/release-clocks.tsv").read_text().splitlines(keepends=True)
        changed = []
        for index, line in enumerate(lines):
            fields = line.rstrip("\n").split("\t")
            if fields[0] in edits:
                fields[5], fields[7] = edits[fields[0]]
                lines[index] = "\t".join(fields) + "\n"
                changed.append(fields[0])
        (root / "corpus/release-clocks.tsv").write_text("".join(lines))
        receipt = json.loads((clone / receipt_rel).read_text())
        for record in receipt["observations"]:
            if record["id"] in edits:
                record["parsed_version"], record["verdict"] = edits[record["id"]]
        receipt_path = root / "receipt.json"
        receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
        sha = hashlib.sha256(receipt_path.read_bytes()).hexdigest()
        argv = ["python3", "-I", "-B", str(clone / "corpus/release-clock.py"), "--root", str(root),
                "--receipt", str(receipt_path), "--receipt-sha", sha]
        proc = subprocess.run(argv, cwd=clone, env=env, text=True, capture_output=True, timeout=120)
        last = [line for line in proc.stdout.splitlines() if line.strip()][-1:] or [""]
        findings = [line for line in proc.stdout.splitlines() if line and not line.startswith("RELEASE_CLOCK:")]
        regressed = sorted(re.findall(r"^REGRESSED (S[0-9]+)$", proc.stdout, re.M))
        results[name] = {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
                         "stderr": proc.stderr, "last_line": last[0], "changed_rows": changed,
                         "findings": findings, "regressed_findings": regressed,
                         "accepted_clean": proc.returncode == 0 and last[0].startswith("RELEASE_CLOCK: CLEAN"),
                         "regressed_exact": (name in EXPECTED_REGRESSED and proc.returncode == 1
                                             and findings == ["REGRESSED " + i for i in EXPECTED_REGRESSED[name]])}
    default_proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py"], cwd=clone, env=env,
                                  text=True, capture_output=True, timeout=120)
    results["default"] = {"exit": default_proc.returncode, "stdout": default_proc.stdout}
    return results


def main():
    if len(sys.argv) != 4 or not re.fullmatch(r"[0-9a-f]{40}", sys.argv[1]):
        raise SystemExit("usage: c2-measure.py FULL_REV LABEL OUT.json")
    rev, label, out = sys.argv[1:]
    with tempfile.TemporaryDirectory(prefix="kagi-r27-c2-", dir="/fast/scratch") as temp:
        temp = Path(temp)
        env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
               "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
        clone = temp / "clone"
        subprocess.run(["git", "clone", "--quiet", "--no-checkout", str(LANE), str(clone)], check=True, env=env)
        subprocess.run(["git", "-C", str(clone), "checkout", "--quiet", "--detach", rev], check=True, env=env)
        results = measure_clone(clone, temp, env)
    accepted = sum(results[name]["accepted_clean"] for name in DOWNGRADES)
    exact = sum(results[name]["regressed_exact"] for name in DOWNGRADES)
    summary = {"format": "kagi-round27-c2-measure-v1", "revision": rev, "label": label,
               "downgrades_accepted_clean": accepted, "downgrades_regressed_exact": exact,
               "downgrade_fixtures": len(DOWNGRADES),
               "control_clean": results["control"]["accepted_clean"], "results": results}
    Path(out).write_text(json.dumps(summary, indent=2) + "\n")
    print("C2_MEASURE %s: downgrades_accepted_clean=%d/%d regressed_exact=%d/%d control_clean=%s default_exit=%d" % (
        label, accepted, len(DOWNGRADES), exact, len(DOWNGRADES),
        results["control"]["accepted_clean"], results["default"]["exit"]))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
