#!/usr/bin/env python3
# K37MutCounter mutation battery for plans/round-37-c2.sh (round 37, kagi).
# Reads the lane via `git archive`/`git show` only; all writes go under S (scratch)
# and the seat dir W. The frozen control runner plans/round-37-controls.sh is run
# unmodified, with BASE pointing at each mutant's BASE extraction.
import glob
import json
import os
import shutil
import subprocess
import sys

R = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
S = "/fast/scratch/hyaku/kagi-r37/K37MutCounter"
W = os.path.join(R, ".ufo/waves/round-37/build/K37MutCounter")
CAND = "9efcea722bdcf19dbbebf558e0172fafa565ae15"
BASE = "911ab519b6b07694c3cb9f7d9a7c56e142ad957c"
PRED = "04489d4184edb25a01ec8983b3ccedb45c683564"
RECEIPT = ".ufo/waves/round-37/controls/observe-r37.json"
WANT_SHA = "cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203"
COUNTER = "plans/round-37-c2.sh"
RUNNER = "plans/round-37-controls.sh"
MODES = ["nowork", "g1", "g2", "g3", "partial", "full"]
# frozen expectations (plans/round-37.controls.tsv + round-37.md + setup controls)
FROZEN = {"cand": 0, "nowork": 3, "g1": 3, "g2": 3, "g3": 3, "partial": 2, "full": 0}
SETUP_EXPECT = {"setup-missing": (2, ""), "setup-tampered": (2, "")}
EXTRA_BOUNDARY_EXPECT = 3  # non-frozen probe: v2.2.10 row under vault URL must NOT hold 2.2.1

PAT_OLD = r'pat = re.compile(r"(?<![0-9.])(?:v|Python\s)?" + re.escape(v) + r"(?![0-9])")'
PAT_ANY = r'pat = re.compile(r"(?<![0-9.])(?:v|Python\s)?[0-9]+(?:\.[0-9]+)+(?![0-9])")'
PAT_NOBOUND = r'pat = re.compile(r"(?<![0-9.])(?:v|Python\s)?" + re.escape(v))'
KN_ROWS = (
    "import glob as _glob\n"
    "for _kp in sorted(_glob.glob(\"corpus/knowledge/*.md\")):\n"
    "    _kt = open(_kp, encoding=\"utf-8\").read()\n"
    "    rows.append((_kt, _kt))\n"
)
PROBE_ROW = ("| S999 | Vault releases feed — https://github.com/hashicorp/vault/releases.atom | code | A "
             "| Vault release identity | Entry titled v2.2.10, tag link /releases/tag/v2.2.10 "
             "| teaches | mined | 2026-11-05 | 90d | corpus/lessons/round-37.md |\n")


def git_show(commit, path):
    return subprocess.run(["git", "-C", R, "show", f"{commit}:{path}"],
                          capture_output=True, check=True).stdout


def extract(commit, paths, dest):
    os.makedirs(dest, exist_ok=True)
    arc = subprocess.run(["git", "-C", R, "archive", commit, "--", *paths],
                         capture_output=True, check=True).stdout
    subprocess.run(["tar", "-x", "-C", dest], input=arc, check=True)


def sub1(text, old, new):
    n = text.count(old)
    assert n == 1, f"pattern occurs {n} times: {old[:70]!r}"
    return text.replace(old, new)


def run(cmd, cwd, env=None):
    e = dict(os.environ)
    if env:
        e.update(env)
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=300, env=e)
    return {"cmd": " ".join(cmd), "cwd": cwd, "rc": p.returncode,
            "out": p.stdout.strip(), "err": p.stderr.strip()[:300]}


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def main():
    if os.path.isdir(S + "/work"):
        shutil.rmtree(S + "/work")
    os.makedirs(S + "/work", exist_ok=True)
    os.makedirs(W, exist_ok=True)
    frozen = git_show(CAND, COUNTER).decode("utf-8")
    assert frozen == git_show(PRED, COUNTER).decode("utf-8"), "counter differs from predeclaration"
    runner_txt = git_show(CAND, RUNNER).decode("utf-8")
    assert runner_txt == git_show(PRED, RUNNER).decode("utf-8"), "runner differs from predeclaration"
    receipt_bytes = git_show(CAND, RECEIPT)

    # candidate extraction (9efcea7): counter, SOURCES, knowledge, frozen controls, receipt
    cand_src = os.path.join(S, "work/src-cand")
    extract(CAND, ["plans", "corpus/SOURCES.md", "corpus/knowledge", ".ufo/waves/round-37/controls"], cand_src)
    # BASE extraction (911ab51): BASE SOURCES + knowledge; frozen counter, runner, receipt
    # copied in from the predeclared blobs (BASE has no round-37 files)
    base_src = os.path.join(S, "work/src-base")
    extract(BASE, ["plans", "corpus/SOURCES.md", "corpus/knowledge"], base_src)
    write(os.path.join(base_src, COUNTER), frozen)
    write(os.path.join(base_src, RUNNER), runner_txt)
    os.makedirs(os.path.join(base_src, ".ufo/waves/round-37/controls"), exist_ok=True)
    with open(os.path.join(base_src, RECEIPT), "wb") as f:
        f.write(receipt_bytes)
    os.chmod(os.path.join(base_src, COUNTER), 0o755)
    os.chmod(os.path.join(base_src, RUNNER), 0o755)

    import hashlib
    sha = lambda b: hashlib.sha256(b).hexdigest()
    assert sha(receipt_bytes) == WANT_SHA, "receipt sha mismatch at candidate blob"
    assert sha(open(os.path.join(cand_src, RECEIPT), "rb").read()) == WANT_SHA
    assert sha(open(os.path.join(base_src, RECEIPT), "rb").read()) == WANT_SHA

    kn_hits = {}
    for tag, root in (("cand", cand_src), ("base", base_src)):
        hits = []
        for p in sorted(glob.glob(os.path.join(root, "corpus/knowledge/*.md"))):
            t = open(p, encoding="utf-8").read()
            for u in ("hashicorp/vault/releases.atom", "openbao/openbao/releases.atom", "python.org/downloads/feed.rss"):
                if u in t:
                    hits.append((os.path.basename(p), u))
        kn_hits[tag] = hits

    mutants = [
        ("M0", "frozen counter, unmutated (sanity baseline)", lambda t: t),
        ("M1", "drop URL requirement: match version in anchor only",
         lambda t: sub1(t, "if not any((url in src) and pat.search(anc) for src, anc in rows):",
                        "if not any(pat.search(anc) for src, anc in rows):")),
        ("M2", "drop version equality: any dotted version in anchor",
         lambda t: sub1(t, PAT_OLD, PAT_ANY)),
        ("M3", "count corpus/knowledge/*.md documents as registry rows",
         lambda t: sub1(t, "stale = 0\n", KN_ROWS + "stale = 0\n")),
        ("M4", "SETUP missing receipt: print 0, exit 0",
         lambda t: sub1(t, "exit 2; }", "echo 0; exit 0; }")),
        ("M5", "drop (?![0-9]) boundary (2.2.10 satisfies 2.2.1)",
         lambda t: sub1(t, PAT_OLD, PAT_NOBOUND)),
        ("M6", "source column read from index 1 instead of 2",
         lambda t: sub1(t, "rows.append((cells[2], cells[6]))", "rows.append((cells[1], cells[6]))")),
    ]

    evidence = []
    table = []
    for mid, desc, fn in mutants:
        mtext = fn(frozen)
        d = os.path.join(S, "work/mut", mid)
        if os.path.isdir(d):
            shutil.rmtree(d)
        # candidate reading
        cand = os.path.join(d, "cand")
        shutil.copytree(cand_src, cand, symlinks=True)
        write(os.path.join(cand, COUNTER), mtext)
        os.chmod(os.path.join(cand, COUNTER), 0o755)
        r_cand = run(["bash", COUNTER], cwd=cand)
        evidence.append({"mutant": mid, "reading": "cand", **r_cand})

        # BASE tree for the frozen control runner (controls build their own fixtures)
        base = os.path.join(d, "base")
        shutil.copytree(base_src, base, symlinks=True)
        write(os.path.join(base, COUNTER), mtext)
        os.chmod(os.path.join(base, COUNTER), 0o755)
        ctl = {}
        for mode in MODES:
            r = run(["bash", RUNNER, mode], cwd=base,
                    env={"BASE": base, "HYAKU_SCRATCH": os.path.join(S, "work/ctl")})
            ctl[mode] = r
            evidence.append({"mutant": mid, "reading": mode, **r})

        # setup controls (receipt missing / sha-tampered) on the mutant counter
        setups = {}
        sm = os.path.join(d, "setup-missing")
        shutil.copytree(base_src, sm, symlinks=True)
        write(os.path.join(sm, COUNTER), mtext)
        os.remove(os.path.join(sm, RECEIPT))
        setups["setup-missing"] = run(["bash", COUNTER], cwd=sm)
        st = os.path.join(d, "setup-tampered")
        shutil.copytree(base_src, st, symlinks=True)
        write(os.path.join(st, COUNTER), mtext)
        with open(os.path.join(st, RECEIPT), "ab") as f:
            f.write(b"\n")
        setups["setup-tampered"] = run(["bash", COUNTER], cwd=st)
        for k, v in setups.items():
            evidence.append({"mutant": mid, "reading": k, **v})

        # extra, non-frozen boundary probe (reported separately, not in the frozen kill set)
        xb = os.path.join(d, "x-boundary")
        shutil.copytree(base_src, xb, symlinks=True)
        write(os.path.join(xb, COUNTER), mtext)
        with open(os.path.join(xb, "corpus/SOURCES.md"), "a", encoding="utf-8") as f:
            f.write(PROBE_ROW)
        r_x = run(["bash", COUNTER], cwd=xb)
        evidence.append({"mutant": mid, "reading": "x-boundary", **r_x})

        # verdict against frozen values
        diffs = []
        if (r_cand["rc"], r_cand["out"]) != (0, "0"):
            diffs.append(f"cand={r_cand['rc']}/{r_cand['out']!r}")
        for mode in MODES:
            exp = str(FROZEN[mode])
            if (ctl[mode]["rc"], ctl[mode]["out"]) != (0, exp):
                diffs.append(f"{mode}={ctl[mode]['rc']}/{ctl[mode]['out']!r}")
        for k, (erc, eout) in SETUP_EXPECT.items():
            if (setups[k]["rc"], setups[k]["out"]) != (erc, eout):
                diffs.append(f"{k}={setups[k]['rc']}/{setups[k]['out']!r}")
        verdict = "KILLED" if diffs else "SURVIVED"
        xdiff = (r_x["rc"], r_x["out"]) != (0, str(EXTRA_BOUNDARY_EXPECT))
        table.append({
            "id": mid, "change": desc,
            "cand": f"{r_cand['rc']}/{r_cand['out']}",
            "ctl": {m: f"{ctl[m]['rc']}/{ctl[m]['out']}" for m in MODES},
            "setup": {k: f"{setups[k]['rc']}/{setups[k]['out'] or '(none)'}" for k in setups},
            "x_boundary": f"{r_x['rc']}/{r_x['out']}",
            "x_boundary_killed": xdiff,
            "verdict": verdict, "diffs": diffs,
        })
        # the mutant's own tree stays in scratch; removed at exit

    write(os.path.join(W, "evidence-K37MutCounter.jsonl"),
          "".join(json.dumps(e) + "\n" for e in evidence))
    shutil.copy(os.path.abspath(__file__), os.path.join(W, "harness-K37MutCounter.py"))
    write(os.path.join(W, "table-K37MutCounter.json"), json.dumps(table, indent=1) + "\n")
    print("PRECHECK knowledge feed-URL hits:", json.dumps(kn_hits))
    print("PRECHECK receipt sha (cand, base): OK", WANT_SHA)
    for t in table:
        print(t["id"], t["verdict"], "| cand", t["cand"], "| ctl", t["ctl"], "| setup", t["setup"],
              "| x-boundary", t["x_boundary"], "| diffs", t["diffs"])
    killed = sum(1 for t in table if t["verdict"] == "KILLED" and t["id"] != "M0")
    survived = sum(1 for t in table if t["verdict"] == "SURVIVED" and t["id"] != "M0")
    m0 = [t for t in table if t["id"] == "M0"][0]
    print("SANITY M0 verdict:", m0["verdict"], m0["diffs"])
    print(f"MUTATION: DONE killed={killed} survived={survived}")


if __name__ == "__main__":
    sys.exit(main())
