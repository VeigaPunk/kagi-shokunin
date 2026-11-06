# K46MutCounters — mutation test of the two frozen round-46 counters

Seat: `K46MutCounters` (round 46, attempt 1, leaf member — no subagent dispatch).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE
`f5977284a8ce5bab09252be8196ee5dc18489926`, predeclaration
`44808ced56359c98f35995178fb24a6482899263`.
Scratch: `/fast/scratch/hyaku/kagi-r46/K46MutCounters` (`$HYAKU_SCRATCH` default
`/fast/scratch/hyaku`). No candidate exists in the lane tree; every mutation was applied to a
scratch clone only.

## Method

Detector = the frozen pre-freeze controls runner `plans/round-46-controls.py` (11 controls,
each with an independent expected value, `MATCH`/`DIFF` per control, exit 0 iff all match).
A mutant is **KILLED** when the runner reports at least one `DIFF`; **SURVIVED** when all 11
controls still match. This is the frozen kill rule; nothing was reinterpreted.

1. Scratch clone at the predeclaration revision, made only in scratch:
   `git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin $S/clone` then
   `git -C $S/clone checkout -q 44808ced56359c98f35995178fb24a6482899263`
   (`git rev-parse --show-toplevel` → `/fast/scratch/hyaku/kagi-r46/K46MutCounters/clone`;
   `git rev-parse HEAD` → `44808ced56359c98f35995178fb24a6482899263`). No git mutation in the
   lane or the fleet.
2. Baseline (pristine counters): `cd $S/clone && HYAKU_SCRATCH=$S/hs-base python3 -B
   plans/round-46-controls.py` → **rc 0**, last line
   `CONTROLS: MATCH (11 controls, 0 differ)`. The run is byte-identical to the committed
   `.ufo/waves/round-46/controls/controls-prefreeze.txt` (`diff` → no output, `FULL_IDENTICAL`;
   K1-0 0, K1-P 3, K1-F1 0, K1-F2 0, K1-F3 0, K2-0 0, K2-P 29, K2-F1 0, K2-F2 0, K2-F3 28,
   K2-F4 29).
   Baseline is a pass: a baseline failure would have been inconclusive, not a kill.
3. Each mutant: restore the counter from `git show 44808ce:plans/round-46-c<N>.sh`, apply one
   exact-string replacement (anchor count asserted == 1), record the mutated sha256, run the
   controls runner with a per-mutant `HYAKU_SCRATCH`, capture stdout+rc, then restore the
   counter from `git show` again and assert the sha256 equals the pristine one.
   Driver: `$S/drive.py`; results: `$S/results.json`.

Commands and exit codes (all executed):

| step | command | rc | last output line |
|---|---|---|---|
| baseline | `python3 -B plans/round-46-controls.py` (cwd = clone) | 0 | `CONTROLS: MATCH (11 controls, 0 differ)` |
| 17 mutant runs | `python3 -B $S/drive.py` (each run = one controls run) | per-mutant, in `results.json` | `FINAL {...} restored_all=True` |
| receipts manifest | `sha256sum … > SHA256SUMS` | 0 | 21 files hashed |

## Mutant table

Expected row (frozen controls): K1-0 0, K1-P 3, K1-F1 0, K1-F2 0, K1-F3 0, K2-0 0, K2-P 29,
K2-F1 0, K2-F2 0, K2-F3 28, K2-F4 29.

| # | mutant | file | mutation (exact anchor → replacement) | diff (control: expected → observed) | verdict | killed by |
|---|---|---|---|---|---|---|
| 1 | C1-1-equiv-drop | `plans/round-46-c1.sh` | `[ "$epass" = 1 ] \|\| EQUIV=0` → `:` (EQUIV leg dropped) | K1-F1: 0 → 3 (`equiv=1` on a byte-keyed self-test) | **KILLED** | K1-F1 |
| 2 | C1-2-real-drop | `plans/round-46-c1.sh` | `REAL=0; if [ "$rrc" -eq 0 ]; then case … REAL=1 … fi` → `REAL=1` | K1-F3: 0 → 3 (`real=1` on a MISMATCHing tree) | **KILLED** | K1-F3 |
| 3 | C1-3-kill-unconditional | `plans/round-46-c1.sh` | `[ "$mrc" -ne 0 ] && KILLED=$((KILLED + 1))` → unconditional increment | K1-0: 0 → 3; K1-F2: 0 → 3 (`killed=3` with `m1=0 m2=0 m3=0`) | **KILLED** | K1-0, K1-F2 |
| 4 | C1-4-positive-drop | `plans/round-46-c1.sh` | insert `POSITIVE=1` before `EQUIV=1` | none — all 11 controls match | SURVIVED | — |
| 5 | C1-5-kill-on-setup | `plans/round-46-c1.sh` | `[ "$mrc" -ne 0 ]` → `[ "$mrc" -ge 2 ]` (kill keyed on SETUP/crash) | K1-P: 3 → 0 (`killed=0` while `m1=1 m2=1 m3=1`) | **KILLED** | K1-P |
| 6 | C1-6-noop-allowed | `plans/round-46-c1.sh` | delete `if cmp -s "$G" "$m"; then setup "mutant-noop-$1"; fi` | none — all 11 controls match | SURVIVED | — |
| 7 | C1-7-empty-pass | `plans/round-46-c1.sh` | selftest pass = `rc -eq 0` only (drop the `CLAIMS_DECLARED_SELFTEST: PASS` prefix check) | none — all 11 controls match | SURVIVED | — |
| 8 | C2-1-http-drop | `plans/round-46-c2.sh` | drop `r.get("http_status") == 200 and` from FRESH | none — all 11 controls match | SURVIVED | — |
| 9 | C2-2-date-floor-drop | `plans/round-46-c2.sh` | drop `at[:10] >= "2026-11-06" and` from FRESH | none — all 11 controls match | SURVIVED | — |
| 10 | C2-3-kept-drop | `plans/round-46-c2.sh` | `kept = int(all(i in cur for i in base))` → `kept = 1` | none — all 11 controls match (K2-F2: `kept=1` but `default=0 pinned=0` still forces value 0) | SURVIVED | — |
| 11 | C2-4-pinned-drop | `plans/round-46-c2.sh` | insert `PINNED=1` before the KEPT/FRESH parse | none — all 11 controls match | SURVIVED | — |
| 12 | C2-5-pinned-no-sha | `plans/round-46-c2.sh` | `gate --receipt "$RECEIPT" --receipt-sha "$RSHA"` → `gate --receipt "$RECEIPT"` | K2-P: 29 → 0; K2-F3: 28 → 0; K2-F4: 29 → 0 (`fresh=29 default=1 kept=1 pinned=0`) | **KILLED** | K2-P, K2-F3, K2-F4 |
| 13 | C2-6-on29-drop-s098 | `plans/round-46-c2.sh` | ON29 `S031 S032 S098"` → `S031 S032"` | K2-P: 29 → 28; K2-F3: 28 → 27; K2-F4: 29 → 28 | **KILLED** | K2-P, K2-F3, K2-F4 |
| 14 | C2-7-dup-accept | `plans/round-46-c2.sh` | `ok = ok and len(r) == 1` → `len(r) >= 1` | none — all 11 controls match | SURVIVED | — |
| 15 | C2-8-value-gate-drop-default | `plans/round-46-c2.sh` | VALUE gate `[ "$DEFAULT" = 1 ] && [ "$PINNED" = 1 ] && [ "$KEPT" = 1 ]` → drop the DEFAULT conjunct | none — all 11 controls match | SURVIVED | — |
| 16 | C2-9-pinned-always0 | `plans/round-46-c2.sh` | `read -r prc PINNED plast` → `read -r prc _ plast` (PINNED can never be 1) | K2-P: 29 → 0; K2-F3: 28 → 0; K2-F4: 29 → 0 | **KILLED** | K2-P, K2-F3, K2-F4 |
| 17 | C2-10-parser-empty | `plans/round-46-c2.sh` | `[ -n "${KEPT:-}" ] && [ -n "${FRESH:-}" ] \|\| setup parser-empty` → `:` | none — all 11 controls match | SURVIVED | — |

Score: **7 killed / 10 survived of 17** (8 required examples all covered: EQUIV drop #1, KEPT drop
#10, PINNED without sha #12, date floor #9, http_status #8, REAL leg #2, kill-on-SETUP #5,
`missing` parser accepting empty #17).

Per-mutant observed matrix (all 11 controls) is in
`K46MutCounters-receipts/results.json` and `K46MutCounters-receipts/out/<mutant>.txt`.

## Surviving mutants — named gaps

Each survivor is a real behavioural deviation of the frozen counter that the frozen controls
cannot see; none of them is behaviour-equivalent to the pristine counter on all trees. Named
gap = the control fixture that would kill it (not added here: the control set is frozen).

| survivor | deviation | gap: the control that would kill it |
|---|---|---|
| C1-4-positive-drop | an unproven gate (`POSITIVE=0`) still scores `KILLED` | a fixture whose unmutated `--selftest` exits 0 but whose last line is not `CLAIMS_DECLARED_SELFTEST: PASS` (e.g. silent selftest). The frozen header already promises "an empty selftest output fails POSITIVE"; **no control exercises it**. |
| C1-6-noop-allowed | a sed program leaving the gate byte-identical is no longer a SETUP refusal | unreachable through the frozen controls: the seven sed programs are hardcoded in the counter, so no control can present a no-op mutant. Gap in the counter's SETUP surface, not in its value line. |
| C1-7-empty-pass | `rc=0` with any last line counts as PASS | same fixture as C1-4 (rc 0, non-`PASS` last line). |
| C2-1-http-drop | a receipt record with `http_status` 500/absent counts as fresh | a receipt where one ON29 record carries `http_status: 500` (all else fresh, tsv synced) → expected 28. |
| C2-2-date-floor-drop | an `observed_at` older than 2026-11-06 counts as fresh when it equals the tsv date | a receipt with `observed_at` 2026-11-05 synced into `release-clocks.tsv` → expected 0. K2-F1 cannot test it (it ships no receipt at all). |
| C2-3-kept-drop | a deleted BASE registry row no longer fails the counter | a fixture where `DEFAULT=1`, `PINNED=1` and a BASE row is missing (delete a row the gate does not miss) → expected 0. K2-F2 deletes S098, which also breaks `default`/`pinned`, so KEPT is masked there. |
| C2-4-pinned-drop | an absent/unpinned receipt counts as CLEAN | a fixture with `DEFAULT=1`, `KEPT=1`, `FRESH=29` and `PINNED=0` (receipt present but digest mismatch, default receipt path clean) → expected 0. |
| C2-7-dup-accept | two receipt records for one id count as one fresh id | a receipt with a duplicated ON29 record → expected 28. |
| C2-8-value-gate-drop-default | `DEFAULT=0` no longer zeroes the value when `PINNED=1` | a fixture where the default gate FAILS while the pinned gate is CLEAN (`--receipt` given explicitly on a tree whose default receipt is stale), `fresh=29` → expected 0. |
| C2-10-parser-empty | an empty KEPT/FRESH parse is accepted instead of a SETUP refusal | a tree where the embedded parser prints nothing (python3 unavailable to the counter). Not reachable from a fixture tree, so this is a structural gap of the control set. |

## Structural ceilings observed (frozen predicate, not candidate defects)

- **C1 kill rule is `rc != 0`.** A mutant that crashes (bash syntax error, exit 2) is scored as
  killed exactly like a mutant the self-test rejects. Mutant #5 shows the rule is load-bearing in
  the other direction (keying on `rc >= 2` zeroes the value); the converse — a broken mutant
  scored as a kill — is a ceiling of the frozen sentence "whose `--selftest` exits non-zero".
- **The pinned sha is enforced by the gate, not only by the counter.** Mutant #12 shows
  `release-clock.py` refuses `--receipt` without `--receipt-sha` (`pinned=0`), so the counter's
  sha pass-through is observed, not assumed.
- **SETUP paths are unexercised.** No control covers bad revision, missing gate, unusable scratch,
  or the C2 `base-registry` refusal; only the value line is scored.
- **K2-F4 remains the declared ceiling** (hand-written receipt with fake digests scores 29); this
  run confirms it (observed 29, MATCH) and adds no new ceiling of that kind.

## Restoration evidence

| file | pristine sha256 (44808ce) | after all 17 mutants | restored |
|---|---|---|---|
| `plans/round-46-c1.sh` | `e3ec7ea0475eecaeeab4cd5220a695a80fa493231ffb5de9ad9f75834a762ddf` | identical | yes |
| `plans/round-46-c2.sh` | `0572caae1c6ba67fc27ecf9bcab973cca70a914b7ecabd17c08c190f8283e17f` | identical | yes |

`results.json` carries `pre_sha`, `mutant_sha`, `restored_sha` and `restored_ok` per mutant; every
row has `restored_ok: true` and the driver's final line is `restored_all=True`. The lane tree was
never written; only the scratch clone was mutated and restored.

## Receipts

`/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-46/build/K46MutCounters-receipts/`

- `baseline-controls.txt` — pristine controls run (rc 0, `CONTROLS: MATCH (11 controls, 0 differ)`).
- `results.json` — 17 rows: mutation, shas, verdict, killing controls, diff lines.
- `pristine.json`, `drive.py` — pristine shas and the exact driver used.
- `out/<mutant>.txt` — full stdout/stderr/rc of the controls run for each mutant.
- `SHA256SUMS` — manifest over all of the above (21 files).
