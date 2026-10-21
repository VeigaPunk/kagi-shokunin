# ScribeLog — Round 25 LOG.md entry draft

Seat: KagiR25.ScribeLog-2 (leaf, scribe). Lane production files untouched; LOG.md
is NOT edited. Paste the block below verbatim.

## Insertion point

- Target: `/home/vgpnk/Projects/shokunin/kagi-shokunin/LOG.md`, append at end of file.
- Current tail: line 1356 is the last line of the Round 24 entry
  (`the lesson records the QM8 defect and the restriction on unbound live-tree notes.`);
  file ends with a single `\n` (`tail -c1` → `\n`, 1356 lines).
- Paste sequence: one blank line, then the `## Round 25` heading below.
- Round 24 heading is at line 1229 (preceded by a blank line at 1228); match that spacing.

## Measurements behind the draft (read-only or sandbox; nothing on the lane tree)

- Base confirmed: `git rev-parse HEAD` in lane → `4587c61a348e4528717404a68912c373f3ef4d03`.
- `sed -n 46p SKILL.md` → `63 stamps + 39 claims + claim ids, round 21` (D1 wording).
- `grep -vc '^#' corpus/stamps.tsv` → 83; `grep -vc '^#' corpus/claim-ledger.tsv` → 61.
- Parsed `corpus/SOURCES.md` table (python, `recheck` column): 32 rows,
  `on-release`=28 (S005..S032), `90d`=4. Matches the plan's "28 unbound on-release clocks".
- Sandbox `/fast/scratch/kagi-r25/ScribeLog-2/lane` (clone `--no-hardlinks`, checkout BASE):
  `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home bash corpus/claim-ledger.sh verify` → exit 1;
  `FAIL R11-08 reason=exit-mismatch exit=1 want=0`;
  `CLAIM_LEDGER: FAIL (claims=61 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=0 labeled_ids=20 host_skipped=12)`.
  Output retained at `/fast/scratch/kagi-r25/ScribeLog-2/verify.txt`. Host rows skipped by default; no `--allow-host-rows`.
- Not run: `citations`, `cells`, any C1/C2/C3 tool (do not exist yet), any `op`/vault/CDP call.
- Tool installs: none. No pacman transactions.

## Draft (paste verbatim)

```markdown
## Round 25 — self-counts bound, lone-clone layout explicit, release clocks bound (2026-10-21)

Base `4587c61a348e4528717404a68912c373f3ef4d03` (round-24 admitted, closure
`CloseKagi24`). Frozen claims: `plans/round-25.md`. Lesson:
`corpus/lessons/round-25.md`.

Motivating evidence (before, measured at BASE):

- Routed D1: `SKILL.md:46` states "63 stamps + 39 claims + claim ids, round 21".
  The ledger measures `corpus/stamps.tsv` = 83 rows and
  `corpus/claim-ledger.tsv` = 61 rows (`grep -vc '^#'`). The doc's current-tense
  count has no live binding, so it drifted unseen.
- Routed D2: a lone clone (`git clone --no-hardlinks` of BASE, `env -i`,
  empty `HOME`) makes default `bash corpus/claim-ledger.sh verify` exit 1:
  `FAIL R11-08 reason=exit-mismatch exit=1 want=0`;
  `CLAIM_LEDGER: FAIL (claims=61 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=0 labeled_ids=20 host_skipped=12)`.
  The fleet-layout dependence of R11-08 is documented only in its R11-08 note.
- Freshness: `corpus/SOURCES.md` has 32 rows; 28 (S005–S032) carry
  `recheck` = `on-release` with no named release identity, so no clock can be
  observed to fire.

Claims (frozen in `plans/round-25.md`):

- C1 calibration: `corpus/self-counts.py` and `corpus/self-counts.tsv` bind each
  current-tense number in a committed doc to its live source (`rows:<path>` or
  `ledger:<ID>`); `SELF_COUNTS: CLEAN|STALE` (exit 0/1), `--selftest`. Closes D1.
  Measure: `.ufo/waves/round-25/tools/c1-measure.sh <rev>`.
- C2 operability: `corpus/claim-ledger.sh` detects the lone-clone layout and
  prints `CITATION_LAYOUT: lone-clone`; `fleet_absent=N` is counted, never
  `unresolved`; `CITATION_GATE: INCOMPLETE` exits 1, never CLEAN; `[fleet]`-tagged
  rows print `LAYOUT-SKIP` and count `layout_skipped=N`. Closes D2.
- C3 freshness: `corpus/release-clocks.tsv` binds each on-release row to a `feed`
  (official release feed opened this round as a SOURCES row) or `rendered-quote`
  clock; `corpus/release-clock.py` checks bindings offline
  (`RELEASE_CLOCK: CLEAN (on_release=N bound=N unbound=0 observed=N fired=K)`) and
  `--observe` records dated receipts. Fired rows are re-verified and recorded,
  not silently re-pinned.

Changes: `<<FILL at landing: files touched, commit>>`.

Measured outcomes (fill at landing; before values above are measured, after values are not yet measured):

- C1 `stale`: before `<<FILL>>` (SKILL.md:46 expected ≥1) → after `<<FILL>>` (expected 0); one-digit mutation exit `<<FILL>>`.
- C2 `citations`: before `unresolved=88` (plan) → after `<<FILL>>`; `verify` lone clone before `FAIL R11-08` exit 1 → after `<<FILL>>`.
- C3 `release-clock`: before `on_release=28 bound=0 unbound=28` (plan) → after `<<FILL>>`; 2026-10-21 observation receipt for every row: `<<FILL>>`.

Re-verification result (freshness duty): lone-clone `verify` at BASE →
exit 1, `FAIL R11-08` by layout, `stale=0 missing=0 unresolved_ids=0`
(sandbox `/fast/scratch/kagi-r25/ScribeLog-2`). This is the pre-round baseline,
not a pass. Post-landing `verify` in the fleet layout: `<<FILL>>`.

Limits: no tool installs; no pacman; no vault, account, handler, CDP or `op`
operation; no `--allow-host-rows`; no credential read. Host-private rows were
skipped by default and are not credited. Historical round-dated numbers stay as
written.
```

## Notes for the planner

- The draft's `<<FILL>>` markers are explicit gaps for landing, not claims; remove them when measured values arrive. Do not paste the draft with markers still present.
- The re-verification line reports the lone-clone baseline as red by design (D2), not as a drift failure; C2 changes that outcome, so the line must be rewritten after C2 lands.
- `corpus/lessons/round-25.md` does not exist yet; the Frozen-claims link is a forward reference until it lands.
