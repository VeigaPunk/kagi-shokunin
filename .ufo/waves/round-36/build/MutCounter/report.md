# MutCounter — mutation probe of the two round-36 counters

Seat: `MutCounter` (mutation-tester, kagi round 36, leaf). Lane repo read-only; every
artifact here is new. Scratch: `/fast/scratch/hyaku/kagi-r36/MutCounter/` (removed on exit).

**Verdict: all five assigned mutants KILLED — C1 `0` and C2 `0` are load-bearing.**
**One defect found in the candidate as specified:** literal F3 (only the 15 drifting
`clock=feed` rows re-dated) does **not** satisfy the C2 operability kill rule —
`python3 corpus/release-clock.py` exits 1 with 15 `RECEIPT-MISMATCH` lines. The candidate
that does satisfy it re-dates all 30 rows to the receipt's `observed_at` (2026-11-04);
that is the tree the mutations below were run against.

## 1. Candidate

`git -C kagi-shokunin archive cb8cb659e84240a8db12e4f7b4a0def5068baf7e` extracted to
scratch (no `.git`), then F1–F4 applied by script:

| fix | bytes | sha256 after |
|---|---|---|
| F1 | `SCORECARD.md` — `## Round 36 — pre-move` + `## Round 36 — post-move`, both calibration rows naming R25-02 (FAIL), R29-01 (POLICY), R29-02 (POLICY) | `c208d15ff75ff2633917d34e93ffde2dc2e77777192a15b901223484be9ff362` |
| F2 | `SCORECARD.md:701` capability cell `--selftest` 59 cases → 70 cases, 59 kept as the `R21-03` record | (same file) |
| F3 | `corpus/release-clocks.tsv` — 15 drifting feed rows take the receipt's `observed_version`, `observed_at` 2026-11-04, `verdict`; `anchored_version` untouched | `1a550a7a4e5e2715930305329744ba9d3dfa45c031b9ff42850901da893387de` |
| F4 | `corpus/release-clock.py` — `DEFAULT_RECEIPT_SHA256` → `3f611eec…58727`, `receipt_path` default → `.ufo/waves/round-36/controls/observe-live.json`, help text follows | `b18444f8f821c314719c91acf83bba3ad76731c7f787995b2783b1db8d2fa960` |

Receipt under test: `.ufo/waves/round-36/controls/observe-live.json`, sha256
`3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727` (verified in the extraction).

**F3 is under-specified.** `receipt_matches()` (`corpus/release-clock.py:485`) requires
`receipt_date(receipt["observed_at"]) == values["observed_at"]` for **every** bound row, not
just the ones whose version drifted. Re-dating only the 15 drifting feed rows leaves 15 rows
at 2026-10-21 and the verify run prints 15 `RECEIPT-MISMATCH` (`raw/f3-literal-verify-full.txt`):

```
RECEIPT-MISMATCH S005 … S011, S017 … S020, S029 … S032
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=15 fired=15 derived=10)   rc=1
```

C2's own counter is unaffected (`0` rc=0 on that tree — its population is `clock=feed` rows
only), so this defect is invisible to the frozen counter and visible only to the operability
kill rule. The 15 rows needing re-dating are S005–S011, S017–S020, S029–S032; my candidate
re-dates all 30 rows, which matches the L1 working-tree bytes
(`corpus/release-clock.py` is byte-identical to the lane working tree; the TSV differs only in
the prose of the 15 drifting rows' notes — every data column matches). ReviewC2 reached the
same conclusion independently.

## 2. Readings

| id | tree | c1 | c2 | release-clock.py | rc |
|---|---|---|---|---|---|
| B0 no-work | pristine `cb8cb65` | **4** | **15** | — | 0 / 0 |
| P0 positive control | candidate | **0** | **0** | `CLEAN (… observed=30 fired=15 derived=15)` | 0 / 0 / 0 |
| M1 | S014 2.7.2→2.7.1, `fired`→`not-fired` | 0 | **1** | `FAILED`, `RECEIPT-MISMATCH S014` | 0 |
| M2 | `R29-02` deleted from the round-36 calibration row | **1** (SD5 0→1) | 0 | — | 0 |
| M3 | capability cell back to 59 | **1** (stale 0→1) | 0 | — | 0 |
| M4 | receipt moved aside | 0 | exit **2** `C2 SETUP: receipt missing` | — | 2 |
| M5 | `lane-status:` line deleted | exit **2** `C1 SETUP: sweep verdict missing` | 0 | — | 2 |

Component attribution (so the sum is not taken on trust):

- M2 sweep: `SELF_DESCRIPTION: MISMATCH n=85 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=1 SD6=84 SD7=0 SD8=0 SD9=0)`.
- M3 self-counts: `STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70` /
  `SELF_COUNTS: POLICY (claims=63 stale=1 …)`.
- Pristine candidate: `SD5=0`, `stale=0`, `OK SA-CAP-CENSUS-SELFTEST … claimed=70 live=70`.
- Incidental decomposition control: F2 applied without F1 → c1 `3` (stale 0, SD5 3). Each
  population moves its own unit; the counter is additive.

## 3. M5 — what the sweep actually does

Deleting the `lane-status:` line does **not** fall through to a count:

- `bash corpus/self-description-sweep.sh` → stdout `SELF_DESCRIPTION: SETUP no lane-status line in SCORECARD.md`, stderr empty, **rc 2** (it `die`s at the SD5 setup check).
- `bash plans/round-36-c1.sh` → stderr `C1 SETUP: sweep verdict missing`, **rc 2**, no integer.

That is fail-closed: the missing reading is never read as `0`. The `*` arm of the `case`
statement in `plans/round-36-c1.sh` is what makes it so — the sweep's `SETUP` line is
`tail -1` of stdout and matches neither the `CLEAN n=0` nor the `MISMATCH` arm.

## 4. Coverage notes (what these mutants do and do not prove)

- M1 is the strong C2 mutant because the row is internally consistent (v2.7.1, level with the
  2.7.1 anchor → `not-fired`) and only the receipt contradicts it: C2 compares equality
  against the receipt, not ordering or internal consistency. Both the counter and the verify
  path catch it, so the counter is not the only detector.
- C2's population is `clock=feed` only. A `rendered-quote` row can drift in `observed_at`
  without moving C2 (by design — that is exactly the F3-literal defect above). Only
  `release-clock.py` catches it.
- M3 shows the stale population counts a *low* claim (59 vs live 70); the frozen forgery
  control covers the *high* side (71). Both directions are measured.
- M2 shows SD5 reads the latest `## Round` section only: the same three reds also appear in
  the pre-move row and in the closing paragraph, and neither substitutes for the calibration
  row.
- Not probed (outside this assignment): an empty/absent `SCORECARD.md` row removal, a
  `--selftest`-count forgery on another self-count row, receipt/table co-editing (ReviewC2's
  forgeF), and C2's above/below-receipt ordering controls (frozen, already executed).

## 5. Method, honesty, dead ends

- Every mutation is a byte-exact edit of one file in an isolated clone of the candidate
  (`m1`…`m5`), applied by `mutate.py`, run with the frozen command, then restored from a
  golden copy and re-verified by sha256; the c1/c2 reading after restore is `0` (M1, M2, M4
  re-run; M3/M5 restored to the same bytes as M2's restored tree, which re-read `0`).
- **Dead end 1 (disclosed):** my first patch script wrote `SCORECARD.md` twice — the F2 write
  overwrote the F1 append — so the first candidate c1 read `3`. Caught by diffing the tree
  against `git show cb8cb65:SCORECARD.md`; F1 re-applied, F1+F2 verified by `grep -c '^## Round 36'` = 2.
- **Dead end 2 (disclosed):** the first M5 sweep was invoked with cwd = the scratch root,
  which is itself a pristine extraction, so it measured the BASE tree (`MISMATCH n=6 … SD5=3`)
  rather than the mutant. Re-run with cwd = `m5` (the result in §3). All other runs use
  `cd <tree>` before the command.
- **Scratch artifact:** `SD6` reads 84 on the `git archive` extraction (citations to
  `.ufo/reports/<round>/<lane>.md` do not resolve outside a fleet checkout) against 3 in the
  lane checkout. SD6 is explicitly outside C1's population, `c1` does not read it, and it is
  identical on the pristine candidate and on M2, so it moves no verdict here.
- Tool installs: none. No package manager was invoked.

## 6. Artifacts

`mutations.tsv` (id, mutation, expected, observed, rc, verdict), `raw/*.txt`
(`poscontrol.txt`, `poscontrol-components.txt`, `base-nowork.txt`, `f3-literal-verify.txt`,
`f3-literal-verify-full.txt`, `m1-s014-version.txt`, `m2-sd5-red-removed.txt`,
`m3-capability-59.txt`, `m4-receipt-missing.txt`, `m5-lane-status.txt`).
