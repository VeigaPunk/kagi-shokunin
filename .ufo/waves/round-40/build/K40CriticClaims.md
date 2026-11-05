# K40CriticClaims — round-40 critic report (leaf, no delegation)

Candidate `cb3f642479a09644a03874909bb7e44b52697a8d` · BASE `6cc8850` · predeclaration `f687504` · frozen plan `38a118f`.
Receipts: `.ufo/waves/round-40/build/K40CriticClaims/falsify.md` (commands, outputs, forgery recipes, chronology),
`verify-noc2-cand-minus-C2-rows.txt`, `verify-forge-c1-loosened-expects.txt`, `c1-cand.stderr`.
Tool installs: **none**. Git: read-only (`git archive`, `log`, `reflog`, `status`, `rev-parse`); no fixture repo, no commit, no push.
Scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40CriticClaims/` removed at finish.

## Verdict

| Claim | Declared | Reproduced at cand | Do-nothing reading | Verdict |
|---|---|---|---|---|
| C1 calibration 6→0 | 0 | **0** (rc 0) | **6** (predec) | Target reproduced. Falsified as a calibration measure: loosening six `expect` cells to `^.*$` reaches 0 with no journal (F-C1-a). Falsified causal separation: 4 of 6 rows read C2's registry rows, so the same counter is 4 without C2 (F-C1-b). |
| C2 freshness 0→3 | 3 | **3** (rc 0) | **0** (predec, pin removed) | Target reproduced. Forgeable to 3 by authoring capture bodies with no network (F-C2-a). Item 1 is a drift-detection coverage move, not freshness (borderline). Reads C3's `anchor-pins.sh` (F-C2-b). |
| C3 operability 0→2 | 2 | **2** (rc 0) | **0** (predec/base) | Target reproduced. Forgeable to 2 with forged rows + constant-PASS selftest stubs (F-C3-a); no control exercises the counter's verdict line. M40-3 chronology and "score-neutral" claim not supported as written. |

No do-nothing tree reaches any target. Forged rows reach 3 (C2) and 2 (C3) with no capture body or selftest content, and C1 reaches 0 by editing expects. The counters are reproducible; their discrimination is not what the plan says.

## Surviving defects (ordered by weight)

1. **C1 is forgeable by expect rebinding (F-C1-a).** `plans/round-40-c1.sh` counts verify FAIL lines only. Nothing committed reads `.ufo/waves/round-40/expectation-migrations.json`; the plan's kill rule "expect moved without matching old→new record → C1 unmet" is reviewer-enforced. Counterexample: predec tree with six `expect` cells set to `^.*$` → counter 0 (`verify-forge-c1-loosened-expects.txt`). Axis: calibration label fits the literal surface, but the number measures expect==output. The ceiling in the plan does not name this. Smallest correction: a committed gate that re-derives each migrated `expect` pair against the BASE ledger and the candidate ledger and refuses any row whose new expect is not a literal of its command's output (a control row `c1_forge_loosen` expecting nonzero).
2. **C1 reads C2's artifacts (F-C1-b).** Removing S095/S096 from SOURCES.md and source-fetches.tsv gives C1 = **4** (R21-02, R31-02, R33-02, R34-03). The migrated census values `rows=96 … captures=96` are a coverage effect of two appended rows, not a calibration effect. This falsifies "C1 verifies without C2 or C3 having landed", "No counter reads another claim's artifact", and "C1 reads only corpus/claim-ledger.tsv rows through verify" (indirectly, through census). Smallest correction: state the coupling in the plan and the SCORECARD row, or move the four census rows out of C1's population (they are not calibration claims), or declare the axis of those moves as coverage.
3. **C2 forgeable to 3 with authored bytes (F-C2-a).** The counter checks: registry row present with `| docs | A |`, fetch row column 10 == sha256 of the committed body, `supersedes S04x` substring, first curly-quoted string located in body. It does not check provenance (no fetch receipt, no URL/HTTP/date binding, no fetch tool output). A forger writes a body containing the quotes, sets column 10 to its sha, and the counter gives 3. The control `c2_forge_rows` only covers the no-body case, so "Forgeries cannot count" is overstated. Today's live bytes equal the committed captures (curl check in falsify.md), so the claim is true; the counter just does not discriminate. Smallest correction: a fetch-receipt table (URL, HTTP status, Date header, `curl` exit, tool version) with its own sha bound to the body, and a control with a forged body.
4. **C2 reads C3's instrument (F-C2-b).** Replacing `corpus/anchor-pins.sh` with a DRIFT stub drops C2 to 2 (and C3 to 1 in the same tree). Plan line "C2 reads only pins/registry/captures" is false. Axis: item 1 moves anchor-pin coverage (3→4 pins) of an existing row; it is drift detection, not a source refresh. The plan itself calls it "drift-detection and currency work". Judgement: borderline misfit under R38-D1; items 2–3 fit freshness.
5. **C3 forgeable to 2 with stub selftests (F-C3-a).** The counter reads the last output line and the exit code. Base tree + two forged SKILL.md rows + `--selftest` stubs that print `PASS (8 cases)` → counter **2**. The C3 controls `c3_selftest_*` also grep the verdict text, so they cannot separate a stub from the real selftest. Smallest correction: the counter must run the gate's selftest and require the eight per-case PASS lines (not the summary token), and a control must stub a selftest and expect 0.
6. **The C3 battery does not execute the counter's verdict line (F-C3 battery sensitivity, M40-3).** Predec counter bug (doubled token) reproduces 0 at a tree with both rows and both selftests (`predec-counter-on-cand` = 0). The fixed counter reads 2. But the four C3 controls give identical readings for buggy and fixed bytes (0/0/8/8), because c3_nowork has no rows and c3_forge_missing_gate exits 2 before the changed line; the selftest controls never run the counter. So the "score-neutral" receipt (`c3-fix-score-neutral.txt`) cannot show neutrality of the changed line. Axis: operability label fits selftest PASS; registry-row presence is a declaration (plan admits).
7. **M40-3 chronology contradicts its own text.** The lesson says the counter was "fixed BEFORE any claim scoring". `candidate-fast-gates.txt` (mtime 10:52:41) records `C3 = 0` at candidate; the fixed counter file mtime is 10:50:46 and fixed bytes read 2, so the 0 reading was produced by pre-fix bytes, i.e. a candidate scoring preceded the fix. The lesson cites that receipt itself. [INFERENCE on run start; the bytes→value mapping is measured.] Also a post-freeze change to a frozen counter is an amendment that the plan's kill rules do not list. Honest record: "a candidate reading of 0 preceded the fix; the fix restored the frozen predicate text."
8. **Lesson miscount repeats M40-1's class.** `corpus/lessons/round-40.md` Gate: "Located quote (8 whitespace tokens ≤ 25)” for S095 — the quote splits into **7** tokens (`Matches Unicode whitespace characters (as defined by`). S096's 11 is correct. Smallest correction: erratum line in the lesson and a QM42 note that token counts are measured by the quote-locate step, not stated.
9. **The W04 claim is unmeasured and internally inconsistent.** `plans/round-40.md` line 196: "six new W04 duplicate-URL warnings"; SCORECARD coverage row: "two new W04 duplicate-URL warnings". The fleet `validate` run at the current tree prints 19 W04 lines, the same as `start-fleet.txt`, none naming S095/S096. The plan's "census after" fleet receipt is not committed. Smallest correction: commit the fleet after-census receipt and state the measured count (currently 0 new lines).
10. **The BASE readings are injected-counter readings.** BASE has no `plans/round-40-c{1,2,3}.sh`; `c1-base.txt`, `c2-nowork.txt`, `c3-base.txt` were measured with the predeclaration counters copied in. The plan's "measured at BASE" should say so. Also, BASE `corpus/anchor-pins.sh --selftest` ignores the flag and prints `ANCHOR_PINS: CLEAN (pins=3)`, exit 0 (observed; the plan's "no selftest" is true only in the sense that no selftest mode exists).
11. **Minor, verified:** QM43 says a constant counter "cannot pass the battery". A constant-6 C1 counter passes c1_nowork (F-C1-c); a constant-0 C3 counter is caught by c3_forge_missing_gate (F-C3-b). The QM43 wording should say "constant equal to the target is caught".

## Unsupported assertions (full table in falsify.md §6)

- SCORECARD post-move calibration: "a constant counter refuses it" — no such branch in `plans/round-40-c1.sh`; detection is only the battery's `c1_mutant_const`.
- SCORECARD post-move calibration: "The routed reds are unchanged" — the committed candidate receipt (`c1-at-candidate.txt`) holds the integer only; no candidate verify output is committed.
- SCORECARD post-move freshness: "Forgeries cannot count (control c2_forge_rows → 1)" — refuted by F-C2-a.
- SCORECARD post-move operability: "A registry row without a passing selftest does not count (c3_forge_missing_gate → 0)" — true by code; the cited control covers the missing-script path, not a failing selftest (F-C3-c measured 1).
- SCORECARD post-move coverage: "two new W04 duplicate-URL warnings" — unmeasured; see defect 9.
- SCORECARD footer: "Measured revision, exact exits and receipts are in the round report" — no round report exists in `.ufo/waves/round-40/` at the candidate.
- SCORECARD pre-move operability: "Nine gate mode-sets with verdicts and selftests" — no committed enumeration.
- Lesson Gate: "8 whitespace tokens" (S095) — 7.
- Lesson M40-3: "fixed BEFORE any claim scoring"; "proven score-neutral"; "byte-identical under both versions" — see defects 6–7, 10.
- Plan Round-34 bullet and C2/C1 separability sentences — see defects 2 and 4.
- Plan: "the closure re-derives both sides" — no committed gate reads the journal.
- LOG.md: no round-40 block exists at the candidate; no LOG assertion to check.
- Lesson "the eight kagi rows of the absent-defect register remain quarantined" — not checked by this seat.
- Verified as supported: S095/S096 body shas (`ef2d8abe…`, `570d72c3…`), located offsets 75897 and 13521, live `curl` bytes equal to the captures, the migration journal's old/new values against BASE and cand ledgers, the S040/S041 rows untouched (candidate diff adds two lines only), the 54-heading count and row-identity sha, census `rows=96`, the nine pre-freeze controls at predec (re-run here: 6, 0, 0, 1, 1, 0, 8, 8, 0), the round-39 "9 words" erratum (quote = 8 tokens).

## Causal separation (step 4)

- C1 ← C2: **violated** (F-C1-b: 6→4 pattern with C2 rows removed; cand 0 → 4).
- C2 ← C3: **violated** (F-C2-b: C2 3→2 with the gate replaced).
- C3 ← C1/C2: not violated (`noc2` C3 = 2; census independent of `anchor-pins.tsv`).

## Commands and exit codes (summary; full list in falsify.md §1–3)

- `bash plans/round-40-c1.sh`: cand 0 (rc 0, ~340 s); predec 6 (rc 0, ~335 s).
- `bash plans/round-40-c2.sh`: cand 3; predec 1; noc2 1; anchorstub 2; forge-c2 3; cand-minus-pin 2 (all rc 0).
- `bash plans/round-40-c3.sh`: cand 2; predec 0; predec-counter-on-cand 0; forge-c3 2; noc2 2; c3const 0 (controls: 0/1); failing-selftest 1; claims no-op → exit 2, no integer (all rc as printed).
- Controls (predec): c1_mutant_const 0; c2_nowork 0; c2_positive_pin 1; c2_forge_rows 1; c3_nowork 0; c3_selftest_anchor 8; c3_selftest_claims 8; c3_forge_missing_gate 0 — all as expected.
- `corpus/sources-census.sh` cand: CLEAN rows=96 (rc 0); with anchor-pins.tsv removed: CLEAN rows=96.
- `corpus/row-identity.sh scorecard-rounds`: count=54 sha256=52e7ba8d… (rc 0).
- `corpus/claim-ledger.sh verify` on forge-c1 and noc2: `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`.
- Fleet `sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`: rc 0, `kagi ok`, 19 W04, none for S095/S096 (read-only use; write behaviour not audited).

## Smallest safe corrections (one line each, for the canonical judge)

- C1: add a committed expectation-migration gate with fail-closed literal check and a loosened-expect control; or re-declare the census-linked moves as coverage.
- C2: add a fetch-receipt binding and a forged-body control; re-declare item 1 as drift detection or drop it from the freshness count.
- C3: counter runs the selftest and requires the eight PASS lines; add a stub-selftest control and a positive-registry control at the candidate-like tree.
- Lesson/SCORECARD: correct "8 tokens"→7, the "fixed BEFORE any claim scoring" sentence, "constant counter refuses it", "two W04" (measure it), and the "round report" pointer.
