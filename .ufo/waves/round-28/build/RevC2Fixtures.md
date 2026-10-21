# RevC2Fixtures — frozen C2 fixture prediction (G1–G4) at BASE

Lane kagi-shokunin, round-28 BUILD, seat `KagiR28.RevC2Fixtures-7`. BASE `3553d499577084a6c98d7078906017840bbf7b28`
archived read-only to `.ufo/waves/round-28/sandboxes/RevC2Fixtures-7/base` (archived `corpus/release-clock.py`
identical to the commit blob). Target: `plans/round-28.md` (frozen), `corpus/release-clock.py` (BASE).
No tool installs (stdlib python3 only).

## Direct answer

**No group is already REGRESSED/INCONSISTENT at BASE.** With the observation receipt forged to match the
lowered observation (round-27 harness precedent) all four groups are **ACCEPTED at BASE**: exit 0,
`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`. So
"ACCEPTED k/4 → 0/4" is **k = 4**; the before-state is not vacuous.

**But** ACCEPTED is conditional on forging the receipt. With the committed receipt untouched (the literal
"release-clocks.tsv edits only") all four groups exit 1 with `RECEIPT-MISMATCH` on exactly their own rows —
not REGRESSED, not INCONSISTENT — so ACCEPTED = 0/4 for a *receipt* reason and the delta measures the wrong
property (F1). The installed `.ufo/waves/round-28/tools/c2-measure.py` (reported by XC2Measure-7, sha
`97fe7ebe…40d4`) does mirror the receipt per group, so it lands in the ACCEPTED-4/4 branch.

| group | feed | rows edited (tsv line) | lower token | BASE, receipt forged | BASE, receipt frozen |
|---|---|---|---|---|---|
| G1 SOPS | S033 | S008–S011 (5-8) | 3.13.2 / 3.0.0 | exit 0 CLEAN30 | exit 1 RECEIPT-MISMATCH ×4 (same ids) |
| G2 Vault | S034 | S013, S022–S024 (10,19-21) | 2.1.0 / 2.0.0 | exit 0 CLEAN30 | exit 1 RECEIPT-MISMATCH ×4 (same ids) |
| G3 OpenBao | S035 | S014–S016, S021, S025, S026 (11-13,18,22-23) | 2.7.0 / 2.0.0 | exit 0 CLEAN30 | exit 1 RECEIPT-MISMATCH ×6 (same ids) |
| G4 curl | S037 | S029 (26) | 8.22.0 / 8.0.0 | exit 0 CLEAN30 | exit 1 RECEIPT-MISMATCH S029 |
| control | — | none | — | exit 0 CLEAN30 | exit 0 CLEAN30 |

## Findings (severity order)

### F1 — HIGH (measurement defect): the fixture is only ACCEPTED if the receipt is forged, and a row-id-only predicate is satisfiable by the wrong finding type

`corpus/release-clock.py:425-455` (`receipt_matches`) compares the receipt's `parsed_version` to the row's
`observed_version` (`:444`), so editing `observed_version` breaks every edited row unless the receipt is
rewritten. Measured with the committed receipt (`.ufo/waves/round-26/observe-2.json`, tracked; sha `13b8540c…`
= `release-clock.py:28`; default path `release-clock.py:497`): G1 → `RECEIPT-MISMATCH S008/S009/S010/S011`,
exit 1, `observed=26`; G2 → S013,S022,S023,S024, exit 1, `observed=26`; G3 → S014,S015,S016,S021,S025,S026,
exit 1, `observed=24`; G4 → S029, exit 1, `observed=29`. Round-27's harness forges the receipt for exactly
this reason (`.ufo/waves/round-27/tools/c2-measure.py:66-70`), and the plan requires it ("lowering every
derived anchor on one feed together with a **matching forged observation**"). Sharper half: those receipt
findings **name exactly the group's row ids**, so a predicate built on the row-id set alone (ignoring finding
type) scores **BASE as EXACT 4/4** and shows no delta. EXACT must count *derivation-typed* findings only
(the installed tool, per XC2Measure-7, excludes BASE's categories and compares id sets — correct).

### F2 — MEDIUM (determinacy): the plan never pins the lowered version; three choices change the BASE outcome

`plans/round-28.md` C2 fixture set says only "lower every derived anchor on that feed to the same lower
canonical version". Measured at BASE (G2/Vault): `2.1` or `2.1.0-rc1` (not strict `X.Y.Z`) → **BASE
`INCONSISTENT S013/S022/S023/S024`**, exit 1 (`release-clock.py:576-580` → `numeric_version(observed) is None`;
`:369-380` demands three numeric components); `2.3.0` (not lower than the feed's other row) → **BASE
`REGRESSED S012`**, exit 1, `observed=29 fired=2` — a false finding on a **non-derived** row, because
`feed_floors` (`:390-411`) takes the feed's max numeric anchor and S012's observed 2.2.0 then sits below it
(`:571-575`); `02.1.0` (leading zero) → BASE CLEAN (C1's debt), but C1's new canonicality rule would flag the
same rows → **cross-axis contamination**. The tool must use a strict `X.Y.Z` token strictly below the group's
anchor and strictly below every other row's observed version on that feed, and C1-canonical; the installed
tool's tokens 3.13.2 / 2.1.9 / 2.7.0 / 8.22.0 satisfy all four conditions (XC2Measure-7).

### F3 — MEDIUM (rule scope): gate on `derived:` and bind to the *feed* registry row, or the control breaks

Measured with two sandbox drafts (my probe, not production): the rule applied to **every** feed row breaks the
control — `DERIVED-ANCHOR-MISMATCH S012`, exit 1, `observed=29 fired=2`. S012 (`corpus/release-clocks.tsv:9`)
is `fired` with non-numeric anchor `v1.21.x` (`numeric_version` → None, `:369-380`), so it must stay outside
the rule; BASE's marker is `values["note"].startswith("derived:")` (`:565`) and `anchor_ok` currently
**exempts** derived rows (`:566`) — that exemption is the C2 hole. Binding to the row's **own** anchor is also
wrong: S008–S011's own anchors name no version (`corpus/SOURCES.md:14-17`), so it fires on the control; the
`feed_source_id` row (`SOURCES.md:39-43`: S033→3.13.3, S034→2.2.0, S035→2.7.1, S037→8.23.0) keeps the control
CLEAN and catches curls — S029's own anchor names `8.23.1` (`SOURCES.md:35`, unreleased dev label) which S037
does not: a fixture anchored at 8.23.1 is CLEAN at BASE and flagged after the fix (measured). All 15 derived
rows currently comply, so the control stays `CLEAN30 … derived=15` after the fix.

### F4 — LOW (predicate decidability): the finding category token is a new observable contract the frozen plan never fixes

`print_result` emits `"<CATEGORY> <row_id>"` (`release-clock.py:644-651`); BASE vocabulary is {ORPHAN, UNBOUND,
INCONSISTENT, BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED} (`:536,:541,:574,:580,:588,:598,:603,:610,
:617`). The plan says "typed derivation findings" without naming a token, so EXACT is not mechanically decidable
from the frozen text; L1 should fix one token (plan-correction line only, no rewrite of frozen text).

### F5 — INFO (the hole is real; confirmations)

`observe_one` sets `parsed_version` from the fetched feed and computes the verdict against the **row's** anchor
(`:788-800`); `run_observe` computes the feed floor from the current table (`:887`). With a derived anchor
lowered to `L`, a live SOPS observation records `3.13.3` / `fired` — the forged receipt (`parsed_version L`,
verdict `not-fired`) is what no live run can produce: the fixture exercises the calibration hole, not a
synthetic artifact. Confirmations: derived inventory matches the plan exactly (15 rows over 4 feeds —
S033×4, S034×4, S035×6, S037×1; module import of BASE `parse_bindings`/`parse_sources`); BASE feed floors
sops→3.13.3, vault→2.2.0, openbao→2.7.1, python→3.15.1, curl→8.23.0 (S012's `v1.21.x` contributes nothing);
`fired=3` (S012, S027, S028) and `derived=15` invariant under all four fixtures; `observed=30` at BASE with a
forged receipt; S012 stays valid under G2 (Vault floor becomes `L < 2.2.0`, its own anchor non-numeric →
`is_regression` False for anchor and floor); S029 is alone on `https://curl.se/info`, so G4's floor is its own
lowered anchor and no other row can regress it; BASE default → exit 0 CLEAN30; `--selftest` → exit 0
`RELEASE_CLOCK_SELFTEST: PASS (79 cases)` (pins `corpus/self-counts.tsv:22,38` → SKILL.md:48, PROVINCE.md:54).

## Commands run (all in my sandbox; lane checkout untouched)

| command | exit |
|---|---|
| `git -C <lane> archive 3553d49… \| tar -x -C …/sandboxes/RevC2Fixtures-7/base` | 0 |
| `diff <(git show 3553d49…:corpus/release-clock.py) base/corpus/release-clock.py` | 0, identical |
| `python3 c2_probe.py base out-receipt-mutated.json 1` (8 fixture runs + control + default) | 0; all runs exit 0 CLEAN30 |
| `python3 c2_probe.py base out-receipt-frozen.json 0` | 0; 8 fixture runs exit 1 RECEIPT-MISMATCH, control exit 0 |
| draft probe: BASE vs derived-gated vs over-broad rule, 4 fixtures + control | 0 (F1/F3) |
| adversarial lowers `2.1`, `2.1.0-rc1`, `2.3.0`, `02.1.0`, `8.23.1` | 0 (F2/F3) |
| `python3 -I -B corpus/release-clock.py` (BASE tree) | 0, CLEAN30 |
| `python3 -I -B corpus/release-clock.py --selftest` (BASE tree) | 0, 79 cases |

Artifacts: `.ufo/waves/round-28/sandboxes/RevC2Fixtures-7/{c2_probe.py, out-receipt-mutated.json, out-receipt-frozen.json, draft/, draft-overbroad/}`. No network; no feed fetched; no `--observe`.

## What I did NOT check

* No live `--observe`, no network fetch, no vault/account/handler/CDP contact; C1's F1–F4 are out of scope and
  their `--observe` behaviour is unverified by me.
* `.ufo/waves/round-28/tools/c2-measure.py` did not exist at BASE; my predictions assume the round-27 harness
  pattern (clone at rev, fixture root, receipt rewritten). I did not read the installed tool myself — the
  receipt-mirroring / category-predicate / token claims in F1–F2 are XC2Measure-7's, cross-checked only against
  my BASE measurements.
* No lane gate run in the lane checkout (`claim-ledger.sh`, `drift-pins.sh`, `self-counts.py`,
  `sources-census.sh`, `scope-gate.sh`); did not read round-28 claim-id pins in `corpus/claim-ledger.tsv`.
* The after-state's finding taxonomy is not mine to fix (my draft is a throwaway sandbox probe); category
  strings, `--selftest` additions and the SC/PV-CLOCK-SELFTEST pin bumps (79 today) are L1's to land. Did not
  audit round-27 `c2-measure.py` beyond the code path exercised, nor any `separability.py` overlay.
