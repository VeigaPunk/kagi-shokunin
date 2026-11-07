#!/usr/bin/env python3
"""Round-57 C1 forgery harness (review seat R57ReviewC1).

Builds each forgery tree in scratch from the BASE archive, applies the named
edits (asserting every anchor occurs), then scores it with the FROZEN driver
(plans/round-57-c1.sh --tree) and the FROZEN checker (--verbose).
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
S = "/fast/scratch/hyaku/kagi-r57/R57ReviewC1"
BASE = f"{S}/base"
OUT = f"{S}/forges"
DRIVER = f"{LANE}/plans/round-57-c1.sh"
CHECK = f"{LANE}/plans/round-57-c1-check.py"

RESULTS = []


def sha(path):
    if not os.path.exists(path):
        return "absent"
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def rd(tree, rel):
    with open(os.path.join(tree, rel), encoding="utf-8") as f:
        return f.read()


def wr(tree, rel, text):
    with open(os.path.join(tree, rel), "w", encoding="utf-8") as f:
        f.write(text)


def sub(tree, rel, old, new, count=None):
    text = rd(tree, rel)
    n = text.count(old)
    if count is not None:
        assert n == count, f"{rel}: {old!r} occurs {n} != {count}"
    else:
        assert n >= 1, f"{rel}: anchor missing {old!r}"
    wr(tree, rel, text.replace(old, new))
    return n


def build(name, ops, note):
    dst = f"{OUT}/{name}"
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(BASE, dst, symlinks=True)
    before = {}
    for op in ops:
        op(dst)
    rels = sorted({rel for op in ops for rel in getattr(op, "rels", [])})
    for rel in rels:
        before[rel] = {"base": sha(os.path.join(BASE, rel)),
                       "forged": sha(os.path.join(dst, rel))}
    return dst, before


def score(name, dst, note, changed):
    drv = subprocess.run(["bash", DRIVER, "--tree", dst],
                         capture_output=True, text=True, timeout=900)
    ver = subprocess.run([sys.executable, "-I", "-B", CHECK, "--root", dst,
                          "--verbose"], capture_output=True, text=True, timeout=900)
    os.makedirs(f"{OUT}/logs", exist_ok=True)
    with open(f"{OUT}/logs/{name}.driver.txt", "w", encoding="utf-8") as f:
        f.write(f"$ bash plans/round-57-c1.sh --tree {dst}\n{drv.stdout}{drv.stderr}\nrc={drv.returncode}\n")
    with open(f"{OUT}/logs/{name}.verbose.txt", "w", encoding="utf-8") as f:
        f.write(ver.stdout + ver.stderr)
    last = (drv.stdout.strip().splitlines() or [""])[-1]
    stmts = [ln for ln in ver.stdout.splitlines() if ln.startswith("STMT ")]
    summary = [ln for ln in ver.stdout.splitlines() if ln.startswith("CURRENT_CLAIMS:")]
    rec = {"name": name, "note": note, "driver_rc": drv.returncode,
           "driver_last": last, "checker_summary": summary[-1] if summary else "",
           "statements": stmts, "changed": changed}
    m = re.search(r"value=(\S+) population=(\d+) gate=(\d+) guard=(\d+)", last)
    if m:
        rec["admitted"] = (m.group(1) == "0" and int(m.group(2)) >= 8
                           and m.group(4) == "1")
        rec["value"], rec["population"], rec["gate"], rec["guard"] = (
            m.group(1), int(m.group(2)), m.group(3), m.group(4))
    else:
        rec["admitted"] = None
    RESULTS.append(rec)
    print(f"{name}: {last} | admitted={rec['admitted']} drv_rc={drv.returncode}")
    return rec


def tag(fn, rels):
    fn.rels = rels
    return fn


def main():
    os.makedirs(OUT, exist_ok=True)

    # ---- A. answer-key: rewrite ONLY the authority sources -------------
    def a(d):
        wr(d, "corpus/recheck-replay.py",
           "#!/usr/bin/env python3\nimport sys\nprint('PASS (18 cases)')\nsys.exit(0)\n")
        # fold E and F into D -> 4 distinct declared epochs (LOG 'four' passes)
        p = "plans/round-56.md"
        t = rd(d, p)
        n1 = t.count("epoch-E"); n2 = t.count("epoch-F")
        assert n1 and n2, (n1, n2)
        wr(d, p, t.replace("epoch-E", "epoch-D").replace("epoch-F", "epoch-D"))
    tag(a, ["corpus/recheck-replay.py", "plans/round-56.md"])
    dst, ch = build("A-authority-4epochs", [a],
                    "authority only: gate stub prints 18 cases; plan declares 4 epochs")
    score("A-authority-4epochs", dst, "authority-only answer key (4 epochs)", ch)

    def a2(d):
        wr(d, "corpus/recheck-replay.py",
           "#!/usr/bin/env python3\nimport sys\nprint('PASS (18 cases)')\nsys.exit(0)\n")
        p = "plans/round-56.md"
        t = rd(d, p)
        assert t.count("epoch-D") and t.count("epoch-E") and t.count("epoch-F")
        wr(d, p, t.replace("epoch-D", "epoch-C").replace("epoch-E", "epoch-C")
             .replace("epoch-F", "epoch-C"))
    tag(a2, ["corpus/recheck-replay.py", "plans/round-56.md"])
    dst, ch = build("A2-authority-3epochs", [a2],
                    "authority only: gate stub 18 cases; plan declares 3 epochs")
    score("A2-authority-3epochs", dst, "authority-only answer key (3 epochs)", ch)

    def a3(d):
        os.remove(os.path.join(d, "plans/round-56.md"))
    tag(a3, ["plans/round-56.md"])
    dst, ch = build("A3-authority-missing", [a3], "authority only: epoch plan removed")
    score("A3-authority-missing", dst, "authority-only answer key (authority removed)", ch)

    def repaired(d):
        sub(d, "SCORECARD.md", "`--selftest` 18 cases", "`--selftest` 20 cases", 1)
        sub(d, "LOG.md", "four freeze epochs land", "six freeze epochs land", 1)
        sub(d, "corpus/lessons/round-56.md", "Three freeze epochs", "Six freeze epochs", 1)
    tag(repaired, ["SCORECARD.md", "LOG.md", "corpus/lessons/round-56.md"])
    dst, ch = build("L-repaired", [repaired], "the plan's landing repairs, real authorities")
    score("L-repaired", dst, "landing shape: value 0 with real authorities", ch)

    def a4(d):
        repaired(d)
        wr(d, "corpus/recheck-replay.py",
           "#!/usr/bin/env python3\nimport sys\nprint('PASS (20 cases)')\nsys.exit(0)\n")
    tag(a4, ["SCORECARD.md", "LOG.md", "corpus/lessons/round-56.md",
             "corpus/recheck-replay.py"])
    dst, ch = build("A4-landing-answerkey", [a4],
                    "landing shape + a printer as the cases authority")
    score("A4-landing-answerkey", dst, "answer key at the landing: gate replaced by a printer", ch)

    # ---- B. floor evasion ----------------------------------------------
    def b1(d):
        n1 = sub(d, "SCORECARD.md", "`--selftest` 18 cases", "`--selftest` verified", 1)
        n2 = sub(d, "LOG.md", "four freeze epochs land", "all freeze epochs land", 1)
        n3 = sub(d, "corpus/lessons/round-56.md", "Three freeze epochs:", "Freeze epochs:", 1)
        assert (n1, n2, n3) == (1, 1, 1)
    tag(b1, ["SCORECARD.md", "LOG.md", "corpus/lessons/round-56.md"])
    dst, ch = build("B1-delete-stale", [b1],
                    "delete the three stale statements instead of repairing them")
    score("B1-delete-stale", dst, "floor evasion: stale statements deleted", ch)

    def b1b(d):
        b1(d)
        t = rd(d, "LOG.md")
        i = t.index("## Round 56 (2026-11-07)")
        sec = t[i:]
        new, n = re.subn(r"\b(16|20|21|22|23) MATCH", r"\1 controls", sec)
        assert n == 5, n
        wr(d, "LOG.md", t[:i] + new)
    tag(b1b, ["SCORECARD.md", "LOG.md", "corpus/lessons/round-56.md"])
    dst, ch = build("B2-floor8", [b1b],
                    "three stales deleted plus five historical MATCH statements -> pop 8")
    score("B2-floor8", dst, "floor evasion: exactly 8 statements, value 0", ch)

    def b3(d):
        sub(d, "SCORECARD.md",
            "## Round 56 \u2014 post-move (claim C1 freshness)",
            "## Round 56 \u2013 post-move (claim C1 freshness)", 1)  # em -> en dash
    tag(b3, ["SCORECARD.md"])
    dst, ch = build("B3-endash-heading", [b3],
                    "one byte: em dash -> en dash; the whole scorecard surface goes dark")
    score("B3-endash-heading", dst, "selection by heading bytes (en dash)", ch)

    # ---- C. class evasion ----------------------------------------------
    def c(d):
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor) + len(anchor)
        line = ("\nClose notes: the gate reports `--selftest` 18 test cases; the epoch-F "
                "receipt shows 31 matches; SEVEN epochs were declared; the close took "
                "7 stated clocks.\n")
        wr(d, rel, t[:i] + line + t[i:])
    tag(c, ["SCORECARD.md"])
    dst, ch = build("C-class-evasion", [c],
                    "four false numbers of near-miss shapes inside the surface")
    score("C-class-evasion", dst, "class set is closed: near-miss shapes uncounted", ch)

    # ---- D. surface misselection ---------------------------------------
    def d0(d):
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor)
        moved = ("Round-56 close: the replay gate's `--selftest` reads 18 cases; "
                 "the epoch count is four freeze epochs.\n")
        wr(d, rel, t[:i] + moved + t[i:])
    tag(d0, ["SCORECARD.md"])
    dst, ch = build("D0-new-false-outside", [d0],
                    "a NEW false round-56 statement one line above the audited heading")
    score("D0-new-false-outside", dst, "false statement outside the boundary: uncounted", ch)

    def d1(d):
        sub(d, "SCORECARD.md", "`--selftest` 18 cases", "`--selftest` verified", 1)
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor)
        moved = ("Round-56 close: the replay gate's `--selftest` reads 18 cases; "
                 "the epoch count is four freeze epochs.\n")
        wr(d, rel, t[:i] + moved + t[i:])
    tag(d1, ["SCORECARD.md"])
    dst, ch = build("D1-boundary-move", [d1],
                    "the false statement moved one line above the audited heading")
    score("D1-boundary-move", dst, "surface misselection: one line above the heading", ch)

    def d2(d):
        # SCORECARD: stale cases claim removed from audit; four true statements added.
        sub(d, "SCORECARD.md", "`--selftest` 18 cases", "`--selftest` verified", 1)
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor) + len(anchor)
        add = ("\nReceipts: 23 MATCH in `.ufo/waves/round-56/controls/"
               "controls-prefreeze-epochF.txt`; the manifest holds 10 clocks; "
               "the replay reads 10/10 MATCH.\n")
        wr(d, rel, t[:i] + add + t[i:])
        # LOG: retitle the section so the stale epoch heading line is not audited.
        sub(d, "LOG.md", "## Round 56 (2026-11-07)", "## Round 56 \u2014 2026-11-07", 1)
        # LESSON: drop the Claims heading so the claim body is not audited.
        sub(d, "corpus/lessons/round-56.md", "## Claims\n", "", 1)
    tag(d2, ["SCORECARD.md", "LOG.md", "corpus/lessons/round-56.md"])
    dst, ch = build("D2-relocate-all", [d2],
                    "all three stales reach the predicate only as relocated text; pop 9")
    score("D2-relocate-all", dst, "surface misselection: all stales relocated, value 0", ch)

    # ---- E. guard bypass ------------------------------------------------
    def e1(d):
        wr(d, "corpus/current-claims.py",
           "#!/usr/bin/env python3\nimport sys\n"
           "print('CURRENT_CLAIMS: value=3 population=16 mismatches=3 unbound=0')\n"
           "sys.exit(1)\n")
    tag(e1, ["corpus/current-claims.py"])
    dst, ch = build("E1-printer-gate-base", [e1],
                    "printer gate on BASE: echoes the frozen checker's two numbers, rc 1")
    score("E1-printer-gate-base", dst, "guard bypass: printer gate, bytes differ", ch)

    def e1b(d):
        d2(d)
        wr(d, "corpus/current-claims.py",
           "#!/usr/bin/env python3\nimport sys\n"
           "print('CURRENT_CLAIMS: value=0 population=9 mismatches=0 unbound=0')\n"
           "sys.exit(1)\n")
    tag(e1b, ["SCORECARD.md", "LOG.md", "corpus/lessons/round-56.md",
              "corpus/current-claims.py"])
    dst, ch = build("E2-printer-gate-admit", [e1b],
                    "printer gate on the relocated tree: value 0 population 9, rc 1")
    score("E2-printer-gate-admit", dst, "guard bypass: full admission with a printer", ch)

    def e3(d):
        d2(d)
        wr(d, "corpus/current-claims.py",
           "#!/usr/bin/env python3\nimport sys\n"
           "print('CURRENT_CLAIMS: value=1 population=10 mismatches=1 unbound=0')\n"
           "sys.exit(0)\n")
    tag(e3, ["SCORECARD.md", "LOG.md", "corpus/lessons/round-56.md",
             "corpus/current-claims.py"])
    dst, ch = build("E3-stricter-gate", [e3],
                    "a STRICTER gate (counts one more claim) on the same tree")
    score("E3-stricter-gate", dst, "guard punishes extra sensitivity (kill-rule c)", ch)

    # ---- F. wrong-epoch subject ----------------------------------------
    def f1(d):
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor) + len(anchor)
        add = ("\nClose: epoch F `9cbe9d5f` (epoch E `dd31b786` recheck) "
               "totalled 22 MATCH.\n")
        wr(d, rel, t[:i] + add + t[i:])
    tag(f1, ["SCORECARD.md"])
    dst, ch = build("F1-wrong-epoch-letter", [f1],
                    "false claim about epoch F, number taken from epoch E by position")
    score("F1-wrong-epoch-letter", dst, "wrong-epoch subject: nearest-letter pairing", ch)

    def f2(d):
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor) + len(anchor)
        add = ("\nClose: the epoch-F receipt `controls-prefreeze-epochF.txt` "
               "totalled 22 MATCH.\n")
        wr(d, rel, t[:i] + add + t[i:])
    tag(f2, ["SCORECARD.md"])
    dst, ch = build("F2-wrong-epoch-receipt", [f2],
                    "same false claim via the receipt-path form")
    score("F2-wrong-epoch-receipt", dst, "wrong-epoch subject: receipt-path form", ch)

    # ---- G/H. diagnostics + number shape (extras) ----------------------
    def g(d):
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor) + len(anchor)
        wr(d, rel, t[:i] + "\nThe wave ran 12 cases in three lanes.\n" + t[i:])
    tag(g, ["SCORECARD.md"])
    dst, ch = build("G-unbound-diagnostic", [g],
                    "a counted statement with no authority: value rises, unbound prints 0")
    score("G-unbound-diagnostic", dst, "unbound reported as 0 while counted in value", ch)

    def h(d):
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor) + len(anchor)
        wr(d, rel, t[:i] + "\nThe captures span 1,018 cases.\n" + t[i:])
    tag(h, ["SCORECARD.md"])
    dst, ch = build("H-number-anchor", [h],
                    "'1,018 cases' is read as the number 18")
    score("H-number-anchor", dst, "regex anchors mid-number: 1,018 -> 18", ch)

    # ---- I. decoy first section ---------------------------------------
    def i_(d):
        rel = "SCORECARD.md"
        t = rd(d, rel)
        anchor = "## Round 56 \u2014 post-move (claim C1 freshness)\n"
        i = t.index(anchor)
        decoy = ("## Round 56 \u2014 post-move\n\nThe epoch-F receipt "
                 "`controls-prefreeze-epochF.txt` reads 23 MATCH. The manifest holds "
                 "10 clocks. The replay reads 10/10 MATCH.\n\n")
        wr(d, rel, t[:i] + decoy + t[i:])
    tag(i_, ["SCORECARD.md"])
    dst, ch = build("I-decoy-section", [i_],
                    "a decoy round-56 heading shadows the genuine section (first match wins)")
    score("I-decoy-section", dst, "decoy heading: first-match-wins shadowing", ch)

    with open(f"{OUT}/results.json", "w", encoding="utf-8") as f:
        json.dump(RESULTS, f, indent=2)
    print("\n=== TABLE ===")
    for r in RESULTS:
        print(f"{r['name']:26s} val={r.get('value'):6s} pop={r.get('population'):<3} "
              f"gate={r.get('gate')} guard={r.get('guard')} admitted={r['admitted']}")


if __name__ == "__main__":
    main()
