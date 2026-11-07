#!/usr/bin/env python3
r"""plans/round-61-c1-check.py — the C1_ROUTED counter (kagi round 61).

Freezes plans/round-61.md §C1 (predeclaration commit
8595018164f7421864254c6c5ca762b8f201e8be; claim BASE
c940f51689d702f1786989d56ad4663833c1452e):

    C1_ROUTED: value = the number of UNRESOLVED items over POP = 7 fixed routed-defect
    items (I1..I7 below), when GUARD = 1, else FAIL; target 0 (BASE 7).
    An item is UNRESOLVED iff its named condition does not hold on the measured tree.
    GUARD = 1 iff the checker evaluates all seven items (prints population=7 with
    i1..i7 each 0|1, none skipped) and, on a copy of the measured tree whose only delta
    is the digit in the I5 correction line's `deletions=1` field changed from 1 to 2,
    prints exactly value+1, and a printer stub that always prints value=0 fails that
    same challenge.

Every number an item compares is derived at run time from the measured tree or,
where the item names a revision, from the lane repository passed with `--repo`; no
constant below carries a fact the measured tree asserts. The literals that remain
are the frozen predicate's own anchors (file paths, `R37`, `M60-2`, `818d2a82`,
`14a6c07d`, `a677c78e`, the launch-line and heading literals, the needle fragment),
not derived facts.

Frozen-condition readings taken where the plan wording allowed more than one
structural read (each is the code's behaviour, named here so a reviewer can
disagree precisely):

  - I1 anchor. "after the line containing `R37`" cannot be read as the LAST line
    containing R37: the correction line itself contains R37 and the item would be
    unsatisfiable. The anchor is the LAST routed-disposition row for R37 (row regex
    `^\|\s*R37\s*\|`) — the round-60 §A5-2 house reading. The statement under test
    is the LAST later line matching `supersedes R37` (last statement wins): it must
    state `results=<R> output=<B>` with derived values and name `mutants.md`.
  - I1 derivation. R = len(results) of `.ufo/waves/round-60/w1-results.json`; B =
    len(output.encode("utf-8")) of the SINGLE record whose `name` contains
    `R60MutCounters` (0 or >1 such records fails closed). Missing/malformed JSON
    leaves I1 UNRESOLVED (fail closed, never a silent 0).
  - I2 legs. (A) `bash <tree>/plans/round-60-c2.sh --selftest` (cwd=<tree>, short
    timeout) exits 0 with a `C2_SELFTEST: PASS (cases=N)` line, N >= 6; (B) the
    SKILL.md gate-registry row (LAST row whose NAME cell contains
    `plans/round-60-c2.sh`) carries `--selftest` in its selftest cell and does not
    carry `none of its own`; (C) a copy of the script with the verdict mapping
    inverted exits non-zero printing at least one `FINDING C2-ST-` line.
  - I2 needle. The plan names no needle ("whose verdict mapping is broken"); the
    measured script's own header declares the canonical red-witness mutation
    ("the verdict mapping inverted via `tr HB BH` in vec") and its round-61 fix
    implements it as `s/| cut -c1)/| cut -c1 | tr HB BH)/`. The checker's needle is
    the vec-body fragment `verdict "$1" "T$i" | cut -c1)"` (it must occur EXACTLY
    once — 0 or >1 fails closed), mutated by inserting ` | tr HB BH` before the
    closing paren — the same inversion the script's own witness applies.
  - I2 isolation. Legs A and C run with TMPDIR and HYAKU_SCRATCH redirected into
    scratch created for the leg, so the measured script cannot write outside it;
    the measured tree is never written. A symlinked script fails the item.
  - I3 geometry. The A6 anchor is the LAST `^###\s+A6\b` heading; the A6 block runs
    to the next `^## ` heading or EOF; the LAST `^## Amendment A7` heading must sit
    at/after that block end (`>=`, because §A6 is the plan's last section at BASE,
    so an appended A7 IS the block terminator), and the A7 section (to the next
    `^## ` heading or EOF) must name `A3 item 2`, `form` (word), `l1-probe.txt` and
    state `withdrawn` (word). The lesson leg: the LAST line naming both `M60-2` and
    `A3 item 2` must also state `second instance` (a later wrong restatement
    breaks the item).
  - I4/I6/I7 statement selection: the LAST line matching the item's supersedes
    phrase is the statement under test (last occurrence wins).
  - I5/I6 derivations need the lane repository (`--repo`). I5 derives the stated
    `insertions=`/`deletions=` values with
    `git -C <repo> diff --numstat 14a6c07d 818d2a82 -- LOG.md`; I6 derives the
    committer-stamp set with `git -C <repo> log --format=%ci a677c78e..818d2a82`
    and normalizes each `%ci` stamp (`2026-11-07 15:06:58 -0300`) to the item's
    `2026-11-07T15:06:58-03:00` shape before the membership test. With `--repo`
    absent both items fall back to shape-only readings (stated digit shapes /
    timestamp shapes, noted in the item detail) — the driver always passes
    `--repo`; with `--repo` given a failed derivation leaves the item UNRESOLVED
    (never a pass), and git missing from PATH is SETUP.
  - I6 qualifying timestamps. The launch stamp (15:03:17, a watchdog time, not a
    commit stamp) is excluded from the "at least three" census; the remaining
    DISTINCT `-03:00` stamps on the line must each occur in the derived set (>= 3;
    shape-only without `--repo`).
  - I7 derivation. A = |{reviewer, critic, mutation-tester, labrat} ∩ `agent`
    values| of `.ufo/waves/round-60/w1-results.json`; B = A + (1 if `sentinel` is
    present else 0) — the plan's "that number plus the sentinel", derived from the
    file; N = len(results). The line must state A/N, B/N, 100*A/N and 100*B/N as
    boundary-delimited tokens (so `25` does not match `250`, `18.75` not `18.750`).
  - GUARD challenge delta. The frozen GUARD literal and the item literal name the
    same field: on the evaluated (LAST) I5 line the `deletions=<D>` digit becomes
    D+1 (1 -> 2 when the line states the derived census), replacing the first
    `insertions=<I> deletions=<D>` occurrence ON THAT LINE ONLY — the copy's only
    delta. The guard's re-run forwards `--repo`, so the stated `deletions=2` no
    longer equals the derived value and I5 alone flips HOLD -> FAIL, moving the
    value by exactly +1. Without `--repo` the flip cannot happen (shape-only
    fallback) and GUARD reads 0 — recorded, deliberate.
  - A tree missing an item's input file reads the item UNRESOLVED (population
    stays 7); GUARD then reads 0 because the challenge cannot inject its delta.
  - QM74: the I2 mutation leg, the GUARD and any item scratch share
    C1_CHALLENGE_PARENT; a scratch resolving at/inside the measured root is
    refused with SETUP rc 2 (checked on every evaluation); a scratch that cannot
    be created leaves the affected leg failed closed (GUARD 0 / item UNRESOLVED),
    never a faked pass. Challenge copies materialise symlinks (`copytree
    symlinks=False`) so no mutation writes through a symlink outside the copy.
  - Symlink refusal: a measured LOG.md, round-60 lesson, round-60 plan, SKILL.md
    or `w1-results.json` that is a symlink is refused with SETUP rc 2 (the
    round-60 §A5-6 class); the checker never executes a lane gate other than the
    two `plans/round-60-c2.sh --selftest` invocations I2 names.
  - Round-62 QM79 hardening (plans/round-62.md §C1 + Amendment A1). I3 requires
    an occurrence of `withdrawn` with the token sequence `A3 item 2` in its
    12-token window and no negator in its truncated 5-token window; I4/I5 require
    `three` / `rewritten in place` to occur with no negator in the truncated
    5-token window before the match; I6 additionally requires at least one
    `HH:MM:SS` time that is neither the launch line's time nor a derived
    committer time (the superseded paragraph's stamp, QM78) and forbids the
    denial phrases `times are correct` / `times are right` / `is correct` /
    `are correct` on the line (Amendment A1 clause d); I7 requires the derived
    fraction/percentage pairs (`3/16 = 18.75 %`, `4/16 = 25 %`,
    whitespace-tolerant) instead of bare token presence. Negators
    (case-insensitive, token-exact): not, no, never, neither, nor, without,
    none, and any token ending `n't`; the bigram `not only` immediately before
    the match is an idiom, not a negator. The window is a floor, not a parser
    (plan §C1 named ceiling).
  - Round-63 hardening (plans/round-63.md §C1). The polarity test is now a
    sentence-scoped asserted-position test shared by I3/I4/I5: a token is
    asserted iff (i) no effective negator sits between the nearest `.` or `;`
    before it and the token (window capped at 24 tokens; `:` no longer
    truncates), (ii) no denial predicate sits between the token and the
    nearest `.` or `;` after it (capped at 24 tokens), (iii) no listed idiom
    (`not only`, `not merely`, `not just`, `no fewer than`, `no less than`)
    immediately precedes it — an idiom's head negator does not count — and
    (iv) no negator before it is followed by `but` before the token
    (contrastive rescue). Double-quoted spans that END before the token are
    masked first (the superseded quotation is not the correction's assertion).
    I3 accepts `A3 item 2` or `item 2 of A3` in the 12-token anchor window;
    I4 accepts `three` or the digit `3` (word-boundary); I5 accepts
    `rewritten in place` or `rewritten in-place`. I6 additionally requires
    the correction line's quoted superseded span's `HH:MM:SS` set to equal
    exactly the stamp derived from `{fleet}/.ufo/reports/round-60/kagi.md`
    §Stale-lane (`launch HH:MM:SS`; `--fleet`, default the fleet root); a
    missing or unreadable report is SETUP (exit 2), never a silent pass. I7
    binds each derived fraction/percentage pair to its subject: `3/16 =
    18.75 %` within 8 tokens after `literal reading`, `4/16 = 25 %` within 8
    tokens after `sentinel` (quoted spans masked). The window and the lists
    are closed lists and a floor (plan §C1 named ceiling).

Usage:
    python3 -I -B plans/round-61-c1-check.py --root <tree> [--repo <lane>]
                                             [--fleet <dir>]
                                             [--no-challenge] [--json] [--verbose]
                                             [--selftest] [--work DIR]
Output: one `c1:` evidence line per item, then
    C1_ROUTED: value=<V|FAIL> population=7 i1=<0|1> … i7=<0|1> guard=<0|1>
(--no-challenge prints the diagnostic unresolved count as V with guard=0; --json
prints one JSON object instead.)  Exit 0 iff guard=1 and value=0; 1 otherwise;
2 SETUP.
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
PLAN60_REL = "plans/round-60.md"
LESSON60_REL = "corpus/lessons/round-60.md"
SKILL_REL = "SKILL.md"
RESULTS60_REL = ".ufo/waves/round-60/w1-results.json"
C2_SCRIPT_REL = "plans/round-60-c2.sh"

FLEET_REPORT_REL = ".ufo/reports/round-60/kagi.md"
DEFAULT_FLEET = "/home/vgpnk/Projects/shokunin"
STALE_LANE_LABEL_RE = re.compile(r"stale-lane", re.IGNORECASE)
LAUNCH_HMS_RE = re.compile(r"launch\s+(\d{2}:\d{2}:\d{2})")

POP = 7
SELFTEST_TIMEOUT = 90
HOLD, FAIL = "HOLD", "FAIL"

# ---- frozen predicate anchors (literals the plan itself states) ----
R37_ROW_RE = re.compile(r"^\|\s*R37\s*\|")
SUPERSEDES_R37_RE = re.compile(r"supersedes\s+R37\b")
RESULTS_OUTPUT_RE = re.compile(r"results=(\d+)\s+output=(\d+)")
MUTANTS_MD = "mutants.md"
MUT_RECORD_TOKEN = "R60MutCounters"

C2_SCRIPT_TOKEN = "plans/round-60-c2.sh"
C2_PASS_RE = re.compile(r"C2_SELFTEST:\s*PASS\s*\(\s*cases=(\d+)\s*\)")
FINDING_RE = re.compile(r"FINDING\s+C2-ST-")
ST_NEEDLE = 'verdict "$1" "T$i" | cut -c1)"'
ST_MUTATED = 'verdict "$1" "T$i" | cut -c1 | tr HB BH)"'
NONE_OWN_LITERAL = "none of its own"
GATE_REG_HEADING_RE = re.compile(r"^#{2,3}\s+.*[Gg]ate registry")
SEPARATOR_CELL_RE = re.compile(r":?-{3,}:?")

H2_RE = re.compile(r"^## ")
A6_HEADING_RE = re.compile(r"^###\s+A6\b")
A7_HEADING_RE = re.compile(r"^##\s+Amendment A7\b")
A3_ITEM2_RE = re.compile(r"A3\s+item\s+2\b")
FORM_RE = re.compile(r"\bform\b")
WITHDRAWN_RE = re.compile(r"\bwithdrawn\b")
L1PROBE_TOKEN = "l1-probe.txt"
M602_TOKEN = "M60-2"
SECOND_INSTANCE_RE = re.compile(r"second\s+instance")

QUALITY_TREND_RE = re.compile(r"supersedes\s+the\s+round-60\s+quality-trend\s+sentence")
NO_NEW_RECORD_DEFECT_RE = re.compile(r"no\s+new\s+record\s+defect")
THREE_RE = re.compile(r"\bthree\b")
COUNT3_RE = re.compile(r"(?<![A-Za-z0-9_'])3(?![A-Za-z0-9_'])")

WAVE_LINE_RE = re.compile(r"^-\s+Wave\s+.*kagi-r60-w1")
SUPERSEDES_LOG_WAVE_RE = re.compile(
    r"supersedes\s+the\s+round-60\s+LOG\s+wave\s+line")
NUMSTAT_SHAPE_RE = re.compile(r"insertions=(\d+)\s+deletions=(\d+)")
REWITTEN_IN_PLACE_RE = re.compile(r"rewritten\s+in(?:\s+|-)place")
REV_A = "14a6c07d"  # the pre-rewrite parent the plan names
REV_B = "818d2a82"  # the rewriting tip the plan names
REV_RANGE_BASE = "a677c78e"  # the range base the plan names

STALE_LANE_RE = re.compile(r"supersedes\s+the\s+round-60\s+stale-lane\s+paragraph")
LAUNCH_LINE_RE = re.compile(
    r"2026\-11\-07T15:03:17\-03:00\s+launch\s+kagi\s+round=60")
TS_RE = re.compile(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}-03:00")
CI_LINE_RE = re.compile(
    r"^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})\s+([+-])(\d{2})(\d{2})$")

ATTACK_SHARE_RE = re.compile(
    r"supersedes\s+the\s+round-60\s+attack-share\s+arithmetic")
ROLE_SET = ("reviewer", "critic", "mutation-tester", "labrat")
SENTINEL_ROLE = "sentinel"

# ---- round-63 hardened grammar (plans/round-63.md §C1) ----
# Negators (case-insensitive, word-boundary). `no longer` is covered by the
# `no` token; `n't` is the suffix rule below.
NEGATORS = frozenset(("not", "no", "never", "neither", "nor", "without",
                      "none", "hardly", "barely", "scarcely", "rarely",
                      "seldom"))
NT_SUFFIX = "n't"
TOKEN_RE = re.compile(r"[A-Za-z0-9_']+")
SENTENCE_CHARS = (".", ";")  # polarity window boundaries (`:` dropped, r63)
NEG_WINDOW = 24   # the plan's 24-token polarity window (a floor, not a parser)
ANCHOR_WINDOW = 12  # I3's anchor window (`A3 item 2` / `item 2 of A3`)
SUBJECT_WINDOW = 8   # I7's 8-token subject->pair binding window
TIME_SCAN_RE = re.compile(r"(?<![0-9])(\d{2}):(\d{2}):(\d{2})(?![0-9])")
QUOTE_SPAN_RE = re.compile(r'"[^"]*"')
I6_DENY_PHRASES = ("times are correct", "times are right", "is correct",
                   "are correct")  # Amendment A1 clause (d), case-insensitive
# Denial predicates (post-token, case-insensitive token sequences).
DENY_SINGLE = frozenset(("denies", "denied", "deny", "refutes", "refuted",
                         "refute", "untrue"))
DENY_PHRASES = (("is", "false"), ("are", "false"), ("not", "true"),
                ("not", "the", "case"), ("no", "such"))
# Idioms (immediately before the token, not a negator): the listed phrase's
# head negator does not count when the idiom occupies the token tail.
IDIOMS = (("not", "only"), ("not", "merely"), ("not", "just"),
          ("no", "fewer", "than"), ("no", "less", "than"))

_SYMLINK_REFUSAL_RELS = (LOG_REL, LESSON60_REL, PLAN60_REL, SKILL_REL,
                         RESULTS60_REL)


class SetupError(Exception):
    """Instrument cannot run (bad root, git unavailable with --repo, challenge
    scratch inside the measured root). Exit 2."""


# --------------------------------------------------------------------------- plumbing
def rd(root: str, rel: str) -> str | None:
    try:
        with open(os.path.join(root, *rel.split("/")), encoding="utf-8",
                  errors="surrogateescape") as f:
            return f.read()
    except OSError:
        return None


def _rd_mut(path: str) -> str:
    with open(path, encoding="utf-8", errors="surrogateescape") as f:
        return f.read()


def _wr_mut(path: str, text: str) -> None:
    with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(text)


def challenge_parent() -> str:
    raw = os.environ.get("C1_CHALLENGE_PARENT")
    if raw:
        return raw
    hs = os.environ.get("HYAKU_SCRATCH")
    if hs:
        return os.path.join(hs, "kagi-r61", "R61ExecCounterC1")
    if os.environ.get("TMPDIR"):
        return os.environ["TMPDIR"]
    return os.path.join("/fast/scratch/hyaku", "kagi-r61", "R61ExecCounterC1")


def _leg_scratch(prefix: str) -> str:
    """A throwaway dir under the shared challenge scratch (never inside the
    measured tree; evaluate() refuses that before any item runs)."""
    par = challenge_parent()
    os.makedirs(par, exist_ok=True)
    return tempfile.mkdtemp(prefix=prefix, dir=par)


def _isolated_env(scratch: str) -> dict:
    env = dict(os.environ)
    env["TMPDIR"] = scratch
    env["HYAKU_SCRATCH"] = scratch
    return env


# --------------------------------------------------------------------------- derivations
def _load_results(root: str) -> list:
    txt = rd(root, RESULTS60_REL)
    if txt is None:
        raise LookupError(".ufo/waves/round-60/w1-results.json missing")
    try:
        data = json.loads(txt)
    except json.JSONDecodeError as e:
        raise LookupError(f"w1-results.json malformed: {e}") from e
    results = data.get("results") if isinstance(data, dict) else data
    if not isinstance(results, list):
        raise LookupError("w1-results.json has no results list")
    return results


def derive_i1(root: str) -> tuple[int, int]:
    """R = number of result records; B = byte length of the single R60MutCounters
    record's final output (utf-8). Raises LookupError (fail closed)."""
    results = _load_results(root)
    matches = [r for r in results
               if isinstance(r, dict) and MUT_RECORD_TOKEN in str(r.get("name", ""))]
    if len(matches) != 1:
        raise LookupError(
            f"{len(matches)} records name {MUT_RECORD_TOKEN} (expected exactly 1)")
    out = matches[0].get("output")
    if not isinstance(out, str):
        raise LookupError("the R60MutCounters record has no output string")
    return len(results), len(out.encode("utf-8"))


def derive_i7(root: str) -> tuple[int, int, int]:
    """(N, A, B): N results; A = attack roles from the plan's literal list present
    among the `agent` values; B = A plus the sentinel when the file shows one."""
    results = _load_results(root)
    agents = [str(r.get("agent", "")) for r in results if isinstance(r, dict)]
    a = len(set(ROLE_SET) & set(agents))
    b = a + (1 if SENTINEL_ROLE in agents else 0)
    return len(results), a, b


def derive_numstat(repo: str) -> tuple[int, int]:
    """`git -C <repo> diff --numstat 14a6c07d 818d2a82 -- LOG.md` -> (ins, dels).
    Raises LookupError (fail closed) on any failure."""
    try:
        cp = subprocess.run(
            ["git", "-C", repo, "diff", "--numstat", REV_A, REV_B, "--", LOG_REL],
            capture_output=True, text=True, timeout=60)
    except (OSError, subprocess.SubprocessError) as e:
        raise LookupError(f"numstat could not run: {e}") from e
    if cp.returncode != 0:
        raise LookupError(f"numstat failed: {(cp.stderr or '').strip()[:120]}")
    for ln in cp.stdout.splitlines():
        m = re.match(r"^(\d+)\s+(\d+)\s+", ln)
        if m:
            return int(m.group(1)), int(m.group(2))
    raise LookupError("numstat produced no numeric row")


def _norm_ci(line: str) -> str | None:
    m = CI_LINE_RE.match(line.strip())
    if not m:
        return None
    return f"{m.group(1)}T{m.group(2)}{m.group(3)}{m.group(4)}:{m.group(5)}"


def derive_ci_set(repo: str) -> set[str]:
    """Normalized committer stamps of `git -C <repo> log --format=%ci
    a677c78e..818d2a82`. Raises LookupError (fail closed)."""
    try:
        cp = subprocess.run(
            ["git", "-C", repo, "log", "--format=%ci",
             f"{REV_RANGE_BASE}..{REV_B}"],
            capture_output=True, text=True, timeout=60)
    except (OSError, subprocess.SubprocessError) as e:
        raise LookupError(f"git log could not run: {e}") from e
    if cp.returncode != 0:
        raise LookupError(f"git log failed: {(cp.stderr or '').strip()[:120]}")
    stamps = {n for ln in cp.stdout.splitlines() if (n := _norm_ci(ln))}
    if not stamps:
        raise LookupError("git log produced no committer stamps")
    return stamps


def derive_fleet_stamp(fleet: str) -> str:
    """The superseded record's launch stamp `HH:MM:SS`, derived from the fleet
    report `{fleet}/.ufo/reports/round-60/kagi.md` §Stale-lane line
    (`launch HH:MM:SS`; the paragraph runs to the next blank line). A missing,
    unreadable or stamp-less report raises SetupError — SETUP (exit 2), never
    a silent pass (plan §C1 I6, §Bounds)."""
    path = os.path.join(fleet, *FLEET_REPORT_REL.split("/"))
    try:
        with open(path, encoding="utf-8", errors="surrogateescape") as f:
            lines = f.read().splitlines()
    except OSError as e:
        raise SetupError(f"fleet report {FLEET_REPORT_REL} unreadable: {e}")
    for i, ln in enumerate(lines):
        if not STALE_LANE_LABEL_RE.search(ln):
            continue
        para = [ln]
        for nxt in lines[i + 1:]:
            if not nxt.strip():
                break
            para.append(nxt)
        m = LAUNCH_HMS_RE.search("\n".join(para))
        if m and _valid_hms(m.group(1)):
            return m.group(1)
        break
    raise SetupError(f"fleet report {FLEET_REPORT_REL} has no "
                     "§Stale-lane 'launch HH:MM:SS' stamp")


# --------------------------------------------------------------------------- round-63 grammar
def _is_negator(tok: str) -> bool:
    t = tok.lower()
    return t in NEGATORS or t.endswith(NT_SUFFIX)


def _mask_quotes(text: str, before: int) -> str:
    """Blank every double-quoted span that ENDS at or before `before` (the
    superseded quotation is not the correction's own assertion). Positions are
    preserved so match offsets stay valid."""
    chars = list(text)
    for m in QUOTE_SPAN_RE.finditer(text):
        if m.end() <= before:
            for i in range(m.start(), m.end()):
                chars[i] = " "
    return "".join(chars)


def _negated_before(text: str, start: int, window: int = NEG_WINDOW) -> bool:
    """True iff an effective negator sits in the `window` tokens before
    position `start`, the window bounded by the nearest `.` or `;` (round-63:
    `:` no longer truncates) and capped at `window` tokens. A negator does not
    count when (iii) it is the head of a listed idiom occupying the token tail
    immediately before the match, or (iv) a `but` token sits between it and
    the match (contrastive `not X but Y` asserts Y). Quote spans ending
    before `start` are masked first (idempotent when `text` is already
    masked, as _asserted passes it)."""
    text = _mask_quotes(text, start)
    cut = 0
    for ch in SENTENCE_CHARS:
        p = text.rfind(ch, 0, start)
        if p >= cut:
            cut = p + 1
    low = [m.group(0).lower() for m in TOKEN_RE.finditer(text, cut, start)]
    low = low[-window:]
    rescued = set()
    for idi in IDIOMS:
        k = len(idi)
        if len(low) >= k and tuple(low[-k:]) == idi:
            rescued.add(len(low) - k)  # the idiom's head negator index
    for i, t in enumerate(low):
        if not _is_negator(t):
            continue
        if i in rescued:
            continue
        if "but" in low[i + 1:]:
            continue  # contrastive: `not … but <token>` asserts the token
        return True
    return False


def _denied_after(mt: str, end: int,
                  window: int = NEG_WINDOW) -> bool:
    """True iff a denial predicate sits between position `end` and the nearest
    `.` or `;` after it, capped at `window` tokens. `mt` is the quote-masked
    text (the mask is applied once, in _asserted)."""
    cut = len(mt)
    for ch in SENTENCE_CHARS:
        p = mt.find(ch, end)
        if 0 <= p < cut:
            cut = p
    post = [m.group(0).lower()
            for m in TOKEN_RE.finditer(mt, end, cut)][:window]
    if any(t in DENY_SINGLE for t in post):
        return True
    for k in range(len(post)):
        for ph in DENY_PHRASES:
            if tuple(post[k:k + len(ph)]) == ph:
                return True
    return False


def _asserted(text: str, start: int, end: int) -> bool:
    """The round-63 asserted-position test: double-quoted spans that END
    before the token are masked once, then no effective pre-token negator
    and no post-token denial predicate."""
    mt = _mask_quotes(text, start)
    return not _negated_before(mt, start) and not _denied_after(mt, end)


def _seq_in_window(text: str, start: int, seq: tuple[str, ...],
                   window: int = ANCHOR_WINDOW) -> bool:
    """The lowercased token sequence `seq` occurs inside the `window` tokens
    before position `start` (I3's anchor window)."""
    toks = [m.group(0).lower()
            for m in TOKEN_RE.finditer(text, 0, start)][-window:]
    n = len(seq)
    return any(toks[i:i + n] == list(seq) for i in range(len(toks) - n + 1))


A3_ITEM2_SEQS = (("a3", "item", "2"), ("item", "2", "of", "a3"))


def _asserted_withdrawn(section: str) -> bool:
    """An occurrence of `withdrawn` whose 12-token window before it contains
    `A3 item 2` or `item 2 of A3` and whose polarity test passes (plan §C1
    I3; the token is tested in the asserting position)."""
    for m in WITHDRAWN_RE.finditer(section):
        if not _asserted(section, m.start(), m.end()):
            continue
        if any(_seq_in_window(section, m.start(), seq)
               for seq in A3_ITEM2_SEQS):
            return True
    return False


def _valid_hms(t: str) -> bool:
    h, m, s = int(t[0:2]), int(t[3:5]), int(t[6:8])
    return h <= 23 and m <= 59 and s <= 59


def _qualifying_times(line: str, launch_time: str | None,
                      derived_times: frozenset[str]) -> set[str]:
    """`HH:MM:SS` times on the line that are neither the launch line's time nor
    a derived committer time — the superseded paragraph's stamp must be among
    them (plan §C1 I6 clause c, QM78/QM79)."""
    return {t.group(0) for t in TIME_SCAN_RE.finditer(line)
            if _valid_hms(t.group(0)) and t.group(0) != launch_time
            and t.group(0) not in derived_times}


def _pair_re(frac: str, pct: str) -> re.Pattern:
    """The I7 pairing: the derived fraction and ITS derived percentage in one
    expression, whitespace-tolerant (`3/16 = 18.75 %`)."""
    ws = r"[ \t]*"
    return re.compile(rf"(?<![0-9]){re.escape(frac)}(?![0-9]){ws}={ws}"
                      rf"(?<![\w.]){re.escape(pct)}(?![\w.]){ws}%")


# --------------------------------------------------------------------------- items
def item1(root: str, repo: str | None, fleet: str | None) -> tuple[str, str]:
    lesson = rd(root, LESSON60_REL)
    if lesson is None:
        return FAIL, "corpus/lessons/round-60.md missing"
    lines = lesson.splitlines()
    anchor = None
    for i, ln in enumerate(lines):
        if R37_ROW_RE.match(ln):
            anchor = i  # the LAST routed `R37` row wins (see docstring reading)
    if anchor is None:
        return FAIL, "no routed row '| R37 |' in the round-60 lesson"
    try:
        r_total, b_bytes = derive_i1(root)
    except LookupError as e:
        return FAIL, f"wave-60 census not derived: {e}"
    candidates = [ln for ln in lines[anchor + 1:]
                  if SUPERSEDES_R37_RE.search(ln)]
    if not candidates:
        return FAIL, "no 'supersedes R37' line after the routed R37 row"
    last = candidates[-1]  # last statement wins
    m = RESULTS_OUTPUT_RE.search(last)
    ok = (m is not None and int(m.group(1)) == r_total
          and int(m.group(2)) == b_bytes and MUTANTS_MD in last)
    det = (f"derived results={r_total} output={b_bytes} "
           f"supersedes-lines-after={len(candidates)} "
           f"last-line={'states-derived-count-and-names-mutants.md'
                        if ok else 'missing-wrong-values-or-no-mutants.md'}")
    return (HOLD if ok else FAIL), det


def _gate_registry_sections(lines: list[str]) -> list[tuple[int, int]]:
    out = []
    for i, ln in enumerate(lines):
        if GATE_REG_HEADING_RE.match(ln):
            end = len(lines)
            for j in range(i + 1, len(lines)):
                if H2_RE.match(lines[j]):
                    end = j
                    break
            out.append((i, end))
    return out


def _scan_registry_table(block: list[str], name_token: str):
    """block = contiguous '|' lines of one table. Returns (line, cells, self_idx)
    for the first data row whose NAME cell contains name_token, else None."""
    parsed = []
    for ln in block:
        # split on unescaped pipes only: registry rows carry `\|` inside cells
        cells = [c.replace("\\|", "|").strip()
                 for c in re.split(r"(?<!\\)\|", ln.strip().strip("|"))]
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
        if cells and all(SEPARATOR_CELL_RE.fullmatch(c) for c in cells if c):
            continue
        if name_idx < len(cells) and name_token in cells[name_idx]:
            return ln, cells, self_idx
    return None


def find_registry_row(text: str, name_token: str):
    """The LAST gate-registry table row whose name cell contains name_token.
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
                row = _scan_registry_table(block, name_token)
                if row is not None:
                    last = row
                i = j
            else:
                i += 1
    return last


def _c2_script_text(script: str) -> str | None:
    if os.path.islink(script):
        return None
    try:
        with open(script, encoding="utf-8", errors="surrogateescape") as f:
            return f.read()
    except OSError:
        return None


def _c2_selftest_run(script: str, cwd: str, timeout: int = SELFTEST_TIMEOUT):
    """Run `bash <script> --selftest` with TMPDIR/HYAKU_SCRATCH redirected into a
    throwaway leg scratch (the measured tree is never written)."""
    scratch = _leg_scratch("c1-i2-")
    try:
        os.makedirs(os.path.join(scratch, "scr"), exist_ok=True)
        try:
            r = subprocess.run(["bash", script, "--selftest"], cwd=cwd,
                               capture_output=True, text=True, timeout=timeout,
                               env=_isolated_env(os.path.join(scratch, "scr")))
        except subprocess.TimeoutExpired:
            return None, f"--selftest timeout {timeout}s"
        except OSError as e:
            return None, f"--selftest could not run: {e}"
        return r, None
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


def _c2_mutation_leg(script: str, text: str) -> tuple[bool, str]:
    """Leg C: copy the script, invert the verdict mapping (the one defined needle,
    which must occur exactly once) and require the copy's --selftest to exit
    non-zero printing >=1 `FINDING C2-ST-` line. Fails closed on any absence,
    ambiguity, timeout or undetected mutation."""
    n = text.count(ST_NEEDLE)
    if n != 1:
        return False, f"mutation needle count={n} (expected exactly 1)"
    tmp = _leg_scratch("c1-i2-mut-")
    try:
        mutated = os.path.join(tmp, "mutated-round-60-c2.sh")
        with open(mutated, "w", encoding="utf-8", errors="surrogateescape") as f:
            f.write(text.replace(ST_NEEDLE, ST_MUTATED))
        r, err = _c2_selftest_run(mutated, cwd=tmp)
        if err is not None or r is None:
            return False, f"mutated --selftest: {err or 'no result'}"
        out = (r.stdout or "") + "\n" + (r.stderr or "")
        finding = bool(FINDING_RE.search(out))
        ok = r.returncode != 0 and finding
        return ok, f"mutated rc={r.returncode} finding={'yes' if finding else 'no'}"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def item2(root: str, repo: str | None, fleet: str | None) -> tuple[str, str]:
    script = os.path.join(root, *C2_SCRIPT_REL.split("/"))
    # leg A: the measured script's own --selftest (isolated fixtures per its
    # contract: no bao, no network; the checker only observes it)
    text = _c2_script_text(script)
    if text is None:
        a_ok, a_det = False, f"{C2_SCRIPT_REL} missing or symlinked"
    else:
        r, err = _c2_selftest_run(script, cwd=root)
        if err is not None or r is None:
            a_ok, a_det = False, err or "no result"
        else:
            out = (r.stdout or "") + "\n" + (r.stderr or "")
            m = None
            for ln in reversed(out.splitlines()):
                mm = C2_PASS_RE.search(ln)
                if mm:
                    m = mm
                    break
            n = int(m.group(1)) if m else None
            a_ok = r.returncode == 0 and n is not None and n >= 6
            a_det = f"rc={r.returncode} cases={n} " + ("PASS-line" if m
                                                       else "no-PASS-line")
    # leg B: the SKILL.md gate-registry row
    sk = rd(root, SKILL_REL)
    if sk is None:
        b_ok, b_det = False, "SKILL.md missing"
    else:
        row = find_registry_row(sk, C2_SCRIPT_TOKEN)
        if row is None:
            b_ok, b_det = False, ("no gate-registry row naming "
                                  "plans/round-60-c2.sh")
        else:
            line, cells, self_idx = row
            cell = cells[self_idx] if self_idx < len(cells) else ""
            b_ok = ("--selftest" in cell and NONE_OWN_LITERAL not in line)
            b_det = (f"selftest-cell={cell.strip()[:40]!r} "
                     f"none-own={'absent' if NONE_OWN_LITERAL not in line
                                 else 'present'}")
    # leg C: the selftest must be shown able to fail on an inverted mapping
    if text is None:
        c_ok, c_det = False, "script missing or symlinked (mutation leg refused)"
    else:
        c_ok, c_det = _c2_mutation_leg(script, text)
    det = f"selftest[{a_det}] registry[{b_det}] mutation[{c_det}]"
    return (HOLD if (a_ok and b_ok and c_ok) else FAIL), det


def item3(root: str, repo: str | None, fleet: str | None) -> tuple[str, str]:
    plan = rd(root, PLAN60_REL)
    if plan is None:
        return FAIL, "plans/round-60.md missing"
    lines = plan.splitlines()
    a6 = None
    for i, ln in enumerate(lines):
        if A6_HEADING_RE.match(ln):
            a6 = i  # last occurrence wins
    if a6 is None:
        return FAIL, "no '### A6' heading in plans/round-60.md"
    block_end = len(lines)
    for j in range(a6 + 1, len(lines)):
        if H2_RE.match(lines[j]):
            block_end = j
            break
    a7s = [i for i, ln in enumerate(lines) if A7_HEADING_RE.match(ln)]
    if not a7s:
        return FAIL, "no '## Amendment A7' heading"
    a7 = a7s[-1]
    if a7 < block_end:
        return FAIL, "the Amendment A7 heading sits before the end of the A6 block"
    sec_end = len(lines)
    for j in range(a7 + 1, len(lines)):
        if H2_RE.match(lines[j]):
            sec_end = j
            break
    section = "\n".join(lines[a7:sec_end])
    a_ok = (A3_ITEM2_RE.search(section) is not None
            and FORM_RE.search(section) is not None
            and L1PROBE_TOKEN in section
            and _asserted_withdrawn(section))
    lesson = rd(root, LESSON60_REL)
    if lesson is None:
        return FAIL, "corpus/lessons/round-60.md missing"
    cands = [ln for ln in lesson.splitlines()
             if M602_TOKEN in ln and A3_ITEM2_RE.search(ln)]
    b_ok = bool(cands) and SECOND_INSTANCE_RE.search(cands[-1]) is not None
    det = (f"a7-at-line={a7 + 1} block-end={block_end + 1} "
           f"amendment={'names-item-form-probe-asserts-withdrawn' if a_ok
                        else 'incomplete'} "
           f"lesson-line={'second-instance' if b_ok else 'missing-or-wrong'}")
    return (HOLD if (a_ok and b_ok) else FAIL), det


def item4(root: str, repo: str | None, fleet: str | None) -> tuple[str, str]:
    lesson = rd(root, LESSON60_REL)
    if lesson is None:
        return FAIL, "corpus/lessons/round-60.md missing"
    candidates = [ln for ln in lesson.splitlines()
                  if QUALITY_TREND_RE.search(ln)]
    if not candidates:
        return FAIL, "no 'supersedes the round-60 quality-trend sentence' line"
    last = candidates[-1]  # last occurrence wins
    count_tokens = list(THREE_RE.finditer(last)) + list(
        COUNT3_RE.finditer(last))
    three_ok = any(_asserted(last, m.start(), m.end())
                   for m in count_tokens)
    ok = (NO_NEW_RECORD_DEFECT_RE.search(last) is not None
          and all(re.search(rf"\bD{n}\b", last) for n in (1, 2, 3))
          and three_ok)
    det = (f"candidates={len(candidates)} "
           f"last-line={'quotes-names-D1-D2-D3-and-asserts-three' if ok
                        else 'missing-quote-ids-or-negated-three'}")
    return (HOLD if ok else FAIL), det


def item5(root: str, repo: str | None, fleet: str | None) -> tuple[str, str]:
    log = rd(root, LOG_REL)
    if log is None:
        return FAIL, "LOG.md missing"
    lines = log.splitlines()
    anchor = None
    for i, ln in enumerate(lines):
        if WAVE_LINE_RE.match(ln):
            anchor = i  # the LAST round-60 wave line wins
    if anchor is None:
        return FAIL, "no '- Wave ... kagi-r60-w1' wave line in LOG.md"
    candidates = [ln for ln in lines[anchor + 1:]
                  if SUPERSEDES_LOG_WAVE_RE.search(ln)]
    if not candidates:
        return FAIL, "no 'supersedes the round-60 LOG wave line' line after it"
    last = candidates[-1]  # last statement wins
    m = NUMSTAT_SHAPE_RE.search(last)
    m_rp = REWITTEN_IN_PLACE_RE.search(last)
    asserted = (m_rp is not None
                and _asserted(last, m_rp.start(), m_rp.end()))
    structural = (m is not None
                  and REV_A in last and REV_B in last
                  and m_rp is not None)
    if repo is None:
        ok = structural and asserted
        det = (f"mode=shape-only repo-not-given stated="
               f"{'insertions/deletions-digits' if m is not None else 'missing'} "
               f"revs={'both' if REV_A in last and REV_B in last else 'missing'} "
               f"mechanism={'rewritten-in-place' if m_rp is not None else 'missing'} "
               f"polarity={'asserted' if asserted else 'not-asserted'}")
        return (HOLD if ok else FAIL), det
    try:
        ins, dels = derive_numstat(repo)
    except LookupError as e:
        return FAIL, f"numstat not derived: {e}"
    ok = (structural and asserted
          and int(m.group(1)) == ins and int(m.group(2)) == dels)
    det = (f"derived insertions={ins} deletions={dels} "
           f"stated={m.group(1) + '/' + m.group(2) if m is not None else 'none'} "
           f"revs={'both' if REV_A in last and REV_B in last else 'missing'} "
           f"mechanism={'rewritten-in-place' if m_rp is not None else 'missing'} "
           f"polarity={'asserted' if asserted else 'not-asserted'}")
    return (HOLD if ok else FAIL), det


def item6(root: str, repo: str | None, fleet: str | None) -> tuple[str, str]:
    lesson = rd(root, LESSON60_REL)
    if lesson is None:
        return FAIL, "corpus/lessons/round-60.md missing"
    candidates = [ln for ln in lesson.splitlines() if STALE_LANE_RE.search(ln)]
    if not candidates:
        return FAIL, "no 'supersedes the round-60 stale-lane paragraph' line"
    last = candidates[-1]  # last occurrence wins
    mlaunch = LAUNCH_LINE_RE.search(last)
    if mlaunch is None:
        return FAIL, "the line does not name the driver launch line"
    mlt = TIME_SCAN_RE.search(mlaunch.group(0))
    launch_time = mlt.group(0) if mlt else None
    stamps = set(TS_RE.findall(last))
    stamps.discard("2026-11-07T15:03:17-03:00")  # the launch stamp is not a commit
    denied = sorted(p for p in I6_DENY_PHRASES if p in last.lower())
    # round-63: the quoted superseded span's HH:MM:SS set must equal exactly
    # the stamp derived from the fleet report's §Stale-lane launch line.
    fleet_dir = fleet if fleet is not None else DEFAULT_FLEET
    fleet_stamp = derive_fleet_stamp(fleet_dir)  # SetupError -> exit 2
    quoted = {t.group(0) for m in QUOTE_SPAN_RE.finditer(last)
              for t in TIME_SCAN_RE.finditer(m.group(0))
              if _valid_hms(t.group(0))}
    superseded_ok = quoted == {fleet_stamp}
    if repo is None:
        superseded = _qualifying_times(last, launch_time, frozenset())
        ok = len(stamps) >= 3 and bool(superseded) and not denied \
            and superseded_ok
        det = (f"mode=shape-only repo-not-given launch=yes distinct-stamps="
               f"{len(stamps)} superseded-stamp={'yes' if superseded else 'no'} "
               f"quoted-stamp={','.join(sorted(quoted)) or 'none'} "
               f"fleet-stamp={fleet_stamp} "
               f"denial={'none' if not denied else '|'.join(denied)}")
        return (HOLD if ok else FAIL), det
    try:
        derived = derive_ci_set(repo)
    except LookupError as e:
        return FAIL, f"committer stamps not derived: {e}"
    qualifying = {t for t in stamps if t in derived}
    superseded = _qualifying_times(last, launch_time,
                                   frozenset(t[11:19] for t in derived))
    ok = len(qualifying) >= 3 and not denied and superseded_ok
    det = (f"launch=yes distinct-stamps={len(stamps)} in-derived={len(qualifying)} "
           f"derived-set={len(derived)} superseded-stamp="
           f"{','.join(sorted(superseded)) if superseded else 'none'} "
           f"quoted-stamp={','.join(sorted(quoted)) or 'none'} "
           f"fleet-stamp={fleet_stamp} "
           f"denial={'none' if not denied else '|'.join(denied)}")
    return (HOLD if ok else FAIL), det


def _fmt_pct(part: int, total: int) -> str:
    return f"{100.0 * part / total:.10g}"


LITERAL_READING_RE = re.compile(r"literal\s+reading", re.IGNORECASE)
SENTINEL_RE = re.compile(r"sentinel", re.IGNORECASE)


def _pair_bound_to_subject(masked: str, subj_re: re.Pattern,
                           pair: re.Pattern) -> bool:
    """True iff `pair` occurs within SUBJECT_WINDOW tokens after some
    occurrence of `subj_re` in the (quote-masked) line."""
    for sm in subj_re.finditer(masked):
        pm = pair.search(masked, sm.end())
        if pm is None:
            continue
        between = TOKEN_RE.findall(masked, sm.end(), pm.start())
        if len(between) <= SUBJECT_WINDOW:
            return True
    return False


def item7(root: str, repo: str | None, fleet: str | None) -> tuple[str, str]:
    lesson = rd(root, LESSON60_REL)
    if lesson is None:
        return FAIL, "corpus/lessons/round-60.md missing"
    candidates = [ln for ln in lesson.splitlines()
                  if ATTACK_SHARE_RE.search(ln)]
    if not candidates:
        return FAIL, "no 'supersedes the round-60 attack-share arithmetic' line"
    last = candidates[-1]  # last occurrence wins
    try:
        n, a, b = derive_i7(root)
    except LookupError as e:
        return FAIL, f"role mix not derived: {e}"
    frac_a, frac_b = f"{a}/{n}", f"{b}/{n}"
    pa, pb = _fmt_pct(a, n), _fmt_pct(b, n)
    # the pairing AND its subject binding are tested in the asserting
    # position: the quoted superseded arithmetic ("4/16 = 25 % on the
    # addendum's literal list") is the forgery of record, not the
    # correction's own claim (QM79); round-63 binds each pair to its
    # subject within SUBJECT_WINDOW tokens.
    asserted = re.sub(r'"[^"]*"', " ", last)
    ok = (_pair_bound_to_subject(asserted, LITERAL_READING_RE,
                                 _pair_re(frac_a, pa))
          and _pair_bound_to_subject(asserted, SENTINEL_RE,
                                     _pair_re(frac_b, pb)))
    det = (f"derived {a}/{n}={pa} {b}/{n}={pb} "
           f"last-line={'both-pairs-bound-to-subjects' if ok
                        else 'pair-missing-swapped-or-unbound'}")
    return (HOLD if ok else FAIL), det


ITEMS = (("i1", item1), ("i2", item2), ("i3", item3), ("i4", item4),
         ("i5", item5), ("i6", item6), ("i7", item7))


# --------------------------------------------------------------------------- guard
def mutate_i5_deletions(tree_dir: str) -> tuple[str | None, str | None]:
    """The challenge's ONLY delta: on the evaluated (LAST) I5 correction line of the
    copy's LOG.md the `deletions=<D>` digit becomes D+1 (1 -> 2 when the line states
    the derived census). The first `insertions=<I> deletions=<D>` occurrence on that
    line only; every other byte of the tree is untouched."""
    path = os.path.join(tree_dir, *LOG_REL.split("/"))
    try:
        text = _rd_mut(path)
    except OSError as e:
        return None, f"LOG.md unreadable in copy: {e}"
    lines = text.splitlines(keepends=True)
    anchor = None
    for i, ln in enumerate(lines):
        if WAVE_LINE_RE.match(ln):
            anchor = i
    if anchor is None:
        return None, "no round-60 wave line in copy"
    target = None
    for i in range(anchor + 1, len(lines)):
        if SUPERSEDES_LOG_WAVE_RE.search(lines[i]):
            target = i  # the evaluated (LAST) I5 correction line
    if target is None:
        return None, "no I5 correction line after the wave line in copy"
    m = NUMSTAT_SHAPE_RE.search(lines[target])
    if m is None:
        return None, "no insertions=/deletions= fields on the evaluated line"
    d = int(m.group(2))

    def repl(mm: re.Match) -> str:
        return f"insertions={mm.group(1)} deletions={d + 1}"

    new_line = NUMSTAT_SHAPE_RE.sub(repl, lines[target], count=1)
    if new_line == lines[target]:
        return None, "deletions digit not mutated"
    lines[target] = new_line
    _wr_mut(path, "".join(lines))
    return f"deletions {d}->{d + 1} on the evaluated I5 line", None


def parse_value(out: str):
    for ln in reversed((out or "").splitlines()):
        if ln.startswith("C1_ROUTED:"):
            m = re.search(r"value=(\d+|FAIL)", ln)
            if m:
                return "FAIL" if m.group(1) == "FAIL" else int(m.group(1))
    return None


def run_value(argv: list[str], timeout: int = 900):
    try:
        r = subprocess.run(argv, capture_output=True, text=True, timeout=timeout)
    except (OSError, subprocess.SubprocessError):
        return None
    return parse_value(r.stdout)


def run_guard(root: str, count: int, repo: str | None, fleet: str | None):
    """Legs 2+3 of the frozen GUARD. Returns (challenge_ok, stub_fails, detail);
    challenge_ok/stub_fails None means the leg could not run (GUARD stays 0)."""
    root_abs = os.path.realpath(root)
    par_abs = os.path.realpath(challenge_parent())
    if par_abs == root_abs or par_abs.startswith(root_abs + os.sep):
        raise SetupError(f"challenge scratch {par_abs} resolves at/inside the "
                         f"measured root {root_abs} (refused, QM74)")
    try:
        os.makedirs(par_abs, exist_ok=True)
        tmp = tempfile.mkdtemp(prefix="c1-challenge-", dir=par_abs)
    except OSError as e:
        return None, None, f"challenge scratch unavailable: {e}"
    try:
        copy = os.path.join(tmp, "tree")
        shutil.copytree(root, copy, symlinks=False,
                        ignore=shutil.ignore_patterns(".git", ".jj"))
        if os.path.realpath(copy) == root_abs:
            return None, None, "challenge copy resolves to the measured tree (refused)"
        changed, err = mutate_i5_deletions(copy)
        if err:
            return False, False, f"challenge not injectable: {err}"
        expect = count + 1
        py = sys.executable or "python3"
        argv = [py, "-I", "-B", os.path.abspath(__file__),
                "--root", copy, "--no-challenge"]
        if repo is not None:
            argv += ["--repo", repo]
        argv += ["--fleet", fleet if fleet is not None else DEFAULT_FLEET]
        v2 = run_value(argv)
        stub = os.path.join(tmp, "stub.py")
        with open(stub, "w", encoding="utf-8") as f:
            f.write('print("C1_ROUTED: value=0 population=7 '
                    'i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")\n')
        sv = run_value([py, "-I", "-B", stub, "--root", copy, "--no-challenge"])
        chal_ok = isinstance(v2, int) and v2 == expect
        stub_fails = not (isinstance(sv, int) and sv == expect)
        detail = (f"copy delta {changed}: value={v2} expect={expect}; "
                  f"stub value={sv} fails={stub_fails}")
        return chal_ok, stub_fails, detail
    except (OSError, shutil.Error, subprocess.SubprocessError) as e:
        return None, None, f"challenge failed: {type(e).__name__}: {e}"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# --------------------------------------------------------------------------- evaluate
def measure(root: str, repo: str | None,
            fleet: str | None = None) -> dict:
    out = {}
    for key, fn in ITEMS:
        try:
            s, d = fn(root, repo, fleet)
        except SetupError:
            raise  # SETUP (exit 2), never a silent item FAIL
        except Exception as e:  # fail closed: an item that cannot be read is not a hold
            s, d = FAIL, f"item raised {type(e).__name__}: {e}"
        out[key] = (s, d)
    return out


def _refuse_symlinks(root: str) -> None:
    for rel in _SYMLINK_REFUSAL_RELS:
        if os.path.islink(os.path.join(root, *rel.split("/"))):
            raise SetupError(f"{rel} is a symlink (refused)")


def _refuse_inside_root(root: str) -> None:
    root_abs = os.path.realpath(root)
    par_abs = os.path.realpath(challenge_parent())
    if par_abs == root_abs or par_abs.startswith(root_abs + os.sep):
        raise SetupError(f"challenge scratch {par_abs} resolves at/inside the "
                         f"measured root {root_abs} (refused, QM74)")


def evaluate(root: str, repo: str | None = None, fleet: str | None = None,
             verbose: bool = False, challenge: bool = True,
             as_json: bool = False) -> int:
    _refuse_symlinks(root)  # refuse to measure symlinked statements/derivations
    if repo is not None and shutil.which("git") is None:
        raise SetupError("git not found on PATH (--repo derivations unavailable)")
    _refuse_inside_root(root)  # QM74 (I2's mutation leg and the GUARD share it)
    fleet_dir = fleet if fleet is not None else DEFAULT_FLEET
    res = measure(root, repo, fleet_dir)
    toks = {k: ("1" if s == HOLD else "0") for k, (s, _) in res.items()}
    population = sum(1 for s, _ in res.values() if s in (HOLD, FAIL))
    count = sum(1 for s, _ in res.values() if s == FAIL)

    if not challenge:
        guard = 0
        value_token = str(count)
        challenge_detail = "not run (--no-challenge); diagnostic count printed"
    else:
        chal_ok, stub_fails, challenge_detail = run_guard(root, count, repo,
                                                        fleet_dir)
        guard = 1 if (population == POP and chal_ok is True
                      and stub_fails is True) else 0
        value_token = str(count) if guard == 1 else "FAIL"

    if as_json:
        print(json.dumps({
            "instrument": "plans/round-61-c1-check.py",
            "root": root,
            "repo": repo,
            "fleet": fleet_dir,
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
RESULTS_GOOD = json.dumps({"lane": "kagi", "round": 60, "wave": "w1", "seats": 16,
                           "results": [
    {"name": "R60ScoutApprole", "agent": "scout", "note": "", "output": "o" * 40},
    {"name": "R60ScoutRouted", "agent": "scout", "note": "", "output": "o" * 40},
    {"name": "R60ExecTrial", "agent": "executor", "note": "", "output": "o" * 40},
    {"name": "R60ExecCounterC1", "agent": "executor", "note": "", "output": "o" * 40},
    {"name": "R60ExecCounterC2", "agent": "executor", "note": "", "output": "o" * 40},
    {"name": "R60ExecFixRecords", "agent": "executor", "note": "", "output": "o" * 40},
    {"name": "R60ExecTransitSelftest", "agent": "executor", "note": "",
     "output": "o" * 40},
    {"name": "R60ScribeEntry", "agent": "scribe", "note": "", "output": "o" * 40},
    {"name": "R60ScribeRows", "agent": "scribe", "note": "", "output": "o" * 40},
    {"name": "R60ExecControls", "agent": "executor", "note": "", "output": "o" * 40},
    {"name": "R60ReviewerC1", "agent": "reviewer", "note": "", "output": "o" * 40},
    {"name": "R60CriticClaims", "agent": "critic", "note": "", "output": "o" * 40},
    {"name": "R60MutCounters", "agent": "mutation-tester", "note": "",
     "output": "m" * 3824},
    {"name": "R60SentinelTrial", "agent": "sentinel", "note": "", "output": "o" * 40},
    {"name": "R60ConnectorSiblings", "agent": "connector", "note": "",
     "output": "o" * 40},
    {"name": "R60RevContext", "agent": "revenger", "note": "", "output": "o" * 40},
]}, indent=1) + "\n"

LOG_GOOD = (
    "# LOG (fixture)\n\n"
    "## Round 60\n\n"
    "- Wave `kagi-r60-w1`, 16 seats v1 (`.ufo/waves/round-60/w1-dispatch.json`): "
    "dead seats 0.\n"
    "- Correction (round-61 C1 I5, spot-check D5): supersedes the round-60 LOG wave "
    "line above — it was rewritten in place at `818d2a82` against `14a6c07d` "
    "(insertions=1 deletions=1: the superseded `dead seats 1` sentence replaced by "
    "`dead seats 0`) instead of an appended correction; the superseded text is "
    "recoverable at `14a6c07d`, and this line is the correction of record.\n"
)

LESSON60_GOOD = (
    "# Round 60 — lesson (fixture)\n\n"
    "## Routed dispositions\n\n"
    "| # | finding | disposition |\n"
    "|---|---|---|\n"
    "| R36 | attack-share arithmetic: 4/16 = 25 % on the literal list | recorded |\n"
    "| R37 | the mutation-tester seat produced no artifacts and no report | routed |\n\n"
    "## Bounds\n\n"
    "- The wave's 16th seat (mutation-tester) produced nothing.\n\n"
    "## Correction (round 61)\n\n"
    "- Correction (I1, spot-check D1): supersedes R37 and the Bounds line — measured "
    "over `.ufo/waves/round-60/w1-results.json`, results=16 output=3824 (16 result "
    "records; the `R60MutCounters` record's final output is 3824 bytes), and the seat "
    "delivered `.ufo/waves/round-60/build/R60MutCounters/mutants.md`.\n"
    "- Correction (I3, spot-check D3): mistake M60-2 mined only §A3 item 4 — §A3 "
    "item 2 is the second instance of the same mistake class; the plan withdraws it "
    "in Amendment A7.\n"
    "- Correction (I4, spot-check D4): supersedes the round-60 quality-trend sentence "
    "\"The round introduced no new record defect that it did not itself route\" — the "
    "round introduced three new record defects it did not route: D1 (the false "
    "no-artifacts claim), D2 (the gate registered with `none of its own`) and D3 (the "
    "receipt-free form-encoded claim).\n"
    "- Correction (I6, spot-check D6): supersedes the round-60 stale-lane paragraph "
    "(\"launch 15:09:28 −03\" with commit times matching neither author nor committer "
    "stamps) — the driver line is `2026-11-07T15:03:17-03:00 launch kagi round=60` "
    "(complete `2026-11-07T16:34:37-03:00`), and the committer stamps "
    "`2026-11-07T15:06:58-03:00`, `2026-11-07T15:14:19-03:00`, "
    "`2026-11-07T15:18:26-03:00`, `2026-11-07T15:47:01-03:00` each occur in "
    "`git log --format='%ci' a677c78e..818d2a82`: the lane was progressing, "
    "not stale.\n"
    "- Correction (I7, spot-check D7): supersedes the round-60 attack-share "
    "arithmetic \"4/16 = 25 % on the addendum's literal list\" — the literal list has "
    "three present roles so the literal reading is 3/16 = 18.75 %, and counting the "
    "sentinel as an attack seat gives 4/16 = 25 %; the round states both readings.\n"
)

PLAN60_GOOD = (
    "# plans/round-60.md (fixture)\n\n"
    "## C2 — operability\n\n"
    "Frozen predicate text.\n\n"
    "## Shape and write scope\n\n"
    "### A3 — feasibility probe\n\n"
    "2. **Every request carries `Content-Type: application/json`.** A form-encoded "
    "body variant.\n\n"
    "### A6 — 2026-11-07, before the recorded candidate reading (I5's scope token)\n\n"
    "A6 body: the scope token reading stands.\n\n"
    "## Amendment A7 — 2026-11-07, after the round-60 closure\n\n"
    "Spot-check D3: §A3 item 2 asserts a form-encoded-body behaviour its cited "
    "receipt `.ufo/waves/round-60/final/l1-probe.txt` does not carry; **A3 item 2 is "
    "withdrawn**. No predicate, target, POP, item or kill rule changes.\n"
)

SKILL_GOOD = (
    "# SKILL (fixture)\n\n"
    "## Gate registry — round-60 additions\n\n"
    "| name | kind | entry command | verdict map | selftest | pinned values | "
    "write scope | owner |\n"
    "|---|---|---|---|---|---|---|---|\n"
    "| AppRole custody counter (`plans/round-60-c2.sh`) | gate | "
    "`bash plans/round-60-c2.sh [revision \\| --tree DIR]` | 0 value=5; 1 <5; "
    "2 SETUP | `bash plans/round-60-c2.sh --selftest` ⇒ `C2_SELFTEST: PASS "
    "(cases=N)`, fixture-driven, fails with named `FINDING` ids on a mutated copy | "
    "fixture | fixture | kagi |\n"
)

C2_GOOD = r"""#!/usr/bin/env bash
# fixture plans/round-60-c2.sh --selftest (round-61 checker selftest fixture).
# Mirrors the fixed counter's selftest contract: fixture-driven, no bao, no
# network; a broken verdict mapping must fail with a named FINDING.
cases=0; failed=0
ck() { cases=$((cases+1)); if [ "$2" != "$3" ]; then failed=$((failed+1)); echo "FINDING C2-ST-$1 got=$2 want=$3"; fi; }
verdict() { case "$2" in T1|T2|T3|T4|T5) echo HOLDS;; *) echo NONE;; esac; }
vec() { local i v=""; for i in 1 2 3 4 5; do v="$v$(verdict "$1" "T$i" | cut -c1)"; done; echo "$v"; }
case "${1:-}" in
  --selftest) ;;
  *) echo "C2_SELFTEST: SETUP usage"; exit 2;;
esac
ck vec-mapping "$(vec out)" "HHHHH"
ck vec-inverted-detects "$( [ "$(vec out | tr HB BH)" = "BBBBB" ] && echo detect || echo miss)" "detect"
ck verdict-holds "$(verdict out T3)" "HOLDS"
ck verdict-none "$(verdict out T9)" "NONE"
ck tlines-count "$(printf 'TRIAL T1 HOLDS\nTRIAL T2 HOLDS\nTRIAL T3 HOLDS\nTRIAL T4 HOLDS\nTRIAL T5 HOLDS\n' | grep -cE '^TRIAL T[0-9]+( |$)')" "5"
ck summary-shape "$(printf 'C2_SELFTEST: PASS (cases=6)' | grep -cE '^C2_SELFTEST: PASS \(cases=[0-9]+\)$')" "1"
if [ "$failed" -gt 0 ]; then
  echo "C2_SELFTEST: FAIL (cases=$cases failed=$failed)"
  exit 1
fi
echo "C2_SELFTEST: PASS (cases=$cases)"
exit 0
"""

ONLY_FILES = {
    "i1": (LESSON60_REL, RESULTS60_REL),
    "i2": (C2_SCRIPT_REL, SKILL_REL),
    "i3": (PLAN60_REL, LESSON60_REL),
    "i4": (LESSON60_REL,),
    "i5": (LOG_REL,),
    "i6": (LESSON60_REL,),
    "i7": (LESSON60_REL, RESULTS60_REL),
}

_FIXTURE_TEXTS = {
    LOG_REL: LOG_GOOD,
    LESSON60_REL: LESSON60_GOOD,
    PLAN60_REL: PLAN60_GOOD,
    SKILL_REL: SKILL_GOOD,
    RESULTS60_REL: RESULTS_GOOD,
    C2_SCRIPT_REL: C2_GOOD,
}


def w(root: str, rel: str, text: str) -> None:
    p = os.path.join(root, *rel.split("/"))
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as f:
        f.write(text)


def mk_tree(base: str, only: str | None = None) -> str:
    os.makedirs(base, exist_ok=True)
    rels = (LOG_REL, LESSON60_REL, PLAN60_REL, SKILL_REL, RESULTS60_REL,
            C2_SCRIPT_REL) if only is None else ONLY_FILES[only]
    for rel in rels:
        w(base, rel, _FIXTURE_TEXTS[rel])
    return base

FLEET_REPORT = (
    "# fleet report (fixture)\n\n"
    "## Round 60\n\n"
    "Stale-lane: the round is `progressing`, not stale — launch 15:09:28 -03, "
    "lane commits at 15:10 and 16:33, all inside the mission window.\n"
)


def mk_fleet(base: str) -> str:
    """A scratch fleet root carrying the round-60 report the I6 derivation
    reads (`{fleet}/.ufo/reports/round-60/kagi.md` §Stale-lane)."""
    os.makedirs(base, exist_ok=True)
    w(base, FLEET_REPORT_REL, FLEET_REPORT)
    return base


def build_fixture_repo(path: str) -> str:
    """A scratch git repo whose tags are LITERALLY named a677c78e / 14a6c07d /
    818d2a82 so the checker's frozen-revision derivations run end-to-end against
    it: 14a6c07d..818d2a82 rewrites LOG.md's wave line in place (1 insertion,
    1 deletion) and a677c78e..818d2a82 carries four committer stamps. Mutating
    git ONLY inside this fixture dir (toplevel asserted)."""
    os.makedirs(path, exist_ok=True)  # git -C <dir> init needs the dir to exist
    env = dict(os.environ,
               GIT_AUTHOR_NAME="fixture", GIT_AUTHOR_EMAIL="fixture@fixture.invalid",
               GIT_COMMITTER_NAME="fixture",
               GIT_COMMITTER_EMAIL="fixture@fixture.invalid")

    def g(*a, date=None, check=True):
        e = dict(env)
        if date:
            e["GIT_AUTHOR_DATE"] = date
            e["GIT_COMMITTER_DATE"] = date
        r = subprocess.run(["git", "-C", path, *a], capture_output=True,
                           text=True, env=e, timeout=60)
        if check and r.returncode != 0:
            raise RuntimeError(f"git {' '.join(a[:3])} failed: "
                               f"{(r.stderr or '').strip()[:160]}")
        return r

    g("-c", "init.defaultBranch=main", "init")
    top = g("rev-parse", "--show-toplevel").stdout.strip()
    if os.path.realpath(top) != os.path.realpath(path):
        raise RuntimeError("fixture repo toplevel mismatch")
    os.makedirs(os.path.join(path, "docs"), exist_ok=True)
    w(path, "docs/README.md", "# fixture repo base\n")
    g("add", "-A")
    g("-c", "user.name=fixture", "-c", "user.email=fixture@fixture.invalid",
      "commit", "-m", "base")
    g("tag", REV_RANGE_BASE)
    log1 = ("- Wave `kagi-r60-w1`, 16 seats v1: dead seats 1.\n")
    w(path, LOG_REL, "# LOG (fixture repo)\n\n" + log1)
    g("add", "-A")
    g("-c", "user.name=fixture", "-c", "user.email=fixture@fixture.invalid",
      "commit", "-m", "wave line", date="2026-11-07 15:06:58 -0300")
    g("tag", REV_A)
    w(path, LOG_REL, ("# LOG (fixture repo)\n\n"
                      "- Wave `kagi-r60-w1`, 16 seats v1: dead seats 0.\n"))
    g("add", "-A")
    g("-c", "user.name=fixture", "-c", "user.email=fixture@fixture.invalid",
      "commit", "-m", "rewrite wave line in place",
      date="2026-11-07 15:14:19 -0300")
    w(path, "docs/other-a.txt", "a\n")
    g("add", "-A")
    g("-c", "user.name=fixture", "-c", "user.email=fixture@fixture.invalid",
      "commit", "-m", "other a", date="2026-11-07 15:18:26 -0300")
    w(path, "docs/other-b.txt", "b\n")
    g("add", "-A")
    g("-c", "user.name=fixture", "-c", "user.email=fixture@fixture.invalid",
      "commit", "-m", "other b", date="2026-11-07 15:47:01 -0300")
    g("tag", REV_B)
    return path


def quiet_evaluate(*a, **k) -> tuple[int, str]:
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = evaluate(*a, **k)
    return rc, buf.getvalue()


def run_selftest(work: str | None = None) -> int:
    try:
        return _run_selftest(work)
    except Exception as e:  # an environment that cannot build the fixtures fails loudly
        print(f"C1_CHECK_SELFTEST: FAIL (cases=0 failed=0) "
              f"fixture-environment={type(e).__name__}: {e}")
        return 1


def _run_selftest(work: str | None = None) -> int:
    if work:
        os.makedirs(work, exist_ok=True)
        top = work
        persistent = True
    else:
        top = tempfile.mkdtemp(prefix="c1-check-selftest-")
        persistent = False
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
    repo = None
    try:
        good = mk_tree(os.path.join(top, "good"))
        repo = build_fixture_repo(os.path.join(top, "repo"))
        fleet = mk_fleet(os.path.join(top, "fleet"))
        case("fleet-stamp-derived",
             derive_fleet_stamp(fleet) == "15:09:28")

        # -- unit: derivations --
        case("derive-results-16-3-4", derive_i7(good) == (16, 3, 4))
        case("derive-mut-bytes-3824", derive_i1(good) == (16, 3824))
        case("fixture-repo-toplevel",
             os.path.realpath(subprocess.run(
                 ["git", "-C", repo, "rev-parse", "--show-toplevel"],
                 capture_output=True, text=True).stdout.strip())
             == os.path.realpath(repo))
        case("derive-numstat-1-1", derive_numstat(repo) == (1, 1))
        ci = derive_ci_set(repo)
        case("derive-ci-set-4-stamps", len(ci) == 4
             and "2026-11-07T15:06:58-03:00" in ci
             and "2026-11-07T15:47:01-03:00" in ci)
        case("norm-ci-format",
             _norm_ci("2026-11-07 15:06:58 -0300") == "2026-11-07T15:06:58-03:00"
             and _norm_ci("not a stamp") is None
             and _norm_ci("2026-11-07 15:06:58 -0330") == "2026-11-07T15:06:58-03:30")

        # -- unit: the guard mutation is only the deletions digit --
        mut = mk_tree(os.path.join(top, "mut"))
        desc, err = mutate_i5_deletions(mut)
        mut_log = rd(mut, LOG_REL) or ""
        case("mutate-deletions-digit-only",
             err is None and desc is not None and "deletions 1->2" in desc
             and "insertions=1 deletions=2" in mut_log
             and "insertions=1 deletions=1" not in mut_log
             and mut_log.count("deletions=2") == 1
             and "rewritten in place" in mut_log and "818d2a82" in mut_log)

        # -- unit: registry row parsing --
        row = find_registry_row(SKILL_GOOD, C2_SCRIPT_TOKEN)
        case("registry-row-found",
             row is not None and "--selftest" in row[1][row[2]]
             and NONE_OWN_LITERAL not in row[0])
        bad_skill = SKILL_GOOD.replace(
            "`bash plans/round-60-c2.sh --selftest` ⇒ `C2_SELFTEST: PASS "
            "(cases=N)`, fixture-driven, fails with named `FINDING` ids on a "
            "mutated copy",
            "none of its own — it runs the trial's --selftest as a conjunct")
        row_bad = find_registry_row(bad_skill, C2_SCRIPT_TOKEN)
        case("registry-none-own-detected",
             row_bad is not None and NONE_OWN_LITERAL in row_bad[0])

        # -- items on the all-resolved fixture --
        res = measure(good, repo, fleet)
        case("aggregate-good-all-hold",
             all(s == HOLD for s, _ in res.values()) and len(res) == POP)

        # -- evaluate legs --
        rc, out = quiet_evaluate(good, repo=repo, challenge=False, fleet=fleet)
        case("evaluate-no-challenge-good",
             rc == 1 and "value=0" in out and "guard=0" in out
             and "population=7" in out and "i7=1" in out)
        rc, out = quiet_evaluate(good, repo=repo, verbose=True, challenge=True, fleet=fleet)
        case("evaluate-guard-good-tree",
             rc == 0 and "value=0" in out and "guard=1" in out
             and "expect=1" in out and "fails=True" in out
             and "deletions 1->2" in out)

        # -- the shape-only fallback (no --repo) --
        rc, out = quiet_evaluate(good, repo=None, challenge=False, fleet=fleet)
        case("no-repo-good-shape-only",
             rc == 1 and "value=0" in out and "population=7" in out
             and "i5=1" in out and "i6=1" in out
             and "mode=shape-only repo-not-given" in out)
        rc, out = quiet_evaluate(good, repo=None, challenge=True, fleet=fleet)
        case("no-repo-guard-cannot-fire",
             rc == 1 and "value=FAIL" in out and "guard=0" in out)

        empty = os.path.join(top, "empty")
        os.makedirs(empty, exist_ok=True)
        rc, out = quiet_evaluate(empty, repo=repo, challenge=False, fleet=fleet)
        case("evaluate-all-unresolved-7",
             rc == 1 and "value=7" in out and "population=7" in out
             and "guard=0" in out and all(f"i{k}=0" in out for k in range(1, 8)))
        rc, out = quiet_evaluate(empty, repo=repo, challenge=True, fleet=fleet)
        case("evaluate-all-unresolved-guard-fails-closed",
             rc == 1 and "value=FAIL" in out and "guard=0" in out)

        # -- each item resolving alone --
        # ONLY_FILES share corpus/lessons/round-60.md across i1/i3/i4/i6/i7, so an
        # only-X tree resolves EVERY item whose inputs it carries; the expected
        # (value, resolved-set) per tree is fixed by that overlap and asserted in
        # full — item k reads 1 exactly when ONLY_FILES[k] is covered.
        ONLY_EXPECT = {
            "i1": (3, {1, 4, 6, 7}),   # lesson + results
            "i2": (6, {2}),            # c2 script + skill row
            "i3": (4, {3, 4, 6}),      # plan + lesson (no results json)
            "i4": (5, {4, 6}),         # lesson only
            "i5": (6, {5}),            # log only
            "i6": (5, {4, 6}),         # lesson only
            "i7": (3, {1, 4, 6, 7}),   # lesson + results
        }
        for k in range(1, 8):
            key = f"i{k}"
            tree = mk_tree(os.path.join(top, f"only-{key}"), only=key)
            rc, out = quiet_evaluate(tree, repo=repo, challenge=False, fleet=fleet)
            want_v, resolved = ONLY_EXPECT[key]
            case(f"only-{key}-resolves",
                 rc == 1 and f"value={want_v}" in out
                 and all(f"i{j}={1 if j in resolved else 0}"
                         for j in range(1, 8)))

        # -- forgery / fail-closed fixtures: I1 --
        bad = mk_tree(os.path.join(top, "bad-i1-bytes"))
        w(bad, LESSON60_REL, LESSON60_GOOD.replace("results=16 output=3824",
                                                   "results=16 output=3823"))
        case("i1-wrong-bytes", item1(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i1-nomutants"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace("build/R60MutCounters/mutants.md",
                                "build/R60MutCounters/raw/"))
        case("i1-no-mutants-md", item1(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i1-restated"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD + "- Correction (I1, restated): supersedes R37 — "
          "results=16 output=3823 (a later wrong restatement in the same "
          "correction section).\n")
        case("i1-later-restatement-wins", item1(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i1-decoy"))
        w(bad, LESSON60_REL,
          "# an early line mentioning R37 in prose\n" + LESSON60_GOOD)
        case("i1-decoy-mention-no-relocate", item1(bad, repo, fleet)[0] == HOLD)
        bad_log = ("# Round 60 — lesson\n\n"
                   "- Correction (I1): supersedes R37 — results=16 output=3824, "
                   "mutants.md.\n\n"
                   "| # | finding | disposition |\n|---|---|---|\n"
                   "| R37 | the mutation-tester seat produced nothing | routed |\n")
        bad = mk_tree(os.path.join(top, "bad-i1-order"))
        w(bad, LESSON60_REL, bad_log)
        case("i1-correction-before-row", item1(bad, repo, fleet)[0] == FAIL)

        # -- forgery / fail-closed fixtures: I2 --
        # drop two assertions -> PASS (cases=4), below the N >= 6 floor
        bad = mk_tree(os.path.join(top, "bad-i2-cases4"), only="i2")
        w(bad, C2_SCRIPT_REL,
          C2_GOOD.replace('ck verdict-none "$(verdict out T9)" "NONE"\n', '')
                 .replace('ck tlines-count', '# dropped: ck tlines-count'))
        case("i2-selftest-cases-below-6", item2(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i2-exit1"), only="i2")
        w(bad, C2_SCRIPT_REL,
          C2_GOOD.replace('echo "C2_SELFTEST: PASS (cases=$cases)"\nexit 0\n',
                          'echo "C2_SELFTEST: PASS (cases=$cases)"\nexit 1\n'))
        case("i2-selftest-exit1", item2(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i2-noneedle"), only="i2")
        w(bad, C2_SCRIPT_REL,
          C2_GOOD.replace('verdict "$1" "T$i" | cut -c1)"',
                          'verdict "$1" "T$i" | awk \'{print substr($0,1,1)}\')"'))
        case("i2-no-needle-fails-closed", item2(bad, repo, fleet)[0] == FAIL)
        # the two vec assertions swapped for neutral ones: leg A still PASSes 6
        # cases, but the inverted copy is UNDETECTED -> leg C must fail closed
        bad = mk_tree(os.path.join(top, "bad-i2-undetected"), only="i2")
        w(bad, C2_SCRIPT_REL,
          C2_GOOD.replace('ck vec-mapping "$(vec out)" "HHHHH"\n',
                          'ck neutral-a "$( [ -z "" ] && echo ok || echo no)" "ok"\n')
                 .replace('ck vec-inverted-detects "$( [ "$(vec out | tr HB BH)"'
                          ' = "BBBBB" ] && echo detect || echo miss)" "detect"\n',
                          'ck neutral-b "$( [ 1 -eq 1 ] && echo ok || echo no)"'
                          ' "ok"\n'))
        case("i2-mutation-undetected", item2(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i2-registry"), only="i2")
        w(bad, SKILL_REL, bad_skill)
        case("i2-registry-none-own", item2(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i2-absent"), only="i2")
        os.remove(os.path.join(bad, *C2_SCRIPT_REL.split("/")))
        rc, out = quiet_evaluate(bad, repo=repo, challenge=False, fleet=fleet)
        # the absent script leaves i2 UNRESOLVED (population stays 7) — never SETUP
        case("i2-absent-script-unresolved-not-setup",
             rc == 1 and "value=7" in out and "population=7" in out
             and "i2=0" in out and "SETUP" not in out)

        # -- forgery / fail-closed fixtures: I3 --
        bad = mk_tree(os.path.join(top, "bad-i3-before"))
        w(bad, PLAN60_REL,
          PLAN60_GOOD.replace("## Amendment A7", "## Amendment A0-marker")
                     .replace("### A3 — feasibility probe",
                              "## Amendment A7 — misplaced\n\n### A3 — feasibility probe"))
        case("i3-a7-before-a6", item3(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i3-nowithdrawn"))
        w(bad, PLAN60_REL,
          PLAN60_GOOD.replace("**A3 item 2 is "
                              "withdrawn**", "**A3 item 2 is narrowed**"))
        case("i3-a7-withdraws-nothing", item3(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i3-lesson"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace("§A3 "
                                "item 2 is the second instance of the same mistake class",
                                "§A3 item 2 is a fresh mistake"))
        case("i3-lesson-second-instance-missing", item3(bad, repo, fleet)[0] == FAIL)

        # -- forgery / fail-closed fixtures: I4 --
        bad = mk_tree(os.path.join(top, "bad-i4-nod3"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace("and D3 (the "
                                "receipt-free form-encoded claim)", ""))
        case("i4-missing-d3", item4(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i4-four"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace("introduced three new "
                                "record defects", "introduced four new record defects"))
        case("i4-wrong-count", item4(bad, repo, fleet)[0] == FAIL)

        # -- forgery / fail-closed fixtures: I5 --
        bad = mk_tree(os.path.join(top, "bad-i5-dels2"))
        w(bad, LOG_REL, LOG_GOOD.replace("insertions=1 deletions=1",
                                         "insertions=1 deletions=2"))
        case("i5-stated-dels-vs-derived", item5(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i5-mechanism"))
        w(bad, LOG_REL, LOG_GOOD.replace("rewritten in place", "appended twice"))
        case("i5-mechanism-missing", item5(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i5-same-shape-no-repo"))
        w(bad, LOG_REL, LOG_GOOD.replace("insertions=1 deletions=1",
                                         "insertions=7 deletions=9"))
        case("i5-shape-only-without-repo", item5(bad, None, fleet)[0] == HOLD)
        case("i5-shape-derived-with-repo", item5(bad, repo, fleet)[0] == FAIL)

        # -- forgery / fail-closed fixtures: I6 --
        # one stamp swapped for an invented one AND one real stamp removed:
        # only two stamps remain derivable -> below the "at least three" floor
        bad = mk_tree(os.path.join(top, "bad-i6-foreign"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace("2026-11-07T15:18:26-03:00",
                                "2026-11-07T09:99:99-03:00")
                       .replace("`2026-11-07T15:47:01-03:00` ", ""))
        case("i6-foreign-timestamp", item6(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i6-two"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace("`2026-11-07T15:18:26-03:00`, "
                                "`2026-11-07T15:47:01-03:00` ", ""))
        case("i6-only-two-stamps", item6(bad, repo, fleet)[0] == FAIL)

        # -- forgery / fail-closed fixtures: I7 --
        bad = mk_tree(os.path.join(top, "bad-i7-pct"))
        w(bad, LESSON60_REL, LESSON60_GOOD.replace("3/16 = 18.75 %",
                                                   "3/16 = 19 %"))
        case("i7-wrong-pct", item7(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad-i7-frac"))
        w(bad, LESSON60_REL, LESSON60_GOOD.replace("gives 4/16 = 25 %",
                                                   "gives 5/16 = 25 %"))
        case("i7-wrong-fraction", item7(bad, repo, fleet)[0] == FAIL)

        # -- round-62 QM79 bypass fixtures (plans/round-62.md §C1): B3..B7 --
        bad = mk_tree(os.path.join(top, "b3"))
        w(bad, PLAN60_REL,
          PLAN60_GOOD.replace("**A3 item 2 is withdrawn**",
                              "**A3 item 2 is not withdrawn**"))
        case("b3-negated-withdrawn-unresolved", item3(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "b4"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace(
              "the round introduced three new record defects it did not route",
              "the round introduced no three new record defects it did not "
              "route"))
        case("b4-no-three-unresolved", item4(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "b5"))
        w(bad, LOG_REL,
          LOG_GOOD.replace("it was rewritten in place at",
                           "it was not rewritten in place at"))
        case("b5-not-rewritten-unresolved", item5(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "b6"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace("the lane was progressing, not stale.",
                                "the paragraph's times are correct."))
        case("b6-tail-denial-unresolved", item6(bad, repo, fleet)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "b7"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace(
              "so the literal reading is 3/16 = 18.75 %, and counting the "
              "sentinel as an attack seat gives 4/16 = 25 %",
              "so the literal reading is 3/16 = 25 %, and counting the "
              "sentinel as an attack seat gives 4/16 = 18.75 %"))
        case("b7-swapped-pairing-unresolved", item7(bad, repo, fleet)[0] == FAIL)
        # the reviewer's whole-line variant: the correction defends the forged
        # paragraph and quotes no superseded stamp (Amendment A1 rationale)
        m_i6line = re.search(r"- Correction \(I6,[^\n]*", LESSON60_GOOD)
        bad = mk_tree(os.path.join(top, "b6-wholeline"))
        w(bad, LESSON60_REL, LESSON60_GOOD.replace(
            m_i6line.group(0) if m_i6line else "",
            "- Correction (I6, spot-check D6): supersedes the round-60 "
            "stale-lane paragraph — the paragraph's times are correct."))
        case("b6-wholeline-no-superseded-stamp-unresolved",
             m_i6line is not None and item6(bad, repo, fleet)[0] == FAIL)
        # benign I6: the correction keeps its conclusion and reads resolved
        case("i6-benign-conclusion-resolved", item6(good, repo, fleet)[0] == HOLD)

        # -- QM79 paraphrase fixtures: P3..P5 keep the assertion --
        bad = mk_tree(os.path.join(top, "p3"))
        w(bad, PLAN60_REL,
          PLAN60_GOOD.replace("**A3 item 2 is withdrawn**",
                              "**A3 item 2 is hereby withdrawn**"))
        case("p3-hereby-resolved", item3(bad, repo, fleet)[0] == HOLD)
        bad = mk_tree(os.path.join(top, "p4"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace(
              "the round introduced three new record defects it did not route",
              "this round did introduce three new record defects it did not "
              "route"))
        case("p4-did-introduce-resolved", item4(bad, repo, fleet)[0] == HOLD)
        bad = mk_tree(os.path.join(top, "p5"))
        w(bad, LOG_REL,
          LOG_GOOD.replace("it was rewritten in place at",
                           "it was rewritten in place, at"))
        case("p5-comma-resolved", item5(bad, repo, fleet)[0] == HOLD)
        for pid, (rel, old, new) in (
                ("p3", (PLAN60_REL, "**A3 item 2 is withdrawn**",
                       "**A3 item 2 is hereby withdrawn**")),
                ("p4", (LESSON60_REL,
                        "the round introduced three new record defects it did "
                        "not route",
                        "this round did introduce three new record defects it "
                        "did not route")),
                ("p5", (LOG_REL, "it was rewritten in place at",
                        "it was rewritten in place, at"))):
            tree = mk_tree(os.path.join(top, f"full-{pid}"))
            w(tree, rel, _FIXTURE_TEXTS[rel].replace(old, new))
            rc, out = quiet_evaluate(tree, repo=repo, challenge=False, fleet=fleet)
            case(f"full-{pid}-value0",
                 rc == 1 and "value=0" in out and "guard=0" in out
                 and "population=7" in out)

        # -- round-63 frozen forgery fixtures F1..F10 (plans/round-63.md §C1):
        # each must read UNRESOLVED on its copy --
        for fid, rel, old, new, item in (
            ("f1", PLAN60_REL, "**A3 item 2 is withdrawn**",
             "**A3 item 2 is hardly withdrawn**", item3),
            ("f2", PLAN60_REL, "**A3 item 2 is withdrawn**",
             "**A3 item 2 is withdrawn — the record denies it**", item3),
            ("f3", PLAN60_REL, "**A3 item 2 is withdrawn**",
             "**A3 item 2 is not, as the earlier draft asserted, withdrawn**",
             item3),
            ("f4", LESSON60_REL,
             "the round introduced three new record defects it did not route",
             'the round introduced "three new record defects it did not '
             'route", a claim the record refutes', item4),
            ("f5", LESSON60_REL,
             "the round introduced three new record defects it did not route",
             "the round did not introduce: three new record defects it did "
             "not route", item4),
            ("f6", LESSON60_REL,
             "the round introduced three new record defects it did not route",
             "the round did not introduce, as the earlier claim had it, three "
             "new record defects it did not route", item4),
            ("f7", LOG_REL, "it was rewritten in place at",
             "it was not, contrary to the earlier record's claim, rewritten "
             "in place at", item5),
            ("f8", LESSON60_REL,
             "so the literal reading is 3/16 = 18.75 %, and counting the "
             "sentinel as an attack seat gives 4/16 = 25 %",
             "so the literal reading is 4/16 = 25 %, and counting the "
             "sentinel as an attack seat gives 3/16 = 18.75 %", item7),
            ("f9", LESSON60_REL, "launch 15:09:28 −03",
             "launch 16:59:59 −03", item6),
            ("f10", LESSON60_REL, "launch 15:09:28 −03",
             "launch 15:09:28 −03 (also seen at 16:59:59 −03)", item6)):
            tree = mk_tree(os.path.join(top, f"fx-{fid}"))
            w(tree, rel, _FIXTURE_TEXTS[rel].replace(old, new))
            rc, out = quiet_evaluate(tree, repo=repo, challenge=False,
                                     fleet=fleet)
            case(f"{fid}-forgery-unresolved",
                 rc == 1 and item(tree, repo, fleet)[0] == FAIL)

        # -- round-63 frozen benign fixtures P1..P6 (plans/round-63.md §C1):
        # each must read RESOLVED on its copy --
        for pid, rel, old, new, item in (
            ("p1", PLAN60_REL, "**A3 item 2 is withdrawn**",
             "**Item 2 of A3 is withdrawn**", item3),
            ("p2", PLAN60_REL, "**A3 item 2 is withdrawn**",
             "**A3 item 2 is not merely withdrawn**", item3),
            ("p3b", LESSON60_REL,
             "the round introduced three new record defects it did not route",
             "the round introduced no fewer than three new record defects it "
             "did not route", item4),
            ("p4b", LESSON60_REL,
             "the round introduced three new record defects it did not route",
             "the round introduced 3 new record defects it did not route",
             item4),
            ("p5b", LOG_REL, "it was rewritten in place at",
             "it was not appended but rewritten in place at", item5),
            ("p6", LOG_REL, "it was rewritten in place at",
             "it was rewritten in-place at", item5)):
            tree = mk_tree(os.path.join(top, f"fx-{pid}"))
            w(tree, rel, _FIXTURE_TEXTS[rel].replace(old, new))
            case(f"{pid}-benign-resolved", item(tree, repo, fleet)[0] == HOLD)

        # -- I6 superseded-stamp conjunct isolation (GM5 witness): the launch
        # line, the >=3 derived committer stamps and the denial exclusion all
        # hold; only the quoted superseded span's stamp is wrong --
        bad = mk_tree(os.path.join(top, "i6-stamp-conjunct"))
        w(bad, LESSON60_REL,
          LESSON60_GOOD.replace('"launch 15:09:28 −03"',
                                '"launch 15:09:29 −03"'))
        case("i6-superseded-stamp-conjunct-isolated",
             item6(bad, repo, fleet)[0] == FAIL)
        # and the fleet report itself missing is SETUP, never a silent pass
        raised = False
        try:
            quiet_evaluate(good, repo=repo, challenge=False,
                           fleet=os.path.join(top, "no-such-fleet"))
        except SetupError:
            raised = True
        case("i6-missing-fleet-report-is-setup", raised)

        # -- round-63 grammar unit cases: the new negators, the post-token
        # denial predicates, the idiom/contrastive rescues and the quote mask
        # --
        case("negator-round63-membership",
             all(_is_negator(t) for t in ("hardly", "barely", "scarcely",
                                          "rarely", "seldom", "Hardly"))
             and _negated_before("A3 item 2 is hardly withdrawn",
                                 "A3 item 2 is hardly withdrawn".index(
                                     "withdrawn")))
        line = "A3 item 2 is withdrawn — the record denies it"
        st = line.index("withdrawn")
        case("denial-after-token-detected",
             _asserted(line, st, st + len("withdrawn")) is False)
        line = "the round introduced three new record defects it did not route"
        st = line.index("three")
        case("post-token-not-route-not-denial",
             _asserted(line, st, st + 5) is True)
        line = "A3 item 2 is not merely withdrawn"
        st = line.index("withdrawn")
        case("not-merely-idiom-rescues",
             _asserted(line, st, st + len("withdrawn")) is True)
        line = "it was not appended but rewritten in place at"
        st = line.index("rewritten")
        case("contrastive-but-rescues",
             _asserted(line, st, st + len("rewritten in place")) is True)
        line = 'the record says "A3 item 2 is not withdrawn" — A3 item 2 is withdrawn'
        st = line.rindex("withdrawn")
        case("quoted-span-masked",
             _asserted(line, st, st + len("withdrawn")) is True)

        # -- unit: the QM79 negator grammar --
        case("negator-set-membership",
             all(_is_negator(t) for t in ("not", "Not", "NOT", "no", "never",
                                          "neither", "nor", "without", "none",
                                          "isn't", "wasn't", "n't"))
             and not any(_is_negator(t) for t in ("noteworthy", "nothing",
                                                  "notice", "only", "known",
                                                  "nobody", "notch")))
        line = "does not carry; A3 item 2 is withdrawn. No predicate"
        st = line.index("withdrawn")
        case("window-truncated-at-boundary",
             _negated_before(line, st) is False
             and _seq_in_window(line, st, ("a3", "item", "2")))
        line = "A3 item 2 is not withdrawn here"
        case("window-negator-detected",
             _negated_before(line, line.index("withdrawn")))
        line = ("the round introduced no three new record defects "
                "it did not route")
        case("window-no-three-negated",
             _negated_before(line, line.index("three")))
        line = "the sentence ends. not only withdrawn but superseded"
        st = line.index("withdrawn")
        case("not-only-idiom-not-negator",
             _negated_before(line, st) is False)
        line = "not only a, then withdrawn"
        case("mid-window-not-only-still-negator",
             _negated_before(line, line.index("withdrawn")))
        # round-63 window bound: a negator 6..24 tokens before the token still
        # negates (kills a 24->5 narrowing); one 25+ tokens before does not
        # (kills a 24->48 widening)
        near = "not " + " ".join(f"w{i}" for i in range(9)) + " withdrawn"
        case("window-negator-at-10-tokens",
             _negated_before(near, near.index("withdrawn")))
        far = "not " + " ".join(f"w{i}" for i in range(30)) + " withdrawn"
        case("window-negator-at-31-tokens-ignored",
             _negated_before(far, far.index("withdrawn")) is False)
        rx = _pair_re("3/16", "18.75")
        case("pair-regex-whitespace-tolerant",
             all(rx.search(s) for s in ("is 3/16 = 18.75 %,", "3/16=18.75%",
                                        "3/16  =\t18.75\t%;"))
             and rx.search("3/16 = 25 %") is None
             and rx.search("13/16 = 18.75 %") is None
             and rx.search("3/16 = 118.75 %") is None)
        case("qualifying-times-validate-and-exclude",
             _valid_hms("15:09:28") and not _valid_hms("09:99:99")
             and _qualifying_times(
                 "quotes 15:09:28, launch 15:03:17, commit 15:06:58, done",
                 "15:03:17", frozenset(("15:06:58",))) == {"15:09:28"}
             and _qualifying_times("only 15:03:17 and 15:06:58 here",
                                   "15:03:17",
                                   frozenset(("15:06:58",))) == set())

        # -- K5 witness: removing the negator test accepts the B3 forgery --
        with open(os.path.abspath(__file__), encoding="utf-8") as f:
            src = f.read()
        k5_needle = ("return t in NEGATORS or t.endswith"
                     "(NT_SUFFIX)")
        case("k5-negator-needle-unique", src.count(k5_needle) == 1)
        kdir = os.path.join(top, "k5")
        os.makedirs(kdir, exist_ok=True)
        mut_path = os.path.join(kdir, "mutated-c1-check.py")
        with open(mut_path, "w", encoding="utf-8") as f:
            f.write(src.replace(k5_needle, "return False"))
        b3tree = os.path.join(top, "b3")
        r = subprocess.run(
            [sys.executable or "python3", "-I", "-B", mut_path,
             "--root", b3tree, "--repo", repo, "--fleet", fleet,
             "--no-challenge"],
            capture_output=True, text=True, timeout=300)
        case("k5-negator-removed-accepts-b3",
             r.returncode == 1 and "value=0" in r.stdout and "i3=1" in r.stdout)

        # -- challenge +1 firing on a tree with unresolved items --
        only5 = mk_tree(os.path.join(top, "only-i5-challenge"), only="i5")
        rc, out = quiet_evaluate(only5, repo=repo, verbose=True, challenge=True, fleet=fleet)
        case("challenge-plus1-fires-with-unresolved",
             rc == 1 and "value=6" in out and "guard=1" in out
             and "expect=7" in out and "value=7" in out)

        # -- QM74 refusal --
        os.environ["C1_CHALLENGE_PARENT"] = os.path.join(good, "inside")
        raised = False
        try:
            quiet_evaluate(good, repo=repo, challenge=True, fleet=fleet)
        except SetupError:
            raised = True
        case("qm74-refusal-inside-root", raised)
        os.environ["C1_CHALLENGE_PARENT"] = scratch

        # -- parse_value tokens --
        case("parse-value-tokens",
             parse_value("x\nC1_ROUTED: value=FAIL population=7 guard=0") == "FAIL"
             and parse_value("C1_ROUTED: value=3 population=7 guard=1") == 3
             and parse_value("nothing") is None)

        # -- symlinked statement file refused with SETUP (never measured) --
        sym_tree = mk_tree(os.path.join(top, "sym-tree"))
        outside = os.path.join(top, "outside-log.md")
        with open(outside, "w", encoding="utf-8") as f:
            f.write(LOG_GOOD)
        os.remove(os.path.join(sym_tree, *LOG_REL.split("/")))
        os.symlink(outside, os.path.join(sym_tree, *LOG_REL.split("/")))
        raised = False
        try:
            quiet_evaluate(sym_tree, repo=repo, challenge=True, fleet=fleet)
        except SetupError:
            raised = True
        with open(outside, encoding="utf-8") as f:
            outside_after = f.read()
        case("symlinked-log-refused-setup",
             raised and outside_after == LOG_GOOD
             and "insertions=1 deletions=1" in outside_after)
    finally:
        if old_parent is None:
            os.environ.pop("C1_CHALLENGE_PARENT", None)
        else:
            os.environ["C1_CHALLENGE_PARENT"] = old_parent
        if not persistent:
            shutil.rmtree(top, ignore_errors=True)

    # -- SETUP leg (subprocess, no fixture tree) --
    r = subprocess.run([sys.executable or "python3", "-I", "-B",
                        os.path.abspath(__file__), "--root", "/nonexistent-c1-root"],
                       capture_output=True, text=True)
    case("setup-missing-root-rc2",
         r.returncode == 2 and "C1_ROUTED: SETUP" in r.stdout)

    if failures:
        print(f"C1_CHECK_SELFTEST: FAIL (cases={cases} failed={len(failures)} "
              f"names={','.join(failures)})")
        return 1
    print(f"C1_CHECK_SELFTEST: PASS (cases={cases})")
    return 0


# --------------------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser(add_help=True,
                                 description="C1_ROUTED counter (round 61)")
    ap.add_argument("--root", default=".", help="measured tree (default: cwd)")
    ap.add_argument("--repo", default=None,
                    help="lane repository used for the named-revision derivations "
                         "(I5: git diff --numstat 14a6c07d 818d2a82 -- LOG.md; "
                         "I6: git log --format=%%ci a677c78e..818d2a82)")
    ap.add_argument("--fleet", default=DEFAULT_FLEET,
                    help="fleet root the I6 derivation reads "
                         "(.ufo/reports/round-60/kagi.md §Stale-lane)")
    ap.add_argument("--no-challenge", action="store_true",
                    help="diagnostic leg: print the unresolved count with guard=0")
    ap.add_argument("--json", action="store_true", help="one JSON object on stdout")
    ap.add_argument("--verbose", action="store_true",
                    help="c1-guard challenge detail line")
    ap.add_argument("--selftest", action="store_true", help="synthetic-tree selftest")
    ap.add_argument("--work", default=None,
                    help="selftest work dir (default: a TMPDIR scratch, removed)")
    args = ap.parse_args()
    if args.selftest:
        return run_selftest(args.work)
    root = os.path.abspath(args.root)
    if not os.path.isdir(root):
        print(f"C1_ROUTED: SETUP no measured tree at {root}")
        return 2
    try:
        return evaluate(root, repo=args.repo, fleet=args.fleet,
                        verbose=args.verbose,
                        challenge=not args.no_challenge, as_json=args.json)
    except SetupError as e:
        print(f"C1_ROUTED: SETUP {e}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
