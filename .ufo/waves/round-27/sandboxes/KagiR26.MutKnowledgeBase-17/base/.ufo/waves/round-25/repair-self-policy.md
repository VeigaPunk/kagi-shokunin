# Self-count policy repair

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b`; fresh candidate checkout: `/fast/scratch/kagi-r25/KagiR25.XSelfCounts-2/repair`.

Changed only `corpus/self-counts.py` in that sandbox. Patch: `.ufo/waves/round-25/patches/self-policy-repair.patch` (23,477 bytes; SHA-256 `d496e1700343ef838493f545892709cda5d50a45b6df432e5fb3fe1ab00edcbd`). No lane production files, index, or jj state changed.

## Changes
- `corpus/self-counts.py:20-27` preserves the reviewed-repo trust boundary and states the best-effort transitive-wrapper scan limit.
- `:155-180,226-252` refuses ordinary self-counts re-entry; only exact `python3 corpus/self-counts.py --selftest` is exempt. Refuses inline `bash -c`/combined `bash` c-options and `python3 -c`; refuses `release-clock.py` `--observe` and argparse prefixes (including `--obs`) in ledger argv. Walks root-local literal bash/Python wrapper calls and refuses detected transitive self-counts, inline, and observe invocations. No claim of a complete hostile-code sandbox.
- `:192-223` inspects literal shell command lines and Python subprocess argv-list calls in wrappers without executing them during policy evaluation.
- `:307-360` labels `expect:<ID>` comparisons `pinned=N`; row and executed ledger sources remain `live=N`.
- `:556-572` confines relative `--table` paths through `repo_path` (rejects symlink escapes); explicit absolute table paths remain supported.
- `:378-548` extends synthetic witness/control coverage for exact selftest exception, normal/options re-entry refusals, bash/python inline refusal, release observe and `--obs`/`--ob`, transitive shell/Python observe, transitive self-count re-entry, pinned labels, relative table symlink escape, and absolute external-table control.

## Authorized verification
Only the isolated selftest was run, as directed:
```text
cwd=/fast/scratch/kagi-r25/KagiR25.XSelfCounts-2/repair
COMMAND: env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.XSelfCounts-2/home TMPDIR=/fast/scratch/kagi-r25/KagiR25.XSelfCounts-2/tmp PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/self-counts.py --selftest
EXIT: 0
STDOUT: SELF_COUNTS_SELFTEST: PASS (48 cases)
```
Patch export used `git -C /fast/scratch/kagi-r25/KagiR25.XSelfCounts-2/repair diff -- corpus/self-counts.py` (exit 0); its output was written to the assigned patch path. Patch-application check and all other checks are UNRUN, per instruction.

No installs or updates. No credentials, host operations, network access, or external-state changes. LSP was unavailable in the mounted tool inventory; this repair is confined to the existing script and its internal synthetic selftest.