# ClaimR22X04 — R22-04 semantic audit (read-only)

Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 -0300).
At audit time the worktree also carried L1's uncommitted round-23 integration (`M LOG.md
SCORECARD.md SKILL.md corpus/SOURCES.md corpus/claim-ledger.sh corpus/claim-ledger.tsv
corpus/knowledge/op-ref-consumption.md corpus/sources-census.sh`; untracked
`corpus/closure-dispositions.{py,json}`, `corpus/fixtures/`, `corpus/lessons/round-23.md`,
`corpus/source-fetches.tsv`, `plans/round-23.md`). The audited obligation is unchanged by that
work: HEAD `corpus/claim-ledger.tsv:58` is byte-identical to worktree line 58, and
`corpus/revision-audit.py` has the same SHA-256 `62e022dec6e5cbafc7eb77b6e1a82d6dca5539258b497b814f19abbaad91131f`
in HEAD, worktree and `corpus/stamps.tsv:58`. No gate or row command was executed; this report is
the only write; no tools installed.

## Row under audit

`corpus/claim-ledger.tsv:58`

```
id      R22-04
command python3 corpus/revision-audit.py --selftest
expect  ^REVISION_AUDIT_SELFTEST: PASS \(cases=17 failed=0\)$
exit    0
timeout 120
note    H1 eleven cases plus Git/JJ metadata and hardlink refusals, gitignore valid control,
        and SHA256 full64/truncated40 controls: expected17. Isolated Git/filesystem fixtures
        only, exact exit/finding assertions; all epochs retained.
```

(Tabs elided for readability; the file is `id<TAB>command<TAB>expect<TAB>exit<TAB>timeout<TAB>note`.)

## Verdict

| question | verdict |
|---|---|
| Expected last line / exit causally reachable? | **Supported.** The summary line is the single `print` at `corpus/revision-audit.py:580-581`; `selftest()` returns 0 iff `failed == 0` (`:582`) and `main` returns that value (`:597`). |
| Is `cases=17` a causal count, not an authored number? | **Supported at this revision.** Exactly 17 `check(...)` calls execute (`:476-578`); `cases` increments unconditionally per call (`:429`). The note's decomposition is exact: 11 H1 cases + 3 Git/JJ/hardlink refusals + 1 gitignore control + 2 SHA-256 controls. |
| Is the command hermetic and policy-executable? | **Yes.** `--selftest` rejects `--root` (`:593-596`) and never reads the real repository; fixtures live in `tempfile.TemporaryDirectory` (`:443`); git env is scrubbed (`:39-47`). The ledger allowlist admits only `corpus/{feature-claims,revision-audit}.py` (`corpus/claim-ledger.sh:161`); no metacharacter or denied verb occurs in the command. |
| Timeout 120 s justified? | **Yes.** Local-only fixture set, no network, no sleeps, FIFO opened `O_NONBLOCK` (`revision-audit.py:179`), reads bounded by `MAX_STAMPS_BYTES` (`:23,:222-237`). Round-22 receipt measured 0.081 s (`final-verification.json:513`). |
| `[substrate]` deferral / SKIP-SELF preserve it? | **Yes, by correctly not applying.** No `[substrate]` tag; the command touches no janitor/op/vault/`$HOME` surface. SKIP-SELF matches only commands naming `claim-ledger.sh` (`claim-ledger.sh:816-818`), which this one does not. |
| Hermetic synthetic mode preserves it? | **Only if explicitly accounted.** The in-flight fixture (`corpus/fixtures/cells-hermetic/`, uncommitted) contains fixture rows `R90-01`/`R90-02` and no `revision-audit.py`; production `SCORECARD.md` cites no `R22-04` at HEAD or in the worktree. The command itself would run unchanged in a fixture root if the real script were copied there. |
| One consumer-visible risk? | **Yes.** The ERE binds the count, not case identity (false clean on a count-preserving swap); a second committed artifact still pins the historical count 11 (false fail if reused). See §Risk. |

Implementation map for the 17 cases (all in `corpus/revision-audit.py`): clean-control → exit rule
`:391-394`; duplicate-history-id → `parse_stamps(history=True)` `:85-137`; dropped-member →
`:368-369`; modified-worktree-stale → `fingerprint_fd`/compare `:208-219`, `:373-387`;
missing-file → `:155-156`; malformed-current-row → `:98-129`; duplicate-current-id → `:130-132`;
path-traversal → `parse_path` `:67-82`; parent-symlink → `:157-167`; fifo-not-file → `:196-199`;
git-admin-path / jj-admin-path → `parse_path` `.git`/`.jj` `:75`; hardlink-path →
`st_nlink != 1` `:200-203`; gitignore-valid → `ADDED` stays exit 0 `:391-394`; option-history →
FULL_OID guard `:327-328`; sha256-full-id / sha256-truncated-id → `FULL_OID` and canonical-OID
equality `:257-270`.

## Evidence: historical vs current

- **BASE.** The row does not exist at `c2cab35bc92e57e39e5489bac3386db078345b3f` (0 matching rows).
- **H1 epoch, `8ada17a`.** `git show 8ada17a:corpus/revision-audit.py` has 11 `check` calls
  (`clean-control`, `duplicate-history-id`, `dropped-member`, `modified-worktree-stale`,
  `missing-file`, `malformed-current-row`, `duplicate-current-id`, `path-traversal`,
  `parent-symlink`, `fifo-not-file`, `option-history`) and `git show 8ada17a:corpus/claim-ledger.tsv`
  line 58 pins `cases=11`. The row text is preserved in
  `.ufo/waves/round-22/pin-migrations-integration.json:459-461`.
- **Current epoch, `4be5da3`.** The six added cases (`git-admin-path`, `jj-admin-path`,
  `hardlink-path`, `gitignore-valid`, `sha256-full-id`, `sha256-truncated-id`) bring the count to
  17; the old→new row is recorded at
  `.ufo/waves/round-22/pin-migrations-falsifier-repairs.json:134-136`. The committed executed
  receipt `.ufo/waves/round-22/final-verification.json:500-514` records `exit=0`,
  `last=REVISION_AUDIT_SELFTEST: PASS (cases=17 failed=0)`, all 17 `SELFTEST_CASE: PASS` lines in
  `stdout`, and `passed=true`. `final-verification-inputs.json:12-15` binds the measured bytes:
  SHA-256 `62e022…`, 24074 bytes — equal to HEAD, worktree and `corpus/stamps.tsv:58`
  (608 lines / 24074 bytes).
- **Current row unchanged.** HEAD's `claim-ledger.tsv` hashes to the receipt's input digest
  `e6806968…`; `git diff 4be5da3 HEAD -- corpus/claim-ledger.tsv` is empty; the in-flight L1 edits
  leave R22-04's line identical. The receipt's 17-case output therefore describes the audited bytes,
  not a superseded snapshot.
- **Contradicting historical artifact.** `.ufo/waves/round-22/safe-row-plan.json:216-220`
  (tracked since `4be5da3`) still pins `^…cases=11 failed=0\)$`. It is the pre-correction plan, not
  the ledger; a C3 fixture must not ingest it as the expected verdict (see §Risk branch B).
- **Receipt provenance defect D6.** `final-verification.json:2` sets `"h1": "8ada17a…"`, whose
  `revision-audit.py` has 11 cases, while the entry was measured at `4be5da3` (17 cases). Only the
  inputs-digest file binds the measured bytes. Following `.h1` alone for R22-04 yields a false fail;
  this is the already-routed D6 (`corpus/lessons/round-22-verifier-spotcheck.md:177-178`).
- **`all epochs retained`.** Supported: both row texts are in the falsifier-repairs record, and both
  source epochs are in immutable history (`8ada17a`, `4be5da3`).

## `[substrate]`, SKIP-SELF, hermetic synthetic mode

- **No `[substrate]` tag — correct and required.** The command reads only `tempfile` fixtures and
  local git objects; it never touches the janitor/op/vault surface. On a substrate-absent host it
  must run, not defer; the tag is a literal bracket in the note field
  (`corpus/knowledge/substrate-deferral.md:27-29,65`), and this note has none. Round 22 confirms the
  row ran: `final-verification.json` `skipped_rows` has zero `R22-04` entries, and the outside
  spot-check states none of R22-01…04 was skipped
  (`corpus/lessons/round-22-verifier-spotcheck.md:74-77`).
- **SKIP-SELF — not matched, correctly.** `cells_evidence` skips a row only when its command text
  contains `claim-ledger.sh` (`corpus/claim-ledger.sh:816-818`). R22-04 names
  `corpus/revision-audit.py`, so if a cell cited it, `cells` would execute it through the ordinary
  exit + last-line machinery (`:426-443`). Its green cannot be laundered as `self_skipped`.
- **Hermetic synthetic mode — command is hermetic; the current fixture does not include it.** The
  `--selftest` branch returns before `audit()` (`revision-audit.py:593-597`), so its result does not
  depend on cwd or repository root; only the script file's presence is required. The in-flight
  `corpus/fixtures/cells-hermetic/` (uncommitted, L1) holds `claims.tsv` rows `R90-01`/`R90-02`
  and `corpus/{fx-ok.sh,adjacency.tsv}`; there is no `revision-audit.py` in the fixture root.
  `SCORECARD.md` cites no `R22-04` at HEAD or in the worktree, so the real `cells` run never selects
  it. The in-flight C3 narrative describes the fixture (`corpus/lessons/round-23.md:121-130`) and
  explicitly states the real-tree claim is not made (`corpus/lessons/round-23.md:143`).

## What C3 (`cells`) must retain

1. **Keep the row byte-identical.** Do not change the command, ERE, exit or timeout to make a
   fixture green. At audit time the L1 integration already satisfies this: R22-04 is unchanged.
2. **State its disposition explicitly.** Two acceptable forms: (a) name R22-04 as covered by the
   43-row `verify` population and outside the hermetic cells fixture (the fixture's `rows_run=2` in
   the in-flight, uncommitted `SCORECARD.md:841` covers only `R90-01`/`R90-02`); or (b) include it in the fixture by copying
   the exact script (`sha256 62e022…`, 24074 bytes) to `<fixture>/corpus/revision-audit.py`, adding
   the exact row to the fixture claims file, and adding a fixture cell pointer to `R22-04`. The
   selftest is cwd-independent, so (b) passes identically and is the cheaper way to prove the
   obligation host-free.
3. **Never count `CELL_AUDIT: CLEAN (rows_run=2 …)` as coverage of R22-04.** `cells` re-runs only
   rows cited by checked cells; a green fixture proves the parser path, not the 43 real rows.
4. **Never route R22-04 through `DEFER` or `SKIP-SELF`.** It is neither substrate-bound nor
   self-invoking; either classification would convert an executed obligation into an unmeasured
   absence.
5. **Do not reuse the stale plan ERE** (`safe-row-plan.json:216-220`, `cases=11`).

## What C1 (closure dispositions) must retain

- **No invented disposition.** R22-04 is not one of the nine routed defects (`D1`–`D9`), the five
  discernment decisions (`SPOT-01`–`05`) or the adjudication ruling; it appears only as an evidence
  tally, "revision 17 (R22-04)", in `corpus/lessons/round-22-verifier-spotcheck.md:71`. The C1
  checker must not create a disposition for it and must not cite its green as D6 or D9 closure.
- **Pointer shape, not count shape.** If any disposition or evidence line cites R22-04, the pointer
  must resolve to the row and its implementation, not to the numeral 17: `corpus/claim-ledger.tsv:58`
  plus `corpus/revision-audit.py:423-582` plus `corpus/stamps.tsv:58`
  (`62e022…`/608/24074). This is exactly the campaign's "actual source/row pointers rather than
  claim-count assurance" requirement.
- **D6.** The in-flight manifest marks D6 `fixed` with the note that this round's verdict file
  carries `measured_commit` (`corpus/closure-dispositions.json`, uncommitted). For R22-04 that
  correction is load-bearing: the round-22 receipt's `.h1` is the 11-case source while its measured
  bytes and expectation are the 17-case source; a consumer following `.h1` would read a false fail.
  Retention requires the corrected verdict file to name `4be5da3` for this entry.
- **D9 pointer granularity (advisory).** The in-flight D9 disposition points at the whole
  `corpus/claim-ledger.tsv`. A file-level pointer resolves trivially and cannot show that a specific
  row exists; row-level pointers (e.g., `claim-ledger.tsv:58`) are the standard this row's audit
  should hold the checker to.
- **Do not duplicate the sibling finding.** The equal-count swap among R22-03's seven post-base
  additions is `ClaimR22X03`'s finding and its proposed 18th case; this report does not re-derive it.

## Consumer-visible risk (one risk, two branches) with minimal falsifier

**Risk.** The ledger certifies the *count* `cases=17`, not the identity of the cases, and a second
committed artifact still carries a different count for the same row. Both branches are statically
derived here; neither was executed.

**Branch A — false clean (count-preserving swap).** In a scratch copy of `revision-audit.py`, delete
the hardlink stamp write at `:538` and replace the check at `:539` with a second use of the state
already left by `jj-admin-path` (`:531-533`):

```python
# line 538 removed; line 539 replaced by:
check("jj-admin-path-2", 2, "PATH-ESCAPE 1", audit(root, history))
```

`cases` remains 17 and every case passes, so the last line is still
`REVISION_AUDIT_SELFTEST: PASS (cases=17 failed=0)` with exit 0 — the ledger ERE matches — while
`st_nlink != 1` (`:200-203`) loses its only test. `verify_stamps` catches an *unrestamped* worktree
edit (`claim-ledger.sh:970-971`), so the live failure mode is a reviewed, restamped authored change:
exactly the drift the ledger exists to catch, and precisely what a count cannot see. Minimal
falsifier: the two-line scratch-copy edit above, then `python3 <copy> --selftest`; expected
[INFERENCE] `PASS (cases=17 failed=0)`, exit 0.

**Branch B — false fail (stale historical count).** If the C3 fixture builds its claims file from
`safe-row-plan.json:216-220` (`cases=11`) while executing the real script, the command exits 0 but
its last line is `cases=17`; `cells_evidence` records `row_failures=1`
(`claim-ledger.sh:1006-1009`) and the fixture prints `CELL_AUDIT: BROKEN`, although the shipped row is
green. Minimal falsifier: fixture claims row with the plan's ERE and the real `revision-audit.py`;
expected [INFERENCE] exit 0 / last-line mismatch. The fix is to use the ledger row and receipt
(digest-bound), never the pre-correction plan.

## Limits

- No row, gate or fixture was executed; falsifier outputs are [INFERENCE] from the cited code paths
  and committed receipts. The 0.081 s receipt value is harness-reported, not re-measured here.
- The worktree was mid-integration (L1 uncommitted edits); in-flight `corpus/fixtures/`,
  `corpus/closure-dispositions.*`, `corpus/lessons/round-23.md` and `plans/round-23.md` are not
  committed evidence and may change. The audited row and script were verified identical to HEAD.
- Host dependency observed read-only: `git version 2.56.0`; the selftest requires a Git with
  `--object-format=sha256` (≥ 2.29). An older or missing git fails loudly (`FAIL (cases=… failed=1)`,
  exit 1), not silently — a portability limit, not a defect observed here.
- Scope is R22-04 only; R22-03, the other 42 command rows and the 23 SOURCES rows are out of scope.
