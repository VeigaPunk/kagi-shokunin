# K44ExecBase — independent re-measurement of round-44 BASE receipts (claim BASE `d54109d943abc900e71613a02e5a7a2e46453c3a`)

## Method / setup

- Sandbox (per fleet rules, never the lane tree):
  `S=/fast/scratch/hyaku/kagi-r44/K44ExecBase`, clone `--shared` from
  `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
- **Revision resolution note (recorded verbatim, no silent choice):** the seat text says
  `checkout --detach d54109d…` while the fleet preamble says to check out the
  predeclaration `ae9e9eb…`. Both were built and inspected:
  - Clone at `d54109d` (`$S/work`, HEAD `d54109d…` verified via
    `git rev-parse HEAD` and `git rev-parse --show-toplevel == $S/work`) **does not contain
    `plans/round-44-c1.sh` / `plans/round-44-c2.sh` / `plans/round-44-c3.sh`, nor
    `.ufo/waves/round-44/controls/fixtures/`** — the counters arrive only in the predeclaration
    commit (`git show ae9e9eb --stat` lists all 24 predeclaration files). A literal
    `bash <clone>/plans/round-44-c1.sh` is therefore impossible from a `d54109d` checkout.
  - The counters resolve `REPO` from their own path and then read the **candidate revision
    argument** (`CAND=${1:-…}`, `git show $CAND:…`), so the faithful reproduction is:
    clone checked out at the **predeclaration** `ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae`
    (`$S/work2`, HEAD verified), counters copied to that clone's `plans/` (they are the
    committed bytes; `cmp` lane↔clone identical for c1/c2/c3 and the TSV), and every
    invocation passed the **claim BASE** `d54109d…` as the measured revision. This is exactly
    the controls runner's own shape (`bash plans/round-44-controls.sh base d54109d…` run in
    the predeclaration worktree). Verified `d54109d` is an ancestor of `ae9e9eb`
    (`merge-base --is-ancestor` → yes).
  - Counters keep their scratch under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r44/…`
    and trap-remove it; no `/tmp` writes; clone `git status --porcelain` stayed empty after
    the battery.
- Frozen plan read in full first: `plans/round-44.md` (260 lines). No predicate
  reinterpretation; the nine commands below are run **exactly** as the assignment names them.
- No tooling was installed or upgraded (tool/version/channel/reason: none — nothing needed);
  the pacman pause was respected trivially.

## Comparison table (receipt, expected, measured, rc, last line)

| receipt | expected | measured | rc | last line | committed receipt agrees? |
|---|---|---|---|---|---|
| `c1-base` (`bash plans/round-44-c1.sh d54109d…`) | 0 | 0 | 0 | `0` | yes |
| `c1-skipfix` (`R44_SKIP_FIXTURES=1 …`) | 0 | 0 | 0 | `0` | yes |
| `c2-base` (`bash plans/round-44-c2.sh d54109d…`) | 0 | 0 | 0 | `0` | yes |
| `c2-forged-sha` (`R44_RECEIPT=…/receipt-wrong-sha.txt …`) | 0 | 0 | 0 | `0` | yes |
| `c2-forged-rev` (`R44_RECEIPT=…/receipt-wrong-rev.txt …`) | 0 | 0 | 0 | `0` | yes |
| `c3-base` (`bash plans/round-44-c3.sh d54109d…`) | 0 | 0 | 0 | `0` | yes |
| `c3-pos` (`R44_REGISTER_ROOT=…/register-full …`) | 3 | 3 | 0 | `3` | yes |
| `c3-wrongvals` (`R44_REGISTER_ROOT=…/register-wrongvals …`) | 1 | 1 | 0 | `1` | yes |
| `prefreeze` (`bash corpus/prefreeze-control.sh run --base d54109d… --controls plans/round-44.controls.tsv`) | `PREFREEZE: CLEAN (controls=13 mismatch=0)`, exit 0 | identical | 0 | `PREFREEZE: CLEAN (controls=13 mismatch=0)` | yes (all 13 `OK` lines byte-identical to `prefreeze-base.txt`) |

Every measured value equals both the frozen-plan expectation and the committed BASE receipt
under `.ufo/waves/round-44/controls/` (`c1-base`, `c1-skipfix`, `c2-base`, `c2-forged-sha`,
`c2-forged-rev`, `c3-base`, `c3-pos`, `c3-wrongvals`, `prefreeze-base.txt`, plus the
`measured-at.txt` per-receipt `rc/last/expect` lines — all match this re-measurement).

Raw full stdout for every run is preserved under
`build/K44ExecBase/raw/` (`c1-base.raw`, `c1-skipfix.raw`, `c2-base.raw`,
`c2-forged-sha.raw`, `c2-forged-rev.raw`, `c3-base.raw`, `c3-pos.raw`, `c3-wrongvals.raw`,
`prefreeze.raw`, `summary.txt`, `parse.tsv`).

## Findings

**Finding 1 — no BASE-receipt drift (the headline result).** All eight counter receipts and
the pre-freeze control reproduce the committed values at the claim BASE. There is **no
mismatch between the committed BASE receipts and this independent re-measurement**. The
pre-freeze `PREFREEZE: CLEAN (controls=13 mismatch=0)` (exit 0) is confirmed, including the
three existence controls (`battery_absent`, `receipt_absent`, `register_absent` = 0) and the
pinned committed values (`c1`=4, `c2`=0, `c2-worktree`=3).

**Finding 2 — instruction/artifact ambiguity (procedure, not a plan defect).** The seat text
orders a `checkout --detach d54109d…` and then `bash <clone>/plans/round-44-c*.sh`, but the
counters do not exist at `d54109d` — they exist only from `ae9e9eb` onward. Any future seat
spec should name the predeclaration as the checkout and the claim BASE as the *argument* (as
the controls runner does). The reproduction above follows the plan's own execution shape; the
alternative (copying counters into a `d54109d` checkout) would have worked identically
because `REPO` is path-derived and `CAND` is the argument, but the predeclaration checkout
is cleaner and byte-identical (`cmp` verified).

**Finding 3 — mechanism spot-checks (why the zero readings are zero, not accidental):**
- `git cat-file -e d54109d…:plans/round-44-c1.sh` → absent, so `c1-base`/`c1-skipfix` read 0
  via the existence leg (do-nothing control, as frozen).
- `git show d54109d…:.ufo/waves/round-44/final/replay-at-tip.txt` → absent, so `c2-base`
  reads 0 (missing receipt reads 0); both forged fixtures were rejected (`receipt-wrong-sha`:
  unknown hash; `receipt-wrong-rev`: unknown revision `6666…`).
- `git show d54109d…:.ufo/waves/round-44/controls/receipt-corrections.md` → absent, so
  `c3-base` reads 0; with the full fixture the executed legs (re-derivation at
  `5f3566c4…` + sweep) score 3, and with wrong re-derived values only the sweep row scores
  (1) — the fixture controls discriminate as frozen.
- No receipt, register, or battery file leaks into the BASE reading: each zero is the frozen
  do-nothing/forged leg firing, not a counter error (all runs rc 0, stdout exactly the
  expected token, nothing on stderr).

**Attack notes (kept, per godspeed axes calibration/operability/freshness):**
- Calibration: the `c3-wrongvals=1` control confirms the executed re-derivation leg is
  load-bearing (rows 1–2 dropped, sweep row alone survives) — a register cannot pass on
  committed values alone.
- Operability: all nine commands are non-interactive, deterministic, and self-cleaning
  (scratch traps; clone stayed clean); the only friction is Finding 2's checkout wording.
- Freshness: the pins inside the counters (`5f3566c…`, the round-43 counter markers) still
  correspond to committed bytes at the BASE; the prefreeze control's 13 rows exhaustively
  re-agree with the frozen tree-shape facts.

## Blockers / risks

- None blocking. The revision ambiguity (Finding 2) is resolved by the plan's own runner
  shape; both candidate interpretations converge to identical counter behaviour.

## Exact commands (all run with `cd` in the seat scratch for fixture-bearing steps)

```
git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/hyaku/kagi-r44/K44ExecBase/work
git -C /fast/scratch/hyaku/kagi-r44/K44ExecBase/work checkout --detach d54109d943abc900e71613a02e5a7a2e46453c3a   # inspected: no counters here
git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/hyaku/kagi-r44/K44ExecBase/work2
git -C /fast/scratch/hyaku/kagi-r44/K44ExecBase/work2 checkout --detach ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae
W=/fast/scratch/hyaku/kagi-r44/K44ExecBase/work2
bash $W/plans/round-44-c1.sh d54109d943abc900e71613a02e5a7a2e46453c3a                                     # rc 0 -> 0
R44_SKIP_FIXTURES=1 bash $W/plans/round-44-c1.sh d54109d943abc900e71613a02e5a7a2e46453c3a                  # rc 0 -> 0
bash $W/plans/round-44-c2.sh d54109d943abc900e71613a02e5a7a2e46453c3a                                     # rc 0 -> 0
R44_RECEIPT=$W/.ufo/waves/round-44/controls/fixtures/receipt-wrong-sha.txt bash $W/plans/round-44-c2.sh d54109d943abc900e71613a02e5a7a2e46453c3a   # rc 0 -> 0
R44_RECEIPT=$W/.ufo/waves/round-44/controls/fixtures/receipt-wrong-rev.txt bash $W/plans/round-44-c2.sh d54109d943abc900e71613a02e5a7a2e46453c3a   # rc 0 -> 0
bash $W/plans/round-44-c3.sh d54109d943abc900e71613a02e5a7a2e46453c3a                                     # rc 0 -> 0
R44_REGISTER_ROOT=$W/.ufo/waves/round-44/controls/fixtures/register-full bash $W/plans/round-44-c3.sh d54109d943abc900e71613a02e5a7a2e46453c3a     # rc 0 -> 3
R44_REGISTER_ROOT=$W/.ufo/waves/round-44/controls/fixtures/register-wrongvals bash $W/plans/round-44-c3.sh d54109d943abc900e71613a02e5a7a2e46453c3a  # rc 0 -> 1
bash $W/corpus/prefreeze-control.sh run --base d54109d943abc900e71613a02e5a7a2e46453c3a --controls $W/plans/round-44.controls.tsv                     # rc 0 -> PREFREEZE: CLEAN (controls=13 mismatch=0)
```

Scratch was removed after copying receipts (`rm -rf -- "$S"`); nothing was committed anywhere.

SEAT-STATUS: complete
