K38ReviewGuard — C2 lane guard: verification + attack (round 38, wave `build`)
==============================================================================
Date: 2026-11-05. Candidate b94473505e6239cee0073d5be7a1c6f2ee07f564; claim BASE
a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c. No tool installs (none needed).

Method
------
Scratch /fast/scratch/hyaku/kagi-r38/K38ReviewGuard (deleted at end; receipts copied here).
Instrument of record: `git archive b944735 | tar -x` -> $S/ext/corpus/laneguard.sh,
sha256 7ca9fcabb7c4bc0551b53353f480077eb1184014fd18343b0976024fffda857e — byte-identical
to the lane worktree copy. Lane read-only; every git mutation happened in `git clone
--shared` clones (toplevel asserted for g/h/l). All attacks ran in fixture clones per-case.
No lsp device in this seat's toolset; every verdict below rests on executed commands.

Guard anatomy (read in full): `snap()` = sha256 over
  1. `git -C LANE rev-parse HEAD`
  2. `git -C LANE --no-optional-locks status --porcelain=v1 -z --untracked-files=all`
  3. `git -C LANE diff --binary --no-ext-diff`            (unstaged; NOT optional-locked)
  4. `git -C LANE diff --cached --binary --no-ext-diff`   (staged;  NOT optional-locked)
`run_guard()`: snapshot, `(cd LANE && CMD)`, re-snapshot; before!=after -> "VIOLATION" exit 1,
else "CLEAN" and CMD's exit status. Not covered by any snapshot component: branch/tag/ref
names, .git/* (config, reflogs, objects), ignored files, contents of already-untracked
files, empty directories, and any write fully reverted inside the run.

D1 (defect, interface break; non-refuting for C2 as measured): the `run` subcommand parser
requires `run -- LANE [--] CMD...` (first token after `run` must literally be `--`), while
the script header, its own usage string, and this seat's assignment all prescribe
`run LANE -- CMD`, which exits 2 with the usage line. Executed:
  `bash $G run $S/case-dg -- true`          -> rc=2, "usage: laneguard.sh run LANE -- CMD..."
All 10 pass-1 cases (run LANE -- cmd) died the same way before any snapshotting; pass 2
re-ran everything with the accepted grammar. Impact: the guard's public `run` interface as
documented cannot be driven by anyone following the docs. Non-refuting: the frozen C2
counter (plans/round-38-c2.sh) only calls `--selftest`, whose selftest() calls run_guard()
directly and never parses this grammar.

D2 (defect, instrument hygiene): snap() calls 3 and 4 lack `--no-optional-locks`; the
unstaged diff opportunistically refreshes and REWRITES .git/index on stat-stale runs.
Measured: CASE_I (touch corpus/laneguard.sh, then clean guarded run):
  .git/index sha256 before = c5cf16384a68923d3d460e7dde957b41c98711583848d12dbd764b5afbe63caf
  .git/index sha256 after  = 371bd0aac57d532962c82f01ddc806cf25d9bde0952fc868285f75df45eab196
Does not affect detection (the index is not hashed by snap(); the two status calls are
--no-optional-locks), and does not false-positive: guard printed CLEAN both times.

D3 (defect, behavior wart): `--selftest --no-mutate` prints the correct control line but
exits 1. Selftest's return is `[ clean_ok = ok ] && [ detected -eq mutants ]`; in
--no-mutate mode mutants is hardcoded 3 while detected is 0 by construction, so the exit
can never be 0. Executed:
  LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok   / rc=1
The frozen counter reads the printed integer (c2_nowork -> 0), so the C2 measurement is
unaffected; any consumer trusting the exit status misreads the do-nothing control.

Attack table (all inside `git clone --shared` fixtures; guard = $S/ext/corpus/laneguard.sh)
------------------------------------------------------------------------------------------
Expected, Actual rc/verdict lines are verbatim from the runs (pass 2/pass 3/pass 4).

case  command (as executed)                                                       verdict     exit  classification
----  --------------------------------------------------------------------------  ----------  ----  ----------------------------------------------------------
a     run -- case-a2 -- bash -c 'cp corpus/laneguard.sh $S/a2.bak; printf tamper  CLEAN           0  Ceiling, stated: usage line says "snapshot ... re-snapshot;
      >> ...; cp back" (tracked edit RESTORED in-run; restored-ok: yes)                              any difference -> VIOLATION" — a fully reverted write leaves
                                                                                                    no before/after difference. Not inside the frozen predicate.
a'    pass-1 case-a (restore failed by scratch-env bug -> edit left in place)    VIOLATION       1  Detection proof: "changed:  M corpus/laneguard.sh".
b     chmod +x corpus/laneguard.sh                                               CLEAN           0  Correct (no-op): blob is 100755 (ls-files -s); chmod +x changed
b2    chmod +x plans/round-38-c2.sh                                              CLEAN           0  Correct (no-op): blob also 100755. Attack error, not a guard gap.
b3    chmod -x corpus/laneguard.sh (demote 755->644)                             VIOLATION       1  Detected: "changed:  M corpus/laneguard.sh".
b4    chmod +x .gitattributes (blob 100644)                                      VIOLATION       1  Detected: "  M .gitattributes"; post status ` M .gitattributes`.
c     mkdir emptydir                                                             CLEAN           0  Ceiling (git tracks files, not directories; "untracked files"
                                                                                                    scope in header). Undocumented in so many words.
d     bash -c 'echo transient > new-tmp.txt; rm new-tmp.txt'                     CLEAN           0  Ceiling (transient, same stated semantics as case a).
e     .gitignore entry added OUTSIDE the guarded run, then                       CLEAN           0  GAP (E4): ignored-file writes escape. Evidence: check-ignore
      run -- case-e -- bash -c 'mkdir -p ignored-dir; echo x > ignored-dir/f.txt'                    matched (.gitignore:3:ignored-dir/), file-after: x exists,
                                                                                                    status --untracked-files=all never lists it; no --ignored pass
                                                                                                    anywhere in snap(). Undocumented.
f     git config laneguard.test attack                                           CLEAN           0  Gap/ceiling (E6): .git/config persisted (config-after: attack);
                                                                                                    outside every snapshot component. Undocumented.
g     git -c user.name=x -c user.email=x@invalid commit --allow-empty -q -m a    VIOLATION       1  Detected (predicate class "a new commit"); HEAD sha changed.
h     bash -c 'echo x >> corpus/laneguard.sh; git add corpus/laneguard.sh'       VIOLATION       1  Detected (staged change): "changed: M  corpus/laneguard.sh".
i     touch corpus/laneguard.sh                                                  CLEAN           0  Correct: content-based snapshot ignores stat-only change.
                                                                                                Side effect = D2 (index rewrite, see above).
j     true                                                                       CLEAN           0  Correct; clean baseline.
k     pre-existing untracked u.txt, in-run: bash -c 'echo drift >> u.txt'        CLEAN           0  GAP (E5): status-before = status-after = "?? u.txt"; diff
                                                                                                    excludes untracked; content drift (seed/drift) invisible.
l     git checkout -q -b attack-branch                                           CLEAN           0  GAP (E6): branch-after: attack-branch; HEAD sha unchanged, so
                                                                                                    branch identity is not snapshotted.
m     git tag attack-tag                                                         CLEAN           0  GAP (E6): tag-after: attack-tag; refs outside HEAD sha.

Calibration at the candidate (context, executed in scratch):
  `bash $G --selftest`             -> "LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok", rc=0
  `bash $G --selftest --no-mutate` -> "LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok", rc=1 (D3)
Both match the frozen C2 dossier (positive 3; do-nothing control 0).

Index-write check (required)
----------------------------
- Pristine clean run (case j): .git/index sha256 bac41c57fe2741e9d8acef... before == after
  (unchanged). `git --no-optional-locks status` (both snap calls carry the guard) does not
  write the index.
- Stat-stale clean run (case i, after touch): index sha256 c5cf1638... -> 371bd0aa...
  The guard DID rewrite .git/index. Only the two unlocked diff calls in snap() can write;
  rev-parse is read-only and status is --no-optional-locks. No false verdict resulted.

Top-line verdict
----------------
C2 HOLDS against these attacks. Reason: every write class named by the frozen predicate is
detected at b944735 with VIOLATION/exit 1 — selftest detected=3 mutants=3 clean=ok (rc=0);
independent probes: tracked unstaged edit (pass-1 case a'), staged change (h), empty commit
(g), tracked-mode change (b3/b4) — and the clean/do-nothing path prints CLEAN with exit 0
(j; no-mutate control prints detected=0). No attack false-positived a clean command. None
of the escape cases (a,c,d,e,f,k,l,m) falls inside the predicate's three classes; they are
recorded below as coverage gaps/ceilings, rigorous to the letter of the frozen sentence,
not as C2 refutations. Had `run` been load-bearing for the claim, D1 alone would break it;
the counter is --selftest-only, so the claim stands.

Residual risk / ledger notes (not claim-refuting)
-------------------------------------------------
- D1: documented `run LANE -- CMD` grammar is dead (exit 2); only `run -- LANE -- CMD`
  works. Any wave seat following the header cannot drive the guard.
- E4: writes to ignored files escape entirely (checked-in .gitignore attacks included).
- E5: content of any file already untracked in the before-snapshot can be tampered freely
  (status is path-only; diff excludes untracked). In-lane relevance: pre-existing untracked
  artifacts are an unguarded write surface.
- E6: any .git-metadata write that leaves HEAD sha + worktree/index diffs unchanged
  escapes: config, hook installation, branch create/rename, tags, reflog edits, `git
  checkout -b`, packed-ref surgery.
- E1/E2 (ceiling, stated): any write fully reverted inside the guarded command is invisible;
  the guard is a before/after differ, not a syscall monitor.
- D2: on stat-stale runs the instrument itself rewrites the guarded repo's .git/index.
- D3: do-nothing control exits 1 while printing the correct 0.

Scope / honesty notes
---------------------
- Second Report trailer (.ufo/waves/round-38/build/K38ReviewGuard.md, lane-relative):
  written with the same findings per the assignment trailer instruction; outside my seat
  subdirectory, so flagged here.
- Every verdict above was executed this session; commands and rc are quoted verbatim. The
  pass-1 battery (documented grammar) failed rc=2 for ALL cases before any snapshot — that
  failure is finding D1, and the battery was re-run with the accepted grammar.
- No pacman transaction, no install, no lane write, no git mutation outside $S clones.
- Scratch deleted before yield; receipts (run-cases.sh, pass3.sh, attacks-output.txt,
  pass3-output.txt, pass4-output.txt) copied into this directory.
