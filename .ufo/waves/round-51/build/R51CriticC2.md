# R51CriticC2 — attack on round-51 C2 (calibration): is 3 → 0 reachable without the change?

Seat R51CriticC2, leaf member (no dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
BASE `214d8bf530a0c87c00686493f21af15396284793`, predeclaration `4ad8ab7`. Lane read-only; all fixture
work in `/fast/scratch/hyaku/kagi-r51/R51CriticC2/` (`HYAKU_SCRATCH=/fast/scratch/hyaku`; `clone/`,
`clone2/`, `receipts/`, driver `forgeries.sh` — copied beside this file as
`R51CriticC2-forgeries.sh`, receipts as `R51CriticC2-receipts/`). Nothing in this item touched a vault,
a token, a key, an account or the network; no tool was installed.

## The predicate under attack

`plans/round-51-c2.sh`: `value = M + V` — M = number of `^MISMATCH ` lines printed by the measured
revision's `bash corpus/claims-declared.sh --root .`; V = `value=` printed by the frozen round-48
counter `bash plans/round-48-c2.sh <rev>`. GUARD: g1 pins both instruments by sha256, g2 pins every
`plans/round-*.md` present at BASE byte-for-byte, g3 pins every BASE manifest data row, g4 requires
both verdict lines (else SETUP, never a zero).

Measured at BASE by this seat (own run, not copied from the controls receipt):

```
C2_SELF_ASSESSMENT: value=3 M=2 V=1 rev=214d8bf530a0c87c00686493f21af15396284793
  MISMATCH 50 C1 no-manifest-row
  MISMATCH 50 C2 no-manifest-row
  K07 DIFF stated=[CLAIMS_DECLARED: CLEAN (claims=23)] executed=[CLAIMS_DECLARED: MISMATCH (claims=25 mismatch=2)]
  claims-declared: CLAIMS_DECLARED: MISMATCH (claims=25 mismatch=2)
```

Method: `git clone --shared` of the lane, `rev-parse --show-toplevel` asserted `= the clone`,
`checkout --detach BASE`, `plans/round-51-c2.sh` copied into the clone **untracked** as `.ctl` (the
controls' own pattern, so `LANE` resolves to the clone), one throwaway-identity fixture commit per
forgery, then `bash clone/plans/round-51-c2.sh.ctl <commit>`. Every run below exits 0 and prints a
`value=`, never SETUP; the diffstat is `git diff --shortstat BASE <commit>`.

Two candidate shapes were used. `clone` = BASE alone. `clone2` = **faithful candidate shape**: BASE
plus `plans/round-51.md` byte-identical to the predeclaration (`git show 4ad8ab7:plans/round-51.md`),
so the round-51 C1/C2 headings are on disk exactly as the L1 will land them and the round is
legitimately in flight (the gate skips a round with headings but no post-move section — its own
selftest case 10).

## Results

| id | forgery | diff vs BASE | counter line | caught |
|---|---|---|---|---|
| N1 | do nothing | — | `value=3 M=2 V=1` | baseline: no free zero |
| N2 | 4 manifest rows + r51 plan + r51 section whose tagged rows describe **a different claim**; correct readings line | 3 files, +18 | `value=0 M=0 V=0` | **NO** — named ceiling QM41 |
| N3 | full M fix, correct readings line placed **outside** `## Capabilities` (end of file) | 3 files, +17 | `value=1 M=0 V=1` | yes |
| N4 | full M fix, readings line with a **different command spelling** (`bash ./corpus/claims-declared.sh --root .`) | 3 files, +18 | `value=1 M=0 V=1` | yes |
| N4c | full M fix, correct spelling but the line sits **above** the stale one (last occurrence wins) | 3 files, +17 | `value=1 M=0 V=1` | yes |
| N5 | full M fix, the round-48 **K07 pair deleted** | 3 files, +17/−1 | `value=1 M=0 V=1` | yes (falls back to the older row-16 pair: `stated=[CLAIMS_DECLARED: CLEAN (claims=2)]`) |
| N6 | hide round 50 by demoting its heading to `### ` | 1 file, +3/−1 | `value=3 M=2 V=1`, now `MISMATCH 49 C1/C2 tagged-rows-2` | yes — *by side effect* |
| N7 | hide round 50 by **deleting the whole `## Round 50 — post-move` block**; no manifest rows; readings `claims=25` | 1 file, +2/−12 | `value=0 M=0 V=0` | **NO** |
| N8 | full M fix + the reading hidden in an **HTML comment** (visible line still `claims=23`) | 3 files, +18 | `value=0 M=0 V=0` | **NO** (V leg blind) |
| N9 | `### ` demotion + hidden comment | 1 file, +3/−1 | `value=3 M=2 V=1` (49 tagged-rows-2) | yes, same side effect |
| N10 | honest shape (rows + section + visible readings line) | 3 files, +18 | `value=0 M=0 V=0` | control: the intended change also reads 0 |
| N11 | rename the heading `post-move` → `Post-move`; no manifest rows; readings line | 1 file, +3/−1 | `value=0 M=0 V=0` | **NO** by C2 |
| N12 | N11 **+ hidden comment**; visible §Capabilities still `claims=23` | 1 file, +3/−1 | `value=0 M=0 V=0` | **NO** by C2 |
| N13 | rename the heading `post-move` → `pre-move` (**9 characters**); no manifest rows; readings line | 1 file, +3/−1 | `value=0 M=0 V=0` | **NO** by C2 |
| **N14** | **faithful candidate shape**: frozen `plans/round-51.md` + N13 (round-50 heading `pre-move`, 1 readings line, zero manifest rows, zero round-51 section) | `SCORECARD.md 3+/1-` + `plans/round-51.md 119+` | `value=0 M=0 V=0` | **NO** |
| N15 | N14 but the reading is an HTML comment, so the rendered §Capabilities still says `claims=23` | `SCORECARD.md 3+/1-` + `plans/round-51.md 119+` | `value=0 M=0 V=0` | **NO** |
| N16 | N14 + the declared change (4 manifest rows, r51 post-move section, visible readings line) | `SCORECARD.md 9+`, `claims-declared.tsv 4+`, `plans/round-51.md 119+` | `value=0 M=0 V=0` | control: honest shape, faithful candidate shape |

Exact commit ids and full counter output per scenario: `R51CriticC2-receipts/`.
N14 = `1a1fc3b8507e94b6ef489cbe30ae022ea73d78f2`, N15 = `60f6d03dcd50d5108f1b14d84e6bf06eba483d5d`,
N16 = `0c7cde5b515a76eca6d3fa8fde7ab91c28ab8d66` (all in the throwaway clone2, not the lane).

## The counterexample

**N14/N15: 0 is reachable with none of the declared change.** The declared change is "append the
manifest rows `50 C1`, `50 C2`, `51 C1`, `51 C2`; land `## Round 51 — post-move`; append one
current-readings line". N14 does the last item only, in the version that is *true* (`CLEAN
(claims=25)`), and buys M=0 by renaming one SCORECARD heading. State at N14, read from the commit:

- `plans/round-50.md` untouched (g2 passes) and still carries `## C1 — operability:` / `## C2 — calibration:` — two landed claims, on disk;
- `corpus/claims-declared.tsv` = 25 rows, **zero** rows for round 50 (`grep -c '^50\t'` = 0);
- SCORECARD holds `## Round 50 — pre-move (claims C1 operability, C2 calibration)` — the post-move
  witness is gone, and the ledger's own `SEC_RE` (`corpus/claim-ledger.sh:940`,
  `— (pre|post)-move`) accepts `pre-move`, so this is not even malformed;
- the gate prints `CLAIMS_DECLARED: CLEAN (claims=25)`, which is therefore a *literal truth about a
  population that no longer contains round 50*; K07 then matches and V=0;
- the `R31-06` kill-rule substring still counts 1 (line 14, `lane-status`), so no kill rule fires.

Mechanism (not luck): `corpus/claims-declared.sh:223` checks a plan's claim headings **only when**
SCORECARD carries `## Round <R> — post-move` (`index(...) == 1`). The heading is the sole witness that
a round landed. g2 pins the plan bytes but nothing pins that witness, so the *population* M counts over
is authored by the measured party. This is the classic "delete the failing test", one character class
away from a typo.

Why the obvious one-liner fails while the rename works: the gate opens a round with
`index($0, "## Round <R> — post-move") == 1` and closes it with `/^## /`. `### Round 50 — post-move`
(N6/N9) neither opens round 50 nor closes round 49, so round-50's `[C1]`/`[C2]` rows are counted a
second time inside round 49 → `tagged-rows-2`, value stays 3. Any *real* `## ` heading (N11
`Post-move`, N13 `pre-move`) closes round 49 cleanly and is simply invisible to the round-45 leg.

## The V leg: four refusals, one blind spot

N3 (wrong section), N4 (command spelling), N4c (ordering) and N5 (pair deletion, which falls back to
an earlier pair rather than reading clean) are all refused — `stated_of()` is a literal `cmd` ⇒ `out`
pair, last occurrence inside `## Capabilities`, MISSING ≠ MATCH. The blind spot is that the extractor
is a raw regex over the section's text with **no comment/fence filtering**, unlike the gate's own D2
fix for headings: N8/N12/N15 write the pair into `<!-- … -->` and V reads 0 while the rendered document
still advertises `CLAIMS_DECLARED: CLEAN (claims=23)`. A fenced block takes the same regex path.

## N2: named ceiling, not a defect

Right axis cells, prose that describes a different claim, correct readings line → 0. The gate checks
the axis byte and the tag count, not fitness (QM41, named in the plan). Recorded because the plan's
own Change sentence promises "tagged rows" — the counter cannot tell whether those rows describe this
round's claims.

## Calibration or thin bookkeeping?

**Calibration in form, movable in population.** Both legs are genuine measurements of the lane against
executed commands: M is a count of the gate's verdict lines, V is a byte comparison of stated vs
executed readings, and the counts cannot be rolled back (g3 pins the 25 BASE rows, so `claims=23` can
never be made true again). No leg restates a claim file. But M's population is "rounds SCORECARD says
landed", and the candidate authors SCORECARD; so a correct count can summarise a shrunken
self-description. 0 does not imply the declared change was made, nor that the manifest covers the
claims the plans declare.

Verdict: **weakened** (not falsified, not "stands"). Not falsified because a do-nothing reads 3 (N1),
every pure-bookkeeping V move is refused (N3/N4/N4c/N5), the gate's D1/D2/D3/D5 classes hold, and the
honest path reads 0 in both candidate shapes (N10, N16). Not "stands" because N14 — one heading rename
plus one true readings line, zero manifest rows — reads the target 0.

## Impacted axes

- **calibration** (owned): a 0 that certifies nothing; the round-51 SCORECARD row would cite
  `value=0` over a repo whose manifest omits two landed claims.
- **freshness / provenance**: SCORECARD's round history can lose a landed round (N7) or be relabelled
  (N13/N14) with all four guard legs silent.
- Named ceiling confirmed: N2/QM41.
- Not implicated: C1, the C1 counter and the trial fixtures (separate predicate; N14 changes no corpus
  file).

## Smallest safe correction (report only — the counters are frozen and this seat does not edit them)

1. **Pin the landed population** in GUARD (five lines, no change to the two instruments): take the set
   of rounds at BASE whose SCORECARD carries `## Round <R> — post-move` and require each to still be
   present exactly once in the measured revision
   (`grep -qxE "^## Round $R — post-move([[:space:]]|$)"`-style presence check). A rename or deletion is
   then `SETUP`, never a zero. This closes N7/N11/N12/N13/N14/N15 without touching g1–g4.
2. **Filter the §Capabilities text** before `stated_of()` runs: drop HTML comments and fenced blocks
   (the same D2 rule `claims-declared.sh` already applies to headings). Closes N8/N12/N15.
3. **Add the missing control**: `K2-F8` = round-50 post-move heading renamed (`pre-move`), otherwise
   the positive fixture → expect SETUP. The battery has no control for "hide a landed round"; K2-F1 is
   the nearest and covers only readings-only. (Also worth a `K2-F9`: the reading inside an HTML
   comment, expect 1.)

## Honest scope

- **Not run**: the full `claim-ledger.sh verify` (300+ s, host-heavy; the item does not name it), so
  N7/N13/N14 are unverified against the ledger's complete audit. What *was* run, bounded: `bash
  corpus/claim-ledger.sh cells` inside the clone at BASE and at three forgery commits (`timeout 180`,
  receipts `R51CriticC2-receipts/cells-*.txt`):
  - BASE `214d8bf5` — rc **124** (killed at 180 s; the audit re-runs cited claims and BASE alone does
    not finish in that budget, so it yields no verdict);
  - N13 `c9d3657f` (`pre-move`) — rc **124**, same timeout, no verdict;
  - N7 `f150b8ab` (deleted block) — rc **124**, same timeout, no verdict;
  - N12 `01c452dd` (`Post-move`) — rc **2** with `claim-ledger: unrecognised round heading in
    SCORECARD.md: '## Round 50 — Post-move (claims C1 operability, C2 calibration)' (expected
    '## Round <N> — pre-move|post-move')`.

  So: the ledger's cells audit **refuses** the case-rename forgery (N11/N12) but did **not** refuse
  `pre-move` (N13/N14/N15) or the deletion (N7) at the parse stage — it got past the heading scan and
  then ran out of the probe's budget, which is *inconclusive, not a pass*. The static reading agrees:
  `SEC_RE` (`claim-ledger.sh:940`) accepts `— (pre|post)-move`, and line 991 `die`s only on an
  *unrecognised* heading.
- `N4b` in the driver was a harness duplicate of N10's insertion point (a correct line appended after
  the stale one) and is dropped; `N4c` is the real ordering test.
- No lane file was written outside `.ufo/waves/round-51/build/R51CriticC2*`; no git mutation in the
  lane (fixture commits only, in the two scratch clones, toplevel asserted).
