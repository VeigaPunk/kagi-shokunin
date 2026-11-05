# K44SentinelScope — confinement & scope attack, round-44 instruments at ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae

Seat: K44SentinelScope (sentinel, leaf — no delegation used). Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (master), never edited. Sandbox: /fast/scratch/hyaku/kagi-r44/K44SentinelScope/work, `git clone --shared` + `checkout --detach ae9e9eb`, `git rev-parse --show-toplevel` = sandbox work dir (verified before writes). Instruments under attack: plans/round-44-c1.sh, -c2.sh, -c3.sh, -controls.sh; nested runtime chain inspected for footprint/containment: plans/round-43-c2.sh, corpus/controls-replay.sh, plans/round-42-controls.sh, plans/round-41-controls.sh (r41/r42 counters grepped for scratch discipline). Instrument sha256 at ae9e9eb:

```
050801ae95c87d49ea57125234a6ce76e1b6ddf774839f687caf1e4ae546f293  plans/round-44-c1.sh
e3aff85dd13c2b1df899a93d97e4cae2c79ffe920e22bc2bac8ab699a1b07be5  plans/round-44-c2.sh
53ac204198c37de9ba2483c50b49d948e0fe4ebc08ec865bb7e89e92e34f7c4e  plans/round-44-c3.sh
b0c680116db8caeeabfd868ff429c68408e01fc4405fc95ee7bb32f8f189036f  plans/round-44-controls.sh
```

## Item results

### 1. Scratch discipline, traps, write scope, rm audit — PASS (1 info defect class)
- Scratch roots honour the override: c1 `battery.$$`, c2 `receipt.$$`, c3 `register.$$` (all `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r44/…`); nested r43-c2 `c2-counter.$$`, controls-replay `controls-replay.$$`, r42/r41 controls runners `kagi-r42|r41/controls.$$`. Proven live: full battery ran with `HYAKU_SCRATCH=<sandbox>/scr` — every write landed inside it (peak sampler saw activity only there).
- No `${TMPDIR:-/tmp}`, no bare `/tmp`, no unanchored `mktemp` in any of the 8 scripts (grep zero hits); c3's only `mktemp` is `mktemp "$SCR/rows.XXXXXX"` — inside its scratch.
- Traps: c1:59, c2:30, c3:40, r43-c2, replay gate, r42/r41 runners all set `trap 'rm -rf -- "$SCR"' EXIT` immediately after mkdir; every later path (rc 0 / 1 / 2, incl. all fail-closed exits) fires it. Residual after the full battery: 0 MB, only the empty shared parent dirs `kagi-r41/42/43/44` (see F2).
- rm audit — every removal traces to bytes the same process created this run: `rm -rf -- "$SCR"` (own scratch, ×6 scripts); c3:91 `rm -f "$SCR/clone/$P1" "$SCR/clone/$P2"` (its own clone, immediately re-created + restored byte-identically, cmp-enforced); replay gate's extras-cleanup `rm -f -- "$C42|$C41/$f"` deletes only files inside the clone it was handed that the runners wrote during step (d) (snapshot taken before, restored first). No script ever removes pre-existing or external bytes.
- Write scope: c1/c2/c3 write only `$SCR` + their own `$SCR/clone`; runners write only `$OUT` inside the repo whose `plans/` dir they live in (base mode: the sanctioned lane controls dir; in clones: scratch-local). Runtime-verified: `git status --porcelain` before/after the full battery differs by exactly 2 tracked files under `.ufo/waves/round-44/controls/` (`c1-base` 0→2 re-measured at the predeclaration, `measured-at.txt`) — nothing else in the clone, nothing outside clone+scratch.

### 2. Nested-clone footprint — BOUNDED, --shared only
- Every `git clone` in the chain is `git clone -q --shared` (c1:74, c2:63, c3:83, r43-c2:33); the r42/r41 runners never clone (they use `git archive | tar -x` into their own scratch + run counters that live in the clone they were invoked in). Object stores of shared clones are 0 bytes (verified `git count-objects -vH` in the sandbox clone: in-pack 0, size 0) — no object mirror anywhere; only working trees are copied.
- Live census across the full 8-cap battery (~56 du samples, 2 s cadence): **peak scratch footprint 895 MB, max 4 live shared clones** (containment/samples-summary.txt). Analytical worst chain ≈ 5 tree copies (~150 MB each): battery clone + nested counter clone + its two `cp -a` stale/silent fixture copies + one nested r42-c2 clone. Depth ≤ 4 clones (battery → counter → replay runners → r42-c2); width bounded by the fixed 7-leg matrix. No whole-lane object mirror in any build dir; my deliverable dir holds receipts/text only.
- All fixture tree copies (`cp -a` in r43-c2, `git archive` extractions in r42/r41 runners) live under the scratch root and die with the traps.

### 3. Battery run against the predeclaration — reproduced, contained
`bash plans/round-44-controls.sh base ae9e9eb…` in the sandbox clone (exit 0; full receipt set copied to `receipts-base-at-ae9e9eb/`, sha256s in README):

| cap | rc | last | expect (plan, measured at d54109d) | note |
|---|---|---|---|---|
| c1-base | 0 | **2** | 0 | expected divergence: at ae9e9eb the battery bytes EXIST (self-compare passes) → full discrimination reading; equals the frozen `c1-real` target. The plan's 0 is the d54109d battery-absent value. |
| c1-skipfix | 0 | 0 | 0 | matches; also proves the `VAR=x cap` env prefix reaches the counter child (gate swap took effect) |
| c2-base | 0 | 0 | 0 | |
| c2-forged-sha | 0 | 0 | 0 | |
| c2-forged-rev | 0 | 0 | 0 | |
| c3-base | 0 | 0 | 0 | |
| c3-pos | 0 | 3 | 3 | executes the PIN re-derivation legs |
| c3-wrongvals | 0 | 1 | 1 | |

Containment observed on that run: porcelain delta = the 2 expected controls-dir files only; `/tmp` + `/var/tmp` before/after deltas contain **zero instrument-attributable entries** (only unrelated host noise: a Chromium `scoped_dir*`, an automount `.mount_*`, the harness's `omp-shell-snapshots-*`); filtered `-newer run-start` listing empty; residual scratch 0 MB. The battery is strace-free observed per assignment (porcelain + tmp snapshots + scratch sampler, no ptrace).

### 4. CAND argument injection — counters fail closed (PASS)
Observed (verbatim in `injection-probes.txt`; sandbox clone at ae9e9eb):

- `bash plans/round-44-c{1,2,3}.sh '--help'` → **rc 2, 0 stdout bytes** (×3); `'--help'` reaches git only as the quoted rev-string `--help^{commit}` → unknown-option error (stderr, suppressed) → refused.
- `/etc/passwd` and `HEAD:plans` → **rc 2, 0 stdout bytes** (×6) — not revisions.
- `''` (empty) → falls back to `HEAD` of the repo the file lives in (documented default): c2/c3 read **0** at the predeclaration, rc 0.
- `round-44-controls.sh` with MODE `--help` → usage, **rc 2, 0 stdout**. But REV `--help` → **rc 0** — Finding F1 below.
- Injection surface audit: CAND is only ever expanded inside double quotes into git rev positions (`$CAND^{commit}`, `$CAND:path`, merge-base arg); c2's receipt revision is regex-gated `^[0-9a-f]{40}$` before any other use; c3's register-supplied superseded-by path is anchored as `"$CAND:$SUP"` → cannot become a git option and is only existence-tested (`cat-file -e`), never written or executed; no eval, no unquoted expansion, no arithmetic on inputs anywhere in the four scripts.

### 5. Host hygiene — CLEAN
Word-boundary sweep over all 8 scripts (4 instruments + 4 nested runners) for sysctl/systemctl/service/pacman/apt/brew/curl/wget/ssh/nc/netcat/http/ftp/rsync/scp/sudo/pkill/reboot/shutdown/crontab/systemd-run: **zero hits**. All git operations are local-object (clone of local paths, cat-file, show, rev-parse, merge-base, status, grep, archive, checkout --detach); the only subprocess is round-41-controls.sh's local `git show`. No network path exists in the chain. (I installed no tools; no pacman/uv/npm use — nothing to record beyond the operator's standing authorization.)

## Findings

### F1 — MEDIUM (fail-closed gap, evidence-set destruction): `round-44-controls.sh` accepts any REV, overwrites the committed receipt set, exits 0
- Exploit path: `bash plans/round-44-controls.sh final <typo-or-stale-rev>` (the L1's final-measurement invocation shape). REV is `=${2:-HEAD}` with **no validation**; every cap then records the counter's rc-2 refusal bytes, and the runner prints `runner done: final <rev>` with **exit 0**.
- Evidence (hit live in my sandbox, injection probe): `measured-at.txt` after `controls.sh base --help` read `revision: --help` with all eight caps `rc=2` and refusal text in the receipt files (`c1-base` = `battery-refused: candidate\n`), while the runner exited **0** (`controls rev=[--help] rc=0 stdout-bytes=478`). Base mode destroys the 8 committed receipts; final mode would destroy/write 5 — a stale-tip typo could land garbage as the round's final receipts with a green exit.
- Impact: silent evidence-set destruction; kill-rule re-measurements and the L1's copy step consume whatever bytes sit there; only a human diffing `expect=` vs `rc=` in measured-at.txt would notice. Violates the lane's own fail-closed convention the three counters implement.
- Smallest remediation (one guard, after `REV=` assignment): `git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || { echo "runner-refused: revision" >&2; exit 2; }`. Optional hardening: have `cap` compare rc/last against `expect` and make the runner exit nonzero on any mismatch (keeps receipts, turns the green exit red). Related sub-point: `cap` merges stderr into receipts (`2>&1`), so rc-2 refusals break the "receipt = ONE unsigned integer" byte contract — the REV gate removes the main path to that state. Also fold in: `mkdir -p -- "$OUT"` is unchecked (F3), so an uncreatable output dir degrades the run to scattered redirect failures instead of one clean rc 2.

### F2 — INFO (cleanup residue): scratch parent namespace persists; pre-trap mkdir window
- Leaf scratch dirs are always trap-removed (0 MB residue verified), but nothing removes the shared parent dirs `kagi-r41/42/43/44` created by `mkdir -p` — empty-dir accumulation across rounds on the scratch root (observed: `scr` residue = 4, `scr2` = 1 empty parent). Same class: if `mkdir -p -- "$SCR"` itself fails, exit 2 fires before the trap exists (no leaf is created then; only parents may persist).
- Impact: cosmetic; no data, no growth beyond empty dirs. Remediation if wanted: append `rmdir -- "${SCR%/*}" 2>/dev/null` inside the trap (rmdir is empty-only, safe under concurrency).

### F3 — INFO (scoped observation): c3's restore duty covers only P1/P2
- After deleting P1/P2 and re-running `round-42-controls.sh`, c3 restores byte-identity for P1/P2 (cmp-enforced) but not for the other four receipts the runner rewrote in its PIN clone. The clone is scratch, trap-deleted on exit, and the frozen predicate checks only P1/P2 + the row-3 sweep — no lane or evidence impact. Named so nobody later byte-compares that clone's controls dir against committed state and calls it drift.

### F4 — INFO (portability ceiling): python3 hard dependency in c1 (mutant recipes) and round-41-controls.sh (decoy build)
- Absent python3 → c1 fails **closed** (rc 2, `battery-refused: recipes`), so correctness is preserved; this is a named portability ceiling, not a defect.

### Verified non-defects (attacked, held)
- **env-prefix through `cap`**: `R44_SKIP_FIXTURES=1 cap …` reaches the counter child (c1-skipfix=0 vs c1-base=2 proves the gate swap fired) and does **not** persist after the function (empirical `V=1 f` → V unset after) — no cross-cap leakage between the eight caps.
- **Bash quirk exploited by nobody**: `${1:-$(git rev-parse HEAD)}` means an omitted arg measures HEAD of the invoked file's repo — in final mode the L1 runs counters from the landing clone, so HEAD=landing; base mode always passes REV explicitly. Documented default, bounded blast radius.
- **c2 receipt parsing**: 4-line shape enforced, R 40-hex-gated, ancestor check via merge-base, double hash binding (S vs candidate gate AND vs R's gate bytes) — forged fixtures both read 0, re-verified at the predeclaration.
- **c3 structural gate**: exactly 3 rows in frozen order else rc 2; register cells only ever flow into `grep -qF`/`awk -F`/`case`/quoted rev-string — no eval surface; disposition paths are existence-checked only.
- **c1 self-binding**: battery refuses (rc 2) if the candidate's `plans/round-44-c1.sh` bytes differ from the invoked file — the battery measures only trees that carry it verbatim; recipes assert exactly-once markers and post-conditions (`assert '"$N1"' not in y1`), failing closed.
- **Replay gate restore**: deletes all files in the two controls dirs of the clone it is handed, re-derives via both committed runners, byte-checks the 8 manifest receipts, restores the snapshot and removes runner extras — pre-run bytes fully recovered inside an ephemeral clone; no path out of `<dir>` + scratch.

## Honesty / method notes
- My first concurrent probe batch overwrote the sandbox clone's committed receipt bytes (`controls.sh base --help` — the F1 behavior, hit unintentionally mid-collection). Detected via `measured-at.txt` (`revision: --help`), disclosed here, and the battery was re-run cleanly and serially; the deliverable receipts are from the clean rerun (`measured-at: 2026-11-05T19:20:23Z`). The lane tree was never touched by any of this.
- The execution harness terminated my multi-statement capture blocks at the first nonzero pipeline rc; all subsequent evidence collection used guarded (`|| true`) commands. The original run's cap table (identical values) is in this seat's transcript.
- Not re-measured (final-mode-only, L1's job at the candidate): `c1-partial` (`R44_ONLY_FIXTURE=stale` → expect 1). Unrun checks are not claimed.

## Evidence index (this dir)
- `receipts-base-at-ae9e9eb/` — the 8 receipts + measured-at.txt from the clean battery rerun at the predeclaration (sha256s in `README.md`).
- `containment/` — porcelain before/after, /tmp & /var/tmp before/after, footprint sampler summary (peak 895 MB, ≤4 live shared clones).
- `injection-probes.txt` — verbatim observed probe results.
- Report trailer path: `.ufo/waves/round-44/build/K44SentinelScope.md` (this file).

SEAT-STATUS: complete
