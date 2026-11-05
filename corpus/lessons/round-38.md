source: S092 (Vault release tag page v2.2.1, GitHub), S093 (OpenBao release tag page v2.7.2, GitHub) — both opened 2026-11-05 with located quotes in §Gate; S089–S091 re-hashed from committed bodies in §Gate

# Round 38 — located-quote gate (C1, freshness) and lane-tree write guard (C2, operability as measured)

Frozen plan: `plans/round-38.md` at `289e8082ef80e9e14694fcf68f1296bfff26ad9d` (plan alone). Predeclaration (instruments, frozen controls, capture bodies, live re-observation receipt, START census receipts): `8c48b7df71066b969ac078205b5ed18cf5f53286`. Pre-freeze gate over the predeclaration: `PREFREEZE: CLEAN (controls=7 mismatch=0)` (`.ufo/waves/round-38/controls/prefreeze-gate.txt`). Candidate: `b94473505e6239cee0073d5be7a1c6f2ee07f564`. Claim BASE: `a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c`.

Fresh-start check: not a fresh-start round (r37 closed `verifier-spotcheck`, C2 verified, no rejection). The round-37 closure's routed items R37-V1..V5 are dispositioned in §Routed items below.

## Claims and verdicts (after the wave)

- **C1 freshness — located-quote gate over committed capture bodies, 0 → 5. REPRODUCED.** `bash plans/round-38-c1.sh` → `5`; `python3 -I -B corpus/quote-locate.py` → `QUOTE_LOCATE: CLEAN located=5 rows=5`, exit 0; BASE `a916f4a` → `0`. Frozen forgeries at the predeclaration: quote 4, bytes 4, registry 4 (`plans/round-38.controls.tsv`). Reproduced at the candidate by K38ExecQuote and K38CriticClaims, and the prefreeze gate re-ran CLEAN 7/7 (K38ExecQuote).
  - The counter binds manifest rows to committed capture rows. It does not detect a body and its capture row rewritten together (K38CriticClaims F6): that is a ceiling of the design, now stated here and in QM39.
  - Axis fit is contested by the wave's critic (F7): the counter checks stored provenance, not live drift. The axis stays `freshness` as declared; the non-author closure decides admission.
- **C2 — lane-tree write guard, 0 → 3. REPRODUCED as a runnable guard; the calibration reading is WITHDRAWN.** `bash plans/round-38-c2.sh` → `3`; `bash corpus/laneguard.sh --selftest` → `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`, exit 0; the do-nothing control `--selftest --no-mutate` → `detected=0` (exit 1 by design). K38CriticClaims F8: the counter reads planted fixture writes only and never reads a self-description, so it measures operability (AXES.md: runnable artifacts that run). The round's SCORECARD therefore records C2 as an operability move. The self-description defect it was written for (M38-2) is recorded below and in QM38; it is not claimed as a calibration move.

## Gate — new registry rows and re-opened sources

Access: `curl -fsSL --compressed` (census profile `curl-fsSL-compressed-v1`), 2026-11-05.

- **ADMIT S092** — `https://github.com/hashicorp/vault/releases/tag/v2.2.1`, opened 2026-11-05, HTTP 200, 161306 bytes, body sha256 `1e0346160e6679f1f5f4f9b6d763cd05235d422ecb1ca1231331b5d9528ba468` (`.ufo/waves/round-38/capture/S092-vault-tag.body`). Located quote at byte offset 21886: “<title>Release v2.2.1 · hashicorp/vault · GitHub</title>”. `datetime="2026-10-22T21:59:36Z"` (one match). Corroborates S089. Live re-fetch (K38ExecSources, 2026-11-05): title and datetime present (one match each); the live page digest differs from the committed one, as the `decoded-http-body-volatile-v1` profile anticipates.
- **ADMIT S093** — `https://github.com/openbao/openbao/releases/tag/v2.7.2`, opened 2026-11-05, HTTP 200, 192563 bytes, body sha256 `a69db25645f08a09bf48a0ed4c98aaf27fc8692e35651e513351496f1b0f6165`. Located quote at byte offset 21886: “<title>Release v2.7.2 · openbao/openbao · GitHub</title>”. `datetime="2026-10-26T20:24:37Z"` (one match). Corroborates S090. Live identity strings present (K38ExecSources, K38CriticClaims).
- **RE-HASHED, no row change — S089, S090, S091** (round-37 committed bodies): sha256 equals the capture rows (`3cbfdd86…`, `a54d1a53…`, `9ba8856e…`); the quotes sit at offsets 726, 729 and 1583 (`quote-locate.py` `located=5` covers all five rows). These are committed bytes, not re-fetched.
- **REFUSE (candidate) — a bare version row citing only the feed.** A tag page is a second surface for the same version; refused as the sole support for C1's quote check.
- **REFUSE (candidate) — `rendered-text-v1 locate` as the quote matcher.** Measured in this round: `locate` on a file containing the raw string `<title>Release v2.2.1 · hashicorp/vault · GitHub</title>` → `count=0`, rc=1 (K38CriticClaims F5 reproduces it); on the same title text without markup, `Release v2.2.1 · hashicorp/vault · GitHub` → `count=1`, rc=0. `locate` strips markup, so it cannot match raw Atom and tag-page bytes at a declared offset. The gate matches the declared quote byte-for-byte at the declared offset, after the body sha256 and byte count equal the capture row's.

## Routed item R37-V2 — release-clock table re-point: not re-pointed; measured

The round-37 closure asked for `corpus/release-clocks.tsv` to be re-pointed to S089–S091, or the quality trend to be re-graded. Measured here and independently by K38ScoutRelease and K38CriticClaims (scratch copies of `b944735`; the table and `corpus/release-clock.py` are unchanged from `a916f4a`):

| experiment | result |
|---|---|
| baseline | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)`, exit 0 |
| S027 feed id only (S036 → S091), anchor kept `3.15.0` | still `CLEAN`, `fired=15` (only this one row changed) |
| S027 feed id S036 → S091 and anchor `3.15.0` → `3.15.2` | `INCONSISTENT S027`; `RELEASE_CLOCK: FAILED (… observed=29 fired=14 derived=15)`, exit 1 — the clock stops firing |
| **all 15 rows** bound to S034/S035/S036/S039 re-pointed to their superseding rows, anchors kept | 10 lines `DERIVATION S013 … S026`; `RELEASE_CLOCK: FAILED (… observed=20 fired=5 derived=5)`, exit 1 |

Reading: a feed-only re-point of one row keeps the gate CLEAN, but the full re-point FAILs with 10 DERIVATION findings (the round-37 closure's count is reproduced). The anchor re-point un-fires a clock. Neither is a freshness move, so R37-V2 is **not claimed and not re-pointed**. Its closure condition ("close it or re-grade") is answered here by the quality trend verdict in the report: **unchanged**, with R37-V2 recorded as open debt.

Live observation (2026-11-05), committed as evidence: `python3 -I -B corpus/release-clock.py --observe .ufo/waves/round-38/controls/observe-r38.json` wrote `RELEASE_CLOCK_OBSERVE: wrote 30 observations (failed=0 fired=15 regressed=0)`. Compared with the pinned round-36 receipt: **30 of 30** records carry the same `parsed_version`, `verdict`, `located`, `http_status`, `sha256` and `url`; only `observed_at` differs. **The new receipt is not a usable pin:** run as `--receipt`, it gives 30 `RECEIPT-MISMATCH` lines and `RELEASE_CLOCK: FAILED`, exit 1, because the bound rows still carry `observed_at` 2026-11-04 (K38ScoutRelease; K38CriticClaims F4). That is a date-binding gap, recorded here and not re-pinned (a pin would be a new claim). The committed `observe-r38.stdout` shows the same FAILED output; the earlier version of this lesson quoted only its first line, which was selective.

## Routed item R37-V1 — transcribed freeze hash (erratum, not a rewrite)

The round-37 report and lesson cite the freeze commit as `e2030d2794…`. The commit is `e2030d2799cf46e77dcfef0369d79d8da4130e05` (round-37 closure §6, R37-V1). Recorded here: `git cat-file -t e2030d2799cf46e77dcfef0369d79d8da4130e05` → `commit` (exit 0); `git cat-file -t e2030d2794` → fatal. The filed round-37 bytes are not rewritten; the defect sites remain as they were (K38CriticClaims F10 notes that they carry no pointer, and this erratum is the pointer).

## Routed item R37-V3 — closed by C1

The closure's "located-quote gate against committed bodies" is C1 (`plans/round-38-c1.sh`, `corpus/quote-locate.py`, manifest `corpus/quote-bodies.tsv`, five rows). Its ceilings: committed bytes only; no live re-fetch; body and capture row rewritten together pass (F6); no check that a quote supports the teaching.

## Routed item R37-V4 — routed to round 39, not claimed

Anchor immutability for S034/S035/S039 (an in-place rewrite of an anchor cell reads 0 on the counter) and the `2.2.10` boundary control (mutant M5) are frozen-counter amendments; routed, not claimed.

## Routed item M37-2 — the self-description, and its committed guard

The round-37 lesson stated that `plans/round-37-controls.sh` prints a `LANE-GUARD` line that compares the lane's tracked state. `git grep -l LANE-GUARD -- ':!.ufo/waves'` at `b944735` lists seven files: `LOG.md`, `SCORECARD.md`, `corpus/QUALITY.md`, `corpus/lessons/round-37-verifier-spotcheck.md`, `corpus/lessons/round-37.md`, `corpus/lessons/round-38.md`, `plans/round-38.md`. None is a script; `plans/round-37-controls.sh` ends at `bash plans/round-37-c2.sh`. The round-37 line (`corpus/lessons/round-37.md:58`) remains uncorrected in place, by the append-only rule; this paragraph is its erratum. The committed guard is `corpus/laneguard.sh` (C2).

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M38-1 | number-drift | `/home/vgpnk/Projects/shokunin/.ufo/reports/round-37/kagi.md:31` (fleet repo) cites the freeze commit as `e2030d2794…`; `corpus/lessons/round-37.md` repeats the prefix once. The true hash is `e2030d2799cf46e77dcfef0369d79d8da4130e05`. | `none` | this lesson's erratum with the full hash; `git cat-file -t` → `commit` (exit 0). Filed bytes not rewritten. |
| M38-2 | attribution (self-description without an artifact) | `git grep -l LANE-GUARD -- ':!.ufo/waves'` (seven text files, no script). | `none` | C2: `corpus/laneguard.sh` committed; `--selftest` → `detected=3`; `--selftest --no-mutate` → `detected=0`. The fix is shown able to fail. Calibration reading withdrawn (above). |
| M38-3 | attribution (evidence checked by hand) | round-37 closure §6 R37-V3: no repo gate checks Gate quotes against bodies. Red-before: the forged quote control reads 4 located of 5 (`c1_forge_quote`). | `none` | C1: `corpus/quote-locate.py`, `corpus/quote-bodies.tsv`. Forgeries (quote, bytes, registry) each read 4. Ceiling recorded (body and capture row rewritten together pass). |
| M38-4 | landing (edit drift) | a hashline `PUT` against a stale line number overwrote one line of `plans/round-38.md` during drafting; caught by reading the range back, repaired before the plan commit. A second `PUT >` placed the SCORECARD round-38 block one line early, splitting round 37's post-move table; repaired by a named-register move (`CUT … @r37rows` / `PUT >… @r37rows`). No defect reached a commit. | `none` | read the exact range after every edit; a whole-section insertion is checked by `grep -n '^## '` before the next edit. |
| M38-5 | stale-premise (own counter reading) | SCORECARD round-38 pre-move calibration row and LOG said the round-36 counter read 6 at HEAD before any round-38 change. Measured at `a916f4a`: 3 (SD5=3, stale 0) — the 6 appeared only after this round's own claim-row edit (stale 3), before the rebinding. Found by K38ScribeLedger and K38CriticClaims F1. | `none` | the pre-move reading corrected to 3 in SCORECARD and LOG; the post-edit reading (6, then 0) recorded as the round's own sequence. |
| M38-6 | landing (ledger regression, own edits) | `bash corpus/claim-ledger.sh verify` differential (K38CriticClaims F11): R12-03, R24-05 and R24-14 passed at `a916f4a` and failed at the first candidate (stamp count 112 → 122; id count 82 → 86); R13-01 and R24-06 were already red at BASE (round-37 headings: measured 48, pinned 46). | `none` | migrated with old→new values (`.ufo/waves/round-38/expectation-migrations.json`); R13-01/R24-06 migrated as inherited reds with the cause stated. R38-03 is a new POLICY row (below). |

QM38 and QM39 (appended to `corpus/QUALITY.md`) take M38-2 and M38-3.

## Ledger disclosure

- `R38-03` (`python3 -I -B corpus/quote-locate.py`) is `POLICY` under the claim ledger: the ledger allows `python3` only for registered corpus scripts (`PYTHON_SCRIPT_RE`), which is operator-owned policy — the same class as `R29-01`/`R29-02`. It is not counted as a pass. Its verdict is also pinned through `R38-01` (the located count `5`). An L0 question asks the operator to register the script or to accept the row as routed (`.ufo/l0-questions.md`).
- `R36-01` passes at the candidate (`plans/round-36-c1.sh` → 0). `R21-04` is 86.
- Ledger at the close, measured by `bash corpus/claim-ledger.sh verify` (`CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`): FAIL `R11-08`, `R22-03`, `R24-15`, `R25-02` — all predate this round; POLICY `R29-01`, `R29-02`, `R38-03`; `MISSING-ID` 53, all pre-existing (R32/R33 ids in older lessons and the round-37 `R36-1`/`R36-2` errata), none in round-38 files. `R13-01` and `R24-06` were red at BASE and pass after migration; `R12-03`, `R24-05`, `R24-14` passed at BASE and were migrated for this round's own growth.

## Mutation survivors and instrument ceilings (K38MutInstruments, K38ReviewQuote, K38ReviewGuard)

- Mutation kill of the instruments under their frozen controls is partial: `quote-locate.py` mutants M2 (byte count), M3 (offset as substring), M5 (capture-quote equality), M6 (absolute path) survive the frozen set; `laneguard.sh` mutant G3 (drop `--untracked-files=all`) survives. With distinguishing probes, 11 of 11 are killed (K38MutInstruments). Routed to round 39 as frozen-counter amendments, with the mutants as red witnesses.
- Quote gate attacks (K38ReviewQuote, eight fixtures plus the sweep): a body path that is a symlink to a file outside the root passes CLEAN and the census also CLEAN (V2) — the committed tree has no symlink (`git ls-files -s .ufo/waves/round-37/capture .ufo/waves/round-38/capture` → all mode 100644), so C1 holds on the committed state; the confinement hole is an instrument defect, routed. An offset with a superscript digit raises an uncaught ValueError (V5; exit 1, no verdict line; counts 0, fails safe). A duplicate registry row is inert (first wins) and a duplicate capture row shadows (last wins); both are caught by the census (V1, V4). No manifest duplicate-id check (V6; cannot fake 5).
- Guard attacks (K38ReviewGuard, K38ExecGuard): transient edits reverted before the second snapshot, create-and-delete within a run, ignored-path writes, `.git/config` writes and empty directories all read CLEAN — the stated design limits (the snapshot compares HEAD, status and diffs, not the filesystem). A mode change is caught (VIOLATION). The clean path rewrites the lane's `.git/index` stat cache via unlocked `git diff` (content unchanged; `--no-optional-locks` is not applied to `diff`): routed. The documented `run LANE -- CMD` form is rejected (exit 2; the implemented form is `run -- LANE -- CMD`, R38_EG_1): the header and this round's SKILL row are corrected to the implemented form; the header line itself is in the frozen instrument and is routed.

## Corrigenda

- **Round-37 report and lesson — freeze hash prefix `e2030d2794…`** → `e2030d2799cf46e77dcfef0369d79d8da4130e05` (M38-1, R37-V1).
- **Round-37 lesson `## Mistakes` M37-2 "the battery prints LANE-GUARD"** → no committed battery prints it; the guard is `corpus/laneguard.sh` (M38-2, C2). Bytes not rewritten.
- **Round-37 lesson "quote check performed by hand"** → measured by `plans/round-38-c1.sh` (M38-3, C1).
- **This lesson's earlier draft** quoted only the first line of `observe-r38.stdout`, stated the wrong round-36 counter reading, and said that "re-pointing only the id leaves the gate CLEAN" for the whole table. All three are corrected above (M38-5, the R37-V2 table, the observation paragraph).

## Census

- Before (START, `.ufo/waves/round-38/controls/start-census-*.txt`): fleet `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → exit 0; lane `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 inrow=16 inrow_only=0 inrow_nonreproducing=12)`.
- After (candidate and close): `SOURCES_CENSUS: CLEAN (rows=93 A=89 B=2 C=2 queued=1 mined=89 rejected=3 entries_sourced=14 legacy=21 captures=93 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0; fleet census exit 0 (`kagi ok`). `entries_sourced=14` and `legacy=21` unchanged (no knowledge entry added).

## Assimilation and considerthese

- Assimilation: none. The eight `kagi` rows of the absent-defect register remain quarantined; none is appended. The register's campaign ids `S090`/`S091` collide in spelling with this lane's rows, so any future adoption runs the id-collision guard first.
- considerthese: no proposal taken this round; the round-37 plan records the 2026-10-26 proposals as implemented or discharged.

## Wave settlement (build, 10 seats)

One v1 wave `kagi-r38-build` (`.ufo/waves/round-38/build-spec.json`, `build-dispatch.json`, `build-results.json`; validator `run` rc 0, `taskCall` 10 seats). Roles: executor 3 (K38ExecQuote, K38ExecGuard, K38ExecSources), scribe 1 (K38ScribeLedger), scout 1 (K38ScoutRelease), connector 1 (K38ConnOverlap), reviewer 2 (K38ReviewQuote, K38ReviewGuard), critic 1 (K38CriticClaims), mutation-tester 1 (K38MutInstruments). Attack seats 4/10 = 40 % (≥25 %); connector 1 (≤2). Dead seats: none (all 10 returned output, no error). The planner seat stayed with the L1 (deviation recorded in the plan, as in rounds 33 and 37). Seat reports: `.ufo/waves/round-38/build/<seat>/report.md`.

Seat verdicts (from each seat's report):
- **K38ExecQuote** (executor): C1 reproduced; prefreeze gate `CLEAN (controls=7 mismatch=0)` re-run; independent sha/byte/offset recomputation agrees on S089–S093. Deviations: a self-copy refusal in a first controls batch (no measurement recorded from it) and a mistyped controls mode name; both rerun cleanly. One stray file `nil` at the fleet root was deleted immediately (verified absent).
- **K38ExecGuard** (executor): C2 reproduced (selftest 3/3, no-mutate 0, clean control CLEAN); the lane tracked state unchanged before and after; the limits list above; R38_EG_1 (documented form rejected).
- **K38ExecSources** (executor): S092/S093 registry and capture rows byte-equal to the generator; committed body sha and byte counts match; quotes at offset 21886; live identity strings present; census CLEAN rows=93 and fleet `kagi ok`.
- **K38ScribeLedger** (scribe): 25 of 33 prose cells AGREE; 1 DISAGREE (the round-36 reading 6, M38-5); migration JSON parses; all five migrated ledger rows equal their `new` values.
- **K38ScoutRelease** (scout): **PARTLY SUPPORTED** on the lesson's R37-V2 reasoning: the single-row experiment and the INCONSISTENT anchor experiment reproduce; the "leaves the gate CLEAN" general sentence does not (corrected above). Unchanged release-clock files between BASE and candidate; the observation 30/30 comparison reproduces; the live feeds' versions (2.2.1, 2.7.2, 3.15.2) are strictly newer than the pinned anchors and the clocks stay pinned as designed.
- **K38ConnOverlap** (connector): **NO OVERLAP** on the claimed ground. Adjacent only: sibling-local located-quote gates (chousa `c3-count.py`, kengaku `sources_adopt.py`, kotoba `locate_quote`), a lane-guard term in tameshi `QUALITY.md:176`, souji's token-shape label on `release-clock.py`, and five siblings routing Vault/secrets questions to kagi. Nothing absorbed or edited.
- **K38ReviewQuote** (reviewer): C1 holds on the committed state; defects V1, V2, V5 (above) and minor V3, V4, V6; the census catches V1, V3, V4 and does not catch V2.
- **K38ReviewGuard** (reviewer): **C2 HOLDS** against its attacks; escapes are the stated limits; the index stat refresh (above).
- **K38CriticClaims** (critic): **C1 and C2 reproduce on their frozen predicates**; falsified and overstated sentences F1, F3, F14, F8 and F4–F7, F9, F11, F15, all addressed in this lesson, the SCORECARD and the LOG; F10 (R37-V1 "corrected" → "recorded") addressed.
- **K38MutInstruments** (mutation-tester): both claims reproduce; kill rates above; survivors routed.

## Routed to round 39 (not claimed)

- R37-V4: anchor-immutability check; `2.2.10` boundary control (frozen-counter amendment).
- Frozen-counter amendments from the wave's red witnesses: the symlink and out-of-root body confinement (V2); the superscript-digit traceback and a no-verdict exit (V5); duplicate registry and capture ids (V1, V4) and a manifest duplicate-id check (V6); the four surviving quote mutants (M2, M3, M5, M6) and the surviving guard mutant (G3); the guard's `run` usage line and `git diff` locking (R38_EG_1; index stat refresh).
- The quote gate covers the five manifest rows; the 21 legacy in-row pins are outside it.
- Operator: register `corpus/quote-locate.py` in the ledger's allowlist or accept `R38-03` as routed (L0 question).
- Seat dispatch does not yet run through `laneguard.sh` automatically; the L1 runs it on any lane write it wants to attest.

## Non-author spot-check

Pending outside closure. This lesson's Gate, the wave's verdicts and the corrections above are lane-authored and seat-authored; dispatched seats are lane evidence, not outside agreement (LEARNING.md discernment rule). The round-37 closure's pointer is at `corpus/lessons/round-37.md` §Non-author spot-check.
