#!/usr/bin/env python3
"""Demonstrate proposed controls for surviving round-54 C1 mutants.

Each case builds the reference fixture (BASE archive + committed capture + ref
overlay) under scratch, applies one edit, then runs a chosen counter with --tree.
Usage: propose.py <case> <counter>
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

S = "/fast/scratch/hyaku/kagi-r54/R54MutCounter"
ORIG = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
LANE = os.path.join(S, "lane")
BASE = "1a0f43a9220bb0e995462c2aef745ac0124c3317"
REF = os.path.join(LANE, ".ufo/waves/round-54/controls/fixtures/ref/c1")
CAP = os.path.join(LANE, ".ufo/waves/round-54/capture/S112.body")
OPFEED = "https://releases.1password.com/developers/cli/index.xml"


def fixture():
    d = tempfile.mkdtemp(prefix="propose.", dir=S)
    arc = subprocess.run(["git", "-C", LANE, "archive", BASE], capture_output=True, check=True).stdout
    subprocess.run(["tar", "-x", "-C", d], input=arc, check=True)
    capdir = os.path.join(d, ".ufo/waves/round-54/capture")
    os.makedirs(capdir, exist_ok=True)
    shutil.copy2(CAP, capdir)
    subprocess.run(["cp", "-a", REF + "/.", d + "/"], check=True)
    return d


def setclock(d, col, value):
    p = os.path.join(d, "corpus/release-clocks.tsv")
    out = []
    for line in open(p, encoding="utf-8").read().split("\n"):
        f = line.split("\t")
        if f[0] == "S072":
            f[col] = value
        out.append("\t".join(f))
    open(p, "w", encoding="utf-8").write("\n".join(out))


def redigest(d):
    g = os.path.join(d, "corpus/release-clock.py")
    r = os.path.join(d, ".ufo/waves/round-54/final/observe-r54.json")
    t = open(g, encoding="utf-8").read()
    t = re.sub(r"(?m)^DEFAULT_RECEIPT_SHA256 = \"[0-9a-f]{64}\"$",
               'DEFAULT_RECEIPT_SHA256 = "%s"' % hashlib.sha256(open(r, "rb").read()).hexdigest(), t)
    open(g, "w", encoding="utf-8").write(t)


def edit(d, rel, fn):
    p = os.path.join(d, rel)
    t = open(p, encoding="utf-8").read()
    t2 = fn(t)
    assert t2 != t, "edit had no effect on " + rel
    open(p, "w", encoding="utf-8").write(t2)


def case(name, d):
    if name == "P-M01":
        # S072 recheck back to 180d, clock row kept (honest gate: ORPHAN -> FAILED)
        edit(d, "corpus/SOURCES.md", lambda t: t.replace(
            "| mined | 2026-11-03 | on-release | corpus/lessons/round-32.md |",
            "| mined | 2026-11-03 | 180d | corpus/lessons/round-32.md |"))
    elif name == "P-M02":
        setclock(d, 4, "2.40.0")          # anchored 2.41.1 -> 2.40.0, observed stays 2.42.0, verdict fired
    elif name == "P-M03":
        setclock(d, 5, "v2.42.0")         # observed spelled v2.42.0: gate norm_version OK, counter exact-string fires
    elif name == "P-M03x":
        setclock(d, 5, "2.41.1")          # observed 2.42.0 -> 2.41.1
        r = os.path.join(d, ".ufo/waves/round-54/final/observe-r54.json")
        doc = json.loads(open(r, encoding="utf-8").read())
        [o for o in doc["observations"] if o["id"] == "S072"][0]["parsed_version"] = "2.41.1"
        open(r, "w", encoding="utf-8").write(json.dumps(doc, indent=2, sort_keys=True) + "\n")
        redigest(d)
    elif name == "P-M04":
        setclock(d, 7, "not-fired")        # verdict fired -> not-fired
    elif name == "P-M05":
        # second registry row carrying the very same feed_url (recheck 90d, so the
        # gate has no clock obligation for it); counter's feed-url uniqueness must fire
        row = ("| S113 | 1Password CLI releases (duplicate URL proposal) — %s | docs | A | "
               "duplicate-URL probe | — | — | mined | 2026-11-07 | 90d | — |" % OPFEED)
        edit(d, "corpus/SOURCES.md", lambda t: t.replace(
            "\n| S112 |", "\n" + row + "\n| S112 |", 1))
    elif name == "P-M06":
        edit(d, "corpus/release-clock.py", lambda t: t.replace(
            'return root / ".ufo" / "waves" / "round-54" / "final" / "observe-r54.json"',
            'return root / ".ufo" / "waves" / "round-54" / "final" / "observe-r54-alt.json"'))
        shutil.copy2(os.path.join(d, ".ufo/waves/round-54/final/observe-r54.json"),
                     os.path.join(d, ".ufo/waves/round-54/final/observe-r54-alt.json"))
    elif name == "P-M07":
        r = os.path.join(d, ".ufo/waves/round-54/final/observe-r54.json")
        open(r, "ab").write(b" ")
    elif name == "P-M11":
        edit(d, "corpus/release-clock.py", lambda t: t.replace(
            "def parse_latest_version(body, title_prefix=None):",
            "def parse_latest_version(body, title_prefix=None):\n"
            "    if len(body) > 10000 and b\"1Password CLI 2.42.0\" in body:\n        return \"2.43.0\"", 1))
    elif name == "P-M12":
        p = os.path.join(d, "corpus/release-clocks.tsv")
        with open(p, "a", encoding="utf-8") as f:
            f.write("S099\tfeed\tS099\thttps://example.invalid/x.xml\t1.0.0\t1.0.1\t"
                    "2026-11-07\tnot-fired\tproposal orphan row\n")
    elif name == "P-M15":
        edit(d, ".ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt", lambda t: re.sub(
            r"(?m)^probe_sha256=[0-9a-f]{64}$", "probe_sha256=" + "0" * 64, t))
    elif name == "P-M16":
        edit(d, ".ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt", lambda t: re.sub(
            r"(?m)^DOTENV_BYTES_CASE id=newline-only status=PASS\n", "", t))
    elif name == "P-M17":
        edit(d, "corpus/knowledge/op-ref-consumption.md", lambda t: re.sub(
            r"(?m)^### 11\.2 .*\n", "", t, count=1))
    elif name == "P-M19":
        edit(d, "corpus/release-clock.py", lambda t: t.replace(
            "    print(\"RELEASE_CLOCK_SELFTEST: PASS (%d cases)\" % cases)\n    return 0",
            "    print(\"RELEASE_CLOCK_SELFTEST: FAIL (proposal)\")\n    return 1", 1))
    else:
        raise SystemExit("unknown case " + name)
    return d


def run(counter, d):
    env = dict(os.environ, HYAKU_SCRATCH="/fast/scratch/hyaku",
               C1_ASOF=str(int(subprocess.run(["date", "-u", "+%s"],
                                              capture_output=True, text=True).stdout.strip())))
    p = subprocess.run(["bash", counter, "--tree", d], capture_output=True, text=True, env=env)
    line = p.stdout.strip().splitlines()[-1] if p.stdout.strip() else ""
    m = re.search(r"value=(\d+)", line)
    return (m.group(1) if m else "SETUP"), line, p.returncode


if __name__ == "__main__":
    name = sys.argv[1]
    counter = sys.argv[2]
    d = fixture()
    try:
        case(name, d)
        val, line, rc = run(counter, d)
        print("%s counter=%s value=%s rc=%s\n  %s" % (
            name, os.path.basename(counter), val, rc, line))
    finally:
        shutil.rmtree(d, ignore_errors=True)
