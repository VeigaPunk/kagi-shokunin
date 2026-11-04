# ExecDomain — round 35 safe domain receipt

Axes: measurement fidelity, credential isolation, bounded scope.

## Trigger → action → outcome → handoff

- **Trigger:** frozen round-35 plan permits only the generated plain dotenv probe as live domain work. Read `plans/round-35.md`, `AGENTS.md`, `corpus/QUALITY.md`, and `.ufo/waves/round-35/controls/measure.py`. Initial literal `controls/measure.py` lookup failed; resolved the wave-local instrument and read it before executing the probe. The nine-case calibration counter was not executed by this seat.
- **Action:** read `corpus/op-ref-probe.sh:133-144,209-271,492-554,766-788`; executed exactly once with explicit scratch TMPDIR and the installed op binary pinned below. No fixture override, clone, production edit, git/jj operation, installation, account command, handler invocation, or credential/reference read was performed.
- **Outcome:** exit **0**, six PASS case lines, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`. Process stderr was empty. This is the observed domain-probe verdict, not evidence that round-35 C1's separate nine-case predicate passed.
- **Handoff:** L1 may retain this receipt as the bounded live domain observation. Parent owns candidate integration and the frozen calibration counter. Non-owned SD6 and R25-02 FAIL / R29-01 and R29-02 POLICY boundaries remain untouched; this receipt does not clear them.

## Exact invocation and identity

Host: current Linux executor supplied by this assignment; no cross-host inference.

Installed CLI lookup: `command -v op` returned `/usr/bin/op`, rc0. `op --version` returned `2.41.1`, rc0. No installs or updates; install channel/reason not applicable. Agent install rules were read; no package transaction occurred.

Script: `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/op-ref-probe.sh`

`sha256sum` observed: `0f1945e8d8a8fc56aaee256180cd7badde466bc8ac91503aa1e1853e79044f4c`.

Cwd: `/fast/scratch/hyaku/kagi-r35/ExecDomain`

```sh
TMPDIR=/fast/scratch/hyaku/kagi-r35/ExecDomain/tmp OP_REF_OP_BIN=/usr/bin/op bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/op-ref-probe.sh --dotenv-bytes
```

Return code: `0`.

Complete process stdout:

```text
DOTENV_BYTES_CASE id=escaped-lf status=PASS
DOTENV_BYTES_CASE id=trailing-lf status=PASS
DOTENV_BYTES_CASE id=newline-only status=PASS
DOTENV_BYTES_CASE id=single-literal status=PASS
DOTENV_BYTES_CASE id=double-multiline status=PASS
DOTENV_BYTES_CASE id=single-multiline status=PASS
OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)
```

Complete process stderr: empty (0 bytes).

## Safety and limits

The inspected arm generates only plain `KAGI16_VALUE` fixtures under `mktemp -d`, whose parent is the explicit TMPDIR. Every env-file passes the regular-file/non-symlink and reference-token guard before op launch. `op_exec` uses `env -i`, isolated HOME/XDG directories, disabled biometric unlocking and cache, and a ten-second timeout per invocation. The byte-mode dispatch rejects external fixture mode and does not enter the handler-backed verify arm.

These are source-inspected isolation properties, not a network trace or universal guarantee about an external binary. No network instrumentation was run and no network-contact claim is inferred from CLEAN. The installed 2.41.1 CLI matched all six literal expectations; the script's general comments cite older measurement versions, so this receipt establishes only these six cases on this installed CLI. The script internally redirects individual op stderr to temporary files and its EXIT trap removes them; the preserved empty stderr is the outer process stream, not proof that every internal op stderr stream was empty.

No LSP tool is exposed in this seat; no symbol refactor was needed. No unrelated build, lint, formatter, selftest, or calibration gate was run. No production documentation/changelog update is applicable to this evidence-only assignment.

## Retained artifacts and cleanup

All durable artifacts are restricted to the explicitly permitted seat directory (the conflicting sibling `ExecDomain.md` report destination was not used):

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecDomain/report.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecDomain/run.json`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecDomain/stdout.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-35/build/ExecDomain/stderr.txt`

Scratch deletion is recorded separately in `cleanup.txt` after durable receipts. No blocker to the assigned domain run.

## Self-evaluation

Accuracy 4/5: raw process streams and rc retained; no independent network trace, explicitly not claimed. Completeness 5/5: version, hash, exact command/cwd/env, output, rc, guards and handoff retained. Clarity 4/5: report repeats output already in receipts for direct auditability. Actionability 5/5: L1 has exact bounded evidence and the separate C1 gate remains its responsibility. Conciseness 4/5: repeated absolute artifact paths are intentional for fleet custody. Overall 4.4/5. Improvement: avoid redundant narrative and retain the network-observation distinction in summaries. Would the user agree? The evidence supports the scoped completion, not broader calibration success.

Report: .ufo/waves/round-35/build/ExecDomain/report.md
