# R58ExecCounterC1 — C1 counter instruments (round 58 wave 1, kagi lane)

Seat: R58ExecCounterC1 (executor, C1 counter). Assignment: build
`plans/round-58-c1-check.py` and `plans/round-58-c1.sh` to the frozen C1_ROUTED
predicate in `plans/round-58.md` (with amendments A1/A2/A3 and the L1 conformance
rulings), run both at BASE and on the current tree, save receipts, report. Non-goals
honored: no prose fixes, no edits to the checked files.

## Files written (lane-relative)

- `plans/round-58-c1-check.py` — sha256 `d37829c017aabe789336c853bb09604d0c30978c84914a20a2d4de185040c77f`
- `plans/round-58-c1.sh` — sha256 `48eab526ff9bb8c10a7ed9462addafe9f035223f835c7540c0b044e958df0d15`
- receipts: `.ufo/waves/round-58/build/R58ExecCounterC1/{00-README,10-selftest,20-base-checker,30-base-driver,40-current-driver,50-positive-fixture,60-sha256}.txt`

## Behavior

Checker (`--root DIR` default `.`, `--verbose`, `--selftest`): evaluates I1–I8, each as a
structural parse per the frozen table plus amendments — I1 round-57 LOG/SCORECARD epoch-C
record (section-run parse, `## Round 57…` correction sections included); I2 all five
`INSTRUMENT` pins of a `controls-prefreeze-epochC*.txt` receipt equal the measured tree's
sha256 plus last `CONTROLS:` `match>=13 mismatch=0` (A1); I3 S117 Gate row (whole-bullet
parse) with registry-derived URL, date, and a ≤25-word quote located whitespace-collapsed
in `S117.body` (A2), plus used-by and `source:` clauses; I4 in two count classes (A3):
`Registry L → N` arrow pinned at landing 117, `tip count = N` / `end … N rows` equal to the
measured live `SOURCES.md` row count, gates.txt attributions equal to the file's single
carried `rows=` with the predates-S117 predication (bullet-level), each location needing ≥1
count statement, failures naming the class; I5 SKILL.md registry row with entry command,
verdict map 0/1/2+SETUP, `--selftest`; I6 AST reads (`--round` argument, no path-shaped
round-56 literal — module docstring excluded, derived-surface construction required,
EPOCHS docstring sentence naming `plans/round-` + `epoch-`, `--selftest` exits 0);
I7 S115 row names the live heading `Enabling/Disabling audit devices`; I8
`bash corpus/scope-gate.sh --lane-root /home/vgpnk/Projects/shokunin` prints
`stale_basis=0`. Tokens: `iN=1` iff item holds, `0` iff evaluated and not holding, `x`
iff input absent; value = unresolved count only when GUARD=1, else `FAIL` (L1 ruling;
`--no-challenge` is a diagnostic leg printing the numeric count). GUARD = all eight
evaluated AND on a copy whose only delta is one I4 statement changed to a wrong count
(A3 cascade: coverage tip→measured+1, else coverage arrow→118, else lesson tip, lesson
end-rows, lesson arrow, gates attribution→carried+1) the checker prints exactly count+1
AND a constant `value=0` printer stub fails that same challenge. Exit 0 iff guard=1 and
value=0; 1 otherwise; 2 SETUP. `--selftest`: 18 synthetic-root cases (each item's pass
and fail shape, aggregate all-hold, removed-input skip).

Driver: `[revision]` (default BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`) or
`--tree DIR`; materialises the tree into `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/R58ExecCounterC1/<tag>/tree`
(git archive — read-only — or tar copy with VCS internals excluded, uncommitted bytes
included); runs the checker diagnostic, applies an independent copy of the A3 mutation
cascade to a copy (only delta), requires exactly count+1, requires the stub to fail,
prints the `C1_ROUTED` line plus `c1-driver:` evidence lines; fail-closed SETUP rc2 on
bad revision/scratch/checker.

## Measured lines (exact, landed bytes d37829c0…/48eab526…, 12:27:47–12:28 −03)

- Selftest: `C1_CHECK_SELFTEST: PASS (18 cases)` rc=0 (18 ≥ 10; each item's pass and fail shape).
- BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a` (git archive, 9740 files):
  `C1_ROUTED: value=FAIL population=8 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 i8=0 guard=0` rc=1.
  Diagnostic leg (guard semantics put FAIL on the guard-bearing line): `value=8 population=8 i1=0 … i8=0`
  — the plan's BASE population census, measured not assumed (A4 records the split).
  Challenge leg at BASE: `CHALLENGE FAILED (unresolved=8): coverage-row Registry arrow -> 118:
  broken-copy value=8 (expect 9)` — I4 fails in every class at BASE, so no wrong-count delta can
  add +1 (guard=0 by construction); stub leg held.
- Current worktree (tar snapshot 12:27:53, 12610 files, uncommitted bytes included):
  `C1_ROUTED: value=0 population=8 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=1` rc=0.
  Challenge: `broken-copy value=1 == value+1 (1)` (coverage-row tip count → 120, only delta);
  stub: `stub read value=0, challenge expects 1: stub fails`.
- Positive synthetic all-hold fixture (rebuilt with the landed checker's `mkroot()`):
  `value=0 population=8 i1..i8=1 guard=1` rc=0 — the end-to-end exit-0 path proven independent
  of lane edits.

## Reading history inside the wave (tree and checker both moved)

12:14 value=4 (pre-A3 checker) → 12:20 value=2 (A3 arrow class catching the live-tree
coverage-row arrow reading `Registry 114 → 120`) → 12:23 value=1 (I6 unresolved) → 12:26
and 12:27 value=0 after the `--round` rewrite of `corpus/current-claims.py`
(R58ExecFixCode's file) landed and passed every I6 structural read. The L1's landing
re-measure is the authoritative revision-bound reading.

Observed landing hazard, recorded per the L1 (mined as **M58-3**): the 12:20
`Registry 114 → 120` line was live-tree corruption from the then-unconfined challenge
scratch leg, not a text edit; the line is restored to 117 and the hazard is closed by
the L1's review pass (challenge scratch now TMPDIR-confined with an in-tree refusal,
verified present in the landed bytes).

## Items not structurally evaluable

None. All eight items evaluate structurally on BASE and on the current tree
(population=8 everywhere, no `x` tokens). Named ceilings honored and declared in the
checker docstring: the checker trusts the files it reads (a forged authority satisfying
the parsed shape passes — K1's forgery class is the controls battery's job); I6 and I8
execute the measured tree's own `current-claims.py --selftest` / `scope-gate.sh` in
subprocesses; statement shapes are the declared ones (arrow/tip/end/rows=, bullet blocks).

## Notes for the L1

1. RESOLVED: the 12:24:11 byte change was the L1's review pass (challenge scratch
   TMPDIR-confined + in-tree refusal, wrapper leg-2 copy confined, I6 fixture-plumbing
   exclusions — all three verified present in the landed bytes by grep and by the
   18-case selftest). Both hashes (d37829c0… / 48eab526…) were unchanged across the two
   final full re-measurement passes; every receipt pins the landed bytes.
2. RESOLVED: A4 landed — the "BASE 8" is the diagnostic leg's count; the citable BASE
   line is `value=FAIL guard=0` with its diagnostic companion. Receipts show both.
3. The BASE leg runs `scope-gate.sh --lane-root /home/vgpnk/Projects/shokunin` per your
   ruling; at BASE this reads stale_basis=1 (two of BASE's three stale bases resolve
   through the fleet-root context). The item still reads unresolved at BASE, as required.

## Tooling, hygiene, provenance

- No tool installs or upgrades (operator authorization unused). python3 3.14.8, bash,
  `git archive`/`rev-parse`/`cat-file` read-only. No `git add/commit/stash/push`, no
  mutating `jj` anywhere; no host sysctls; no pacman.
- Writes confined to: the two instrument files, the receipts above, and this report.
  Scratch `/fast/scratch/hyaku/kagi-r58/R58ExecCounterC1` deleted before yield.
- Secret hygiene: no token, cookie, session or vault-item value appears in any artifact
  (none encountered; receipts carry hashes, paths and counts only — QM72).
