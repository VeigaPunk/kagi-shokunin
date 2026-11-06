# K47CriticClaims — falsification of the two declared claims (kagi round 47, attempt 1)

Seat: critic. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `252ef1cac9f41d84639c0d1f211d0e0911196112` (`2026-11-06T19:23:42Z`, epoch 1793993022).
Predeclaration `b020d978bac91284a431710148ebb7a7950eaab8` (`2026-11-06T19:31:04Z`). HEAD is the
predeclaration; `git diff --stat 252ef1ca HEAD -- corpus/ SCORECARD.md LOG.md SHONEN.md SKILL.md
PROVINCE.md` is empty, so every BASE reading below is also a HEAD-of-predeclaration reading.

Everything below was re-measured by me over committed bytes or public GETs. No lane file, registry
row, plan, control or scratch of another seat was modified. Tamper fixtures were built in
`$HYAKU_SCRATCH/kagi-r47/K47CriticClaims/` from `git archive BASE` and removed after the run; the
receipt lines are copied into `K47CriticClaims/tamper-receipts.txt`.

## 0. What I re-measured (commands, exit codes, last lines)

| # | command | rc | last line |
|---|---|---|---|
| M1 | `python3 corpus/release-clock.py` | 0 | `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` |
| M2 | `bash corpus/sources-census.sh` at BASE | 1 | `SOURCES_CENSUS: FAILED (findings=3 rows=102)` — the three declared findings |
| M3 | `awk` over `corpus/source-fetches.tsv` for S012–S016,S021–S026 | 0 | `11 rows / 6 unique urls / 7 unique url+quote` |
| M4 | `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S095.body <S027 quote>` | 0 | `RENDERED_TEXT_V1_LOCATE: count=1` |
| M5 | `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-40/capture/S096.body <S028 quote>` | 0 | `RENDERED_TEXT_V1_LOCATE: count=1` |
| M6 | live GET `https://developer.hashicorp.com/vault/docs/auth/jwt` (2026-11-06) then `locate <S012 quote>` | 0 | `RENDERED_TEXT_V1_LOCATE: count=1` (386833 bytes) |
| M7 | C1 counter on a BASE tree + real S099 provenance row/capture + **census used-by check neutered** | 0 | `C1_CENSUS_CALIBRATION: value=3 cleared=3 new=0 intact=1 bound=1` (no lesson edits) |
| M8 | C2 counter on a BASE tree + **one 18-byte non-page body**, 11 ledger rows, **stub normalizer** | 0 | `C2_FIRED_REVERIFIED: value=11 reverified=11 gate=1 (ok=S012 … S026)` (zero fetches) |

M7/M8 are the pre-freeze control the plan did not build: the cheapest tree that skips the claimed
work. Both meet their frozen targets.

## D-1 — C1: calibration, or registry bookkeeping?

**Claim under attack.** `C1_CENSUS_CALIBRATION: value = CLEARED when INTACT=1 and BOUND=1 and
NEW=0; target 3` (`plans/round-47.md` C1; same sentence in `plans/round-47-c1.sh` header).

**Case that it is calibration.** The census is the lane's self-description instrument: for every
`mined` registry row it asserts that each `used-by` file carries the row id in its `source:` field
(`corpus/sources-census.sh:230-231`), and for every registry id it asserts a fetch-provenance row
(`:254-279`). A red census is therefore the lane's committed self-description disagreeing with the
observed tree — the same class this lane has scored as calibration before: round 40 C1 (ledger rows
re-run green, `SCORECARD.md:1520`), round 45 C1 (`SCORECARD.md:1682`), and the `self-description-sweep`
rows. The plan counts real mismatches (3), not an assertion, and the counter enumerates the
population (102 ids, 3 frozen finding strings).

**Case that it is bookkeeping.** (a) `AXES.md` defines calibration as "SHONEN.md/SCORECARD entries
match observed repo state", and prompt §6 item 9 says "A calibration claim must count mismatches
between the lane's self-assessment (SCORECARD/SHONEN) and observed repo state." C1 touches neither
SCORECARD nor SHONEN: it appends two `source:` lines to `corpus/lessons/round-43.md` /
`round-44.md` and adds one `corpus/source-fetches.tsv` row. (b) Two of the three findings are the
same data-entry defect on two ids; the third is a missing provenance row — all three are registry
hygiene, not score self-assessment. (c) The work is not discretionary: §2b item 2 makes a CLEAN
census mandatory at round end ("Exit 0 is required at round end for conformance"), and the plan
also uses C1 as the round's §2b item 4 sourced claim. Counting mandatory conformance as an axis
move is the "bookkeeping-only" thin claim the run-15 addendum names (`.ufo/prompts/kagi-round-47.md:146`).

**Falsifier (M7).** The counter runs *the measured tree's own* census
(`round-47-c1.sh:55`), and no predicate or kill rule pins the census bytes. One-line neutering of the
`SC_USEDBY_NOCITE` branch (`|| finding … || :`) on a BASE tree, plus the real S099 row and capture
(no lesson edits at all), reads `value=3 cleared=3 new=0 intact=1 bound=1`. The pre-freeze controls
do not cover this: K1-F1 narrows `used-by`, K1-F2 hand-writes the digest, K1-F3 deletes rows, K1-F4
silences the census, K1-F5 adds a finding — none edits the instrument's check logic
(`plans/round-47-controls.py:168-198`; receipt `controls-prefreeze.txt` 7×MATCH). `instrument-sha256.txt`
records the BASE census sha `8d30d627…`, but neither counter reads it.

**Ruling: C1 — weakened as calibration; falsified as a measurement.** The axis label is defensible
only under this lane's instrument precedent, and it is the weakest admissible form (no score cell
moves; mandatory conformance). The frozen value 3 does not entail the claimed fix, because the meter
is candidate-owned.

**Smallest safe correction.** Run the BASE instrument bytes against the measured tree instead of the
candidate's: in `round-47-c1.sh`, `git -C "$REPO" show $BASE:corpus/sources-census.sh` into
`$T/corpus/` (the census resolves `ROOT` from its own path, `sources-census.sh:122-124`) and execute
that; or add `sha256sum $T/corpus/sources-census.sh = 8d30d627…` as a SETUP condition. Add the
matching control ("census-check-neutered → 0"). Then re-run the pre-freeze controls before data.

## D-2 — C2: freshness, or re-scoring held rows (kaidoku r29 rule)?

**Case that it re-scores.** The eleven rows' verdicts stay `fired` (kill rule: no column 1–8 edit of
`corpus/release-clocks.tsv`); the new ledger only re-declares `teaching-holds`. The docs are the same
pages at the same observed releases (`2.2.1` / `2.7.2`, unchanged since 2026-11-04 per M1), so the
"new inputs" are the same bytes. Under §9's "re-scoring a rule the lane already holds on new inputs
… is quality work", a reader could call this held-row bookkeeping.

**Case that it moves freshness.** `AXES.md` freshness = "skill claims re-verified against live
surfaces; stale items flagged or fixed". M6 shows the S012 quote still locates (`count=1`) on the
served page today, and the K2-P reference control measured 11/11 live at `2026-11-06T19:29:56–59Z`
(`k2p-capture-times.tsv`). For 10 of the 11 ids this is the first teaching re-check *after* the
round-36 firing; the clock table stays immutable, so the claim flags rather than fixes, which the
axis definition permits.

**Ruling: C2 — holds on the axis (freshness), weakened on marginal information.** It is drift
detection, not re-scoring, and it does not touch the clock verdicts. Two qualifications: S012 was
already re-checked after firing (D-5), and the freshness surface is 6 URLs / 7 located quotes, not
11 independent surfaces (D-3).

## D-3 — can C2 reach 11 with work a do-nothing control also does?

**Do-nothing: no.** K2-0 reads `value=0` (`controls-prefreeze.txt`); the ledger, the bodies and the
locate leg are all absent at BASE.

**Skip-work: yes, twice.**
1. **Named ceiling K2-C = 11** (`round-47-controls.py:240-242`): byte-correct bodies with hand-typed
   `fetched_at` score the target. The plan discloses this as a "named ceiling" and moves the check to
   an out-of-predicate "live leg". §9 does not allow that: "Before freezing, build the cheapest
   control that skips the claimed work, score it with the frozen counter, and commit that receipt:
   if it meets the target, the counter or target is wrong — fix it before data." The control met the
   target and the counter was not fixed.
2. **Full forge (M8).** The counter runs *the measured tree's* normalizer
   (`round-47-c2.sh:86-88`) and *the measured tree's* gate (`:50-54`). Replacing
   `corpus/rendered-text-v1.py` with a six-line stub that prints `count=1`, pointing all eleven
   ledger rows at one 18-byte file (`not a vault page\n`) with its real sha/bytes, typing
   `2026-11-06T00:00:01Z` and `quote_count=1`, reads `value=11 reverified=11 gate=1` with **zero
   fetches**. K2-F7 only covers a *missing* normalizer; no control covers a lying one. The counter
   never requires distinct capture paths (one path for 11 rows is legal), and `quote_count` is a
   candidate-declared integer.

**Sizing.** The frozen target counts registry rows, not surfaces: the eleven ids are 11 rows over
**6 unique URLs** and **7 unique (url,quote) pairs** (M3) — S012/S022, S013/S023, S014/S025 and
S016/S026 are byte-identical pairs. A seat can satisfy 11 with six bodies (or, per M8, one).

**Ruling: C2 — falsified as a measurement.** The target is not do-nothing reachable, but it is
reachable with a one-file instrument edit and no re-verification at all; the value 11 therefore does
not measure freshness. The underlying work is feasible and was proven feasible by K2-P and by my own
S012 live locate (M6), which is why this is a fixable instrument defect, not a wrong claim.

**Smallest safe correction.** (i) Execute the BASE `corpus/rendered-text-v1.py` and
`corpus/release-clock.py` bytes against `$T` (place them in `$T/corpus/`), or SETUP on any sha drift
from `instrument-sha256.txt` (`14f6ca6a…`, `88aaabb7…`); (ii) require `capture_path` to be distinct
per id and equal for the ids sharing a URL; (iii) move the date authority from the ledger cell to the
measured revision: require the capture's first-appearance commit (`git log --diff-filter=A --format=%ct --
<cap>`) to lie in the window; (iv) restate the target as **6 URL captures / 7 located quotes**, with
the 11-row ledger as bookkeeping, so the value cannot be inflated by duplicate rows. Add controls for
each before data.

## D-4 — separability

**Measured.** K1-P (BASE + C1 change only) = 3 and K2-P (BASE + C2 change only) = 11
(`controls-prefreeze.txt`, both MATCH). Code-level: C1 reads `source-fetches.tsv` only for S099
(`round-47-c1.sh:100-104`) and runs the census, which does not read `fired-reverify.tsv`; C2 reads
`source-fetches.tsv` column 13 only at the F ids (`round-47-c2.sh:80-84`). C1's one S099 row does not
shift or alter the F rows. The shared artifact is only the directory `.ufo/waves/round-47/capture/`,
which no predicate cross-reads. So the claims are separable as predicates, and the axes are distinct
(calibration / freshness).

**Residual coupling (not C1↔C2).** The plan's non-claim item moves the `recheck` cell of S040/S041 to
"a cadence". If that cell becomes `on-release` while no clock row is bound, M1's gate flips to
`FAILED (… unbound=2 …)` and C2's `GATE=1` collapses to 0 — value 0. This exact failure happened in
round 40 (`corpus/lessons/round-40.md` M40-11: adding S095/S096 on-release → `unbound=2` → FAILED).
The plan does not state the constraint. Route it: the S040/S041 cadence must be a dated/recheck
cadence, never `on-release`, and the C2 kill rule should name this.

**Ruling: D-4 holds.** Separability is measured and code-supported; the S040/S041 coupling is a named
risk outside the two-claim relation.

## D-5 — universal clauses in the plan text

Enumerated universals are safe: "every BASE registry id (102)" is looped by the counter
(`:76-96`), "the eleven"/F is enumerated (`:71`), "exactly one S099 row" is counted (`:100`).

Two defects:

1. **"the other eleven … have never had their teaching re-checked after the clock fired" (plan, C2
   Problem).** False for S012 on local evidence: S012 was already `fired` at round 25
   (`corpus/lessons/round-25.md:118-127`, "the feed's newest stable release is v2.2.0 … the clock
   FIRED; re-verification (ClockS012, fresh fetch 2026-10-21) … the row's teaching holds on 2.2.0"),
   and `round-25.md:227-228` states "Fired S012 predates the registry open date". Independently,
   round 39 re-located S012's quote on the live page on **2026-11-05** —
   `corpus/lessons/round-39.md` trial paragraph: "Vault `/vault/docs/auth/jwt` now serves v2.x; the
   S012 plain-text quote locates (`count=2`)". Under the operative reading ("after the round-36
   re-observation, 2026-11-04") the premise holds for the other ten; under the literal reading it is
   false. Smallest correction: replace "never had their teaching re-checked after the clock fired"
   with "have not been re-verified since the round-36 re-observation (2026-11-04)", and record
   S012's marginal freshness as ~0.
2. **"C1's counter reads none of C2's files …" (plan, Causal separability).** A universal negative no
   predicate counts; only the fixture pair K1-P/K2-P approximates it, and neither control removes the
   *other claim's directory* (both claims write `.ufo/waves/round-47/capture/`). Smallest correction:
   state it as "neither counter reads the other's ledger rows" and add the cross-tree control.

**Ruling: D-5 weakened** — one falsified "never" and one unenumerated universal; no target of either
claim changes.

## D-6 — does the BASE population miss fired rows?

**Measured population.** M1: `fired=13`. The thirteen are exactly F (11) plus S027/S028; there is no
fired row outside `F ∪ {S027,S028}` in `corpus/release-clocks.tsv` (rows S005–S032 plus S098; registry
`on-release` rows = 29, `bound=29`, `unbound=0`).

**The two exclusions are sound.** S027's quote and S028's quote both locate once in the round-40
successor captures (M4, M5, rc 0), and S095/S096 are `mined`, fetched 2026-11-05, `supersedes
S040/S041` (`corpus/SOURCES.md:102-103`). So S027/S028's teaching really is re-verified through the
successors. (Note: S096's *own* registry quote is raw-literal and reads `count=0` under the rendered
normalizer, rc 1 — a representation fact, not a defect in the exclusion, which rests on S028's
quote.)

**Two definitional defects, both harmless to coverage.**
1. The F definition says "registry status `mined`, no successor row" (`round-47-c2.sh:10-13`), but
   four of the eleven have registry correction/supersession rows: S022 supersedes S012's scope
   (`round-25.md:124-126`), S025 supersedes S014 (`round-24.md:91`), S026 covers S016/S021
   (`round-23.md:76-79`). The definition is only consistent if "successor" means "a successor that is
   itself re-verified"; S022/S025/S026 are not (they are in F). Smallest correction: restate F as
   "the eleven fired rows whose successor, if any, is itself fired/unverified".
2. The "no successor" clause is asserted in the header and never machine-checked; only the clock
   verdict and `observed_version` are read (`round-47-c2.sh:74-79`). Smallest correction: derive the
   population in the counter (fired ∧ mined ∧ no `recheck` successor) and print it, so a future
   firing or retirement changes the target visibly instead of silently.

**Ruling: D-6 holds** — the population is complete and the two exclusions are verified; the F
definition is imprecise but its membership is correct.

## D-7 (cross-cutting) — both counters trust candidate-owned instruments

M7 and M8 are the same defect in both counters: the measured tree's own `sources-census.sh`,
`rendered-text-v1.py` and `release-clock.py` are the instruments, and the pre-freeze receipt
`instrument-sha256.txt` pins their BASE hashes that no predicate reads. Round 40 already recorded the
class (`SCORECARD.md:1520`: "the counter is forgeable by loosening the expect cells"); round 47
reproduces it in the instrument layer. This is a **fixable defect**, not a tradeoff: running the BASE
bytes (or SETUP on sha drift) costs one helper function per counter and makes both values mean what
the predicates say.

## Verdict summary

| claim | axis | ruling | basis |
|---|---|---|---|
| C1 census calibration 0 → 3 | calibration | **weakened** as calibration (registry bookkeeping; mandatory §2b.2 conformance + §2b.4 sourced claim); **falsified as a measurement** | M7: 3 with the census check neutered and no lesson edits |
| C2 fired re-verified 0 → 11 | freshness | **holds** as axis work (10/11 first post-fire re-check; feasibility M6, K2-P); **falsified as a measurement**; sizing weak (6 URLs / 7 quotes) | M8: 11 with one fake body + stub normalizer; K2-C = 11; M3 surface count |
| separability C1↔C2 | — | holds | K1-P=3, K2-P=11; code paths disjoint; S040/S041 gate coupling routed |
| fired population F | — | holds | M1 fired=13 across 3 rounds/11 unique (url,quote); M4/M5 successor proofs |

**Smallest safe correction, in one line:** both counters must execute the BASE instrument bytes
against the measured tree (or SETUP on sha drift from `instrument-sha256.txt`), and C2's target must
be restated as 6 URL captures / 7 located quotes with the capture's first-appearance commit as the
date authority. With those three changes the pre-freeze controls can honestly carry a "skip-work"
control at 0, and the two claims become measurable.

## Scratch and receipts

Tamper fixtures: `$HYAKU_SCRATCH/kagi-r47/K47CriticClaims/tamper/{c1,c2}` built with
`git -C <lane> archive 252ef1ca | tar -x -C <tree>`; the counters were invoked as
`C1_TREE=<tree> bash plans/round-47-c1.sh` and
`C2_TREE=<tree> C2_ASOF=$(( $(date -u +%s) + 3600 )) bash plans/round-47-c2.sh`.
Exact last lines are copied to `K47CriticClaims/tamper-receipts.txt` in the same directory. The
live S012 GET was a read-only public page fetch (no form post, no account, no vault contact). No
secret, token, cookie or vault field was printed. No lane or fleet file was modified.

SEAT-STATUS: complete
