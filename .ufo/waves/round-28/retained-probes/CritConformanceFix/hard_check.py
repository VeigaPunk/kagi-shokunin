#!/usr/bin/env python3
"""Hardened round-conformance draft (critic sandbox; advice only, not a lane tool).

usage: hard_check.py <repo> <round> [lane] [tip] [manifest.json]
Read-only git. Exit 0 PASS, 1 FAIL, 2 setup. Each typed line names one defect.
"""
import datetime, hashlib, json, re, subprocess, sys
from pathlib import Path


def git(repo, *a, ok=False):
    p = subprocess.run(["git", "-C", repo, *a], capture_output=True)
    if ok:
        return p.returncode, p.stdout.decode()
    if p.returncode:
        raise SystemExit(2)
    return p.stdout.decode()


def blob(repo, rev, path):
    rc, out = git(repo, "show", f"{rev}:{path}", ok=True)
    return out if rc == 0 else None


def touched(repo, c):
    """Exact path set of a non-merge commit vs its parent; renames split, no combined diff."""
    out = git(repo, "diff-tree", "--no-renames", "--no-commit-id", "-r", "--name-status", "--root", c)
    return {tuple(l.split("\t", 1)) for l in out.splitlines() if l}


def parents(repo, c):
    return git(repo, "rev-list", "--parents", "-n1", c).split()[1:]


def cdate(repo, c):
    return datetime.datetime.fromisoformat(git(repo, "log", "-1", "--format=%cI", c).strip())


def frozen(text):
    i = text.find("\n## Plan corrections")
    return text if i < 0 else text[: i + 1]


def main(repo, n, lane=None, tip="HEAD", manifest=None):
    lane = lane or Path(repo).resolve().name.removesuffix("-shokunin")
    plan, census = f"plans/round-{n}.md", f".ufo/waves/round-{n}/census-start.txt"
    out = []
    F = lambda t, d: out.append(f"CONFORMANCE {t} round={n} {d}")
    tip = git(repo, "rev-parse", tip).strip()
    ev = git(repo, "log", "--no-renames", "--format=%H %s", "--name-status", "--reverse", tip, "--", plan)
    events = re.findall(r"^([ADM])\t" + re.escape(plan) + "$", ev, re.M)
    adds = list(dict.fromkeys(git(repo, "log", "-m", "--no-renames", "--diff-filter=A", "--format=%H", tip, "--", plan).split()))
    if not adds:
        F("PLAN-MISSING", plan); return finish(out, n)
    if len(adds) != 1 or "D" in events:
        F("PLAN-READDED", f"adds={len(adds)} deletes={events.count('D')}")
    P = adds[-1]
    ptext = blob(repo, P, plan)
    # H1 first-commit purity: single parent, exact path set {A plan, A census}
    ps = parents(repo, P)
    if len(ps) != 1:
        F("PLAN-FIRST-MERGE", f"{P[:7]} parents={len(ps)}")
    else:
        t = touched(repo, P)
        want = {("A", plan), ("A", census)}
        if t != want:
            extra = sorted(p for s, p in t - want)
            F("PLAN-FIRST-IMPURE", f"{P[:7]} extra={len(extra)} e.g. {extra[:3]} missing={sorted(p for s, p in want - t)}")
    # H2 BASE binding: P^ == declared BASE == MANIFEST previous admitted commit; BASE has no round-N paths
    m = re.search(r"Frozen BASE: `([0-9a-f]{40})`", ptext)
    base = m.group(1) if m else None
    if not base:
        F("PLAN-NO-BASE", "no `Frozen BASE: <40-hex>` line")
    elif ps and ps[0] != base:
        F("PLAN-NOT-ON-BASE", f"parent={ps[0][:7]} declared={base[:7]} between={git(repo,'rev-list','--count',f'{base}..{ps[0]}').strip() if git(repo,'merge-base','--is-ancestor',base,ps[0],ok=True)[0]==0 else '?'}")
    if base:
        pre = git(repo, "ls-tree", "-r", "--name-only", base, "--", plan, f".ufo/waves/round-{n}/").split()
        if pre:
            F("BASE-HAS-ROUND-PATHS", f"{len(pre)} e.g. {pre[:2]}")
        if manifest:
            ms = [r for r in json.load(open(manifest)).get("rounds", []) if r.get("lane") == lane and r.get("admitted") and r.get("lane_round") == int(n) - 1]
            if not ms or ms[-1].get("commit", "").split("@")[-1] != base:
                F("BASE-NOT-ADMITTED", f"declared={base[:7]} manifest={[r.get('commit') for r in ms]}")
    # H3 structure: frozen part has claim headings, each with an indented counting command
    fz = frozen(ptext)
    claims = re.split(r"^## (C\d+)\b", fz, flags=re.M)
    heads = claims[1::2]
    if not heads:
        F("PLAN-NO-CLAIMS", f"frozen_bytes={len(fz.encode())}")
    for h, body in zip(heads, claims[2::2]):
        sect = body.split("\n## ", 1)[0]
        if not re.search(r"^    \S.*$", sect, re.M):
            F("CLAIM-NO-COUNTING-COMMAND", h)
    # H4 append-only at every plan-touching commit and in the worktree
    for c in git(repo, "log", "--no-renames", "--format=%H", f"{P}..{tip}", "--", plan).split():
        b = blob(repo, c, plan) or ""
        if not b.startswith(ptext):
            F("FROZEN-REWRITTEN", f"{c[:7]}")
    wt = Path(repo, plan)
    if wt.exists() and wt.read_text() != (blob(repo, tip, plan) or ""):
        F("PLAN-WORKTREE-DIRTY", plan)
    # H8 every round commit descends from the plan commit (no work merged in from a parallel line)
    after = set(git(repo, "rev-list", f"{P}..{tip}").split())
    desc = set(git(repo, "rev-list", "--ancestry-path", f"{P}..{tip}").split())
    off = sorted(after - desc)
    if off:
        F("WORK-OFF-PLAN", f"{len(off)} commits not descended from {P[:7]} e.g. {off[0][:7]}")
    # H5 amendments only before any work: plan-touching commits after P touch only the plan,
    # and every commit between P and them touches only the plan.
    seen_work = None
    for c in git(repo, "rev-list", "--reverse", "--topo-order", f"{P}..{tip}").split():
        if len(parents(repo, c)) != 1:
            seen_work = seen_work or c; continue
        paths = {p for s, p in touched(repo, c)}
        if plan in paths:
            if paths != {plan}:
                F("PLAN-AMENDED-WITH-WORK", f"{c[:7]} paths={len(paths)}")
            elif seen_work:
                F("PLAN-AMENDED-AFTER-WORK", f"{c[:7]} after {seen_work[:7]}")
        if paths != {plan}:
            seen_work = seen_work or c
    # H6 census-start: committed only in P, immutable, well-formed, timestamp in [BASE, P]
    cc = git(repo, "log", "--no-renames", "--format=%H", tip, "--", census).split()
    if cc != [P]:
        F("CENSUS-START-NOT-WITH-PLAN" if not cc or cc[-1] != P else "CENSUS-START-REWRITTEN", f"commits={[x[:7] for x in cc]}")
    ctext = blob(repo, P, census) or blob(repo, tip, census)
    if ctext is None:
        F("CENSUS-START-MISSING", census)
    else:
        lines = [l for l in ctext.splitlines() if l.strip()]
        try:
            ts = datetime.datetime.fromisoformat(lines[0])
        except (ValueError, IndexError):
            ts = None; F("CENSUS-START-NO-TIMESTAMP", repr(lines[:1]))
        if ts and base and not (cdate(repo, base) <= ts <= cdate(repo, P)):
            F("CENSUS-START-OUT-OF-WINDOW", f"ts={ts.isoformat()} base={cdate(repo, base).isoformat()} plan={cdate(repo, P).isoformat()}")
        exitl = lines[-1] if lines else ""
        allowed = {"exit=0"} | ({"exit=2"} if base and blob(repo, base, "corpus/SOURCES.md") is None else set())
        if exitl not in allowed:
            F("CENSUS-START-EXIT", repr(exitl))
        body = lines[1:-1]
        if not any(re.fullmatch(rf"{re.escape(lane)}\tok\t\S*corpus/SOURCES\.md", l) for l in body):
            F("CENSUS-START-NOT-LANE-REGISTRY", f"lines={len(body)}")
        sha = [l.split("=", 1)[1] for l in body if l.startswith("source_registry_sha256=")]
        body = [l for l in body if not l.startswith("source_registry_sha256=")]
        if sha and base:
            src = subprocess.run(["git", "-C", repo, "show", f"{base}:corpus/SOURCES.md"], capture_output=True).stdout
            if sha[0] != hashlib.sha256(src).hexdigest():
                F("CENSUS-START-NOT-BASE-REGISTRY", f"sha={sha[0][:12]}")
        elif int(n) >= int(SHA_REQUIRED_FROM):
            F("CENSUS-START-UNBOUND", "no source_registry_sha256= line")
        bad = [l for l in body if not re.match(rf"{re.escape(lane)}\t(ok|[A-Z]\d\d)\t", l)]
        if bad:
            F("CENSUS-START-FOREIGN-LINES", f"{len(bad)} e.g. {bad[:1]}")
    # H7 measurement tools named by frozen counting commands are written once
    for tool in sorted(set(re.findall(rf"(\.ufo/waves/round-{n}/tools/\S+)", fz))):
        tc = git(repo, "log", "--no-renames", "--format=%H", tip, "--", tool).split()
        if len(tc) > 1:
            F("TOOL-REWRITTEN", f"{tool} commits={len(tc)}")
    return finish(out, n, P, tip)


SHA_REQUIRED_FROM = __import__("os").environ.get("SHA_REQUIRED_FROM", "29")


def finish(out, n, P="", tip=""):
    for l in out:
        print(l)
    print(f"ROUND_CONFORMANCE: {'FAIL' if out else 'PASS'} (round={n} plan_first={P[:7]} tip={tip[:7]} defects={len(out)})")
    return 1 if out else 0


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__); sys.exit(2)
    sys.exit(main(*sys.argv[1:]))
