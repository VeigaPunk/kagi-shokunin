# ClaimR22X03 — R22-03 semantic audit (round 23 parent-build, read-only)

Seat `ClaimR22X03` (connector), row `R22-03` = `corpus/claim-ledger.tsv:57` at HEAD.
Axes: calibration, freshness, operability. Advisory only; no judgment or admission authority.

## Observed revision

- Frozen tree: `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf` (detached; `master` and
  `origin/master` contain base `c2cab35`). The clone is not shallow (50 commits).
- HEAD digests: `corpus/stamps.tsv` `febcdf46…` (70 rows); `corpus/revision-audit.py` `62e022de…`
  (608 lines); `corpus/claim-ledger.sh` `cf56f9ea…`; `corpus/claim-ledger.tsv` `e6806968…`;
  `SCORECARD.md` `96cf354a…`. The base blob `c2cab35:corpus/stamps.tsv` is `0ce7fa4f…` (63 rows),
  byte-identical to `.ufo/waves/round-22/frozen/before/corpus/stamps.tsv`.
- The live tree moved during this audit. These are L1's in-flight edits, not mine. From 00:46 the
  following appeared:
  - `corpus/closure-dispositions.{py,json}`
  - `corpus/fixtures/cells-hermetic/`
  - `corpus/source-fetches.tsv`
  - `corpus/lessons/round-23.md`
  - ledger rows R23-01 and R23-02
  - `plans/round-23.md`, which is not in HEAD

  At 2026-10-21 00:57:27 -0300 nine pins were stale in the live tree: claim-ledger.sh, claim-ledger.tsv,
  SOURCES.md, sources-census.sh, surface-census.sh, knowledge/op-ref-consumption.md, LOG, SCORECARD and
  SKILL. On the live tree R22-03 would therefore read DRIFT until restamped. That is the intended
  tripwire, not a defect. Everything below describes HEAD unless it is labelled **live**.

## Mechanism traced (`corpus/revision-audit.py` @ `62e022de`)

- **History checks:**
  - full-OID regex (:20);
  - the object must be a commit;
  - the resolved ID must be canonical, so a short or prefix ID is refused (:256-279, :269);
  - the base tree must hold the paths as regular blobs (:240-253);
  - every base row must be tracked in that tree (:360-364).
- **Root selection:** `Path(__file__).resolve().parent.parent`, unless `--root` is given (:330).
  `git rev-parse --show-prefix` must be empty, so the root must be the top of a worktree (:336-338).
- **Membership:**
  - `DROPPED` = base − current (:368-369). This is a set comparison.
  - `ADDED` = current − base (:370-371).
- **Bytes:** each current row is reopened without following symlinks and on the same device. It must
  have `nlink==1` (:143-206, :200), and the final component is opened `O_NONBLOCK` (:179). The
  SHA-256, LF count and byte count are then compared (:373-387).
- **Exit code:** 1 on STALE, MISSING or DROPPED; 2 on any other finding except ADDED; otherwise 0.
  An ADDED finding alone gives CLEAN with exit 0 (:391-394). The summary line carries only counts
  (:397-411).
- **Ledger side:** the runner requires the exit code to match and applies the ERE to the last
  non-empty line (`claim-ledger.sh:427-444`). It **never echoes** claim output (`:85`).

## Determinations

| question | result | basis |
|---|---|---|
| expected last line and exit 0 at HEAD | **supported (static; not executed)** | All 70 HEAD rows are parse-valid with no duplicates. SHA-256, LF and byte counts match both the HEAD blobs and the worktree as it stood at audit start. All 70 files have nlink=1 and the same st_dev (57); no parent directory is a symlink. The 63 base paths are a subset of the current paths, and all are 100644/100755 blobs in the `c2cab35` tree. current − base is exactly the seven additions. The non-author closure independently re-measured the same at `254d632` (`corpus/lessons/round-22-verifier-spotcheck.md:46-66`). From `254d632` to `d218603` the only change is the unpinned spot-check file. |
| timeout 120 | supported | The receipt shows 0.037 s (`final-verification.json` R22-03). Git runs with stdin from /dev/null, `GIT_NO_LAZY_FETCH=1` and `GIT_OPTIONAL_LOCKS=0` (:41-44). A FIFO is refused rather than blocking. |
| "all original63 retained" | **supported** | This is a set difference, not a count. Exit is 1 on any base drop. |
| "seven reviewed pin additions" | **partly refuted: only the count is checked** | The ADDED paths are printed, but the ledger checks only the last line and never echoes output. See the Finding. |
| admin-metadata and hardlink refusal; canonical full OID | supported as a tool property | :75, :200 and :269. These are exercised only by the R22-04 fixtures. A live CLEAN shows only that invalid=0. |
| "does not adjudicate repin legitimacy" | supported, and binding | STALE compares each current row with the current bytes. It never compares current digests with base digests (:373-387). |
| `[substrate]` deferral | correctly absent | The row does not depend on the-janitor, and its note is untagged (verified). Keep it untagged; R18-02's `^11$` also counts the tags. |
| SKIP-SELF | not applicable | The command does not contain `claim-ledger.sh` (`claim-ledger.sh:816`). Under a real `cells` run, `SCORECARD.md:736` would re-run R22-03, because that heading matches SEC_RE (:690). R13-03 is `[substrate]`-tagged and is skipped in the authorized regime, so that re-run is never credited. |
| hermetic synthetic mode | **cannot carry this row** | The row needs the real object database (`c2cab35`) and a top-level worktree. Inside a committed fixture subdirectory there are two outcomes. A copied tool gives ROOT-NOT-REPOSITORY, exit 2, which fails closed. A symlinked tool is resolved by `.resolve()` into the real corpus, so it audits the live repo: a false clean, plus live Git reads inside a "hermetic" run. [INFERENCE: static reading] |

## Historical vs current evidence

- **Historical (round 22):**
  - `before-runnable.json`: the H1 auditor `ac19e186…` on the base clone reports `DRIFT (stale=6 …)`, exit 1.
    Between H1 and the measured landing, the auditor (`git diff 8ada17a 4be5da3`) only added the
    `.git`/`.jj` refusal, the nlink refusal and the canonical-OID check. None of these fire on the
    base clone, so the before and after runs remain comparable. [INFERENCE]
  - `pin-only-ablation.json`: changing only the stamps gives CLEAN with added=0.
  - The H1 epoch had `added=6` (`integration-pin-check.json`; `safe-row-plan.json:209-214`). The
    6→7 change is recorded in `pin-migrations-falsifier-repairs.json:129-131`.
  - `final-verification.json:483-500`: exit 0, CLEAN, added=7, seven ADDED lines.
- **That receipt is stale and mislabelled.**
  - Its `.h1` field (:2) is `8ada17a`. At `8ada17a` the same command printed added=6, so `.h1` cannot
    be the revision R22-03 measured.
  - The inputs file binds `corpus/stamps.tsv` `d082e9f1…`, i.e. the `4be5da3` stamps
    (`final-verification-inputs.json:24`). That differs from HEAD's `febcdf46…`, because `254d632`
    repinned round-22.md, README, SOURCES, LOG and SCORECARD.
  - Routed defect D6 (`round-22-verifier-spotcheck.md:177-179`) applies to this row concretely.
- **Current (`d218603`):** no persisted R22-03 receipt exists for the `febcdf46` snapshot. Support for
  the expected result comes only from the closure's independent re-measurement and the static
  recomputation in this audit.

## Finding: an equal-count swap among post-base additions is a false clean consumers can see

**Causality.** R22-03 protects base members by identity (DROPPED), but post-base additions only by
count. Suppose one reviewed addition's row is removed and a correct row for any other regular file is
added. The summary line stays byte-identical, so the exit code and last line are unchanged and the
ledger reports OK silently. R12-03 (`^70$`) also passes.

**Other guards for each addition in the authorized safe-row regime**, per the round-22 safe list:

- `knowledge/feature-bound-credential-review.md` — guarded: R14-01 `docs` reports UNPINNED if it is dropped.
- `lessons/round-22.md` and `lessons/round-21-verifier-spotcheck.md` — guarded only by the stamp-only
  cells `SCORECARD.md:707` and `:708`, which turn UNCITED under `cells`. But R13-03 is deferred or
  skipped, so this guard never runs. ClaimR12X03 confirmed this independently.
- `feature-claims.py`, `feature-claims.json`, `lessons/round-22-source-errata.md` and `revision-audit.py`
  — no guard at all.

So 6 of the 7 additions, including the auditor's own pin, depend only on R22-03's count.

**Prior evidence.** The round-22 build acceptance condition in `.ufo/waves/round-22/build/ReviewScore.md:27`
reads: "Do not report CLEAN on unavailable history, malformed input, or a count-preserving path swap."
Line :35 asked for swap fixtures. The 17 R22-04 cases (:423-582) include no swap case.

The writer has had a per-path guard since round 12, after "an equal-count path swap … slipped past the
earlier row-count rule" (`claim-ledger.sh:255-258`). `--prune`, a hand edit or a merge resolution
bypasses that guard. The reader also must not rely on writer discipline: `claim-ledger.sh:330` states
the read/write-symmetry lesson.

**Why this matters in round 23.** Integration adds pins and must migrate `added=7` to 7+k. The new
expectation will be read off the count, so that migration is exactly where a loss of identity can hide.

### Minimal synthetic falsifier (for L1; not executed here)

Use the existing selftest fixture, whose base commit pins `corpus/keep.txt` and `corpus/drop.txt`:

1. Write `corpus/add-a.txt` (`a\n`) and `corpus/add-b.txt` (`b\n`).
2. Reviewed state: original stamps + `stamp_line(add-a)` → exit 0, `ADDED corpus/add-a.txt`.
3. Mutant: original stamps + `stamp_line(add-b)` → exit 0, `ADDED corpus/add-b.txt`.
4. Assert that the reviewed summary differs from the mutant summary.

Today both summaries are `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=1 invalid=0)`, so
step 4 fails. That is the intended red-before. In production terms: replacing the
`corpus/revision-audit.py` row with a correct row for any new file leaves R22-03's last line
unchanged. [INFERENCE]

### Proposed move (one, bounded)

- **Fix:** append ` added_set=<sha256 hex of the sorted ADDED paths, each followed by "\n">` to the
  `REVISION_AUDIT:` line, using the hash of empty input when there are no additions.
- **New selftest case** `added-swap-identity`. It asserts exit 0 for both states, that the two
  summaries differ, and the exact hex for add-a.
- **Migrate R22-03's ERE** to pin that hex. Put the explicit ADDED list in the QM14 record, so the hex
  can be recomputed with `printf '%s\n' <paths> | sha256sum`.
- **R22-04:** its last line should bind case identity (for example a manifest digest), not just go
  from 17 to 18. That is ClaimR22X04's point; cite their report.

**Axes:**

- calibration ↑: a PASS would imply which paths were added, not only how many;
- freshness neutral: per-pin churn is the same as the count causes today;
- operability neutral: the only executable consumer of the line is R22-03 (grep finds only
  `claim-ledger.tsv` and `revision-audit.py`).

**Risks:** the hex is opaque, so the migration record must carry the path list. Old receipts and docs
that quote the current format must stay historical and must not be rewritten.

**Weaker alternative needing no code:** add a new row using `--history d218603…`. It protects
round 22's seven additions by membership, but each round's newest additions would still be protected
only by count, and it adds one more migrating row every round.

**Verification after integration (single run):**

1. The swap case is red on the current code and green after the fix.
2. R22-03 passes on the integrated tree, with the ADDED list recorded.
3. In a scratch clone, swapping the `corpus/revision-audit.py` row turns R22-03 into
   `verdict-not-final`.

## What C3 and C1 integration must keep for R22-03

**C3**

- Keep R22-03 as a direct safe row on the real tree. Do not mirror it into
  `corpus/fixtures/cells-hermetic/`.
  - The **live** in-flight fixture already fits this: claims are R90-01/R90-02, with no revision-audit
    row and no symlinks.
- R23-01's `CELL_AUDIT: CLEAN` must not be credited as re-running R22-03 or `SCORECARD.md:736`.
- Keep R22-03 untagged.
  - On a shallow or partial clone, HISTORY-UNAVAILABLE (exit 2) is a correct fail-closed SETUP result.
  - Disclose that result; do not hide it with a deferral.

**C1**

- No `fixed` disposition may cite R22-03 or its receipt for D4 (per-tuple drift journal) or D6
  (measured commit in the verdict file). R22-03 cannot see whether a repin was legitimate, and its
  round-22 receipt is itself an instance of D6.
  - The **live**, uncommitted `corpus/closure-dispositions.json` points D4 and D6 at
    `corpus/lessons/round-23.md#Routed defect dispositions`, which is consistent.
- The closure's C2 verdict "verifies" came from its own re-measurement, made without the lane auditor.
  An R22-03 PASS must not be presented as outside agreement.
- To satisfy D6 for this row, the round-23 verdict file should record the measured commit and the
  `corpus/stamps.tsv` digest next to R22-03's result.
- Any new pin migrates R22-03 in the same change. That includes the spot-check file if it is pinned
  for source-drift binding.

## Limits and boundary disclosure

- I did not execute R22-03, R22-04, `claim-ledger.sh` or any sibling gate or fixture. Behavioral
  statements come from static reading or from recomputed hashes and membership; inferences are marked.
- R22-03 audits the worktree, not HEAD, and the `gitignore-valid` selftest case (:541-545) pins an
  untracked file. At HEAD, all 70 pins are tracked and match their blobs, so there is no live instance;
  I did not pursue this class further.
- Git usage:
  - I used read-only object and ref reads: rev-parse, log, show, ls-tree, cat-file, commit-to-commit
    diff, merge-base and branch --contains.
  - One early `git status --porcelain` ran without `GIT_OPTIONAL_LOCKS=0` and may have refreshed the
    index stat cache; it changed no content.
  - One `/tmp` ls-tree listing was created and deleted within the same command.
- This report is my only write.
- In-flight round-23 files are cited as **live** observations from 00:46–00:57, not as frozen evidence.
- No public sources were needed. Peer coordination: ClaimR22X04 (R22-04 case identity) and ClaimR12X03
  (stamp-only cells) will cite this report rather than duplicate it. KagiR23 was notified of the
  contradiction.
- Tools installed: none.

Report: .ufo/waves/round-23/parent-build/ClaimR22X03.md
