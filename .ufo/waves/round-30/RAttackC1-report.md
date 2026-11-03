# RAttackC1 — C1 attack report (round 30)

Measured at lane HEAD `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c` (plan commit; diff vs frozen
BASE `f67232c` touches only `plans/round-30.md` + `.ufo/waves/round-30/census-start.txt`, so
BASE and HEAD carry identical calibration surface). All measurements from scratch copies
(`git archive` extract + one `git clone --no-hardlinks` copy); zero writes to the lane.
Raw outputs: `.ufo/waves/round-30/final/attack-c1/{selfcounts-head-b7482b4.out,
selfcounts-base-f67232c.out, verify-archive-b7482b4.out, verify-git-b7482b4.out}`.

Tooling: none installed (system `python3` 3.14.8, system `git`, coreutils). No pacman use.

## 1. Seventh-cell hunt — FOUND: two extra stale cells, not one

`python3 corpus/self-counts.py` (archive copy, read-only): **8 STALE at HEAD and 8 STALE at
BASE** (`SELF_COUNTS: POLICY (claims=62 stale=8 unlocated=0 ambiguous=0 policy=2 setup=1)`,
exit 2). The plan's START receipt ("six STALE cells") is a **miscount at both revisions**.

Beyond the routed six (SC-SKILL-STAMPS, SC-SKILL-CLAIMS, PV-STAMPS, PV-CLAIMS, RD-STAMPS,
RD-LEDGER-ROWS), the stale cells are both children of `ledger:R14-01`:

| binding | doc cell (README.md:67) | live (`bash corpus/claim-ledger.sh docs`) |
|---|---|---|
| RD-DOCS-ROWLINKED | claimed=22 row-linked | live=23 |
| RD-DOCS-ENTRIES | claimed=25 pinned | live=26 (entries) |

`README.md:67` is the only current-tense row-linked/pinned doc line (grep-scanned SKILL.md,
PROVINCE.md, corpus/README.md — no other unbound mentions). Cause is round-29 bookkeeping
(`corpus/knowledge/feed-token-boundaries.md` declares a Reverify row): identical class to the
routed six, but not in the frozen six-cell correction set. **The frozen C1 counting command
(`stale=0`) is unreachable while only six doc cells are routed.**

Sibling defect of the same family (ledger side, not a doc cell): **R25-02** pins
`^SELF_COUNTS: CLEAN \(claims=60 stale=0\)$` but the binder population is **claims=62**
(round 29 added `PV-FEEDTOKEN-SHAPES`/`PV-FEEDTOKEN-SELFTEST` bindings; self-counts.tsv has
62 data rows, verified). Even after all 12 planned migrations + all EIGHT doc-cell
corrections + C2's CRLF repair, the last line reads `SELF_COUNTS: CLEAN (claims=62 stale=0)`
→ R25-02 fails `verdict-not-final` until its recorded value moves 60→62.

Independently re-derived bindings (my own commands, not the binder's): stamps=94, claim rows=67,
round headings=35, surface-census rows=35, state-shape rows=22, drift-baseline files=15,
drift-symbols=20 — all match the binder's live values; ledger-backed OK bindings (170, 61, 70,
48, 116, 22, 14, 34, 16, 16, 4, pins 36/16/18/15) corroborated by the verify run and draft
receipts. No other mismatch found; `unlocated=0 ambiguous=0`.

## 2. FAIL-set diff vs the plan's enumerated 12 rows

Canonical run: full `bash corpus/claim-ledger.sh verify` in the **git-ful clone** (2m34s):
**FAIL ×13, POLICY ×2, verdict `CLAIM_LEDGER: POLICY (claims=67 policy=2 stamped=94)`** —
same shape as the plan's BASE control (13 FAIL + 2 POLICY).

- All 12 enumerated rows present: R12-03, R13-01, R14-01, R21-02, R21-04, R22-03, R24-05,
  R24-06, R24-14, R24-15 FAIL on value drift; R29-01/R29-02 POLICY `first-token:python`. ✓
- Out-of-scope FAIL rows (3), classification required:
  1. **R11-08** (citations, exit=1) — classified by the plan (integration triage; lone-clone
     explicitly not a defect per row bounds; committed BASE receipt BROKEN unresolved=19 is
     the lane-state authority). Classified, not absorbed.
  2. **R15-05** (exit=2 SETUP) — C2's CRLF cause (D5). Classified, not absorbed.
  3. **R25-02** (exit=2) — **UNCLASSIFIED anywhere in the plan. Enumeration is INCOMPLETE.**
     Not CRLF (self-counts.py is not a SETUP victim — it exits 2 on stale=8), not an
     integrator file, not one of the 12. Cause is pure committed-bookkeeping drift
     (60→62 + stale cells), i.e. exactly C1's migration class; it must either join the
     enumerated migration set (60→62, old→new recorded) or be classified as a routed
     residual — otherwise the end-state verify carries an unexplained FAIL.

Archive-copy caveat (methodology honesty): in the git-less `git archive` copy, R22-03/R24-15
report `exit-mismatch exit=2` because `revision-audit.py`/`row-identity.sh revision-added`
need git history; R25-02's exit=2 is real (stale). The git-ful clone run is canonical;
the archive run is retained as a negative control.

## 3. Migration-draft audit (.ufo/waves/round-30/final/c1/)

- **No draft changes a gate's semantics.** No draft edits `claim-ledger.sh`; the
  `PYTHON_SCRIPT_RE` blocker is documented, not silently widened. ✓
- **REJECT (form, not value): anchor loss in 9 of 12 drafts** — R14-01, R21-02, R22-03,
  R24-05, R24-06, R24-14, R24-15, R29-01, R29-02 propose `new_expect` without `^`/`$`.
  The runner matches with unanchored bash `=~` (claim-ledger.sh:621), so the committed
  `^…$` convention is a full-line pin and the drafts degrade it to a substring match.
  R21-02 is the worst case: its census verdict line has historically *gained fields*
  (`inrow_only`, `inrow_nonreproducing`), and an unanchored pin would let future field
  additions pass silently. The **values themselves are faithful**: I independently
  reproduced all eight git-free draft-observed outputs exactly (docs entries=26
  row_linked=23 by_hand=3; census rows=52 A=50 B=0 C=2 queued=1 mined=48 rejected=3
  entries_sourced=5 legacy=21 captures=52 inrow=16 inrow_only=0 inrow_nonreproducing=12;
  stamps 94/94df9364…; scorecard-rounds 35/92016a58…; ledger-ids 67/917ef251…).
  **Remedy: re-add `^…$` (R14-01: at least restore `^`; its old expect was tail-open by
  design). Value migration accepted once re-anchored.**
- **R29-01/R29-02 re-host is necessary but not sufficient — kill rule must fire.** The
  plan-prescribed token `python3 -I -B` still reads POLICY: `feed-token-agree.py` is absent
  from `PYTHON_SCRIPT_RE` (claim-ledger.sh:263) and *any* pre-script flag breaks the anchored
  pattern (the drafts' `_policy-matrix.txt` is corroborated by my own read of the policy
  code, lines 263–291). Reaching PASS requires widening `PYTHON_SCRIPT_RE` — gate code, not a
  recorded value — which the kill rule forbids as a migration. Honest end-state: re-host the
  recorded token, report both rows as not passing, C1 not claimed CLEAN on them. The drafts
  document exactly this ("plan fix INSUFFICIENT"). ✓ honest.
- Draft token `python3 -B` vs plan-prescribed `python3 -I -B`: measured equivalent verdicts;
  `-B` is load-bearing (live mode writes `corpus/__pycache__/release-clock.cpython-314.pyc`
  without it), `-I` inert here. Deviation from the frozen plan text is measured and
  recorded — acceptable; keeping `-I` would equally work and minimize plan delta.
- Draft receipts are marked PROVISIONAL (pre-C2/C3) — correct: at the measured revision,
  R21-02 moves again (rows 52→60 after C3's append), R21-04/R24-14 (67→68) and
  R22-03/R24-15 (added 31→32) move if C2's standing row R30-01 and `.gitattributes` join,
  R12-03/R24-05 move if C3-stamped files are added. Final values must be re-derived then;
  the plan mandates this and the drafts comply.

## 4. Kill-rule honesty check

- Would any proposed expectation edit silence a real defect? **The anchor drops would** —
  they convert full-line pins into substring pins and would silence future verdict-line
  drift (rejected above). Beyond that: every migrated value's underlying command exits 0
  with a CLEAN verdict at the new value (verified live by me); no *passing* row's
  expectation is touched; R14-01 additionally tightens (pins `duplicate_reasons=0`). No
  migration relaxes an anchored expectation *to hide a broken gate*; the only genuinely
  broken gates (R29-01/02 policy) are left red and documented. Kill rule honored in
  substance; violated only by the anchor-drop form.

## Verdicts (per work item)

1. **Seventh cell: FOUND ×2** (RD-DOCS-ROWLINKED 22→23, RD-DOCS-ENTRIES 25→26 on
   README.md:67) + sibling ledger pin R25-02 claims=60→62. Plan START receipt miscounts
   stale (6 vs actual 8, at BASE and HEAD alike).
2. **Enumeration INCOMPLETE**: 13th FAIL row R25-02 unclassified/unrouted; must be migrated
   (60→62) or explicitly routed. R11-08/R15-05 correctly classified elsewhere.
3. **Rejects**: anchor-drop form on 9 drafts (re-pin with `^…$`, keep values). No semantic
   gate changes proposed anywhere; R29-01/02 honestly blocked by gate code — kill rule fires
   for them.
4. **Kill rule**: honest in the drafts; the only defect-silencing edits are the dropped
   anchors.

## Residual risk / verification gaps

- R11-08's true lane-state unresolved count not re-measured (lone-clone environment;
  committed BASE receipt cited as authority); my runs corroborate exit≠0 only.
- The two self-counts POLICY bindings (PV-FEEDTOKEN-*) are unverifiable until the R29-01/02
  re-host lands (binder's ALLOWED_COMMANDS admits python3); PROVINCE.md:76 text (12 shapes /
  4 cases) matches the live gate outputs, so no ninth cell is expected.
- Scratch trees deleted after receipt copy; no lane file touched; no git/jj mutation in the
  lane (read-only `rev-parse`/`archive`/`diff`/`clone --no-hardlinks` reads only).
