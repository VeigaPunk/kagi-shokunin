#!/usr/bin/env python3
"""Round-29 C2 counting instrument (frozen counting command, plans/round-29.md C2
as corrected by plans/round-29.md Correction 1: child processes run
sys.executable; on a POSIX host the same tool bytes run unchanged).

c2-measure.py REV LABEL OUT.json

Exports REV's tree (git archive; the lane checkout is never touched) and the
frozen BASE `c49023b773b69de983f0e6eb7e5867ceb5c2c634` tree, then measures:

  M1  the gate exists in REV's tree and is runnable:
      `feed-token-agree.py --help` exits 0;
  M2  `feed-token-agree.py --selftest` exits 0 with PASS (the seeded
      divergence is caught -- the gate is shown able to fail);
  M3  the gate's live run over REV's own instrument exits 0 with
      `FEED_TOKEN_AGREE: AGREE` and `disagreements=0`;
  M4  red-before witness: the REV gate run against the BASE instrument
      (`--instrument <c49023b>/corpus/release-clock.py`) exits 1 with
      DISAGREE naming the trailing-period suffix shape (the round-28 D1
      class) -- the gate is shown able to fail on the pre-fix extractors.

The four measures are the frozen booleans of plans/round-29.md C2; the run
passes (exit 0) only when all four hold. Every boolean, its argv, its exit
and its output tails are written to OUT.json whatever the verdict.

Summary line:  C2_MEASURE <label>: m1=%d m2=%d m3=%d m4=%d  (exit 0 iff 1/1/1/1)
"""
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

LANE = Path(__file__).resolve().parents[4]
BASE_REV = "c49023b773b69de983f0e6eb7e5867ceb5c2c634"
GATE_REL = "corpus/feed-token-agree.py"


def export(rev, dest):
    """Sparse projection: corpus/** only (plans/round-29.md Correction 2 --
    a full extractall collides on NTFS; the gate reads corpus files only).
    A case-colliding pair inside the projection aborts loudly."""
    archive = subprocess.run(
        ["git", "-C", str(LANE), "archive", "--format=tar", rev],
        capture_output=True, timeout=300)
    if archive.returncode != 0:
        raise RuntimeError("git archive %s failed: %s"
                           % (rev, archive.stderr.decode().strip()))
    tree = Path(dest)
    tree.mkdir(parents=True)
    extracted = set()
    with tarfile.open(fileobj=io.BytesIO(archive.stdout)) as tar:
        for member in tar.getmembers():
            if member.name != "corpus" and not member.name.startswith("corpus/"):
                continue
            if member.isdir():
                continue
            key = member.name.casefold()
            if key in extracted:
                raise RuntimeError(
                    "case-colliding paths inside export: %s" % member.name)
            extracted.add(key)
            (tree / member.name).parent.mkdir(parents=True, exist_ok=True)
            tar.extract(member, tree, filter="data")
    return tree


def child_run(argv, cwd, env):
    proc = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=300)
    return {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
            "stderr": proc.stderr}


def tails(text, count=8):
    lines = text.splitlines()
    return lines[-count:]


def measure(rev, label, out):
    temp = Path(tempfile.mkdtemp(prefix="kagi-r29-c2-"))
    try:
        tree = export(rev, temp / "tree")
        base_tree = export(BASE_REV, temp / "base")
        env = {
            "PATH": os.environ.get("PATH", ""),
            "HOME": str(temp),
            "LC_ALL": "C",
            "PYTHONDONTWRITEBYTECODE": "1",
            "SYSTEMROOT": os.environ.get("SYSTEMROOT", ""),
        }
        gate = tree / GATE_REL
        measures = {}

        m1 = (gate.is_file()
              and child_run([sys.executable, "-I", "-B", str(gate), "--help"],
                            cwd=tree, env=env)["exit"] == 0)
        m1_run = (child_run([sys.executable, "-I", "-B", str(gate), "--help"],
                            cwd=tree, env=env) if gate.is_file()
                  else {"argv": None, "exit": None, "stdout": "", "stderr":
                        "gate file absent"})
        measures["M1_gate_present_runnable"] = {
            "value": bool(m1), "evidence": {
                k: (tails(v) if isinstance(v, str) else v)
                for k, v in m1_run.items()}}

        m2_run = (child_run([sys.executable, "-I", "-B", str(gate), "--selftest"],
                            cwd=tree, env=env) if gate.is_file()
                  else {"argv": None, "exit": None, "stdout": "",
                        "stderr": "gate file absent"})
        m2 = (m2_run["exit"] == 0
              and "FEED_TOKEN_AGREE_SELFTEST: PASS" in m2_run["stdout"])
        measures["M2_selftest_catches_seeded_divergence"] = {
            "value": bool(m2), "evidence": {
                k: (tails(v) if isinstance(v, str) else v)
                for k, v in m2_run.items()}}

        m3_run = (child_run([sys.executable, "-I", "-B", str(gate)],
                            cwd=tree, env=env) if gate.is_file()
                  else {"argv": None, "exit": None, "stdout": "",
                        "stderr": "gate file absent"})
        m3 = (m3_run["exit"] == 0
              and "FEED_TOKEN_AGREE: AGREE" in m3_run["stdout"]
              and "disagreements=0" in m3_run["stdout"])
        measures["M3_live_run_agree"] = {
            "value": bool(m3), "evidence": {
                k: (tails(v) if isinstance(v, str) else v)
                for k, v in m3_run.items()}}

        m4_run = (child_run([sys.executable, "-I", "-B", str(gate),
                             "--instrument",
                             str(base_tree / "corpus" / "release-clock.py")],
                            cwd=tree, env=env) if gate.is_file()
                  else {"argv": None, "exit": None, "stdout": "",
                        "stderr": "gate file absent"})
        m4 = (m4_run["exit"] == 1
              and "FEED_TOKEN_AGREE: DISAGREE" in m4_run["stdout"]
              and "shape=trailing-period" in m4_run["stdout"])
        measures["M4_red_before_base_instrument_disagrees"] = {
            "value": bool(m4), "base_revision": BASE_REV, "evidence": {
                k: (tails(v) if isinstance(v, str) else v)
                for k, v in m4_run.items()}}

        document = {
            "format": "kagi-round29-c2-measure-v1",
            "revision": rev,
            "label": label,
            "extraction": {
                "mode": "sparse-corpus",
                "reason": "plans/round-29.md Correction 2 (NTFS case collision)",
            },
            "measures": measures,
        }
        Path(out).parent.mkdir(parents=True, exist_ok=True)
        Path(out).write_text(json.dumps(document, indent=2) + "\n",
                             encoding="utf-8")
        values = [measures[k]["value"] for k in sorted(measures)]
        print("C2_MEASURE %s: m1=%d m2=%d m3=%d m4=%d" % (label, *values))
        return 0 if all(values) else 1
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def main():
    if len(sys.argv) != 4 or not re.fullmatch(r"[0-9a-f]{40}", sys.argv[1]):
        raise SystemExit("usage: c2-measure.py FULL_REV LABEL OUT.json")
    return measure(*sys.argv[1:4])


if __name__ == "__main__":
    raise SystemExit(main())
