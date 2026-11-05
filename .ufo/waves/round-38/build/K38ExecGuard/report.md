# K38ExecGuard — C2 lane-tree write guard: sandbox verification and attack (round 38, wave build, attempt 1)

Seat: K38ExecGuard. Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master).
Candidate under test: b944735 (full: b94473505e6239cee0073d5be7a1c6f2ee07f564) == lane master == lane HEAD at seat start.
Scratch: /fast/scratch/hyaku/kagi-r38/K38ExecGuard (TMPDIR and HYAKU_SCRATCH passed explicitly on every instrument run; dir removed before yield; all receipts are embedded below — nothing else needed copying).
Installs: none (no pacman/uv/cargo/npm installs were performed or needed).
No frozen instrument, counter, control, manifest, capture, or lesson was edited. No lane-tracked file, lane git/jj state, or lane index was touched.

## Top-line verdict

C2 REPRODUCED at candidate b944735, with one new defect found (CLI dispatch; does not affect the selftest path) and five blind spots/observations recorded for the reviewers:

- `bash corpus/laneguard.sh --selftest` (in a `git archive b944735` extraction) prints `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`, exit 0 — matches the frozen claim.
- `bash plans/round-38-c2.sh` prints `3`, exit 0 — matches the frozen counter claim.
- The do-nothing control `--selftest --no-mutate` prints `LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok` (the claimed 0), but exits 1 by construction — see §2.2.
- Live guard on a `git clone --shared` sandbox clone: tracked edit → VIOLATION exit 1; untracked file → VIOLATION exit 1; new (empty) commit → VIOLATION exit 1; clean `true` → CLEAN exit 0 — matches the predicate.
- Defect R38-EG-1: the `run` subcommand rejects its own documented invocation `run LANE -- CMD` with usage exit 2 (§3). The code accepts `run -- LANE [--] CMD`. The selftest calls `run_guard` directly, so `detected=3` is unaffected; every live probe below uses the code-accepted form and is labeled as such.

## 1. Lane state bookends

Before any seat activity (command: `git -C <LANE> status --porcelain`; `git -C <LANE> rev-parse master`; `git -C <LANE> rev-parse HEAD`):

```
?? .ufo/waves/round-38/build-dispatch.json
?? .ufo/waves/round-38/build-run.stderr
?? .ufo/waves/round-38/build-run.stdout
?? .ufo/waves/round-38/build-spec.json
?? .ufo/waves/round-38/build.ready
?? .ufo/waves/round-38/build.ready.dispatched
?? .ufo/waves/round-38/build/
master: b94473505e6239cee0073d5be7a1c6f2ee07f564
HEAD:   b94473505e6239cee0073d5be7a1c6f2ee07f564
```

Pinned commits resolve in the lane: `b944735^{commit}` → b94473505e6239cee0073d5be7a1c6f2ee07f564; `8c48b7df71066b969ac078205b5ed18cf5f53286` → same object; `a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c` → same object (exit 0 each).

After all seat activity (§6): status identical (same 7 untracked lines), master unchanged. This seat's report files land under the already-untracked `.ufo/waves/round-38/build/` entry and add no porcelain lines.

## 2. Selftest and counter at the candidate (assignment step 2)

Setup: `git -C <LANE> archive b944735 | tar -x -C "$S/ext"` (exit 0; `corpus/laneguard.sh`, `corpus/quote-locate.py`, `README.md` all present in the extraction; note: an archive extraction has no `.git`, which does not matter — the selftest creates its own `git init` fixtures).

### 2.1 Positive selftest

```
$ cd "$S/ext" && TMPDIR=$S/tmp HYAKU_SCRATCH=$S/hs bash corpus/laneguard.sh --selftest
LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok
SELFTEST_EXIT=0
```

Matches the C2 claim exactly (`detected=3 mutants=3 clean=ok`, exit 0).

### 2.2 Do-nothing control

```
$ cd "$S/ext" && TMPDIR=$S/tmp HYAKU_SCRATCH=$S/hs bash corpus/laneguard.sh --selftest --no-mutate
LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok
NOMUTATE_EXIT=1
```

The printed detected count is 0, exactly what the claim and `c2_nowork` expect (`plans/round-38-controls.sh` reads the count through `sed`, so the control prints 0 regardless of exit code). The exit code is 1 because `selftest()` ends with `[ "$clean_ok" = ok ] && [ "$detected" -eq "$mutants" ]` and 0 != 3 under `--no-mutate`. Recorded as an observation on the instrument's exit semantics, not as a claim mismatch.

### 2.3 Counter (extra, reproduces the claim line `bash plans/round-38-c2.sh` prints 3)

```
$ cd "$S/ext" && TMPDIR=$S/tmp HYAKU_SCRATCH=$S/hs bash plans/round-38-c2.sh
3
C2COUNTER_EXIT=0
```

### 2.4 Fixture containment

`ls -A $S/hs` after the runs → only `laneguard/` (the scratch root named by the instrument); `ls -A $S/hs/laneguard` → empty: the `mktemp -d` fixture is removed on exit, consistent with "fixtures live under ${HYAKU_SCRATCH}/laneguard, removed on exit".

## 3. Defect R38-EG-1: `run` dispatch rejects its own documented usage

Raw bytes of `corpus/laneguard.sh` lines 99–103 at b944735 (read via `:99-108:raw`):

```
  run)
    shift
    [ "${1:-}" = "--" ] || { echo "usage: laneguard.sh run LANE -- CMD..." >&2; exit 2; }
    shift
    lane=${1:?lane}
```

The first argument after `run` must literally be `--`. The code therefore accepts `run -- LANE [--] CMD...`, while the header comment (line 10: `laneguard.sh run LANE -- CMD [ARG...]`), the usage string itself, and the seat assignment all use `run LANE -- CMD...`. With the documented form the guard prints usage to stderr and exits 2 — it never snapshots and never runs CMD.

Evidence (assignment step 3, documented form, against the shared clone):

```
$ bash $G run "$S/clone" -- sh -c 'echo x >> README.md'
usage: laneguard.sh run LANE -- CMD...
A_EXIT=2          # clone status after: empty (no side effect)
$ bash $G run "$S/clone" -- sh -c 'echo x > untracked-new.txt'
usage: laneguard.sh run LANE -- CMD...
B_EXIT=2
$ bash $G run "$S/clone" -- true
usage: laneguard.sh run LANE -- CMD...
C_EXIT=2
```

($G = $S/ext/corpus/laneguard.sh.) Impact on the frozen claims: none on the selftest/counter path (`selftest()` calls `run_guard` directly). Impact on users of `run`: the advertised invocation is impossible; anyone scripting `run LANE -- CMD` gets exit 2 silently (stderr only). Left unmodified per honesty rule; flagged for the wave's reviewer/mutation seats.

## 4. Live exercise on the sandbox clone (assignment step 3, code-accepted form)

Clone: `git clone --shared -q <LANE> $S/clone` (exit 0; HEAD b94473505e6239cee0073d5be7a1c6f2ee07f564; status clean; 5532 tracked files; `README.md` present; toplevel asserted = $S/clone before every mutating step, per host guard).

| case | command (cwd-independent; $G=$S/ext/corpus/laneguard.sh) | stdout | exit | verdict |
|---|---|---|---|---|
| a2 | `bash $G run -- $S/clone sh -c 'echo x >> README.md'` | `LANE_GUARD: VIOLATION lane=…` + `  changed:  M README.md` | 1 | VIOLATION (expected) |
| b2 | `bash $G run -- $S/clone sh -c 'echo x > untracked-new.txt'` | `LANE_GUARD: VIOLATION lane=…` + `  changed:  M README.md` + `  changed: ?? untracked-new.txt` | 1 | VIOLATION (expected) |
| c2 | `bash $G run -- $S/clone -- true` | `LANE_GUARD: CLEAN lane=… rc=0` | 0 | CLEAN (expected) |
| h (extra) | `bash $G run -- $S/clone git -c user.name=probe -c user.email=probe@invalid commit -q --allow-empty -m probe` | `LANE_GUARD: VIOLATION lane=…` | 1 | VIOLATION — live analog of selftest mutant 3 (HEAD change) |

All three assignment expectations reproduced once the code-accepted invocation form is used. Note on c2: the tree still carried the a2/b2 residue, and the guard still said CLEAN — it compares before vs after the command (`snap()` = sha256 of `rev-parse HEAD`, `status --porcelain=v1 -z --untracked-files=all`, `diff --binary`, `diff --cached --binary`), not the tree against HEAD (see L6).

## 5. Limit probes (assignment step 4) — every result recorded honestly

| case | command (working form) | stdout | exit | verdict |
|---|---|---|---|---|
| d | `run -- $S/clone sh -c 'echo x >> README.md; git checkout -- README.md'` | `LANE_GUARD: CLEAN lane=… rc=0` | 0 | CLEAN — blind spot |
| e | `run -- $S/clone sh -c 'chmod +x corpus/laneguard.sh'` | `LANE_GUARD: CLEAN lane=… rc=0` | 0 | CLEAN — probe vacuous, see (e2) |
| e2 (extra) | `run -- $S/clone sh -c 'chmod -x corpus/laneguard.sh'` | `LANE_GUARD: VIOLATION lane=…` + `  changed:  M corpus/laneguard.sh` | 1 | VIOLATION — real mode change caught |
| f | `run -- $S/clone sh -c 'echo x > ignored-probe.txt'` (after `.gitignore` entry appended to tracked .gitignore and committed in the clone, head 0c64c6e) | `LANE_GUARD: CLEAN lane=… rc=0` | 0 | CLEAN — ignored-probe.txt exists on disk, invisible to the guard |
| g | `run -- $S/clone sh -c 'printf "[probe] x = 1\n" >> .git/config'` | `LANE_GUARD: CLEAN lane=… rc=0` | 0 | CLEAN — change persisted (`git config --local probe.x` reads `1`) |

The clone was reset between probe groups (`git checkout -- .` + removal of probe untracked files; status lines = 0 before each group) so each verdict is attributable to its own case; every reset was preceded by the `rev-parse --show-toplevel` assert.

Findings, stated plainly:

- L1 (case d): a write that is reverted before the command returns is invisible. `snap()` is taken before and after; before==after → CLEAN. The guard's predicate is "no net change across the command", so this blindness is by design, but it means a command that dirties and restores the tree passes unattested.
- L2 (case e/e2): mode changes are handled through git's filemode machinery, not specially. `corpus/laneguard.sh` is index mode 100755 and `core.filemode=true` in the clone, so the assigned `chmod +x` was a no-op (status shows nothing — the CLEAN is real but vacuous). The complementary `chmod -x` shows ` M` and is caught: VIOLATION exit 1. A real mode change on a tracked file is detected.
- L3 (case f): ignored-path writes pass. `--untracked-files=all` does not include `--ignored`, so a file matched by .gitignore never appears in the snapshot. Setup note: the `.gitignore` entry was appended to the tracked `.gitignore` and committed inside the clone first (toplevel asserted), so the setup itself did not dirty the snapshot.
- L4 (case g): everything outside the work tree — `.git/config`, hooks, packed-refs surgery below HEAD — is unguarded; only `rev-parse HEAD` (first line of the snapshot) would catch a branch-ref change, and even that can be evaded by e.g. `--replace-all`-style ref games only if HEAD's own value stays put. Recorded as observed for config: CLEAN while the file changed.
- L5 (selftest containment): fixtures live under `${HYAKU_SCRATCH}/laneguard` and are removed on exit (§2.4); the lane was never touched (§1, §6).
- L6 (observed in §4): the guard never reverts; a VIOLATION leaves the change in place (a2's ` M README.md` persisted through b2; h's commit remained, clone HEAD now b85cb386b853b19f00457824fc9f63f85579956d). CLEAN attests "nothing changed during the command", not "tree matches HEAD" — c2 passed on a dirty tree.

## 6. Lane untouched (assignment step 5)

After all probing (command: `git -C <LANE> status --porcelain`; `git -C <LANE> rev-parse master`; `git -C <LANE> rev-parse HEAD`):

```
?? .ufo/waves/round-38/build-dispatch.json
?? .ufo/waves/round-38/build-run.stderr
?? .ufo/waves/round-38/build-run.stdout
?? .ufo/waves/round-38/build-spec.json
?? .ufo/waves/round-38/build.ready
?? .ufo/waves/round-38/build.ready.dispatched
?? .ufo/waves/round-38/build/
master: b94473505e6239cee0073d5be7a1c6f2ee07f564
HEAD:   b94473505e6239cee0073d5be7a1c6f2ee07f564
```

Byte-identical to §1. No tracked file changed; no git mutation was run against the lane.

## 7. Acceptance summary

- Table of every case with command, exit and verdict: §4 (a2, b2, c2, h) and §5 (d, e, e2, f, g), plus §3 (documented-form a/b/c exits 2).
- Lane-untouched check: §1 before, §6 after, identical.
- Top-line verdict: C2 REPRODUCED — selftest `detected=3 mutants=3 clean=ok` exit 0, counter `3`, do-nothing control prints `detected=0`, and the live guard reports VIOLATION/exit 1 for a tracked edit, an untracked file, and a new commit, CLEAN/exit 0 for the no-op.
- Limits found: R38-EG-1 (documented `run LANE -- CMD` form rejected, exit 2); blind to transient writes reverted in-command (d); ignored-path writes (f); `.git/` writes (g); assigned mode probe vacuous but real mode changes caught (e/e2); guard is non-restoring and CLEAN means "no change during the command", not "clean tree" (L6). `--no-mutate` exit code is 1 while printing the claimed `detected=0` (§2.2).

Scratch `/fast/scratch/hyaku/kagi-r38/K38ExecGuard` (ext extraction, shared clone, hs fixture root, logs) is deleted immediately after this report lands; the EXIT trap set at seat start removes it as a backstop.
