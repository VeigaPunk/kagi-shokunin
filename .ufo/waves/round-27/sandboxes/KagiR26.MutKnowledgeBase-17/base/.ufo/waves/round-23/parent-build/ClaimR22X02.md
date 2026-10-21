# ClaimR22X02: the R22-02 feature-claims selftest verdict holds, but `cases=12` proves the case set, not the strength of each assertion

Scope: a read-only audit of one row. No gate, selftest, mutant, census, ledger, git or jj command
was executed. HEAD was read from the file `.git/HEAD`. This file is the only write.
`K` = `/home/vgpnk/Projects/shokunin/kagi-shokunin`; every path below sits under `K/`.

## 0. Observed revision

- HEAD: `d218603b74099ddca0bd8f869516fc41db0979bf`.
- **Frozen epoch:** first hashed about 2026-10-21T00:4x-03:00.
  - `corpus/claim-ledger.tsv` = `e6806968…ce8305`.
  - `corpus/claim-ledger.sh` = `cf56f9ea…6cb2c2c`.
  - Both equal `.ufo/waves/round-22/final-verification-inputs.json`.
- **In-flight epoch (L1 integration, at 00:58:32):**
  - Changed: ledger = `6fa0c24f…`, `claim-ledger.sh` = `c20c2d04…` (still 1428 lines; every claim-ledger.sh line cited below is unchanged).
  - New, untracked: `corpus/closure-dispositions.{py,json}`, `corpus/fixtures/cells-hermetic/`, `corpus/lessons/round-23.md`, `corpus/source-fetches.tsv`.
- **Unchanged in both epochs:**
  - `corpus/feature-claims.py` = `d53b39fe…4de164` (1052 lines, 46,095 B).
  - `corpus/feature-claims.json` = `a66acbfb…38449b` (48,164 B).
  - Both equal `corpus/stamps.tsv:9-10` and `final-verification-inputs.json`.
- The R22-02 line itself is byte-identical in both epochs. It equals `pin-migrations-falsifier-repairs.json` `claim_changes[R22-02].new` (line sha256 `ec03b885efc9dfda…`).

## 1. Row

`corpus/claim-ledger.tsv:56` has these fields:

- command: `python3 corpus/feature-claims.py --selftest`
- expected last line (ERE): `^FEATURE_CLAIMS_SELFTEST: PASS cases=12$`
- exit: `0`
- timeout: `120`
- note: untagged (no `[substrate]` tag).

## 2. Expected verdict, last line, exit and timeout: SUPPORTED

All `:` line references in this section are to `feature-claims.py`.

- **Last line.**
  - `PASS cases=N` is the final print (`:954`) and only happens when `failures == 0` (`:951-953`).
  - Child output is captured, not echoed (`_invoke` `:863-881`: stdout PIPE, stderr→STDOUT).
  - So the anchored ERE matches exactly.
- **The count is a membership pin.**
  - 12 = 6 fixed invocations (`:924-931`) + 6 `--input` cases (`:916-923`, appended at `:932-943`).
  - `cases += 1` runs for each executed invocation (`:947`).
  - Any `_invoke` error aborts the whole selftest (`:880-881`), so PASS implies all 12 ran.
- **Exit codes, all of which fail closed against `0`:**

  | Outcome | Exit | Source |
  |---|---|---|
  | All 12 cases pass | 0 | `:955` |
  | A case assertion fails | 1 | `:953` |
  | `GateError` (artifact pin drift, `FC-SELFTEST-INVOKE`, `FC-SELFTEST-ARGS`) | 2, prints `CANNOT_EVALUATE` | `:1044-1046` |
  | Uncaught exception (traceback) | 1 | — |

  `claim-ledger.sh` `verify_claims` (`:400-445`) applies exit equality (`:433`) and then the last-line ERE (`:442`).
- **Timeout 120 s.**
  - Measured runtime: 0.332 s (`.ufo/waves/round-22/final-verification.json:466-481`).
  - The first hung child aborts the selftest within 20 s (`:945`, `:880-881`), well inside 120 s.
  - If the outer limit fires, the result is `reason=timeout` (`claim-ledger.sh:428`).
- **Policy.**
  - `python3` passes the `PYTHON_SCRIPT_RE` script allowlist (`claim-ledger.sh:161`; in-flight it also allows closure-dispositions, and R22-02 still matches).
  - No shell metacharacters and no denied word.
- **Data integrity.** The selftest re-validates the six canonical-digest pins of `feature-claims.json` before it builds its fixture (`:61-66`, `:887-888`, `_artifact` `:742-753`). Data drift therefore makes R22-02 exit 2.

## 3. What each of the 12 cases actually proves (static reading)

| Case(s) | Can a regression slip past it? | Why |
|---|---|---|
| `after` | no | exit 0 needs all 4 after-controls admitted with no mismatch (`:829-847`) |
| `boundary` | no | exit 2 needs all 3 boundary records to give their exact cannot-evaluate finding (`:787-799`) |
| `before` | **yes** | Exit 1 is forced by `phase == "before"` (`:835`) whatever the per-record decisions are. The four markers only check that a substring is present (`:948`). |
| `input-path-escape` | **yes** for the `..` guard | see §6 |
| `claims-fifo`, `input-fifo` | no | Dropping O_NONBLOCK (`:263`) makes the open block, so the 1 s child timeout fires and the selftest exits 2 with `FC-SELFTEST-INVOKE`. Accepting a non-regular file (`:265`) means no `FC-CLAIMS-FILE`, so the assertion fails. |
| 6 `--input` cases | no | each checks an exact exit plus a specific finding |

More on the `before` case. The recorded `--phase before` output (`final-verification.json` `additional[4]`) contains these findings:

- STATUS-MISMATCH ×2
- ELIGIBILITY-QUALIFIER ×2
- CROSS-PRODUCT ×2
- EVIDENCE-ANCHOR ×1
- RUNTIME-CONSTRAINT ×2 (no marker asserts these)
- STATUS-UNSUPPORTED ×1 (no marker asserts this)

**Net effect.** R22-02 does re-verify:

- the 4 bounded admits;
- the 3 boundary exclusions;
- 4 of the 10 known-bad classes with exact findings (E1-ELIGIBILITY, SAME-PAGE-PREVIEW, E3-VAULT-ONLY, CUSTOM-UNDERCITED);
- the valid and permuted admits;
- FIFO refusal.

It does **not** re-verify:

- the decisions for the other 6 before-records;
- the `..` containment guard;
- the note's "No caller expected-label override":
  - no case carries a label key;
  - the `--selftest --claims` refusal at `:885-886` and `:1013-1014` is never invoked.

`SCORECARD.md:800` says "ten known-bad records refused". That rests on the recorded `--phase before` run, which is a historical receipt. No ledger row re-runs `--phase before`; R22-01 runs `--phase after` only.

## 4. `[substrate]` deferral, SKIP-SELF and hermetic mode

- **`[substrate]`: correctly absent.**
  - Untagged rows are never deferred (`claim-ledger.sh:416-418`).
  - The script reads no HOME, environment or network (no `environ`, `getenv`, `socket` or `urllib` appears in it).
  - It must stay untagged. The substrate is absent on this host (`test -x ~/.local/bin/the-janitor` returned 1 at 00:58). A tag would therefore defer a runnable obligation and break R18-02's `^11$`.
- **SKIP-SELF: correctly not applied.**
  - Only commands containing `claim-ledger.sh` are skipped (`claim-ledger.sh:816-818`).
  - `feature-claims.py` never invokes the ledger, so there is no recursion.
- **Hermetic: the selftest isolates itself.**
  - It copies the validated bytes into a tempdir and runs children with `--root <tmp>` and `cwd=<tmp>` (`:866-881`, `:893-897`).
  - It has undeclared host needs:
    - `python3`;
    - a FIFO-capable `tempfile.gettempdir()`: an OSError from `os.mkfifo` at `:914-915` is uncaught, giving a traceback and exit 1 [INFERENCE];
    - Linux O_* open flags (`FC-SAFE-OPEN`, `:252`).
  - The root comes from the **resolved script path**, not from cwd (`:216`, `:890`).
- **Cell pointer.**
  - The only scored cell that cites R22-02 is `SCORECARD.md:737` (Round 22 post-move, calibration). `IDWORD_RE` (`claim-ledger.sh:631-632`) extracts both R22-01 and R22-02 from `R22-01/R22-02`.
  - Only R13-03 (`cells`) re-runs that cell's rows. R13-03 is tagged `[substrate]`, so it is deferred on this host.
  - R13-03 was also skipped in the round-22 final verification (`SCORECARD.md:803-805`).
  - So the cell→row re-run is currently never exercised; R22-02's direct row is the only live path.

## 5. What integration must retain for this row

### C3 (in-flight `R23-01`)

The in-flight fixture `corpus/fixtures/cells-hermetic/claims.tsv` holds only rows R90-01 and R90-02.

1. R22-02 is not part of the hermetic proof. Its obligation survives only because its row is unchanged (checked above) and runs directly.
2. Preservation should be checked as an exact 5-column tuple against frozen line 56, not through R21-04's row count.
3. If R22-02 ever enters a fixture:
   - copy `corpus/feature-claims.{py,json}` as **regular files** whose sha256 equals `stamps.tsv:9-10`;
   - never symlink the script: it would resolve its root back to production (`:216`), and mutations of the fixture JSON would go unseen (false-clean);
   - missing files make Python exit 2, so the row FAILs.
4. A clean R23-01 must not be read as re-verifying `SCORECARD.md:737`. Keep R13-03's skip explicit; the in-flight `corpus/lessons/round-23.md:121-130` already does this.

### C1 (in-flight closure-dispositions)

1. Follow R22-02's evidence pointer by pointer:
   - ledger line 56 tuple;
   - → `final-verification.json:466-481`: exit 0, exact `last`, and `expected_last_ere` equal to ledger column 3 (checked: true);
   - → `final-verification-inputs.json` digests plus `expected_selftest_cases.feature=12` (`:35`);
   - → current bytes;
   - → `stamps.tsv:9-10`.

   `summary.safe_passed=31` is only count assurance.
2. **D6, evidence specific to this row.**
   - R22-02's own receipt (`cases=12`) shows that `final-verification.json:2` `.h1 = 8ada17a5` is not the measured revision. H1 bytes gave `cases=10` (`repaired-checks.json:15`; the row note says "H1 had10").
   - The in-flight D6 disposition is `fixed`, pointing at `corpus/lessons/round-23.md#Routed defect dispositions`. That fix only looks forward (`round-23.md:101-103`).
   - The checker only checks that the file exists, names the id and has the heading (`closure-dispositions.py:104-116`, stated bound at `:41-44`). It cannot see a missing round-23 verdict file, or one that leaves out the R22-02 run.
   - For this row, D6 is retired only when `.ufo/waves/round-23/final-verification.json` carries `measured_commit`, an R22-02 execution, and the two feature-claims digests.

### C2

R22-02 validates the canonical digest of the embedded source catalog (`:62`, `:326`). That checks the integrity of review-time attestations (`digest_observed_at` 2026-10-19/20); it says nothing about whether the pages are current.

- Do not edit `feature-claims.json` `sources`: R22-01 and R22-02 would turn into exit 2 `FC-SOURCE-MANIFEST`.
- The S012/S013 digest provenance belongs to the SourceS012/SourceS013 reports and is not repeated here.

## 6. Falsifier: false-clean visible to consumers (proposal, not executed)

**Claim at risk.** Readers take a PASS as including path containment:

- `.ufo/waves/round-22/falsify/AttackActiveReview.md:49`: "includes `--input ../outside.json` path refusal";
- the help text (`:1020`): "one typed claim beneath --root".

**Mutant P (one token).** At `feature-claims.py:243`, change `("", ".", "..")` to `("", ".")`.

**Static trace:**

- `../outside.json` passes the regex at `:245`.
- `_read_beneath` opens `..` through `dir_fd`; O_NOFOLLOW does not block `..`. That lands in `tempfile.gettempdir()`.
- `outside.json` is absent there, so the open raises ENOENT.
- `except (OSError, ValueError)` turns that into `FC-CLAIMS-PATH` (`:284-285`), exit 2. That is exactly what the case expects (`:928`).
- The other 11 cases and R22-01 are untouched.
- Result: `FEATURE_CLAIMS_SELFTEST: PASS cases=12`, exit 0, R22-02 green. Meanwhile `--root R --input ../x.json` now reads outside R.
- The survival condition holds here: `/tmp/outside.json` was absent at 00:58.

**Minimal fixture for L1:**

- Scratch tree:
  - `T/root/corpus/feature-claims.json` (a copy);
  - `T/outside.json` = the `AFTER-CUSTOM-BETA-BOUNDED` claim.
- Expected results:

  | Script | Command | Result |
  |---|---|---|
  | production | `python3 <script> --root T/root --input ../outside.json` | exit 2, `FC-CLAIMS-PATH` |
  | mutant P | same | exit 0, `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |
  | mutant P | `--selftest` | still `PASS cases=12` (the false-clean) |

**Fix (keeps `cases=12`, so the row text stays the same):**

- In `_selftest`, set `fixture_root = Path(temporary) / "root"`.
- Write `valid_claim` to `Path(temporary) / "outside.json"`.
- Under P, the escape case then admits with exit 0, giving `FAIL cases=12 failed=1`.
- The byte change requires a repin of `stamps.tsv:10` with a QM14 old/new journal (owned by R22-03/R12-03).
- Optional `--claims ../`, absolute-path or intermediate-symlink cases would change the count and need an R22-02 old/new journal.

**Secondary falsifier (calibration axis, same class): mutant M.**

- Delete the `not_asserted` branch (`:651-652`).
- Only BEFORE-VAULT-GA-UNPINNED reaches that branch (per the recorded output). It becomes `reject:false-claim FC-STATUS-MISMATCH`.
- The `--phase before` summary becomes `false_claims=3 bar_failures=7`, but all 12 cases still pass: the exit is forced at `:835` and the STATUS-MISMATCH marker is still present.
- Effect for consumers: `--input` now calls an unsourced Vault-GA claim *false* instead of *unsupported*, with the same exit 1. This blurs the QA9/QA10 distinction (`corpus/knowledge/feature-bound-credential-review.md`, "Missing product support" row).
- Fix (count stays 12): assert the 10 exact recorded `DECISION` lines plus this summary:
  `FEATURE_CLAIMS: FAILED phase=before false_claims=2 bar_failures=8 false_admissions=0 misses=0 finding=FC-RUNTIME-CONSTRAINT`.

**Not found.** No single-site evaluator change produces a false *admission* of a before-record. Each weakly covered record fails at least two independent checks: a claim qualifier, and evidence completeness or binding (`:626-739`) [static]. No admission defect is claimed.

## 7. Historical vs current evidence

- **Historical (H1 `8ada17a5`):**
  - `PASS cases=10` (`repaired-checks.json:15`);
  - `safe-row-plan.json:204` expects `cases=10`, but describes itself as a "plan, not an exercised pass";
  - `pin-migrations-integration.json:449-451` holds the `cases=10` row;
  - `SCORECARD.md:755` says "10 self-invocations", under "before falsification";
  - the FIFO hang was exercised at H1 (`falsify/SentinelClaimInput.md:14-22`), which led to O_NONBLOCK plus two new cases.
- **Migration:** `pin-migrations-falsifier-repairs.json:124-126` (from `8ada17a5`) changes `cases=10` to `cases=12`; the current line equals `new`.
- **Current:**
  - `final-verification.json:466-481` records PASS `cases=12`, exit 0, 0.332 s, on bytes bound by the inputs digest file;
  - `SCORECARD.md:686,800`;
  - the non-author spot-check verified this from evidence but did not re-run it (`corpus/lessons/round-22-verifier-spotcheck.md:35-36,71`).

## 8. Verdict

| Question | Finding |
|---|---|
| Expected verdict / last line / exit / timeout justified? | **Supported** |
| `[substrate]` deferral and SKIP-SELF preserve the obligation? | **Supported**: neither is applied, correctly |
| Hermetic mode preserves it? | **Supported** for the selftest itself; R22-02 sits outside the C3 fixture, and its unchanged direct row carries it |
| Coverage implied by the note and the scorecard? | **Refuted in part**: `cases=12` proves case membership, but 3 of the 12 assertions are non-discriminating (`before`, `input-path-escape`, and the absent label case), and mutants P and M survive |

## Limits

- Nothing was executed. Mutant outcomes are static traces [INFERENCE]. The only executed evidence used for per-record findings is the recorded output in `final-verification.json`.
- No git or jj was used. In-flight files are a snapshot taken at 00:58 and may have moved since.
- A false-fail of the 1 s FIFO budget under heavy load is not evidenced (all 12 cases took 0.332 s) and is not claimed.
- Diagnostics gap: a FIFO regression is reported as `FC-SELFTEST-INVOKE` with no case id.
- Tools installed or updated: none. Public sources quoted: none.
