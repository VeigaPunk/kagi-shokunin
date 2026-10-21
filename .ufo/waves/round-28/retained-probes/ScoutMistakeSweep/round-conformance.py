#!/usr/bin/env python3
"""Falsifiable round-conformance probe (mistake-sweep draft, not a lane gate).

Checks, per round N, against read-only git history:
  PLAN_FIRST     the commit that first adds plans/round-N.md touches no
                 production path (corpus/, LOG.md, SCORECARD.md, SKILL.md,
                 PROVINCE.md, README.md).
  APPEND_ONLY    later commits to the plan remove no line (append-only).
  CENSUS_START   a .ufo/waves/round-N/census-start.* receipt exists.
  CENSUS_RECEIPT that receipt carries a timestamp and a 40-hex revision.

Exit 0 = every check PASS on every round; 1 = at least one FAIL.
Prints one PASS/FAIL line per check so each can be shown to fail.
"""
import re
import subprocess
import sys

REPO = sys.argv[1]
REV_OF = {n: (sys.argv[2] if n == 28 else sys.argv[3]) for n in range(22, 29)}
PROD = ("corpus/", "LOG.md", "SCORECARD.md", "SKILL.md", "PROVINCE.md", "README.md")
TS = re.compile(r"\b20\d\d-\d\d-\d\dT\d\d:\d\d")
SHA = re.compile(r"\b[0-9a-f]{40}\b")


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True)


def plan_commits(n):
    out = git("log", "--diff-filter=A", "--format=%H", "--", f"plans/round-{n}.md").stdout.split()
    return out[-1] if out else None


def show_files(sha):
    return [p for p in git("show", "--name-only", "--format=", sha).stdout.split() if p]


def check(n):
    results = []
    add = plan_commits(n)
    if add is None:
        return [(n, "PLAN_FIRST", "FAIL", "no plan commit")], add
    touching = [p for p in show_files(add) if p.startswith(PROD)]
    results.append((n, "PLAN_FIRST", "FAIL" if touching else "PASS",
                    f"{add[:8]} prod_files={len(touching)} first={touching[:3]}"))
    diff = git("diff", add, REV_OF[n], "--", f"plans/round-{n}.md").stdout.splitlines()
    removed = [l for l in diff if l.startswith("-") and not l.startswith("---")]
    results.append((n, "APPEND_ONLY", "FAIL" if removed else "PASS",
                    f"removed_lines={len(removed)}"))
    tree = git("ls-tree", "-r", "--name-only", REV_OF[n], "--", f".ufo/waves/round-{n}/").stdout.split()
    prefix = f".ufo/waves/round-{n}/census-start"
    census = [p for p in tree if p.startswith(prefix) and p.count("/") == prefix.count("/")]
    results.append((n, "CENSUS_START", "PASS" if census else "FAIL", f"files={census}"))
    if census:
        body = git("show", f"{REV_OF[n]}:{census[0]}").stdout
        has_ts, has_sha = bool(TS.search(body)), bool(SHA.search(body))
        results.append((n, "CENSUS_RECEIPT", "PASS" if has_ts and has_sha else "FAIL",
                        f"timestamp={has_ts} revision={has_sha}"))
        plan = git("show", f"{add}:plans/round-{n}.md").stdout.splitlines()[:6]
        base = next(iter(SHA.findall("\n".join(plan))), None)
        sha = next(iter(SHA.findall(body)), None)
        results.append((n, "CENSUS_REVISION", "PASS" if base and sha == base else "FAIL",
                        f"declared={base} receipt={sha}"))
        ts = TS.search(body)
        commit_ts = git("show", "-s", "--format=%cI", add).stdout.strip()
        ok = bool(ts) and ts.group(0) <= commit_ts[:16]
        results.append((n, "CENSUS_TIMING", "PASS" if ok else "FAIL",
                        f"census={ts.group(0) if ts else None} plan_commit={commit_ts}"))
    else:
        for name in ("CENSUS_RECEIPT", "CENSUS_REVISION", "CENSUS_TIMING"):
            results.append((n, name, "FAIL", "no receipt"))
    return results, add


def main():
    bad = 0
    for n in range(22, 29):
        rows, add = check(n)
        for row in rows:
            rnd, name, verdict, detail = row
            print(f"R{rnd} {name:14s} {verdict} {detail}")
            bad += verdict == "FAIL"
    print(f"ROUND_CONFORMANCE: {'CLEAN' if bad == 0 else f'FAIL ({bad} failing checks)'}")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
