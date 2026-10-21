"""CritC1Vacuity probe: BASE release-clock.py vs two draft patches, sandbox only."""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "base"
WORK = HERE / "work"
PYFEED = HERE / "feed-f6f08ce3"
OBAO = HERE / "feed-eeab1559"
BIG = "1" * 4301
BIG4300 = "1" * 4300

OBSERVE_WRAPPER = r'''
import copy, importlib.util, json, sys
from pathlib import Path
root, out, feed_url, feed_path = sys.argv[1:5]
spec = importlib.util.spec_from_file_location("rc", Path(root) / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec); spec.loader.exec_module(rc)
default = {r["id"]: r for r in json.load(open(Path(root) / ".ufo/waves/round-26/observe-2.json"))["observations"]}
body = Path(feed_path).read_bytes()
real_observe = rc.observe_one
rc.utc_timestamp = lambda: "2026-10-21T17:00:00Z"
def fake_request(url, opener=None, resolver=None):
    return 200, body, None
rc.request_body = fake_request
def observe_one(source, values, normalizer, **kw):
    if values.get("feed_url") == feed_url:
        return real_observe(source, values, normalizer, **kw)
    return copy.deepcopy(default[values["id"]])
rc.observe_one = observe_one
rc.load_normalizer = lambda root: None
code = rc.main(["--root", root, "--observe", out])
for r in json.load(open(out))["observations"]:
    if r.get("url") == feed_url:
        print("WRITTEN %s verdict=%s parsed=%s error=%s" % (r["id"], r.get("verdict"), (r.get("parsed_version") or "")[:12], (r.get("error") or "")[:60]))
sys.exit(code)
'''


def tree(name, patch=None):
    dest = WORK / name
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(BASE, dest, symlinks=True)
    if patch:
        patch(dest / "corpus" / "release-clock.py")
    return dest


def edit_row(root, row_id, **cols):
    path = root / "corpus" / "release-clocks.tsv"
    lines = path.read_text(encoding="utf-8").split("\n")
    header = lines[0].split("\t")
    for i, line in enumerate(lines):
        fields = line.split("\t")
        if fields[0] == row_id:
            for key, value in cols.items():
                fields[header.index(key)] = value
            lines[i] = "\t".join(fields)
    path.write_text("\n".join(lines), encoding="utf-8")


def mirror_receipt(root, row_id, parsed, verdict):
    src = root / ".ufo/waves/round-26/observe-2.json"
    doc = json.loads(src.read_text(encoding="utf-8"))
    for rec in doc["observations"]:
        if rec["id"] == row_id:
            rec["parsed_version"] = parsed
            rec["verdict"] = verdict
    out = root / "mirror.json"
    out.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out, hashlib.sha256(out.read_bytes()).hexdigest()


def run(argv, root, env_extra=None, isolated=True):
    env = {"PATH": os.environ["PATH"], "LC_ALL": "C"}
    env.update(env_extra or {})
    cmd = [sys.executable] + (["-I", "-B"] if isolated else ["-B"]) + argv
    p = subprocess.run(cmd, cwd=root, env=env, capture_output=True, text=True, timeout=300)
    out = p.stdout + p.stderr
    tb = "Traceback" in out
    lines = [l[:110] for l in out.splitlines() if not l.startswith("  ")]
    return p.returncode, tb, lines


def table_case(label, patch, row_id, receipt_parsed, receipt_verdict, env=None, isolated=True, **cols):
    root = tree(label, patch)
    edit_row(root, row_id, **cols)
    receipt, sha = mirror_receipt(root, row_id, receipt_parsed, receipt_verdict)
    return run(["corpus/release-clock.py", "--receipt", str(receipt), "--receipt-sha", sha],
               root, env, isolated)


def observe_case(label, patch, feed_url, body_fn, src):
    root = tree(label, patch)
    body = body_fn(Path(src).read_bytes())
    feed = root / "fixture-feed.bin"
    feed.write_bytes(body)
    wrapper = root / "observe_wrapper.py"
    wrapper.write_text(OBSERVE_WRAPPER, encoding="utf-8")
    return run([str(wrapper), str(root), str(root / "observe-out.json"), feed_url, str(feed)], root)


PY = "https://www.python.org/downloads/feed.rss"
OB = "https://github.com/openbao/openbao/releases.atom"


def canon_regex_src():
    return r're.compile(r"v?(?:0|[1-9][0-9]{0,4299})\.(?:0|[1-9][0-9]{0,4299})\.(?:0|[1-9][0-9]{0,4299})", re.IGNORECASE)'


def patch_p1(path):
    """P1: guard the table OBSERVATION and the RETURNED feed max only."""
    s = path.read_text(encoding="utf-8")
    s = s.replace('NUMERIC_VERSION_RE = re.compile(r"[0-9]+\\.[0-9]+\\.[0-9]+")',
                  'NUMERIC_VERSION_RE = re.compile(r"[0-9]+\\.[0-9]+\\.[0-9]+")\nCANONICAL_RE = ' + canon_regex_src(), 1)
    old = '        if clock == "feed":\n            feed_source = sources.get(feed_source_id)\n'
    new = ('        if clock == "feed" and observed_version not in ("", "-") and not CANONICAL_RE.fullmatch(observed_version):\n'
           '            errors.add(("NONCANONICAL", source_id))\n            row_valid = False\n'
           '        elif clock == "feed":\n            feed_source = sources.get(feed_source_id)\n')
    assert old in s
    s = s.replace(old, new, 1)
    old = '    return max(stable, key=lambda v: tuple(int(part) for part in v.split(".")))\n'
    new = ('    newest = max(stable, key=lambda v: tuple(int(part) for part in v.split(".")))\n'
           '    if not CANONICAL_RE.fullmatch(newest):\n        raise ValueError("non-canonical version token")\n'
           '    return newest\n')
    assert old in s
    s = s.replace(old, new, 1)
    path.write_text(s, encoding="utf-8")


def patch_p2(path):
    """P2: numeric_version returns None for non-canonical/oversize; parser silently drops them."""
    s = path.read_text(encoding="utf-8")
    old = '    if not NUMERIC_VERSION_RE.fullmatch(value):\n        return None\n'
    new = ('    if not NUMERIC_VERSION_RE.fullmatch(value):\n        return None\n'
           '    if any(len(p) > 4300 or (len(p) > 1 and p[0] == "0") for p in value.split(".")):\n        return None\n')
    assert old in s
    s = s.replace(old, new, 1)
    old = '    return max(stable, key=lambda v: tuple(int(part) for part in v.split(".")))\n'
    new = ('    stable = [v for v in stable if numeric_version(v) is not None]\n'
           '    if not stable:\n        raise ValueError("feed has no canonical stable release")\n'
           '    return max(stable, key=numeric_version)\n')
    assert old in s
    s = s.replace(old, new, 1)
    path.write_text(s, encoding="utf-8")


def patch_p3(path):
    """P3: catch the int() ValueError (bound = interpreter's int_max_str_digits) + leading-zero check."""
    s = path.read_text(encoding="utf-8")
    old = '    return tuple(int(part) for part in value.split("."))\n\n\ndef is_regression'
    new = ('    parts = value.split(".")\n    if any(len(p) > 1 and p[0] == "0" for p in parts):\n        return None\n'
           '    try:\n        return tuple(int(part) for part in parts)\n    except ValueError:\n        return None\n\n\ndef is_regression')
    assert old in s
    s = s.replace(old, new, 1)
    path.write_text(s, encoding="utf-8")


def py_replace(new):
    return lambda b: b.replace(b"<title>Python 3.15.1</title>", b"<title>Python " + new.encode() + b"</title>", 1)


def py_prepend(new):
    return lambda b: b.replace(b"<item>", b"<item><title>Python " + new.encode() + b"</title></item><item>", 1)


def obao_tag(new):
    return lambda b: b.replace(b"releases/tag/v2.7.1\"", b"releases/tag/v" + new.encode() + b"\"", 1)


CASES = [
    ("CONTROL", "table", dict(row_id="S040", receipt_parsed="3.15.1", receipt_verdict="not-fired")),
    ("F1", "table", dict(row_id="S040", receipt_parsed="3.15.01", receipt_verdict="fired", observed_version="3.15.01", verdict="fired")),
    ("F2", "table", dict(row_id="S040", receipt_parsed="3.15." + BIG, receipt_verdict="fired", observed_version="3.15." + BIG, verdict="fired")),
    ("F3replace", "observe", (PY, py_replace("3.15.01"), PYFEED)),
    ("F4replace", "observe", (PY, py_replace("3.15." + BIG), PYFEED)),
    ("F3prepend", "observe", (PY, py_prepend("3.15.01"), PYFEED)),
    ("F4prepend", "observe", (PY, py_prepend("3.15." + BIG), PYFEED)),
    ("CX-canonlie", "table", dict(row_id="S040", receipt_parsed="3.15.2", receipt_verdict="fired", observed_version="3.15.2", verdict="fired")),
    ("CX-anchor-oversize", "table", dict(row_id="S041", receipt_parsed="3.15.1", receipt_verdict="fired", anchored_version="3.15." + BIG, verdict="fired")),
    ("CX-derived-lz-fired", "table", dict(row_id="S014", receipt_parsed="2.7.1", receipt_verdict="fired", anchored_version="2.7.01", verdict="fired")),
    ("CX-derived-lz-notfired", "table", dict(row_id="S014", receipt_parsed="2.7.01", receipt_verdict="not-fired", anchored_version="2.7.01", observed_version="2.7.01")),
    ("CX-major-lz", "table", dict(row_id="S040", receipt_parsed="03.15.1", receipt_verdict="fired", observed_version="03.15.1", verdict="fired")),
    ("CX-4300digits", "table", dict(row_id="S040", receipt_parsed="3.15." + BIG4300, receipt_verdict="fired", observed_version="3.15." + BIG4300, verdict="fired")),
    ("CX-F2-env0-noI", "table-env", dict(row_id="S040", receipt_parsed="3.15." + BIG, receipt_verdict="fired", observed_version="3.15." + BIG, verdict="fired")),
    ("CX-atom-taglz", "observe", (OB, obao_tag("2.7.01"), OBAO)),
]

PATCHES = [("BASE", None), ("P1", patch_p1), ("P2", patch_p2), ("P3", patch_p3)]


def main():
    WORK.mkdir(exist_ok=True)
    results = {}
    for pname, patch in PATCHES:
        for label, kind, spec in CASES:
            name = "%s-%s" % (pname, label)
            if kind == "table":
                code, tb, lines = table_case(name, patch, **spec)
            elif kind == "table-env":
                code, tb, lines = table_case(name, patch, env={"PYTHONINTMAXSTRDIGITS": "0"}, isolated=False, **spec)
            else:
                code, tb, lines = observe_case(name, patch, *spec)
            results[name] = {"exit": code, "traceback": tb, "lines": lines[-8:]}
            print("%-30s exit=%d tb=%s | %s" % (name, code, tb, " ; ".join(lines[-7:])[:600]))
            shutil.rmtree(WORK / name)
    (HERE / "probe-results.json").write_text(json.dumps(results, indent=1) + "\n")


if __name__ == "__main__":
    main()
