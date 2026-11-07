# R58ExecFixCode — C1 executable repairs I6 + I8 (lane: kagi, round 58, attempt 1)

Seat: R58ExecFixCode (executor). Claim BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`;
lane working tree measured while scribe repairs (I1–I4 surfaces) were landing around me.
Non-goals honored: no edits to SCORECARD.md, LOG.md, corpus/lessons/*.md, SKILL.md, plans/*;
no commit; no scratch residue.

## Files changed (2)

| file | sha256 |
|---|---|
| `corpus/current-claims.py` (I6) | `6f3a532494706290b848eb625cf9dedace427e7052ea4523e5a8200c72c3fafb` |
| `corpus/adjacency.tsv` (I8, basis column of one row only) | `5b9218933e9bbcb4d614775a5677a51fd1150a8d711c45a0d635955dc703043b` |

Both files were still at these shas at report time (re-checked after all receipt runs);
receipt headers pin the gate sha they ran.

## I6 — `corpus/current-claims.py` gains `--round N`

- `--round N` (int, ≥1) selects the audited round; default = **the previous completed round,
  derived as the highest `## Round <n> (` heading in LOG.md, falling back to the highest
  `corpus/lessons/round-<n>.md` when LOG.md names none**; underivable ⇒ `SETUP` rc 2
  (`die`), never a wrong audit. It does **not** scan for the post-move section (L1 asked me to
  state the derivation rule explicitly — done here and in `agent://KagiR58`).
- Every audited-surface path is derived from N: `SCORECARD.md` section `## Round <N> [—-] post-move`,
  `LOG.md` heading `## Round <N> (`, `corpus/lessons/round-<N>.md`,
  `.ufo/waves/round-<N>/controls/controls-prefreeze-epoch<L>.txt` (MATCH authority),
  `plans/round-<N>.md` (EPOCHS authority). No literal `round-56` path remains in the surface
  code (`measure`/`receipt_match`/`epoch_declared`); the remaining `round-56` literals are
  selftest fixtures only (CLEAN_SC/LOG/LESSON, `rnd: int = 56` default, r56-surface defect case).
- Module docstring fixed: usage/derivation paragraph rewritten; the **EPOCHS sentence now names
  `plans/round-<N>.md`** (the frozen round plan, not the control receipts) — the authority the
  code actually reads; `--round` is defined as the audited round.
- `--selftest` extended: 13 → **19 cases, PASS, rc 0** — adds a synthetic **round-57** root
  (clean at 57, `FAIL` when forced to 56), a two-round default-derivation tree (derives 57,
  audits 57 cleanly, reads the planted stale statement only under explicit 56), and the
  lesson-fallback derivation case. All 13 original cases unchanged and green.
- Pre-existing behavior intentionally unchanged: the CASES authority still executes
  `<tree>/corpus/recheck-replay.py --selftest` (flagged to R58SentinelTrial and the L1 as
  candidate-controlled execution; the frozen I6 condition carries no env clause, so I did not
  widen scope into it).

### Gate proof — exact readings (receipts in `.ufo/waves/round-58/build/R58ExecFixCode/`)

BASE tree = `git archive 1b13f5dad921f8901f56d30c428f89614dd74d8a` extracted to
`${HYAKU_SCRATCH}/kagi-r58/R58ExecFixCode/base` (deleted after capture, per seat rules; the
receipts carry the root path, command and gate sha). Script is always the edited gate;
only `--root` differs.

| command (abbreviated; full line inside each receipt) | receipt | output (exact) |
|---|---|---|
| `--root <lane> --round 57` | `r57-tree.txt` | `CURRENT_CLAIMS: value=13 population=15 mismatches=13 unbound=6 cases=3 match=6 epochs=6 clocks=0 pop=0 guard=1`, rc 1 |
| `--root <lane> --round 57 --verbose` | `r57-tree-verbose.txt` | 15 STMT lines over SCORECARD/LOG/LESSON round-57 sections (sha `2aab18016d…`) |
| `--root <lane> --round 56` | `r56-tree.txt` | `CURRENT_CLAIMS: value=0 population=16 mismatches=0 unbound=0 cases=3 match=7 epochs=2 clocks=2 pop=2 guard=1`, rc 0 |
| `--root <lane> --selftest` | `selftest-tree.txt` | `CURRENT_CLAIMS_SELFTEST: PASS (19 cases)`, rc 0 |
| `--root <BASE> --round 57` | `r57-base.txt` | same summary line as `r57-tree`, rc 1 |
| `--root <BASE> --round 57 --verbose` | `r57-base-verbose.txt` | 15 STMT lines over the BASE round-57 surface (sha `68c466f2bf…`); STMT line numbers differ from the tree receipt (different bytes), totals coincide |
| `--root <BASE> --round 56` | `r56-base.txt` | same summary line as `r56-tree`, rc 0 |
| no args, run from the lane root | `default-noargs-tree.txt` | identical to `--round 57` (derives 57) |
| (baseline, annotated) BASE's own pre-fix script | `selftest-base.txt` | `PASS (13 cases)` — pre-I6 baseline, not the landed gate |

Reading notes: `--round 56` reproduces the r57 spot-check's independent 16-statement census
(3 cases + 7 MATCH + 2 epochs + 2 clocks + 2 pop), value 0. `--round 57` shows the gate now
reads the round-57 surface: 6 epoch statements bind to `plans/round-57.md`, which declares no
`epoch-[A-F]` tokens (auth 0), and the quoted historical numbers ("23 MATCH", "four/Three freeze
epochs", "18 cases") are unbound/mismatched — those statement-text repairs belong to the
surface owners (I1–I4/I7), not to the gate. Receipt population/values are the L1's to
re-measure at integration.

## I8 — stale basis re-point (`corpus/adjacency.tsv`, basis column only)

`$HOME/.config/opencode` row basis `SCORECARD.md:54` → **`SCORECARD.md:70`**. Line 70 is the
round-10 post-move adjacency cell — the line that actually carries the ownership claim
("the global `~/.config/opencode/opencode.json` ownership boundary (connector: needs an
integrator ruling)"); the basis was written when that claim sat at line 54 and later rounds
inserted rows above it (citation-decay class). Token `opencode` matches line 70.

Before (`scope-gate-before.txt`):
```
SCOPE STALE-BASIS $HOME/.config/opencode basis=SCORECARD.md:54 lines=54-54 token=opencode
ADJACENCY_SCOPE: DEFECT (… stale_basis=1 basis_escape=0 own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_checked=3 breadth_ok=0 breadth_missing=0 breadth_invalid=0 breadth_drift=5 breadth_exceeds=0 breadth_unverified=1)   rc=1
```
After (`scope-gate-after.txt`): the STALE-BASIS line is gone and the summary reads the same
DEFECT line with **`stale_basis=0`**; every other counter identical (unresolved=1, contested=1,
breadth_drift=5, breadth_unverified=1 — pre-existing host-state readings, not mine to move).
R58ScoutRouted independently confirmed 1→0 for a `:70` re-point on an archive copy.

Caveat for the C1 counter (forwarded to L1): on a **copy** of the tree, scope-gate needs
`--lane-root /home/vgpnk/Projects/shokunin` (LANE_ROOT derives from the script location), else
stale_basis reads 2. My before/after runs were in the real lane tree where the default is
correct.

## Landing hazards

- **Transient revert observed once**: during the first receipt batch, one invocation of the
  lane-tree `current-claims.py` printed argparse usage (old bytes, `--round` rejected) while
  adjacent invocations ran the edited bytes; edited bytes present before and after
  (`hazard-transient-revert.txt`: git status + shas + timestamp). All peers deny the write;
  R58ExecCounterC1 notes its driver materializes point-in-time tar snapshots, so a mid-copy
  read can show old shape. Receipt headers now pin the gate sha they ran; L1's landing
  re-measure is authoritative.
- Neighbors' in-flight edits at report time (`git status`): LOG.md, SCORECARD.md, SKILL.md,
  corpus/lessons/round-57.md, plans/round-58.md modified; untracked trial/instruments. My
  readings are point-in-time.

## Routed, not mine (for the L1's ledger)

- D8 is a different file: `plans/round-57-c1-check.py` docstring vs its own code (frozen bytes
  → erratum route) — R58CriticClaims; needs lesson/LOG coverage or I6 over-covers it.
- I2 vs the untracked `controls-prefreeze-epochC-final.txt` (`match=15` vs frozen `match=13`;
  A1 amendment pending) — L1/critic.
- Lane census red at BASE (`sources-census.sh` FAILED findings=4: S115/S116/S117
  missing-provenance + S117 used-by) — no C1 item covers it (R58ScribeLesson).

## Tooling

No tools installed or upgraded (none needed). No mutating git/jj command was run anywhere;
no fleet-root tracked file written; scratch deleted.
