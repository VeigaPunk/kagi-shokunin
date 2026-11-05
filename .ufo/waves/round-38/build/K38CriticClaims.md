# K38CriticClaims — kagi round 38, wave `build`: falsification of the claims as written

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, candidate `b944735`, claim BASE `a916f4a`, predeclaration `8c48b7d`, frozen plan `289e808`.
Method: read-only. Every test ran in a `git archive` extraction of the named revision under my scratch (`/fast/scratch/hyaku/kagi-r38/K38CriticClaims/`); the lane tree was not written; lane `git` was read-only (`status`, `grep`, `rev-parse`, `cat-file`); one `git clone --shared` into scratch for the selftest hygiene check; live `curl -fsSL --compressed` of two GitHub tag URLs (read-only, into scratch).

## Top line

- **Reproduced.** C1 `QUOTE_LOCATE: CLEAN located=5 rows=5`, exit 0; `plans/round-38-c1.sh` → 5; BASE → 0; forgeries (quote, bytes, registry) → 4, 4, 4 at `8c48b7d` and at `b944735`. C2 `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`, exit 0; `plans/round-38-c2.sh` → 3; BASE → 0; `--no-mutate` → `detected=0`. Selftest leaves the lane clone untouched and no fixture residue.
- **Falsified (sentence or premise is false on the measured evidence):** F1 (the round-36 counter "reads 6 at HEAD", and "stale=3" — measured 3 and 0); F3 (lesson: "Re-pointing only the id leaves the gate CLEAN" — measured FAILED with 10 DERIVATION findings); F14 (SCORECARD points to a "round-38 lesson's Wave settlement" that does not exist); F8 (the C2 counter measures an operability artifact, not calibration; the calibration reading relabels it).
- **Overstated:** F4 (live-check quote omits `RELEASE_CLOCK: FAILED`, 30 `RECEIPT-MISMATCH` lines and exit 1); F5 (the rendered-text command quoted does not test its own sentence); F6 (capability cell "forged … each fail" — a regenerated forgery passes CLEAN 5); F7 (C1 axis label "freshness" against AXES.md); F9 (M38-2 `git grep` output quoted as three files; it is seven at `b944735`); F11 (ledger migrations described as complete; three previously passing ledger rows now FAIL and one new row is POLICY, none disclosed); F10 and F15 (“corrected” / “answered” for R37-V1 and R37-V2).
- **Not testable by me:** M38-4 (edit-drift narrative), lesson "Assimilation: none" and the eight quarantined rows, the `R37-V3` section number in the closure. Listed in §6.

## 1. Findings (file:line, quoted text, command, output, verdict)

Line numbers: `SCORECARD.md`, `LOG.md`, `plans/round-38.md`, `corpus/lessons/round-38.md` at `b944735`.

### F1 — round-36 counter "reads 6 at HEAD" and "stale=3" — FALSIFIED
- SCORECARD.md:1452 (pre-move calibration row): "`bash plans/round-36-c1.sh` reads 6 at HEAD after the round-37 calibration row omitted the three routed reds (SD5=3)".
- LOG.md:1738: "Round-36 counter `bash plans/round-36-c1.sh` read 6 at HEAD (SD5=3 from the round-37 calibration row; stale=3 from the claim-row count)."
- Command (clean extraction of `a916f4a`, no round-38 file present): `bash plans/round-36-c1.sh; echo rc=$?` → `3`, `rc=0`. Companion: `python3 corpus/self-counts.py` → `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`. So the counter's sum is SD5=3 + stale=0.
- Prose at BASE: `SKILL.md`: "stamps + 82 claims"; `PROVINCE.md`: "112 revision stamps + 82 claim rows"; live `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` → 82. Nothing was stale.
- Verdict: the "6" is **FALSIFIED** (measured 3); "stale=3 from the claim-row count" is **FALSIFIED** (measured 0). SD5=3 is SUPPORTED (sweep at BASE: SD5=3). The landing reading `0` at `b944735` is SUPPORTED (see §2c).

### F2 — round-36 counter reads 0 at landing — SUPPORTED
- SCORECARD.md:1462: "the round-36 counter `bash plans/round-36-c1.sh` is brought back to its frozen 0 by that row and by rebinding SKILL.md, PROVINCE.md and `corpus/README.md` to 86 claim rows."
- Command: `cd ext-cand && bash plans/round-36-c1.sh; echo rc=$?` → `0`, `rc=0`. Sweep at cand: `SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=0 SD8=0 SD9=0)` (SD6 is excluded from this counter by its own header); `SELF_COUNTS: POLICY (claims=63 stale=0 …)`.
- Verdict: SUPPORTED as a reading at `b944735`. I did not ablate the calibration row vs the prose rebinding, so the attribution "by that row and by rebinding" is not separately measured.

### F3 — R37-V2 lesson reading "Re-pointing only the id leaves the gate CLEAN" — FALSIFIED
- `corpus/lessons/round-38.md:37`: "Re-pointing only the id leaves the gate CLEAN and leaves the derived clocks inconsistent with their feed anchor cell (the round-37 closure's 10 DERIVATION findings)."
- The lesson's own table (lines 29–33) measured one row: S027 id S036→S091, anchor kept: `RELEASE_CLOCK: CLEAN (… observed=30 fired=15 derived=15)` (reproduced exactly).
- The general sentence was tested by re-pointing all four superseded feed ids in `corpus/release-clocks.tsv` (S034→S089, S035→S090, S036→S091, S039→S091; anchors untouched; the 15 clocks bound to those feeds are S012–S016, S021–S028, S040, S041 — 5 + 6 + 2 + 2):
  `DERIVATION S013`, `S014`, `S015`, `S016`, `S021`, `S022`, `S023`, `S024`, `S025`, `S026` (10 lines), then `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=20 fired=5 derived=5)`, rc=1.
- Verdict: "leaves the gate CLEAN" is **FALSIFIED** as a general statement (true only for the single S027 edit); "10 DERIVATION findings" is SUPPORTED (reproduced exactly).

### F4 — R37-V2 live-check quote omits the verdict and exit — OVERSTATED
- `corpus/lessons/round-38.md:39`: "`python3 -I -B corpus/release-clock.py --observe .ufo/waves/round-38/controls/observe-r38.json` → `wrote 30 observations (failed=0 fired=15 regressed=0)`."
- Committed stdout `.ufo/waves/round-38/controls/observe-r38.stdout` (and my rerun at `b944735`, rc=1): line 1 is the quoted line; then 30 lines `RECEIPT-MISMATCH S005` … `RECEIPT-MISMATCH S041`; last line `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=0 fired=0 derived=0)`.
- Cause (corpus/release-clock.py `receipt_matches`, line 485): `receipt_date(receipt["observed_at"]) != values["observed_at"]` — the bound rows still say 2026-11-04, the fresh receipt says 2026-11-05. The mismatch is a date-binding gap, not a clock movement, but the committed evidence FAILs and the lesson omits it.
- The 30-of-30 comparison (§2f) is SUPPORTED. Verdict for the quoted line: **OVERSTATED** (selective quote; the gate verdict and exit status are omitted from the lesson, and the same non-consumability that R37-V2 names for round-37 recurs for the round-38 receipt, unremarked).

### F5 — rendered-text command in the lesson — OVERSTATED
- `corpus/lessons/round-38.md:24`: "Measured: `python3 -I -B corpus/rendered-text-v1.py locate <file> '<title>v2.2.1</title>'` → `count=0` on a file that contains that exact string, because `locate` strips markup before matching."
- `grep -c '<title>v2.2.1</title>' .ufo/waves/round-38/capture/S092-vault-tag.body` → `0`: the quoted string is not in the file. The command as written does not test the sentence.
- With the string the file does contain, `'<title>Release v2.2.1 · hashicorp/vault · GitHub</title>'` → `RENDERED_TEXT_V1_LOCATE: count=0`, rc=1 (the lesson's claim holds for this string). With the same title text without markup, `'Release v2.2.1 · hashicorp/vault · GitHub'` → `count=1`, rc=0. The markup-stripping reading is consistent with those two queries.
- Verdict: **OVERSTATED** (the printed command does not test the stated premise; the reading is supported only by the unquoted variants).

### F6 — capability cell "forged quotes, bytes and registry rows each fail" — OVERSTATED
- `SCORECARD.md:708` (located-quote gate row): "forged quotes, bytes and registry rows each fail". QM39 (`corpus/QUALITY.md`) and `corpus/lessons/round-38.md:65–67` (M38-3) read the same way.
- Counterexample (scratch copy of `b944735`): overwrote `S092-vault-tag.body` with 21,886 bytes of filler, then the quote at offset 21886 (21,954 bytes total); regenerated the S092 `source-fetches.tsv` row's sha256 and byte count (the capture row is produced by the same lane script, `plans/round-38-rows.py fetch`).
  `python3 -I -B corpus/quote-locate.py` → `QUOTE_LOCATE: CLEAN located=5 rows=5`, rc=0; `bash plans/round-38-c1.sh` → `5`.
- Control (same fabricated body, capture row not regenerated): `NOT-LOCATED S092 body-sha256-mismatch`, `QUOTE_LOCATE: FAIL located=4 rows=5`, rc=1.
- The gate detects uncoordinated tampering. It does not detect a tampered body whose capture row is rewritten by the same generator; the row is lane-authored, so the gate's sha binding is only as independent as that generator. The lesson's ceiling (`plans/round-38.md:62`: "checks committed bytes against committed captures") does not name this path.
- Verdict: **OVERSTATED** (the capability cell and QM39 state stronger detection than the measured design gives).

### F7 — C1 labelled "freshness" — OVERSTATED (axis label)
- `plans/round-38.md:38–46` and `SCORECARD.md:1461`: "C1 freshness".
- AXES.md:14: "**freshness** | Drift detection — skill claims re-verified against live surfaces; stale items flagged or fixed | Each round LOG entry includes a re-verification result".
- The counter reads committed bytes only (`corpus/quote-locate.py` docstring: "it does not re-fetch a live page"; `plans/round-38.md:62`).
- Live check I ran (read-only, 2026-11-05 ~ same day): `curl -fsSL --compressed https://github.com/hashicorp/vault/releases/tag/v2.2.1` → HTTP 200, decoded 161,255 bytes, sha256 `3b02c7ef…`; title `<title>Release v2.2.1 · hashicorp/vault · GitHub</title>` present (1 match); `datetime="2026-10-22T21:59:36Z"` present (1 match). OpenBao `…/v2.7.2` → HTTP 200, 192,516 bytes, sha256 `0f5164ef…`, title present, `datetime="2026-10-26T20:24:37Z"` present (1 match).
- Capture rows: S092 161,306 bytes, sha256 `1e034616…`; S093 192,563 bytes, sha256 `a69db256…`. The quoted title and datetime reproduce live; the body digest does not (the registry's own profile label is `decoded-http-body-volatile-v1`, which the freshness wording does not surface).
- Verdict: the quote and datetime facts are SUPPORTED live; the axis label is **OVERSTATED** — C1 is a provenance-binding counter over stored snapshots, which AXES.md does not define as freshness.

### F8 — C2 labelled "calibration"; SCORECARD says the round-37 description is "corrected" — FALSIFIED (relabel) / OVERSTATED
- `plans/round-38.md:80–82` (calibration reading): "The measured move is that a committed guard now exists, and a self-description that names it can be checked against it. The claim is not an assertion: the counter fails on the do-nothing control."
- AXES.md:13: "**operability** | Runnable artifacts: checklists that are executable, commands that exist, scripts that run | A checklist item can be run and produces the stated outcome".
- AXES.md:15: "**calibration** | Self-assessment quality: gaps named honestly, confidence graded, overreach caught | SHONEN.md/SCORECARD entries match observed repo state".
- The C2 counter (`plans/round-38-c2.sh` → `laneguard.sh --selftest`) reads planted fixture writes only. It never reads a SCORECARD, LOG, lesson or SHONEN line. Test: the round-37 lesson is unchanged at `b944735` on the false sentence — `corpus/lessons/round-37.md:58`: "the battery prints `LANE-GUARD` comparing the lane's tracked status and `master` before and after" — and `git grep -n LANE-GUARD -- ':!.ufo/waves'` still shows no committed script that prints it (only text: LOG.md, SCORECARD.md, corpus/QUALITY.md, corpus/lessons/round-37-verifier-spotcheck.md, corpus/lessons/round-37.md, corpus/lessons/round-38.md, plans/round-38.md). The counter would read 3 with that false sentence still in place.
- SCORECARD.md:1462: "The round-37 lesson's `LANE-GUARD` description is **corrected** by the M38-2 row". The round-37 line is not corrected in place; the only pointer is appended at `corpus/lessons/round-37.md:75` ("Round 38 answers … M37-2 (C2)") and in the round-38 lesson.
- The laneguard script is not wired into any battery (`grep -rln laneguard` at `b944735` lists `plans/round-38-c2.sh` and `plans/round-38-controls.sh` only, plus SKILL/LOG/QUALITY text), and `corpus/lessons/round-38.md:110` says seat dispatch does not run through it.
- Verdict: the C2 **calibration** reading is **FALSIFIED** — the counter measures an operability artifact (a runnable guard that detects planted writes), and the calibration signal the AXES definition names is not measured. The SCORECARD "corrected" is **OVERSTATED** (pointer, not correction). The operability reading of C2 is SUPPORTED.

### F9 — M38-2 `git grep` output — OVERSTATED
- `corpus/lessons/round-38.md:66`: "`git grep -l LANE-GUARD -- ':!.ufo/waves'` → `corpus/lessons/round-37-verifier-spotcheck.md`, `corpus/lessons/round-37.md`, `plans/round-38.md`: text only".
- Command at `b944735`: `git grep -l LANE-GUARD -- ':!.ufo/waves'` →
  `LOG.md`, `SCORECARD.md`, `corpus/QUALITY.md`, `corpus/lessons/round-37-verifier-spotcheck.md`, `corpus/lessons/round-37.md`, `corpus/lessons/round-38.md`, `plans/round-38.md` (seven files, rc=0).
- "text only, no script prints it" — SUPPORTED (none of the seven is a `.sh` or `.py`).
- Verdict: the quoted list is **OVERSTATED** (stale output presented as the current command result).

### F10 — M38-1 pointers and the R37-V1 "correction" — SUPPORTED (with a caveat)
- `git cat-file -t e2030d2799cf46e77dcfef0369d79d8da4130e05` → `commit`, rc=0. `git cat-file -t e2030d2794` → `fatal: Not a valid object name e2030d2794`.
- `grep -c 'e2030d2794' corpus/lessons/round-37.md` → 1 (line 5). Fleet `/home/vgpnk/Projects/shokunin/.ufo/reports/round-37/kagi.md` line 31 contains `e2030d2794…` (count 1).
- Caveat: LOG.md:1737 says R37-V1 is "corrected in the round-38 lesson". The defect sites (round-37.md:5, report:31) carry no pointer; the candidate's only edit to `round-37.md` is the R37-V5 line at :75. "Corrected" should read "recorded".

### F11 — ledger migrations described as complete; three ledger rows turned red; R38-03 POLICY — OVERSTATED (undisclosed regression)
- `corpus/lessons/round-38.md:81`: "The four pinned count rows migrated (old→new in `.ufo/waves/round-38/expectation-migrations.json`); the claim-row count `R21-04` migrated 82 → 86." LOG.md:1735 and SCORECARD.md:1465 repeat the migration claim.
- `expectation-migrations.json` lists five migrations: R21-02, R31-02, R33-02, R34-03, R21-04. Nothing else.
- Differential `bash corpus/claim-ledger.sh verify` (same extraction method for both; full summaries; outputs in `receipts/ledger-base.txt`, `receipts/ledger-cand.txt`):
  - base: `CLAIM_LEDGER: POLICY (claims=82 policy=2 stamped=112)`; cand: `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`.
  - R12-03 `grep -c '[^[:space:]]' corpus/stamps.tsv` (expect `^112$`): base PASS; cand prints `122` → **FAIL** (`verdict-not-final exit=0`). Direct re-run at cand: `122`.
  - R24-05 `bash corpus/row-identity.sh stamps` (expect `count=112 sha256=84fb4a48…`): base PASS (`count=112`); cand `ROW_IDENTITY: stamps count=122 sha256=3586872e…` → **FAIL**.
  - R24-14 `bash corpus/row-identity.sh ledger-ids` (expect `count=82 sha256=bf834978…`): base `ROW_IDENTITY: ledger-ids count=82 sha256=bf834978…` PASS; cand `count=86 sha256=3728b4c4…` → **FAIL**.
  - R38-03 `python3 -I -B corpus/quote-locate.py`: cand `POLICY R38-03 reason=python-script` (not PASS). SCORECARD.md:709 cites "(ledger `R38-03`)" as the gate's evidence.
  - R36-01 (`plans/round-36-c1.sh`, expect `^0$`): base FAIL (prints 3); cand PASS (fixed by this round).
  - Net FAIL rows: base 7 (R11-08, R13-01, R22-03, R24-06, R24-15, R25-02, R36-01) → cand 9 (R11-08, R12-03, R13-01, R22-03, R24-05, R24-06, R24-14, R24-15, R25-02). The three new FAILs are reproduced by direct command, so they do not depend on the extraction environment.
- Neither the lesson, LOG, SCORECARD nor `expectation-migrations.json` names R12-03, R24-05, R24-14 or R38-03. The SCORECARD `lane-status:` line still names three reds (R25-02, R29-01, R29-02).
- Verdict: the migration sentence is **OVERSTATED** (incomplete record; three rows that passed at BASE fail at the candidate). AXES.md:9 ("A round is admitted only if every claim verifies **and no axis is harmed**") makes a regression in the ledger (the calibration gate, per `corpus/claim-ledger.sh` header) a disclosure item.

### F12 — "scores stay 9 → 9" and capability rows — SUPPORTED (with F11 and F6 attached)
- `SCORECARD.md:1457`: "Scores stay 9 → 9: a claim move adds no new score, and the capability rows enter the main table in this round."
- All six axes 9 at BASE (SCORECARD.md:1442–1452 table) and 9 at the post-move table (1459–1466). Saturation line 9 (SCORECARD.md "## Saturation"). Consistent with the AXES.md saturation/capability rules.
- Capability rows: AXES.md §Capabilities requires "a passing demonstration in the round report". Demonstrations exist in this round: `quote-locate.py` CLEAN 5; `laneguard.sh --selftest` detected=3; control reads 4/4/4 and 0/0. The rows are admissible under the rule. Their wording is the issue (F6), and the F11 ledger regression is not reflected in any row.

### F13 — C2 selftest hygiene (kill rule: no repository other than fixtures) — SUPPORTED
- `git clone --shared` of `b944735` into scratch; `git status --porcelain` + `HEAD` captured before and after `LANEGUARD_SCRATCH=<scratch> bash corpus/laneguard.sh --selftest`: `cmp` clean; selftest printed `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`, rc=0; scratch residue 0.

### F14 — SCORECARD "Wave settlement" pointer — FALSIFIED
- `SCORECARD.md:1466` (adjacency row): "Connector sweep: see the round-38 lesson's Wave settlement."
- `grep -n 'Wave settlement' corpus/lessons/round-38.md` → no match. The only "Wave settlement" section is `corpus/lessons/round-37.md:77`. The round-38 lesson contains no connector sweep text.
- Verdict: **FALSIFIED** (dead pointer; the adjacency row's only evidence for the sweep is missing).

### F15 — R37-V2 disposition: "answered" — OVERSTATED
- Closure `corpus/lessons/round-37-verifier-spotcheck.md:85`: "round 38 must close it or this trend is re-graded." Plan and lesson: "not claimed and not re-pointed; the round-37 closure's 're-grade' condition is answered in the report rather than by a table edit" (`corpus/lessons/round-38.md:37`).
- `grep -n -i 're-grad\|regrad\|trend' LOG.md` in the round-38 section → no entry. SCORECARD round-38 rows do not record a quality-trend re-grade. The "report" the lesson points to is not in the candidate.
- Verdict: **OVERSTATED** — the closure's "or" branch (re-grade) is neither taken nor recorded; the condition is deferred, not answered.

## 2. Priority list (assignment a–g)

(a) C1 0 → 5 and forgeries 4 — **SUPPORTED** (`b944735` and `8c48b7d`; §F6 caveat on what the gate detects; `prefreeze-gate.txt` consistent).
(b) C2 0 → 3 and do-nothing 0 — **SUPPORTED** as counters. `--selftest --no-mutate` prints `detected=0 mutants=3 clean=ok` but exits 1 by design; the claim does not state an exit.
(c) round-36 counter "brought back to its frozen 0" — **SUPPORTED** at `b944735` (0); the premise "reads 6" — **FALSIFIED** (3, F1); "stale=3" — **FALSIFIED** (0).
(d) Mistakes rows:
  - M38-1 — SUPPORTED (F10).
  - M38-2 — the "no script prints it" part SUPPORTED; the `git grep` output list OVERSTATED (F9); "calibration" classification FALSIFIED as calibration (F8).
  - M38-3 — SUPPORTED (forgery reads 4 of 5; QM38/QM39 present in `corpus/QUALITY.md:201–202`). Ceiling on regenerated rows missing (F6).
  - M38-4 — not testable (§6). Plan at `289e808` and `b944735` is byte-identical (`git diff --quiet`), so no post-freeze drift in the plan.
(e) R37-V2 experiments — experiment 1 (S027 id only) reproduced: `CLEAN … fired=15`; experiment 2 (id and anchor `3.15.2`) reproduced: `INCONSISTENT S027`, `RELEASE_CLOCK: FAILED (… observed=29 fired=14 derived=15)`; "10 DERIVATION findings" reproduced by the all-rows re-point (F3). The general "leaves the gate CLEAN" — FALSIFIED (F3). Live-check quoted output — OVERSTATED (F4).
(f) "30 of 30 records unchanged against the pinned round-36 receipt" — **SUPPORTED**. Python over `.ufo/waves/round-36/controls/observe-live.json` (sha256 `3f611eec…`, equal to `DEFAULT_RECEIPT_SHA256`) and `.ufo/waves/round-38/controls/observe-r38.json` (30 observations each; ids equal): `parsed_version`, `verdict`, `located` equal in 30/30; additionally `clock`, `http_status`, `sha256`, `url` equal in 30/30; only `observed_at` differs (by design). All 30 records `http_status` 200; fired count 15.
(g) Routed items — disposition:
  - R37-V1 (transcribed hash) — answered by erratum (F10); "corrected" is an overstatement at the defect sites.
  - R37-V2 (release-clock re-point) — answered by measurement and deferral; the closure's "close it or re-grade" is not dispositioned (F15); the reading in F3 is FALSIFIED.
  - R37-V3 (located-quote gate) — answered by C1; ceiling does not cover rewritten capture rows (F6).
  - R37-V4 (anchor immutability; `2.2.10` boundary; M37-2 red-before) — routed to round 39 (`corpus/lessons/round-38.md:92–94`). No round-39 artifact exists; the M37-2 red-before part is answered by C2's planted writes.
  - R37-V5 (pointer in round-37 lesson) — answered: `corpus/lessons/round-37.md:75` pointer present (diff of `8c48b7d..b944735`).
  - Round-37 lesson's "Routed to round 38" bullets not in the closure: (i) "The round-37 receipt is not consumable by `release-clock.py`" (`corpus/lessons/round-37.md:109`) — **silently dropped**: not named in any round-38 file; the round-38 receipt has the same non-consumability (F4) and it is not mentioned; (ii) "The calibration hold (R36-4 reviewer conditions)" (`round-37.md:110`) — routed as unchanged (`plans/round-38.md`, "R36-4 and the calibration reviewer conditions: unchanged"), answered.

## 3. Calibration framing (AXES.md; M38-2 and C2)

AXES.md:13–15 (quoted in F8). The round's calibration claim is the M38-2 fix: a self-description ("the battery prints LANE-GUARD") that no committed script backs. The lane's own QM38 (`corpus/QUALITY.md:201`) says such a defect "fails the round's calibration until a committed instrument with a red witness … exists". That rule is the lane's, and it is what the round relies on. Measured against AXES.md's own calibration definition (SCORECARD/SHONEN entries match observed state), the instrument fixes an operability gap (no runnable guard), and the defective self-description remains uncorrected at `corpus/lessons/round-37.md:58`. The calibration reading is therefore a relabel of an operability move; the correct statement would be "operability: committed guard; calibration: round-37 line still false, pointer only".

## 4. Scores and capability rows against SCORECARD's own rules

- Scores 9 → 9 (SCORECARD.md:1457): consistent with "## Saturation" (line 9, window N=3) and with AXES.md "Working the axes". No score moved; the rows say so.
- Capability rows (SCORECARD.md:708–709): both demonstrated in the round (§F12). Wording of the located-quote row overstates (F6). "The latest first-working round in this table is 38" — SUPPORTED.
- The round's calibration row (SCORECARD.md:1462) cites `(ledger R38-03)` and the migration record; the ledger now reports R38-03 as POLICY and three prior rows FAIL (F11). Under AXES.md "no axis is harmed", the round's report should state this; it does not.

## 5. Scratch, installs, lane discipline

- Scratch root: `/fast/scratch/hyaku/kagi-r38/K38CriticClaims/` (extractions of `b944735`, `8c48b7d`, `289e808`, `a916f4a`; a clone; expA/expB/expC/regen fixtures; `tmp/`). Receipts copied to `.ufo/waves/round-38/build/K38CriticClaims/receipts/` before deletion; scratch deleted at the end of this seat.
- Installs: none (no pacman, uv, npm or cargo operations; none needed).
- Lane writes: none. Lane `git` used read-only (`grep`, `cat-file`, `rev-parse`, `status`, `archive`/`clone --shared` into scratch). The lane's untracked round-38 wave dispatch files were not touched.
- Stray background job: a `python3` diff of two ~160 KB live bodies (bg_3770) was started and not waited for; its output is not used in any verdict.

## 6. Not tested (named)

- M38-4 "a hashline PUT … overwrote one line of `plans/round-38.md` (line 33) … No defect reached a commit": the pre-repair text is not in any commit; only the post-freeze identity (`git diff --quiet 289e808 b944735 -- plans/round-38.md`) was tested.
- Lesson "Assimilation: none" and "the eight `kagi` rows of the absent-defect register remain quarantined": the register file was not inspected.
- `corpus/lessons/round-38.md:65–67` M38-3 "round-37 closure §6 R37-V3": the closure's R37-V3 text exists (closure line 92); the §6 section number was not checked.
- Plan's "Attack seats = … 40 %" and the wave roster: not checked against the dispatch record.
- `corpus/stamps.tsv` re-pin (38 lines changed): the pinned byte values were not re-verified beyond the `revision-audit` rule. Only the R12-03/R24-05 consequence was measured.
- The full `claim-ledger.sh verify` numbers are from git-archive extractions (untracked lane files absent). Only the differential and the three directly re-run rows are used as evidence.
- Non-R38 ledger FAIL rows (R11-08, R13-01, R22-03, R24-06, R24-15, R25-02) are present at BASE too; not investigated.

## 7. Receipts (in `.ufo/waves/round-38/build/K38CriticClaims/receipts/`)

- `ledger-base.txt`, `ledger-cand.txt` — full `claim-ledger.sh verify` output, BASE and candidate extractions.
- `lb.txt`, `lc.txt` — verdict-line digests (`diff lb.txt lc.txt` shows the R12-03, R24-05, R24-14, R36-01, R38-03 changes).
- `sweep-base.txt` — `self-description-sweep.sh` at the (contaminated) BASE extraction; SD7=1 there is my own copied `laneguard.sh`, not a lane value. The clean BASE reading is 3 (F1).
- `observe-recheck.json`, `observe-rerun-cand.stdout` — my re-run of `--observe` at `b944735` (rc=1; same `RECEIPT-MISMATCH` pattern as F4).
- `live-S092-title-check.body` — decoded live body of `https://github.com/hashicorp/vault/releases/tag/v2.2.1` fetched 2026-11-05 (F7).

### F7 addendum — why the live body digest differs (measured)
- `diff` of the decoded live S092 body against the committed capture (difflib over bytes, 256 non-equal regions): the differences are per-response values — a page-level nonce (`<meta name="…-nonce" content="v2:…">`, a different UUID in each response) and a feature-flag list (e.g. `"ks_view_ui_checks","pull_requests_structural_quick_filter_updates"`). The title and datetime strings were checked by string search in both bodies (present, one match each), not by the diff. This is the "volatile" profile in the registry: the capture's sha256 is a snapshot identity and cannot be re-derived from the live URL.
