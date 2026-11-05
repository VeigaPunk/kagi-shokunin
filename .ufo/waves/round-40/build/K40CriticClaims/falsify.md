# K40CriticClaims — falsify receipts (round 40)

Scope: the frozen round-40 counters C1 (calibration 6→0), C2 (freshness 0→3), C3 (operability 0→2)
at candidate `cb3f642479a09644a03874909bb7e44b52697a8d`, BASE `6cc8850dfc5757927699e5a53a876f47c8df21aa`,
predeclaration `f687504767ce9ed56b848dfde83e03a1ec6cedd3`, frozen plan `38a118f9cf15729e7732cc3cafe1011e3a899ee4`.

Method: `git archive` of the three commits into a scratch tree (read-only on the lane; no fixture repo,
no git mutation, no commit, no push). Every counter, control and forgery ran inside a scratch copy
(`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40CriticClaims/`), removed on finish. Lane tracked
status unchanged by this seat (`git status --porcelain` shows only untracked wave files; no tracked
modifications). Tool installs: none.

Scratch tree name used below: `$S` = that directory. Exit codes as printed.

## 1. Reproduction of the declared readings

| Command (tree) | Result | rc | Notes |
|---|---|---|---|
| `bash plans/round-40-c1.sh` (cand) | `0` | 0 | ~340 s; wall-clock logged by the runner |
| `bash plans/round-40-c1.sh` (predec, do-nothing with round-40 counter) | `6` | 0 | ~335 s |
| `bash plans/round-40-c2.sh` (cand) | `3` | 0 | |
| `bash plans/round-40-c2.sh` (predec) | `1` | 0 | positive pin only |
| `bash plans/round-40-c3.sh` (cand) | `2` | 0 | |
| `bash plans/round-40-c3.sh` (predec counter on cand tree, i.e. the pre-M40-3 bytes) | `0` | 0 | reproduces the doubled-token bug |
| `bash plans/round-40-c3.sh` (predec) | `0` | 0 | |
| `bash plans/round-40-c3.sh` (base) | not runnable | 127 | BASE has no counter file; `c3-base.txt` was measured with the predec counter injected |
| `corpus/anchor-pins.sh --selftest` (base) | `ANCHOR_PINS: CLEAN (pins=3)` | 0 | base ignores the flag: no selftest mode exists |
| `corpus/claims-declared.sh --selftest` (base) | `CLAIMS_DECLARED: CLEAN (claims=2)` | 0 | same |
| base SKILL.md gate-registry rows naming either gate | `0` | — | |
| `corpus/anchor-pins.sh --root .` (cand) | `ANCHOR_PINS: CLEAN (pins=4)` | 0 | |
| `corpus/anchor-pins.sh --selftest` (cand) | `ANCHOR_PINS_SELFTEST: PASS (8 cases)` | 0 | |
| `corpus/claims-declared.sh --root .` (cand) | `CLAIMS_DECLARED: CLEAN (claims=5)` | 0 | |
| `corpus/claims-declared.sh --selftest` (cand) | `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` | 0 | |
| `corpus/sources-census.sh` (cand) | `SOURCES_CENSUS: CLEAN (rows=96 A=92 ... captures=96 ...)` | 0 | |
| `corpus/row-identity.sh scorecard-rounds` (cand) | `ROW_IDENTITY: scorecard-rounds count=54 sha256=52e7ba8d…fe50c7` | 0 | matches R24-06 expect |
| `grep -c '^## Round ' SCORECARD.md` (cand / base) | `54` / `52` | — | matches R13-01 migration; base 52 matches plan |

Pre-freeze controls at predec (all re-run here, `BASE=$S/predec bash $S/predec/plans/round-40-controls.sh <mode>`):

| mode | measured | expected |
|---|---|---|
| c1_nowork (receipt run in `prefreeze-gate.txt`, plus 335 s predec run above) | 6 | 6 |
| c1_mutant_const | 0 | 0 |
| c2_nowork | 0 | 0 |
| c2_positive_pin | 1 | 1 |
| c2_forge_rows | 1 | 1 |
| c3_nowork | 0 | 0 |
| c3_selftest_anchor | 8 | 8 |
| c3_selftest_claims | 8 | 8 |
| c3_forge_missing_gate | 0 | 0 |

All nine match. Controls reproduce; see §3 for what they do not test.

Live source check (2026-11-05, this seat): `curl -fsSL https://docs.python.org/3/library/re.html` →
sha256 `ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1`, title `… Python 3.15.2 documentation`;
`…/library/html.html` → sha256 `570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5`.
Both equal the committed S095/S096 capture shas today. The served-3.15.2 claim is true at check time.

Located-quote offsets (python bytes.find on committed bodies): S095 quote at 75897 (matches claim),
S096 quote at 13521 (matches claim). Whitespace token counts (`str.split`): S095 quote = **7** (the
round-40 lesson says 8); S096 quote = 11 (lesson says 11); round-39 S094 quote = 8 (round-39 lesson says 9).

Migration journal: for all six ids, the BASE ledger `expect` equals the journal `old_expect`,
the candidate ledger `expect` equals `new_expect`, and the `command` cell matches. Journal accurate.

Fleet census (`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`,
run read-only as `validate`, write behaviour not audited) at the current lane tree: 19 `W04` lines,
identical to `start-fleet.txt`; **no** `W04` line names S095 or S096; result `ok`.

## 2. Forgery and discrimination tests

### F-C1-a: loosened expects, no journal → C1 reaches target
Tree `$S/forge-c1` = predec tree (its ledger equals BASE) with the six `expect` cells of
R13-01, R21-02, R24-06, R31-02, R33-02, R34-03 replaced by `^.*$`. No journal entry, no migration file.
`bash corpus/claim-ledger.sh verify` → `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`; the six ids produce no FAIL/STALE/MISSING line;
counter count = **0** (`verify-forge-c1-loosened-expects.txt`). Nothing in the committed tree reads `expectation-migrations.json`
(grep: only ledger notes, lessons, and the plan mention it), so the kill rule "expect moved without matching old→new record → C1 unmet" is reviewer-enforced only.

### F-C1-b: C1 reads C2 artifacts → C1 is not separable
Tree `$S/noc2` = cand with the S095/S096 registry rows and their `source-fetches.tsv` rows removed (C2 items 2–3 absent).
Verify counter = **4** (R21-02, R31-02, R33-02, R34-03 each `verdict-not-final exit=0`; `verify-noc2-cand-minus-C2-rows.txt`).
These four rows encode `rows=96 … captures=96`, which exists only because C2 appended two registry rows.
Plan claim "C1 verifies without C2 or C3 having landed" and "No counter reads another claim's artifact" are falsified at this level.

### F-C2-a: authored capture bodies → C2 reaches target
Tree `$S/forge-c2` = predec tree + the candidate's S095/S096 registry rows verbatim + the candidate's S095/S096
`source-fetches.tsv` rows with column 10 rewritten to the sha256 of **fabricated** bodies
(`capture/S095.body` 248 B, sha `7e65057aa0cbb1b2724bf1d54ac0b396c166a1a0c602159dc4866a699027fc1f`;
`capture/S096.body` 259 B, sha `11b351f98933fe6c67918181b6377c2e6788536543bd080071e4d786fd19b715`).
Bodies contain the verbatim quotes and a 3.15.2 title; no network used.
`bash plans/round-40-c2.sh` → **3** (rc 0). Item 1 (predec S036 pin) + item 2 + item 3.
The counter binds row to body only by sha equality and locates the quote in the body; it has no provenance check
(no fetch receipt, no URL/HTTP/date binding, no signature). Control `c2_forge_rows` (no body) → 1 is the only forgery control.
SCORECARD sentence "Forgeries cannot count (control c2_forge_rows → 1)" is therefore overstated.

### F-C2-b: C2 item 1 reads the C3 instrument
Tree `$S/cand-anchorstub` = cand with `corpus/anchor-pins.sh` replaced by a one-line DRIFT stub.
`bash plans/round-40-c2.sh` → **2** (item 1 lost). `bash plans/round-40-c3.sh` → 1 in the same tree.
C2 therefore reads a C3-owned artifact (the gate bytes that the M40 amendments changed). Plan line
"C2 reads only pins/registry/captures" is false.
Cross-check: `$S/noc2` (C2 rows removed) → `bash plans/round-40-c3.sh` = **2**, so C3 does not read C2 rows.

### F-C2-c: pin-only sensitivity
cand with S036 row removed from `corpus/anchor-pins.tsv`: C2 = **2** (items 2–3 still satisfied). Items 2–3 are independent of item 1.

### F-C3-a: stub selftests + forged registry rows → C3 reaches target
Tree `$S/forge-c3` = base tree + the round-40 counter file (candidate bytes) + two SKILL.md gate-registry rows
naming `corpus/anchor-pins.sh` and `corpus/claims-declared.sh` + a first-line `--selftest` stub in each gate
that prints `…_SELFTEST: PASS (8 cases)` and exits 0 without running any case.
`bash plans/round-40-c3.sh` → **2** (rc 0). The counter reads only the last output line and the exit code.
The battery's `c3_selftest_*` controls also only grep the verdict text, so they cannot distinguish a stub from the real selftest.

### F-C3-b: constant-0 counter vs the C3 battery
`$S/c3const` = predec tree with `plans/round-40-c3.sh` = `echo 0`. Controls: c3_nowork → 0 (passes),
c3_forge_missing_gate → **1** (caught, since the stub exits 0). So a constant equal to the target is caught; a
constant equal to the no-work value is not (see F-C1-c).

### F-C1-c: constant-6 counter vs the C1 battery
`$S/c1const6` = predec tree with `plans/round-40-c1.sh` = `echo 6`. Control c1_nowork → 6 (passes the battery).
Landing reading → 6 ≠ 0 (honest unmet). QM43's sentence "a counter replaced by a constant cannot pass the battery"
holds only for the constant equal to the target, not the no-work value. Minor.

### F-C3-c: failing-selftest path (not covered by any control)
cand with `anchor-pins.sh` selftest printing `PASS (7 cases)`: `plans/round-40-c3.sh` → **1** (not counted, as the code says).
True, but the SCORECARD sentence cites `c3_forge_missing_gate → 0`, which covers the missing-script path only.

### F-C3-d: claims-declared selftest replaced by a no-op
cand with `claims-declared.sh` = `exit 0` (no verdict): counter refuses (`counter-refused: … selftest produced no verdict`, exit 2, no integer). Fail-closed works.

## 3. Battery sensitivity to the M40-3 counter change

Changed line (cb3f642 vs f687504): `${token}_SELFTEST: PASS (8 cases)` → `${token}: PASS (8 cases)`.
Predec counter grep pattern was `ANCHOR_PINS_SELFTEST_SELFTEST: PASS (8 cases)`, which never matches; this is the reproduced bug (predec-counter-on-cand → 0).

Controls with buggy vs fixed counter (`$S/sn-fixed` = predec + fixed counter):

| mode | buggy | fixed |
|---|---|---|
| c3_nowork | 0 | 0 |
| c3_forge_missing_gate | 0 | 0 |
| c3_selftest_anchor | 8 | 8 |
| c3_selftest_claims | 8 | 8 |

Why this is vacuous: c3_nowork has zero registry rows, so the loop never reaches the changed line;
c3_forge_missing_gate deletes `corpus/anchor-pins.sh` and the counter exits 2 before the line; the two selftest
modes call the gate directly and never execute the counter. The changed line is executed by no control.
The "score-neutral" receipt (`c3-fix-score-neutral.txt`) therefore cannot show neutrality of the changed line.

Chronology (mtime, local -03:00, `stat -c %y`):
- `plans/round-40-c3.sh` (fixed bytes in lane): 10:50:46
- `.ufo/waves/round-40/build/c3-at-candidate.txt` (value 2, no rc line): 10:52:25.9
- `.ufo/waves/round-40/controls/c3-fix-score-neutral.txt`: 10:52:25.7
- `.ufo/waves/round-40/build/candidate-fast-gates.txt` (contains `C3` = **0**, `C2` = 3): 10:52:41
- reflog export of cb3f642: 10:52:49; of 38a118f: 10:45:08; of f687504: 10:39:47.
Inference: the `C3 0` reading in `candidate-fast-gates.txt` was produced by pre-fix bytes (fixed bytes give 2; buggy bytes give 0), so a candidate-tree C3 reading of 0 was recorded before the fix. The lesson sentence "fixed BEFORE any claim scoring" is contradicted by the lesson's own citation of that receipt. [INFERENCE on the exact run start; the value-to-bytes mapping is measured.]

BASE reading for C3 (0) was measured with the predec counter injected (BASE has no counter file); same for C1 and C2 BASE receipts.

## 4. Causal separation summary

| Counter | Reads artifact of | Evidence |
|---|---|---|
| C1 | C2 (S095/S096 rows via census rows 93→96) | F-C1-b: 6 → 4 when C2 rows removed |
| C2 | C3 (`corpus/anchor-pins.sh`) | F-C2-b: 3 → 2 when the gate is replaced |
| C3 | none of C1/C2 | `noc2` C3 = 2; `sources-census.sh` does not read `anchor-pins.tsv` (census CLEAN rows=96 with the tsv removed) |

## 5. Axis fit (R38-D1 standard)

- C1 calibration: the surface moved is the ledger `expect` cells. The counter measures expect==output, not calibration against truth (F-C1-a). Four of six migrated values (census summary) move with registry size, i.e. a coverage/currency effect, not a calibration effect (F-C1-b). Two (R13-01, R24-06) count this round's own SCORECARD headings. Axis label fits the literal surface; the moved quantity does not measure calibration. Judgement: misfit for four rows.
- C2 freshness: items 2–3 move currency (new 3.15.2 fetch rows; quote verified; live-equal today). Item 1 moves the anchor-pin gate's pin count 3→4 (detection coverage of an existing row, no source refresh). Judgement: item 1 is a drift-detection coverage move labelled freshness; borderline misfit (the plan itself calls it "drift-detection and currency work").
- C3 operability: selftest PASS is an operability surface; registry row presence is a declaration (the plan's own ceiling). A row plus a verdict line can satisfy the counter with stubs (F-C3-a). Judgement: partial fit.

## 6. Unsupported assertions (exact sentence → missing evidence)

Plan (`plans/round-40.md`):
- "Census after: recorded at the landing revision; expected rows=96 A=92 captures=96 …" → candidate-lane census is committed (`candidate-lane.txt`: rows=96) ✓; the fleet "after" census is not committed (only `start-fleet.txt`).
- "The six new W04 duplicate-URL warnings the two new rows add" (line 196) → no committed after-census; the live validator shows 0 new W04 lines (19 total, unchanged). Contradicted by measurement; also contradicts SCORECARD's "two".
- "C1 verifies without C2 or C3 having landed" → contradicted (F-C1-b).
- "No counter reads another claim's artifact." → contradicted (F-C1-b, F-C2-b).
- "C2 reads only pins/registry/captures" (Round-34 bullet) → contradicted (F-C2-b).
- "the closure re-derives both sides" (C1 ceiling/kill rules) → no committed gate or closure script reads the journal; not evidenced.
- "a registry row without a passing selftest does not count (c3_forge_missing_gate → 0)" → the control covers the missing-script path only; failing-selftest path measured separately (F-C3-c), not by a control.
- "Forgeries cannot count" (plan C2 text, SCORECARD) → F-C2-a refutes.
- "the S095/S096 …" facts: verified (body shas, offsets, live equality) ✓.

SCORECARD `## Round 40 — pre-move`:
- operability row: "the two round-39 gates carry no selftest and no registry row (… measured at BASE: bash plans/round-40-c3.sh → 0 …)" → registry-row absence measured (0), but the BASE counter file does not exist; the reading is with the injected predec counter. "No selftest" is observed (base `--selftest` prints CLEAN) but no committed receipt states it.
- operability row: "Nine gate mode-sets with verdicts and selftests" → no committed enumeration; not measured here.
- freshness row: "S040/S041 name the served-3.15.1 documentation while docs.python.org serves 3.15.2" → supported at BASE capture time and by today's live fetch (3.15.2); the 3.15.1 naming is in SOURCES rows ✓.
- calibration row: "reads 6 at BASE (base-verify-at-tip.txt) … fail verify" ✓ supported.

SCORECARD `## Round 40 — post-move`:
- calibration: "The counter is fail-closed (a deleted row, a missing verify summary or a constant counter refuses it" → deleted row and missing summary are fail-closed (code, exit 2 branches read; not executed here). "a constant counter refuses it": no such branch in `plans/round-40-c1.sh`; constant detection is the battery's `c1_mutant_const` (a different script) → unsupported as worded.
- calibration: "The routed reds are unchanged and stay operator-owned" → no committed candidate verify output (`c1-at-candidate.txt` holds only `0`; wave `verify-at-candidate.txt` now exists, untested here) → unmeasured at candidate in the committed receipts.
- freshness: "Forgeries cannot count (control c2_forge_rows → 1)" → refuted (F-C2-a).
- operability: "A registry row without a passing selftest does not count (c3_forge_missing_gate → 0)" → true per code, untested by cited control (F-C3-c).
- operability: "Nothing schedules any gate; the by-hand duties remain by-hand." → not checked here [INFERENCE from absence of scheduler config in lane].
- coverage: "two new W04 duplicate-URL warnings are the round-37 precedent class" → contradicted/unmeasured (see plan item above).
- adjacency: "the connector sweep is in .ufo/waves/round-40/build/" → at my check time `K40ConnOverlap/` exists; its content not audited here.
- Footer: "Measured revision, exact exits and receipts are in the round report" → no round report exists in `.ufo/waves/round-40/` at the candidate (`ls` shows none).
- Scores "9 → 9" → judgement, no measurement.

Lesson `corpus/lessons/round-40.md`:
- Gate: "Located quote (8 whitespace tokens ≤ 25): “Matches Unicode whitespace characters (as defined by”" → **7** tokens (str.split). Same miscount class as M40-1, repeated in the erratum's own round.
- M40-3: "fixed BEFORE any claim scoring (no wave seat had been dispatched …)" → contradicted by `candidate-fast-gates.txt` C3 = 0 (scored before fix, see §3 chronology).
- M40-3: "proven score-neutral on the predeclaration extraction: all four c3 controls read their frozen expectations with the fixed bytes" → true (I reproduced 0/0/8/8) but the changed line is executed by none of them; "proven" overstates.
- M40-3: "the BASE receipt is byte-identical under both versions because 0 is 0" → BASE has no counter file; the receipt was measured with the predec counter; "byte-identical under both versions" is not a measured comparison.
- M40-1 (round-39 "9 words" → 8): verified ✓ (round-39 quote splits into 8).
- M40-2: receipts `base-verify-at-tip.txt`, `c2-nowork.txt`, `c2-at-predec.txt`, `c3-base.txt`, `prefreeze-gate.txt` exist ✓.
- "the eight `kagi` rows of the absent-defect register remain quarantined" → not checked here.
- QM43 "a counter replaced by a constant cannot pass the battery" → holds for constant = target; not for constant = no-work value (F-C1-c).

LOG.md: no round-40 block exists at the candidate (grep `Round 40` finds none). Nothing to check; no unsupported LOG assertion.

## 7. Forgery recipes (reproducible)

- F-C1-a: copy predec; in `corpus/claim-ledger.tsv`, set column 3 of the six ids to `^.*$`; run `bash corpus/claim-ledger.sh verify`; counter → 0.
- F-C1-b: copy cand; delete lines matching `^\| S09[56] \|` from `corpus/SOURCES.md` and `^S09[56]\t` from `corpus/source-fetches.tsv`; run `bash plans/round-40-c1.sh` → 4.
- F-C2-a: copy predec; append cand's S095/S096 registry lines; write any bytes containing the two quotes to `.ufo/waves/round-40/capture/S09{5,6}.body`; set column 10 of the cand S095/S096 fetch rows to `sha256sum` of those bytes; append rows; run `bash plans/round-40-c2.sh` → 3.
- F-C3-a: copy base; add `| x | gate | corpus/anchor-pins.sh | | \`…--selftest\` | | | kagi |` rows under `## Gate registry — round-22 changed contracts`; prepend `if [ "${1:-}" = "--selftest" ]; then echo "ANCHOR_PINS_SELFTEST: PASS (8 cases)"; exit 0; fi` to `corpus/anchor-pins.sh` (and the claims-declared analogue); copy cand's `plans/round-40-c3.sh`; run → 2.

## 8. Receipts in this seat directory

- `verify-noc2-cand-minus-C2-rows.txt` (6772 B), `verify-forge-c1-loosened-expects.txt` (6516 B), `c1-cand.stderr` (empty).
- This file. The remaining outputs are transcribed above from the executed commands.
