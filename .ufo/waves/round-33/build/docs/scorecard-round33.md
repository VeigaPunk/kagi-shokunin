# SCORECARD.md — round-33 sections, capability row and R32-4 repair (draft; the L1 installs)

## Round 33 — pre-move (repo HEAD 76f4eea, round-32 close)

Frozen BASE `76f4eeae7aa9af4dbb9423f5632b55791824253a`; plan and frozen claims `880824b1d3da5f70b2fe489a34fe866a47314672`, committed alone before any round-33 data (`plans/round-33.md`). All six axes stood at 9 at the round-32 close; this table is the reference line the round's two claims are measured against, and no value in it is a round-33 measurement.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock extraction contract and the feed-token agreement invariant, and the refusal bounds (masking of ref-resolved values, item-level reads, the absent handler). Row `R29-01`. | round 29 |
| coverage | 9 | 72 registry rows with the census green at BASE (`entries_sourced=10 legacy=21 captures=72`, the `R21-02` BASE expected line, row `R21-02`); the NIST key-management lead is unopened ground (`corpus/README.md` §Frontier since round 21). The round-33 plan declares `captures=101` here, which the BASE counter cannot print (corrected in the round lesson as M33-3). | round 32 |
| operability | 9 | Nine gate mode-sets with verdicts and selftests; `bash corpus/eol-sweep.sh` green at BASE (row `R30-01`); `corpus/self-description-sweep.sh` at BASE reads `n=2` with both SD6 lines integrator-owned; nothing schedules any gate. | round 32 |
| freshness | 9 | Every declared entry's re-verification link is gate-checked (`docs` mode inside `verify`, row `R14-01`); §11 of `op-ref-consumption.md` names op 2.41.1 (round-32 C2); the 21 legacy entries remain the named gap (`corpus/README.md` §Known gaps). | round 32 |
| calibration | 9 | Kept at 9 with the reason stated: the cell audit completes to `CELL_AUDIT: POLICY` with one FAIL and two POLICY rows, all operator-owned (`R25-02` FAIL; `R29-01`/`R29-02` policy-blocked). Round 32 closed with C1 not admitted (frozen `n=0` unmet at `n=1`; SD6 residual integrator-owned); `R32-2` leaves the mistakes-row shape open at this line and QM34 is owed. | round 32 |
| adjacency | 9 | Ownership partition gate green (row `R17-02`); OIDC, secret-scanning and workload-identity ground unclaimed by siblings (round-31 sweep over 20 lanes, 0 hits). | round 31 |

## Round 33 — post-move (claims C1 capability, C2 coverage)

Measured commands and receipts: `.ufo/waves/round-33/build/` (gate runs, census mirror, landed-tree gates, mutation report) and `.ufo/waves/round-33/final/` (the two red witnesses). The frozen predicates and kill rules are `plans/round-33.md` §C1/§C2 and are not amended after data. Scores stay 9 → 9: a claim move adds no new score, so the rows record what moved, what is measured, and which reds remain. This section lands only after the `PROVINCE.md`/`corpus/README.md` edits in `build/docs/` are applied (the coverage row names them as landed).

C1's four frozen readings are met at the landing tree: `PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0 on `plans/round-33.controls.tsv`, the round-32 replay `PREFREEZE: MISMATCH (controls=2 mismatch=2)` exit 1, `--selftest` `PREFREEZE_SELFTEST: PASS (11 cases)` exit 0, and the capabilities-table count 1 once this section lands. The red-witness receipt is bound to the pre-hardening gate bytes (`c265a5d8…`); the final bytes (`b634a8d1…`) re-verify CLEAN and the eleven-case selftest, and M33-4's hardening changed only the selftest — a disclosed residual, not a clean binding. C2's fourth reading is not met: `captures=111` is unreachable because the census counts registry ids carrying a capture (72 at BASE, 82 at the tip), so under the frozen kill rule **C2 is not admitted** and the round reports a partial coverage move.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | C1: the pre-freeze control gate enters as a capability. It extracts a frozen revision with `git archive`, runs every declared counting command in that extraction and compares the last integer with the frozen `expect`; the round-32 declared values replay as the red witness (SD5 3 vs measured 1; total 10 vs measured 8 → `MISMATCH 2/2`), and the class gains QM34. The round's own plan supplies a second red witness (M33-3: `captures` declared 101, measured 72 — the gate fires on it); MutGate's M7 escape (a selftest that could not witness `--base`) is recorded as M33-4 and fixed by an eleventh base-isolation case (`PASS (11 cases)`). The three operator reds (`R25-02` FAIL, `R29-01`/`R29-02` POLICY) are unchanged. | Claim C1; `.ufo/waves/round-33/build/prefreeze-33.txt`, `prefreeze-32.txt`, `prefreeze-selftest.txt`; `.ufo/waves/round-33/final/c1-red-witness.txt`, `c1-captures-red.txt`; `corpus/knowledge/prefreeze-controls.md`; row `R33-01` |
| coverage | 9 → 9 | C2 partial: the NIST key-management theme's artifacts landed — two entries, ten registry rows S073–S082 renumbered by document, ten capture rows, and the discharged Frontier bullet removed from both files — but the frozen fourth reading `captures=111` cannot be produced and the plan's named census command prints no `captures=` field, so the claim is **not admitted** under the kill rule. Measured census: `rows=82 entries_sourced=12 legacy=22 captures=82`, exit 0. | Claim C2; `.ufo/waves/round-33/build/assimilation/validate/landed-tree-gates.txt`; `.ufo/waves/round-33/final/c1-captures-red.txt`; `corpus/lessons/round-33.md` §Mistakes M33-3 |
| depth | 9 → 9 | Two entries on newly held ground: publication-status and currency signals, and the Part 2/Part 3 withdrawal-and-successor contract. No new mechanism claim on a held host surface. | `corpus/knowledge/nist-key-management-guidance-status.md`, `corpus/knowledge/nist-key-management-parts-withdrawal.md` (stamped) |
| operability | 9 → 9 | One new gate mode-set with the `CLEAN`/`MISMATCH`/`NORESULT` verdicts and an eleven-case selftest (the eleventh is the base-isolation case M33-4 added after a mutation escape); no scheduler added. | `corpus/prefreeze-control.sh` (stamped); `.ufo/waves/round-33/final/c1-final.txt`; row `R33-01` |
| freshness | 9 → 9 | Ten sources re-opened 2026-11-04 with located quotes; the two legacy PDFs' capture sha256 equals the staged campaign pin (their rows are `raw-literal-v1` + `-`, because the declared normalizer refuses PDF bytes, so no normalized digest is claimed); the two entries carry `verified-at`/`recheck` and enter the census/docs checks. | `corpus/source-fetches.tsv`; `.ufo/waves/round-33/build/nist-captures.tsv`; `corpus/knowledge/nist-key-management-*.md` |
| adjacency | 9 → 9 | Connector sweep over all 20 sibling lanes: 0 hold any NIST key-management source ground, so C2's source ground is sole; one capability-class neighbor is reported for C1 — kasegi's `corpus/instruments/freeze-check.py` states the same replay predicate class — and is neither absorbed nor adjudicated. The ownership partition is unchanged. | `.ufo/waves/round-33/build/ConnOverlap.md` §1, §4; row `R17-02` |

Measured revision, exact exits and receipts are in the round report; no unrun result is stated here. C1 enters only through the demonstrated runs named above; C2 is recorded as a partial move, never as an admitted claim.

## Capabilities table — the row to add

Insert this row as the last data row of `## Capabilities`, immediately after the `differential feed-token agreement gate` row (`| 29 |`) and before the paragraph beginning `Rows enter only through demonstrated execution`.

| Capability | What it can now do | Evidence pointer | First-working round |
|---|---|---|---|
| pre-freeze BASE control execution | extract a named revision with `git archive` into a scratch dir, run each declared counting command there with `BASE`/`LANE` exported, read the last non-empty stdout line's final integer and compare it with the frozen `expect`; a mismatch names the id and both numbers, a command with no integer is `NORESULT`/SETUP (exit 2), and `--selftest` proves the mismatch, `NORESULT`, malformed/missing/empty controls, bad revision and timeout cases | `bash corpus/prefreeze-control.sh run --base <rev> --controls <file>` (claim C1); `--selftest` `PASS (11 cases)` (row `R33-01`; the eleventh is the base-isolation case M33-4 added); `PREFREEZE: CLEAN (controls=4 mismatch=0)` on `plans/round-33.controls.tsv` and `MISMATCH 2/2` on `plans/round-32.controls.tsv` (`.ufo/waves/round-33/build/prefreeze-*.txt`); red witnesses `.ufo/waves/round-33/final/c1-red-witness.txt` and `c1-captures-red.txt`; `corpus/knowledge/prefreeze-controls.md` | 33 |

## R32-4 prose repair (same paragraph under the capabilities table, byte-exact)

OLD:

> The latest first-working round in this table is 25 (release-clock observation).

NEW:

> The latest first-working round in this table is 33 (pre-freeze BASE control execution).
