# ScribeCapRow — D1 draft: closure disposition review in the main `## Capabilities` table

Seat: scribe (leaf, no dispatch). Lane: `kagi-shokunin`, BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Axes touched by this item: operability, freshness, calibration (the capability row is bookkeeping under the round-24 plan's "Routed debt" D1; it moves no axis score).
Lane contract honored: `SCORECARD.md` is **not edited**; the fix is drafted here for the L1 integrator to land. Only this file was written.
Name collision: `corpus/closure-dispositions.json` has its own routed defect labelled `D1` (round-23 W04 warnings). In this report, `D1` means the round-24 plan's item (`plans/round-24.md:71`): "D1 capability row in the main `## Capabilities` table".

## 1. Finding (defect, verified by reading)

- Main table `SCORECARD.md:682-686` has three rows (op-only dotenv probe, source registry + census, feature-bound credential review). **No closure row.**
- The round-23 row exists only in the round-23 sub-table `SCORECARD.md:846-851` (`### Capabilities`, lowercase headers). That is the round-23 post-move record, not the main table.
- Trailing prose `SCORECARD.md:688` names round 22 as the latest entry: "feature-bound typed credential review first worked in round 22 through R22-01/R22-02. The 2026-10-16 rollout added none." This is stale: round 23 entered a row.
- `AXES.md:57-63` requires a row only after a round demonstrates the capability running. The demonstration exists (section 2), so the row is owed, not pre-claimed.

## 2. Evidence-pointer verification (executed)

Run host-free from the lane root with `PYTHONDONTWRITEBYTECODE=1` (no `__pycache__` written; `corpus/__pycache__` confirmed absent afterwards). Python `3.14.8`. No installs, no network, no `op`, no `$HOME` reads; the selftest writes only under `tempfile.TemporaryDirectory` (`corpus/closure-dispositions.py:276`).

| # | Command | Exit | Output (last line, verbatim) |
|---|---|---|---|
| E1 | `python3 corpus/closure-dispositions.py --selftest` | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` |
| E2 | `python3 corpus/closure-dispositions.py` | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)` |
| E3 | `grep -n 'R23-0' corpus/claim-ledger.tsv` (ran; exit not captured, output shows match) | — | line 60 (`R23-02`): expected regex `^CLOSURE_DISPOSITIONS: CLEAN \(obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15\)$` |
| E4 | `grep -c 'closure-dispositions.py --selftest' corpus/claim-ledger.tsv` | 1 | `0` (no ledger row runs the selftest; see §5) |
| E5 | `ls corpus/closure-dispositions.py corpus/closure-dispositions.json` | 0 | both present (`.py` 18315 B, `.json` 4392 B, 01:25 / 01:18) |

E2 matches the R23-02 expected regex byte-for-byte, so the pointer resolves to a passing row as of this tree.

Quoted last line for the pointer: **`CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)`** (E1, exit 0).

## 3. Draft main-table row (insert after `SCORECARD.md:686`)

```
| closure disposition review | map a non-author closure's obligation list (routed defects, spot-check decisions, adjudication) to exactly one typed disposition each (`fixed`, `reported`, `rejected`, `no-action`, `operator-owned`); a `fixed` pointer must resolve in-tree and contain the obligation id token (comments count); the closure source is digest-pinned. Ceiling: checks record shape, id coverage and pointer presence, not that a fix is correct | `python3 corpus/closure-dispositions.py --selftest` (last line `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)`); ledger `R23-02` (`CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)`); `corpus/closure-dispositions.json` | 23 |
```

Format check against the main table: four columns, no `|` inside any cell, one line per row. Ceiling is in the same cell (the file's own rule, `SCORECARD.md:7-10`). The docstring (`corpus/closure-dispositions.py:1-40`, Bounds paragraph) is the source for the ceiling wording.

## 4. Draft replacement for trailing prose (replace `SCORECARD.md:688`)

```
Rows enter only through demonstrated execution (`AXES.md` §Capabilities): the two round-21 capabilities entered through that round's runs; feature-bound typed credential review first worked in round 22 through R22-01/R22-02; closure disposition review first worked in round 23 through R23-02 and its selftest. The 2026-10-16 rollout added none. The latest first-working round in this table is 23.
```

Why these words: keeps the existing rule and the 2026-10-16 historical claim verbatim, adds round 23 with the two pointers the row uses, and states the latest round explicitly so a reader does not have to infer it from the rows.

## 5. Bounds carried by the row (from other seats' filed reports; not re-run by me)

- **Selftest count is unpinned.** No ledger row runs `--selftest` (E4 = 0). The "14 cases" in the row is a count-only claim until the round-24 plan's D3 lands (`plans/round-24.md:72-74`: "D3 ledger row for the closure selftest"). The row's command is runnable and E1 proves the current count; it does not prove the count is stable.
- **Arguments are not guarded.** `corpus/claim-ledger.sh:235` allows `python3 corpus/closure-dispositions.py` followed by any arguments (`([[:space:]]|$)`), and the script accepts absolute `--source`/`--dispositions` paths (`closure-dispositions.py:148`, `:151` per CritNoHarm, not re-measured here). The row claims nothing about arguments; do not extend it to imply argument safety. Source: `.ufo/waves/round-23/falsify/CritNoHarm.md` E5 (reported there as a counterexample).
- **Pointer existence is not fix quality.** Falsify seats showed a count-preserving rewrite of an obligation (M8) yields CLEAN, and `fixed` can be satisfied with its fix artifacts deleted (CritNoHarm E2, F8). Sources: `.ufo/waves/round-23/falsify/ConnCellsPatterns.md` (M8), `CritNoHarm.md` (E2/F8). The ceiling sentence in §3 covers this; do not drop it when landing.
- **First-working round is conditional on round 23's admission.** The demonstration ran (E1/E2) and the gate is green, but round 23 is under parent-held non-author closure (`LOG.md` round-23 block: "Independent non-author closure owns admission"). The row is entered on the demonstration, as `AXES.md` requires. If the parent rejects round 23, the row and §4's sentence must be withdrawn with it. This is an integrator/operator decision, not a scribe call.

## 6. Adjacent stale text (outside the D1 scope; flagged, optional)

`SCORECARD.md:690-692` (`## Saturation`) still reads: "Declared round 21 … two entered in round 21, so the earliest round it can fire is round 25 (after rounds 22–24 with none)." Round 22 and round 23 each entered a row, and `SCORECARD.md:855-858` says the nudge was not applied in round 23. Applying the file's own rule (stagnation window N=3, last entry round 23) gives earliest round **27** (after rounds 24–26 with none). Proposed replacement, if the integrator takes it:

```
## Saturation

Declared round 23: saturation line 9, stagnation window N = 3 completed rounds. The last capability entered in round 23 (closure disposition review), so the nudge can fire only if rounds 24–26 add none; the earliest round it can fire is round 27. Earlier entries: round 21 (two), round 22 (one).
```

I did not verify the round-24 outcome; this text is conditional on round 24 adding no row, which is exactly what the window tests.

## 7. Landing instructions for the integrator (SCORECARD is not mine to edit)

1. Insert the §3 row after `SCORECARD.md:686` (fresh tag needed; file tag observed as `B378` at read time).
2. Replace `SCORECARD.md:688` with the §4 text.
3. Optional: replace `SCORECARD.md:690-692` with the §6 text, only if the integrator accepts the round-27 computation.
4. Re-run in the integrator's scratch clone (not the real tree, per lane contract): `python3 corpus/closure-dispositions.py --selftest` (expect last line of §2 E1) and `python3 corpus/closure-dispositions.py` (expect the E2 line). Do not run `claim-ledger.sh verify` or `cells` against the real host.
5. Do not treat this file as a capability demonstration for round 24; it is only the round-23 pointer check.

## 8. Installs / tool changes

None. Python `3.14.8` was already on the host; no `uv`, `pacman` or other install was run.

## 9. Not examined

- `claim-ledger.sh citations` / `cells` over the edited SCORECARD (lane-bound; not run).
- The full falsify reports were used only for the bounds in §5 (grep excerpts); their verdicts were not re-derived.
- `.ufo/waves/round-24/build/` contains `ScribeCapRow.md`, `ScribeCorrections.md` and `swarm-registry.json` (listed, not inspected). `tools/` sits at `.ufo/waves/round-24/tools`, not under `build/`; this line supersedes the earlier claim.
