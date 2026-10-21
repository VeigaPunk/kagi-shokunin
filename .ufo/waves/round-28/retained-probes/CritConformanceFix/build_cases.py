#!/usr/bin/env python3
"""Build synthetic lane histories (round 28 shape) for counterexamples. Sandbox only."""
import json, os, shutil, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "cases"
PLAN0 = Path(sys.argv[1]).read_text()      # real bdf90f5:plans/round-28.md
CENSUS0 = Path(sys.argv[2]).read_text()    # real .ufo/waves/round-28/census-start.txt
PLAN, CENSUS = "plans/round-28.md", ".ufo/waves/round-28/census-start.txt"
TOOL = ".ufo/waves/round-28/tools/c1-measure.py"


class Repo:
    def __init__(self, name):
        self.d = OUT / name
        shutil.rmtree(self.d, ignore_errors=True)
        self.d.mkdir(parents=True)
        self.g("init", "-q", "-b", "main")
        self.minute = 0

    def g(self, *a, date=None):
        env = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t",
                   GIT_COMMITTER_EMAIL="t@t", GIT_CONFIG_GLOBAL="/dev/null", GIT_CONFIG_SYSTEM="/dev/null")
        if date:
            env["GIT_AUTHOR_DATE"] = env["GIT_COMMITTER_DATE"] = date
        return subprocess.run(["git", "-C", str(self.d), *a], check=True, capture_output=True, text=True, env=env).stdout.strip()

    def write(self, files):
        for p, c in files.items():
            f = self.d / p
            if c is None:
                self.g("rm", "-q", p)
            else:
                f.parent.mkdir(parents=True, exist_ok=True)
                f.write_text(c)
                self.g("add", p)

    def commit(self, msg, files=None, minute=None):
        self.minute = minute if minute is not None else self.minute + 10
        if files:
            self.write(files)
        self.g("commit", "-q", "--allow-empty", "-m", msg, date=f"2026-10-21T10:{self.minute:02d}:00-03:00")
        return self.g("rev-parse", "HEAD")

    def base(self):
        h = self.commit("round-27 admitted", {"corpus/release-clock.py": "v=1\n", "corpus/SOURCES.md": "| S001 |\n",
                                              "corpus/helper.py": "h=1\n"}, minute=0)
        self.basesha = h
        return h

    def plan(self, base=None, text=None):
        return (text if text is not None else PLAN0).replace("3553d499577084a6c98d7078906017840bbf7b28", base or self.basesha)

    def census(self, ts="2026-10-21T10:05:00-03:00"):
        return ts + "\n" + CENSUS0.split("\n", 1)[1]


def manifest(base):
    return {"rounds": [{"lane": "kagi", "lane_round": 27, "admitted": True, "commit": f"kagi-shokunin@{base}"}]}


CASES = {}


def case(fn):
    CASES[fn.__name__] = fn
    return fn


@case
def GOOD(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("plan correction before work", {PLAN: r.plan() + "\n- clarification\n"})
    r.commit("tool", {TOOL: "print(1)\n"}); r.commit("work", {"corpus/release-clock.py": "v=2\n"})


@case
def CE01_empty_frozen_claims_appended_with_code(r):
    b = r.base()
    stub = f"# Round 28\n\nFrozen BASE: `{b}`\n\n## Plan corrections (appended during the round)\n"
    r.commit("plan stub+census", {PLAN: stub, CENSUS: r.census()})
    body = PLAN0.split("## C1", 1)[1].replace("\n    python3", "\n    (cmd) python3")
    r.commit("work + real claims as corrections", {"corpus/release-clock.py": "v=2\n", PLAN: stub + "\n## C1" + body})


@case
def CE02_work_committed_before_plan(r):
    r.base(); r.commit("candidate code first", {"corpus/release-clock.py": "v=2\n"})
    r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census("2026-10-21T10:15:00-03:00")})


@case
def CE03_work_before_plan_base_line_moved(r):
    r.base(); w = r.commit("candidate code first", {"corpus/release-clock.py": "v=2\n"})
    r.commit("plan+census declaring BASE=work", {PLAN: r.plan(base=w), CENSUS: r.census("2026-10-21T10:15:00-03:00")})


@case
def CE04_census_rewritten_later(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("work", {"corpus/release-clock.py": "v=2\n"})
    r.commit("census 'correction'", {CENSUS: r.census("2026-10-21T10:35:00-03:00")})


@case
def CE05_empty_census(r):
    r.base(); r.commit("plan+empty census", {PLAN: r.plan(), CENSUS: ""})


@case
def CE06_census_failed_exit(r):
    r.base(); r.commit("plan+census exit=1", {PLAN: r.plan(), CENSUS: r.census().replace("exit=0", "exit=1")})


@case
def CE07_rename_code_into_plans(r):
    r.base(); r.write({PLAN: r.plan(), CENSUS: r.census()})
    r.g("mv", "corpus/helper.py", "plans/helper.py"); r.commit("plan+census (+rename)")


@case
def CE08_candidate_patch_under_plans(r):
    r.base(); r.commit("plan+census+patch", {PLAN: r.plan(), CENSUS: r.census(),
                                              "plans/round-28-candidate.patch": "--- a/corpus/release-clock.py\n"})


@case
def CE09_merge_carries_code(r):
    b = r.base(); r.g("checkout", "-q", "-b", "side")
    r.commit("candidate code on side", {"corpus/release-clock.py": "v=2\n"})
    r.g("checkout", "-q", "main"); r.g("merge", "-q", "--no-ff", "--no-commit", "side")
    r.write({PLAN: r.plan(), CENSUS: r.census()}); r.commit("merge side + plan+census")


@case
def CE21_zero_byte_plan_then_full_with_code(r):
    r.base(); r.commit("empty plan+census", {PLAN: "", CENSUS: r.census()})
    r.commit("work + full plan", {PLAN: r.plan(), "corpus/release-clock.py": "v=2\n"})


@case
def CE20_plan_on_side_code_on_main_merged(r):
    r.base(); r.g("checkout", "-q", "-b", "planline")
    r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.g("checkout", "-q", "main"); r.commit("candidate code", {"corpus/release-clock.py": "v=2\n"})
    r.g("merge", "-q", "--no-ff", "planline", "-m", "merge plan"); r.minute += 10


@case
def CE10_frozen_fixture_rewritten(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("plan edit", {PLAN: r.plan().replace("observed_version=3.15.01", "observed_version=3.15.1")})


@case
def CE11_rewrite_then_revert(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("widen", {PLAN: r.plan().replace("c1-measure.py <rev>", "c1-measure.py --wide <rev>")})
    r.commit("work+measure", {"corpus/release-clock.py": "v=2\n"})
    r.commit("restore", {PLAN: r.plan()})


@case
def CE12_late_appended_widening_r27_shape(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("work", {"corpus/release-clock.py": "v=2\n"})
    r.commit("correction", {PLAN: r.plan() + "\n- C2 scope widened before landing: also refuses ...\n"})


@case
def CE13_corrections_heading_moved_up(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("move heading", {PLAN: r.plan().replace("## C2 ", "## Plan corrections (moved)\n\n## C2 ", 1)})


@case
def CE14_readd_laundering(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("drop plan", {PLAN: None})
    r.commit("re-add plan with code", {PLAN: r.plan(), "corpus/release-clock.py": "v=2\n"})


@case
def CE15_worktree_dirty(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    (r.d / PLAN).write_text(r.plan().replace("4301", "5000"))


@case
def CE16_tool_rewritten(r):
    r.base(); r.commit("plan+census", {PLAN: r.plan(), CENSUS: r.census()})
    r.commit("tool", {TOOL: "print(1)\n"}); r.commit("measure+work", {"corpus/release-clock.py": "v=2\n"})
    r.commit("tool fix", {TOOL: "print(2)\n"})


@case
def CE17_census_after_work_uncommitted(r):
    r.base(); r.commit("plan+census (census ran on dirty tree)", {PLAN: r.plan(), CENSUS: r.census()})


@case
def CE18_census_bound_to_dirty_registry(r):
    import hashlib
    r.base(); dirty = hashlib.sha256(b"| S001 |\n| S044 |\n").hexdigest()
    c = r.census().replace("exit=0", f"source_registry_sha256={dirty}\nexit=0")
    r.commit("plan+census", {PLAN: r.plan(), CENSUS: c})


@case
def CE19_census_after_plan_separate_commit(r):
    r.base(); r.commit("plan", {PLAN: r.plan()})
    r.commit("census", {CENSUS: r.census("2026-10-21T10:15:00-03:00")})


if __name__ == "__main__":
    for name, fn in CASES.items():
        r = Repo(name); fn(r)
        (r.d.parent / f"{name}.manifest.json").write_text(json.dumps(manifest(r.basesha)))
    print(len(CASES))
