#!/usr/bin/env python3
"""Bounded selftest evidence for twelve separately copied BASE trees."""
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
BASE = ROOT / "base"
TARGET = Path("corpus/release-clock.py")
IDS = ["M%02d" % number for number in range(1, 13)]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def command(argv, cwd, environment, timeout):
    record = {"argv": [str(part) for part in argv], "cwd": str(cwd),
              "timeout_seconds": timeout}
    try:
        completed = subprocess.run(
            record["argv"], cwd=cwd, env=environment, capture_output=True,
            text=True, timeout=timeout, check=False,
        )
        record.update(exit=completed.returncode, stdout=completed.stdout,
                      stderr=completed.stderr, timed_out=False)
    except subprocess.TimeoutExpired as exc:
        def text(value):
            return value.decode("utf-8", errors="replace") if isinstance(value, bytes) else (value or "")
        record.update(exit=None, stdout=text(exc.stdout), stderr=text(exc.stderr), timed_out=True)
    return record


def measure(mutant_id):
    tree = ROOT / mutant_id
    temporary = tree / ".mutbase-tmp"
    temporary.mkdir(exist_ok=True)
    environment = dict(os.environ, TMPDIR=str(temporary), PYTHONDONTWRITEBYTECODE="1")
    record = {"id": mutant_id, "sha256_before": digest(tree / TARGET)}
    record["selftest"] = command(
        [sys.executable, "-I", "-B", TARGET, "--selftest"], tree, environment, 120,
    )
    record["witness"] = command(
        [sys.executable, "-I", "-B", ROOT / "witness.py", tree / TARGET], tree, environment, 30,
    )
    record["sha256_after"] = digest(tree / TARGET)
    return record


def measure_all():
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        return list(pool.map(measure, IDS))


def persist(name, payload):
    (ROOT / name).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def show(phase, records):
    for record in records:
        test = record["selftest"]
        print("%s %s exit=%r before=%s after=%s" % (
            phase, record["id"], test["exit"], record["sha256_before"], record["sha256_after"],
        ))
        print(test["stdout"], end="")
        if test["stderr"]:
            print(test["stderr"], end="")


phase = sys.argv[1]
base_hash = digest(BASE / TARGET)
metadata = {"base_commit": "3553d499577084a6c98d7078906017840bbf7b28",
            "base_sha256": base_hash, "python_version": platform.python_version(),
            "parallel_workers": 6, "phase": phase}
if phase == "baseline":
    copies = []
    for mutant_id in IDS:
        destination = ROOT / mutant_id
        if destination.exists():
            raise SystemExit("Refusing to replace an existing isolated tree: " + mutant_id)
        completed = subprocess.run(
            ["cp", "-a", "--reflink=auto", str(BASE), str(destination)], check=True,
        )
        copies.append({"id": mutant_id, "exit": completed.returncode})
    records = measure_all()
    metadata.update(copies=copies, records=records)
    persist("baseline.json", metadata)
    show("pristine", records)
    raise SystemExit(0 if all(record["selftest"]["exit"] == 0 for record in records) else 1)
if phase != "mutated":
    raise SystemExit("Expected baseline or mutated")
mutated_records = []
restore_commands = []
try:
    mutated_records = measure_all()
finally:
    for mutant_id in IDS:
        target = ROOT / mutant_id / TARGET
        result = subprocess.run(["cp", "--reflink=auto", str(BASE / TARGET), str(target)], check=False)
        restore_commands.append({"id": mutant_id, "exit": result.returncode,
                                 "sha256": digest(target),
                                 "exact_bytes": target.read_bytes() == (BASE / TARGET).read_bytes()})
    metadata.update(mutated=mutated_records, restoration=restore_commands)
    persist("mutated-restored.json", metadata)
restored_records = measure_all()
metadata["restored"] = restored_records
persist("mutated-restored.json", metadata)
show("mutated", mutated_records)
show("restored", restored_records)
raise SystemExit(0 if all(record["exact_bytes"] for record in restore_commands)
                 and all(record["selftest"]["exit"] == 0 for record in restored_records) else 1)
