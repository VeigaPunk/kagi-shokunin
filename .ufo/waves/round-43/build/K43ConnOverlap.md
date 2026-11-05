# ConnOverlap — sibling overlap scan for kagi round 43 (C1 counter-discrimination, C2 controls-replay gate, C3 scratch discipline, SEAT-STATUS)

Seat: K43ConnOverlap (connector, leaf, read-only over siblings). Lane: kagi-shokunin.
BASE: `5f3566c4cfe65a74da4d201d74d28b403929807b` (amendment A1 `dd6ccb92bf04a061e9f1e66913d15f097397b1b3`).
Plan `plans/round-43.md` read in full; its frozen vocabulary, predicates, targets, kill rules, and controls govern this scan.
Axes touched by scanned claims: C1 → calibration; C2 → freshness; C3 → operability.

---

## 1. Scope and method

### Sibling lanes scanned (20 total, kagi-shokunin excluded)
All 20 active sibling worktrees under `/home/vgpnk/Projects/shokunin/`:
`audio-shokunin` (tip `f9da7ee9`), `chousa-shokunin` (tip `378fda82`), `game-dev-2d-shokunin` (tip `1e033ef0`), `game-dev-3d-shokunin` (tip `39ca397`), `kaidoku-shokunin` (tip `3baac2ef4`), `kake-shokunin` (tip `bde98691`), `kama-shokunin` (tip `9b4c7af1`), `kasegi-shokunin` (tip `d16d212`), `kengaku-shokunin` (tip `28e9f8bf`), `kotoba-shokunin` (tip `e073723`), `kotodama-shokunin` (tip `19aa4dd0`), `kumitate-shokunin` (tip `0bff4bab`), `lore-shokunin` (tip `0f044aa`), `mado-shokunin` (tip `24ba2a9d`), `mori-shokunin` (tip `973b2af1`), `revenger-shokunin` (tip `2875b9c`), `souji-shokunin` (tip `8b393b19`), `tabi-shokunin` (tip `58d84eda`), `tameshi-shokunin` (tip `f256302b`), `tsukuroi-shokunin` (tip `64f45b79`).

### Terms scanned across sibling tracked files
Searches executed across all 20 sibling repositories using read-only git queries over tracked trees (`git ls-files` and `git grep -n`):

| # | term / query pattern | scope | matching files | total hits | notes |
|---|---|---|---|---|---|
| 1 | `controls-replay` / `controls_replay` | all tracked files | **13** | **17** | kaidoku r38, souji r30/r59, tameshi r34, kengaku r90 cite (all wave-level audit seats / probe receipts) |
| 2 | `receipt-replay` / `receipt_replay` | all tracked files | **863** | **3,096** | kake r24 receipt registry, audit seats across fleet |
| 3 | `git archive` in verification gates / scripts / plans | all tracked files | **7,051** | **12,377** | widespread export/clone fixture pattern (kake r51, kaidoku r38, etc.) |
| 4 | `re-derive` / `rederive` | all tracked files | **29,469** | **81,128** | pervasive audit/verification principle across fleet |
| 5 | `token-refusing` / `token-refus` | all tracked files | **44** | **54** | kake, kumitate, tameshi, tabi token rejection tests |
| 6 | `answer-key` / `answer key` | all tracked files | **602** | **1,264** | mado, kotoba r86, tsukuroi r31, kumitate r64/65, chousa, kaidoku |
| 7 | `blanket gate` / `fixture` / `refuse` / `accept` | all tracked files | **696** | **935** | kake, kasegi r43, kotoba r88, tabi r64, mado, game-dev |
| 8 | `fakeC` (exact word match `\bfakeC\b`) | all tracked files | **0** | **0** | kagi-specific fixture name; lexical homoglyphs `FakeClock`, `FakeChild`, `fakechroot` exist |
| 9 | `${TMPDIR:-/tmp}` / `TMPDIR:-/tmp` | all tracked files | **1,658** | **3,331** | historical fallback pattern across wave scripts |
| 10 | `${TMPDIR:-/tmp}` / `TMPDIR:-/tmp` | `corpus/` only | **27** | **32** | kasegi, game-dev-3d, chousa scripts; kake, souji, tsukuroi lesson/quality audits |
| 11 | `SEAT-STATUS` (exact token uppercase) | all tracked files | **1** | **1** | souji r16 (`.ufo/waves/round-16/w2/RevWaveOneDispositions.md:307`: `LG-SEAT-STATUSVOCAB`) |
| 12 | `seat-status` / `SEAT STATUS` (any case) | all tracked files | **430** | **589** | kaidoku QUALITY 22, kake `seat-status.json`, lore r93, mori M12, souji r16/17 |

### Method caveats
All queries inspected tracked files only (via `git grep` and `git ls-files`); ignored files, uncommitted sandboxes, and git metadata directories (`.git`) were excluded. Large match clusters (`re-derive`, `git archive`, `receipt-replay`, `${TMPDIR:-/tmp}` overall) were analyzed by targeted subdirectory filtering (`corpus/`, `plans/`, `scripts/`, `quality/`, `tools/`) and classified into functional families rather than enumerated file-by-file.

---

## 2. Headline answers (the two explicit questions)

### (1) Does any sibling already run a committed replay gate over its committed receipts? — NO.
**No sibling currently runs a standing committed replay gate over its committed receipts at its current tip.**
- **Verification of kake r90→r91 prior art at current tip:**
  In the round-42 lesson (§Adjacency line 198), kake r90→r91 was cited as fleet prior art for the defect class where a controls runner read the live lane tree (R90-C) and stopped replaying cleanly.
  At kake's current tip (`bde9869144f69c5a459c0d2c93f5135922fe3a8d`), `.ufo/waves/round-91/c91_defects.py` **still exists as a tracked, committed file**:
  - `path:line`: `/home/vgpnk/Projects/shokunin/kake-shokunin/.ufo/waves/round-91/c91_defects.py:24-32` (docstring defining item C replay requirement);
  - `path:line`: `/home/vgpnk/Projects/shokunin/kake-shokunin/.ufo/waves/round-91/c91_defects.py:216-255` (`def item_c(root, rev, work, detail)`: creates scratch clone via `git clone -q --shared root clone`, checks out `--detach rev`, executes `.ufo/waves/round-90/controls/run_controls.sh`, and asserts rc 0 with `controls ok K/K`, $K \ge 9$);
  - Committed receipt: `/home/vgpnk/Projects/shokunin/kake-shokunin/.ufo/waves/round-91/controls/replay-tip.txt:1-16` (`controls ok 9/9` at `f4fff130a52ae6de49af5de7d568d2ee320ebfb0`).
  - Round-92 successor: `.ufo/waves/round-92/c92_defects.py:65` pinned `FROZEN91 = ".ufo/waves/round-91/c91_defects.py"` and re-scored it.
  - **However**, `c91_defects.py` was a round-specific wave counter, not a permanent standing gate in `scripts/` or `corpus/`, and has no registry row in `SKILL.md` (kake `corpus/lessons/round-91-verifier-spotcheck.md:49`). Later kake rounds (r93, r94, r95, r96) do not execute `c91_defects.py`.
- **Other siblings:**
  - `tameshi-shokunin` committed `tools/receipt-revision-gate.py:1-60` (round 56/57, documented in `corpus/knowledge/receipt-revision-binding.md:1-40`), but it is a **static git-object revision validator** (`rev=` token inspection against git commit trees), NOT an execution-replay runner.
  - `souji-shokunin` established the principle in round 18 (`census/round-18/transcripts/w1/ConnFleetPointerTools.txt:110-119`: "resolve at `--rev`, never the worktree") and ran one-off controls replays in wave 2 seats (round 30 `census/round-30/waves/make-spec-w2.py:49`; round 59 `census/round-59/wave/w1/S59Reviewer.md:140`), but has no standing gate.
  - `audio-shokunin` has verifier scripts (`corpus/live/r86-critic/arm-replay.py`, `corpus/live/r96-verifier/runs/r96v_laws.py`), which re-derive mathematical laws from recorded receipt fields (JSON/WAV), but do not execute controls runners in scratch clones.
- **Synthesis:** Kagi's round-43 C2 candidate rule (`corpus/controls-replay.sh`), which takes a clean clone at the candidate revision, snapshots and deletes its historical controls directories (`round-41` and `round-42`), re-runs both runners, and verifies byte-matching re-derivation across all 8 manifest receipts, is the **first standing, durable committed gate of its kind in the fleet**.

---

### (2) Does any sibling implement counter-discrimination controls like K1/K3/fakeC? — NO (in exact form); YES (in adjacent 1D form).
**No sibling implements kagi's specific K1/K3/fakeC counter-discrimination matrix (crossing counter mutants with broken gate stand-ins), but adjacent counter-level discrimination controls exist in several siblings.**
- **Kagi round-43 C1 mechanism:**
  A 2D discrimination matrix specifically constructed to expose three broken instrument shapes that survived round 42:
  - `K1`: valid-token blanket gate that refuses positive control P0 → scores 0 on real counter; exposes guard-drop mutant `m3` (reads 6 instead of 0).
  - `K3`: constant-wrong-token gate that accepts positive control P0 → scores 0 on real counter; exposes token-drop mutant `m5` (reads 6 instead of 0).
  - `fakeC`: basename-keyed 5-forgery answer-key gate (accepts P0, answers F1–F5, ignorant of F6) → scores 5 < target 6, rejected by the 6-forgery target.
  - Blanket refuse / blanket accept: score 0 / 0.
- **Sibling prior art (adjacent implementations):**
  1. **`mado-shokunin` — `quality/check-counter-discrimination.py:1-60` (closest sibling gate in purpose):**
     A dedicated gate scoring whether admission counters can tell work from shape. Runs counters against a 25-item control manifest (3 accept, 22 reject) to score the *instrument* rather than the corpus claim. Catches always-accept, always-reject, and crashing mutants.
  2. **`kotoba-shokunin` — `plans/round-86.md:65-90` (K-series controls):**
     Counters tested against `K0` (do-nothing base), `K1` (echo forgery), `K2` (answer-key forgery: 215 hardcoded module literals in `K2-hardcode-module.py:704`), and `S` (34-assertion selftest over broken modules, answer keys, echo tokens).
  3. **`tsukuroi-shokunin` — `plans/round-31.md` and `.ufo/waves/round-31/measure/controls/build-c1-controls.py:1-40`:**
     Builds `K1` (sourceless-forged / answer-key statements) and `K2`–`K4` junk controls in sandbox clones against the round counter.
  4. **`kake-shokunin` — `c96_reval.py:15-20, 51-58` and `c89_key.py:599-607`:**
     - `anti_table`: asserts no hand-case or generated-case input digest, and no forgery stem, appears in candidate source (`c96_reval.py:15-16`);
     - `FORGERIES`: 6 frozen negative fixture scripts (`neg-blanket-construct.py`, `neg-blanket-update.py`, `neg-swap-precedence.py`, `neg-refuse-all.py`, `neg-oracle-import.py`, `neg-pin-reader.py`) that must be refused 6/6;
     - Shortcut guards that reject candidate sources containing oracle imports or case-table stubs (`c89_key.py:603-605`).
  5. **`kasegi-shokunin` — round 43 `w1/CritC2DoNothing.md:131-134`:**
     Uses `standins/blanket-accept/claim-package-check.py` and blanket-refuse gates.
  6. **`kumitate-shokunin` — round 64/65 (`forge-oracle.mjs:5`, `cheat-tool.mjs:9`):**
     Answer-key replay fixtures and anti-answer-key isolation.
- **Synthesis:**
  Kagi's innovation in C1 is the **closed 2D matrix** where specific broken gate fixtures (K1, K3) are paired with specific counter mutations (guard-drop m3, token-drop m5) to prove the counter instrument cannot be compromised by dropping its positive-control guard or its token validation, while expanding the forgery population (F6) kills 5-key answer gates like `fakeC`. Sibling prior art addresses answer-key and blanket gates via source inspection (`anti_table` in kake) or 1D test manifests (mado, kotoba), but does not cross counter mutants with broken gates.

---

## 3. Hit table (path:line, owning lane, verdict)

Verdicts:
- **overlap** = directly implements or carries the exact mechanism / script defect in scope.
- **adjacent** = same problem family, alternative mechanism, or sibling lesson / quality audit of the concept.
- **none** = lexical collision, false positive, housekeeping receipt, or unrelated usage.

### Topic A: Replay and re-derivation gates over committed receipts

| path:line | owning lane | verdict | detail |
|---|---|---|---|
| `.ufo/waves/round-91/c91_defects.py:24-32, 216-255` | kake | **overlap** | Item C: clones `--shared` at `--revision`, replays `.ufo/waves/round-90/controls/run_controls.sh`, asserts rc 0 and `controls ok K/K` ($K \ge 9$). |
| `.ufo/waves/round-91/controls/replay-tip.txt:1-16` | kake | **overlap** | Committed replay receipt: `controls ok 9/9` at `f4fff130a52ae6de49af5de7d568d2ee320ebfb0`. |
| `.ufo/waves/round-92/c92_defects.py:65` | kake | adjacent | Re-scores frozen round-91 counter (`FROZEN91 = ".ufo/waves/round-91/c91_defects.py"`). |
| `tools/receipt-revision-gate.py:1-60` | tameshi | adjacent | Static git-object revision binding validator; checks `rev=` against git tree blobs; no execution replay. |
| `corpus/knowledge/receipt-revision-binding.md:1-40` | tameshi | adjacent | Contract and rules for binding receipts to revision; names positive, verdict, and control roles. |
| `census/round-30/waves/make-spec-w2.py:49` | souji | adjacent | Seat `ControlsReplay`: replays `controls.sh` and `controls-amended.sh` in scratch and diffs `controls.tsv`. |
| `census/round-59/wave/w1/S59Reviewer.md:140` | souji | adjacent | Replays frozen controls twice into `probe-controls-replay.json` to verify determinism. |
| `.ufo/waves/round-38/w2/R38W2C2Controls.md:88` | kaidoku | adjacent | `item1_controls_replay`: `git archive efd5c47a... tools -> scratch`, runs counter against 7 controls. |
| `corpus/live/r86-critic/arm-replay.py:109-136` | audio | adjacent | Re-derives law verdicts from recorded JSON receipt fields; no runner re-execution. |
| `corpus/live/r96-verifier/runs/r96v_laws.py:2-10` | audio | adjacent | Re-derives armed claim cells from receipt raw fields only. |
| `corpus/evidence/round31/gate-binding-neutered.txt:1-2` | kengaku | adjacent | Re-derivation and neutering check on `/tmp` clone copy. |
| `scripts/receipt_replay.py:1-53` | kake | adjacent | Round-24 receipt-set replay registry against pinned revision with digest pinning. |

### Topic B: Counter-level discrimination controls (token-refusing, answer-key, blanket fixtures, K1/K3/fakeC)

| path:line | owning lane | verdict | detail |
|---|---|---|---|
| `quality/check-counter-discrimination.py:1-60` | mado | adjacent | Dedicated gate running admission counters against 25 control fixtures (3 accept, 22 reject) to score instrument discrimination. |
| `plans/round-86.md:65-90` | kotoba | adjacent | Counter discrimination table: `K0` base, `K1` echo forgery, `K2` answer-key forgery (`K2-hardcode-module.py:704`), `S` selftest. |
| `.ufo/waves/round-86/receipts/c1-K2-hardcode.txt:1-10` | kotoba | adjacent | Receipt showing answer-key forgery rejected (`G1 FAIL (215 hardcoded literals)`). |
| `.ufo/waves/round-31/measure/controls/build-c1-controls.py:1-40` | tsukuroi | adjacent | Builds `K1` (sourceless forged answer key) and `K2`–`K4` junk fixtures in clone for counter testing. |
| `.ufo/waves/round-96/c96_reval.py:13-22, 51-58` | kake | adjacent | Counter checks `anti_table` (no input digest/forgery stem in candidate) and rejects 6 negative fixtures (blanket, oracle-import, etc.). |
| `.ufo/waves/round-89/c89_key.py:599-607` | kake | adjacent | Shortcut guard rejects `ctl-oracle-import` and `ctl-table` stubs. |
| `.ufo/waves/round-43/w1/CritC2DoNothing.md:131-134` | kasegi | adjacent | Counter tested against `standins/blanket-accept/claim-package-check.py` and blanket refuser. |
| `.ufo/waves/round-64/build/K64CriticC1Predicate/forge-oracle.mjs:5` | kumitate | adjacent | Answer-key fixture reading expect files to answer without evaluation. |
| `.ufo/waves/round-64/build/K64ReviewProbeC1/probe-fixes.patch.txt:3` | kumitate | adjacent | Patch addressing answer-key leakage into tool CWD neighborhood. |
| `.ufo/waves/round-31/controls/a1/c2-falsifier-b-answer-key.sh:2` | mori | adjacent | Falsifier B: reads lane's frozen answer key `c2-fixtures.json`. |
| `corpus/live/r89-simplifier/proofs/differential.py:49` | audio | none | `class FakeClock`: fake clock class in audio timing fixture (lexical collision). |
| `reports/round-84/r84-author.md:77` | game-dev-3d | none | `scratch_fakechild/`: test directory for child process (lexical collision). |
| `.ufo/waves/round-25/a2-falsify/advice/ReviewerCapacityTool.md:10` | kama | none | `FakeChild`: stub class writing log bytes (lexical collision). |
| `.ufo/waves/round-24/w1/ExecMirrorTimestamps/host-extra-pkglist.txt:1875` | tsukuroi | none | `fakechroot`: pacman package listing in mirror audit (lexical collision). |

### Topic C: Scratch defaults (`${TMPDIR:-/tmp}` in corpus scripts)

| path:line | owning lane | verdict | detail |
|---|---|---|---|
| `corpus/instruments/r-defect-closure.sh:461, 750` | kasegi | **overlap** | Line 461 `mktemp -d "${TMPDIR:-/tmp}/rdc-r9.XXXXXX"`; line 750 `${SCRATCH_ARG:-${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}}`. |
| `corpus/instruments/r35-defect-closure.sh:114` | kasegi | **overlap** | `SCRATCH_BASE=${KASEGI_SCRATCH:-${TMPDIR:-/tmp}}`. |
| `corpus/instruments/r42-closure.sh:75` | kasegi | **overlap** | `SCRATCH_ROOT="${TMPDIR:-/tmp}"`. |
| `corpus/instruments/r43-closure.sh:80` | kasegi | **overlap** | `WORK="$(mktemp -d "${TMPDIR:-/tmp}/r43-work.XXXXXX")"`. |
| `corpus/instruments/r43-limbs/k17-claims-before.sh:570` | kasegi | **overlap** | `K17_WORK=$(mktemp -d "${TMPDIR:-/tmp}/k17-work.XXXXXXXX")`. |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh:23, 49, 59` | game-dev-3d | **overlap** | Line 59 `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` in gate runner. |
| `corpus/evidence/round33/no-name-signals.sh:104` | chousa | **overlap** | `tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/no-name-signals.XXXXXX")`. |
| `corpus/evidence/round73/controls/v72-killline-harness.sh:7` | chousa | **overlap** | `work=$(mktemp -d "${TMPDIR:-/tmp}/v72-killline.XXXXXXXX")`. |
| `verifiers/fault_injection_corpus.sh:30, 53` | kotoba | adjacent | Line 53 `WORLDS=${TMPDIR:-/tmp}/round12-faults.$$` (in verifiers/, not corpus/). |
| `scripts/plan-before-ready.sh:205, 222, 374, 611, 613` | kumitate | adjacent | Multiple `${TMPDIR:-/tmp}` mktemp paths in standing script (in scripts/, not corpus/). |
| `tools/tsukuroi-census.sh:2048, 2057` | tsukuroi | adjacent | Selftest scratch path uses `st_base=${TMPDIR:-/tmp}` (in tools/, not corpus/). |
| `corpus/lessons/round-71.md:71` | kake | adjacent | C2 counter flaw: fails to reject `${TMPDIR:-/tmp}` repoint escaping scratch root. |
| `corpus/lessons/round-72.md:59` | kake | adjacent | Analysis of `${TMPDIR:-/tmp}` fallback repoint escaping regex guards. |
| `corpus/lessons/round-73.md:39` | kake | adjacent | Fleet rationale: `${TMPDIR:-/tmp}` substitutes `/tmp` when unset/null, re-introducing `/tmp` hazard. |
| `corpus/QUALITY.md:28` | souji | adjacent | Rule Q4: fixtures must run only under `/var/tmp` (never `/tmp`, checks `${TMPDIR:-/tmp}`). |
| `corpus/lessons/round-12.md:152` | souji | adjacent | M10/M23 fix: Q4 test checks and rejects `${TMPDIR:-/tmp}`. |

### Topic D: `SEAT-STATUS` liveness conventions

| path:line | owning lane | verdict | detail |
|---|---|---|---|
| `.ufo/waves/round-16/w2/RevWaveOneDispositions.md:307` | souji | adjacent | Proposes `LG-SEAT-STATUSVOCAB` for tracking seat STATUS lines across wave boundaries. |
| `.ufo/waves/round-17/w2/ScribeLessonDraft.md:64` | souji | adjacent | Round-17 seat STATUS paragraphs carried under round-16 channel rule; open vs resolved@rev. |
| `.ufo/waves/round-93/wave-spec.json:13` | lore | adjacent | `"seat_status_semantics": "complete means the declared report receipt is present; it is not claim admission..."` |
| `.ufo/waves/round-93/validate_wave_spec.py:132` | lore | adjacent | Validates wave spec: checks `seat_status_invalid:{phase_id}:{seat_id}`. |
| `corpus/QUALITY.md:7-32` (row 22) | kaidoku | adjacent | Admission criterion: round seat-status claims must name cutoff, distinguish terminal failures from unreturned, retain dispositions. |
| `.ufo/waves/round-19/w2/QualityPrefix.md:9` | kaidoku | adjacent | Explains Row 22 seat-status grounding and lesson M19 fix. |
| `.ufo/waves/round-31/w1/seat-status.json:1-180` | kake | adjacent | Retained per-seat record: dead-at-spawn=18, returned=13, refused=1, with ID/role/error. |
| `scripts/seat_status_check.py:60` | kake | adjacent | Check script for verifying wave seat status against partials and returns. |
| `corpus/lessons/round-12.md:35, 80` | mori | adjacent | Mistake M12: "Seat status ≠ artifact" (settlement requires artifact + status). |
| `.ufo/waves/round-46/w1/ScribeReport.md:94, 184` | tsukuroi | adjacent | PENDING tag on per-seat status; requires settled `w1-results.json` before status inference. |
| `LOG.md:1433` | tsukuroi | adjacent | States that missing per-seat status in manifest prevents dead-seat inference. |
| `.ufo/waves/round-68/R68ReviewSkillRefresh.md:3` | revenger | none | `**Seat status (required disclosure).** I am a lane-dispatched seat...` (advisory role disclosure). |
| `.ufo/waves/round-29/w2/RevMarkerO10/NEWS-v262:21855` | tsukuroi | none | Upstream systemd changelog: `* "loginctl seat-status" will now show...` (command name false positive). |

---

## 4. Verdict tally summary

| category | overlap | adjacent | none | total |
|---|---|---|---|---|
| A. Replay / re-derivation gates | 2 | 10 | 0 | 12 |
| B. Counter discrimination controls | 0 | 10 | 4 | 14 |
| C. `${TMPDIR:-/tmp}` scratch defaults | 3 | 8 | 0 | 11 |
| D. `SEAT-STATUS` liveness conventions | 0 | 11 | 2 | 13 |
| **Total** | **5** | **39** | **6** | **50** |

*Note on cluster totals:*
- **Overlap (5):** kake r91 `c91_defects.py:24-32, 216-255` (re-derives controls in clone at revision, verifies receipt); kake r91 `controls/replay-tip.txt` (replay receipt); kasegi corpus instruments (`r-defect-closure.sh`, `r35-defect-closure.sh`, `r42-closure.sh`, `r43-closure.sh`); game-dev-3d `run_gate.sh:59`; chousa corpus evidence scripts.
- **Adjacent (39):** mado `quality/check-counter-discrimination.py`; tameshi `tools/receipt-revision-gate.py` and `corpus/knowledge/receipt-revision-binding.md`; kake `c96_reval.py`, `c89_key.py`, and r71–r73 lessons on `${TMPDIR:-/tmp}`; kotoba `plans/round-86.md` K-series controls and `verifiers/fault_injection_corpus.sh`; tsukuroi `build-c1-controls.py` K-series controls and `tools/tsukuroi-census.sh`; kumitate `forge-oracle.mjs` and `scripts/plan-before-ready.sh`; souji Q4 `/var/tmp` rule and r16/r17 `LG-SEAT-STATUSVOCAB`; lore r93 `seat_status_semantics`; kaidoku QUALITY row 22; mori M12; souji r30/r59 review probes.
- **None (6):** lexical collisions for `fakeC` (audio `FakeClock`, game-dev-3d `scratch_fakechild`, kama `FakeChild`, tsukuroi `fakechroot`); systemd `loginctl seat-status` in tsukuroi NEWS; revenger advisory disclosure.

---

## 5. Proposed move (connector synthesis)

### Move M: Document fleet prior art in round-43 lesson and affirm the standing nature of kagi's new instruments
1. **Freshness (C2 Lineage):**
   Record in `corpus/lessons/round-43.md` (§Adjacency) that kake r90→r91 (`.ufo/waves/round-91/c91_defects.py:24-32, 216-255`) and tameshi r56/r57 (`tools/receipt-revision-gate.py:1-60`) established the necessity of revision binding. Kake's implementation was a one-shot wave counter; tameshi's was static AST/token verification. Kagi's `corpus/controls-replay.sh` synthesizes these into the fleet's first **standing, execution-based controls re-derivation gate** committed to `corpus/`.
2. **Calibration (C1 Lineage):**
   Record in the lesson that while mado (`quality/check-counter-discrimination.py`), kotoba (`plans/round-86.md` K2 answer key), and kake (`c96_reval.py` `anti_table` and negative fixtures) verified counter discrimination against 1D failure sets, kagi C1 introduces a **2D matrix** specifically pairing broken gates (K1, K3) with counter mutants (guard-drop m3, token-drop m5) and using forgery expansion (F6) to expose 5-key answer gates (`fakeC`).
3. **Operability (C3 Lineage):**
   Record that kagi's migration away from `${TMPDIR:-/tmp}` directly reflects hard-learned fleet lessons from kake (rounds 71–73) and souji (rule Q4 in `corpus/QUALITY.md:28`), where `${TMPDIR:-/tmp}` was proven to defeat scratch isolation whenever `TMPDIR` is unset or null.
4. **Liveness (SEAT-STATUS convention):**
   Record that kagi's M42-5 fix (`SEAT-STATUS: complete` / `SEAT-STATUS: partial <detail>`) advances the fleet's seat accounting lineage (kaidoku QUALITY row 22, lore r93 `seat_status_semantics`, souji r16 `LG-SEAT-STATUSVOCAB`) by establishing an in-band terminal yield token easily verifiable by the L1 aggregator without heuristic inference.

### Affected axes
- **Calibration:** Improved — clear lineage bounds and exact discrimination matrix characterization.
- **Freshness:** Improved — verifiable grounding of C2 standing gate against historical wave-only precedents.
- **Operability:** Improved — reinforces `${HYAKU_SCRATCH:-/fast/scratch/hyaku}` discipline against `${TMPDIR:-/tmp}` hazard.
- **Harm:** None — zero lane mutations; read-only scan.

### Risks and bounds
- Sibling paths are mutable across rounds; citations are pinned to exact tip commits and line numbers observed during this round.
- No sibling files or lane tree files outside `.ufo/waves/round-43/build/K43ConnOverlap/` were modified.
- Sandbox clone was deleted on completion.

---

## 6. Verification and bounds

- Searches: Git grep executed across all 20 sibling directories with exact patterns shown in §1.
- Read tools used to inspect:
  - kake tip `bde98691`: `.ufo/waves/round-91/c91_defects.py:1-68, 196-255`, `.ufo/waves/round-91/controls/replay-tip.txt`, `.ufo/waves/round-92/c92_defects.py:50-100`, `.ufo/waves/round-96/c96_reval.py:1-63`;
  - mado tip `24ba2a9d`: `quality/check-counter-discrimination.py:1-65`;
  - kotoba tip `e073723`: `plans/round-86.md:65-95`;
  - tsukuroi tip `64f45b79`: `.ufo/waves/round-31/measure/controls/build-c1-controls.py:1-40`;
  - tameshi tip `f256302b`: `tools/receipt-revision-gate.py:1-64`, `corpus/knowledge/receipt-revision-binding.md:1-40`;
  - souji tip `8b393b19`: `.ufo/waves/round-16/w2/RevWaveOneDispositions.md:300-315`, `census/round-30/waves/make-spec-w2.py:45-55`, `corpus/QUALITY.md:20-35`;
  - kasegi tip `d16d212`: `corpus/instruments/r-defect-closure.sh:455-465, 745-755`, `.ufo/waves/round-43/w1/CritC2DoNothing.md:130-140`.
- Tooling: No new tools installed; standard python3, bash, git used.
- Scratch sandbox: Created at `/fast/scratch/hyaku/kagi-r43/K43ConnOverlap`, cleaned up before completion.

---

SEAT-STATUS: complete

Report: .ufo/waves/round-43/build/K43ConnOverlap.md
