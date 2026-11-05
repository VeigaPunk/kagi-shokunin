source: S034, S035, S040, S041 — the four cited registry rows, re-opened 2026-11-04 by the fetch seat (`.ufo/waves/round-36/build/ScribeGate/`); located quotes are pasted into §Gate by the L1 from those receipts (TODO)

# Round 36 — self-assessment calibration and release-clock freshness

Frozen claim: `plans/round-36.md` at `09f27e2e16c26484b2675aa2a2b1e2ca4d3d1d8d`.
Frozen instrument bytes and the executed predeclaration controls:
`cb8cb659e84240a8db12e4f7b4a0def5068baf7e`. BASE for both claims is the
predeclaration commit; no target, counter, kill rule or population is rebooked
after data. Motivating rejected closures: round32 at
`76f4eeae7aa9af4dbb9423f5632b55791824253a`, round33 at
`f9dc06fd8f6b43c175193c76dc6350468f551634`, round34 at
`063c407494276d0c616e6c712a2e5d7aeb7e3768`. They remain rejected; no new control
backdates old evidence.

## Claims

- **C1 — calibration: SCORECARD self-assessment mismatches 4 → 0.** Counter
  `plans/round-36-c1.sh` (committed at `cb8cb65`, sha256
  `206cbcc53c31fad848fa8312ce0a7625a718a8211b2d4d6384021f4a0dbd086d`), one
  unsigned integer on stdout, SETUP exit 2 on any missing reading. Population:
  SD5 (`corpus/self-description-sweep.sh`: red ids named on the SCORECARD
  `lane-status:` line that the latest `## Round` section's calibration row
  omits) plus `stale` (`corpus/self-counts.py`: declared self-count rows whose
  claimed integer differs from the live source), the latter extended at BASE with
  the SCORECARD capability-table row `SA-CAP-CENSUS-SELFTEST` (ledger `R21-03`).
  BASE **4** = SD5 3 (`R25-02`, `R29-01`, `R29-02`) + stale 1
  (`SCORECARD.md:701` claimed 59 cases, live 70); target **0**. Both parts are
  lane-owned SCORECARD bytes; the SD6 class is not in this reading and is
  preserved. Kill rules (frozen): SD6 differs from its BASE value, or any
  non-owned verifier file is edited → C1 fails, admission withheld; the counter
  printing 0 on a tree where either population is non-empty (removed
  instrument, missing reading, SETUP-shaped output read as zero) → C1 fails; a
  wrong-number forgery (`71 cases`) or a red-id forgery planted in an earlier
  round row is not counted → C1 fails. Controls (committed at `cb8cb65`, in
  `.ufo/waves/round-36/controls/`): no-work `4` rc0; stale-forgery `4` rc0;
  early-row red forgery `4` rc0; missing instrument → exit 2 with
  `C1 SETUP: sweep verdict missing` and no integer.
- **C2 — freshness: declared release clocks re-observed, drift 15 → 0.** Counter
  `plans/round-36-c2.sh` (committed at `cb8cb65`, sha256
  `ac010f163c03313ef97251c1cce7aacfb7d01f99d65fdad313bbd8e4284c01c6`), one
  unsigned integer on stdout: `clock=feed` rows in `corpus/release-clocks.tsv`
  whose `observed_version` or `verdict` differs from the committed live receipt
  `.ufo/waves/round-36/controls/observe-live.json` (sha256
  `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`, observed
  2026-11-04T23:42Z), plus rows the receipt does not carry (fail closed). BASE
  **15** of the 20 feed rows; target **0**. Population: only `clock=feed` rows;
  `rendered-quote` rows have no version and are out of population by the table's
  own schema. Kill rules (frozen): `python3 corpus/release-clock.py` (verify)
  does not print a CLEAN verdict at the landing revision against the repointed
  default receipt → operability is harmed → C2 fails; a table value *above* the
  receipt value is not counted (ordering instead of equality), or an empty
  receipt reads 0 → C2 fails; any historical receipt is rewritten or deleted
  rather than superseded → C2 fails. Controls (committed at `cb8cb65`): no-work
  `15` rc0; one row above its receipt value → `16` rc0; empty receipt → `20`
  rc0; receipt removed → exit 2 with `C2 SETUP: receipt missing`.

Re-execution of the frozen counters over committed bytes (my own run, from a
`git archive 09f27e2` extraction): `plans/round-36-c1.sh` → `4` rc0,
`plans/round-36-c2.sh` → `15` rc0, matching the frozen BASE and the committed
control receipts.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M36-1 | self-declaration | `SCORECARD.md:14` (the `lane-status:` line) names the routed reds `R25-02,R29-01,R29-02`; the round-35 calibration row (`SCORECARD.md:1374` at BASE, the latest `## Round` section) names none of them, so the sweep's SD5 class reads 3 — measured at BASE: `MISMATCH SD5 SCORECARD.md:14 red id 'R25-02' is absent from the latest calibration row (SCORECARD.md:1374)` ×3 (`SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)`). The class was repaired before: round 32's calibration row (`SCORECARD.md:1314`) says "red-id naming repaired", and rounds 33 and 34 kept naming the three reds (`SCORECARD.md:1342`, `:1357`; the sweep at the round-34 close reads `SD5=0`). Round 35's row dropped the names again — the sweep reads only the *last* `## Round` section, so a round that writes a fresh row silently re-opens what the previous row repaired. | `none` — QM32 (a plan that touches a gate enumerates every red row that gate prints at BASE, from a measured run committed with the plan) was satisfied in rounds 33 and 34, whose plans read the sweep at BASE; no criterion binds a repaired red-id naming to the *next* round's calibration row, so each new row can silently re-open the class. | C1's SD5 arm makes the omission countable, and the round-36 calibration row names `R25-02` (FAIL), `R29-01` and `R29-02` (POLICY) with their state instead of clearing them. Shown able to fail: `controls/forge-sd5-early-c1.out` (`4`, rc0 — reds planted in an earlier row only are not counted) and `controls/setup-c1-missing-c1.out` (exit 2, no integer). |
| M36-2 | number-drift | The SCORECARD capability row (`SCORECARD.md:701`) declared the source-census `--selftest` at **59 cases** while the live gate prints `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` (executed 2026-11-04, rc0). The prose copy was last written at round 23 (`7af07b4`, where the ledger pinned 59 too); the census grew to 70 at round 24 (`a3eb6c7`, whose ledger row `R21-03` already pins 70 and whose `corpus/sources-census.sh --selftest` re-run here prints `PASS (70 cases)`), and the SCORECARD copy stayed at 59 through round 35 — twelve rounds stale. The cell was introduced at the capability's first working round (21, `c41af82`, at 40 cases) and sat outside every self-count check for fifteen rounds (21–35): `corpus/self-counts.tsv` (`82745e2`, round 25) bound SKILL.md, PROVINCE.md, corpus/README.md and later `corpus/knowledge/*.md`, but never SCORECARD.md — so every "self-description" round (32–35) ran a sweep that never compared this cell. | `QM21` (round 25) — "a current-tense number a committed doc states about this lane's own artifacts is bound to the live source that defines it (`corpus/self-counts.tsv` …)"; the criterion named the binding surface but its population excluded SCORECARD.md, and `QM26` extended the population to `corpus/knowledge/*.md` only, so the class stayed uncovered. | The population is extended at BASE with `SA-CAP-CENSUS-SELFTEST` (`corpus/self-counts.tsv:87`), the capability row is corrected to the live 70 with 59 kept as the round-21 record, and the three count declarations that the ledger append invalidated are re-bound in the same landing. Shown able to fail: `controls/forge-stale-c1.out` (`4`, rc0 — a forged 71 leaves stale 1) and `controls/setup-c1-missing-c1.out` (exit 2). |
| M36-3 | frozen-instrument drift | An earlier attempt of this same round edited the frozen counters *after* the freeze commit `cb8cb65`: commit `404a7b94b09af4df692e6d5b04f59b143531462c` (parent `cb8cb65`, kept only as `refs/jj/keep/404a7b9…`, **not** an ancestor of `master`) changed `plans/round-36-c1.sh:12` and `plans/round-36-c2.sh:12` from `root=$(cd "$(dirname "$0")/.." && pwd)` to `root=${LANE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}` (discarded bytes sha256 `bfa1ec8d04c8757dc391be02167ffb4066a3ebf9fe2920c938e59298f53575c2` and `a11034c3d5d3f544d4923d6a42fbbd4e6d168a344e86f7c88aa164d8117e7bde`). The committed instrument bytes are identical at `cb8cb65` and at `09f27e2` (`206cbcc5…`, `ac010f16…`, `grep -c LANE_ROOT` = 0 in both), so the `LANE_ROOT="$BASE"` prefix in `plans/round-36.controls.tsv` is inert against the frozen scripts, which resolve their own root from their own location. | `QM29` — a round's claims file is committed alone before any work commit and its frozen text and counting commands never change afterwards; the edit was made after the freeze commit and never reached `master` (it survives only as an abandoned keep commit), which is exactly the drift QM29 forbids. | The edit never reached `master` and was discarded rather than landed; the committed bytes were re-proved by re-execution rather than by assertion — `git archive 09f27e2` extracted and both counters re-run (`4` rc0, `15` rc0), and the same scripts over the candidate tree read `0` rc0 and `0` rc0. The plan-carry commit `91746685ea22552d9b7bef5b52ab87a840eba0e6` has the identical tree to `09f27e2` (`847106900cbd434ea1cfdd703fd5c89e78970c79`), so the attempt-1 predeclaration was carried forward unchanged. A separate in-round episode — the wrong-column `corpus/SOURCES.md` edit — is recorded in §Migrations below, not as a fourth mistake row. |

## Migrations

| Surface | Old | New | Where recorded |
|---|---|---|---|
| `corpus/release-clocks.tsv` — 15 drifting `clock=feed` rows | S012 `2.2.0`/2026-10-21/`fired`; S013 `2.2.0`/`not-fired`; S014, S015, S016, S021, S025, S026 `2.7.1`/`not-fired`; S022, S023, S024 `2.2.0`/`not-fired`; S027, S028 `3.15.1`/`fired`; S040, S041 `3.15.1`/`not-fired` | S012 `2.2.1`/`fired`; S013 `2.2.1`/`fired`; S014, S015, S016, S021, S025, S026 `2.7.2`/`fired`; S022, S023, S024 `2.2.1`/`fired`; S027, S028 `3.15.2`/`fired`; S040, S041 `3.15.2`/`fired`; every `observed_at` → 2026-11-04; `anchored_version` untouched; each note names the round-36 receipt | receipt `.ufo/waves/round-36/controls/observe-live.json` (sha256 `3f611eec…`); `plans/round-36.md` §C2 BASE drift list (12 of 15 change verdict, 3 keep `fired`: S012, S027, S028) |
| `corpus/release-clocks.tsv` — 15 further bound rows (values unchanged) | S005–S011, S017–S020, S029–S032 at `observed_at` 2026-10-21 | same `observed_version`/`verdict`, `observed_at` → 2026-11-04, note gains "re-observed unchanged by the round-36 receipt observe-live.json (2026-11-04)" | `corpus/release-clock.py` `receipt_matches` (lines 475–495) compares each bound row's `observed_at` date with the receipt's, so the whole table is re-dated; the counter's population is unchanged (only `clock=feed` rows are counted) |
| `corpus/release-clock.py` — default receipt pin | `DEFAULT_RECEIPT_SHA256` `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`; `receipt_path` default `.ufo/waves/round-26/observe-2.json`; argparse help "default is the round-26 rearmed receipt" | `DEFAULT_RECEIPT_SHA256` `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`; `receipt_path` default `.ufo/waves/round-36/controls/observe-live.json`; help "default is the round-36 rearmed receipt" | the round-26 receipt is retained byte-identical (sha256 `13b8540c…`, committed at `d30c989`) and stays citable with `--receipt … --receipt-sha …` — superseded, never rewritten |
| `corpus/claim-ledger.tsv` — claim rows | 79 rows (`R21-04` pins `^79$`) | 82 rows: `R36-01` (C1 counter), `R36-02` (C2 counter), `R36-03` (release-clock verify against the repointed default receipt) | `corpus/claim-ledger.tsv:98-100` |
| `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:64` — the three count declarations that count the ledger | `79` claims / `79` claim rows / `79 rows` | `82` / `82` / `82` | `corpus/self-counts.py` (rows `SC-SKILL-CLAIMS`, `PV-CLAIMS`, `RD-LEDGER-ROWS`, all bound to ledger `R21-04`); the append itself invalidated them, so they are re-bound in the same landing (measured `stale` 3 → 0) |
| `SCORECARD.md:701` — capability row `source registry + census gate` | `--selftest` 59 cases (`R21-03`) | `--selftest` 70 cases (`R21-03`; the round-21 record said 59, measured stale by round 36 C1) | ledger `R21-03`; live `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` |
| `corpus/SOURCES.md` — S034, S035, S040, S041 (the four rows the plan's §Frontier step names) | S034 `opened` 2026-10-21, `recheck` 90d, `used-by` `corpus/lessons/round-25.md`; S035 `opened` 2026-10-21, `recheck` 90d, `used-by` `corpus/lessons/round-25.md`; S040 `opened` 2026-10-21, `recheck` on-release, `used-by` `corpus/lessons/round-26.md`; S041 `opened` 2026-10-21, `recheck` on-release, `used-by` `corpus/lessons/round-26.md` | **as landed at the time of this draft, no cell changes.** Each row's `opened` date old→new = 2026-10-21 → 2026-10-21 and each `recheck` cadence old→new = `90d`→`90d` (S034, S035), `on-release`→`on-release` (S040, S041): `git diff corpus/SOURCES.md` is empty and the file sha256 `b974504e40f250aa2402c9c08fddb54c546f1144a2f5e0b1910283c48629ef72` equals the `HEAD` blob. The plan's §Frontier step named these rows for a `recheck`/`used-by`/observation touch; an in-round edit wrote 2026-11-04 into the `opened` column — the wrong column, read as the `recheck` cell — and the census accepted it (exit 0) because both columns accept ISO dates; that edit was reverted | `plans/round-36.md` §Frontier step ("Rows touched: S034, S035, S040, S041 — `recheck`/`used-by`/observation cells only, old → new logged in the lesson"). The `recheck` cells carry cadences (`90d`, `on-release`), not dates, so the only dated cell on these rows is `opened`. Whether the four rows should be re-dated (2026-10-21 → 2026-11-04) is **unknown** — the plan's frontier step and the landed bytes disagree, and the decision is the L1's, not this seat's |

## Gate

TODO: filled from the fetch receipts.

The located quotes, access dates, body sha256 values and anchor-presence
verdicts for S034, S035, S040 and S041 were produced by a separate seat and are
pasted here by the L1 from those receipts; this seat opened no URL and quotes
nothing.

## Boundaries and retained debt

- `R25-02` (FAIL) and `R29-01`/`R29-02` (POLICY) remain operator-owned and
  routed; the round-36 calibration row names them, it does not clear them.
- The C1 counter's `stale` producer (`corpus/self-counts.py`) exits 2 at BASE
  and at the candidate because two rows are POLICY (`R29-01`/`R29-02`, "command
  not allowlisted"). The counter reads the `SELF_COUNTS:` summary line, so a
  POLICY exit does not become a zero; the reading is bounded by that producer's
  envelope.
- SD6 is layout-sensitive and is not a portable constant. Measured by this
  seat: a `git archive 09f27e2` extraction reads
  `SELF_DESCRIPTION: MISMATCH n=6 (… SD5=3 SD6=3 …)`; the live lane checkout
  reads `n=5 (… SD5=0 SD6=5 …)`. The two extra lines are the round-34 and
  round-35 verifier spot-check files' absolute `/home/vgpnk/…/corpus/SOURCES.md`
  citations, which the gate classes as an unresolved sibling only when the lane
  root *is* the live lane path. The frozen C1 kill rule names SD6 = 5, which
  matches the live-lane reading; it does not match an extraction reading of 3.
  This round does not change SD6, but any future use of that number must say
  which layout it was measured in.
- Per the fetch receipts this seat read (`.ufo/waves/round-36/build/ScribeGate.md`
  and `.ufo/waves/round-36/build/ScribeGate/gate.md` — not re-opened by this
  seat): the S034/S035 anchor cells now describe a superseded first-stable entry
  (`v2.2.0` is the second stable Vault entry, `v2.7.1` the third stable OpenBao
  entry), and the S040/S041 anchor titles (`Python 3.15.1 documentation`) are
  absent from the served pages, which serve the 3.15.2 titles. Re-anchoring
  would trip the gate's DERIVATION rule, so it is recorded as debt, not
  silently repaired.
- No account, vault, credential, private reference, handler or service
  operation is authorized or performed by this round. The four feeds were read
  unauthenticated over public HTTPS.

## Next

Round 36 leaves the lane's calibration population closed at the bytes it
measures — the two self-assessment classes the lane's own documents were
already failing (the lane-status red set and a stale capability count) are now
counted by a counter that fails closed, and the release-clock table is
re-observed against a pinned, independent receipt so drift is a measured
number rather than an unnoticed one — and the next move is the one this round
deliberately did not take: decide, as a claim-level question rather than a
cell-level edit, whether the four cited registry rows should be re-anchored to
the releases the round observed (S034/S035 first-stable-entry, S040/S041
documentation title), since the DERIVATION rule makes that a re-binding of
what the rows teach and not a date refresh, and no counter in this lane
currently measures that class; until then the drift is bounded, named and
routed, and the next round should re-run both counters over committed bytes
before it claims anything about self-description again.
