# `op-ref-probe.sh`: host-surface classification

Static source review only; no host mode was executed. Findings below are from `corpus/op-ref-probe.sh` and `corpus/claim-ledger.tsv` at the frozen lane tree. An LSP device was unavailable (`read xd://lsp` returned “No such tool”); grep was used to locate text, with classification based on the read source sections.

## Entry points and reads

The parser recognizes `--selftest`, `--dotenv-bytes`, `--evaluate FILE`, `--fixture DIR`, and `-h|--help`; default mode is `verify` (`corpus/op-ref-probe.sh:63-70,753-789`). The last `--selftest`/`--evaluate` wins; `--dotenv-bytes` stays set. `--help` exits as soon as parsed. `--fixture` is retained for the final mode. This normalizes all flag orders to the modes below.

| Invocation / normalized mode | Class | Read/process evidence and limits |
|---|---|---|
| No flags; `--fixture DIR` only → `verify` | **HOST** | With no fixture, creates local generated fixtures (`:160-205`, `:472-490`), but still checks for `op` (`:483-484`), checks `$HOME/.local/bin/the-janitor` (default path `:70`, executable test `:485-486`), then runs `op` (`:243-265`, `:322-347`) and the janitor (`:297-298,304-314`). A supplied fixture replaces generated inputs and is read/guarded at `:209-240,482`; absolute/external fixture paths are not rejected by this script. |
| `--evaluate FILE` → `evaluate` | **HOST-FREE only for a repo/scratch-local input; otherwise HOST** | No `op` or janitor call in this branch. It opens the caller-supplied file through `awk`/`get_field` and input redirection (`:356-360,363-441`); an absolute/external `FILE` therefore makes this a host-path read. Without byte mode, an optional `--fixture DIR` first invokes `guard_op_side` (`:778-787`), which stats its named files and `grep`s existing regular files (`:209-240`); local fixture paths remain repo/fixture-only, external paths are HOST. No path-containment check exists in this script. |
| `--selftest` alone | **HOST-FREE** | Uses `mktemp` fixtures and generated observations (`:595-668,672-742`), and its nested calls are the probe's own `--evaluate` cases. The two verify setup cases override `OP_REF_OP_BIN` / `OP_REF_JANITOR_BIN` with nonexistent paths (`:664-668`); they do not call the real tools. It does not enter `verify` or call `op_exec`/`refs_rows`. `$HOME` is interpolated into the unused default `JAN_BIN` at startup (`:70`), but no HOME file test is reached in this exact mode. |
| `--selftest --fixture DIR` (either flag order) | **HOST-FREE for a repo/scratch-local DIR; HOST for an external DIR** | The pre-dispatch guard runs before selftest (`:778-784`) and scans the supplied directory (`:209-240`). Selftest does not otherwise consume it. A bare-script-name exception must not silently bless an arbitrary fixture path. |
| `--dotenv-bytes` without `--evaluate` | **HOST** | Generates its own dotenv fixtures under `mktemp` and isolated scratch HOME/XDG directories (`:519-551`, especially `:528-544`). Nevertheless it resolves and invokes the `op` executable (`:521-526,258-265`); `env -i` and scratch HOME prevent inherited HOME/XDG state, but do not make the external `op` process host-free. This is the explicit `op` surface in the user's classification. No direct socket/network call appears in this script; runtime behavior of `op` is not statically established here. |
| `--dotenv-bytes --evaluate FILE` (either flag order) | **HOST-FREE only for a repo/scratch-local input; otherwise HOST** | This branch calls only `evaluate_bytes`, which reads `FILE` (`:766-775,493-517`); it does not call `dotenv_bytes` or `op_exec`. The byte-mode policy rejects any `--fixture` and rejects when the final mode is selftest (`:766-775`). Absolute/external `FILE` remains a HOST read. |
| `-h` / `--help` | **HOST-FREE** | `usage` reads this script's own header through `sed` (`:157`), then the parser exits immediately (`:760`). Normal ledger spelling is repo-relative `corpus/op-ref-probe.sh`; invoking the script itself by an external absolute path is outside that repo-only assumption. |
| Unknown option / byte mode with `--fixture` or final `--selftest` | **Rejected, not an executable mode** | Unknown args fail in the parser (`:760-762`). Byte mode rejects fixture/selftest combinations before evaluating a file or invoking `op` (`:766-775`). |

The guard checks op-side fixture files for reference tokens and refuses symlink/non-regular files and invalid probe premises (`:209-240`), but that is not a general host-path prohibition. Normal verify inherits the caller's environment for `op` (`:263-265`); the byte runner instead sets scratch HOME/XDG (`:258-262`). The script contains no transcript or `~/.config` path read; the source evidence for direct host surfaces is `$HOME`/janitor and `op` above.

## Ledger rows invoking this script

Only these three `corpus/claim-ledger.tsv` rows invoke it (`:26-27,51`):

| Row | Command / mode | Class | Current note tag |
|---|---|---|---|
| R12-01 | `bash corpus/op-ref-probe.sh` → live verify | HOST | `[substrate]` |
| R12-02 | `bash corpus/op-ref-probe.sh --selftest` | HOST-FREE | none |
| R21-01 | `bash corpus/op-ref-probe.sh --dotenv-bytes` → live `op` | HOST | **none (untagged)** |

R21-01 is an untagged HOST row under the explicit rule that invoking the `op` CLI is host access, even though this arm uses `env -i` and scratch HOME/XDG. Recommend `[host]` for R21-01, rather than `[substrate]`: it invokes `op` but does not use the handler. R18-01 is the already-known untagged host row elsewhere in the ledger; no other probe row is untagged HOST. The existing ledger classifier currently treats exact `--dotenv-bytes` as host-free (`corpus/claim-ledger.sh:174-185`), which conflicts with the source path above.

## Allowlist recommendation

Use mode-aware parsing plus path confinement, not the script name alone. Safe forms are:

1. Exactly `--selftest` (the current R12-02 form).
2. Exactly `-h` or `--help`.
3. `--evaluate FILE`, with optional `--fixture DIR`, only when every supplied path resolves to a regular repo/scratch fixture without a symlink escape.
4. `--dotenv-bytes --evaluate FILE` or `--evaluate FILE --dotenv-bytes`, with no `--fixture`, only when `FILE` resolves to a regular repo/scratch fixture without a symlink escape.

Do **not** allow bare `--dotenv-bytes`, default verify, or any other verify invocation. Do not allow unvalidated path arguments merely because the mode is `--evaluate` or `--selftest`; `op-ref-probe.sh` accepts arbitrary paths, while the ledger's current command guard only rejects `~`, absolute paths, and `..` components (`corpus/claim-ledger.sh:268-278`) and does not establish symlink containment. The narrow current `host_free_args` allowlist accepts `--selftest` and `--dotenv-bytes` but blocks the safe help/evaluate forms and wrongly exempts R21-01 (`corpus/claim-ledger.sh:175-185,211`). No current ledger row uses the evaluate-only forms, so allowing them requires a validated local input; `corpus/fixtures/` currently has only the cells-hermetic fixture set, not a probe observation file.

**Confidence:** high for control-flow and direct process/file accesses from static source. **Unresolved:** actual `op` runtime network/sign-in/config behavior is intentionally unobserved; no host mode was run.