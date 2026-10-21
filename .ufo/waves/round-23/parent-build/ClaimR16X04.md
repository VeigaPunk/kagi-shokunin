# R16-04 — owned-prefix count: the verdict is a spelling filter, not the declared-prefix count

- **Row**: `corpus/claim-ledger.tsv:42` (6 tab fields, 685 bytes UTF-8)
- **Command**: `grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv` · **expect** `^5$` · **exit** 0 · **timeout** 30
- **Observed revision**: HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 -0300, "round-22 verifier spot-check (integrator, hyaku): non-author admit/reject")
- **Method**: read-only source/fixture/receipt audit. The row was not run through `verify`/`cells`, no sibling gate, handler, op, vault or host command was executed (see §8 Limits).

## 1. What the row binds today — SUPPORTED for current bytes

- `corpus/adjacency.tsv` is 83 lines / 5660 bytes; sha256 `4d9bfb1145aa46290b1184f24a8b230db71fc71b72d5d688eac9dfa7811f9549`, exactly equal to `corpus/stamps.tsv:1` (sha + line + byte columns), so the row's count is bound to pinned bytes, not just a worktree copy.
- Five `# own` directives: `corpus/adjacency.tsv:48-52`. Four `# owner` vocabulary directives: `:54-57`. No other line in the file begins `# own`; the header instruction at `:41-42` is the only place that discusses directive counting and it is accurate ("header prose also begins with directive words").
- Historical receipt: `.ufo/waves/round-22/final-verification.json` → `safe_rows` record `id=R16-04`, `exit=0`, `stdout="5\n"`, `last="5"`, `passed=true`, `seconds=0.001`; summary `safe_rows=31 safe_passed=31 skipped=12`. R16-04 is **not** in `skipped_rows` (that list is the 11 `[substrate]`-tagged rows — including R13-03, which is also the self-referential one — plus the untagged but host-dependent R18-01).
- Frozen membership: `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:42` is byte-identical to the current row (verified by diff).
- Verdict/exit/timeout are **justified** for these bytes: `grep -c` prints `5` and exits 0; zero matches exits 1 (so a zero-match file fails at `claim-ledger.sh:433` before the verdict); a missing file exits 2; 0.001 s observed against a 30 s timeout is ~3×10⁴ margin. `expect` passes the literal-only guard (`claim-ledger.sh:414`).

## 2. Causal chain — who actually consumes this row

1. `corpus/scope-gate.sh` parses `# own` (`:202`), expands only `$HOME` (`:121-124`), and derives the partition; its summary prints `census=35 owned=27 shared=8 …` but **no own-prefix count** (`:640-655`). The gate therefore cannot substitute for this row; R16-04 is the only pin on the number of `# own` directives.
2. `SCORECARD.md:237` — the Round 16 post-move `adjacency` cell (section heading `:233`) — cites `R16-04`/`R16-05`/`R16-06`. `cells` tokenizes that cell into `CEL_IDS` (`claim-ledger.sh:715-786`) and re-runs the row through `cells_evidence` (`:802-828`). **SKIP-SELF does not fire** (`:816-818`, command does not contain `claim-ledger.sh`), so the scored adjacency cell genuinely depends on this row executing.
3. `corpus/knowledge/adjacency-scope.md:19` lists `R16-04` in `Reverify:`; `docs` only checks that the id resolves (`claim-ledger.sh:906-918`), it does not execute the row. The entry restates the number at `:4`, `:47`, and reproduces the exact command with `# 5` at `:261`.
4. `corpus/stamps.tsv:1` pins `corpus/adjacency.tsv`; `verify_stamps` (`claim-ledger.sh:371-383`) makes any edit STALE until deliberately re-stamped.
5. Number-restating consumers outside the mechanism: `corpus/README.md:44`, `PROVINCE.md:51`, `SCORECARD.md:237`, `LOG.md:600`, `corpus/lessons/round-16.md:28`, `corpus/knowledge/adjacency-scope.md:4,47`.

## 3. Finding F1 (calibration) — the predicate measures spelling, not the claimed quantity (high confidence)

`META_RE='[;&|<>$`]'` (`claim-ledger.sh:163`) refuses `$` in any claim command, so the row cannot write a literal `$HOME`. `.HOME/` is an ERE wildcard: *one arbitrary character*, then `HOME/`. It matches `# own<TAB>$HOME/...` only because `$` is the wildcard character. Observed consequences:

- **False-fail (primary, consumer-visible).** `corpus/adjacency.tsv:10` documents a surface root as "`$HOME/...` or absolute", and `expand()` (`scope-gate.sh:121-124`) leaves absolute paths literal; R11 (`:445-467`) compares *expanded* strings. On the live invocation `ROOT=$HOME` (`scope-gate.sh:89`), rewriting one own directive from `$HOME` spelling to the absolute spelling of the same path keeps the partition identical and the default gate summary CLEAN (the R16-01 invocation has no `--map`), but the row prints `4` → `FAIL R16-04 reason=verdict-not-final` (`claim-ledger.sh:442`) in `verify`, and `row_failures=1` → `CELL_AUDIT: BROKEN` in `cells` — breaking the scored cell at `SCORECARD.md:237` although ownership did not change.
- **False-clean polarity (weaker).** Appending a sixth `# own` directive spelled absolutely and nested under an already-owned prefix (e.g. a census file row such as `$HOME/.config/the-janitor/op.env`, `surface-census.tsv:24`) leaves the row at `5` and the gate summary identical: the literal `is_dup` check (`scope-gate.sh:202`) does not see it, first-match coverage is unchanged (`:295-299`), and R11 matches the expanded census row. The file then declares six `# own` directives while six docs say "5". Any *coverage-changing* count-preserving swap is caught by `owned=`/`shared=` in R16-01, so the practical exposure is the false-fail plus undetected spelling changes, not silent ownership drift.
- **F1b (separator class; correction from the R16-06 owner, supported).** `scope-gate.sh:191-196` splits on TAB only (`IFS=$'\t'`) and `continue`s when the second field is empty, so a space-separated `# own $HOME/x` line is treated as prose, not a directive. The row's `[[:space:]]+` matches it anyway, so the row can count a "declaration" the gate never parses. `[[:cntrl:]]+` matches TAB but not SPACE and follows the parser; statically, `^# own[[:cntrl:]]+[^[:cntrl:]]` matches exactly the five directives at `:48-52` today. This is independent of F1: `[[:cntrl:]]` alone still excludes an absolute-spelled directive, so the fix needs both changes.
- **Note rationale F2 (refuted as written).** The row's note says the `+.HOME/` tail exists because "the file's own prose lines also start with `# own` (a naive count returns 9)". The 9 is `5 # own + 4 # owner` (`adjacency.tsv:54-57`); there are **zero** prose lines beginning `# own`. `^# own[[:space:]]` alone already excludes `# owner`; the `.HOME/` tail's actual effect is the spelling filter above (and it makes the note's stated reason wrong, hiding the defect). The note's "the gate computes the prefix count" is also imprecise: the gate has no prefix count (`scope-gate.sh:640-655`).

## 4. [substrate], SKIP-SELF, hermetic synthetic mode — obligation preserved, with conditions

- **[substrate]**: untagged and correctly so. The row reads only a committed file; `substrate_present()` is consulted only for tagged notes (`claim-ledger.sh:416-420`). Keeping it untagged matters: on a substrate-absent host R16-01/R16-03 defer, and this row is one of the few adjacency checks that still executes. Tagging it would erase the obligation exactly where it is most load-bearing.
- **SKIP-SELF**: not applicable (`:816-818`). Do not move this count into `claim-ledger.sh`; any command containing that name is skipped inside `cells` (reported as `self_skipped`, never executed), which would silently drop the obligation.
- **Hermetic synthetic mode**: the command runs under `cd "$ROOT"` (`:427-428`), so a hermetic `--root` must stage `corpus/adjacency.tsv`, else `grep` exits 2 and the row fails. `KAGI_SUBSTRATE=absent` does not affect this row. Caveat for C3: `CELL_AUDIT: CLEAN` does **not** require `row_deferred=0` (`:1006-1013`), and `rows_run` counts selected rows including deferred ones (`:415`, `:828`); a CLEAN summary with deferrals is not proof for the deferred rows.

## 5. What C1 closure-disposition must retain

For R16-04, disposition must be resolved from pointers, not from "row exists / cited once":

- **EXECUTED** (untagged), never DEFERRED; closure evidence is exit 0 / last line `5` on the stamped bytes plus the round-22 receipt.
- Follow `SCORECARD.md:237` → `cells` re-run. This is the only scored-cell pointer to the row; a checker that walks only `Reverify:` declarations or only row ids would still miss the execution edge.
- Follow `corpus/knowledge/adjacency-scope.md:19` **and** its numeric claims at `:4`, `:47`, `:261`; today `docs` resolves the id but does not bind the doc's "5" to the row's verdict.
- Follow `corpus/stamps.tsv:1`: the count means `5` **for those bytes**; a re-stamp is a disposition event (new revision, re-checked count), not a green.
- Do not let a green R16-04 dispose of coverage (`owned=27` is R16-01) or of prefix identity (the row cannot see which prefixes, only how many `$HOME`-spelled ones).

## 6. What C3 hermetic cells proof must retain

- Account R16-04 in the **executed** class; assert exit 0 and stdout `5`, and assert it is absent from the deferred set.
- Stage `corpus/adjacency.tsv` byte-equal to `corpus/stamps.tsv:1` under the hermetic root, or use a synthetic claims row + fixture pair whose expectation is derived for that fixture (never the live `^5$` against a different fixture).
- If live substrate must not run, force `KAGI_SUBSTRATE=absent` and assert the deferred set equals the declared substrate-tagged rows at HEAD (11, matching R18-02's expectation; note R13-03 is also self-skipped when cited) minus rows actually self-skipped. R16-04 must be in neither set.
- Assert that the only deferrals are the declared substrate-tagged rows, and that `row_deferred` is never allowed to stand in for a non-substrate row that did not execute.

## 7. Minimal synthetic falsifier (proposed for L1; not executed)

Fixture `$R/corpus/adjacency.tsv` with five directives, the fifth spelled absolutely:

```
# own	$HOME/a
# own	$HOME/b
# own	$HOME/c
# own	$HOME/d
# own	/abs/e
```

Claims row identical to `corpus/claim-ledger.tsv:42`. Derived result (from `claim-ledger.sh:427-445`): stdout `4`, exit 0 ⇒ `FAIL R16-04 reason=verdict-not-final` in `verify`; in the cells path, `row_failures=1` and `CELL_AUDIT: BROKEN`. Gate-side control for L1: an `ADJ_HOME`-rooted copy whose absolute prefix equals the expanded census row should print `ADJACENCY_SCOPE: CLEAN` with the same `owned=`/`shared=` fields, proving the fact is unchanged. (Gate acceptance of the absolute prefix is a code-path inference, not executed; it holds when `ROOT == $HOME`.)

Fix options for L1:

1. **Preferred, policy-clean**: `grep -cE '^# own[[:cntrl:]]+[^[:cntrl:]]' corpus/adjacency.tsv` → 5 today (statically verified); matches the gate's TAB-only parser (`scope-gate.sh:191-196`), counts every declared own prefix regardless of path spelling, and excludes `# owner` and a bare `# own`. Rewrite the note: 9 = 5 `# own` + 4 `# owner`; the predicate is separator-faithful and spelling-agnostic; the gate has no prefix count. If L1 also wants to catch space-written directives that the gate silently drops as prose, make that a second, explicit guard (e.g. a `[[:space:]]` count expected to stay 5), not this row's quantity.
2. **Alternative**: keep the predicate, document the `$HOME`-only bound in the note and in `adjacency-scope.md` §Bounds, and re-stamp the entry if its reproduction text changes.
3. If **identity**, not count, is the intended claim: a claim command cannot express it (`META_RE` forbids `$`); use a script plus a row.
4. The same `.HOME/` spelling class exists in R16-06, R17-02, R17-03 — route to their owners; not audited here.

## 8. Limits

- The row was not executed as a claim: no `verify`/`cells`/`scope-gate`/handler/op/vault/host command was run. While checking bytes I did evaluate the same read-only `grep` pattern over `corpus/adjacency.tsv` (observed `5`), statically matched the two candidate replacement predicates (`[[:space:]]` and `[[:cntrl:]]`, 5 each) against the same file, and used `sha256sum`/`wc` for the stamp comparison; that is a literal re-evaluation of the row's read-only command, disclosed rather than presented as a gate result.
- Revision identity came from read-only `git rev-parse`/`git log -1`; no worktree, index or ref operations.
- `verify`/`cells` behavior is inferred from the committed script paths cited above, not observed at HEAD; the round-22 receipt is historical execution evidence, not a re-run.
- Absolute-prefix acceptance depends on `ROOT == $HOME` (the R16-01 default, `scope-gate.sh:89`); on a hermetic root an absolute own prefix would not match the `$HOME`-spelled census and would be `OWN-UNLISTED`.
- Open question: whether the `$HOME`-only scope was intentional. The note's stated reason (prose) is refuted; no commit message or doc states a spelling bound.
