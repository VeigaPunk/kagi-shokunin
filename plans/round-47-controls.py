#!/usr/bin/env python3
"""plans/round-47-controls.py -- round 47 pre-freeze controls for plans/round-47-c1.sh and
plans/round-47-c2.sh. Each control is a fixture tree built from BASE 252ef1ca (git archive) plus
one named change, scored by the frozen counter through C1_TREE / C2_TREE. Every expected value
below was written before the control ran; a control MATCHes only when the counter's printed
value (or SETUP refusal) equals it.

usage: python3 plans/round-47-controls.py CAPDIR OUT
  CAPDIR  directory holding the L1's live captures (S099.body, S012.body ... S026.body) and
          capture-times.tsv (id<TAB>fetched_at) -- the positive controls' inputs
  OUT     receipt file (absolute path)
Exit 0 when every control MATCHes, 1 otherwise, 2 on setup.
"""
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = "252ef1cac9f41d84639c0d1f211d0e0911196112"
F = "S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026".split()
S099_URL = ("https://raw.githubusercontent.com/VeigaPunk/shokunin/"
            "75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md")
S099_QUOTE = "The claim is judged on the counter, kill rule and predicate declared before data. A rule"
SCRATCH = os.path.join(os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku"), "kagi-r47")


def sha(path):
    with open(path, "rb") as h:
        return hashlib.sha256(h.read()).hexdigest()


def base_tree(dest):
    os.makedirs(dest)
    a = subprocess.run(["git", "-C", REPO, "archive", BASE], stdout=subprocess.PIPE, check=True)
    subprocess.run(["tar", "-x", "-C", dest], input=a.stdout, check=True)


def append(path, text):
    with open(path, "a", encoding="utf-8") as h:
        h.write(text)


def sub_file(path, old, new):
    with open(path, encoding="utf-8") as h:
        s = h.read()
    if old not in s:
        raise SystemExit("SETUP: pattern absent in %s: %r" % (path, old[:60]))
    with open(path, "w", encoding="utf-8") as h:
        h.write(s.replace(old, new, 1))


def s099_row(body_sha, body_bytes, fetched="2026-11-06"):
    url = S099_URL
    ident = hashlib.sha256(("S099\tmined\t%s\n" % url).encode()).hexdigest()
    return "\t".join(["S099", "mined", ident, url, url, "200", "curl-fsSL-compressed-v1", fetched,
                      "decoded-http-body-v1", body_sha, str(body_bytes),
                      "75dd26121698f10cf111120f6cbcd2b2125598f1", S099_QUOTE, "raw-literal-v1", "-",
                      "§6 item 9, line 561, byte offset 52924"]) + "\n"


def c1_fix(t, capdir, body_sha=None, with_sources=True, with_capture=True):
    """the reference C1 change: source: lines appended to the two lessons, one S099 provenance
    row, the committed capture."""
    body = os.path.join(capdir, "S099.body")
    if with_sources:
        append(os.path.join(t, "corpus/lessons/round-43.md"),
               "\nsource: S094 (CORPUS.md §SOURCES.md rule 2, re-opened 2026-11-05 by this round)\n")
        append(os.path.join(t, "corpus/lessons/round-44.md"),
               "\nsource: S099 (fleet round-44 prompt §6 item 9, opened 2026-11-05 by this round)\n")
    append(os.path.join(t, "corpus/source-fetches.tsv"),
           s099_row(body_sha or sha(body), os.path.getsize(body)))
    if with_capture:
        d = os.path.join(t, ".ufo/waves/round-47/capture")
        os.makedirs(d, exist_ok=True)
        shutil.copyfile(body, os.path.join(d, "S099.body"))


def c2_fix(t, capdir, times=None, quote_counts=None, verdict="teaching-holds", captures=True):
    rows = {}
    with open(os.path.join(t, "corpus/SOURCES.md"), encoding="utf-8") as h:
        for line in h:
            if line.startswith("| S"):
                cells = line.split("|")
                rows[cells[1].strip()] = cells[2]
    clocks = {}
    with open(os.path.join(t, "corpus/release-clocks.tsv"), encoding="utf-8") as h:
        for line in h:
            c = line.rstrip("\n").split("\t")
            clocks[c[0]] = c
    fetch_q = {}
    with open(os.path.join(t, "corpus/source-fetches.tsv"), encoding="utf-8") as h:
        for line in h:
            c = line.rstrip("\n").split("\t")
            if len(c) == 16:
                fetch_q[c[0]] = c[12]
    times = times or {}
    d = os.path.join(t, ".ufo/waves/round-47/capture")
    os.makedirs(d, exist_ok=True)
    out = ["\t".join(["id", "url", "observed_release", "fetched_at", "capture_path", "sha256",
                      "bytes", "quote_count", "verdict"])]
    for i in F:
        src = os.path.join(capdir, "%s.body" % i)
        url = rows[i][rows[i].index("https://"):].split()[0]
        cap = ".ufo/waves/round-47/capture/%s.body" % i
        if captures:
            shutil.copyfile(src, os.path.join(t, cap))
        r = subprocess.run(["python3", os.path.join(t, "corpus/rendered-text-v1.py"), "locate", src,
                            fetch_q[i]], stdout=subprocess.PIPE, text=True)
        k = r.stdout.split("count=")[1].split()[0] if "count=" in r.stdout else "0"
        if quote_counts and i in quote_counts:
            k = quote_counts[i]
        out.append("\t".join([i, url, clocks[i][5], times.get(i, TIMES[i]), cap, sha(src),
                              str(os.path.getsize(src)), k, verdict]))
    with open(os.path.join(t, "corpus/fired-reverify.tsv"), "w", encoding="utf-8") as h:
        h.write("\n".join(out) + "\n")


def run(counter, env_extra):
    env = dict(os.environ)
    env.update(env_extra)
    r = subprocess.run(["bash", os.path.join(REPO, "plans", counter)], stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, text=True, env=env)
    return r.returncode, r.stdout.strip().splitlines()[-1] if r.stdout.strip() else ""


def value_of(line):
    if ": SETUP " in line:
        return "SETUP"
    return line.split("value=")[1].split()[0]


def main(argv):
    global TIMES
    if len(argv) != 2:
        print(__doc__)
        return 2
    capdir, outp = argv
    TIMES = {}
    with open(os.path.join(capdir, "capture-times.tsv"), encoding="utf-8") as h:
        for line in h:
            i, ts = line.split()
            TIMES[i] = ts
    asof = str(int(time.time()) + 3600)
    os.makedirs(SCRATCH, exist_ok=True)
    work = tempfile.mkdtemp(prefix="controls.", dir=SCRATCH)
    results = []
    try:
        def control(name, counter, expect, build, extra=None):
            t = os.path.join(work, name)
            base_tree(t)
            build(t)
            key = "C1_TREE" if counter.endswith("c1.sh") else "C2_TREE"
            env = {key: t, "C2_ASOF": asof}
            env.update(extra or {})
            rc, line = run(counter, env)
            got = value_of(line)
            verdict = "MATCH" if got == expect else "MISMATCH"
            results.append("%s %s expect=%s got=%s rc=%d :: %s" % (verdict, name, expect, got, rc, line))

        # ---- C1 ----------------------------------------------------------------------
        control("K1-0-do-nothing", "round-47-c1.sh", "0", lambda t: None)
        control("K1-P-reference", "round-47-c1.sh", "3", lambda t: c1_fix(t, capdir))

        def k1_f1(t):  # used-by narrowing: drop the non-citing paths instead of citing
            p = os.path.join(t, "corpus/SOURCES.md")
            sub_file(p, "corpus/lessons/round-39.md, corpus/lessons/round-42.md, corpus/lessons/round-43.md",
                     "corpus/lessons/round-39.md, corpus/lessons/round-42.md")
            c1_fix(t, capdir, with_sources=False)
            sub_file(p, "| 2026-11-05 | 90d | corpus/lessons/round-44.md |",
                     "| 2026-11-05 | 90d | corpus/lessons/round-39.md |")
        control("K1-F1-usedby-narrowing", "round-47-c1.sh", "0", k1_f1)
        control("K1-F2-handwritten-provenance", "round-47-c1.sh", "0",
                lambda t: c1_fix(t, capdir, body_sha="0" * 64, with_capture=False))

        def k1_f3(t):  # delete the two rows outright
            p = os.path.join(t, "corpus/SOURCES.md")
            with open(p, encoding="utf-8") as h:
                lines = [l for l in h if not (l.startswith("| S094 ") or l.startswith("| S099 "))]
            with open(p, "w", encoding="utf-8") as h:
                h.writelines(lines)
        control("K1-F3-row-deletion", "round-47-c1.sh", "0", k1_f3)

        def k1_f4(t):  # positive tree with a census that prints nothing -> SETUP, never 0 findings
            c1_fix(t, capdir)
            with open(os.path.join(t, "corpus/sources-census.sh"), "w") as h:
                h.write("#!/usr/bin/env bash\nexit 0\n")
        control("K1-F4-silent-census", "round-47-c1.sh", "SETUP", k1_f4)

        def k1_f5(t):  # fix plus a new finding elsewhere (S001 status flipped in provenance only)
            c1_fix(t, capdir)
            p = os.path.join(t, "corpus/source-fetches.tsv")
            with open(p, encoding="utf-8") as h:
                s = h.read()
            s = s.replace("\nS001\tmined\t", "\nS001\tqueued\t", 1) if "\nS001\tmined\t" in s else s
            with open(p, "w", encoding="utf-8") as h:
                h.write(s)
        control("K1-F5-fix-plus-new-finding", "round-47-c1.sh", "0", k1_f5)

        # ---- C2 ----------------------------------------------------------------------
        control("K2-0-do-nothing", "round-47-c2.sh", "0", lambda t: None)
        control("K2-P-reference", "round-47-c2.sh", "11", lambda t: c2_fix(t, capdir))
        control("K2-F1-ledger-without-captures", "round-47-c2.sh", "0",
                lambda t: c2_fix(t, capdir, captures=False))
        control("K2-F2-stale-dates-r36", "round-47-c2.sh", "0",
                lambda t: c2_fix(t, capdir, times={i: "2026-11-04T12:00:00Z" for i in F}))
        control("K2-F3-future-dates", "round-47-c2.sh", "0",
                lambda t: c2_fix(t, capdir, times={i: "2026-12-01T00:00:00Z" for i in F}))

        def k2_f4(t):  # quote swap: a trivially present word replaces the declared quote
            c2_fix(t, capdir)
            p = os.path.join(t, "corpus/source-fetches.tsv")
            with open(p, encoding="utf-8") as h:
                rows = h.read().split("\n")
            for n, line in enumerate(rows):
                c = line.split("\t")
                if len(c) == 16 and c[0] in F:
                    c[12] = "the"
                    rows[n] = "\t".join(c)
            with open(p, "w", encoding="utf-8") as h:
                h.write("\n".join(rows))
        control("K2-F4-quote-swap", "round-47-c2.sh", "0", k2_f4)
        control("K2-F5-verdict-unset", "round-47-c2.sh", "0",
                lambda t: c2_fix(t, capdir, verdict="pending"))

        def k2_f6(t):  # reverified but the clock gate broken (S008, outside F, observed version edited)
            c2_fix(t, capdir)
            p = os.path.join(t, "corpus/release-clocks.tsv")
            sub_file(p, "S008\tfeed\tS033\thttps://github.com/getsops/sops/releases.atom\t3.13.3\t3.13.3",
                     "S008\tfeed\tS033\thttps://github.com/getsops/sops/releases.atom\t3.13.3\t3.13.2")
        control("K2-F6-gate-broken", "round-47-c2.sh", "0", k2_f6)

        def k2_f7(t):  # normalizer removed -> SETUP, never located
            c2_fix(t, capdir)
            os.remove(os.path.join(t, "corpus/rendered-text-v1.py"))
        control("K2-F7-normalizer-missing", "round-47-c2.sh", "SETUP", k2_f7)
        # named ceiling: hand-typed fetched_at inside the window over byte-correct bodies
        control("K2-C-handtyped-times-ceiling", "round-47-c2.sh", "11",
                lambda t: c2_fix(t, capdir, times={i: "2026-11-06T00:00:01Z" for i in F}))
    finally:
        shutil.rmtree(work, ignore_errors=True)
    bad = sum(1 for r in results if not r.startswith("MATCH"))
    with open(outp, "w", encoding="utf-8") as h:
        h.write("# round-47 pre-freeze controls; BASE %s; run %s\n" % (
            BASE, time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())))
        h.write("\n".join(results) + "\n")
        h.write("CONTROLS: %s (match=%d mismatch=%d)\n" % ("ALL-MATCH" if bad == 0 else "MISMATCH",
                                                          len(results) - bad, bad))
    print(open(outp, encoding="utf-8").read())
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
