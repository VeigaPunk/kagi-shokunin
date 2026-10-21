# SentSelfCounts — self-count ledger-binding security review

**BASE:** `0a47dd189356ea66ec83c3891eed54526e95b89b`  
**Scope:** static review of `corpus/self-counts.py`, `corpus/claim-ledger.tsv`, and the directly relevant row scripts/policy. References below are BASE `path:line` citations.  
**Verdict:** the explicit `[host]`/`[substrate]` rows are refused by the binder. One existing untagged row, `R21-01`, is not safe to bind as an executed `ledger:` source when the caller environment is not trusted: an environment override selects the executable that the byte-mode row runs, despite its `env -i` child environment. The binder also relies on row-note tags rather than applying the ledger gate’s host-script classification.

## Findings

### MEDIUM — `R21-01` can execute an environment-selected binary

- **Exploit path:** bind `ledger:R21-01` to a matched knowledge number. The row has no host/substrate tag and is `bash corpus/op-ref-probe.sh --dotenv-bytes` (`corpus/claim-ledger.tsv:51`). `self-counts.py` allows the `bash` command and starts it with `subprocess.run(..., shell=False)` but no `env=` argument, so it inherits the caller environment (`corpus/self-counts.py:255-275, 287-303`). The script reads `OP_REF_OP_BIN` into `OP_BIN` (`corpus/op-ref-probe.sh:69`), resolves that value with `command -v` (`corpus/op-ref-probe.sh:519-526`), then executes the selected binary in byte mode (`corpus/op-ref-probe.sh:258-264, 542-549`). The `env -i` wrapper clears environment variables for the child, but it does not constrain the already-selected executable or sandbox its filesystem/network access.
- **Why the current refusals miss it:** the note is untagged, so `ledger_command`'s tag check passes (`corpus/self-counts.py:255-275`). The binder’s nested scanner only recognizes literal nested `bash`/`python3` commands and only adds recursion/release-observe refusals; it is not a general shell-script command or executable-identity policy (`corpus/self-counts.py:183-223, 226-252`). The separate claim-ledger policy explicitly treats this exact `op-ref-probe.sh --dotenv-bytes` mode as host-free (`corpus/claim-ledger.sh:189-199`), so that policy would not catch a substituted `OP_REF_OP_BIN` either.
- **Impact:** if an untrusted or unintended `OP_REF_OP_BIN` is inherited, the selected program runs as the invoking user and can read any same-user host-private files it can access or make network requests. This is a conditional capability finding, not a claim that the default `op` executable contacted a service. The documented generated plain-value fixtures avoid passing reference tokens to `op`; they do not constrain a substituted executable.
- **Smallest remediation:** do not use `ledger:R21-01` for a knowledge binding; use `expect:R21-01` where a committed pin suffices (the `expect:` path reads the pin and executes nothing: `corpus/self-counts.py:342-348`). If live execution is required, remove/reject `OP_REF_OP_BIN` for this path and bind only a trusted, fixed executable identity.

### LOW — host protection is a note-tag check, not the ledger’s host-command policy

- **Exploit path:** if a host-reading ledger command loses its `[host]`/`[substrate]` note marker, a new `ledger:<ID>` binding can pass the current binder. `ledger_command` checks the literal marker, then the small command-token allowlist, self-count recursion, host-consent and release-observe conditions; it does not call the host-script classification in `claim-ledger.sh` (`corpus/self-counts.py:226-275`). The binder executes the command directly (`corpus/self-counts.py:287-303`). By contrast, `claim-ledger.sh` declares a host-reading-script list and refuses an untagged host invocation (`corpus/claim-ledger.sh:121-129, 184-200, 555-565`).
- **Concrete counterexample / control:** at BASE, `R18-01` is correctly marked `[host]` (`corpus/claim-ledger.tsv:48`), and its script enumerates `$HOME/.config/the-janitor/op.env`, private state files and other `$HOME` paths (`corpus/drift-pins.sh:45-62`). `R11-06` is also marked `[substrate]` (`corpus/claim-ledger.tsv:20`) and its default input is the handler transcript database under `$HOME/.local/state/the-janitor/xdg-data/opencode/opencode.db` (`corpus/transcript-scan.sh:34-35`). These current rows are refused; omission of a marker would bypass the binder’s only host-specific test, even though the claim-ledger verifier has a separate untagged-host refusal.
- **Impact:** an accidental or malicious reclassification of an existing host-reading row can turn a knowledge-number binding into a same-user file read. Current BASE row tags prevent that for the identified rows, but the refusal is not independent of the ledger note being evaluated.
- **Smallest remediation:** have `self-counts.py` enforce the same host-script/host-free-argument classification as `claim-ledger.sh`, or use a positive allowlist of reviewed host-free ledger IDs. Keep the note-tag check as an additional guard, not the sole one.

### Informational — children inherit the caller’s execution environment

The count runner does not pass a sanitized environment to child processes (`corpus/self-counts.py:287-293`). Therefore the safe classification below assumes a trusted invocation environment and ordinary trusted executables; a caller-controlled `PATH` (or shell/Python startup environment) can alter child behavior independently of the row text. I did not inspect the invoking process environment. **[INFERENCE]** This is a general runner boundary, not a finding that a specific BASE row reads a secret by default.

## Row classification at BASE

`ledger:<ID>` executes the ledger row command only for a located, unambiguous binding; `expect:<ID>` reads the committed output pin instead (`corpus/self-counts.py:306-323, 342-355`). “Safe” here means the committed command paths showed no host-private read or network operation under a trusted caller environment; it is not a claim of OS isolation.

### Unsafe by current row declaration, but refused by `self-counts.py`

- `[substrate]`: `R11-01`, `R11-02`, `R11-03`, `R11-04`, `R11-06` (`corpus/claim-ledger.tsv:15-20`); `R12-01` (`corpus/claim-ledger.tsv:26`); `R13-03` (`corpus/claim-ledger.tsv:38`); `R15-01` (`corpus/claim-ledger.tsv:33`); `R16-01`, `R16-03` (`corpus/claim-ledger.tsv:39-41`); `R17-01` (`corpus/claim-ledger.tsv:45`).
- `[host]`: `R18-01` (`corpus/claim-ledger.tsv:48`).
- The refusal is explicit and occurs in `ledger_command` before process launch (`corpus/self-counts.py:255-260`); `check` applies source policy before it attempts to locate the number (`corpus/self-counts.py:315-323`). Its selftest source contains host/substrate and host-unlocated refusal cases (`corpus/self-counts.py:444-449`), but I did not run that selftest.

### Unsafe to bind as a live `ledger:` source; **not** refused today

- `R21-01` — environment-selected executable route above (`corpus/claim-ledger.tsv:51`). This is the only untagged BASE row I found with a concrete host/private or network-capable execution path in its reviewed command mode.

### Refused for recursion, not for a host/network read

- `R23-01` (`corpus/claim-ledger.tsv:59`) invokes `claim-ledger.sh cells`; the binder refuses `cells`/`verify` recursion (`corpus/self-counts.py:267-272`).
- `R25-02` (`corpus/claim-ledger.tsv:81`) invokes `self-counts.py` without the exact allowed `--selftest` argv, so the recursive self-count refusal applies (`corpus/self-counts.py:226-230`).

### Safe for the host-private/network question, under the stated environment assumption

`R11-05`, `R11-07`–`R11-11`; `R12-02`–`R12-03`; `R13-01`–`R13-02`; `R14-01`; `R15-02`–`R15-05`; `R16-02`, `R16-04`–`R16-06`; `R17-02`–`R17-03`; `R18-02`–`R18-03`; `R21-02`–`R21-04`; `R22-01`–`R22-04`; `R23-02`; `R24-01`–`R24-16`; `R25-01`, `R25-03`–`R25-04` (rows at `corpus/claim-ledger.tsv:19, 21-25, 27-32, 34-37, 40, 42-44, 46-47, 49-50, 52-58, 60, 64-79, 80, 82-83`). These are local count/selftest/audit commands or offline `release-clock.py` invocations as written. `R11-08`’s citations mode can probe sibling/fleet checkout paths for reference existence, so it performs a broader local filesystem existence check than a strictly repo-confined command; I found no host-private path or network operation in that command mode.

The current release-clock ledger rows do not request observation. The binder refuses `--observe` and its argparse prefixes (`corpus/self-counts.py:160-168, 233-250`); the claim-ledger policy also calls out the network mode (`corpus/claim-ledger.sh:279-283`). Do not generalize that refusal to arbitrary scripts: it is specifically a release-clock mode check.

## What I did not check

- I did not execute any ledger row, `self-counts.py`, selftest, build, gate, or runtime check; no checks are reported as passing.
- I did not read host-private files, inspect the actual `OP_REF_OP_BIN`/`PATH` environment or executable, contact `op`, a vault, any account, or any network endpoint.
- I did not test malicious ledger mutations, symlink races, or every possible hostile caller-environment configuration. Findings about substituted executables and inherited startup environments are static capability analysis only.
- The worktree contains Round-27 data changes relative to BASE; this report’s classifications and citations are anchored to the frozen BASE, not those later edits.
