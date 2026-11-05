## Round 37 — pre-move

Frozen BASE `911ab519b6b07694c3cb9f7d9a7c56e142ad957c`; predeclaration `04489d4184edb25a01ec8983b3ccedb45c683564`; frozen plan alone `e2030d2` (`plans/round-37.md`). One claim, C2 freshness; no calibration claim (`corpus/lessons/round-37.md` §Calibration hold). Every axis stood at 9 at the round-36 close; this table is the reference line the claim is measured against, and no value in it is a round-37 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged: release-clock extraction contract and feed-token agreement invariant (rows `R29-01`, `R29-02`). No depth claim this round (`plans/round-37.md`; `corpus/lessons/round-37.md`). | round 29 |
| coverage | 9 | Unchanged as a score: 88 registry rows and 88 captures at BASE, lane census `SOURCES_CENSUS: CLEAN (rows=88 …)` (`corpus/lessons/round-37.md` §Census; `plans/round-37.md` §Frontier step). | round 35 |
| operability | 9 | Unchanged: nine gate mode-sets, nothing schedules any gate; the new counter is on-demand (`plans/round-37.md` §Capability; `corpus/lessons/round-37.md`). | round 35 |
| freshness | 9 | Unchanged as a score. Measured BASE gap: `bash plans/round-37-c2.sh` reads 3 at `04489d4` and `e2030d2` (`plans/round-37.md` §C2; `corpus/lessons/round-37.md` §Before → after). | round 36 |
| calibration | 9 | Unchanged as a score. `bash plans/round-36-c1.sh` reads 0 at HEAD, so no calibration claim is admitted this round (`plans/round-37.md` §Why one claim; `corpus/lessons/round-37.md` §Calibration hold). | round 36 |
| adjacency | 9 | Unchanged: ownership partition gate (row `R17-02`); no adjacency claim this round (`plans/round-37.md`). | round 35 |

Last-change column: freshness and calibration read round 36 because the round-36 post-move table records a measured move on each (`R36-02`/`R36-03`; `R36-01`/`R21-03`). The other four carry their round-36 pre-move values because the round-36 post-move table records no change for them.

## Round 37 — post-move (claim C2 freshness)

Measured commands and receipts: `.ufo/waves/round-37/controls/` and `corpus/lessons/round-37.md` §Before → after. The frozen predicate and kill rules are `plans/round-37.md` §C2 and are not amended after data. Scores stay 9 → 9: a claim move adds no new score, so the rows record what moved and which reds remain.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| freshness | 9 → 9 | C2 `bash plans/round-37-c2.sh` 3 → 0. Vault S034 (`v2.2.0`), openbao S035 (`v2.7.1`) and python S039 (`Python 3.15.1`) are superseded by rows S089, S090 and S091, each naming its feed URL and the receipt version (`2.2.1`, `2.7.2`, `3.15.2`). No mutable cell of S034, S035 or S039 changed; the supersession sits in each new row's `teaches`. Commits: predeclaration `04489d4`, plan `e2030d2`, candidate `9efcea7`. | Rows `S089`, `S090`, `S091` (`corpus/SOURCES.md`); captures `corpus/source-fetches.tsv`; receipt `.ufo/waves/round-37/controls/observe-r37.json` (sha256 `cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203`); controls `.ufo/waves/round-37/controls/` (`prefreeze-gate.txt`: `PREFREEZE: CLEAN (controls=6 mismatch=0)`) |
| calibration | 9 → 9 | No calibration move. Two round-36 errata are routed in the round-37 lesson and not counted: `R36-1` (the `M36-4` pointer does not exist; the discarded edit is row `M36-3`) and `R36-2` (the round-36 report says "five" W04 lines; the live count is 16). | `corpus/lessons/round-37.md` §Corrigenda, §Calibration hold |
| operability | 9 → 9 | The release-feed anchor counter is added as a capability, with six executed controls and a setup refusal (exit 2) for a missing or sha-mismatched receipt. Nothing schedules it. | `plans/round-37-c2.sh`; `plans/round-37-controls.sh`; `plans/round-37.controls.tsv`; `.ufo/waves/round-37/controls/c2-controls.txt` |
| depth | 9 → 9 | No mechanism change. | `plans/round-37.md` |
| coverage | 9 → 9 | Registry rows 88 → 91 and captures 88 → 91: three supersession rows, no new entry, no frontier-to-core move. Fleet duplicate-URL warnings W04 16 → 19 (the three new cross-scope duplicates; no E-finding). | `corpus/lessons/round-37.md` §Census |
| adjacency | 9 → 9 | No change. | `plans/round-37.md` |

Capability row for the main `## Capabilities` table (first working round 37; the table's prose sentence that reads "The latest first-working round in this table is 33" becomes "37"):

| release-feed anchor currency counter | counts release-feed surfaces with no registry row naming the feed URL and receipt version | plans/round-37-c2.sh; plans/round-37.controls.tsv | 37 |

