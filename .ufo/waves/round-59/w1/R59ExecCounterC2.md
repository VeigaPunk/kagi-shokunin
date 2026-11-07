# R59ExecCounterC2 — round-59 C2 counter

Seat: R59ExecCounterC2 (executor, leaf). Item: write `plans/round-59-c2.sh`, the
counter measuring `plans/round-59.md` §C2's frozen predicate
(`C2_TRANSIT_TRIAL`).

## Files changed

- `plans/round-59-c2.sh` — new, 155 lines, 8179 B,
  sha256 `9bc3da958b665cd7359cd1697890d1126936ba30185234ef6f9fa6199e331f8d`
  (frozen; hash sent to R59MutCounters).
- `.ufo/waves/round-59/build/R59ExecCounterC2/` — 9 receipt files (below).
- `.ufo/waves/round-59/w1/R59ExecCounterC2.md` — this report.

No other lane paths touched. No git/jj mutations anywhere; all validation ran
in `${HYAKU_SCRATCH}/kagi-r59/R59ExecCounterC2/` (deleted before yield).

## What the counter does

Takes `[revision]` (default BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`)
or `--tree DIR`; materialises the measured tree into
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecCounterC2/c2-counter.$$/tree`
via `git archive` (or uses `--tree` directly), then runs
`corpus/openbao-transit-trial.sh --work <scratch>` under `env -i` in nine legs:
`real`, `real2`, `none` (PATH without bao), `sh1`..`sh5`
(`KAGI_TRANSIT_SHIM=SHn`). Run-log names are `rhex`-randomised under
`$SCR/log/`, outside every `--work` dir (round-51 M51-2). Legs run in `shuf`
order; `timeout 900` per leg.

Reads per leg: exactly-once `TRIAL T<n> HOLDS|BROKEN|ERROR` (DUP/missing →
fail), exactly-once `TRIAL CLEANROOM HOLDS|BROKEN|ERROR`, and the summary
`OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=<ver>` required in
BOTH real runs. value=5 iff: both real runs rc 0 + vector HHHHH + summary +
CLEANROOM HOLDS in both; all five shims rc 1 with exact vectors
BHHHH/HBHHH/HHBHH/HHHBH/HHHHB; none leg rc 2 with no `HOLDS` anywhere; secret
scan clean. Output:
`C2_TRANSIT_TRIAL: value=V tests=5 pass=P shims=K vectors=ok|K/5 guard=G (real=… none=… cleanroom=… secret=…)`;
exit 0 iff value=5, 1 otherwise, 2 SETUP.

Absent trial → `value=0 … guard=0 (absent)` rc 0. Bad revision/tree (incl.
`--tree` with no arg — improved over r58's `${2:?}` abort) → `guard=0` rc 1.
SETUP rc 2: no python3/git, unusable scratch, `PIN_BAO` unreadable (read live
from `$REPO/plans/round-57-c2.sh`, exactly-one-match enforced), missing
`$R59_BAO`/`$HOME/.local/bin/bao`, bao sha256 ≠ pin, or a `bao` in
`/usr/bin`/`/bin`.

## Contract measured — IMPORTANT

`corpus/openbao-transit-trial.sh` does **not exist** at BASE
(`git cat-file -e 5fa6e658:corpus/openbao-transit-trial.sh` → absent) and was
not on disk in the working tree at freeze time. Per the assignment I coded to
the §C2 + A2 printed contract and the round-57/58 trial convention, and
confirmed the exact interface with seat R59ExecTrial (they locked all six
points: invocation, six TRIAL lines + one summary, exit codes, shim env var
`KAGI_TRANSIT_SHIM`, secret handling). Every `value=5` reading below is a
**contract reading against a reference fixture**
(`reference-trial.sh.txt`, sha256 in `notes.md`), not a reading of the wave's
trial bytes. L1 must re-run the counter on the landed trial.

## Evidence (all under `.ufo/waves/round-59/build/R59ExecCounterC2/`)

| receipt | content | result |
|---|---|---|
| `receipt-base.txt` | counter, no arg (BASE) | `value=0 … guard=0 (absent)`, rc 0 |
| `receipt-candidate.txt` | counter `--tree` BASE+fixture | `value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)`, rc 0 |
| `receipt-shim-vectors.txt` | SH1..SH5 direct trial runs | vectors BHHHH HBHHH HHBHH HHHBH HHHHB, each rc 1, CLEANROOM HOLDS each |
| `receipt-no-bao.txt` | trial under `env -i PATH=/usr/bin:/bin` | `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH`, rc 2, zero TRIAL lines |
| `receipt-cleanroom.txt` | (a) CLEANROOM HOLDS ×2 real runs; (b) independent two-`bao server -dev` probe on the pinned binary | server B refuses server A's T1 ciphertext with no key AND with a fresh same-name key |
| `receipt-failclosed.txt` | forge legs + SETUP + guard + ambient env | cleanroom-removed → value=0 rc 1; summary-removed → value=0 rc 1; SH1 double-flip → `shims=4 vectors=4/5` value=0 rc 1; bao-missing/bao-pin-mismatch → SETUP rc 2; bad-revision/bad-tree/`--tree`-no-arg → guard=0 rc 1; hostile `BAO_*`/`VAULT_*` ambient → still value=5 rc 0 (env -i blocks) |
| `receipt-secret-scan.txt` | `grep -rEl 'r59-[0-9a-f]{24}\|(hvs\|hvb)\.\|s\.[A-Za-z0-9]{20,}'` over the receipts dir | clean, 0 files (one self-inflicted hit — literal `hvs.`/`hvb.` probe strings quoted in the ambient-env command line — redacted to `<ambient-token-shaped-value>` and re-scanned clean) |
| `reference-trial.sh.txt`, `notes.md` | byte-exact fixture + reproduction commands/hashes | — |

Transit mechanics were pre-probed live on the pinned binary
(`/home/vgpnk/.local/bin/bao`, sha256 = `PIN_BAO` = OpenBao v2.7.2):
`secrets enable transit` required; convergent keys need `derived=true` +
`context`; rotate→v2 with v1 still decrypting; rewrap→v2 surviving
`min_decryption_version=2` while v1 is refused; mdv raise/lower round trip;
convergent determinism per context; cross-server refusal. All confirmed before
the fixture was written.

## Ceilings the counter cannot see

- **K2 (named):** a trial resolving `bao` by absolute path and shape-keying its
  output reads 5 without measuring — checked by receipts and a non-author
  probe, not by this counter.
- **K4 (named):** whether the CLEANROOM leg's second dev server is genuinely
  independent (own storage) cannot be proven from printed output; the counter
  only requires the `TRIAL CLEANROOM HOLDS` line in both real runs. Server
  independence is a receipts/probe matter — `receipt-cleanroom.txt` part (b)
  is the non-trial ground for it.
- A trial leaking secrets into files under `--work` (rather than stdout/stderr)
  escapes the secret scan, which covers only captured leg output; a
  differently-shaped secret also escapes the `r59-`/`hvs.`/`hvb.`/`s.` patterns.
- A trial that prints conforming HOLDS lines without running servers passes —
  same shape-keyed class as K2.
- The counter's per-leg verdicts are the trial's self-report; it cannot
  distinguish a real second server from a same-server refusal (K4 above).
- `guard=1` is constant on evaluated trees; the fail-closed surface is the
  SETUP/guard=0 paths plus the value conjuncts, not a mutation challenge like
  C1's.

## Risks / blockers

- None blocking. If R59ExecTrial's bytes deviate from the locked contract the
  counter reads <5 — intended fail-closed; L1 re-measures post-landing.
- Full candidate pass costs ~3.5 min (9 legs × 2 dev servers each).

SEAT-STATUS: complete
