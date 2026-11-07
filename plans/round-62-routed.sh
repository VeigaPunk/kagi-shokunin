#!/usr/bin/env bash
# plans/round-62-routed.sh — the round-62 routed-defect receipt (kagi).
#
# Not a claim: the five defects the round-61 verifier spot-check routed (§7.1-§7.5)
# are resolved as work items and re-derived here from the measured tree. The round's
# two claims are C1_BYPASS and C2_HARDENED (plans/round-62.md).
#
# Usage: bash plans/round-62-routed.sh [--tree DIR] [--repo DIR]
#   default tree = this repo's working tree; default repo = this repo.
# Output: ROUTED: resolved=N population=5 d1=.. d5=..
# Exit 0 iff resolved=5; 1 otherwise; 2 SETUP.
set -u
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=${SELF_DIR%/plans}
TREE=$REPO
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=${2:-}; shift 2;;
    --repo) REPO=${2:-}; shift 2;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}"; exit 0;;
    *) echo "ROUTED: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "ROUTED: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$REPO" ] || { echo "ROUTED: SETUP bad-repo $REPO" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "ROUTED: SETUP no-python3" >&2; exit 2; }

python3 -I -B - "$TREE" "$REPO" <<'PY'
import json, os, re, subprocess, sys

tree, repo = sys.argv[1], sys.argv[2]

def rd(rel):
    p = os.path.join(tree, rel)
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None

def git(*args):
    r = subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True)
    return r.returncode, r.stdout

D = {}

# ---------------------------------------------------------------- D1
# SCORECARD.md §Round 61 post-move said `CONTROLS: match=17 mismatch=0` where the
# committed receipt reads match=18. The correction is appended and names the receipt.
sc = rd("SCORECARD.md") or ""
cands = [ln for ln in sc.splitlines() if "supersedes the round-61 controls count" in ln]
last = cands[-1] if cands else ""
receipt_rel = ".ufo/waves/round-61/controls/controls-prefreeze.txt"
rcpt = rd(receipt_rel)
n_control = 0
if rcpt is not None:
    n_control = sum(1 for ln in rcpt.splitlines() if ln.startswith("CONTROL "))
d1 = bool(last) and "match=18" in last and receipt_rel in last and n_control == 18
D["d1"] = (1 if d1 else 0,
           f"correction={'yes' if last else 'no'} receipt-controls={n_control}")

# ---------------------------------------------------------------- D2
# SKILL.md gate-registry rows for the round-61 gates and the round-62 instruments.
skill = rd("SKILL.md") or ""
def registry_row(name_token):
    for ln in skill.splitlines():
        if not ln.startswith("|"):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) < 8:
            continue
        if name_token in cells[0]:
            return cells
    return None
need = ["plans/round-61-c1-check.py", "plans/round-61-c2.sh",
        "corpus/openbao-seal-trial.sh", "plans/round-62-c1.sh",
        "plans/round-62-c2.sh", "plans/round-62-controls.sh"]
missing, bad = [], []
for tok in need:
    row = registry_row(tok)
    if row is None:
        missing.append(tok)
        continue
    if row[1] != "gate" or (not row[4]) or "none of its own" in row[4]:
        bad.append(tok)
d2 = not missing and not bad
D["d2"] = (1 if d2 else 0,
           f"rows={len(need) - len(missing)}/{len(need)} kind-or-selftest-bad={len(bad)}")

# ---------------------------------------------------------------- D3
# The round's wave carries >=25 % literal attack seats, and the plan states the
# arithmetic the dispatch derives.
plan = rd("plans/round-62.md") or ""
disp = rd(".ufo/waves/round-62/w1-dispatch.json")
attack_roles = {"reviewer", "critic", "mutation-tester", "labrat"}
a = n = 0
if disp:
    try:
        roles = [t.get("agent") for t in json.loads(disp)["taskCall"]["tasks"]]
        n = len(roles)
        a = sum(1 for r in roles if r in attack_roles)
    except (ValueError, KeyError):
        a = n = 0
pct = f"{100.0 * a / n:.2f}" if n else "0.00"
plan_flat = re.sub(r"\s+", " ", plan)
d3 = (n > 0 and 4 * a >= n
      and f"{a} of {n} = {pct} %" in plan_flat
      and "18.75" in plan)
D["d3"] = (1 if d3 else 0, f"derived {a}/{n}={pct} plan-states={'yes' if d3 else 'no'}")

# ---------------------------------------------------------------- D4
# A committed candidate-revision receipt names the revision and both verdict lines.
cand = rd(".ufo/waves/round-62/final/candidate.txt") or ""
m = re.search(r"^candidate=([0-9a-f]{40})$", cand, re.M)
d4 = False
det4 = "no receipt"
if m:
    rev = m.group(1)
    rc, _ = git("cat-file", "-e", rev + "^{commit}")
    rc2, out2 = git("merge-base", "--is-ancestor", rev, "master")
    has_c1 = re.search(r"^C1_BYPASS: accepted=0 population=5 guard=1", cand, re.M) is not None
    has_c2 = re.search(r"^C2_HARDENED: killed=3 population=3 guard=1", cand, re.M) is not None
    d4 = rc == 0 and rc2 == 0 and has_c1 and has_c2
    det4 = f"rev-exists={rc == 0} ancestor={rc2 == 0} c1={has_c1} c2={has_c2}"
D["d4"] = (1 if d4 else 0, det4)

# ---------------------------------------------------------------- D5
# One committed receipt per ancillary gate verdict line, cited from LOG.md.
log = rd("LOG.md") or ""
need5 = [(".ufo/waves/round-62/final/release-clock.txt", "RELEASE_CLOCK:"),
         (".ufo/waves/round-62/final/doc-audit.txt", "DOC_AUDIT:"),
         (".ufo/waves/round-62/final/claims-declared.txt", "CLAIMS_DECLARED:")]
ok5 = []
for rel, label in need5:
    body = rd(rel)
    ok5.append(bool(body) and any(ln.startswith(label) for ln in body.splitlines())
               and rel in log)
d5 = all(ok5)
D["d5"] = (1 if d5 else 0, f"receipts={sum(ok5)}/3 log-cites={sum(ok5)}/3")

resolved = sum(v[0] for v in D.values())
parts = " ".join(f"{k}={v[0]}" for k, v in D.items())
detail = " ".join(f"{k}:{v[1]}" for k, v in D.items())
print(f"ROUTED: resolved={resolved} population=5 {parts} ({detail})")
sys.exit(0 if resolved == 5 else 1)
PY
