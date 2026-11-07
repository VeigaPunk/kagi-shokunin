# Round 55 plan (frozen at the predeclaration commit)

Lane kagi, round 55, attempt 1. BASE `ebe095857a734caf5efdd7bd776feb22b4e23972` (round-54 verifier spot-check tip; `jj-lane.sh state` at start `ahead=0 tracked=0 untracked=0`, nothing inherited). Two claims on two axes, each with its own counter; the L1 holds the protocol planner seat.

## Axes

All six axes stand at 9 (SCORECARD round 54). Lowest non-retired axis: a six-way tie at 9; C1 works calibration (a lane-owned axis). Stagnation nudge: the last capability entered in round 52; completed rounds since are 53 and 54, so the N = 3 window has not elapsed and the nudge does not fire this round. Freshness (C2) is the second lane-owned axis.

## C1 — calibration: the registry's used-by cells record every entry that names the row

Motivating evidence (measured at BASE, `bash plans/round-55-c1.sh ebe09585…` ⇒ `value=25`): 25 (row, entry) pairs where a knowledge entry names a registry id in its text while the row's `used-by` — the lane's own statement of which entries cite it — omits the entry. Round-54 closure D1 found one of them (S112 and `op-ref-consumption.md`); the census never saw any because SC_USEDBY_NOCITE and SC_ENTRY_CITE read only the `source:` line. The pairs: S012, S022, S047, S050 in `oidc-federation-trust-policy.md`; S017, S018, S020 in `cdp-bridge-1password-oidc-workflow.md`; S017–S020 in `onepassword-machine-credentials.md`; S021, S022, S023, S105 in `vault-openbao-token-lease-lifecycle.md`; S024 in `openbao-kv-v2-version-lifecycle.md`; S048, S055, S056 in `secret-scanning-detection-vs-validation.md`; S049 in both NIST entries; S072, S112 in `op-ref-consumption.md` (legacy); S103, S104 in `sops-age-key-rotation.md`.

Landing: each entry records the ids it names outside its support line on one column-1 `cites:` line (cross-references, later-section sources, and every id a legacy entry names; `cites:` does not make an entry sourced); each row's used-by lists the entry; `corpus/sources-census.sh` gains SC_BODY_CITE (an entry naming a registry id on neither its `source:` nor its `cites:` line; a `cites:` id that is not a row or whose used-by omits the entry; two `cites:` lines) and SC_USEDBY_NOCITE accepts the id on the `cites:` line; eight selftest cases (three positive controls), and the `cite-no-id` case expectation moves 3 → 5 (its fixture's `recheck:` line names S001/S002 once the source line is stripped, which the new rule reports).

Frozen predicate: `C1_USEDBY_GAP: value = GAP when GUARD = 1, else FAIL; target 0 (BASE 25).` Counter `plans/round-55-c1.sh` (definitions of CITATION, GAP and the guard conjuncts g1–g5 in its header, verbatim the claim's rule).

Kill rules: the counter, this plan and the controls script are unchanged between the predeclaration and the candidate (`git diff --quiet <predeclaration> <candidate> -- plans/round-55.md plans/round-55-c1.sh plans/round-55-c2.sh plans/round-55-controls.sh`); a reading other than `value=0 … guard=1` at the candidate is a miss, reported as such, never re-scoped.

Named ceilings: lessons are outside the population; ids in a form the token rule does not match are not counted; g5 runs the measured tree's own census (a printer census passes g5; g4 is the independent NOCITE check that kills padding).

## C2 — freshness: the ISO/IEC 11770-3 entry names the amendment in force and its recheck clock reads true

Motivating evidence: `corpus/knowledge/iso-11770-3-edition-status.md` (round 45) says the IEC record "names a newer amendment to the 2021 edition" and leaves it unnamed; the ISO catalogue records opened 2026-11-07 show it is ISO/IEC 11770-3:2021/Amd 1:2025 (TFNS identity-based key agreement, published 2025-04, stage 60.60), listed in the 2021 edition's life cycle. The entry's `recheck:` command states `-> 1` for `grep -c 'Withdrawal of International Standard'` on S101, while the committed round-45 capture (sha256 `2e4c1524…`, byte-identical to the 2026-11-07 live body) gives 2: the clock reports a change on every run although nothing changed. BASE reading `value=0 amd=0 recheck=0`.

Landing: rows S113 (ISO record of the 2021 edition) and S114 (ISO record of Amd 1:2025), both opened 2026-11-07, captures `.ufo/waves/round-55/capture/S113.body`, `S114.body`, fetch and quote-body rows; the entry gains a section naming the amendment with `[S114]`/`[S113]` citations, both ids on its `source:` line, and a `recheck:` line whose two commands state the counts the captures give (S101 `-> 2`, S113 `-> 3`).

Frozen predicate: `C2_ISO_CURRENT: value = AMD + RECHECK when GUARD = 1, else FAIL; target 2 (BASE 0).` Counter `plans/round-55-c2.sh` (AMD conjuncts a–d, RECHECK and GUARD in its header, verbatim the claim's rule).

Kill rules: as for C1 (same four files unchanged); the S114 capture sha256 `8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf` is frozen in the counter.

Named ceilings: committed bytes only; a recheck command whose quote is true of the capture but not discriminating scores; the live re-fetch by a non-author is the check of currency on the day.

## Causal separability

C1 lands without C2 (BASE + the census change, cites lines and used-by cells reads `value=0`; C2's new rows name only the ISO entry and the round lesson, which already record them on `source:` lines). C2 lands without C1 (BASE census accepts S113/S114 because the entry carries them on its `source:` line). Neither counter reads the other claim's surface beyond the census exit.

## Pre-freeze controls

`plans/round-55-controls.sh <reference tree>` runs 22 controls with expectations fixed in the script before the run: C1 BASE 25 (no-work), reference 0, and nine forgeries/fail-closed (strip a mention, pad a used-by cell, pad all with a printer census, delete an entry, symlink an entry, rewrite a token, delete a row, land without the gate change, withdraw one record) all `FAIL`; C2 BASE 0 (no-work), reference 2, and nine forgeries (stale expectation, absent quote with `-> 0`, tampered capture, uncited statement, amendment id off the `source:` line, S101 row edited, recheck on a foreign URL, wrong opened date, symlinked capture) reading 1 or `FAIL`. Receipt: `.ufo/waves/round-55/controls/controls-prefreeze.txt`.

## Frontier step

Census before/after with `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`; C2 is the sourced claim (S113, S114 opened this round); one mistake mined into `corpus/lessons/round-55.md` `## Mistakes` (the round-45 recheck expectation stated 1 against a body that gives 2; the used-by drift the gate could not see).
