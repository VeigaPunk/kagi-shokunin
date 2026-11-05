# K45ReviewerPlan — surgical correctness review of the frozen round-45 counters (pre-candidate)

Scope: `plans/round-45.md`, `plans/round-45-c1.sh`, `plans/round-45-c2.sh` read in full; both counters
re-run and diffed against the BASE receipts; predicate attacked with broken-gate and staged-row
harnesses. Lane read-only; all experiments in `/fast/scratch/hyaku/kagi-r45/K45ReviewerPlan/`
(isolated `HYAKU_SCRATCH=.../iso`). Context measured: lane tip = master = `307fb50d…` (the
predeclaration commit); `git diff --stat 0d0192f…..HEAD -- corpus/` is empty; worktree dirty-path
count 7 before and after every run. Frozen counters untouched, verified by sha256:
`266d149ed13fc24a9ce19048c04a375ec46a11afa69328b89930bfbf735b02f4  plans/round-45-c1.sh`,
`cab6fbc3815f5f478d97246b5070303ad33462afac04adc850c30060bf3077ae  plans/round-45-c2.sh`.

All `bash`/`sh` receipt lines below are last lines of the named run. Repro one-liner for every
harness receipt (from `.ufo/waves/round-45/build/K45ReviewerPlan-receipts/`):
`HYAKU_SCRATCH=<scratch> bash build-fakelane.sh && bash run-experiments.sh`
The harness copies `h-c1.sh`/`h-c2.sh` differ from the frozen counters in exactly three lines
(`C1_GATE_OVERRIDE` hook; `C2_TARGET` LANE; BASE read from `fake-base.txt`); everything else is the
frozen text.

## Findings

### F-1 — HIGH — C2 awards the target while the locating instrument is in SETUP (`locate_rc` never gated)
Where: `plans/round-45-c2.sh:57` (captures `locate_rc=$?`), `:65-68` (f_add parsed from output),
`:69` (`located=$((m_add - f_add))`), `:72-73` (value gate checks census/entries/located — not rc).
Defect: `corpus/quote-locate.py` exits 2 (SETUP: malformed manifest row, unreadable input) printing
zero `NOT-LOCATED` lines, so `f_add=0` and `located=m_add`: every ADDED body row counts as located
with the locator having verified nothing. One malformed appended body row (3 instead of 4 tab
fields — a plausible single-row typo while appending the round's rows) turns the C2 target into a
false PASS. The receipt does display `quote-locate rc=2`, but neither `value` nor the frozen kill
rules act on it ("killed if any admitted entry quote is NOT-LOCATED" — SETUP is neither).
Reproduction: harness `fk-setup` case (honest candidate + one 3-column body row).
Last output line: `C2_LOCATED: value=4 added=1 entries=1 census=0 located=4 (quote-locate rc=2, rows-added=4, not-located-added=0, tree=LANE)`
Correct-behavior contrast (same harness, `fk-good`): rc=1 with real reasons gives
`located=3` only because `not-located-added=0` there; a genuinely failing row does deflate (rc=1
arithmetic is sound). Suggested handling (named, not edited — counter is frozen): any candidate
verification should treat `quote-locate rc≠0-and-not-1` as value 0, or the round names an L0
amendment; the lesson's Gate duty would also catch it, but the scored `value` line must not depend
on that.

### F-2 — MED — C1's DETECTED/POSITIVE/REAL are jointly satisfiable by a gate with no bijection logic (no negative-control fixture)
Where: `plans/round-45-c1.sh:50-51,56-58,63-64` — all three fixtures begin `# fixture` /
`# fixture scorecard` in `plans/*.md` and `SCORECARD.md`; the real tree contains none (measured:
`grep -rln '^# fixture' plans/*.md SCORECARD.md` → 0 files; only the two counter scripts
`plans/round-39-c2.sh`, `plans/round-43-controls.sh` contain it, and the gate glob is `*.md`);
`:66-72` score legs purely by exit code; there is no leg that requires a *complete, correct
synthetic* tree to stay CLEAN. A gate keyed only on the fixture marker — zero bijection logic —
therefore reads `detected=2, positive=1, real=CLEAN` and hits the frozen target value 2.
Reproduction: harness E3 (`C1_GATE_OVERRIDE=<bundle>/g-marker.sh bash h-c1.sh LANE`).
Last output line: `C1_BIJECTION: value=2 detected=2 positive=1 real=CLEAN (rc A=1 B=1 C=1 tree=LANE)`
Constant gates are correctly caught (see V-3); this is the remaining degenerate shape. Mitigation
that exists today: the gate's committed `--selftest` (its case-1 clean fixture expects rc 0 and
fails a marker gate) — the candidate verification should run it. A negative-control fixture inside
the counter would be an L0 amendment to the frozen counter; named here, not made.

### F-3 — LOW — C1 discards all gate output; a REAL FAIL is undiagnosable from the receipt
Where: `plans/round-45-c1.sh:66,68` (`>/dev/null 2>&1` on every leg), `:71-73` (`real=` collapses
rc 1 (MISMATCH) and rc 2 (SETUP) into `FAIL`). The kill rule requires naming any real round ≥ 39
that mismatches; the receipt cannot name it — a manual gate rerun is needed. Fail-safe for `value`
(FAIL → 0), diagnostics gap only.
Reproduction: harness E1. Last output line: `C1_BIJECTION: value=0 detected=2 positive=1 real=FAIL (rc A=1 B=1 C=1 tree=LANE)` — no reason text anywhere in the line.

### F-4 — LOW — C2 silently floors a `located` value that correct parsing cannot produce
Where: `plans/round-45-c2.sh:70` (`[ "$located" -lt 0 ] && located=0`). `quote-locate.py` emits
exactly one `NOT-LOCATED` line per failing manifest row (`corpus/quote-locate.py:89-115`), so
`f_add > m_add` is impossible while parsing is aligned; a negative would signal parser/manifest
divergence and deserves to surface, not to be floored. The `located ≥ 3` gate makes this
cosmetic for `value`; honesty gap only. Never triggered in any run (all receipts show
`located ≥ 0` with `not-located-added ≤ rows-added`).

### F-5 — LOW — C2's census leg executes the fleet census script at an unpinned revision
Where: `plans/round-45-c2.sh:41` — always `$FLEET/scripts/sources-census.sh` (current fleet text),
unlike `quote-locate.py`, which correctly runs from the measured tree (`:57`, `cd "$TREE"`). A
fleet-side change to the census between BASE and the candidate redefines the census leg while the
receipt keeps printing `census=<rc>`. `scripts/` is outside lane write scope so drift is unlikely;
instrument-identity note only.

### F-6 — LOW — C1 invokes the gate via `sh`, but the gate needs bash
Where: `plans/round-45-c1.sh:66,68` (`sh "$GATE"`) with `corpus/claims-declared.sh:116`
(`declare -A seen_pair=()`). On this host `sh` is bash (`readlink -f /bin/sh` → `/usr/bin/bash`,
receipt `sh-target=/usr/bin/bash`), so semantics hold and the BASE receipts prove the gate parses.
On a dash host every leg would exit non-zero → `value=0` — fail-safe, but the receipt would read
`detected=2 positive=1 real=FAIL`, mimicking a broken gate. Portability note only.

## Verified clean (each backed by a run)

- V-1 Freshness — re-runs reproduce the BASE receipts byte-for-byte: `diff controls/c1-base.txt` vs
  rerun → `IDENTICAL`; last line `C1_BIJECTION: value=0 detected=0 positive=1 real=CLEAN (rc A=0 B=0 C=1 tree=LANE)`, rc=0. Same for C2 → `IDENTICAL`; last line
  `C2_LOCATED: value=0 added=0 entries=0 census=0 located=0 (quote-locate rc=0, rows-added=0, not-located-added=0, tree=LANE)`, rc=0.
- V-2 Fixture fidelity — A/B/C encode exactly the plan's planted omissions: A (:49-51) round-90 C2
  has plan heading + post-move tag but no manifest row; B (:53-58) whole round 90 unmanifested while
  round 91 is a complete correct row set; C (:60-64) manifest axis ≠ plan-heading axis. Walked
  against the gate's checks (heading awk incl. fence/comment handling, section-once, tagged-rows=1,
  axis-cell) — no fixture trips SETUP (`missing-input`/`no-rows`/`axis-not-in-AXES`); BASE rc
  A=0 B=0 is the documented forward-only behavior C1 exists to fix, C rc=1 is the alive gate.
- V-3 Constant gates are caught by the predicate (`:72`): always-1 →
  `C1_BIJECTION: value=0 detected=2 positive=1 real=FAIL (rc A=1 B=1 C=1 tree=LANE)`; always-0 →
  `C1_BIJECTION: value=0 detected=0 positive=0 real=CLEAN (rc A=0 B=0 C=0 tree=LANE)`.
- V-4 C2 cannot read positive from a row present at BASE: `comm -13` (`:38`) makes BASE ids
  structurally excluded; harness `fk-baseid` (entry + 3 body rows citing BASE id S009) →
  `C2_LOCATED: value=0 added=0 entries=0 census=0 located=0 (quote-locate rc=1, rows-added=0, not-located-added=0, tree=LANE)`.
- V-5 C2 cannot read positive from a staged-but-unadopted row: the counter references the staged
  package nowhere (no `shokuknow` path in the script); staged ids exist for it only after adoption
  into the measured `corpus/SOURCES.md`, and only *new* ids count. Harness `fk-staged` (entry + body
  rows citing staged S053) → `C2_LOCATED: value=0 added=0 entries=0 census=0 located=0 (quote-locate rc=1, rows-added=0, not-located-added=0, tree=LANE)`.
- V-6 The honest candidate is reachable — the counter is not vacuous: harness `fk-good` (one new
  registry row S100 passing the real census, new knowledge entry `source: S100`, three body rows
  locating byte-for-byte) → `C2_LOCATED: value=3 added=1 entries=1 census=0 located=3 (quote-locate rc=1, rows-added=3, not-located-added=0, tree=LANE)`
  (rc=1 is a fixture artifact: BASE captures S089–S093 not copied, correctly ignored as non-added).
- V-7 Collision-by-overwrite cannot score: overwriting a held id keeps it in ids-base → excluded
  from ADDED → `entries` cannot fire; renumbering by document to S100+ is forced by `:38` + `:51-52`.
- V-8 Bad-REV rc handling: `bash plans/round-45-c1.sh deadbeef…` → `C1_BIJECTION: SETUP archive deadbeef…`, rc=2;
  `bash plans/round-45-c2.sh deadbeef…` → `C2_LOCATED: SETUP archive deadbeef…`, rc=2 (GNU tar exits 2
  on the empty stream, so the `||` guards at `:31-33` fire on both counters).
- V-9 No writes outside scratch: `git status --porcelain | wc -l` = 7 before and after all runs;
  the counters' write surface is `mkdir -p`/`mktemp -d`/tree extraction under `HYAKU_SCRATCH`
  (`c1 :25-27`, `c2 :24-26`); the invoked instruments are read-only in the modes used (gate: stdout
  only, `claims-declared.sh:109-192`; `quote-locate.py`: reads + prints; census `validate` without
  `--out`: stdout only per its header).
- V-10 Scratch cleanup: EXIT traps (`c1 :27`, `c2 :26`) remove the `C1-XXXXXX`/`C2-XXXXXX` dirs;
  post-run leftover scan shows only the empty scaffold dir the `mkdir -p` created (`iso/kagi-r45`).

## Residual risk and verification gaps

- The candidate gate does not exist yet; fixture behavior *at the candidate* is reasoned from the
  gate's documented amendment direction plus BASE receipts, not measured (impossible pre-candidate).
- F-5: census script identity checked at the current revision only.
- F-2: the marker gate is one degenerate shape; any fixture-vs-real separator defeats an
  exit-code-only counter — the actionable gap is the missing negative control, not this instance.
- The C2 arithmetic assumes `quote-locate.py` keeps emitting one `NOT-LOCATED` per failing row; a
  future output-shape change breaks `f_add` parsing silently (adjacent to F-4).
- Quarantine slice (S053, S071, S081, S090, S091, S093, S108, S113) handling is a lesson-level duty;
  the counters neither enforce nor bypass it (they never read the staged package). Registry already
  holds S090/S091 at BASE (census receipt), confirming the plan's collision premise.

## Receipts bundle

`.ufo/waves/round-45/build/K45ReviewerPlan-receipts/`: `build-fakelane.sh`, `run-experiments.sh`,
`h-c1.sh`, `h-c2.sh` (patched harness copies), `g-always1.sh`, `g-always0.sh`, `g-marker.sh`,
`c1-rerun.txt`, `c2-rerun.txt`. Scratch remains at `/fast/scratch/hyaku/kagi-r45/K45ReviewerPlan/`
per seat contract.
