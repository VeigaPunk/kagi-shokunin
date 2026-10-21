#!/usr/bin/env python3
"""C2 counting instrument (round 27): does release-clock refuse a downgraded feed?

usage: python3 c2-measure.py <rev> <label> [--expect auto|base|after] [--work DIR]

Stdlib only; never imports release-clock.py. Expectations come from the round-27
contract (BASE accepts the S040 downgrade as CLEAN; the candidate refuses it with a
REGRESSED S040 finding and does not count it as a release event) and from the R25-04
pin text in corpus/claim-ledger.tsv, which is read as data and never executed.

Steps: resolve <rev> in the lane repo; scratch-clone it at that commit; run the clone's
default offline check (no arguments) and match its summary to the R25-04 pin; build a
downgrade fixture (copy corpus/ and the current receipt; set S040 to observed 3.15.0 /
fired in the table and in its receipt record; re-digest the receipt); run the clone's
release-clock.py on that fixture with --root, --receipt and --receipt-sha; judge both
runs and write c2-measure.json into the work directory.

Writes only under the work directory (default: runs/ beside this script). The lane
repo is read only (rev-parse, clone) with git's global and system config disabled.
No network, no --observe, no host-private paths.
Exit: 0 PASS, 1 FAIL (expectation not met), 2 SETUP (could not measure).
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
BASE = "0a47dd189356ea66ec83c3891eed54526e95b89b"
SANDBOX = Path(__file__).resolve().parent
TARGET = "S040"
DOWNGRADE = "3.15.0"
SCRIPT_REL = "corpus/release-clock.py"
TABLE_REL = "corpus/release-clocks.tsv"
LEDGER_REL = "corpus/claim-ledger.tsv"
LEDGER_ROW = "R25-04"
RECEIPT_REL = ".ufo/waves/round-26/observe-2.json"
TABLE_FIELDS = ("id", "clock", "feed_url", "anchored_version", "observed_version",
                "observed_at", "verdict")
COUNT_KEYS = ("on_release", "bound", "unbound", "observed", "fired", "derived")
TIMEOUT_SECONDS = 300
FINDING_RE = re.compile(r"([A-Z][A-Z_-]*(?: [A-Z_-]+)*) (S[0-9]{3})(?![0-9])")
STATE_RE = re.compile(r"RELEASE_CLOCK: (CLEAN|FAILED|SETUP)\b")
COUNTS_RE = re.compile(r"on_release=(\d+) bound=(\d+) unbound=(\d+) observed=(\d+) "
                       r"fired=(\d+) derived=(\d+)")
NUMERIC_RE = re.compile(r"v?([0-9]+)\.([0-9]+)\.([0-9]+)")


class Setup(Exception):
    """The instrument could not measure: a precondition or the harness failed."""


def git(*args):
    env = dict(os.environ, GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1",
               GIT_TERMINAL_PROMPT="0")
    return subprocess.run(["git", *args], capture_output=True, encoding="utf-8",
                          errors="replace", env=env)


def sha256_file(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def numeric(version):
    """X.Y.Z as an int tuple, leading v allowed; None for any other shape."""
    match = NUMERIC_RE.fullmatch(version.strip())
    return tuple(int(part) for part in match.groups()) if match else None


def bare(version):
    return version.strip().lstrip("vV")


def resolve_rev(rev):
    result = git("-C", str(REPO), "rev-parse", "--verify", "--quiet", rev + "^{commit}")
    sha = result.stdout.strip()
    if result.returncode != 0 or not re.fullmatch(r"[0-9a-f]{40}", sha):
        raise Setup("cannot resolve %r to a commit in %s" % (rev, REPO))
    return sha


def scratch_clone(sha, work):
    clone = work / "clone"
    made = git("clone", "--quiet", "--no-checkout", "--no-hardlinks", str(REPO), str(clone))
    if made.returncode != 0:
        raise Setup("git clone failed: %s" % made.stderr.strip()[:300])
    if git("-C", str(clone), "cat-file", "-e", sha + "^{commit}").returncode != 0:
        fetched = git("-C", str(clone), "fetch", "--quiet", "--no-tags", str(REPO), sha)
        if fetched.returncode != 0:
            raise Setup("rev %s is not reachable: %s" % (sha, fetched.stderr.strip()[:300]))
    checked = git("-C", str(clone), "checkout", "--quiet", "--detach", sha)
    if checked.returncode != 0:
        raise Setup("checkout of %s failed: %s" % (sha, checked.stderr.strip()[:300]))
    return clone


def run_release_clock(argv, cwd, env):
    try:
        done = subprocess.run(argv, cwd=str(cwd), env=env, capture_output=True,
                              encoding="utf-8", errors="replace", timeout=TIMEOUT_SECONDS)
    except subprocess.TimeoutExpired:
        raise Setup("release-clock.py did not finish within %d s" % TIMEOUT_SECONDS)
    return {"argv": argv, "exit": done.returncode, "stdout": done.stdout, "stderr": done.stderr}


def parse_output(stdout):
    findings = []
    summary = None
    for line in stdout.splitlines():
        if line.startswith("RELEASE_CLOCK: "):
            summary = line
            continue
        match = FINDING_RE.match(line)
        if match:
            findings.append({"category": match.group(1), "id": match.group(2), "line": line})
    state = None
    counts = None
    if summary is not None:
        state_match = STATE_RE.match(summary)
        state = state_match.group(1) if state_match else None
        counts_match = COUNTS_RE.search(summary)
        if counts_match:
            counts = dict(zip(COUNT_KEYS, (int(value) for value in counts_match.groups())))
    return {"findings": findings, "summary": summary, "state": state, "counts": counts}


def ledger_pin(clone):
    for line in (clone / LEDGER_REL).read_text(encoding="utf-8").splitlines():
        columns = line.split("\t")
        if columns[0] == LEDGER_ROW:
            try:
                return {"command": columns[1], "pattern": columns[2], "exit": int(columns[3])}
            except (IndexError, ValueError):
                raise Setup("%s row in %s is malformed" % (LEDGER_ROW, LEDGER_REL))
    raise Setup("%s row not found in %s at rev" % (LEDGER_ROW, LEDGER_REL))


def pin_matches(pin, stdout):
    try:
        return re.search(pin["pattern"], stdout, re.MULTILINE) is not None
    except re.error:
        return False


def read_table(path):
    try:
        return path.read_bytes().decode("utf-8").splitlines(keepends=True)
    except UnicodeDecodeError:
        raise Setup("%s is not UTF-8" % TABLE_REL)


def target_row(lines):
    if not lines:
        raise Setup("%s is empty" % TABLE_REL)
    header = lines[0].rstrip("\r\n").split("\t")
    missing = [name for name in TABLE_FIELDS if name not in header]
    if missing:
        raise Setup("%s header lacks %s" % (TABLE_REL, ", ".join(missing)))
    hits = [position for position in range(1, len(lines))
            if lines[position].rstrip("\r\n").split("\t")[0] == TARGET]
    if len(hits) != 1:
        raise Setup("%s has %d %s rows, expected 1" % (TABLE_REL, len(hits), TARGET))
    fields = lines[hits[0]].rstrip("\r\n").split("\t")
    if len(fields) != len(header):
        raise Setup("%s row has %d fields, header has %d" % (TARGET, len(fields), len(header)))
    return hits[0], header, fields


def row_values(header, fields):
    return {name: fields[header.index(name)] for name in TABLE_FIELDS}


def check_downgrade_precondition(values):
    if values["clock"] != "feed":
        raise Setup("%s is not a feed clock row" % TARGET)
    anchor = numeric(values["anchored_version"])
    if anchor is None:
        raise Setup("%s anchor %r is not numeric X.Y.Z" % (TARGET, values["anchored_version"]))
    if not numeric(DOWNGRADE) < anchor:
        raise Setup("%s anchor %s is not above %s" % (TARGET, values["anchored_version"], DOWNGRADE))


def load_receipt(path):
    try:
        document = json.loads(path.read_bytes().decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        raise Setup("%s is not UTF-8 JSON" % RECEIPT_REL)
    observations = document.get("observations") if isinstance(document, dict) else None
    if not isinstance(observations, list):
        raise Setup("%s has no observations list" % RECEIPT_REL)
    hits = [record for record in observations
            if isinstance(record, dict) and record.get("id") == TARGET]
    if len(hits) != 1:
        raise Setup("%s has %d %s records, expected 1" % (RECEIPT_REL, len(hits), TARGET))
    return document, hits[0]


def check_receipt_agrees(record, values):
    """The rev's own receipt must agree with its table row, so only the lie differs."""
    observed_at = record.get("observed_at")
    if (record.get("clock") != "feed" or record.get("url") != values["feed_url"]
            or record.get("verdict") != values["verdict"]
            or not isinstance(observed_at, str) or observed_at[:10] != values["observed_at"]
            or bare(str(record.get("parsed_version"))) != bare(values["observed_version"])):
        raise Setup("%s receipt record at rev does not agree with its table row" % TARGET)


def build_fixture(clone, work):
    """Copy corpus/ and the current receipt, then forge the same S040 downgrade in both."""
    fixture = work / "fixture"
    shutil.copytree(clone / "corpus", fixture / "corpus")
    receipt_file = fixture / RECEIPT_REL
    receipt_file.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(clone / RECEIPT_REL, receipt_file)

    table_file = fixture / TABLE_REL
    original = read_table(table_file)
    position, header, fields = target_row(original)
    before = row_values(header, fields)
    check_downgrade_precondition(before)
    document, record = load_receipt(receipt_file)
    check_receipt_agrees(record, before)
    record_before = dict(record)

    ending = original[position][len(original[position].rstrip("\r\n")):]
    fields[header.index("observed_version")] = DOWNGRADE
    fields[header.index("verdict")] = "fired"
    forged = list(original)
    forged[position] = "\t".join(fields) + ending
    if len(forged) != len(original) or sum(a != b for a, b in zip(original, forged)) != 1:
        raise Setup("table forgery changed more than one line")
    table_file.write_bytes("".join(forged).encode("utf-8"))

    record["parsed_version"] = DOWNGRADE
    record["verdict"] = "fired"
    receipt_file.write_bytes(
        (json.dumps(document, indent=2, ensure_ascii=False) + "\n").encode("utf-8"))
    return {
        "root": fixture,
        "receipt": receipt_file,
        "table_line_before": original[position].rstrip("\r\n"),
        "table_line_after": forged[position].rstrip("\r\n"),
        "table_before": before,
        "table_after": row_values(header, fields),
        "record_before": record_before,
        "record_after": dict(record),
    }


def judge_default(run, parsed, pin, pin_ok):
    reasons = []
    if "Traceback" in run["stderr"]:
        reasons.append("default run crashed")
    if run["exit"] != pin["exit"]:
        reasons.append("default exit %s, pinned %s" % (run["exit"], pin["exit"]))
    if parsed["state"] != "CLEAN":
        reasons.append("default state %s, expected CLEAN" % parsed["state"])
    if parsed["findings"]:
        reasons.append("default printed %d finding line(s)" % len(parsed["findings"]))
    if not pin_ok:
        reasons.append("default summary does not match the %s pin" % LEDGER_ROW)
    return reasons


def judge_downgrade(mode, run, parsed, default_fired):
    refused = any(f["category"] == "REGRESSED" and f["id"] == TARGET
                  for f in parsed["findings"])
    fired = parsed["counts"]["fired"] if parsed["counts"] else None
    counted = None if fired is None or default_fired is None else fired > default_fired
    reasons = []
    if "Traceback" in run["stderr"]:
        reasons.append("downgrade run crashed")
    if mode == "base":
        if run["exit"] != 0:
            reasons.append("exit %s, expected 0 (accepted lie)" % run["exit"])
        if parsed["state"] != "CLEAN":
            reasons.append("state %s, expected CLEAN" % parsed["state"])
        if parsed["findings"]:
            reasons.append("findings printed at base; expected none")
        if counted is not True:
            reasons.append("lie not counted as a release event (fired %s, default %s)"
                           % (fired, default_fired))
    else:
        if run["exit"] != 1:
            reasons.append("exit %s, expected 1 (refusal)" % run["exit"])
        if parsed["state"] != "FAILED":
            reasons.append("state %s, expected FAILED" % parsed["state"])
        if not refused:
            reasons.append("no REGRESSED %s finding" % TARGET)
        if counted is not False:
            reasons.append("downgrade counted as a release event (fired %s, default %s)"
                           % (fired, default_fired))
    return reasons, {"refused": refused, "fired": fired, "counted_as_release": counted}


def describe(run, parsed, reasons):
    return {"argv": run["argv"], "exit": run["exit"], "state": parsed["state"],
            "summary": parsed["summary"], "findings": parsed["findings"],
            "stdout": run["stdout"], "stderr": run["stderr"], "reasons": reasons}


def measure(args):
    sha = resolve_rev(args.rev)
    mode = args.expect if args.expect != "auto" else ("base" if sha == BASE else "after")
    label = re.sub(r"[^A-Za-z0-9_.-]+", "_", args.label) or "run"
    if args.work:
        work = Path(args.work).resolve()
        try:
            work.mkdir(parents=True)
        except FileExistsError:
            raise Setup("work directory %s already exists" % work)
    else:
        runs = SANDBOX / "runs"
        runs.mkdir(parents=True, exist_ok=True)
        work = Path(tempfile.mkdtemp(prefix="%s-%s-" % (label, sha[:12]), dir=runs))
    home = work / "home"
    home.mkdir()
    clone = scratch_clone(sha, work)
    script = clone / SCRIPT_REL
    if not script.is_file():
        raise Setup("%s is missing at rev %s" % (SCRIPT_REL, sha))
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "LANG": "C.UTF-8",
           "LC_ALL": "C.UTF-8", "HOME": str(home), "PYTHONDONTWRITEBYTECODE": "1"}

    pin = ledger_pin(clone)
    default_run = run_release_clock([sys.executable, "-I", "-B", str(script)], clone, env)
    default = parse_output(default_run["stdout"])
    pin_ok = pin_matches(pin, default_run["stdout"])
    default_reasons = judge_default(default_run, default, pin, pin_ok)
    default_fired = default["counts"]["fired"] if default["counts"] else None

    fixture = build_fixture(clone, work)
    receipt_sha = sha256_file(fixture["receipt"])
    down_run = run_release_clock(
        [sys.executable, "-I", "-B", str(script), "--root", str(fixture["root"]),
         "--receipt", RECEIPT_REL, "--receipt-sha", receipt_sha],
        clone, env)
    down = parse_output(down_run["stdout"])
    down_reasons, down_facts = judge_downgrade(mode, down_run, down, default_fired)

    verdict = "PASS" if not (default_reasons or down_reasons) else "FAIL"
    anchored = fixture["table_before"]["anchored_version"]
    result = {
        "instrument": "c2-measure",
        "label": label,
        "rev": args.rev,
        "rev_sha": sha,
        "base_sha": BASE,
        "expect": mode,
        "verdict": verdict,
        "python": sys.version.split()[0],
        "measured_script_sha256": sha256_file(script),
        "receipt_sha256_at_rev": sha256_file(clone / RECEIPT_REL),
        "ledger_pin": {"row": LEDGER_ROW, "pattern": pin["pattern"], "exit": pin["exit"],
                       "matched": pin_ok},
        "default": describe(default_run, default, default_reasons),
        "fixture": {
            "table_line_before": fixture["table_line_before"],
            "table_line_after": fixture["table_line_after"],
            "table_before": fixture["table_before"],
            "table_after": fixture["table_after"],
            "record_before": fixture["record_before"],
            "record_after": fixture["record_after"],
            "receipt_sha256_after": receipt_sha,
        },
        "downgrade": dict(describe(down_run, down, down_reasons), **down_facts),
    }
    out = work / "c2-measure.json"
    out.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    down_findings = " | ".join(f["line"] for f in down["findings"]) or "none"
    print("C2_MEASURE label=%s rev=%s expect=%s verdict=%s" % (label, sha, mode, verdict))
    print("  default: exit=%s state=%s pin=%s findings=%d"
          % (default_run["exit"], default["state"], "match" if pin_ok else "MISMATCH",
             len(default["findings"])))
    print("  default summary: %s" % (default["summary"] or "none"))
    print("  downgrade %s %s->%s: exit=%s state=%s refused=%s fired=%s counted=%s"
          % (TARGET, anchored, DOWNGRADE, down_run["exit"], down["state"],
             down_facts["refused"], down_facts["fired"], down_facts["counted_as_release"]))
    print("  downgrade findings: %s" % down_findings)
    print("  downgrade summary: %s" % (down["summary"] or "none"))
    for reason in default_reasons + down_reasons:
        print("  reason: %s" % reason)
    print("  json: %s" % out)
    return 0 if verdict == "PASS" else 1


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="C2 downgrade-refusal counting instrument (round 27).")
    parser.add_argument("rev", help="commit-ish to measure, resolved in the lane repo")
    parser.add_argument("label", help="label for the work directory and the summary")
    parser.add_argument("--expect", choices=("auto", "base", "after"), default="auto",
                        help="auto: base when rev is the frozen BASE, otherwise after")
    parser.add_argument("--work", metavar="DIR",
                        help="new work directory that must not exist "
                             "(default: runs/ beside this script)")
    args = parser.parse_args(argv)
    try:
        return measure(args)
    except (Setup, OSError, subprocess.SubprocessError) as exc:
        print("C2_MEASURE: SETUP (%s)" % exc)
        return 2


if __name__ == "__main__":
    sys.exit(main())
