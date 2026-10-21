#!/usr/bin/env python3
"""Literal reading of the XConformance assignment (build-spec.json "XConformance"),
used only to test whether that specification can pass while the defect recurs.

checks: (1) plan's FIRST commit touches no path outside plans/ and the census-start file;
(2) census-start exists and was committed no later than the plan;
(3) counting-command lines (indented code lines) in the frozen part (before
`## Plan corrections`) are byte-identical at the plan's first commit and at the tip.
"""
import subprocess, sys


def git(repo, *a, ok=False):
    p = subprocess.run(["git", "-C", repo, *a], capture_output=True, text=True)
    if p.returncode and not ok:
        raise SystemExit(f"git {' '.join(a)} failed: {p.stderr.strip()}")
    return p.stdout if not ok else (p.returncode, p.stdout)


def frozen_cmds(text):
    out = []
    for line in text.splitlines():
        if line.startswith("## Plan corrections"):
            break
        if line.startswith("    ") and line.strip():
            out.append(line)
    return out


def main(repo, n, tip="HEAD"):
    plan, census = f"plans/round-{n}.md", f".ufo/waves/round-{n}/census-start.txt"
    fails = []
    adds = git(repo, "log", "--diff-filter=A", "--format=%H", tip, "--", plan).split()
    if not adds:
        print(f"SPEC FAIL plan-missing {plan}"); return 1
    first = adds[-1]
    names = [x for x in git(repo, "show", "--name-only", "--format=", first).splitlines() if x]
    bad = [x for x in names if not (x.startswith("plans/") or x == census)]
    if bad:
        fails.append(f"SPEC FAIL first-commit-impure {first[:7]} outside={len(bad)} e.g. {bad[:3]}")
    cadds = git(repo, "log", "--diff-filter=A", "--format=%H", tip, "--", census).split()
    if not cadds:
        fails.append("SPEC FAIL census-start-missing")
    else:
        rc, _ = git(repo, "merge-base", "--is-ancestor", cadds[-1], first, ok=True)
        if rc:
            fails.append(f"SPEC FAIL census-after-plan {cadds[-1][:7]}")
    a = frozen_cmds(git(repo, "show", f"{first}:{plan}"))
    b = frozen_cmds(git(repo, "show", f"{tip}:{plan}"))
    if a != b:
        fails.append(f"SPEC FAIL frozen-lines-changed first={len(a)} tip={len(b)}")
    for f in fails:
        print(f)
    print(f"SPEC_CONFORMANCE: {'FAIL' if fails else 'PASS'} (round={n} first={first[:7]} frozen_cmd_lines={len(a)})")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
