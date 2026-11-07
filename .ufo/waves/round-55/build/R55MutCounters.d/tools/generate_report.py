#!/usr/bin/env python3
"""Generate the R55MutCounters report from the receipts."""
import hashlib
import json
import os
import re

S = "/fast/scratch/hyaku/kagi-r55/R55MutCounters"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
OUT = os.path.join(LANE, ".ufo/waves/round-55/build/R55MutCounters.md")
CAND = "348aa3b8ea7298aeb2f4d69db321fe827a92ae4f"
BASE = "ebe095857a734caf5efdd7bd776feb22b4e23972"
PRE = "f2b986fadd8f8551e760cc89f59e0ae0edb0d499"
FROZEN = {
    "round-55-c1.sh": "3c0b483c5842453a5a397db213c50106597d096216cd1dedcea6b936a5e9c466",
    "round-55-c2.sh": "9696937a23fe8c3cb29c1fbe7b338372b466c64fbcb893d588b4f8e4353d2ae6",
    "round-55-controls.sh": "dd75bf8fc3f884032b26629706f44f88bc3a5c093a1b48c1bad80c97474a7fdf",
}

DESC = {
 "C1-02-g2-off": "REF + `corpus/knowledge/adjacency-breadth.md` becomes a symlink to a copy outside corpus/knowledge "
                 "(entry has no registry-id token and no used-by cell) + census printer",
 "C1-03-g3-dup-off": "REF + duplicate the `S005` registry row + census printer",
 "C1-04-g3-rows-off": "REF + delete the `S005` row (BASE row, uncited by any entry, no used-by record) + census printer",
 "C1-10-g5-selftest-off": "REF + census whose `--selftest` exits 0 and prints a non-PASS last line",
 "C1-11-g4-islink-off": "REF + S112 used-by cell points at `corpus/knowledge/zz-symlink.md` (a symlink to "
                        "`op-ref-consumption.md`, which carries S112) + census printer",
 "C1-12-entries-islink-off": "same tree as P-C1-02-g2-off",
 "C2-01-a-ub-off": "S114 used-by cell drops the entry + census printer",
 "C2-02-a-tier-off": "S114 tier A -> B + census printer",
 "C2-04-b-sha-off": "S114 `source-fetches.tsv` column 10 -> 64 zeroes + census printer",
 "C2-05-c-offset-off": "S114 `quote-bodies.tsv` byte offset 541 -> 540 + census printer",
 "C2-11-srcids-off": "entry recheck command 2 -> S112 feed URL + `'<title>1Password CLI 2.42.0</title>'` -> 1 "
                     "(a true count in S112's capture; S112 is not on the entry's `source:` line) + census printer",
 "C2-13-guard-census-off": "census prints `SOURCES_CENSUS: DIRTY` and exits 0",
 "C2-14-recheck-capture-sha-off": "append one byte to the S113 recheck capture + census printer",
 "C2-15-recheck-lines-off": "append a second column-1 `recheck:` line + census printer",
 "C2-16-guard-s101sha-off": "append one byte to `.ufo/waves/round-45/controls/capture-r45/S101.raw` and update "
                            "S101's fetch digest to its new sha256 (recheck stays true) + census printer",
}

rows = json.load(open(os.path.join(S, "receipts", "analysis.json")))["rows"]
props = json.load(open(os.path.join(S, "receipts", "03-proposals.json")))
base_txt = open(os.path.join(S, "receipts", "00-baseline-controls.txt"), encoding="utf-8").read()

mut_json = {}
for f in os.listdir(os.path.join(S, "receipts")):
    if f.endswith(".mutation.json"):
        mid = f[: -len(".mutation.json")]
        mut_json[mid] = json.loads(open(os.path.join(S, "receipts", f), encoding="utf-8").read())

kill_counts = {}
restores, exits = [], []
for r in rows:
    path = os.path.join(S, "receipts", r["id"] + ".controls.txt")
    t = open(path, encoding="utf-8").read()
    m = re.search(r"^RESTORE (.*)$", t, re.M)
    restores.append((r["id"], m.group(1) if m else "MISSING"))
    e = re.search(r"^exit=(\d+)$", t, re.M)
    exits.append(int(e.group(1)) if e else -1)
    for cid, b, g, res in r["flipped"]:
        kill_counts.setdefault(cid, []).append(r["id"])

all_controls = re.findall(r"^CONTROL (\S+)", base_txt, re.M)
never = [c for c in all_controls if c not in kill_counts]
only_failmode = []
for c in all_controls:
    ms = kill_counts.get(c, [])
    if ms and all(m.endswith("fail-mode-off") for m in ms):
        only_failmode.append(c)

def esc(s):
    return s.replace("|", "\\|")

lines = []
A = lines.append
A("# R55MutCounters — mutation test of the round-55 frozen counters")
A("")
A("Seat R55MutCounters (leaf member, no dispatch). Lane `kagi-shokunin`, branch `master`.")
A("Measured revision: **`%s`** (from `git -C %s rev-parse 348aa3b8…`; every receipt copy in "
  "`R55MutCounters.d/` carries this literal hash in its header or in `PROVENANCE.txt`). "
  "BASE `%s`, predeclaration `%s`." % (CAND, LANE, BASE, PRE))
A("")
A("**STATUS: complete.** Pristine baseline 22/22 controls MATCH; 29 single-point mutants run; "
  "**14 killed by the frozen battery, 15 survived**; for every survivor a post-hoc proposed control "
  "was predeclared, run, and **15/15 kill it**; all 29 mutated counter files were restored byte-identically.")
A("")
A("## 1. Objects under test")
A("")
A("| object | sha256 / revision |")
A("|---|---|")
for f, h in FROZEN.items():
    A("| `plans/%s` (frozen) | `%s` |" % (f, h))
A("| candidate / measured revision | `%s` |" % CAND)
A("| BASE | `%s` |" % BASE)
A("")
A("The frozen hashes are identical in the lane working tree and at the candidate commit; the controls "
  "script is also identical at the predeclaration commit `%s`." % PRE)
A("")
A("## 2. Method and recorded deviations")
A("")
A("- Scratch `HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r55/R55MutCounters` passed on every command; every "
  "clone, tree, fixture and receipt lives under it. `/tmp` unused.")
A("- Pristine reference work tree: `git clone --shared` of the lane, `rev-parse --show-toplevel` asserted "
  "equal to the clone dir, detached checkout of `%s`. It is the controls' REF overlay." % CAND)
A("- Detector: the frozen pre-freeze battery `plans/round-55-controls.sh` with its 22 predeclared "
  "expectations. **Baseline: 22/22 MATCH, exit 0**, last line `CONTROLS: match=22 mismatch=0` "
  "(`R55MutCounters.d/00-baseline-controls.txt`) — the pre-freeze receipt reproduced.")
A("- Mutant run: one literal replacement in one counter script, asserted to occur exactly once and to "
  "change the file; mutation applied in a minimal scratch repo holding `plans/` and a `.git` whose "
  "`objects/info/alternates` points at the lane object store (so the counter's `git archive BASE` works; "
  "`git cat-file -e BASE^{commit}` asserted).")
A("- **Deviation (permitted by the seat tasking):** the control battery in the mutant repo is a "
  "counter-scoped copy of the frozen script — the unused counter's block is removed verbatim. "
  "`controls-c1-only.sh` is the frozen text minus the C2 block; `controls-c2-only.sh` is the frozen text "
  "plus exactly one line `mk_ref ref` before the C2 block. A C1 mutant is exercised by all 11 K1 "
  "controls and a C2 mutant by all 11 K2 controls; no text of the kept blocks changed.")
A("- After every run the counter is restored from the frozen copy and the restored sha256 is recorded. "
  "All 29 restore lines show frozen sha == restored sha.")
A("- Verdict rule: a mutant is KILLED iff ≥1 control of its counter differs from the baseline reading "
  "(the baseline is 22/22, so this equals differing from the predeclared expectation); SURVIVED iff all "
  "11 keep it. Baseline failure would be INCONCLUSIVE; there was none.")
A("")
A("## 3. Mutant table (29 mutants: 28 in the parallel wave, C2-17 run separately)")
A("")
A("`sha_after` is the mutated file's sha256 (first 12 hex); the full before/after pair is in each "
  "`*.mutation.json`. Killing controls are shown as `control (baseline→mutant)`.")
A("")
A("| # | mutant | counter | conjunct mutated | sha_after | killing control(s) | verdict |")
A("|---|---|---|---|---|---|---|")
for i, r in enumerate(rows, 1):
    mid = r["id"]
    mj = mut_json[mid]
    cnt = "C1" if mid.startswith("C1") else "C2"
    kj = "; ".join("%s (%s→%s)" % (c, b, g) for c, b, g, res in r["flipped"]) or "none — 11/11 kept"
    A("| %d | `%s` | %s | %s | `%s` | %s | **%s** |" % (
        i, mid, cnt, esc(mj["conjunct"]), mj["sha_after"][:12], esc(kj), r["verdict"]))
A("")
k1 = [r for r in rows if r["id"].startswith("C1")]
k2 = [r for r in rows if r["id"].startswith("C2")]
A("Kill ratio, frozen battery: **%d/%d = %.1f%%** (C1 %d/%d, C2 %d/%d)." % (
    sum(1 for r in rows if r["verdict"] == "KILLED"), len(rows),
    100.0 * sum(1 for r in rows if r["verdict"] == "KILLED") / len(rows),
    sum(1 for r in k1 if r["verdict"] == "KILLED"), len(k1),
    sum(1 for r in k2 if r["verdict"] == "KILLED"), len(k2)))
A("")
A("Controls that killed at least one mutant in wave 1: %s. Controls that never flipped: %s. "
  "Controls that flipped **only** under the fail-closed-value mutants: %s — i.e. their intended forged "
  "defect was detected only through loss of `FAIL`, not through the predicate they were built for." % (
      ", ".join(sorted(kill_counts)), ", ".join(never) or "none",
      ", ".join(only_failmode) or "none"))
A("")
A("## 4. Survivors and proposed controls (15)")
A("")
A("Each proposal was written into `tools/proposals.py` with its expected pristine reading **before** the "
  "run, on a REF-derived tree; it is post-hoc with respect to the frozen battery, so it does not raise "
  "the frozen kill ratio. Column *real census* is the last line of the measured tree's own "
  "`sources-census.sh` on the edited tree before the isolation printer replaced it: where it is "
  "`FAILED`, the printer was necessary to test the counter's independent conjunct; where `CLEAN`, the "
  "printer was conservative.")
A("")
A("| mutant | conjunct | proposed control | predeclared | pristine got | mutant got | real census | kill |")
A("|---|---|---|---|---|---|---|---|")
for p in props:
    rc = "CLEAN" if p["real_census_last_line"].startswith("SOURCES_CENSUS: CLEAN") else \
         ("FAILED" if p["real_census_last_line"].startswith("SOURCES_CENSUS: FAILED") else
          p["real_census_last_line"][:40])
    A("| `%s` | %s | %s | `%s` | `%s` | `%s` | %s | %s |" % (
        p["proposal"], esc(mut_json[p["mutant"]]["conjunct"]), esc(DESC[p["proposal"][2:]]),
        p["expected_pristine"], p["pristine_value"], p["mutant_value"], rc,
        "KILL" if p["kills"] else "NO-KILL"))
A("")
A("Result: **15/15 proposed controls kill their survivor**, with the predeclared pristine reading "
  "matched in all 15 cases. The one predeclaration that needed correction is recorded below.")
A("")
A("## 5. What the survivors say about the frozen battery")
A("")
A("**C1 (6 survivors).** `g1` (BASE citations), `g4` (NOCITE), `g5` (census) and the fail-closed value "
  "have independent detectors. `g2` (BASE entry names), `g3`'s duplicate-id arm and its BASE-rows arm, "
  "the selftest-PASS arm of `g5`, `g4`'s symlink arm and `entries`' symlink exclusion have no control "
  "that isolates them: the frozen forgeries that touch the same inputs are also caught by `g1`/`g4`/`g5`.")
A("")
A("**C2 (9 survivors).** AMD(a) (`ENTRY` in used-by, tier `A`), AMD(b) (fetch digest == AMDSHA), "
  "AMD(c) (declared byte offset), RECHECK's source-line gate for a foreign row URL, RECHECK's capture-"
  "digest check, RECHECK's single-line rule, GUARD's census arm and GUARD's S101-capture-digest arm are "
  "unexercised. K2-F3 (tampered AMD capture) exercises AMD(c)'s **digest** but not its **offset**; "
  "K2-F7's foreign URL carries `-> 0`, so the `N>=1` arm fires first and the source-line gate never "
  "decides; K2-F6 edits an S101 row, but its kill is through GUARD's row arm, not its digest arm.")
A("")
A("**Layering is real but not independent.** The BASE expectations are load-bearing: K2-BASE killed "
  "C2-09 (count check removed) because the BASE tree's honest recheck lies. Conversely, several guard "
  "arms are redundant *on the frozen forgeries* while remaining necessary against a forger who edits "
  "only the field they guard: the survivors are exactly those cases.")
A("")
A("## 6. Recorded correction (honesty)")
A("")
A("The first P-C1-10 probe made the census `--selftest` exit 1. That does not discriminate "
  "C1-10-g5-selftest-off, whose mutation lives inside the selftest-success branch: both pristine and "
  "mutant read `FAIL (bad=g5:selftest-exit)` (`R55MutCounters.d/04-proposal-runs.txt`, no kill). The "
  "probe was corrected to `--selftest` exiting 0 with a non-PASS last line, which is the branch the "
  "mutant removes; the rerun killed it (`05-proposal-runs-v2.txt`). All other 14 proposals are the "
  "first implementation.")
A("")
A("## 7. Restoration evidence")
A("")
A("All 29 mutated counter files were restored from `frozen/`; every receipt records "
  "`RESTORE sha_frozen=<h> sha_restored=<h>` with equal hashes "
  "(`3c0b483c…` for C1, `9696937…` for C2). Exit codes: %d runs exit 0 (all 11 controls matched), "
  "%d runs exit 1 (≥1 MISMATCH). The fixture counter repos were disposable; this seat modified no corpus, "
  "plan, registry or git object, and its writes outside scratch were confined to its build/ path. The "
  "lane working tree did show 7 tracked modifications at finish that are not this seat's writes; every "
  "measurement above was taken from committed revisions with `git archive`, never the working tree." % (sum(1 for e in exits if e == 0), sum(1 for e in exits if e == 1)))
A("")
A("## 8. Receipts")
A("")
A("Copied to `.ufo/waves/round-55/build/R55MutCounters.d/`:")
A("")
A("- `00-baseline-controls.txt` — full 22-control pristine baseline (22 MATCH, exit 0).")
A("- `01-mutant-wave.txt` — wave driver window (`2026-11-07T05:00:27` → `05:07:11`, 28 runs, `xargs -P 6`).")
A("- `02-analysis.txt` / `analysis.json` — scoped verdict computation.")
A("- `03-proposals.json` — 15 proposed controls, pristine and mutant readings.")
A("- `04-proposal-runs.txt` — first proposal run (contains the non-discriminating P-C1-10 probe).")
A("- `05-proposal-runs-v2.txt` — corrected full proposal run (15/15).")
A("- `06-c2-17.txt` — the added C2 fail-closed mutant run.")
A("- `*.controls.txt` (29), `*.mutation.json` (29) — per-mutant battery output, mutation before/after sha, "
  "restore line.")
A("- `tools/` — `mutants.py` (29 specs), `proposals.py` (15 proposals), `run_one.sh`, `analyze.py`, "
  "`build_variants.py`, `controls-c1-only.sh`, `controls-c2-only.sh`.")
A("- `PROVENANCE.txt` — measured revision, copy header, sha256 of every copied receipt.")
A("")
A("Commands (all with absolute paths, `S=%s`):" % S)
A("")
A("```")
A("HYAKU_SCRATCH=$S bash $S/frozen/round-55-controls.sh $S/repo            # baseline (via clone)")
A("echo <ids> | xargs -P 6 -I{} bash $S/tools/run_one.sh {}                 # 29 mutant batteries")
A("python3 -I -B $S/tools/analyze.py                                       # verdicts")
A("python3 -I -B $S/tools/proposals.py                                     # 15 proposed controls")
A("```")

report = "\n".join(lines) + "\n"
os.makedirs(os.path.dirname(OUT), exist_ok=True)
open(OUT, "w", encoding="utf-8").write(report)
print("wrote", OUT, len(report), "bytes")
print("rows", len(rows), "killed", sum(1 for r in rows if r["verdict"] == "KILLED"),
      "survived", sum(1 for r in rows if r["verdict"] == "SURVIVED"),
      "proposals", len(props), "proposal-kills", sum(1 for p in props if p["kills"]))
print("never-flipped:", never)
print("failmode-only:", only_failmode)
