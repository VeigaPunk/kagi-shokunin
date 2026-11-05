# K38ExecGuard — scoped findings (round 38 build wave, C2)

Top-line verdict: **C2 REPRODUCED** at candidate b944735.

Evidence (exact commands, stdout and exit codes): `.ufo/waves/round-38/build/K38ExecGuard/report.md`.

Reproduced:
- `bash corpus/laneguard.sh --selftest` in a `git archive b944735` extraction → `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`, exit 0.
- `bash plans/round-38-c2.sh` → `3`, exit 0.
- Do-nothing control `--selftest --no-mutate` → prints `detected=0 mutants=3 clean=ok` (claimed 0); exit code is 1 by construction (`detected != mutants`), the counter reads the printed count, so the control is unaffected.
- Live on a `git clone --shared` sandbox clone, working invocation form: tracked edit → VIOLATION exit 1; untracked file → VIOLATION exit 1; empty commit → VIOLATION exit 1; `true` → CLEAN exit 0. Matches the frozen predicate (before/after snapshot).

Defect found (new): R38-EG-1 — `corpus/laneguard.sh` `run` dispatch requires `--` as the first argument after `run`, so the documented/advertised form `run LANE -- CMD` (header line 10, usage string, assignment step 3) prints usage and exits 2 without snapshotting or running CMD. The code accepts `run -- LANE [--] CMD`. Selftest path unaffected (calls `run_guard` directly). Instrument left unmodified (frozen); flagged for reviewer/mutation seats.

Limits found (all exercised on the sandbox clone, all honestly CLEAN-or-VIOLATION as observed):
1. Transient write reverted inside the command → CLEAN exit 0 (before==after; blindness is inherent to the predicate).
2. `chmod +x corpus/laneguard.sh` → CLEAN, but vacuous: the file is already index mode 100755 (`core.filemode=true`), a no-op. Complementary `chmod -x` → VIOLATION exit 1: real mode changes are caught.
3. Ignored-path write (entry committed into the clone's tracked `.gitignore` first, then the file written) → CLEAN exit 0; the file exists on disk and is invisible (`--untracked-files=all` has no `--ignored`).
4. `.git/config` write → CLEAN exit 0; change persisted (`git config --local probe.x` → `1`). The snapshot covers HEAD + status + both diffs only.
5. Guard never reverts: violations leave the change in place; CLEAN attests "no change during the command", not "tree matches HEAD" (CLEAN observed on a tree carrying prior residue).
6. Selftest containment: fixtures under `${HYAKU_SCRATCH}/laneguard`, removed on exit (verified empty).

Lane untouched: `git status --porcelain` byte-identical before/after seat activity (7 untracked lines under `.ufo/waves/round-38/`, no new entries); `rev-parse master` = b94473505e6239cee0073d5be7a1c6f2ee07f564 before and after; no lane git/jj mutation performed.

Installs: none. Scratch /fast/scratch/hyaku/kagi-r38/K38ExecGuard deleted before yield.
