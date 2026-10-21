#!/usr/bin/env python3
"""Round-27 claim-only overlays: each claim measured with the other absent.

separability.py MEASURED_REV OUT.json

c1-only: BASE + C1 data/docs from MEASURED_REV (self-counts.tsv and the bound
         knowledge entries); C2's release-clock.py stays at BASE.
         Measured: self-counts over the overlay (knowledge STALE ids must be
         empty) and the BASE release-clock selftest/downgrade fixtures
         (still accepted: C1 does not cause C2).
c2-only: BASE + corpus/release-clock.py from MEASURED_REV; C1 table/docs at
         BASE. Measured: downgrade fixtures (exact REGRESSED sets) and the
         clock selftest; self-counts at BASE carries no KN-* bindings.
Every overlaid blob's SHA256 is recorded. The constructed trees are not
asserted to be full-ledger-clean commits (their shared bookkeeping pins stay
at BASE); only each claim's own counting command is run.
"""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

LANE = Path(__file__).resolve().parents[4]
BASE = "0a47dd189356ea66ec83c3891eed54526e95b89b"
C1_PATHS = ["corpus/self-counts.tsv"] + ["corpus/knowledge/%s.md" % n for n in (
    "adjacency-breadth", "adjacency-scope", "checklist-execution", "claim-ledger",
    "drift-gate", "op-ref-consumption", "surface-census", "substrate-deferral")]
C2_PATHS = ["corpus/release-clock.py"]


def load_c2():
    spec = importlib.util.spec_from_file_location("c2m", Path(__file__).with_name("c2-measure.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def overlay(temp, name, rev, paths, env):
    clone = temp / name / "kagi-shokunin"
    subprocess.run(["git", "clone", "--quiet", "--no-checkout", str(LANE), str(clone)], check=True, env=env)
    subprocess.run(["git", "-C", str(clone), "checkout", "--quiet", "--detach", BASE], check=True, env=env)
    blobs = {}
    for rel in paths:
        data = subprocess.check_output(["git", "-C", str(clone), "show", rev + ":" + rel], env=env)
        (clone / rel).write_bytes(data)
        blobs[rel] = hashlib.sha256(data).hexdigest()
    return clone, blobs


def run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=cwd, env=env, text=True, capture_output=True, timeout=1500)
    last = [line for line in proc.stdout.splitlines() if line.strip()][-1:] or [""]
    return {"argv": argv, "exit": proc.returncode, "last_line": last[0], "stdout": proc.stdout, "stderr": proc.stderr}


def main():
    if len(sys.argv) != 3 or not re.fullmatch(r"[0-9a-f]{40}", sys.argv[1]):
        raise SystemExit("usage: separability.py MEASURED_REV OUT.json")
    rev, out = sys.argv[1:]
    c2m = load_c2()
    result = {"format": "kagi-round27-separability-v1", "base": BASE, "measured_revision": rev}
    with tempfile.TemporaryDirectory(prefix="kagi-r27-sep-", dir="/fast/scratch") as temp:
        temp = Path(temp)
        env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
               "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
        clone, blobs = overlay(temp, "c1", rev, C1_PATHS, env)
        counts = run(["python3", "-I", "-B", "corpus/self-counts.py"], clone, env)
        knowledge_ids = [l.split("\t")[0] for l in (clone / "corpus/self-counts.tsv").read_text().splitlines()
                         if l.startswith("KN-")]
        stale = re.findall(r"^(?:STALE|UNLOCATED|AMBIGUOUS) (\S+)", counts["stdout"], re.M)
        fixtures = c2m.measure_clone(clone, temp / "c1", env)
        result["c1_only"] = {"overlaid": blobs, "self_counts": counts, "knowledge_bindings": len(knowledge_ids),
                             "stale_knowledge": [i for i in stale if i in knowledge_ids], "stale_all": stale,
                             "clock_selftest": run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"], clone, env),
                             "downgrades_accepted_clean": sum(fixtures[n]["accepted_clean"] for n in c2m.DOWNGRADES)}
        clone, blobs = overlay(temp, "c2", rev, C2_PATHS, env)
        fixtures = c2m.measure_clone(clone, temp / "c2", env)
        counts = run(["python3", "-I", "-B", "corpus/self-counts.py"], clone, env)
        result["c2_only"] = {"overlaid": blobs,
                             "downgrades_accepted_clean": sum(fixtures[n]["accepted_clean"] for n in c2m.DOWNGRADES),
                             "downgrades_regressed_exact": sum(fixtures[n]["regressed_exact"] for n in c2m.DOWNGRADES),
                             "control_clean": fixtures["control"]["accepted_clean"],
                             "default": fixtures["default"],
                             "clock_selftest": run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"], clone, env),
                             "self_counts": counts,
                             "knowledge_bindings": sum(1 for l in (clone / "corpus/self-counts.tsv").read_text().splitlines() if l.startswith("KN-"))}
    Path(out).write_text(json.dumps(result, indent=2) + "\n")
    c1, c2 = result["c1_only"], result["c2_only"]
    print("SEPARABILITY c1-only: knowledge=%d stale_knowledge=%d clock_selftest=%r downgrades_accepted=%d/4"
          % (c1["knowledge_bindings"], len(c1["stale_knowledge"]), c1["clock_selftest"]["last_line"], c1["downgrades_accepted_clean"]))
    print("SEPARABILITY c2-only: regressed_exact=%d/4 accepted=%d/4 control_clean=%s selftest=%r knowledge=%d self_counts=%r"
          % (c2["downgrades_regressed_exact"], c2["downgrades_accepted_clean"], c2["control_clean"],
             c2["clock_selftest"]["last_line"], c2["knowledge_bindings"], c2["self_counts"]["last_line"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
