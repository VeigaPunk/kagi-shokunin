# R50bReviewerC1 — residual attack on C1 (round 50, attempt 2)

Seat: R50bReviewerC1 (leaf, no subagents). Godspeed axes: (1) **operability** — does the C1
counter actually pass on candidate 9e4dcbcc and fail (value=0) on BASE 565c43a; (2) **calibration**
— do the §C1 kill rules hold (instruments untouched, diff scope = header/setup/launch only, no r49
blob refs); (3) honesty — every receipt is a real run with rc and last line.

Status: IN PROGRESS — findings appended below as they land.

## Environment
- lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master)
- scratch: /fast/scratch/hyaku/kagi-r50/R50bReviewerC1

## Findings

### (b) Kill rules — checks run 2026-11-06, lane master
All four revs verified as commits via `git rev-parse --verify <rev>^{commit}`: BASE=565c43a…, C1 cand=9e4dcbc…, C2 cand=e4abab1…, predeclaration=7d3b2c01…. rc=0 each.

- **Instruments frozen**: `git diff --stat 7d3b2c01 e4abab1d -- plans/round-50-c1.sh plans/round-50-c2.sh plans/round-50-controls.sh plans/round-49-c1.sh .ufo/waves/round-50/controls/fixtures` → rc=0, **0 bytes (empty)**. KILL RULE PASS.
- **No r49 blob refs**: `git grep -nE 'r49-[0-9a-f]{24}' e4abab1d` → rc=1, 0 lines. KILL RULE PASS. (The runtime-generated token prefix `r49-` in the trial is built by `secrets.token_hex` at run time, not a committed literal — not a kill-rule object.)
- **Trial diff scope**: `git diff 565c43a e4abab1d -- corpus/openbao-token-trial.sh` → rc=0, 31-line diff, exactly 3 hunks: (1) 3 added header-comment lines; (2) 1 added setup check `command -v setpriv`; (3) server launch line `bao server -dev … &` → `setpriv --pdeathsig KILL bao server -dev … &`. No TRIAL/OPENBAO_TRIAL grammar line, no test body touched. KILL RULE PASS. Identical 31-line diff for BASE→9e4dcbc (C1 candidate), confirming C2's tree carries C1's change.

### (a) Counter runs — receipts R50bReviewerC1-receipts/c1-counter-{cand,base}.txt
Both runs: `bash plans/round-50-c1.sh <rev>` from the lane, cwd=/home/vgpnk/Projects/shokunin/kagi-shokunin. The frozen counter builds its own scratch (`kagi-r50/c1-counter.XXXXXX`, removed on exit), pins `~/.local/bin/bao` by sha256 (verified `9c5f3628…bd41b788` matches PIN_BAO before running), and runs the frozen round-49 counter for POSITIVE.

- **Candidate 9e4dcbcc8666b22aa871037138826693fa0ba4fa**: `C1_ORPHAN_SAFE: value=3 positive=1 reaped=0 K1:observed=1,captured=1,survivors=0 K2:observed=1,captured=1,survivors=0 K3:observed=1,captured=1,survivors=0`, rc=0. Target 3 reached; at every kill point a server was observed and 5 s later zero survived; the counter's own exit reaper had nothing to reap (reaped=0) — pdeathsig did the killing.
- **BASE 565c43a874b59cd216f4a55c8742db48fa854f16**: `C1_ORPHAN_SAFE: value=0 positive=1 reaped=3 K1:observed=1,captured=1,survivors=1 K2:observed=1,captured=1,survivors=1 K3:observed=1,captured=1,survivors=1`, rc=0. Expected BASE reading 0 confirmed: every kill point left the server alive and the counter reaped 3 orphans itself. Discrimination 0 → 3 shown on this host today.
- `positive=1` on both trees: the frozen round-49 counter still prints `value=5` (C1_OPENBAO_TRIAL) — the candidate does no harm to round-49 C1.

### (c) Independent SIGKILL demo — receipts R50bReviewerC1-receipts/demo-{cand,base}.txt, driver demo.sh
Method: `git archive` of each tree into scratch; trial started as its own session (`setsid`, HOME/PATH and `--work` all inside scratch, bao via /home/vgpnk/.local/bin); the driver polls for a `bao server` descendant of the trial shell, SIGKILLs **only** the trial shell, waits 5 s, judges the captured server by pid+starttime (/proc/…/stat field 22), then kills any survivor.

- **Candidate tree (e4abab1d)**: trial_shell_pid=4161468; captured server pid=4162462 starttime=37600246 (2nd poll, ≈1 s — K1); `kill -9` rc=0; after 5 s `/proc/4162462/stat gone` → **verdict=dead**, no orphan. Trial.log empty (kill landed before the first TRIAL line, consistent with K1).
- **BASE tree (565c43a)**: trial_shell_pid=4161463; captured server pid=4162403 starttime=37600245 (K1); `kill -9` rc=0; after 5 s state=S, same starttime → **verdict=alive** (expected survivor); driver reaped it (`kill -9` pid=4162403).
- The counter result and the out-of-counter demo agree: BASE orphans, candidate does not.

## Verdicts
1. **C1 operability (a)** — NOT falsified. Counter on candidate reads `value=3` rc=0 (target); on BASE reads `value=0` rc=0 (expected). Command + rc + last lines recorded above.
2. **Kill rules (b)** — NOT falsified. Instruments diff-stat 7d3b2c01→e4abab1d empty (0 bytes); `git grep -nE 'r49-[0-9a-f]{24}' e4abab1d` rc=1 no matches; trial diff touches only header comment (3 lines), one `command -v setpriv` setup check, and the server launch line — no grammar or test-body lines.
3. **Independent SIGKILL demo (c)** — NOT falsified. BASE survivor observed and reaped by me; candidate server gone ≤5 s after shell SIGKILL, verified by pid+starttime identity outside the counter.

## Residual risk and gaps
- Note: the frozen counter emits `line 78: /proc/<pid>/cmdline: No such file or directory` stderr lines during its capture walk (races with short-lived pids; 20–27 lines per run here, several host pids). Cosmetic — the capture is identity-checked (pid+starttime) and fail-closed; no effect on readings. Routed observation, not applied (instrument frozen).
- Ceiling (named in plan §C1): the counter cannot see a server that is neither a trial descendant nor an R50_NONCE carrier; my demo matches that blind spot too (descendant-based capture). The detached+stripped case remains covered only by control K1-F2, not by this seat.
- Both counter runs and both demos ran while several sibling OpenBao trials were live on this host; readings still discriminated cleanly, so load sensitivity was not observed — but a 120 s kill-point timeout under heavier load remains a SETUP (exit 2) path by design, untested here.
- POSITIVE was verified indirectly via the counter's own `positive=1` flag (it prints only the last line of the round-49 run); I did not independently rerun round-49's counter.

## Hygiene
- bao pin verified before runs: sha256 of /home/vgpnk/.local/bin/bao = 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788 (PIN_BAO match); binary never replaced.
- Post-run scan `pgrep -f '^bao server'` with silent argv classification (dev root tokens ride in server argv, so cmdlines were never printed): mine=0, other=0 — **no bao process of mine alive at exit**; demo driver reaped the BASE survivor itself; counter runs reaped their own (reaped=3 / reaped=0).
- No tokens, passwords or key material printed or persisted; no git mutations anywhere; scratch `/fast/scratch/hyaku/kagi-r50/R50bReviewerC1` removed after receipt copy.
- No tool installs were needed (pacman untouched).
