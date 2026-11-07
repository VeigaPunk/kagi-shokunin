#!/usr/bin/env python3
"""Mutation harness for the round-58 C1 checker.

Usage:
  python3 mutate.py prep  <pristine-tree> <dest-base>
  python3 mutate.py apply <tree> <mutation-id>
  python3 mutate.py run   <checker> <tree> [--wrapper <sh>]

Every mutation edits only its named file(s) and asserts the old text exists.
"""
import os
import shutil
import subprocess
import sys

R57 = "controls-prefreeze-epochC-final.txt"
R57DIR = ".ufo/waves/round-57/controls"


def rep(tree, rel, old, new, count=1):
    p = os.path.join(tree, rel)
    s = open(p, encoding="utf-8").read()
    n = s.count(old)
    if n != count:
        raise SystemExit(f"MUTATION-SETUP {rel}: expected {count} occurrence(s), found {n}: {old[:70]!r}")
    open(p, "w", encoding="utf-8").write(s.replace(old, new))


def m_i1(tree):
    # LOG round-57 block: point at a plausible sibling receipt that is not an epoch-C receipt.
    d = os.path.dirname(os.path.join(tree, "LOG.md"))
    lg = os.path.join(d, "LOG.md")
    s = open(lg, encoding="utf-8").read()
    old = f"{R57DIR}/controls-prefreeze-epochC.txt"
    if old not in s:
        old = f"{R57DIR}/controls-prefreeze-epochC-final.txt"
    cand = f"{R57DIR}/controls-prefreeze.txt"
    assert old in s, "i1 anchor missing"
    open(lg, "w", encoding="utf-8").write(s.replace(old, cand, 1))


def m_i2(tree):
    rep(tree, f"{R57DIR}/{R57}",
        "INSTRUMENT 76e836ee111d60b7cf60007da4b45a102f1d94393f1d83c9de1a32d7cd33b173 plans/round-57.md",
        "INSTRUMENT 76e836ee111d60b7cf60007da4b45a102f1d94393f1d83c9de1a32d7cd33b174 plans/round-57.md")


def m_i3(tree):
    rep(tree, "corpus/lessons/round-57.md",
        "data with the specified audit device's hash function and salt.",
        "data with the specified audit backend's hash function and salt.")


def m_i4(tree):
    rep(tree, "corpus/lessons/round-57.md",
        "Registry 114 → 117 (S115, S116, S117;", "Registry 114 → 116 (S115, S116, S117;")


def m_i5(tree):
    rep(tree, "SKILL.md",
        "`python3 -I -B corpus/current-claims.py --selftest` prints `CURRENT_CLAIMS_SELFTEST: PASS (N cases)`",
        "none of its own")


def m_i6(tree):
    p = os.path.join(tree, "corpus/current-claims.py")
    s = open(p, encoding="utf-8").read()
    # Find the derived lesson surface read inside measure().
    for old in ('os.path.join("corpus", "lessons", f"round-{n}.md")',
                'f"corpus/lessons/round-{n}.md"',
                'os.path.join("corpus", "lessons", f"round-{round_n}.md")',
                'f"corpus/lessons/round-{round_n}.md"'):
        if old in s:
            new = old.replace("round-", "round-56-", 0)  # placeholder, replaced below
            new = 'os.path.join("corpus", "lessons", "round-56.md")' if "os.path.join" in old else '"corpus/lessons/round-56.md"'
            s = s.replace(old, new, 1)
            open(p, "w", encoding="utf-8").write(s)
            return
    raise SystemExit("MUTATION-SETUP i6: no derived lesson path found")


def m_i7(tree):
    rep(tree, "corpus/lessons/round-57.md",
        "§Enabling/Disabling audit devices", "§Enabling and disabling audit devices")


def m_i8(tree):
    p = os.path.join(tree, "corpus/adjacency.tsv")
    s = open(p, encoding="utf-8").read()
    lines = s.splitlines(True)
    hit = 0
    for i, ln in enumerate(lines):
        if ln.startswith("$HOME/.config/opencode\t") and "\topencode\t" in ln:
            cells = ln.rstrip("\n").split("\t")
            cells[4] = "SCORECARD.md:54"  # stale pointer (line carries no opencode token)
            lines[i] = "\t".join(cells) + "\n"
            hit += 1
    if hit != 1:
        raise SystemExit(f"MUTATION-SETUP i8: opcode row hits={hit}")
    open(p, "w", encoding="utf-8").write("".join(lines))


def m_ga(tree):
    os.remove(os.path.join(tree, "corpus/lessons/round-57.md"))


MUTATIONS = {"i1": m_i1, "i2": m_i2, "i3": m_i3, "i4": m_i4, "i5": m_i5,
             "i6": m_i6, "i7": m_i7, "i8": m_i8, "ga": m_ga}


def copytree(src, dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    subprocess.run(["rsync", "-a", "--exclude=.git", src + "/", dst + "/"], check=True)


def main() -> int:
    cmd = sys.argv[1]
    if cmd == "prep":
        copytree(sys.argv[2], sys.argv[3])
        return 0
    if cmd == "apply":
        tree, mid = sys.argv[2], sys.argv[3]
        MUTATIONS[mid](tree)
        return 0
    raise SystemExit("usage: prep|apply")


if __name__ == "__main__":
    raise SystemExit(main())
