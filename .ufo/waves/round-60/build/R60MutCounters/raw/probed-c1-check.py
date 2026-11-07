#!/usr/bin/env python3
r"""plans/round-60-c1-check.py — the C1_ROUTED counter (kagi round 60).

Freezes plans/round-60.md §C1 (predeclaration commit cd631737; claim BASE
a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2), as amended by §A5 (commit b662e114,
six attack-seat item defects, none easier):

    C1_ROUTED: value = the number of UNRESOLVED items over POP = 7 fixed routed-defect
    items (I1..I7), when GUARD = 1, else FAIL; target 0 (BASE 7).
    An item is UNRESOLVED iff its named condition does not hold on the measured tree.
    GUARD = 1 iff the checker evaluates all seven items (prints population=7 with
    i1..i7 each 0|1, none skipped) and, on a copy of the measured tree whose only delta
    is the digit in the I1 correction line's `dead seats=<n>` field changed from 0 to 1,
    prints exactly value+1, and a printer stub that always prints value=0 fails that same
    challenge.

Every number an item compares is derived at run time from the measured tree; no
constant below carries a fact the measured tree asserts. The literals that remain are
the frozen predicate's own anchors (file paths, `R31`, `SCORECARD.md:1971`, `21 controls`,
the heading/phrase literals), not derived facts.

Frozen-condition readings taken where the plan wording allowed more than one structural
read (each is the code's behaviour, named here so a reviewer can disagree precisely):

  - I1 block geometry. "AFTER its last line containing the literal __DEAD__" selects the
    last `__DEAD__` line; a "block whose first line matches `^## Round 59 — correction`"
    runs from that heading to the next `^## ` heading (or EOF). Because §C1's correction
    convention is "last occurrence wins", the LAST such block after the anchor is the one
    evaluated. A `results=` line in a later `## ` section is outside the block and does
    not count. The block must name `w1-results.json`.
  - I1 last statement wins (§A5 1). Inside the evaluated block the LAST line matching the
    SHAPE `results=<R> dead=<D>` is the statement under test, and ITS values must equal
    the derived census; a later wrong restatement in the same block therefore breaks the
    item (control C1-F1's class).
  - I1 derivation. R = len(.ufo/waves/round-59/w1-results.json["results"]); D = how many
    of those results have an empty or absent `output` string. Missing/malformed JSON
    leaves I1 UNRESOLVED (fail closed, never a silent 0).
  - I1 line format. The item literal `results=<R> dead=<D>` and the GUARD literal
    `dead seats=<n>` are reconciled by reading the dead-seats count tolerantly: the
    correction line must match `results=<R>` followed by `dead=` or `dead seats=` and
    the derived D. The numeric comparison (R and D equal to the derived census) is
    unchanged; only the label around the dead count is flexible.
  - I2 anchor (§A5 2). The anchor is the LAST line whose first table cell is the routed
    id `R31` (row regex `^\| *R31 *\|`), not any earlier mention of the string; the
    statement under test is the LAST line after that anchor naming `C1_CHECK_SELFTEST`,
    and it must still match `supersedes R31` and state the derived case count.
  - I2 derivation. The case count is the N of the LAST
    `C1_CHECK_SELFTEST: PASS (N cases)` line of
    .ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt (BASE 33).
  - I4 "last occurrence wins". The anchor is the LAST line matching `\(21 controls`; the
    statement is the LAST later line matching `supersedes SCORECARD.md:1971` and it must
    state the derived N immediately followed by `controls` (e.g. "20 controls"). A later
    wrong restatement breaks the item.
  - I5. The LAST line matching `supersedes the round-59 gate-evidence pointer` must
    (a) name three DISTINCT repo-relative paths under `.ufo/waves/round-60/final/` whose
    basenames contain `release-clock`, `doc-audit` and `scope` respectively, (b) each
    named file exist in the measured tree (never a symlink) with its last non-empty line
    carrying its token prefix (`RELEASE_CLOCK:`, `DOC_AUDIT:`, `ADJACENCY_SCOPE:` — the
    scope gate's own verdict token, §A6) AND at least one
    numeric `key=value` field (§A5 3: a one-line stub fails), and (c) state `never
    written`. Path containment under `.ufo/waves/round-60/final/` is enforced.
  - I6 anchor (§A5 4). The item requires a line matching `supersedes the round-59
    measured-commit citation` that names `c1-landed.txt` and states
    `measured=revision <40hex>` equal to the value derived from the receipt's own
    `c1-driver: measured=revision` line. (The first-written `75165a07` anchor was
    unsatisfiable at BASE and is gone.)
  - I7 (§A5 5). Three legs, all required: (A) `bash <tree>/corpus/openbao-transit-trial.sh
    --selftest` (cwd=<tree>, short timeout) exits 0 with a `TRANSIT_SELFTEST: PASS
    (cases=N)` line, N >= 6; (B) the SKILL.md gate-registry row (found by column name,
    LAST row whose name cell contains the script) carries `--selftest` in its selftest
    cell and no longer carries `none — its own five shims`; (C) a copy of the trial with
    the single defined mutation `then S=BROKEN; rc=1;` -> `then S=BROKEN; rc=0;` (the
    needle must occur exactly once — 0 or more than 1 fails closed) must exit non-zero
    and print at least one `FINDING TRANSIT-ST-` line. A missing script, a timeout, a
    non-zero exit, N < 6, an absent needle or an undetected mutation leaves I7
    UNRESOLVED (never SETUP).
  - Symlink refusal (§A5 6). A tree whose LOG.md, lesson, SCORECARD.md or one of the four
    read receipts is a symlink is refused with SETUP rc 2; item5 additionally refuses a
    symlinked named receipt (item UNRESOLVED).
  - GUARD challenge delta (the frozen GUARD literal and the item literal name the same
    field). The frozen GUARD text says the mutated field is "the I1 correction line's
    `dead seats=<n>` field"; item I1's condition writes the line as `results=<R>
    dead=<D>`. The checker reads the dead-seats count tolerantly (see the I1
    line-format reading) and the challenge changes that digit from D to D+1
    (0 -> 1 at the round-59 census) on the evaluated (LAST) I1 correction line,
    preserving the line's `dead=` or `dead seats=` label, and nothing else. A strict
    `dead=`-only item reading would leave a guard-conforming `dead seats=` correction
    line unresolved and the challenge un-fireable; the tolerant reading changes no
    numeric comparison. Recorded here and in checker-notes.md.
  - A tree missing an item's input file reads the item UNRESOLVED (population stays 7);
    GUARD then reads 0 because the challenge cannot inject its delta.
  - QM74: a challenge scratch resolving at/inside the measured root is refused with
    SETUP rc 2 (checked on every evaluation — item I7's mutation leg and the GUARD share
    the scratch); a scratch that cannot be created leaves GUARD = 0 / the I7 mutation leg
    UNRESOLVED (fail closed), it never fakes a pass. The challenge copy materialises
    symlinks (`copytree symlinks=False`, the round-59 routed R22/M58-3 class) so no
    mutation ever writes through a symlink to a file outside the copy.

Usage:
    python3 -I -B plans/round-60-c1-check.py --root <tree> [--repo <lane>]
                                             [--no-challenge] [--json] [--verbose]
                                             [--selftest]
Output: one `c1:` evidence line per item, then
    C1_ROUTED: value=<V|FAIL> population=7 i1=<0|1> … i7=<0|1> guard=<0|1>
(--no-challenge prints the diagnostic unresolved count as V with guard=0; --json prints
one JSON object instead.)  Exit 0 iff guard=1 and value=0; 1 otherwise; 2 SETUP.
"""
from __future__ import annotations

import argparse
import contextlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

LOG_REL = "LOG.md"
SCORECARD_REL = "SCORECARD.md"
SKILL_REL = "SKILL.md"
LESSON59_REL = "corpus/lessons/round-59.md"
LESSON60_REL = "corpus/lessons/round-60.md"
RESULTS_REL = ".ufo/waves/round-59/w1-results.json"
SELFTEST59_REL = ".ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt"
CONTROLS59_REL = ".ufo/waves/round-59/controls/controls-prefreeze.txt"
CLANDED_REL = ".ufo/waves/round-59/final/c1-landed.txt"
TRANSIT_REL = "corpus/openbao-transit-trial.sh"
FINAL_PREFIX = ".ufo/waves/round-60/final/"

POP = 7
SELFTEST_TIMEOUT = 90
HOLD, FAIL = "HOLD", "FAIL"

DEAD_LITERAL = "__DEAD__"
CORRECTION_HEADING_RE = re.compile(r"^## Round 59 — correction")
H2_RE = re.compile(r"^## ")
RESULTS_LINE_RE = re.compile(r"results=(\d+)(\s+)(dead(?:\s+seats)?=)(\d+)")
SELFTEST_PASS_RE = re.compile(r"C1_CHECK_SELFTEST:\s*PASS\s*\(\s*(\d+)\s+cases\s*\)")
ROUTED_HEADING_RE = re.compile(r"^##\s+Routed dispositions")
ID_TOKEN_RE = re.compile(r"R\d+")
SEPARATOR_CELL_RE = re.compile(r":?-{3,}:?")
CONTROLS21_RE = re.compile(r"\(21 controls")
SUPERSEDES_1971_RE = re.compile(r"(?i:supersedes)\s+SCORECARD\.md:1971")
SUPERSEDES_R31_RE = re.compile(r"(?i:supersedes)\s+R31\b")
GATE_EVIDENCE_RE = re.compile(r"(?i:supersedes\s+the\s+round-59\s+gate-evidence\s+pointer)")
NEVER_WRITTEN_RE = re.compile(r"(?i)never\s+written")
DUPLICATE_RE = re.compile(r"(?i)duplicate")
FINAL_PATH_RE = re.compile(r"\.ufo/waves/round-60/final/[^\s`'\"|)]+")
MEASURED_REV_RE = re.compile(r"c1-driver:\s*measured=revision\s+([0-9a-f]{40})")
TRANSIT_PASS_RE = re.compile(r"TRANSIT_SELFTEST:\s*PASS\s*\(\s*cases=(\d+)\s*\)")
GATE_REG_HEADING_RE = re.compile(r"^#{2,3}\s+.*[Gg]ate registry")
NONE_SHIMS_LITERAL = "none — its own five shims"
ANCHOR_R31_RE = re.compile(r"^\| *R31 *\|")
SUPERSEDES_MC_RE = re.compile(
    r"(?i:supersedes\s+the\s+round-59\s+measured-commit\s+citation)")
RECEIPT_FIELD_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*=\d+")
FINDING_RE = re.compile(r"FINDING\s+TRANSIT-ST-")
ST_NEEDLE = "then S=BROKEN; rc=1;"
ST_MUTATED = "then S=BROKEN; rc=0;"
_SYMLINK_REFUSAL_RELS = (LOG_REL, LESSON59_REL, LESSON60_REL, SCORECARD_REL,
                         RESULTS_REL, SELFTEST59_REL, CONTROLS59_REL, CLANDED_REL)


class SetupError(Exception):
    """Instrument cannot run (bad root, challenge scratch inside the measured root).
    Exit 2."""


# --------------------------------------------------------------------------- plumbing
def rd(root: str, rel: str) -> str | None:
    try:
        with open(os.path.join(root, *rel.split("/")), encoding="utf-8",
                  errors="surrogateescape") as f:
            return f.read()
    except OSError:
        return None


def last_nonempty_line(text: str | None) -> str | None:
    for ln in reversed((text or "").splitlines()):
        if ln.strip():
            return ln.strip()
    return None


def _rd_mut(path: str) -> str:
    with open(path, encoding="utf-8", errors="surrogateescape") as f:
        return f.read()


def _wr_mut(path: str, text: str) -> None:
    with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(text)


# --------------------------------------------------------------------------- derivations
def derive_results_counts(root: str) -> tuple[int, int]:
    """R = number of results in .ufo/waves/round-59/w1-results.json; D = how many have
    an empty or absent final `output`. Raises LookupError (fail closed)."""
    txt = rd(root, RESULTS_REL)
    if txt is None:
        raise LookupError("w1-results.json missing")
    try:
        data = json.loads(txt)
    except json.JSONDecodeError as e:
        raise LookupError(f"w1-results.json malformed: {e}") from e
    results = data.get("results") if isinstance(data, dict) else data
    if not isinstance(results, list):
        raise LookupError("w1-results.json has no results list")
    r_count = len(results)
    d_count = 0
    for r in results:
        out = r.get("output") if isinstance(r, dict) else None
        if out is None or not str(out).strip():
            d_count += 1
    return r_count, d_count


def derive_selftest_cases(root: str) -> int:
    """N of the LAST `C1_CHECK_SELFTEST: PASS (N cases)` line of the round-59 counter's
    committed selftest receipt. Raises LookupError."""
    txt = rd(root, SELFTEST59_REL)
    if txt is None:
        raise LookupError("round-59 selftest receipt missing")
    for ln in reversed(txt.splitlines()):
        m = SELFTEST_PASS_RE.search(ln)
        if m:
            return int(m.group(1))
    raise LookupError("no C1_CHECK_SELFTEST: PASS (N cases) line")


def derive_control_count(root: str) -> int:
    """`grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt`.
    Raises LookupError."""
    txt = rd(root, CONTROLS59_REL)
    if txt is None:
        raise LookupError("round-59 controls receipt missing")
    return sum(1 for ln in txt.splitlines() if ln.startswith("CONTROL "))


def derive_measured_rev(root: str) -> str:
    """The 40-hex revision on the LAST `c1-driver: measured=revision` line of
    .ufo/waves/round-59/final/c1-landed.txt. Raises LookupError."""
    txt = rd(root, CLANDED_REL)
    if txt is None:
        raise LookupError("c1-landed.txt missing")
    for ln in reversed(txt.splitlines()):
        m = MEASURED_REV_RE.search(ln)
        if m:
            return m.group(1)
    raise LookupError("no c1-driver: measured=revision <40hex> line")


# --------------------------------------------------------------------------- items
def _i1_blocks(lines: list[str], dead_idx: int):
    """Yield (start, end) for each `## Round 59 — correction` block after dead_idx;
    a block runs to the next `^## ` heading or EOF."""
    i = dead_idx + 1
    while i < len(lines):
        if CORRECTION_HEADING_RE.match(lines[i]):
            start = i
            end = len(lines)
            for j in range(start + 1, len(lines)):
                if H2_RE.match(lines[j]):
                    end = j
                    break
            yield start, end
            i = end
        else:
            i += 1


def item1(root: str) -> tuple[str, str]:
    log = rd(root, LOG_REL)
    if log is None:
        return FAIL, "LOG.md missing"
    lines = log.splitlines()
    dead_idx = None
    for i, ln in enumerate(lines):
        if DEAD_LITERAL in ln:
            dead_idx = i
    if dead_idx is None:
        return FAIL, "no line containing __DEAD__ in LOG.md"
    try:
        r_count, d_count = derive_results_counts(root)
    except LookupError as e:
        return FAIL, f"results census not derived: {e}"
    blocks = list(_i1_blocks(lines, dead_idx))
    if not blocks:
        return FAIL, "no '## Round 59 — correction' block after the last __DEAD__ line"
    # last occurrence wins: the LAST correction block is the evaluated one
    start, end = blocks[-1]
    block = lines[start:end]
    names_json = any("w1-results.json" in ln for ln in block)
    shape = None
    for ln in block:
        m = RESULTS_LINE_RE.search(ln)
        if m:
            shape = m  # the LAST `results=<R> dead=<D>` line wins (§A5 1)
    ok = (names_json and shape is not None
          and int(shape.group(1)) == r_count and int(shape.group(4)) == d_count)
    det = (f"blocks={len(blocks)} results={r_count} dead={d_count} "
           f"names_w1-results={'yes' if names_json else 'no'} "
           f"last-shape-line={'match' if ok else 'no-match-or-wrong-values'}")
    return (HOLD if ok else FAIL), det


def item2(root: str) -> tuple[str, str]:
    lesson = rd(root, LESSON59_REL)
    if lesson is None:
        return FAIL, "round-59 lesson missing"
    try:
        cases = derive_selftest_cases(root)
    except LookupError as e:
        return FAIL, f"selftest case count not derived: {e}"
    lines = lesson.splitlines()
    anchor = None
    for i, ln in enumerate(lines):
        if ANCHOR_R31_RE.match(ln):
            anchor = i  # the LAST routed `R31` row wins (§A5 2)
    if anchor is None:
        return FAIL, "no routed row '| R31 |' in the round-59 lesson"
    candidates = []
    for ln in lines[anchor + 1:]:
        if "C1_CHECK_SELFTEST" in ln:
            candidates.append(ln)
    hit = None
    if candidates:
        last = candidates[-1]
        if (SUPERSEDES_R31_RE.search(last)
                and cases in [int(x) for x in re.findall(r"\d+", last)]):
            hit = last
    det = (f"derived cases={cases} anchor-row={'found' if anchor is not None else 'none'} "
           f"selftest-lines-after={len(candidates)} "
           f"last-line={'supersedes+count' if hit else 'missing-supersedes-or-wrong-count'}")
    return (HOLD if hit else FAIL), det


def item3(root: str) -> tuple[str, str]:
    lesson = rd(root, LESSON60_REL)
    if lesson is None:
        return FAIL, "corpus/lessons/round-60.md missing"
    lines = lesson.splitlines()
    start = None
    for i, ln in enumerate(lines):
        if ROUTED_HEADING_RE.match(ln):
            start = i
            break
    if start is None:
        return FAIL, "no '## Routed dispositions' heading in the round-60 lesson"
    # the section's first contiguous table (rows starting with '|')
    table: list[str] = []
    seen = False
    for ln in lines[start + 1:]:
        if H2_RE.match(ln):
            break
        s = ln.strip()
        if s.startswith("|"):
            seen = True
            table.append(s)
        elif seen:
            break
    ids: list[str] = []
    for row in table[1:]:  # skip the header row
        cells = [c.strip() for c in row.strip("|").split("|")]
        if not cells:
            continue
        if all(SEPARATOR_CELL_RE.fullmatch(c) for c in cells if c):
            continue
        ids.extend(ID_TOKEN_RE.findall(cells[0]))
    distinct = sorted(set(ids))
    max_occ = max((ids.count(i) for i in distinct), default=0)
    a_ok = len(distinct) >= 3 and max_occ == 1
    b_ok = any("R20" in ln and "R21" in ln and "R22" in ln and DUPLICATE_RE.search(ln)
               for ln in lines)
    det = (f"routed ids distinct={len(distinct)} max_occ={max_occ} "
           f"R20/R21/R22-duplicate-line={'yes' if b_ok else 'no'}")
    return (HOLD if (a_ok and b_ok) else FAIL), det


def item4(root: str) -> tuple[str, str]:
    sc = rd(root, SCORECARD_REL)
    if sc is None:
        return FAIL, "SCORECARD.md missing"
    try:
        n = derive_control_count(root)
    except LookupError as e:
        return FAIL, f"control census not derived: {e}"
    lines = sc.splitlines()
    anchor = None
    for i, ln in enumerate(lines):
        if CONTROLS21_RE.search(ln):
            anchor = i
    if anchor is None:
        return FAIL, "no SCORECARD line matching '(21 controls'"
    candidates = [ln for ln in lines[anchor + 1:] if SUPERSEDES_1971_RE.search(ln)]
    hit = None
    if candidates:
        last = candidates[-1]
        if re.search(rf"(?<!\d){n}\s+controls\b", last):
            hit = last
    det = (f"derived controls={n} supersedes-candidates={len(candidates)} "
           f"last-line={'states-count' if hit else 'missing-or-wrong-count'}")
    return (HOLD if hit else FAIL), det


_FINAL_KEYS = ("release-clock", "doc-audit", "scope")
_FINAL_PREFIXES = {"release-clock": "RELEASE_CLOCK:", "doc-audit": "DOC_AUDIT:",
                   "scope": "ADJACENCY_SCOPE:"}


def item5(root: str) -> tuple[str, str]:
    sc = rd(root, SCORECARD_REL)
    if sc is None:
        return FAIL, "SCORECARD.md missing"
    lines = sc.splitlines()
    anchor = None
    for i, ln in enumerate(lines):
        if GATE_EVIDENCE_RE.search(ln):
            anchor = i
    if anchor is None:
        return FAIL, "no 'supersedes the round-59 gate-evidence pointer' line"
    ln = lines[anchor]  # last occurrence wins (only one anchor: the last match)
    paths = [p.rstrip(",;:.") for p in FINAL_PATH_RE.findall(ln)]
    chosen: dict[str, str] = {}
    for p in paths:
        base = p.rsplit("/", 1)[-1].lower()
        for key in _FINAL_KEYS:
            if key in base and key not in chosen:
                chosen[key] = p
    problems: list[str] = []
    if set(chosen) != set(_FINAL_KEYS):
        problems.append(f"missing-keys={sorted(set(_FINAL_KEYS) - set(chosen))}")
    elif len(set(chosen.values())) != 3:
        problems.append("paths-not-distinct")
    else:
        final_real = os.path.realpath(os.path.join(root, *FINAL_PREFIX.split("/")))
        for key, p in chosen.items():
            full = os.path.join(root, *p.split("/"))
            if os.path.islink(full):
                problems.append(f"{key}:symlinked-receipt")
                continue
            real = os.path.realpath(full)
            if not (real == final_real or real.startswith(final_real + os.sep)):
                problems.append(f"{key}:path-escapes-final-dir")
                continue
            txt = rd(root, p)
            if txt is None:
                problems.append(f"{key}:missing-file")
                continue
            last = last_nonempty_line(txt)
            if last is None or not last.startswith(_FINAL_PREFIXES[key]):
                problems.append(f"{key}:last-line-prefix")
            elif not RECEIPT_FIELD_RE.search(last):
                problems.append(f"{key}:no-numeric-key-value")
    never = bool(NEVER_WRITTEN_RE.search(ln))
    if not never:
        problems.append("never-written-missing")
    det = (f"paths={ {k: v.rsplit('/', 1)[-1] for k, v in chosen.items()} } "
           f"problems={problems or 'none'}")
    return (HOLD if not problems else FAIL), det


def item6(root: str) -> tuple[str, str]:
    sc = rd(root, SCORECARD_REL)
    if sc is None:
        return FAIL, "SCORECARD.md missing"
    try:
        rev = derive_measured_rev(root)
    except LookupError as e:
        return FAIL, f"measured revision not derived: {e}"
    lines = sc.splitlines()
    anchor = None
    for i, ln in enumerate(lines):
        if SUPERSEDES_MC_RE.search(ln):
            anchor = i  # last occurrence wins
    if anchor is None:
        return FAIL, "no 'supersedes the round-59 measured-commit citation' line"
    ln = lines[anchor]
    want = f"measured=revision {rev}"
    ok = "c1-landed.txt" in ln and want in ln
    det = (f"derived rev={rev} "
           f"line={'names-receipt-and-states-rev' if ok else 'missing-receipt-or-wrong-rev'}")
    return (HOLD if ok else FAIL), det


def _gate_registry_sections(lines: list[str]) -> list[tuple[int, int]]:
    out = []
    for i, ln in enumerate(lines):
        if GATE_REG_HEADING_RE.match(ln):
            end = len(lines)
            for j in range(i + 1, len(lines)):
                if re.match(r"^## ", lines[j]):
                    end = j
                    break
            out.append((i, end))
    return out


def _scan_registry_table(block: list[str]):
    """block = contiguous '|' lines of one table. Returns (line, cells, self_idx) for
    the first data row whose NAME cell contains the transit script, else None."""
    parsed = []
    for ln in block:
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        parsed.append((ln, cells))
    if len(parsed) < 2:
        return None
    header = parsed[0][1]
    try:
        name_idx = next(i for i, c in enumerate(header) if c.lower() == "name")
        self_idx = next(i for i, c in enumerate(header) if c.lower() == "selftest")
    except StopIteration:
        return None
    for ln, cells in parsed[1:]:
        if all(SEPARATOR_CELL_RE.fullmatch(c) for c in cells if c) and cells:
            continue
        if name_idx < len(cells) and "openbao-transit-trial.sh" in cells[name_idx]:
            return ln, cells, self_idx
    return None


def find_registry_row(text: str):
    """The LAST gate-registry table row whose name cell contains the transit script.
    Returns (raw_line, cells, selftest_col_index) or None."""
    lines = text.splitlines()
    last = None
    for (s, e) in _gate_registry_sections(lines):
        i = s
        while i < e:
            if lines[i].strip().startswith("|"):
                j = i
                block = []
                while j < e and lines[j].strip().startswith("|"):
                    block.append(lines[j])
                    j += 1
                row = _scan_registry_table(block)
                if row is not None:
                    last = row
                i = j
            else:
                i += 1
    return last


def _transit_mutation_leg(root: str, script: str) -> tuple[bool, str]:
    """§A5 5 leg C: copy the trial, apply the one defined mutation (`then S=BROKEN;
    rc=1;` -> `then S=BROKEN; rc=0;`, the needle must occur exactly once) and require
    the copy's --selftest to exit non-zero printing >=1 `FINDING TRANSIT-ST-` line.
    Any absence, ambiguity, timeout or undetected mutation fails closed."""
    if not os.path.isfile(script):
        return False, "transit trial script missing"
    try:
        with open(script, encoding="utf-8", errors="surrogateescape") as f:
            text = f.read()
    except OSError as e:
        return False, f"trial unreadable: {e}"
    n = text.count(ST_NEEDLE)
    if n != 1:
        return False, f"mutation needle count={n} (expected exactly 1)"
    root_abs = os.path.realpath(root)
    par_abs = os.path.realpath(challenge_parent())
    if par_abs == root_abs or par_abs.startswith(root_abs + os.sep):
        raise SetupError(f"challenge scratch {par_abs} resolves at/inside the measured "
                         f"root {root_abs} (refused, QM74)")
    try:
        os.makedirs(par_abs, exist_ok=True)
        tmp = tempfile.mkdtemp(prefix="c1-st-mut-", dir=par_abs)
    except OSError as e:
        return False, f"mutation scratch unavailable: {e}"
    try:
        mutated = os.path.join(tmp, "trial.sh")
        with open(mutated, "w", encoding="utf-8", errors="surrogateescape") as f:
            f.write(text.replace(ST_NEEDLE, ST_MUTATED))
        try:
            r2 = subprocess.run(["bash", mutated, "--selftest"], cwd=tmp,
                                capture_output=True, text=True,
                                timeout=SELFTEST_TIMEOUT)
        except subprocess.TimeoutExpired:
            return False, f"mutated --selftest timeout {SELFTEST_TIMEOUT}s"
        except OSError as e:
            return False, f"mutated --selftest could not run: {e}"
        out = (r2.stdout or "") + "\n" + (r2.stderr or "")
        finding = bool(FINDING_RE.search(out))
        ok = r2.returncode != 0 and finding
        return ok, f"mutated rc={r2.returncode} finding={'yes' if finding else 'no'}"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def item7(root: str) -> tuple[str, str]:
    # leg A: execute the trial's own --selftest from the measured tree
    script = os.path.join(root, *TRANSIT_REL.split("/"))
    if not os.path.isfile(script):
        a_ok, a_det = False, "transit trial script missing"
    else:
        try:
            r = subprocess.run(["bash", script, "--selftest"], cwd=root,
                               capture_output=True, text=True,
                               timeout=SELFTEST_TIMEOUT)
        except subprocess.TimeoutExpired:
            a_ok, a_det = False, f"--selftest timeout {SELFTEST_TIMEOUT}s"
        except OSError as e:
            a_ok, a_det = False, f"--selftest could not run: {e}"
        else:
            out = (r.stdout or "") + "\n" + (r.stderr or "")
            m = None
            for ln in reversed(out.splitlines()):
                mm = TRANSIT_PASS_RE.search(ln)
                if mm:
                    m = mm
                    break
            n = int(m.group(1)) if m else None
            a_ok = r.returncode == 0 and n is not None and n >= 6
            a_det = (f"rc={r.returncode} cases={n} "
                     f"{'PASS-line' if m else 'no-PASS-line'}")
    # leg B: SKILL.md gate-registry row
    sk = rd(root, SKILL_REL)
    if sk is None:
        b_ok, b_det = False, "SKILL.md missing"
    else:
        row = find_registry_row(sk)
        if row is None:
            b_ok, b_det = False, "no gate-registry row naming corpus/openbao-transit-trial.sh"
        else:
            line, cells, self_idx = row
            cell = cells[self_idx] if self_idx < len(cells) else ""
            b_ok = ("--selftest" in cell and NONE_SHIMS_LITERAL not in line)
            b_det = (f"selftest-cell={cell.strip()[:48]!r} "
                     f"none-shims={'absent' if NONE_SHIMS_LITERAL not in line else 'present'}")
    # leg C (§A5 5): the selftest must be shown able to fail
    c_ok, c_det = _transit_mutation_leg(root, script)
    det = f"selftest[{a_det}] registry[{b_det}] mutation[{c_det}]"
    return (HOLD if (a_ok and b_ok and c_ok) else FAIL), det


ITEMS = (("i1", item1), ("i2", item2), ("i3", item3), ("i4", item4),
         ("i5", item5), ("i6", item6), ("i7", item7))


# --------------------------------------------------------------------------- guard
def challenge_parent() -> str:
    raw = os.environ.get("C1_CHALLENGE_PARENT")
    if raw:
        return raw
    hs = os.environ.get("HYAKU_SCRATCH")
    if hs:
        return os.path.join(hs, "kagi-r60", "R60ExecCounterC1")
    if os.environ.get("TMPDIR"):
        return os.environ["TMPDIR"]
    return os.path.join("/fast/scratch/hyaku", "kagi-r60", "R60ExecCounterC1")


def mutate_i1_dead(tree_dir: str) -> tuple[str | None, str | None]:
    """The challenge's ONLY delta: in the evaluated (LAST) I1 correction block of the
    copy's LOG.md, the evaluated (LAST) line matching the `results=<R> dead=<D>` shape
    has its dead-seats digit changed D -> D+1 (0 -> 1 at the round-59 census; §A5 1
    last-statement-wins). See the docstring's GUARD note for the label forms."""
    try:
        r_count, d_count = derive_results_counts(tree_dir)
    except LookupError as e:
        return None, f"results census not derivable in copy: {e}"
    path = os.path.join(tree_dir, *LOG_REL.split("/"))
    try:
        text = _rd_mut(path)
    except OSError as e:
        return None, f"LOG.md unreadable in copy: {e}"
    lines = text.splitlines(keepends=True)
    dead_idx = None
    for i, ln in enumerate(lines):
        if DEAD_LITERAL in ln:
            dead_idx = i
    if dead_idx is None:
        return None, "no __DEAD__ line in copy"
    blocks = list(_i1_blocks([ln.rstrip("\n") for ln in lines], dead_idx))
    if not blocks:
        return None, "no '## Round 59 — correction' block in copy"
    start, end = blocks[-1]
    target = None
    for i in range(start, end):
        if RESULTS_LINE_RE.search(lines[i]):
            target = i  # the evaluated (LAST) `results=<R> dead=<D>` line (§A5 1)
    if target is None:
        return None, "no results=<R> dead=<D> line in the evaluated correction block"

    def repl(m: re.Match) -> str:
        return f"results={m.group(1)}{m.group(2)}{m.group(3)}{d_count + 1}"

    lines[target] = RESULTS_LINE_RE.sub(repl, lines[target])
    _wr_mut(path, "".join(lines))
    return f"dead {d_count}->{d_count + 1} on the evaluated line", None


def parse_value(out: str):
    for ln in reversed((out or "").splitlines()):
        if ln.startswith("C1_ROUTED:"):
            m = re.search(r"value=(\d+|FAIL)", ln)
            if m:
                return "FAIL" if m.group(1) == "FAIL" else int(m.group(1))
    return None


def run_value(argv: list[str], timeout: int = 900):
    r = subprocess.run(argv, capture_output=True, text=True, timeout=timeout)
    return parse_value(r.stdout)


def run_guard(root: str, count: int) -> tuple[bool | None, bool | None, str]:
    """Leg 2+3 of the frozen GUARD. Returns (challenge_ok, stub_fails, detail);
    challenge_ok/stub_fails None means the leg could not run (GUARD stays 0)."""
    root_abs = os.path.realpath(root)
    par_abs = os.path.realpath(challenge_parent())
    if par_abs == root_abs or par_abs.startswith(root_abs + os.sep):
        raise SetupError(f"challenge scratch {par_abs} resolves at/inside the measured "
                         f"root {root_abs} (refused, QM74)")
    try:
        tmp = tempfile.mkdtemp(prefix="c1-challenge-", dir=par_abs)
    except OSError as e:
        return None, None, f"challenge scratch unavailable: {e}"
    try:
        copy = os.path.join(tmp, "tree")
        shutil.copytree(root, copy, symlinks=False,
                        ignore=shutil.ignore_patterns(".git", ".jj"))
        if os.path.realpath(copy) == root_abs:
            return None, None, "challenge copy resolves to the measured tree (refused)"
        changed, err = mutate_i1_dead(copy)
        if err:
            return False, False, f"challenge not injectable: {err}"
        expect = count + 1
        py = sys.executable or "python3"
        v2 = run_value([py, "-I", "-B", os.path.abspath(__file__),
                        "--root", copy, "--no-challenge"])
        stub = os.path.join(tmp, "stub.py")
        with open(stub, "w", encoding="utf-8") as f:
            f.write('print("C1_ROUTED: value=0 population=7 '
                    'i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")\n')
        sv = run_value([py, "-I", "-B", stub, "--root", copy, "--no-challenge"])
        chal_ok = isinstance(v2, int) and v2 == expect
        stub_fails = not (isinstance(sv, int) and sv == expect)
        detail = (f"copy delta dead-digit {changed}: value={v2} expect={expect}; "
                  f"stub value={sv} fails={stub_fails}")
        return chal_ok, stub_fails, detail
    except (OSError, shutil.Error, subprocess.SubprocessError) as e:
        return None, None, f"challenge failed: {type(e).__name__}: {e}"
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


def _refuse_symlinks(root: str) -> None:
    """§A5 6: a symlinked statement file or receipt is refused (QM74/R22 class)."""
    for rel in _SYMLINK_REFUSAL_RELS:
        if os.path.islink(os.path.join(root, *rel.split("/"))):
            raise SetupError(f"{rel} is a symlink (refused)")


def _refuse_inside_root(root: str) -> None:
    """QM74: the I7 mutation leg and the GUARD share the challenge scratch."""
    root_abs = os.path.realpath(root)
    par_abs = os.path.realpath(challenge_parent())
    if par_abs == root_abs or par_abs.startswith(root_abs + os.sep):
        raise SetupError(f"challenge scratch {par_abs} resolves at/inside the measured "
                         f"root {root_abs} (refused, QM74)")


def evaluate(root: str, verbose: bool = False, challenge: bool = True,
             as_json: bool = False) -> int:
    _refuse_symlinks(root)  # §A5 6: refuse to measure symlinked statements/receipts
    _refuse_inside_root(root)  # QM74 (both modes: item I7's mutation leg needs it)
    res = measure(root)
    toks = {k: ("1" if s == HOLD else "0") for k, (s, _) in res.items()}
    population = sum(1 for s, _ in res.values() if s in (HOLD, FAIL))
    count = sum(1 for s, _ in res.values() if s == FAIL)

    if not challenge:
        guard = 0
        value_token = str(count)
        challenge_detail = "not run (--no-challenge); diagnostic count printed"
    else:
        chal_ok, stub_fails, challenge_detail = run_guard(root, count)
        guard = 1 if (population == POP and chal_ok is True and stub_fails is True) else 0
        value_token = str(count) if guard == 1 else "FAIL"

    if as_json:
        print(json.dumps({
            "instrument": "plans/round-60-c1-check.py",
            "root": root,
            "value": value_token, "value_diagnostic": count,
            "population": population,
            "items": {k: (1 if s == HOLD else 0) for k, (s, _) in res.items()},
            "guard": guard, "challenge": challenge_detail,
            "evidence": {k: d for k, (s, d) in res.items()},
        }, sort_keys=True))
    else:
        for k, (s, d) in res.items():
            print(f"c1: {k} {s} {d}")
        if verbose:
            print(f"c1-guard: {challenge_detail}")
        print(f"C1_ROUTED: value={value_token} population={population} "
              + " ".join(f"{k}={toks[k]}" for k, _ in ITEMS) + f" guard={guard}")
    return 0 if (guard == 1 and value_token == "0") else 1


# --------------------------------------------------------------------------- selftest
RESULTS_GOOD = json.dumps({"results": [
    {"name": f"Seat{i}", "agent": "executor", "note": "", "output": f"done {i}"}
    for i in range(14)]})

LOG_GOOD = (
    "# LOG (fixture)\n\n"
    "## Round 59\n\n"
    "- Wave `kagi-r59-w1`, 14 seats v1 (`.ufo/waves/round-59/w1-dispatch.json`): "
    "dead seats __DEAD__.\n\n"
    "## Round 59 — correction\n\n"
    "- correction (D1): the wave line above is superseded; results=14 dead=0 — all 14 "
    "results in .ufo/waves/round-59/w1-results.json have a non-empty final output "
    "(0 dead seats).\n"
)

LESSON59_GOOD = (
    "# Round 59 — lesson (fixture)\n\n"
    "## Routed dispositions\n\n"
    "| # | finding | disposition |\n"
    "|---|---|---|\n"
    "| R31 | the C1 counter's report says `--selftest` runs 33 cases while its committed "
    "receipt reads `C1_CHECK_SELFTEST: PASS (32 cases)` | routed |\n\n"
    "- correction (D2): supersedes R31 — the receipt "
    "`.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt` reads "
    "C1_CHECK_SELFTEST: PASS (33 cases); the 32-case figure was wrong.\n"
)

SELFTEST59_GOOD = (
    "# receipt: checker selftest\n"
    "# captured: fixture\n"
    "# cmd: python3 -I -B plans/round-59-c1-check.py --selftest\n"
    "C1_CHECK_SELFTEST: PASS (33 cases)\n"
    "rc=0\n"
)

LESSON60_GOOD = (
    "# Round 60 — lesson (fixture)\n\n"
    "## Routed dispositions\n\n"
    "Every attack finding this wave produced, and what happened to it.\n\n"
    "| # | finding | disposition |\n"
    "|---|---|---|\n"
    "| R20 | fixture finding A | fixed |\n"
    "| R21 | fixture finding B | fixed |\n"
    "| R22 | fixture finding C | fixed |\n\n"
    "Note: the round-59 lesson's routed table used R20, R21, R22 twice each — a "
    "duplicate id names two findings; this table keeps ids unique.\n"
)

SC_LINE_I4 = (
    "| calibration | 9 → 9 | [C1] fixture (21 controls; the pre-freeze battery receipt) "
    "| evidence |\n"
)
SC_LINE_I5 = (
    "- correction (D5): supersedes the round-59 gate-evidence pointer — the round-59 "
    "final/ never wrote those receipts; the round-60 receipts are "
    ".ufo/waves/round-60/final/release-clock-r60.txt, "
    ".ufo/waves/round-60/final/doc-audit-r60.txt and "
    ".ufo/waves/round-60/final/scope-r60.txt (never written at round-59 close; "
    "written this round). never written.\n"
)
SC_LINE_I6_STATED = (
    "- correction (D6): supersedes the round-59 measured-commit citation — "
    ".ufo/waves/round-59/final/c1-landed.txt states "
    "c1-driver: measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c "
    "(measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c).\n"
)
SC_LINE_I4_FIX = (
    "- correction (D4): supersedes SCORECARD.md:1971 — the pre-freeze receipt holds "
    "20 controls, not 21.\n"
)
SC_GOOD = ("# SCORECARD (fixture)\n\n| Axis | Before → after | What moved | Evidence |\n"
           "|---|---|---|---|\n" + SC_LINE_I4 + SC_LINE_I6_STATED
           + SC_LINE_I4_FIX + SC_LINE_I5)
SC_I4_ONLY = SC_LINE_I4 + SC_LINE_I4_FIX
SC_I5_ONLY = SC_LINE_I5
SC_I6_ONLY = SC_LINE_I6_STATED

CONTROLS59_GOOD = "".join(f"CONTROL C1-F{i} expect=1 got=1 MATCH\n" for i in range(20))

CLANDED_GOOD = (
    "c1: i1 HOLD fixture\n"
    "c1: i2 HOLD fixture\n"
    "c1: i3 HOLD fixture\n"
    "c1: i4 HOLD fixture\n"
    "c1: i5 HOLD fixture\n"
    "C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=1\n"
    "c1-driver: measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c (git archive)\n"
    "c1-driver: scratch=/fixture\n"
    "c1-driver: checker rc=0\n"
    "c1-driver: verdict value=0 guard=1 (resolved and re-checkable)\n"
)

FINAL_RELEASE = "# receipt\nRELEASE_CLOCK: CLEAN (on_release=32 bound=32)\n"
FINAL_DOC = "# receipt\nDOC_AUDIT: CLEAN (entries=40 row_linked=37 by_hand=3)\n"
FINAL_SCOPE = ("# receipt\n"
               "ADJACENCY_SCOPE: DEFECT (census=35 stale_basis=0 breadth_drift=5 "
               "breadth_unverified=1)\n")

TRANSIT_GOOD = (
    "#!/usr/bin/env bash\n"
    "# fixture transit selftest (A5 §5 contract)\n"
    "rc=0\n"
    "S=HOLDS\n"
    "if true; then S=BROKEN; rc=1; fi\n"
    "if [ \"$S\" != \"BROKEN\" ] || [ \"$rc\" -ne 1 ]; then\n"
    "  echo \"FINDING TRANSIT-ST-900 verdict-mapping mutation undetected\"\n"
    "  exit 1\n"
    "fi\n"
    "echo \"TRANSIT_SELFTEST: PASS (cases=7)\"\n"
    "exit 0\n"
)

SKILL_GOOD = (
    "# SKILL (fixture)\n\n"
    "## Gate registry — round-60 additions\n\n"
    "| name | kind | entry command | verdict map | selftest | pinned values | "
    "write scope | owner |\n"
    "|---|---|---|---|---|---|---|---|\n"
    "| transit-engine trial (`corpus/openbao-transit-trial.sh`) | gate | "
    "`bash corpus/openbao-transit-trial.sh [--work DIR]` | 0 HOLDS; 1 BROKEN; 2 SETUP | "
    "`bash corpus/openbao-transit-trial.sh --selftest` → `TRANSIT_SELFTEST: PASS (cases=N)` | "
    "fixture | fixture | kagi |\n"
)

ONLY_FILES = {
    "i1": (LOG_REL, RESULTS_REL),
    "i2": (LESSON59_REL, SELFTEST59_REL),
    "i3": (LESSON60_REL,),
    "i4": (SCORECARD_REL, CONTROLS59_REL),
    "i5": (SCORECARD_REL, FINAL_PREFIX + "release-clock-r60.txt",
           FINAL_PREFIX + "doc-audit-r60.txt", FINAL_PREFIX + "scope-r60.txt"),
    "i6": (SCORECARD_REL, CLANDED_REL),
    "i7": (TRANSIT_REL, SKILL_REL),
}
ONLY_SCORECARD = {"i4": SC_I4_ONLY, "i5": SC_I5_ONLY, "i6": SC_I6_ONLY}
ONLY_FINALS = {FINAL_PREFIX + "release-clock-r60.txt": FINAL_RELEASE,
               FINAL_PREFIX + "doc-audit-r60.txt": FINAL_DOC,
               FINAL_PREFIX + "scope-r60.txt": FINAL_SCOPE}


def _fixture_text(rel: str, scorecard: str) -> str:
    if rel == LOG_REL:
        return LOG_GOOD
    if rel == RESULTS_REL:
        return RESULTS_GOOD
    if rel == LESSON59_REL:
        return LESSON59_GOOD
    if rel == SELFTEST59_REL:
        return SELFTEST59_GOOD
    if rel == LESSON60_REL:
        return LESSON60_GOOD
    if rel == SCORECARD_REL:
        return scorecard
    if rel == CONTROLS59_REL:
        return CONTROLS59_GOOD
    if rel == CLANDED_REL:
        return CLANDED_GOOD
    if rel == TRANSIT_REL:
        return TRANSIT_GOOD
    if rel == SKILL_REL:
        return SKILL_GOOD
    if rel in ONLY_FINALS:
        return ONLY_FINALS[rel]
    raise KeyError(rel)


def w(root: str, rel: str, text: str) -> None:
    p = os.path.join(root, *rel.split("/"))
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as f:
        f.write(text)


def mk_tree(base: str, only: str | None = None, scorecard: str = SC_GOOD) -> str:
    os.makedirs(base, exist_ok=True)
    if only is None:
        for rel in (LOG_REL, RESULTS_REL, LESSON59_REL, SELFTEST59_REL, LESSON60_REL,
                    SCORECARD_REL, CONTROLS59_REL, CLANDED_REL, TRANSIT_REL, SKILL_REL,
                    *ONLY_FINALS):
            w(base, rel, _fixture_text(rel, scorecard))
    else:
        sc = ONLY_SCORECARD.get(only, scorecard)
        for rel in ONLY_FILES[only]:
            w(base, rel, _fixture_text(rel, sc))
    return base


def quiet_evaluate(*a, **k) -> tuple[int, str]:
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = evaluate(*a, **k)
    return rc, buf.getvalue()


def run_selftest() -> int:
    top = tempfile.mkdtemp(prefix="c1-check-selftest-")
    cases = 0
    failures: list[str] = []

    def case(name: str, cond: bool) -> None:
        nonlocal cases
        cases += 1
        if not cond:
            failures.append(name)

    old_parent = os.environ.get("C1_CHALLENGE_PARENT")
    scratch = os.path.join(top, "challenge-scratch")
    os.makedirs(scratch, exist_ok=True)
    os.environ["C1_CHALLENGE_PARENT"] = scratch
    try:
        good = mk_tree(os.path.join(top, "good"))

        # -- unit: derivations --
        case("derive-results-14-0", derive_results_counts(good) == (14, 0))
        case("derive-selftest-cases-33", derive_selftest_cases(good) == 33)
        case("derive-controls-20", derive_control_count(good) == 20)
        case("derive-measured-rev",
             derive_measured_rev(good) == "160caf750dcf15892b78ec066e66bc605ba57a5c")

        # -- unit: guard mutation is only the dead digit --
        mut = mk_tree(os.path.join(top, "mut"))
        desc, err = mutate_i1_dead(mut)
        mut_log = rd(mut, LOG_REL) or ""
        case("mutate-dead-digit-only",
             err is None and desc is not None and "dead 0->1" in desc
             and "results=14 dead=1" in mut_log and "results=14 dead=0" not in mut_log
             and mut_log.count("dead=1") == 1)

        # -- unit: registry row parsing --
        row = find_registry_row(SKILL_GOOD)
        case("registry-row-found", row is not None
             and "--selftest" in row[1][row[2]] and NONE_SHIMS_LITERAL not in row[0])
        bad_skill = SKILL_GOOD.replace("`bash corpus/openbao-transit-trial.sh --selftest` → "
                                       "`TRANSIT_SELFTEST: PASS (cases=N)`",
                                       "none — its own five shims and the clean-room leg")
        row_bad = find_registry_row(bad_skill)
        case("registry-row-none-shims-fails",
             row_bad is not None and NONE_SHIMS_LITERAL in row_bad[0])

        # -- items on the all-resolved fixture --
        res = measure(good)
        case("aggregate-good-all-hold",
             all(s == HOLD for s, _ in res.values()) and len(res) == POP)

        # -- evaluate legs --
        rc, out = quiet_evaluate(good, challenge=False)
        case("evaluate-no-challenge-good",
             rc == 1 and "value=0" in out and "guard=0" in out and "population=7" in out
             and "i7=1" in out)
        rc, out = quiet_evaluate(good, verbose=True, challenge=True)
        case("evaluate-guard-good-tree",
             rc == 0 and "value=0" in out and "guard=1" in out
             and "expect=1" in out and "fails=True" in out)

        empty = os.path.join(top, "empty")
        os.makedirs(empty, exist_ok=True)
        rc, out = quiet_evaluate(empty, challenge=False)
        case("evaluate-all-unresolved-7",
             rc == 1 and "value=7" in out and "population=7" in out and "guard=0" in out
             and all(f"i{k}=0" in out for k in range(1, 8)))
        rc, out = quiet_evaluate(empty, challenge=True)
        case("evaluate-all-unresolved-guard-fails-closed",
             rc == 1 and "value=FAIL" in out and "guard=0" in out)

        # -- each item resolving alone --
        for k in range(1, 8):
            key = f"i{k}"
            tree = mk_tree(os.path.join(top, f"only-{key}"), only=key)
            rc, out = quiet_evaluate(tree, challenge=False)
            others = " ".join(f"i{j}=0" for j in range(1, 8) if j != k)
            case(f"only-{key}-resolves",
                 rc == 1 and f"i{k}=1" in out and f"value=6" in out
                 and all(f"i{j}=0" in out for j in range(1, 8) if j != k))

        # -- forgery / fail-closed fixtures on the good tree --
        # satisfied-text-but-false-substance: I2 states 32 cases, derived is 33
        bad = mk_tree(os.path.join(top, "bad-substance"))
        w(bad, LESSON59_REL, LESSON59_GOOD.replace("(33 cases); the 32-case figure was wrong",
                                                  "(32 cases); the figure was wrong"))
        case("i2-false-substance-32", item2(bad)[0] == FAIL)
        # §A5 2: a decoy R31 mention does not relocate the anchor (row regex only)
        bad = mk_tree(os.path.join(top, "bad-i2-decoy"))
        w(bad, LESSON59_REL, "# a decoy line mentioning R31 early\n" + LESSON59_GOOD)
        case("i2-decoy-mention-does-not-relocate", item2(bad)[0] == HOLD)
        # §A5 2: a correction placed before the real routed row does not resolve
        bad = mk_tree(os.path.join(top, "bad-i2-misplaced"))
        w(bad, LESSON59_REL, (
            "# Round 59 — lesson (fixture)\n\n"
            "A decoy: R31 was mentioned earlier; the correction sits before the row.\n\n"
            "- correction (D2): supersedes R31 — the receipt reads "
            "C1_CHECK_SELFTEST: PASS (33 cases).\n\n"
            "| # | finding | disposition |\n"
            "|---|---|---|\n"
            "| R31 | the receipt says 32 cases | routed |\n"))
        case("i2-misplaced-correction-fails", item2(bad)[0] == FAIL)
        # §A5 2: the LAST C1_CHECK_SELFTEST line after the anchor is the statement
        bad = mk_tree(os.path.join(top, "bad-i2-later"))
        w(bad, LESSON59_REL, LESSON59_GOOD + "- later: the receipt reads "
          "C1_CHECK_SELFTEST: PASS (32 cases), supersedes R31 again.\n")
        case("i2-later-wrong-restatement", item2(bad)[0] == FAIL)
        # I1 tolerant label: `dead seats=0` resolves; the guard mutates that digit
        seats = mk_tree(os.path.join(top, "seats-label"))
        w(seats, LOG_REL, LOG_GOOD.replace("results=14 dead=0", "results=14 dead seats=0"))
        case("i1-dead-seats-label-resolves", item1(seats)[0] == HOLD)
        desc2, err2 = mutate_i1_dead(seats)
        case("i1-dead-seats-label-mutates",
             err2 is None and desc2 is not None and "dead 0->1" in desc2
             and "results=14 dead seats=1" in (rd(seats, LOG_REL) or ""))
        # after-the-wrong-line: I1 correction block placed BEFORE the __DEAD__ line
        bad = mk_tree(os.path.join(top, "bad-order"))
        log_bad = ("# LOG\n\n## Round 59 — correction\n\n"
                   "- correction (D1): results=14 dead=0 in .ufo/waves/round-59/"
                   "w1-results.json.\n\n"
                   "## Round 59\n\n- Wave line: dead seats __DEAD__.\n")
        w(bad, LOG_REL, log_bad)
        case("i1-correction-before-anchor", item1(bad)[0] == FAIL)
        # §A5 1: a later census restatement inside the same block is the evaluated line
        bad = mk_tree(os.path.join(top, "bad-i1-later"))
        w(bad, LOG_REL, LOG_GOOD + "- correction (D1, restated): results=14 dead=1 — "
          "a later census line in the same block.\n")
        case("i1-later-restatement-in-block", item1(bad)[0] == FAIL)
        # missing receipt: c1-landed.txt absent
        bad = mk_tree(os.path.join(top, "bad-missing-receipt"))
        os.remove(os.path.join(bad, *CLANDED_REL.split("/")))
        case("i6-missing-receipt", item6(bad)[0] == FAIL)
        # malformed receipt: no measured=revision line
        bad = mk_tree(os.path.join(top, "bad-malformed-receipt"))
        w(bad, CLANDED_REL, "c1-driver: verdict value=0 guard=1\n")
        case("i6-malformed-receipt", item6(bad)[0] == FAIL)
        # absent I7 script
        bad = mk_tree(os.path.join(top, "bad-no-transit"))
        os.remove(os.path.join(bad, *TRANSIT_REL.split("/")))
        rc, out = quiet_evaluate(bad, challenge=False)
        case("i7-absent-script-unresolved-not-setup",
             item7(bad)[0] == FAIL and rc == 1 and "value=1" in out and "i7=0" in out)
        # I7 selftest cases < 6
        bad = mk_tree(os.path.join(top, "bad-cases5"))
        w(bad, TRANSIT_REL, TRANSIT_GOOD.replace("cases=7", "cases=5"))
        case("i7-selftest-cases5", item7(bad)[0] == FAIL)
        # I7 selftest exits non-zero
        bad = mk_tree(os.path.join(top, "bad-exit1"))
        w(bad, TRANSIT_REL, "#!/usr/bin/env bash\necho \"TRANSIT_SELFTEST: PASS (cases=7)\"\nexit 1\n")
        case("i7-selftest-exit1", item7(bad)[0] == FAIL)
        # §A5 5: a PASS printer with no mutation needle fails closed
        bad = mk_tree(os.path.join(top, "bad-i7-printer"))
        w(bad, TRANSIT_REL, "#!/usr/bin/env bash\n"
          "echo \"TRANSIT_SELFTEST: PASS (cases=7)\"\nexit 0\n")
        case("i7-pass-printer-no-needle", item7(bad)[0] == FAIL)
        # §A5 5: a mutated copy that still exits 0 without a FINDING line fails closed
        bad = mk_tree(os.path.join(top, "bad-i7-mutation-undetected"))
        w(bad, TRANSIT_REL, "#!/usr/bin/env bash\n"
          "if true; then S=BROKEN; rc=1; fi\n"
          "echo \"TRANSIT_SELFTEST: PASS (cases=7)\"\nexit 0\n")
        case("i7-mutation-not-detected", item7(bad)[0] == FAIL)
        # I4 duplicate correction stating 21 controls after the good one (last wins)
        bad = mk_tree(os.path.join(top, "bad-i4-dup"))
        w(bad, SCORECARD_REL, SC_GOOD + "- later restatement: supersedes "
          "SCORECARD.md:1971 — actually 21 controls.\n")
        case("i4-later-wrong-restatement", item4(bad)[0] == FAIL)
        # I3 duplicate id in the routed table
        bad = mk_tree(os.path.join(top, "bad-i3-dup"))
        w(bad, LESSON60_REL, LESSON60_GOOD.replace("| R22 | fixture finding C | fixed |",
                                                  "| R20 | fixture finding C | fixed |"))
        case("i3-duplicate-id", item3(bad)[0] == FAIL)
        # I5 missing one final receipt
        bad = mk_tree(os.path.join(top, "bad-i5-missing"))
        os.remove(os.path.join(bad, *FINAL_PREFIX.split("/"), "release-clock-r60.txt"))
        case("i5-missing-final-file", item5(bad)[0] == FAIL)
        # §A5 3: a one-line stub receipt (token only, no numeric key=value) fails
        bad = mk_tree(os.path.join(top, "bad-i5-stubs"))
        w(bad, FINAL_PREFIX + "release-clock-r60.txt", "RELEASE_CLOCK: CLEAN\n")
        w(bad, FINAL_PREFIX + "doc-audit-r60.txt", "DOC_AUDIT: CLEAN\n")
        w(bad, FINAL_PREFIX + "scope-r60.txt", "ADJACENCY_SCOPE: CLEAN\n")
        case("i5-stub-receipts-fail", item5(bad)[0] == FAIL)
        # §A5 4: the stating line itself carries the supersedes phrase
        bad = mk_tree(os.path.join(top, "bad-i6-noline"), scorecard="")
        case("i6-supersedes-line-absent", item6(bad)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i6-wronghash"),
                      scorecard=SC_LINE_I6_STATED.replace(
                          "160caf750dcf15892b78ec066e66bc605ba57a5c",
                          "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"))
        case("i6-wrong-hash-stated", item6(bad)[0] == FAIL)
        # SCORECARD absent entirely: i4/i5/i6 unresolved, population stays 7
        bad = mk_tree(os.path.join(top, "bad-no-scorecard"))
        os.remove(os.path.join(bad, *SCORECARD_REL.split("/")))
        res_bad = measure(bad)
        case("scorecard-absent-population-7",
             res_bad["i4"][0] == FAIL and res_bad["i5"][0] == FAIL
             and res_bad["i6"][0] == FAIL and len(res_bad) == POP)

        # -- challenge +1 firing on a tree with unresolved items --
        only1 = mk_tree(os.path.join(top, "only-i1-challenge"), only="i1")
        rc, out = quiet_evaluate(only1, verbose=True, challenge=True)
        case("challenge-plus1-fires-with-unresolved",
             rc == 1 and "value=6" in out and "guard=1" in out and "expect=7" in out
             and "value=7" in out)

        # -- QM74 refusal --
        os.environ["C1_CHALLENGE_PARENT"] = os.path.join(good, "inside")
        raised = False
        try:
            quiet_evaluate(good, challenge=True)
        except SetupError:
            raised = True
        case("qm74-refusal-inside-root", raised)
        os.environ["C1_CHALLENGE_PARENT"] = scratch

        # -- parse_value tokens --
        case("parse-value-tokens",
             parse_value("x\nC1_ROUTED: value=FAIL population=7 guard=0") == "FAIL"
             and parse_value("C1_ROUTED: value=3 population=7 guard=1") == 3
             and parse_value("nothing") is None)

        # §A5 6: a symlinked statement file is refused with SETUP (never measured)
        sym_tree = mk_tree(os.path.join(top, "sym-tree"))
        outside = os.path.join(top, "outside-log.md")
        with open(outside, "w", encoding="utf-8") as f:
            f.write(LOG_GOOD)
        os.remove(os.path.join(sym_tree, *LOG_REL.split("/")))
        os.symlink(outside, os.path.join(sym_tree, *LOG_REL.split("/")))
        raised = False
        try:
            quiet_evaluate(sym_tree, challenge=True)
        except SetupError:
            raised = True
        with open(outside, encoding="utf-8") as f:
            outside_after = f.read()
        case("symlinked-log-refused-setup",
             raised and outside_after == LOG_GOOD
             and "results=14 dead=0" in outside_after)
    finally:
        if old_parent is None:
            os.environ.pop("C1_CHALLENGE_PARENT", None)
        else:
            os.environ["C1_CHALLENGE_PARENT"] = old_parent
        shutil.rmtree(top, ignore_errors=True)

    # -- SETUP leg (subprocess, no fixture tree) --
    r = subprocess.run([sys.executable or "python3", "-I", "-B",
                        os.path.abspath(__file__), "--root", "/nonexistent-c1-root"],
                       capture_output=True, text=True)
    case("setup-missing-root-rc2", r.returncode == 2
         and "C1_ROUTED: SETUP" in r.stdout)

    if failures:
        print(f"C1_CHECK_SELFTEST: FAIL ({cases - len(failures)}/{cases} cases) "
              f"failed={','.join(failures)}")
        return 1
    print(f"C1_CHECK_SELFTEST: PASS ({cases} cases)")
    return 0


# --------------------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser(add_help=True, description="C1_ROUTED counter (round 60)")
    ap.add_argument("--root", default=".", help="measured tree (default: cwd)")
    ap.add_argument("--repo", default=None,
                    help="lane repository (accepted for CLI compatibility; no item "
                         "derives from a named revision — every compared number comes "
                         "from the measured tree)")
    ap.add_argument("--no-challenge", action="store_true",
                    help="diagnostic leg: print the unresolved count with guard=0")
    ap.add_argument("--json", action="store_true", help="one JSON object on stdout")
    ap.add_argument("--verbose", action="store_true", help="c1-guard challenge detail line")
    ap.add_argument("--selftest", action="store_true", help="synthetic-tree selftest")
    args = ap.parse_args()
    if args.selftest:
        return run_selftest()
    root = os.path.abspath(args.root)
    if not os.path.isdir(root):
        print(f"C1_ROUTED: SETUP no measured tree at {root}")
        return 2
    try:
        return evaluate(root, verbose=args.verbose,
                        challenge=not args.no_challenge, as_json=args.json)
    except SetupError as e:
        print(f"C1_ROUTED: SETUP {e}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
