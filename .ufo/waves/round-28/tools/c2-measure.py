#!/usr/bin/env python3
"""Round-28 C2 counting instrument: does lowering a feed's derived anchors get
accepted CLEAN, or rejected by typed derivation findings?

c2-measure.py REV LABEL OUT.json   (REV is a full 40-hex commit id)

Materializes REV's own tree read-only via `git archive` into a temp dir, then,
per feed carrying author-declared `derived:` anchor rows, builds one fixture
(G1..G4, frozen in plans/round-28.md §C2):

  G1  feed S033 SOPS:    S008 S009 S010 S011            3.13.3 -> 3.13.2
  G2  feed S034 Vault:   S013 S022 S023 S024            2.2.0  -> 2.1.9
  G3  feed S035 OpenBao: S014 S015 S016 S021 S025 S026  2.7.1  -> 2.7.0
  G4  feed S037 curl:    S029                           8.23.0 -> 8.22.0

A fixture edits ONLY the revision's corpus/release-clocks.tsv: every derived
row on that feed gets anchored_version lowered to the same canonical version,
observed_version set equal, verdict `not-fired`. Exactly those rows are
mirrored into a copy of the revision's default observation receipt (parsed_version
and verdict); the receipt copy is passed with --receipt/--receipt-sha as
round-27's tools/c2-measure.py did. SOURCES.md, the revision's code, and every
other table row and receipt record are untouched. A control run uses the
unmodified tree with the default command.

Predicate (frozen plans/round-28.md §C2):
- ACCEPTED when exit 0 and the last output line starts "RELEASE_CLOCK: CLEAN".
- EXACT  when exit 1, no traceback, and the typed derivation findings name
  exactly that group's row ids.

Finding-line extraction is generic because BASE has no derivation category.
Every non-empty stdout line before the final "RELEASE_CLOCK:" line is a
finding line; each line must carry >= one row id matching S[0-9]{3} (a line
without an id, or any id outside the group, fails EXACT), the union of named
ids must equal the group's ids exactly, and every line's category (the text
before its first id) must be OUTSIDE BASE's own categories -- ORPHAN, UNBOUND,
INCONSISTENT, BADFEED, REGRESSED, "NOT OBSERVED", RECEIPT-MISMATCH -- because
those are not derivation findings.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import tempfile

LANE = next((p for p in Path(__file__).resolve().parents
             if (p / "corpus" / "release-clock.py").is_file()
             and (p / "plans" / "round-28.md").is_file()), None)

GROUPS = {
    "G1": {"feed": "S033", "rows": ["S008", "S009", "S010", "S011"], "lower": "3.13.2"},
    "G2": {"feed": "S034", "rows": ["S013", "S022", "S023", "S024"], "lower": "2.1.9"},
    "G3": {"feed": "S035", "rows": ["S014", "S015", "S016", "S021", "S025", "S026"],
           "lower": "2.7.0"},
    "G4": {"feed": "S037", "rows": ["S029"], "lower": "8.22.0"},
}
BASE_CATEGORIES = {"ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
                   "NOT OBSERVED", "RECEIPT-MISMATCH"}
ID_RE = re.compile(r"(?<![A-Za-z0-9])S[0-9]{3}(?![0-9])")
DEFAULT_RECEIPT_RE = re.compile(
    r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")')


def run(argv, cwd, env, timeout=120):
    return subprocess.run(argv, cwd=cwd, env=env, text=True, capture_output=True,
                          timeout=timeout)


def extract_tree(rev, clone, env):
    proc = subprocess.Popen(["git", "-C", str(LANE), "archive", "--format=tar", rev],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    with tarfile.open(fileobj=proc.stdout, mode="r|") as tar:
        tar.extractall(clone)
    _out, err = proc.communicate()
    if proc.returncode != 0:
        raise SystemExit("c2-measure: git archive %s failed: %s"
                         % (rev, err.decode("utf-8", "replace").strip()))


def parse_findings(stdout):
    lines = stdout.splitlines()
    tails = [i for i, line in enumerate(lines) if line.startswith("RELEASE_CLOCK:")]
    findings = [line for line in lines[:tails[-1]] if line.strip()] if tails else \
               [line for line in lines if line.strip()]
    parsed = []
    for line in findings:
        match = ID_RE.search(line)
        parsed.append({
            "line": line,
            "category": line[:match.start()].strip() if match else None,
            "ids": ID_RE.findall(line),
        })
    return parsed


def classify(name, group, proc, edited, mirrored):
    stdout, stderr = proc.stdout, proc.stderr
    lines = [line for line in stdout.splitlines() if line.strip()]
    last = lines[-1] if lines else ""
    findings = parse_findings(stdout)
    named = sorted({rid for item in findings for rid in item["ids"]})
    accepted_clean = proc.returncode == 0 and last.startswith("RELEASE_CLOCK: CLEAN")
    exact = (
        proc.returncode == 1
        and "Traceback" not in stdout and "Traceback" not in stderr
        and last.startswith("RELEASE_CLOCK: FAILED")
        and bool(findings)
        and all(item["ids"] and item["category"] not in BASE_CATEGORIES
                for item in findings)
        and named == sorted(group)
    )
    return {
        "fixture": name, "group": group, "argv": proc.args, "exit": proc.returncode,
        "stdout": stdout, "stderr": stderr, "last_line": last,
        "findings": [item["line"] for item in findings],
        "finding_categories": [item["category"] for item in findings],
        "named_ids": named, "edited_rows": edited, "mirrored_rows": mirrored,
        "accepted_clean": accepted_clean, "derivation_exact": exact,
    }


def measure_clone(clone, temp, env):
    code = (clone / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    match = DEFAULT_RECEIPT_RE.search(code)
    if not match:
        raise SystemExit("c2-measure: cannot locate the default receipt path in "
                         "the revision's corpus/release-clock.py")
    receipt_rel = "/".join(part.strip('" ') for part in match.group(1).split("/"))
    default_receipt = clone / receipt_rel
    if not default_receipt.is_file():
        raise SystemExit("c2-measure: default receipt %s missing from the archive"
                         % receipt_rel)
    receipt = json.loads(default_receipt.read_text(encoding="utf-8"))
    if receipt.get("format") != "release-clock-observations-v1":
        raise SystemExit("c2-measure: default receipt has format %r"
                         % receipt.get("format"))

    table_lines = (clone / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)

    results = {}
    for name, spec in GROUPS.items():
        group = list(spec["rows"])
        root = temp / ("fixture-" + name)
        (root / "corpus").mkdir(parents=True)
        for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
            (root / "corpus" / rel).write_bytes(
                (clone / "corpus" / rel).read_bytes())
        edited = []
        lines = list(table_lines)
        for index, line in enumerate(lines):
            fields = line.rstrip("\n").split("\t")
            if fields[0] not in group:
                continue
            if fields[2] != spec["feed"] or not fields[8].startswith("derived:"):
                raise SystemExit("c2-measure: %s is not a derived row on feed %s"
                                 % (fields[0], spec["feed"]))
            fields[4] = spec["lower"]
            fields[5] = spec["lower"]
            fields[7] = "not-fired"
            lines[index] = "\t".join(fields) + "\n"
            edited.append(fields[0])
        if sorted(edited) != sorted(group):
            raise SystemExit("c2-measure: fixture %s edited %s, expected %s"
                             % (name, edited, group))
        (root / "corpus" / "release-clocks.tsv").write_text("".join(lines),
                                                            encoding="utf-8")
        receipt_copy = json.loads(json.dumps(receipt))
        mirrored = []
        for record in receipt_copy["observations"]:
            if record.get("id") in group:
                record["parsed_version"] = spec["lower"]
                record["verdict"] = "not-fired"
                mirrored.append(record["id"])
        if sorted(mirrored) != sorted(group):
            raise SystemExit("c2-measure: fixture %s mirrored %s, expected %s"
                             % (name, mirrored, group))
        receipt_path = root / "receipt.json"
        receipt_path.write_text(json.dumps(receipt_copy, indent=2) + "\n",
                                encoding="utf-8")
        argv = ["python3", "-I", "-B", str(clone / "corpus" / "release-clock.py"),
                "--root", str(root), "--receipt", str(receipt_path),
                "--receipt-sha", hashlib.sha256(receipt_path.read_bytes()).hexdigest()]
        results[name] = classify(name, group, run(argv, clone, env), edited, mirrored)

    control = run(["python3", "-I", "-B", "corpus/release-clock.py"], clone, env)
    control_lines = [line for line in control.stdout.splitlines() if line.strip()]
    results["control"] = {
        "fixture": "control", "argv": control.args, "exit": control.returncode,
        "stdout": control.stdout, "stderr": control.stderr,
        "last_line": control_lines[-1] if control_lines else "",
        "control_clean": (control.returncode == 0 and bool(control_lines)
                          and control_lines[-1].startswith("RELEASE_CLOCK: CLEAN")),
    }
    return results


def main():
    if len(sys.argv) != 4 or not re.fullmatch(r"[0-9a-f]{40}", sys.argv[1]):
        raise SystemExit("usage: c2-measure.py FULL_REV LABEL OUT.json")
    rev, label, out = sys.argv[1:]
    scratch = "/fast/scratch" if os.path.isdir("/fast/scratch") else None
    with tempfile.TemporaryDirectory(prefix="kagi-r28-c2-", dir=scratch) as tempdir:
        temp = Path(tempdir)
        env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
               "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
        clone = temp / "clone"
        clone.mkdir()
        extract_tree(rev, clone, env)
        results = measure_clone(clone, temp, env)
    names = sorted(GROUPS)
    accepted = sum(results[name]["accepted_clean"] for name in names)
    exact = sum(results[name]["derivation_exact"] for name in names)
    summary = {
        "format": "kagi-round28-c2-measure-v1", "revision": rev, "label": label,
        "groups_accepted_clean": accepted, "derivation_exact": exact,
        "group_fixtures": len(names), "control_clean": results["control"]["control_clean"],
        "results": results,
    }
    Path(out).write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print("C2_MEASURE %s: groups_accepted_clean=%d/%d derivation_exact=%d/%d "
          "control_clean=%s default_exit=%d"
          % (label, accepted, len(names), exact, len(names),
             results["control"]["control_clean"], results["control"]["exit"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
