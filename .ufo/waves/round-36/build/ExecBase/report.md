# ExecBase — round 36 BASE measurement (kagi, attempt 2)

## Verdict

**BASE confirmed as frozen.** Both counters print exactly the declared integers
with rc 0 and empty stderr over the committed bytes of
`cb8cb659e84240a8db12e4f7b4a0def5068baf7e`:

- C1 calibration `bash plans/round-36-c1.sh` → stdout exactly `4`, rc 0 (BASE 4)
- C2 freshness `bash plans/round-36-c2.sh` → stdout exactly `15`, rc 0 (BASE 15)

No value differs from 4/15; nothing was adjusted, edited or re-run to fit.

## Provenance

- Extraction: `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive
  cb8cb659e84240a8db12e4f7b4a0def5068baf7e | tar -x -C <scratch>/base`
- Committed-tree proof: `git -C .../kagi-shokunin rev-parse cb8cb65` →
  `cb8cb659e84240a8db12e4f7b4a0def5068baf7e` (full sha resolves).
- Committed live receipt inside the extraction
  `.ufo/waves/round-36/controls/observe-live.json` sha256 =
  `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727` — equals
  the frozen pin (`receipts/receipt-sha256.txt`).

## Measurements (verbatim bytes in `receipts/`, summary row per measurement in `base.tsv`)

| id | command | stdout | stderr | rc |
|---|---|---|---|---|
| c1 | `bash plans/round-36-c1.sh` | `4` | empty | 0 |
| c2 | `bash plans/round-36-c2.sh` | `15` | empty | 0 |
| sweep | `bash corpus/self-description-sweep.sh` | 7 lines, see below | empty | 1 |
| selfcounts | `python3 corpus/self-counts.py` | 64 lines, see below | empty | 2 |

(c) sweep — last line verbatim:
`SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)`

Every `MISMATCH SD5` line (all three):
- `MISMATCH SD5 SCORECARD.md:14 red id 'R25-02' is absent from the latest calibration row (SCORECARD.md:1374)`
- `MISMATCH SD5 SCORECARD.md:14 red id 'R29-01' is absent from the latest calibration row (SCORECARD.md:1374)`
- `MISMATCH SD5 SCORECARD.md:14 red id 'R29-02' is absent from the latest calibration row (SCORECARD.md:1374)`

(d) selfcounts — `SELF_COUNTS: POLICY (claims=63 stale=1 unlocated=0 ambiguous=0 policy=2 setup=0)`

Stale claim id, from the instrument's own per-claim line:
`STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70`
— i.e. the SCORECARD capability-table row declares the source-census
`--selftest` at **59** cases while the live source counts **70**. Exactly the
round-36 stale population (`R21-03` record). The two POLICY rows at BASE are
`PV-FEEDTOKEN-SHAPES` / `PV-FEEDTOKEN-SELFTEST` (`ledger:R29-02` /
`ledger:R29-01`, "command not allowlisted") — they are excluded from `stale`
and are the R29-01/R29-02 POLICY states the candidate's calibration row names.

## C1 decomposition check

SD5 = 3 (the three red ids above) + stale = 1 (SA-CAP-CENSUS-SELFTEST) = **4**
= c1 stdout. The counter's sum reproduces the frozen population split exactly.

## Instrument sha256 (inside the extraction)

```
206cbcc53c31fad848fa8312ce0a7625a718a8211b2d4d6384021f4a0dbd086d  plans/round-36-c1.sh
ac010f163c03313ef97251c1cce7aacfb7d01f99d65fdad313bbd8e4284c01c6  plans/round-36-c2.sh
77ad6e22e92b64c3610c3464ca6d2e131f3caa906de594f5cdcd5449f76b0bec  corpus/self-counts.tsv
5b600f0a997929cace485fc280bc74be5f0ef6f63711195855db0feaa79a6654  corpus/self-counts.py
45d8e4a2d0bbf152d1f21a7acc073dbe6cc987cb857e2f903df6a7bb6fe640a9  corpus/self-description-sweep.sh
```

## Observations / risks (recorded, nothing adjusted)

1. **SD6 tension between plan prose and counter output.** `plans/round-36.md`
   says the SD6 class is "preserved unchanged at **5**" (5 citations inside
   non-author verifier spot-check files) and its kill rule fires when "SD6
   differs from 5 at the landing revision". The BASE sweep prints **SD6=3**
   (three lines: round-30/round-32/round-33 verifier-spotcheck files). If the
   kill rule reads the counter's printed number, an untouched landing (SD6
   still 3) would fire C1. [INFERENCE] The prose "5" may count citations inside
   those 3 files rather than printed mismatch lines — but that reconciliation
   is not in the frozen text. Flag for the L1/critic before landing; BASE bytes
   are recorded here unmodified.
2. **self-counts exits 2 at BASE** (POLICY=2 rows), not 0; c1 still reads
   stale=1 from it. Recorded because QM37-style producer-envelope checks may
   care that the stale reading's producer is rc-2 at BASE.
3. Sweep rc=1 at BASE (fail-closed summary line) — consistent with a MISMATCH
   verdict, recorded for envelope completeness.

## Environment / tooling / dead ends

- No tool installed or upgraded (none needed); pacman untouched per the
  host-wide pause. disk-guard before the heavy pass: `/fast/scratch/hyaku`
  60 % used, 322.2 G free.
- Git strictly read-only with explicit `-C`; no fixture repo needed (no writes
  anywhere except this seat's scratch and the designated build dir).
- Bash tool output surfaced via supervised-process follow-ups rather than
  inline; handled by writing every run's bytes to files under scratch and
  reading them back — outputs below are those captured files, never re-typed.
- Scratch `/fast/scratch/hyaku/kagi-r36/ExecBase/` is removed at yield, after
  copying all receipts into `build/ExecBase/receipts/`.

## Files written by this seat

- `.ufo/waves/round-36/build/ExecBase/base.tsv` — one row per measurement
  (id, command, stdout, stderr, rc, sha256 of the instrument run; multi-line
  cells escaped `\n`/`\\`).
- `.ufo/waves/round-36/build/ExecBase/receipts/` — verbatim
  `c1|c2|sweep|selfcounts .out/.err/.rc`, `HASHES.txt`, `receipt-sha256.txt`.
- `.ufo/waves/round-36/build/ExecBase.md` — the Report trailer (concise copy
  of this verdict).
