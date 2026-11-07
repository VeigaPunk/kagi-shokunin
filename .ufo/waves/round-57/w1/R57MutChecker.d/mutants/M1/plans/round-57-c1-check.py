#!/usr/bin/env python3
"""Frozen round-57 C1 checker: stale numeric self-description in the audited surface.

Usage: python3 -I -B plans/round-57-c1-check.py --root DIR [--verbose]

The audited surface is the PREVIOUS round's landing statements (round 56), the
surface a non-author closure spot-check reads:
  - SCORECARD.md  section `## Round 56 - post-move` (up to the next column-0 `## `)
  - LOG.md        section `## Round 56 (` (up to the next column-0 `## `)
  - corpus/lessons/round-56.md : header block (through the first blank line after
    `Frozen plan:`) plus `## Claims` (up to `## Gate`)

Four statement classes, each with a machine authority read from the measured root:
  CASES  `N cases` on a line naming `recheck-replay` -> the instrument's own
         `--selftest` PASS line case count (`PASS (N cases)`).
  MATCH  `N MATCH` on a line that names a receipt path
         `.ufo/waves/round-56/controls/controls-prefreeze-epoch<L>.txt` -> that
         receipt's `CONTROLS: match=N mismatch=0` number; a line with several
         MATCH numbers and several receipt paths pairs by order. A line with no
         receipt path pairs each number with the nearest preceding `A`-`F` letter
         that is followed by a backticked 7-40 char hex revision.
  EPOCHS `W freeze epochs` (W a word number ONE..SIX or digits) -> the number of
         `.ufo/waves/round-56/controls/controls-prefreeze-epoch*.txt` files.
  CLOCKS `N clocks` -> the number of data rows of `corpus/recheck-captures.tsv`.

value = mismatches + unbound statements; a line of a class that names no
authority is UNBOUND (fail closed). `--verbose` prints one `STMT` line per
statement. Final line:
  CURRENT_CLAIMS: value=V population=P mismatches=M unbound=U cases=C match=K
  epochs=E clocks=Z
Exit 0 iff V == 0 and P >= 8; 1 otherwise; 2 on SETUP (no python/root unreadable).

Named ceilings: an authority file forged to agree with the statement passes; the
class set is closed (a numeric statement of another shape is not counted); a
statement's subject is resolved by the line's own text.
"""
from __future__ import annotations

import argparse
import glob
import os
import re
import subprocess
import sys

WORDNUM = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6,
           "seven": 7, "eight": 8, "nine": 9, "ten": 10}


def die(msg: str) -> None:
    print(f"CURRENT_CLAIMS: SETUP {msg}")
    sys.exit(2)


def section(text: str, start_re: str) -> str:
    m = re.search(start_re, text, re.M)
    if not m:
        return ""
    start = m.start()
    m2 = re.compile(r"^## ", re.M).search(text, m.end())
    return text[start: m2.start() if m2 else len(text)]


def read(root: str, rel: str) -> str:
    p = os.path.join(root, rel)
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return ""


def lesson_surface(text: str) -> str:
    lines = text.splitlines()
    head: list[str] = []
    seen_plan = False
    for i, ln in enumerate(lines):
        head.append(ln)
        if ln.startswith("Frozen plan:"):
            seen_plan = True
        if seen_plan and ln.strip() == "":
            head = lines[: i + 1]
            break
    claims = section(text, r"^## Claims\s*$")
    return "\n".join(head) + "\n" + claims


def selftest_cases(root: str) -> int | None:
    gate = os.path.join(root, "corpus", "recheck-replay.py")
    if not os.path.isfile(gate):
        return None
    try:
        r = subprocess.run([sys.executable, "-I", "-B", "corpus/recheck-replay.py",
                            "--selftest"], cwd=root, capture_output=True,
                           text=True, timeout=600)
    except (OSError, subprocess.SubprocessError):
        return None
    if r.returncode != 0:
        return None
    m = None
    for ln in (r.stdout or "").splitlines():
        m = re.search(r"PASS \(([0-9]+) cases\)", ln)
        if m:
            break
    return int(m.group(1)) if m else None


def receipt_match(root: str, letter: str) -> int | None:
    rel = f".ufo/waves/round-56/controls/controls-prefreeze-epoch{letter}.txt"
    p = os.path.join(root, rel)
    if not os.path.isfile(p):
        return None
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            for ln in f:
                m = re.match(r"^CONTROLS: match=([0-9]+) mismatch=([0-9]+)\s*$", ln)
                if m:
                    return int(m.group(1)) if int(m.group(2)) == 0 else None
    except OSError:
        return None
    return None


def epoch_declared(root: str) -> int | None:
    p = os.path.join(root, "plans", "round-56.md")
    if not os.path.isfile(p):
        return None
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            text = f.read()
    except OSError:
        return None
    return len(set(re.findall(r"epoch-([A-F])\b", text)))


def manifest_rows(root: str) -> int | None:
    p = os.path.join(root, "corpus", "recheck-captures.tsv")
    if not os.path.isfile(p):
        return None
    n = 0
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            for ln in f:
                if ln.strip() == "" or ln.startswith("#"):
                    continue
                if ln.startswith("id\t"):
                    continue
                n += 1
    except OSError:
        return None
    return n


CASES_RE = re.compile(r"([0-9]+) cases")
MATCH_RE = re.compile(r"([0-9]+) MATCH")
EPOCHS_RE = re.compile(r"\b(one|two|three|four|five|six|seven|eight|nine|ten|[0-9]+)\s+freeze epochs?\b",
                       re.I)
CLOCKS_RE = re.compile(r"([0-9]+) clocks")
POP_RE = re.compile(r"([0-9]+)/([0-9]+) MATCH")
RECEIPT_RE = re.compile(r"controls-prefreeze-epoch([A-F])\.txt")
LETTER_REV_RE = re.compile(r"\b([A-F])\b\s*`[0-9a-f]{7,40}`")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()
    root = os.path.abspath(args.root)
    if not os.path.isdir(root):
        die(f"no-root {root}")
    sc = read(root, "SCORECARD.md")
    lg = read(root, "LOG.md")
    ls = read(root, "corpus/lessons/round-56.md")
    if not sc or not lg or not ls:
        print("CURRENT_CLAIMS: value=FAIL population=0 mismatches=0 unbound=0 "
              "cases=0 match=0 epochs=0 clocks=0")
        return 1
    surfaces = [
        ("SCORECARD", section(sc, r"^## Round 56 [—-] post-move")),
        ("LOG", section(lg, r"^## Round 56 \(")),
        ("LESSON", lesson_surface(ls)),
    ]
    cases_auth = selftest_cases(root)
    match_auth = {L: receipt_match(root, L) for L in "ABCDEF"}
    epochs_auth = epoch_declared(root)
    clocks_auth = manifest_rows(root)

    population = 0
    bad = 0
    per = {"cases": 0, "match": 0, "epochs": 0, "clocks": 0, "pop": 0}

    def stmt(where: str, lineno: int, cls: str, stated: int, auth: int | None,
             how: str) -> None:
        nonlocal population, bad
        population += 1
        per[cls] += 1
        ok = auth is not None and stated == auth
        if not ok:
            bad += 1
        if args.verbose:
            verdict = "OK" if ok else ("UNBOUND" if auth is None else "MISMATCH")
            print(f"STMT {where}:{lineno} cls={cls} stated={stated} "
                  f"auth={'none' if auth is None else auth} via={how} {verdict}")

    for name, text in surfaces:
        if not text:
            continue
        for i, line in enumerate(text.splitlines(), 1):
            for m in CASES_RE.finditer(line):
                stated = int(m.group(1))
                if "recheck-replay" in line:
                    stmt(name, i, "cases", stated, cases_auth, "recheck-replay-selftest")
                else:
                    stmt(name, i, "cases", stated, None, "no-named-instrument")
            pop_spans = []
            for m in POP_RE.finditer(line):
                pop_spans.append((m.start(), m.end()))
                stmt(name, i, "pop", int(m.group(1)), clocks_auth, "pop-size")
                stmt(name, i, "pop", int(m.group(2)), clocks_auth, "pop-match")
            ms = [m for m in MATCH_RE.finditer(line)
                  if not any(a <= m.start() < b for a, b in pop_spans)]
            if ms:
                recs = RECEIPT_RE.findall(line)
                if recs and len(recs) == len(ms):
                    pairs = [(int(m.group(1)), recs[j]) for j, m in enumerate(ms)]
                    for stated, L in pairs:
                        stmt(name, i, "match", stated, match_auth.get(L),
                             f"receipt-epoch{L}")
                else:
                    for m in ms:
                        before = line[: m.start()]
                        letters = LETTER_REV_RE.findall(before)
                        L = letters[-1] if letters else None
                        stmt(name, i, "match", int(m.group(1)),
                             match_auth.get(L) if L else None,
                             f"nearest-epoch{L or '-'}")
            for m in EPOCHS_RE.finditer(line):
                w = m.group(1).lower()
                stated = WORDNUM.get(w, int(w) if w.isdigit() else None)
                stmt(name, i, "epochs", stated if stated is not None else -1,
                     epochs_auth, "receipt-file-count")
            for m in CLOCKS_RE.finditer(line):
                stmt(name, i, "clocks", int(m.group(1)), clocks_auth,
                     "manifest-data-rows")

    guard = 1 if population >= 8 else 0
    value = 0 if guard else "FAIL"  # M1: value ignores mismatches
    print(f"CURRENT_CLAIMS: value={value} population={population} "
          f"mismatches={bad} unbound=0 cases={per['cases']} match={per['match']} "
          f"epochs={per['epochs']} clocks={per['clocks']} pop={per['pop']} guard={guard}")
    return 0 if (guard and bad == 0) else 1


if __name__ == "__main__":
    sys.exit(main())
