# ClaimR18X02 — R18-02 semantic audit (read-only)

**Observed revision:** `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 -0300).
Untracked worktree additions are round-23/C1 in-flight only (`plans/round-23.md`,
`corpus/closure-dispositions.{py,json}`, `corpus/__pycache__/`, `.ufo/waves/round-23/`);
the audited artifacts are byte-identical to HEAD.

**Measured artifacts**

- `corpus/claim-ledger.tsv` — sha256 `e6806968436375870067d0e587fb1e8ea27e5d3304b8bb563e3f484c1dce8305`,
  58 lines / 17844 B; equals `corpus/stamps.tsv:5`. Git blob `51d676d1e890287840b13885b2cf37e51850cb32`
  at both HEAD and `4be5da3` (the round-22 measured landing).
- `corpus/claim-ledger.sh` — sha256 `cf56f9ea75d512f60c3be80b8afe34d331eb0f007b8fa6aef2d3d9f188cb6c2c`,
  1428 lines / 88425 B; equals `corpus/stamps.tsv:4`. All line cites below are that file.

**Method / limits:** no gate, row command, host probe, or sibling run was executed to produce a
verdict; no production write. Evidence is committed receipts, static reading, and a TSV field
inventory (`awk -F'\t'`). A read-only `grep -n` listing was used once for orientation; the pinned
`grep -cE` form was not run. C2 does not apply (no `SOURCES` row). Per-row adjudication of whether
each tagged row truly depends on the substrate is out of scope (row owners).

**Row, exactly (`corpus/claim-ledger.tsv:49`):**

| id | command | expect | exit | tmo | note |
|---|---|---|---|---|---|
| R18-02 | `grep -cE '\[substrate\]' corpus/claim-ledger.tsv` | `^11$` | 0 | 30 | eleven substrate-tagged command rows; the escaped regex text does not self-match. Historical ten-plus-own-pattern explanation withdrawn (round-22 Entry20 static audit); expectation remains 11 and no tags change. |

## 1. Is the expected verdict / last line / exit / timeout justified?

- **Exit 0 — justified (OBSERVED).** `grep -c` exits 0 when at least one line matches; 11 matches
  exist. The round-22 receipt records exit 0.
- **Last line `^11$` — justified (OBSERVED).** The command prints only the count, and
  `verify_claims` compares the last non-empty line (`:436`). Static field inventory: exactly
  **11 data rows contain the literal `[substrate]`, all in field 6 (note)**; fields 1–5 and every
  `#` line contain none. The note's claim that the escaped text does not self-match is correct:
  the row text is `\[substrate\]`, so the contiguous literal is absent.
- **Timeout 30 s — justified (OBSERVED).** The executed receipt records `seconds: 0.001` over a
  17.8 KB file; 30 s is a hang bound, not a performance claim.
- **Receipt currency (OBSERVED).** `.ufo/waves/round-22/final-verification.json` (tracked) records
  R18-02 `{expected_exit:0, exit:0, stdout:"11\n", last:"11", passed:true, seconds:0.001}` at
  `4be5da3`. The ledger blob is `51d676d1…` at `4be5da3` and at HEAD, and its bytes match the
  current stamp, so the historical run applies to current bytes — but it was not re-run here.
- **Causality caveat (OBSERVED).** The row measures *lines anywhere in the file*; deferral tests
  *field 6 only* (`:416-419`). They coincide on today's 11 rows but are not the same predicate;
  see §5, secondary.

## 2. Deferral (`[substrate]`) preservation

- R18-02 is **untagged (OBSERVED)** and must stay so. It is host-free (grep over a committed file)
  and is the only always-run observation of the tag population while all 11 tagged rows defer.
- Self-inclusion hazard (OBSERVED mechanism, INFERENCE on consequence): if the row's own note ever
  gained the literal, (a) `verify_claims` would DEFER it before policy/execution (`:416-419`;
  bound 5 at `corpus/knowledge/substrate-deferral.md:73-76`), silently removing the assertion on an
  absent host, and (b) the row's own line would become a 12th match, so a present host would fail
  it `12 != 11`. Nothing pins "R18-02 is untagged"; only review does.
- Deferral is correctly not forgiveness: the row is a cardinality tripwire, not evidence that any
  deferred claim holds (`substrate-deferral.md:59-63`).

## 3. SKIP-SELF preservation

- `cells_evidence` skips a cited row only when the command contains `claim-ledger.sh`
  (`:813-819`). R18-02 names `claim-ledger.tsv`, so it is **not skipped**; `cells` re-runs it, and
  the Round-18 post-move cell cites it as "tag surface count" (`SCORECARD.md:322`). That is the
  intended reader-vs-reinvoker distinction and is load-bearing: the cell's count is re-measured.
- C3 constraint: a mirrored fixture row must not contain `claim-ledger.sh`, or the fixture's cells
  run silently skips it and still prints `CELL_AUDIT: CLEAN` with `self_skipped` incremented.

## 4. Hermetic synthetic mode — what C3 must retain for this row

R18-02 is already host-free; the hermetic proof must not replace it with a skip or a stamp. A
`cells`-at-fixture-root run must retain:

1. The live row untagged, outside the `*claim-ledger.sh*` skip string, with `^11$` / 0 / 30
   unchanged.
2. If mirrored, a fixture-root `corpus/claim-ledger.tsv` with exactly the expected number of
   matching lines — `verify_claims` executes with `cd "$ROOT"` (`:426-427`), so the row's relative
   path resolves under the fixture root.
3. `KAGI_SUBSTRATE=absent` forced by the fixture *runner* (a ledger command cannot start with
   `env`; allowlist at `:169`). Without it, tagged fixture rows un-defer on a substrate-present
   host and could execute live-gate mirrors, violating C3's "never run live substrate commands".
4. **Exact** `rows_run=` and `row_deferred=` integers in R23-01's expected ERE, not `[0-9]+` as
   R13-03 uses (`corpus/claim-ledger.tsv:38`). Otherwise a fixture that defers or skips everything
   still prints CLEAN.
5. A mutation removing exactly one tag line (count 10 → the count row must fail) **and** a positive
   control (an untagged fixture row with a wrong expect must fail). The count-preserving swap in
   §5 is not caught by R18-02 and must not be the only mutation.
6. The live row remains one of the 43 obligations; the fixture proves the machinery, not the live
   count.

## 5. Concrete consumer-visible risk

### Primary — documented backslash refusal is not implemented; R18-02 is its only legitimate user

**Observed contract:** "no backslash" (`:93`), repeated in the guard comment (`:182-183`), in
`corpus/knowledge/claim-ledger.md:86` (`reason=backslash`) and `:348`, and in
`corpus/lessons/round-11.md:160`.

**Observed code:** `:184` is `[[ $c == *'\\'* ]]`, which matches only **two adjacent** backslashes.
Direct bash semantics test on the exact expression: the R18-02 command, `g\it`, and any
single-backslash string are **allowed**; `a\\b` is refused. The unquoted form `*\\*` refuses a
single backslash.

**False-clean (OBSERVED semantics):** a row `bash corpus/ok.sh the-jan\itor` passes
`policy_check` — first token `bash`; no `META_RE` character; the guard misses; the quote-stripped
deny regex (`:187-189`) sees `the-jan\itor`, which does not match `the-janitor`. `bash -c` then
unescapes the argument (`printf '%s\n' the-jan\itor` → `the-janitor`). The round-11 guard against
denied-name smuggling is therefore absent for any non-first-token name. (The first-token allowlist
still refuses a backslash-obfuscated first token, so the round-11 `g\it` example is masked by a
different check.)

**False-fail (OBSERVED inventory + INFERENCE on the fix):** a static scan of field 2 shows
**R18-02 is the only row whose command column contains a backslash**. Correcting `:184` to match
its own documentation turns this legitimate, host-free row into `POLICY … reason=backslash` exit 2;
`verify` then exits 2 and, because `SCORECARD.md:322` cites it, `cells` exits 2 `CELL_AUDIT: POLICY`
(`:1002-1004`).

**Minimal synthetic failing fixture (proposal; not run here):**

```
c1<TAB>bash corpus/ok.sh the-jan\itor<TAB>^ok$<TAB>0<TAB>5<TAB>selftest
```

with a scratch `corpus/ok.sh` printing `ok` (a stand-in; it never invokes the handler). Documented
contract: exit 2 + `POLICY c1 reason=backslash`. Current bytes: admitted, row passes,
`CLAIM_LEDGER: CLEAN` — so the fixture fails against current code.

**Recommended fix:** tighten `:184` to a true single-backslash refusal and rewrite R18-02 to a
backslash-free equivalent, e.g. `grep -cE '[[]substrate]' corpus/claim-ledger.tsv`. Under
`/usr/bin/grep` this matches the literal `[substrate]` (`[substrate]`→1, `substrate`→0,
`[substrate`→0) and the command text contains no contiguous `[substrate]`, so the count remains 11
(INFERENCE from ERE equivalence; not run on the ledger). Add selftest cases for single-backslash
refusal and for the bracket-form admission. The alternative — narrowing the documented contract to
permit escaped ERE brackets — needs quote-aware parsing and is riskier.

**Operability bound:** the row depends on the `grep` on PATH. In a child `bash -c`, `type -t grep`
is `file` and `type -P grep` is `/usr/bin/grep`; both ERE forms work there (verified). The
PCRE2-style `pi-uu-grep` builtin that rejected `[[]substrate[]]` exists only in the interactive tool
shell, not in the gate's subshell. Whichever form is chosen, record the grep dependence.

### Secondary — count is not set (silent tag swap)

**Observed:** R18-02 counts matching lines anywhere in the file, while the gate defers on field 6
only (`:416-419`); no row pins an exact deferred count (the only expect mentioning it is R13-03's
`row_deferred=[0-9]+`). A tag can therefore **vanish** from a row and **appear** in a comment line,
keeping the count at 11.

**Concrete false-clean:** remove the tag from a row whose command still passes on an absent host
(e.g. R11-03, whose census selftest now passes hermetically per `Entry20.md:43`) and add the literal
to a `#` comment line. R18-02 still sees 11 and passes; `deferred` drops 11→10; nothing compares
`deferred`, so both `CLAIM_LEDGER: CLEAN` and `CELL_AUDIT: CLEAN` are printed. The scorecard cell
that cites R18-02 as the "tag surface count" is re-run green against a changed tag set.

**Minimal synthetic fixture (proposal; not run here):** scratch ledger with 10 rows
`bash corpus/ok.sh` whose notes end `[substrate]`, one comment line containing the literal, one
untagged count row expecting `^11$`, one untagged control. With `KAGI_SUBSTRATE=absent` the gate
prints `deferred=10` and CLEAN. Mutation: strip one row's tag (its command still passes) → the
comment keeps the count at 11, the count row passes, `deferred=9`, CLEAN. Under the row's stated
purpose (a tag cannot silently vanish unnoticed) this mutation must fail.

**Fix direction:** use an allowlisted Python row (exact path token, e.g. `corpus/claim-tags.py`)
that parses columns exactly as `verify_claims` does and prints a set digest/count, or pin the
deferred count in the `cells`/`verify` surface the fixture asserts. A line count cannot express
set identity.

## 6. What C1 closure-disposition integration must retain

- Resolve R18-02 → row 49 → command → `corpus/claim-ledger.tsv` (blob `51d676d1…`, stamps row 5)
  and `corpus/claim-ledger.sh` (sha256 `cf56f9ea…`, stamps row 4). Do not accept a count-only or
  row-existence assertion; the in-flight (untracked) `corpus/closure-dispositions.py` resolves
  `file#anchor` pointers and enforces one disposition per obligation (`:9-44`, `:104-116`) but does
  **not** compare a cited cell's prose number to the row's verdict.
- That gap is live: `SCORECARD.md:322-323` still says "10 rows are *carried*" and "10 claims are
  parked", while the same Evidence cell cites R18-02 (11) and the same section's carried-debt list
  says 11 (`:333`). The "10" was already wrong at `fecee87` (11 note-tags at that commit). `cells`
  cannot catch it: the pointer resolves and the row re-runs green. C1 should record it as stale
  text or append an erratum; do not count R18-02's green row as agreement with "10".
- Retain the untagged invariant and the 11-id set: R11-01, R11-02, R11-03, R11-04, R11-06, R12-01,
  R13-03, R15-01, R16-01, R16-03, R17-01.
- D9's `fixed` pointer must resolve to the actual fixture **and** the gate path that the fixture
  proves; R18-02 must not become SKIP-SELF (it invokes `grep`, not the gate).

## 7. Historical vs current evidence

| Class | Evidence | Status |
|---|---|---|
| Historical | `frozen/before/corpus/claim-ledger.tsv:49` old note: "10 tagged rows plus this row's own pattern" | withdrawn by round-22; self-match never occurred |
| Historical | `.ufo/waves/round-22/pin-migrations-integration.json` R18-02 old→new (note-only; `^11$` unchanged) | tracked; expectation not rewritten |
| Historical (executed) | `.ufo/waves/round-22/final-verification.json` R18-02 exit 0 / stdout `11` / last `11` / 0.001 s at `4be5da3` | applies to current bytes (same blob) |
| Historical | `.ufo/waves/round-22/build/Entry20.md:47` (C4): note wrong, pin value correct; scorecard 10-vs-11 flagged | advisory report; no corpus erratum |
| Historical | `fecee87:corpus/claim-ledger.tsv` — 11 note-tags; `fecee87:SCORECARD.md:322-323` already said 10 | factual error from origin, not later drift |
| Current | ledger line 49 (new note), 11 field-6 tags, stamps fresh | observed at HEAD |
| Current | `SCORECARD.md:322-323` "10 rows" / "10 claims" | still present at HEAD |
| Current (planned) | `plans/round-23.md:32-39` C3 fixtures + R23-01 | not implemented: no `corpus/fixtures/`, no R23 rows |

## 8. Remaining unknowns

- Whether the 11 tagged rows each genuinely measure the substrate (per-row owners; not adjudicated).
- Whether L1 will integrate the policy-guard correction in round 23 (a fix breaks R18-02 unless the
  row is rewritten in the same change).
- No live `verify`/`cells` run was made to re-confirm 11 beyond the round-22 receipt; the count is
  supported by static field identity plus that receipt.
- Exact fixture ids/counts for R23-01 are L1's design; this report states constraints only.

Report: .ufo/waves/round-23/parent-build/ClaimR18X02.md
