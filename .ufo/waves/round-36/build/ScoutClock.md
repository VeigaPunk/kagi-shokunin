# ScoutClock — round 36 (attempt 2), seat report

Lane: `kagi-shokunin`. Scope: reconnaissance of the C2 reading and the
F3/F4 edit. Read-only on the lane; all writes under
`.ufo/waves/round-36/build/ScoutClock/`.

## Verdict

The C2 mechanism and the proposed values are sound — **no row trips
REGRESSED / DERIVATION / INCONSISTENT** with the proposed values and the
`corpus/SOURCES.md` anchor cells untouched. Two findings remain open for the
L1, both about the landing rather than about the claim:

1. **Stale prose citation of the old default receipt** — `SKILL.md:48`,
   `SKILL.md:787`, `PROVINCE.md:75` still say "the pinned round-26 rearmed
   receipt" after F4 repoints the default to the round-36 receipt. No
   counter reads these lines; this is the QM21 class, an honest-reporting
   finding.
2. **Five committed ledger expectations no longer match their live source**
   because the landing itself moved what they pin — R13-01 (44 → 46 round
   headings), R21-04 (79 → 82 claim rows), R24-06 and R24-14 (the identity
   digests over those two sets), R25-04 (`fired=3` → `fired=15`). Each needs
   an explicit old→new migration record (QM14).

## Numbers

| quantity | BASE | landing | rc |
|---|---|---|---|
| `bash plans/round-36-c1.sh` | 4 | **0** | 0 |
| `bash plans/round-36-c2.sh` | 15 | **0** | 0 |
| `bash plans/round-36-c3.sh` | — (new) | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` | 0 |
| `python3 -I -B corpus/release-clock.py` | CLEAN fired=3 derived=15 | CLEAN **fired=15 derived=15** | 0 |
| `bash corpus/sources-census.sh` | CLEAN rows=88 | CLEAN rows=88 | 0 |
| sweep SD5 / SD6 | 3 / 5 | **0 / 5** (SD6 preserved — C1 kill rule) | 1 (SD6 non-clean by design) |
| `claim-ledger.sh verify` FAIL rows | R11-08, R22-03, R24-15, R25-02 | + **R13-01, R21-04, R24-06, R24-14, R25-04** | — |

C2 population: 20 `clock=feed` rows; **15** drift at BASE (S012–S016,
S021–S028, S040, S041), 5 do not (S008–S011, S029). 12 of the 15 change
verdict `not-fired → fired`, 3 keep `fired` (S012, S027, S028) — matching
the frozen plan. **All 30** bound rows re-date `2026-10-21 → 2026-11-04`,
because `receipt_matches` compares `observed_at` on every bound row; the
counter's population is unchanged.

Receipt digest confirmed: `sha256sum` =
`3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`.
Round-26 receipt retained byte-identical at
`13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`.

## Key traps measured (isolated fixtures, scratch)

- **The C2 counter reading 0 ≠ the gate CLEAN.** F3 on only the fifteen
  drifting rows + F4 → `c2.sh` prints **0** while `release-clock.py` prints
  `RECEIPT-MISMATCH` ×15 and `RELEASE_CLOCK: FAILED (observed=15 …)`.
- **Rewriting an SOURCES.md anchor cell breaks the derived binding.**
  S034's cell → `v2.2.1` ⇒ `DERIVATION` S013/S022/S023/S024. S040's cell →
  `Python 3.15.2` ⇒ `INCONSISTENT` S040/S041.
- **The `derived:` note prefix is load-bearing** — `is_derived` is
  `note.startswith("derived:")`; the receipt clause must be **appended**.

## Files (this seat)

| path | sha256 | bytes |
|---|---|---|
| `.ufo/waves/round-36/build/ScoutClock/recon.md` | `9ec0276e48a9d3309b75cc90e6405c6ca654e0d972c8c4a989bea8f78a5dfa48` | 20941 |
| `.ufo/waves/round-36/build/ScoutClock/proposal.tsv` | `e264248275c4f3f8e38b62cc759556d31292eeb55d9fe1ca34c86aa59060296a` | 3216 |
| `.ufo/waves/round-36/build/ScoutClock/report.md` | `dc6a92663d730df0815ca16e7745d51183e7a4834dad8967a4871caa40eef797` | 7822 |
| `.ufo/waves/round-36/build/ScoutClock/base-release-clocks.tsv` | `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd` | 5944 |

`base-release-clocks.tsv` is the committed BASE `corpus/release-clocks.tsv`,
copied out of scratch before cleanup; its digest equals the `corpus/stamps.tsv`
pin for that path, so it is the BASE bytes the proposal was measured against.

`proposal.tsv` carries the per-row proposal for all 20 `clock=feed` rows
measured over committed BASE bytes: old/new observed_version, old/new
verdict, the `observed_at` re-date, `anchored_version` untouched, whether
the `derived:` prefix must be kept, and whether the row is in the C2 counter
population.

## Tooling

No tool was installed or upgraded for this recon; the operator's tooling
authorisation was not needed. No pacman transaction was attempted (the
orchestrator's host-wide pacman pause stands).

## Limits (honest)

- `claim-ledger.sh verify` takes ~3 min and the lane tree changed under me
  during the run; the five-row FAIL list is re-confirmed by running each
  row's command directly.
- I did not re-run `claim-ledger.sh cells` / `citations` / `docs` against
  the final tree (last full `verify` predates the last two L1 edits). I did
  confirm all eight touched files' digests match their `corpus/stamps.tsv`
  pins and that no `STALE`/`MISSING` stamp line appeared.
- SD6 measures 5 on the real tree and 3 in a lone `git archive` fixture
  (two spot-check lessons cite a sibling-lane absolute path); the frozen
  BASE of 5 matches the real tree, which I used as the reference.
- The C1 counter's `stale` producer exits 2 at BASE and at landing because
  two rows are POLICY (R29-01/R29-02); the counter reads the summary line,
  so a POLICY exit never becomes a zero. I did not alter that envelope.

Report: .ufo/waves/round-36/build/ScoutClock.md
