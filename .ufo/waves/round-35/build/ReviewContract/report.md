# ReviewContract — round 35 frozen calibration review

Axes: calibration accuracy, positive-control retention, immutable predeclaration, bounded claims. Read-only review of frozen controls and canonical BASE run logic; no candidate execution or candidate review is claimed. Recommendation only, not admission.

## Findings by severity

### Medium — the counter's success predicate does not validate a whole-process verdict

Location: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/measure.py:24-29`.

`finding` is an existential `startswith(kind + ' ' + name + ' ')`; `match` checks only that boolean and rc. It does not require an exact finding body, exactly one row, absence of contradictory findings, or the canonical final summary. Thus [INFERENCE, static counterexample, not executed] stdout `OK valid-zero garbage\nPREFREEZE: SETUP noresult\n` with rc0 satisfies that case, and an analogous NORESULT prefix with rc2 satisfies an invalid case without the promised final SETUP. A script emitting expected prefixes and exit codes can satisfy all nine while never producing an honest whole-process receipt. This matters under QUALITY QM19 and the plan's final-SETUP contract (plan line18), not just parser aesthetics.

Admission blocker: a green MEASUREMENT_RESULT alone cannot establish whole-process producer-result integrity. L1/non-author review must inspect the saved complete per-case receipts against canonical verdicts and actual candidate run logic. Do not amend the frozen instrument to erase this limit. The finding does not invalidate the precisely frozen rc/prefix mismatch statistic; it blocks a stronger claim based solely on that statistic.

### Low — identity is recorded, not enforced by the instrument

Location: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/measure.py:4-5,26-29`; `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-35.md:16`.

The instrument accepts any `--base`, records the selected script digest, and never checks its own bytes against input-identity.json. The frozen plan explicitly makes changed instrument bytes a kill condition. Admission therefore requires an external identity check and exact BASE/counter invocation; green stdout cannot establish these itself. This is an admission prerequisite, not an observed identity violation: current instrument hash and frozen files match, as detailed below.

## Requested control attacks

| Fixed case | Expected public rc / finding | Committed BASE result | Contract interpretation |
|---|---|---|---|
| setup-number | 2 / NORESULT | 0 / OK | Invalid SETUP-shaped producer output falsely admitted |
| failed-number | 2 / NORESULT | 0 / OK | Producer rc127 falsely admitted |
| diagnostic-number | 2 / NORESULT | 0 / OK | FAIL-shaped producer output falsely admitted |
| stderr-number | 2 / NORESULT | 0 / OK | Producer stderr falsely admitted |
| valid-zero | 0 / OK | 0 / OK | Valid acceptance retained |
| grep-empty | 0 / OK | 0 / OK | Valid grep count zero retained despite producer rc1 |
| empty-output | 2 / NORESULT | 2 / NORESULT | No-work command `:` is refused, not accepted as zero |
| wrong-count | 1 / MISMATCH | 1 / MISMATCH | A real wrong numeric value remains a mismatch |
| clean-forgery | 2 / NORESULT | 0 / OK | Numeric CLEAN summary is a known-bad admit at BASE |

Evidence: literal independent expectations at `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/measure.py:6-16`; complete previously executed outputs at `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/before.json:4-197`. Historical errors were not rerun.

The counter counts decisions, not fixture cardinality alone: lines24-26 compare each public invocation's actual rc and finding to fixed expected rc/finding. Five decision mismatches and five false CLEANs, two positive matches, and nine cases follow from the committed receipt. This is bounded QM13 calibration rather than a claim that nine authored fixtures constitute discernment. Expected outcomes derive from the frozen producer-result representation contract; they are not external/vendor truth or non-author agreement.

Canonical BASE code was read with `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 063c407494276d0c616e6c712a2e5d7aeb7e3768:corpus/prefreeze-control.sh`. In its run loop, only rc124 is refused; otherwise it takes the last nonempty line's final digit run and ignores stderr/other rc. Its final verdict prioritizes NORESULT -> SETUP exit2, then mismatch -> exit1, otherwise CLEAN exit0. That mechanism explains all five bad admits and the retained refusals; it is not inferred from fixture names. `grep-empty` runs on the extracted named BASE script, not candidate bytes.

## Observed chronology and identity

Read-only commands, all with explicit lane `-C`:

- `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin log --format='%H %P %s' -6 83ba8d1` showed direct ancestry BASE `063c407494276d0c616e6c712a2e5d7aeb7e3768` -> predeclaration `63ba87afce53842007ec27c09e3469132d149abd` -> freeze `83ba8d1aac70f0f04a2357471def9b19b2bdc794`.
- `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show --format=fuller --stat 63ba87af 83ba8d1` showed predeclaration adds only census-start and three control files; freeze adds only plans/round-35.md. Commit times were 2026-11-04 15:26:01 -0300 then 15:26:33 -0300. Ancestry, not author timestamps, establishes order. This does not independently prove remote push timing or absence of uncommitted work before freeze.
- `sha256sum /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/measure.py` yielded `e73cd1ffa315a7c864ad27c098f965abe5e8cd67e43da57afd8383579fac8f17`, matching input-identity.json.
- `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 063c407494276d0c616e6c712a2e5d7aeb7e3768:corpus/prefreeze-control.sh | sha256sum` yielded `ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a`, matching baseline producer identity and before.json.
- `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff 83ba8d1aac70f0f04a2357471def9b19b2bdc794 -- plans/round-35.md .ufo/waves/round-35/controls` produced no output. This checks tracked frozen bytes, not a claim about arbitrary untracked additions.

## Bounded limits versus blockers

Not blockers for the fixed nine-case statistic: no detection of a dishonest plain-integer rc0 producer or masked upstream pipeline failure; no proof of arbitrary producers, general sandboxing, all integer representations, multi-row interactions, or universal saturation. These are outside the causal population, and the important dishonest-integer limit is explicit at plan line18. The nine-case instrument does not itself exhaust every behavior named by the wider production contract (for example multiline output and rc1 with nonzero value); candidate review must establish those behaviors rather than calling nine-case success universal coverage.

Blockers for admission: any final mismatch/false CLEAN; fewer than two positive matches; missing case; changed instrument; wrong BASE; refused grep zero; unreviewed contradictory/truncated whole-process receipts; or a broader claim than the frozen measured population. Current review establishes predeclaration order and historical counter sensitivity, not repaired after-state performance. No candidate was considered before this attack, and no candidate success is inferred.

R25-02 FAIL, R29-01/R29-02 POLICY and non-owned SD6 remain explicitly routed by the frozen plan. This seat did not run or alter them. No canonical runtime replacement, rerouting, resume path, or saturation change is part of this assigned diff; none is certified here.

## Verification gaps and custody

`xd://lsp` is unavailable (device lookup returned “No such tool”); semantic references/definition/diagnostics could not be requested. Static source inspection is not semantic-server proof. The assignment's short `controls/measure.py` path does not exist at lane root; the canonical path is the frozen plan's `.ufo/waves/round-35/controls/measure.py`, which was read before analysis.

No builds, lint, fixtures, candidate counter executions, historical-error reruns, installs, production writes, git mutations, secret reads or account contact. No scratch or clone was created, so no scratch cleanup was necessary. Only this report was written. The narrower explicit seat-directory write bound was followed instead of the conflicting sibling `ReviewContract.md` suggestion.

Self-evaluation: accuracy4 (static counterexamples are labeled, candidate not exercised); completeness4 (remote push timing and candidate state deliberately unproven); clarity4 (detailed identity evidence lengthens the report); actionability4 (receipt/identity admission prerequisites are explicit but require L1 execution); conciseness4 (full case table retained for audit). Mean4.0. Highest-impact improvement is independent whole-receipt/candidate review, not changing frozen expectations. Would the user agree: likely, because exercised checks and inference are separated.

Report: .ufo/waves/round-35/build/ReviewContract/report.md
