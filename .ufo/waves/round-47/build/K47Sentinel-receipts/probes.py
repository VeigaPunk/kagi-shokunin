#!/usr/bin/env python3
"""K47Sentinel probe program -- adversarial checks of the round-47 frozen counters.

Read-only with respect to the lane: every tree is built by `git archive BASE` into
$HYAKU_SCRATCH/kagi-r47/K47Sentinel and scored through the frozen counters' fixture mode
(C1_TREE / C2_TREE ... C2_ASOF). Nothing under corpus/, plans/, .ufo/state or any registry is
written; the lane repo is only read (`git archive`, `git show`).

D1  C1 with corpus/sources-census.sh replaced by a 3-line stub that prints CLEAN
    -> value=3 with the two lessons byte-identical at BASE (no calibration work done).
D2  C2 with 11 captures that provably do not contain the quote, plus a stub normalizer
    that prints `count=1` -> value=11.
D3  C2 as D2 plus a doctored corpus/release-clock.py and a broken clock row
    (the exact mutation K2-F6 catches) -> value=11, gate=1.
D4  C2 with one capture as a symlink to a host file outside the tree -> that id reverified.
D5  C2 tree mode with fetched_at=2029-06-01 and caller-declared C2_ASOF=2030-01-01 -> value=11.
Run: python3 -B probes.py
"""
import calendar, hashlib, os, shutil, subprocess, sys, time

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
BASE = "252ef1cac9f41d84639c0d1f211d0e0911196112"
FLEET_PROMPT = "/home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-44.md"
SCR = os.path.join(os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku"), "kagi-r47", "K47Sentinel")
F = "S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026".split()


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def tree(dest):
    if os.path.isdir(dest):
        shutil.rmtree(dest)
    os.makedirs(dest)
    a = subprocess.run(["git", "-C", LANE, "archive", BASE], stdout=subprocess.PIPE, check=True)
    subprocess.run(["tar", "-x", "-C", dest], input=a.stdout, check=True)
    return dest


def run(counter, extra):
    env = dict(os.environ)
    env.update(extra)
    r = subprocess.run(["bash", os.path.join(LANE, "plans", counter)], stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, text=True, env=env)
    lines = r.stdout.strip().splitlines()
    return r.returncode, (lines[-1] if lines else "")


def c2_material(t, dummy=True):
    """ledger + captures; dummy=True writes bodies that do not contain any quote."""
    reg, clk = {}, {}
    for line in open(os.path.join(t, "corpus/SOURCES.md"), encoding="utf-8"):
        if line.startswith("| S"):
            c = line.split("|")
            if "https://" in c[2]:
                reg[c[1].strip()] = c[2][c[2].index("https://"):].split()[0]
    for line in open(os.path.join(t, "corpus/release-clocks.tsv"), encoding="utf-8"):
        c = line.rstrip("\n").split("\t")
        clk[c[0]] = c
    capd = os.path.join(t, ".ufo/waves/round-47/capture")
    os.makedirs(capd, exist_ok=True)
    rows = ["\t".join(["id", "url", "observed_release", "fetched_at", "capture_path", "sha256",
                       "bytes", "quote_count", "verdict"])]
    for i in F:
        p = os.path.join(capd, i + ".body")
        if dummy:
            open(p, "w").write("placeholder body for %s -- no documentation text\n" % i)
        rows.append("\t".join([i, reg[i], clk[i][5], "2026-11-06T00:00:01Z",
                               ".ufo/waves/round-47/capture/%s.body" % i, sha(p),
                               str(os.path.getsize(p)), "1", "teaching-holds"]))
    open(os.path.join(t, "corpus/fired-reverify.tsv"), "w").write("\n".join(rows) + "\n")
    return rows


def doctored_normalizer(t):
    open(os.path.join(t, "corpus/rendered-text-v1.py"), "w").write(
        "#!/usr/bin/env python3\nimport sys\nprint('count=1')\n")


def main():
    os.makedirs(SCR, exist_ok=True)
    out = []

    # D1
    t1 = tree(os.path.join(SCR, "d1"))
    before = {p: sha(os.path.join(t1, p)) for p in ("corpus/lessons/round-43.md",
                                                    "corpus/lessons/round-44.md")}
    open(os.path.join(t1, "corpus/sources-census.sh"), "w").write(
        '#!/usr/bin/env bash\necho "SOURCES_CENSUS: CLEAN (rows=102)"\nexit 0\n')
    capd = os.path.join(t1, ".ufo/waves/round-47/capture")
    os.makedirs(capd, exist_ok=True)
    shutil.copyfile(FLEET_PROMPT, os.path.join(capd, "S099.body"))
    url = ("https://raw.githubusercontent.com/VeigaPunk/shokunin/"
           "75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md")
    q = "The claim is judged on the counter, kill rule and predicate declared before data. A rule"
    open(os.path.join(t1, "corpus/source-fetches.tsv"), "a").write("\t".join(
        ["S099", "mined", "ident", url, url, "200", "curl-fsSL-compressed-v1", "2026-11-06",
         "decoded-http-body-v1", sha(FLEET_PROMPT), str(os.path.getsize(FLEET_PROMPT)),
         "75dd26121698f10cf111120f6cbcd2b2125598f1", q, "raw-literal-v1", "-", "note"]) + "\n")
    rc, line = run("round-47-c1.sh", {"C1_TREE": t1})
    after = {p: sha(os.path.join(t1, p)) for p in before}
    out.append("D1 rc=%d\n   %s\n   lessons identical to BASE: %s" % (rc, line, before == after))

    # D2
    t2 = tree(os.path.join(SCR, "d2"))
    c2_material(t2)
    for i in F:
        body = open(os.path.join(t2, ".ufo/waves/round-47/capture", i + ".body")).read()
        assert q not in body
    doctored_normalizer(t2)
    rc, line = run("round-47-c2.sh", {"C2_TREE": t2, "C2_ASOF": str(int(time.time()) + 3600)})
    out.append("D2 rc=%d\n   %s\n   captures containing the S012 quote: 0/11" % (rc, line))

    # D3
    t3 = tree(os.path.join(SCR, "d3"))
    c2_material(t3)
    doctored_normalizer(t3)
    p = os.path.join(t3, "corpus/release-clocks.tsv")
    s = open(p).read()
    s2 = s.replace("S008\tfeed\tS033\thttps://github.com/getsops/sops/releases.atom\t3.13.3\t3.13.3",
                   "S008\tfeed\tS033\thttps://github.com/getsops/sops/releases.atom\t3.13.3\t3.13.2", 1)
    open(p, "w").write(s2)
    open(os.path.join(t3, "corpus/release-clock.py"), "w").write(
        "#!/usr/bin/env python3\nprint('RELEASE_CLOCK: CLEAN (doctored)')\nraise SystemExit(0)\n")
    rc, line = run("round-47-c2.sh", {"C2_TREE": t3, "C2_ASOF": str(int(time.time()) + 3600)})
    out.append("D3 rc=%d (clock row mutated: %s)\n   %s" % (rc, s2 != s, line))

    # D4
    t4 = tree(os.path.join(SCR, "d4"))
    c2_material(t4)
    doctored_normalizer(t4)
    rows = open(os.path.join(t4, "corpus/fired-reverify.tsv")).read().rstrip("\n").split("\n")
    new = [rows[0]]
    for r in rows[1:]:
        c = r.split("\t")
        if c[0] == "S021":
            link = os.path.join(t4, ".ufo/waves/round-47/capture", "S021.body")
            if os.path.exists(link):
                os.remove(link)
            os.symlink(FLEET_PROMPT, link)
            c[5], c[6] = sha(FLEET_PROMPT), str(os.path.getsize(FLEET_PROMPT))
        new.append("\t".join(c))
    open(os.path.join(t4, "corpus/fired-reverify.tsv"), "w").write("\n".join(new) + "\n")
    rc, line = run("round-47-c2.sh", {"C2_TREE": t4, "C2_ASOF": str(int(time.time()) + 3600)})
    out.append("D4 rc=%d (S021 capture is a symlink: %s)\n   %s" % (
        rc, os.path.islink(os.path.join(t4, ".ufo/waves/round-47/capture", "S021.body")), line))

    # D5
    t5 = tree(os.path.join(SCR, "d5"))
    c2_material(t5)
    doctored_normalizer(t5)
    rows = open(os.path.join(t5, "corpus/fired-reverify.tsv")).read().rstrip("\n").split("\n")
    new = [rows[0]]
    for r in rows[1:]:
        c = r.split("\t")
        c[3] = "2029-06-01T00:00:00Z"
        new.append("\t".join(c))
    open(os.path.join(t5, "corpus/fired-reverify.tsv"), "w").write("\n".join(new) + "\n")
    asof = str(calendar.timegm((2030, 1, 1, 0, 0, 0, 0, 0, 0)))
    rc, line = run("round-47-c2.sh", {"C2_TREE": t5, "C2_ASOF": asof})
    out.append("D5 rc=%d (C2_ASOF=%s, fetched_at=2029-06-01T00:00:00Z)\n   %s" % (rc, asof, line))

    print("\n".join(out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
