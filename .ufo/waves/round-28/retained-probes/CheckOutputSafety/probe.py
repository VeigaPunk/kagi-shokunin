#!/usr/bin/env python3
"""Independent output-safety probe for round-28 candidate 62a33b1.

Checks (independent of the frozen c1-measure classification):
  A. An oversized (4301-digit) non-canonical token in a TABLE row:
       - exit code, no Traceback on stdout/stderr
       - stdout/stderr must NOT contain the raw untrusted token
       - stdout must name a class + row id only
  B. The same token arriving through a FEED (--observe path) with the
       transport stubbed the way the lane's own selftest stubs it.
  C. DERIVED paths (C2): a derived row whose anchored version is
       (i) mismatched with its feed row's located anchor  -> DERIVATION
       (ii) leading-zero                                  -> NON-CANONICAL
       (iii) oversized 4301-digit                         -> NON-CANONICAL
     each must exit 1, print no Traceback, and never echo the token.
  D. Control: unmodified tree, default command.

Nothing here writes to the lane checkout; all runs use the exported
candidate tree under this sandbox.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
TREE = SANDBOX / "cand"
OVERSIZE = "1" * 4301
BIG = "3.15." + OVERSIZE

RUNNER = r'''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location(
    "rc_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''

CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")


def env_for(tmp):
    return {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "HOME": str(tmp),
        "LC_ALL": "C",
        "PYTHONDONTWRITEBYTECODE": "1",
    }


def stage(tmp, name, table_text, sources_text=None):
    root = tmp / name
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    if sources_text is not None:
        (root / "corpus" / "SOURCES.md").write_text(sources_text, encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(table_text, encoding="utf-8")
    return root


def table_edit(tree, edits):
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f and f[0] in edits:
            f[5], f[7] = edits[f[0]]
            out.append("\t".join(f) + "\n")
        else:
            out.append(line)
    return "".join(out)


def narrow_table(tree, keep_ids):
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f and f[0] != "id" and f[0] not in keep_ids:
            continue
        out.append(line)
    return "".join(out)


def narrow_sources(tree, keep_ids):
    lines = (tree / "corpus" / "SOURCES.md").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        s = line.strip()
        if s.startswith("|"):
            cells = [c.strip() for c in s[1:].split("|")]
            if cells and cells[0].startswith("S") and cells[0][1:].isdigit() \
                    and cells[0] not in keep_ids:
                continue
        out.append(line)
    return "".join(out)


def default_receipt():
    return TREE / ".ufo" / "waves" / "round-26" / "observe-2.json"


def mirror_receipt(root, edits):
    doc = json.loads(default_receipt().read_text(encoding="utf-8"))
    for rec in doc["observations"]:
        if rec.get("id") in edits:
            rec["parsed_version"], rec["verdict"] = edits[rec["id"]]
    p = root / "receipt.json"
    p.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
    return p, hashlib.sha256(p.read_bytes()).hexdigest()


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n" % (t, i)
        for i, t in enumerate(titles))
    doc = ('<?xml version="1.0" encoding="utf-8"?>\n'
           '<feed xmlns="http://www.w3.org/2005/Atom">\n'
           "  <title>Python releases (fixture)</title>\n"
           "  <id>https://www.python.org/downloads/feed.rss</id>\n"
           "  <updated>2026-10-21T00:00:00Z</updated>\n" + entries + "</feed>\n")
    return doc.encode("utf-8")


def run(argv, cwd, env):
    p = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                       capture_output=True, timeout=180)
    return {"argv": argv, "exit": p.returncode, "stdout": p.stdout, "stderr": p.stderr}


def scan(res, tokens):
    """Output-safety scan of one run."""
    both = res["stdout"] + res["stderr"]
    out = {
        "exit": res["exit"],
        "traceback": "Traceback" in both,
        "stdout_lines": res["stdout"].splitlines(),
        "stderr_lines": res["stderr"].splitlines(),
        "echoed_tokens": [],
        "max_line_len": max((len(l) for l in both.splitlines()), default=0),
    }
    for label, tok in tokens:
        if tok and tok in both:
            out["echoed_tokens"].append(label)
    return out


def main():
    tmp = Path(tempfile.mkdtemp(prefix="r28-probe-", dir=str(SANDBOX)))
    env = env_for(tmp)
    report = {"tree": str(TREE), "cases": {}}
    runner = tmp / "runner.py"
    runner.write_text(RUNNER, encoding="utf-8")
    try:
        # --- A: table oversize -------------------------------------------------
        root = stage(tmp, "A-table-oversize",
                     table_edit(TREE, {"S040": (BIG, "fired")}))
        rp, sha = mirror_receipt(root, {"S040": (BIG, "fired")})
        res = run(["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                  cwd=TREE, env=env)
        report["cases"]["A-table-oversize"] = scan(
            res, [("oversize-full", BIG), ("oversize-digits", OVERSIZE),
                  ("leading-zero", "3.15.01")])

        # --- A2: table leading zero -------------------------------------------
        root = stage(tmp, "A2-table-leadzero",
                     table_edit(TREE, {"S040": ("3.15.01", "fired")}))
        rp, sha = mirror_receipt(root, {"S040": ("3.15.01", "fired")})
        res = run(["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                  cwd=TREE, env=env)
        report["cases"]["A2-table-leadzero"] = scan(
            res, [("leading-zero", "3.15.01")])

        # --- B: observe oversize (feed carries the bad token) ------------------
        table = narrow_table(TREE, {"S040"})
        sources = narrow_sources(TREE, {"S040", "S039"})
        root = stage(tmp, "B-observe-oversize", table, sources)
        feed = root / "feed.atom"
        feed.write_bytes(atom_feed(["Python " + BIG, "Python 3.15.0"]))
        out_receipt = root / "obs.json"
        res = run(["python3", "-I", "-B", str(runner), str(TREE), str(root),
                   str(out_receipt), str(feed),
                   "https://www.python.org/downloads/feed.rss", "2026-10-21"],
                  cwd=TREE, env=env)
        case = scan(res, [("oversize-full", BIG), ("oversize-digits", OVERSIZE)])
        try:
            doc = json.loads(out_receipt.read_text(encoding="utf-8"))
            case["receipt_records"] = [
                {"id": r.get("id"), "verdict": r.get("verdict"),
                 "error": r.get("error"), "parsed_version": r.get("parsed_version")}
                for r in doc.get("observations", [])]
            raw = out_receipt.read_text(encoding="utf-8")
            case["receipt_echoes_oversize"] = OVERSIZE in raw
        except Exception as exc:  # pragma: no cover - probe diagnostics
            case["receipt_error"] = exc.__class__.__name__
        report["cases"]["B-observe-oversize"] = case

        # --- C: derived paths --------------------------------------------------
        # C1: derived row S008 anchored lowered -> must be DERIVATION (mismatch)
        edits = {"S008": ("3.13.2", "not-fired")}
        root = stage(tmp, "C1-derived-mismatch", table_edit(TREE, edits))
        rp, sha = mirror_receipt(root, {"S008": ("3.13.2", "not-fired")})
        res = run(["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                  cwd=TREE, env=env)
        report["cases"]["C1-derived-mismatch"] = scan(res, [("lowered", "3.13.2")])

        # C2: derived row S008 anchored leading-zero -> NON-CANONICAL
        edits = {"S008": ("3.13.03", "not-fired")}
        root = stage(tmp, "C2-derived-leadzero", table_edit(TREE, edits))
        rp, sha = mirror_receipt(root, {"S008": ("3.13.03", "not-fired")})
        res = run(["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                  cwd=TREE, env=env)
        report["cases"]["C2-derived-leadzero"] = scan(res, [("leadzero", "3.13.03")])

        # C3: derived row S008 anchored oversized -> NON-CANONICAL, no crash
        big_derived = "3.13." + OVERSIZE
        edits = {"S008": (big_derived, "not-fired")}
        root = stage(tmp, "C3-derived-oversize", table_edit(TREE, edits))
        rp, sha = mirror_receipt(root, {"S008": (big_derived, "not-fired")})
        res = run(["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                  cwd=TREE, env=env)
        report["cases"]["C3-derived-oversize"] = scan(
            res, [("oversize-full", big_derived), ("oversize-digits", OVERSIZE)])

        # C4: derived row with a NON-numeric anchor (series) -> version_is_named path
        edits = {"S008": ("3.13.x", "not-fired")}
        root = stage(tmp, "C4-derived-series", table_edit(TREE, edits))
        rp, sha = mirror_receipt(root, {"S008": ("3.13.x", "not-fired")})
        res = run(["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                  cwd=TREE, env=env)
        report["cases"]["C4-derived-series"] = scan(res, [])

        # C5: derived row whose feed_source_id names a row that is not a feed
        lines = (TREE / "corpus" / "release-clocks.tsv").read_text(
            encoding="utf-8").splitlines(keepends=True)
        out = []
        for line in lines:
            f = line.rstrip("\n").split("\t")
            if f and f[0] == "S008":
                f[2] = "S017"  # a rendered-quote registry row, not a feed
                out.append("\t".join(f) + "\n")
            else:
                out.append(line)
        root = stage(tmp, "C5-derived-badfeed", "".join(out))
        rp, sha = mirror_receipt(root, {"S008": ("3.13.3", "not-fired")})
        res = run(["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                   "--root", str(root), "--receipt", str(rp), "--receipt-sha", sha],
                  cwd=TREE, env=env)
        report["cases"]["C5-derived-badfeed"] = scan(res, [])

        # --- D: control --------------------------------------------------------
        res = run(["python3", "-I", "-B", "corpus/release-clock.py"],
                  cwd=TREE, env=env)
        report["cases"]["D-control"] = scan(res, [])

        # --- E: selftest isolation --------------------------------------------
        res = run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"],
                  cwd=TREE, env=env)
        report["cases"]["E-selftest"] = scan(res, [])
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    outp = SANDBOX / "probe-result.json"
    outp.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    for name, case in report["cases"].items():
        print("== %s exit=%s traceback=%s echoed=%s maxlen=%s" % (
            name, case["exit"], case["traceback"], case["echoed_tokens"],
            case["max_line_len"]))
        for line in case["stdout_lines"][:12]:
            print("   OUT| %s" % (line[:160]))
        for line in case["stderr_lines"][:12]:
            print("   ERR| %s" % (line[:160]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
