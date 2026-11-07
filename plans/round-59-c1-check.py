#!/usr/bin/env python3
"""plans/round-59-c1-check.py — the C1_ROUTED counter (kagi round 59).

Freezes plans/round-59.md §C1 (predeclaration af7b665106749e24c02758f8d79e39a05aa3c905):

    C1_ROUTED: value = the number of UNRESOLVED items over POP = 5 fixed routed-defect
    items (I1..I5), when GUARD = 1, else FAIL; target 0 (BASE 5).
    An item is UNRESOLVED iff its named condition does not hold on the measured tree.
    GUARD = 1 iff the checker evaluates all five items (prints population=5 with
    i1..i5 each 0|1, none skipped) and, on a copy of the measured tree whose only delta
    is the digit after the arrow on the LAST `Registry N → M at the candidate` line of
    corpus/lessons/round-58.md changed from M to M+1, prints exactly value+1, and a
    printer stub that always prints value=0 population=5 fails that same challenge.

Every number an item compares is derived at run time; no constant below carries a fact
the measured tree asserts. The two revision hashes are data-source selectors, not facts:

  I1  `git show <rev>:corpus/SOURCES.md` row census at the round-58 claim BASE
      1b13f5dad921f8901f56d30c428f89614dd74d8a and the round-58 landing
      be8705f8b08054cfb96db8d2b70e4234c1a2992f, compared with the LAST lesson line of
      the form `Registry <N> → <M> at the candidate` (append-only: last wins).
  I2  `git diff <BASE> <LAND> -- corpus/source-fetches.tsv` added-row count (lines
      starting `+S`), compared with the first unsigned integer after the file name on
      the LAST lesson line naming corpus/source-fetches.tsv.
  I3  (a) total `CONTROL ` / `CONTROL C1-F` / `CONTROL C2-F` line counts derived from
      .ufo/waves/round-58/controls/controls-prefreeze.txt on the measured tree, all
      three stated on the LAST lesson line naming controls-prefreeze.txt;
      (b) plans/round-58-controls-supplement.sh names both C1-F10 and C2-F4, and
      .ufo/waves/round-59/final/supplement-receipt.txt ends with the exact frozen line
      `SUPPLEMENT: match=2 mismatch=0`.
  I4  the LAST line of .ufo/waves/round-59/final/citation-gate-r59.txt matches
      `CITATION_GATE: … unresolved=<U> …` and the LAST lesson line naming that path
      states `unresolved=<U>` with the same U.
  I5  the mission duration in whole minutes derived from the two driver-digest
      timestamps (… launch kagi / … complete kagi) in
      corpus/lessons/round-58-verifier-spotcheck.md, stated together with the word
      `progressing` on the LAST `stale-lane:` line of the round-58 lesson.

Frozen-condition readings taken where the plan wording allowed more than one structural
read (each is the code's behaviour, named here so a reviewer can disagree precisely):
  - I2 "first unsigned integer after the file name" = the first whole digit-run after
    the FIRST occurrence of the path in that line; a correction line must therefore
    place the delta integer immediately after the path, before any commit hash.
  - I3(a) "states all three counts" = the line contains each derived integer as a
    whole number; order and labels are free.
  - I3(b) "ends with the line" = the file's last non-empty line equals the frozen
    line exactly (whitespace-stripped).
  - I4/I3 receipt files are trusted (named ceiling K3); the lesson line must carry the
    same `unresolved=<U>` digit-run as the receipt's last line.
  - I5 `stale-lane:` and `progressing` match case-insensitively; the last
    `stale-lane:` line is selected by subject alone and must then state the derived
    minute count as a whole number and `progressing` — the literal "carries a line"
    is harmonized with §C1's named "last occurrence wins" correction convention and
    kill rule K1 (a later wrong `stale-lane:` line must leave the item unresolved,
    which the C1-F5 forgery control asserts; an existential reading would read 0 on
    that forged tree and void the claim).
  - A tree missing an item's input file reads the item UNRESOLVED (population stays 5),
    per "UNRESOLVED iff its named condition does not hold"; GUARD then reads 0 because
    the challenge cannot inject its delta.
  - QM74: a challenge scratch resolving at/inside the measured root is refused with
    SETUP rc 2; a challenge scratch that cannot be created leaves GUARD = 0 (fail
    closed), it never fakes a pass.

Usage:
    python3 -I -B plans/round-59-c1-check.py --root <tree> [--no-challenge] [--json]
                                             [--verbose] [--repo <git-repo>] [--selftest]
Output: one `c1:` evidence line per item (the derived number it compared), then
    C1_ROUTED: value=<V|FAIL> population=5 i1=<0|1> i2=<0|1> i3=<0|1> i4=<0|1> i5=<0|1> guard=<0|1>
(--no-challenge prints the diagnostic count as V with guard=0; --json prints one JSON
object instead.)  Exit 0 iff guard=1 and value=0; 1 otherwise; 2 SETUP.
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
from datetime import datetime

R58_BASE = "1b13f5dad921f8901f56d30c428f89614dd74d8a"  # round-58 claim BASE (selector)
R58_LAND = "be8705f8b08054cfb96db8d2b70e4234c1a2992f"  # round-58 landing (selector)

LESSON_REL = "corpus/lessons/round-58.md"
SPOTCHECK_REL = "corpus/lessons/round-58-verifier-spotcheck.md"
SOURCES_REL = "corpus/SOURCES.md"
FETCHES_REL = "corpus/source-fetches.tsv"
CONTROLS_REL = ".ufo/waves/round-58/controls/controls-prefreeze.txt"
SUPPLEMENT_REL = "plans/round-58-controls-supplement.sh"
SUPP_RECEIPT_REL = ".ufo/waves/round-59/final/supplement-receipt.txt"
CITATION_REL = ".ufo/waves/round-59/final/citation-gate-r59.txt"
SUPPLEMENT_LINE = "SUPPLEMENT: match=2 mismatch=0"

REGISTRY_LINE_RE = re.compile(r"Registry\s+(\d+)\s*→\s*(\d+)\s+at the candidate")
S_ROW_RE = re.compile(r"(?m)^\|[ \t]*S\d{3,}[ \t]*\|")
CITATION_GATE_RE = re.compile(r"CITATION_GATE:.*?unresolved=(\d+)")
UNRESOLVED_RE = re.compile(r"unresolved=(\d+)")
DIGEST_RE = r"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:Z|[+-]\d{2}:?\d{2})?)\s+(launch|complete)\s+kagi\b"

HOLD, FAIL, SKIP = "HOLD", "FAIL", "SKIP"
POP = 5
GIT_ENV_STRIP = ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_OBJECT_DIRECTORY",
                 "GIT_ALTERNATE_OBJECT_DIRECTORIES", "GIT_COMMON_DIR")


class SetupError(Exception):
    """Instrument cannot run (bad root, no repository with the pinned revisions,
    challenge scratch resolving inside the measured root). Exit 2."""


class GitError(Exception):
    """A read-only git derivation failed."""


class Ctx:
    __slots__ = ("repo", "base_rev", "land_rev")

    def __init__(self, repo: str, base_rev: str, land_rev: str) -> None:
        self.repo, self.base_rev, self.land_rev = repo, base_rev, land_rev


# --------------------------------------------------------------------------- plumbing
def rd(root: str, rel: str) -> str | None:
    try:
        with open(os.path.join(root, *rel.split("/")), encoding="utf-8",
                  errors="surrogateescape") as f:
            return f.read()
    except OSError:
        return None


def last_line(text: str | None, pred) -> str | None:
    hit = None
    for ln in (text.splitlines() if text else []):
        if pred(ln):
            hit = ln
    return hit


def last_nonempty_line(text: str | None) -> str | None:
    for ln in reversed((text or "").splitlines()):
        if ln.strip():
            return ln.strip()
    return None


def short(rev: str) -> str:
    return rev[:8]


def git_run(repo: str, *args: str, timeout: int = 600) -> str:
    env = {k: v for k, v in os.environ.items() if k not in GIT_ENV_STRIP}
    try:
        r = subprocess.run(["git", "-C", repo, *args], capture_output=True,
                           text=True, env=env, timeout=timeout)
    except (OSError, subprocess.SubprocessError) as e:
        raise GitError(f"git {args[0]} {args[1] if len(args) > 1 else ''}: {e}") from e
    if r.returncode != 0:
        raise GitError(f"git {args[0]} rc={r.returncode}: {(r.stderr or '').strip()[:160]}")
    return r.stdout


def _is_git(d: str) -> bool:
    return os.path.isdir(os.path.join(d, ".git")) or os.path.isfile(os.path.join(d, ".git"))


def resolve_repo(root: str, repo_arg: str | None, base_rev: str, land_rev: str,
                 extra_cands: tuple = ()) -> str:
    cands: list[str] = []
    if repo_arg:
        cands.append(os.path.abspath(repo_arg))
    cands.append(os.path.abspath(root))
    cands.extend(os.path.abspath(c) for c in extra_cands if c)
    tried: list[str] = []
    for c in cands:
        if not _is_git(c):
            tried.append(f"{c}:no-.git")
            continue
        try:
            git_run(c, "cat-file", "-e", f"{base_rev}^{{commit}}")
            git_run(c, "cat-file", "-e", f"{land_rev}^{{commit}}")
            return c
        except GitError as e:
            tried.append(f"{c}:{e}")
    raise SetupError(
        f"no git repository carrying both pinned revisions "
        f"{short(base_rev)},{short(land_rev)} (tried {'; '.join(tried)}; pass --repo)")


# --------------------------------------------------------------------------- derivations
def derive_registry_counts(ctx: Ctx) -> tuple[int, int]:
    """Row census of corpus/SOURCES.md at the two pinned revisions
    (`git show <rev>:corpus/SOURCES.md | grep -cE '^\\|[[:space:]]*S[0-9]{3,}[[:space:]]*\\|'`)."""
    n_base = len(S_ROW_RE.findall(git_run(ctx.repo, "show", f"{ctx.base_rev}:{SOURCES_REL}")))
    n_land = len(S_ROW_RE.findall(git_run(ctx.repo, "show", f"{ctx.land_rev}:{SOURCES_REL}")))
    return n_base, n_land


def derive_fetches_delta(ctx: Ctx) -> int:
    """Added-row count (`git diff <BASE> <LAND> -- corpus/source-fetches.tsv | grep -c '^+S'`)."""
    out = git_run(ctx.repo, "diff", ctx.base_rev, ctx.land_rev, "--", FETCHES_REL)
    return sum(1 for ln in out.splitlines() if ln.startswith("+S"))


def derive_mission_minutes(root: str) -> tuple[int, str, str]:
    spot = rd(root, SPOTCHECK_REL)
    if spot is None:
        raise LookupError("driver-digest file missing")
    stamps: dict[str, str] = {}
    for m in re.finditer(DIGEST_RE, spot):
        stamps[m.group(2)] = m.group(1)
    if "launch" not in stamps or "complete" not in stamps:
        raise LookupError("driver-digest launch/complete timestamps not found")
    t0 = datetime.fromisoformat(stamps["launch"])
    t1 = datetime.fromisoformat(stamps["complete"])
    return int((t1 - t0).total_seconds() // 60), stamps["launch"], stamps["complete"]


def derive_control_counts(root: str) -> tuple[int, int, int]:
    ctl = rd(root, CONTROLS_REL)
    if ctl is None:
        raise LookupError("controls receipt missing")
    lines = ctl.splitlines()
    return (sum(1 for ln in lines if "CONTROL " in ln),
            sum(1 for ln in lines if "CONTROL C1-F" in ln),
            sum(1 for ln in lines if "CONTROL C2-F" in ln))


# --------------------------------------------------------------------------- items
def item1(root: str, ctx: Ctx) -> tuple[str, str]:
    line = last_line(rd(root, LESSON_REL), lambda ln: REGISTRY_LINE_RE.search(ln))
    if line is None:
        return FAIL, "no 'Registry N → M at the candidate' line in the lesson"
    m = REGISTRY_LINE_RE.search(line)
    n_base, n_land = derive_registry_counts(ctx)
    det = (f"registry lesson={m.group(1)}->{m.group(2)} "
           f"derived base({short(ctx.base_rev)})={n_base} land({short(ctx.land_rev)})={n_land}")
    ok = (int(m.group(1)), int(m.group(2))) == (n_base, n_land)
    return (HOLD if ok else FAIL), det


def item2(root: str, ctx: Ctx) -> tuple[str, str]:
    line = last_line(rd(root, LESSON_REL), lambda ln: FETCHES_REL in ln)
    if line is None:
        return FAIL, "no lesson line names corpus/source-fetches.tsv"
    m = re.search(re.escape(FETCHES_REL) + r"\D*?(\d+)", line)
    stated = int(m.group(1)) if m else None
    delta = derive_fetches_delta(ctx)
    det = f"fetches lesson first-int-after-name={stated} derived diff(+S lines)={delta}"
    return (HOLD if stated == delta else FAIL), det


def item3(root: str, ctx: Ctx) -> tuple[str, str]:
    line = last_line(rd(root, LESSON_REL), lambda ln: "controls-prefreeze.txt" in ln)
    total, c1, c2 = derive_control_counts(root)
    lesson_ints = [int(x) for x in re.findall(r"\d+", line)] if line else []
    a_ok = line is not None and all(n in lesson_ints for n in (total, c1, c2))
    supp = rd(root, SUPPLEMENT_REL)
    b_script = supp is not None and "C1-F10" in supp and "C2-F4" in supp
    rec_last = last_nonempty_line(rd(root, SUPP_RECEIPT_REL))
    b_receipt = rec_last == SUPPLEMENT_LINE
    det = (f"controls lesson ints={lesson_ints[:8]} derived total={total} c1F={c1} c2F={c2} "
           f"supplement={'ok' if b_script else 'missing-or-not-naming-C1-F10+C2-F4'} "
           f"receipt_end={(rec_last[:48] + '…') if rec_last and len(rec_last) > 48 else rec_last}")
    return (HOLD if (a_ok and b_script and b_receipt) else FAIL), det


def item4(root: str, ctx: Ctx) -> tuple[str, str]:
    gate_line = last_nonempty_line(rd(root, CITATION_REL))
    mg = CITATION_GATE_RE.search(gate_line) if gate_line else None
    u_gate = int(mg.group(1)) if mg else None
    line = last_line(rd(root, LESSON_REL), lambda ln: "citation-gate-r59.txt" in ln)
    ml = UNRESOLVED_RE.search(line) if line else None
    u_lesson = int(ml.group(1)) if ml else None
    det = f"citation gate-U={u_gate} lesson-U={u_lesson}"
    ok = u_gate is not None and u_lesson is not None and u_gate == u_lesson
    return (HOLD if ok else FAIL), det


def item5(root: str, ctx: Ctx) -> tuple[str, str]:
    try:
        minutes, t_launch, t_complete = derive_mission_minutes(root)
    except (LookupError, ValueError) as e:
        return FAIL, f"mission minutes not derived: {e}"
    # Last occurrence wins (§C1 correction convention; load-bearing for K1/C1-F5):
    # the lesson's stale-lane statement is its LAST `stale-lane:` line; the derived
    # minutes and `progressing` are then required on that selected line.
    line = last_line(rd(root, LESSON_REL), lambda ln: "stale-lane:" in ln.lower())
    if line is None:
        return FAIL, (f"stale-lane derived minutes={minutes} "
                      f"({t_launch} → {t_complete}) lesson_line=missing")
    ok = ("progressing" in line.lower()
          and minutes in [int(x) for x in re.findall(r"\d+", line)])
    det = (f"stale-lane derived minutes={minutes} ({t_launch} → {t_complete}) "
           f"lesson_line={'stated' if ok else 'wrong-or-incomplete'}")
    return (HOLD if ok else FAIL), det


ITEMS = (("i1", item1), ("i2", item2), ("i3", item3), ("i4", item4), ("i5", item5))


# --------------------------------------------------------------------------- guard
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
        return os.path.join(hs, "kagi-r59", "R59ExecCounterC1")
    if os.environ.get("TMPDIR"):
        return os.environ["TMPDIR"]
    return os.path.join("/fast/scratch/hyaku", "kagi-r59", "R59ExecCounterC1")


def mutate_last_registry_arrow(tree_dir: str) -> tuple[str | None, str | None]:
    """The challenge's ONLY delta: on the LAST `Registry N → M at the candidate` line,
    the digit after the arrow changes from M to M+1."""
    path = os.path.join(tree_dir, *LESSON_REL.split("/"))
    try:
        text = _rd_mut(path)
    except OSError as e:
        return None, f"lesson unreadable in copy: {e}"
    matches = list(REGISTRY_LINE_RE.finditer(text))
    if not matches:
        return None, "no 'Registry N → M at the candidate' line to mutate"
    m = matches[-1]
    old, new = m.group(2), str(int(m.group(2)) + 1)
    _wr_mut(path, text[:m.start(2)] + new + text[m.end(2):])
    return f"{old}->{new}", None


def parse_value(out: str) -> int | str | None:
    for ln in reversed((out or "").splitlines()):
        if ln.startswith("C1_ROUTED:"):
            m = re.search(r"value=(\d+|FAIL)", ln)
            if m:
                return "FAIL" if m.group(1) == "FAIL" else int(m.group(1))
    return None


def run_value(argv: list[str], timeout: int = 900):
    r = subprocess.run(argv, capture_output=True, text=True, timeout=timeout)
    return parse_value(r.stdout)


def run_guard(root: str, count: int, ctx: Ctx) -> tuple[bool | None, bool | None, str]:
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
        shutil.copytree(root, copy, symlinks=True,
                        ignore=shutil.ignore_patterns(".git", ".jj"))
        if os.path.realpath(copy) == root_abs:
            return None, None, "challenge copy resolves to the measured tree (refused)"
        changed, err = mutate_last_registry_arrow(copy)
        if err:
            return False, False, f"challenge not injectable: {err}"
        expect = count + 1
        py = sys.executable or "python3"
        v2 = run_value([py, "-I", "-B", os.path.abspath(__file__), "--root", copy,
                        "--repo", ctx.repo, "--base-rev", ctx.base_rev,
                        "--land-rev", ctx.land_rev, "--no-challenge"])
        stub = os.path.join(tmp, "stub.py")
        with open(stub, "w", encoding="utf-8") as f:
            f.write('print("C1_ROUTED: value=0 population=5 '
                    'i1=1 i2=1 i3=1 i4=1 i5=1 guard=0")\n')
        sv = run_value([py, "-I", "-B", stub, "--root", copy, "--no-challenge"])
        chal_ok = isinstance(v2, int) and v2 == expect
        stub_fails = not (isinstance(sv, int) and sv == expect)
        detail = (f"copy delta arrow {changed}: value={v2} expect={expect}; "
                  f"stub value={sv} fails={stub_fails}")
        return chal_ok, stub_fails, detail
    except (OSError, shutil.Error, subprocess.SubprocessError) as e:
        return None, None, f"challenge failed: {type(e).__name__}: {e}"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# --------------------------------------------------------------------------- evaluate
def measure(root: str, ctx: Ctx) -> dict:
    out = {}
    for key, fn in ITEMS:
        try:
            s, d = fn(root, ctx)
        except Exception as e:  # fail closed: an item that cannot be read is not a hold
            s, d = FAIL, f"item raised {type(e).__name__}: {e}"
        out[key] = (s, d)
    return out


def evaluate(root: str, ctx: Ctx, verbose: bool = False, challenge: bool = True,
             as_json: bool = False) -> int:
    res = measure(root, ctx)
    toks = {k: {"HOLD": "1", "FAIL": "0", "SKIP": "x"}[s] for k, (s, _) in res.items()}
    population = sum(1 for s, _ in res.values() if s != SKIP)
    skipped = [k for k, (s, _) in res.items() if s == SKIP]
    count = sum(1 for s, _ in res.values() if s == FAIL)

    if not challenge:
        guard = 0
        value_token = str(count)
        challenge_detail = "not run (--no-challenge); diagnostic count printed"
    elif skipped:
        guard = 0
        value_token = "FAIL"
        challenge_detail = f"not run: skipped items {','.join(skipped)}"
    else:
        chal_ok, stub_fails, challenge_detail = run_guard(root, count, ctx)
        guard = 1 if (population == POP and chal_ok is True and stub_fails is True) else 0
        value_token = str(count) if guard == 1 else "FAIL"

    if as_json:
        print(json.dumps({
            "instrument": "plans/round-59-c1-check.py",
            "root": root, "repo": ctx.repo,
            "base_rev": ctx.base_rev, "land_rev": ctx.land_rev,
            "value": value_token, "value_diagnostic": count,
            "population": population,
            "items": {k: (1 if s == HOLD else 0 if s == FAIL else "SKIP")
                      for k, (s, _) in res.items()},
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
SPOTCHECK_T = (
    "# Round 58 — verifier spot-check (non-author closure)\n\n"
    "Driver digest:\n\n"
    "    2026-11-07T11:54:48-03:00 launch kagi round=58 pgid=2514153 driver=hyaku-inline attempt=1\n"
    "    2026-11-07T13:36:19-03:00 complete kagi round=58; hyaku-inline attempt=1\n"
)
CONTROLS_T = (
    "CONTROL C1-F1 no-work expect=5 got=5 MATCH\n"
    "CONTROL C1-F2 no-work expect=5 got=5 MATCH\n"
    "CONTROL C1-F3 no-work expect=5 got=5 MATCH\n"
    "CONTROL C1-F4 no-work expect=5 got=5 MATCH\n"
    "CONTROL C2-F1 shim expect=4 got=4 MATCH\n"
    "CONTROL C2-F2 shim expect=4 got=4 MATCH\n"
    "CONTROL C2-F3 shim expect=4 got=4 MATCH\n"
    "CONTROLS: match=7 mismatch=0\n"
)
SUPPLEMENT_T = "#!/usr/bin/env bash\n# C1-F10 printer-stub challenge + C2-F4 single-run leg\n"
SUPP_RECEIPT_T = "seal: fixture run\nSUPPLEMENT: match=2 mismatch=0\n"
CITATION_T = "earlier noise\nCITATION_GATE: fixture re-read unresolved=7 scope=ok\n"


def lesson_ok(n_line: str, m_line: str, fetches: str, controls: str, citation: str,
              minutes: str) -> str:
    return (
        "# Round 58 — lesson (fixture)\n\n"
        "## Sources\n\n"
        f"- Registry {n_line} → {m_line} at the candidate (fixture rows).\n"
        f"- Correction (D2): corpus/source-fetches.tsv {fetches} added rows between the "
        "pinned revisions.\n"
        f"- Correction (D3): .ufo/waves/round-58/controls/controls-prefreeze.txt census is "
        f"{controls[0]} CONTROL lines: {controls[1]} CONTROL C1-F and {controls[2]} CONTROL C2-F "
        "(the superseded run-1 numbers are wrong).\n"
        f"- Correction (D4): the post-fix reading "
        f".ufo/waves/round-59/final/citation-gate-r59.txt states unresolved={citation}.\n"
        f"- stale-lane: launch 11:54:48 → complete 13:36:19 = {minutes} minutes; row reads "
        "progressing.\n"
    )


GOOD_LESSON = lesson_ok("3", "5", "3", (7, 4, 3), "7", "101")


def srows(n: int) -> str:
    return "\n".join(f"| S{i + 1:03d} | fixture row {i + 1} |" for i in range(n))


def init_repo(top: str) -> tuple[str, str, str]:
    repo = os.path.join(top, "repo")
    subprocess.run(["git", "init", "-q", "-b", "main", repo], check=True, capture_output=True)
    top_out = subprocess.run(["git", "-C", repo, "rev-parse", "--show-toplevel"],
                             check=True, capture_output=True, text=True).stdout.strip()
    assert top_out == os.path.realpath(repo), "fixture git toplevel must be the fixture"

    def commit(files: dict[str, str], msg: str) -> str:
        for rel, txt in files.items():
            p = os.path.join(repo, *rel.split("/"))
            os.makedirs(os.path.dirname(p), exist_ok=True)
            with open(p, "w", encoding="utf-8") as f:
                f.write(txt)
        subprocess.run(["git", "-C", repo, "add", "-A"], check=True, capture_output=True)
        subprocess.run(["git", "-C", repo, "-c", "user.email=f@f", "-c", "user.name=f",
                        "commit", "-q", "-m", msg], check=True, capture_output=True)
        return subprocess.run(["git", "-C", repo, "rev-parse", "HEAD"], check=True,
                              capture_output=True, text=True).stdout.strip()

    r1 = commit({"corpus/SOURCES.md": "# S\n" + srows(3) + "\n",
                 "corpus/source-fetches.tsv": "S001\tu1\nS002\tu2\n"}, "fixture r1")
    r2 = commit({"corpus/SOURCES.md": "# S\n" + srows(5) + "\n",
                 "corpus/source-fetches.tsv":
                     "S001\tu1\nS002\tu2\nS003\tu3\nS004\tu4\nS005\tu5\n"}, "fixture r2")
    return repo, r1, r2


def mk_tree(base: str, lesson: str = GOOD_LESSON) -> str:
    for d in ("corpus/lessons", "plans", ".ufo/waves/round-58/controls",
              ".ufo/waves/round-59/final"):
        os.makedirs(os.path.join(base, *d.split("/")), exist_ok=True)
    files = {
        "corpus/lessons/round-58.md": lesson,
        "corpus/lessons/round-58-verifier-spotcheck.md": SPOTCHECK_T,
        ".ufo/waves/round-58/controls/controls-prefreeze.txt": CONTROLS_T,
        "plans/round-58-controls-supplement.sh": SUPPLEMENT_T,
        ".ufo/waves/round-59/final/supplement-receipt.txt": SUPP_RECEIPT_T,
        ".ufo/waves/round-59/final/citation-gate-r59.txt": CITATION_T,
    }
    for rel, txt in files.items():
        with open(os.path.join(base, *rel.split("/")), "w", encoding="utf-8") as f:
            f.write(txt)
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

    try:
        repo, r1, r2 = init_repo(top)
        ctx = Ctx(repo, r1, r2)
        good = mk_tree(os.path.join(top, "good"))

        # -- unit: line selection and derivations --
        two = "- Registry 1 → 2 at the candidate (old).\n- Registry 3 → 5 at the candidate (new).\n"
        m1 = last_line(two, lambda ln: REGISTRY_LINE_RE.search(ln))
        case("registry-last-of-two", m1 is not None and "3 → 5" in m1)
        m2 = last_line("Registry 1 → 2 rows moved\n- Registry 3 → 5 at the candidate.\n",
                       lambda ln: REGISTRY_LINE_RE.search(ln))
        case("registry-form-needs-at-the-candidate",
             m2 is not None and "3 → 5" in m2)
        mut = mk_tree(os.path.join(top, "mut"))
        desc, err = mutate_last_registry_arrow(mut)
        mut_text = rd(mut, LESSON_REL) or ""
        case("mutate-arrow-only-delta",
             err is None and desc == "5->6" and "Registry 3 → 6 at the candidate" in mut_text
             and "fixture rows" in mut_text)
        src_fix = "# S\n| S001 | a |\n| S002 | b |\n| S12 | tiny |\n| S003 | c |\n"
        case("srow-count-3plus-digits-only", len(S_ROW_RE.findall(src_fix)) == 3)
        m3 = re.search(re.escape(FETCHES_REL) + r"\D*?(\d+)",
                       "3 stale rows precede corpus/source-fetches.tsv 6 added rows")
        case("fetches-int-after-name-not-before", m3 is not None and m3.group(1) == "6")
        diff_t = "diff --git a/f b/f\n+++ b/f\n+note\n+S006\tu6\n+S007\tu7\n-S001\tu1\n"
        case("fetches-delta-plusS-only",
             sum(1 for ln in diff_t.splitlines() if ln.startswith("+S")) == 2)
        case("control-counts-fixture", derive_control_counts(good) == (7, 4, 3))
        line_d3 = last_line(GOOD_LESSON, lambda ln: "controls-prefreeze.txt" in ln)
        ints_d3 = [int(x) for x in re.findall(r"\d+", line_d3 or "")]
        case("controls-lesson-line-states-all-three",
             all(n in ints_d3 for n in (7, 4, 3)))
        bad_d3 = GOOD_LESSON.replace(" 7 CONTROL lines", " CONTROL lines")
        ints_bad = [int(x) for x in re.findall(r"\d+", last_line(
            bad_d3, lambda ln: "controls-prefreeze.txt" in ln) or "")]
        case("controls-lesson-line-missing-one-fails", not all(n in ints_bad for n in (7, 4, 3)))
        case("citation-gate-extract",
             CITATION_GATE_RE.search(CITATION_T.rstrip().splitlines()[-1]).group(1) == "7")
        case("minutes-from-real-digest", derive_mission_minutes(good)[0] == 101)

        # -- items on the fixture repo --
        case("i1-hold", item1(good, ctx)[0] == HOLD)
        bad = mk_tree(os.path.join(top, "bad1"),
                      lesson=GOOD_LESSON.replace("Registry 3 → 5", "Registry 2 → 5"))
        case("i1-fail-wrong-n", item1(bad, ctx)[0] == FAIL)
        case("i2-hold", item2(good, ctx)[0] == HOLD)
        bad = mk_tree(os.path.join(top, "bad2"),
                      lesson=GOOD_LESSON.replace("3 added rows", "4 added rows"))
        case("i2-fail-wrong-delta", item2(bad, ctx)[0] == FAIL)
        case("i3-hold", item3(good, ctx)[0] == HOLD)
        bad = mk_tree(os.path.join(top, "bad3"))
        with open(os.path.join(bad, *SUPP_RECEIPT_REL.split("/")), "w",
                  encoding="utf-8") as f:
            f.write(SUPP_RECEIPT_T.replace("mismatch=0", "mismatch=1"))
        case("i3-fail-receipt-ending", item3(bad, ctx)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad4"))
        with open(os.path.join(bad, *SUPPLEMENT_REL.split("/")), "w",
                  encoding="utf-8") as f:
            f.write("#!/bin/sh\n# C1-F10 only\n")
        case("i3-fail-supplement-missing-C2-F4", item3(bad, ctx)[0] == FAIL)
        case("i4-hold", item4(good, ctx)[0] == HOLD)
        bad = mk_tree(os.path.join(top, "bad5"))
        with open(os.path.join(bad, *CITATION_REL.split("/")), "w",
                  encoding="utf-8") as f:
            f.write(CITATION_T.replace("unresolved=7", "unresolved=8"))
        case("i4-fail-u-mismatch", item4(bad, ctx)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad6"))
        os.remove(os.path.join(bad, *CITATION_REL.split("/")))
        case("i4-fail-gate-missing", item4(bad, ctx)[0] == FAIL)
        case("i5-hold", item5(good, ctx)[0] == HOLD)
        bad = mk_tree(os.path.join(top, "bad7"),
                      lesson=GOOD_LESSON.replace("= 101 minutes", "= 100 minutes"))
        case("i5-fail-wrong-minutes", item5(bad, ctx)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad7b"),
                      lesson=GOOD_LESSON
                      + "- stale-lane: the round-58 mission ran 96 min and reads progressing.\n")
        case("i5-fail-later-wrong-line-supersedes", item5(bad, ctx)[0] == FAIL)
        bad = mk_tree(os.path.join(top, "bad8"))
        os.remove(os.path.join(bad, *SPOTCHECK_REL.split("/")))
        case("i5-fail-spotcheck-missing", item5(bad, ctx)[0] == FAIL)
        res = measure(good, ctx)
        case("aggregate-good-value0-pop5",
             sum(1 for s, _ in res.values() if s == FAIL) == 0
             and sum(1 for s, _ in res.values() if s != SKIP) == 5)

        # -- evaluate / guard legs --
        old_parent = os.environ.get("C1_CHALLENGE_PARENT")
        scratch = os.path.join(top, "challenge-scratch")
        os.makedirs(scratch, exist_ok=True)
        try:
            os.environ["C1_CHALLENGE_PARENT"] = scratch
            rc, out = quiet_evaluate(good, ctx, challenge=False)
            case("evaluate-no-challenge-diagnostic",
                 rc == 1 and "value=0" in out and "guard=0" in out and "i5=1" in out)
            rc, out = quiet_evaluate(good, ctx, verbose=True, challenge=True)
            case("evaluate-guard-good-tree",
                 rc == 0 and "value=0" in out and "guard=1" in out
                 and "stub value=0 fails=True" in out and "expect=1" in out)
            broken = mk_tree(os.path.join(top, "broken"),
                             lesson=GOOD_LESSON.replace("Registry 3 → 5", "Registry 2 → 5"))
            rc, out = quiet_evaluate(broken, ctx, verbose=True, challenge=True)
            case("evaluate-base-like-fails-closed",
                 rc == 1 and "value=FAIL" in out and "guard=0" in out)
            os.environ["C1_CHALLENGE_PARENT"] = os.path.join(good, "inside")
            raised = False
            try:
                quiet_evaluate(good, ctx, challenge=True)
            except SetupError:
                raised = True
            case("qm74-refusal-inside-root", raised)
        finally:
            if old_parent is None:
                os.environ.pop("C1_CHALLENGE_PARENT", None)
            else:
                os.environ["C1_CHALLENGE_PARENT"] = old_parent

        case("resolve-repo-finds-explicit", resolve_repo(good, repo, r1, r2) == repo)
        raised = False
        try:
            resolve_repo(good, None, r1, r2, extra_cands=())
        except SetupError:
            raised = True
        case("resolve-repo-setup-without-revisions", raised)
        case("parse-value-tokens",
             parse_value("x\nC1_ROUTED: value=FAIL population=5 guard=0") == "FAIL"
             and parse_value("C1_ROUTED: value=3 population=5 guard=1") == 3
             and parse_value("nothing") is None)
    finally:
        shutil.rmtree(top, ignore_errors=True)
    if failures:
        print(f"C1_CHECK_SELFTEST: FAIL ({cases - len(failures)}/{cases} cases) "
              f"failed={','.join(failures)}")
        return 1
    print(f"C1_CHECK_SELFTEST: PASS ({cases} cases)")
    return 0


# --------------------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser(add_help=True, description="C1_ROUTED counter (round 59)")
    ap.add_argument("--root", default=".", help="measured tree (default: cwd)")
    ap.add_argument("--repo", default=None,
                    help="git repo carrying the pinned revisions (default: --root/.git, "
                         "then the lane this instrument ships in)")
    ap.add_argument("--no-challenge", action="store_true",
                    help="diagnostic leg: print the unresolved count with guard=0")
    ap.add_argument("--json", action="store_true", help="one JSON object on stdout")
    ap.add_argument("--verbose", action="store_true", help="c1-guard challenge detail line")
    ap.add_argument("--selftest", action="store_true", help="synthetic-tree selftest")
    # internal: the guard's self-run passes the parent run's derivation context so a
    # measured tree outside the lane derives from the same revisions (default: pinned)
    ap.add_argument("--base-rev", default=R58_BASE, help=argparse.SUPPRESS)
    ap.add_argument("--land-rev", default=R58_LAND, help=argparse.SUPPRESS)
    args = ap.parse_args()
    if args.selftest:
        return run_selftest()
    root = os.path.abspath(args.root)
    if not os.path.isdir(root):
        print(f"C1_ROUTED: SETUP no measured tree at {root}")
        return 2
    try:
        repo = resolve_repo(root, args.repo, args.base_rev, args.land_rev, extra_cands=(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),))
        ctx = Ctx(repo, args.base_rev, args.land_rev)
        return evaluate(root, ctx, verbose=args.verbose,
                        challenge=not args.no_challenge, as_json=args.json)
    except SetupError as e:
        print(f"C1_ROUTED: SETUP {e}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
