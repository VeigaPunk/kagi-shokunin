# ConnScope — bounded overlap and historical-control coupling

## Axis and evidence status

Declared axis: **calibration**, specifically producer-result integrity, not general soundness or research-method acquisition. Frozen C1 is `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9` (plans/round-35.md:6–22).

This seat performed static reads/searches only. No gate, sibling command, candidate, fixture, clone, account operation or host-private probe was executed. No tools installed; no scratch created, so no scratch remains to remove. Existing before.json is attributed recorded evidence, not this seat's execution: it records five false-CLEAN cases, two accepted controls, and retained empty-output/wrong-count refusals. Instrument identity is recorded in controls/input-identity.json: `e73cd1ffa315a7c864ad27c098f965abe5e8cd67e43da57afd8383579fac8f17`.

Paths in citations below are relative to the cited lane; all Kagi paths resolve under `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

## Bounded sibling-overlap evidence

Discovery used `glob` over `/home/vgpnk/Projects/shokunin/*/SKILL.md` and `*/PROVINCE.md`, followed by `grep` on those declarations for `fail.closed|fail-closed|false.CLEAN|result.envelope|NORESULT|calibrat|exit.code|exit.status|stderr|stdout|research method`. The broad search was truncated/paginated by the tool; it is NOT an exhaustive absence sweep. Focused follow-up covered tameshi, kumitate, kengaku and kasegi declarations, plus chousa ownership and its specific preflight row. No sibling implementation or private substrate was executed/read. These are concrete analogies, not a universal uniqueness claim.

| Owner | Local declaration evidence | Analogy and useful command (NOT EXECUTED) | Boundary |
|---|---|---|---|
| tameshi L1 | tameshi-shokunin/PROVINCE.md:3–17; SKILL.md:502–550 | Exit plus final verdict must agree; zero-work is not green; SETUP/POLICY/deferral are different arms. The documented recipe requires retaining the before-set and an explicitly enumerated normalization policy. | Owns reusable verification-fixture craft, not sibling gate code. Kagi applies that craft to its own producer gate; it must not claim the method as new domain ground. |
| kumitate L1 | kumitate-shokunin/SKILL.md:607, `counter-receipt` registry row | `node scripts/counter-receipt.mjs --receipt FILE` reconciles denominator, unique case names, prefix, ok/FAIL counts, verdict and ordering. Documented exits 0/1/2/64 distinguish clean, drift, fail-closed and usage. | Arm-form transcript contract `kumitate-counter-receipt-v1`; not a parser for arbitrary Kagi numeric producers. Importing it would add an incompatible representation, not establish producer truth. |
| chousa L1 | chousa-shokunin/PROVINCE.md:3–17; SKILL.md:154 | `python3 corpus/evidence/round63/c1-battery-v2.py --tool tools/lane-preflight.py --fleet FLEET --work DIR` documents clean/defect/benign/zero legs and strict output validation, including no non-contract stdout lines and distinct summary members. | Research question framing, hierarchy and claim-vs-source verification remain chousa's. Its eight-gate preflight and historical battery are not authorized checks for this seat and are not Kagi C1 evidence. |
| kengaku L1 | kengaku-shokunin/SKILL.md:598–600; PROVINCE.md:361–364 | `python3 plans/grader_perturb.py --summary` is a **probe** whose documented exit 0 can include family FAIL findings; `python3 plans/attrib_calibration.py --summary` is a **gate** with a different exit contract. | A completed measurement is not necessarily an affirmative verdict. Model attribution/eval interpretation stays kengaku's; its declarations explicitly credit tameshi's method. |
| kasegi L1 | kasegi-shokunin/SKILL.md:846–858 | Historical EV-report declaration distinguishes UNKNOWN values from numeric zero and notes malformed-input completion can still exit 0. | Historical/lost-base scope is explicit there. Do not run its external-target tools or treat its exit map as interchangeable with the Kagi scalar producer contract. |

**Assessment:** the frozen Kagi repair does not absorb research method when described as a local result-envelope check. It does not choose sources, rank evidence, verify vendor truth or generalize a new fixture methodology. Kagi PROVINCE.md:93,106–110 already reserves research method to chousa; QUALITY QA7/QM13/QM19 already bounds local calibration and whole-process evidence. The tameshi overlap is stronger than the chousa overlap: reusable verdict/fail-closed discipline already has an explicit sibling owner.

## One bounded proposed move: contract-generation disposition matrix

L1 should accompany the producer-parser cutover with an explicit **historical-versus-current disposition matrix**, without changing any frozen controls, instrument, historical receipts or C1 target. This is a documentation/integration recommendation only; this seat does not install or admit it.

The non-obvious coupling: `--base` selects the measured tree, but the invoked parser remains the current selected script, and `$LANE` points at the live repository. Therefore replaying an old controls table through a new parser is NOT necessarily replaying the old experiment. Producer grammar and counter identity must travel with a historical receipt.

Static evidence: corpus/prefreeze-control.sh:249–258 extracts BASE, then executes commands in that extraction with `LANE=$REPO`; :265–270 currently reads the final digit run on the last nonempty line. The frozen plan replaces this with a single nonempty integer stdout line, empty stderr, rc0 or rc1-with-zero. Historical controls deliberately contain non-scalar producers.

| Surface / owner | Explicit recommended disposition | Reason / risk |
|---|---|---|
| round-35 controls/measure.py, input-identity.json, before.json / L1 | Immutable instrument and before receipt; candidate only changes production contract. Keep all nine case identities and independent expectations. | No expectation amendment or counter widening to make the candidate pass. |
| plans/round-34.controls.tsv `sd789` / L1 historical evidence | Preserve original row/helper and receipt as historical under the old parser; do not interpret a new-parser NORESULT as proof the old SD measurement changed. | `.ufo/waves/round-34/controls/sd789-base.sh:49–50` emits a diagnostic count line AND `SD789_SUM=N`; it violates the new plain-single-integer grammar even if the arithmetic is correct. |
| round-34 `prefreeze_cases`, `sweep_selftest_cases` / L1 historical evidence | Historical-only replay semantics; new active counters, if ever needed outside this freeze, require explicitly new producer definitions, not edits to these rows. | Both commands end in textual selftest summaries via `tail -1` (round-34.controls.tsv:5–6); those are not plain integer lines. Their old expected counts stay historical. |
| round-32 `sd5`, `total` / L1 historical red witness | Preserve the rejected expectations and original MISMATCH receipt; distinguish a later NORESULT from the historical count mismatch. | These rows pipe a failing gate into grep/cut or sed (round-32.controls.tsv:3–4). A downstream scalar can mask upstream failure. Strict final-output parsing does not resolve that admitted ceiling. `$LANE/corpus/self-description-sweep.sh` also selects live helper bytes. |
| round-33 scalar controls / L1 | Leave frozen rows and receipts unchanged. Classify as scalar-shaped, not newly proven compatible without execution. | `nist_entries` and `frontier_nist` are pipelines; suppressed `ls` errors and absent pipefail can yield valid numeric output. Representation validity is not producer honesty. |
| current production header / SKILL registry / PROVINCE description / L1 | Update active wording together at cutover; keep historical last-integer descriptions explicitly dated. | Existing prefreeze header:15–34, SKILL.md:820 and PROVINCE.md:77 still document the old grammar. Leaving these active would contradict the installed contract. |
| SD6; R25-02 FAIL; R29-01/R29-02 POLICY / existing owners via L1 | Preserve and explicitly route unchanged; none is cleared by C1. | A producer-integrity repair neither repairs unrelated self-description nor authorizes forbidden execution. |

### Contradictions that must stay visible

1. Tightening the grammar improves calibration but rejects historical textual-count producers. Keeping those live unchanged while claiming universal backward compatibility is contradictory; weakening the parser to accept them reopens the false-CLEAN class. Preserve historical semantics, not a compatibility shim.
2. A scalar pipeline with rc0 can pass the envelope while its upstream command failed. The frozen plan expressly excludes dishonest valid integers/pipeline masking. Do not claim end-to-end producer truth from nine representation cases.
3. Historical count mismatch and current representation NORESULT are distinct findings. Never relabel one as the other to erase the rejected round-32 claim.
4. Output instructions name both `build/ConnScope/` as the only writable namespace and `build/ConnScope.md` as a report destination. This seat chose the stricter directory-only boundary; the durable report is `build/ConnScope/report.md`, with no sibling-path write.

## Effects, risks and verification handoff

Affected declared axis: calibration only. Proposed benefit [INFERENCE]: explicit dispositions prevent a stricter producer contract from being mistaken for changed historical measurements while keeping the five invalid producers refused and the two valid controls retained. No other declared axis improvement is claimed. Keeping frozen bytes, old receipts, scope ownership and refusal routes unchanged is the no-harm condition, not a measured new result.

Runtime: retain raw rc/stdout/stderr in the frozen measurement receipt; parser failure is SETUP, never a count mismatch or CLEAN. Contract: document the new scalar envelope separately from historic last-integer rules. Substrate: BASE extraction is not a sandbox; no host/account permission follows from it. Verification: a new parser's nine-case success cannot certify every old table or every pipeline.

Authorized C1 handoff to L1, copied from the frozen plan (NOT EXECUTED here; run from lane root):

```sh
python3 .ufo/waves/round-35/controls/measure.py --script corpus/prefreeze-control.sh --base 063c407494276d0c616e6c712a2e5d7aeb7e3768 --out .ufo/waves/round-35/final/after.json --work /fast/scratch/hyaku/kagi-r35/L1
```

Required outcome: exit0 and exact frozen predicate, with unchanged instrument bytes, all nine rows, invalid findings NORESULT, valid-zero/grep-empty retained, wrong-count still MISMATCH, empty-output still refused. Compare the instrument against the recorded SHA-256 above. Do not rerun historical controls merely to obtain green; if L1 authorizes a historical compatibility investigation separately, preserve old/new parser identity and old/new verdict categories as distinct receipts. No such additional check was executed or claimed here.

Self-evaluation: accuracy 4/5 (static declarations and attributed receipts, not runtime candidate evidence); completeness 4/5 (concrete ownership and historical dispositions, explicitly bounded nonexhaustive sweep); clarity 4/5 (historical/current separation is explicit); actionability 4/5 (L1 owner and frozen command supplied, implementation intentionally outside this seat); conciseness 4/5 (matrix retains the necessary coupling detail). Mean 4.0/5. No scalar acceptance judgment follows from these self-ratings.

Report: .ufo/waves/round-35/build/ConnScope/report.md
