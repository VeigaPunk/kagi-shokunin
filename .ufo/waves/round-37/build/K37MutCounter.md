# K37MutCounter — mutation test of `plans/round-37-c2.sh` (round 37, kagi, wave build)

Seat: K37MutCounter (mutation-tester, leaf, no subagents). Judged on: freshness.
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin, branch `master` = candidate `9efcea7`.
BASE `911ab519b6b07694c3cb9f7d9a7c56e142ad957c`. Predeclaration `04489d4184edb25a01ec8983b3ccedb45c683564`.
Counter blob `9beb0844d987bb466b75431a54038aed750e1974` is identical at `04489d4`, `e2030d2` and `9efcea7`.
Frozen control runner `plans/round-37-controls.sh` blob `304c578e6f3807301ddf97b407528cd06835a8ca` is identical at `04489d4` and `9efcea7`.
Receipt `observe-r37.json` sha256 `cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203`
(working tree, `9efcea7` blob, and `04489d4` blob all match).

## Method

- Scratch: `/fast/scratch/hyaku/kagi-r37/K37MutCounter/` (deleted before this report was written; `trap` set; 28 MB peak).
- No lane file was edited. Lane reads were `git show`, `git archive`, `git rev-parse`, `git status --porcelain` only.
  One read-only run of `bash plans/round-37-c2.sh` was made in the lane working tree (= `9efcea7`) before the harness; it printed `0`.
- Extractions (read-only `git archive` piped to `tar -x`):
  - candidate: `git archive 9efcea7 -- plans corpus/SOURCES.md corpus/knowledge .ufo/waves/round-37/controls`
  - BASE: `git archive 911ab51 -- plans corpus/SOURCES.md corpus/knowledge`, then the frozen counter, the frozen runner and the receipt copied in from the `9efcea7` blobs (BASE has no round-37 files; the copied blobs equal the predeclared ones).
- Mutants: one textual substitution each on the frozen counter text, applied with a Python script (`str.count(old)==1` asserted, else the mutant aborts). No `sed`, no edit in the lane.
- Readings, per mutant:
  - candidate: `bash plans/round-37-c2.sh` in the mutant's candidate extraction; frozen value 0.
  - controls: the **frozen runner, unmodified**: `BASE=<mutant BASE dir> HYAKU_SCRATCH=<scratch>/ctl bash plans/round-37-controls.sh <mode>` for `nowork g1 g2 g3 partial full`. The runner builds each fixture and runs the mutant counter inside it. Frozen values: 3, 3, 3, 3, 2, 0.
  - setup: `bash plans/round-37-c2.sh` in a BASE copy with the receipt deleted (`setup-missing`), and in a copy with one byte appended to the receipt (`setup-tampered`). Frozen value: exit 2, empty stdout.
  - extra, NOT in the frozen set: a row `S999` naming `https://github.com/hashicorp/vault/releases.atom` with anchor `Entry titled v2.2.10` appended to the BASE SOURCES. Frozen counter must read 3 (2.2.10 is not 2.2.1). Reported separately.
- A mutant is KILLED when any frozen reading (candidate, six controls, two setup controls) differs from its frozen rc/stdout.

## Sanity baseline (M0, unmutated frozen counter)

All frozen readings reproduced exactly; `M0` is therefore not a mutant and is excluded from the count.

| reading | rc | stdout | frozen |
|---|---:|---|---|
| candidate `9efcea7` | 0 | `0` | 0 |
| c2_nowork (BASE) | 0 | `3` | 3 |
| c2_forge_superseded_g1 | 0 | `3` | 3 |
| c2_forge_wrong_url_g2 | 0 | `3` | 3 |
| c2_forge_knowledge_g3 | 0 | `3` | 3 |
| c2_positive_partial | 0 | `2` | 2 |
| c2_positive_full | 0 | `0` | 0 |
| setup-receipt-missing | 2 | (none) | exit 2, no integer |
| setup-receipt-tampered | 2 | (none) | exit 2, no integer |
| extra boundary probe (v2.2.10) | 0 | `3` | 3 (not frozen) |

Precheck: `corpus/knowledge/*.md` contains none of the three feed URLs at BASE or at the candidate, so the M3 mutant has a row to find only in its own G3 fixture.

## Mutant table

Substitutions (old → new, on the frozen text):

- M1: `if not any((url in src) and pat.search(anc) for src, anc in rows):` → `if not any(pat.search(anc) for src, anc in rows):`
- M2: `pat = re.compile(r"(?<![0-9.])(?:v|Python\s)?" + re.escape(v) + r"(?![0-9])")` → `pat = re.compile(r"(?<![0-9.])(?:v|Python\s)?[0-9]+(?:\.[0-9]+)+(?![0-9])")` (any dotted version in the anchor; URL requirement kept)
- M3: insert before `stale = 0`: a loop appending each `corpus/knowledge/*.md` file as one row `(text, text)` (whole document as both source and anchor cell)
- M4: `exit 2; }` → `echo 0; exit 0; }` (the missing/sha-mismatch SETUP branch only)
- M5: `pat = ... + re.escape(v) + r"(?![0-9])")` → `pat = ... + re.escape(v))` (boundary dropped)
- M6: `rows.append((cells[2], cells[6]))` → `rows.append((cells[1], cells[6]))` (source read from the id column)

| id | change | candidate `9efcea7` (frozen 0) | c2_nowork (3) | g1 (3) | g2 (3) | g3 (3) | partial (2) | full (0) | setup-missing (exit 2, none) | setup-tampered (exit 2, none) | verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | drop URL requirement | 0 | 3 | 3 | **2** | 3 | 2 | 0 | 2 | 2 | **KILLED** (g2) |
| M2 | any dotted version in anchor | 0 | **0** | **0** | **0** | **0** | **0** | 0 | 2 | 2 | **KILLED** (nowork, g1, g2, g3, partial) |
| M3 | count knowledge/ docs as rows | 0 | 3 | 3 | 3 | **2** | 2 | 0 | 2 | 2 | **KILLED** (g3) |
| M4 | SETUP missing receipt → `0`, exit 0 | 0 | 3 | 3 | 3 | 3 | 2 | 0 | **0 / stdout `0`** | **0 / stdout `0`** | **KILLED** (setup-missing, setup-tampered) |
| M5 | drop `(?![0-9])` | 0 | 3 | 3 | 3 | 3 | 2 | 0 | 2 | 2 | **SURVIVED** on the frozen set; extra probe KILLS it (below) |
| M6 | source column = index 1 | **3** | 3 | 3 | 3 | 3 | **3** | **3** | 2 | 2 | **KILLED** (candidate, partial, full) |

Totals on the frozen set: **killed = 5, survived = 1** (M1, M2, M3, M4, M6 killed; M5 survived).

Raw rc/stdout for every cell is in `evidence-K37MutCounter.jsonl` and `run-K37MutCounter.log` in this seat dir.

## Per-mutant notes

- **M1 (URL dropped).** The G2 fixture (`openbao 2.7.2` under the vault URL) now counts openbao as held: g2 reads `2` against the frozen `3`. The candidate and the other controls are unchanged. Kill by G2, as predicted.
- **M2 (any version).** Version equality is gone, so every surface whose anchor has any dotted version is held. This reads `0` on the no-work BASE (frozen 3), so it is killed by c2_nowork as well as by G1 (the predicted kill). It is the most visible mutant: the no-work control alone exposes it.
- **M3 (knowledge rows).** With the knowledge file counted, the G3 fixture (`Vault v2.2.1 is current.` plus the vault URL in `corpus/knowledge/g3.md`) counts vault as held: g3 reads `2` against `3`. Kill by G3, as predicted. This depends on my reading of "count rows in knowledge/" as one document per row; a line-wise reading would not hold G3 (the URL and the version are on different lines), so it would survive. That alternative was not run.
- **M4 (SETUP exit).** Missing and sha-tampered receipts both exit 0 and print `0`. Frozen setup controls require exit 2 with no integer. Kill by setup-receipt-missing (and the tampered control, since the same branch is taken).
- **M5 (boundary dropped) — SURVIVED on the frozen set.** No frozen fixture has a vault, openbao or python anchor whose version is a longer number with the observed version as prefix. The candidate, the BASE and every control read the same as the frozen values. The mutant is not killed by the 6 controls + 2 setup controls + candidate.
  - Extra, non-frozen probe: appending `S999` with anchor `Entry titled v2.2.10` under the vault URL to the BASE tree. Frozen counter reads `3` (correct: 2.2.10 does not hold 2.2.1). M5 reads `2`, so the extra probe **kills** it. Reported separately; it is not a frozen control, and the frozen claim is not changed by it.
  - Conclusion: the frozen control set does not exercise the boundary. A control on the `2.2.10`-style prefix would kill M5. Recorded as a coverage gap; per the assignment, the claim and the controls are not changed.
- **M6 (source column index 1).** The source cell becomes the id (`S0nn`), so no row's source contains the feed URL. The candidate reads `3` (was `0`); positive partial reads `3` (was `2`); positive full reads `3` (was `0`). The no-work and forgery controls still read 3, so only the positive controls and the candidate kill it. The candidate reading is the decisive kill, as predicted.

## Verification of the claim under mutation

- The frozen counter with no mutation reproduces every frozen value at BASE and at the candidate (table above, M0).
- Under the five killing mutants, the candidate reading or a control changes, so the frozen predicate (URL-bound, version-equal, registry-only, column 2, boundary-aware) is not interchangeable with a looser one for the frozen fixtures. The one survivor (M5) is a boundary gap that a non-frozen prefix probe detects.
- Setup behaviour (exit 2, no integer on missing or tampered receipt) is killed by M4.

## Tooling and installs

- No tool was installed or upgraded. Python 3 (`python3`, present on the host) and `git`, `tar`, `sha256sum` were used as found.
- No pacman, no `~/.local/bin` writes, no git mutation, no lane file written.

## Limitations (stated, not hidden)

- The harness runs the frozen controls via the frozen runner on a reconstructed BASE tree (the `911ab51` archive plus the predeclared blobs). It does not run the predeclaration tree `04489d4` itself; the counter and runner blobs are byte-identical there.
- M3 uses a whole-document row reading (see notes). A different reading of "knowledge rows" would change the M3 result.
- The extra boundary probe is my own construction, not in `plans/round-37.controls.tsv`.
- The lane working-tree counter run (`0`) was a single read-only observation before the harness; the harness's candidate reading is the extraction of `9efcea7` and matches it.

## Report path note

The assignment names two deliverable paths: `build/K37MutCounter/report.md` (seat dir) and the `Report:` trailer `build/K37MutCounter.md`. This content is written at both paths; the trailer copy is identical.

MUTATION: DONE killed=5 survived=1
