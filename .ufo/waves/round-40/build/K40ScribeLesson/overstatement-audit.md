# K40ScribeLesson — overstatement-audit.md

Every sentence in the round-40 sections of `SCORECARD.md` and of
`corpus/lessons/round-40.md` that claims more than its receipt shows.

Scope: the round-40 sections are `SCORECARD.md` `## Round 40 — pre-move` and
`## Round 40 — post-move` (lines 1501–1530 at the candidate), and the whole of
`corpus/lessons/round-40.md` (49 lines at the candidate `cb3f642479a09644a03874909bb7e44b52697a8d`).
The L1's uncommitted working-tree edits (which already withdraw several of these)
are noted per item as **[withdrawn in the live tree]**.

Verdict vocabulary: **OVER** = the sentence asserts more than any committed
receipt shows. **UNSUPPORTED** = the sentence asserts something no receipt
establishes (weaker than OVER). **OK** = supported by a committed receipt I
re-ran or read.

Method: each candidate sentence is checked against committed bytes only —
`.ufo/waves/round-40/controls/`, `.ufo/waves/round-40/census/`,
`.ufo/waves/round-40/expectation-migrations.json`, the counters
`plans/round-40-c{1,2,3}.sh`, the gates, and the committed capture bodies.
Where the critic (K40CriticClaims) independently found the same thing I mark
**[critic]**; where the finding is mine alone I mark **[scribe]**.

---

## A. `SCORECARD.md` — `## Round 40 — pre-move` (lines 1501–1513)

| # | Sentence (condensed) | Verdict | Evidence |
|---|---|---|---|
| A1 | "Fresh-start round (operator "Authorize all", 2026-11-05)." | **UNSUPPORTED** | The manifest says kagi's last three closures are 36 `rejected-honest-stop`, 37 `admitted`, 38 `rejected-honest-stop`, 39 `admitted` (`MANIFEST.json` rounds 1298, 1321, 1328, 1343/1346 — read with `python3` over `MANIFEST.json`). The plan's own gloss ("the last three closures hold two rejected rounds — 36 and 38 — plus admitted 37, and round 39 closed verified") describes rounds 36/37/38, not the three most recent (37/38/39). Round 39 closed `admitted`/`verified`, so the three consecutive rejections the fresh-start rule needs are not all in the window. This is exactly the M39-5 class the round-39 lesson corrected (round 39 read `lanes: ok` as admission). **[scribe]** — not in the critic's list. |
| A2 | "Every axis stood at 9 at the round-39 close" | OK | `SCORECARD.md` round-39 post-move rows all read `9 → 9`. |
| A3 | "94 registry rows at BASE, census CLEAN (row `R21-02`, failing at BASE as named debt)." | OK | Measured at the BASE extraction: `SOURCES_CENSUS: CLEAN (rows=94 …)`, rc 0. `R21-02` FAIL at BASE confirmed in `.ufo/waves/round-40/controls/base-verify-at-tip.txt` line 21. |
| A4 | "the two round-39 gates carry no selftest and no registry row (routed defect, measured at BASE: `bash plans/round-40-c3.sh` → 0, `.ufo/waves/round-40/controls/c3-base.txt`)" | **OVER** | `controls/c3-base.txt` holds `0` — but BASE has **no** `plans/round-40-c3.sh` (`git ls-tree 6cc8850 -- plans/` → no round-40 file). The reading was taken with the predeclaration counter copied in, so "measured at BASE" is an injected-counter reading, not a BASE-tree run of a BASE script. The lesson/SCORECARD do not say so. **[critic]** (defect 10) |
| A5 | "Measured BASE gap: S036 is an unpinned fourth superseded feed anchor (M39-7) and S040/S041 name the served-3.15.1 documentation while docs.python.org serves 3.15.2" | OK | `corpus/anchor-pins.tsv` at the candidate holds four rows (S034, S035, S039, **S036**); S040/S041 scope cells read "title Python 3.15.1 documentation"; the S095/S096 fetch rows and capture titles read 3.15.2. |
| A6 | "Measured BASE gap: `bash plans/round-40-c1.sh` reads 6 at BASE (`.ufo/waves/round-40/controls/base-verify-at-tip.txt`)" | **OVER** | Same injected-counter issue: BASE has no `plans/round-40-c1.sh`. The cited receipt `base-verify-at-tip.txt` is the ledger **verify** output (it shows the six ids failing), not the counter's integer; the integer `6` lives in `controls/c1-base.txt`, which the sentence does not cite. Two receipts are conflated into one pointer. **[critic]** (defect 10) |
| A7 | "the inherited non-set FAIL rows R11-08, R22-03, R24-15, R36-03 are outside the frozen set and untouched" (post-move) | **OVER** | The *ledger cells* are indeed untouched — but R36-03's expectation is `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` and the gate it drives reads **differently at the candidate than at BASE**: BASE `FAILED (on_release=28 bound=28 unbound=0 observed=28 fired=13 derived=15)`, candidate `FAILED (on_release=30 bound=28 unbound=2 observed=28 fired=13 derived=15)` with `UNBOUND S095` and `UNBOUND S096`. The two new rows carry `recheck: on-release` and **no** `corpus/release-clocks.tsv` binding row, so the round's own rows grew the gate's `on_release` population 28 → 30 and its error set by two `UNBOUND` entries. The row was already FAILing at BASE (R37-V2 is routed out of scope), so no ledger verdict flipped — but "untouched" reads as "the gate reads as it did", and it does not: the round's rows are the reason the reading changed. **[scribe]** — not in the critic's list; the critic's list does not cover the release-clock side effect. |

---

## B. `SCORECARD.md` — `## Round 40 — post-move` (lines 1514–1530)

| # | Sentence (condensed) | Verdict | Evidence |
|---|---|---|---|
| B1 | "The frozen predicates, counters, kill rules and targets are `plans/round-40.md` and are not amended after data." | **OVER** | `plans/round-40-c3.sh` **was** amended after the freeze: the predeclaration bytes check `"${token}_SELFTEST: PASS (8 cases)"` (`git show f687504:plans/round-40-c3.sh`, line 37) while the candidate bytes check `"${token}: PASS (8 cases)"` (line 38). The plan's C3 kill rule "Weakening a selftest after data … is an amendment: C3 is then unmet" names the selftest; the token arithmetic in the counter was repaired in the same candidate commit. The lesson records the repair (M40-3), but this SCORECARD sentence still asserts no amendment after data. **[critic]** (defect 7, chronology) |
| B2 | "[C1] `bash plans/round-40-c1.sh` 6 → 0 at the candidate … the six routed debt rows re-run green after round-38-style measured migrations … every old→new pair in `.ufo/waves/round-40/expectation-migrations.json`" | OK (target) | I reproduced the counter in a scratch extraction of the candidate: prints **0**, rc 0, 289 s (`bash plans/round-40-c1.sh`, 2026-11-05). The journal's six old/new pairs match BASE and candidate ledger bytes field-for-field. The *target* is met. |
| B3 | "The counter is fail-closed (a deleted row, a missing verify summary **or a constant counter refuses it**; controls `c1_nowork` 6 and `c1_mutant_const` 0, red witnesses)." | **OVER** | `plans/round-40-c1.sh` has no constant-detection branch; it only refuses a missing `CLAIM_LEDGER:` summary and an absent id. Constant detection lives in the **battery** (`plans/round-40-controls.sh` `c1_mutant_const`), not in the counter. And the battery's coverage is one-sided: a counter replaced by `echo 6` passes `c1_nowork` (whose expectation is 6). QM43's wording ("a counter replaced by a constant cannot pass the battery") is therefore too strong. **[critic]** (defects 1, 11) |
| B4 | "The routed reds are unchanged and stay operator-owned: R25-02 (FAIL), R29-01 and R29-02 (POLICY), R38-03 (POLICY)" | **UNSUPPORTED** | No committed candidate verify output exists at the candidate: `.ufo/waves/round-40/build/c1-at-candidate.txt` holds the integer only, and the six ids' absence from FAIL/STALE/MISSING lines rests on the executor seat's uncommitted `verify-full.txt`. The committed `base-verify-at-tip.txt` is the **BASE** receipt, not the candidate's. **[critic]** |
| B5 | "the inherited non-set FAIL rows R11-08, R22-03, R24-15, R36-03 are outside the frozen set and untouched" | **OVER** | See A7 — the R36-03 **ledger cell** is untouched, but the gate it drives reads differently at the candidate because the round's own two rows grew the release-clock's `on_release` population (28 → 30) and added two `UNBOUND` entries. **[scribe]** |
| B6 | "[C2] `bash plans/round-40-c2.sh` 0 → 3 at the candidate" | OK (target) | Reproduced in the candidate extraction: prints **3**, rc 0. |
| B7 | "the gate reads `ANCHOR_PINS: CLEAN (pins=4)`" | OK | `bash corpus/anchor-pins.sh --root .` → `ANCHOR_PINS: CLEAN (pins=4)`, rc 0. The S036 pin value `04d278bb…` equals sha256 of the trimmed S036 anchor cell (recomputed). |
| B8 | "S095 and S096 are tier-A documentation refresh rows opened 2026-11-05 on the served Python 3.15.2 pages … each with a committed capture body, a fetch row whose sha binds the body, a verbatim quote located in the body, and the superseded row named" | OK | Capture shas match `source-fetches.tsv` column 10; both needles locate (count=1 each); both teaches cells open "supersedes S040 —" / "supersedes S041 —"; both bodies carry the 3.15.2 `<title>`. |
| B9 | "S040/S041 are not edited in place (CORPUS.md rule 2)" | OK | `git diff 6cc8850 cb3f642 -- corpus/SOURCES.md` adds exactly two lines (S095, S096); no S040/S041 line is touched. |
| B10 | "Forgeries cannot count (control `c2_forge_rows` → 1)." | **OVER** | The control covers a *registry-only* forgery (no fetch row, no capture body). A manifest-side forgery — fabricated bodies whose sha is written into the fetch row — reads 3. "Forgeries cannot count" is withdrawn in the live tree as M40-7. **[critic]** (defect 3) |
| B11 | "[C3] `bash plans/round-40-c3.sh` 0 → 2 at the candidate" | OK (target) | Reproduced in the candidate extraction: prints **2**, rc 0. |
| B12 | "both round-39 gates are registered in SKILL.md's gate registry and carry committed `--selftest` modes (8 cases each) whose expected findings include the reviewer's false-clean classes F1/F2/F3/F6 and D1/D2/D3/D5 plus a constant-mutant divergence witness" | **OVER** | Two gaps. (i) `claims-declared.sh --selftest` covers **D2 as a fenced-code-block heading only**; the reviewer's D2 class was "fence/comment headings" — the HTML-comment variant is not in the selftest (the gate's own header at line 15–16 names "fence/comment headings"; the selftest case 3 is the fence only). (ii) `anchor-pins.sh --selftest` case 5 is labelled "F3: extra trailing pipe cell", i.e. a *shape* case, while the plan and the SKILL.md registry row name F3 "schema". The class names do not line up with the committed case list. **[scribe]** — not in the critic's list. |
| B13 | "A registry row without a passing selftest does not count (`c3_forge_missing_gate` → 0)." | **OVER** | The cited control deletes the *gate script*, exercising the missing-script refusal; it does not exercise a *failing selftest*. Measured by the critic as F-C3-c = 1. The live tree withdraws it as part of the M40-9 correction. **[critic]** |
| B14 | "Registry 94 → 96 and captures 94 → 96 … `entries_sourced` stays 14" | OK | Lane census at the candidate: `SOURCES_CENSUS: CLEAN (rows=96 A=92 … entries_sourced=14 … captures=96 …)`, rc 0. |
| B15 | "two new W04 duplicate-URL warnings are the round-37 precedent class" | **OVER** | The fleet `validate` run prints **19** W04 lines at the candidate — the identical set as `census/start-fleet.txt` (`diff` of the two sorted W04 sets: no difference). No W04 line names S095 or S096: the two new rows reuse their superseded rows' scope cells, so the fleet census's W04 rule (same URL across *different* scopes) does not fire. The plan's own prose says "six new W04"; the SCORECARD says two; the measurement is **zero**. Three inconsistent numbers, none measured. **[critic]** (defect 9) — confirmed independently by me. |
| B16 | "Measured revision, exact exits and receipts are in the round report; no unrun result is stated here." | **OVER** | No round report exists in `.ufo/waves/round-40/` at the candidate. **[critic]** |
| B17 | SCORECARD post-move **citations** row: "`.ufo/waves/round-40/controls/prefreeze-gate.txt`" (candidate line 1520, in the C1 evidence cell) | **OVER** | The cited file is **not committed at the candidate**: `git cat-file -e cb3f642:.ufo/waves/round-40/controls/prefreeze-gate.txt` → `fatal: path … exists on disk, but not in 'cb3f642'` (rc 128). It is an untracked working-tree file. The committed candidate's citations gate therefore emits a **new** UNRESOLVED line: base extraction → 3 UNRESOLVED, candidate extraction → 4, the delta being exactly `UNRESOLVED SCORECARD.md:1520 .ufo/waves/round-40/controls/prefreeze-gate.txt (ufo)`. The self-description sweep's SD6 count consequently rises from 3 (BASE) to 4 (candidate) — a new self-description red introduced by the round's own evidence pointer. **[scribe]** — unique to this seat; not in the critic's list, and the L1's live M40 "SD6 (non-owned, measured)" note frames the SD6 movement as lane-tree-vs-extraction only and does not name this candidate-introduced UNRESOLVED. |
| B18 | SCORECARD pre-move operability row: "Nine gate mode-sets with verdicts and selftests" | **UNSUPPORTED** | No committed enumeration of nine mode-sets exists at the candidate; `SKILL.md`'s `## Gate registry` headings are three separate tables (`## Gate registry — round-22 changed contracts`, `## Gate registry — round-23/24 contracts (routed D2)`, `## Gate registry — round-34 routed closures`), not one numbered set of nine. **[critic]** |
| B19 | SCORECARD post-move adjacency row: "the connector sweep is in `.ufo/waves/round-40/build/`" | OK | `build/K40ConnOverlap.md` and `build/K40ConnOverlap/overlap.md` exist. |

---

## C. `corpus/lessons/round-40.md` (candidate, 49 lines)

### §Claims (lines 13–20)

| # | Sentence | Verdict | Evidence |
|---|---|---|---|
| C1 | "**C1 calibration** — `bash plans/round-40-c1.sh` 6 → 0" | OK (target) | Reproduced: 0, rc 0, 289 s. |
| C2 | "**C2 freshness** — `bash plans/round-40-c2.sh` 0 → 3" | OK (target) | Reproduced: 3, rc 0. |
| C3 | "**C3 operability** — `bash plans/round-40-c3.sh` 0 → 2" | OK (target) | Reproduced: 2, rc 0. |
| C4 | "clearing spot-check routed items 1 and 2" (on C3) | **OVER** | Spot-check routed item 1 asked for gate-registry rows "no name/kind/entry-command/verdict-map/selftest/pinned-values/write-scope/owner row exists for either". The two new SKILL.md rows carry 8 cells; the round-22/23/24 registry rows in the same file carry the full column set. Item 2 asked for a self-invocation mode "over isolated fixtures"; both selftests write scratch fixtures under `${HYAKU_SCRATCH:-${TMPDIR:-/tmp}}` — i.e. **outside** the repo and outside the lane's own tree, and the `TMPDIR` default is `/tmp`, which §7.4 of the round prompt makes non-citable. Item 2 is therefore only partly cleared. **[scribe]** — unique. |

### §Gate (lines 24–41)

| # | Sentence | Verdict | Evidence |
|---|---|---|---|
| C5 | "Located quote (8 whitespace tokens ≤ 25)" (S095) | **OVER** | Whitespace count is **7** (`str.split()` and `wc -w` agree). Same class as M40-1, repeated inside the lesson that mined it. Live tree corrects to 7 as M40-4. **[critic]** (defect 8); independently recounted by me (see `quote-counts.md`). |
| C6 | "Located quote (11 whitespace tokens ≤ 25)" (S096) | OK | 11 by both methods. |
| C7 | "served `<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>`" / "`html — HyperText Markup Language support … 3.15.2 …`" | OK | Both `<title>` strings are present byte-exact in the committed capture bodies. |
| C8 | "capture `.ufo/waves/round-40/capture/S095.body` (257722 bytes, sha256 `ef2d8abe…bf469b1`)" / S096 (20100 bytes, `570d72c3…d3fbab5`) | OK | `sha256sum` of both committed bodies matches; byte counts match. |
| C9 | "at raw body byte offset 75897" / "13521" | OK | `bytes.find(needle)` returns exactly 75897 and 13521. |
| C10 | "the backslash-s entry's Unicode-whitespace declaration is the basis of `corpus/rendered-text-v1.py`'s whitespace class, and it is unchanged on 3.15.2" | **OVER** | The *served text* is unchanged (the rendered-text-v1 locate of the full S040 sentence returns `count=1` in the 3.15.2 body), but the **basis has moved**: `corpus/rendered-text-v1.py` is the lane's single declared normalizer and its step-5 comment still cites the round-24 source S027, whose teaching is the `str.isspace()` class — and the S040/S027 sentence it quotes is still the one that locates. The stronger claim is the *versioned* one: the S095 teaches cell's verbatim quote is a **raw-literal truncation at an HTML tag boundary** (`…(as defined by <a class="reference internal" href=…#str.isspace>`), not a rendered-text sentence. So the new row quotes a *different string* from the one the normalizer's comment rests on. The lesson's "unchanged on 3.15.2" holds for the teaching; it does not hold for the quoted artefact the registry now binds. **[scribe]** — unique to this seat. |
| C11 | "The teaching grounds `rendered-text-v1.py`'s entity-step class; unchanged on 3.15.2." | **OVER** | Same shape as C10. The S096 verbatim quote is also a raw-literal truncation: the raw body reads `…HTML 5 standard\nfor both valid and invalid character references, and the <a class=…>` — the committed quote stops at "standard" and the continuation ("for both valid and invalid character references") is in the Derivation cell, not the quote. So the row's verbatim segment does not contain the clause the entity-step class actually turns on. **[scribe]** — unique. |
| C12 | "QM42 applied to both new rows … each teaches cell separates the verbatim quote … from the derived clause" | OK | Both S095/S096 teaches cells carry the "Quote (verbatim):" / "Derivation (paraphrase, outside the quote):" markers. |

### §Mistakes (lines 45–49)

| # | Sentence | Verdict | Evidence |
|---|---|---|---|
| C13 | M40-1 fix: "shown able to fail: the census's quote-locating counter (`plans/round-40-c2.sh` items 2–3) locates the verbatim segment only — a teaches cell whose quoted segment does not locate in the committed body cannot satisfy the item (red witness `c2_forge_rows` → 1)" | **OVER** | `c2_forge_rows` forges registry rows with **no capture body and no fetch row**; it fails at the fetch-row check, never reaching the quote-locate step. No committed control exercises the quote-locate branch. The fix claim is true in the counter's *code* but the cited red witness does not demonstrate it. **[scribe]** — unique. |
| C14 | M40-2 fix: "every BASE population measured and committed in the predeclaration before the freeze: `c1` 6 (`.ufo/waves/round-40/controls/base-verify-at-tip.txt`), `c2` 0 without the pin / 1 with (`c2-nowork.txt`, `c2-at-predec.txt`), `c3` 0 (`c3-base.txt`); the pre-freeze gate re-derived them on the predeclaration extraction (`prefreeze-gate.txt`, CLEAN)" | **OVER** (pointer) | The four control receipts exist and hold 6 / 0 / 1 / 0, and `prefreeze-gate.txt` reads `PREFREEZE: CLEAN (controls=9 mismatch=0)`. But `prefreeze-gate.txt` is **not committed** — it is untracked at the candidate (`git status --porcelain` → `?? .ufo/waves/round-40/controls/prefreeze-gate.txt`) — and the candidate SCORECARD cites it, which is what produces the new UNRESOLVED at B17. The lesson's own fix cell names the file without its directory, so the citations gate does not flag the lesson; the SCORECARD's full-path pointer is what breaks. **[scribe]** — unique. |
| C15 | M40-2 fix: "the pre-freeze gate re-derived them **on the predeclaration extraction**" | **OVER** | `plans/round-40.controls.tsv` rows command `bash "$BASE/plans/round-40-controls.sh" <mode>`, and `corpus/prefreeze-control.sh` extracts `--base <rev>` into scratch. The committed `prefreeze-gate.txt` does not record which revision it extracted, so the claim "on the predeclaration extraction" is not shown by the receipt it cites. (The counters themselves do not exist at BASE — `git ls-tree 6cc8850 -- plans/` shows no round-40 file — so some non-BASE tree was necessarily used.) **[critic]** (defect 10, partially) |
| C16 | M40-3 fix: "fixed BEFORE any claim scoring (no wave seat had been dispatched; the BASE receipt is byte-identical under both versions because 0 is 0)" | **OVER** | The committed `build/candidate-fast-gates.txt` records `C3 0` **at the candidate** with both registry rows present and both selftests passing — a candidate scoring that preceded the repair. The lesson cites that receipt itself. "No wave seat had been dispatched" may be true, but a *candidate reading* was taken and recorded, so "before any claim scoring" is imprecise. **[critic]** (defect 7) |
| C17 | M40-3 fix: "proven score-neutral on the predeclaration extraction: all four c3 controls read their frozen expectations with the fixed bytes (`.ufo/waves/round-40/controls/c3-fix-score-neutral.txt`)" | **OVER** | The receipt exists and reads `c3_nowork -> 0; c3_selftest_anchor -> 8; c3_selftest_claims -> 8; c3_forge_missing_gate -> 0` — all four as expected. But score-neutrality is asserted for the *predeclaration* only; the receipt's own header names the tree it ran on (`the fixed round-40-c3.sh … on the predeclaration extraction f6875047`), so nothing in it shows the fixed bytes give the same reading **at the candidate tree** where the frozen control rows are not the same population. The critic measured the four controls giving identical readings for buggy and fixed bytes (0/0/8/8) because two of the four do not execute the counter's verdict line. **[critic]** (defect 6) |
| C18 | M40-3 evidence pointer: "the candidate battery receipt `.ufo/waves/round-40/build/candidate-fast-gates.txt` shows `C3 0`" | OK | The committed file's `=== C3 at candidate ===` block reads `0`, rc 0. (Also note this committed receipt is the pre-fix artifact; the same file's C2 block reads `3`.) |
| C19 | M40-1 evidence pointer: "the round-39 lesson's Gate said "9 words" where the whitespace count is 8" | OK | Round-39 lesson §Gate: "located quote, 9 words: “Only `status`, `recheck` and `used-by` change in place”". `wc -w` on that string = **8**. Confirmed. |
| C20 | M40-1 evidence pointer: "the S094 teaches cell appends "an in-place anchor rewrite violates this rule", which appears nowhere in CORPUS.md" | OK | `grep` of the S094 teaches cell phrase against `CORPUS.md` → 0 hits; the S094 cell text matches the round-39 spot-check's §4 wording. |
| C21 | Lesson header: "Fresh-start round (operator "Authorize all", 2026-11-05); the rejection-history reads (rounds 38, 36, 34 spot-checks) are dispositioned in the plan's §Read before freezing." | **UNSUPPORTED** | Same premise as A1: `MANIFEST.json` shows kagi round 39 `admitted`, so the "three rejected closures" window the fresh-start rule needs is not the last three closures. **[scribe]** — unique. |

### §Census / Frontier / Assimilation — **ABSENT at the candidate**

The candidate lesson has **no** `## Census` section, no `## Frontier step` /
`§2b` record, no `## Assimilation and considerthese` section and no
`## Trial on real domain work` section. The frozen plan's "Frontier step (§2b)"
requires the census-before/after, the rows added, the rows touched, mistakes
mined, assimilation and considerthese — and round 39's lesson has all of them.
The candidate lesson is 49 lines with only §Claims, §Gate, §Mistakes.

Consequences, each a receipt the lesson does not show:

- **Census after is not recorded in the lesson.** The plan expects
  `rows=96 A=92 captures=96`; the committed `.ufo/waves/round-40/census/`
  holds `start-lane.txt` (rows=94), `start-fleet.txt` (19 W04),
  `candidate-lane.txt` (rows=96) and `candidate-fleet.txt` — but
  `candidate-fleet.txt` and `candidate-eol.txt` are **untracked** at the
  candidate (`git status --porcelain` lists them as `??`), so the "after"
  fleet census is not a committed receipt.
- **Rows touched old→new is not recorded.** The plan says "S040/S041 are not
  edited; S036's anchor is pinned, its cells unchanged". The migration journal
  records only the six ledger rows; the S036 pin addition (a new
  `corpus/anchor-pins.tsv` row) has no old→new record anywhere.
- **"the six new W04 duplicate-URL warnings the two new rows add"** (plan) is
  not recorded as falsified in the candidate lesson, and is false (B15).
- **No trial section.** Round 39's lesson has `## Trial on real domain work`;
  the candidate round-40 lesson has none, so the round's real-domain trial
  (S095/S096) has no home. The live tree adds a wave-settlement section but
  still no `## Trial on real domain work`. **[scribe]** — unique.
- **No §Wave settlement at the candidate.** The live tree adds one; the
  candidate has none, so the per-seat receipt map the plan's wave paragraph
  implies does not exist in the candidate bytes. **[scribe]**

---

## D. Summary

**24 items are flagged** (OVER or UNSUPPORTED) across the SCORECARD and lesson
round-40 sections: A1, A4, A6, A7, B1, B3, B4, B5, B10, B12, B13, B15, B16, B17,
C4, C5, C10, C11, C13, C14, C15, C16, C17, C21. They partition cleanly:

- **12 are already recorded by the critic** (K40CriticClaims §"Unsupported
  assertions" and defects 1, 3, 6, 7, 9, 10, 11): A4, A6, B1, B3, B4, B10, B13,
  B15, B16, C5, C16, C17.
- **12 are mine alone**, not in the critic's list and not in the L1's live
  corrections: **A1 / C21** (the fresh-start premise — the M39-5 class
  recurring), **A7 / B5** (the release-clock population grew by the round's own
  two unbound rows), **B12** (the committed selftest case list does not cover
  the D2 HTML-comment variant the reviewer named; F3 is a shape case labelled
  "schema"), **B17** (the candidate's own SCORECARD cites an **uncommitted**
  receipt, producing a new UNRESOLVED and a new SD6 red at the candidate),
  **C4** (the two selftests' scratch lives outside the tree and defaults to
  `/tmp`), **C10 / C11** (the two new verbatim quotes are raw-literal
  truncations at tag/line boundaries, so the quoted segments do not contain the
  clauses the teachings turn on), **C13** (the `c2_forge_rows` red witness
  never reaches the quote-locate branch it is cited for), **C14** (the
  pre-freeze receipt the lesson relies on is uncommitted), and **C15** (the
  pre-freeze gate's receipt does not record which revision it extracted).

Separately, **four lesson sections are absent** from the candidate
(§Census, §Frontier step, §Assimilation and considerthese, §Trial on real
domain work) where the frozen plan's Frontier step and round 39's lesson both
require them — see §C below. This seat's settlement draft carries the eight
findings above that need a new mistake id as M40-11 … M40-18.

The round's **three counter targets are reproduced** at the candidate by my own
runs (C1 = 0 rc 0 in 289 s; C2 = 3 rc 0; C3 = 2 rc 0). The overstatements are in
the prose that surrounds those numbers, and in three registry cells the round
bound to a body they do not fully cover.
