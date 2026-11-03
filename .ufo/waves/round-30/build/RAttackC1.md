# RAttackC1 — scoped findings (C1 attack, round 30)

HEAD measured `b7482b4`; BASE `f67232c` is calibration-identical (plan commit touched only
plan files). Full evidence + receipts: `.ufo/waves/round-30/RAttackC1-report.md` and
`.ufo/waves/round-30/final/attack-c1/`. Scratch-only execution; lane untouched; no installs.

## F1 (MAJOR) — Seventh-cell hunt: two stale doc cells beyond the routed six
`self-counts.py` prints **stale=8 at BASE and at HEAD**; the plan's START receipt says six —
miscount. The extras, both bound to `ledger:R14-01`'s live docs verdict:
- `RD-DOCS-ROWLINKED` README.md:67 claimed=22 → live=23
- `RD-DOCS-ENTRIES` README.md:67 claimed=25 → live=26
Round-29 cause (`feed-token-boundaries.md` Reverify row), same class as the routed six, but
absent from the frozen correction set → frozen counting command (`stale=0`) unreachable as
scoped. README.md:67 must move to `23 row-linked / 3 by-hand / 26 pinned`.

## F2 (MAJOR) — Enumeration incomplete: R25-02 is an unclassified 13th FAIL row
Git-ful verify at HEAD: FAIL ×13 + POLICY ×2 (`CLAIM_LEDGER: POLICY`, claims=67 policy=2
stamped=94). The 12 enumerated rows are all present. The FAIL set minus the 12 = R11-08
(classified: integration triage) + R15-05 (classified: C2 CRLF) + **R25-02 — no route, no
classification**. R25-02 pins `SELF_COUNTS: CLEAN (claims=60 stale=0)`; live population is
claims=62 (round 29 added two self-counts bindings). Pure recorded-value drift (C1's own
class): migrate 60→62 with old→new record, or route it explicitly — else end-state verify
keeps an unexplained FAIL even after every planned fix (stale=0, setup=0, policy=0 → last
line `CLEAN (claims=62 stale=0)` ≠ pinned claims=60).

## F3 (MAJOR, bounded) — R29-01/R29-02: prescribed re-host cannot reach PASS
`PYTHON_SCRIPT_RE` (claim-ledger.sh:263) does not admit `feed-token-agree.py`, and ANY
pre-script flag breaks its anchored pattern — so the plan's `python3 -I -B` token reads
POLICY `python-script` exactly like the status quo (`first-token:python`). PASS requires
widening gate code, which the kill rule forbids as a migration → the frozen counting command
("each of the twelve enumerated rows re-run individually must pass") is unsatisfiable for
these two rows; kill rule fires; report honestly, C1 not CLEAN on them. The drafts document
this correctly ("plan fix INSUFFICIENT"). Draft token `python3 -B` (−`-I`) is measured
equivalent; `-B` is load-bearing (pycache write without it), deviation from plan text is
recorded — acceptable.

## F4 (MINOR, reject form) — Anchor loss in 9 of 12 drafted expects
R14-01, R21-02, R22-03, R24-05, R24-06, R24-14, R24-15, R29-01, R29-02 drop `^`/`$` in
`new_expect`. Runner is unanchored bash `=~` (claim-ledger.sh:621): committed `^…$` rows are
full-line pins; the drafts degrade to substring pins. R21-02's verdict line historically
gains fields (`inrow_only`, `inrow_nonreproducing`) — an unanchored pin would silence future
field-drift, i.e. a real-defect silencer under item 4's test. **Reject the form, keep the
values**: all eight git-free draft-observed outputs independently reproduced exactly
(docs 26/23/3; census rows=52 A=50 B=0 C=2 queued=1 mined=48 rejected=3 entries_sourced=5
legacy=21 captures=52 inrow=16 inrow_only=0 inrow_nonreproducing=12; stamps 94/94df9364…;
scorecard 35/92016a58…; ledger-ids 67/917ef251…). Re-add `^…$` (R14-01: restore at least
`^`; old expect tail-open by design).

## F5 (MINOR) — Plan-receipt accuracy
START receipt "six STALE cells" is wrong at both revisions (8). Control-receipt correction
should be appended per the plan's own corrections rule; the routed-six list itself is
otherwise accurate (all six confirmed stale in the claimed direction).

## Kill-rule check (item 4)
No draft edit masks a broken gate: every migrated value's command exits 0 CLEAN at the new
value (live-verified); no passing row touched; R14-01 tightens (adds `duplicate_reasons=0`).
Only defect-silencers = F4's dropped anchors (rejected). PROVISIONAL draft values correctly
marked for re-measurement at the measured revision (post-C2/C3 movers: R21-02 rows 52→60;
R21-04/R24-14 67→68 and R22-03/R24-15 added 31→32 if R30-01/.gitattributes join;
R12-03/R24-05 stamps if C3 files stamped).

Residual: R11-08 lane-state unresolved count cited from the committed BASE receipt (lone
clone here); PV-FEEDTOKEN bindings unverifiable until re-host lands (PROVINCE.md:76 text
12 shapes / 4 cases already matches live outputs — no ninth cell expected).
