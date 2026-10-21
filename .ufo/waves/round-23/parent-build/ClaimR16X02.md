# ClaimR16X02 — R16-02 (`scope-gate.sh --selftest`) audit (round 23, attempt 1)

Seat: `ClaimR16X02` (scout, leaf, read-only). Axes: **calibration**, **freshness**,
**operability**. Scope: exactly row `R16-02`; sibling rows R16-01/R16-03 and all SOURCES
rows are other owners. No command executed (contract: no behavioral gate execution), no
build/lint/test, no installs, no production or source mutation beyond this file.

- Observed revision: git `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf` (matches
  `plans/round-23.md:3`). Working tree: no tracked modification; untracked only
  `.ufo/waves/round-23/**`, `plans/round-23.md`, `corpus/closure-dispositions.py`,
  `corpus/closure-dispositions.json`, `corpus/__pycache__/` (in-flight C1 work, treated
  below as in-flight, never as landed evidence).
- Gate revision: `corpus/scope-gate.sh` sha256
  `078a260184e25282096ef5f611b01ac1fb97deddb52d78facc1d551ff61f8082`, 1129 lines,
  55002 bytes — equals `corpus/stamps.tsv:59`.
- Ledger revision: `corpus/claim-ledger.tsv` sha256
  `e6806968436375870067d0e587fb1e8ea27e5d3304b8bb563e3f484c1dce8305`, 58 lines,
  17844 bytes — equals `corpus/stamps.tsv:5`. Row at **line 40**.
- Gate text has not changed since `bc1af88` (round 17): `git log -- corpus/scope-gate.sh`
  lists only `8a6ec16`, `bc1af88`. The round-22 receipt therefore measured the same gate
  bytes audited here.

## 1. The obligation, exactly as committed

`corpus/claim-ledger.tsv:40` (six TAB fields, header contract at `:2-4`):

| field | value |
|---|---|
| id | `R16-02` |
| command | `bash corpus/scope-gate.sh --selftest` |
| expect (ERE) | `^SCOPE_SELFTEST: PASS \(61 cases\)$` |
| exit | `0` |
| timeout | `300` |
| note | "… 43 partition cases plus 18 breadth cases covering completeness, exact directive schema, aggregate/no-enumerate/scan boundaries, invalid arithmetic, both count-drift directions, missing/not-dir/symlink roots, hostile names, and whole-HOME refusal" |

## 2. Is the expected verdict / last line / exit / timeout justified? — **supported**

1. **Emitter is exact and conditional.** `scope-gate.sh:1121` prints
   `SCOPE_SELFTEST: PASS (%s cases)` and exits 0 **only** when `failures == 0`;
   `:1122` prints `FAIL (failures/cases)` and exits 1 otherwise; `:1126` dispatches
   `--selftest` to that function. No other path prints a PASS-shaped line.
2. **The count is runtime state, not authored text.** `cases` is incremented once per
   executed case: 56 `run_case` sites (increment at `:883`) plus 5 explicit
   `cases=$((cases+1))` blocks (`:902`, `:1076`, `:1087`, `:1103`, `:1112`) = **61** at
   the stamped sha. A dropped case changes the count and fails the row; a failing case
   replaces the PASS line with FAIL. This is causality, not a line-count coincidence.
3. **Each case asserts two facts.** `run_case` (`:880-889`) requires the gate's exit to
   equal the case's expected exit **and** its stdout to contain the case token.
   `run_gate` (`:873-878`) invokes the shipped `$SELF` with scratch `--data/--census/
   --root/--basis-root/--lane-root`, i.e. the selftest exercises the shipped parser, not
   a copy. (Two cases are full duplicates — see §3.)
4. **Harness semantics match the row.** `claim-ledger.sh:426-427` runs the command with
   `timeout -k 5 300` from `$ROOT`; exit must equal `want` (`:434`); `expect` is matched
   against the **last non-empty line of combined stdout+stderr** (`:436`, `:441`). The
   ERE anchors and escaped parens match the emitter byte-for-byte. The command passes
   `policy_check` (first token `bash`, no metacharacters, no denied verb).
5. **Frozen executed receipt (round 22).**
   `.ufo/waves/round-22/final-verification.json` → `safe_rows` entry `R16-02`:
   `exit 0`, `stdout "SCOPE_SELFTEST: PASS (61 cases)\n"`, `stderr ""`,
   `last "SCOPE_SELFTEST: PASS (61 cases)"`, `passed true`, `seconds 4.49`, with the
   identical `expected_last_ere` in `.ufo/waves/round-22/safe-row-plan.json`. Timeout
   300 s is ~67× the only measured run; it never masks a wrong verdict — it only delays
   hang detection.
6. **Receipt provenance caveat (historical vs current).** The verdict file's `.h1` names
   `8ada17a5…`, not the measured commit `4be5da3` (round-22 spot-check D6,
   `corpus/lessons/round-22-verifier-spotcheck.md:177-178`). Its `inputs` digest set
   (`final-verification-inputs.json`) binds `corpus/claim-ledger.tsv`
   `e6806968…` — the current ledger — and `corpus/claim-ledger.sh` `cf56f9ea…`, the
   current harness, but **not** `corpus/scope-gate.sh`; the gate's immutability since
   `bc1af88` is what makes the receipt causally cover today's bytes. Treat the receipt
   as an executed point attestation of stdout/exit on unchanged inputs, not as a commit
   pin.
7. **Documentation is current at 61.** `corpus/knowledge/adjacency-scope.md:16,155,256,298`
   and `corpus/knowledge/adjacency-breadth.md:152` all state `PASS (61 cases)`.

No observation refutes the verdict, exit, or timeout.

## 3. Note decomposition — **partially stale (calibration, low severity)**

The note's "43 partition cases plus 18 breadth cases" is *migration arithmetic*, not
today's composition:

- At `8a6ec16` (round 16) the selftest held 39 `run_case` + 4 explicit = **43**
  (`git show 8a6ec16:corpus/scope-gate.sh`; corroborated by
  `corpus/lessons/round-16.md:49`).
- `bc1af88` (round 17) added 18 `run_case` + 1 explicit breadth-mode block and
  **replaced** one case: `asset-absent-named` (exit 0) became
  `asset-absent-breadth-drift` (exit 1, `scope-gate.sh:1060`) because breadth now folds
  into that verdict. Net **+18 = 61** (`corpus/lessons/round-17.md:32`).
- Current composition at `078a2601`: **44** non-breadth cases (40 non-breadth
  `run_case` + 4 non-breadth explicit) and **17** breadth cases (16 breadth-named
  `run_case`, including `clean-breadth` and the replaced asset-absent case, plus the
  explicit breadth-mode block). Two added cases are non-breadth
  (`directive-extra-field`, `noenum-whole-home-refused`), so "18 breadth" overstates
  breadth by at least one.

The asserted total (61) is correct; the 43/18 split describes baseline + delta. Fix
recommendation (L1, note text only): "61 cases (43 at round 16; +18 net in round 17)".
The note otherwise enumerates real cases: completeness (`breadth-missing`), directive
schema (`directive-extra-field`), aggregate/no-enumerate/scan boundaries
(`breadth-aggregate-refused`, `breadth-noenum`, `breadth-scan-refused`), invalid
arithmetic (`breadth-invalid-arithmetic`), count drift both directions
(`breadth-children-drift`, `breadth-declared-drift`/`breadth-exceeds`),
missing/not-dir/symlink roots (`breadth-host-missing`, `breadth-not-dir`,
`breadth-root-symlink`), hostile names (`breadth-hostile-names`), whole-HOME refusal
(`noenum-whole-home-refused`).

Counting caveats, demonstrated statically:
- `scope-gate.sh:970-971` (`bad-status`) and `:1031-1032` (`bad-value-status`) apply the
  **same** mutation (`kotoba shared-read → bogus-status`) and assert the same token
  `SCOPE BAD-VALUE`. 61 cases = 60 distinct mutations + 1 duplicate.
- Four cases assert the generic token `SCOPE BAD-ROW`; 3 share `SCOPE UNKNOWN-OWNER`;
  2 each share `SCOPE BAD-VALUE`/`OVERCLAIM`/`ESCAPE`/`STALE-BASIS`/`ENUM-CLASH`/
  `BASIS-ESCAPE`/`OWN-UNLISTED`. On inspection each mutation reaches only the intended
  parser branch, so no masking instance exists today [INFERENCE from branch reading];
  the structural limit is that a token identifies a defect class, not a rule.

## 4. `[substrate]`, SKIP-SELF, hermetic synthetic mode — obligation preserved

- **No `[substrate]` tag** (contrast `claim-ledger.tsv:39` R16-01 and `:41` R16-03).
  `claim-ledger.sh:415-420` defers only tagged rows, so R16-02 executes in every
  `verify` and was executed (not deferred) in round 22's safe rows. Correct: the
  selftest reads no host state — it builds under `mktemp -d` (`scope-gate.sh:815-817`),
  and every gate invocation passes `--root "$R/host" --basis-root "$R"
  --lane-root "$R/lanes"` (`:873-878`, breadth-mode `:902`, realpath `:1076`, map
  `:1087`); the two setup cases (`:1103`, `:1112`) never reach host data. Its only
  environment dependencies are tools on `PATH`, not host data.
- **SKIP-SELF does not apply.** `claim-ledger.sh:817` skips rows whose command contains
  `claim-ledger.sh`; R16-02's command names `scope-gate.sh`. R16-02 is cited by
  `SCORECARD.md:241` and `:302`, so `cells_evidence` (`:802-840`) re-runs it through
  `verify_claims`; the cell audit preserves the obligation by execution, not by pointer
  membership.
- **Hermetic synthetic mode is data-hermetic but not tool-pinned.** The selftest needs
  `mktemp, mkdir, chmod, rm, cat, sed, env, ln, /bin/false, dirname, basename,
  readlink, find, paste, sort, grep, printf` plus the outer `timeout`. A C3 fixture cell
  must provide these; otherwise "PASS (61 cases)" silently depends on the fixture's
  `PATH`.

## 5. What C3 (hermetic cells proof) must retain for this row

1. **Keep R16-02 in the executed set.** Do not add a skip class that covers it. Any new
   skip must be printed and counted, following the SKIP-SELF precedent
   (`claim-ledger.sh:817-818`) and the substrate DEFER line (`:416-420`).
2. **Fixtures must pass `--claims` explicitly.** `CLAIMS` defaults to
   `$SCRIPT_DIR/claim-ledger.tsv` (`claim-ledger.sh:105`) and `--root` does **not**
   rebind it (`:203`). A fixture invocation `cells --root <fixture>` with default claims
   executes the real 43 rows with `cwd=<fixture>`; R16-02 then fails at
   `bash: corpus/scope-gate.sh: No such file or directory` (rc 127) →
   `FAIL R16-02 reason=exit-mismatch exit=127` (`:430-433`) and `CELL_AUDIT: BROKEN`.
   Fix: refuse `--root` outside `SCRIPT_DIR/..` without an explicit `--claims`, or
   resolve/stage row commands against the script root.
3. **If a fixture intentionally runs R16-02, stage `corpus/scope-gate.sh` at
   `<fixture>/corpus/scope-gate.sh`.** It is then fully host-free at ~4.5 s (receipt)
   against any 300 s budget. Do not count the fixture's `rows_run=` as covering R16-02
   for the live obligation.
4. **Summary shape.** `CELL_AUDIT: CLEAN` is printed last (`claim-ledger.sh:1011`), so
   R23-01's expect can anchor on it; include `row_failures=0`. Budget: SCORECARD.md names
   41 tokens that are ledger rows (an upper bound on `CEL_IDS`); the 29 with a round-22
   measured time total 56.8 s, and R16-02 contributes 4.49 s of that. R13-03's 300 s
   (`claim-ledger.tsv:38`) is adequate today, but the fixture must not inherit the live
   cited-row set.

## 6. What C1 (closure-disposition) must retain for this row

R16-02 is not a `D` obligation; it is **cited** by two scorecard cells:

- `SCORECARD.md:230` heading `## Round 16 — post-move (adjacency axis-move landed,
  commit round-16)`; cell `:241` (operability) asserts "43 selftest cases" and cites
  `R16-01`, `R16-02`, `R16-03`.
- `SCORECARD.md:302` (round 17) states "selftest grew 43 → 61" and cites `R16-02`,
  `R16-03`.

`cells` certifies `:241` **today** [code reading, not executed]: the heading matches
`SEC_RE` (`claim-ledger.sh:690`), `R16-02` is a row (`is_row`), and `cells_evidence`
re-runs the row, which passes with 61. `cells` never compares the cell's asserted number with the
row's `expect` — so "pointer resolves and the row passes" is not evidence that the
cell's 43 still holds.

C1 must therefore:

1. Record the `:241` assertion as **superseded by `:302`** (historical), with pointers to
   both cell lines and to the row's current `expect`
   `^SCOPE_SELFTEST: PASS \(61 cases\)$` — not `fixed` on the strength of "R16-02
   passes", and not an open contradiction (the supersession is in the same document).
2. Distinguish historical from active: the same "43" also appears in
   `SCORECARD.md:95` for a **different** artifact (`claim-ledger.sh --selftest`), so a
   bare numeric match is not a row pointer.
3. Note the in-flight checker's pointer grammar. `corpus/closure-dispositions.py:104-121`
   resolves a `fixed` pointer by file existence + heading anchor + obligation-id token;
   it has no claim-row grammar, so `corpus/claim-ledger.tsv` cannot express "row R16-02,
   expect cell, exact literal". Recommendation: for a row-anchored `fixed` pointer require
   the row id at line start (`^R16-02<TAB>`) and, where a numeric claim is made, the
   asserted literal in the expect column.

## 7. Risk with minimal synthetic falsifier

**Primary — false-fail at the C3 boundary (supported by code path).** `verify_claims`
executes rows with `cwd=$ROOT` (`claim-ledger.sh:426`) while commands are repo-relative
(`claim-ledger.tsv:40`), and `--root` does not move `CLAIMS` (`:105`, `:203`). A
hermetic cells fixture that reuses real cited rows without staging their scripts turns
the one host-free row into a false failure.

Minimal fixture proposal for L1 (not executed here, per contract):

```bash
R2=$(mktemp -d); mkdir -p "$R2"                     # deliberately no corpus/scope-gate.sh
printf 'R16-02\tbash corpus/scope-gate.sh --selftest\t^SCOPE_SELFTEST: PASS \\(61 cases\\)$\t0\t300\tcopy of the real row\n' >"$R2/claims.tsv"
printf '## Round 99 — post-move\n\n| Axis | Score | What moved | Evidence |\n|---|---|---|---|\n| operability | 9 | x | `R16-02` |\n| depth | 9 | x | `R16-02` |\n| coverage | 9 | x | `R16-02` |\n| freshness | 9 | x | `R16-02` |\n| calibration | 9 | x | `R16-02` |\n| adjacency | 9 | x | `R16-02` |\n' >"$R2/SCORECARD.md"
bash corpus/claim-ledger.sh cells --root "$R2" --claims "$R2/claims.tsv" \
  --stamps corpus/stamps.tsv --scorecard "$R2/SCORECARD.md" --docs "$R2/SCORECARD.md"
```

Predicted current behaviour [INFERENCE from `:426-433` and `:802-840`]:
`FAIL R16-02 reason=exit-mismatch exit=127 want=0` then `CELL_AUDIT: BROKEN (… 
row_failures=1 …)`. Expected after the C3 fix: a setup refusal for a root outside the
script tree without a staged script, or a green run once `corpus/scope-gate.sh` is
staged. The one-row claims file keeps the observation causal and executes no real gate.

**Secondary — false-clean at the C1 boundary (live instance).** `SCORECARD.md:241`
asserts "43 selftest cases"; `claim-ledger.tsv:40` asserts 61; `cells` reports CLEAN.
Reduction: a claims file with row `R99-01` = `bash corpus/selftest-stub.sh` and expect
`^SCOPE_SELFTEST: PASS \(61 cases\)$` (stub prints that line), plus a scorecard cell
`| operability | 9 → 9 | 43 selftest cases | R99-01 |`. Predicted current
[INFERENCE]: `CELL_AUDIT: CLEAN … rows_run=1 row_failures=0` — green over a cell whose
number contradicts the row it cites. Fix: C1 compares numeric cell assertions to the
cited row's `expect`, or requires an explicit supersession marker on the cell line,
mirroring the citation `MARK_RE` convention (`claim-ledger.sh:459`).

**Adjacent contract contradiction found while tracing (not on this row's path).**
`scope-gate.sh:48` says "A missing/empty input file is a setup error (`die`, exit 2)",
but only *missing* files are SETUP (`:184`, `:187`); an empty data file is a DEFECT with
exit 1, and the selftest enshrines that (`:1093` `empty-data` want 1). R16-02 does not
exercise this (the selftest supplies valid inputs), but the gate's own contract prose
misleads a fresh reviewer. Recommendation: check `[[ -s $DATA ]]` and die, or reword
line 48 to "missing input file".

## 8. Limits

- No command executed: the row, sibling gates, and both fixture proposals above were
  **not** run; their predicted verdicts are code-reading inference and are labelled.
  Case count/composition is static at the stamped sha.
- Executed evidence is the round-22 receipt only; it binds the ledger and harness by
  digest but not `scope-gate.sh` (see §2.6), and its `.h1` is the disclosed wrong commit.
- Timeout headroom is one measured host run (4.49 s); no cold-cache or slow-disk
  measurement.
- Not audited: R16-01/R16-03 and any SOURCES row (separate owners); `--falsify`
  behaviour; live `verify`/`breadth` counts (host-dependent, out of scope).

Report: .ufo/waves/round-23/parent-build/ClaimR16X02.md
