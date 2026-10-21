# ClaimR17X02 — semantic audit of ledger row R17-02 (round 23, parent-build, read-only)

**Seat:** ClaimR17X02, leaf scout. **Axes:** calibration, freshness, operability. **Read:** 2026-10-21, ending 01:00 -03.
**Revision:** git HEAD `d218603b74099ddca0bd8f869516fc41db0979bf`, the frozen base named in `plans/round-23.md:3`.

**Working tree:** L1 is integrating in the working tree right now. While I read, these changed: `SCORECARD.md`, `corpus/claim-ledger.{sh,tsv}`, `LOG.md`, `SKILL.md` and others were modified, and the new files `corpus/fixtures/`, `corpus/closure-dispositions.*` and `corpus/lessons/round-23.md` appeared. This row's own inputs are unchanged in the working tree:
- R17-02's line (sha256 `b7c94b28…`, still line 46) is the same.
- `corpus/adjacency.tsv`, `corpus/scope-gate.sh`, `corpus/surface-census.tsv` and `corpus/stamps.tsv` have no modifications.
- The `claim-ledger.sh` diff touches only the python allowlist and its comment. No line numbers shifted.

Items marked **[in-flight]** come from uncommitted L1 files and may change.

**What I did not do:** I did not run the R17-02 command, and I did not run any gate, selftest, falsify, `verify` or `cells`. Expected outcomes below are worked out from the cited code. The only file I wrote is this report. I installed no tools.

## Row
`corpus/claim-ledger.tsv:46`:
- command: `grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv`
- expected last line `^4$`, exit `0`, timeout `30`
- note: "adjacency.tsv carries exactly four breadth pins; the gate independently derives the required member set and fails on a missing, extra, aggregate, scan, or non-no-enumerate row"
- no `[substrate]` tag

The row was added in `bc1af88` (round 17, 2026-09-29) and its text has never been edited (`git log -S`). The line is byte-identical at 8ada17a5, 4be5da3c, 254d632e and d218603b, so no QM14 migration record is owed.

## Verdicts
| question | result |
|---|---|
| expect `^4$`, exit 0, timeout 30 | **SUPPORTED** at current bytes |
| note clause 1 ("exactly four breadth pins") | **SUPPORTED**, with a grammar caveat (§2) |
| note clause 2 (the gate derives the set and fails on 5 classes) | True of the gate code, but **not caused by this row's command**. On the current substrate-absent host, no executing row checks it against the shipped data. This is a calibration overclaim (QM13). |
| `[substrate]` deferral | Keeps the count obligation (the row is never deferred). Does **not** keep clause 2 (§3). |
| SKIP-SELF | Does not apply to this row; preserved |
| hermetic/synthetic modes | They prove the machinery this row relies on. They never touch the shipped breadth rows. |
| `SCORECARD.md:325` pointer | **REFUTED attribution** (QM11, §4) |
| [in-flight] `SCORECARD.md:844` "pins are unchanged" | **Not supported by the row it cites** (§5, primary risk) |

## 1. Expectation — SUPPORTED (current evidence)
- **Which lines match.** Exactly `corpus/adjacency.tsv:75-78` match. Each is `# breadth<TAB>$HOME/…<TAB>children=N<TAB>declared=M`: `cat -A` shows TABs and LF line endings, and the file has no CR. The grammar prose at `:33` starts with `#   # breadth`, so it cannot match `^# breadth`. I found these lines with a broader read-only `grep -n '^# breadth'`, not with the row's command.
- **Exit code and expectation agree.** `grep -c` prints one count line and exits 0 only when the count is at least 1. A count of 0 would print `0` and exit 1, which the ledger reports as `FAIL … exit-mismatch` (`claim-ledger.sh:427` runs the command, `:436` takes the last line).
- **Static derivation (not executed)** using `scope-gate.sh:499-517`, the 8 `# no-enumerate` rows (`adjacency.tsv:67-74`) and the 4 census `# scan` rows (`surface-census.tsv:17-20`):
  - The four leaves are `.local/bin`, `.config/opencode`, `.agents` and `…/chrome-profile`.
  - `.config`, `.local/state`, `.local/share` and `the-musketeer` are aggregates.
  - The four pins equal the derived leaf set, and `declared ≤ children` holds for every pin.
  - So 4 equals the gate's `breadth_required` today. R17-02 does not compute that value; it only counts lines.
- **Round-22 receipt (historical).** `.ufo/waves/round-22/final-verification.json:319` records exit 0, stdout `4\n`, passed, 0.001 s.
  - Spot-check D6 (`lessons/round-22-verifier-spotcheck.md:177`) notes the file's `h1` is 8ada17a5 while the bytes were measured at 4be5da3. That gap does not matter for this row: `corpus/adjacency.tsv` has the same blob `1aebaf61…` at 8ada17a5, 4be5da3c, 254d632e and d218603b, and was last changed in `bc1af88`.
  - The receipt does not bind `adjacency.tsv` directly; `final-verification-inputs.json` lists 7 inputs and this file is not one of them.
  - The binding is indirect, through the stamps file: the inputs' `corpus/stamps.tsv` sha256 `d082e9f1…` equals `git show 4be5da3:corpus/stamps.tsv`. That file's row 1 pins `adjacency.tsv` at `4d9bfb11…/83/5660`, which matches the current file. Row 1 is unchanged in today's `stamps.tsv`.
- **Operability.** The row is host-free, deterministic and fast (30 s timeout against 0.001 s measured). `grep` is in `ALLOWED_RE` (`claim-ledger.sh:160`). `.HOME` is a forced wildcard, not a choice: `META_RE` (`:163`) refuses `$` and the policy refuses backslashes. As a result `.` also accepts `XHOME/` or `/HOME/`.

## 2. Causality — what the command proves vs. what the note says (Finding A, calibration, moderate)
R17-02 counts lines that match a regex. The gate counts pins its parser accepts. The two differ in two ways:
- **Grammar.** `[[:space:]]+` accepts spaces, but the gate splits on TAB only (`IFS=$'\t'`, `scope-gate.sh:191`).
  - A pin separated only by spaces is treated by the gate as prose and skipped (`:196`).
  - A pin with a space after the directive and TABs later becomes `BAD-ROW` (`:197-200`).
  - R17-02 counts both kinds.
- **Content.** R17-02 never checks the directory or the two counts. The gate validates membership, scope and arithmetic (`:207-221`, `:520-543`).

**How many of the gate's own falsifiers R17-02 would notice.** Of the 9 shipped breadth falsify mutations (`:770-802`), R17-02 flips only on the 3 that change the line count: `breadth-missing` deletes a pin, and `breadth-aggregate` and `breadth-noenum` append one. It stays green on the in-place ones, such as `breadth-extra-field` at `:793`. It also misses any swap that keeps the count at 4.

**Where clause 2 is actually proven.** It is true of the gate code: `scope-gate.sh` still matches its stamp `078a2601…` and is unchanged since `bc1af88`. The synthetic selftest cases at `:907-925` cover missing, duplicate, aggregate, noenum and scan, and R16-02's round-22 receipt shows `PASS (61 cases)`.

**The gap on today's host.** Only R16-01, R16-03 and R17-01 run the gate on the shipped data. All three carry `[substrate]` (`claim-ledger.tsv:39,41,45`) and are deferred while the handler is absent (`claim-ledger.sh:140-147,416-418`). That has been the documented state since round 18: the spot-check skip list (`:74-77`) and round-22 Entry02 §4.2 both record it. R16-02's selftest builds its own 3-pin data (`scope-gate.sh:846-870`) and never reads `corpus/adjacency.tsv`.

Net: today the shipped breadth rows are checked only by count rows. QM13 (`QUALITY.md:72`) says an authored count is not calibration, and this note sits a gate property next to a count row as if the row proved it.

**Spelling issue routed from ClaimR16X04 §7.4.** Evaluated for this row:
- **One pin respelled with an absolute path:** the gate fails (`BREADTH-NOENUM` plus `BREADTH-MISSING`, because pins are compared to `# no-enumerate` entries as literal strings) and R17-02 drops to 3. Both go red, so the signals agree.
- **A leaf's `# no-enumerate` line and its `# breadth` line both respelled absolute:** at `ROOT=$HOME` the gate verdict should not change. R10 expands paths (`:471-476`), the pin checks stay consistent, and the host check expands. But R17-02 drops to 3, a **false-fail**. This is a weaker risk because it needs two coordinated line edits.
- **Effect on the note's word "derives":** the derivation compares raw strings (`:507-513`), so it only holds when spelling is consistent.

## 3. `[substrate]` deferral, SKIP-SELF and hermetic modes
- **`[substrate]`:** R17-02 is untagged, so it is never deferred, and `KAGI_SUBSTRATE` has no effect on it. Keep it untagged: it is one of the few adjacency rows that still runs when the handler is absent.
- **SKIP-SELF:** the skip test looks for `*claim-ledger.sh*` in the command (`claim-ledger.sh:816`). R17-02 reads `adjacency.tsv`, so `cells` re-runs it (`:825`).
- **Hermetic and synthetic modes:**
  - The ledger selftest never runs R17-02. It proves the DEFER, SKIP-SELF and last-line machinery that R17-02 depends on (121 cases in the R11-09/R18-03 receipts).
  - The scope selftest is synthetic and never reads the shipped data.
  - No hermetic path checks the shipped `# breadth` rows.
- **What `cells` leans on.**
  - R17-02 is cited by three scored cells: `SCORECARD.md:301` (round 17 post-move, with R17-01, R17-03 and a stamped document), `:312` (round 18 pre-move, with R17-01) and `:325` (round 18 post-move, with the round-18 lesson).
  - With R17-01 deferred, **R17-02 is the only row that executes behind `:312` and `:325`**.
  - `cells` compares stamps only for paths a cell cites (`:831`). The only mention of `corpus/adjacency.tsv` in `SCORECARD.md` is prose at `:256`, which is not a cell, so `cells` never compares that file's bytes.
  - The generic `cells` swap gap for `:301` and the no-enumerate rows is already reported in ClaimR17X03 §Risk; I do not repeat it here.

## 4. Finding B — `SCORECARD.md:325` cites the wrong row (QM11), refuted attribution
- **The claim.** The round-18 post-move coverage cell says "The live breadth pins' substrate dependence is now declared in the ledger rather than implicit" and cites `R17-02`.
- **What git shows.** Commit `fecee87` (round 18) wrote line 325 *and* added `[substrate]` to **R17-01**: the tag is absent at `bc1af88` and present at `fecee87`. R17-02's line is byte-identical before and after.
- **Why the audit misses it.** R17-02 declares no substrate dependence and measures no live breadth. `cells` still counts the cell as row-pointed, and R17-02 passes on every host. The project already documents this blind spot: a declaration is a pointer, not a proof of relevance (`knowledge/claim-ledger.md:380-386`).
- **The rule.** QM11 (`QUALITY.md:49`) says an attribution the cited row does not carry must be removed.
- **Fix.** Append an erratum, without rewriting the historical cell, naming R17-01 (and R16-01/R16-03) as the breadth rows that declare substrate dependence.

## 5. Primary risk — false-clean visible to readers, with a minimal synthetic falsifier (proposal for L1, NOT executed)
**[in-flight] the cell.** Working-tree `SCORECARD.md:844` (mtime 00:56:35) is the round-23 post-move adjacency cell. It reads "R17-02's four declared breadth pins are unchanged" and cites only `R17-02`.
- R17-02 can show the pin count is **four**. It cannot show the pins are **unchanged**; only the stamp at `stamps.tsv:1` can.
- The cell does not cite `corpus/adjacency.tsv`, so `cells` never compares that file's bytes.
- L1's own fixture already uses the right pattern: its freshness cell cites `R90-02` **and** `corpus/adjacency.tsv`.

**Fixture F1: swap one pin, keep the count.**
- Control file `T/corpus/adjacency.tsv` (a scratch root, or just the 4 pin lines `:75-78`).
- Mutant: replace line `:77`, `# breadth<TAB>$HOME/.agents<TAB>children=4<TAB>declared=1`, with `# breadth<TAB>$HOME/.config<TAB>children=94<TAB>declared=2`.

**Expected results, worked out from the code:**
- R17-02 prints `4` and exits 0 on both control and mutant, so the mutation survives. The counts read by R16-04, R16-05, R16-06 and R17-03 do not change either.
- Gate oracle (shipped `:67-74` and census included): `SCOPE BREADTH-SCOPE $HOME/.config is an aggregate ancestor, not a required leaf` (`scope-gate.sh:536`) and `SCOPE BREADTH-MISSING $HOME/.agents has no # breadth pin` (`:522`), exit 1. Neither depends on the host, but every ledger row that runs the gate is deferred on this host.
- `cells` on the real tree gives the same verdict with or without the mutation. `verify` and the QM12 safe-row check would report `STALE corpus/adjacency.tsv` until someone re-stamps the file after review; after that, nothing that runs on a handler-absent host notices.

**Hermetic kill test.** Use a cells fixture laid out like L1's `corpus/fixtures/cells-hermetic/`:
- A claims row with synthetic id `R91-02` that copies R17-02's command, expectation, exit and timeout exactly.
- A stamps row pinning the control `corpus/adjacency.tsv`.
- A six-axis section whose adjacency cell says "four declared breadth pins are unchanged".

Run it two ways:
- (a) The cell cites only `R91-02`: control CLEAN and mutant CLEAN. **The false-clean reproduces.**
- (b) The cell also cites `corpus/adjacency.tsv`: control CLEAN, mutant `STALE-POINTER`, `CELL_AUDIT: BROKEN`, exit 1. **The mutant is killed.**

**Secondary risk (false-fail, low likelihood).** Add a prose line `# breadth $HOME/.agents re-measured` with spaces only. The gate skips it as prose (`:196`), but R17-02 prints `5` and fails with `verdict-not-final`. The current file avoids this by indenting its grammar line (`:33`).

## 6. What C3 (D9 hermetic cells) must keep for this row
1. **Keep R17-02 in the real safe-row run.** It must still execute individually in the real safe-row population (QM12, `QUALITY.md:60`). The fixture's `CELL_AUDIT` adds evidence; it does not replace that run.
2. **Do not copy R17-02 into fixture claims.** `verify_claims` runs `cd "$ROOT"` (`claim-ledger.sh:427`). At a fixture root, the row would either fail with grep exit 2 (`BROKEN`, a false-fail) or prove a copy of the file rather than the real one. [in-flight] The current fixture follows this rule: it uses synthetic `R90-01`/`R90-02`, `R90-02` mirrors R17-03, and the fixture's `adjacency.tsv` has no `# breadth` lines.
3. **Do not credit the fixture to the real cells.** A clean fixture run says nothing about `SCORECARD.md:301/312/325/844`.
4. **Fix the [in-flight] `:844` cell.** Add `corpus/adjacency.tsv` to its evidence, or reword "unchanged" to "four (count)".
5. **[in-flight, low] The round-23 lesson's fixture contract is stale.** `lessons/round-23.md:149-159` describes one row, empty stamps and cells citing `R90-01`. The actual fixture and the R23-01 expectation (`stamp_pointed=1 rows_run=2`) have two rows, two stamps and an `adjacency.tsv` stamp pointer.

## 7. What C1 (closure dispositions) must keep for this row
- **R17-02 is not an obligation.** It is one of the 31 safe rows (spot-check `:74-77`), and D6 is the only routed defect that touches its receipt.
  - For this row the D6 gap is immaterial: the blob is identical across the commits (§1).
  - A real D6 fix should make the round-23 verdict file carry `measured_commit`. It should also bind each row's input files (here `corpus/adjacency.tsv`, or the stamps chain) instead of relying on "31/31 passed".
- **[in-flight] The checker's pointers go to prose.** `corpus/closure-dispositions.json` marks D6 and D9 `fixed`, pointing at `corpus/lessons/round-23.md#Routed defect dispositions`. `resolve_pointer` (`closure-dispositions.py:104-121`) checks only that the file exists, that a heading contains the anchor, and that the id appears somewhere in the file.
  - It does not open `.ufo/waves/round-23/final-verification.json`, which was absent at 00:58, or R23-01 and its fixture.
  - This limit is stated honestly in the module docstring (`:41-45`). It is still assurance about a record, not about the artifact. If "follow actual source/row pointers" is the requirement, point D6 at the verdict file and its key, and point D9 at R23-01.

## 8. Recommendations for L1, smallest first
1. **[in-flight]** Add `corpus/adjacency.tsv` to the `SCORECARD.md:844` evidence cell. The stamp check then makes F1 detectable.
2. Rewrite R17-02's note, keeping a QM14 old/new record and leaving the expectation alone:
   - State what the command proves: 4 lines match `^# breadth<ws>?HOME/`; it is count-only, and its grammar is looser than the parser's.
   - Turn clause 2 into a pointer: synthetic proof is R16-02; proof against the shipped data is R16-01/R16-03/R17-01, all `[substrate]`-deferred while the handler is absent.
3. Append the QM11 erratum for `SCORECARD.md:325` (R17-01 carries the substrate tag, not R17-02).
4. Named debt, outside r23 unless L1 chooses otherwise:
   - A host-free breadth mode that only checks the data: parse, derive and validate pins, then stop before host enumeration. Pin it with an untagged row and use F1 as its kill test. It is the only way to make clause 2 actually cause a failure on every host.
   - A tighter count predicate that is still policy-clean and does not depend on spelling, e.g. `'^# breadth[[:cntrl:]][^[:cntrl:]]+[[:cntrl:]]children=[0-9]+[[:cntrl:]]declared=[0-9]+'` (TAB-only, needs both count fields). It is unexecuted, so L1 must check `policy_check` and the resulting count. It would close §2's grammar and spelling gaps, but not the membership gap.

## Limits
- I ran no commands or gates (§ header). The results in §2 and §5 are inferred from the cited code lines.
- I used read-only git (`rev-parse`, `show`, `log`, `diff`, `blame`, `status`, `merge-base`), `sha256sum`, `cat -A`, `sed` and `grep` on repository files, and read the uncommitted L1 files.
- **Compliance disclosure:** early on I ran one presence-only `test -e` on five `$HOME` paths, without listing them or reading contents. I do not use the result as evidence; the absence of the substrate comes from committed records.
- I did not observe live breadth counts (182/8/174), and they are not this row's subject.
- [in-flight] observations may be out of date as soon as L1 commits.
- Tools installed or updated: none.
