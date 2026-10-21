# Round 24 C1 — FPolicyPath fresh falsification

## Scope and axes

- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Axes: C1 operability was attacked. C2 freshness and C3 calibration were not assessed; no saturation or overall-round conclusion is made.
- One canonical runtime was exercised: `corpus/claim-ledger.sh` in a no-hardlinks clone at the frozen revision. No real-lane gate, host/private path, account, handler, or network operation was used.
- LSP route unavailable (`xd://lsp` returned “No such tool”); no semantic references/definitions/diagnostics were obtained.
- No tools installed; no production files changed. Scratch only: `/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9`.

## Fresh isolated probe

`env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9/empty-home git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9` → success (`Cloning into …` / `done.`); `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9/empty-home git -C /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9 checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0` → success (`HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`). Then `mkdir -p /fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9/empty-home`. The fixture had inert scripts/files only.

Command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9/empty-home bash path-probe/run-probe.sh` (exit 0; `PROBE_COMPLETE cases=18`). `bash corpus/control.sh control` and declared host-free `bash corpus/drift-pins.sh --selftest` both returned exit 0/CLEAN and hit only their fixture stubs. Ordinary `~`, absolute, `..`, `bash -o`, quoted `'-o'`, `bash -c`, `bash --`, single-backslash, direct host-script and direct final-symlink forms returned POLICY exit 2 without executing their fixture scripts.

## Findings (severity ordered)

### HIGH — shell glob hides Bash `-c` and bypasses host-script classification

At `corpus/claim-ledger.sh:259`, `bash-option` checks only literal text beginning `bash` + optional quote + `-`; `invoked_script()` at `196-212` tokenizes the unexpanded command text. In the fixture, a file named `-c` made the command `bash ?c 'bash corpus/drift-pins.sh glob-option-host'` expand to Bash inline mode after the lexical checks. It returned exit 0, `CLAIM_LEDGER: CLEAN`, and the inert `drift-pins.sh` stub logged `glob-option-host`. The `?` glob is not rejected by `META_RE` (`238`) or by the option check, and the host guard never sees the expanded nested script. This falsifies fail-closed option/host-script screening; literal `bash -o` selftest at `1346`, `1580` does not cover expansion.

### HIGH — attached option values evade absolute/parent-path rejection

`policy_check()` scans whitespace-split words at `274-282`, rejecting a word beginning `/`, `~`, `=` followed by `/`, or `..` at selected path boundaries. It does not parse option-attached filenames such as grep `-fFILE`. On the fixture, `grep -c -f/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyPath-9/path-probe/outside/patterns.txt corpus/ok.txt` and `grep -c -f../outside/patterns.txt corpus/ok.txt` each returned exit 0/CLEAN. Both read only the probe’s own `outside/patterns.txt`, not host/private data. The paired controls `grep -c --file=/…` and bare `/…`, `~…`, `../…` were refused (the existing `--file=/etc/hostname` selftest row is at `1336`). Thus path policy blocks tested spellings, not all file operands that cross the root.

### HIGH — ancestor-directory symlink bypasses the script symlink guard

The guard at `523-527` checks only `[[ -L $ROOT/$INV_SCRIPT ]]` on the final script path. The host allowlist is lexical/exact (`174`); `invoked_script()` normalizes `./`, repeated `/`, and `/./` but does not resolve symlinked ancestors (`196-212`). With fixture symlink `corpus/hostalias -> .`, `bash corpus/hostalias/drift-pins.sh host-parent-alias` returned exit 0/CLEAN and ran the declared host-script stub (hit `host-parent-alias`); `test -L corpus/hostalias/drift-pins.sh` was false although it resolves to `corpus/drift-pins.sh`. A separate `corpus/linked -> ../../outside` fixture alias likewise ran the inert out-of-root payload. The existing direct-final-component symlink case (`1347-1348`, `1581`) correctly refused its alias but does not cover symlinked parents.

### MEDIUM — host-free `cells` match is a prefix, not a closed argument vector

The `claim-ledger.sh` host-free branch accepts `cells --root corpus/fixtures/` followed by arbitrary text (`175-185`). CLI parsing allows later `--root` options to replace earlier ones (`286-307`, especially `295`). The committed `build/ProbeHostEvasion.md:19` records a fixture run where extra `cells` arguments were accepted and the stub ran; this was not rerun in this probe. Treat the special-case as an unclosed classifier, not proof of a safe fixture-only invocation. The `host-free-mode-runs` selftest (`1576`) checks a different script/argument pair, not this cells vector.

## Receipt, residual bounds, and verification gaps

- `tripwire-after.txt:1-5` records `HOST_TRIPWIRE … rev=735123d53238 … total=0 complete=4/4` for its declared 12-row host population. The receipt measures the direct population through four complete `verify`/`cells` runs; it is not evidence against the glob, attached-file, ancestor-symlink, or prefix-vector bypasses above. The frozen source’s `claim-ledger.sh` matches that receipt tree for these reviewed changes.
- Confirmed fail-closed lexical cases: literal tilde/absolute/dotdot, common literal Bash options, single backslash, and a direct script symlink. Untested: other shell expansion forms and option-specific path syntax. No full selftest was run; relevant new selftests were read at `1332-1348` and `1572-1581`.
- No independent LSP callers/diagnostics review was possible. The findings are from the frozen script, cited selftest definitions, committed probe/receipts, and the isolated fixture outputs above.
