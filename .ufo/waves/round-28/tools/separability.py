#!/usr/bin/env python3
"""Round-28 claim-only overlays for corpus/release-clock.py: C1 vs C2.

separability.py CANDIDATE MANIFEST OUT.json [--label LABEL] [--allow-unassigned]
separability.py --from-patches C1PATCH C2PATCH OUT.json [--label LABEL]

CANDIDATE is a 40-hex revision or a unified-diff file. The candidate's
corpus/release-clock.py hunks against BASE 3553d499577084a6c98d7078906017840b
bf7b28 are split by MANIFEST (JSON {"c1": [...], "c2": [...], "shared": [...],
"drop": [...]}; hunks are 1-based over the candidate diff in file order):

  c1-only overlay: BASE tree + C1+shared hunks of corpus/release-clock.py.
  c2-only overlay: BASE tree + C2+shared hunks of corpus/release-clock.py.

Each overlay is measured with the round-28 frozen fixture logic (fixtures are
built from the overlay's own tree; table edits are mirrored into the receipt
records exactly like the round-27 instruments):

  c1-only: F1 table lie (S040 observed 3.15.01 verdict fired), F2 table
           oversize (S040 4301-digit patch component, verdict fired),
           F3 observe over a local python.org feed copy titled
           "Python 3.15.01", F4 the same with a 4301-digit component
           (offline: the feed is served through the clock's own request_body
           seam; the fixture table is reduced to the python.org feed rows so
           no network is touched), control default run.
  c2-only: G1..G4 -- every derived anchor on one feed (S033 SOPS, S034 Vault,
           S035 OpenBao, S037 curl) lowered to the same lower canonical
           version with the observed version set equal and verdict
           not-fired, receipt mirrored; control default run.

Both overlays also run the clock selftest and corpus/self-counts.py. The
constructed trees are not asserted to be full-ledger-clean commits (their
shared bookkeeping pins stay at BASE); only each claim's own fixture logic,
the selftest and self-counts are run. Every overlaid blob's SHA256, every raw
exit/stdout/stderr and the receipt contents are recorded; the frozen
predicate words (mishandled / typed / accepted_clean / exact) are computed
mechanically from those recorded facts.
"""
import argparse
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
BASE_REV = "3553d499577084a6c98d7078906017840bbf7b28"
CLOCK_REL = "corpus/release-clock.py"
SCRATCH = "/fast/scratch" if os.path.isdir("/fast/scratch") else None
PYTHON_FEED_URL = "https://www.python.org/downloads/feed.rss"
OBSERVE_ROWS = ("S027", "S028", "S040", "S041")
GROUP_FEEDS = (("G1_sops", "S033"), ("G2_vault", "S034"),
               ("G3_openbao", "S035"), ("G4_curl", "S037"))
FEED_SOURCE_IDS = frozenset(feed_source for _name, feed_source in GROUP_FEEDS)
EXPECTED_GROUP_SIZES = {"S033": 4, "S034": 4, "S035": 6, "S037": 1}
TRACEBACK_MARK = "Traceback (most recent call last)"
OBSERVE_DRIVER = """#!/usr/bin/env python3
import importlib.util
import sys

spec = importlib.util.spec_from_file_location("rc_overlay_fixture", sys.argv[1])
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
with open(sys.argv[2], "rb") as handle:
    feed_body = handle.read()

def fixture_request_body(url, opener=None, resolver=None):
    return 200, feed_body, None

module.request_body = fixture_request_body
code = module.main(["--root", sys.argv[3], "--observe", sys.argv[4]])
sys.exit(int(code) if isinstance(code, int) else 1)
"""


class SplitError(Exception):
    """A candidate/manifest/fixture construction the tool refuses to guess past."""


def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest()


def git(args, cwd=None, env=None, check=True):
    proc = subprocess.run(["git"] + args, cwd=cwd, env=env, text=True,
                          capture_output=True, timeout=600)
    if check and proc.returncode != 0:
        raise SplitError("git %s failed (%d): %s" % (" ".join(args[:3]), proc.returncode, proc.stderr.strip()))
    return proc


def make_env(temp):
    return {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(temp),
            "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}


def run(argv, cwd, env, timeout):
    try:
        proc = subprocess.run(argv, cwd=cwd, env=env, text=True,
                              capture_output=True, timeout=timeout)
        out = {"argv": argv, "exit": proc.returncode, "stdout": proc.stdout,
               "stderr": proc.stderr}
    except subprocess.TimeoutExpired as exc:
        out = {"argv": argv, "exit": None, "timeout": timeout,
               "stdout": (exc.stdout or b"").decode("utf-8", "replace") if isinstance(exc.stdout, bytes) else (exc.stdout or ""),
               "stderr": (exc.stderr or b"").decode("utf-8", "replace") if isinstance(exc.stderr, bytes) else (exc.stderr or "")}
    lines = [line for line in out.get("stdout", "").splitlines() if line.strip()]
    out["last_line"] = lines[-1] if lines else ""
    summary = [line for line in lines if line.startswith("RELEASE_CLOCK")]
    out["clock_summary"] = summary[-1] if summary else ""
    out["traceback"] = TRACEBACK_MARK in out.get("stdout", "") + out.get("stderr", "")
    out["findings"] = [line for line in lines if not line.startswith("RELEASE_CLOCK")]
    out["named_ids"] = sorted(set(re.findall(r"S[0-9]{3}", "\n".join(out["findings"]))))
    out["clean_exit0"] = bool(out["exit"] == 0 and "CLEAN (" in out["clock_summary"])
    return out


class Hunk:
    __slots__ = ("old_start", "old_count", "new_start", "new_count", "lines")

    def __init__(self, old_start, old_count, new_start, new_count):
        self.old_start = old_start
        self.old_count = old_count
        self.new_start = new_start
        self.new_count = new_count
        self.lines = []

    def meta(self, index):
        return {"hunk": index, "old_start": self.old_start, "old_count": self.old_count,
                "new_start": self.new_start, "new_count": self.new_count}


HUNK_HEADER_RE = re.compile(r"@@ -([0-9]+)(?:,([0-9]+))? \+([0-9]+)(?:,([0-9]+))? @@")


def parse_unified_diff(text):
    """Parse a unified diff into {path: [Hunk, ...]} plus the file order."""
    files = {}
    order = []
    lines = text.split("\n")
    index = 0
    current = None
    while index < len(lines):
        line = lines[index]
        if line.startswith("diff --git "):
            current = None  # the section path comes from the +++ line below
            index += 1
        elif line.startswith("--- "):
            index += 1  # the old path adds nothing; the +++ line keys the section
        elif line.startswith("+++ "):
            raw = line[4:].split("\t")[0].strip()
            if raw == "/dev/null":
                current = None
            else:
                current = raw[2:] if raw[:2] in ("a/", "b/") else raw
                if current not in files:
                    files[current] = []
                    order.append(current)
            index += 1
        elif line.startswith("@@ "):
            if current is None:
                raise SplitError("hunk header outside a diff file section: %r" % line)
            header = HUNK_HEADER_RE.match(line)
            if not header:
                raise SplitError("unparsable hunk header: %r" % line)
            hunk = Hunk(int(header.group(1)),
                        1 if header.group(2) is None else int(header.group(2)),
                        int(header.group(3)),
                        1 if header.group(4) is None else int(header.group(4)))
            index += 1
            seen_old = seen_new = 0
            while (seen_old < hunk.old_count or seen_new < hunk.new_count) \
                    and index < len(lines):
                body = lines[index]
                if body.startswith("\\"):
                    raise SplitError("\\ No-newline diff marker is not supported "
                                     "(%s hunk at %s)" % (current, line))
                if body == "":
                    body_line = ""
                    tag = " "
                else:
                    tag, body_line = body[0], body[1:]
                if tag == " ":
                    seen_old += 1
                    seen_new += 1
                elif tag == "-":
                    seen_old += 1
                elif tag == "+":
                    seen_new += 1
                else:
                    raise SplitError("hunk body ended early (%d/%s old, %d/%s new) at %r"
                                     % (seen_old, hunk.old_count, seen_new, hunk.new_count, body))
                hunk.lines.append((tag, body_line))
                index += 1
            if seen_old != hunk.old_count or seen_new != hunk.new_count:
                raise SplitError("truncated hunk body for %s (%d/%d old, %d/%d new)"
                                 % (current, seen_old, hunk.old_count, seen_new, hunk.new_count))
            files[current].append(hunk)
        else:
            index += 1
    return files, order


def split_text_lines(text):
    lines = text.split("\n")
    trailing = lines[-1] == ""
    if trailing:
        lines.pop()
    return lines, trailing


def join_text_lines(lines, trailing):
    text = "\n".join(lines)
    return text + "\n" if trailing or text else text


def apply_hunks(base_lines, hunks, label):
    """Apply selected hunks (ascending) by matching context near their header."""
    result = list(base_lines)
    offset = 0
    applied = []
    for number, hunk in enumerate(hunks, 1):
        old_seq = [text for tag, text in hunk.lines if tag in (" ", "-")]
        new_seq = [text for tag, text in hunk.lines if tag in (" ", "+")]
        if hunk.old_count == 0:
            position = hunk.old_start + offset
            result[position:position] = new_seq
            offset += len(new_seq)
            applied.append({"hunk": number, "at": position + 1, "note": "insert"})
            continue
        start = hunk.old_start - 1 + offset
        found = None
        for distance in range(0, 400):
            for candidate in ([start] if distance == 0 else [start - distance, start + distance]):
                if 0 <= candidate and candidate + len(old_seq) <= len(result) \
                        and result[candidate:candidate + len(old_seq)] == old_seq:
                    found = candidate
                    break
            if found is not None:
                break
        if found is None:
            raise SplitError("%s: hunk %d context does not match the base content "
                             "(header line %d)" % (label, number, hunk.old_start))
        result[found:found + len(old_seq)] = new_seq
        offset += len(new_seq) - len(old_seq)
        applied.append({"hunk": number, "at": found + 1,
                        "shifted_by": found - (hunk.old_start - 1)})
    return result, applied


def clone_base(temp, name, env):
    clone = temp / name / "kagi-shokunin"
    clone.parent.mkdir(parents=True, exist_ok=True)
    git(["clone", "--quiet", "--no-checkout", str(LANE), str(clone)], env=env)
    git(["checkout", "--quiet", "--detach", BASE_REV], cwd=clone, env=env)
    return clone


def base_blob(env):
    raw = subprocess.check_output(["git", "-C", str(LANE), "show", BASE_REV + ":" + CLOCK_REL],
                                  env=env, timeout=600)
    return raw


def candidate_from_rev(rev, env):
    diff = git(["-C", str(LANE), "diff", "--no-color", BASE_REV, rev, "--", CLOCK_REL], env=env).stdout
    blob = git(["-C", str(LANE), "show", rev + ":" + CLOCK_REL], env=env).stdout
    files, _ = parse_unified_diff(diff)
    hunks = files.get(CLOCK_REL, [])
    if any(path != CLOCK_REL for path in files):
        raise SplitError("revision diff touches unexpected files: %s" % sorted(files))
    base_text = base_blob(env).decode("utf-8")
    base_lines, trailing = split_text_lines(base_text)
    rebuilt, _ = apply_hunks(base_lines, hunks, "rev-diff")
    if join_text_lines(rebuilt, trailing) != blob:
        raise SplitError("internal: full hunk application does not reproduce "
                         "the candidate blob for %s" % rev)
    return blob.encode("utf-8"), hunks, diff, []


def candidate_from_patch(patch_path, env):
    text = Path(patch_path).read_text(encoding="utf-8")
    files, order = parse_unified_diff(text)
    matches = [path for path in order if path == CLOCK_REL or path.endswith("/" + CLOCK_REL)]
    if len(matches) > 1:
        raise SplitError("patch has %d sections for %s: %s" % (len(matches), CLOCK_REL, matches))
    hunks = files.get(matches[0], []) if matches else []
    other = sorted(path for path in order if path not in matches)
    base_text = base_blob(env).decode("utf-8")
    base_lines, trailing = split_text_lines(base_text)
    rebuilt, applied = apply_hunks(base_lines, hunks, "patch")
    return join_text_lines(rebuilt, trailing).encode("utf-8"), hunks, text, other


def load_manifest(path, hunk_total, allow_unassigned):
    document = json.loads(Path(path).read_text(encoding="utf-8"))
    claims = {}
    for key in ("c1", "c2", "shared", "drop"):
        raw = document.get(key, [])
        if not isinstance(raw, list) or not all(isinstance(item, int) for item in raw):
            raise SplitError("manifest %r must be a list of integers" % key)
        claims[key] = sorted(raw)
    overlap = (set(claims["c1"]) & set(claims["c2"])) | (set(claims["shared"]) & set(claims["c1"])) \
        | (set(claims["shared"]) & set(claims["c2"])) | (set(claims["drop"]) & (set(claims["c1"]) | set(claims["c2"]) | set(claims["shared"])))
    if overlap:
        raise SplitError("manifest hunk(s) %s appear in more than one claim list "
                         "(use shared for hunks both overlays need)" % sorted(overlap))
    seen = set()
    for key in ("c1", "c2", "shared", "drop"):
        for number in claims[key]:
            if number in seen:
                raise SplitError("manifest lists hunk %d twice" % number)
            seen.add(number)
            if not 1 <= number <= hunk_total:
                raise SplitError("manifest hunk %d is outside 1..%d" % (number, hunk_total))
    unassigned = sorted(n for n in range(1, hunk_total + 1) if n not in seen)
    if unassigned and not allow_unassigned:
        raise SplitError("manifest leaves hunk(s) %s unassigned; assign them or pass "
                         "--allow-unassigned to drop them from both overlays" % unassigned)
    return claims, unassigned


def overlay_lines(base_lines, hunks, selection, label):
    chosen = [hunk for number, hunk in enumerate(hunks, 1) if number in selection]
    lines, applied = apply_hunks(base_lines, chosen, label)
    return lines, chosen, applied


def read_table(clone):
    return (clone / "corpus/release-clocks.tsv").read_text(encoding="utf-8").splitlines(keepends=True)


def default_receipt_rel(clone):
    code = (clone / CLOCK_REL).read_text(encoding="utf-8")
    match = re.search(r'return root / (".ufo" / "waves" / "round-[0-9]+" / "observe-[0-9]+\.json")', code)
    if not match:
        raise SplitError("cannot locate the default receipt path in the overlay's release-clock.py")
    return "/".join(re.findall(r'"([^"]+)"', match.group(1)))


GENERIC_FINDING_CODES = frozenset((
    "BADFEED", "REGRESSED", "INCONSISTENT", "UNBOUND", "ORPHAN",
    "RECEIPT-MISMATCH", "NOT OBSERVED", "SETUP",
))


def fixture_class(result, written_fired=False):
    if result.get("traceback"):
        return "mishandled-traceback"
    if written_fired:
        return "mishandled-written-fired"
    if result.get("clean_exit0"):
        return "mishandled-clean-exit0"
    if result.get("exit") not in (0, None) and typed_finding_codes(result):
        return "typed"
    return "other"


def typed_finding_codes(result):
    """Finding lines whose code is not a BASE-era generic code."""
    codes = set()
    for line in result.get("findings", []):
        code = line.split(" ", 1)[0]
        if code not in GENERIC_FINDING_CODES:
            codes.add(code)
    return codes


def build_table_fixture(clone, temp, env, name, edits):
    root = temp / ("fixture-" + name)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(clone / "corpus" / rel, root / "corpus" / rel)
    lines = read_table(clone)
    changed = []
    for index, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in edits:
            edit = edits[fields[0]]
            if len(edit) == 3:
                fields[4], fields[5], fields[7] = edit
                changed.append(fields[0])
            else:
                fields[5], fields[7] = edit
                changed.append(fields[0])
            lines[index] = "\t".join(fields) + "\n"
    (root / "corpus/release-clocks.tsv").write_text("".join(lines), encoding="utf-8")
    receipt = json.loads((clone / default_receipt_rel(clone)).read_text(encoding="utf-8"))
    mirrored = []
    for record in receipt.get("observations", []):
        if record.get("id") in edits:
            edit = edits[record["id"]]
            record["parsed_version"] = edit[1] if len(edit) == 3 else edit[0]
            record["verdict"] = edit[-1]
            mirrored.append(record["id"])
    missing = sorted(set(edits) - set(mirrored))
    if missing:
        raise SplitError("fixture %s: default receipt has no record(s) for %s" % (name, missing))
    receipt_path = root / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    sha = sha256_bytes(receipt_path.read_bytes())
    argv = ["python3", "-I", "-B", str(clone / CLOCK_REL), "--root", str(root),
            "--receipt", str(receipt_path), "--receipt-sha", sha]
    result = run(argv, clone, env, 300)
    result.update({"kind": "table", "changed_rows": changed, "edits": edits,
                   "table_sha256": sha256_bytes((root / "corpus/release-clocks.tsv").read_bytes()),
                   "receipt_sha256": sha, "class": fixture_class(result)})
    return result


def build_observe_fixture(clone, temp, env, name, feed_body):
    root = temp / ("fixture-" + name)
    (root / "corpus").mkdir(parents=True)
    for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
        shutil.copy2(clone / "corpus" / rel, root / "corpus" / rel)
    table = read_table(clone)
    header = table[0]
    wanted = set(OBSERVE_ROWS)
    feed_sources = []
    rows = [header]
    for line in table[1:]:
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] in wanted:
            rows.append(line if line.endswith("\n") else line + "\n")
            if len(fields) > 2 and fields[2] != "-":
                feed_sources.append(fields[2])
    found = [line.split("\t")[0] for line in rows[1:]]
    missing = sorted(wanted - set(found))
    if missing:
        raise SplitError("fixture %s: table lacks python.org feed row(s) %s" % (name, missing))
    wanted_sources = wanted | set(feed_sources)
    source_lines = []
    for line in (clone / "corpus/SOURCES.md").read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = stripped[1:].split("|")
            if cells and cells[0].strip() in wanted_sources:
                source_lines.append(line)
    if len(source_lines) != len(wanted_sources):
        raise SplitError("fixture %s: SOURCES.md lacks row(s) for %s" % (name, sorted(wanted_sources)))
    reduced = ["| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
               "|---|---|---|---|---|---|---|---|---|---|---|"] + source_lines
    (root / "corpus/SOURCES.md").write_text("\n".join(reduced) + "\n", encoding="utf-8")
    (root / "corpus/release-clocks.tsv").write_text("".join(rows), encoding="utf-8")
    feed_path = root / "python-feed.rss"
    feed_path.write_bytes(feed_body)
    output = root / "observe-out.json"
    driver = temp / ("observe-driver-%s.py" % name)
    driver.write_text(OBSERVE_DRIVER, encoding="utf-8")
    argv = ["python3", "-I", "-B", str(driver), str(clone / CLOCK_REL), str(feed_path),
            str(root), str(output)]
    result = run(argv, clone, env, 300)
    receipt_summary = None
    written_fired = []
    if output.exists():
        try:
            document = json.loads(output.read_text(encoding="utf-8"))
            receipt_summary = []
            for record in document.get("observations", []):
                entry = {"id": record.get("id"), "verdict": record.get("verdict")}
                if record.get("parsed_version") is not None:
                    entry["parsed_version"] = record.get("parsed_version")
                if record.get("error"):
                    entry["error"] = str(record.get("error"))[:200]
                receipt_summary.append(entry)
                if record.get("verdict") == "fired":
                    written_fired.append(record.get("id"))
        except (json.JSONDecodeError, UnicodeError) as exc:
            receipt_summary = [{"receipt_read_error": exc.__class__.__name__}]
    result["receipt"] = receipt_summary
    result["written_fired_ids"] = sorted(written_fired)
    result.update({"kind": "observe", "feed": PYTHON_FEED_URL,
                   "feed_sha256": sha256_bytes(feed_body),
                   "scope": "python.org feed rows only (offline via request_body seam)",
                   "class": fixture_class(result, written_fired=bool(written_fired))})
    return result


def python_feed_body(component):
    entries = "".join(
        "<entry><title>%s</title></entry>" % title
        for title in ("Python 3.14.9", component, "Python 3.16.0a1"))
    return (('<?xml version="1.0" encoding="utf-8"?>\n'
             '<feed xmlns="http://www.w3.org/2005/Atom">'
             '<title>Python release feed (fixture copy)</title>%s</feed>\n') % entries).encode("utf-8")


def lower_canonical(version):
    parts = version.split(".")
    if not all(re.fullmatch(r"[0-9]+", part) for part in parts):
        raise SplitError("derived anchor %r is not a canonical numeric version; "
                         "cannot build the round-28 C2 fixture" % version)
    numbers = [int(part) for part in parts]
    for index in range(len(numbers) - 1, -1, -1):
        if numbers[index] > 0:
            numbers[index] -= 1
            for later in range(index + 1, len(numbers)):
                numbers[later] = 0
            lowered = ".".join(str(number) for number in numbers)
            if lowered >= version:
                raise SplitError("lowering %r produced %r" % (version, lowered))
            return lowered
    raise SplitError("derived anchor %r has no lower canonical version" % version)


def derived_groups(clone):
    groups = {}
    anchors = {}
    for line in read_table(clone)[1:]:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        fields = line.rstrip("\n").split("\t")
        if len(fields) < 9:
            continue
        row_id, clock, feed_source, _url, anchored, _observed, _at, _verdict, note = fields[:9]
        if clock == "feed" and note.startswith("derived:") and feed_source in FEED_SOURCE_IDS:
            groups.setdefault(feed_source, []).append(row_id)
            anchors[row_id] = anchored
    for feed_source, expected in EXPECTED_GROUP_SIZES.items():
        if len(groups.get(feed_source, [])) != expected:
            raise SplitError("BASE table derived rows for %s: %s, expected %d -- the frozen "
                             "C2 fixture groups no longer match the table"
                             % (feed_source, groups.get(feed_source), expected))
    return groups, anchors


def measure_c1(clone, temp, env):
    fixtures = {
        "F1_table_lie": build_table_fixture(clone, temp, env, "F1", {"S040": ("3.15.01", "fired")}),
        "F2_table_oversize": build_table_fixture(
            clone, temp, env, "F2", {"S040": ("3.15." + "1" * 4301, "fired")}),
        "F3_observe_leading_zero": build_observe_fixture(
            clone, temp, env, "F3", python_feed_body("Python 3.15.01")),
        "F4_observe_oversize": build_observe_fixture(
            clone, temp, env, "F4", python_feed_body("Python 3.15." + "1" * 4301)),
        "control_default": run(["python3", "-I", "-B", "corpus/release-clock.py"], clone, env, 300),
    }
    fixtures["control_default"]["kind"] = "default-run"
    fixtures["control_default"]["class"] = ("clean" if fixtures["control_default"]["clean_exit0"] else "changed")
    return fixtures


def measure_c2(clone, temp, env):
    groups, anchors = derived_groups(clone)
    fixtures = {}
    for name, feed_source in GROUP_FEEDS:
        row_ids = groups[feed_source]
        lowered = lower_canonical(anchors[row_ids[0]])
        edits = {row_id: (lowered, lowered, "not-fired") for row_id in row_ids}
        result = build_table_fixture(clone, temp, env, name, edits)
        group_set = set(row_ids)
        result["group_ids"] = row_ids
        result["lowered_to"] = lowered
        result["accepted_clean"] = bool(result["clean_exit0"])
        result["exact"] = bool(result["exit"] == 1 and not result["traceback"]
                               and set(result["named_ids"]) == group_set)
        result["class"] = ("accepted-clean" if result["accepted_clean"]
                           else "typed-exact" if result["exact"] else "other")
        fixtures[name] = result
    fixtures["control_default"] = run(["python3", "-I", "-B", "corpus/release-clock.py"], clone, env, 300)
    fixtures["control_default"]["kind"] = "default-run"
    fixtures["control_default"]["class"] = ("clean" if fixtures["control_default"]["clean_exit0"] else "changed")
    return fixtures


def measure_overlay(selection_hunks, temp, env, which):
    clone = clone_base(temp, which, env)
    label = "c1_only" if which == "c1" else "c2_only"
    lines = selection_hunks["lines"]
    (clone / CLOCK_REL).write_bytes(join_text_lines(lines, selection_hunks["trailing"]).encode("utf-8"))
    record = {"blob_sha256": sha256_bytes(join_text_lines(lines, selection_hunks["trailing"]).encode("utf-8")),
              "hunks_applied": selection_hunks["applied"]}
    fixtures = measure_c1(clone, temp, env) if which == "c1" else measure_c2(clone, temp, env)
    record["fixtures"] = fixtures
    record["clock_selftest"] = run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"],
                                   clone, env, 900)
    match = re.search(r"PASS \((\d+) cases\)", record["clock_selftest"]["stdout"])
    record["selftest_cases"] = int(match.group(1)) if match else None
    counts = run(["python3", "-I", "-B", "corpus/self-counts.py"], clone, env, 1500)
    counts["finding_kinds"] = sorted(set(re.findall(r"^(STALE|UNLOCATED|AMBIGUOUS|POLICY|SETUP)", counts["stdout"], re.M)))
    record["self_counts"] = counts
    shutil.rmtree(clone.parent, ignore_errors=True)
    return record


def compact_fixtures(fixtures):
    parts = []
    for name in sorted(fixtures):
        result = fixtures[name]
        piece = "%s=%s" % (name, result.get("class", "?"))
        if "accepted_clean" in result:
            piece += "(accepted=%s,exact=%s)" % (result["accepted_clean"], result["exact"])
        parts.append(piece)
    return " ".join(parts)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    parser.add_argument("positionals", nargs="*",
                        help="CANDIDATE MANIFEST OUT.json -- or just OUT.json with --from-patches")
    parser.add_argument("--from-patches", nargs=2, metavar=("C1PATCH", "C2PATCH"),
                        help="candidate = BASE + C1PATCH then C2PATCH (release-clock.py hunks)")
    parser.add_argument("--label", default="unlabeled")
    parser.add_argument("--allow-unassigned", action="store_true",
                        help="drop manifest-unassigned hunks from both overlays (recorded)")
    args = parser.parse_args(argv)

    if args.from_patches:
        if len(args.positionals) != 1:
            raise SystemExit("usage: separability.py --from-patches C1PATCH C2PATCH OUT.json [--label L]")
        out_path = args.positionals[0]
    else:
        if len(args.positionals) != 3:
            raise SystemExit("usage: separability.py CANDIDATE MANIFEST OUT.json [--label L] [--allow-unassigned]")
        candidate_spec, manifest_path, out_path = args.positionals

    result = {"format": "kagi-round28-separability-v1", "base": BASE_REV, "label": args.label,
              "host_python": "%d.%d.%d" % sys.version_info[:3]}
    with tempfile.TemporaryDirectory(prefix="kagi-r28-sep-", dir=SCRATCH) as temp_name:
        temp = Path(temp_name)
        env = make_env(temp)
        base_raw = base_blob(env)
        base_lines, base_trailing = split_text_lines(base_raw.decode("utf-8"))
        result["base_blob_sha256"] = sha256_bytes(base_raw)

        if args.from_patches:
            c1_blob, c1_hunks, _, c1_other = candidate_from_patch(args.from_patches[0], env)
            c1_only_lines, c1_applied = apply_hunks(base_lines, c1_hunks, "c1-patch")
            c2_blob, c2_hunks, _, c2_other = candidate_from_patch(args.from_patches[1], env)
            c2_only_lines, c2_applied = apply_hunks(base_lines, c2_hunks, "c2-patch")
            candidate_blob = None
            union_error = None
            cand_applied = None
            try:
                candidate_lines, cand_applied = apply_hunks(c1_only_lines, c2_hunks, "candidate")
                candidate_blob = join_text_lines(candidate_lines, base_trailing).encode("utf-8")
            except SplitError as exc:
                union_error = str(exc)  # overlapping BASE-relative hunks: the union is
                cand_applied = None     # L1's merge to define; the overlays stay valid
            result["candidate"] = {
                "mode": "from-patches", "c1_patch": args.from_patches[0], "c2_patch": args.from_patches[1],
                "blob_sha256": sha256_bytes(candidate_blob) if candidate_blob is not None else None,
                "union_error": union_error,
                "c1_hunks": len(c1_hunks), "c2_hunks": len(c2_hunks),
                "c1_other_files": c1_other, "c2_other_files": c2_other,
                "manifest": {"mode": "from-patches",
                             "c1": list(range(1, len(c1_hunks) + 1)),
                             "c2": list(range(1, len(c2_hunks) + 1)),
                             "note": "patch hunks are per-claim by construction; "
                                     "overlays are BASE+each patch directly"},
                "candidate_apply": cand_applied}
            overlays = {
                "c1_only": {"lines": c1_only_lines, "trailing": base_trailing, "applied": c1_applied},
                "c2_only": {"lines": c2_only_lines, "trailing": base_trailing, "applied": c2_applied},
            }
        else:
            if re.fullmatch(r"[0-9a-f]{40}", candidate_spec):
                candidate_blob, hunks, diff_text, other = candidate_from_rev(candidate_spec, env)
                mode = "revision"
            else:
                candidate_blob, hunks, diff_text, other = candidate_from_patch(candidate_spec, env)
                mode = "patch"
            claims, unassigned = load_manifest(manifest_path, len(hunks), args.allow_unassigned)
            meta = [hunk.meta(number) for number, hunk in enumerate(hunks, 1)]
            result["candidate"] = {"mode": mode, "spec": candidate_spec,
                                   "blob_sha256": sha256_bytes(candidate_blob),
                                   "diff_sha256": sha256_bytes(diff_text.encode("utf-8")),
                                   "hunks": meta, "other_files": other}
            result["manifest"] = dict(claims, unassigned=unassigned, path=manifest_path)
            overlays = {}
            for which, keys in (("c1", ("c1", "shared")), ("c2", ("c2", "shared"))):
                selection = set()
                for key in keys:
                    selection.update(claims[key])
                lines, chosen, applied = overlay_lines(base_lines, hunks, selection, which + "_only")
                overlays[which + "_only"] = {"lines": lines, "trailing": base_trailing,
                                             "applied": applied,
                                             "hunk_numbers": sorted(selection & set(range(1, len(hunks) + 1)))}
        for which in ("c1", "c2"):
            name = which + "_only"
            overlays[name]["blob_sha256"] = sha256_bytes(
                join_text_lines(overlays[name]["lines"], overlays[name]["trailing"]).encode("utf-8"))

        result["overlays"] = {
            "c1_only": measure_overlay(overlays["c1_only"], temp, env, "c1"),
            "c2_only": measure_overlay(overlays["c2_only"], temp, env, "c2"),
        }

    c1 = result["overlays"]["c1_only"]
    c2 = result["overlays"]["c2_only"]
    accepted = sum(1 for name in ("G1_sops", "G2_vault", "G3_openbao", "G4_curl")
                   if c2["fixtures"][name]["accepted_clean"])
    exact = sum(1 for name in ("G1_sops", "G2_vault", "G3_openbao", "G4_curl")
                if c2["fixtures"][name]["exact"])
    result["summary"] = {
        "c1_only": {name: c1["fixtures"][name]["class"] for name in c1["fixtures"]},
        "c2_only": {name: (c2["fixtures"][name].get("class"), c2["fixtures"][name].get("accepted_clean"),
                           c2["fixtures"][name].get("exact"))
                    for name in ("G1_sops", "G2_vault", "G3_openbao", "G4_curl", "control_default")},
        "c2_accepted_clean": accepted, "c2_exact": exact,
    }
    Path(out_path).write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    candidate_sha = result["candidate"]["blob_sha256"]
    print("SEPARABILITY %s base=%s candidate=%s" % (
        args.label, BASE_REV[:12], candidate_sha[:12] if candidate_sha else "union-not-computable"))
    print("SEPARABILITY c1-only: blob=%s selftest=%r cases=%s self_counts_exit=%s | %s"
          % (c1["blob_sha256"][:12], c1["clock_selftest"]["last_line"], c1["selftest_cases"],
             c1["self_counts"]["exit"], compact_fixtures(c1["fixtures"])))
    print("SEPARABILITY c2-only: blob=%s selftest=%r cases=%s self_counts_exit=%s accepted=%d/4 exact=%d/4 | %s"
          % (c2["blob_sha256"][:12], c2["clock_selftest"]["last_line"], c2["selftest_cases"],
             c2["self_counts"]["exit"], accepted, exact, compact_fixtures(c2["fixtures"])))
    print("SEPARABILITY wrote %s" % out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
