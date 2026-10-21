# Round 24 C1 — untagged-host evasion probe

## Scope and retained evidence

- Only this report was written in the lane. No tool was installed or updated.
- Scratch: cloned `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` with `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24/seats/ProbeHostEvasion-2 && git -C /fast/scratch/kagi-r24/seats/ProbeHostEvasion-2 checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (tool returned success). Then copied the current `corpus/claim-ledger.sh` candidate into that clone and ran it there; all seven host paths under the probe root were replaced with inert logging stubs, and `HOME=/fast/scratch/kagi-r24/seats/ProbeHostEvasion-2/empty-home`.
- `HOME=/fast/scratch/kagi-r24/seats/ProbeHostEvasion-2/empty-home bash /fast/scratch/kagi-r24/seats/ProbeHostEvasion-2/corpus/claim-ledger.sh --selftest` → exit 0, `SELFTEST: PASS (138 cases)`.
- `HOME=/fast/scratch/kagi-r24/seats/ProbeHostEvasion-2/empty-home bash /fast/scratch/kagi-r24/seats/ProbeHostEvasion-2/run-host-probes.sh` used a scratch-only claim row per case and captured child-stub logs. No real host mode ran. Direct spelling probes were refused with exit 2 and `reason=untagged-host`; result details below.
- LSP was unavailable in the exposed tool set (no LSP route); this is not an empty symbol/reference result.

## Findings

**Direct lexical aliases are covered by the candidate.** `bash ./corpus/drift-pins.sh`, `bash corpus//drift-pins.sh`, `bash corpus/./drift-pins.sh`, `bash 'corpus/drift-pins.sh'`, quote-stitched `bash cor'pus/'drift-pins.sh`, `bash -x corpus/drift-pins.sh`, and `bash -- corpus/drift-pins.sh` each returned exit 2, `POLICY … reason=untagged-host script=corpus/drift-pins.sh`, and no stub log. `bash corpus/drift-pins.sh --selftest --x` was likewise refused. The exact declared `bash corpus/drift-pins.sh --selftest` control ran only the stub and returned exit 0/CLEAN.

**Critical Bash-option parsing bypass.** `invoked_script()` skips every word beginning `-` as a Bash option, but Bash options `-o` and `-O` consume a following operand; lines 203–205 therefore mistake `posix`/`extglob` for the script. Scratch rows `bash -o posix corpus/drift-pins.sh` and `bash -O extglob corpus/drift-pins.sh` both returned exit 0/CLEAN and logged the drift stub. More seriously, `bash -o posix -c 'bash corpus/drift-pins.sh'` also returned exit 0 and logged the stub: the existing `bash -c` refusal only checks the command prefix. The control `bash -c 'bash corpus/drift-pins.sh'` was refused exit 2 as `inline-shell`. The same option-operand bypass ran the checklist stub, which delegated to the drift stub.

**Aliases beyond lexical spelling are not covered.** With inert stubs, `bash corpus/renamed.sh` (copy of the drift stub), `bash corpus/alias.sh` (symlink to it), and `bash corpus/relay.sh` (stub wrapper invoking it) each returned exit 0/CLEAN and logged execution. This establishes a limitation of the direct path-list match, not execution of copied real host code. A direct `bash corpus/checklist-run.sh` row was refused as `untagged-host` before the stub ran; that wrapper is explicitly listed and its real E1 check delegates to surface-census and drift-pins (`corpus/checklist.tsv:26`).

**Host-free arguments need a closed vector.** `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md` returned exit 0/CLEAN and ran the stub: `host_free_args()`'s `cells --root corpus/fixtures/` prefix wildcard admits arbitrary trailing switches (`corpus/claim-ledger.sh:183-184`). The actual hermetic R23-01 row has a specific set of `--claims`, `--stamps`, `--scorecard`, and `--docs` paths (`corpus/claim-ledger.tsv:59`); retain that exact full-row control, but refuse an added/changed argument or prove every canonical input remains under the committed fixture root. By contrast, `surface-census.sh --selftest` is not safe to whitelist just because it builds fixtures: its selftest conditionally runs the real handler through `--verbs` (`corpus/surface-census.sh:816-845`); current conservative refusal is appropriate.

## Minimal rule

After the existing simple-command policy has rejected metacharacters, backslashes and disallowed paths, parse the actual restricted argv rather than skipping arbitrary `-` words. Safest small contract: accept only `bash <script> <args…>` with no pre-script options, or implement Bash's operand-taking options explicitly; always reject `-c`/`-s` wherever they occur before the script operand. Normalize the script operand as a repo-relative path by stripping repeated leading `./`, collapsing repeated `/` and `/./` components, and refusing `..`; compare the **whole normalized `corpus/<name>.sh` path** against the host list, never basename-only. Resolve/reject symlinks relative to the command's `--root` before matching. Match host-free modes against complete argv vectors (no trailing wildcard); for the current cells fixture, keep the exact R23-01 vector.

A path normalizer cannot identify a byte-copy under a new name or an arbitrary wrapper that invokes a host script. If the claim is meant to include those semantic aliases, fail closed on unclassified Bash script targets (review/allowlist targets as host or host-free) and classify known wrappers transitively; otherwise explicitly narrow the policy claim to direct invocation. Do not imply that `realpath` alone detects copies or wrappers.

## Proposed selftest `tcase` additions

For each command below, expect exit 2, a POLICY refusal, and **no stub log**, except noted controls. Use the real fixture row for `cells-exact` and stub targets as in the probe.

| tcase | Command / expected |
|---|---|
| `untagged-dot-prefix` | `bash ./corpus/drift-pins.sh` → `untagged-host`, normalized path |
| `untagged-double-slash` | `bash corpus//drift-pins.sh` → `untagged-host` |
| `untagged-dot-segment` | `bash corpus/./drift-pins.sh` → `untagged-host` |
| `untagged-quoted`, `untagged-quote-stitched` | `bash 'corpus/drift-pins.sh'`; `bash cor'pus/'drift-pins.sh` → `untagged-host` |
| `untagged-bash-x`, `untagged-bash-end-options` | `bash -x corpus/drift-pins.sh`; `bash -- corpus/drift-pins.sh` → `untagged-host` |
| `untagged-hostfree-extra` | `bash corpus/drift-pins.sh --selftest --x` → `untagged-host`; paired exact `--selftest` control runs stub only (exit 0) |
| `untagged-bash-o-operand`, `untagged-bash-O-operand` | `bash -o posix corpus/drift-pins.sh`; `bash -O extglob corpus/drift-pins.sh` → refusal/no stub |
| `untagged-bash-c-after-option` | `bash -o posix -c 'bash corpus/drift-pins.sh'` → refusal/no stub; direct `bash -c '…'` remains an `inline-shell` control |
| `untagged-checklist-delegator` | `bash corpus/checklist-run.sh` → `untagged-host`, no delegated stub; exact safe list/ratio/selftest modes are positive controls |
| `untagged-renamed-copy`, `untagged-symlink-alias`, `untagged-relay` | `bash corpus/renamed.sh`, `bash corpus/alias.sh`, `bash corpus/relay.sh` → reject unclassified target (or document narrower direct-only scope); stub invocation is the failure signal |
| `untagged-ledger-cells-real` | `bash corpus/claim-ledger.sh cells` → `untagged-host` |
| `hostfree-cells-exact`, `untagged-cells-extra-option` | exact R23-01 fixture command stays allowed; append/change an argument (including `--scorecard …`) → refusal, not prefix-wildcard allow |
| `policy-inline-shell-control`, `policy-denied-word-control`, `policy-host-path-control` | `bash -c '…'` → `inline-shell`; `bash corpus/drift-pins.sh rm` → `denied-verb:rm`; `bash corpus/../corpus/drift-pins.sh` / absolute target → `host-path` |

Evidence anchors: target host list/host-free cases at `corpus/claim-ledger.sh:173-185`; tokenization and incomplete Bash-option scan/path normalization at `:188-220`; existing metachar/deny/quote-strip/path checks at `:231-278`; refusal before execution at `:505-515`; existing selftests at `:1318-1325` and `:1553-1564`; frozen requirement at `plans/round-24.md:13-25`.