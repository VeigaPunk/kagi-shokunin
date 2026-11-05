# Round 44 — C2/C3 counter review (seat K44ReviewC2C3)

Reviewed at predeclaration ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae in sandbox clone
`/fast/scratch/hyaku/kagi-r44/K44ReviewC2C3/work` (shared clone of lane, detached at ae9e9eb;
`git rev-parse --show-toplevel` verified before any write; no commits anywhere). BASE =
d54109d943abc900e71613a02e5a7a2e46453c3a. All runs re-executed by this seat; transcripts in
`.ufo/waves/round-44/build/K44ReviewC2C3/` (`c2-battery.txt`, `c3-battery.txt`,
`c3-rederive-sweep.txt`, `gate-restore-duty.txt`, crafted fixtures under `evidence/`).

## Findings by severity

### MEDIUM — ceiling text misdescribes the `via` mechanism (F1)

`plans/round-44-c3.sh` never reads the register's `via` cell (cell 6); it hardcodes
`(cd "$SCR/clone" && bash plans/round-42-controls.sh)`. The frozen predicate itself hardcodes the
runner, so the counter is predicate-compliant — but the plan's C3 declared ceiling asserts
*"the runner path is checked by execution: the legs run the named via file, so a nonexistent
runner fails the leg"*, which is false as implemented.

Evidence: register with rows 1–2 `via = plans/nonexistent-runner.sh` (all other cells correct)
reads **3** (`c3-battery.txt` line `via-bogus rc=0 out=[3]`; fixture `evidence/reg-via.md`).
A candidate register can carry any bogus/misleading `via` value and still reach N = 3; the row
leg that the ceiling claims would fail does not exist. The values, not the runner name, are the
load-bearing fact. Recommend correcting the ceiling sentence at amendment time (L1 scope), not
the counter (re-freeze).

### LOW — superseded-by existence accepts trees; pipes truncate the cell into one (F2)

Row 1–2 disposition leg: `git cat-file -e "$CAND:$SUP1"` — passes for any existing path,
including a **directory (tree)**. Combined with awk `-F'|'` cell extraction, a stray pipe inside
the disposition cell truncates it at the pipe, and the truncated directory prefix satisfies the
leg:

- `superseded-by: .ufo` → row counts (tree-disposition, out=3, `evidence/reg-tree.md`);
- `superseded-by: .ufo/waves/round-43|controls/...` → cell = `superseded-by: .ufo/waves/round-43`
  → tree exists → row counts (pipe-truncated, out=3, `evidence/reg-pipe.md`);
- sanity: `superseded-by: .ufo/waves/round-43/controls/NOSUCHFILE.txt` → row drops
  (nonexistent-sup, out=2) — the leg is not vacuous.

Payload legs (committed cell, re-derive-at pin, executed re-derivation) remain exact and
load-bearing in all three runs, so exposure is limited to a mislabeled superseding record in a
hand-edited register; review is the control. Named looseness, not measured in any committed
artifact.

### LOW — C2 receipt grammar counts newlines, not lines (F3)

The four-line grammar is implemented as `wc -l == 4` + four `sed -n` reads, i.e. "exactly four
newline-terminated bytes-runs". A **fifth unterminated line is ignored**:
`...exit: 0\nstray-fifth-line` (no trailing LF) parses as valid and reads **1** (`v-unt5`,
`evidence/v-unt5.txt`). All four semantic lines still bind everything, so the payload is
unaffected; the looseness is purely grammatical ("exactly four lines" is really "exactly four
LFs, trailing junk after the 4th LF tolerated if unterminated"). The mirror direction is strict:
four lines without a trailing LF read **0** (`v-nonl`, wc=3). Operational note for the executor:
the receipt-production command must emit a trailing newline on line 4.

### LOW — C3 row identity is substring-based; extra trailing cells ignored (F4)

The row pattern `^\|[[:space:]]*\.ufo/waves/round-42/controls/c[12]-(base|worktree)` plus the
`grep -qF` order checks never equality-check the receipt path: a row naming
`.../c1-base.txt.old` (no such receipt) passes order and counts on its values
(path-suffix, out=3). A row with a trailing extra cell `| extra-cell |` still counts
(shape-extra-cell, out=3) — cell 7 is unaffected. Values stay load-bearing; no measured impact.

### LOW/PREDICATE-FROZEN — row-3 token is substring (F5)

Row 3 disposition uses `grep -q 'not-written-by-any-committed-runner'` — the frozen predicate
says "contains the token", so this is predicate-compliant: `superseded-by: X
not-written-by-any-committed-runner` counts (token-prefix, out=3). Named for the lesson; not a
counter defect.

## Checks requested — results

1. **C2 parse strictness.** Strict in every tested direction at BASE d54109d: forged-sha → 0,
   forged-rev → 0 (committed fixtures re-measured); trailing-space L1 → 0; 4 lines + blank 5th → 0;
   no trailing newline → 0; double space in `revision:` → 0; CRLF → 0; reordered lines → 0;
   uppercase-hex R → 0. Positive controls: valid receipt reads **1** at BASE (R = CAND, self-ancestor)
   and **1** at ae9e9eb (R = d54109d) — both exercise leg (c) end-to-end (fresh clone + gate CLEAN).
   Named looseness: F3.
2. **C2 ancestor+sha binding.** Counter enforces: R is 40-hex, exists (`^{commit}`), is ancestor of
   candidate (`merge-base --is-ancestor`), S == gate hash at CAND **and** S == gate hash at R
   (both-sha equality). Verified live: non-ancestor R (ae9e9eb vs candidate d54109d) → 0; R before
   the gate existed (5f3566c — `corpus/controls-replay.sh` absent there, verified `git cat-file -e`)
   → 0 (GATE_SHA_R empty). Future tip with changed gate → 0 via the S == CAND leg (intended; the
   wrong-sha fixture proves that leg fires; no live changed-gate pair exists — single landing commit
   542885e, bytes identical 65f66e17..ae9e9eb, sha256 fab42e1d…740f at both d54109d and ae9e9eb).
   Note: R == CAND passes (git treats a commit as its own ancestor) and any ancestor with identical
   gate bytes is accepted — predicate-consistent ("R … is an ancestor"), binding is the gate bytes,
   not the landing parent.
3. **C2/gate restore duty.** Direct gate runs in a shared sandbox clone of ae9e9eb
   (`gate-restore-duty.txt`): run 1 clean → rc 0, `controls-replay: CLEAN`, `git status --porcelain`
   on `.ufo/waves/round-41/controls` + `round-42/controls` **empty**; run 3 with a tampered
   `plans/round-41-controls.sh` exiting 3 → rc 1, `controls-replay: REFUSED`, porcelain still
   **empty** (restore happens before the verdict); run 4 after revert → rc 0 CLEAN, porcelain empty,
   runner bytes back to committed. The C2 counter's forged fixtures exit before any clone is created
   (all receipt legs precede `git clone`), so restore duty is vacuous for them. Gate note: on the
   runner-failure refusal path `controls-replay: REFUSED` goes to **stdout** (stderr empty), unlike
   manifest-mismatch lines (stderr) — minor observability nit, harmless for the counter (it reads rc
   + last stdout line).
4. **C3 row parsing.** Exactly-3-rows is fail-closed: register-full + duplicate row → rc 2
   `counter-refused: register rows`; rows 1/2 swapped → rc 2 `counter-refused: register order`;
   prose can never trigger these (pattern requires a leading `|` + exact path prefix). Cell
   extraction `awk -F'|'` indices 2..7 match the frozen 6-column shape (comment in the counter
   documents them). Stray-pipe / trailing-text behavior per F2/F4: rows drop or count only on real
   values; structural defects refuse (rc 2); nothing parses a wrong row *up* without its values
   matching reality.
5. **C3 sweep precision at 5f3566c.** Full `.sh` inventory at 5f3566c: **204** files — **21** under
   `plans/`, **17** under `corpus/` (incl. nested `corpus/fixtures/cells-hermetic/corpus/fx-ok.sh`),
   **166 outside plans/ + corpus/**, all under `.ufo/waves/` (round-24…42 build artifacts, mutant
   scripts, sandbox copies — e.g. `.ufo/waves/round-42/build/K42ExecRunner/patched.sh`). The frozen
   sweep (`git grep c2-worktree-at-base <rev> -- 'plans/*.sh' 'corpus/*.sh'`) touches only the 38
   in-scope runners; the exact command in the PIN worktree prints nothing (rc 1). Unrestricted
   `*.sh` grep for the token at 5f3566c: **0 files** — the row-3 conclusion holds under the widest
   `.sh` scope; the 17 token matches at that revision are all non-`.sh` (round-42 build
   json/stdout/md, SCORECARD.md, corpus/QUALITY.md, lessons, plans/round-42.md). Under-coverage is
   fail-safe for row 3: extra hits can only drop the row, never raise N. Pin is frozen, so no drift
   surface remains for this instrument.
6. **C3 executed legs at BASE.** Re-measured: `c3-base` (no register) → **0**; `R44_REGISTER_ROOT=
   fixtures/register-full` → **3**; `register-wrongvals` → **1** — all equal to the committed
   controls (`measured-at.txt` rows c3-base/c3-pos/c3-wrongvals). Re-derivation leg verified by hand
   (`c3-rederive-sweep.txt`): PIN clone, snapshot + delete `c1-base.txt`/`c2-base.txt`, runner rc 0,
   produced last lines **5** and **1** (equal to the register's re-derived cells), restore cmp OK,
   post-restore porcelain on `.ufo/waves/round-42/controls` **empty**. Note: the counter's own
   restore covers only the two deleted receipts; the runner rewrites all five round-42 receipts
   inside the throwaway clone (deleted on exit) — no lane reach, named.

## Drift timeline (reconstructed from the read set)

`plans/round-42-controls.sh` header pins round-42 expectations at its claim BASE e8265c0: C1 base 4,
C2 base 0; the worktree receipt (`c2-worktree-at-base.txt`, last line 3) was written by no runner
then or since. The same runner re-run at 5f3566c (round-43 BASE) produces 5 and 1 — the tree grew,
the counters' readings moved to their targets, and the committed bytes stayed at the old readings.
Round 43 disclosed the three drifted receipts (`c2-manifest-rederive-base.txt`: 8/8 manifest MATCH,
3 excluded listed with re-derived 5 / 1 / absent) and the round-43 C2 gate froze its manifest to the
8 re-derivable files. Round 44's register supersedes the three with the executed values at the
pinned revision — internally consistent with everything re-executed here.

## Residual risk and verification gaps

- The "gate changed between R and L" half of the both-sha check is proven by the code path and the
  wrong-sha fixture; no live revision pair with differing gate bytes exists to exercise it end-to-end
  (single landing commit for the gate). No commits were made anywhere (seat rule), so no synthetic
  changed-gate tip was constructed.
- The C2 counter deletes its leg-(c) clone with its scratch; post-gate dirt inside the counter's own
  clone cannot be observed post-hoc. Verified equivalently via four direct gate runs (clean, no-op
  tamper, hard-fail tamper, reverted).
- Lane-wide claim-ledger verify and self-counts intentionally not run (seat rule); only the named
  counters, the gate, the round-42 runner, and git plumbing were executed.
- No tools were installed or upgraded (pacman transactions paused host-wide; nothing needed).

SEAT-STATUS: complete
