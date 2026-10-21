# R16-05: the group-row outside count is justified for the frozen bytes, but it does not see the lane's recorded fused-append class

- **Row**: `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv:43`. It has 6 tab fields and is 310 bytes including the LF. The line sha256 is `10550605f397e2cb762ec51f4422c8f082c1a0c9521fe5b4ac87a38202eadc67`, and it is byte-identical to `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:43`.
- **Command**: `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv`, **expect** `^4$`, **exit** `0`, **timeout** `30`. The note says the row is "the outside count" for R16-01's `groups=4` and names 4 group rows that cover 8 census rows.
- **Observed revision**: frozen HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 −0300). Every citation below points at a HEAD blob. Paths are relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
  - L1 was integrating r23 in the working tree during this audit (see §6).
  - At 2026-10-21T01:00 −03:00 these files were byte-identical between HEAD and the working tree: the R16-05 row, `corpus/adjacency.tsv`, `corpus/scope-gate.sh`, `corpus/stamps.tsv` and `corpus/knowledge/adjacency-scope.md`.
- **Method**: read-only. I did **not** run the row command, `verify`, `cells`, `scope-gate`, or any handler/op/vault/host command. Counts come from a Python byte classification and from git object reads.
- **Bottom line**:
  - **Expectation**: SUPPORTED for the frozen bytes.
  - **Execution**: `[substrate]`, SKIP-SELF and the hermetic modes leave the row running (preserved).
  - **The note's claim that this row is the outside count of `groups=`**: REFUTED under the fused-append class (F1, §3). F1 is a consumer-visible false-clean. Confidence in the mechanism is high; confidence that it will actually occur is medium.

## 1. Expectation: SUPPORTED for frozen bytes

- **Pinned bytes.** `corpus/adjacency.tsv` has sha256 `4d9bfb11…f9549`, 83 LF and 5660 bytes, which equals `corpus/stamps.tsv:1`. The blob is identical at `bc1af88` (round 17, the last change), `8ada17a`, `4be5da3` and `d218603`.
- **Static classification (Python, not grep).** Exactly 4 lines start with a byte other than `#` or whitespace:
  - `:81` opencode
  - `:82` chrome-profile
  - `:83` NativeMessagingHosts
  - `:84` AGENTS.md

  Each of these lines has 7 TAB fields and a unique path. None has leading whitespace, and the file has no CR, BOM, NUL or other control bytes. The file has **no final LF**, as `adjacency-scope.md:108-110,311-313` records.
- **The gate counts the same rows for these bytes.**
  - The gate reads the same file (`scope-gate.sh:87`).
  - It parses each non-`#`, 7-column, unique-path line into `g_path` (`:191-236`).
  - It prints `groups=${#g_path[@]}` (`:265`, `:641-642`). That value is 4 for these bytes.
  - I re-derived the gate's string partition (rules R2–R4) without executing the gate: census 35, owned 27, shared 8, coverage 4/1/2/1, 0 foreign, 0 orphan. So the note's membership and coverage clauses hold for the current bytes.
- **Last line.** `grep -c` prints one line. It is matched at `claim-ledger.sh:436,441`.
- **Exit.** `grep` exits 0 when it selects a line. A zero count exits 1 and a missing file exits 2; both become `reason=exit-mismatch` (`claim-ledger.sh:432-434`).
- **Unterminated last line.** grep supplies the missing final newline, so the count is 4 and not 3. The round-22 receipt agrees: stdout `4\n`.
- **Timeout.** The row runs under `timeout -k 5 30` (`claim-ledger.sh:426-427`). The receipt measured 0.002 s, so 30 s is ample. The value matches R16-04 and R16-06.
- **Policy.** I emulated `policy_check` (`claim-ledger.sh:160-192`) and it returns allowed. The round-22 run confirms the row executes.

## 2. What the row actually counts

- **The two counts are different measurements.** R16-05 counts **physical lines by their first byte**. `groups=` counts **lines the gate parses into well-formed rows**.
- **They agree only under conditions.** Each group row must sit on its own LF-terminated line, start in column 1 with a non-TAB byte, and have exactly 7 fields.
- **On a substrate-absent host, R16-05 is the only executed check of the shipped group rows.**
  - R16-01 and R16-03 carry `[substrate]`, so they are deferred (`claim-ledger.sh:416-419`). Round 22 skipped them (`round-22-verifier-spotcheck.md:74`).
  - R16-02 runs on synthetic data. Its `groups=4` (`scope-gate.sh:893`) is a fixture coincidence, not a statement about the shipped file.
  - R16-04, R16-06, R17-02 and R17-03 count directive lines, not group rows.
- **Identity and coverage are not checked by this command.** The note's "which 4 rows" and "covering 8" are gate facts. They were last observed live on 2026-09-29 (`adjacency-scope.md:249-265`). The erratum at `:315-326` says "this round performed no live scope-gate run".

## 3. F1 (calibration): a naive append fuses into the AGENTS.md row, and R16-05 still reads 4

### Mechanism (all cited to HEAD)

1. **The last line has no LF.** The last line (`:84`) is the AGENTS.md group row.
2. **A naive append fuses into that line.** `printf '<row>\n' >> corpus/adjacency.tsv` lands on line 84.
   - The lane recorded this class itself: "3 of 5 mutations merged into the last row and silently no-opped" (`corpus/lessons/round-16.md:67`).
   - `append_row` (`scope-gate.sh:695-699`) exists to normalize exactly this.
3. **The gate rejects the fused line.**
   - `read` puts the overflow into `f7`. A synthetic probe gave `[A][B][C<TAB>D]`.
   - `scope-gate.sh:230-233` reports `BAD-ROW … a fused line lands here` and skips the line, so `groups=3`.
   - `$HOME/.agents/AGENTS.md` (`surface-census.tsv:55`) loses its only cover and becomes `FOREIGN` (`:310-312`). The gate exits 1.
4. **R16-05 still counts 4.** The fused line is still one line that starts with `$`. In an in-memory emulation on the shipped bytes:

   | input | R16-05 count |
   |---|---|
   | shipped bytes | 4 |
   | after a fused append | **4** |
   | after a normalized append | 5 |

### Why it is visible to consumers

The scenario is a substrate-absent host (the recorded state since round 18; see the R18-01 note at `claim-ledger.tsv:48`), after the reviewed re-stamp that any intended data edit needs (`claim-ledger.sh:14-22`, QM14 at `corpus/QUALITY.md:73`). In that state:

- **No executed row changes its verdict.** R16-05 reads 4, R16-04 reads 5, R16-06 and R17-03 read 8, R17-02 reads 4, and R22-03 reports stale 0.
- **The only rows that would see the defect are deferred.** Those are R16-01 and R16-03.
- **The scored cell stays green.** In production `cells`, the scored adjacency cell `SCORECARD.md:237` (heading `:233`) cites R16-01..06 plus `corpus/knowledge/adjacency-scope.md`. Every pointer it executes stays green. No checked cell stamp-pins `corpus/adjacency.tsv`.
- **The shipped partition is broken at the same time.** It has a BAD-ROW, a FOREIGN row and only 3 valid groups.

The defining symptom: an append of a group row that leaves R16-05 unchanged is never correct. A well-formed append must move the count to 5.

Two things catch the drift before a re-stamp, but only generically: `verify_stamps`, and R22-03 when it is cited in `cells` or run in the safe-row set. R16-05 itself never catches it.

### Limits on likelihood

- It needs a shell-style append. Editors that fix the end-of-line would not fuse.
- It needs a re-stamp.
- It needs no proactive bump of the expectation: an author who changes it to `^5$` gets a FAIL.
- It has never been observed on the shipped file. It was observed on the lane's own scratch copies.
- R16-05 is uniquely exposed among the adjacency count rows because the group rows sit at the file tail (`:81-84`).

### Minimal synthetic falsifier (a proposal for L1; I did not run it)

```
R=$(mktemp -d); mkdir -p "$R/corpus"
printf '# fx\n$HOME/a\tkagi\twriter\tdeclared\tb.md:1\tt\tn1' >"$R/corpus/adjacency.tsv"   # shipped shape: no final LF
printf '$HOME/b\tkagi\twriter\tdeclared\tb.md:1\tt\tn2\n' >>"$R/corpus/adjacency.tsv"       # naive append
# fixture-local claim row, same predicate as R16-05:
# R9x-01 <TAB> grep -cE '^[^#[:space:]]' corpus/adjacency.tsv <TAB> ^2$ <TAB> 0 <TAB> 10
```

- **Predicted result**: stdout `1`, exit 0. Against the true post-append expectation `^2$`, that is `FAIL … verdict-not-final`. With the stale expectation `^1$` it **passes**, which is the false-clean.
- **Control**: perform the same append through `append_row`-style normalization. The count should be `2`.
- **Kill criterion for any fix**: the mutant must match neither the pre-append nor the post-append expectation.

### Fix options

All three commands pass an emulated `policy_check`. The counts are Python emulations; none was executed.

1. **Preferred: count the rows the gate can parse.**
   - Command: `grep -cxE '[^#[:space:]][^[:cntrl:]]*([[:cntrl:]][^[:cntrl:]]+){6}' corpus/adjacency.tsv`. It matches whole lines with exactly 7 non-empty TAB fields; `-x` stands in for the `$` anchor that `META_RE` forbids.
   - Counts: shipped **4** (the expectation does not change), fused mutant **3**, normalized append 5.
   - Bookkeeping: needs a QM14 old/new command journal entry and a matching note rewrite.
   - Known gap: a CRLF row would drop out, although the gate keeps CR inside `note`. That is an acceptable false-fail.
2. **Append-only alternative: keep R16-05 and add a guard row.**
   - Command: `grep -cE '^([^[:cntrl:]]*[[:cntrl:]]){7}' corpus/adjacency.tsv`, expect `^0$`, exit `1`. It flags any over-wide line.
   - Counts: shipped 0, mutant 1, normalized append 0.
   - Side effect: R21-04's row count moves.
3. **Complementary: end `corpus/adjacency.tsv` with an LF.**
   - Bookkeeping: needs a re-stamp and a QM14 record.
   - Limit: this removes the precondition but adds no guard against the file losing its LF again.

## 4. `[substrate]`, SKIP-SELF and hermetic modes: the row keeps running, but they add no evidence

- **`[substrate]`**: the note carries no tag, and deferral keys on the note substring (`claim-ledger.sh:416`).
  - The tag set is pinned only by count: R18-02 expects `^11$` (`claim-ledger.tsv:49`).
  - If a tag were moved onto R16-05, the count would stay 11. The donor row would then run on a substrate-absent host and fail visibly [INFERENCE].
- **SKIP-SELF**: it keys on `*claim-ledger.sh*` in the command (`:816-818`), which R16-05 does not contain.
  - I statically derived production `cells` at HEAD: 41 cited rows, 5 self-skipped (R11-08, R11-09, R13-03, R14-01, R18-03), 36 run, and 10 of those deferred when the substrate is absent.
  - R16-05 is in the set that runs and is not deferred.
  - R13-03's expectation wildcards these counts. Dropping R16-05 from the re-run set would therefore not change R13-03's verdict.
- **Hermetic modes**: none of them is evidence for R16-05.
  - The `KAGI_SUBSTRATE` override (`:141-144`, selftest `:1422-1424`) only affects tagged rows.
  - The claim-ledger and scope-gate selftests never read the shipped `corpus/adjacency.tsv`.

## 5. What C1 closure-dispositions must retain

- **No obligation names R16-05.** None of the 15 does. The spot-check `:74` lists R16-01 and R16-03 only among the skipped rows. A disposition must not be supported by R16-05 being green.
- **D6 (`:177`).** For this row, the binding that matters is the per-row measured commit **plus** the `corpus/adjacency.tsv` sha256.
  - Round 22's `final-verification-inputs.json` has no adjacency digest, and its `.h1` is 8ada17a5.
  - That is harmless for R16-05 only because the bytes and the row are identical from `bc1af88` through `d218603`.
  - The round-23 safe-row record should carry both values.
- **D9 (`:183`).** The hermetic run proves the mechanism. It is not a re-run of R16-05 under `SCORECARD.md:237`.

## 6. What C3 hermetic cells must retain

- **Keep R16-05 executing.** It must stay untagged, stay in the safe-row population, and stay in production `cells`. Assert exit 0 and stdout `4` on the stamped bytes. Assert that it is in neither the deferred nor the self-skipped set.
- **Do not let a fixture stand in for production.** A fixture must not reuse the production id, and must not present its CLEAN as production evidence. If a fixture mirrors a group-count row, the F1 mutation (a last row with no final LF, then a naive append) is the evidenced kill case.
- **In-flight working tree** (non-authoritative and L1-owned; observed 2026-10-21T01:00). It is consistent with this list, but it does not exercise F1.
  - `R23-01` passes explicit `--claims`, `--stamps`, `--scorecard` and `--docs` under `corpus/fixtures/cells-hermetic/`. That avoids the `--root` default-binding hazard already raised by ClaimR16X02 and ClaimR13X01.
  - The fixture ids are R90-01 and R90-02. The fixture `adjacency.tsv` ends with an LF and has no group rows.
  - The R16-05 row is unchanged.
  - The only `claim-ledger.sh` change widens the python allowlist.
  - `corpus/closure-dispositions.json` mentions neither R16-05 nor adjacency.

## 7. Historical vs current evidence

| evidence | when | status |
|---|---|---|
| `corpus/lessons/round-16.md:44-48`: live gate `groups=4` | 2026-09-29 (`8a6ec16`) | historical |
| `adjacency-scope.md:249-265`: reproduction, including `:262` (this exact command, `# 4 groups`) | 2026-09-29 | historical; erratum at `:315-326` |
| `.ufo/waves/round-22/final-verification.json` safe_rows R16-05: exit 0, stdout `4`, passed, 0.002 s, `.h1` 8ada17a5 (measured 4be5da3, per D6) | round 22 | historical execution receipt |
| HEAD row equals the r22 frozen row; adjacency stamp matches; static classification and partition re-derivation | 2026-10-21 | current, not executed |

## 8. Secondary observations (out of row or lower confidence)

- **TAB-led group row.**
  - `IFS=$'\t' read` strips leading TABs (probe result `[X][Y][]`), so the gate counts such a row and `^[^#[:space:]]` does not.
  - Appending a fifth row that starts with a TAB would leave R16-05 at 4 while the gate reports `groups=5`.
  - I found no recorded occurrence, so the likelihood is low.
- **Ledger header.** `corpus/claim-ledger.tsv:3` has said "the exit code must equal the fifth column" since `301b9ec` (round 11). The code reads the fourth column (`want=${TF[3]}`, `claim-ledger.sh:408`). Read literally, R16-05's exit would be `30`. This is comment-only; route it to whoever owns the header.
- **R15-04 probably has the same exposure.** `corpus/checklist.tsv` ends with an `H8` row and no final LF. This is routed to ClaimR15X04's owner; I did not audit it.
- **R16-05 is immune to R16-04's `.HOME/` spelling class.** Its first-byte predicate also counts absolute paths.

## 9. Limits

- **Nothing was executed.** I ran no row, sibling gate, `cells`, `verify`, handler, op, vault or host command.
  - The predictions in §3 and §8 are Python emulations plus the documented semantics quoted below.
  - The only probe I ran was bash `read` IFS splitting, on literal synthetic strings.
- **Git use.** The very first call was a plain `git status --porcelain`. It may have refreshed the index stat cache; it changed no content and no ref. Every later call was an object or log read with `GIT_OPTIONAL_LOCKS=0`.
- **Scratch files.** I placed scratch copies of HEAD blobs in `/dev/shm` and two failed curl outputs in `/tmp`. All were removed. This report is my only remaining write.
- **grep binaries.** The agent shell's `grep` is a harness builtin (`pi-uu-grep 0.2.0`), and no count in this report relies on it. `/usr/bin/grep` is GNU grep 3.12 (pacman `grep 3.12-2`).
- **Quote sources.** The gnu.org fetches timed out on 2026-10-21. The quotes below come from the installed info manuals (`grep 3.12-2`, `bash 5.3.20-1`).
- **Tool installs**: none.
- **Escalation**: I found no serious contradiction in the frozen evidence, so I did not message KagiR23.

### Public-source quotes

- GNU grep manual, "Introduction" (grep 3.12; https://www.gnu.org/software/grep/manual/grep.html#Introduction): "If the final byte of an input file is not a newline, ‘grep’ silently supplies one."
- GNU grep manual, "Exit Status" (same URL, `#Exit-Status`): "Normally the exit status is 0 if a line is selected, 1 if no lines were selected, and 2 if an error occurred."
- Bash Reference Manual, Edition 5.3 (last updated 18 May 2025), "Word Splitting" (https://www.gnu.org/software/bash/manual/html_node/Word-Splitting.html): "Word splitting begins by removing sequences of IFS whitespace characters from the beginning and end of the results of the previous expansions"
