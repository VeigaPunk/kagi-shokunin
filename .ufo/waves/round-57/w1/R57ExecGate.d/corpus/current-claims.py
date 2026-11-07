#!/usr/bin/env python3
"""corpus/current-claims.py -- reusable C1 gate: stale numeric self-description
in the audited surface (round 57 draft, seat R57ExecGate).

Port of the frozen checker plans/round-57-c1-check.py at claim BASE
1cda9e7ae4767b4133e283bfbc08266d4c86362d (lane kagi-shokunin, master): the
measurement core below reproduces it exactly -- same audited surface, same
four statement classes, same authorities, same population/mismatch/unbound
accounting, same population floor, same printed lines and exit codes. The one
addition is a real --selftest that builds ten isolated synthetic roots under
the system temp dir (never the measured tree, never the lane) and drives this
CLI end to end on each.

Usage: python3 -I -B corpus/current-claims.py --root DIR [--verbose]
       python3 -I -B corpus/current-claims.py --selftest

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
  EPOCHS `W freeze epochs` (W a word number ONE..TEN or digits) -> the number of
         distinct `epoch-[A-F]` tokens declared in `plans/round-56.md`.
  CLOCKS `N clocks` -> the number of data rows of `corpus/recheck-captures.tsv`.

value = mismatches + unbound statements; a statement of a class that names no
authority is UNBOUND (fail closed). `--verbose` prints one `STMT` line per
statement. Final line:
  CURRENT_CLAIMS: value=V population=P mismatches=M unbound=U cases=C match=K
  epochs=E clocks=Z pop=F guard=G
Exit 0 iff V == 0 and P >= 8; 1 otherwise; 2 on SETUP (root unreadable).

Named ceilings: an authority file forged to agree with the statement passes; the
class set is closed (a numeric statement of another shape is not counted); a
statement's subject is resolved by the line's own text.
"""
from __future__ import annotations

import argparse
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile

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
    ap.add_argument("--selftest", action="store_true",
                    help="run the isolated synthetic-root selftest")
    args = ap.parse_args()
    if args.selftest:
        return selftest()
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
    value = bad if guard else "FAIL"
    print(f"CURRENT_CLAIMS: value={value} population={population} "
          f"mismatches={bad} unbound=0 cases={per['cases']} match={per['match']} "
          f"epochs={per['epochs']} clocks={per['clocks']} pop={per['pop']} guard={guard}")
    return 0 if (guard and bad == 0) else 1


# ------------------------------ --selftest ---------------------------------
#
# Ten isolated synthetic-root cases. Every case builds its own throwaway root
# under tempfile.mkdtemp (system temp, never the measured tree, never the
# lane), runs this CLI on it as a subprocess (the real argument path), and
# asserts on the exit code, the final summary line and the --verbose STMT
# lines. A synthetic surface also carries out-of-surface sections (`## Round
# 55 ...`) whose numeric statements must NOT enter the population.

RECEIPT_MATCHES = {"A": 20, "B": 21, "C": 21, "D": 22, "E": 22, "F": 23}

SCORECARD_MD = """# Scorecard

Standing rows for every round.

## Round 56 — post-move

- recheck-replay `--selftest` 20 cases green at the tip.
- epoch E 22 MATCH `aaaaaaaa` per .ufo/waves/round-56/controls/controls-prefreeze-epochE.txt and epoch F 23 MATCH `bbbbbbbb` per .ufo/waves/round-56/controls/controls-prefreeze-epochF.txt.
- six freeze epochs land in the controls dir.
- 10 clocks in the capture manifest.
- census 10/10 MATCH.

## Round 55 — post-move

- recheck-replay `--selftest` 11 cases green.
"""

LOG_MD = """# Log

## Round 56 (2026-11)

- six freeze epochs land in the controls dir.
- epoch F 23 MATCH per .ufo/waves/round-56/controls/controls-prefreeze-epochF.txt.

## Round 55 (2026-10)

- 7 clocks noted.
"""

LESSON_MD = """# Lesson round 56

Round: 56
Frozen plan: plans/round-56.md

Body prose between the head block and the claims.

## Claims

- Six freeze epochs in this round.
- recheck-replay selftest: 20 cases.

## Gate

- 3 clocks outside the surface.
"""

PLAN56_MD = """# Round 56 plan

Six receipt epochs: epoch-A epoch-B epoch-C epoch-D epoch-E epoch-F.
"""

SMALL_SC = ("# Scorecard\n\n## Round 56 — post-move\n\n"
            "- recheck-replay `--selftest` 20 cases green at the tip.\n")
SMALL_LG = "# Log\n\n## Round 56 (2026-11)\n\n- 10 clocks in the capture manifest.\n"
SMALL_LS = ("# Lesson round 56\n\nRound: 56\nFrozen plan: plans/round-56.md\n"
            "\n## Claims\n\n- Six freeze epochs in this round.\n")


def put(root: str, rel: str, text: str) -> None:
    p = os.path.join(root, rel)
    os.makedirs(os.path.dirname(p) or root, exist_ok=True)
    with open(p, "w", encoding="utf-8") as f:
        f.write(text)


def sub(root: str, rel: str, old: str, new: str) -> None:
    p = os.path.join(root, rel)
    with open(p, encoding="utf-8") as f:
        s = f.read()
    t = s.replace(old, new, 1)
    if t == s:
        raise AssertionError(f"inert edit {rel}: {old!r}")
    with open(p, "w", encoding="utf-8") as f:
        f.write(t)


def synth(d: str, *, small: bool = False) -> None:
    sc, lg, ls = (SMALL_SC, SMALL_LG, SMALL_LS) if small else \
                 (SCORECARD_MD, LOG_MD, LESSON_MD)
    put(d, "SCORECARD.md", sc)
    put(d, "LOG.md", lg)
    put(d, "corpus/lessons/round-56.md", ls)
    put(d, "plans/round-56.md", PLAN56_MD)
    for L, n in RECEIPT_MATCHES.items():
        put(d, f".ufo/waves/round-56/controls/controls-prefreeze-epoch{L}.txt",
            f"CONTROLS: match={n} mismatch=0\n")
    put(d, "corpus/recheck-captures.tsv",
        "id\tkind\n" + "".join(f"r{i:02d}\tclock\n" for i in range(1, 11)))
    put(d, "corpus/recheck-replay.py",
        "#!/usr/bin/env python3\n"
        "import sys\n"
        "print('RECHECK_REPLAY: PASS (20 cases)')\n"
        "sys.exit(0)\n")


def cli(root: str, verbose: bool = False):
    cmd = [sys.executable, "-I", "-B", os.path.abspath(__file__), "--root", root]
    if verbose:
        cmd.append("--verbose")
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    lines = (r.stdout or "").splitlines()
    return r.returncode, (lines[-1] if lines else ""), lines


def fld(line: str, key: str) -> str | None:
    m = re.search(rf"(?:^| ){re.escape(key)}=([^ ]*)", line)
    return m.group(1) if m else None


def expect(fails: list[str], name: str, cond: bool, detail: str) -> None:
    if not cond:
        fails.append(f"{name}: {detail}")


def case_clean(d: str, fails: list[str], name: str) -> None:
    synth(d)
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 0, f"rc={rc} final={fin!r}")
    for k, v in [("value", "0"), ("population", "11"), ("mismatches", "0"),
                 ("cases", "2"), ("match", "3"), ("epochs", "3"),
                 ("clocks", "1"), ("pop", "2"), ("guard", "1")]:
        expect(fails, name, fld(fin, k) == v, f"{k}!={v}: {fin!r}")


def case_cases_mismatch(d: str, fails: list[str], name: str) -> None:
    synth(d)
    sub(d, "SCORECARD.md", "`--selftest` 20 cases", "`--selftest` 19 cases")
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 1, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "value") == "1", fin)
    expect(fails, name, fld(fin, "mismatches") == "1", fin)
    _, _, lines = cli(d, verbose=True)
    want = "STMT SCORECARD:3 cls=cases stated=19 auth=20 " \
           "via=recheck-replay-selftest MISMATCH"
    expect(fails, name, want in lines, f"missing {want!r}")


def case_epochs_mismatch(d: str, fails: list[str], name: str) -> None:
    synth(d)
    sub(d, "LOG.md", "six freeze epochs land", "four freeze epochs land")
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 1, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "value") == "1", fin)
    _, _, lines = cli(d, verbose=True)
    want = "STMT LOG:3 cls=epochs stated=4 auth=6 " \
           "via=receipt-file-count MISMATCH"
    expect(fails, name, want in lines, f"missing {want!r}")


def case_missing_surface(d: str, fails: list[str], name: str) -> None:
    synth(d)
    os.remove(os.path.join(d, "corpus", "lessons", "round-56.md"))
    rc, fin, _ = cli(d)
    exact = ("CURRENT_CLAIMS: value=FAIL population=0 mismatches=0 unbound=0 "
             "cases=0 match=0 epochs=0 clocks=0")
    expect(fails, name, rc == 1, f"rc={rc} final={fin!r}")
    expect(fails, name, fin == exact, f"final={fin!r} want {exact!r}")


def case_population_floor(d: str, fails: list[str], name: str) -> None:
    synth(d, small=True)
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 1, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "value") == "FAIL", fin)
    expect(fails, name, fld(fin, "population") == "3", fin)
    expect(fails, name, fld(fin, "guard") == "0", fin)


def case_receipt_tamper(d: str, fails: list[str], name: str) -> None:
    synth(d)
    sub(d, ".ufo/waves/round-56/controls/controls-prefreeze-epochE.txt",
        "CONTROLS: match=22 mismatch=0", "CONTROLS: match=19 mismatch=0")
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 1, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "value") == "1", fin)
    _, _, lines = cli(d, verbose=True)
    want = "STMT SCORECARD:4 cls=match stated=22 auth=19 " \
           "via=receipt-epochE MISMATCH"
    expect(fails, name, want in lines, f"missing {want!r}")


def case_pop_fraction(d: str, fails: list[str], name: str) -> None:
    synth(d)
    sub(d, "SCORECARD.md", "census 10/10 MATCH.", "census 9/10 MATCH.")
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 1, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "value") == "1", fin)
    expect(fails, name, fld(fin, "pop") == "2", fin)
    _, _, lines = cli(d, verbose=True)
    expect(fails, name,
           "STMT SCORECARD:7 cls=pop stated=9 auth=10 via=pop-size MISMATCH" in lines,
           "missing pop-size MISMATCH")
    expect(fails, name,
           "STMT SCORECARD:7 cls=pop stated=10 auth=10 via=pop-match OK" in lines,
           "missing pop-match OK")


def case_nearest_epoch(d: str, fails: list[str], name: str) -> None:
    synth(d)
    sub(d, "SCORECARD.md",
        "- epoch E 22 MATCH `aaaaaaaa` per "
        ".ufo/waves/round-56/controls/controls-prefreeze-epochE.txt and epoch F "
        "23 MATCH `bbbbbbbb` per "
        ".ufo/waves/round-56/controls/controls-prefreeze-epochF.txt.",
        "- epoch E `aaaaaaaa` scored 22 MATCH and epoch F `bbbbbbbb` scored "
        "23 MATCH.")
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 0, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "value") == "0", fin)
    expect(fails, name, fld(fin, "population") == "11", fin)
    _, _, lines = cli(d, verbose=True)
    expect(fails, name,
           "STMT SCORECARD:4 cls=match stated=22 auth=22 via=nearest-epochE OK" in lines,
           "missing nearest-epochE OK")
    expect(fails, name,
           "STMT SCORECARD:4 cls=match stated=23 auth=23 via=nearest-epochF OK" in lines,
           "missing nearest-epochF OK")


def case_unbound(d: str, fails: list[str], name: str) -> None:
    synth(d)
    sub(d, "SCORECARD.md", "- recheck-replay `--selftest` 20 cases green at the tip.",
        "- hand-counted 20 cases in the ledger.")
    sub(d, "LOG.md",
        "- epoch F 23 MATCH per "
        ".ufo/waves/round-56/controls/controls-prefreeze-epochF.txt.",
        "- 23 MATCH with no epoch letter or receipt.")
    rc, fin, _ = cli(d)
    expect(fails, name, rc == 1, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "value") == "2", fin)
    _, _, lines = cli(d, verbose=True)
    expect(fails, name,
           "STMT SCORECARD:3 cls=cases stated=20 auth=none "
           "via=no-named-instrument UNBOUND" in lines,
           "missing no-named-instrument UNBOUND")
    expect(fails, name,
           "STMT LOG:4 cls=match stated=23 auth=none via=nearest-epoch- UNBOUND" in lines,
           "missing nearest-epoch- UNBOUND")


def case_verbose_sync(d: str, fails: list[str], name: str) -> None:
    synth(d)
    rc, fin, lines = cli(d, verbose=True)
    stmts = [ln for ln in lines if ln.startswith("STMT ")]
    expect(fails, name, rc == 0, f"rc={rc} final={fin!r}")
    expect(fails, name, fld(fin, "population") == str(len(stmts)),
           f"population={fld(fin, 'population')} vs {len(stmts)} STMT lines")
    expect(fails, name, len(stmts) == 11, f"{len(stmts)} STMT lines")
    shape = re.compile(r"STMT (SCORECARD|LOG|LESSON):\d+ cls=[a-z]+ stated=[0-9]+ "
                       r"auth=(none|[0-9]+) via=[A-Za-z0-9-]+ (OK|MISMATCH|UNBOUND)$")
    bad_shape = [s for s in stmts if not shape.fullmatch(s)]
    expect(fails, name, not bad_shape, f"malformed STMT: {bad_shape[:3]}")
    expect(fails, name, all(s.endswith(" OK") for s in stmts),
           f"non-OK verdicts on clean root: {[s for s in stmts if not s.endswith(' OK')][:3]}")
    cls_seen = {m.group(1) for s in stmts for m in [re.search(r"cls=([a-z]+)", s)] if m}
    expect(fails, name, cls_seen == {"cases", "match", "epochs", "clocks", "pop"},
           f"cls coverage {sorted(cls_seen)}")


SELFTEST_CASES = [
    ("clean-root-zero", case_clean),
    ("cases-mismatch", case_cases_mismatch),
    ("epochs-mismatch", case_epochs_mismatch),
    ("missing-surface", case_missing_surface),
    ("population-floor", case_population_floor),
    ("receipt-tamper", case_receipt_tamper),
    ("pop-fraction-bound", case_pop_fraction),
    ("nearest-epoch-pairing", case_nearest_epoch),
    ("unbound-ambiguous", case_unbound),
    ("verbose-names-every-stmt", case_verbose_sync),
]


def selftest() -> int:
    fails: list[str] = []
    for name, fn in SELFTEST_CASES:
        d = tempfile.mkdtemp(prefix="current-claims-selftest-")
        try:
            fn(d, fails, name)
        except Exception as exc:  # a selftest case must never die silently
            fails.append(f"{name}: exception {type(exc).__name__}: {exc}")
        finally:
            shutil.rmtree(d, ignore_errors=True)
    n = len(SELFTEST_CASES)
    if fails:
        for f in fails:
            print(f"CURRENT_CLAIMS_SELFTEST: FAIL {f}")
        print(f"CURRENT_CLAIMS_SELFTEST: FAIL ({n} cases, "
              f"{len(fails)} failed checks)")
        return 1
    print(f"CURRENT_CLAIMS_SELFTEST: PASS ({n} cases)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
