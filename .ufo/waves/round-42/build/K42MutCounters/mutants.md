# K42MutCounters — round-42 counter mutation battery (pre-freeze attack)

Claim BASE e8265c0 · probe checkout 98dd4de (predeclaration; pre-A1 bytes — see provenance) · all runs in scratch clone `/fast/scratch/hyaku/kagi-r42/K42MutCounters/work` (toplevel verified) · no lane tree writes.
Kill rule (frozen): killed = any control differs from its expected value (C1: BASE 4, blanket-refuse 0, blanket-accept 0; C2: BASE 0, derivation D 1).

Pristine reproduction at 98dd4de (all five frozen receipts reproduce exactly): c1 = **4 / 0 / 0**; c2 = **0**; fresh derivation D = **1** (`c2-derivation-D-fresh.txt`); clean-clone runner receipt R = **3** (`c2-rside-clone-receipt-value.txt`, matches `c2-worktree-at-base.txt`).

## C1 — `plans/round-42-c1.sh` (5 mutants × 3 controls)

| mutant | mutation (smallest behavior-bearing point) | BASE (exp 4) | refuse-all (exp 0) | accept-all (exp 0) | killed | survivor reason |
|---|---|---|---|---|---|---|
| c1-M1 | P0-gate output and final output hardcoded to 5 | 5 | 5 | 5 | yes | — (all three controls differ from expected) |
| c1-M2 | output = 4 if F5 refused (rc 1 + exact token) else 5; F1–F4 count discarded | 5 | 0 | 5 | yes | — (BASE and blanket-accept differ) |
| c1-M3 | P0 gate block deleted (refused P0 no longer forces N=0) | 4 | 0 | 0 | **NO** | Battery never exercises a gate that refuses P0 with a *valid frozen token*: the frozen blanket-refuse fixture refuses token-lessly (`EXPECT_JOURNAL: REFUSED (violations=1)`), which the per-token `grep -qxF` already filters to 0. Demonstrated: against a token-refusing gate (`REFUSE UNJOURNALED R13-01`, rc 1) M3 reads **1** (`c1-M3.refuse-token.txt`) while pristine reads **0** (P0 gate bites, `pristine-c1.refuse-token.txt`) — that gate shape is absent from the frozen battery. |
| c1-M4 | F5 check line deleted; output hardcoded 5 | 5 | 0 | 5 | yes | — |
| c1-M5 | `check()` counts rc==1 only; token-line grep dropped | 4 | 0 | 0 | **NO** | No frozen control refuses a forgery with rc 1 and a wrong/absent token: blanket-refuse is filtered upstream by the P0 gate, BASE refuses carry valid tokens anyway, blanket-accept never refuses. M3+M5 together read 4/0/0 on the whole battery — C1 battery discrimination is value-only. |

## C2 — `plans/round-42-c2.sh` (3 mutants, claim-BASE reading; exp 0)

| mutant | mutation | BASE (exp 0) | killed | survivor reason |
|---|---|---|---|---|
| c2-M1 | decision → constant 1 (clone + D + runner body intact) | 1 | yes | — (c2-base control 0 ≠ 1 kills it; the assignment's predicted "M1 survives" does **not** occur for the counter mutant) |
| c2-M2 | D derivation and clone-runner run dropped; reads the worktree's *committed* receipt, N = (receipt == 1) | 1 | yes | — killed at BASE because the committed round-41 receipt in the 98dd4de tree reads 1 (stale) while the true reading is 3: the mutant reproduces the round-41 staleness defect and the value control catches it |
| c2-M3 | D derivation dropped; decision N = (R == 1), clone+runner kept | 0 | **NO** | At BASE R=3 already fails the ==1 comparison, so dropping D changes nothing there; the D==1 conjunct is only distinguishable in a world with D≠1 (or, post-A1, a candidate-edited `plans/round-41-c2.sh`), and the battery never creates either input. |

## Ceiling probe (the plan's named ceiling, now with a receipt)

Patched `plans/round-41-controls.sh` in a scratch clone of 98dd4de (worktree-only edit, **no commit created**) to `echo 1 > "$OUT/c2-base-19025d9.txt"` instead of deriving: measured receipt = **1** (`c2-ceiling-receipt-value.txt`). With D = 1 (`c2-derivation-D-fresh.txt`), the pristine counter's decision (D==1 && R==D) is **1** — no frozen C2 control inspects the runner's source, so a constant-1 runner passes at the candidate while c2-base (0 at BASE) and D (1) both hold. This is the ceiling declared in plans/round-42.md §C2; the reviewed-candidate-runner is the control the plan names. The assignment's predicted finding ("M1 survives any control that does not know the runner's source") occurs on the **runner side**, not for counter-mutant M1.

## Provenance, honesty, restoration

- Mutants built from the seat's pinned checkout **98dd4de = pre-A1 bytes** (c2 header: "copied from the candidate"; D line: `cp -- "$SCR/clone/plans/round-41-c2.sh" ...`). A1 (fdbb83d) changes only the D source to `git show 5142b52:plans/round-41-c2.sh` (+header). At the claim BASE the candidate copy *equals* the frozen counter, so D = 1 either way — every value above is A1-invariant. Under A1, c2-M3's dropped step also carries the 5142b52 source pin; its survivor verdict is unchanged (the battery never exercises a candidate-edited round-41 counter nor D≠1).
- sha256 (`hashes.txt`): pristine sandbox c1 `05133bff…` == lane `plans/round-42-c1.sh` (lane untouched by this seat); pristine sandbox c2 `1079df84…` == `git show 98dd4de:plans/round-42-c2.sh` (lane worktree's `693e495a…` is A1 fdbb83d, not my edit); per-mutant hashes recorded.
- Restoration evidence: `git diff-index --name-only HEAD` in the sandbox is empty (`sandbox-tracked-changes.txt`); `status --porcelain -- plans/` shows only the 8 untracked mutant copies (`sandbox-plans-status.txt`); originals byte-identical to their pinned blobs.
- Every run: rc recorded in `receipts/*.txt`; full command list in `receipts/commands.log`; battery script at `receipts/battery.sh`. Exit codes: all mutant/control runs rc=0; one counter (`c1-counter`) fail-closed path not triggered (P0 accepted throughout).
- No tool installs or upgrades were made (bash, git, python3 sufficed). Scratch dir deleted before yield.
