#!/usr/bin/env python3
# K46ReviewerPlan pre-candidate attack fixtures. Builds each fixture from BASE via the frozen
# controls module's own builders, scores it with the frozen counter, and records the counter's
# last line. Nothing here edits the lane; every tree lives under $S (scratch).
import importlib.util, json, os, subprocess, sys

S = os.environ["S"]
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
os.environ["HYAKU_SCRATCH"] = os.path.join(S, "hs")
os.makedirs(os.environ["HYAKU_SCRATCH"], exist_ok=True)
spec = importlib.util.spec_from_file_location("ctl", LANE + "/plans/round-46-controls.py")
ctl = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ctl)
FX = os.path.join(S, "fx")
os.makedirs(FX, exist_ok=True)
OUT = []


def run(counter, d):
    env = dict(os.environ)
    env["C1_TREE" if counter == "c1" else "C2_TREE"] = d
    p = subprocess.run(["bash", LANE + "/plans/round-46-%s.sh" % counter],
                       env=env, capture_output=True, text=True)
    line = (p.stdout.strip().splitlines() or ["<no output>"])[-1]
    return p.returncode, line, p.stderr.strip()[-200:]


def rec(name, counter, d, expect):
    rc, line, err = run(counter, d)
    OUT.append("%s\trc=%d\t%s\tEXPECT=%s\tSTDERR=%s" % (name, rc, line, expect, err))


def gate_diff(d):
    base = os.path.join(S, "base-claims-declared.sh")
    subprocess.run("git -C %s show %s:corpus/claims-declared.sh > %s" % (LANE, ctl.BASE, base),
                   shell=True, check=True)
    p = subprocess.run(["diff", "-u", base, os.path.join(d, "corpus/claims-declared.sh")],
                       capture_output=True, text=True)
    changed = [l for l in p.stdout.splitlines() if l[:1] in "+-" and l[:3] not in ("+++", "---")]
    return " | ".join(changed)


# ---- C1 ----
# F1: out-of-block edit (adjacency dropped from the AXES case, line 122) on a tree whose
# --selftest carries the frozen reference cases 9-10.
d = ctl.tree(FX, "f1-axis")
ctl.c1_positive(d)
g = d + "/corpus/claims-declared.sh"
ctl.edit(g, "depth|coverage|operability|freshness|calibration|adjacency) ;;",
         "depth|coverage|operability|freshness|calibration) ;;")
OUT.append("F1-diff\t" + gate_diff(d))
rec("F1-c1-out-of-block-axis-weakening", "c1", d, "3 (counter does not enforce the block kill rule)")

# F2: out-of-block edit to the plan-to-manifest leg itself: the manifest key drops the axis
# (lines 192 and 208 rewritten consistently so the leg still runs and the real tree stays CLEAN).
d = ctl.tree(FX, "f2-axis-blind-leg")
ctl.c1_positive(d)
g = d + "/corpus/claims-declared.sh"
ctl.edit(g, 'manifest_set["$mround/$mclaim/$maxis"]=1', 'manifest_set["$mround/$mclaim"]=1')
ctl.edit(g, 'manifest_set["$rname/$hclaim/$haxis"]', 'manifest_set["$rname/$hclaim"]')
OUT.append("F2-diff\t" + gate_diff(d))
rec("F2-c1-plan-leg-axis-blind", "c1", d, "3 (leg ignores axis; kill rule not enforced)")

# F3: kill-by-exit-status: a selftest that exits 2 (SETUP) when the gate has lost a line counts
# as a KILL (rc != 0) under the frozen predicate. Only M1 changes the line count.
d = ctl.tree(FX, "f3-setup-as-kill")
ctl.c1_positive(d)
g = d + "/corpus/claims-declared.sh"
ctl.edit(g, "  cases=0; passed=0\n",
         "  cases=0; passed=0\n  [ \"$(wc -l < \"$GATE_SRC\")\" -eq 238 ] || exit 2\n")
rec("F3-c1-setup-exit-counts-as-kill", "c1", d, "1 (only M1 changes line count; exit 2 counted as KILLED)")

# ---- C2 ----
# F4: future-dated observations (2099) on every record and the synced tsv: the gate has no
# upper bound on observed_at, so FRESH counts all 29 as freshly observed.
rb = json.loads(ctl.pos_bytes())
for r in rb["observations"]:
    r["observed_at"] = "2099-12-31T00:00:00Z"
fut = (json.dumps(rb, indent=2, sort_keys=True) + "\n").encode()
d = ctl.tree(FX, "f4-future")
ctl.c2_rebind(d, fut)
rec("F4-c2-future-dated-observations", "c2", d, "29 (no upper bound on observed_at)")

# F5: an http 200 record that also carries an error key (failed fetch recorded as failed).
rb = json.loads(ctl.pos_bytes())
for r in rb["observations"]:
    if r["id"] == "S008":
        r["error"] = "HTTP 503 after 3 retries"
err_b = (json.dumps(rb, indent=2, sort_keys=True) + "\n").encode()
d = ctl.tree(FX, "f5-error-record")
ctl.c2_rebind(d, err_b)
rec("F5-c2-failed-fetch-with-error-key", "c2", d, "0 (gate rejects error key; FRESH column alone is not a verdict)")

# F6: a registry row gains extra pipes in a cell (no escape): the naive split in the counter
# reads 13 cells, so S005 is not counted FRESH; does the gate agree?
d = ctl.tree(FX, "f6-cell-pipe")
ctl.c2_rebind(d, ctl.pos_bytes())
src = d + "/corpus/SOURCES.md"
lines = open(src, encoding="utf-8").read().splitlines(True)
n = 0
for i, l in enumerate(lines):
    if l.startswith("| S005 |"):
        lines[i] = l.replace("| S005 |", "| S005 | scope note a | b |", 1)
        n += 1
assert n == 1
open(src, "w", encoding="utf-8").writelines(lines)
rec("F6-c2-pipe-in-cell-naive-split", "c2", d, "29 if the gate parses the row; counter reads a false red if the gate is CLEAN")
gate = subprocess.run([sys.executable, "-B", "corpus/release-clock.py", "--root", d],
                      cwd=d, capture_output=True, text=True)
OUT.append("F6-gate-direct\trc=%d\t%s" % (gate.returncode,
                                          (gate.stdout.strip().splitlines() or ["<none>"])[-1]))

# F8: PINNED only -- observe-r46 is present but the default is NOT repointed (round-36 default).
d = ctl.tree(FX, "f8-pinned-only")
ctl.c2_rebind(d, ctl.pos_bytes(), repoint=False)
rec("F8-c2-pinned-not-default", "c2", d, "0 (PINNED self-digests the file; DEFAULT must still be CLEAN)")

open(os.path.join(S, "results.txt"), "w", encoding="utf-8").write("\n".join(OUT) + "\n")
print("\n".join(OUT))
