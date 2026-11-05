# K45MutBattery — C1 predicate mutation battery (pre-candidate, scratch-only)

Seat: mutation-tester, round 45, lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Measured revision: predeclaration `307fb50da825d6e6f2b5c7981c71556d35611142` (BASE claim tip `0d0192f6…` untouched).
Method: an INDEPENDENT reference gate `ref.sh` was written from the frozen predicate text in
`plans/round-45.md` §C1 only (bijection between `corpus/claims-declared.tsv` rows and landed plan
headings `## C<k> — <axis>:`; scope: round R ≥ 39 with claim headings AND a SCORECARD
`## Round R — post-move` section; in-flight rounds not checked; rounds < 39 out of scope; axis word
must match). No text was taken from `corpus/claims-declared.sh` and no sibling seat output was read.
Fixture construction (A/B/C) is copied verbatim from `plans/round-45-c1.sh`; the battery only swaps
the gate under test. The lane was never edited; all scratch lived under
`/fast/scratch/hyaku/kagi-r45/K45MutBattery/` and was removed on exit (receipts copied out first).

## Ground truth at 307fb50 (read-only measurement)

- `corpus/claims-declared.tsv`: header + 15 rows, all rounds 39–44.
- `plans/round-39..44.md`: exactly 15 `## C<k> — <axis>:` headings, axes equal to the 15 rows
  (39: freshness/calibration; 40: calibration/freshness/operability; 41: calibration/freshness;
  42: calibration/freshness; 43: calibration/freshness/operability; 44: calibration/operability/freshness).
- `SCORECARD.md`: 39 `## Round R — post-move` sections (rounds 9–18, 21–44); NO `## Round 45 —
  post-move` (grep rc=1) — round 45 is in flight, as declared.

## Anchor: BASE gate reads 0 (expected 0)

Command: `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-45-c1.sh 307fb50da825d6e6f2b5c7981c71556d35611142` → exit 0
`C1_BIJECTION: value=0 detected=0 positive=1 real=CLEAN (rc A=0 B=0 C=1 tree=307fb50da825d6e6f2b5c7981c71556d35611142)`
Matches `controls/c1-base.txt` (tree=LANE). The lane gate misses both planted omissions at BASE — the measured defect C1 fixes.

## Mutation table (value = DETECTED if POSITIVE=1 and REAL=CLEAN else 0; KILLED if value ≠ 2)

Battery command per row: `sh /fast/scratch/hyaku/kagi-r45/K45MutBattery/battery.sh /fast/scratch/hyaku/kagi-r45/K45MutBattery/<gate>.sh 307fb50da825d6e6f2b5c7981c71556d35611142`

| gate | mutation (single point) | rc A B C | REAL | POSITIVE | value | verdict |
|---|---|---|---|---|---|---|
| ref.sh | none (reference) | 1 1 1 | CLEAN | 1 | **2** | reference valid (expected 2) |
| m1.sh | plan→manifest direction dropped (heading-without-row check deleted) | 0 0 1 | CLEAN | 1 | 0 | **KILLED** |
| m2.sh | post-move gating removed (`POSTMOVE_REQ=1→0`; in-flight rounds checked) | 1 1 1 | FAIL | 1 | 0 | **KILLED** |
| m3.sh | heading axis matched loosely (`cut -f1-3→1-2`; axis word ignored) | 1 1 0 | CLEAN | 0 | 0 | **KILLED** |
| m4.sh | round ≥ 39 lower bound dropped (`MINR=39→1`) | 1 1 1 | FAIL | 1 | 0 | **KILLED** |
| ref.sh (restored re-run) | none | 1 1 1 | CLEAN | 1 | **2** | pristine bytes re-verified |

Each row's value line is in the receipts named below (last line of each receipt file quoted in `ref.txt` … `frozen-counter-at-rev.txt`).

## Findings

1. **No surviving mutant.** All four probes read value=0, i.e. the C1 value formula separates each
   broken predicate from the reference. The frozen predicate is discriminating before any candidate
   exists: dropping a direction (M1), the landed/in-flight gate (M2), the axis word (M3), or the
   scope bound (M4) each changes at least one of detected/positive/real.
2. **M1's surviving shape equals the measured BASE defect**: rc A=0 B=0 C=1 — byte-for-byte the same
   profile as the frozen counter at 307fb50 and `controls/c1-base.txt`. This corroborates that the
   candidate's new direction is exactly what moves rc A/B from 0 to 1.
3. **M2 is killed by the real tree, not by fixtures**: the mismatch it introduces is round 45
   headings (45 C1 calibration; 45 C2 coverage) with no manifest rows — the in-flight round the
   frozen scope must skip. The post-move gating is load-bearing at this revision.
4. **M4 is killed by the real tree**: without the bound, rounds 27–38 (headings + post-move, no
   manifest rows) all mismatch, e.g. 36 C1 calibration, 36 C2 freshness, 37 C2 freshness, 38 C1
   freshness, 38 C2 calibration. Note (ceiling-style, not a defect): rounds 27–35 headings use
   non-colon shapes (`## C1 — calibration, 9 → 9 (…)`, `## C1 — calibration — …`); the reference
   parser reads `<axis>` up to the first colon or end of line, so those rows carry long axis
   strings. M4's verdict does not depend on the shape question — those rounds have no manifest rows
   under any axis reading.
5. Inconclusive baseline check: none — the reference ran first and read the expected 2; every
   verdict above is conclusive against that baseline.

## Restoration evidence

- `sha256` before == after for all five gates (receipts `hashes-before.txt` == `hashes-after.txt`;
  driver printed `HASHES-STABLE`):
  - ref.sh `8cddad522e7cfcd3f2b66fedf4a5a20b248540262e808cc36fb46612fa9e1c6d`
  - m1.sh `72eff417437e2cd375944b3948e5ecc90ccc2f5c1fa1c594d8fbc1b74618ed0a`
  - m2.sh `f52252dbce9c2bb77544ffe10e0dd70a230e59c518b8c88db1b02709e6eacb15`
  - m3.sh `f022fa7e91d0948a2c7ed46e748f4e9225059d785e824f030faab84956b478e2`
  - m4.sh `2952c57241e6a70a6b24c81df9295e7cbd8b9211486dc6856eb2c6421dec2796`
- Mutants were copies; `ref.sh` was never mutated in place; post-battery re-run (ref-restored.txt)
  reproduces value=2. Scratch dir removed by the driver's EXIT trap after receipts were copied.

## Receipts (copied to `.ufo/waves/round-45/build/K45MutBattery.receipts/`)

`ref.txt`, `m1.txt`, `m2.txt`, `m3.txt`, `m4.txt`, `ref-restored.txt`,
`frozen-counter-at-rev.txt`, `hashes-before.txt`, `hashes-after.txt`, plus `ref.sh`, `m1.sh`–`m4.sh`,
`battery.sh` (the exact bytes that ran).

Last output lines: `ref.txt` / `ref-restored.txt` → `REAL-TREE-GATE: REF[BIJECTION]: CLEAN scoped-rounds=6 pairs=15 rows=15`;
`m1.txt`/`m3.txt` same CLEAN line; `m2.txt` → `REAL-TREE-GATE:   45	C2	coverage`;
`m4.txt` → `REAL-TREE-GATE:   38	C2	calibration`;
`frozen-counter-at-rev.txt` → `C1_BIJECTION: value=0 detected=0 positive=1 real=CLEAN (rc A=0 B=0 C=1 tree=307fb50da825d6e6f2b5c7981c71556d35611142)`.
