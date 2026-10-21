#!/usr/bin/env python3
"""FDeriveRaised attack harness (round-28 falsify wave).

Carrier under attack: corpus/release-clock.py C2 rule (derived anchor bound to
its feed registry row's located anchor).

Attack: raise a derived row's anchored_version ABOVE the version named by its
feed_source_id registry row's located anchor in corpus/SOURCES.md, and set the
observation to match the raised (canonical) anchor, verdict not-fired.

The default receipt pins every table row's observation, so the edited rows'
receipt records are mirrored into a copy of the default receipt and the run
uses --receipt <copy> --receipt-sha <sha>, exactly as the frozen c2-measure.py
does.  A generic RECEIPT-MISMATCH is therefore NOT available as proof: the
mirror removes it, so any finding that remains is the derivation rule.

No network.  Only the exported candidate tree and the BASE archive are read.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile

LANE = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
CANDIDATE = "62a33b1bd15217ed729df2ca40c8a30aba3076c0"
BASE = "3553d499577084a6c98d7078906017840bbf7b28"
SANDBOX = Path(__file__).resolve().parent.parent
WORK = Path(__file__).resolve().parent

# Raised groups: feed registry row -> derived rows -> version ABOVE the
# version that row's located anchor names.
GROUPS = {
    "R1": {"feed": "S033", "rows": ["S008", "S009", "S010", "S011"], "raise": "3.13.4"},
    "R2": {"feed": "S034", "rows": ["S013", "S022", "S023", "S024"], "raise": "2.2.1"},
    "R3": {"feed": "S035", "rows": ["S014", "S015", "S016", "S021", "S025", "S026"],
           "raise": "2.7.2"},
    "R4": {"feed": "S037", "rows": ["S029"], "raise": "8.23.1"},
}

ID_RE = re.compile(r"(?<![A-Za-z0-9])S[0-9]{3}(?![0-9])")
DEFAULT_RECEIPT_RE = re.compile(
    r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")')
BASE_CATEGORIES = {"ORPHAN", "UNBOUND", "INCONSISTENT", "BADFEED", "REGRESSED",
                   "NOT OBSERVED", "RECEIPT-MISMATCH"}


def extract(rev, dest):
    dest.mkdir(parents=True, exist_ok=True)
    proc = subprocess.Popen(["git", "-C", str(LANE), "archive", "--format=tar", rev],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    with tarfile.open(fileobj=proc.stdout, mode="r|") as tar:
        tar.extractall(dest)
    _, err = proc.communicate()
    if proc.returncode != 0:
        raise SystemExit("git archive %s failed: %s"
                         % (rev, err.decode("utf-8", "replace").strip()))
    return dest


def parse_findings(stdout):
    lines = stdout.splitlines()
    tails = [i for i, line in enumerate(lines) if line.startswith("RELEASE_CLOCK:")]
    body = lines[:tails[-1]] if tails else lines
    out = []
    for line in body:
        if not line.strip():
            continue
        match = ID_RE.search(line)
        out.append({
            "line": line,
            "category": line[:match.start()].strip() if match else None,
            "ids": ID_RE.findall(line),
        })
    return out


def build_fixture(clone, name, spec, dest, mirror_receipt):
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "corpus").mkdir(exist_ok=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copyfile(clone / "corpus" / rel, dest / "corpus" / rel)
    code = (clone / "corpus" / "release-clock.py").read_text(encoding="utf-8")
    match = DEFAULT_RECEIPT_RE.search(code)
    if not match:
        raise SystemExit("cannot locate the default receipt path")
    receipt_rel = "/".join(p.strip('" ') for p in match.group(1).split("/"))
    default_receipt = clone / receipt_rel
    if not default_receipt.is_file():
        raise SystemExit("default receipt %s missing" % receipt_rel)
    receipt = json.loads(default_receipt.read_text(encoding="utf-8"))

    group = list(spec["rows"])
    lines = (clone / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    edited = []
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields[0] not in group:
            continue
        if fields[2] != spec["feed"] or not fields[8].startswith("derived:"):
            raise SystemExit("%s is not a derived row on feed %s"
                             % (fields[0], spec["feed"]))
        fields[4] = spec["raise"]      # anchored_version raised above the feed anchor
        fields[5] = spec["raise"]      # matching canonical observation
        fields[7] = "not-fired"
        lines[index] = "\t".join(fields) + "\n"
        edited.append(fields[0])
    if sorted(edited) != sorted(group):
        raise SystemExit("edited %s, expected %s" % (edited, group))
    (dest / "corpus" / "release-clocks.tsv").write_text("".join(lines), encoding="utf-8")

    receipt_path = None
    mirrored = []
    if mirror_receipt:
        for record in receipt["observations"]:
            if record.get("id") in group:
                record["parsed_version"] = spec["raise"]
                record["verdict"] = "not-fired"
                mirrored.append(record["id"])
        if sorted(mirrored) != sorted(group):
            raise SystemExit("mirrored %s, expected %s" % (mirrored, group))
        receipt_path = dest / "receipt.json"
        receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    else:
        # no mirror: use the clone's own default receipt verbatim, so the
        # generic RECEIPT-MISMATCH path is visible instead of NOT OBSERVED.
        receipt_path = default_receipt
    return edited, mirrored, receipt_path


def run(argv, cwd):
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"),
           "HOME": str(cwd), "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}
    return subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                          capture_output=True, timeout=180)


def classify(proc, group, edited, mirrored, control_fired):
    stdout = proc.stdout
    stderr = proc.stderr
    lines = [l for l in stdout.splitlines() if l.strip()]
    last = lines[-1] if lines else ""
    findings = parse_findings(stdout)
    named = sorted({rid for item in findings for rid in item["ids"]})
    categories = sorted({item["category"] for item in findings if item["category"]})
    summary = last
    m = re.search(r"observed=(\d+) fired=(\d+) derived=(\d+)", summary)
    fired = int(m.group(2)) if m else None
    observed = int(m.group(1)) if m else None
    derivation_rows = sorted({rid for item in findings
                               if item["category"] == "DERIVATION" for rid in item["ids"]})
    receipt_mismatch_rows = sorted({rid for item in findings
                                     if item["category"] == "RECEIPT-MISMATCH"
                                     for rid in item["ids"]})
    verdict = {
        "exit": proc.returncode,
        "last_line": last,
        "findings": [item["line"] for item in findings],
        "categories": categories,
        "named_ids": named,
        "derivation_rows": derivation_rows,
        "receipt_mismatch_rows": receipt_mismatch_rows,
        "traceback": ("Traceback" in stdout) or ("Traceback" in stderr),
        "stderr": stderr,
        "observed": observed,
        "fired": fired,
        "derived": None,
    }
    verdict["typed_derivation"] = (
        proc.returncode == 1
        and not verdict["traceback"]
        and last.startswith("RELEASE_CLOCK: FAILED")
        and derivation_rows == sorted(group)
        and not (set(receipt_mismatch_rows) & set(group))
    )
    verdict["no_fired_event"] = (fired is not None and control_fired is not None
                                 and fired <= control_fired)
    return verdict


def main():
    out_path = WORK / "raise-results.json"
    cand = WORK / "clone-candidate"
    base = WORK / "clone-base"
    if not cand.exists():
        extract(CANDIDATE, cand)
    if not base.exists():
        extract(BASE, base)

    results = {"candidate": CANDIDATE, "base": BASE, "groups": {}}

    for label, clone in (("candidate", cand), ("base", base)):
        control = run(["python3", "-I", "-B", "corpus/release-clock.py"], clone)
        clines = [l for l in control.stdout.splitlines() if l.strip()]
        cm = re.search(r"fired=(\d+)", clines[-1] if clines else "")
        control_fired = int(cm.group(1)) if cm else None
        results[label + "_control"] = {
            "argv": control.args, "exit": control.returncode,
            "stdout": control.stdout, "stderr": control.stderr,
            "last_line": clines[-1] if clines else "", "fired": control_fired,
        }
        for name, spec in sorted(GROUPS.items()):
            for mirror in (True, False):
                tag = "%s-%s-%s" % (name, "mirror" if mirror else "nomirror",
                                    label)
                dest = WORK / "run" / tag
                if dest.exists():
                    shutil.rmtree(dest)
                edited, mirrored, receipt_path = build_fixture(
                    clone, name, spec, dest, mirror)
                argv = ["python3", "-I", "-B", str(clone / "corpus" / "release-clock.py"),
                        "--root", str(dest)]
                if receipt_path is not None:
                    argv += ["--receipt", str(receipt_path),
                             "--receipt-sha",
                             hashlib.sha256(receipt_path.read_bytes()).hexdigest()]
                proc = run(argv, clone)
                v = classify(proc, spec["rows"], edited, mirrored, control_fired)
                v.update({"argv": argv, "edited_rows": edited,
                          "mirrored_rows": mirrored, "raised_to": spec["raise"],
                          "feed": spec["feed"], "stdout": proc.stdout})
                results["groups"][tag] = v

    out_path.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    for tag in sorted(results["groups"]):
        v = results["groups"][tag]
        print("%-28s exit=%s typed_derivation=%s no_fired=%s fired=%s findings=%s"
              % (tag, v["exit"], v["typed_derivation"], v["no_fired_event"],
                 v["fired"], v["findings"]))
    for label in ("candidate", "base"):
        c = results[label + "_control"]
        print("%-9s control exit=%s last=%s" % (label, c["exit"], c["last_line"]))
    print("wrote", out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
