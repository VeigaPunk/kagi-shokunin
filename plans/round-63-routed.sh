#!/usr/bin/env bash
# plans/round-63-routed.sh — the round-63 routed-defect receipt (kagi).
#
# Not a claim: the three defects the round-62 verifier spot-check routed (§6
# D-A, D-B, D-C) are resolved as work items and re-derived here from the
# measured tree. The round's two claims are C1_RESIDUAL and C2_REFUSAL
# (plans/round-63.md).
#
# Usage: bash plans/round-63-routed.sh [--tree DIR] [--repo DIR]
#   default tree = this repo's working tree; default repo = this repo.
# Output: ROUTED: da=<0|1> db=<0|1> dc=<0|1> (da=report counts, db=receipts,
#         dc=case enumeration)
# Exit 0 iff da=db=dc=1; 1 otherwise; 2 SETUP.
set -u
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=${SELF_DIR%/plans}
TREE=$REPO
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=${2:-}; shift 2;;
    --repo) REPO=${2:-}; shift 2;;
    -h|--help) sed -n '2,14p' "${BASH_SOURCE[0]}"; exit 0;;
    *) echo "ROUTED: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "ROUTED: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$REPO" ] || { echo "ROUTED: SETUP bad-repo $REPO" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "ROUTED: SETUP no-python3" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "ROUTED: SETUP no-git" >&2; exit 2; }

python3 -I -B - "$TREE" "$REPO" <<'PY'
import os, re, subprocess, sys

tree, repo = sys.argv[1], sys.argv[2]

def rd(rel):
    p = os.path.join(tree, rel)
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None

def git(*args):
    r = subprocess.run(["git", "-C", repo, *args],
                       capture_output=True, text=True)
    return r.returncode, r.stdout

D = {}

# ------------------------------------------------------------------ D-A
# Round-62 report counts that do not re-derive: the report says the checker
# is `1454 -> 1822` lines and the measured counter `389 -> 520`; committed
# bytes read `1454 -> 1710` and `389 -> 478`. The round-63 lesson must carry
# a correction line naming both measured values AND the command that produced
# them; a correction that restates the report's figure reads da=0.
#
# Re-derive the two counts from committed bytes.
BASE_REV = "60b5b7b60b76629633110a5b4adac883193c8b2a"   # round-62 claim BASE
CAND_REV = "c8407396"                                    # round-62 candidate tip
PAIRS = [
    ("plans/round-61-c1-check.py", "checker"),
    ("plans/round-61-c2.sh",       "counter"),
]
counts = {}   # path -> (base_lines, cand_lines)
missing_rev = []
# wc -l counts newline characters; a file ending in \n has N lines = N newlines.
def wc_l(text):
    return text.count("\n")
for path, _tag in PAIRS:
    rc_b, out_b = git("show", f"{BASE_REV}:{path}")
    rc_c, out_c = git("show", f"{CAND_REV}:{path}")
    if rc_b != 0 or rc_c != 0:
        missing_rev.append(path)
        counts[path] = (None, None)
    else:
        counts[path] = (wc_l(out_b), wc_l(out_c))

lesson = rd("corpus/lessons/round-63.md") or ""
# A correction line: a line in the lesson that names the measured values and
# the command. Require all four numbers and the `git show`/`wc -l` shape.
da = False
da_detail = []
if lesson and not missing_rev and all(v[0] is not None for v in counts.values()):
    c1b, c1c = counts["plans/round-61-c1-check.py"]
    c2b, c2c = counts["plans/round-61-c2.sh"]
    # The lesson's correction must carry both measured pairs and the command.
    need_nums = {str(c1b), str(c1c), str(c2b), str(c2c)}
    # Find candidate correction lines (lines mentioning the counts or D-A).
    cand_lines = [ln for ln in lesson.splitlines()
                  if ("D-A" in ln or "round-62" in ln.lower()
                      or "correction" in ln.lower() or "count" in ln.lower())]
    for ln in cand_lines:
        flat = re.sub(r"\s+", " ", ln)
        has_nums = all(n in flat for n in need_nums)
        has_cmd = ("git show" in flat or "git -C" in flat) and "wc -l" in flat
        # Reject a line that restates the report's wrong figures (1822/520)
        # as the measured values — i.e. the line must not present 1822 or 520
        # as the candidate counts. Simplest: require the measured numbers and
        # forbid the stale report numbers appearing as `->` targets.
        stale = re.search(r"(1822|520)", flat)
        if has_nums and has_cmd:
            # if the line also asserts the stale figures as the answer, fail
            if stale and re.search(r"(1454\s*->\s*1822|389\s*->\s*520)", flat):
                continue
            da = True
            break
    da_detail = [f"c1={c1b}->{c1c}", f"c2={c2b}->{c2c}",
                 f"lesson={'yes' if lesson else 'no'}",
                 f"missing_rev={missing_rev}"]
else:
    da_detail = [f"lesson={'yes' if lesson else 'no'}",
                 f"missing_rev={missing_rev}"]
D["da"] = (1 if da else 0, " ".join(da_detail))

# ------------------------------------------------------------------ D-B
# One receipt per round-63 gate verdict line: six files under
# .ufo/waves/round-63/final/, each carrying its label line, each cited from
# LOG.md. A missing receipt or an uncited path reads db=0.
log = rd("LOG.md") or ""
NEED_B = [
    (".ufo/waves/round-63/final/c1-residual.txt",   "C1_RESIDUAL:"),
    (".ufo/waves/round-63/final/c2-refusal.txt",    "C2_REFUSAL:"),
    (".ufo/waves/round-63/final/controls.txt",      "CONTROLS:"),
    (".ufo/waves/round-63/final/release-clock.txt", "RELEASE_CLOCK:"),
    (".ufo/waves/round-63/final/doc-audit.txt",     "DOC_AUDIT:"),
    (".ufo/waves/round-63/final/claims-declared.txt","CLAIMS_DECLARED:"),
]
ok_b = []
for rel, label in NEED_B:
    body = rd(rel)
    has_label = bool(body) and any(ln.lstrip().startswith(label) for ln in body.splitlines())
    cited = rel in log
    ok_b.append(has_label and cited)
db = all(ok_b)
D["db"] = (1 if db else 0,
           f"receipts={sum(ok_b)}/6 "
           + " ".join(f"{os.path.basename(rel)}={'ok' if o else 'miss'}"
                      for (rel, _), o in zip(NEED_B, ok_b)))

# ------------------------------------------------------------------ D-C
# The case enumeration: the lesson's case list must name every case the
# instruments' own selftest counts claim. Parse the `cases=N` figures (and
# `N/N checks`) the lesson cites for the round-63 instruments and require an
# enumerated list in the lesson whose item count is >= the largest cited
# figure. A list shorter than the count reads dc=0.
#
# Collect every selftest-count figure the lesson asserts for a round-63
# instrument, scoped to lines that name a selftest PASS line (so an unrelated
# `cases=` mention does not set the floor). Instruments and PASS shapes:
#   C1_CHECK_SELFTEST / C2_SELFTEST / C2R62_SELFTEST / C2R63_SELFTEST /
#   C1_RESIDUAL_SELFTEST / CONTROLS_SELFTEST: PASS (cases=N)
#   C1_COUNTER_SELFTEST: PASS (N/N checks)
max_cases = 0
cited = []
for ln in lesson.splitlines():
    if "SELFTEST" not in ln and "selftest" not in ln:
        continue
    for m in re.finditer(r"cases=(\d+)", ln):
        cited.append(int(m.group(1)))
    for m in re.finditer(r"PASS\s*\((\d+)/(\d+)\s+checks\)", ln):
        cited.append(int(m.group(2)))
if cited:
    max_cases = max(cited)

# The lesson's enumerated case list: list items (lines opening with `- `,
# `* `, `N. `, `N) `, or a `|`-table row) that carry at least one case-like
# token. Count distinct ITEMS (one per list line), not tokens — a list shorter
# than the count reads dc=0. A case-like token has a digit or a hyphen and at
# least one letter, or is a FINDING id.
enum_items = 0
for ln in lesson.splitlines():
    s = ln.strip()
    if not s:
        continue
    if not (s.startswith(("- ", "* ", "|")) or re.match(r"^\d+[.)]\s", s)):
        continue
    toks = re.findall(r"[A-Za-z][A-Za-z0-9_\-]*", s)
    hit = any(("-" in t and any(c.isalpha() for c in t))
              or (t.startswith("FINDING") and any(c.isdigit() for c in t))
              or (any(c.isdigit() for c in t) and any(c.isalpha() for c in t))
              for t in toks)
    if hit:
        enum_items += 1

dc = False
dc_detail = f"max_cases={max_cases} enum_items={enum_items}"
if lesson and max_cases > 0:
    dc = enum_items >= max_cases
elif lesson and max_cases == 0:
    # no selftest count cited: nothing to enumerate against -> fail closed.
    dc = False
D["dc"] = (1 if dc else 0, dc_detail)

resolved = sum(v[0] for v in D.values())
parts = " ".join(f"{k}={v[0]}" for k, v in D.items())
detail = " ".join(f"{k}:{v[1]}" for k, v in D.items())
print(f"ROUTED: da={D['da'][0]} db={D['db'][0]} dc={D['dc'][0]} ({detail})")
sys.exit(0 if resolved == 3 else 1)
PY
