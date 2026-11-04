# ExecGate — round-34 C2 part 1: `relative-work` selftest case for the prefreeze gate

Deliverable: `.ufo/waves/round-34/build/prefreeze-control.sh`
**sha256sum:** `ca338da7c7400e07fa551c42b02a4bb6b7bedf4c47bda849e1aa162fbc86493a`
Selftest case count: **12** (`PREFREEZE_SELFTEST: PASS (12 cases)`, exit 0)
BASE bytes: `git show f9dc06fd8f6b43c175193c76dc6350468f551634:corpus/prefreeze-control.sh` (273 lines, sha256 `b634a8d1a1a161debf6069c5ea033a220550efa61c3271313257f8a8f9cd9098`); deliverable started as an exact copy of those bytes.

## Change

- One new case, `relative-work`, inserted immediately after `base-isolation`'s `ck` (deliverable lines 179–189). It creates `$tmp/rel`, writes a one-row controls file (`lines<TAB>3<TAB>wc -l < corpus/a.txt` — expect 3 at the fixture's first commit), and runs the gate FROM `$tmp/rel` with a relative `--work ./w`:
  `out=$(cd -- "$tmp/rel" && PREFREEZE_REPO=$repo TMPDIR=$tmp/tmp bash "$SELF" run --base "$rev" --controls "$ctl" --work ./w 2>&1); rc=$?`
  then `ck relative-work 0 '^PREFREEZE: CLEAN \(controls=1 mismatch=0\)$' '^OK lines expect=3 measured=3$'`.
  The `try`/`ck` helpers are unchanged; the case sets the same `$out`/`$rc`/`$last` globals `try` sets and reuses `ck` verbatim. Every existing case is byte-identical to BASE.
- Header comment only: case enumeration updated eleven → twelve and the relative-work witness described (round-33 F1). No predicate sentence touched.

## Witness removed for the mutant

Exact line deleted from the unfixed copy (`diff` against the deliverable shows `241d240` and nothing else):

```
WORK_ROOT=$(cd -- "$WORK_ROOT" && pwd -P) || { note "cannot resolve: $WORK_ROOT"; die work-unwritable; }
```

Failure mechanism: without canonicalization `EXTRACT` is relative (`./w/prefreeze.XXXXXX`); every row executes with `cwd =` the extraction, so the row's `2>"$errf"` stderr redirect (`$RECEIPTS/$id.stderr`, relative) points under a nonexistent `./w` inside the extraction → redirect fails → empty output → false `NORESULT` → `PREFREEZE: SETUP noresult`.

## Executed evidence (each run once)

1. `bash .ufo/waves/round-34/build/prefreeze-control.sh --selftest` → all 12 `CASE … ok`, `PREFREEZE_SELFTEST: PASS (12 cases)`, exit 0. Receipt: `receipts/gate-selftest.txt`.
2. `receipts/gate-relative-work.txt` — standalone replay of the case (fresh fixture: `mktemp -d`, `git init -q`, `rev-parse --show-toplevel` asserted equal to the fixture before its single commit, `corpus/a.txt` = a,b,c) prints `OK lines expect=3 measured=3`, `PREFREEZE: CLEAN (controls=1 mismatch=0)`, `exit=0`; plus the selftest's `CASE relative-work              ok` line.
3. Unfixed copy (line above deleted) `--selftest` → `CASE relative-work FAIL rc=2 last=PREFREEZE: SETUP noresult`, `PREFREEZE_SELFTEST: FAIL (12 cases)`, exit 1 — all 11 pre-existing cases still ok, so the new case is the only witness that fires. Receipt: `receipts/gate-unfixed-relative-work.txt` (names the removed line in its header).
4. `PREFREEZE_REPO=/home/vgpnk/Projects/shokunin/kagi-shokunin bash .ufo/waves/round-34/build/prefreeze-control.sh run --base f9dc06fd8f6b43c175193c76dc6350468f551634 --controls plans/round-34.controls.tsv --work /fast/scratch/hyaku/kagi-r34/ExecGate/w2` → exit 0, full output:

```
OK sd7 expect=3 measured=3
OK sd8 expect=1 measured=1
OK sd9 expect=1 measured=1
OK sd789 expect=5 measured=5
OK prefreeze_cases expect=11 measured=11
OK sweep_selftest_cases expect=7 measured=7
OK registry_rows expect=82 measured=82
OK aliyun_entry expect=0 measured=0
OK m7_receipt expect=0 measured=0
OK doc_entries expect=34 measured=34
PREFREEZE: CLEAN (controls=10 mismatch=0)
```

(`PREFREEZE_REPO` set per the script's own documented override: a copy outside `<lane>/corpus/` would otherwise derive the repository from its build-tree location. Matches the L1's BASE receipt values exactly.)

## Failures seen

- Expected, and the point of the case: the unfixed mutant's `CASE relative-work FAIL rc=2 last=PREFREEZE: SETUP noresult` (run 3). No gate failure in any other run.
- Seat-side, fixed, no rerun needed: (a) my receipt-extraction grep `^CASE relative-work (ok|FAIL)` missed the case line because `ck` pads the label to 26 columns — re-extracted with `^CASE relative-work +(ok|FAIL)`; (b) the two-step append left a duplicated section header in `gate-relative-work.txt` — collapsed. `gate-selftest.txt` and `gate-unfixed-relative-work.txt` were written in one pass and needed no correction.

## M7 interaction (counter limitation — flagged, not changed)

ReviewC2-9 executed an independent `--base`-ignoring (M7) mutant against delivered `ca338da7…` and observed `base-isolation` FAIL **and** `relative-work` FAIL. Consistent with the bytes: after `base-isolation`'s second fixture commit the live `corpus/a.txt` is 4 lines while both rows expect 3 at `$rev`, so an extraction-ignoring harness breaks both witnesses. The frozen contract (plans/round-34.md:78–84) requires the M7 receipt to *name* `base-isolation` and counts `grep -c 'CASE base-isolation FAIL' .ufo/waves/round-34/mut/m7-shipped.txt` (0→1) — the second FAIL line is invisible to that counter and no exclusivity is promised, so the case stays exactly as item-pinned (`wc -l < corpus/a.txt` expect 3). Counting `b.txt` instead would isolate M7 to `base-isolation` if a future counter ever demands that; noted here, deliberately not done.

## Tooling

No installs or updates (bash, git, grep, diff, sha256sum, timeout sufficed). Pacman untouched per the host-wide pause. No network, no vault contact, no subagents.

## Bounds

Lane tree strictly read-only; writes only under `.ufo/waves/round-34/build/` (deliverable, `ExecGate.md`, three receipts). Scratch `/fast/scratch/hyaku/kagi-r34/ExecGate/` (TMPDIR exported to its `tmp/`, EXIT trap set; the trap did not survive the job harness teardown, so an explicit `rm -rf` closed it out) — fixtures created only as `mktemp -d` + `git -C "$D" init -q` with `rev-parse --show-toplevel` asserted before any commit. Sibling receipts `base-new.txt`/`selftest-new.txt` in this directory belong to other seats; untouched.
