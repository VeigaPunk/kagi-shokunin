# ClaimR21X03 — R21-03 read-only semantic audit

Scope: one row, `R21-03`, in `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv`. This is an advisory report with no judgment or admission authority. Nothing from the ledger was executed (no gate, selftest or handler run).

## Observed revision

- **Frozen population.** git HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (jj @ `4410ccad…`). Observed 2026-10-21 00:46–01:02 -03:00.
- **The row.** `corpus/claim-ledger.tsv:53` at HEAD:
  - command `bash corpus/sources-census.sh --selftest`
  - expect `^SOURCES_CENSUS_SELFTEST: PASS \(47 cases\)$`, exit `0`, timeout `120`
  - It is byte-identical to `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:53`.
- **The gate it runs.** `corpus/sources-census.sh` at HEAD has sha256 `03fb300a74157232978525c6bc4b028d7ed9159bccbb47d32333deb48ba76b3c`, 450 lines, 25950 bytes.
  - This matches `corpus/stamps.tsv:60`.
  - The bytes are the same at e1544c1, 4be5da3, 8ada17a5 and HEAD; no commit in e1544c1..HEAD touched the file. At c41af82 the sha was `657cfc0b…`.
  - So the D6 label problem in the round-22 verdict file (`.h1` 8ada17a5 versus measured 4be5da3) does not affect which gate bytes the R21-03 receipts measured.
- **Ledger harness.** `corpus/claim-ledger.sh` at HEAD has sha `cf56f9ea…`.
- **Working tree moved during the audit.** L1 was editing the C2 and C3 files. Section 6 records those observations with a hash and time for each one.

## Verdicts

| # | Question | Verdict |
|---|---|---|
| V1 | Is the last-line ERE justified? | **Supported.** `sources-census.sh:443` prints `SOURCES_CENSUS_SELFTEST: PASS (%d cases)`. `cases` goes up once per CASES entry (`:364-412`, 47 entries at `:365-411`). The ERE is anchored at both ends and the parentheses are escaped. |
| V2 | Is exit 0 justified? | **Supported.** `:443` exits 0 on PASS; `:444` exits 1 on FAIL; SETUP exits 2 via `setup()` at `:90`, for example when mktemp fails (`:359`). The harness requires the exit code to match (`claim-ledger.sh:432`). |
| V3 | Is timeout 120 justified? | **Supported.** Both round-22 receipts ran against the same gate bytes. `.ufo/waves/round-22/initial-checks.json` `/checks[7]`: exit 0, 0.949 s. `.ufo/waves/round-22/final-verification.json` `/safe_rows[25]`: exit 0, 0.92 s, `passed: true`. That leaves about 126× headroom. A timeout is a FAIL (`claim-ledger.sh:427-430`). |
| V4 | Is the note accurate? | **Supported, with one overstatement.** The breakdown adds up to 47: 3 clean + 38 finding + 6 SETUP. A name diff from c41af82 to e1544c1 adds exactly the seven cases the note names (row-leading-space, row-two-digit-id, row-lowercase-id, usedby-absolute, usedby-dotdot, entry-two-source, cite-tier-c-sole). History is retained in `.ufo/waves/round-22/historical-migrations.json:7-8` (40 → 47). The overstatement is "each asserting exit + finding id + findings count": the SETUP cases (`:406-411`, count `-`) only check exit 2 and the `SOURCES_CENSUS: SETUP (*)` shape (`:430`), not the reason or a count. |
| V5 | Do the cases test real behaviour, not just count? | **Supported at HEAD.** See section 2. I found no vacuous case. |
| V6 | Is the row correctly not tagged `[substrate]`? | **Supported.** The selftest is host-free: `mktemp -d` at `:359`, EXIT trap at `:360`, every path under `$ST_DIR`, no network and no `op`. The DEFER branch at `claim-ledger.sh:416-418` never applies. R18-02 pins the tag count at 11, so tagging R21-03 would trip that count. |
| V7 | Does SKIP-SELF apply? | **No.** The command does not contain `claim-ledger.sh` (`claim-ledger.sh:816`), so `cells` re-runs it. See section 3. |
| V8 | Do the hermetic modes preserve the obligation? | **The selftest's own synthetic fixture: yes.** **The C3 hermetic cells fixture: it does not and cannot re-run R21-03** (section 3). |
| V9 | Does the count pin bind which cases exist? | **Refuted.** The pin checks only the case count. Risk R1 in section 4. |
| V10 | Does the in-flight C1 D7 pointer reach R21-03? | **Refuted.** Section 5. |

## 1. Expectation chain at HEAD

The harness (`claim-ledger.sh:400-446`) works like this:

1. The row's note has no `[substrate]` tag, so it is never deferred.
2. `policy_check` allows `bash`, and the command has no metacharacters.
3. The command runs as `timeout -k 5 120 bash -o pipefail -c …` from the lane root (`:427`).
4. The exit code must equal 0.
5. The last non-empty line of the output (`:436`) must match the ERE.

Each case checks the following (`:425-435`):
- **CLEAN cases:** the whole verdict line must equal the literal at `:362`. This is stronger than the note says.
- **Finding cases:** the target `FINDING <id>` must be present, and the last line must report `findings=<n>`.
- **Credential cases:** the needle string must not appear in the output (`:435`).

## 2. Do the cases test behaviour or just add to the count?

I walked every mutation (`:307-356`) through `verify()` (`:130-243`) by hand. These cases are the ones where the risk of a vacuous pass is highest:

- **usedby-dotdot** (`:321`): `../base/corpus/knowledge/e1.md` points at a real file under `$ST_DIR/base`, so the contract existence check passes. Only the shape check (`usedby_re`, `:185`) can produce the finding.
- **usedby-absolute** (`:320`): same pattern; only the shape check can fire.
- **continuation-line** (`:308`): this is a CLEAN case. If the continuation parsing in `src_field` (`:121`) were removed, S002 would drop out of e1's source field and the gate would report SC_USEDBY_NOCITE instead of CLEAN. So the case does test the parser.
- **row-leading-space / row-two-digit-id / row-lowercase-id** (`:311-313`): the contract regex does not see these rows, so only the registry-shape scan (`:180`) can emit SC_MALFORMED.
- **entry-two-source** (`:336`): fires only through the `nsrc` check (`:216-217`).
- **cite-tier-c-sole** (`:344-347`): fires only through `:231`.
- **Expected count 1 means isolation:** for every case expecting one finding, that count also proves nothing else fired. **cite-no-id** expects 3: SC_ENTRY_CITE plus two SC_USEDBY_NOCITE.
- **Inert-mutation guard (QM9).** `:421-424` uses `diff -rq`. In a child bash, `diff` and `sed` resolve to GNU diffutils 3.12 and GNU sed 4.10; this agent shell's builtins do not leak into children (checked with `bash -c 'type sed diff'`).
  - Portability note only: if `diff` were missing, the guard would fail open for the two mutated CLEAN cases.
- **Low-severity gap.** The SETUP cases don't check the reason. Example surviving mutant: change `-f` to `-e` at `:134`. A directory named SOURCES.md then reaches `setup "row count failed"` instead. The exit code and verdict class are the same, so a consumer would not see a difference.
- **The tier-C sole-support rule is proven only by the selftest.** Header `:49-53`; check `:231`; case `:397`.
  - At HEAD the only tier-C rows are S005 (queued) and S008 (rejected), and neither is mined. So no real entry can exercise the rule, and R21-02 would not notice if the rule were removed.

## 3. `[substrate]`, SKIP-SELF, hermetic mode and C3

**`cells` re-runs this row.**
- Line `SCORECARD.md:644` sits under `## Round 21 — post-move` (`:633`). Its first cell is `operability`, which is in `AXES_RE` (`claim-ledger.sh:689`).
- The line cites `R21-03`, which `line_ids` collects (`:757-763`). It also contains the token `corpus/sources-census.sh`, which is a stamped path (`stamps.tsv:60`) and so becomes a STALE-POINTER check (`:764-773`).
- So that cell rests on two things: a re-run of R21-03 and an unchanged stamp for the gate.
- `SCORECARD.md:685` is under `## Capabilities`, so it is not a cell.

**Historical:** round 22 skipped R13-03 (see the skipped list in `final-verification.json`). The tooth that runs this row through `cells` therefore did not execute in round 22. R21-03 ran directly as one of the 31 safe rows, which is the substitute QM12 allows.

**C3 (in flight, 00:59:47):**
- `corpus/fixtures/cells-hermetic/claims.tsv` contains only synthetic rows R90-01 and R90-02. R21-03 is not copied there, which is good: there is no duplicate pin to keep in sync.
- R21-03 could not run there anyway, because the commands run with the fixture as the root directory.
- So a green R23-01 says nothing about R21-03. This row's obligation is kept only by running it directly and by `cells` at the real repository root.
- R13-03's ERE accepts any `rows_run` and `row_deferred` value (`claim-ledger.tsv:38`). If a future hermetic mode deferred R21-03 at the real root, R13-03 would stay CLEAN and the deferral would not show.

## 4. Risk R1 (consumer-visible false-clean): the pin only counts cases

**The problem.** The ERE checks how many cases passed, not which properties they prove. The membership the note lists is not checked by anything.
- **Historical precedent.** `PASS (40 cases)` at c41af82 passed while the gate had four fail-open paths (`SCORECARD.md:669`; `corpus/lessons/round-21.md:95-105`).
- **Current trigger.** C2 rewrites this case table this round, and the gate will be re-pinned for that reason. The stamp, the only guard on the gate's bytes, gets refreshed anyway, so it won't flag a quiet case swap.

**Falsifier F1 (a proposal for L1; not executed; the outcomes below are [INFERENCE]):**
1. Make a scratch copy of the gate (HEAD bytes, or the C2 candidate).
2. Edit A: replace the case at `:397`, `"cite-tier-c-sole|m_cite_tier_c||1|SC_ENTRY_CITE|1"`, with `"cite-tier-c-sole|m_clean||0|CLEAN|0"`. `m_clean` is exempt from the inert guard (`:422`).
3. Edit B: delete line `:231`.
4. Predicted result:
   - `--selftest` prints `PASS (47 cases)` and exits 0 (59 on the C2 candidate), so R21-03 stays green.
   - R21-02's CLEAN line on HEAD data does not change, because no mined tier-C row exists.
   - Yet the rule is gone: `SKILL.md:47` lists tier-C sole support under "Never", and `PROVINCE.md:53` and `SCORECARD.md:685` name this selftest as the proof.
5. What it should show: the F1 copy must make R21-03 fail. Under a count-only pin it cannot.

**Fix options (L1 decides):**
- **(a) Minimum, a process fix.** Every migration of R21-03 records the case-spec diff: removed, changed and added cases, with old and new values. QM14 already requires old/new values for expectation changes, and the case-table literals are expectations (header `:85`).
- **(b) A calibration fix.** The PASS line also prints a digest over the sorted `name|fn|arg|exit|id|n` specs of the cases that passed, and R21-03 pins that digest. F1 would then change the digest, R21-03 would fail on its last line, and the swap would have to be named in a migration record.
  - A per-finding-id coverage count is weaker: under F1 SC_ENTRY_CITE is still covered by other cases.

## 5. What C1 (closure dispositions) must keep for this row

- D7 (`corpus/lessons/round-22-verifier-spotcheck.md:180-181`) is fixed inside this gate, as SC_FETCH. The executable checks that prove that fix are R21-03 (the selftest) and R21-02 (real data).
- **The in-flight D7 record.** `corpus/closure-dispositions.json` (untracked, sha `f20f00d1…`) marks D7 `fixed` with pointer `corpus/lessons/round-23.md#Routed defect dispositions`.
- **How the in-flight resolver treats it.** `corpus/closure-dispositions.py:104-121` (sha `6cc82278…`) accepts the pointer if any `#`-line contains the anchor and the token `D7` appears anywhere in the file.
  - It is not scoped to a section.
  - It never reaches the gate or a ledger row.
- **Falsifier F2 (not executed, [INFERENCE]):**
  1. In a scratch copy, revert the gate to HEAD bytes (no SC_FETCH) and leave the lesson and JSON unchanged.
  2. Predicted C1 result: still CLEAN, because no pointer touches the gate.
  3. Predicted R21-03 result: once migrated, it fails, because the selftest prints `PASS (47 cases)` instead of 59.
  4. So R21-03 is what actually tests the fix; C1 only shows that a record exists.
- **What to keep:**
  - D7's disposition should name R21-03 and R21-02.
  - The cheapest pointer the current resolver will follow to the implementing file is `corpus/sources-census.sh#SC_FETCH`. The in-flight header comment starts with `#` and contains both `SC_FETCH` and `routed D7`. It is still only a text check.
  - The real fix is a pointer type for claim rows: the row id must exist in `corpus/claim-ledger.tsv`, and ideally a passing round-23 safe-run receipt must carry the gate's sha256 (the D6 lesson).

## 6. In-flight C2/C3 observations (moving target, outside the frozen population)

**Working-tree timeline (-03:00):**
- 00:48 — gate equals HEAD `03fb300a`.
- 00:52:56 — 613 lines (diff captured).
- 00:54:35 — `bf56b1a4`.
- 00:56:21–35 — `4e60d5e0`.
- 00:58:12 — `80966e20`. `claim-ledger.tsv:53` already reads `PASS \(59 cases\)`; `stamps.tsv:60` still pins `03fb300a…`.

**At 80966e20:**
- **Case membership.** All 47 HEAD case names are kept (none removed). Twelve `fetch-*` cases are added, for 59 in total by static count.
- **Nine kept cases changed their expected finding count**, because their fixture mutations now also trigger SC_FETCH:
  - zero 1→5
  - malformed, row-leading-space, row-two-digit-id, row-lowercase-id, mined-unused-dash, mined-unused-empty and cite-tier-c-sole 1→2
  - enum-status 1→3. It read 2 at 00:52:56. My static analysis gives SC_ENUM + status mismatch + row-identity digest mismatch = 3, which matches the later edit.
- The in-flight R21-03 note does not record those old/new values, which QM14 requires.
- For those nine cases, the presence of the target finding id is still what proves the check works. The extra findings' ids are not asserted, so isolation is weaker. Option: give those mutations matching provenance, for example an S005 provenance row alongside ROW5/ROW5C, so they stay at 1.
- **fetch-disagree at 4e60d5e0** (an illustration of R1). At 4e60d5e0 the same-URL digest comparison had been removed. `fetch-disagree` (expecting 1) passed only through `duplicate-provenance`, the same path `fetch-duplicate` already covers, and the count stayed 59. At 80966e20 the comparison is back and the case expects 2.
- **Risk R2, the selftest passes while real data aborts** (sent to KagiR23).
  - What breaks: line `:242` assigns `SUPERSEDED[$fid]=1`, but `SUPERSEDED` is no longer declared `-A` (`:229`).
  - Evidence: a separate bash probe under `set -uo pipefail` gives `S007: unbound variable` and rc 127. That probe did not run the gate.
  - Effect on real data: the working-tree `SOURCES.md` has six `supersedes S0..` rows (S019/S020/S022/S023/S025/S026). [INFERENCE] Plain `verify` (R21-02) should abort before printing a verdict.
  - Why R21-03 misses it: `--selftest` stays green because no fixture row's teaches starts with `supersedes`.
  - Minimal failing fixture: a CLEAN shape that adds a superseding row with provenance and expects the CLEAN line.
- **No case for rejected or superseded provenance being treated as active.** If C2 claims to tell them apart, R21-03's selftest should carry a case. Example: give S004 provenance the status `mined`, which should produce two SC_FETCH findings (status and row identity).
- **No case for a missing provenance file.** No case deletes `corpus/source-fetches.tsv`. The missing-provenance loop currently runs after the `if [[ -f $fetchf ]]` block, so it fails closed, but a regression that moved the loop inside that block would pass all 59 cases. Proposed case: `fetch-file-absent`, expecting SC_FETCH with findings=4.
- **The in-flight note.** The breakdown in parentheses still adds up to 47 and has no "fetch x12". "Rows now 59" should say "cases".
- **Docs that still cite 47 at observation time:**
  - Current-state, need updating or a label: `PROVINCE.md:53`, `SKILL.md:47`, `SCORECARD.md:685`.
  - Historical, keep as is: `SCORECARD.md:644`, `corpus/lessons/round-21-verifier-spotcheck.md:17`, `corpus/lessons/round-22-verifier-spotcheck.md:71`, `corpus/lessons/round-22.md:70`.
  - The ledger header (`:11-14`) names exactly this kind of staleness, and no gate ties doc numbers to the ledger.

## 7. Integration checklist for R21-03 (for L1)

1. Migrate the expectation in the same commit as the gate change. The QM14 old/new record should carry the case-spec diff, including the nine count changes.
2. Re-pin `stamps.tsv:60` (old `03fb300a…`, 450 lines, 25950 bytes) with a QM14 record. Otherwise `verify` reports STALE and `cells` reports STALE-POINTER on `SCORECARD.md:644`.
3. Fix R2 and add the superseding-row CLEAN shape. Consider adding the missing-file and rejected-as-active cases.
4. Update or label `PROVINCE.md:53`, `SKILL.md:47` and `SCORECARD.md:685`.
5. Keep R21-03 untagged and runnable when `cells` runs at the real root. Don't let C3 count R23-01 as covering it.
6. Make the round-23 safe-run receipt for R21-03 record the gate's sha256 (D6).
7. Consider R1 fix (b). F1 is the fixture that tells the two designs apart.

## Limits

- No ledger command, gate, selftest or handler was executed. F1, F2 and the R2 effect on real data are static predictions. The receipts cited are the round-22 ones on disk. The only thing executed was a bash nounset probe that does not touch the gate.
- **Version-control reads.**
  - Early on I ran two plain `git status --porcelain` calls and one `jj log -r @`.
  - The mtimes of `.jj/repo/op_heads/heads/*` and `.git/index` stayed at 2026-10-20 21:12:00, before this session, so I saw no op-log or index write.
  - Every later git read used `GIT_OPTIONAL_LOCKS=0`.
- **One scratch-file deviation.** One command wrote a pair of scratch files, `/tmp/.r21x03-cases-{head,now}.txt`, and deleted them in the same command.
- The files in section 6 changed during the audit; the hashes and times there are snapshots.
- The row has no public source, so there are no quotes.
- No tools were installed or updated.
