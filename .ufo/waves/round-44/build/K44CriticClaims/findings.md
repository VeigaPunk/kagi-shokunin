# K44CriticClaims — attack on the frozen round-44 plan and instruments

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`. Claim BASE `d54109d943abc900e71613a02e5a7a2e46453c3a`; predeclaration `ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae` (all plan text below cites the plan/instruments at that commit). No candidate exists; nothing was amended.

Method: sandbox `S=/fast/scratch/hyaku/kagi-r44/K44CriticClaims`, `git clone --shared` of the lane, detached at `ae9e9eb`; `git rev-parse --show-toplevel` verified equal to the sandbox work dir before any write. Fixture probes used separate scratch clones (`probe/fix`, `probe/fix2`) with the explicit fixture identity `K44CriticClaims-fixture <critic-fixture@scratch.invalid>` (self-describing, never pushed, scratch deleted before yield — same pattern as the plan's own smoke fixture). Scratch removed at end. No tools installed (none needed; pacman guard respected trivially).

## A. QM48 — every pre-candidate kill-clause command, run verbatim

All eight counter receipts re-executed in the sandbox at `ae9e9eb` with `d54109d…` as argument; `rc=0` each; outputs identical to the committed receipt bytes:

| receipt | committed | re-run (rc, stdout) |
|---|---|---|
| `c1-base` | 0 | rc 0, `0` |
| `c1-skipfix` | 0 | rc 0, `0` |
| `c2-base` | 0 | rc 0, `0` |
| `c2-forged-sha` | 0 | rc 0, `0` |
| `c2-forged-rev` | 0 | rc 0, `0` |
| `c3-base` | 0 | rc 0, `0` |
| `c3-pos` | 3 | rc 0, `3` |
| `c3-wrongvals` | 1 | rc 0, `1` |

Prefreeze, verbatim: `bash corpus/prefreeze-control.sh run --base d54109d… --controls plans/round-44.controls.tsv` → last line `PREFREEZE: CLEAN (controls=13 mismatch=0)`, rc 0 — byte-equal verdict to committed `prefreeze-base.txt`. All 13 tsv rows reproduce their `measured=` values.

Pins: instrument pin (C1 kill (d)) `git diff --quiet ae9e9eb HEAD -- plans/round-44-c1.sh plans/round-44-c2.sh plans/round-44-c3.sh plans/round-44-controls.sh plans/round-44.controls.tsv` → rc 0. Gate pin (C1 kill (e) form) `git diff --quiet 65f66e17… HEAD -- corpus/controls-replay.sh plans/round-43-c2.sh` → rc 0.

Kill-rule forms that only fire at the candidate were pre-exercised on battery-carrying trees (the predeclaration itself and scratch fixtures): `R44_SKIP_FIXTURES=1` at predecl → `0`; `R44_ONLY_FIXTURE=stale` at predecl → `1` (final-mode expectations hold before any candidate exists); kill (f) form exercised: battery against a bare-echo-2 counter → stdout empty, rc 2, stderr last line `battery-refused: recipes`. C2 kill (c)'s restore duty is implemented in the gate itself (`corpus/controls-replay.sh` steps (b)–(f): snapshot → delete → re-run → cmp → restore + drop extras), so the clause is executable and expected to pass.

QM48 verdict: no clause's form is refused by its gate; no M43-1-class defect this round. Every pre-candidate kill-clause command runs and reproduces.

## B. QM34/QM43 — declared BASE values: all executed, none an estimate

- The three `committed` facts were re-measured at the actual pin: `git show 5f3566c:.ufo/waves/round-42/controls/{c1-base,c2-base,c2-worktree-at-base}.txt | tail -1` → `4`, `0`, `3`; `git diff --stat 5f3566c d54109d -- <those three>` rc 0 (byte-identical at both revisions), so the tsv/prefreeze values measured at the d54109d archive are also true at the PIN the counter reads. Not estimates.
- Disposition paths exist at the predeclaration: row 1 `c2-manifest-rederive-base.txt` EXISTS; row 2 `c2-base-19025d9.txt` EXISTS, content last line `1` (matches the re-derived cell it supersedes).
- Only unreproducible evidence: `smoke-matrix.txt`'s fixture revisions `R1=17826e5…` / `R2=edecb28…` are UNREACHABLE (`git cat-file -e` fails in the lane; the smoke scratch fixture was deleted). Its three battery readings are nonetheless corroborated by reproducible measurements at the predeclaration below (2 / 0 / 1 — same shapes). Record the dead pointers in the lesson (D10).

## C. Predicate identity (plan sentence ↔ counter header ↔ receipt label)

Semantic comparison of the three frozen-predicate sentences against the counter headers: no semantic drift found in C1, C2, C3 (legs, gates, fail-closed lists, targets all correspond; C3's "exactly `superseded-by: <path>`" is effectively enforced — the suffix must exist as a path).

Drift found (D3): the C1 and C2 counter headers claim a third location — "the same sentence appears in plans/round-44.md section C1/C2 **and in the receipt labels**". No receipt carries the sentence: the round-44 receipts are bare digits (`cat .ufo/waves/round-44/controls/c1-base` → `0`), and the round-43 receipts are too (`cat .ufo/waves/round-43/controls/c2-base` → `0`). The C3 header correctly names only the plan. The "receipt labels" claim is false inherited provenance (the round-43-c2.sh header makes the same false claim).

## D. Do-nothing analysis (targets 2 / 1 / 3)

- At the claim BASE: battery/receipt/register all absent (prefreeze rows `battery_absent`/`receipt_absent`/`register_absent` = 0); all three counters read 0 (receipts re-run, section A). No do-nothing tree at BASE reaches any target.
- At the predeclaration `ae9e9eb` (the minimal tree every candidate descends from): `bash plans/round-44-c1.sh ae9e9eb` → **2** (rc 0). The C1 target is reached by a tree with zero candidate-specific work — this is the plan's declared design ("Candidate rule (executor's work): none on the lane tree — the instrument itself is the claim"), but see D6: the plan's no-work sentence over-infers from the BASE fact. `c2` at predecl → 0 (needs the committed receipt); `c3` at predecl → 0 (needs the register); `c3-pos` override → 3 (a fixture copy of the register reaches the target — register-as-claim, by design and honestly declared).
- Net: the wave's candidate work content is exactly C2's receipt production and C3's register landing; C1's target is precommitted. The kill rules' load-bearing content for C1 is P0 + the two pins.

## E. Forgeability per counter

**C1.** Cheapest forgery: a counter keyed on its own basename (`${0##*/}` = `r44b-real` / `r44b-mut-y1` / `r44b-mut-y2`) plus the override gate's blanket shape, carrying the frozen recipe markers inertly. Fixture probe (`FORG=467f73b2f71bdd413ce488248ee949dc4f45ce0b`): `bash plans/round-44-c1.sh $FORG` → **2**, rc 0 — the battery alone is fooled. The frozen controls catch it: gate pin `git diff --quiet 65f66e17… $FORG -- corpus/controls-replay.sh plans/round-43-c2.sh` → **rc 1** (kill (e) fires); instrument pin (kill (d)) rc 0 (battery untouched). Constants are caught by the battery itself: marker-carrying `echo 1` counter → battery **0** (the R-leg reads 1 ≠ 0 → kill (a)); bare `echo 2` → rc 2 (kill (f)). Ceiling text misattribution in D4.

**C2.** A fabricated receipt naming a real green revision passes — declared ceiling, confirmed and measured: the gate bytes are identical from `65f66e17` through the predeclaration (`git diff --quiet 65f66e17 ae9e9eb -- corpus/controls-replay.sh` rc 0; sha `fab42e1d…`), so any ancestor in that whole window satisfies leg (b); the counter cannot verify R = K = L^ (the parentage claim in the candidate rule is unenforceable by this counter). Leg (c) re-execution remains the load-bearing fact. The forged fixtures isolate the legs correctly (`receipt-wrong-rev` carries the REAL gate sha with an unknown revision; `receipt-wrong-sha` the real revision with sha `1111…`). Hash-leg hazard in D5 (verdict-safe).

**C3.** Values cannot be forged: `committed` cells are checked against PIN bytes, `re-derived` cells against an executed re-derivation, the sweep against executed `git grep`, dispositions against path existence at the candidate. Gaps found: extra register rows outside the frozen pattern family pass the "exactly three rows" structural leg (D1); the `via` cell is never read, contradicting a ceiling sentence (D2); the Basis/S099 duty is unenforced (D7).

## F. Causal separability

Each claim is verifiable without the others having landed: no counter consumes another's artifact — C1 runs the round-43 counter over pinned bytes, C2 runs gate + its receipt, C3 runs register + PIN re-derivation; all three were executed standalone in this seat. Shared files only. The kill rules' (d)/(e) pins are shared across claims but are tree-state facts, not shared verdicts. One common-mode coupling to record (D11): gate cleanliness (the eight-manifest re-derivation) is load-bearing for BOTH C1's P0 (the round-43 counter's P1) and C2's leg (c) — a single drifted manifest receipt byte at the candidate kills C1 and C2 simultaneously while C3 is insulated (its row-2 disposition leg is existence-only). Independent instruments, independent executions — no forbidden shared verdict.

## G. C3 register vs disclosed evidence; row-3 sweep precision

The register rows match `.ufo/waves/round-43/controls/c2-manifest-rederive-base.txt` exactly: c1-base 4→5, c2-base 0→1, c2-worktree-at-base "not written by any committed runner (absent after full delete)"; dispositions match; the row-2 superseding receipt exists and reads `1`. M44-1's corrected path is in the frozen fixture and `c3-pos` = 3 reproduces.

Row-3 sweep (`git grep c2-worktree-at-base <rev> -- 'plans/*.sh' 'corpus/*.sh'` at 5f3566c): the fact it claims is true repo-wide — a full-tree `git grep -l 'c2-worktree-at-base' 5f3566c` matches only `.ufo/waves/round-42/build-*` artifacts, round-42 build-seat files, SCORECARD.md, QUALITY.md, round-42 lessons and `plans/round-42.md` (prose/artifacts, no `.sh` at all), and `git grep -n 'worktree-at' 5f3566c -- '*.sh'` is empty (no dynamic-construction fragment either). But the frozen sweep is narrower than the claim's wording ("written by no committed runner" is repo-wide): it covers only `plans/*.sh` + `corpus/*.sh`; `scripts/` is empty at the PIN, but committed `.sh` trees exist outside both (e.g. `.ufo/waves/round-26/tools/replay-current.sh`), and literal grep cannot see a runner that constructs the name dynamically. Precision ceiling; widening to `'*.sh'` is provably value-preserving today (repo-wide grep already empty) — D8.

## H. Claims-declared repair; C2 receipt protocol

Repair: at BASE the tsv holds 7 rows; the predeclaration adds exactly the five omitted rows (git diff shows only `41 C1 calibration`, `41 C2 freshness`, `43 C1 calibration`, `43 C2 freshness`, `43 C3 operability` appended). At the predeclaration `bash corpus/claims-declared.sh` → `CLAIMS_DECLARED: CLEAN (claims=12)`, rc 0; SCORECARD.md carries `## Round 41 — post-move (claims C1 calibration, C2 freshness)` and `## Round 43 — post-move (claims C1 calibration, C2 freshness, C3 operability)` with exactly one `[C1]`/`[C2]`/`[C3]` tagged row each and matching axis cells. Consistent and already green; the QM41 omission-blindness is confirmed (the SCORECARD rows existed all along; only the manifest omitted them). Note: the repair landed inside the predeclaration commit itself, not "at landing" — harmless, but the lesson should say so.

C2 protocol: receipt names content revision K, L adds it, measured at L — coherent with the counter (receipt read from CAND bytes at `git show CAND:.ufo/waves/round-44/final/replay-at-tip.txt`; R ancestor-of-candidate + gate-hash binding; leg (c) re-executes at L). Unenforceable part: R = K = L^ (declared ceiling, D9). The receipt is hand-produced (no committed producer script); a typo'd line reads 0 — fail direction safe.

## Findings

### D1 — C3 structural leg is fail-open for rows outside the frozen pattern family
Defect: predicate says "The register holds exactly three rows in the frozen order (anything else fails closed)" / header "anything else is a structural defect". The structural check counts only rows matching `^\|[[:space:]]*\.ufo/waves/round-42/controls/c[12]-(base|worktree)`; any extra data row naming another receipt passes invisibly.
Evidence: copy of `register-full` with a 4th row `| .ufo/waves/round-42/controls/c2-derivation-D.txt | 1 | 1 | 5f3566c… | plans/round-42-controls.sh | superseded-by: … |` → `R44_REGISTER_ROOT=<that dir> bash plans/round-44-c3.sh ae9e9eb` → **3**, rc 0 (should be a structural refusal).
Impact: bounded — extra rows cannot increment N (only the three frozen rows count), so no false target is reachable; this is an integrity/structure-hygiene gap, not a value corruption.
Amendment (pre-measurement; values provably preserved — all measured registers carry exactly three such rows): add a total-row leg before counting, e.g. `[ "$(grep -cE '^\| \.ufo/waves/round-42/controls/' "$SCR/reg")" -eq 3 ] || { echo "counter-refused: register rows" >&2; exit 2; }`. Touching the counter requires the pin note below.

### D2 — C3 ceiling sentence is false about the code: the `via` cell is never read
Defect: plan §C3 ceilings: "the runner path is checked by execution: the legs run the named `via` file, so a nonexistent runner fails the leg". The counter hardcodes `bash plans/round-42-controls.sh`; cell 6 is never parsed.
Evidence: register copy with both rows' via cells = `plans/nonexistent-runner.sh` (diff verified) → `R44_REGISTER_ROOT=<dir> bash plans/round-44-c3.sh ae9e9eb` → **3**, rc 0. A nonexistent runner does NOT fail the leg.
Amendment (pre-validated in scratch on a patched copy — `RUNNER=$(cell "$R1" 6); (cd "$SCR/clone" && bash "$RUNNER")` replaces the hardcoded line): `c3-pos` → 3 (preserved), `c3-wrongvals` → 1 (preserved), nonexistent-via register → **1** (rows 1–2 drop; the ceiling sentence becomes true). Alternatively, minimum: correct the ceiling sentence to "the legs execute the hardcoded runner `plans/round-42-controls.sh`; the `via` cell is descriptive metadata (a wrong runner that still produces the values passes — reviewed as code)". Touching the counter requires the pin note below.

### D3 — false provenance claim in the C1/C2 counter headers ("receipt labels")
Defect: both headers claim the predicate sentence also appears "in the receipt labels". No round-43 or round-44 receipt carries any sentence; receipts are bare digits.
Evidence: `grep -n 'same sentence appears' plans/round-44-c{1,2,3}.sh` → C1 line 7 and C2 line 6 claim receipt labels, C3 line 8 does not; `cat .ufo/waves/round-43/controls/c2-base` → `0`; `cat .ufo/waves/round-44/controls/c1-base` → `0`.
Amendment: comment-only fix — drop the "and in the receipt labels" clause (C1/C2), or actually carry the sentence in the runner's `measured-at` labels. Comment-only edits still move instrument bytes: see the pin constraint below.

### D4 — C1 ceiling text misattributes the catchers
Defect: plan §C1 ceilings: "a counter mutant outside the recipe vocabulary (e.g. an echo-constant counter at 2) is caught only by the no-work control at BASE (a constant-2 counter cannot read 0 at BASE) and is otherwise outside the battery". Measured reality: constants ARE caught by the battery (echo-1 → 0 via the R-leg; bare echo-2 → rc 2 via the recipe guard); the BASE no-work control cannot catch any counter constant (there is no battery at BASE to run one); and the forgery class the battery genuinely cannot catch — a name/gate-keyed counter — is caught by the gate pin (e), which the ceiling text does not name.
Evidence: section E probes (`FORG` → 2 with pin rc 1; `E1` echo-1 → 0; `E2` echo-2 → rc 2, `battery-refused: recipes`).
Amendment (plan text only — `plans/round-44.md` is not covered by the instrument pin): reword to "constants are caught by the battery itself (P0/R-legs, recipe guard); a name- or gate-keyed counter forgery survives the battery and is caught only by the gate pin (e); the BASE no-work control establishes the battery-absent zero only."

### D5 — C2 fail-closed contract not implemented for unreadable gate bytes (verdict-safe)
Defect: header promises rc 2 for "candidate gate bytes that cannot be read". Code pipes `git show CAND:corpus/controls-replay.sh | sha256sum`, so a missing gate yields the sha256-of-empty (`e3b0c44298…`), which passes the `[ -n ]` guard; the counter proceeds and reaches 0 via the later `-f` leg instead of refusing.
Evidence: fixture commit `G=d3d4e462268fc3073717d72cd236855c0a4b0203` (gate deleted) + receipt `revision: 5f3566c…` (gate absent there, verified) with `gate-sha256: e3b0c4…` → `R44_RECEIPT=<receipt> bash plans/round-44-c2.sh $G` → stdout `0`, **rc 0** (contract says rc 2). At a normal candidate the same receipt reads 0 at the S-binding leg (measured) — the binding is solid wherever the gate exists.
Amendment: after computing `GATE_SHA_CAND`, verify the blob exists (`git cat-file -e "$CAND:corpus/controls-replay.sh"`) else exit 2. Verdict-neutral (0 either way). Requires the pin note below if applied.

### D6 — C1 no-work sentence over-infers (BASE fact stated as a global)
Defect: "at the claim BASE the battery file does not exist …, so no do-nothing tree reaches N = 2". True only at the BASE; every admissible candidate (≥ the predeclaration) carries the battery, and the minimal such tree reads the target.
Evidence: `bash plans/round-44-c1.sh ae9e9eb…` → **2**, rc 0, on a tree with zero candidate-specific work.
This is the declared instrument-as-claim design, not a hidden regression; the sentence should not read as if candidate work were required. Amendment (plan text): "no tree at the claim BASE reaches N = 2; every candidate carries the battery, so the candidate reading re-executes the precommitted discrimination — its load-bearing content is P0 and the pins (d)/(e)."

### D7 — the C3 Basis/S099 sourced-claim duty is unenforced by the counter
Defect/ceiling: the candidate rule requires the register's Basis line to cite S099, but no leg reads the prose.
Evidence: register fixture with ALL prose stripped (table rows only, no Basis) → `R44_REGISTER_ROOT=<dir> bash plans/round-44-c3.sh ae9e9eb` → **3**, rc 0.
Amendment options: (a) add a cheap leg `grep -q 'Basis: S099' "$SCR/reg"` (a predicate touch — allowed only as a named pre-measurement amendment; values preserved: the frozen register carries the line); or (b) declare it reviewed-as-code in the ceilings. S099 itself is correctly absent from SOURCES.md at BASE and predecl (it opens at landing).

### D8 — row-3 sweep is narrower than its claim's wording (precision ceiling)
Covered in section G. The repo-wide fact holds at the PIN (no `.sh` mention, not even the fragment). Optional amendment: widen the pathspec to `'*.sh'` (value provably unchanged today); otherwise name the scope+literalism ceiling in the lesson.

### D9 — C2 receipt provenance window (declared ceiling, now measured)
Gate bytes identical `65f66e17…` → predeclaration (rc 0, sha `fab42e1d…`), so any ancestor in the window passes leg (b); the counter cannot check R = K = L^. Declared ceiling; recommended: record the measured window in the lesson rather than amending (a `R == CAND^` leg would break the wrong-sha fixture's declared expectation, since it names R = the BASE itself).

### D10 — smoke-matrix fixture revisions are dead pointers
`git cat-file -e 17826e5…` / `edecb28…` fail (smoke scratch deleted). The smoke readings (2 / 0 / 1 / 1 / 0 / 0 / 3 / 1) are independently corroborated by this seat's reproducible runs (sections A/D). Lesson should note the smoke receipt is receipt-only evidence.

### D11 — common-mode coupling C1↔C2 via gate cleanliness (observation, no action)
One drifted eight-manifest receipt byte at the candidate kills C1 (P0) and C2 (leg c) together; C3 is insulated. Independent instruments/verdicts — record in the L1's kill bookkeeping so a simultaneous C1+C2 kill is diagnosed once, not twice.

### D12 — cosmetic: battery stderr can leak into final receipts
`cap` captures `2>&1`; when CAND ≠ the clone's HEAD the inner `git checkout --detach` prints the detached-HEAD advice (observed in fixture runs). Last line remains the digit, so `measured-at` is unaffected; at the real final measurement CAND = clone HEAD → clean. No action.

## Amendment constraint the L1 must honor

The instrument pin (kill (d)) anchors at the predeclaration `ae9e9eb` for `plans/round-44-c1.sh`, `-c2.sh`, `-c3.sh`, `-controls.sh`, `.controls.tsv`. Any byte edit to those five files after `ae9e9eb` makes the pin rc ≠ 0 and kills C1–C3 by their own clauses. Therefore: plan-text/ceiling corrections (D3 text via plan, D4, D6, D7(b), D8, D9, D10) are free — `plans/round-44.md` is not in the pin. Code amendments (D1, D2, D5, D3-in-counter-bytes) are admissible only if the L1 first declares, in the lesson and before any candidate measurement, a meta-amendment re-anchoring the pin to the amendment commit (the round-43 A2 pattern). All code amendments above were pre-validated in scratch to preserve every declared value (D2: 3/1 preserved; D1/D5 verdict-neutral by construction).

## Per-assignment verdicts

(a) QM48: all pre-candidate kill-clause commands run verbatim and reproduce; no refused form. (b) QM34/QM43: every declared BASE value executed; none an estimate; smoke caveat D10. (c) predicate identity holds semantically; drift = D3. (d) do-nothing: BASE-safe by receipts; predecl already reads C1's target (D6, by declared design); C2/C3 require their committed artifacts. (e) cheapest forgeries: C1 name-keyed (battery 2, pin catches); C2 fabricated receipt (declared ceiling, window measured); C3 values unforgable, structure/metadata gaps D1/D2/D7. (f) separable; common-mode D11. (g) register matches disclosed evidence; sweep fact true repo-wide, scope ceiling D8. (h) repair verified green (CLEAN claims=12, SCORECARD rows present, landed inside the predeclaration); C2 protocol coherent with an unenforceable parentage claim (D9).

Report: .ufo/waves/round-44/build/K44CriticClaims.md

SEAT-STATUS: complete
