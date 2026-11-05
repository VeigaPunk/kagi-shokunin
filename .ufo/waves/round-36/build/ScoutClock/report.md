# ScoutClock — report

Seat: ScoutClock (scout). Lane: `kagi-shokunin`, round 36 attempt 2.
Scope: reconnaissance of the C2 reading and the F3/F4 edit.

Deliverables (this directory):

- `recon.md` — the full findings, quoted constraints, per-row proposal, trap
  arithmetic, and the stale round-26 citation list.
- `proposal.tsv` — the per-row proposal, measured over committed BASE bytes.
- `report.md` — this file.

---

## Verdict

**The C2 mechanism and the proposed values are sound. Two classes of finding
remain open for the L1, both about the landing rather than about the claim.**

1. **A stale prose citation of the old default receipt** in `SKILL.md:48`,
   `SKILL.md:787` and `PROVINCE.md:75` (all three still say "the pinned
   round-26 rearmed receipt" after F4 repoints the default to the round-36
   receipt). No counter reads these lines, so they will not fail a gate —
   they are honest-reporting findings, and they are the exact class QM21
   names.
2. **Five committed ledger expectations no longer match their live source**
   because the landing itself moved the quantities they pin: R13-01
   (44 → 46 round headings), R21-04 (79 → 82 claim rows), R24-06 and
   R24-14 (the identity digests over those two sets), and R25-04
   (`fired=3` → `fired=15`). Measured `claim-ledger.sh verify` printed
   `FAIL` for exactly those five, on top of the four FAILs already present
   at BASE (R11-08, R22-03, R24-15, R25-02 — pre-existing, unrelated).
   Each needs an explicit old→new migration record per QM14.

Neither finding changes the C2 claim. Both are within the L1's integration
scope and neither is visible to the C1/C2 counters.

## Numbers

Measured over committed BASE bytes (`git archive HEAD`, HEAD `09f27e2`) and
over the working tree at the landing revision.

| quantity | BASE | landing |
|---|---|---|
| `bash plans/round-36-c1.sh` | 4 | **0** |
| `bash plans/round-36-c2.sh` | 15 | **0** |
| `bash plans/round-36-c3.sh` | — (script is new) | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` |
| `python3 -I -B corpus/release-clock.py` | CLEAN, fired=3 derived=15 | CLEAN, **fired=15 derived=15** |
| `bash corpus/sources-census.sh` | CLEAN rows=88 | CLEAN rows=88 |
| sweep SD5 / SD6 | 3 / 5 | **0 / 5** (SD6 preserved — C1 kill rule satisfied) |
| `claim-ledger.sh verify` FAIL rows | R11-08, R22-03, R24-15, R25-02 | + R13-01, R21-04, R24-06, R24-14, R25-04 |

The C2 population arithmetic:

- 20 `clock=feed` rows; **15** disagree with the receipt at BASE
  (S012–S016, S021–S028, S040, S041), **5** do not (S008–S011, S029).
- 12 of the 15 change verdict `not-fired → fired`; 3 keep `fired`
  (S012, S027, S028). Matches the frozen plan's prose.
- All **30** bound rows must be re-dated `2026-10-21 → 2026-11-04`, because
  `receipt_matches` compares `observed_at` on every bound row. The C2
  counter's population is unchanged by the fifteen extra re-dates.

The receipt's digest was confirmed against the frozen plan:
`sha256sum .ufo/waves/round-36/controls/observe-live.json` =
`3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`.
The round-26 receipt remains byte-identical at
`13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`
(not rewritten, not deleted).

## The three findings that carried the most weight

**1. The C2 counter reading 0 does not imply the gate is CLEAN.** In an
isolated fixture I applied the F3 edit to *only* the fifteen drifting rows
plus the F4 code change. `plans/round-36-c2.sh` printed **0** — the
target — while `corpus/release-clock.py` printed `RECEIPT-MISMATCH` for
fifteen rows and `RELEASE_CLOCK: FAILED (observed=15 …)`. The counter
compares only `parsed_version` and `verdict` on `clock=feed` rows; the
operability kill rule is a separate check, and it is the one that forces the
thirty-row re-date. The plan's §Fix prose names only the fifteen drifting
rows; the landing has to do thirty. The L1's working tree does thirty, and
`corpus/lessons/round-36.md` §Migrations records this explicitly.

**2. Rewriting a `corpus/SOURCES.md` anchor cell breaks the derived binding.**
`derived_anchor_bound` pins a derived anchor to exactly the one strict
X.Y.Z token in the *feed row's* anchor cell. I measured two traps in
isolated fixtures: editing S034's anchor cell to `v2.2.1` produced
`DERIVATION` for S013, S022, S023, S024; editing S040's own anchor cell to
`Python 3.15.2` produced `INCONSISTENT` for S040 and S041. The working
tree currently has **no** `corpus/SOURCES.md` diff, which is the correct
state — and the L1's own lesson M36-3 records that an in-round registry
edit was reverted for exactly this class of error.

**3. The `derived:` note prefix is load-bearing.** `is_derived` is
`values["note"].startswith("derived:")` — the first characters of the cell.
The receipt citation must therefore be **appended** to a derived row's note,
never prepended. The proposed note texts in `proposal.tsv` are written to
that rule.

## The answer to "which rows trip REGRESSED / DERIVATION / INCONSISTENT"

**None**, with the proposed values and the anchor cells untouched. The
arithmetic that shows it, per feed:

| feed | floor (highest numeric anchor) | new observation | verdict |
|---|---|---|---|
| Vault | 2.2.0 (S012's `v1.21.x` is non-numeric, contributes nothing) | 2.2.1 | above floor; ≠ anchor ⇒ `fired` valid |
| OpenBao | 2.7.1 | 2.7.2 | above floor; ≠ anchor ⇒ `fired` valid |
| Python | **3.15.1** (S040/S041, not 3.15.0) | 3.15.2 | above floor; ≠ anchor ⇒ `fired` valid |
| SOPS | 3.13.3 | 3.13.3 unchanged | == anchor ⇒ `not-fired` valid; equal-to-floor is a declared limit |
| curl | 8.23.0 | 8.23.0 unchanged | == anchor ⇒ `not-fired` valid |

The Python floor is the one that could have tripped: had the observation
stayed at 3.15.0 it would be below S040/S041's 3.15.1 anchor and read
`REGRESSED`.

## Dead ends and limits (stated honestly)

- The C1 counter's `stale` producer (`corpus/self-counts.py`) exits 2
  because two rows are POLICY (R29-01/R29-02). The counter reads the
  `SELF_COUNTS:` summary line, so a POLICY exit does not become a zero. I
  did not "fix" this; it is the producer's own envelope, and the plan
  bounds it.
- `bash corpus/claim-ledger.sh verify` takes ~3 minutes and the lane tree
  changed under me during the run. The five-row FAIL list in the report is
  the version I stand behind because I re-confirmed each by running that
  row's command directly (`grep -c`, `row-identity.sh`, `release-clock.py`).
- I did not re-run `claim-ledger.sh cells`, `citations` or `docs` against
  the final landing tree; the last full `verify` I captured predates the
  last two L1 edits (`corpus/lessons/round-36.md`, the `corpus/stamps.tsv`
  re-pin). I did confirm the stamps themselves are current: all eight
  touched files' digests match their `corpus/stamps.tsv` pins, and the
  verify run surfaced no `STALE`/`MISSING` stamp line.
- The SD6 baseline is 5 on the real tree and 3 in a lone `git archive`
  fixture, because two of the five non-author spot-check lessons cite a
  sibling-lane absolute path. The plan's frozen BASE (5) matches the real
  tree, so the real tree is the reference I used.
- No tool was installed or upgraded for this recon; the operator's tooling
  authorisation was not needed. Nothing was written to the lane except the
  three files in this directory.

## Files

| file | sha256 | bytes |
|---|---|---|
| `.ufo/waves/round-36/build/ScoutClock/recon.md` | `9ec0276e48a9d3309b75cc90e6405c6ca654e0d972c8c4a989bea8f78a5dfa48` | 20941 |
| `.ufo/waves/round-36/build/ScoutClock/proposal.tsv` | `e264248275c4f3f8e38b62cc759556d31292eeb55d9fe1ca34c86aa59060296a` | 3216 |
| `.ufo/waves/round-36/build/ScoutClock/base-release-clocks.tsv` | `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd` | 5944 |

(This file's own digest is quoted in the seat trailer `.ufo/waves/round-36/build/ScoutClock.md`,
which is written after this file is final.)

`base-release-clocks.tsv` is the committed BASE `corpus/release-clocks.tsv`
copied out of scratch before cleanup; its digest equals the `corpus/stamps.tsv`
pin for that path, so it is the BASE bytes the proposal was measured against.
