#!/usr/bin/env python3
"""Round-conformance checker for one lane round (read-only git only).

Usage:
    python3 -I -B round-conformance.py <lane> <round>

    <lane>   path to the lane repository (the directory holding plans/ and .ufo/)
    <round>  round number, e.g. 28 ("round-28" also accepted)

Checks (one typed line each; VERDICT is PASS only when every check is OK):

  C1 PLAN-FIRST-COMMIT-SCOPE
      The first commit that touches plans/round-<N>.md touches no path
      outside plans/ and .ufo/waves/round-<N>/census-start.txt.

  C2 CENSUS-START-ORDER
      .ufo/waves/round-<N>/census-start.txt exists at HEAD and its first
      commit is no later than the plan's first commit (same commit counts;
      ordering is by commit-graph ancestry, not commit time).

  C3 FROZEN-COUNTING-COMMANDS
      The counting-command lines inside the plan's frozen part (everything
      before the first line starting with "## Plan corrections") are
      byte-identical at the plan's first commit and at HEAD ("lane tip";
      uncommitted worktree edits are not consulted). Counting-command lines
      are the content lines of fenced (```) code blocks and lines indented
      by >= 4 spaces within the frozen part; fence delimiter lines are
      excluded.

Exit status: 0 = PASS, 1 = FAIL (any FAIL/ERROR line, including usage errors).

Only read-only git commands are issued (rev-parse, log, rev-list, diff-tree,
show, cat-file -e, merge-base --is-ancestor); nothing is written anywhere.
"""

import subprocess
import sys

FROZEN_END_PREFIX = b"## Plan corrections"
INDENT = b"    "
FENCE = b"```"


def die(msg):
    print("ERROR %s" % msg)
    sys.exit(1)


def git(lane, *args):
    """Run one read-only git command; return (rc, stdout_bytes, stderr_bytes)."""
    proc = subprocess.run(
        ["git", "-C", lane, *args],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return proc.returncode, proc.stdout, proc.stderr


def git_out(lane, *args):
    rc, out, err = git(lane, *args)
    if rc != 0:
        die("GIT-FAILED %s: %s" % (" ".join(args),
                                   err.decode("utf-8", "replace").strip()))
    return out


def blob_at(lane, rev_path):
    rc, out, _err = git(lane, "show", rev_path)
    return rc, out


def frozen_lines(blob):
    """Every line before the first '## Plan corrections' heading."""
    lines = []
    for line in blob.split(b"\n"):
        if line.rstrip(b"\r").startswith(FROZEN_END_PREFIX):
            break
        lines.append(line)
    return lines


def counting_command_lines(frozen):
    """Content lines of fenced blocks plus >=4-space-indented block lines."""
    cmds = []
    in_fence = False
    for line in frozen:
        if line.lstrip().startswith(FENCE):
            in_fence = not in_fence
            continue
        if in_fence or line.startswith(INDENT):
            cmds.append(line)
    return cmds


def brief(line_bytes, limit=100):
    text = line_bytes.decode("utf-8", "backslashreplace")
    if len(text) > limit:
        text = text[: limit - 3] + "..."
    return repr(text)


def main(argv):
    if len(argv) != 3:
        die("ARGS usage: round-conformance.py <lane> <round>")
    lane = argv[1]
    token = argv[2]
    if token.startswith("round-"):
        token = token[len("round-"):]
    if not token.isdigit():
        die("ARGS round must be a number, got %r" % (argv[2],))
    n = token
    plan_path = "plans/round-%s.md" % n
    census_path = ".ufo/waves/round-%s/census-start.txt" % n

    rc, _out, _err = git(lane, "rev-parse", "--git-dir")
    if rc != 0:
        die("NOT-A-GIT-REPO %s" % lane)
    head = git_out(lane, "rev-parse", "HEAD").decode().strip()
    print("ROUND-CONFORM lane=%s round=%s head=%s" % (lane, n, head[:12]))

    failures = 0

    def record(ok, line):
        nonlocal failures
        print(line)
        if not ok:
            failures += 1

    # The plan's first (oldest) commit that touches the file.
    log = git_out(lane, "log", "--format=%H %ct", "--", plan_path)
    entries = log.decode().splitlines()
    if not entries:
        die("PLAN-NEVER-COMMITTED %s" % plan_path)
    first_sha, first_ct = entries[-1].split()
    subject = git_out(lane, "show", "-s", "--format=%s", first_sha).decode().strip()

    # --- C1: scope of the plan's first commit --------------------------------
    parents = git_out(lane, "rev-list", "--parents", "-n1", first_sha).decode().split()
    if len(parents) > 2:
        die("MERGE-FIRST-COMMIT %s: merge commits are not supported for C1"
            % first_sha[:12])
    raw = git_out(lane, "diff-tree", "--no-commit-id", "--name-only", "-r",
                  "--root", "-z", first_sha)
    touched = [p.decode("utf-8", "replace")
               for p in raw.split(b"\0") if p]
    outside = [p for p in touched
               if p != census_path and not p.startswith("plans/")]
    if outside:
        record(False,
               "C1 PLAN-FIRST-COMMIT-SCOPE FAIL-SCOPE first=%s ct=%s subject=%r "
               "touched=%d outside=%d"
               % (first_sha[:12], first_ct, subject, len(touched), len(outside)))
        for path in outside:
            print("  C1 OUTSIDE-PATH %s" % path)
    else:
        record(True,
               "C1 PLAN-FIRST-COMMIT-SCOPE OK first=%s ct=%s subject=%r touched=%d"
               % (first_sha[:12], first_ct, subject, len(touched)))

    # --- C2: census-start presence and ordering ------------------------------
    clog = git_out(lane, "log", "--format=%H %ct", "--", census_path)
    centries = clog.decode().splitlines()
    census_first = centries[-1].split()[0] if centries else None
    census_ct = centries[-1].split()[1] if centries else None
    exists_rc, _ignored_out, _ignored_err = git(lane, "cat-file", "-e",
                                                "HEAD:%s" % census_path)
    if census_first is None or exists_rc != 0:
        detail = "never-committed" if census_first is None else \
            "committed-at=%s-but-absent-at-HEAD" % census_first[:12]
        record(False,
               "C2 CENSUS-START-ORDER FAIL-MISSING census=%s plan_first=%s(%s)"
               % (detail, first_sha[:12], first_ct))
    elif census_first == first_sha:
        record(True,
               "C2 CENSUS-START-ORDER OK same-commit-as-plan first=%s ct=%s"
               % (census_first[:12], census_ct))
    else:
        anc_rc, _o, _e = git(lane, "merge-base", "--is-ancestor",
                             census_first, first_sha)
        if anc_rc == 0:
            record(True,
                   "C2 CENSUS-START-ORDER OK census_first=%s(%s) plan_first=%s(%s) "
                   "census-not-later" % (census_first[:12], census_ct,
                                         first_sha[:12], first_ct))
        else:
            record(False,
                   "C2 CENSUS-START-ORDER FAIL-ORDER census_first=%s(%s) "
                   "plan_first=%s(%s) census-committed-after-plan"
                   % (census_first[:12], census_ct, first_sha[:12], first_ct))

    # --- C3: frozen counting-command lines stable since the first commit -----
    rc_first, blob_first = blob_at(lane, "%s:%s" % (first_sha, plan_path))
    rc_head, blob_head = blob_at(lane, "HEAD:%s" % plan_path)
    if rc_first != 0 or rc_head != 0:
        die("PLAN-BLOB-UNREADABLE %s first_rc=%d head_rc=%d"
            % (plan_path, rc_first, rc_head))
    cmds_first = counting_command_lines(frozen_lines(blob_first))
    cmds_head = counting_command_lines(frozen_lines(blob_head))
    if cmds_first == cmds_head:
        vacuous = len(cmds_first) == 0
        record(True,
               "C3 FROZEN-COUNTING-COMMANDS OK lines=%d first=%s tip=HEAD%s"
               % (len(cmds_first), first_sha[:12],
                  " (vacuous: none detected)" if vacuous else ""))
        if vacuous:
            print("  C3 NOTE no fenced/indented counting-command lines in the "
                  "frozen part; check is vacuous for this plan")
    else:
        record(False,
               "C3 FROZEN-COUNTING-COMMANDS FAIL-CHANGED first=%s tip=HEAD"
               % first_sha[:12])
        k = min(len(cmds_first), len(cmds_head))
        idx = next((i for i in range(k) if cmds_first[i] != cmds_head[i]), k)
        print("  C3 FIRST-DIFF index=%d" % idx)
        if idx < len(cmds_first):
            print("  C3 AT-FIRST %s" % brief(cmds_first[idx]))
        else:
            print("  C3 AT-FIRST <absent: first commit had fewer command lines>")
        if idx < len(cmds_head):
            print("  C3 AT-TIP %s" % brief(cmds_head[idx]))
        else:
            print("  C3 AT-TIP <absent: tip has fewer command lines>")

    print("VERDICT %s" % ("PASS" if failures == 0 else "FAIL"))
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
