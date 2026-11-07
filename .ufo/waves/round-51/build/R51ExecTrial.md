# R51ExecTrial — C1 candidate measurement + SIGKILL safety

Seat: R51ExecTrial. Report: `.ufo/waves/round-51/build/R51ExecTrial.md`
Receipts: `.ufo/waves/round-51/build/R51ExecTrial/`
Scratch: `/fast/scratch/hyaku/kagi-r51/R51ExecTrial`

Axes: operability — C1 counter green on reference tree, BASE absent, SIGKILL leaves no surviving server.

## Method
Tree = `git archive 214d8bf530a0c87c00686493f21af15396284793` + reference trial copied to `corpus/openbao-wrap-trial.sh` + S108 row inserted after the last registry row of `corpus/SOURCES.md` + `entry-section.md` appended to `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (mirroring `ref_tree()` in `plans/round-51-controls.sh`). Counter: `plans/round-51-c1.sh`.

## 1. C1 tree runs (×3)
Command: `bash plans/round-51-c1.sh --tree <tree>` (exit 0 each; receipts `c1-tree-1.txt`..`c1-tree-3.txt`)
All three final lines (identical):
```
C1_OPENBAO_WRAP: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 src=1(S108) real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
```
Acceptance: **PASS** — each prints `value=5`.

## 2. C1 on BASE
Command: `bash plans/round-51-c1.sh 214d8bf530a0c87c00686493f21af15396284793` (exit 0; receipt `c1-base.txt`)
```
C1_OPENBAO_WRAP: value=0 absent=1 pins=1
```
Acceptance: **PASS**.

## 3. SIGKILL safety (×2)
Trial started in background under `env -i HOME=<scratch> PATH=/home/vgpnk/.local/bin:/usr/bin:/bin` + unique `MY_NONCE`; server found by matching its `/proc/<pid>/environ` to the nonce; trial shell SIGKILLed (rc=137); after 5 s, check `/proc/<srvpid>` existence and starttime (field 22 of `/proc/<pid>/stat`).
- Run 1 (receipt `kill-1.txt`): trial=2422820 server=2423360 starttime=37956808 → after-5s `alive=no`
- Run 2 (receipt `kill-2.txt`): trial=2457114 server=2457615 starttime=37957329 → after-5s `alive=no`
The server dies with the trial — trial runs it under `setpriv --pdeathsig KILL`. Acceptance: **PASS**.
Cleanup: my leftover `bao server -dev` count = 0 (a remaining `bao server -dev` seen at one probe belonged to a sibling seat's counter — HOME under `R51MutCounters` scratch — and was left untouched per no-blind-pkill rule).

## 4. Wall time
One full trial run: **6.24 s** (receipt `time-run.txt`; `OPENBAO_WRAP_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`).

## Notes / risks
- No new tools installed; no lane files written outside scope (only report + receipts).
- C1 counter output is stable across repeats (no flake observed in 6 tree runs total this session).
- SIGKILL safety relies on the trial's `setpriv --pdeathsig KILL` wrapping the server launch; verified empirically twice.

SEAT-STATUS: complete
