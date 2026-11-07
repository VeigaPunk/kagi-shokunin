# R55ExecCounters — independent re-measurement of round-55 claims and kill rules

Seat: R55ExecCounters (kagi round 55, lane /home/vgpnk/Projects/shokunin/kagi-shokunin, branch master).
Scope: re-run the frozen counters on three revisions, re-run the kill-rule diff, re-run the 22 pre-freeze controls with the candidate as reference; compare every reading with the lane's report-to-be values.

## Measured revisions (obtained with `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse <rev>^{commit}`, written literally)

| label | 40-hex |
|---|---|
| BASE | ebe095857a734caf5efdd7bd776feb22b4e23972 |
| predeclaration | f2b986fadd8f8551e760cc89f59e0ae0edb0d499 |
| candidate (landed) | 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f |

All three `rev-parse` calls resolved the abbreviated forms to themselves (no rewriting).

## (1) Counter runs — full outputs saved as receipts

Command per cell: `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-55-cN.sh <rev>` (each extracts the revision with `git archive`/`git show` into its own scratch under `$HYAKU_SCRATCH/kagi-r55/cN.$$`, self-cleans).

### Claim x revision -> value/guard

| claim | BASE ebe0958 | predecl f2b986f | candidate 348aa3b | expected |
|---|---|---|---|---|
| C1_USEDBY_GAP | **25** gap=25 citations=88 entries=37 guard=1 (bad=none) | **25** gap=25 citations=88 entries=37 guard=1 (bad=none) | **0** gap=0 citations=90 entries=37 guard=1 (bad=none) | 25 / 25 / 0 — all MATCH |
| C2_ISO_CURRENT | **0** amd=0 recheck=0 guard=1 (bad=amd:a-rows=0,recheck:S101-count-2-stated-1) | **0** amd=0 recheck=0 guard=1 (bad=amd:a-rows=0,recheck:S101-count-2-stated-1) | **2** amd=1 recheck=1 guard=1 (bad=none) | 0 / 0 / 2 — all MATCH |

All six runs exited 0. Full outputs (including BASE's 25 GAP lines) in R55ExecCounters.d/: `round-55-c1-base.txt`, `round-55-c1-predecl.txt`, `round-55-c1-cand.txt`, `round-55-c2-base.txt`, `round-55-c2-predecl.txt`, `round-55-c2-cand.txt`.

Last output lines: c1-base/c1-predecl last GAP line `GAP S112 corpus/knowledge/op-ref-consumption.md`; c1-cand `C1_USEDBY_GAP: value=0 ...`; c2-base/c2-predecl `(bad=amd:a-rows=0,recheck:S101-count-2-stated-1)`; c2-cand `(bad=none)`.

Disagreements with the lane readings (BASE 25/0, predeclaration 25/0, candidate 0/2): **none**.

## (2) Kill rules

`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff --quiet f2b986fadd8f8551e760cc89f59e0ae0edb0d499 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f -- plans/round-55.md plans/round-55-c1.sh plans/round-55-c2.sh plans/round-55-controls.sh` → **exit 0**: no plan/counters/controls file changed between predeclaration and candidate. Kill rule holds (counters measured the candidate bytes with the frozen predicates).

Context checks (not kill rules): the four plan files do not exist at BASE (base→predecl diff is +495 lines, files added at predeclaration); the lane working tree is byte-identical to the candidate for all four files (diff --stat empty, exit 0), so the controls run below exercised the candidate's own frozen counters.

## (3) Controls re-run with candidate as reference

Procedure: `git clone -q --shared /home/vgpnk/Projects/shokunin/kagi-shokunin $HYAKU_SCRATCH/kagi-r55/R55ExecCounters/ref`, asserted `git rev-parse --show-toplevel` equals the clone dir (pwd -P resolved), `git checkout -q 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`, then `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-55-controls.sh <clone>`.

Result: **exit 0**, last line `CONTROLS: match=22 mismatch=0`. All 22 controls MATCH, including both candidate readings re-derived from the reference overlay:

- K1-BASE 25 MATCH, K1-REF 0 MATCH; forgeries F1–F9 all degrade to guard=0/FAIL as expected (e.g. F3 pad-all+printer: `bad=g4:25-used-by-parts-without-record` — the independent g4 NOCITE check catches what the replaced census does not; F8 base-census: `bad=g5:census-exit`).
- K2-BASE 0 MATCH, K2-REF 2 MATCH; forgeries F1–F9 all score 1 or FAIL as expected (F6 s101-row-edited trips the guard: `bad=guard:row-S101`; F3 capture-tampered: `bad=amd:c`).

Full per-control output: R55ExecCounters.d/controls-candref.txt.

**Cross-check vs the pre-freeze receipt** (.ufo/waves/round-55/controls/controls-prefreeze.txt, which claims 22 MATCH with the predeclaration working tree as reference): `diff` shows all 22 `CONTROL ...` lines **byte-identical** between the two runs — the only differences are the pre-freeze file's runner-added header line (`# 2026-11-07T04:31:31-03:00 bash plans/round-55-controls.sh <lane working tree as reference overlay>`) and trailing `exit=0` line (diff exit 1 for exactly those two lines). Same expectations, same readings, different reference checkout (candidate vs predeclaration tree) — the candidate landing satisfies the frozen controls.

## (4) Cross-check vs lane receipts

- Pre-freeze receipt: .ufo/waves/round-55/controls/controls-prefreeze.txt claims 22 MATCH. My candidate-ref controls output is diffed against it in section (3).
- Comparison of readings with report-to-be values: done in section (1) table — all six cells agree.

## Honesty notes

- Every receipt in R55ExecCounters.d/ carries a header line naming its measured revision as the literal 40-hex hash obtained with `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse <rev>^{commit}` (no abbreviated forms, no unexpanded `$(...)`); each receipt also records its command's exit code.
- Scratch hygiene: the counters and the controls script each created their own `$HYAKU_SCRATCH/kagi-r55/{c1,c2,controls}.$$` scratch and self-cleaned via `trap ... EXIT`; the candidate ref clone at `$HYAKU_SCRATCH/kagi-r55/R55ExecCounters/ref` was removed after the controls run; receipts were written directly into the report dir, so nothing remained to copy.
- No fetch, web read, 1Password contact, token, or vault material was touched by this seat; counters and controls operate on committed bytes and scratch-built forgeries only. No tools were installed or upgraded. No git mutation was run anywhere (only clone/checkout inside the asserted scratch fixture, per the assignment's stated procedure).
- The host was under heavy load; one counter batch ran ~88 s wall for six runs; the 22-control run completed with exit 0.

## Verdict

Both claims reproduce exactly from committed bytes: C1 25 → 25 → 0 and C2 0 → 0 → 2 across BASE → predeclaration → candidate, guards all 1; kill-rule diff exit 0 (frozen plan/counters/controls untouched between predeclaration and candidate); the 22 pre-freeze controls reproduce MATCH-for-MATCH with the candidate as reference. **No disagreement with the lane readings anywhere.**
