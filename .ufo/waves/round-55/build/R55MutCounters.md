# R55MutCounters — mutation test of the round-55 frozen counters

Seat R55MutCounters (leaf member, no dispatch). Lane `kagi-shokunin`, branch `master`.
Measured revision: **`348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`** (from `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse 348aa3b8…`; every receipt copy in `R55MutCounters.d/` carries this literal hash in its header or in `PROVENANCE.txt`). BASE `ebe095857a734caf5efdd7bd776feb22b4e23972`, predeclaration `f2b986fadd8f8551e760cc89f59e0ae0edb0d499`.

**STATUS: complete.** Pristine baseline 22/22 controls MATCH; 29 single-point mutants run; **14 killed by the frozen battery, 15 survived**; for every survivor a post-hoc proposed control was predeclared, run, and **15/15 kill it**; all 29 mutated counter files were restored byte-identically.

## 1. Objects under test

| object | sha256 / revision |
|---|---|
| `plans/round-55-c1.sh` (frozen) | `3c0b483c5842453a5a397db213c50106597d096216cd1dedcea6b936a5e9c466` |
| `plans/round-55-c2.sh` (frozen) | `9696937a23fe8c3cb29c1fbe7b338372b466c64fbcb893d588b4f8e4353d2ae6` |
| `plans/round-55-controls.sh` (frozen) | `dd75bf8fc3f884032b26629706f44f88bc3a5c093a1b48c1bad80c97474a7fdf` |
| candidate / measured revision | `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` |
| BASE | `ebe095857a734caf5efdd7bd776feb22b4e23972` |

The frozen hashes are identical in the lane working tree and at the candidate commit; the controls script is also identical at the predeclaration commit `f2b986fadd8f8551e760cc89f59e0ae0edb0d499`.

## 2. Method and recorded deviations

- Scratch `HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r55/R55MutCounters` passed on every command; every clone, tree, fixture and receipt lives under it. `/tmp` unused.
- Pristine reference work tree: `git clone --shared` of the lane, `rev-parse --show-toplevel` asserted equal to the clone dir, detached checkout of `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`. It is the controls' REF overlay.
- Detector: the frozen pre-freeze battery `plans/round-55-controls.sh` with its 22 predeclared expectations. **Baseline: 22/22 MATCH, exit 0**, last line `CONTROLS: match=22 mismatch=0` (`R55MutCounters.d/00-baseline-controls.txt`) — the pre-freeze receipt reproduced.
- Mutant run: one literal replacement in one counter script, asserted to occur exactly once and to change the file; mutation applied in a minimal scratch repo holding `plans/` and a `.git` whose `objects/info/alternates` points at the lane object store (so the counter's `git archive BASE` works; `git cat-file -e BASE^{commit}` asserted).
- **Deviation (permitted by the seat tasking):** the control battery in the mutant repo is a counter-scoped copy of the frozen script — the unused counter's block is removed verbatim. `controls-c1-only.sh` is the frozen text minus the C2 block; `controls-c2-only.sh` is the frozen text plus exactly one line `mk_ref ref` before the C2 block. A C1 mutant is exercised by all 11 K1 controls and a C2 mutant by all 11 K2 controls; no text of the kept blocks changed.
- After every run the counter is restored from the frozen copy and the restored sha256 is recorded. All 29 restore lines show frozen sha == restored sha.
- Verdict rule: a mutant is KILLED iff ≥1 control of its counter differs from the baseline reading (the baseline is 22/22, so this equals differing from the predeclared expectation); SURVIVED iff all 11 keep it. Baseline failure would be INCONCLUSIVE; there was none.

## 3. Mutant table (29 mutants: 28 in the parallel wave, C2-17 run separately)

`sha_after` is the mutated file's sha256 (first 12 hex); the full before/after pair is in each `*.mutation.json`. Killing controls are shown as `control (baseline→mutant)`.

| # | mutant | counter | conjunct mutated | sha_after | killing control(s) | verdict |
|---|---|---|---|---|---|---|
| 1 | `C1-01-g1-off` | C1 | g1 base-citations-subset enforced | `7cfdf5512a6f` | K1-F1-strip (FAIL→23); K1-F6-token-rewrite (FAIL→24) | **KILLED** |
| 2 | `C1-02-g2-off` | C1 | g2 base-entries-subset enforced | `b5e785bd95c7` | none — 11/11 kept | **SURVIVED** |
| 3 | `C1-03-g3-dup-off` | C1 | g3 duplicate-id detection | `f4fce1aff05a` | none — 11/11 kept | **SURVIVED** |
| 4 | `C1-04-g3-rows-off` | C1 | g3 base-rows-subset enforced | `da24d6a41a74` | none — 11/11 kept | **SURVIVED** |
| 5 | `C1-05-g4-off` | C1 | g4 NOCITE independent record check | `4f921626cbe6` | K1-F3-pad-printer (FAIL→0) | **KILLED** |
| 6 | `C1-06-g4-cites-ignored` | C1 | g4 reads the column-1 cites: field | `8afd8be96dba` | K1-REF (0→FAIL) | **KILLED** |
| 7 | `C1-07-g5-off` | C1 | g5 census CLEAN + selftest PASS | `a738296f0ebc` | K1-F8-base-census (FAIL→0); K1-F9-one-record-withdrawn (FAIL→1) | **KILLED** |
| 8 | `C1-08-ubp-lessons` | C1 | g4 accepts corpus/lessons used-by parts | `6711a45ffd8e` | K1-BASE (25→FAIL); K1-REF (0→FAIL) | **KILLED** |
| 9 | `C1-09-fail-mode-off` | C1 | fail-closed value (FAIL when guard=0) | `f0b620999de9` | K1-F1-strip (FAIL→23); K1-F2-pad (FAIL→25); K1-F3-pad-printer (FAIL→0); K1-F4-entry-deleted (FAIL→0); K1-F5-symlink-entry (FAIL→0); K1-F6-token-rewrite (FAIL→24); K1-F7-row-deleted (FAIL→0); K1-F8-base-census (FAIL→0); K1-F9-one-record-withdrawn (FAIL→1) | **KILLED** |
| 10 | `C1-10-g5-selftest-off` | C1 | g5 requires the census selftest PASS line | `b9aa3e96784f` | none — 11/11 kept | **SURVIVED** |
| 11 | `C1-11-g4-islink-off` | C1 | g4 rejects symlinked used-by file | `d39b09bac2b3` | none — 11/11 kept | **SURVIVED** |
| 12 | `C1-12-entries-islink-off` | C1 | entries exclude symlinks | `c97a6bdb1fd3` | none — 11/11 kept | **SURVIVED** |
| 13 | `C2-01-a-ub-off` | C2 | AMD(a) requires ENTRY in the row used-by cell | `fbc92f9bd2c8` | none — 11/11 kept | **SURVIVED** |
| 14 | `C2-02-a-tier-off` | C2 | AMD(a) requires tier A | `70fd5f49ecb7` | none — 11/11 kept | **SURVIVED** |
| 15 | `C2-03-a-opened-off` | C2 | AMD(a) requires opened 2026-11-07 | `375bf43a0e0f` | K2-F8-opened-date (1→2) | **KILLED** |
| 16 | `C2-04-b-sha-off` | C2 | AMD(b) fetch sha256 == AMDSHA | `9712c838ccf7` | none — 11/11 kept | **SURVIVED** |
| 17 | `C2-05-c-offset-off` | C2 | AMD(c) quote at declared byte offset | `dadfabab51e7` | none — 11/11 kept | **SURVIVED** |
| 18 | `C2-06-c-symlink-off` | C2 | AMD(c) capture path has no symlinked component | `bbf11d577799` | K2-F9-symlinked-capture (1→2) | **KILLED** |
| 19 | `C2-07-d-bracket-off` | C2 | AMD(d) body line carries [X] | `c9ebc3a4659d` | K2-F4-uncited-statement (1→2) | **KILLED** |
| 20 | `C2-08-d-srcids-off` | C2 | AMD(d) X is a token of ENTRY source: | `65d185e1be89` | K2-F5-not-on-source-line (1→2) | **KILLED** |
| 21 | `C2-09-count-off` | C2 | RECHECK body line count equals stated N | `b3f04766e028` | K2-BASE (0→1); K2-F1-stale-expectation (1→2) | **KILLED** |
| 22 | `C2-10-n0-accepted` | C2 | RECHECK N >= 1 | `2bb8d505e495` | K2-F2-absent-quote-zero (1→2) | **KILLED** |
| 23 | `C2-11-srcids-off` | C2 | RECHECK URL row id is on ENTRY source: | `79d9fde6d761` | none — 11/11 kept | **SURVIVED** |
| 24 | `C2-12-guard-s101-off` | C2 | GUARD rows S100,S101,S102 byte-identical | `9c1b394f39c3` | K2-F6-s101-row-edited (FAIL→2) | **KILLED** |
| 25 | `C2-13-guard-census-off` | C2 | GUARD census CLEAN | `94b8dbccdc28` | none — 11/11 kept | **SURVIVED** |
| 26 | `C2-14-recheck-capture-sha-off` | C2 | RECHECK capture sha256 == fetch column 10 | `94a17638b7a7` | none — 11/11 kept | **SURVIVED** |
| 27 | `C2-15-recheck-lines-off` | C2 | RECHECK exactly one recheck: line | `106cedecce04` | none — 11/11 kept | **SURVIVED** |
| 28 | `C2-16-guard-s101sha-off` | C2 | GUARD S101 capture sha256 == S101SHA | `f802d63c22b3` | none — 11/11 kept | **SURVIVED** |
| 29 | `C2-17-fail-mode-off` | C2 | fail-closed value (FAIL when guard=0) | `396b0050685b` | K2-F6-s101-row-edited (FAIL→2) | **KILLED** |

Kill ratio, frozen battery: **14/29 = 48.3%** (C1 6/12, C2 8/17).

Controls that killed at least one mutant in wave 1: K1-BASE, K1-F1-strip, K1-F2-pad, K1-F3-pad-printer, K1-F4-entry-deleted, K1-F5-symlink-entry, K1-F6-token-rewrite, K1-F7-row-deleted, K1-F8-base-census, K1-F9-one-record-withdrawn, K1-REF, K2-BASE, K2-F1-stale-expectation, K2-F2-absent-quote-zero, K2-F4-uncited-statement, K2-F5-not-on-source-line, K2-F6-s101-row-edited, K2-F8-opened-date, K2-F9-symlinked-capture. Controls that never flipped: K2-REF, K2-F3-capture-tampered, K2-F7-recheck-foreign-url. Controls that flipped **only** under the fail-closed-value mutants: K1-F2-pad, K1-F4-entry-deleted, K1-F5-symlink-entry, K1-F7-row-deleted — i.e. their intended forged defect was detected only through loss of `FAIL`, not through the predicate they were built for.

## 4. Survivors and proposed controls (15)

Each proposal was written into `tools/proposals.py` with its expected pristine reading **before** the run, on a REF-derived tree; it is post-hoc with respect to the frozen battery, so it does not raise the frozen kill ratio. Column *real census* is the last line of the measured tree's own `sources-census.sh` on the edited tree before the isolation printer replaced it: where it is `FAILED`, the printer was necessary to test the counter's independent conjunct; where `CLEAN`, the printer was conservative.

| mutant | conjunct | proposed control | predeclared | pristine got | mutant got | real census | kill |
|---|---|---|---|---|---|---|---|
| `P-C1-02-g2-off` | g2 base-entries-subset enforced | REF + `corpus/knowledge/adjacency-breadth.md` becomes a symlink to a copy outside corpus/knowledge (entry has no registry-id token and no used-by cell) + census printer | `FAIL` | `FAIL` | `0` | CLEAN | KILL |
| `P-C1-03-g3-dup-off` | g3 duplicate-id detection | REF + duplicate the `S005` registry row + census printer | `FAIL` | `FAIL` | `0` | FAILED | KILL |
| `P-C1-04-g3-rows-off` | g3 base-rows-subset enforced | REF + delete the `S005` row (BASE row, uncited by any entry, no used-by record) + census printer | `FAIL` | `FAIL` | `0` | FAILED | KILL |
| `P-C1-10-g5-selftest-off` | g5 requires the census selftest PASS line | REF + census whose `--selftest` exits 0 and prints a non-PASS last line | `FAIL` | `FAIL` | `0` | CLEAN | KILL |
| `P-C1-11-g4-islink-off` | g4 rejects symlinked used-by file | REF + S112 used-by cell points at `corpus/knowledge/zz-symlink.md` (a symlink to `op-ref-consumption.md`, which carries S112) + census printer | `FAIL` | `FAIL` | `1` | FAILED | KILL |
| `P-C1-12-entries-islink-off` | entries exclude symlinks | same tree as P-C1-02-g2-off | `FAIL` | `FAIL` | `0` | CLEAN | KILL |
| `P-C2-01-a-ub-off` | AMD(a) requires ENTRY in the row used-by cell | S114 used-by cell drops the entry + census printer | `1` | `1` | `2` | FAILED | KILL |
| `P-C2-02-a-tier-off` | AMD(a) requires tier A | S114 tier A -> B + census printer | `1` | `1` | `2` | CLEAN | KILL |
| `P-C2-04-b-sha-off` | AMD(b) fetch sha256 == AMDSHA | S114 `source-fetches.tsv` column 10 -> 64 zeroes + census printer | `1` | `1` | `2` | CLEAN | KILL |
| `P-C2-05-c-offset-off` | AMD(c) quote at declared byte offset | S114 `quote-bodies.tsv` byte offset 541 -> 540 + census printer | `1` | `1` | `2` | CLEAN | KILL |
| `P-C2-11-srcids-off` | RECHECK URL row id is on ENTRY source: | entry recheck command 2 -> S112 feed URL + `'<title>1Password CLI 2.42.0</title>'` -> 1 (a true count in S112's capture; S112 is not on the entry's `source:` line) + census printer | `1` | `1` | `2` | CLEAN | KILL |
| `P-C2-13-guard-census-off` | GUARD census CLEAN | census prints `SOURCES_CENSUS: DIRTY` and exits 0 | `FAIL` | `FAIL` | `2` | CLEAN | KILL |
| `P-C2-14-recheck-capture-sha-off` | RECHECK capture sha256 == fetch column 10 | append one byte to the S113 recheck capture + census printer | `1` | `1` | `2` | CLEAN | KILL |
| `P-C2-15-recheck-lines-off` | RECHECK exactly one recheck: line | append a second column-1 `recheck:` line + census printer | `1` | `1` | `2` | CLEAN | KILL |
| `P-C2-16-guard-s101sha-off` | GUARD S101 capture sha256 == S101SHA | append one byte to `.ufo/waves/round-45/controls/capture-r45/S101.raw` and update S101's fetch digest to its new sha256 (recheck stays true) + census printer | `FAIL` | `FAIL` | `2` | CLEAN | KILL |

Result: **15/15 proposed controls kill their survivor**, with the predeclared pristine reading matched in all 15 cases. The one predeclaration that needed correction is recorded below.

## 5. What the survivors say about the frozen battery

**C1 (6 survivors).** `g1` (BASE citations), `g4` (NOCITE), `g5` (census) and the fail-closed value have independent detectors. `g2` (BASE entry names), `g3`'s duplicate-id arm and its BASE-rows arm, the selftest-PASS arm of `g5`, `g4`'s symlink arm and `entries`' symlink exclusion have no control that isolates them: the frozen forgeries that touch the same inputs are also caught by `g1`/`g4`/`g5`.

**C2 (9 survivors).** AMD(a) (`ENTRY` in used-by, tier `A`), AMD(b) (fetch digest == AMDSHA), AMD(c) (declared byte offset), RECHECK's source-line gate for a foreign row URL, RECHECK's capture-digest check, RECHECK's single-line rule, GUARD's census arm and GUARD's S101-capture-digest arm are unexercised. K2-F3 (tampered AMD capture) exercises AMD(c)'s **digest** but not its **offset**; K2-F7's foreign URL carries `-> 0`, so the `N>=1` arm fires first and the source-line gate never decides; K2-F6 edits an S101 row, but its kill is through GUARD's row arm, not its digest arm.

**Layering is real but not independent.** The BASE expectations are load-bearing: K2-BASE killed C2-09 (count check removed) because the BASE tree's honest recheck lies. Conversely, several guard arms are redundant *on the frozen forgeries* while remaining necessary against a forger who edits only the field they guard: the survivors are exactly those cases.

## 6. Recorded correction (honesty)

The first P-C1-10 probe made the census `--selftest` exit 1. That does not discriminate C1-10-g5-selftest-off, whose mutation lives inside the selftest-success branch: both pristine and mutant read `FAIL (bad=g5:selftest-exit)` (`R55MutCounters.d/04-proposal-runs.txt`, no kill). The probe was corrected to `--selftest` exiting 0 with a non-PASS last line, which is the branch the mutant removes; the rerun killed it (`05-proposal-runs-v2.txt`). All other 14 proposals are the first implementation.

## 7. Restoration evidence

All 29 mutated counter files were restored from `frozen/`; every receipt records `RESTORE sha_frozen=<h> sha_restored=<h>` with equal hashes (`3c0b483c…` for C1, `9696937…` for C2). Exit codes: 15 runs exit 0 (all 11 controls matched), 14 runs exit 1 (≥1 MISMATCH). The fixture counter repos were disposable; this seat modified no corpus, plan, registry or git object, and its writes outside scratch were confined to its build/ path. The lane working tree did show 7 tracked modifications at finish that are not this seat's writes; every measurement above was taken from committed revisions with `git archive`, never the working tree.

## 8. Receipts

Copied to `.ufo/waves/round-55/build/R55MutCounters.d/`:

- `00-baseline-controls.txt` — full 22-control pristine baseline (22 MATCH, exit 0).
- `01-mutant-wave.txt` — wave driver window (`2026-11-07T05:00:27` → `05:07:11`, 28 runs, `xargs -P 6`).
- `02-analysis.txt` / `analysis.json` — scoped verdict computation.
- `03-proposals.json` — 15 proposed controls, pristine and mutant readings.
- `04-proposal-runs.txt` — first proposal run (contains the non-discriminating P-C1-10 probe).
- `05-proposal-runs-v2.txt` — corrected full proposal run (15/15).
- `06-c2-17.txt` — the added C2 fail-closed mutant run.
- `*.controls.txt` (29), `*.mutation.json` (29) — per-mutant battery output, mutation before/after sha, restore line.
- `tools/` — `mutants.py` (29 specs), `proposals.py` (15 proposals), `run_one.sh`, `analyze.py`, `build_variants.py`, `controls-c1-only.sh`, `controls-c2-only.sh`.
- `PROVENANCE.txt` — measured revision, copy header, sha256 of every copied receipt.

Commands (all with absolute paths, `S=/fast/scratch/hyaku/kagi-r55/R55MutCounters`):

```
HYAKU_SCRATCH=$S bash $S/frozen/round-55-controls.sh $S/repo            # baseline (via clone)
echo <ids> | xargs -P 6 -I{} bash $S/tools/run_one.sh {}                 # 29 mutant batteries
python3 -I -B $S/tools/analyze.py                                       # verdicts
python3 -I -B $S/tools/proposals.py                                     # 15 proposed controls
```
