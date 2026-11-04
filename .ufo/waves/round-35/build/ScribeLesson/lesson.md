# Round35 lesson draft — Gate and Mistakes

Draft for L1 installation only. This seat read sources and existing receipts; it ran no gate, counter, selftest or mutation. Calibration is the sole claimed axis; freshness, coverage, depth, operability and adjacency receive no new claim here. No round35 after-result or non-author admission is asserted.

## Gate

**Frozen claim.** `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-35.md` fixes BASE `063c407494276d0c616e6c712a2e5d7aeb7e3768` and nine public-path cases. `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/before.json:195-197` records mismatches=5, invalid_false_clean=5, positive_matches=2. The frozen plan reports the instrument's before exit1. The unchanged after acceptance predicate is `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`, exit0. That is a target, not an execution observed by this scribe. Any mismatch, omitted case, unexpected rc/finding, changed instrument or refused positive control defeats C1.

**S088 reopened this round.** On 2026-11-04 this seat read the registered row at `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md:95`, the knowledge entry at `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:1-103`, and the published source directly:

https://raw.githubusercontent.com/VeigaPunk/kagi-shokunin/97b35ceec87cceac25d1e0e5f92f75c953728802/corpus/prefreeze-control.sh

Located quote (header measurement rule, lines15–16; 13 whitespace-delimited words, with comment markers omitted): **“Measurement = the final run of digits on the LAST non-empty stdout line.”** The pinned source explicitly ignores producer exit codes except timeout handling; this is implementation evidence, not independent truth about a command or sandbox confinement. The source at that revision describes eleven selftest cases, not the later twelve-case implementation.

The local own-work gate was also read this round at `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh:15-34,253-288`. At reading, its header retained the last-digit rule; code stored `rc`, special-cased124, selected the last nonempty stdout line and extracted trailing digits; stderr did not participate in the comparison. Located local quote, lines18–19, 17 words with comment markers omitted: **“Exit codes are deliberately ignored (`grep -c` exits 1 while printing 0, which is a measured 0).”** This records the read-time source, not a claim about an independently installed round35 candidate.

| Candidate interpretation | Decision | Source-grounded basis and flip |
|---|---|---|
| S088 at its named revision implements a last-nonempty-line/final-digit numeric BASE comparator and deliberately permits `grep -c` zero with rc1 | ADMIT, bounded own-work implementation reading | Published header measurement rule and loop agree. It establishes what those bytes implement, not the correctness of arbitrary counters. Recheck on gate change. |
| A CLEAN from that implementation proves a producer succeeded, emitted only a measurement, or performed real work | REJECT | Five frozen public-path witnesses below contradict this reading. Flip only to a source-bound, narrower producer-result contract with observed refusal and retained acceptance controls; even that does not establish arbitrary producer honesty. |
| General soundness against deliberately dishonest integer output or pipelines masking upstream failures | REJECT / outside this claim | The frozen plan explicitly excludes this guarantee. A plain integer and acceptable status can be fabricated; do not rename syntax validation as semantic validation. |

**Outside spotcheck remains pending.** These are lane-authored decisions for later non-author review. Neither this seat nor other dispatched seats supply outside admission or promotion.

### Actual frozen counterexamples and controls

Evidence source for every gate output/rc below: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/controls/before.json:5-193`. These are existing receipts read, not commands rerun. Commands in the producer column are literal frozen fixture commands; only the gate rc is separately recorded by this JSON. Each gate invocation is recorded in that case's `argv`: `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh run --base 063c407494276d0c616e6c712a2e5d7aeb7e3768 --controls <that case's recorded TSV> --work <that case's recorded work directory>`.

| id | Frozen producer command | Actual gate stdout (line break shown as `<br>`) | Actual gate rc | Frozen expected rc / finding |
|---|---|---|---:|---|
| setup-number | `printf "PREFREEZE: SETUP producer 0\n"; exit 2` | `OK setup-number expect=0 measured=0`<br>`PREFREEZE: CLEAN (controls=1 mismatch=0)` | 0 | 2 / NORESULT |
| failed-number | `printf "0\n"; exit 127` | `OK failed-number expect=0 measured=0`<br>`PREFREEZE: CLEAN (controls=1 mismatch=0)` | 0 | 2 / NORESULT |
| diagnostic-number | `printf "FAIL rows=0\n"` | `OK diagnostic-number expect=0 measured=0`<br>`PREFREEZE: CLEAN (controls=1 mismatch=0)` | 0 | 2 / NORESULT |
| stderr-number | `printf "0\n"; printf "producer unavailable\n" >&2` | `OK stderr-number expect=0 measured=0`<br>`PREFREEZE: CLEAN (controls=1 mismatch=0)` | 0 | 2 / NORESULT |
| clean-forgery | `printf "PREFREEZE: CLEAN (controls=0 mismatch=0)\n"` | `OK clean-forgery expect=0 measured=0`<br>`PREFREEZE: CLEAN (controls=1 mismatch=0)` | 0 | 2 / NORESULT |
| valid-zero | `printf "0\n"` | `OK valid-zero expect=0 measured=0`<br>`PREFREEZE: CLEAN (controls=1 mismatch=0)` | 0 | 0 / OK |
| grep-empty | `grep -c QQQ_NO_MATCH_R35 corpus/prefreeze-control.sh` | `OK grep-empty expect=0 measured=0`<br>`PREFREEZE: CLEAN (controls=1 mismatch=0)` | 0 | 0 / OK |
| empty-output | `:` | `NORESULT empty-output expect=0 (no integer)`<br>`PREFREEZE: SETUP noresult` | 2 | 2 / NORESULT |
| wrong-count | `printf "1\n"` | `MISMATCH wrong-count expect=0 measured=1`<br>`PREFREEZE: MISMATCH (controls=1 mismatch=1)` | 1 | 1 / MISMATCH |

The receipt's outer stderr field is empty for all nine cases. In stderr-number, that does **not** prove the producer was silent: the fixture writes producer stderr, and the baseline gate redirects it internally. Do not conflate wrapper stderr with producer stderr.

### Historical non-author constraints carried forward

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-32-verifier-spotcheck.md:59-67,129-153`: calibration C1 rejected because actual8→1 did not meet frozen0; BASE10/SD5=3 were estimates. Partial repair is not admission. Mistakes must identify a criterion or `none`, with a genuine red-before witness. Non-owned SD6 remains untouched.
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33-verifier-spotcheck.md:46-82,139-169`: prefreeze capability accepted within bounds; C2 rejected because captures111 was unmet. M7 and relative-work execution claims were unbacked then; later receipts cannot make them observed earlier. Cite each output to its actual producer.
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-34-verifier-spotcheck.md:21-41,43-58,92-97`: bounded SD7–SD9 and operability results accepted with source-bound receipts; C3 rejected at rows88/sourced14/captures88 rather than frozen87/13/87. The frozen awk's missing/SETUP→zero behavior motivated R34-2; preserve historical instrument bytes, declare a new contract instead.

**considerthese decision: NONE adopted.** Latest dated file discovered and read: `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/2026-10-26.md:47-65`. Proposal1 changes operator HOLD policy; proposal2 duplicates the existing status surface acknowledged by the round32 outside check; proposal3 names historical tokenizer D1, not this round's producer-validity predicate, and adding a warning would not repair invalid measurements; proposal4 writes operator-owned input state. No operator input edited, and no stale HOLD description treated as current authority.

## Mistakes

| id | class | evidence | captured-by (before) | fix / falsifier, with observation status |
|---|---|---|---|---|
| M35-1 | A parseable number was accepted as a valid producer result | Frozen setup-number, failed-number, diagnostic-number, stderr-number and clean-forgery each print `OK <id> expect=0 measured=0` then `PREFREEZE: CLEAN (controls=1 mismatch=0)`, actual gate rc0, where the independently frozen expected result is NORESULT/rc2 | QM19 (whole-process validity), QM3 (failure accounting), QM13 (bounded calibration); proposed QM37 makes the producer-specific rule explicit | Existing frozen nine-case receipt is the failing-before witness, not an after-pass. The round35 declared repair accepts one nonempty integer stdout line, no stderr, and producer rc0 or rc1 with zero; all other results fail closed NORESULT/final SETUP rc2. Acceptance requires unchanged instrument mismatches0/false-clean0/positive-matches2/cases9, exit0. This seat did not execute or observe that after-run. |
| M35-2 | Execution evidence could be upgraded from a source reading or later reproduction | Round33 outside R33-2/R33-3 identifies unobserved mutant/retest claims; round34 outside lines35–39 distinguishes source-bound raw failure receipts from normalized summaries | QM36 | Retain actual output plus rc and named source identity. Current lesson records existing before outputs/rc only; it asserts no candidate PASS and does not backdate round34 evidence into round33. |
| M35-3 | Frozen arithmetic or a bounded comparator could be widened after data | Round32 C1 residual1; round33 C2 captures82 vs111; round34 C3 rows88/sourced14/captures88 vs87/13/87; all remain rejected in the cited outside records | QM13, QM29, QM34 | Preserve all historical rejections and the exact round35 predicate. Independently measured populations are reporting invariants, not a second claim or replacement target. Semantic command truth, confinement and dishonest plain-integer output remain excluded. |

### QM37 proposal — producer-result validity

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM37 (PROPOSED, not installed) | Supplements QM19/QM3/QM13: a numeric comparison first validates the producer result against its declared stdout/stderr/exit contract. For this prefreeze numeric contract, accept exactly one nonempty integer stdout line, empty stderr, and rc0 or rc1 with value zero; any other result yields NORESULT and final SETUP exit2, never CLEAN. Preserve source identity, actual gate output/rc and independently fixed expected findings; retain valid-zero and grep-empty acceptance controls beside invalid-result witnesses. This checks result shape/status, not producer honesty, arbitrary command truth or masked pipeline failures. | Last-digit extraction certifies diagnostic text, failure status, stderr or a forged numeric CLEAN as `OK`; refusal-all removes the two valid controls. | Proposed `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-35.md` M35-1; frozen before receipt above, especially failed-number and clean-forgery output/rc0. That lesson path is an installation target, not evidence of an already landed file. |

The criterion has actual red-before counterexamples, but this draft does not call its repair verified. It adds no source row, knowledge entry, registry append, population claim, assimilation or general soundness guarantee. R25-02 FAIL, R29-01/R29-02 POLICY and non-owned SD6 findings remain routed, not cleared.
