# CritSeparability — C1/C2 causal separability (round 28, BASE 3553d499)

Seat: KagiR28.CritSeparability-7 (critic). Lane-authored advice, not closure. Line refs are at BASE
`3553d499577084a6c98d7078906017840bbf7b28` (`plans/round-28.md` at bdf90f58). Probe drafts are mine and
live only in `.ufo/waves/round-28/sandboxes/CritSeparability/` (`overlay.py`, `fixtures.py`,
`observe_e2e.py`, `runs-base.txt`, `runs-overlays.txt`). They approximate the frozen fixture sets, because
`c1-measure.py` and `c2-measure.py` did not exist yet (`.ufo/waves/round-28/tools/` was empty).

## Findings (highest impact first)

**S1. The receipt layer is a third causal path, and C1's frozen predicate counts it.** Impacted axes: freshness, calibration.
`evaluate` refuses any tsv observation that differs from the pinned receipt (`corpus/release-clock.py:605-615`,
`receipt_matches` :440-446). At BASE, with the default receipt (`runs-base.txt`):
- F1 exits 1 with `RECEIPT-MISMATCH S040`. Under plan:40-41 ("names a typed finding for the fixture's row"), F1 is already **TYPED at BASE**.
- F4, run end to end through `--observe` (`observe_e2e.py`), exits 1 with no traceback and prints `RECEIPT-MISMATCH S040`. So F4 is also **TYPED at BASE**: `observe_one` catches the ValueError at :822.
- On the C1 overlay, F3 and F4 print the same generic `RECEIPT-MISMATCH S040`. That output cannot be told apart from my HTTP-503 stub rows, so it is not evidence of C1.
- G1–G4 each exit 1 with `RECEIPT-MISMATCH` for every group row. That makes **ACCEPTED 0/4 at BASE** (plan:66-67 "k/4").
- The harm plan:49-50 describes ("stays CLEAN") only reproduces with a forged receipt passed through `--receipt/--receipt-sha` (:1712-1713, 1743-1747). With one, G1–G4 at BASE all exit 0 CLEAN30, and F1 exits 0 with `fired=4`.

This is a defect in the frozen fixture and predicate text, so it is reported here and not redefined. Smallest safe correction, inside the latitude the tool author still has:
- Each measure records both receipt modes: the default receipt, and a receipt forged to match the fixture.
- TYPED and EXACT are scored only on the claim's own finding category: a new C1 token category, or the C2 derivation category. Never on `RECEIPT-MISMATCH`, `NOT OBSERVED` or `INCONSISTENT`.
- For the observe path, C1 must surface a distinct category for a non-canonical feed entry. Without it, F3/F4 after-state equals network failure.

**S2. Ordering coupling: C1 verifies alone, but a numeric C2 brings the traceback back in the combined tree.** Impacted axis: freshness.
- Probe C2 "numeric" (`c2n`) compares integer tuples parsed from the feed row's anchor, placed right after `is_derived` (:565).
- Fixture X3: S029 `anchored_version=8.23.` + 4301 zeros, `verdict=fired`, forged receipt.
  - `o_c1`: typed `NONCANONICAL S029`, no traceback.
  - `o_c1c2n`: **`Traceback ... ValueError: Exceeds the limit (4300 digits)`**.
- The frozen F2 fixture mutates S040, which is not a derived row (`corpus/release-clocks.tsv:30`). So the frozen C1 measure cannot see this regression.

Correction:
- C2 must not call `int()` on an unvalidated token. Compare normalized strings (`norm_version`, :362) or the shared helper `version_is_named` (:341-346).
- C1's bound must sit inside `numeric_version` (:369-380). `feed_floors` (:404, :409) and `is_regression` (:383) call it before any row check, and BASE tracebacks there too.
- Add an advisory cross-probe "X3 on the derived row S029" to both overlay runs.

**S3. Comparison mode decides whether C2 overlaps C1 on the 15 derived rows.** Impacted axes: calibration, freshness.
Fixture X1: S008 `anchored=observed=3.13.03`, forged receipt.
- String binding (`c2s`, through `version_is_named`) alone gives `UNDERIVED S008`, so C2 covers C1's defect class on derived anchors.
- Numeric binding (`c2n`) alone gives CLEAN, so C2 accepts a leading-zero derived anchor and depends on C1.
- With both claims under `c2s`, the row gets both `NONCANONICAL` and `UNDERIVED`. That double count is harmless only if it is declared.

The frozen F and G fixtures avoid this overlap: F uses S040, and G uses a canonical lower version. Correction:
- Pick string binding.
- Declare the overlap edge: "on a derived row a non-canonical anchor is reported by both claims; each measure counts only its own category".
- `c2-measure` should assert that the lowered version is canonical. Otherwise X4 (G1 lowered to `3.13.02`) makes C1 findings appear inside a C2 group.

**S4. Undeclared shared edge: the selftest harness's feed source S002, and three existing cases.** Impacted axis: calibration.
- `run_case` builds S002 with anchor `"Latest release"` (:987-989), which names no version.
- Every C2 variant I built fails three EXISTING cases:
  - "derived anchor counted" (:1052-1055)
  - "non-numeric anchor keeps inequality" (:1073-1076): a derived `1.2.x` series anchor can never equal a feed-located X.Y.Z
  - "feed floor lifts non-numeric anchor" (:1084-1091)
- `o_c2s` and `o_c2n` print `RELEASE_CLOCK_SELFTEST: FAIL ... UNDERIVED S001`. `o_c1` passes `(79 cases)`.

So C2 must edit the shared fixture or the expectations of existing cases. That edits shared code, which plan:82-84 does not list. If C1 adds any derived-row case against BASE's S002, the combined tree fails even though each overlay passes alone.

Correction:
- C2 gives S002 a located anchor (e.g. `Entry titled v1.2.0`) or passes `extra_sources`.
- C2 re-expects those three cases explicitly, and decides what happens to derived series anchors. Production has none: S012 `v1.21.x` is not derived (:9).
- C1 writes no derived-row case that depends on S002's anchor.
- Note that the C1 sentence "count grows only by new cases" (plan:43-44) would be false for the combined tree if C2's re-expectations are counted against it.

**S5. Shared helpers are causal edges the plan does not list.**
- `numeric_version` (:369-380) is the natural place for C1's guard. It also feeds REGRESSED and `feed_floors` (round 27) and any numeric C2.
- `version_is_named` (:341-346) is the non-derived anchor check (:566) and the natural C2 binding.
- If C1 changes `version_is_named`, for example to numeric matching, C2's string binding silently weakens.

Declare both helpers as shared edges. Each overlay's diff must show which claim owns each helper hunk, and the other claim must not modify it.

**S6. Bookkeeping must be built separately per overlay, not as one hunk.**
- Selftest count `79` is pinned at:
  - `corpus/claim-ledger.tsv:82` (R25-03)
  - `SKILL.md:48` via `corpus/self-counts.tsv:22` (SC-CLOCK-SELFTEST)
  - `PROVINCE.md:54` via `corpus/self-counts.tsv:38` (PV-CLOCK-SELFTEST)
- Stamps: `corpus/stamps.tsv:77` (release-clock.py hash/lines/bytes).
- Edges that only C1 touches (via its new registry row):
  - `corpus/stamps.tsv:8` (SOURCES.md)
  - `corpus/claim-ledger.tsv:52` (R21-02 `rows=43 ... captures=43`)
  - `corpus/source-fetches.tsv` (16 fields, :149-150)
- C1's registry row must not be `on-release`. Otherwise :509-512 makes `on_release=31`, `UNBOUND`, and the control (plan:42-43, ledger :83) breaks under both measures.

## Overlay matrix required to prove separability (counterfactual, claim-only)

| tree | contents | c1-measure | c2-measure | selftest |
|---|---|---|---|---|
| O0 | BASE | BASE values (S1: mode-dependent) | BASE values | 79 |
| O1 | BASE + C1 code, C1 cases, C1 row + capture + lesson, C1 bookkeeping only | 0/4 MISHANDLED, 4/4 TYPED (own category) | **= O0 exactly** (same findings per group) | 79+a |
| O2 | BASE + C2 code, S002 fixture + 3 re-expected cases, C2 cases, C2 bookkeeping only | **= O0 exactly** | 0/4 ACCEPTED, 4/4 EXACT | 79+b |
| O12 | integrated candidate | = O1 | = O2 | 79+a+b (additivity) |

- Control CLEAN30 must exit 0 in all four trees.
- Run every measure in both receipt modes (S1).
- Advisory cross-probes X1, X3 and X4 go on O1, O2 and O12. Expected: no traceback anywhere, and each claim's category appears only where its own check applies.
- The additivity check (`a`, `b` and `a+b`, with the re-expected case set listed) is the executed proof that the bookkeeping edge is the only shared edge.

**Observed on my probes (forged receipt):**
- c1-like results: identical on O0 and `o_c2s` (F1 CLEAN, F2 traceback). F1 and F2 typed on `o_c1` and `o_c1c2s`.
- c2-like results: G1–G4 CLEAN on `o_c1`, the same as O0. Exactly the group ids appear as `UNDERIVED` on `o_c2s` and `o_c1c2s`.
- So with string binding, the frozen fixture sets do separate. The breaks are S2–S4, which those fixtures do not exercise.

## Commands run (cwd: my sandbox unless noted)
- `git show bdf90f58:plans/round-28.md` (lane, read-only) → 0; `git diff --stat 3553d499 bdf90f58` → 0 (only plan and census differ)
- `git archive 3553d499 | tar -x -C .../CritSeparability/base` → 0
- `python3 -I -B base/corpus/release-clock.py` → 0, CLEAN30 control; `--selftest` → 0, `PASS (79 cases)`
- `python3 -I -B fixtures.py base [--forge-receipt]` → 0 (`runs-base.txt`)
- `overlay.py` ×5 (`o_c1 o_c2s o_c2n o_c1c2s o_c1c2n`) → 0; each overlay's `--selftest`: `o_c1` PASS 79; every C2 overlay FAIL on 3 cases. The script itself exits 1 on failure; my pipe through `tail` hid that exit.
- `fixtures.py <overlay> [--forge-receipt]` ×10 → 0 (`runs-overlays.txt`)
- `observe_e2e.py {base,o_c1} {F3,F4}` → 0. BASE F3 prints `fired=4`; BASE F4 exits 1, no traceback, `RECEIPT-MISMATCH S040`.

Python: 3.14.8 (host). No tools installed or upgraded.

## Not checked
- The real C1/C2 drafts, `c1-measure.py` and `c2-measure.py`: none existed at review time. My `c1`, `c2s` and `c2n` are minimal probes, not proposals.
- Lane gates `claim-ledger.sh`, `self-counts.py`, `sources-census.sh`: not run, per the contract. Pins were read from the tsv only.
- The F3/F4 feed is a synthetic three-item RSS (Python 3.14.9, the fixture title, Python 3.15.1), not a copy of the real python.org feed. Every non-python.org fetch was stubbed to HTTP 503.
- Whether the round-28 registry row is or should be `on-release`: [INFERENCE] from plan:42-43 that it must not be.
- The CPython limit's sensitivity to the environment: `-I` ignores `PYTHONINTMAXSTRDIGITS`, but the default command's interpreter flags were not verified.
- Whether C1's `numeric_version` hardening changes REGRESSED floors when the feed's maximum anchor is non-canonical.
