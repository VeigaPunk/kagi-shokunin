#!/usr/bin/env python3
"""Derived-path / output-safety probe #2 (round-28 candidate 62a33b1).

Fixes probe #1's mistake: the DERIVATION path reads the row's ANCHORED
version (field 4), so these fixtures edit fields[4] (anchored) and fields[5]
(observed) together, exactly as the frozen C2 fixture G1 does.

Cases (all in the sandbox; lane checkout untouched):
  D1  derived S008 anchored lowered to 3.13.2 (feed S033 anchor names 3.13.3)
      -> expect DERIVATION S008, exit 1, no traceback, token not echoed.
  D2  derived S008 anchored leading-zero 3.13.03 -> NON-CANONICAL, no crash.
  D3  derived S008 anchored oversized (4301 digits) -> NON-CANONICAL, no crash,
      oversized token must not appear in stdout/stderr.
  D4  derived S008 anchored 4-component 3.13.1.1 -> no crash, typed finding.
  D5  derived S008 anchored huge 4-component-ish "3.13." + 4301 digits is D3;
      D5 = derived S008 whose feed_source_id names a MISSING registry row
      -> feed_source is None -> no crash (KeyError/TypeError would show).
  D6  derived S008 anchored lowered AND verdict=fired -> still typed, no
      fired observation, no crash.
  D7  derived S008 anchored lowered, receipt NOT mirrored (default receipt)
      -> receipt mismatch path, no crash.
  D8  observe path with a feed whose newest canonical entry is ABOVE a
      non-canonical entry (leading-zero token strictly lower than newest):
      does the feed still parse (silently ignoring the bad token) or fail?
  D9  same, but the feed's ONLY entry is non-canonical -> must fail typed.
  D10 timing: STABLE_TOKEN_RE.findall over an anchor cell holding a 4301-digit
      token (DoS / catastrophic-backtracking probe).
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

SANDBOX = Path(__file__).resolve().parent
TREE = SANDBOX / "cand"
OVERSIZE = "1" * 4301
BIG3 = "3.13." + OVERSIZE
CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")

RUNNER = r'''#!/usr/bin/env python3
import importlib.util, sys
from pathlib import Path
tree, root, out, feed_file, feed_url, observed_at = sys.argv[1:7]
spec = importlib.util.spec_from_file_location("rc_fixture", Path(tree) / "corpus" / "release-clock.py")
module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
feed_bytes = Path(feed_file).read_bytes()
def fixture_request_body(url, opener=None, resolver=None):
    if url == feed_url:
        return 200, feed_bytes, None
    return None, None, "fixture harness: unexpected URL fetch"
module.request_body = fixture_request_body
module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
raise SystemExit(module.main(["--root", root, "--observe", out]))
'''


def env_for(tmp):
    return {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": str(tmp),
            "LC_ALL": "C", "PYTHONDONTWRITEBYTECODE": "1"}


def stage(tmp, name, table_text, sources_text=None):
    root = tmp / name
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(TREE / "corpus" / rel, root / "corpus" / rel)
    if sources_text is not None:
        (root / "corpus" / "SOURCES.md").write_text(sources_text, encoding="utf-8")
    (root / "corpus" / "release-clocks.tsv").write_text(table_text, encoding="utf-8")
    return root


def edit(tree, edits, keep=None):
    """edits: row id -> dict of field index -> new value."""
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    out = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f and f[0] in edits:
            for idx, val in edits[f[0]].items():
                f[idx] = val
            out.append("\t".join(f) + "\n")
        elif keep is not None and f and f[0] != "id" and f[0] not in keep:
            continue
        else:
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


def mirror_receipt(root, edits):
    doc = json.loads((TREE / ".ufo" / "waves" / "round-26" / "observe-2.json")
                     .read_text(encoding="utf-8"))
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
    t0 = time.time()
    p = subprocess.run(argv, cwd=str(cwd), env=env, text=True,
                       capture_output=True, timeout=300)
    return {"argv": argv, "exit": p.returncode, "stdout": p.stdout,
            "stderr": p.stderr, "secs": round(time.time() - t0, 3)}


def scan(res, tokens):
    both = res["stdout"] + res["stderr"]
    return {"exit": res["exit"], "secs": res["secs"],
            "traceback": "Traceback" in both,
            "stdout_lines": res["stdout"].splitlines(),
            "stderr_lines": res["stderr"].splitlines(),
            "echoed": [label for label, tok in tokens if tok and tok in both],
            "max_line_len": max((len(l) for l in both.splitlines()), default=0)}


def main():
    tmp = Path(tempfile.mkdtemp(prefix="r28-probe2-", dir=str(SANDBOX)))
    env = env_for(tmp)
    runner = tmp / "runner.py"
    runner.write_text(RUNNER, encoding="utf-8")
    cases = {}
    try:
        def table_case(name, edits, mirror=None, keep=None, sources_keep=None):
            table = edit(TREE, edits, keep=keep)
            sources = narrow_sources(TREE, sources_keep) if sources_keep else None
            root = stage(tmp, name, table, sources)
            argv = ["python3", "-I", "-B", str(TREE / "corpus" / "release-clock.py"),
                    "--root", str(root)]
            if mirror:
                rp, sha = mirror_receipt(root, mirror)
                argv += ["--receipt", str(rp), "--receipt-sha", sha]
            cases[name] = scan(run(argv, TREE, env),
                               [("oversize", OVERSIZE), ("leadzero", "3.13.03"),
                                ("lowered", "3.13.2"), ("4comp", "3.13.1.1")])

        # D1: derived anchor lowered -> DERIVATION
        table_case("D1-derived-lowered",
                   {"S008": {4: "3.13.2", 5: "3.13.2", 7: "not-fired"}},
                   mirror={"S008": ("3.13.2", "not-fired")})
        # D2: derived anchor leading zero
        table_case("D2-derived-leadzero",
                   {"S008": {4: "3.13.03", 5: "3.13.03", 7: "not-fired"}},
                   mirror={"S008": ("3.13.03", "not-fired")})
        # D3: derived anchor oversized
        table_case("D3-derived-oversize",
                   {"S008": {4: BIG3, 5: BIG3, 7: "not-fired"}},
                   mirror={"S008": (BIG3, "not-fired")})
        # D4: derived anchor 4 components
        table_case("D4-derived-4comp",
                   {"S008": {4: "3.13.1.1", 5: "3.13.1.1", 7: "not-fired"}},
                   mirror={"S008": ("3.13.1.1", "not-fired")})
        # D5: derived row whose feed_source_id names a missing registry row
        table_case("D5-derived-missing-feed",
                   {"S008": {2: "S999", 4: "3.13.2", 5: "3.13.2", 7: "not-fired"}},
                   mirror={"S008": ("3.13.2", "not-fired")})
        # D6: derived anchor lowered but verdict fired
        table_case("D6-derived-lowered-fired",
                   {"S008": {4: "3.13.2", 5: "3.13.2", 7: "fired"}},
                   mirror={"S008": ("3.13.2", "fired")})
        # D7: derived anchor lowered, default receipt (not mirrored)
        table_case("D7-derived-lowered-default-receipt",
                   {"S008": {4: "3.13.2", 5: "3.13.2", 7: "not-fired"}},
                   mirror=None)
        # D8: feed newest canonical ABOVE a lower non-canonical entry
        table = edit(TREE, {}, keep={"S040"})
        sources = narrow_sources(TREE, {"S040", "S039"})
        root = stage(tmp, "D8-observe-lower-noncanonical", table, sources)
        feed = root / "feed.atom"
        feed.write_bytes(atom_feed(["Python 3.15.5", "Python 3.14.01"]))
        outp = root / "obs.json"
        res = run(["python3", "-I", "-B", str(runner), str(TREE), str(root),
                   str(outp), str(feed),
                   "https://www.python.org/downloads/feed.rss", "2026-10-21"],
                  TREE, env)
        c = scan(res, [("leadzero", "3.14.01")])
        try:
            doc = json.loads(outp.read_text(encoding="utf-8"))
            c["receipt_records"] = [
                {"id": r.get("id"), "verdict": r.get("verdict"),
                 "error": r.get("error"), "parsed_version": r.get("parsed_version")}
                for r in doc.get("observations", [])]
        except Exception as exc:
            c["receipt_error"] = exc.__class__.__name__
        cases["D8-observe-lower-noncanonical"] = c
        # D9: feed whose only entry is non-canonical
        root = stage(tmp, "D9-observe-only-noncanonical", table, sources)
        feed = root / "feed.atom"
        feed.write_bytes(atom_feed(["Python 3.15.01"]))
        outp = root / "obs.json"
        res = run(["python3", "-I", "-B", str(runner), str(TREE), str(root),
                   str(outp), str(feed),
                   "https://www.python.org/downloads/feed.rss", "2026-10-21"],
                  TREE, env)
        c = scan(res, [("leadzero", "3.15.01")])
        try:
            doc = json.loads(outp.read_text(encoding="utf-8"))
            c["receipt_records"] = [
                {"id": r.get("id"), "verdict": r.get("verdict"),
                 "error": r.get("error"), "parsed_version": r.get("parsed_version")}
                for r in doc.get("observations", [])]
        except Exception as exc:
            c["receipt_error"] = exc.__class__.__name__
        cases["D9-observe-only-noncanonical"] = c
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    # D10: regex behaviour on a huge token inside an anchor cell
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "rc10", TREE / "corpus" / "release-clock.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    t0 = time.time()
    toks = m.STABLE_TOKEN_RE.findall("Entry titled v3.13.3, " + OVERSIZE)
    d10 = {"findall_secs": round(time.time() - t0, 3), "n_tokens": len(toks),
           "token_lens": [len(t) for t in toks]}
    t0 = time.time()
    hit = m.version_is_named("Entry titled v3.13.3", "3.13." + OVERSIZE)
    d10["version_is_named_secs"] = round(time.time() - t0, 3)
    d10["version_is_named"] = hit
    cases["D10-regex-timing"] = d10

    (SANDBOX / "probe2-result.json").write_text(
        json.dumps(cases, indent=2) + "\n", encoding="utf-8")
    for name, c in cases.items():
        if "stdout_lines" in c:
            print("== %s exit=%s secs=%s traceback=%s echoed=%s" % (
                name, c["exit"], c["secs"], c["traceback"], c["echoed"]))
            for l in c["stdout_lines"][:8]:
                print("   OUT| %s" % l[:200])
            for l in c["stderr_lines"][:8]:
                print("   ERR| %s" % l[:200])
            if "receipt_records" in c:
                print("   REC| %s" % json.dumps(c["receipt_records"]))
        else:
            print("== %s %s" % (name, json.dumps(c)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
