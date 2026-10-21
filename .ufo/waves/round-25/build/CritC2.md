# CritC2 — layout skips and fleet absence

Revision reviewed: frozen BASE `4587c61a348e4528717404a68912c373f3ef4d03`.
Axes: **operability** (primary); **calibration** if a result reports CLEAN while omitting its check. No C1/C3 conclusion.

## Evidence at BASE

Exact command sequence run (setup/revision lookup chained with `&&`; isolated `HOME`; no `--allow-host-rows`):
```
mkdir -p /fast/scratch/kagi-r25/CritC2-2/home
git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/CritC2-2/lane
git -C /fast/scratch/kagi-r25/CritC2-2/lane checkout -q 4587c61a348e4528717404a68912c373f3ef4d03
git -C /fast/scratch/kagi-r25/CritC2-2/lane rev-parse HEAD
cd /fast/scratch/kagi-r25/CritC2-2/lane
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/CritC2-2/home bash corpus/claim-ledger.sh citations
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/CritC2-2/home bash corpus/claim-ledger.sh verify
```
Setup/revision lookup exited 0; revision printed exactly BASE. `citations` exited 1, stdout summary: `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`; `verify` exited 1, excerpt: `FAIL R11-08 reason=exit-mismatch exit=1 want=0`, final `CLAIM_LEDGER: FAIL (... host_skipped=12)`. This reproduces the documented lone-clone red (`corpus/lessons/round-11.md:192-208`) and gives the before state promised in the plan.

Relevant contract/code: `plans/round-25.md:38-55`; `corpus/claim-ledger.tsv:22` (R11-08); `corpus/claim-ledger.sh:554-560,1126-1132` (host rows are skipped; `C_HOST` is not a CLEAN failure condition); `:1155-1161` (`cells` likewise omits host skips); `:1164-1172` (citations currently become CLEAN iff unresolved/ephemeral are zero). Round-24 accepted `HOST-SKIP`/CLEAN for its default-safe host-row policy (`SCORECARD.md:882,899-903`), but its lesson explicitly classifies citations as non-host: it only reads lane docs and checks sibling/fleet path existence (`corpus/lessons/round-24.md:64-66`).

## Counterexamples / risks

1. **HIGH — a row-level `LAYOUT-SKIP` can turn the historically red lone-clone `verify` into CLEAN.** The plan requires `layout_skipped=N` and says the row is “never credited as passing,” but does not require the *overall* `verify`/`cells` verdict to be incomplete/nonzero when that count is nonzero. [INFERENCE] If the new skip follows the existing HOST-SKIP pattern (count and continue), current verify/cells failure predicates permit CLEAN. R11-08 is a required non-host citation check, not a prohibited host operation; R24 HOST-SKIP is not justification for treating this missing evidence as a passing overall gate. **Falsifier:** after implementation, run the exact BASE-clone `verify` above with empty HOME. Require `LAYOUT-SKIP R11-08`, `layout_skipped=1`, an `INCOMPLETE` (or equivalent non-clean) terminal summary, exit 1; `CLAIM_LEDGER: CLEAN`/exit 0 falsifies the claim that this preserves the gate. Repeat `cells` and require non-clean/exit 1. **UNRUN** against round-25 code (proposal only at reviewed revision).

2. **HIGH — an incomplete fleet can be misclassified as a lone clone unless the layout marker is independent of the cited target.** “Marker fixed by implementation” is not defined in the plan. If the marker is inferred from the presence of the sibling or `.ufo` target being checked, a genuinely broken/missing fleet citation can satisfy the “fleet absent” test and be downgraded to `FLEET-ABSENT`; that is a false absence, not a clone-layout limitation. **Falsifier:** in a scratch tree with the documented fleet marker present, remove/omit one cited sibling target and one cited `.ufo` target, then run `citations` on docs naming each. Require `UNRESOLVED`, `fleet_absent=0`, exit 1 (and in full-fleet `verify`, require `FAIL R11-08`); any `FLEET-ABSENT` classification falsifies the layout detector. Include a pristine fleet control where both targets resolve (`fleet_absent=0`). **UNRUN**; no round-25 detector exists at BASE. Marker must be documented before these cases can be implemented unambiguously.

3. **MEDIUM — `cells` can overstate scorecard audit coverage even if `verify` is repaired.** Plan names `cells`, but only requires a skip line/count; current `cells` CLEAN predicate excludes host-skipped rows (`claim-ledger.sh:1155-1161`), so a new layout counter must not merely inherit that treatment. **Falsifier:** in a lone clone, run `cells` with an otherwise-clean scorecard whose evidence points to R11-08; with `layout_skipped>0`, require an explicit incomplete/broken summary and exit 1, never `CELL_AUDIT: CLEAN`. Repeat with a full-fleet missing target and require a real row failure. **UNRUN** against round-25 code.

Smallest safe correction: specify the marker as a positive, independent fleet-root identity (not presence of the citation target); keep missing paths unresolved whenever that marker is present; and make any nonzero `layout_skipped` force `verify` and `cells` to an explicit non-clean `INCOMPLETE` result/exit 1. Keep lone-clone `citations` itself non-clean/exit 1 as already required by C2. No tools installed.