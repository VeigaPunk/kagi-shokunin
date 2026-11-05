# ExecControls — round-36 pre-freeze control reproduction

Seat: ExecControls (leaf, fleet executor). Lane: kagi-shokunin. Scope: re-derive the eight committed
pre-freeze controls from the frozen bytes; no lane edits.

## 0. Verdict

- **Reproduction: 8/8 MATCH.** Every committed control at cb8cb659e84240a8db12e4f7b4a0def5068baf7e
  re-executes to byte-identical stdout, stderr and rc (`cmp`, receipts vs observed).
- **Instrument at BASE, re-measured:** C1 = **4** (SD5 = 3, stale = 1), C2 = **15** (20 feed rows, 15 drift).
  These match the plan's declared BASE values.
- **Defects found, routed to the L1 (not fixed here):**
  1. **SD6 is 3 at BASE, not 5.** `plans/round-36.md` declares "SD6 = 5" as a population and its kill rule
     says "SD6 differs from 5 at the landing revision → C1 fails". The pristine sweep prints `SD6=3`
     at cb8cb65. The C1 counter excludes SD6, so the value 4 is unaffected, but the plan's stated
     population and kill-rule threshold do not match the bytes it froze against. The plan text needs a
     measured correction (appended before any work commit, or the kill rule is already tripped at BASE).
  2. **`forge-sd5-early-c1` cannot discriminate on its own.** Its target, the round-34 calibration row
     (`SCORECARD.md:1357`), already names `R25-02`, `R29-01` and `R29-02` in BASE bytes. Planting the
     reds there changes no presence reading. Measured: a mutant that reads the round-34 row prints
     `SD5=0` on both the pristine tree and the planted tree, so this control adds no kill beyond
     `nowork-c1`. It is redundant, not a defect in the counter.
  3. **`forge-stale-c1` kills only a direction-restricted counter.** 59→71 leaves `stale=1` (the
     equality compares against live 70 in either direction). Its discriminating power is the
     under-declaration-only mutant (prints 3, not 4): it is the sole control that kills that mutant.
- **Tooling:** none installed or updated. No pacman. No `~/.local/bin` writes.

## 1. Frozen inputs (sha256)

| file (at cb8cb65 extraction) | sha256 |
|---|---|
| plans/round-36-c1.sh | 206cbcc53c31fad848fa8312ce0a7625a718a8211b2d4d6384021f4a0dbd086d |
| plans/round-36-c2.sh | ac010f163c03313ef97251c1cce7aacfb7d01f99d65fdad313bbd8e4284c01c6 |
| .ufo/waves/round-36/controls/observe-live.json | 3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727 |
| corpus/release-clocks.tsv | 99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd |
| corpus/self-counts.py | 5b600f0a997929cace485fc280bc74be5f0ef6f63711195855db0feaa79a6654 |
| corpus/self-description-sweep.sh | 45d8e4a2d0bbf152d1f21a7acc073dbe6cc987cb857e2f903df6a7bb6fe640a9 |

Frozen plan commit `09f27e2e16c26484b2675aa2a2b1e2ca4d3d1d8d` (plan sha256
`3ddc2da27ae91b8b22123340e1201ae63186ff54dc56ea928719fda05b4b7a5e`, matches HEAD's copy).
Extraction: `git -C <lane> archive cb8cb659… | tar -x` into scratch (read-only git).

## 2. Reproduction table

Full table with expected/observed stdout, rc and stderr: `reproduction.tsv` (same directory).
Byte-level comparison: `cmp` of `obs-<label>.out` (stdout + `rc=N` line) and `obs-<label>.err` against the
committed `.out`/`.err` receipts. Copies of both sides are in `evidence/`, with `evidence/SHA256SUMS`.

| control | expected (receipt) | observed stdout | rc | observed stderr | result |
|---|---|---|---|---|---|
| nowork-c1 | `4`, rc0 | 4 | 0 | (empty) | MATCH |
| nowork-c2 | `15`, rc0 | 15 | 0 | (empty) | MATCH |
| forge-stale-c1 | `4`, rc0 | 4 | 0 | (empty) | MATCH |
| forge-sd5-early-c1 | `4`, rc0 | 4 | 0 | (empty) | MATCH |
| setup-c1-missing-c1 | empty + rc2 | (empty) | 2 | `C1 SETUP: sweep verdict missing` | MATCH |
| forge-c2-version-c2 | `16`, rc0 | 16 | 0 | (empty) | MATCH |
| forge-c2-empty-c2 | `20`, rc0 | 20 | 0 | (empty) | MATCH |
| setup-c2-missing-c2 | empty + rc2 | (empty) | 2 | `C2 SETUP: receipt missing` | MATCH |

Forgeries rebuilt in per-control copies of the extraction (`t-*` trees; `diff -rq` against `base` shows only
the intended file changed):
- forge-stale: `SCORECARD.md:701` `--selftest 59 cases` → `71 cases`.
- forge-sd5-early: `SCORECARD.md:1357` (round-34 calibration row) appended with `(R25-02,R29-01,R29-02)`.
- forge-c2-version: `corpus/release-clocks.tsv:5` S008 `observed_version` `3.13.3` → `3.13.4`.
- forge-c2-empty: `observe-live.json` replaced by `{"format": "release-clock-observations-v1", "observations": []}`.
- setup-c1-missing: `corpus/self-description-sweep.sh` removed.
- setup-c2-missing: `observe-live.json` removed.

Runtime: C1 counter ≈150–250 s per run (it executes the ledger); C2 under 1 s.

## 3. Failure direction proven, per control

| control | direction proven | evidence of the proof |
|---|---|---|
| nowork-c1 / nowork-c2 | fail-open guard: a do-nothing tree on red bytes cannot read 0 | 4 and 15 at BASE |
| forge-stale-c1 | equality, not one-sided: over-declaration counts too | kills mutant m2 (under-declaration-only): 3 ≠ 4 |
| forge-sd5-early-c1 | wrong population (earlier round row): **intended, not achieved independently** | see §5, defect 2 |
| setup-c1-missing-c1 | fail-closed SETUP | kills m5 (SETUP → sd5=0): prints `1` rc0 ≠ empty rc2 |
| forge-c2-version-c2 | ordering: a row above its receipt value counts, not only a row below | kills m3 (one-sided ordering): 15 ≠ 16 |
| forge-c2-empty-c2 | fail-open on absent records: a row with no receipt record counts as drift | kills m4 (absent record → agreement): 0 ≠ 20 |
| setup-c2-missing-c2 | fail-closed SETUP | kills m6 (SETUP → 0): prints `0` rc0 ≠ empty rc2 |

## 4. Mutant battery (discriminating power, measured)

Each mutant is a one-site edit in a scratch copy (`evidence/forge-diffs/mutants.diff`, 104 lines).
"Pristine" = cb8cb65 base. The question each answers: does the committed control fail when the counter is wrong?

| mutant | change | pristine | on forged/setup tree | killed by |
|---|---|---|---|---|
| m1 | sweep selects the second-latest `## Round` (round-34 row) | SD5=0 (true 3) | SD5=0 on planted tree | nowork-c1 (C1 = 0+1 = 1 ≠ 4 [INFERENCE: stale term unchanged, measured 1]) |
| m2 | self-counts stale counts only `claimed < live` | C1 = 4 (survives nowork) | C1 = 3 ≠ 4 | **forge-stale-c1 only** |
| m3 | C2 counts only observed-below-receipt (one-sided ordering) | 15 (survives nowork) | 15 ≠ 16 | **forge-c2-version-c2 only** |
| m4 | C2 skips rows with no receipt record (fail-open) | 15 (survives nowork) | 0 ≠ 20 | **forge-c2-empty-c2 only** |
| m5 | C1 sweep-missing branch → `sd5=0` | (not reached) | prints `1` rc0 | setup-c1-missing-c1 |
| m6 | C2 receipt-missing branch → `echo 0; exit 0` | (not reached) | prints `0` rc0 | setup-c2-missing-c2 |

Every mutant is killed by at least one committed control. m2, m3, m4 survive the no-work controls, so the
forgeries are the only thing that kills them. That is the evidence the forgery controls carry real weight.

## 5. Controls that cannot fail as designed (defects)

- **forge-sd5-early-c1 (redundant).** The planted reds already exist in BASE at `SCORECARD.md:1357`, so the
  forgery is a no-op on the SD5 reading. The measured m1 mutant prints `SD5=0` on both the pristine and the
  planted tree; the forgery therefore does not separate a correct counter from the earlier-row mutant.
  Only `nowork-c1` does that. Repair belongs to the plan: the planted bytes must be the only occurrence of
  the reds in the earlier round (e.g. remove them from the round-34 row in the forgery, or plant a round row
  that carries them while the latest row carries none in the forgery copy). Not fixed here.
- **SD6 = 3, plan says 5.** The C1 counter does not read SD6, so the number 4 stands. The plan's stated
  population (`SD6 = 5`) and kill rule do not match pristine BASE. The pristine sweep output is at
  `evidence/observed/sweep-base-full.txt`: `SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)`,
  with SD6 lines at `corpus/lessons/round-30-verifier-spotcheck.md:41`, `round-32-verifier-spotcheck.md:54`
  and `round-33-verifier-spotcheck.md:90`. `bash corpus/claim-ledger.sh citations` → `CITATION_GATE: BROKEN (cites=2299 docs=96 unresolved=3 ephemeral=0 labeled=26)`.
  The L1 must decide whether the plan's `5` is a stale count to be corrected by an appended, measured note,
  or the kill rule as written already fails at BASE.
- **forge-stale-c1 (direction-limited).** Its stale term is `1` both pristine and forged; it only earns its
  place against the under-declaration mutant (m2). Keep it, but do not count it as a stale-population proof.

Kill accounting, measured against the no-work controls: five controls (forge-stale-c1, forge-c2-version-c2,
forge-c2-empty-c2, setup-c1-missing-c1, setup-c2-missing-c2) each kill a mutant that no no-work control kills.
nowork-c1 kills m1. nowork-c2 kills no mutant in §4; it is a BASE measurement, not a mutation killer.
forge-sd5-early-c1 is redundant with nowork-c1 (§5). No control is vacuous as executed; one is redundant.

## 6. Scope and hygiene

- Lane writes: none. All git calls were read-only (`rev-parse`, `log`, `show`, `archive`). No fixture repo was created.
- Fleet root: no writes. Sibling lanes, `.ufo/state`, `.ufo/watchdog.log`, `MANIFEST.json`, fleet `templates/` and `scripts/`: untouched.
- Deliverables: `.ufo/waves/round-36/build/ExecControls/` (`reproduction.tsv`, `report.md`, `evidence/`)
  and this report at `.ufo/waves/round-36/build/ExecControls.md`, the path the Report trailer names.
- Scratch `/fast/scratch/hyaku/kagi-r36/ExecControls/` removed before yield; all receipts and observations were
  copied into `evidence/` first.
- Disk guard before the heavy pass: `/fast/scratch/hyaku` 60% used, 322.0G free.
- Leaf rule: no subagent, no task, no swarm.
- Not run: no lane build/lint/test gate beyond the frozen counters (not assigned to this seat).
