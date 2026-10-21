#!/usr/bin/env python3
"""Independent reproduction of round-28 C2 fixture G4 (curl feed S037, row S029).

Builds its own fixture roots from an exported tree; never touches the lane
checkout. Every run is offline (--receipt only; no --observe, no network).
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

SB = Path(__file__).resolve().parent
# heavy trees live under /fast/scratch per the round scratch directive
HEAVY = Path("/fast/scratch/hyaku/kagi-r28/FDeriveCurl")
WORK = HEAVY if HEAVY.is_dir() else SB
CLONES = {"cand": WORK / "cand", "base": WORK / "base"}
HEADER_FIELDS = 9
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
REVS = {"cand": "62a33b1bd15217ed729df2ca40c8a30aba3076c0",
        "base": "3553d499577084a6c98d7078906017840bbf7b28"}


def ensure_clones():
    """Re-create the exported trees if they were deleted (read-only git archive)."""
    import tarfile
    for name, rev in REVS.items():
        dest = CLONES[name]
        if (dest / "corpus" / "release-clock.py").is_file():
            continue
        dest.mkdir(parents=True, exist_ok=True)
        proc = subprocess.run(["git", "-C", LANE, "archive", "--format=tar", rev],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if proc.returncode != 0:
            raise SystemExit("git archive %s failed: %s" % (rev, proc.stderr.decode()))
        with tarfile.open(fileobj=__import__("io").BytesIO(proc.stdout)) as tar:
            tar.extractall(dest)


def build_fixture(clone: Path, root: Path, row_id: str, feed_id: str,
                  lower: str | None, mirror: bool, verdict: str = "not-fired"):
    if root.exists():
        shutil.rmtree(root)
    shutil.copytree(clone / "corpus", root / "corpus")
    tsv = root / "corpus" / "release-clocks.tsv"
    lines = tsv.read_text(encoding="utf-8").splitlines(keepends=True)
    edited = []
    for i, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] != row_id:
            continue
        assert fields[2] == feed_id, (fields[0], fields[2])
        assert fields[8].startswith("derived:"), fields[8]
        if lower is not None:
            fields[4] = lower          # anchored_version
            fields[5] = lower          # observed_version
            fields[7] = verdict
        lines[i] = "\t".join(fields) + "\n"
        edited.append(fields[0])
    assert edited == [row_id], edited
    tsv.write_text("".join(lines), encoding="utf-8")
    receipt_src = clone / ".ufo" / "waves" / "round-26" / "observe-2.json"
    receipt = json.loads(receipt_src.read_text(encoding="utf-8"))
    if mirror and lower is not None:
        for rec in receipt["observations"]:
            if rec.get("id") == row_id:
                rec["parsed_version"] = lower
                rec["verdict"] = verdict
    rpath = root / "receipt.json"
    rpath.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return rpath


def run(clone: Path, root: Path, rpath: Path, label: str):
    argv = ["python3", "-I", "-B", str(clone / "corpus" / "release-clock.py"),
            "--root", str(root), "--receipt", str(rpath),
            "--receipt-sha", hashlib.sha256(rpath.read_bytes()).hexdigest()]
    before = sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file())
    proc = subprocess.run(argv, cwd=clone, text=True, capture_output=True, timeout=180,
                          env={"PATH": os.environ.get("PATH", "/usr/bin:/bin"),
                               "HOME": str(root), "LC_ALL": "C",
                               "PYTHONDONTWRITEBYTECODE": "1"})
    after = sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file())
    out = proc.stdout.splitlines()
    tail = out[-1] if out else ""
    findings = [l for l in out if l.strip() and not l.startswith("RELEASE_CLOCK:")]
    return {
        "case": label, "argv": " ".join(argv), "exit": proc.returncode,
        "stdout": proc.stdout, "stderr": proc.stderr,
        "traceback": "Traceback" in proc.stdout or "Traceback" in proc.stderr,
        "last_line": tail, "findings": findings,
        "files_written": [p for p in after if p not in before],
    }


def show(r):
    print("=" * 78)
    print("CASE", r["case"], "exit", r["exit"], "traceback", r["traceback"])
    print("argv:", r["argv"])
    print("stdout:")
    for line in r["stdout"].splitlines():
        print("   |", line)
    if r["stderr"].strip():
        print("stderr:")
        for line in r["stderr"].splitlines():
            print("   !", line)
    print("files_written:", r["files_written"])
    print("last:", r["last_line"])


def main():
    ensure_clones()
    results = []
    scenarios = [
        ("G4-lowered-8.22.0-mirrored", "8.22.0", True),
        ("G4-lowered-8.10.0-mirrored", "8.10.0", True),
        ("G4-lowered-8.22.0-unmirrored-receipt", "8.22.0", False),
    ]
    for which, clone in CLONES.items():
        # control: unmodified tree, default receipt
        ctl = run(clone, clone, clone / ".ufo" / "waves" / "round-26" / "observe-2.json",
                  "%s-control-default" % which)
        show(ctl)
        results.append(ctl)
        for label, lower, mirror in scenarios:
            root = WORK / ("fixture-%s-%s" % (which, lower.replace(".", "_")))
            rpath = build_fixture(clone, root, "S029", "S037", lower, mirror)
            r = run(clone, root, rpath, "%s-%s" % (which, label))
            show(r)
            results.append(r)
    (SB / "results.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print("results written to", SB / "results.json")


if __name__ == "__main__":
    main()
