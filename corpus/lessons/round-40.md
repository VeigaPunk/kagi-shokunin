source: S095 (docs.python.org/3/library/re.html, opened 2026-11-05); S096 (docs.python.org/3/library/html.html, opened 2026-11-05); the instruments' committed bytes are the evidence for the rest

# Round 40 — ledger debt migration (C1, calibration), python-currency routed debt (C2, freshness), gate-registry conformance (C3, operability)

Frozen plan: `plans/round-40.md` (plan alone; committed after the pre-freeze gate). Predeclaration:
counters, gate `--selftest` amendments, controls, S036 pin, S095/S096 capture bodies, measured BASE
receipts. Claim BASE: `6cc8850dfc5757927699e5a53a876f47c8df21aa`. Fresh-start round (operator
"Authorize all", 2026-11-05); the rejection-history reads (rounds 38, 36, 34 spot-checks) are
dispositioned in the plan's §Read before freezing.

## Claims

- **C1 calibration** — `bash plans/round-40-c1.sh` 6 → 0: the six routed debt rows
  (R13-01, R21-02, R24-06, R31-02, R33-02, R34-03) migrate round-38-style to the values the
  committed tree re-derives, with old→new records in `.ufo/waves/round-40/expectation-migrations.json`.
- **C2 freshness** — `bash plans/round-40-c2.sh` 0 → 3: S036 anchor pinned (M39-7); S095/S096
  documentation refresh rows (M39-routed S040/S041 refresh; new rows, no in-place edit).
- **C3 operability** — `bash plans/round-40-c3.sh` 0 → 2: both round-39 gates registered in
  SKILL.md's gate registry and carrying committed `--selftest` modes (8 cases each), clearing
  spot-check routed items 1 and 2.

## Gate

- **ADMIT S095** — `https://docs.python.org/3/library/re.html`, tier A docs. Access: fetched
  2026-11-05 with `curl -fsSL`; served `<title>re — Regular expression operations &#8212; Python
  3.15.2 documentation</title>`; capture `.ufo/waves/round-40/capture/S095.body` (257722 bytes,
  sha256 `ef2d8abe…bf469b1`). Located quote (8 whitespace tokens ≤ 25): “Matches Unicode
  whitespace characters (as defined by” at raw body byte offset 75897. The teaching that grounds
  C2's refresh: the backslash-s entry's Unicode-whitespace declaration is the basis of
  `corpus/rendered-text-v1.py`'s whitespace class, and it is unchanged on 3.15.2.
- **ADMIT S096** — `https://docs.python.org/3/library/html.html`, tier A docs. Access: fetched
  2026-11-05 with `curl -fsSL`; served `<title>html — HyperText Markup Language support
  &#8212; Python 3.15.2 documentation</title>`; capture `.ufo/waves/round-40/capture/S096.body`
  (20100 bytes, sha256 `570d72c3…d3fbab5`). Located quote (11 whitespace tokens ≤ 25): “This
  function uses the rules defined by the HTML 5 standard” at raw body byte offset 13521. The
  teaching grounds `rendered-text-v1.py`'s entity-step class; unchanged on 3.15.2.
- **Not appended:** nothing was refused this round; the eight `kagi` rows of the absent-defect
  register remain quarantined (assimilation: none).
- **QM42 applied to both new rows** (see Mistakes M40-1): each teaches cell separates the
  verbatim quote (marked “Quote (verbatim)”) from the derived clause (marked “Derivation
  (paraphrase, outside the quote)”), unlike the S094 cell that mixed them.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M40-1 | row-precision (a registry teaches cell mixed the verbatim quote with a derived clause; a word count was stated wrong) | `corpus/lessons/round-39-verifier-spotcheck.md` routed item 4: the S094 teaches cell appends “an in-place anchor rewrite violates this rule”, which appears nowhere in CORPUS.md; the round-39 lesson's Gate said “9 words” where the whitespace count is 8. S094's row is append-only and is NOT edited; the erratum stands here. | `none` (no criterion separated quote from derived clause) | QM42 in `corpus/QUALITY.md`; applied to S095/S096 (verbatim marked, paraphrase marked); shown able to fail: the census's quote-locating counter (`plans/round-40-c2.sh` items 2–3) locates the verbatim segment only — a teaches cell whose quoted segment does not locate in the committed body cannot satisfy the item (red witness `c2_forge_rows` → 1). |
| M40-2 | measurement-premise (a declared BASE population was never measured before the freeze — the round-33 class) | `corpus/lessons/round-33-verifier-spotcheck.md`: the declared BASE `captures=101` was never measured; the trees measured 72 → 82 (M33-3). | `round-33-verifier-spotcheck.md` (M33-3) | every BASE population measured and committed in the predeclaration before the freeze: `c1` 6 (`.ufo/waves/round-40/controls/base-verify-at-tip.txt`), `c2` 0 without the pin / 1 with (`c2-nowork.txt`, `c2-at-predec.txt`), `c3` 0 (`c3-base.txt`); the pre-freeze gate re-derived them on the predeclaration extraction (`prefreeze-gate.txt`, CLEAN). |
| M40-3 | instrument amendment (a frozen counter carried a doubled verdict token and could never read its target) | `plans/round-40-c3.sh` as frozen in the predeclaration checked for `ANCHOR_PINS_SELFTEST_SELFTEST: PASS…` (the token already contained `_SELFTEST`), so the counter read 0 at any tree — the candidate battery receipt `.ufo/waves/round-40/build/candidate-fast-gates.txt` shows `C3 0` with both registry rows present and both selftests passing. | `none` (no control exercised a post-work tree before data) | fixed BEFORE any claim scoring (no wave seat had been dispatched; the BASE receipt is byte-identical under both versions because 0 is 0), and proven score-neutral on the predeclaration extraction: all four c3 controls read their frozen expectations with the fixed bytes (`.ufo/waves/round-40/controls/c3-fix-score-neutral.txt`). The claim's predicate sentence is unchanged; only the verdict-token arithmetic was repaired. |
