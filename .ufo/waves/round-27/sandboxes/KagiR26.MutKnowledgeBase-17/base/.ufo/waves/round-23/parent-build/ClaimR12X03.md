# ClaimR12X03 — R12-03 `grep -c '[^[:space:]]' corpus/stamps.tsv`

**Observed revision.** HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (round-22 non-author spot-check).
Every line citation below was re-checked against HEAD blobs (`git show HEAD:<path>`).
The row is at `corpus/claim-ledger.tsv:28`, HEAD blob sha256 `e6806968…`:

```
R12-03  grep -c '[^[:space:]]' corpus/stamps.tsv  ^70$  0  30  current pin membership: original 63 retained,
        six reviewed integration additions and one late source-errata lesson pin. The outside-verifier artifact
        was pre-existing but unstamped, not newly authored; provenance correction retained. Count is pointer
        membership, not source currentness.
```

**Method and limits.** This was a static reading only. I did not execute the row's command or any gate, selftest,
handler, `op` or vault command. Facts about the stamp file come from independent structural reads:
`wc`, `awk` field/blank counts, `cut | sort -u`, `sha256sum`, and `comm` over `git show <rev>:corpus/stamps.tsv`.
Historical counts use `awk 'NF'` over `git show` output, not the ledger command.

Git use was read-only: `log`, `show`, `diff <rev> <rev>`, `ls-files`, `hash-object` without `-w`, and `check-ignore`.
After the first call, all git commands ran with `--no-optional-locks`. **Disclosure:** that first call was a plain
`git status --porcelain`, which may have refreshed the index stat cache. It made no content change. No JJ command
was run. No tools were installed or needed.

**The worktree changed during this audit.** L1 integration started around 00:5x -03. It modified the ledger,
`claim-ledger.sh` and docs, and added untracked round-23 files. `corpus/stamps.tsv` stayed byte-identical to HEAD
(blob `32137e5f…`, sha256 `febcdf46…`, 7329 B). In-flight observations are tagged **[worktree, time]**. They are
not evidence about the frozen population.

---

## 1. Verdict, last line, exit and timeout — supported

**Execution path.** `verify_claims` (`corpus/claim-ledger.sh:400-445`) handles the row as follows:
- It reads the six fields and finds no `[substrate]` tag (`:416`).
- `policy_check` passes the command: `grep` is allowlisted, there are no metacharacters, and the quote-stripped
  text contains no denied word.
- It runs `cd "$ROOT" && timeout -k 5 30 bash -o pipefail -c "$cmd" 2>&1` (`:426`).
- A return code of 124 or 137 is a timeout. Any other non-zero code is an exit mismatch.
- The last non-empty line (`:436`) must match `^70$` (`:441`).

**Command semantics.** `grep -c` prints exactly one line, the count of matching lines:
- It exits 0 only when the count is at least 1.
- A file with no non-blank line prints `0` and exits 1.
- A missing file or a directory exits 2 with stderr.

All of those fail on the exit column first. The anchored `^70$` also rejects `170`, `700` and empty output.
The row therefore fails closed when the file is missing or empty.

**Independent structural read at HEAD.** `corpus/stamps.tsv` has:
- 70 LF-terminated lines, all with 4 fields
- 70 distinct first-column paths
- 0 blank or whitespace-only lines, 0 lines starting with `#`, 0 CR bytes, 0 non-ASCII bytes

[INFERENCE, not executed] The command would print `70` and exit 0.

**Timeout 30 is justified.** The last executed receipt took 0.002 s
(`.ufo/waves/round-22/final-verification.json` `safe_rows[7]`). The command reads one 7 KB file.

## 2. Is 70 caused by the claimed composition? Supported

The count is backed by a receipt chain, an independent membership diff and the outside re-measurement. It does
not rest on line-counting alone.

| epoch | ledger expect | stamps count | cause, with receipt |
|---|---|---|---|
| `e1544c1` (round 21) | `^63$` | 63 | `round21-migrations.json`: 56→63, nine same-path replacements, `removed_members: []` |
| `8ada17a` | `^69$` | 69 | `pin-migrations-integration.json`: `old_members 63 → new_members 69`, `removed_members: []`; six records with `old_stamp: null` (listed below) |
| `4be5da3` | `^70$` | 70 | `pin-migrations-falsifier-repairs.json`: 69→70, `added_members: [corpus/lessons/round-22-source-errata.md]`, `removed_members: []` |
| `254d632` | unchanged | 70 | `pin-migrations-outcome-metadata.json`: `member_count 70`; in-place re-pins of LOG.md, SCORECARD.md, corpus/README.md, corpus/SOURCES.md and lessons/round-22.md; nothing added or removed |
| `d218603` (HEAD) | unchanged | 70 | Touches only `corpus/lessons/round-22-verifier-spotcheck.md`, which is new and unstamped |

The six `old_stamp: null` records at `8ada17a` are `feature-claims.json`, `feature-claims.py`,
`knowledge/feature-bound-credential-review.md`, `lessons/round-21-verifier-spotcheck.md`, `lessons/round-22.md`
and `revision-audit.py`.

`pin-migration-errata.json` corrects `round-21-verifier-spotcheck.md` from a null base observation to "pre-existing,
previously unstamped". That matches the note's provenance sentence.

**Independent check.** `comm` between `git show c2cab35:corpus/stamps.tsv` and HEAD shows exactly those seven paths
added and zero removed. The outside verifier re-measured the same thing at `254d632`:
"base members 63, final 70, dropped [], added 7" with names (`corpus/lessons/round-22-verifier-spotcheck.md:46-60`).

**History.** At every committed epoch (`4b8c018` 33 · `2486643` 44 · `587fda0` 48 · `8a6ec16` 52 · `bc1af88` 54 ·
`fecee87` 56 · `c41af82`/`e1544c1` 63 · `8ada17a` 69 · `4be5da3` 70), the committed expectation equals the committed
non-blank stamp count. No red state was ever committed. The row's job as a pre-commit tripwire is observed once in
round 17: `LOG.md:713-716` records that the landing audit caught `R12-03` still expecting 52 after two new artifacts.

## 3. What the count does not carry

- **The note over-reads the command.** "Count is pointer membership" claims more than the command checks: it checks
  **cardinality**. The composition the note lists is true at HEAD (section 2), but identity is guarded elsewhere,
  in the executed regime on this host:
  - **Base 63:** R22-03 (`revision-audit.py:366-371`; exit 1 on `DROPPED` at `:391`).
  - **`knowledge/feature-bound-credential-review.md`:** R14-01 (`docs`, `unpinned=0`).
  - **`lessons/round-22.md` and `lessons/round-21-verifier-spotcheck.md`:** guarded only by production `cells`.
    `SCORECARD.md:707` and `:708` are stamp-only cells with no row id, so a dropped pin makes them `UNCITED`.
    However, R13-03 is `[substrate]`-tagged (`claim-ledger.tsv:38`) and was skipped in round-22
    `final-verification.json`, so on this host this guard is never executed.
  - **`feature-claims.py`, `feature-claims.json`, `revision-audit.py`, `lessons/round-22-source-errata.md`:** guarded
    by count only. That is R12-03, plus R22-03's `added=7`.
- **Equal-count swap.** The falsifier for an equal-count swap belongs to **ClaimR22X03**
  (`.ufo/waves/round-23/parent-build/ClaimR22X03.md`, still pending when I wrote this). I cite it rather than
  re-derive it. I sent ClaimR22X03 the `:707`/`:708` nuance, and it confirmed it.
- **"70 = distinct pins" depends on R22-03.** Three readers parse `stamps.tsv` with different rules:
  - R12-03 counts `#` lines and duplicate rows.
  - `load_stamps` skips `#` lines (`claim-ledger.sh:323`), dies on a blank line (`:326`) and has **no duplicate
    check** (`:316-338`).
  - `parse_stamps` rejects comments and malformed lines (`MALFORMED-LINE`) and rejects `DUPLICATE`
    (`revision-audit.py:96-140`).

  So R12-03's "70 = distinct pins" reading only holds while R22-03 is not in SETUP. At HEAD there are 0 comment
  lines and 0 duplicate lines, so the reading holds.
- **Not freshness.** The note already says so. `verify_stamps` and R22-03 check freshness. At HEAD, `stale=[]` is
  inferred: the outside verifier measured `254d632 stale=[] missing=[]`, and `d218603` touches no pinned path.

## 4. `[substrate]` deferral, SKIP-SELF and hermetic mode — the obligation is preserved

- **`[substrate]`.** The row is not tagged, so it is never deferred (`:416`). It is host-free because it only reads
  a repo file, and it is correctly in round-22's safe rows. The tag *count* is pinned by R18-02 (`^11$`). *Which*
  rows carry the tag is not pinned (ClaimR18X02's domain). Only that count and review keep R12-03 from being
  silently deferred.
- **SKIP-SELF.** This applies only to commands containing `claim-ledger.sh` (`:816`), so R12-03 is never skipped.
  Production `cells` would re-run it for `SCORECARD.md:86` (Round 12 pre-move calibration; R12-03 and R13-02 are
  its only pointers) and `:108` (Round 13 pre-move calibration; also stamp-pointed via `lessons/round-13.md`).
  For these historical cells, a green R12-03 is *current* evidence (70 now). It does not re-verify the round-12/13
  numbers. This is the documented pointer-not-relevance ceiling (`corpus/knowledge/claim-ledger.md:380-385`), not a
  new defect.
- **Hermetic mode.** Not present at HEAD. Three code facts bind the design:
  - `STAMPS` and `CLAIMS` default to `SCRIPT_DIR` (`:104-105`).
  - `--root` changes only `ROOT` (`:203`).
  - Claim commands run under `cd "$ROOT"` (`:426`).

  Running `cells --root <fixture>` without `--claims`/`--stamps` would point production R12-03 at the fixture's
  bytes. The result would be either a false FAIL (`exit-mismatch exit=2` when the fixture has no `corpus/stamps.tsv`)
  or a coincidental pass. The selftest's cells cases pass every flag explicitly (`:1361-1394`).

## 5. Persisted receipts — historical versus current

- **Current (HEAD).** The `stamps.tsv` bytes are `febcdf46…`. **No executed receipt exists for these bytes.**
  Count invariance since the last receipt is derived from the `4be5da3→254d632` diff (five same-path in-place
  replacements) and from `254d632→d218603` (no change).
- **Historical, executed.** `final-verification.json` (added in `4be5da3`) has `safe_rows[7]`:
  argv `grep -c [^[:space:]] corpus/stamps.tsv`, `^70$`, exit 0, stdout `70\n`, passed. Its inputs file binds
  `stamps.tsv` to `d082e9f1…` / 7329 B, which is `git show 4be5da3:corpus/stamps.tsv`.
- **Contradiction (D6, row-specific).** The same file says `.h1 = 8ada17a`. At `8ada17a`, `stamps.tsv` is
  `88bbe15b…` with **69** rows, and R12-03 expected `^69$`. A `^70$` pass is impossible at the recorded `.h1`.
- **Historical, plan only.** `safe-row-plan.json` has R12-03 `^69$` at `8ada17a`, with status "plan, not an
  exercised pass". It is superseded and must not seed a round-23 run.
- **Superseded wave readings.** Round-22 build/falsify reports that cite `^63$`/`^69$` describe earlier epochs, for
  example `falsify/AttackEntry01.md:24`. Current docs agree on 70: `corpus/lessons/round-22.md:251` and
  `SCORECARD.md:801`.

## 6. Consumer-visible false-clean and a minimal synthetic falsifier

**Risk.** A committed verdict attributes a pass to a revision where that pass is impossible. A reader of
`final-verification.json` sees R12-03 `passed` at `8ada17a`, but re-running it there gives `69`, which fails `^70$`.

The in-flight C1 disposition for D6 is "fixed" with a lesson-anchor pointer. R23-02 states that it "records
existence, not fix quality". Under that check, a new verdict whose `measured_commit` is wrong would still pass.

**Synthetic fixture for L1** (scratch git repo, no production bytes; I did not run it):

```
commit A: corpus/stamps.tsv = 2 valid rows; claims: X  grep -c '[^[:space:]]' corpus/stamps.tsv  ^2$  0  30
commit B: corpus/stamps.tsv = 3 valid rows; claims: X  …  ^3$
verdict-ok.json : {"measured_commit": B, "rows":[{"id":"X","expected_last_ere":"^3$","exit":0,"last":"3"}]}
verdict-bad.json: {"measured_commit": A, …same row…}   # mirrors .h1=8ada17a with R12-03 ^70$/70
check: count(non-blank lines of git show <measured_commit>:corpus/stamps.tsv) == last
       AND the claims row's expect at <measured_commit> == expected_last_ere
expected: ok → pass; bad → FAIL with a named finding (2 ≠ 3; ^2$ ≠ ^3$)
```

The check needs only `git show` plus a count, so it runs no ledger command and reads no host state. R12-03 is the
best witness for this because its value changes on every pin-set change.

## 7. What C1 and C3 integration must retain for R12-03

- **C1.** Never accept R12-03 as a `fixed` pointer for an identity or freshness obligation, such as D4's per-tuple
  drift commits or QM14 membership. It is cardinality evidence only. [worktree 00:58] `corpus/closure-dispositions.json`
  contains no R12-03 pointer, which is good.
- **C1.** Make D6 falsifiable using the §6 check against the round-23 verdict's `measured_commit`.
- **C1.** If C1 pins its source via `stamps.tsv`, then:
  - `corpus/lessons/round-22-verifier-spotcheck.md` must be added. It is unstamped at HEAD; a grep of
    `stamps.tsv` finds no match.
  - R12-03 must migrate in the same commit (QM5).
  - The checker must fail closed if its source pin is absent, and must not infer presence from R12-03's count.
- **C3.** Keep R12-03 as a direct safe/verify row. Do not count the fixture run as its evidence.
- **C3.** Use fixture-local ids and explicit `--claims/--stamps/--scorecard/--docs`. [worktree 00:57] R23-01 does
  this with R90-01/R90-02 and has no R12-03 analogue, so the requirement is met in-flight but not yet landed.
- **C3.** Keep R13-03's skip explicit. Production cells remain the only executable identity guard for the two
  stamp-only cells at `SCORECARD.md:707-708`.

## 8. In-flight integration observations [worktree 2026-10-21T00:57–00:58 -03, not landed]

- **Nine new corpus artifacts are unstamped.** These are `closure-dispositions.py/.json`, `source-fetches.tsv`,
  `lessons/round-23.md` and five `fixtures/cells-hermetic/*` files. Meanwhile `stamps.tsv` equals HEAD and R12-03
  still expects `^70$`. QM5 (`corpus/QUALITY.md:43`) requires stamping them in the landing commit. Then:
  - R12-03 moves 70 → the measured N.
  - That change needs a QM14 per-path record (`QUALITY.md:73`), not a count-only one.
  - R22-03's `added=` moves in lockstep. Invariant: N = 63 + added − dropped.

  A green R12-03 after landing cannot show that these artifacts were stamped.
- **Untracked bytecode.** `corpus/__pycache__/closure-dispositions.cpython-314.pyc` is not ignored (`.gitignore` only
  lists `.ufo/interactive-sessions/`). Keep it out of both the commit and the stamp set.
- **Stale lesson text.** `lessons/round-23.md:151-153` describes an "empty-but-valid stamps file". `load_stamps`
  refuses an empty stamp set (`claim-ledger.sh:320-321`), and the fixture actually has 2 rows.

I sent items 1 and 3, plus the §5 contradiction, to agent://KagiR23.

## 9. Recommendations (advisory; L1 integrates)

1. **Reword R12-03's note** to "count is pin cardinality; identity: base by R22-03, additions by the migration
   receipts". This removes the identity claim the command cannot back.
2. **Migrate at landing with old and new values.** Use `^70$` → measured `^N$`, list the added paths by name,
   `removed=[]`, and give the motivating correction (QM14).
3. **Add the §6 measured-commit check** to the round-23 verdict and to C1's D6 selftest.
4. **For identity of the additions,** see ClaimR22X03's fix. Do not raise R12-03's assurance by adding more count
   rows.

**Checks for the parent after integration** (I ran none of these):
- R12-03 itself, through the QM12 safe-row path
- `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`
- A `comm` membership diff from HEAD to the landing commit
- `sha256sum` of `stamps.tsv` recorded in the verdict next to `measured_commit`

## Limits

No command was executed against the live ledger. Expected outputs are code-derived and marked [INFERENCE]. In-flight
files may change after the timestamps above. No public sources were needed for this row. No private config, vault or
credential surface was read.

Report: .ufo/waves/round-23/parent-build/ClaimR12X03.md
