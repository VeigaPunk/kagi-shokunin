# MutKnowledgeBase — frozen-BASE C1 mutation probe

Author: `KagiR26.MutKnowledgeBase-17` (lane-authored mutation evidence, not non-author closure).

BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b`.

Axes: **calibration** — whether CLEAN notices a false current-tense knowledge-entry number; **freshness** — C2 release-clock regression refusal was not independently exercised by this assignment.

## Result

**SURVIVED.** Pristine, one-digit-mutated, and exactly restored bytes each returned exit **0**, with the identical last nonempty line:

```text
SELF_COUNTS: CLEAN (claims=38 stale=0)
```

The pristine detector passed, so this is a surviving mutant, not a baseline-failure/inconclusive result. It establishes the requested BASE coverage gap only; it neither changes the reviewed C1 population nor judges an after implementation.

## Mutant and concrete counterexample

All source locations below refer to the frozen BASE, not the concurrent lane working tree.

- `corpus/knowledge/claim-ledger.md:226-229` states that a by-hand declaration's reason must have **at least 24 characters**. This is an undated current-tense bound on the lane's own gate, not a historical case-count quotation. The same bound is explicitly named at `corpus/knowledge/claim-ledger.md:425-426`.
- Its defining implementation is `corpus/claim-ledger.sh:1172-1177`: surrounding whitespace is trimmed, then `[[ ${#reason} -ge 24 ]]` is enforced, with the stated-floor diagnostic also naming 24.
- In the isolated copy only, changed the single ASCII digit `4` to `5` at `corpus/knowledge/claim-ledger.md:226`:

```diff
-  `_serve` env), `interactive-only`, `vault-refusal`. The reason must be ≥24
+  `_serve` env), `interactive-only`, `vault-refusal`. The reason must be ≥25
```

This makes the documented bound false relative to the unchanged defining implementation: the prose says 25 while the code still says 24. Only one byte differed, at zero-based offset **13630** (`0x34` → `0x35`); the file remained **34510 bytes**. No script, binding-table, or ledger-pin bytes were changed.

**Expected detector:** the assigned `python3 -B corpus/self-counts.py`. Expected frozen-BASE behavior was CLEAN/exit0 despite the false knowledge number; that is exactly what occurred. No after-tool STALE result is claimed.

## Why the BASE detector misses it

`corpus/self-counts.tsv:3-10` declares its existing population as selected numbers in `SKILL.md`, `PROVINCE.md`, and `corpus/README.md`. Its complete data population, `corpus/self-counts.tsv:15-52`, contains 38 bindings and no `corpus/knowledge/*.md` document binding.

`corpus/self-counts.py:306-327` loads that table and extracts numbers only from the documents selected by its claims. `corpus/self-counts.py:357-374` compares those selected claims and emits CLEAN if their counters remain zero. The normal run does transitively invoke existing local ledger commands, including the knowledge declaration audit; those do not turn the modified paragraph's numeric bound into a self-count binding. In particular, `corpus/knowledge/claim-ledger.md:239-245` explicitly distinguishes declaration/stamp membership from hash freshness.

The complete combined output was byte-identical across all three detector runs: **39 lines**, SHA-256 `141bbb8d982dd9fd2e1891320cb6b1054d95b5abdcf62147e844fada7feb6ffc`.

## Exact execution and actual outputs

Created a metadata-free frozen scratch copy by extracting the output of:

```text
argv: ["git", "archive", "--format=tar", "0a47dd189356ea66ec83c3891eed54526e95b89b"]
source cwd: /home/vgpnk/Projects/shokunin/kagi-shokunin
```

This materialization reads Git objects; it does not change the lane's Git index or checkout. The target document, detector, binding table, and ledger bytes each matched `git show BASE:<path>` before the probe.

For **each** detector run:

```text
argv: ["python3", "-B", "corpus/self-counts.py"]
cwd: /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/KagiR26.MutKnowledgeBase-17/base
stdin: /dev/null
capture: combined stdout + stderr
timeout: 600 seconds
TMPDIR: /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-27/sandboxes/KagiR26.MutKnowledgeBase-17/tmp
PYTHONDONTWRITEBYTECODE: 1
```

| Bytes under test | Exit | Last nonempty combined-output line | Elapsed | Timed out |
|---|---:|---|---:|---|
| Pristine BASE | 0 | `SELF_COUNTS: CLEAN (claims=38 stale=0)` | 14.217 s | no |
| Mutated line 226, ≥25 | 0 | `SELF_COUNTS: CLEAN (claims=38 stale=0)` | 14.908 s | no |
| Restored line 226, ≥24 | 0 | `SELF_COUNTS: CLEAN (claims=38 stale=0)` | 15.071 s | no |

The detector was **never run in the lane checkout**. The three runs used the same argv, cwd, timeout, and environment overrides. No separate ledger-row verification was launched; any isolated selftests executed were children of the requested normal detector through its unchanged table.

## Restoration evidence

Reversed the one-digit edit immediately after the mutated run. Exact byte comparison with the saved pristine document returned true; the restored detector also returned CLEAN as recorded above.

SHA-256 of `corpus/knowledge/claim-ledger.md`:

```text
pristine: 4bfe3d6cbf7923ddfb9b283e9046567680269c9c42d7f2e6bebcf2eb603691b5
mutated:  e65303120f0e53fd62f4e6d888f0f0fbfc5bd86fc908d8c78d9a4ccf30434fa0
restored: 4bfe3d6cbf7923ddfb9b283e9046567680269c9c42d7f2e6bebcf2eb603691b5
```

The following remained byte-identical to BASE across all three states:

| Path | SHA-256 |
|---|---|
| `corpus/self-counts.py` | `5b600f0a997929cace485fc280bc74be5f0ef6f63711195855db0feaa79a6654` |
| `corpus/self-counts.tsv` | `ceadba8964006d29b4ab2cca9256615730c3829ac7af8f8738cb55b8412d80f4` |
| `corpus/claim-ledger.tsv` | `3fcdab10441d18038726f15420ccc58c36c292c698a9c8ad433c3725fb7c2aa5` |

Retained receipts, all lane-relative under `.ufo/waves/round-27/sandboxes/KagiR26.MutKnowledgeBase-17/`:

- `materialization.json` — BASE, archive digest, source-object byte equality, pristine hashes.
- `mutation.json` — exact changed byte, original/mutated lengths and hashes.
- `detector-pristine.txt`, `detector-mutated.txt`, `detector-restored.txt` — full actual combined outputs.
- `detector-pristine.json`, `detector-mutated.json`, `detector-restored.json` — exact argv/cwd, exits, last lines, timeouts, elapsed times, and per-state hashes.
- `restoration.json` — exact byte equality and restored hashes, plus output identity across the three runs.

## What was not checked

- No after binding-table overlay, after implementation, or after C1 acceptance detector; no assertion that every knowledge-entry digit belongs to the reviewed population.
- No second mutation, exhaustive knowledge-number census, or separate 24-versus-25-character behavioral fixture for the defining gate. The defining threshold comparison above is a source observation.
- No independent C2 downgrade/regression probe, live release observation, public-source recapture, or version-precedence adjudication. The BASE release-clock selftest invoked transitively by the binder is not evidence for the round-27 C2 change.
- No lane-checkout detector run, full build, standalone verification/selftest suite, linter, formatter, commit, push, or integration. No account, vault, handler, or CDP operation was requested or invoked by this probe.

Production source files and sibling scratch copies were not edited. Writes were confined to this unique sandbox and this assigned report. No tools were installed or updated. Unrun checks are not passes.
