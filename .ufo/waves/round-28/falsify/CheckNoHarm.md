# CheckNoHarm — round-28 falsify: six axes/trends no-harm, owned-lane boundaries, eight BUILD connector revisions
Target `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, BASE `3553d499577084a6c98d7078906017840bbf7b28`,
lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`. Seat `KagiR28.CheckNoHarm` (reviewer, leaf).
Lane-authored advice; no SHONEN mark; no production edit; no git/jj mutation in the lane.

**Verdicts** — six axes/trends no-harm **PASS**; owned-lane boundaries **PASS**; eight BUILD connector
revisions **PASS (narrow)**, wording mismatch F3; freshness claim substance (C1+C2, one claim) **PASS**
(independently re-measured); freshness claim *evidence inside the pinned tree* **FAIL** (F1);
calibration **PASS** — no delta claimed (`SCORECARD.md:1122`).
## Findings
**F1 MED-HIGH — the pinned candidate ships the round's scorecard without the measured after-state it
points at.** `SCORECARD.md:1121` ends both claim rows with "→ measured revision below";
`SCORECARD.md:1128-1129` are the file's last lines ("…appended below after the measured revision
lands"); the file ends at 1129 — no appendix (round 25's equivalent is present, `SCORECARD.md:982`+).
Committed build artifacts carry BASE-side numbers only (`build/XC1Measure-base-c1.json`,
`build/XC1Measure-patched-probe-c1.json`, `build/XC2Measure-c2-base.json`); the candidate-side
`build/XC1Measure-candidate-c1.json` (5848 B, mtime 14:47) and the integrated-tool BASE rerun are
**untracked** in the lane, and `build/XC1Measure.md` was edited after the commit. Counterexample:
`git ls-tree -r --name-only 62a33b1 -- .ufo/waves/round-28/build | grep -c candidate` → 0 while the
file exists on disk (`git status` → `?? …/XC1Measure-candidate-c1.json`). At the pinned candidate the
only claimed axis therefore has no in-tree after-state (UNPROVABLE from the tree); I re-measured it
independently (below) and it holds — the defect is evidence placement, not the claim.

**F2 LOW-MED — interpreter-specific build artifacts in the pinned candidate, plus a silent
re-collation of `corpus/stamps.tsv`.** Committed: `.ufo/waves/round-28/tools/__pycache__/c2-measure.cpython-314.pyc`
and `separability.cpython-314.pyc` (`git ls-tree -r 62a33b1`); untracked in the checkout:
`corpus/__pycache__/`, `tools/__pycache__/c1-measure.cpython-314.pyc` (same class flagged in
`build/ConnTsukuroi.md`). `corpus/stamps.tsv` was regenerated in a different collation (uppercase paths
moved to the end; first difference at index 0); no path dropped (`dropped=[]`,
`added=['corpus/lessons/round-28.md']`) and the new order is what R24-05 now pins — but the re-collation
is not recorded in the round's migration note.

**F3 LOW — the adjacency row understates what the eight connectors found.** `SCORECARD.md:1126` says
"eight connector scans found vocabulary overlap only (`REGRESSED`, registry grammar), no absorbed
ground". No ground was absorbed (verified below), but two connectors found *mechanism* overlap:
`build/ConnTsukuroi.md:55` (pacman `vercmp` "Contradicts" — `vercmp 3.15.01 3.15.1` → `0`, a comparator
can never see C1's defect) and `:57` (tsukuroi's `section_key` "Absorbs" it — silent `int()`
canonicalization, same 4301-digit hazard); `build/ConnKumitate.md:31,36` reports three sibling sites
already accepting leading-zero tokens ("the defect class C1 closes is fleet-wide, not kagi-local");
`build/ConnSourcesCensus.md:74,80` states a contradiction — with the round's own frozen "SemVer S042
§2" citation, not a sibling's ground. Honest form: "no sibling ground absorbed; two sibling lanes carry
the same defect class, reported not patched" (the form rounds 23/25 used). No ownership row changed.
## Narrow PASS evidence
- **Six axes, no scalar movement:** every `| <axis> |` score row is byte-identical BASE→candidate
  (diff of axis rows → empty); the round-28 table `SCORECARD.md:1121-1126` has exactly the six axes,
  each "9 → 9"; no axis retired/split/renamed; no capability/retirement/promotion claimed
  (`SCORECARD.md:1117`); `corpus/feature-claims.json`, `corpus/knowledge/*`, `corpus/surface-census.tsv`,
  `corpus/state-shape.tsv` untouched → the coverage cell's "no knowledge entry or governed surface" holds.
- **Trends honest:** "last capability entered round25" matches `SCORECARD.md:1021` (round 26) and
  `:1085` (round 27), both claiming none; window N=3 → rounds 26-28 without one → the nudge can fire at
  round 29 ("cannot fire before round29", `SCORECARD.md:1115-1116`).
- **Owned-lane boundaries:** the commit touches 12 in-repo files + `.ufo/waves/round-28/*` only
  (`git show --stat 62a33b1 -- . ':!.ufo'`); `corpus/adjacency.tsv` unchanged → R17-02 unchanged
  (`SCORECARD.md:1126`); no `$HOME`/`~`//home/` reference in candidate `corpus/release-clock.py` or
  `corpus/lessons/round-28.md` (grep 0 hits, same as BASE) → no host-private read; no sibling-lane or
  fleet-root file in the candidate tree.
- **Eight connector revisions present and consistent:** all eight `build/Conn*.md` are in the candidate
  tree; seven give explicit "no absorb / no contradict / neutral" rulings (chousa, kasegi, kengaku,
  kotoba, kumitate, tabi, tsukuroi), the eighth is the W04/E04 registry scan; the connector-demanded
  shapes are implemented — DERIVATION reads **only** the feed row's anchor cell
  (`corpus/release-clock.py:349-363`, called at `:618-619`; never `teaches`) and ordering never calls
  `int()` (`:387`, `:409-415`) → no sibling's silent-canonicalization mechanism was absorbed.

## Commands run (exit codes) — scratch clone `/fast/scratch/hyaku/kagi-r28/CheckNoHarm/clone` (deleted)
`env -i PATH=… HOME=… LC_ALL=C PYTHONDONTWRITEBYTECODE=1 python3 -I -B`:
- `tools/c1-measure.py 3553d499… BASE` → 0 `mishandled=3/4 typed=0/4 other=1/4 control_clean=True`;
  `… 62a33b1… CAND` → 0 `mishandled=0/4 typed=4/4 other=0/4 control_clean=True`
- `tools/c2-measure.py 3553d499… BASE` → 0 `groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True`;
  `… 62a33b1… CAND` → 0 `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True`
- `corpus/release-clock.py` (BASE and CAND trees) → 0, byte-identical
  `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`;
  `corpus/release-clocks.tsv` diff empty
- `corpus/release-clock.py --selftest` → 0 `PASS (106 cases)`; `corpus/sources-census.sh` → 0 `CLEAN
  (rows=49 A=47 … captures=49 …)`; `corpus/self-counts.py` → 0 `SELF_COUNTS: CLEAN (claims=60 stale=0)`;
  `corpus/row-identity.sh stamps` → 0 `count=91 sha256=14663dcd…`; `scorecard-rounds` → 0 `count=34
  sha256=c59f5341…` → every migrated expectation (R12-03/R13-01/R21-02/R22-03/R24-05/06/15, R25-03)
  holds. Read-only: `git show/ls-tree/status/diff` at both revs; `git -C <sibling> status` (7 lanes);
  fleet-root `git status`. Receipts: `.ufo/waves/round-28/sandboxes/CheckNoHarm/receipts/*.json`.
## What I did NOT check
No lane gate/selftest in the lane checkout (all runs in the scratch clone); no host-private ledger row
executed (`corpus/claim-ledger.sh verify` not run — it would execute host rows); no feed/network fetch;
no sibling lane gate or selftest run; the round-28 END census is **absent** from the pinned tree
(`git ls-tree -r 62a33b1 -- .ufo/waves/round-28 | grep -i census` → only `census-start.txt`; the plan's
Frontier step requires an END census) — observed, but CritConformance's item; the lesson's M28-1..M28-4
evidence (CritMistakes); C1/C2 fixture semantics beyond the frozen commands' outputs; the
`sdk/v0.26.0`-style left-boundary residual (`STABLE_TOKEN_RE`, `corpus/release-clock.py:345`, allows a
preceding `/`; no live row does) and the "below-newest non-canonical feed entry" leniency named only in
`build/XC1Measure.md` R4. Attribution of fleet-root dirt (`.ufo/state/*.report-baseline`, `watchdog.log`,
untracked `.ufo/waves/round-28/build`) to fleet tooling rather than this lane is [INFERENCE] from mtimes;
no kagi artifact was found there. Tooling: no install or upgrade (pacman pause respected).
