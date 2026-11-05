# K44ExecIsolate — round-44 negative fixture gate leg-isolation probe

Seat: `K44ExecIsolate` (assignment header also names deliverable dir `K44LabratIsolation`; this memo is the `Report:` trailer `.ufo/waves/round-44/build/K44ExecIsolate.md`; raw matrix lives under `.ufo/waves/round-44/build/K44LabratIsolation/`).
Candidate revision: `ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae`
Sandbox: `$HYAKU_SCRATCH/kagi-r44/K44LabratIsolation` (clone `--shared`, detached checkout verified `rev-parse --show-toplevel` = `$S/work` before any write; receipts copied to deliverable before scratch removal).
Tooling installs/upgrades: none required (bash, git, python3 already present; pacman was PAUSED host-wide, no installs attempted).

## Hypothesis & method

HYPOTHESIS — the round-44 negative fixture gates are leg-isolated: the accept-stale gate kills counter mutant y1 (mutant 1, real 0) but leaves y2 surviving (mutant 0), and the accept-silent gate kills y2 but leaves y1 surviving.

Method (per assignment): built the two mutants per `plans/round-44-c1.sh` frozen recipes (byte-copy of the candidate's `plans/round-43-c2.sh`; python block at lines 87–107) and both fixture gate templates from their bytes (`g-as` accept-stale, `g-asi` accept-silent heredocs at lines 114–138; byte-identity to on-disk copies verified by extraction diff — both `MATCH`). Ran the 2×2 matrix plus real×each gate, each as `CONTROLS_REPLAY_GATE=<gate> bash <counter-copy-in-clone> ae9e9eb…` (the `c1.sh` `run_counter` shape). Acceptance = each counter's single-integer stdout, with rc.

## Matrix table (measured)

| counter \ gate | accept-stale (`g-as`) | accept-silent (`g-asi`) |
|---|---|---|
| **real** | 0 (rc 0) | 0 (rc 0) |
| **y1** (N1 stale-refusal leg dropped) | **1** (rc 0) | 0 (rc 0) |
| **y2** (N2 silent-refusal leg dropped) | 0 (rc 0) | **1** (rc 0) |
| real, default gate (P0) | 1 (rc 0) | — |

Prediction (falsifier): y1×accept-stale=1, y1×accept-silent=0, y2×accept-stale=0, y2×accept-silent=1, real×accept-stale=0, real×accept-silent=0. **Every reading matches the prediction.**

## Verdict

**Isolation hypothesis CONFIRMED (not falsified).** No reading broke the falsifier. Each accept-* gate discriminates exactly its paired mutant (kills it: mutant 1 vs real 0) while the cross pairing leaves the other mutant surviving (mutant 0 = same as real 0), and neither gate fires on the real counter. This is precisely the per-fixture behaviour the frozen plan's C1 predicate relies on (y1 killed only via accept-stale, y2 only via accept-silent, with the always-refuse blanket leg as the third discrimination conjunct — not re-measured here; that leg belongs to the battery's own count predicate).

## Evidence

- Raw outputs (rc + stdout for all 7 runs, plus recipe rc): `.ufo/waves/round-44/build/K44LabratIsolation/raw-outputs.txt`
- Built mutants: `.ufo/waves/round-44/build/K44LabratIsolation/mut-y1.sh`, `mut-y2.sh` (post-conditions verified: no `"$N1"` in y1, no `"$N2"` in y2)
- Gate templates (byte-identical to `plans/round-44-c1.sh` heredocs): `.ufo/waves/round-44/build/K44LabratIsolation/gate-accept-stale.sh`, `gate-accept-silent.sh`
- Exact commands: `CONTROLS_REPLAY_GATE=$SCR/g-as bash $SCR/clone/plans/r44b-real ae9e9eb…` etc. (full log in `raw-outputs.txt`); last output lines all rc 0, stdout as tabulated above; stderr files were empty.
- P0 cross-check: real counter with default (candidate's own) gate reads 1, rc 0 — the battery's positive control holds at this revision.

## Risks / blockers

- The always-refuse blanket leg (mutant reads 0) was not part of the assignment's 2×2 and was not re-measured; the frozen battery itself measures it.
- Scratch dir `$HYAKU_SCRATCH/kagi-r44/K44LabratIsolation` removed on exit per rules (receipts copied to the deliverable first).

SEAT-STATUS: complete
