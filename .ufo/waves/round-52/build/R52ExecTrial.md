# R52ExecTrial — C1 reference trial & counter execution (operability)

## Method
- Scratch: `$S=/fast/scratch/hyaku/kagi-r52/R52ExecTrial` (created, explicit in all commands). Lane base for tree: predeclaration `52ebb412561d9601ad8658c30d1cfa0087af64d4`.
- Tree build (assignment order):
  - `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 52ebb412… | tar -x -C $S/tree` — rc 0. Tree alone has no trial/entry/S110 (`ls` no such file, `grep -c S110` 0), as expected at predeclaration (K1-P fixture stage).
  - Then K1-P fixture exactly as `plans/round-52-controls.sh` `c1_ref`/`add_row`: `cp` reference trial + entry from `.ufo/waves/round-52/controls/fixtures/ref/corpus/`, append S110 row (status `mined`, same `$S110_ROW` string as controls.sh:19) after `| S109 ` row. Verified: `grep -c '^| S110 '` = 1 (receipt `R52ExecTrial/k1p-s110-count.txt`); trial 10593 B, entry 5417 B (`k1p-files.txt`).
- Pinned binary check (pre-run): `sha256sum ~/.local/bin/bao` = `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (matches counter `PIN_BAO`); `bao version` = `OpenBao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379)`. `~/.local/bin/bao` untouched; no pacman run; no tool install needed.
- Refusal boundary: all servers were the trial's own throwaway `bao server -dev` on 127.0.0.1 with random port/root token in scratch env; no token/secret printed, copied or committed; no `~/.config/sops`/`~/.ssh`, no 1Password/vault contact, no op:// paths; no fixed port.
- Driver: `$S/run.sh` (bash, `set -u`, `trap 'rm -rf -- "$S/dump"' EXIT`); after each run `pgrep -af "bao server" | grep -F "$S"` asserted no survivor.

## Receipts (dir `.ufo/waves/round-52/build/R52ExecTrial/`, exact command + rc + last line + wall clocks in each `*.rc.txt`)

### C1 counter ×2: `bash plans/round-52-c1.sh --tree $S/tree`
| run | rc | wall (s) | last line (verbatim, `c1-run<n>.txt`) |
|---|---|---|---|
| c1-run1 | 0 | 35.14 | `C1_OPENBAO_KV: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=31,real2=31) src=1(S110) real_rc=0 none_rc=2 T1:real=HOLDS/HOLDS,shimvec=BHHHH,entry=1,ok=1 T2:real=HOLDS/HOLDS,shimvec=HBHHH,entry=1,ok=1 T3:real=HOLDS/HOLDS,shimvec=HHBHH,entry=1,ok=1 T4:real=HOLDS/HOLDS,shimvec=HHHBH,entry=1,ok=1 T5:real=HOLDS/HOLDS,shimvec=HHHHB,entry=1,ok=1` |
| c1-run2 | 0 | 29.45 | identical to run1 (see `c1-run2.txt`) |

Both runs: `setup_ok=1` (the counter's own `none` run exited 2), `nosecret=1`, `noargv=1` with 31 recorded bao calls in each real run (≥20 required), `src=1(S110)`, `pins=1`, every shim vector matches plan `EXPECT_VEC` (BHHHH/HBHHH/HHBHH/HHHBH/HHHHB). pgrep after each counter run: no surviving `bao server` with scratch path.

### Reference trial alone ×3: `bash $S/tree/corpus/openbao-kv-versions-trial.sh --work $S/w<n>`
| run | rc | wall (s) | summary line (verbatim) |
|---|---|---|---|
| trial-run1 | 0 | 4.30 | `OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` |
| trial-run2 | 0 | 4.31 | `OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` |
| trial-run3 | 0 | 4.94 | `OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` |

All three full outputs identical: T1 HOLDS (cas0-on-existing-refused=1 cas-current-accepted=1 stale-cas-refused=1), T2 HOLDS (deleted-data-null=1 deletion-time-set=1 undelete-restores-value=1), T3 HOLDS (after-destroy-and-undelete data-null=1 destroyed=1), T4 HOLDS (version1-dropped=1 version2-kept=1 version3-kept=1), T5 HOLDS (version1-gone=1 version2-gone=1 metadata-gone=1). pgrep after each: none.

### No-bao PATH run (corrected)
First attempt `env -i PATH=$S/empty-bin:/nonexistent … bash` failed rc=127 `env: ‘bash’: No such file or directory` — that tested env's bash lookup, not the trial; recorded then superseded. Corrected run: `env -i PATH=/usr/bin:/bin HOME=$S/w1 bash $S/tree/corpus/openbao-kv-versions-trial.sh --work $S/w1` → rc=2, wall 0.011 s, `OPENBAO_KV_TRIAL: SETUP no bao on PATH`, HOLDS-line count 0. (Confirmed `ls /usr/bin/bao /bin/bao` → No such file, so PATH genuinely lacks bao while providing bash.) Receipts `trial-nobao.txt`, `trial-nobao.rc.txt`.

## Verdict
**value=5 reproduces** on this host, twice, with the pinned binary: all five mechanics T1–T5 discriminate (both real runs HOLDS ×2 and the exact falsifier vectors), pins/setup/nosecret/noargv/src all 1. Trial is deterministic across 3 solo runs (~4.3–4.9 s each; counter ~29–35 s, well under the 70–120 s budget — likely because solo trial runs reuse a warm cache/binary and the counter's 8 runs each re-exec the trial but the host is fast). No `bao server` processes started by this seat survive (checked per-run via scratch-path pgrep). At final check `pgrep -af "bao server"` showed two dev servers (127.0.0.1:0 and 127.0.0.1:44849) whose cmdlines do not contain this seat's scratch path — other concurrent seats' servers, deliberately not killed (blind `pkill bao` forbidden).

## Findings / weaknesses (frozen instruments — reported, not edited)
1. Trial solo runtime ~4–5 s vs counter's ~30 s makes the plan's "70–120 s per counter run" estimate conservative, not wrong; no action.
2. Seat brief's no-bao recipe (`PATH` lacking bao) must still contain bash/coreutils; an empty PATH hits `env: bash: No such file` (rc 127) before the trial starts. The counter's own `none` mode already covers this correctly via its dispatcher bin dir. Not a defect in the frozen counter/trial.

## Risks / blockers
- None for operability. Concurrency: other seats' `bao server -dev` instances were running concurrently; random-port selection avoided collisions (all runs rc 0).
- Frozen files untouched: no edits under `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `README.md`, `QUALITY`, `SOURCES.md`, registries, `MANIFEST.json`, `templates/`, `scripts/`, `.ufo/state`, `.ufo/watchdog.log`. Writes confined to `.ufo/waves/round-52/build/R52ExecTrial{,/*.txt}` and `$S`. No git mutating commands run in lane or fleet.
- Tooling installs: none (no new tools; `python3` used only for wall-time arithmetic, system tool).

## Files changed
- `.ufo/waves/round-52/build/R52ExecTrial.md` (this report; exists early and updated after first result)
- `.ufo/waves/round-52/build/R52ExecTrial/` receipts: `c1-run{1,2}.{txt,rc.txt,pgrep.txt}`, `trial-run{1,2,3}.{txt,rc.txt,pgrep.txt}`, `trial-nobao.{txt,rc.txt}`, `k1p-{s110-count,files}.txt`, `timings.txt`, `trial-nobao2.sh` (rerun helper script kept as receipt method)
- Scratch only (not lane): `/fast/scratch/hyaku/kagi-r52/R52ExecTrial/{tree,w1,w2,w3,nobin,empty-bin,run.sh}` — tree/w dirs remain for parent inspection; no secrets inside (trial work dirs hold only dev-server state from throwaway tokens, no plaintext real secrets; tokens were dev-only, never printed/committed).
