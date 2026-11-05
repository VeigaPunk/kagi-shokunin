# ExecBase — kagi round 36 BASE (attempt 2)

**Verdict: BASE CONFIRMED, no adjustment.** Measured over a `git archive`
extraction of `cb8cb659e84240a8db12e4f7b4a0def5068baf7e`; extraction proven
committed (`git rev-parse cb8cb65` → full sha).

| measurement | command | stdout | stderr | rc |
|---|---|---|---|---|
| C1 calibration | `bash plans/round-36-c1.sh` | `4` (expect 4) | empty | 0 |
| C2 freshness | `bash plans/round-36-c2.sh` | `15` (expect 15) | empty | 0 |
| sweep | `bash corpus/self-description-sweep.sh` | `SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)` | empty | 1 |
| self-counts | `python3 corpus/self-counts.py` | `SELF_COUNTS: POLICY (claims=63 stale=1 unlocated=0 ambiguous=0 policy=2 setup=0)` | empty | 2 |

- SD5 = 3: red ids `R25-02`, `R29-01`, `R29-02` absent from the latest
  calibration row (`SCORECARD.md:1374`); stale = 1:
  `SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70`. 3+1 = 4 = c1.
- Instrument sha256 (in extraction): c1.sh `206cbcc5…d086d`,
  c2.sh `ac010f16…01c6`, self-counts.tsv `77ad6e22…0bec`,
  self-counts.py `5b600f0a…6654`, sweep.sh `45d8e4a2…40a9` (full hashes in
  `build/ExecBase/report.md`).
- Committed receipt `.ufo/waves/round-36/controls/observe-live.json` inside the
  extraction: sha256 `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`
  = frozen pin.

**Risks flagged (measured bytes only, nothing edited):**
1. Plan prose says SD6 "preserved unchanged at **5**" and its kill rule fires
   when "SD6 differs from 5 at the landing revision", but the BASE sweep prints
   **SD6=3** (3 spot-check files). Literal reading of the kill rule would fire
   C1 on an untouched landing; L1/critic should reconcile citations-vs-lines
   before landing.
2. `self-counts.py` is rc 2 at BASE (two POLICY rows `PV-FEEDTOKEN-SHAPES`/
   `PV-FEEDTOKEN-SELFTEST`, ledger R29-01/R29-02) — the stale-1 producer is
   not rc 0; relevant to QM37-style envelope checks.

Files: `build/ExecBase/base.tsv` (one row per measurement, sha256 per row),
`build/ExecBase/receipts/` (verbatim out/err/rc + hashes),
`build/ExecBase/report.md` (full report). Scratch
`/fast/scratch/hyaku/kagi-r36/ExecBase/` removed at yield. No tools installed;
git read-only throughout; no lane production file touched.
