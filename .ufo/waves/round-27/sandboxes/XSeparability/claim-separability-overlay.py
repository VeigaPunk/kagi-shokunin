#!/usr/bin/env python3
"""Claim-separability overlay recorder (round-27 XSeparability draft; UNRUN).

Builds claim-only trees from two committed revisions of the lane. Each tree is a
fresh scratch clone checked out at BASE and then overlaid. The tool proves that
every overlaid byte stream is the committed blob, or the committed hunk
composition, then runs each claim's own counting command inside each tree.

It reads committed objects only (rev-parse, diff-tree, diff, cat-file, clone).
It never reads the lane's working tree, index, refs or objects, and never writes
to the lane. It writes only to its scratch directory and to --out, which may not
sit under corpus/ or .git.

Trees:
  base         BASE, no overlay (control)
  c1           BASE + everything the partition assigns to C1
  c2           BASE + everything the partition assigns to C2
  table-after  BASE + the AFTER binding table only ("after table on BASE docs")
  after        BASE + every changed path from AFTER (must equal AFTER exactly)

Claim commands, run inside each tree:
  C1  python3 -B corpus/self-counts.py                   per-claim status lines
  C2  python3 -B corpus/release-clock.py --selftest      case count
      python3 -B corpus/release-clock.py                 live default receipt
      python3 -B corpus/release-clock.py --root F --receipt R --receipt-sha S
                                                         S040 downgraded to 3.15.0
  --mutate ID  one-digit change to ID's document in the after tree; expects STALE ID

Partition TSV, no header, '#' comments: path<TAB>claim<TAB>hunk_regex
  claim       C1 or C2
  hunk_regex  ALL (whole file; the only row for that path) or a Python regex
              (re.M) searched in each git -U0 hunk's removed and added lines.
              Every hunk must match exactly one claim. A changed path with no row,
              or a row for an unchanged path, is refused.

Exit: 0 every asserted check PASS; 1 an asserted check FAILED (measured and
reported); 2 refused on integrity or setup (nothing is claimed).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

LANE = pathlib.Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
BASE_DEFAULT = "0a47dd189356ea66ec83c3891eed54526e95b89b"
SCHEMA = "kagi-r27-claim-separability-overlay/draft-1"
CLAIMS = ("C1", "C2")
DEFAULT_TABLE = "corpus/self-counts.tsv"
CLOCK = "corpus/release-clock.py"
RECEIPT = ".ufo/waves/round-26/observe-2.json"
DOWNGRADE_ID = "S040"
DOWNGRADE_OBSERVED = "3.15.0"
GATE_ARGV = ["python3", "-B", "corpus/self-counts.py"]
CLOCK_SELFTEST_ARGV = ["python3", "-B", CLOCK, "--selftest"]
CLOCK_DEFAULT_ARGV = ["python3", "-B", CLOCK]
VERIFY_ARGV = ["bash", "corpus/claim-ledger.sh", "verify"]
ENV_FIXED = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "PYTHONDONTWRITEBYTECODE": "1"}
MODE_BITS = {"100644": 0o644, "100755": 0o755}
ZERO_MODE = "000000"
HUNK_RE = re.compile(rb"^@@ -([0-9]+)(?:,([0-9]+))? \+([0-9]+)(?:,([0-9]+))? @@")
GATE_LINE_RE = re.compile(r"^(OK|STALE|UNLOCATED|AMBIGUOUS|POLICY|SETUP) (\S+)")
GATE_SUMMARY_RE = re.compile(r"^SELF_COUNTS: (CLEAN|STALE|POLICY|SETUP)(?: \((.*)\))?\s*$", re.M)
SELFTEST_RE = re.compile(r"RELEASE_CLOCK_SELFTEST: (PASS|FAIL)(?: \(([0-9]+) cases\))?")


class Refused(Exception):
    """Integrity or setup failure: nothing is claimed."""


def refuse(message: str):
    raise Refused(message)


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def git(*args: str, cwd: pathlib.Path = LANE) -> bytes:
    proc = subprocess.run(["git", "-C", str(cwd), *args], stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, check=False)
    if proc.returncode != 0:
        detail = proc.stderr.decode("utf-8", "replace").strip()[:300]
        refuse(f"git {' '.join(args[:2])} failed (rc={proc.returncode}): {detail}")
    return proc.stdout


def blob_oid(data: bytes, algo: str) -> str:
    digest = hashlib.new(algo)
    digest.update(b"blob %d\x00" % len(data))
    digest.update(data)
    return digest.hexdigest()


def is_zero_oid(oid: str) -> bool:
    return set(oid) == {"0"}


def resolve_commit(rev: str) -> str:
    return git("rev-parse", "--verify", f"{rev}^{{commit}}").decode("ascii").strip()


def load_partition(path: pathlib.Path) -> dict[str, list]:
    rules: dict[str, list] = {}
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        fields = line.split("\t")
        if len(fields) != 3 or any(not field.strip() for field in fields):
            refuse(f"partition:{number}: need three nonempty tab-separated fields")
        rel, claim, pattern = fields
        pure = pathlib.PurePosixPath(rel)
        if pure.is_absolute() or ".." in pure.parts:
            refuse(f"partition:{number}: path must be repository-relative: {rel}")
        if claim not in CLAIMS:
            refuse(f"partition:{number}: claim must be one of {', '.join(CLAIMS)}")
        compiled = None
        if pattern != "ALL":
            try:
                compiled = re.compile(pattern, re.M)
            except re.error as exc:
                refuse(f"partition:{number}: bad regex: {exc}")
        rules.setdefault(rel, []).append((claim, compiled, number))
    if not rules:
        refuse("partition is empty")
    for rel, entries in rules.items():
        if any(compiled is None for _, compiled, _ in entries) and len(entries) != 1:
            refuse(f"partition: {rel} mixes ALL with other rows")
    return rules


def changed_entries(base: str, after: str) -> list[dict]:
    raw = git("diff-tree", "-r", "-z", "--no-renames", "--raw", base, after)
    parts = raw.split(b"\x00")
    entries: list[dict] = []
    index = 0
    while index + 1 < len(parts) and parts[index]:
        meta = parts[index].decode("ascii")
        path = parts[index + 1].decode("utf-8")
        index += 2
        if not meta.startswith(":"):
            refuse(f"unexpected diff-tree record: {meta[:40]!r}")
        old_mode, new_mode, old_oid, new_oid, status = meta[1:].split()
        entries.append({"path": path, "old_mode": old_mode, "new_mode": new_mode,
                        "old_oid": old_oid, "new_oid": new_oid, "status": status})
    return entries


def split_lines(data: bytes) -> list[bytes]:
    pieces = data.split(b"\n")
    lines = [piece + b"\n" for piece in pieces[:-1]]
    if pieces[-1]:
        lines.append(pieces[-1])
    return lines


def parse_hunks(diff: bytes) -> list[dict]:
    """Parse one file's git -U0 diff. Newline-at-EOF markers are honoured."""
    hunks: list[dict] = []
    current = None
    last = None
    for raw in diff.split(b"\n"):
        if not raw:
            continue
        match = HUNK_RE.match(raw)
        if match:
            old_count, new_count = match.group(2), match.group(4)
            current = {"a": int(match.group(1)),
                       "b": int(old_count) if old_count is not None else 1,
                       "d": int(new_count) if new_count is not None else 1,
                       "removed": [], "added": []}
            hunks.append(current)
            last = None
            continue
        if current is None:
            continue  # file header lines precede the first hunk
        if raw.startswith(b"\\"):
            if last is not None and last[1]:
                last[1][-1] = last[1][-1][:-1]  # the marked line had no newline
            last = None
            continue
        sign, body = raw[:1], raw[1:] + b"\n"
        if sign == b"-":
            current["removed"].append(body)
            last = ("-", current["removed"])
        elif sign == b"+":
            current["added"].append(body)
            last = ("+", current["added"])
        else:
            refuse(f"unexpected line in -U0 hunk: {raw[:40]!r}")
    for hunk in hunks:
        if len(hunk["removed"]) != hunk["b"] or len(hunk["added"]) != hunk["d"]:
            refuse("hunk body disagrees with its header counts")
        hunk["text"] = b"".join(hunk["removed"] + hunk["added"]).decode("utf-8", "surrogateescape")
    return hunks


def apply_hunks(base_lines: list[bytes], hunks: list[dict]) -> bytes:
    lines = list(base_lines)
    for hunk in sorted(hunks, key=lambda h: h["a"], reverse=True):
        start = hunk["a"] if hunk["b"] == 0 else hunk["a"] - 1
        lines[start:start + hunk["b"]] = hunk["added"]
    return b"".join(lines)


def assign(path: str, hunks: list[dict], rule_rows: list) -> dict[str, list[int]]:
    result: dict[str, list[int]] = {}
    for index, hunk in enumerate(hunks):
        claims = {claim for claim, compiled, _ in rule_rows if compiled.search(hunk["text"])}
        if len(claims) != 1:
            refuse(f"{path}: hunk at BASE line {hunk['a']} matches "
                   f"{sorted(claims) or 'no rule'}; need exactly one claim")
        result.setdefault(claims.pop(), []).append(index)
    return result


def whole_entry(change: dict, content: bytes | None, base_bytes: bytes | None,
                after_bytes: bytes | None) -> dict:
    return {
        "path": change["path"], "mode": change["new_mode"], "content": content,
        "state_sha256": None if content is None else sha256_hex(content),
        "whole": True, "after_oid": change["new_oid"],
        "after_sha256": None if after_bytes is None else sha256_hex(after_bytes),
        "base_sha256": None if base_bytes is None else sha256_hex(base_bytes),
        "hunks_total": None, "hunks_selected": None,
    }


def build_plan(base: str, after: str, rules: dict, algo: str):
    changes = changed_entries(base, after)
    if not changes:
        refuse("no changed paths between BASE and AFTER")
    changed = {change["path"] for change in changes}
    unclassified = sorted(changed - rules.keys())
    if unclassified:
        refuse("unclassified changed paths: " + ", ".join(unclassified))
    unchanged = sorted(rules.keys() - changed)
    if unchanged:
        refuse("partition rows for unchanged paths: " + ", ".join(unchanged))
    overlays: dict[str, dict[str, dict]] = {claim: {} for claim in CLAIMS}
    whole_after: dict[str, dict] = {}
    for change in changes:
        path = change["path"]
        modes = {change["old_mode"], change["new_mode"]}
        if modes - {ZERO_MODE, *MODE_BITS}:
            refuse(f"{path}: unsupported mode {change['old_mode']} -> {change['new_mode']}")
        base_bytes = None if is_zero_oid(change["old_oid"]) else git("cat-file", "blob", change["old_oid"])
        after_bytes = None if is_zero_oid(change["new_oid"]) else git("cat-file", "blob", change["new_oid"])
        if after_bytes is not None and blob_oid(after_bytes, algo) != change["new_oid"]:
            refuse(f"{path}: AFTER bytes do not hash to {change['new_oid']}")
        whole = whole_entry(change, after_bytes, base_bytes, after_bytes)
        whole_after[path] = whole
        rule_rows = rules[path]
        if base_bytes is None or after_bytes is None or change["old_oid"] == change["new_oid"]:
            if len(rule_rows) != 1 or rule_rows[0][1] is not None:
                refuse(f"{path}: added, deleted or mode-only path needs exactly one ALL row")
            overlays[rule_rows[0][0]][path] = whole
            continue
        diff = git("diff", "-U0", "--no-color", "--no-ext-diff", "--no-textconv",
                   "--no-renames", base, after, "--", path)
        hunks = parse_hunks(diff)
        if not hunks:
            refuse(f"{path}: changed blob with no textual hunks")
        base_lines = split_lines(base_bytes)
        if apply_hunks(base_lines, hunks) != after_bytes:
            refuse(f"{path}: all hunks applied to BASE do not reproduce the AFTER blob")
        if rule_rows[0][1] is None:
            overlays[rule_rows[0][0]][path] = whole
            continue
        for claim, indexes in assign(path, hunks, rule_rows).items():
            content = apply_hunks(base_lines, [hunks[i] for i in indexes])
            overlays[claim][path] = {
                "path": path, "mode": change["new_mode"], "content": content,
                "state_sha256": sha256_hex(content), "whole": False,
                "after_oid": change["new_oid"], "after_sha256": whole["after_sha256"],
                "base_sha256": whole["base_sha256"], "hunks_total": len(hunks),
                "hunks_selected": len(indexes),
            }
    return changed, overlays, whole_after


def build_tree(root: pathlib.Path, name: str, base: str, after: str, overlay: dict,
               changed: set, whole_after: dict, algo: str):
    dest = root / name
    proc = subprocess.run(["git", "clone", "-q", "--no-checkout", "--no-hardlinks",
                           str(LANE), str(dest)], stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, check=False)
    if proc.returncode != 0:
        refuse(f"{name}: clone failed: {proc.stderr.decode('utf-8', 'replace').strip()[:300]}")
    git("checkout", "-q", "--detach", base, cwd=dest)
    if git("rev-parse", "HEAD", cwd=dest).decode("ascii").strip() != base:
        refuse(f"{name}: scratch HEAD is not BASE")
    for path in sorted(overlay):
        item = overlay[path]
        target = dest / path
        if item["content"] is None:
            target.unlink(missing_ok=True)
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(item["content"])
        os.chmod(target, MODE_BITS[item["mode"]])
        written = target.read_bytes()
        if sha256_hex(written) != item["state_sha256"]:
            refuse(f"{name}: written bytes differ from the expected SHA256 for {path}")
        if item["whole"] and blob_oid(written, algo) != item["after_oid"]:
            refuse(f"{name}: whole-file overlay of {path} is not blob {item['after_oid']}")
    if overlay:
        git("add", "-A", "-f", "--", *sorted(overlay), cwd=dest)
    staged_base = set(git("diff", "--cached", "--name-only", "-z", base, cwd=dest)
                      .decode("utf-8").split("\x00")) - {""}
    if staged_base != set(overlay):
        refuse(f"{name}: staged paths {sorted(staged_base)} differ from overlay {sorted(overlay)}")
    expected_vs_after = set()
    for path in changed:
        entry = overlay.get(path)
        if entry is None or entry["state_sha256"] != whole_after[path]["state_sha256"]:
            expected_vs_after.add(path)
    staged_after = set(git("diff", "--cached", "--name-only", "-z", after, cwd=dest)
                       .decode("utf-8").split("\x00")) - {""}
    if staged_after != expected_vs_after:
        refuse(f"{name}: differs from AFTER on {sorted(staged_after)}, expected {sorted(expected_vs_after)}")
    record = {
        "overlays": [{"path": path, "whole": overlay[path]["whole"],
                      "sha256": overlay[path]["state_sha256"],
                      "after_oid": overlay[path]["after_oid"],
                      "after_sha256": overlay[path]["after_sha256"],
                      "base_sha256": overlay[path]["base_sha256"],
                      "hunks_selected": overlay[path]["hunks_selected"],
                      "hunks_total": overlay[path]["hunks_total"]}
                     for path in sorted(overlay)],
        "staged_vs_base": sorted(staged_base),
        "staged_vs_after": sorted(staged_after),
    }
    return dest, record


def measure(dest: pathlib.Path, argv: list, env: dict, timeout: int) -> dict:
    try:
        proc = subprocess.run(argv, cwd=dest, env=env, stdin=subprocess.DEVNULL,
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              timeout=timeout, check=False)
        code, output = proc.returncode, proc.stdout
    except subprocess.TimeoutExpired as exc:
        code, output = "TIMEOUT", exc.stdout or b""
    return {"argv": argv, "cwd": dest.name, "exit": code,
            "stdout": output.decode("utf-8", "replace"), "stdout_sha256": sha256_hex(output)}


def make_fixture(dest: pathlib.Path, scratch: pathlib.Path) -> dict:
    """Copy the tree's corpus/, set S040 to observed 3.15.0 'fired', re-hash receipt."""
    fixture = scratch / f"{dest.name}-downgrade"
    shutil.copytree(dest / "corpus", fixture / "corpus")
    table = fixture / "corpus" / "release-clocks.tsv"
    lines = table.read_bytes().split(b"\n")
    hits = [index for index, line in enumerate(lines)
            if line.split(b"\t")[0] == DOWNGRADE_ID.encode("ascii")]
    if len(hits) != 1:
        refuse(f"{dest.name}: {DOWNGRADE_ID} is not a unique release-clocks.tsv row")
    fields = lines[hits[0]].split(b"\t")
    if len(fields) != 9:
        refuse(f"{dest.name}: {DOWNGRADE_ID} row does not have nine fields")
    fields[5] = DOWNGRADE_OBSERVED.encode("ascii")  # observed_version
    fields[7] = b"fired"                            # verdict
    lines[hits[0]] = b"\t".join(fields)
    table.write_bytes(b"\n".join(lines))
    document = json.loads((dest / RECEIPT).read_bytes().decode("utf-8"))
    records = [item for item in document["observations"] if item.get("id") == DOWNGRADE_ID]
    if len(records) != 1:
        refuse(f"{dest.name}: {DOWNGRADE_ID} is not a unique receipt record")
    records[0]["parsed_version"] = DOWNGRADE_OBSERVED
    records[0]["verdict"] = "fired"
    receipt = fixture / "downgrade-observe.json"
    receipt.write_bytes((json.dumps(document, ensure_ascii=False, indent=2, sort_keys=True)
                         + "\n").encode("utf-8"))
    return {"root": fixture, "receipt": receipt, "receipt_sha256": sha256_hex(receipt.read_bytes())}


def downgrade_argv(fixture: dict) -> list:
    return ["python3", "-B", CLOCK, "--root", str(fixture["root"]),
            "--receipt", str(fixture["receipt"]), "--receipt-sha", fixture["receipt_sha256"]]


def measure_tree(dest: pathlib.Path, scratch: pathlib.Path, env: dict, timeout: int, *,
                 gate: bool, clock: bool, verify: bool) -> dict:
    result: dict = {}
    if gate:
        result["gate"] = measure(dest, GATE_ARGV, env, timeout)
    if clock:
        result["clock_selftest"] = measure(dest, CLOCK_SELFTEST_ARGV, env, timeout)
        result["clock_default"] = measure(dest, CLOCK_DEFAULT_ARGV, env, timeout)
        fixture = make_fixture(dest, scratch)
        result["clock_downgrade"] = measure(dest, downgrade_argv(fixture), env, timeout)
        result["clock_downgrade"]["fixture_receipt_sha256"] = fixture["receipt_sha256"]
    if verify:
        result["ledger_verify"] = measure(dest, VERIFY_ARGV, env, 1200)
    return result


def mutate_one(dest: pathlib.Path, ident: str) -> dict:
    rows = [line.split("\t") for line in (dest / DEFAULT_TABLE).read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")]
    selected = [row for row in rows if row and row[0] == ident]
    if len(selected) != 1 or len(selected[0]) != 6:
        refuse(f"mutation id {ident} is absent or not unique in the after table")
    doc, locator = selected[0][1], selected[0][2]
    path = dest / doc
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    hits = [(number, match) for number, line in enumerate(lines)
            if (match := re.search(locator, line)) is not None]
    if len(hits) != 1 or hits[0][1].re.groups != 1:
        refuse(f"mutation locator for {ident} is not unique in {doc}")
    number, match = hits[0]
    old = match.group(1)
    new = str(int(old) + 1)
    lines[number] = lines[number][:match.start(1)] + new + lines[number][match.end(1):]
    path.write_text("".join(lines), encoding="utf-8")
    return {"id": ident, "doc": doc, "line": number + 1, "old": old, "new": new}


def parse_gate(run: dict) -> dict:
    text = run["stdout"]
    per_claim = {}
    for line in text.splitlines():
        match = GATE_LINE_RE.match(line)
        if match:
            per_claim[match.group(2)] = match.group(1)
    summaries = list(GATE_SUMMARY_RE.finditer(text))
    if not summaries:
        return {"verdict": None, "counts": {}, "per_claim": per_claim}
    last = summaries[-1]
    counts = {key: int(value) for key, value in
              re.findall(r"(claims|stale|unlocated|ambiguous|policy|setup)=([0-9]+)",
                         last.group(2) or "")}
    return {"verdict": last.group(1), "counts": counts, "per_claim": per_claim}


def parse_selftest(run: dict):
    matches = list(SELFTEST_RE.finditer(run["stdout"]))
    if not matches:
        return None
    last = matches[-1]
    return int(last.group(2)) if last.group(2) else None


def selftest_span(text: str) -> tuple:
    lines = text.splitlines()
    start = next((n for n, line in enumerate(lines, 1) if line.startswith("def selftest(")), None)
    if start is None:
        refuse("def selftest( not found in the BASE release-clock.py")
    end = next((n for n, line in enumerate(lines, 1)
                if n > start and line.startswith("def ")), len(lines) + 1)
    return start, end - 1


def selftest_growth(base_text: str, hunks: list) -> dict:
    start, end = selftest_span(base_text)
    pure = True
    inserted = 0
    for hunk in hunks:
        a, b = hunk["a"], hunk["b"]
        if b > 0 and a <= end and a + b - 1 >= start:
            pure = False
        elif b == 0 and start <= a <= end:
            inserted += sum(1 for line in hunk["added"] if b"run_case(" in line)
    return {"selftest_lines": [start, end], "pure_insertion": pure,
            "inserted_run_case_lines": inserted}


def checks_for(measured: dict, changed: set, base: str, after: str, mutate_id) -> list:
    checks: list = []

    def add(ident, passed, observed, expected):
        checks.append({"id": ident, "status": "PASS" if passed else "FAIL",
                       "observed": observed, "expected": expected})

    def info(ident, observed):
        checks.append({"id": ident, "status": "INFO", "observed": observed})

    exits = {name: run["gate"]["exit"] for name, run in measured.items() if "gate" in run}
    gates = {name: parse_gate(run["gate"]) for name, run in measured.items() if "gate" in run}
    base_gate, after_gate, table_gate = gates["base"], gates["after"], gates["table-after"]
    add("C1.base-table-on-base-docs-pinned",
        exits["base"] == 0 and base_gate["verdict"] == "CLEAN" and base_gate["counts"].get("claims") == 38,
        {"exit": exits["base"], "verdict": base_gate["verdict"], "counts": base_gate["counts"]},
        "exit 0, CLEAN, claims=38 (ledger R25-02 pin)")
    add("C1.after-tree-clean",
        exits["after"] == 0 and after_gate["verdict"] == "CLEAN" and after_gate["counts"].get("stale") == 0,
        {"exit": exits["after"], "verdict": after_gate["verdict"], "counts": after_gate["counts"]},
        "exit 0, CLEAN, stale=0")
    add("C1.after-table-on-base-docs-detects",
        exits["table-after"] == 1 and sum(table_gate["counts"].get(key, 0)
                                          for key in ("stale", "unlocated", "ambiguous")) >= 1,
        {"exit": exits["table-after"], "verdict": table_gate["verdict"], "counts": table_gate["counts"]},
        "exit 1 with stale+unlocated+ambiguous >= 1 (parse stale= too; exit 1 alone is not enough)")
    info("C1.table-after-non-ok-rows", {ident: status for ident, status in table_gate["per_claim"].items()
                                        if status != "OK"})
    if mutate_id:
        mutant_run = measured["after-mutant"]["gate"]
        mutant = parse_gate(mutant_run)
        add("C1.one-digit-mutation-detected",
            mutant_run["exit"] == 1 and mutant["per_claim"].get(mutate_id) == "STALE",
            {"exit": mutant_run["exit"], "status": mutant["per_claim"].get(mutate_id)},
            f"exit 1 and STALE {mutate_id}")
    base_dg = measured["base"]["clock_downgrade"]
    after_dg = measured["after"]["clock_downgrade"]
    add("C2.downgrade-accepted-at-base",
        base_dg["exit"] == 0 and "RELEASE_CLOCK: CLEAN" in base_dg["stdout"],
        {"exit": base_dg["exit"], "stdout": base_dg["stdout"][-300:]}, "exit 0 and CLEAN")
    add("C2.downgrade-refused-after",
        after_dg["exit"] == 1 and "REGRESSED" in after_dg["stdout"] and DOWNGRADE_ID in after_dg["stdout"],
        {"exit": after_dg["exit"], "stdout": after_dg["stdout"][-300:]}, f"exit 1, REGRESSED {DOWNGRADE_ID}")
    for name in ("base", "after"):
        default = measured[name]["clock_default"]
        add(f"C2.live-default-clean-{name}",
            default["exit"] == 0 and "RELEASE_CLOCK: CLEAN (on_release=30 " in default["stdout"],
            {"exit": default["exit"], "stdout": default["stdout"][-200:]},
            "exit 0 and CLEAN with on_release=30 (R25-04 pin)")
    base_cases = parse_selftest(measured["base"]["clock_selftest"])
    after_cases = parse_selftest(measured["after"]["clock_selftest"])
    if CLOCK in changed:
        hunks = parse_hunks(git("diff", "-U0", "--no-color", "--no-ext-diff", "--no-textconv",
                                "--no-renames", base, after, "--", CLOCK))
        growth = selftest_growth(git("cat-file", "blob", f"{base}:{CLOCK}").decode("utf-8"), hunks)
        add("C2.selftest-only-insertions", growth["pure_insertion"], growth,
            "no modified or deleted line inside selftest()")
        add("C2.selftest-growth-equals-inserted-cases",
            base_cases is not None and after_cases is not None
            and after_cases - base_cases == growth["inserted_run_case_lines"],
            {"base_cases": base_cases, "after_cases": after_cases,
             "inserted_run_case_lines": growth["inserted_run_case_lines"]},
            "after - base == inserted run_case( lines (approximation: one call per case)")
    else:
        info("C2.release-clock-unchanged", "corpus/release-clock.py is unchanged between BASE and AFTER")
    info("C2.cross-claim-rows-in-c2-tree",
         {rid: gates["c2"]["per_claim"].get(rid) for rid in ("SC-CLOCK-SELFTEST", "PV-CLOCK-SELFTEST")})
    return checks


def run_all(args, root: pathlib.Path) -> dict:
    base = resolve_commit(args.base)
    after = resolve_commit(args.after)
    if base == after:
        refuse("BASE and AFTER resolve to the same commit")
    algo = git("rev-parse", "--show-object-format").decode("ascii").strip()
    rules = load_partition(args.partition)
    changed, overlays, whole_after = build_plan(base, after, rules, algo)
    table = args.table_path
    if table not in changed:
        refuse(f"binding table {table} is unchanged between BASE and AFTER")
    specs = {
        "base": {},
        "c1": overlays["C1"],
        "c2": overlays["C2"],
        "table-after": {table: whole_after[table]},
        "after": whole_after,
    }
    dests: dict[str, pathlib.Path] = {}
    builds: dict[str, dict] = {}
    for name, overlay in specs.items():
        dests[name], builds[name] = build_tree(root, name, base, after, overlay, changed,
                                               whole_after, algo)
    home, tmp = root / "home", root / "tmp"
    home.mkdir()
    tmp.mkdir()
    env = {**ENV_FIXED, "HOME": str(home), "TMPDIR": str(tmp)}
    matrix = {  # (gate, clock, verify)
        "base": (True, True, False),
        "c1": (True, False, True),
        "c2": (True, True, False),
        "table-after": (True, False, False),
        "after": (True, True, True),
    }
    measured = {name: measure_tree(dests[name], root, env, args.timeout, gate=g, clock=c, verify=v)
                for name, (g, c, v) in matrix.items()}
    if args.mutate:
        mutation = mutate_one(dests["after"], args.mutate)
        measured["after-mutant"] = {"mutation": mutation,
                                    "gate": measure(dests["after"], GATE_ARGV, env, args.timeout)}
    checks = checks_for(measured, changed, base, after, args.mutate)
    return {
        "base": base, "after": after, "object_format": algo,
        "partition_sha256": sha256_hex(args.partition.read_bytes()),
        "git_version": git("version").decode("ascii").strip(),
        "python_version": sys.version.split()[0],
        "python_on_path": shutil.which("python3"),
        "env": env,
        "changed_paths": sorted(changed),
        "trees": builds,
        "measured": measured,
        "checks": checks,
    }


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--base", default=BASE_DEFAULT, help="frozen BASE revision")
    parser.add_argument("--after", required=True, help="committed AFTER revision (never the working tree)")
    parser.add_argument("--partition", required=True, type=pathlib.Path, help="claim partition TSV")
    parser.add_argument("--table-path", default=DEFAULT_TABLE, help="binding table path in the repo")
    parser.add_argument("--out", required=True, type=pathlib.Path,
                        help="JSON record path (may not sit under corpus/ or .git)")
    parser.add_argument("--scratch", type=pathlib.Path, default=None,
                        help="scratch parent (default /fast/scratch when present)")
    parser.add_argument("--timeout", type=int, default=900, help="seconds per measured command")
    parser.add_argument("--mutate", metavar="ID", default=None, help="one-digit mutation check")
    parser.add_argument("--keep", action="store_true", help="keep the scratch directory")
    args = parser.parse_args(argv)
    out = args.out.resolve()
    for forbidden in (LANE / "corpus", LANE / ".git"):
        if out.is_relative_to(forbidden):
            print(f"REFUSED: --out may not be under {forbidden}")
            return 2
    default_scratch = pathlib.Path("/fast/scratch")
    parent = args.scratch or (default_scratch if default_scratch.is_dir()
                              else pathlib.Path(tempfile.gettempdir()))
    root = pathlib.Path(tempfile.mkdtemp(prefix="kagi-r27-sep-", dir=str(parent)))
    record: dict = {"schema": SCHEMA, "lane": str(LANE), "scratch": str(root),
                    "tool_sha256": sha256_hex(pathlib.Path(__file__).read_bytes())}
    try:
        result = run_all(args, root)
        record.update(result)
        record["integrity"] = "OK"
        status = 1 if any(check["status"] == "FAIL" for check in result["checks"]) else 0
    except Refused as exc:
        record["integrity"] = f"REFUSED: {exc}"
        status = 2
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(record, indent=2, sort_keys=True, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    verdict = {0: "PASS", 1: "CHECK-FAILED", 2: "REFUSED"}[status]
    print(f"CLAIM_SEPARABILITY: {verdict} -> {out}")
    if not args.keep:
        shutil.rmtree(root, ignore_errors=True)
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
