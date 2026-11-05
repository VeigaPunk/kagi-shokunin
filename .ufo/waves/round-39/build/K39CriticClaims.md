# K39CriticClaims — round 39 falsification report (critic, kagi)

Report: .ufo/waves/round-39/build/K39CriticClaims.md
Candidate `6742fdef0e261dd06a38a0fb0b66b1bc027d1bee` (lane HEAD, tracked tree clean) · BASE `06144518d3b3745e7fdf82d4207b4a3b5532a7a7` · predeclaration `1909e3876341cc90246516886def37a7c9ea92f9` · frozen plan `7c11e769cd7c2450cf46faabcd3b43fca993f388`.
Receipts: `.ufo/waves/round-39/build/K39CriticClaims/` (index `README.md`, receipts `01`–`13`, citation outputs). Scratch extractions deleted after receipts were preserved. No admission verdict is given here; this is evidence and defects only.

## 1. Frozen counters and controls — reproduced

| check | result | receipt |
|---|---|---|
| `PREFREEZE: CLEAN (controls=4 mismatch=0)` at `1909e38` (c1_nowork 0, c1_positive_three 3, c2_nowork 0, c2_positive_three 3) | reproduced | 01 |
| `bash plans/round-39-c1.sh` at candidate | **3** (target 3) | 02 |
| `bash plans/round-39-c2.sh` at candidate | **3** (target 3) | 02 |
| `bash corpus/anchor-pins.sh --root .` | `ANCHOR_PINS: CLEAN (pins=3)` rc 0 | 02 |
| `bash corpus/claims-declared.sh --root .` | `CLAIMS_DECLARED: CLEAN (claims=2)` rc 0 | 02 |
| BASE is instrument-free (8 files absent at `0614451`) | confirmed by `git cat-file -e` | 01 |
| pins equal sha256 of BASE registry anchor cells (S034, S035, S039); anchor cells unchanged BASE→candidate | confirmed | 03 |
| `plans/round-37-c2.sh` at candidate | 0 (lesson's "still reads 0" holds) | 02 |
| `corpus/laneguard.sh --selftest` | `detected=3 mutants=3 clean=ok` rc 0; implemented form `run -- LANE` works; documented form refused rc 2 (M39-2 holds) | 05 |
| S094 capture: body digest = fetch row digest = fleet `CORPUS.md` blob at `f47ad6ba`; line 116 quote matches | confirmed (local; live refetch not performed) | 04 |
| `corpus/release-clock.py` | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` | 02 |
| sibling seat receipts (K39ExecDeclared, K39ConnOverlap, K39ReviewDeclared) | consistent with my runs; no contradiction | 13 |

The two claims reproduce on their frozen predicates. Counter outputs are not contested. The defects below are in justification, prose, ledger/migration and measurement provenance.

## 2. Adversarial tests of the instruments

- **Do-nothing / forgery.** Instrument absent → 0 (`c1_nowork`, `c2_nowork`). A forged `anchor-pins.sh` that always prints CLEAN → C1 counter reads 0, not 3 (receipt 09).
- **Single-sided tamper.** Row rewritten, pin left at BASE → `DRIFT S034`, rc 1 (receipt 09).
- **Ceiling QM40, confirmed.** Row and pin rewritten together (S034 `v2.2.0→v2.2.1`, pin set to the new digest) → `ANCHOR_PINS: CLEAN (pins=3)` rc 0. The named ceiling holds exactly as declared.
- **C2 probes** (K39ReviewDeclared): padding and tag-position variants read CLEAN; case, typo, and wrong-cell variants read MISMATCH; a consistent plan+scorecard relabel reads CLEAN (K39ExecDeclared P2). This matches the declared ceiling: the gate proves agreement, not axis fit.

## 3. Defects — every surviving unsupported assertion

Severity: **H** = contradicts a frozen plan kill rule or a recorded measurement; **M** = prose/receipt claim false or unsupported; **L** = wording or pointer.

### D1 (H) — the SCORECARD and lesson claim a migration file that does not exist
- SCORECARD round-39 coverage row: "`R21-02`, `R31-02`, `R33-02`, `R34-03` (migrated, `.ufo/waves/round-39/expectation-migrations.json`)".
- That file is absent (`ls`; `git log` empty). Round 38 committed its migrations file with the candidate (`b944735`) and corrected it at close (`88374f9`).
- Consequence, measured: the census now reads `rows=94 A=90 … captures=94`. Ledger rows R21-02, R31-02, R33-02 and R34-03 each pin the anchored regex `^SOURCES_CENSUS: CLEAN \(rows=93 A=89 … captures=93 …\)$` (`corpus/claim-ledger.tsv`). Those four rows cannot match the candidate's census line, so the ledger's census claims are stale at the candidate. I did not run `claim-ledger.sh verify`; the mismatch is from reading the regex against the observed line (receipt 12).
- Frozen-plan kill rule: `plans/round-39.md` requires the census to be CLEAN at landing; the census is CLEAN, but the ledger it feeds is not. The plan's own "Ledger rows" routing says ledger rows are "not appended in round 39 … that rebinding is its own round-38-style migration". The migration file is still cited as done.

### D2 (H) — C1's coverage justification is falsified: S036 is a fourth superseded feed anchor
- `plans/round-39.md` §Read-before-freezing: "Registry anchor cells of the superseded feed rows S034, S035 and S039 are the only anchors the round-37 counter cannot see changing in place."
- `corpus/lessons/round-37.md:91` lists "Superseded feed anchors: S034, S035, **S036**, S039". `round-37.md:116`: S036 "remain[s] as superseded history rows".
- S036's source cell is the python.org feed; its anchor reads `Python 3.15.0` while S091 (3.15.2) is current.
- Kill-shot run (receipt 11): S036 anchor rewritten `3.15.0 → 9.9.9` in a scratch copy (byte change verified) → round-37 counter still **0**, C1 gate still `CLEAN (pins=3)`.
- The frozen predicate (three pins) is met as declared. The *justification* that the three pins are the complete set of invisible anchors is false, so C1 leaves one R37-V4-class row unbound. This is a scope defect in the plan's reasoning, not a counter defect. The plan's ceiling sentence ("does not cover any registry row other than the three pinned ones") is honest; the "only" sentence is not.

### D3 (M) — "MANIFEST.json rounds 1321, 1328" pointer is broken; fresh-start statement is wrong
- `plans/round-39.md` line 18 and `corpus/lessons/round-39.md` line 7: "Rounds 36, 37 and 38 closed `ok` (`MANIFEST.json` rounds 1321, 1328 and the round-36 entry); the last-three window holds no rejected closure."
- `MANIFEST.json` contains no `1321` at all (`grep -c` = 0); `1328` occurs only inside a sha256 substring. The kagi closures are entries with `round` 36, 37 and 38.
- Those entries: round 36 `verdict: rejected-honest-stop, admitted: false`; round 37 `admitted`; round 38 `rejected-honest-stop, admitted: false`. Round 38's own spot-check says "Admission: not admitted". `ok` describes only the `lanes` field.
- The lane's own round-37 plan counts round 36 as a rejected closure ("the rejected closures … of the last three rejected rounds"). Under that usage the last-three window does contain rejected closures. The fresh-start check as written is falsified (receipt 10).
- Not a claim defect (the routed round-38 items were read and dispositioned), but the statement that closes the fresh-start check is false.

### D4 (M) — the self-description sweep regressed 3 → 9 at the lane's own location; the plan does not disclose it
- Plan: "`bash corpus/self-description-sweep.sh` reads `SELF_DESCRIPTION: MISMATCH n=3 (SD6=3)`". I reproduce n=3 (SD6=3) on the BASE bytes in a lone extraction (receipt 06).
- At the candidate, at the lane's real location: `SELF_DESCRIPTION: MISMATCH n=9 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=6 …)` (receipt 06). The plan and lesson do not mention this, and the SCORECARD states no self-description outcome.
- Candidate-introduced hits (attributable to round 39):
  - **SD5 ×3** — `SCORECARD.md:14` lists `R25-02`, `R29-01`, `R29-02` as lane-status reds. The latest `## Round` section is now round 39, whose calibration row (SCORECARD:1490) does not carry them. The round-38 calibration row did carry them, so the red list was dropped by the round-39 SCORECARD section.
  - **SD6 ×1** — `SCORECARD.md:1493` cites `.ufo/waves/round-39/expectation-migrations.json` (see D1).
- The verifier-owned SD6 rows (round-30/32/33) are unchanged across BASE and HEAD; the plan's "not lane-owned, not claimed" statement for them holds.

### D5 (M) — the sweep baseline is layout-dependent; "n=3" is an extraction-layout number (measurement provenance)
- Same BASE bytes, two layouts: lone extraction → n=3 (SD6=3); a fleet-shaped sim (MANIFEST.json beside the tree) → n=100 (SD6=100) (receipt 08). The 100 is an upper-bound artifact of the sim (it lacks the real `.ufo` tree), not a faithful BASE-at-lane reading.
- The plan does not state the layout used for its BASE measurement. Any 3→9 comparison is layout-sensitive.
- Two of the candidate's nine hits (`round-34-verifier-spotcheck.md:84`, `round-35-verifier-spotcheck.md:78`) are host-absolute paths (`/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`). These lessons are unchanged between BASE and HEAD. `claim-ledger.sh` classifies them as `sibling` (line 648), and in a lone layout they print FLEET-ABSENT and are not counted. At the real location they print UNRESOLVED. [INFERENCE from code at lines 644–648 and the lone-layout selftest, not run: a faithful BASE measurement at the real location would already count them.] Either way, host-absolute paths in committed lessons are a self-description defect that predates round 39; round 39 neither introduced nor fixed it.

### D6 (M) — "copied to the wave dir" census receipts are not in the wave dir; the lesson's W04 count is wrong
- Plan §Frontier step: receipts "`/fast/scratch/hyaku/kagi-r39/l1/census/start-fleet.txt`, `start-lane.txt` (copied to the wave dir)". `.ufo/waves/round-39/census/` is **empty**. The receipts exist only in the L1 scratch directory (receipt 12).
- Lesson §Census Before: "one W04 duplicate-URL warning, S091". The receipt the lesson cites (`start-fleet.txt`) contains **19** W04 warnings (S019, S020, S021, S022, S023, S025, S026, S032, S039, S040, S041, S045, S050, S051, S069, S070, S089, S090, S091).
- Lesson §Census After: "see §Census result at the landing revision (filled from the measured commands in the round report)". No such section exists, and no round-39 report exists in the wave dir at the candidate (dangling forward reference).
- The start-lane census (`rows=93 … CLEAN`) and the candidate census (`rows=94 … CLEAN`) do match the SCORECARD's stated counts (HELD).

### D7 (M) — a candidate-introduced citation defect (SCORECARD:1493)
- See D4 and D1. `SCORECARD.md:1493` is a round-39-authored reference to a nonexistent file. Unresolved at the candidate; not mentioned in the round-39 lesson, LOG or plan.

### D8 (L) — round-38 relabel not gated (declared ceiling, restated)
- The round-38 C2 relabel (`calibration`→`operability`) remains outside the manifest and unrecorded as a mismatch. The lesson states this honestly ("unrecorded mismatch, not claimed as fixed"). Restated only for completeness; not a falsification.

## 4. Claim-axis fit, causal separation, and domain drift

- **Claim-axis fit (freshness, calibration).** C1 measures freshness of registry anchors: fit holds. C2 measures agreement of declared axis with the reporting row: fit holds as a conformance check, with the declared ceiling that it does not judge axis correctness (receipt 13 P2).
- **Causal separation.** Holds at the instrument level: C1 touches only `corpus/anchor-pins.*`, `plans/round-39-c1.sh`, and the registry; C2 touches only `corpus/claims-declared.*`, `plans/round-39-c2.sh`, and the SCORECARD/plan headings it reads. Diff enumeration BASE→candidate (`git diff --name-only`) confirms no other instrument moved. The coupling that does exist is D1: the registry/ledger census pins move with the S094 row, and the migration that should carry that was not committed.
- **Domain drift triage (what the live anchors say).** The registry's own tier-A tag-page rows S092 (Vault `v2.2.1`) and S093 (OpenBao `v2.7.2`) are dated 2026-11-05 and post-date the S034 (`v2.2.0`) and S035 (`v2.7.1`) anchors. The python feed moved `3.15.0 → 3.15.1 → 3.15.2` (S036, S039, S091). So all four superseded feed anchors (S034, S035, S036, S039) describe releases the lane's own rows already supersede. The three C1 pins protect the three that the plan named; S036 (D2) is the unprotected fourth. I did not refetch live vendor feeds (not in scope; the registry rows were not re-observed by me).
- **Do-nothing / forgery discrimination.** Adequate for both counters (section 2).

## 5. Verdict-relevant summary (for the closure reader; not an admission)

- C1 and C2 **reproduce on their frozen predicates** (3 and 3; controls 4/4; gates CLEAN; do-nothing 0; forged gate 0).
- Surviving defects that the claim/prose layer must correct before any round-39 closure is written: **D1** (migration file missing; four ledger census rows stale), **D2** (S036 falsifies the "only three" coverage justification), **D3** (fresh-start statement and MANIFEST pointer false; round 36 and round 38 are rejected-honest-stop), **D4** (self-description regression 3→9 undisclosed, including dropped SD5 red list and a dangling SD6 reference), **D6** (census receipt location and W04 count).
- D5 (layout-dependent sweep baseline) and the host-absolute sibling paths are measurement and self-description debts; they must be stated in the close.

## 6. Tools, actions, cleanup

- Tool installs: none. Only existing `bash`, `git`, `python3`, `sed`, `awk`, `sha256sum`.
- Git: explicit `git -C` on every call; no commits, pushes, or mutations in the lane or fleet. Scratch fixtures asserted `git rev-parse --show-toplevel` == fixture dir before commit.
- Writes: only under `.ufo/waves/round-39/build/K39CriticClaims/` and this report. Scratch `/fast/scratch/hyaku/kagi-r39/K39CriticClaims/` removed. A temporary `/tmp/r39base-sources.md` file was removed.
- No subagent dispatch (leaf member).
