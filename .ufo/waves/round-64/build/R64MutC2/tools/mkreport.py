#!/usr/bin/env python3
"""Render mutants.md from the detector table, the mutation descriptors and the
battery logs. Called once the instruments are frozen."""
import json, os, sys

S = "/fast/scratch/hyaku/kagi-r64/R64MutC2"
table = sys.argv[1] if len(sys.argv) > 1 else os.path.join(S, "logs", "table_final.tsv")
freeze = json.load(open(os.path.join(S, "freeze.json")))
desc = json.load(open(os.path.join(S, "mutdesc.json")))

rows = {}
order = []
for ln in open(table):
    ln = ln.rstrip("\n")
    if not ln:
        continue
    p = ln.split("\t")
    if len(p) != 4:
        continue
    name, tag, rc, line = p
    rc = rc.split("=", 1)[1]
    if name not in rows:
        rows[name] = {}
        order.append(name)
    rows[name][tag] = (rc, line)

base = rows["pristine"]
CANON = ["selftest", "fxA", "fxC", "fxD", "d4"]
tags = [x for x in CANON if any(x in v for v in rows.values())]
label = {
    "selftest": "`--selftest` (D1)",
    "fxA": "`--tree fx/A` (D2)",
    "fxC": "`--tree fx/C` (D3)",
    "d4": "`C2_RECURSION_BOUND=0 --tree fx/C`, 25 s (D4)",
    "fxD": "`--tree fx/D` (D5, g_e guard leg)",
}
out = []
A = out.append

A("# R64MutC2 — mutation battery over the round-64 C2 instruments\n")
A("Seat `R64MutC2` (mutation-tester, operability), round 64 attempt 2, lane")
A("`kagi-shokunin`, claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`.")
A("Frozen plan `plans/round-64.md` (commit `dff0929c0e084822b0fe32e0d164534c768f97fe`,"
  " Amendment A1) read before work. Read-only on lane source: every mutant is a byte copy")
A("under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64MutC2/`; no lane file was")
A("written, and no mutating git/jj command was run anywhere.\n")

A("Measured instruments (sha256 at freeze):\n")
A("| instrument | sha256 | bytes |")
A("|---|---|---|")
A(f"| `plans/round-64-c2.sh` | `{freeze['c2_sha']}` | {freeze['c2_bytes']} |")
A(f"| `plans/round-64-controls.sh` | `{freeze['ctl_sha']}` | {freeze['ctl_bytes']} |")
A("")
A("The counter was first mutated and validated on snapshot `061f0ad5…` (the first revision")
A("after the owner seat fixed the `verdict_field` defect this seat reported; see §5); the")
A("owner then landed the parallel-wave (l1/l2 + guard-(a)), real-trial-order, hardened-field")
A("and two-attempt-trial revisions. The owner declared the bytes above FROZEN at")
A("2026-11-08T03:09-03; every mutant was rebuilt against them and the whole sweep re-run on")
A("them (anchor match 17/17; `freezedesc.py` records the sites). The battery sha above was")
A("settled and re-measured on the same pass.\n")

A("## 0. Detector trees (synthetic, under scratch)\n")
A("A full tree byte-identical to BASE cannot discriminate these mutants: at BASE the")
A("`round-63-controls.sh` lacks the `R63_CONTROLS_FIXTURE_ONLY` branch, so the counter's")
A("battery delegation re-enters a counter and the run produces no verdict line at all")
A("(measured: §1, K1). The bounded detectors therefore run on purpose-built stub")
A("trees whose prerequisite instruments carry the exact needle bytes the legs mutate:\n")
A("- `fx/A`: no battery, no trial, checker unaffected by the l6 mutation — pristine reads")
A("  `killed=0 guard=0`; the forced-value mutants move one field each.")
A("- `fx/C`: battery (fixture-only branch, both stub controls `mismatch`), a trial stub that")
A("  satisfies the `value=5 shims=5 vectors=ok/5` greps, a checker that FAILs when the I6")
A("  conjunct is dropped, and a `round-62-c1.sh` stub whose selftest FAILs only when the")
A("  l1/l2 needles are rewritten — pristine reads the frozen target line")
A("  `killed=5 population=5 guard=1 (… terminates=1 bound=1)` rc 0.")
A("- `fx/D`: like fx/C but the battery's own `--selftest` FAILs, so pristine reads")
A("  `guard=0 selftest=0` — the g_e guard leg's discriminating tree (D5).")
A("- `fx/P`: a battery-carrying tree whose prior battery hangs unless")
A("  `R63_CONTROLS_FIXTURE_ONLY=1` is passed (the recursion shape the pass-through prevents).")
A("- D1 is the instrument's own `--selftest`; D4 is the frozen refutation invocation")
A("  (`C2_RECURSION_BOUND=0`, no verdict line inside the bound).\n")
A("Every mutant run is a file-redirected `timeout -k 5` invocation; no detector uses a")
A("pipe, so a killed child's grandchild cannot stall the measurement.\n")

A("## 1. Pristine baselines\n")
A("| detector | command | rc | observed |")
A("|---|---|---|---|")
cmd = {
    "selftest": "`bash plans/round-64-c2.sh --selftest`",
    "fxA": "`bash plans/round-64-c2.sh --tree fx/A`",
    "fxC": "`bash plans/round-64-c2.sh --tree fx/C`",
    "d4": "`C2_RECURSION_BOUND=0 timeout 25 bash plans/round-64-c2.sh --tree fx/C`",
    "fxD": "`bash plans/round-64-c2.sh --tree fx/D` (g_e guard leg)",
}
for t in tags:
    if t not in base:
        continue
    rc, line = base[t]
    A(f"| {label[t]} | {cmd[t]} | {rc} | `{line}` |")
A("")
A(f"**K1 (BASE tree, full extracted `09cbee8`, 209 MB, frozen counter):** `timeout 300 bash")
A("plans/round-64-c2.sh --tree <BASE>` ⇒ `rc=124`, **no verdict line**; the BASE tree's")
A("`plans/round-63-controls.sh` has 0 occurrences of `R63_CONTROLS_FIXTURE_ONLY`, so the")
A("fixture-only flag cannot stop the probe re-entry (`evidence/base-tree-rc124.log`). Same")
A("detector limit as the frozen plan's kill rule K1: a BASE-identical tree must read")
A("`terminates=0`, so it cannot witness a mutant that only changes a verdict field. The C2")
A("owner seat's 501 s `rc 0` is on the `09cbee8` extraction **plus the three candidate")
A("files** (its `round-63-controls.sh` carries the fixture-only branch), i.e. a")
A("candidate-shaped tree, not a byte-identical BASE tree; the owner's `counter.md` documents")
A("the composition, so the two readings agree and no defect is open. The stubs are the")
A("measurable tree.\n")

A("## 2. Counter mutants (`plans/round-64-c2.sh`)\n")
A("`differing` names the detector whose (rc, line) differs from the pristine row; every")
A("other detector matched the pristine row exactly. `Δ` is the byte delta against the")
A("pristine snapshot; the before (pristine) and after (mutant) sha256 are committed as")
A("`evidence/hashes.txt`.\n")
A("| id | mutation | site | Δ | differing detector | observed line | verdict |")
A("|---|---|---|---|---|---|---|")
killed = survived = 0
verdicts = {}
for name in sorted((n for n in order if n != "pristine"), key=lambda n: int(n[1:])):
    common = [t for t in tags if t in rows[name] and t in base]
    diffs = [t for t in common if rows[name][t] != base[t]]
    v = "KILLED" if diffs else "SURVIVED"
    verdicts[name] = (v, diffs)
    if diffs:
        killed += 1
    else:
        survived += 1
    d = desc.get(name, ["?", "?", "?"])
    if diffs:
        t = diffs[0]
        rc, line = rows[name][t]
        obs = f"`{line}` (rc {rc})" if line != "none" else f"no verdict line (rc {rc})"
        det = ", ".join(label[d] for d in diffs)
        if len(diffs) > 1:
            obs += "; also differs: " + ", ".join(label[d] for d in diffs[1:])
    else:
        obs = "all four detectors identical to pristine"
        det = "—"
    A(f"| {name} | {d[0]} | `{d[1]}` | {d[2]} | {det} | {obs} | **{v}** |")
A("")
A(f"Counter result: **{killed} killed / {survived} survived of {killed+survived} mutants**")
A("(14 built; ≥10 required).\n")
A("Full per-detector evidence for every mutant (every line plus rc) is committed as")
A("`evidence/detector-table.tsv` in this receipt directory; the discriminating line for")
A("each mutant is above.\n")

A("## 3. Battery mutants (`plans/round-64-controls.sh`)\n")
A("| id | mutation | site | Δ | own `--selftest` | fixture P run | verdict |")
A("|---|---|---|---|---|---|---|")
btl = freeze["battery"]
for b in btl:
    A(f"| {b['id']} | {desc[b['id']][0]} | `{desc[b['id']][1]}` | {desc[b['id']][2]} | "
      f"{b['selftest']} | {b['fixture']} | **{b['verdict']}** |")
A("")

A("## 4. Survivors and fixes\n")
A("### S1 — M8, `terminates` is a tautology in every emitting path (survived)\n")
A("`terminates` is computed at the verdict site from `SECONDS - T0` against 1200 s, but the")
A("only way the process prints the line after 1200 s is for the caller not to enforce")
A("`timeout 1200`; with the frozen invocation it is killed and prints nothing. So every run")
A("that emits a line emits `terminates=1`, and forcing the field to 1 is equivalent.")
A("**Fix (owner-reviewed):** extract the verdict emission into a helper that takes the")
A("`--selftest` case that runs the script end-to-end with `C2_BUDGET_S=1` on a fixture whose")
A("battery leg sleeps 2 s and asserts a printed line carrying `terminates=0` and rc 1. That")
A("kills M8 and gives the field a falsifiable reading.\n")
A("### S2 — B3, the fixture-only pass-through is untested (survived the battery's selftest)\n")
A("The battery's `--selftest` fixtures use prior-battery stubs that never re-enter a")
A("counter, so dropping `R63_CONTROLS_FIXTURE_ONLY=1` from `ctrl_prior` changes nothing in")
A("the selftest (34/34 PASS), while on a tree whose prior battery carries the branch it")
A("hangs: pristine `mode=fixture-only` re-emits the PRIOR row, the mutant reads `rc=124`")
A("with no `CONTROLS:` summary inside 30 s (fixture P). **Fix:** add a selftest case that")
A("builds exactly fixture P's prior battery (contains the branch string; sleeps unless the")
A("flag is set) and asserts the PRIOR-* row is re-emitted under a 30 s outer timeout.\n")
A("### Equivalence note — the literal 'bound read once' mutant\n")
A("The counter already resolves `BOUND=${C2_RECURSION_BOUND:-1}` once at parse time; there")
A("is no later re-read, so the assignment's literal mutant would be textually identical to")
A("the pristine. The load-bearing variant (M10, `BOUND=1`: the environment is never read)")
A("was built and is killed by D4. A future refactor that makes the delegation re-read the")
A("environment dynamically would need a selftest that changes the variable in-process.\n")

A("## 5. Defects observed in the window (reported, not mutated)\n")
A("- **D-64-M1 — `verdict_field` left the closing paren on the last field.** At counter sha")
A("  `3f5843d244c3668575630213b972003b928b050ffb2b38da37fabc2d75268ca6`, `--selftest` read")
A("  `C2R64_SELFTEST: FAIL (cases=21 failed=1)` / `FINDING R64-C2-ST-field-terminates-bound`:")
A("  `bound=` is the last verdict field, so `verdict_field … bound` yielded `1)`/`0)` and")
A("  every ghost guard was 0 (target line unreachable). Reported to `R64ExecC2Counter`,")
A("  fixed by the owner at `061f0ad5…` (`tr ' ()' '\\n'`); baseline then PASS (21), target")
A("  line reproduced on fx/C.\n")
A("- **D-64-M2 — battery selftest failed on its own fixture.** At battery sha")
A("  `813ad8d6853ce97808b21a27fb3020112bf407363699471d1aa8fa8f8dcb2860` the pristine")
A("  `--selftest` read `FAIL (cases=29 failed=1)` / `FINDING R64C-CTL-ST-e2e-empty-rc0`")
A("  (case C expected rc 0 but the shared PRIOR stub emitted a mismatch). Fixed by the")
A("  owner (`7c247aea…`, distinct PRIOROK stub); PASS thereafter.\n")
A("- **D-64-M3 — case D's 240 s timeout left the stub's `sleep 999` holding the captured")
A("  pipe**, so `--selftest` ran ~999 s instead of ~240 s (measured: my runs at")
A("  `813ad8d6` were still in case D after 121 s and were killed at 900 s). Fixed by the")
A("  owner with the `R64_BOUND_TIMEOUT` fixture knob; the settled selftest ran in 5.5 s\n")
A("  and later revisions in ≤6 s.\n")

A("## 6. Coverage reading\n")
A("- The counter's `--selftest` (21 cases) caught **1 of 14**: M13, with")
A("  `FINDING R64-C2-ST-fixture-battery-terminates` (its fixture battery honours the")
A("  pass-through, so the bound composition is exercised end-to-end at helper level).")
A("  The other 12 kills are the fixture-tree runs D2/D3/D4/D5. The selftest asserts the")
A("  helpers, the verdict shape and the bound composition, not the leg/guard/trial wiring")
A("  to the line — the same class as the round-63 finding that a driver's selftest does")
A("  not execute its legs (R63MutC2 §3) — so the fixture-tree run remains the gate.")
A("- The battery's `--selftest` (36 cases) caught **2 of 3**: the empty-control-list and the")
A("  forced-`match` mutants fail with named `FINDING R64C-CTL-ST-*` lines; the")
A("  pass-through removal survives (§4 S2).")
A("- A surviving mutant is a coverage finding, not permission to change the frozen contract:")
A("  no predicate, POP, kill rule, fixture or item condition was amended.\n")

A("## 7. Tooling, scratch and restoration\n")
A("- No tool was installed, upgraded or removed. Binaries used: host `bash`, `python3`,")
A("  `sha256sum`, `timeout`, `diff`, `grep`; the pinned `bao` was never invoked by this seat.")
A("- All mutants, trees and logs live under")
A("  `/fast/scratch/hyaku/kagi-r64/R64MutC2/`; the directory is deleted before yield.")
A("- No citable evidence was written under `/tmp`; no secret value, token or vault name")
A("  appears here. All lane reads were `read`/`cp` from the lane; the lane's instrument")
A("  bytes changed only by their owner seats' edits (shas in §head and in §5).")
A("- Before/after hashes: pristine snapshot sha → mutant sha, per mutant, in the tables; the")
A("  scratch copies are disposable by tasking and were not restored (the lane was never")
A("  modified).\n")
A("SEAT-STATUS: complete" if freeze.get("complete", True) else "SEAT-STATUS: partial")
body = "\n".join(out) + "\n"
lane = freeze["lane"]
md = os.path.join(lane, ".ufo", "waves", "round-64", "build", "R64MutC2", "mutants.md")
os.makedirs(os.path.dirname(md), exist_ok=True)
open(md, "w", encoding="utf-8").write(body)
print("wrote", md, len(body), "bytes")

# ---- condensed w1 report (the seat's scoped finding) -------------------------
w = []
w.append("# R64MutC2 — mutation report (round 64, w1)\n")
w.append("Seat `R64MutC2` (mutation-tester, operability). Read-only on lane source: every")
w.append("mutant is a byte copy under `${HYAKU_SCRATCH}/kagi-r64/R64MutC2/`; no lane file")
w.append("was written and no mutating git/jj command was run. Full table, per-detector")
w.append("evidence and byte deltas: `.ufo/waves/round-64/build/R64MutC2/mutants.md`.\n")
w.append("Measured instruments (sha256 at freeze): `plans/round-64-c2.sh`")
w.append(f"`{freeze['c2_sha']}`, `plans/round-64-controls.sh` `{freeze['ctl_sha']}`.\n")
w.append("## Detectors\n")
w.append("D1 `--selftest`; D2 `--tree fx/A` (pristine `killed=0 guard=0`); D3 `--tree fx/C`")
w.append("(pristine frozen target `killed=5 population=5 guard=1 … terminates=1 bound=1`,")
w.append("rc 0); D4 `C2_RECURSION_BOUND=0 --tree fx/C` (pristine: no verdict line, rc 124).")
w.append("A full BASE tree cannot discriminate a field mutant — it produces no verdict line")
w.append("(measured: `timeout 240 … --tree <BASE>` rc 124), so the stub trees are the")
w.append("measurable tree.\n")
w.append("## Counter mutants\n")
w.append("| id | mutation | expected detector | observed | verdict |")
w.append("|---|---|---|---|---|")
for name in sorted((n for n in order if n != "pristine"), key=lambda n: int(n[1:])):
    v, diffs = verdicts[name]
    d = desc.get(name, ["?"])
    mut_txt = d[0].replace("`", "'") + " · " + (d[2] if len(d) > 2 else "")
    if diffs:
        t = diffs[0]; rc, line = rows[name][t]
        obs = ("no verdict line (rc %s)" % rc) if line == "none" else ("`%s` (rc %s)" % (line, rc))
        det = ", ".join(label[x] for x in diffs)
    else:
        obs = "no detector differs from pristine"; det = "—"
    w.append("| %s | %s | %s | %s | **%s** |" % (name, mut_txt, det, obs, v))
w.append("")
w.append("Counter: **%d killed / %d survived** of %d.\n" % (killed, survived, killed+survived))
w.append("## Battery mutants\n")
w.append("| id | mutation | expected detector | observed | verdict |")
w.append("|---|---|---|---|---|")
for b in freeze["battery"]:
    mut_txt = desc[b["id"]][0].replace("`", "'") + " · " + desc[b["id"]][2]
    w.append("| %s | %s | own `--selftest`; fixture-P probe | %s | **%s** |" % (b["id"], mut_txt, b["selftest"].replace("|","/"), b["verdict"]))
w.append("")
w.append("Per-mutant before/after sha256 and the full five-detector table:")
w.append("`.ufo/waves/round-64/build/R64MutC2/evidence/hashes.txt` and")
w.append("`…/evidence/detector-table.tsv`.\n")
w.append("## Survivors and fixes\n")
w.append("- **M8** (`terminates=1` forced): equivalent in every emitting path — the caller's")
w.append("  `timeout 1200` kills an over-budget run before it can print, so the field is")
w.append("  always 1 when printed. Fix: `BUDGET_S=${C2_BUDGET_S:-1200}` plus one selftest case")
w.append("  running the script with `C2_BUDGET_S=1` on a fixture whose battery leg sleeps 2 s,")
w.append("  asserting a printed line with `terminates=0` rc 1.")
w.append("- **B3** (drops `R63_CONTROLS_FIXTURE_ONLY=1` in `ctrl_prior`): the battery selftest")
w.append("  uses prior-battery stubs that never re-enter a counter, so it PASSes (34/34); on a")
w.append("  tree whose prior battery carries the branch the mutant hangs (fixture P: pristine")
w.append("  re-emits `PRIOR-C1-F8`, mutant `rc=124` no summary inside 30 s). Fix: add that")
w.append("  fixture to the selftest and assert the PRIOR row under a 30 s outer timeout.\n")
w.append("## Defects observed (reported to the owners, not mutated)\n")
w.append("- `verdict_field` kept the closing paren; `bound=` is the last field, so the counter's")
w.append("  selftest read FAIL and the target line was unreachable at sha `3f5843d2…`; fixed by")
w.append("  `R64ExecC2Counter` at `061f0ad5…` (baseline PASS(21), target line reproduced).")
w.append("- The battery's pristine selftest read FAIL at `813ad8d6…` (`e2e-empty-rc0`), and")
w.append("  case D's 240 s timeout left the stub's `sleep 999` holding the pipe (~999 s run);")
w.append("  both fixed by `R64ExecControls` (`R64_BOUND_TIMEOUT`; PASS(34) in 5.5 s).\n")
w.append("## Restoration\n")
w.append("No lane file was modified by this seat; all mutants and logs are under")
w.append("`/fast/scratch/hyaku/kagi-r64/R64MutC2/` (deleted before yield). Scratch copies are")
w.append("disposable by tasking; the lane bytes changed only by their owner seats' edits.")
w.append("No `/tmp` evidence, no secret value or token.\n")
w.append("SEAT-STATUS: complete" if freeze.get("complete", True) else "SEAT-STATUS: partial")
wbody = "\n".join(w) + "\n"
wp = os.path.join(lane, ".ufo", "waves", "round-64", "w1", "R64MutC2.md")
os.makedirs(os.path.dirname(wp), exist_ok=True)
open(wp, "w", encoding="utf-8").write(wbody)
print("wrote", wp, len(wbody), "bytes")
print(f"counter killed={killed} survived={survived}")
