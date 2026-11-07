# R56Critic — C1 freshness counterattack (round 56, attempt 1)

seat: R56Critic (UFO-FSD critic, freshness axis)
observed model: `amr/deepseek-v4.1-flash` (runtime project context; not inferred from the prompt)
lane: `kagi-shokunin`; **frozen predeclaration epoch B `5d9a1571911ec38a456a40b443e19640abb9a88b`**; BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`; superseded epoch A `42070de7770e1558adcf6aa7a7bc59309a9654d7`
review window: 2026-11-07T07:20–07:55 -03:00, 12-seat pre-freeze wave
constraint compliance: read-only on production; all runs on private scratch copies; no response headers stored, no cookies, public documentation GETs only; no git/jj mutation anywhere.

## Verdict

The mechanism is real and the frozen epoch-B instruments pass their own battery. At the frozen commit `5d9a157` the counter reads `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1`, BASE reads `value=0`, epoch A reads `value=0` (gate digest), the gate is `CLEAN (clocks=10 match=10 …)` with `--selftest PASS (13 cases)`, the controls are `CONTROLS: match=16 mismatch=0` rc 0, drift/deletion/restatement fail closed, and today's live filters give exactly the ten stated counts. The superseded epoch-A counter (`42070de`) was **breakable** — I broke it with a 4,203-byte synthesizing gate (10 with zero captures committed) and a 1,270-byte printer (10 with genuine captures) — and the committed `GATE_SHA256_PIN=2e9dfde3…` closes both (both read 0 at epoch B). **C1 is admissible at `value=10` at `5d9a157`; one landing blocker remains outside the predicate:** `corpus/recheck-captures.tsv` duplicates `corpus/source-fetches.tsv` per-id provenance and **conflicts for S057/S070/S074**, with no gate reading both. Two minor corrections: the manifest's `fetched`/`http_status` are unverified, and the plan's GUARD sentence omits the pinned-gate qualifier that the controls encode. Named ceilings, including the forged-capture ceiling, are correctly disclosed; add volatile-body (S074).

## Instrument epochs

The tree changed under this review; every reading is labelled with the epoch it was taken at. Epoch B is the frozen commit; the transient pre-B counter/controls (`d2bcb790…` / `bb48db96…`) are only cited in F4.

| epoch | ref | counter `plans/round-56-c1.sh` | gate `corpus/recheck-replay.py` | plan `plans/round-56.md` | controls `plans/round-56-controls.sh` |
|---|---|---|---|---|---|
| A | `42070de` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | `d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07` | `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094` |
| B | `5d9a157` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` | `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f` |

`corpus/recheck-captures.tsv` is `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` in both epochs. The committed counter pins `GATE_SHA256_PIN=2e9dfde3…`, which equals `sha256sum corpus/recheck-replay.py` at `5d9a157`; the pin is the behavioural coupling that the kill-rule pathspec (plans only) omits.

## Revision readings (anchored)

- `bash plans/round-56-c1.sh 5d9a1571911ec38a456a40b443e19640abb9a88b` → `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`, rc 0. (`rev-5d9a157.txt`)
- `bash plans/round-56-c1.sh 42070de7770e1558adcf6aa7a7bc59309a9654d7` → `value=0 … (bad=r5-gate:×10)` — epoch A's gate bytes are not the pin, so r5 fails every clock. (`rev-42070de.txt`)
- `bash plans/round-56-c1.sh 832ba6a53d6a76706b5c80bce2278683dea33d42` → `value=0 present=10 … (bad=r2-manifest:×10)`, rc 0. (`rev-base.txt`)
- `bash plans/round-56-c1.sh --tree <lane worktree>` after the post-freeze `source:`/`SOURCES.md` edits → `value=10 …`, rc 0 (r1 unaffected: the cdp entry's `recheck:` line is unchanged). (`worktree-postfreeze.txt`)

## What the claim genuinely establishes (positive controls)

1. **Reference 10 / gate clean / selftest.** Ten `MATCH` lines, last line `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`, rc 0; `--selftest` `PASS (13 cases)`, rc 0. (`ref.txt`, `gate.txt`, `gate-selftest-current.txt`)
2. **Drift is detected.** Change one capture from one matching line to two and update its manifest `bytes`/`sha256` self-consistently: gate `MISMATCH … id=S055 form=grep stated=1 replayed=2`, `RECHECK_REPLAY: DRIFT`, rc 1; counter `value=0 … (bad=r4-replay2:betterleaks…,r5-gate:…)`. (`drift.txt`, `drift-gate.txt`)
3. **Deletion is detected.** Remove `corpus/knowledge/trufflehog-verification-lifecycle.md` → `value=FAIL present=9 replayed=0 guard=0 (bad=…absent:trufflehog-verification-lifecycle.md:verification-caching)`. (`deleted-clock-counter.txt`; controls K1-F1)
4. **Restatement is detected.** Manual `-> 1` → `-> 1x` and `-> 1` → `-> 10` each read `value=FAIL present=9 … absent:betterleaks…`; the right-bound `(?![0-9A-Za-z_.])` works. (`restated-Nx-manual.txt`, `restated-N10-manual.txt`)
5. **Epoch-B controls: 16/16.** `CONTROLS: match=16 mismatch=0`, rc 0, with hashes identical before/after the run (`controls-final.txt`, `hashes-before-controls.txt`, `hashes-after-controls.txt`). Covered: BASE 0, REF 10, clock removed FAIL, restated N FAIL, body tampered 0, row dropped 0, printer gate 0, gate edited 0, gate symlink 0, `-> 1x` FAIL, extra uncaptured clock 0, symlinked body 0, header bytes 0, unsupported form 0, gate byte drift 0, entry symlink FAIL.
6. **Currency on the day (non-author live re-fetch).** All ten stated filters against today's public bodies give the stated N: S054 1, S055 1, S057 1, S067 1, S070 locate 1, S074 1, S078 pdftotext 1, S101 2, S113 3, S114 2. Nine bodies are byte-identical to the committed captures; S074 is volatile (see ceilings). (`live-recheck.txt`)

So: **ten true captured counts do add detection vs BASE** for statement-vs-capture drift, deletion and restatement; they do **not** add live-page freshness (named ceiling).

## Findings

### F1 — CLOSED at epoch B: epoch-A gate substitution and evidence synthesis

The epoch-A counter (`096251c9…`) executed the candidate gate with write access to the same scratch tree it then validated, before reading r1–r4, and r5 compared output only. Two counterexamples, both executed:

- *Synthesizing gate.* A 4,203-byte `corpus/recheck-replay.py` that, under `--root "$T"`, writes `corpus/recheck-captures.tsv` plus ten bodies into `$T` and prints the ten `MATCH` lines and `CLEAN`, from a tree committing **no manifest and no captures** (`.ufo` absent; `find` = 0). `bash plans/round-56-c1.sh --tree synth` (epoch A) → `value=10 present=10 replayed=10 gate=1 guard=1`, rc 0. (`OLD-counter-synth-gate.txt`; source `instruments/synth-gate.py`.)
- *Printer gate.* A 1,270-byte gate hardcoding the ten `MATCH` lines, `CLEAN` and a selftest `PASS`, with genuine captures → `value=10 … guard=1`, rc 0. (`OLD-counter-printer-gate.txt`; source `instruments/printer-gate.py`.)

At epoch B the same trees read `value=0` (`synth-gate.txt`, `printer-gate.txt`): the non-pinned gate is not executed and every r5 fails. The epoch-B controls add printer (F5), gate-edit (F5b), gate-symlink (F5c) and gate-byte-drift (F9) cases. **This is the fix that must stay frozen.**

Residual (design tradeoff, not a hole): the pin freezes the gate bytes with the counter, so a reviewed post-freeze gate fix is a `0`; the plan should say so, or replace the pin with a behavioural differential (run the pinned gate on a scratch copy whose S055 body gains one matching line and whose manifest row is updated; require `MISMATCH`/`DRIFT`). With the pin, the synthesizing-gate class is closed, but adding it to the controls would test the order of operations.

### F2 — LANDING BLOCKER (outside the C1 predicate): duplicate, conflicting capture provenance

`corpus/source-fetches.tsv` already declares one capture digest per registry id (16 columns; `quote-locate.py` reads columns 10/11 as body `sha256`/bytes). The new manifest re-declares the same ids; three conflict:

| id | `recheck-captures.tsv` (fetched, bytes, sha256) | `source-fetches.tsv` (date, bytes, sha256) | |
|---|---|---|---|
| S057 | 2026-11-07, 110710, `221d80fae1227db73c5f65ff71080d72e6e91666856a1dd8e1e2d402dfe9604b` | 2026-11-03, 102006, `0beb84fec97fa0ac2cb2c8c8b1cb0e1616ea7b8485b6848da1771d109c9d44d1` | CONFLICT |
| S070 | 2026-11-07, 268454, `5c226c06413854281f229aa0831f3fa7b9e63cdd3d2a4bf761f2226652a1c0dd` | 2026-11-03, 266770, `a34902cc251b9d9c9573ff25d7bd9a230494689a4cc9a6c99775c1f1e28eca0b` | CONFLICT |
| S074 | 2026-11-07, 45351, `df32e64b9cce734698974dde083feeeaa7d34eef2e6c6391c7694ea7f29c3688` | 2026-11-04, 45351, `389177cee332fad618606d6f3ed8c385a96c04dcd14ccb65648213f4fe54418d` | CONFLICT |

S054/S055/S067/S078/S101/S113/S114 agree. The lane's convention is to update the row on re-capture: the S113/S114 `source-fetches.tsv` rows are dated 2026-11-07 and equal their round-55 captures. `bash corpus/sources-census.sh verify --root <ref>` reads `SOURCES_CENSUS: CLEAN (rows=114 … captures=114 …)` because it never opens bodies, so the conflict is unguarded. Divergence class demonstrated on scratch (new manifest self-consistent with changed bodies, `source-fetches.tsv` unchanged): `bash plans/round-56-c1.sh --tree fq` → `value=10` while `python3 -I -B corpus/quote-locate.py --root fq` → `QUOTE_LOCATE: FAIL located=9 rows=12` (`NOT-LOCATED S101/S113/S114 body-sha256-mismatch`), rc 1. (`provenance-crosscheck.txt`, `quote-locate-forged.txt`, `forged-bodies-conflicting-authority.txt`.)

Smallest safe correction: update the three `source-fetches.tsv` rows (date, sha256, bytes) in the landing commit (S113/S114 precedent), or have the gate/counter require agreement with the id's `source-fetches` row when one exists and name the override in the plan.

### F3 — MINOR: unverified provenance columns

`corpus/recheck-captures.tsv`'s `fetched` and `http_status` are read by neither the gate nor the counter. Rewriting every row to `fetched=1999-01-01`, `http_status=404` still reads `value=10 … guard=1` at epoch B. (`garbage-provenance.txt`.) Fix: require `http_status == 200` (all ten rows are), or declare both columns records. Same class: `body_path` is any repo-relative regular file, not necessarily a capture (committed bytes only); the named ceiling covers it, the manifest header's "capture" wording overstates.

### F4 — MINOR: transient pre-B controls failure, and a plan-wording gap

Before the frozen bytes landed I ran the transient counter `d2bcb790…` with controls `bb48db96…`: `CONTROLS: match=11 mismatch=5`, rc 1 (`epoch-B-controls-11of16.txt`). Four mismatches were the non-pinned-gate GUARD semantics (`F5`, `F5b`, `F5c`, `F9` expect `FAIL`, read `0`); the fifth was F11, whose edit was inert (literal `by default\`` does not occur; the entry has `by default'\``), so the tree stayed reference-like and read 10 with an `AssertionError: inert edit` traceback. The final epoch-B controls fix the expectations to the counter's `0` semantics and use a working `-> 1x` edit; the battery is now 16/16. The counter rejects `-> 1x` (manual `FAIL present=9`), so F11 was a control bug, not a counter hole.

Residual: the frozen plan (`033f2104…`) says `GUARD = 1 iff all 10 clocks are PRESENT … and the gate's --selftest exits 0 with last line PASS (13 cases)`. For a tree that carries a non-pinned gate, the counter never runs the selftest and leaves `GUARD=1` (reading `0`); the controls now encode that. Add the qualifier: only the pinned regular gate's selftest is consulted; an absent or non-pinned gate leaves the conjunct vacuous and all r5 fail. Minor, but it is the frozen sentence.

### F5 — MINOR: controls hygiene

`mk_ref` archives a `git ls-files` list captured before `tar` reads it; wave files deleted mid-run (`build.ready`, `build/swarm-registry.json`, `build-dispatch.json`, `build-spec.json`) produce `tar: … Cannot stat` and `tar: Exiting with failure status due to previous errors` on every control. The run continues (`set -u`, no `-e`) and the files are irrelevant, but the receipt reads as a failure. The inherited epoch-A receipt `.ufo/waves/round-56/controls/controls-prefreeze.txt` binds no instrument sha256; the epoch-B freeze receipt should (this report's receipts do).

## Ceilings confirmed (and one to add)

- **Forged captures score (named).** Ten hand-written bodies totalling 1,097 bytes (nine tiny text files plus a 604-byte generated PDF) with a self-consistent manifest, real pinned gate, read `value=10 … guard=1`. (`forged-bodies-pinned-gate.txt`; `instruments/forge-bodies.py`.) The claim must not be read as "the bytes are true of the live page".
- **Non-discriminating patterns score (named).** Not separately attacked; the ceiling is correctly stated.
- **Live currency is outside the predicate (named).** Confirmed by the re-fetch; do not claim it in the capability row.
- **ADD: volatile bodies.** S074 is a dynamic csrc page: four distinct sha256 for the identical 45,351-byte body — capture `df32e64b…`, live `2b983a39…`, `f3319e79…`, `f525aadd…` — all with `grep -c 'public comment period is CLOSED'` = 1. The digest is a snapshot; a live re-fetch can only confirm the count for this URL. Say so, or the provenance rule will look failed for S074 forever.

## Decision

**Admit C1 at `value=10` at frozen commit `5d9a157`**, conditional on the landing resolving or naming F2; F3 and F4 are minor corrections. Rationale:

- The measured capability is anchored: `5d9a157` reads 10; BASE and epoch A read 0; the gate is the pinned reviewed gate; the controls are 16/16; the failure modes (deletion, restatement, digest, header bytes, symlink, unsupported form, printer, gate edit, gate byte drift, extra clock) all fail closed; the live counts are true on the day.
- The epoch-A holes I found (synthesizing gate, printer) are closed by the pin; they are not absent by accident, they are closed by the committed bytes.
- F2 is a real identity defect but not a C1 score miss: no gate reads both tables, so the score is unaffected; the landing would leave two current answers for S057/S070/S074. Update the rows (S113/S114 precedent) or name the override and cross-check.
- F3 asks the manifest not to claim unverified provenance; F4 asks the frozen GUARD sentence to match the counter's non-pinned-gate semantics; both are cheap.
- Add the volatile-body ceiling (S074).

No C2: the other support-id work was correctly left out.

## Impacted axes

- **freshness** — the claim's axis. Detection is real for statement-vs-capture; no live-freshness inference. F2/F3/S074 bound the provenance claim.
- **calibration / identity** — F1 (gate authenticity, closed by pin), F2 (two provenance tables), F4 (plan vs counter reading on failure paths).
- **operability** — the freeze is coherent at `5d9a157`; the gate is coupled by the pin, not by the kill-rule pathspec.

## Evidence index (lane-relative)

Receipts under `.ufo/waves/round-56/build/R56Critic.d/receipts/`:

- `rev-5d9a157.txt`, `rev-42070de.txt`, `rev-base.txt`, `worktree-postfreeze.txt` — anchored readings.
- `ref.txt`, `base.txt`, `gate.txt`, `gate-selftest-current.txt` — positive baseline.
- `drift.txt`, `drift-gate.txt`, `deleted-clock-counter.txt`, `restated-Nx-manual.txt`, `restated-N10-manual.txt` — fail-closed controls.
- `controls-final.txt`, `hashes-before-controls.txt`, `hashes-after-controls.txt` — epoch-B controls 16/16, hash-bound.
- `OLD-counter-synth-gate.txt`, `OLD-counter-printer-gate.txt` — epoch-A counterexamples; `instruments/synth-gate.py`, `instruments/printer-gate.py`.
- `synth-gate.txt`, `printer-gate.txt` — epoch-B closures.
- `forged-bodies-pinned-gate.txt`, `instruments/forge-bodies.py` — named-ceiling demo.
- `provenance-crosscheck.txt`, `quote-locate-forged.txt`, `forged-bodies-conflicting-authority.txt` — F2.
- `garbage-provenance.txt` — F3.
- `epoch-B-controls-11of16.txt` — F4 transient failure.
- `live-recheck.txt` — all ten live counts and body hashes (S074 volatility).

## Scratch

Scratch `/fast/scratch/hyaku/kagi-r56/R56Critic/`: my trees (`crit/`, `crit2/`, `crit3/`) are removed before yield. Foreign files appeared in my named scratch at 07:30 (`a1`–`a6/`, `min/`, `fake-gate.py`) from another seat; I did not read, use or delete them beyond noting the collision.
