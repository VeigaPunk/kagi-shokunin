# K45ExecStampRW — M45-1 red witness (stamp drift must be able to fail)

Axes: green-when-clean / red-when-altered (independent reference for stamps), honest receipts, no lane mutation.

## Artifact
- `.ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py` — reads `corpus/stamps.tsv` under a given root, recomputes sha256 per row, prints `STAMP_DRIFT: rows=N drift=D` plus `DRIFT <path>` per mismatch/missing; exit 0 iff D=0 else 1.
- `.ufo/waves/round-45/build/K45ExecStampRW/receipts.txt` — full commands, RCs, last lines.

## Results (quoted from receipts)
- (a) base archive `307fb50da825d6e6f2b5c7981c71556d35611142`: `STAMP_DRIFT: rows=123 drift=0`, RC 0. Matches frozen stamps.
- (b) same archive with one byte appended to `LOG.md` (the stamped path is root-level `LOG.md`): `STAMP_DRIFT: rows=123 drift=1`, `DRIFT LOG.md`, RC 1. Expectation met (note: first attempt appended to `corpus/LOG.md`, which is not a stamped path and correctly gave D=0 — the red witness stayed honest; corrected to root `LOG.md`).
- (c) same archive with one sha256 cell flipped in `corpus/stamps.tsv` (row 1, `corpus/adjacency.tsv`): `STAMP_DRIFT: rows=123 drift=1`, `DRIFT corpus/adjacency.tsv`, RC 1. Expectation met.

## Optional claim-ledger verify (time-boxed 240 s each, scratch copies only)
- (a) `timeout 240 bash corpus/claim-ledger.sh verify`: RC 124 (timeout), last line `FAIL R34-03 reason=exit-mismatch exit=1 want=0`. Run never completed inside the timeout; no pass claimed.
- (b) same command on the altered copy: RC 124 (timeout), last line `FAIL R34-03 reason=exit-mismatch exit=1 want=0`. No pass claimed.

## Scratch
All archives/copies lived under `/fast/scratch/hyaku/kagi-r45/K45ExecStampRW/` (base, altered-byte, altered-sha); `/tmp` unused. No lane files touched; no git mutations (read-only `git archive` only).

## Specialists to spawn
None required.

## Risks / blockers
- The optional verify timed out both times — not a pass; if M45-1 gating needs a green verify, the command needs a longer budget or a smaller subset on a scratch copy.
- `stamp-drift.py` only checks sha256 cells (lines/bytes columns ignored by design); a drift that only changes line/byte counts without altering content is invisible.
