#!/usr/bin/env python3
"""plans/round-58-c1-check.py — the C1_ROUTED counter (kagi round 58).

Frozen predicate (plans/round-58.md §C1, verbatim):

    C1_ROUTED: value = the number of UNRESOLVED items over POP = 8 fixed routed-defect
    items (I1..I8 below), when GUARD = 1, else FAIL; target 0 (BASE 8).
    An item is UNRESOLVED iff its named condition does not hold on the measured tree.
    GUARD = 1 iff the checker evaluates all eight items (prints population=8 with
    i1..i8 each 0|1, none skipped) and, on a copy of the measured tree whose only
    delta is the I4 statement text changed to a wrong count, prints exactly value+1.

Output line:  C1_ROUTED: value=V population=P i1=T i2=T ... i8=T guard=G
Token convention (declared, per the L1's A-read of the frozen table): token T is
  1  iff item N's required condition HOLDS on the measured tree (resolved),
  0  iff the item was evaluated and its condition does NOT hold (unresolved),
  x  iff an input file the item must read is absent (skipped; population<8).
value = the number of unresolved items (= population minus the 1-tokens) ONLY
when GUARD = 1; whenever GUARD = 0 the line prints the literal FAIL (frozen
"when GUARD = 1, else FAIL"). The --no-challenge diagnostic leg prints the
numeric count with guard=0 so driver/seed legs can parse value+1 expectations. Exit 0 iff guard=1 and value==0; 1
otherwise; 2 SETUP (bad --root). Amended conditions are implemented, not
re-interpreted: A1 (I2 = all FIVE INSTRUMENT pins of a controls-prefreeze-epochC*.txt
receipt equal the measured tree's sha256 for plans/round-57.md, plans/round-57-c1.sh,
plans/round-57-c2.sh, plans/round-57-controls.sh, plans/round-57-c1-check.py, and the
receipt's last CONTROLS: line reads match=N mismatch=0 with N>=13 — the b130bb83
receipt cannot qualify), A2 (I3 quote comparison collapses every whitespace run to
one space on both sides; the quote is <=25 words).

Structural reads, per item (each is a parse, not a word-grep):
  I1  LOG.md's round-57 record = every `## Round 57...` section run (entry +
      appended correction sections) until the first non-`Round 57` `## ` heading;
      it must contain an `epoch C` / `epoch-C` token and a path matching
      `.ufo/waves/round-57/controls/controls-prefreeze-epochC*.txt`; SCORECARD.md's
      `## Round 57 — post-move` section must contain an epoch-C token.
  I2  glob `.ufo/waves/round-57/controls/controls-prefreeze-epochC*.txt`; parse
      `INSTRUMENT <sha256> <path>` lines and the LAST `CONTROLS:` line per receipt.
  I3  the lesson's `## Gate` rows naming S117 (a row is a whole markdown bullet
      or table row, not a line — the rows wrap) must carry the S117 registry URL
      (read from the S117 row of corpus/SOURCES.md), a YYYY-MM-DD date, and a
      “-quoted span of <=25 words whose whitespace-collapsed text occurs in the
      whitespace-collapsed `.ufo/waves/round-57/capture/S117.body`; the S117 row's
      last (used-by) cell must name corpus/lessons/round-57.md; a `source:` line of
      the lesson must name S117.
  I4  (A3, two count classes) measured count = lines of corpus/SOURCES.md
      matching `^| S<3+ digits> |` (the lane's census shape; landing pin 117).
      In the SCORECARD post-move coverage row and the lesson §Sources:
      (a) a `Registry L → N` arrow must state N = 117, the round-57 landing
      count; (b) a `tip count ... = N` or `end ... N rows` form must equal the
      measured live count; (c) any `rows=N` attributed on such a bullet (blocks,
      not lines — the bullets wrap) to `.ufo/waves/round-57/final/gates.txt` must
      equal the single distinct `rows=` the file carries, and the bullet must
      carry the predates-S117 predication; (d) each location needs at least one
      count statement. Failure messages name the class.
  I5  a SKILL.md table row naming corpus/current-claims.py that carries an entry
      command (`python3`), its `--selftest`, and a verdict map shaped `0 ...;
      1 ...; 2 ... SETUP ...`.
  I6  AST of corpus/current-claims.py: add_argument('--round'...); no path- or
      heading-shaped literal containing round-56 (a constant matching round-56
      AND containing '/', '.md', '.tsv' or '##'); at least one dynamic string
      (f-string, %-format, .format, concat) deriving a `round-`/`Round ` surface
      from a substitution; the module docstring's EPOCHS sentence (sentence,
      not line — it may wrap) names `plans/round-` and `epoch-` while the code
      carries an `epoch-` pattern and a plans path; `--selftest` exits 0
      (subprocess, cwd=measured tree).
  I7  the lesson's `## Gate` row naming S115 contains the live heading
      `Enabling/Disabling audit devices`.
  I8  `bash corpus/scope-gate.sh --lane-root <fleet root>` (L1 conformance
      ruling: a copied tree's script-derived LANE_ROOT misreads the partition)
      run in the measured tree prints a `stale_basis=N` token with N=0 (last
      occurrence).

GUARD challenge: a copy of the measured tree (made next to the measured tree,
override with C1_CHALLENGE_PARENT; deleted afterwards) receives the first
applicable A3-class I4 mutation — coverage-row tip count -> measured+1, else
coverage-row Registry arrow -> 118, else lesson tip count -> measured+1, else
lesson `end ... N rows` -> measured+1, else lesson Registry arrow -> 118, else
a gates.txt-attributed rows=N -> carried+1 — changing nothing else; the checker
re-runs itself (--no-challenge) on the copy and must print exactly count+1. On
a tree where I4 already fails no wrong-count delta can add +1, so guard reads
0 there and the line prints value=FAIL (BASE reads value=FAIL population=8
with i1..i8=0 by construction; the guard-bearing reading is a tree that holds
all eight items).

Selftest: `--selftest` builds isolated synthetic roots under TMPDIR and proves
18 cases — each item's pass and fail shape plus the aggregate all-hold root and
a removed-input root (population<8, value=FAIL) — printing
C1_CHECK_SELFTEST: PASS (18 cases) and exiting 0.

Named ceilings: the checker trusts the files it reads; a forged authority that
satisfies the parsed shape passes; the item set is closed (POP=8); the I8 leg
executes the measured tree's own scope-gate.sh and the I6 leg executes the
measured tree's own current-claims.py --selftest in a subprocess (no network,
no writes outside TMPDIR/scratch).
"""
from __future__ import annotations

import argparse
import ast
import glob
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile

INSTRUMENT_FILES = [
    "plans/round-57.md",
    "plans/round-57-c1.sh",
    "plans/round-57-c2.sh",
    "plans/round-57-controls.sh",
    "plans/round-57-c1-check.py",
]
LANDING_COUNT = 117  # A3: the round-57 landing registry count (S117 landed in 94d72de9)
FLEET_ROOT = "/home/vgpnk/Projects/shokunin"  # I8 lane-root pin (L1 conformance ruling)
EPOCH_C_RE = re.compile(r"epoch[ \t]*-?[ \t]*C\b")
EPOCH_C_RECEIPT_RE = re.compile(
    r"\.ufo/waves/round-57/controls/controls-prefreeze-epochC[^`\s]*\.txt")
INSTRUMENT_RE = re.compile(r"^INSTRUMENT\s+([0-9a-f]{64})\s+(\S+)\s*$")
CONTROLS_RE = re.compile(r"^CONTROLS:.*?match=(\d+)\s+mismatch=(\d+)")
POSTMOVE_RE = r"^## Round 57[ \t]*[—-][ \t]*post-move\b"
S_ROW_RE = re.compile(r"(?m)^\|[ \t]*S\d{3,}[ \t]*\|")
REG_ARROW_RE = re.compile(r"Registry\s+(\d+)\s*→\s*(\d+)")
TIPCOUNT_RE = re.compile(r"tip count\b[^;\n]{0,200}?=\s*(\d+)")
END_ROWS_RE = re.compile(r"\bend\b[^.;\n]{0,120}?(\d+)\s+rows")
GATES_ROWS_RE = re.compile(r"rows=(\d+)")
BARE_ROWS_RE = re.compile(r"\b(\d+)\s+rows\b")
DATE_RE = re.compile(r"\d{4}-\d{2}-\d{2}")
URL_RE = re.compile(r"https?://[^\s|`]+")
LIVE_HEADING = "Enabling/Disabling audit devices"
LESSON_REL = "corpus/lessons/round-57.md"
S117_BODY_REL = ".ufo/waves/round-57/capture/S117.body"
GATES_REL = ".ufo/waves/round-57/final/gates.txt"
HOLD, FAIL, SKIP = "HOLD", "FAIL", "SKIP"


def rd(root: str, rel: str) -> str | None:
    p = os.path.join(root, rel)
    # a symlinked measured file is not the tree's own bytes: the reviewer's symlink-tree
    # exploit read value=0/guard=1 off a host directory outside the tree (round-58 M58-6).
    if os.path.islink(p):
        return None
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None


def sha_of(root: str, rel: str) -> str | None:
    try:
        with open(os.path.join(root, rel), "rb") as f:
            return hashlib.sha256(f.read()).hexdigest()
    except OSError:
        return None


def section(text: str, start_re: str) -> str:
    m = re.search(start_re, text, re.M)
    if not m:
        return ""
    m2 = re.compile(r"^## ", re.M).search(text, m.end())
    return text[m.start(): m2.start() if m2 else len(text)]


def r57_surface(log_text: str) -> str:
    """Every `## Round 57...` heading section, run until a non-Round-57 `## `."""
    out: list[str] = []
    inside = False
    for ln in log_text.splitlines(keepends=True):
        is_h = ln.startswith("## ")
        is_r57 = bool(re.match(r"^## Round 57\b", ln))
        if not inside and is_r57:
            inside = True
            out.append(ln)
            continue
        if inside:
            if is_h and not is_r57:
                break
            out.append(ln)
    return "".join(out)


def collapse(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()


def gate_blocks(gate_text: str) -> list[str]:
    """A Gate row is a whole markdown bullet (or table row), not a single line:
    the lesson's rows wrap over several lines, with the URL/date on the first
    and the quote/anchor on continuation lines."""
    blocks: list[str] = []
    cur: list[str] = []
    for ln in gate_text.splitlines(keepends=True):
        if re.match(r"^[-*] ", ln) or ln.startswith("|"):
            if cur:
                blocks.append("".join(cur))
            cur = [ln]
        elif cur:
            cur.append(ln)
    if cur:
        blocks.append("".join(cur))
    return blocks


def quoted_spans(line: str) -> list[str]:
    spans = re.findall(r"“([^”]+)”", line)
    spans += re.findall(r'"([^"\n]{4,400})"', line)
    return spans


def registry_row(src_text: str, sid: str) -> str | None:
    for ln in src_text.splitlines():
        if re.match(rf"^\|[ \t]*{sid}[ \t]*\|", ln):
            return ln
    return None


def used_by_cell(row: str) -> str:
    cells = [c.strip() for c in row.split("|") if c.strip()]
    return cells[-1] if cells else ""


def coverage_row(post_text: str) -> str:
    for ln in post_text.splitlines():
        if ln.lstrip().startswith("| coverage"):
            return ln
    return ""


def gates_rows_of(root: str) -> int | None:
    txt = rd(root, GATES_REL)
    if txt is None:
        return None
    vals = set(GATES_ROWS_RE.findall(txt))
    return int(next(iter(vals))) if len(vals) == 1 else None


# --------------------------------------------------------------------------- items
def item1(root: str) -> tuple[str, str]:
    log = rd(root, "LOG.md")
    sc = rd(root, "SCORECARD.md")
    if log is None or sc is None:
        return SKIP, "LOG.md or SCORECARD.md absent"
    surf = r57_surface(log)
    post = section(sc, POSTMOVE_RE)
    # both tokens on ONE line: a file that says "no epoch C" somewhere and names the
    # receipt elsewhere held I1 under the reviewer's negative-naming probe (M58-6).
    ok_log_epoch = any(EPOCH_C_RE.search(ln) and EPOCH_C_RECEIPT_RE.search(ln)
                       for ln in surf.splitlines())
    ok_log_path = ok_log_epoch and any(
        os.path.isfile(os.path.join(root, p)) for p in EPOCH_C_RECEIPT_RE.findall(surf))
    ok_sc_epoch = bool(post) and bool(EPOCH_C_RE.search(post))
    det = (f"log-epoch-C={'y' if ok_log_epoch else 'n'} "
           f"log-epochC-receipt-path={'y' if ok_log_path else 'n'} "
           f"scorecard-postmove-epoch-C={'y' if ok_sc_epoch else 'n'}")
    return (HOLD if (ok_log_epoch and ok_log_path and ok_sc_epoch) else FAIL), det


def item2(root: str) -> tuple[str, str]:
    missing = [f for f in INSTRUMENT_FILES if rd(root, f) is None]
    if missing:
        return SKIP, "instrument files absent: " + ",".join(missing)
    ctl = os.path.join(root, ".ufo", "waves", "round-57", "controls")
    recs = sorted(glob.glob(os.path.join(ctl, "controls-prefreeze-epochC*.txt")))
    if not recs:
        return FAIL, "no controls-prefreeze-epochC*.txt receipt under .ufo/waves/round-57/controls/"
    shas = {f: sha_of(root, f) for f in INSTRUMENT_FILES}
    tried: list[str] = []
    for rp in recs:
        txt = rd(root, os.path.relpath(rp, root)) or ""
        pins: dict[str, str] = {}
        for ln in txt.splitlines():
            m = INSTRUMENT_RE.match(ln)
            if m:
                pins[m.group(2)] = m.group(1)
        ctrl = [CONTROLS_RE.match(ln) for ln in txt.splitlines() if ln.startswith("CONTROLS:")]
        ctrl = [c for c in ctrl if c]
        last = ctrl[-1] if ctrl else None
        pins_ok = all(pins.get(f) == shas[f] for f in INSTRUMENT_FILES)
        ctrl_ok = bool(last) and int(last.group(2)) == 0 and int(last.group(1)) >= 13
        tried.append(f"{os.path.basename(rp)}:pins={'ok' if pins_ok else 'bad'}"
                     f":controls={'ok' if ctrl_ok else 'bad'}")
        if pins_ok and ctrl_ok:
            return HOLD, f"qualifying receipt {os.path.basename(rp)} (" + tried[-1] + ")"
    return FAIL, "no epochC* receipt qualifies (" + "; ".join(tried) + ")"


def item3(root: str) -> tuple[str, str]:
    lesson = rd(root, LESSON_REL)
    src = rd(root, "corpus/SOURCES.md")
    if lesson is None or src is None:
        return SKIP, "lesson or SOURCES.md absent"
    body = rd(root, S117_BODY_REL)
    if body is None:
        return FAIL, "S117 capture body absent"
    s117 = registry_row(src, "S117")
    if s117 is None:
        return FAIL, "no S117 registry row in SOURCES.md"
    url_m = URL_RE.search(s117)
    url = url_m.group(0) if url_m else ""
    usedby_ok = "corpus/lessons/round-57.md" in used_by_cell(s117)
    source_ok = any(ln.startswith("source:") and "S117" in ln for ln in lesson.splitlines())
    gate = section(lesson, r"^## Gate\s*$")
    rows = [blk for blk in gate_blocks(gate) if "S117" in blk]
    body_c = collapse(body)
    url_ok = date_ok = quote_ok = False
    best_q = ""
    for blk in rows:
        if url and url in blk:
            url_ok = True
        if set(DATE_RE.findall(s117)) & set(DATE_RE.findall(blk)):
            date_ok = True
        for q in quoted_spans(blk):
            qc = collapse(q)
            if 6 <= len(qc.split()) <= 25 and qc in body_c:
                quote_ok = True
                best_q = qc
    parts = [f"gate-rows={len(rows)}", f"url={'y' if url_ok else 'n'}",
             f"date={'y' if date_ok else 'n'}",
             f"quote<=25w-in-body={'y' if quote_ok else 'n'}",
             f"used-by={'y' if usedby_ok else 'n'}",
             f"source-line={'y' if source_ok else 'n'}"]
    ok = url_ok and date_ok and quote_ok and usedby_ok and source_ok
    return (HOLD if ok else FAIL), " ".join(parts)


def item4(root: str) -> tuple[str, str]:
    sc = rd(root, "SCORECARD.md")
    lesson = rd(root, LESSON_REL)
    src = rd(root, "corpus/SOURCES.md")
    if sc is None or lesson is None or src is None:
        return SKIP, "SCORECARD.md, lesson or SOURCES.md absent"
    measured = len(S_ROW_RE.findall(src))
    gates_rows = gates_rows_of(root)
    problems: list[str] = []
    stated = {"SCORECARD coverage row": False, "lesson §Sources": False}
    post = section(sc, POSTMOVE_RE)
    cov_rows = [ln for ln in post.splitlines() if ln.lstrip().startswith("| coverage")]
    if len(cov_rows) != 1:
        problems.append(f"coverage-row count {len(cov_rows)} != 1 (a decoy row shadows the read)")
    locations = [
        ("SCORECARD coverage row", cov_rows[0] if cov_rows else ""),
        ("lesson §Sources", section(lesson, r"^## Sources\s*$")),
    ]
    for where, text in locations:
        if not text:
            problems.append(f"{where}: section/row absent")
            continue
        for _l, r in REG_ARROW_RE.findall(text):
            stated[where] = True
            if int(r) != LANDING_COUNT:
                problems.append(f"{where}: Registry-arrow states {r} != landing {LANDING_COUNT}")
        for m in TIPCOUNT_RE.finditer(text):
            stated[where] = True
            if int(m.group(1)) != measured:
                problems.append(f"{where}: tip-count states {m.group(1)} != measured {measured}")
        for m in END_ROWS_RE.finditer(text):
            stated[where] = True
            if int(m.group(1)) != measured:
                problems.append(f"{where}: end-rows states {m.group(1)} != measured {measured}")
        for blk in gate_blocks(text):
            if "gates.txt" not in blk or not GATES_ROWS_RE.search(blk):
                continue
            stated[where] = True
            for m in GATES_ROWS_RE.finditer(blk):
                if gates_rows is None or int(m.group(1)) != gates_rows:
                    problems.append(
                        f"{where}: gates.txt attribution {m.group(1)} != carried "
                        f"{gates_rows if gates_rows is not None else 'none'}")
                elif not re.search(r"\bpredat|\bafter\b", blk):
                    problems.append(f"{where}: gates.txt attribution lacks the "
                                    f"predates-S117 predication")
    for where, seen in stated.items():
        if not seen:
            problems.append(f"{where}: no count statement found")
    det = f"measured={measured} landing={LANDING_COUNT} gates={gates_rows} problems={len(problems)}"
    return (HOLD if not problems else FAIL), det + ((" :: " + "; ".join(problems[:4])) if problems else "")


def item5(root: str) -> tuple[str, str]:
    sk = rd(root, "SKILL.md")
    if sk is None:
        return SKIP, "SKILL.md absent"
    # the row must sit inside a `## Gate registry ...` section: a table row anywhere else
    # in SKILL.md held I5 under the reviewer's fake-row probe (round-58 M58-6).
    rows: list[str] = []
    in_registry = False
    for ln in sk.splitlines():
        if ln.startswith("## "):
            in_registry = "gate registry" in ln.lower()
            continue
        if in_registry and ln.lstrip().startswith("|") and "corpus/current-claims.py" in ln:
            rows.append(ln)
    if not rows:
        return FAIL, "no gate-registry row names corpus/current-claims.py"
    for ln in rows:
        codes = set(re.findall(r"(?:^|[|\s;:])([012])(?=[\s:`])", ln))
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        cmd_cell = cells[2] if len(cells) > 2 else ""
        if ("corpus/current-claims.py" in cmd_cell and "python3" in ln
                and "--selftest" in ln and "SETUP" in ln
                and {"0", "1", "2"} <= codes):
            return HOLD, "registry row carries entry command, verdict map 0/1/2 SETUP, --selftest"
    return FAIL, ("row present but lacks entry command / verdict map 0,1,2+SETUP / --selftest; "
                  f"rows={len(rows)}")


def _dynamic_round_string(tree: ast.AST) -> bool:
    for n in ast.walk(tree):
        if isinstance(n, ast.JoinedStr):
            lparts = [v.value for v in n.values
                      if isinstance(v, ast.Constant) and isinstance(v.value, str)]
            has_sub = any(isinstance(v, ast.FormattedValue) for v in n.values)
            if has_sub and any(re.search(r"round[-_ /]", p, re.I) for p in lparts):
                return True
        if isinstance(n, ast.BinOp):
            if isinstance(n.op, ast.Mod) and isinstance(n.left, ast.Constant) \
                    and isinstance(n.left.value, str) \
                    and re.search(r"round[-_ /]", n.left.value, re.I):
                return True
            if isinstance(n.op, ast.Add):
                sides = [n.left, n.right]
                if any(isinstance(s, ast.Constant) and isinstance(s.value, str)
                       and re.search(r"round[-_ /]", s.value, re.I) for s in sides) \
                        and any(not isinstance(s, ast.Constant) for s in sides):
                    return True
        if isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute) \
                and n.func.attr == "format" \
                and isinstance(n.func.value, ast.Constant) \
                and isinstance(n.func.value.value, str) \
                and re.search(r"round[-_ /]", n.func.value.value, re.I):
            return True
    return False


def _round_probe(root: str) -> tuple[bool, str]:
    """`--round` must move the audited surface, not just be accepted.

    Plants a round-57-only disagreement (a `--selftest N cases` line naming
    recheck-replay) in a scratch copy: `--round 57` must read a value above 0 and
    `--round 56` must stay at 0. A gate that parses the flag and audits a fixed
    round held I6 under the reviewer's dead-flag probe (round-58 M58-6)."""
    try:
        tmp = tempfile.mkdtemp(prefix="c1-roundprobe-", dir=tempfile.gettempdir())
    except OSError as e:
        return False, f"probe scratch unavailable: {e}"
    try:
        copy = os.path.join(tmp, "tree")
        shutil.copytree(root, copy, symlinks=True)
        les = os.path.join(copy, "corpus", "lessons", "round-57.md")
        with open(les, encoding="utf-8") as f:
            t = f.read()
        m = re.search(r"^## Claims\s*$", t, re.M)
        pos = m.end() if m else len(t)  # fixtures may carry no Claims section; the real
        def val(rnd: int) -> int | None:
            r = subprocess.run(
                [sys.executable, "-I", "-B", os.path.join(copy, "corpus", "current-claims.py"),
                 "--root", copy, "--round", str(rnd)],
                capture_output=True, text=True, timeout=600)
            out = (r.stdout or "") + (r.stderr or "")
            mm = re.search(r"CURRENT_CLAIMS: value=(\d+)", out)
            return int(mm.group(1)) if mm else None

        base57, base56 = val(57), val(56)
        planted = ("\n\nThe gate `corpus/recheck-replay.py` reports `--selftest` 21 cases.\n")
        with open(les, "w", encoding="utf-8") as f:
            f.write(t[:pos] + planted + t[pos:])
        brk57, brk56 = val(57), val(56)
        # a live --round sees the planted round-57 break and leaves round 56 alone; a dead
        # flag returns the same pair twice (reviewer's dead-flag probe, round-58 M58-6).
        ok = (None not in (base57, base56, brk57, brk56)
              and brk57 > base57 and brk56 == base56)
        return ok, (f"--round probe: r57 {base57}->{brk57} r56 {base56}->{brk56}")
    except (OSError, subprocess.SubprocessError, shutil.Error) as e:
        return False, f"probe failed: {type(e).__name__}"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def item6(root: str) -> tuple[str, str]:
    path = os.path.join(root, "corpus", "current-claims.py")
    if not os.path.isfile(path):
        return SKIP, "corpus/current-claims.py absent"
    with open(path, encoding="utf-8", errors="replace") as f:
        src = f.read()
    try:
        tree = ast.parse(src)
    except SyntaxError as e:
        return FAIL, f"parse error: {e}"
    problems: list[str] = []
    has_round = any(
        isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute)
        and n.func.attr == "add_argument" and n.args
        and isinstance(n.args[0], ast.Constant) and isinstance(n.args[0].value, str)
        and n.args[0].value.startswith("--round")
        for n in ast.walk(tree))
    if not has_round:
        problems.append("no add_argument('--round', ...)")
    doc = ast.get_docstring(tree) or ""
    doc_node_ids = set()
    if tree.body and isinstance(tree.body[0], ast.Expr) \
            and isinstance(tree.body[0].value, ast.Constant) \
            and isinstance(tree.body[0].value.value, str):
        doc_node_ids.add(id(tree.body[0].value))
    # --selftest fixture strings are test data, not the audited surface: a fixture that
    # names round 56 does not make the gate audit round 56 (round-58 M58-4).
    st_ids: set[int] = set()
    for n in ast.walk(tree):
        if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef)) and n.name == "run_selftest":
            for sub in ast.walk(n):
                st_ids.add(id(sub))
    # fixture plumbing: module-level `.replace(old, new)` transforms and the fixture
    # builders rewrite synthetic round-56 text; those literals are test data, never a
    # surface the gate reads (round-58 M58-4).
    repl_ids: set[int] = set()
    for n in ast.walk(tree):
        if isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute) \
                and n.func.attr in {"replace", "write", "remove"}:
            for a in n.args:
                repl_ids.add(id(a))
    consts = [n.value for n in ast.walk(tree)
              if isinstance(n, ast.Constant) and isinstance(n.value, str)
              and id(n) not in doc_node_ids and id(n) not in st_ids
              and id(n) not in repl_ids]
    for n in ast.walk(tree):
        if isinstance(n, ast.JoinedStr):
            consts += [v.value for v in n.values
                       if isinstance(v, ast.Constant) and isinstance(v.value, str)]

    def bad_lit(c: str) -> bool:
        # a surface path/heading literal is short; the --selftest fixture bodies are
        # multi-kilobyte blocks of synthetic SCORECARD/LOG text (round-58 M58-4).
        return (len(c) <= 200 and bool(re.search(r"round[-_]?56", c, re.I))
                and ("/" in c or ".md" in c or ".tsv" in c or "##" in c))

    bad = [c for c in consts if bad_lit(c)]
    if bad:
        problems.append("round-56 path/heading literal: "
                        + repr(str(bad[0])[:60]) + ("..." if len(str(bad[0])) > 60 else ""))
    derived = _dynamic_round_string(tree)
    if not derived:
        problems.append("no audited-surface string is derived from the round value")
    doc_flat = collapse(doc)
    ep_sentence = next((s for s in re.split(r"(?<=[.!?])\s+", doc_flat) if "EPOCHS" in s), "")
    doc_ok = bool(ep_sentence) and "plans/round-" in ep_sentence and "epoch-" in ep_sentence
    code_ok = (any(re.search(r"epoch-", c) for c in consts)
               and any(c == "plans" or "plans/" in c for c in consts))
    if not (doc_ok and code_ok):
        problems.append("EPOCHS docstring sentence does not name the plans/round- + epoch- "
                        "authority its code reads")
    probe_ok, probe_desc = _round_probe(root)
    if not probe_ok:
        problems.append(probe_desc)
    st_ok = False
    try:
        r = subprocess.run([sys.executable, "-I", "-B", path, "--selftest"],
                           cwd=root, capture_output=True, text=True, timeout=300)
        st_ok = r.returncode == 0
    except (OSError, subprocess.SubprocessError):
        st_ok = False
    if not st_ok:
        problems.append("--selftest did not exit 0")
    det = (f"--round={'y' if has_round else 'n'} round56-lit={'y' if bad else 'n'} "
           f"derived={'y' if derived else 'n'} docstring-epochs={'y' if doc_ok else 'n'} "
           f"probe={'y' if probe_ok else 'n'} selftest-rc0={'y' if st_ok else 'n'}")
    return (HOLD if not problems else FAIL), det + ((" :: " + "; ".join(problems)) if problems else "")


def item7(root: str) -> tuple[str, str]:
    lesson = rd(root, LESSON_REL)
    if lesson is None:
        return SKIP, "lesson absent"
    gate = section(lesson, r"^## Gate\s*$")
    rows = [blk for blk in gate_blocks(gate) if "S115" in blk]
    if not rows:
        return FAIL, "no S115 Gate row in the round-57 lesson"
    if any(LIVE_HEADING in blk for blk in rows):
        return HOLD, "S115 Gate row names the live heading"
    return FAIL, "S115 Gate row does not name the live heading 'Enabling/Disabling audit devices'"


def item8(root: str) -> tuple[str, str]:
    p = os.path.join(root, "corpus", "scope-gate.sh")
    if not os.path.isfile(p):
        return SKIP, "corpus/scope-gate.sh absent"
    try:
        r = subprocess.run(["bash", "corpus/scope-gate.sh", "--lane-root", FLEET_ROOT],
                           cwd=root, capture_output=True, text=True, timeout=300)
    except (OSError, subprocess.SubprocessError) as e:
        return FAIL, f"scope-gate run failed: {type(e).__name__}"
    blob = (r.stdout or "") + (r.stderr or "")
    vals = re.findall(r"stale_basis=(\d+)", blob)
    if not vals:
        return FAIL, "scope-gate printed no stale_basis token"
    return (HOLD if int(vals[-1]) == 0 else FAIL), f"stale_basis={vals[-1]}"


ITEMS = [("i1", item1), ("i2", item2), ("i3", item3), ("i4", item4),
         ("i5", item5), ("i6", item6), ("i7", item7), ("i8", item8)]


# --------------------------------------------------------------------------- challenge
def _rd_mut(path: str) -> str:
    with open(path, encoding="utf-8", errors="surrogateescape") as f:
        return f.read()


def _wr_mut(path: str, text: str) -> None:
    with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(text)


def break_i4(tree_dir: str) -> str | None:
    """Change exactly one I4 statement text to a wrong count. Returns a label.

    A3 cascade (first applicable wins): coverage-row tip count -> measured+1;
    coverage-row Registry arrow -> landing+1; lesson tip count -> measured+1;
    lesson end-rows -> measured+1; lesson Registry arrow -> landing+1;
    gates.txt attribution -> carried+1. Each injected number is wrong for its
    class on any tree, so a holding I4 always flips to FAIL (value+1) and an
    already-failing I4 stays failing (the challenge cannot fire at BASE)."""
    try:
        src = _rd_mut(os.path.join(tree_dir, "corpus", "SOURCES.md"))
    except OSError:
        return None
    live_wrong = len(S_ROW_RE.findall(src)) + 1
    landing_wrong = LANDING_COUNT + 1
    arrow = re.compile(r"Registry\s+(\d+)\s*→\s*(\d+)")

    def bump_tip(text: str) -> str | None:
        m = TIPCOUNT_RE.search(text)
        if not m:
            return None
        return text[:m.start(1)] + str(live_wrong) + text[m.end(1):]

    sc_path = os.path.join(tree_dir, "SCORECARD.md")
    t = _rd_mut(sc_path)
    m = re.search(POSTMOVE_RE, t, re.M)
    if m:
        m2 = re.compile(r"^## ", re.M).search(t, m.end())
        end = m.end() + m2.start() if m2 else len(t)
        seg = t[m.start():end]
        for ln in seg.splitlines(keepends=True):
            if ln.lstrip().startswith("| coverage"):
                new = bump_tip(ln)
                if new is not None and new != ln:
                    _wr_mut(sc_path, t[:m.start()] + seg.replace(ln, new, 1) + t[end:])
                    return f"coverage-row tip count -> {live_wrong}"
                am = arrow.search(ln)
                if am:
                    new = ln[:am.start(2)] + str(landing_wrong) + ln[am.end(2):]
                    _wr_mut(sc_path, t[:m.start()] + seg.replace(ln, new, 1) + t[end:])
                    return f"coverage-row Registry arrow -> {landing_wrong}"
    les_path = os.path.join(tree_dir, *LESSON_REL.split("/"))
    t = _rd_mut(les_path)
    m = re.search(r"^## Sources\s*$", t, re.M)
    if m:
        m2 = re.compile(r"^## ", re.M).search(t, m.end())
        end = m.end() + m2.start() if m2 else len(t)
        seg = t[m.start():end]
        new = bump_tip(seg)
        if new is not None and new != seg:
            _wr_mut(les_path, t[:m.start()] + new + t[end:])
            return f"lesson tip count -> {live_wrong}"
        em = END_ROWS_RE.search(seg)
        if em:
            new = seg[:em.start(1)] + str(live_wrong) + seg[em.end(1):]
            _wr_mut(les_path, t[:m.start()] + new + t[end:])
            return f"lesson end-rows -> {live_wrong}"
        am = arrow.search(seg)
        if am:
            new = seg[:am.start(2)] + str(landing_wrong) + seg[am.end(2):]
            _wr_mut(les_path, t[:m.start()] + new + t[end:])
            return f"lesson Registry arrow -> {landing_wrong}"
        for ln in seg.splitlines(keepends=True):
            if "gates.txt" in ln and GATES_ROWS_RE.search(ln):
                new = GATES_ROWS_RE.sub(lambda g: f"rows={int(g.group(1)) + 1}", ln, count=1)
                _wr_mut(les_path, t[:m.start()] + seg.replace(ln, new, 1) + t[end:])
                return "gates.txt attribution -> carried+1"
    return None


def parse_value(out: str) -> int | str | None:
    for ln in reversed((out or "").splitlines()):
        if ln.startswith("C1_ROUTED:"):
            m = re.search(r"value=(\d+|FAIL)", ln)
            if m:
                return "FAIL" if m.group(1) == "FAIL" else int(m.group(1))
    return None


def run_challenge(root: str, value: int) -> tuple[bool, str]:
    parent = os.environ.get("C1_CHALLENGE_PARENT") or tempfile.gettempdir()
    root_abs = os.path.realpath(root)
    if os.path.realpath(parent) == root_abs or os.path.realpath(parent).startswith(root_abs + os.sep):
        return False, "challenge scratch resolves inside the measured tree (refused)"
    try:
        tmp = tempfile.mkdtemp(prefix="c1-challenge-", dir=parent)
    except OSError as e:
        return False, f"challenge scratch unavailable: {e}"
    try:
        copy = os.path.join(tmp, "tree")
        shutil.copytree(root, copy, symlinks=True)
        if os.path.realpath(copy) == root_abs:
            return False, "challenge copy resolves to the measured tree (refused)"
        desc = break_i4(copy)
        if desc is None:
            return False, "no I4 statement text found to break"
        r = subprocess.run(
            [sys.executable, "-I", "-B", os.path.abspath(__file__),
             "--root", copy, "--no-challenge"],
            capture_output=True, text=True, timeout=1800)
        v2 = parse_value(r.stdout or "")
        ok = isinstance(v2, int) and v2 == value + 1
        return ok, f"{desc}: broken-copy value={v2} (expect {value + 1})"
    except (OSError, subprocess.SubprocessError, shutil.Error) as e:
        return False, f"challenge failed: {type(e).__name__}: {e}"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# --------------------------------------------------------------------------- evaluate
def measure(root: str) -> dict:
    out = {}
    for key, fn in ITEMS:
        try:
            s, d = fn(root)
        except Exception as e:  # fail closed: an item that cannot be read is not a hold
            s, d = FAIL, f"item raised {type(e).__name__}: {e}"
        out[key] = (s, d)
    return out


def evaluate(root: str, verbose: bool, challenge: bool) -> int:
    res = measure(root)
    toks = {}
    for key, (s, _d) in res.items():
        toks[key] = {"HOLD": "1", "FAIL": "0", "SKIP": "x"}[s]
    population = sum(1 for s, _ in res.values() if s != SKIP)
    skipped = [k for k, (s, _) in res.items() if s == SKIP]
    if verbose:
        for key, (s, d) in res.items():
            print(f"ITEM {key.upper()} {s}: {d}")
    count = sum(1 for s, _ in res.values() if s == FAIL)
    if skipped:
        value_token: str = "FAIL"
        guard = 0
        if verbose:
            print(f"CHALLENGE not run: skipped items {','.join(skipped)}")
    elif challenge:
        ok, desc = run_challenge(root, count)
        guard = 1 if (population == 8 and ok) else 0
        # frozen-predicate semantics: value is the unresolved count ONLY when
        # GUARD = 1; whenever GUARD = 0 the line prints the literal FAIL
        value_token = str(count) if guard == 1 else "FAIL"
        if verbose:
            print(f"CHALLENGE {'ok' if ok else 'FAILED'} (unresolved={count}): {desc}")
    else:
        # diagnostic (--no-challenge) leg: prints the numeric count with guard=0
        # so driver/seed legs can parse value+1 expectations
        guard = 0
        value_token = str(count)
        if verbose:
            print("CHALLENGE not run (--no-challenge); diagnostic count printed")
    line = (f"C1_ROUTED: value={value_token} population={population} "
            + " ".join(f"{k}={toks[k]}" for k, _ in ITEMS)
            + f" guard={guard}")
    print(line)
    return 0 if (guard == 1 and value_token == "0") else 1


# --------------------------------------------------------------------------- selftest
SC_T = """# SC

## Round 57 — post-move (claims C1 calibration, C2 operability)

Candidate: the round-57 landing commit. Freeze epoch C `8d8e0588` (the hardened instruments; receipt
`.ufo/waves/round-57/controls/controls-prefreeze-epochC-final.txt`).

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | [C1] the audited surface agrees with its authorities. | `plans/round-57.md` |
| coverage | 9 → 9 | Registry 114 → 117 (S115, S116, S117); the landing count is 117 and the tip count = 3 (S118/S119 added later); `.ufo/waves/round-57/final/gates.txt` predates S117 and reads `rows=16`. | `corpus/SOURCES.md` |

## Round 58 — pre-move

Claim BASE `1b13f5d`.
"""
LOG_T = """# LG

## Round 57 (2026-11-07) — the round-57 entry

- Names freeze epoch B `03cbf656`; receipt `.ufo/waves/round-57/controls/controls-prefreeze-epochB.txt`.
{correction}
## Round 58 — next round
"""
LOG_CORRECTION = """
## Round 57 correction (2026-11-07, appended in round 58) — freeze epoch C and the epoch-C receipt

- Freeze **epoch C** `8d8e0588`; the 13-control receipt `.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt`, regenerated as `.ufo/waves/round-57/controls/controls-prefreeze-epochC-final.txt`.
"""
LESSON_T = """# Round 57 — lesson

source: S115 (https://openbao.org/docs/audit/); S116 (https://openbao.org/docs/commands/audit/); S117 (https://openbao.org/docs/api/system/audit-hash/), opened 2026-11-07.

## Gate

- **Admit S115** — https://openbao.org/docs/audit/, opened 2026-11-07. Located quote (7 words): “Audit devices must be enabled by a root user.”
  (§Enabling/Disabling audit devices — the live heading).
- **Admit S117** — https://openbao.org/docs/api/system/audit-hash/, opened 2026-11-07. Located quote (9 words): “This endpoint hashes the input data with salt.”
  (§Calculate hash).

## Sources

- Registry 114 → 117 (S115, S116, S117). S117 landed before the round-58 additions, after the `.ufo/waves/round-57/final/gates.txt` capture that reads `rows=16`; the landing count is 117 and the tip count = 3.
- Census: start `kagi ok`, 2 rows; end `kagi ok`, 3 rows.
"""
SOURCES_T = """# Sources

| id | title | kind | tier | claim | context | quote | status | date | recheck | used-by |
|---|---|---|---|---|---|---|---|---|---|---|
| S115 | Audit devices — https://openbao.org/docs/audit/ | docs | A | c | ctx | q | mined | 2026-11-07 | 90d | corpus/lessons/round-57.md |
| S116 | audit command — https://openbao.org/docs/commands/audit/ | docs | A | c | ctx | q | mined | 2026-11-07 | 90d | corpus/lessons/round-57.md |
| S117 | /sys/audit-hash API — https://openbao.org/docs/api/system/audit-hash/ | docs | A | c | ctx | q | mined | 2026-11-07 | on-release | corpus/lessons/round-57.md |
"""
SKILL_T = """# SK

## Gate registry — round-58 additions

| name | kind | entry command | verdict map | selftest | pinned values | write scope | owner |
|---|---|---|---|---|---|---|---|
| current-tense self-description gate (`corpus/current-claims.py`) | gate | `python3 -I -B corpus/current-claims.py [--root DIR] [--round N]` | 0 `CURRENT_CLAIMS: value=0 … guard=1`; 1 value>0 or guard=0; 2 `CURRENT_CLAIMS: SETUP <reason>` | `python3 -I -B corpus/current-claims.py --selftest` prints `CURRENT_CLAIMS_SELFTEST: PASS (N cases)` | plans/round-N.md | reads the measured tree | kagi |
"""
CC_PASS = '''#!/usr/bin/env python3
"""Bind the previous round's numeric self-descriptions to their machine authorities.

EPOCHS `W freeze epochs` -> the distinct `epoch-[A-F]` tokens declared in plans/round-{N}.md.
"""
import argparse, os, re, sys


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--round", type=int, default=57)
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()
    if args.selftest:
        print("CURRENT_CLAIMS_SELFTEST: PASS (1 cases)")
        return 0
    n = args.round
    plan = os.path.join("plans", f"round-{n}.md")
    lesson = os.path.join("corpus", "lessons", f"round-{n}.md")
    heading = re.compile(rf"^## Round {n} ", re.M)
    tokens = set()
    if os.path.isfile(os.path.join(args.root, plan)):
        with open(os.path.join(args.root, plan)) as f:
            tokens = set(re.findall(r"epoch-([A-F])\\b", f.read()))
    ok = False
    cases_bad = 0
    lp = os.path.join(args.root, lesson)
    if os.path.isfile(lp):
        with open(lp) as f:
            txt = f.read()
        ok = bool(heading.search(txt))
        m = re.search(r"--selftest` (\\d+) cases", txt)
        cases_bad = 0 if (m is None or int(m.group(1)) == 20) else 1
    print(f"CURRENT_CLAIMS: value={(0 if tokens and ok else 1) + cases_bad} population=2 "
          f"epochs={len(tokens)} guard=1")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
'''
CC_FAIL_D7 = CC_PASS.replace('f"round-{n}.md"', '"round-56.md"').replace(
    'rf"^## Round {n} "', 'r"^## Round 56 "')
SG_PASS = "#!/usr/bin/env bash\nprintf 'ADJACENCY_SCOPE: CLEAN (stale_basis=0)\\n'\n"
SG_FAIL = "#!/usr/bin/env bash\nprintf 'ADJACENCY_SCOPE: DEFECT (stale_basis=1)\\n'\n"
BODY_T = ("<html><p>This endpoint hashes the given input data with the specified audit device's\n"
          "hash function and salt.</p><p>This endpoint hashes the input data with salt.</p></html>\n")
GATES_T = "== census-end\nkagi\tok\t/path/to/corpus/SOURCES.md\nrows=16\n"


def mkroot(base: str, *, log: str | None = None, sc: str | None = None,
           lesson: str | None = None, skill: str | None = None, cc: str | None = None,
           sg: str | None = None, body: str | None = None,
           corrupt_pin: bool = False, drop_log: bool = False) -> str:
    os.makedirs(os.path.join(base, "corpus", "lessons"), exist_ok=True)
    os.makedirs(os.path.join(base, "plans"), exist_ok=True)
    os.makedirs(os.path.join(base, ".ufo", "waves", "round-57", "controls"), exist_ok=True)
    os.makedirs(os.path.join(base, ".ufo", "waves", "round-57", "final"), exist_ok=True)
    os.makedirs(os.path.join(base, ".ufo", "waves", "round-57", "capture"), exist_ok=True)
    files = {
        "SCORECARD.md": sc if sc is not None else SC_T,
        "corpus/lessons/round-57.md": lesson if lesson is not None else LESSON_T,
        "corpus/SOURCES.md": SOURCES_T,
        "SKILL.md": skill if skill is not None else SKILL_T,
        "corpus/current-claims.py": cc if cc is not None else CC_PASS,
        "corpus/scope-gate.sh": sg if sg is not None else SG_PASS,
        "corpus/recheck-captures.tsv": "id\turl\nS001\thttps://e/1\n",
        "plans/round-57.md": "# plan round 57 (epoch A epoch-B epoch-C)\n",
        "plans/round-57-c1.sh": "#!/usr/bin/env bash\n# c1 driver\n",
        "plans/round-57-c2.sh": "#!/usr/bin/env bash\n# c2 driver\n",
        "plans/round-57-controls.sh": "#!/usr/bin/env bash\n# controls\n",
        "plans/round-57-c1-check.py": "#!/usr/bin/env python3\n# checker\n",
        ".ufo/waves/round-57/final/gates.txt": GATES_T,
        ".ufo/waves/round-57/capture/S117.body": body if body is not None else BODY_T,
        ".ufo/waves/round-57/controls/controls-prefreeze-epochC.txt": (
            "INSTRUMENT " + "b130" + "0" * 60 + " plans/round-57.md\n"
            "CONTROL K1-BASE expect=8 got=8 MATCH\nCONTROLS: match=13 mismatch=0\n"),
    }
    if not drop_log:
        files["LOG.md"] = log if log is not None else LOG_T.format(correction=LOG_CORRECTION)
    for rel, txt in files.items():
        with open(os.path.join(base, rel), "w", encoding="utf-8") as f:
            f.write(txt)
    pins = []
    for rel in INSTRUMENT_FILES:
        digest = hashlib.sha256(open(os.path.join(base, rel), "rb").read()).hexdigest()
        if corrupt_pin and rel == "plans/round-57-c1.sh":
            digest = "a" * 64
        pins.append(f"INSTRUMENT {digest} {rel}")
    pins.append("CONTROL K1-BASE expect=8 got=8 MATCH")
    pins.append("CONTROLS: match=15 mismatch=0")
    with open(os.path.join(
            base, ".ufo/waves/round-57/controls/controls-prefreeze-epochC-final.txt"),
            "w", encoding="utf-8") as f:
        f.write("\n".join(pins) + "\n")
    return base


def run_selftest() -> int:
    top = tempfile.mkdtemp(prefix="c1-check-selftest-")
    cases = 0
    failures: list[str] = []

    def case(name: str, cond: bool) -> None:
        nonlocal cases
        cases += 1
        if not cond:
            failures.append(name)

    def hold(fn, root) -> bool:
        return fn(root)[0] == HOLD

    def fail(fn, root) -> bool:
        return fn(root)[0] == FAIL

    try:
        clean = mkroot(os.path.join(top, "clean"))
        for key, fn in ITEMS:
            case(f"hold-{key}", hold(fn, clean))
        res = measure(clean)
        pop = sum(1 for s, _ in res.values() if s != SKIP)
        val = sum(1 for s, _ in res.values() if s == FAIL)
        case("aggregate-clean-value0-pop8", val == 0 and pop == 8)

        r = mkroot(os.path.join(top, "f1-no-epochC-in-log"),
                   log=LOG_T.format(correction=""))
        case("fail-i1", fail(item1, r))
        r = mkroot(os.path.join(top, "f2-bad-pin"), corrupt_pin=True)
        case("fail-i2", fail(item2, r))
        r = mkroot(os.path.join(top, "f3-quote-not-in-body"),
                   body=BODY_T.replace("This endpoint hashes the input data with salt.",
                                       "Completely different words appear here instead."))
        case("fail-i3", fail(item3, r))
        r = mkroot(os.path.join(top, "f4-wrong-count"),
                   sc=SC_T.replace("the tip count = 3", "the tip count = 4"))
        case("fail-i4", fail(item4, r))
        r = mkroot(os.path.join(top, "f5-no-selftest-token"),
                   skill=SKILL_T.replace("`python3 -I -B corpus/current-claims.py --selftest` "
                                         "prints `CURRENT_CLAIMS_SELFTEST: PASS (N cases)`",
                                         "`python3 -I -B corpus/current-claims.py` "
                                         "prints `CURRENT_CLAIMS_SELFTEST: PASS (N cases)`"))
        case("fail-i5", fail(item5, r))
        r = mkroot(os.path.join(top, "f6-hardcoded-round56"), cc=CC_FAIL_D7)
        case("fail-i6", fail(item6, r))
        r = mkroot(os.path.join(top, "f7-stale-heading"),
                   lesson=LESSON_T.replace("§Enabling/Disabling audit devices",
                                           "§Enabling and disabling audit devices"))
        case("fail-i7", fail(item7, r))
        r = mkroot(os.path.join(top, "f8-stale-basis"), sg=SG_FAIL)
        case("fail-i8", fail(item8, r))
        r = mkroot(os.path.join(top, "f9-no-log"), drop_log=True)
        res = measure(r)
        pop = sum(1 for s, _ in res.values() if s != SKIP)
        case("skip-i1-value-FAIL-pop7",
             res["i1"][0] == SKIP and pop == 7 and sum(1 for s, _ in res.values() if s == FAIL) >= 0
             and any(s == SKIP for s, _ in res.values()))
    finally:
        shutil.rmtree(top, ignore_errors=True)
    if failures:
        print(f"C1_CHECK_SELFTEST: FAIL ({cases - len(failures)}/{cases} cases) "
              f"failed={','.join(failures)}")
        return 1
    print(f"C1_CHECK_SELFTEST: PASS ({cases} cases)")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--root", default=".", help="measured tree (default: cwd)")
    ap.add_argument("--verbose", action="store_true", help="per-item detail lines")
    ap.add_argument("--selftest", action="store_true",
                    help="synthetic-root selftest under TMPDIR")
    ap.add_argument("--no-challenge", action="store_true", help=argparse.SUPPRESS)
    args = ap.parse_args()
    if args.selftest:
        return run_selftest()
    root = os.path.abspath(args.root)
    if not os.path.isdir(root):
        print(f"C1_ROUTED: SETUP no-root {root}")
        return 2
    return evaluate(root, args.verbose, challenge=not args.no_challenge)


if __name__ == "__main__":
    raise SystemExit(main())
